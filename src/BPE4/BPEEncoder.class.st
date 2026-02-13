Class {
	#name : 'BPEEncoder',
	#superclass : 'BPELearner',
	#instVars : [
		'rules'
	],
	#category : 'BPE4',
	#package : 'BPE4'
}

{ #category : 'adding' }
BPEEncoder >> addEndTokentoEachWordsInText: text [ 

	| newText prevIsSeparator endToken |
	
	newText := WriteStream on: String new .
	prevIsSeparator := true .
	endToken := '</t>'.
	
	text do: [ :c |
		c isSeparator
			ifTrue: [ 
				prevIsSeparator ifFalse: [ newText nextPutAll: endToken ].
				newText nextPut: c .
				prevIsSeparator := true . 
				
			] ifFalse: [ 
				newText nextPut: c .
				prevIsSeparator := false .
				] .
			] .
	
	prevIsSeparator ifFalse: [ newText nextPutAll: endToken ].
		
	^ newText contents 
]

{ #category : 'adding' }
BPEEncoder >> addNewPairFrom: aSubword and: aSubword1 [

"Ajout d'un nouveau pair formée par aSubword et aSubword1 dans pairPositions"
			
	pairPositions at: { aSubword subword . aSubword1 subword} 
						update: [:set| set add: { aSubword position . aSubword1 position } ; yourself ] 
						initial: (Set with: { aSubword position . aSubword1 position })
]

{ #category : 'as yet unclassified' }
BPEEncoder >> applyRulesTo: inpuText from: filePath [
	
	|tokens|
	self words: inpuText .
	self computePairs .
	self loadMergesSTON: filePath .
	tokens := OrderedCollection new .
	
	rules do: [ :each | |pair|
		pair := each key .
		( pairPositions includesKey: pair ) ifTrue: [ self update: pair ] 
		].
	
	words linksDo: [ :link | ( link value class ~= EndOfWord ) ifTrue: [ tokens add: link value subword ] ].
	
	^ tokens
	
											
	
]

{ #category : 'as yet unclassified' }
BPEEncoder >> loadMergesSTON: filePath [
    rules := STON fromString: (filePath asFileReference contents)
]

{ #category : 'accessing' }
BPEEncoder >> rules [ 

	^ rules 
]

{ #category : 'update' }
BPEEncoder >> updatePairFrom: aSubword and: aSubword1 [
"Mises à jour de la paire formée par aSubword et aSubword1 dans pairsPositions"
	
	pairPositions at: {aSubword subword . aSubword1 subword } 
					update: [:set| set remove: {aSubword position . aSubword1 position } ifAbsent:[] ; yourself ].
					
	(pairPositions at: {aSubword subword . aSubword1 subword }) size = 0 ifTrue: [  pairPositions removeKey: {aSubword subword . aSubword1 subword }]
]

{ #category : 'adding' }
BPEEncoder >> words: anObject [
	| text token i |
	text:=self addEndTokentoEachWordsInText: anObject .
	token := '</t>'.
	i := 1 .
	[ i <= text size ] whileTrue: [ 
		|subword|
		
		(text includesSubstring: token at: i)
			ifTrue: [ subword := Subword new subword: token .
						i := i + token size .
						words add: subword .
						words lastLink value position: words lastLink .
						words add: EndOfWord new .  ]
					
			 ifFalse: [ subword := Subword new subword: ( text at: i ) asString .
							i := i + 1 .
							words add: subword .
							words lastLink value position: words lastLink . ] .
			].
		
	^ words
	

]
