Class {
	#name : 'BPELearner',
	#superclass : 'Object',
	#instVars : [
		'words',
		'vocabulary',
		'merges',
		'pairs',
		'pairPositions'
	],
	#category : 'BPE4',
	#package : 'BPE4'
}

{ #category : 'adding' }
BPELearner >> addToMergesPair: aCollection mergedInto: aString [

	merges add: aCollection -> aString
]

{ #category : 'adding' }
BPELearner >> addToPairs: aPair [
	"Add the pair to the pair dictionary (it keeps the pair occurrences)."
	
	pairs add: aPair key withOccurrences: aPair value
]

{ #category : 'adding' }
BPELearner >> addToPairsPosition: aPair [
	"Ajoute la position associée à une paire dans le dictionnaire des positions."
	
	self pairPositions 
		at: aPair key 
		update: [ :set| set add: aPair value; yourself ] 
		initial: (Set with: aPair value) 
]

{ #category : 'adding' }
BPELearner >> addToVocabulary: aString [

	vocabulary add: aString 
]

{ #category : 'nodes' }
BPELearner >> collectPairFrom: aNode [

	self addToPairs: (self extractPairAndOccurencesFrom: aNode).
	self addToPairsPosition: (self extractPairAndPositionFrom: aNode )
]

{ #category : 'adding' }
BPELearner >> computePairs [
"Parcours la liste chaînée des mots pour construire toutes les paires possibles."
	|current|
	current := self words firstLink .
	[current nextLink notNil ] whileTrue: [
		current nextLink value buildPairFrom: current in: self .
		current := current nextLink .
		].

]

{ #category : 'adding' }
BPELearner >> computeVocabulary [ 
	|i|
	i:=words firstLink .
	[ i notNil ] whileTrue: [ 
	[ i value class ~= EndOfWord ] whileTrue: [ 
	vocabulary add: (i value subword ).
	i:= i nextLink 
	 ].
	i:= i nextLink 
	 ]
]

{ #category : 'nodes' }
BPELearner >> extractPairAndOccurencesFrom: aNode [
"Construit et renvoie une association représentant la paire formée par le nœud donné et son suivant, ainsi que l’occurrence de la paire."
	|pairAndOccurence|
	pairAndOccurence := Association key: { aNode value subword . aNode nextLink value subword } value: aNode value occurence .
	^pairAndOccurence 
]

{ #category : 'nodes' }
BPELearner >> extractPairAndPositionFrom: aNode [
"Construit et renvoie une association représentant la paire formée par le nœud donné et son suivant, ainsi que leurs références dans la liste chaînée."
	|pairAndPosition |
	pairAndPosition := Association key: { aNode value subword . aNode nextLink value subword } value: {aNode . aNode nextLink }.
	^pairAndPosition
]

{ #category : 'public API' }
BPELearner >> fromText: aText [

	self words: aText.
	self computeVocabulary.
	self computePairs 
]

{ #category : 'nodes' }
BPELearner >> fusion: anArray [
"Concatène les sous-mots du premier et du second nœud référencés dans le vecteur fourni, en mettant à jour le sous-mot du premier nœud, puis supprime le second nœud de la liste chaînée."
	anArray first value subword: (anArray first value subword , anArray second value subword ).
	words removeLink: anArray second .
]

{ #category : 'initalization' }
BPELearner >> initialize [ 
	super initialize. 
	words := DoubleLinkedList new.
	vocabulary := Set new.
	pairs := Bag new .
	pairPositions := Dictionary new.
	merges:= OrderedCollection new
]

{ #category : 'accessing' }
BPELearner >> merges [ 
	^merges 
]

{ #category : 'merges' }
BPELearner >> mergesOneStep [ 
	
	| pair vocabulaire |
	pair := pairs sortedCounts first value.
	vocabulaire:= pair first , pair second.
	self addToMergesPair: pair mergedInto: vocabulaire.
	self addToVocabulary: vocabulaire.
	self update: pair
]

{ #category : 'accessing' }
BPELearner >> pairPositions [ 
	"Renvoie le dictionnaire dont les cles sont les paires et les valeurs sont un ensemble de positions des paires dans la liste chaînée."

	^ pairPositions 
]

{ #category : 'accessing' }
BPELearner >> pairs [ 
	"Return the bags of pairs."
	
	^pairs 
]

{ #category : 'pretokenisation' }
BPELearner >> prepareWordsFrom: anObject [

	| bag |
	anObject isArray ifTrue: [
		bag := anObject asBag ].
	anObject isString ifTrue: [ 
		bag := self pretokenization: anObject ].
	^ bag
]

{ #category : 'pretokenisation' }
BPELearner >> prepareWordsFromText: anObject [

	^ self pretokenization: anObject
]

{ #category : 'pretokenisation' }
BPELearner >> pretokenization:aText [
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

{ #category : 'update' }
BPELearner >> update: anArray [
	"Met à jour toutes les occurrences, les positions d’une paire donnée et ses voisines dans la liste chaînée, effectue la fusion, et ajout de nouvelles paires."

	| position |
	position := pairPositions at: anArray.
	position do: [ :each |
			each first value
				updatePairFromNode: each first previousLink
				in: self.
			each second nextLink value 
				updatePairFromNode: each second 
				in: self.
			self fusion: each.
			each first value 
				buildPairFrom: each first previousLink 
				in: self.
			each first nextLink value 
				buildPairFrom: each first 
				in: self ].
	pairs removeKey: anArray ifAbsent: [ ].
	pairPositions removeKey: anArray ifAbsent: [ ]
]

{ #category : 'update' }
BPELearner >> updatePairFrom: aNode [
	self updatePairsWith: (self extractPairAndOccurencesFrom: aNode ).
	self updatePairPositionsWith: (self extractPairAndPositionFrom: aNode )
]

{ #category : 'update' }
BPELearner >> updatePairPositionsWith: anAssociation [
	"Supprime les positions associées à une paire et supprime la clé dans la dictionnaire pairesPosition si l'ensemble des positions est vides."

	pairPositions at: anAssociation key update: [ :set |
			set
				remove: anAssociation value ifAbsent: [ ];
				yourself ].
	(pairPositions at: anAssociation key) size = 0 ifTrue: [
		pairPositions removeKey: anAssociation key ]
]

{ #category : 'update' }
BPELearner >> updatePairsWith: anAssociation [
	"Met à jour le nombre d’occurrences d’une paire dans le dictionnaire, et la supprime si son occurrence devient zéro."
	
	pairs 
		add: anAssociation key 
		withOccurrences: anAssociation value negated.
	(pairs occurrencesOf: anAssociation key) = 0 
		ifTrue: [ pairs removeKey: anAssociation key ifAbsent: []]
]

{ #category : 'accessing' }
BPELearner >> vocabulary [
	^vocabulary 
]

{ #category : 'accessing' }
BPELearner >> words [ 
	^words 
]

{ #category : 'adding' }
BPELearner >> words: anObject [
	| text |
	text:=self prepareWordsFrom: anObject.
	text associationsDo: [ :each|
			each key do: [ :char |
			words add: (Subword subword: char asString occurence: each value) ].
		words add: (Subword subword: '</t>' occurence: each value).
		words add: EndOfWord new ].
	^ words
]
