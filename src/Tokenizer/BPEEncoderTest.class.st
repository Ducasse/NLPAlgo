Class {
	#name : 'BPEEncoderTest',
	#superclass : 'TestCase',
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'tests' }
BPEEncoderTest >> testApplyRulesText [
	
	|enc tokens|
	enc := BPEEncoder new .
	tokens := OrderedCollection new .
	
	self assert: ( enc applyRulesTo: self text from: '10') equals: { 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>'  . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . 'e' . 'r' . '</t>' . 'o' . 'l' . 'd' . 'e' . 'r' . '</t>' . 'o' . 'l' . 'd' . 'e' . 'r' . '</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'f' . 'i' . 'n' . 'est</t>' . 'low' . 'est</t>' . 'low' . 'est</t>' . 'low' . 'est</t>' . 'low' . 'est</t>' } asOrderedCollection .
]

{ #category : 'tests' }
BPEEncoderTest >> testApplyRulesText3 [
	
	|enc tokens|
	enc := BPEEncoder new .
	tokens := OrderedCollection new .
	
	self assert: ( enc applyRulesTo: self text3 from: '10') equals: {'low</t>' . 'low</t>' . 'low</t>' . 'low</t>' . 'low</t>' . 'lower</t>' . 'lower</t>' . 'newest</t>' . 'newest</t>' . 'newest</t>' . 'newest</t>' . 'newest</t>' . 'newest</t>' . 'widest</t>' . 'widest</t>' . 'widest</t>'} asOrderedCollection .
]

{ #category : 'tests' }
BPEEncoderTest >> testComputePairsText [ 
	|encoder collection i |
	encoder := BPEEncoder new.
	encoder corpus: self text .
	encoder loadMerges: '10'.
	encoder computePairs .
	collection := OrderedCollection new.
	collection add: (Association key: #('t' '</t>') value: 15).
	collection add: (Association key: #('e' 's' ) value: 14).
	collection add: (Association key: #('l' 'o') value: 12).
	i:=1.
	
	self assert: encoder pairPositions keys asSet equals: { {'o' . 'l'} . {'l' . 'd'} . {'d' . '</t>'} . { 'd'  . 'e' } . { 'e'  . 'r' } . { 'r'  . '</t>' } . { 'f'  . 'i' } . { 'i'  . 'n' } . { 'n'  . 'e' } . { 'e'  . 's' } . { 's'  . 't' } . { 't'  . '</t>' } . { 'l'  . 'o' } . { 'o'  . 'w' } . { 'w'  . 'e' } } asSet .
	
	encoder pairScore do: [ :each | self assert: each key equals: (collection at: i) key .
		self assert: each value equals: (collection at: i) value .
		i:= i+1]
]

{ #category : 'tests' }
BPEEncoderTest >> testComputePairsText2 [
	|encoder collection i |
	encoder := BPEEncoder new.
	encoder corpus: self text2 .
	encoder loadMerges: '10'.
	encoder computePairs .
	collection := OrderedCollection new.
	collection add: (Association key: #('t' '</t>') value: 15).
	collection add: (Association key: #('e' 's' ) value: 14).
	collection add: (Association key: #('l' 'o') value: 12).
	collection add: (Association key: #('e' 'w') value: 10).
	collection add: (Association key: #('i' 'd') value: 6).
	i:=1.
	
	self assert: encoder pairPositions keys asSet equals: { {'l' . 'o'} . {'o' . 'w'} . {'w' . '</t>'} . { 'e'  . 'r' } . { 'r'  . '</t>' } . { 'n'  . 'e' } . { 'e'  . 'w' } . { 'w'  . 'e' } . { 'e'  . 's' } . { 's'  . 't' } . { 't'  . '</t>' } . { 'w'  . 'i' } . { 'i'  . 'd' } . { 'd' . 'e' } } asSet .
	
	encoder pairScore do: [ :each | self assert: each key equals: (collection at: i) key .
		self assert: each value equals: (collection at: i) value .
		i:= i+1]

]

{ #category : 'tests' }
BPEEncoderTest >> testCorpus [

	|enc list i|
	enc := BPEEncoder new .
	list := {'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . '</t>' . 'o' . 'l' . 'd' . 'e' . 'r' . '</t>' . 'o' . 'l' . 'd' . 'e' . 'r' . '</t>' . 'o' . 'l' . 'd' . 'e' . 'r' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' . 'f' . 'i' . 'n' . 'e' . 's' . 't' . '</t>' .   'l' . 'o' . 'w' . 'e' . 's' . 't' . '</t>' . 'l' . 'o' . 'w' . 'e' . 's' . 't' . '</t>' . 'l' . 'o' . 'w' . 'e' . 's' . 't' . '</t>' . 'l' . 'o' . 'w' . 'e' . 's' . 't' . '</t>' } .
	enc corpus: self text .
	i := 1 .
	enc corpus linksDo: [ :link |
		( link isNotNil and: [ link value class ~= EndOfWord ] ) 
			ifTrue: [ self assert: link value token equals: ( list at: i ) . 
						i := i + 1 ]  
					]
	
]

{ #category : 'tests' }
BPEEncoderTest >> testLoadMerges [

	|bpe dict|
	bpe := BPEEncoder new.
	bpe loadMerges: '10' .
	dict := Dictionary new.
	
	
	self assert: (bpe merges at: #('t' '</t>') ) equals: 15.
	self assert: (bpe merges at: #('e' 's') ) equals: 14.
	self assert: (bpe merges at: #('es' 't</t>')) equals: 13 .
	self assert: (bpe merges at: #('l' 'o' )) equals: 12 .
	self assert: (bpe merges at: #('lo' 'w')) equals: 11 .
	self assert: (bpe merges at: #('e' 'w')) equals: 10 .
	self assert: (bpe merges at: #('ew' 'est</t>')) equals: 9 .
	self assert: (bpe merges at: #('n' 'ewest</t>')) equals: 8 .
	self assert: (bpe merges at: #('low' '</t>')) equals: 7 .
	self assert: (bpe merges at: #('i' 'd')) equals: 6 .
	self assert: (bpe merges at: #('id' 'est</t>')) equals: 5 .
	self assert: (bpe merges at: #('w' 'idest</t>')) equals: 4 .
	self assert: (bpe merges at: #('low' 'e')) equals: 3 .
	self assert: (bpe merges at: #('lowe' 'r')) equals: 2 .
	self assert: (bpe merges at: #('lower' '</t>')) equals: 1 .
	
	self assert: bpe merges size equals: 15
	

]

{ #category : 'accessing structure variables' }
BPEEncoderTest >> text [
	^ 'old old old old old old old 
older older older
finest finest finest finest finest finest finest finest finest 
lowest lowest lowest lowest 
'

]

{ #category : 'accessing structure variables' }
BPEEncoderTest >> text2 [
	^ '
low low low low low
lower lower
newest newest newest newest newest newest 
widest widest widest'
]

{ #category : 'accessing structure variables' }
BPEEncoderTest >> text3 [
	^ '
low low low low low
lower lower
newest newest newest newest newest newest 
widest widest widest'

]
