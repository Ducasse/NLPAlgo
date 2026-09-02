Class {
	#name : 'WordPieceTrain',
	#superclass : 'BPETrain',
	#instVars : [
		'tokenFrequencies',
		'tokenPositions',
		'pairScores',
		'affectedPairSet'
	],
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'adding' }
WordPieceTrain >> addNewPairScoresFrom: aSubword and: aSubword1 [
"Ajout d'une nouvelle paire formée par aSubword et aSubword1 dans pairesScores."

	|pair|.
	pair := { aSubword token . aSubword1 token }.
	
	(pairFrequencies occurrencesOf: pair) = 0 ifTrue: [ pairScores removeKey: pair ifAbsent:[] ]
		
	 											ifFalse: [ pairScores 
																	at: pair 
																	put: (pairFrequencies occurrencesOf: pair )/ ((tokenFrequencies occurrencesOf: pair first) * (tokenFrequencies occurrencesOf: pair second )) asFloat] .
]

{ #category : 'adding' }
WordPieceTrain >> addToAffectedPairSet: pair [
"Ajout de la nouvelle paire pair dans affectedPairSet"
	
	affectedPairSet add: pair 
]

{ #category : 'adding' }
WordPieceTrain >> addToTokenFrequenciesAndTokenPositions: aSubword [

"Ajout d'un nouveau chaîne de caractère dans letters et lettersPositions à partir de aSubword."

	tokenFrequencies add: aSubword token 
				withOccurrences: aSubword occurence .
				
	tokenPositions at: aSubword token 
						update: [:set| set add: aSubword position ; yourself ] 
						initial: (Set with: aSubword position)


]

{ #category : 'accessing' }
WordPieceTrain >> affectedPairSet [
"Renvoie l'ensemble des paires affectées par la fusion (les paires contenant l'un des élémentsde la paire fusionnée)"

	^ affectedPairSet 
]

{ #category : 'adding' }
WordPieceTrain >> computePairs [
"Ajout de paires dans pairs, pairPositions (grâce à la méthode computePairs en parcourant la liste châinée de mots) et pairsScores (obtenus grâce aux éléments de pairs et letters)."

	super computePairs .
	
	pairFrequencies associationsDo: [ :each| 
		pairScores 
			at: each key 
			put: each value/ ((tokenFrequencies occurrencesOf: each key first) * (tokenFrequencies occurrencesOf: each key second))asFloat ]

]

{ #category : 'as yet unclassified' }
WordPieceTrain >> computeVocabulary [ 

	|i|
	i:=corpus firstLink .
	[ i notNil ] whileTrue: [ 
	[ i value class ~= EndOfWord ] whileTrue: [ 
		self addToTokenFrequenciesAndTokenPositions: (i value ).
	i:= i nextLink 
	 ].
	i:= i nextLink 
	 ].
	vocabulary := tokenFrequencies asSet .

]

{ #category : 'adding' }
WordPieceTrain >> corpus: anObject [
	| wordFrequencies |
	
	wordFrequencies := Bag new.
	wordFrequencies addAll: (Preprocessing1 preprocess: anObject) .
	wordFrequencies associationsDo: [ :each||word|
			word := each key.
			1 to: word size do: [ :i ||char|
			char := word at: i.
			i = 1 ifTrue: [ corpus add: (Token token: char asString occurence: each value) ]
					ifFalse:[corpus add: (Token token: ('##', char asString) occurence: each value)] .
			corpus lastLink value position: corpus lastLink ].
		corpus add: EndOfWord new ].
	^ corpus
]

{ #category : 'operations' }
WordPieceTrain >> createNewVocabulary: pair [
"Construit un nouveau vocabulaire en concatenant le premier élément de la paire avec le second élément privé de son premier caractère."

	|newVocabulary|
	newVocabulary := pair first, ( pair second allButFirst: 2 ) .
	^ newVocabulary 
]

{ #category : 'accessing' }
WordPieceTrain >> findPairToMerge [ 
"Cherche la paire ayant la fréquence maximale dans pairsScores et le renvoie."

	^ (pairScores associations detectMax: [:assoc | assoc value]) key
]

{ #category : 'nodes' }
WordPieceTrain >> fusion: anArray [
"Concatène les sous-mots du premier et du second nœud référencés dans le vecteur fourni, en mettant à jour le sous-mot du premier nœud, puis supprime le second nœud de la liste chaînée."
	anArray first value token: (anArray first value token , ( anArray second value token allButFirst: 2 ) ).
	corpus removeLink: anArray second .
]

{ #category : 'initialization' }
WordPieceTrain >> initialize [ 
	super initialize .
	pairScores := Dictionary new.
	tokenFrequencies := Bag new.
	tokenPositions := Dictionary new.
	affectedPairSet := Set new .
]

{ #category : 'accessing' }
WordPieceTrain >> pairScores [
"Renvoie un dictionnaire associant chaque paire à son score correspondant."

	^pairScores 
]

{ #category : 'adding' }
WordPieceTrain >> pairsAffectedByMerging: aPair [
"Ajout des paires affectées par la fusion de aPair dans affectedPairSet grâce à la méthode tryAddPairAffectedByMergeWith:in:
et en parcourant lettersPositions car les paires affectées par la fusion sont les paires contenant l'un des éléments de la paire fusionnée"

	| pair|
	pair:= {( Token new token: aPair first) . ( Token new token: aPair second)}.
	
	(tokenPositions at: aPair first ) do: [ :each | 
		
		({ each previousLink value . each value } ~= pair ) ifTrue: [ each value tryAddPairAffectedByMergeWith: each previousLink value in: self ].
		
		({ each value . each nextLink value } ~= pair ) ifTrue: [ each nextLink value tryAddPairAffectedByMergeWith: each value in: self ]
		
			].
			
	(tokenPositions at: aPair second ) do: [ :each | 
		
		({ each previousLink value . each value } ~= pair ) ifTrue: [ each value tryAddPairAffectedByMergeWith: each previousLink value in: self ].
		
		({ each value . each nextLink value } ~= pair ) ifTrue: [ each nextLink value tryAddPairAffectedByMergeWith: each value in: self ]
		
			].
]

{ #category : 'as yet unclassified' }
WordPieceTrain >> saveLearnedData: aFileName [
    (aFileName , '.ston') asFileReference
        writeStreamDo: [ :stream |
            stream nextPutAll: (STON toString: vocabulary) ].
]

{ #category : 'as yet unclassified' }
WordPieceTrain >> saveVocabulary: aFileName [
    (aFileName , '.ston') asFileReference
        writeStreamDo: [ :stream |
            stream nextPutAll: (STON toString: vocabulary) ].
]

{ #category : 'accessing' }
WordPieceTrain >> tokenFrequencies [ 
"renvoie un bag contenant tous les chaînes de caractères qui composent le texte."

	^tokenFrequencies 
]

{ #category : 'accessing' }
WordPieceTrain >> tokenPositions [
"Retourne un dictionnaire associant chaque caractère du texte à un ensemble de ses positions dans le texte."


	^ tokenPositions 
]

{ #category : 'update' }
WordPieceTrain >> update: aPair [
	| position|
	affectedPairSet removeAll . "initialiser affectedPairSet à chaque mises à jours car elle change à chaque mises à jours."
	self pairsAffectedByMerging: aPair . "ajoute toutes paires affectée par la fusion dans affectedPairSet."
	position := pairPositions at: aPair . "récupère la position de chacun des éléments du paire fusionnée dans le texte."
	
	position do: [ :each |           
		self updateTokenFrequenciesAndFrequenciesPositions: each first value. "mises à jours de l'occurence du premier élément de la paire fusionée 
		dans letters et lettersPositions"
		self updateTokenFrequenciesAndFrequenciesPositions: each second value. "mises à jours de l'occurence du second élément de la paire fusionée 
		dans letters et lettersPositions"
		 ].
	
	super update: aPair . "Mises à jours des paires voisines de la paire fusionnée."

	affectedPairSet do: [ :each |    "mises à jours des paires affectées par la fusion dans pairsScores"
		self updatePairsScoresFrom: each
		 ].
	
	position do: [ :each | self addToTokenFrequenciesAndTokenPositions: each first value ]. "ajouts du nouveau chaîne de caratère, ainsi que ses occurences et ses positions dans le texte, obtenus grâce à la fusion dans letters et lettersPositions."
	
	position do: [ :each|   "ajouts des nouveaux paires obtenus grâce à la fusion dans pairsScores."
		each first value 
			tryAddPairsScoreWith: each first previousLink value 
			in: self.
		each first nextLink value 
			tryAddPairsScoreWith: each first value  
			in: self].
		
	pairScores removeKey: aPair . "suppresion de la paire fusionnée dans pairsScores"
]

{ #category : 'adding' }
WordPieceTrain >> updatePairsScoresFrom: pair [
	
	(pairFrequencies occurrencesOf: pair) = 0 ifTrue: [ pairScores removeKey: pair ifAbsent:[] ]
		
	 											ifFalse: [ pairScores at: pair 
																				put: (pairFrequencies occurrencesOf: pair )/ ((tokenFrequencies occurrencesOf: pair first) * (tokenFrequencies occurrencesOf: pair second )) asFloat] .
]

{ #category : 'update' }
WordPieceTrain >> updateTokenFrequenciesAndFrequenciesPositions: aSubword [

	tokenFrequencies add: aSubword token withOccurrences: aSubword occurence negated .
	
	(tokenFrequencies occurrencesOf: aSubword token ) = 0 ifTrue: [ tokenFrequencies removeKey: aSubword 
																						token ifAbsent: []].
	
	tokenPositions at: aSubword token  update: [:set| set remove: aSubword position  
																				ifAbsent:[] ; yourself ].
	
	(tokenPositions at: aSubword token ) size = 0 ifTrue: [ tokenPositions removeKey: aSubword token ]
	


]
