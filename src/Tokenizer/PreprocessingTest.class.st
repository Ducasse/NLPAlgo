Class {
	#name : 'PreprocessingTest',
	#superclass : 'TestCase',
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'nil' }
PreprocessingTest >> array [

	^#('Byte Pair Encoding is a subword tokenization algorithm used in NLP.' 'WordPiece is used in transformer models like BERT.')
]

{ #category : 'tests' }
PreprocessingTest >> testPreprocess [

	|p textPreprocessed arrayOfSentencesPreprocessed|
	p := Preprocessing new.
	textPreprocessed := p preprocess: self text .
	arrayOfSentencesPreprocessed := p preprocess: self array .
	
	self assert: textPreprocessed equals: #('Byte' 'Pair' 'Encoding' 'is' 'a' 'subword' 'tokenization' 'algorithm' 'used' 'in' 'NLP.').
	self assert: arrayOfSentencesPreprocessed equals: #('Byte' 'Pair' 'Encoding' 'is' 'a' 'subword' 'tokenization' 'algorithm' 'used' 'in' 'NLP.' 'WordPiece' 'is' 'used' 'in' 'transformer' 'models' 'like' 'BERT.')
	
]

{ #category : 'tests' }
PreprocessingTest >> testPreprocessArrayOfSentences [

	|p arrayOfSentencesPreprocessed|
	
	p := Preprocessing new.
	arrayOfSentencesPreprocessed := p preprocessCollectionOfSentences: self array .
	
	self assert: arrayOfSentencesPreprocessed equals: #('Byte' 'Pair' 'Encoding' 'is' 'a' 'subword' 'tokenization' 'algorithm' 'used' 'in' 'NLP.' 'WordPiece' 'is' 'used' 'in' 'transformer' 'models' 'like' 'BERT.')
	 
]

{ #category : 'tests' }
PreprocessingTest >> testPreprocessClassMethod [

	|textPreprocessed arrayOfSentencesPreprocessed|
	textPreprocessed := Preprocessing preprocess: self text .
	arrayOfSentencesPreprocessed := Preprocessing preprocess: self array .
	
	self assert: textPreprocessed equals: #('Byte' 'Pair' 'Encoding' 'is' 'a' 'subword' 'tokenization' 'algorithm' 'used' 'in' 'NLP.').
	self assert: arrayOfSentencesPreprocessed equals: #('Byte' 'Pair' 'Encoding' 'is' 'a' 'subword' 'tokenization' 'algorithm' 'used' 'in' 'NLP.' 'WordPiece' 'is' 'used' 'in' 'transformer' 'models' 'like' 'BERT.')
]

{ #category : 'tests' }
PreprocessingTest >> testPreprocessText [

	|p textPreprocessed|
	
	p:=Preprocessing new.
	textPreprocessed:= p preprocessText: self text.
	
	self assert: textPreprocessed equals: #('Byte' 'Pair' 'Encoding' 'is' 'a' 'subword' 'tokenization' 'algorithm' 'used' 'in' 'NLP.')

]

{ #category : 'nil' }
PreprocessingTest >> text [

	^'Byte Pair Encoding is a subword tokenization algorithm used in NLP.'
]
