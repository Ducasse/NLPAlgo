Class {
	#name : 'Token',
	#superclass : 'Object',
	#instVars : [
		'token',
		'occurence',
		'position'
	],
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'nil' }
Token class >> token: aToken [

	|token|
	token := self new.
	token token: aToken .
	^token 
]

{ #category : 'as yet unclassified' }
Token class >> token: aString occurence: anInteger [
	|aToken|
	aToken := Token new.
	aToken token: aString.
	aToken occurence: anInteger.
	^aToken . 
]

{ #category : 'as yet unclassified' }
Token class >> token: aString occurence: anInteger position: aLink [
	|aSubword|
	aSubword := self new.
	aSubword token: aString.
	aSubword occurence: anInteger.
	aSubword position: aLink .
	^ aSubword
]

{ #category : 'comparing' }
Token >> = aSubword [
	self class = aSubword class ifFalse: [ ^ false ].
	^ self token = aSubword token .
]

{ #category : 'operations' }
Token >> addPairAffectedByMergeWith: aToken in: aBPE [ 

"Ajout des paires affectes par la fusion dans la variable d'instance affectedPairSet de WordPiece."

	aBPE addToAffectedPairSet: { self token . aToken token }
	 
]

{ #category : 'operations' }
Token >> addPairsScoreWith: aSubword in: aBPE [

"ajout de nouveaux paires dans la variable d'instance pairsScores de WordPiece."

	aBPE addNewPairScoresFrom: self and: aSubword

]

{ #category : 'operations' }
Token >> createPairWith: aSubword in: aBPE [

"ajout de nouveaux paires dans les variables d'instance pairs et pairPositions de BPE."

	aBPE addNewPairFrom: self and: aSubword

]

{ #category : 'comparing' }
Token >> hash [
    ^ self token hash
]

{ #category : 'initialize' }
Token >> initialize [ 
	super initialize .
	token := String new.
	occurence := SmallInteger 
]

{ #category : 'accessing' }
Token >> occurence [
	^occurence 
]

{ #category : 'accessing' }
Token >> occurence: anInteger [
	occurence := anInteger 
]

{ #category : 'accessing' }
Token >> position [
	^ position 
]

{ #category : 'accessing' }
Token >> position: aLink [
	position := aLink 
]

{ #category : 'accessing' }
Token >> token [
	^token
]

{ #category : 'accessing' }
Token >> token: aString [
	token := aString 
]

{ #category : 'operations' }
Token >> tryAddPairAffectedByMergeWith: anObject in: aBPE [
"Essaie d'ajouter une paire dans affectedPairSet de WordPiece en déléguant l’opération
à anObject, si celui-ci n'est pas nil."
		
	anObject ifNil: [ ^self ].
	anObject addPairAffectedByMergeWith: self in: aBPE 
]

{ #category : 'operations' }
Token >> tryAddPairsScoreWith: anObject in: aBPE [
"Essaie d'ajouter une paire dans pairsScores de WordPiece en déléguant l’opération
à anObject, si celui-ci n'est pas nil."

	anObject ifNil: [ ^self ].
	anObject addPairsScoreWith: self in: aBPE 
	
	

]

{ #category : 'operations' }
Token >> tryToCreatePairWith: anObject in: aBPE [
"Essaie d’ajouter une paire dans pairs et pairPositions de BPE en déléguant l’opération
à anObject. Ne fait rien si anObject est nil."

	anObject ifNil: [ ^self ].
	anObject createPairWith: self in: aBPE 
	
	

]

{ #category : 'operations' }
Token >> tryToUpdatePairWith: aToken in: aBPE [
"Essaie de mettre à jour une paire dans pairs et pairPositions de BPE en déléguant l’opération
à anObject, si celui-ci n'est pas nil."

	aToken ifNil: [ ^self ].
	aToken updatePairWith: self in: aBPE
	
]

{ #category : 'operations' }
Token >> updatePairWith: aToken in: aBPE [
"Mises à jour d'une paire dans pairs et pairPositions de BPE en déléguant l’opération
à anObject, si celui-ci n'est pas nil."

	aBPE updatePairFrom: self and: aToken 
	
]
