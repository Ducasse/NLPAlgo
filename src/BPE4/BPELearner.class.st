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
BPELearner >> addNewPairFrom: aSubword and: aSubword1 [

"Ajout d'un nouveau pair formée par aSubword et aSubword1 dans pairs et pairPositions"

	pairs add: { aSubword subword . aSubword1 subword } 
			withOccurrences: aSubword occurence .
			
	pairPositions at: { aSubword subword . aSubword1 subword} 
						update: [:set| set add: { aSubword position . aSubword1 position } ; yourself ] 
						initial: (Set with: { aSubword position . aSubword1 position })
]

{ #category : 'adding' }
BPELearner >> addToLettersAndLettersPositions: aSubword [

"Ajoute un nouveau caractère ou chaîne de caractère dans letters et lettersPositions de WordPiece. Dans BPE, elle ne fait rien."
	^self 
]

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
		current nextLink value 
			tryAddPairWith: current value 
			in: self.
		current := current nextLink .
		].

]

{ #category : 'adding' }
BPELearner >> computeVocabulary [ 

"Parcours la liste chainée de mots pour construire le vocabulaire. Dans WordPiece, elle ajoute en même temps des éléments dans letters et lettersPositions"
	|i|
	i:=words firstLink .
	[ i notNil ] whileTrue: [ 
	[ i value class ~= EndOfWord ] whileTrue: [ 
		self addToVocabulary: (i value subword ).
		self addToLettersAndLettersPositions: (i value).
	i:= i nextLink 
	 ].
	i:= i nextLink 
	 ]
]

{ #category : 'operations' }
BPELearner >> createNewVocabulary: pair [
"Crée un nouveau vocabulaire en concaténant les deux subwords de la paire donnée et le renvoie."

	|newVocabulary|
	newVocabulary := pair first , pair second.
	^ newVocabulary 
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

{ #category : 'merges' }
BPELearner >> findPairToMerge [
"Cherche la paire ayant la fréquence maximale à fusionnée" 

	^ pairs sortedCounts first value
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

	| pair newVocabulary |
	pair := self findPairToMerge.
	newVocabulary := self createNewVocabulary: pair .
	self addToMergesPair: pair mergedInto: newVocabulary .
	self addToVocabulary: newVocabulary .
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

{ #category : 'pretokenisation' }
BPELearner >> pretokenize: anObject [

	anObject isArray ifTrue: [ ^ self pretokenizeArrayOfSentences:anObject ].
	anObject isString  ifTrue: [ ^ self pretokenizeText: anObject ].

]

{ #category : 'pretokenisation' }
BPELearner >> pretokenizeArrayOfSentences: anArray [
	|bag|
	bag:= Bag new.
	anArray do: [ :each | bag addAll: (self pretokenizeText: each ) ].
	^ bag 
]

{ #category : 'pretokenisation' }
BPELearner >> pretokenizeText:aText [
"Transforme le texte en un bag de tokens en séparant les mots."
	|rawWords bag|
	bag := Bag new.
	rawWords :=(aText substrings: {Character space . Character cr . Character tab}).
	bag addAll: (rawWords collect: [:each|
	self splitWord: each  ] ).
	^bag 
	
]

{ #category : 'operations' }
BPELearner >> splitWord: aString [
"Transforme la chaîne passée en argument en une collection de caractères (chaque caractère converti en chaîne), 
et ajoute '</t>' à la fin."

	|col|
	col:=OrderedCollection new.
	aString do: [ :aChar |
		col add: aChar asString].
	col add: '</t>'.
	^ col 
]

{ #category : 'update' }
BPELearner >> update: pair [
	"Met à jour toutes les occurrences, les positions d’une paire donnée et ses voisines dans la liste chaînée, effectue la fusion, et ajout de nouvelles paires."
	| position |
	position := pairPositions at: pair.
	position do: [ :each |
			each first value
				tryUpdatePairWith: each first previousLink value 
				in: self.
			each second nextLink value 
				tryUpdatePairWith: each second value 
				in: self.
			self fusion: each	.
			each first value 
				tryAddPairWith: each first previousLink value
				in: self.
			each first nextLink value
				tryAddPairWith: each first value 
				in: self].
	pairs removeKey: pair ifAbsent: [ ].
	pairPositions removeKey: pair ifAbsent: [ ]
]

{ #category : 'update' }
BPELearner >> updatePairFrom: aNode [
	self updatePairsWith: (self extractPairAndOccurencesFrom: aNode ).
	self updatePairPositionsWith: (self extractPairAndPositionFrom: aNode )
]

{ #category : 'update' }
BPELearner >> updatePairFrom: aSubword and: aSubword1 [
"Mises à jour de la paire formée par aSubword et aSubword1 dans pairs et pairsPositions"

	pairs add: {aSubword subword . aSubword1 subword } 
			withOccurrences: aSubword occurence negated .
	(pairs occurrencesOf: {aSubword subword . aSubword1 subword }) = 0 ifTrue: [  pairs removeKey: {aSubword subword . aSubword1 subword } ifAbsent: []].
	
	pairPositions at: {aSubword subword . aSubword1 subword } 
					update: [:set| set remove: {aSubword position . aSubword1 position } ifAbsent:[] ; yourself ].
					
	(pairPositions at: {aSubword subword . aSubword1 subword }) size = 0 ifTrue: [  pairPositions removeKey: {aSubword subword . aSubword1 subword }]
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
	text:=self pretokenize: anObject.
	text associationsDo: [ :each|
			each key do: [ :char |
			words add: (Subword subword: char asString occurence: each value) .
			words lastLink value position: words lastLink ].
		words add: EndOfWord new ].
	^ words
]
