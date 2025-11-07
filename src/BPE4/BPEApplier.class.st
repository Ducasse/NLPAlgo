Class {
	#name : 'BPEApplier',
	#superclass : 'Object',
	#instVars : [
		'words',
		'tokens',
		'pairPositions'
	],
	#category : 'BPE4',
	#package : 'BPE4'
}

{ #category : 'adding' }
BPEApplier >> addToPairsPosition: aPair [
	"Ajoute la position associée à une paire dans le dictionnaire des positions."

	pairPositions 
		at: aPair key 
		update: [ :set| set add: aPair value; yourself ] 
		initial: (Set with: aPair value) 
]

{ #category : 'apply' }
BPEApplier >> applyRulesFrom:aBPE [
	|merges|
	merges := aBPE merges.
	merges do: [ :each| (self pairPositions includesKey: each key) ifTrue: [ self update: each key ] ]
]

{ #category : 'nodes' }
BPEApplier >> collectPairFrom: aNode [
	self addToPairsPosition: (self extractPairAndPositionFrom: aNode )
]

{ #category : 'adding' }
BPEApplier >> computePairs [
	"Parcours la liste chaînée des mots pour construire toutes les paires possibles."
	
	| current |
	current := self words firstLink.
	[ current nextLink notNil ] whileTrue: [
		current nextLink value buildPairFrom: current in: self.
		current := current nextLink.
		].
]

{ #category : 'nodes' }
BPEApplier >> extractPairAndPositionFrom: aNode [
"Construit et renvoie une association représentant la paire formée par le nœud donné et son suivant, ainsi que leurs références dans la liste chaînée."
	|pairAndPosition |
	pairAndPosition := Association key: { aNode value subword . aNode nextLink value subword } value: {aNode . aNode nextLink }.
	^pairAndPosition
]

{ #category : 'pretokenisation' }
BPEApplier >> fromText: aText [
	self words: aText .
	self computePairs 
]

{ #category : 'nodes' }
BPEApplier >> fusion: anArray [
"Concatène les sous-mots du premier et du second nœud référencés dans le vecteur fourni, en mettant à jour le sous-mot du premier nœud, puis supprime le second nœud de la liste chaînée."
	anArray first value subword: (anArray first value subword , anArray second value subword ).
	words removeLink: anArray second .
]

{ #category : 'initialize' }
BPEApplier >> initialize [ 
	super initialize .
	words := DoubleLinkedList new.
	pairPositions := Dictionary new.
	tokens := Bag new .
]

{ #category : 'accessing' }
BPEApplier >> pairPositions [ 
	^ pairPositions 
]

{ #category : 'pretokenisation' }
BPEApplier >> prepareWordsFrom: anObject [

	| bag |
	anObject isArray ifTrue: [
		bag := anObject asBag ].
	anObject isString ifTrue: [ 
		bag := self pretokenization: anObject ].
	^ bag
]

{ #category : 'accessing' }
BPEApplier >> pretokenization:aText [
"Transforme le texte en un bag de tokens en séparant les mots."
	|rawWords bag|
	bag := Bag new.
	rawWords :=(aText substrings: {Character space . Character cr . Character tab}).
	bag addAll: (rawWords collect: [:each|
		|col|
		col:=OrderedCollection new: each size + 1 .
		each do: [:aChar|col add: aChar asString].
		col ] ).
	^bag
]

{ #category : 'accessing' }
BPEApplier >> tokens [
	|current token|
	current := self words firstLink .
	[ current isNotNil ] whileTrue: [ 
		token := OrderedCollection new.
		[ current value class ~= EndOfWord ] whileTrue: [ 
			token add: current value subword .
			current := current nextLink .
		 ].
		tokens add: token withOccurrences: current previousLink value occurence .
		current := current nextLink .
	 ].
	^tokens 
]

{ #category : 'update' }
BPEApplier >> update: anArray [
	"Met à jour toutes les occurrences, les positions d’une paire donnée et ses voisines dans la liste     chaînée, effectue la fusion, et ajout de nouvelles paires."
	
	| position |
	position := pairPositions at: anArray.
	position do: [ :each|
		each first value updatePairFromNode: each first previousLink in: self.
		each second nextLink value updatePairFromNode: each second in: self.
		self fusion: each .
		each first value buildPairFrom: each first previousLink in: self.
		each first nextLink value buildPairFrom: each first in: self.
		].
	self pairPositions removeKey: anArray ifAbsent: [  ].
]

{ #category : 'update' }
BPEApplier >> updatePairFrom: aNode [
	self updatePairPositionsWith: (self extractPairAndPositionFrom: aNode )
]

{ #category : 'update' }
BPEApplier >> updatePairPositionsWith: anAssociation [
"Supprime les positions associées à une paire et supprime la clé dans la dictionnaire pairesPosition si l'ensemble des positions est vides."
	self pairPositions at: anAssociation key update: [:set| set remove: anAssociation value ifAbsent:[] ; yourself ].
	(self pairPositions at: anAssociation key)size =0 ifTrue: [ self pairPositions removeKey: anAssociation key ]
]

{ #category : 'accessing' }
BPEApplier >> words [ 
	^words 
]

{ #category : 'adding' }
BPEApplier >> words: anObject [
	|text|
	text:=self prepareWordsFrom: anObject .
	text associationsDo: [ :each|
			each key do:[:char|
			words add: (Subword subword: char asString occurence: each value)].
		words add: (Subword subword: '</t>' occurence: each value).
		words add: EndOfWord new ].
	^words
]
