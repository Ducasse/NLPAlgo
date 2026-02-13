Class {
	#name : 'WordPieceEncoder',
	#superclass : 'BPELearner',
	#instVars : [
		'trie',
		'failureLink',
		'failurePop',
		'punctuationNode',
		'specialsCharacter'
	],
	#category : 'BPE4',
	#package : 'BPE4'
}

{ #category : 'compute' }
WordPieceEncoder >> computeFailureLinkAndFailurePop: aVocabulary [ 
"Computes the failure links and failure pops for all nodes in the trie
based on the given vocabulary."
	
	|queue currentNode r z v string |
	
	queue := CTQueue new .
	self computeTrieFromVocabulary: aVocabulary .
	queue enqueue: trie rootNode .
	r := trie rootNode findChildWithString: $# .
	r := r findChildWithString: $# .
	queue enqueue: r .
	failureLink at: punctuationNode put: nil .
	
	[ queue isEmpty ] whileFalse: [ 
		currentNode := queue dequeue .
		currentNode children valuesDo: [ :child |
			child ~= r ifTrue: [ 
				string := self labelOfPathFromRootToANode: child .
				( aVocabulary includes: string ) 
					ifTrue: [ 
						child character isAlphaNumeric ifTrue: [ failureLink at: child put: r ] 
							ifFalse: [ failureLink at: child put: punctuationNode ] .
						( failurePop at: child ) add: string ] 
					ifFalse: [ 
						z := ( failureLink at: currentNode ) .
						v := OrderedCollection new .
						[ z isNotNil and: [ ( z findChildWithString: child character ) isNil ] ] 
							whileTrue:[  
								v := v addAllLast: ( failurePop at: z ) .
								z := ( failureLink at: z ) 
								] . 
						z ifNotNil: [ 
							failureLink at: child put: ( z findChildWithString: child character ) .
							( failurePop at: child ) addAll: ( failurePop at: currentNode ) .
							( failurePop at: child ) addAll: v  
							] . 
					] .
				queue enqueue: child 
				 ] . 
			]
	 ]
]

{ #category : 'compute' }
WordPieceEncoder >> computeTrieFromVocabulary: aVocabulary [
"Builds the trie from the given vocabulary and initializes
the failure links and failure pops for each node."

	|queue currentNode|
	
	queue := CTQueue new .
	
	aVocabulary do: [ :aSubword |
		trie at: aSubword put: aSubword ] .
	queue enqueue: trie rootNode .
	
	[ queue isEmpty ] whileFalse: [ 
	   currentNode := queue dequeue . 
		self failureLink: ( Association key: currentNode value: nil ) .
		self failurePop: ( Association key: currentNode value: OrderedCollection new ) .
		( currentNode character notNil and: [ currentNode character isAlphaNumeric not ] ) ifTrue: [ specialsCharacter add: currentNode character ] .
		currentNode isLeaf ifFalse: [
			 currentNode children associationsDo: [ :association | queue enqueue: association value ] 
			]
		]
	
	
]

{ #category : 'compute' }
WordPieceEncoder >> e2EWordPiece: text [
	
	|result text1 i tokens currentNode r result1|
	result := OrderedCollection new .
	text1 := text, ' ' .
	i := 1 .
	r := trie rootNode findChildWithString: $# .
	r := r findChildWithString: $# .
	
	[ i <= text1 size ] whileTrue: [ 
		result1 := self matchLoopFrom: i in: text1 .
		tokens := result1 first .
		currentNode := result1 second .
		i := result1 third .
		( ( self isWordBoundaryAt: i in: text1 ) not or: [ ( { trie rootNode . r . punctuationNode } includes: currentNode ) not ] ) ifTrue: [ tokens := OrderedCollection with:  '<UNK>' ] .
		result addAll: tokens .
		[ i <= text1 size and: [ ( self isWordBoundaryAt: i in: text1 ) not ] ] whileTrue: [ 
			i := i + 1 ] .
		( ( text1 at: i) isAlphaNumeric not and: [ ( self isSpecialsCharacterInVocabulary: (text1 at: i) ) not and: [ (text1 at: i) isSeparator not ] ] ) ifTrue: [ result add: '<UNK>' . i:= i+1 ].
		[ i <= text1 size and: [ ( text1 at: i ) isSeparator ] ] whileTrue: [ 
			i := i + 1 ] .
		 ] .
	^ result 
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
	specialsCharacter := Set new .
]

{ #category : 'testing' }
WordPieceEncoder >> isSpecialsCharacterInVocabulary: char [

	( specialsCharacter includes: char ) ifTrue: [ ^ true ] .
	
	^ false
]

{ #category : 'accessing' }
WordPieceEncoder >> isWordBoundaryAt: anInteger in: aString [

	anInteger > aString size ifTrue: [ ^ true ].

	(anInteger > 1 and: [ (aString at: anInteger - 1) isAlphaNumeric not ]) ifTrue: [
		^ true ].

	(aString at: anInteger) isAlphaNumeric ifFalse: [ ^ true ].

	(aString at: anInteger) isSeparator ifTrue: [ ^ true ].

	^ false
]

{ #category : 'path' }
WordPieceEncoder >> labelOfPathFromRootToANode: aCTTrieNode [ 
"Builds and returns the string label corresponding to the path from the trie root to the given node by concatenating
the characters along the path."

	|path|
	
	path := self pathFromRootToANode: aCTTrieNode .
	
	^ (String streamContents: [:stream |
    path do: [:each | stream nextPutAll: each character asString ]
])

]

{ #category : 'as yet unclassified' }
WordPieceEncoder >> linMaxMatch: aString [
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
		i := i + 1 .
	] .

	^ { tokens . currentNode . i }
	
]

{ #category : 'path' }
WordPieceEncoder >> pathFromRootToANode: aNode [ 

"This method allows finding the path from the root of the trie to the node given as a parameter."

	|currentNode path|
	
	currentNode := aNode .
	path := OrderedCollection new .
	
	[ currentNode isRoot ] whileFalse: [ 
	
		path add: currentNode .
		currentNode := currentNode parent .
		
		 ].
	
	^ path reverse 
]

{ #category : 'accessing' }
WordPieceEncoder >> specialsCharacter [

	^ specialsCharacter 
]

{ #category : 'accessing' }
WordPieceEncoder >> trie [

	^ trie 
]
