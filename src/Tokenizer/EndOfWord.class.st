Class {
	#name : 'EndOfWord',
	#superclass : 'Object',
	#classVars : [
		'UniqueInstance'
	],
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'instance creation' }
EndOfWord class >> uniqueInstance [
	^UniqueInstance ifNil: [ UniqueInstance := self new ].
]

{ #category : 'operations' }
EndOfWord >> addPairAffectedByMergeWith: aSubword in: aBPE [ 
	
	^ self
]

{ #category : 'operations' }
EndOfWord >> addPairsScoreWith: aSubword in: aBPE [
	^ self
]

{ #category : 'operations' }
EndOfWord >> createPairWith: anObject in: aBPE [
	^ self 
	
]

{ #category : 'operations' }
EndOfWord >> tryAddPairAffectedByMergeWith: anObject in: aBPE [
	
	^ self
]

{ #category : 'operations' }
EndOfWord >> tryAddPairsScoreWith: anObject in: aBPE [
	^ self 
]

{ #category : 'operations' }
EndOfWord >> tryToCreatePairWith: anObject in: aBPE [
	^ self 
]

{ #category : 'operations' }
EndOfWord >> tryToUpdatePairWith: anObject in: aBPE [
	^ self 
]

{ #category : 'operations' }
EndOfWord >> updatePairWith: aSubword in: aBPE [

	^ self 
]
