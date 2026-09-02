Class {
	#name : 'BPEEncoder',
	#superclass : 'BPETrain',
	#instVars : [
		'rules',
		'pairScore'
	],
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'adding' }
BPEEncoder >> addNewPairFrom: aToken and: aToken1 [

"Ajout d'un nouveau pair formée par aSubword et aSubword1 dans pairPositions"

	(merges includesKey: {aToken token . aToken1 token}) ifTrue: [ 
		pairScore 
		add: (Association key: {aToken token . aToken1 token} value: (merges at: {aToken token . aToken1 token}) ).
		merges removeKey: {aToken token . aToken1 token}].
			
	pairPositions at: { aToken token . aToken1 token} 
						update: [:set| set add: { aToken position . aToken1 position } ; yourself ] 
						initial: (Set with: { aToken position . aToken1 position })
]

{ #category : 'as yet unclassified' }
BPEEncoder >> applyRulesTo: inpuText from: aFileName [
	
	|tokens|
	self corpus: inpuText .
	self loadMerges: aFileName .
	self computePairs .
	tokens := OrderedCollection new .
	
	[ pairScore notEmpty ] whileTrue: [ 
	|pair|
	pair := pairScore first key.
	(pairPositions includesKey: pair) ifTrue: [self update: pair].
	pairScore removeFirst ].
	
	corpus linksDo: [ :link | ( link value class ~= EndOfWord ) ifTrue: [ tokens add: link value token ] ].
	
	^ tokens
	
											
	
]

{ #category : 'adding' }
BPEEncoder >> corpus: anObject [
	| wordSequences |
	
	wordSequences := Preprocessing preprocess: anObject .
	wordSequences do: [ :word|
			word do: [ :char |
			corpus add: (Token token: char asString) .
			corpus lastLink value position: corpus lastLink ].
		corpus add: (Token token: '</t>').
		corpus lastLink value position: corpus lastLink .
		corpus add: EndOfWord new ].
	^ corpus 
	

]

{ #category : 'initalization' }
BPEEncoder >> initialize [ 

	super initialize .
	pairScore := Heap sortBlock: [ :a :b | a value > b value ].
]

{ #category : 'as yet unclassified' }
BPEEncoder >> loadMerges: aFileName [
 
	merges := Dictionary new.
	merges := STON fromString:
    (aFileName , '.ston')  asFileReference contents.
]

{ #category : 'accessing' }
BPEEncoder >> pairScore [ 

	^ pairScore 
]

{ #category : 'accessing' }
BPEEncoder >> rules [ 

	^ rules 
]

{ #category : 'update' }
BPEEncoder >> updatePairFrom: aToken and: aToken1 [

	pairPositions
		at: {
				aToken token.
				aToken1 token }
		update: [ :set |
				set
					remove: {
							aToken position.
							aToken1 position }
					ifAbsent: [ ];
					yourself ].

	(pairPositions at: {
			 aToken token.
			 aToken1 token }) size = 0 ifFalse: [ ^ self ].
	pairPositions removeKey: {
			aToken token.
			aToken1 token }.
]
