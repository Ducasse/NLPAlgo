Class {
	#name : 'Preprocessing',
	#superclass : 'Object',
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'nil' }
Preprocessing class >> preprocess: anObject [

	|p|
	p := self new.
	
	^ (p preprocess: anObject)
]

{ #category : 'pretokenisation' }
Preprocessing >> preprocess: anObject [

	(#(Set OrderedCollection Array)includes: anObject className) ifTrue: [ ^ self preprocessCollectionOfSentences: anObject ].
	anObject isString  ifTrue: [ ^ self preprocessText: anObject ].
]

{ #category : 'pretokenisation' }
Preprocessing >> preprocessCollectionOfSentences: aCollection [

	^(aCollection  collect: [ :each | self preprocessText: each ]) flatCollect: [ :each | each ].
]

{ #category : 'pretokenisation' }
Preprocessing >> preprocessText:aText [
"Transforme le texte en un bag de tokens en séparant les mots."
	|rawWords|
	rawWords :=(aText asString substrings: {Character space . Character cr . Character tab}).
	^rawWords
]
