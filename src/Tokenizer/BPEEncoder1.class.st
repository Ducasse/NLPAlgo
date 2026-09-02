Class {
	#name : 'BPEEncoder1',
	#superclass : 'BPETrain',
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'adding' }
BPEEncoder1 >> addNewPairFrom: aToken and: aToken1 [

"Ajout d'un nouveau pair formée par aSubword et aSubword1 dans pairPositions"
			
	pairPositions at: { aToken token . aToken1 token} 
						update: [:set| set add: { aToken position . aToken1 position } ; yourself ] 
						initial: (Set with: { aToken position . aToken1 position })
]

{ #category : 'as yet unclassified' }
BPEEncoder1 >> applyRulesTo: inpuText from: aFileName [
	
	|tokens|
	self corpus: inpuText .
	self computePairs .
	self loadMerges: aFileName .
	tokens := OrderedCollection new .
	
	merges do: [ :each | |pair|
		pair := each key .
		( pairPositions includesKey: pair ) ifTrue: [ self update: pair ] 
		].
	
	corpus linksDo: [ :link | ( link value class ~= EndOfWord ) ifTrue: [ tokens add: link value token ] ].
	
	^ tokens
	
											
	
]

{ #category : 'adding' }
BPEEncoder1 >> corpus: anObject [
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

{ #category : 'as yet unclassified' }
BPEEncoder1 >> loadMerges: aFileName [ 

	merges := STON fromString:
    (aFileName , '.ston') asFileReference contents.
]

{ #category : 'update' }
BPEEncoder1 >> updatePairFrom: aToken and: aToken1 [

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
