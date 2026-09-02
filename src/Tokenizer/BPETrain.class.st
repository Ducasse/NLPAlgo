Class {
	#name : 'BPETrain',
	#superclass : 'Object',
	#instVars : [
		'corpus',
		'pairFrequencies',
		'pairPositions',
		'merges',
		'vocabulary',
		'iteration',
		'iteration1'
	],
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'as yet unclassified' }
BPETrain class >> trainOn: aText until: anInteger [

	|bpe|
	
	bpe := self new .
	bpe fromText: aText .
	
	[ bpe vocabulary size < anInteger and: [ bpe pairFrequencies notEmpty ] ] whileTrue: [ bpe mergesOneStep ] .

	^bpe
]

{ #category : 'as yet unclassified' }
BPETrain class >> trainOn: aText until: anInteger andSaveData: aFileName [

	|bpe|
	
	bpe := self new .
	bpe fromText: aText .
	
	[ bpe vocabulary size < anInteger and: [ bpe pairFrequencies notEmpty ] ] whileTrue: [ bpe mergesOneStep ] .

	bpe saveLearnedData: aFileName.

	^bpe
]

{ #category : 'as yet unclassified' }
BPETrain class >> trainOn: aText vocabularySize: n batchSize: k [

	|bpe|
	bpe := self new.
	bpe fromText: aText.
	
	[ bpe vocabulary size < n  and: [ bpe pairFrequencies notEmpty ] ] whileTrue: [ 
		|seenFirstTokens seenSecondTokens sortedPairsByFrequency maxFrequency i j|
		
		seenFirstTokens := Set new.
		seenSecondTokens := Set new.
		sortedPairsByFrequency := bpe pairFrequencies sortedCounts.
		maxFrequency := sortedPairsByFrequency first key.
		i := 1.
		j := 1.
		[ ( i <= (	sortedPairsByFrequency size min: k )) and: [ (sortedPairsByFrequency at: i)key = maxFrequency and: [ bpe vocabulary size < n ] ] ] whileTrue: [ 
			|pair|
			pair := (sortedPairsByFrequency at: i) value.
			
			( (seenFirstTokens includes: pair second) or: [seenSecondTokens includes: pair first] ) ifFalse: [ 
					bpe mergePairAndUpdateStructures: pair.
					j:=j+1
				 ].
			seenFirstTokens add: pair first.
			seenSecondTokens add: pair second.
			i:= i+1
		 ].
	bpe iteration add: j-1.
	bpe iteration1 add: i-1.
	 ].

	^bpe 
	
	
]

{ #category : 'adding' }
BPETrain >> addNewPairFrom: aSubword and: aSubword1 [

"Ajout d'un nouveau pair formée par aSubword et aSubword1 dans pairs et pairPositions"

	pairFrequencies add: { aSubword token . aSubword1 token } 
			withOccurrences: aSubword occurence .
			
	pairPositions at: { aSubword token . aSubword1 token} 
						update: [:set| set add: { aSubword position . aSubword1 position } ; yourself ] 
						initial: (Set with: { aSubword position . aSubword1 position })
]

{ #category : 'adding' }
BPETrain >> addToMergesPair: aCollection mergedInto: aString [

	merges add: aCollection -> aString
]

{ #category : 'adding' }
BPETrain >> addToVocabulary: aString [

	vocabulary add: aString 
]

{ #category : 'adding' }
BPETrain >> computePairs [
"Parcours la liste chaînée des mots pour construire toutes les paires possibles."
	|current|
	current := self corpus firstLink .
	[current nextLink notNil ] whileTrue: [
		current nextLink value 
			tryToCreatePairWith: current value 
			in: self.
		current := current nextLink .
		].

]

{ #category : 'adding' }
BPETrain >> computeVocabulary [ 

"Parcours la liste chainée de mots pour construire le vocabulaire. Dans WordPiece, elle ajoute en même temps des éléments dans letters et lettersPositions"
	|i|
	i:=corpus firstLink .
	[ i notNil ] whileTrue: [ 
	[ i value class ~= EndOfWord ] whileTrue: [ 
		self addToVocabulary: (i value token ).
	i:= i nextLink 
	 ].
	i:= i nextLink 
	 ]
]

{ #category : 'accessing' }
BPETrain >> corpus [ 
	^corpus 
]

{ #category : 'adding' }
BPETrain >> corpus: anObject [
	| wordFrequencies |
	
	wordFrequencies := Bag new.
	wordFrequencies addAll: (Preprocessing preprocess: anObject) .
	wordFrequencies associationsDo: [ :each|
			each key do: [ :char |
			corpus add: (Token token: char asString occurence: each value) .
			corpus lastLink value position: corpus lastLink ].
		corpus add: (Token token: '</t>' occurence: each value).
		corpus lastLink value position: corpus lastLink .
		corpus add: EndOfWord new ].
	^ corpus 
]

{ #category : 'operations' }
BPETrain >> createNewVocabulary: pair [
"Crée un nouveau vocabulaire en concaténant les deux subwords de la paire donnée et le renvoie."

	|newVocabulary|
	newVocabulary := pair first , pair second.
	^ newVocabulary 
]

{ #category : 'merges' }
BPETrain >> findPairToMerge [
"Cherche la paire ayant la fréquence maximale à fusionnée" 

	^ pairFrequencies sortedCounts first value
]

{ #category : 'public API' }
BPETrain >> fromText: aText [

	self corpus: aText.
	self computeVocabulary.
	self computePairs 
]

{ #category : 'nodes' }
BPETrain >> fusion: anArray [
"Concatène les sous-mots du premier et du second nœud référencés dans le vecteur fourni, en mettant à jour le sous-mot du premier nœud, puis supprime le second nœud de la liste chaînée."
	anArray first value token: (anArray first value token , anArray second value token ).
	corpus removeLink: anArray second .
]

{ #category : 'initalization' }
BPETrain >> initialize [ 
	super initialize. 
	corpus := DoubleLinkedList new.
	vocabulary := Set new.
	pairFrequencies := Bag new .
	pairPositions := Dictionary new.
	merges:= OrderedCollection new.
	iteration := OrderedCollection new. 
	iteration1 := OrderedCollection new .
]

{ #category : 'accessing' }
BPETrain >> iteration [ 

	^iteration 
]

{ #category : 'accessing' }
BPETrain >> iteration1 [

	^ iteration1
]

{ #category : 'merges' }
BPETrain >> mergePairAndUpdateStructures: aPair [

	| newVocabulary |
	newVocabulary := self createNewVocabulary: aPair .
	self addToMergesPair: aPair mergedInto: newVocabulary .
	self addToVocabulary: newVocabulary .
	self update: aPair 
]

{ #category : 'accessing' }
BPETrain >> merges [ 
	^merges 
]

{ #category : 'merges' }
BPETrain >> mergesOneStep [

	| pair newVocabulary |
	pair := self findPairToMerge.
	newVocabulary := self createNewVocabulary: pair .
	self addToMergesPair: pair mergedInto: newVocabulary .
	self addToVocabulary: newVocabulary .
	self update: pair
]

{ #category : 'accessing' }
BPETrain >> pairFrequencies [ 
	"Return the bags of pairs."
	
	^pairFrequencies 
]

{ #category : 'accessing' }
BPETrain >> pairPositions [ 
	"Renvoie le dictionnaire dont les cles sont les paires et les valeurs sont un ensemble de positions des paires dans la liste chaînée."

	^ pairPositions 
]

{ #category : 'as yet unclassified' }
BPETrain >> saveLearnedData1: aFileName [
    | dict i |
	
	dict := Dictionary new .
	i:= merges size .
	merges do: [ :assoc | dict at: assoc key put: i . i:=i-1 ] .
   (aFileName , '.ston')  asFileReference
    writeStreamDo: [ :stream |
        stream nextPutAll: (STON toString: dict) ].

]

{ #category : 'as yet unclassified' }
BPETrain >> saveLearnedData: aFileName [

	(aFileName , '.ston')  asFileReference
    writeStreamDo: [ :stream |
        stream nextPutAll: (STON toString: merges) ].

]

{ #category : 'update' }
BPETrain >> update: pair [
	"Met à jour toutes les occurrences, les positions d’une paire donnée et ses voisines dans la liste chaînée, effectue la fusion, et ajout de nouvelles paires."
	| position |
	position := pairPositions at: pair.
	position do: [ :each |  
			each first value
				tryToUpdatePairWith: each first previousLink value 
				in: self.
			each second nextLink value 
				tryToUpdatePairWith: each second value 
				in: self.
			self fusion: each	.
			each first value 
				tryToCreatePairWith: each first previousLink value
				in: self.
			each first nextLink value
				tryToCreatePairWith: each first value 
				in: self].
	pairFrequencies removeKey: pair ifAbsent: [ ].
	pairPositions removeKey: pair ifAbsent: [ ]
]

{ #category : 'update' }
BPETrain >> updatePairFrom: aToken and: aToken1 [
"Mises à jour de la paire formée par aSubword et aSubword1 dans pairs et pairsPositions"

	pairFrequencies add: {aToken token . aToken1 token } 
			withOccurrences: aToken occurence negated .
	(pairFrequencies occurrencesOf: {aToken token . aToken1 token }) = 0 ifTrue: [  pairFrequencies removeKey: {aToken token . aToken1 token } ifAbsent: []].
	
	pairPositions at: {aToken token . aToken1 token } 
					update: [:set| set remove: {aToken position . aToken1 position } ifAbsent:[] ; yourself ].
					
	(pairPositions at: {aToken token . aToken1 token }) size = 0 ifTrue: [  pairPositions removeKey: {aToken token . aToken1 token }]
]

{ #category : 'accessing' }
BPETrain >> vocabulary [
	^vocabulary 
]
