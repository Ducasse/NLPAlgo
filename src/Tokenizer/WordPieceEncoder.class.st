Class {
	#name : 'WordPieceEncoder',
	#superclass : 'BPETrain',
	#instVars : [
		'trie',
		'failureLink',
		'failurePop',
		'punctuationNode'
	],
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'compute' }
WordPieceEncoder >> buildTrieAndInitializeFailureData [
"Builds the trie from the given vocabulary and initializes
the failure links and failure pops for each node."

	|queue currentNode punctuations|
	
	queue := CTQueue new .
	
	vocabulary do: [ :aSubword |
		trie 
		at: aSubword
		put: aSubword ] .
	punctuations := '~`!@#$%^&*()_=+-\|]}[{":;/?.>,<'''.
	
	punctuations do:[ :punctuation|
		(vocabulary includes:punctuation asString ) ifFalse: [ 
			trie 
				at: punctuation asString 
				put: punctuation asString ]].
	
	queue enqueue: trie rootNode .
	
	[ queue isEmpty ] whileFalse: [ 
	   currentNode := queue dequeue . 
		self failureLink: ( Association key: currentNode value: nil ) .
		self failurePop: ( Association key: currentNode value: OrderedCollection new ) .
		currentNode isLeaf ifFalse: [
			 currentNode children associationsDo: [ :association | queue enqueue: association value ] 
			]
		]
	
	
]

{ #category : 'compute' }
WordPieceEncoder >> computeFailureLinkAndFailurePop [
"Computes the failure links and failure pops for all nodes in the trie
based on the given vocabulary."
	
	|queue currentNode r prefixIndicatorNode|
	
	queue := CTQueue new .
	queue enqueue: trie rootNode .
	r := trie rootNode findChildWithString: $# .
	prefixIndicatorNode := r findChildWithString: $# .
	queue enqueue: prefixIndicatorNode .
	failureLink at: punctuationNode put: nil .
	
	[ queue isEmpty ] whileFalse: [ 
		currentNode := queue dequeue .
		currentNode children valuesDo: [ :child |
			
			child ~= prefixIndicatorNode ifTrue: [
				self computeFailureLinkAndFailurePopForANode: child parent: currentNode prefixIndicatorNode: prefixIndicatorNode.
				queue enqueue: child  ].
			
			] . 
		]
]

{ #category : 'compute' }
WordPieceEncoder >> computeFailureLinkAndFailurePopForANode: aCTTrieNode parent: parent prefixIndicatorNode: aCTTrieNode1 [

	| string failureNode tokens|
	
	string := trie labelOfPathFromRootToANode: aCTTrieNode .
	
	string isPunctuation 
		ifTrue: [ 
			failureLink
				at: aCTTrieNode 
				put: punctuationNode .
			(vocabulary includes: string)
				ifTrue: [ (failurePop at: aCTTrieNode ) add: string ]
				ifFalse: [ (failurePop at: aCTTrieNode ) add: '<UNK>' ] ]
						
		ifFalse:[
			( vocabulary includes: string ) 
				ifTrue: [ 
					failureLink
						at: aCTTrieNode
						put: aCTTrieNode1.
					(failurePop at: aCTTrieNode ) add: string ]
				
				ifFalse: [ 
					failureNode := ( failureLink at: parent ) .
					tokens := OrderedCollection new .
					
					[ failureNode isNotNil and: [ ( failureNode findChildWithString: aCTTrieNode character ) isNil ] ] 
						whileTrue:[  
							tokens := tokens addAllLast: ( failurePop at: failureNode ) .
							failureNode := ( failureLink at: failureNode ) ] .
						
					failureNode ifNotNil: [ 
						failureLink
							at: aCTTrieNode 
							put: ( failureNode findChildWithString: aCTTrieNode character ) .
						( failurePop at: aCTTrieNode ) addAll: ( failurePop at: parent ) .
						( failurePop at: aCTTrieNode ) addAll: tokens 
									] . 
								].
							].
]

{ #category : 'as yet unclassified' }
WordPieceEncoder >> encodeACollectionOfText: aCollectionOfText [
	
	^ aCollectionOfText flatCollect: [ :each | self encodeText: each ] 
	
]

{ #category : 'compute' }
WordPieceEncoder >> encodeText: aText [
	
	|result text i tokens currentNode r prefixIndicatorNode result1|
	result := OrderedCollection new .
	text := aText , ' ' .
	i := 1 .
	r := trie rootNode findChildWithString: $# .
	prefixIndicatorNode := r findChildWithString: $# .
	
	[ i <= text size ] whileTrue: [ 
		result1 := self matchLoopFrom: i in: text .
		tokens := result1 first .
		currentNode := result1 second .
		i := result1 third .
		
		( ( self isWordBoundaryAt: i in: text ) not or: [ ( { trie rootNode . prefixIndicatorNode . punctuationNode } asSet includes: currentNode ) not ] ) ifTrue: [ tokens := OrderedCollection with:  '<UNK>' ] .
		
		(currentNode = prefixIndicatorNode and: [tokens isEmpty]) ifTrue: [
			(vocabulary includes: '##')
				ifTrue: [ tokens := OrderedCollection with: '##' ]
				ifFalse: [ tokens := OrderedCollection with: '<UNK>' ]	
			].
		
		result addAll: tokens .
		
		[ i <= text size and: [ ( self isWordBoundaryAt: i in: text ) not ] ] whileTrue: [ 
			i := i + 1 ] .
		
		[ i <= text size and: [ ( text at: i ) isSeparator ] ] whileTrue: [ 
			i := i + 1 ] .
		 ] .
	
	^ result 
]

{ #category : 'as yet unclassified' }
WordPieceEncoder >> encodeWord: aString [
"Tokenizes a single word.
Returns the resulting tokens or <UNK> if the word cannot be properly tokenized."
	|string result tokens node i r|
	
	string := aString, ' ' .
	result := self matchLoopFrom: 1 in: string .
	tokens := result first .
	node := result second .
	i := result third . 
	r := trie rootNode findChildWithString: $# .
	r := r findChildWithString: $# .
	
	( i <= aString size or: [ ( { trie rootNode . r } asSet includes: node ) not ] ) ifTrue: [ 
		tokens := OrderedCollection with: '<UNK>' ] .
	
	^ tokens 
	
]

{ #category : 'accessing' }
WordPieceEncoder >> failureLink [ 

	^ failureLink 
]

{ #category : 'accessing' }
WordPieceEncoder >> failureLink: anAssociation [

	failureLink add: anAssociation 
]

{ #category : 'accessing' }
WordPieceEncoder >> failurePop [

	^ failurePop 
]

{ #category : 'accessing' }
WordPieceEncoder >> failurePop: anAssociation [

	failurePop add: anAssociation 
]

{ #category : 'initialize' }
WordPieceEncoder >> initialize [ 

	super initialize .
	trie := CTTrie new .
	punctuationNode := CTTrieNode new .
	failureLink := Dictionary new .
	failurePop := Dictionary new .
]

{ #category : 'accessing' }
WordPieceEncoder >> isWordBoundaryAt: anInteger in: aString [

	anInteger > aString size ifTrue: [ ^ true ].

	(anInteger > 1 and: [ (aString at: anInteger - 1) isPunctuation ]) ifTrue: [
		^ true ].

	(aString at: anInteger) isPunctuation ifTrue: [ ^ true ].

	(aString at: anInteger) isSeparator ifTrue: [ ^ true ].

	^ false
]

{ #category : 'as yet unclassified' }
WordPieceEncoder >> loadVocabulary: aFileName [
    vocabulary := STON fromString:
        (aFileName , '.ston') asFileReference contents.
]

{ #category : 'as yet unclassified' }
WordPieceEncoder >> matchLoopFrom: aStartingIndex in: aString [
"Scans the string from a given index using the trie and failure links to find matching subwords.
Returns the collected tokens, the current trie node, and the stopping index."

	|currentNode tokens i|
	currentNode := trie rootNode .
	tokens := OrderedCollection new .
	i := aStartingIndex .
	
	[ i <= aString size ] whileTrue: [ 
	
		[ ( currentNode findChildWithString: ( aString at: i ) ) isNil  ] whileTrue: [ 
			( failureLink at: currentNode ) ifNil: [ ^ { tokens . currentNode . i } ].
			
			tokens addAll: ( failurePop at: currentNode ) .
			currentNode := ( failureLink at: currentNode ) .
		] .
	
		currentNode := ( currentNode findChildWithString: ( aString at: i ) ) .
		i := i + 1.
	] .

	^ { tokens . currentNode . i }
	
]

{ #category : 'accessing' }
WordPieceEncoder >> trie [

	^ trie 
]
