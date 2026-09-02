Class {
	#name : 'TestWordPieceTrain',
	#superclass : 'TestCase',
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'tests' }
TestWordPieceTrain >> testComputePairs [ 
	|wordpiece|
	wordpiece := WordPieceTrain new.
	wordpiece corpus: self text2 .
	wordpiece computeVocabulary .
	wordpiece computePairs .
	
	self assert: (wordpiece pairPositions keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairScores keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairPositions keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	self assert: (wordpiece pairScores keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	
	self assert: wordpiece pairPositions keys asSet equals: #(#('l' '##o') #('##o' '##w') #('##w' '##e') #('##e' '##r') #('n' '##e') #('##e' '##w') #('##e' '##s') #('##s' '##t') 
	#('w' '##i') #('##i' '##d') #('##d' '##e') ) asSet.
	
	self assert: (wordpiece pairFrequencies occurrencesOf: #('l' '##o')) equals: 7.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##o' '##w')) equals: 7.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##w' '##e')) equals: 8.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##r')) equals: 2.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('n' '##e')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##w')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##s')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##s' '##t')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('w' '##i')) equals: 3.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##i' '##d')) equals: 3.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##d' '##e')) equals: 3.
	
	self assert: (wordpiece pairScores at: #('l' '##o')) equals: 7/(7*7)asFloat .
	self assert: (wordpiece pairScores at: #('##o' '##w')) equals: 7/(7*13)asFloat .
	self assert: (wordpiece pairScores at: #('##w' '##e')) equals: 8/(13*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##r')) equals: 2/(17*2)asFloat .
	self assert: (wordpiece pairScores at: #('n' '##e')) equals: 6/(6*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##w')) equals: 6/(17*13)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##s')) equals: 9/(17*9)asFloat .
	self assert: (wordpiece pairScores at: #('##s' '##t')) equals: 9/(9*9)asFloat .
	self assert: (wordpiece pairScores at: #('w' '##i')) equals: 3/(3*3)asFloat .
	self assert: (wordpiece pairScores at: #('##i' '##d')) equals: 3/(3*3)asFloat .
	self assert: (wordpiece pairScores at: #('##d' '##e')) equals: 3/(3*17)asFloat .
]

{ #category : 'tests' }
TestWordPieceTrain >> testComputeVocabulary [ 
	|wordpiece|
	wordpiece := WordPieceTrain new.
	wordpiece corpus: self text2 .
	wordpiece computeVocabulary .
	
	self assert: (wordpiece vocabulary size = wordpiece tokenFrequencies keys size) equals: true.
	self assert: (wordpiece vocabulary size = wordpiece tokenPositions keys size) equals: true.
	self assert: (wordpiece vocabulary = wordpiece tokenFrequencies keys asSet) equals: true.
	self assert: (wordpiece vocabulary = wordpiece tokenPositions keys asSet) equals: true.
	
	self assert: wordpiece vocabulary equals: #('l' '##o' '##w' '##e' '##r' 'n' '##s' '##t' 'w' '##i' '##d') asSet.
	
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'l') equals: 7.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##o') equals: 7.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##w') equals: 13.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'w') equals: 3.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##e') equals: 17.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##r') equals: 2.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'n') equals: 6.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##s') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##t') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'w') equals: 3.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##i') equals: 3.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##d') equals: 3.
]

{ #category : 'tests' }
TestWordPieceTrain >> testCreateNewVocabulary [
	|wordpiece|
	wordpiece := WordPieceTrain new.
	wordpiece corpus: self text2 .
	wordpiece computeVocabulary .
	wordpiece computePairs .
	
	self assert: (wordpiece findPairToMerge ) equals: { 'w' . '##i' }.
	self assert: (wordpiece createNewVocabulary: wordpiece findPairToMerge ) equals: 'wi'
]

{ #category : 'tests' }
TestWordPieceTrain >> testFindPairToMerge [
	|wordpiece|
	wordpiece := WordPieceTrain new.
	wordpiece corpus: self text2 .
	wordpiece computeVocabulary .
	wordpiece computePairs .
	
	self assert: (wordpiece findPairToMerge ) equals: { 'w' . '##i' }
	
]

{ #category : 'tests' }
TestWordPieceTrain >> testFusion [ 
	|position pair bpe|
	bpe := WordPieceTrain new.
	bpe fromText: self text2 .
	
	pair:= #('##w' '##e').
	position := (bpe pairPositions at: pair) asArray .
	
	self assert: position size equals: 2.
	
	self assert: (position at: 1) first value token equals: '##w'.
	self assert: (position at: 1) second value token equals: '##e'.
	self assert: (position at: 2) first value token equals: '##w'.
	self assert: (position at: 2) second value token equals: '##e'.
	
	position do: [ :each | bpe fusion: each ].
	
	self assert: (position at: 1) first value token equals: '##we'.
	self assert: (position at: 2) first value token equals: '##we'.
]

{ #category : 'tests' }
TestWordPieceTrain >> testMergeOneStepIncreaseVocabulary [

	| wordpiece |
	wordpiece := WordPieceTrain new. 
	wordpiece fromText: self text2.
	
	self assert: wordpiece vocabulary size equals: 11.

	wordpiece mergesOneStep .
	
	self assert: (wordpiece vocabulary includes: 'wi') equals: true.
	self assert: wordpiece vocabulary size equals: 12.
	
	self assert: (wordpiece vocabulary size ~= wordpiece tokenFrequencies size) equals: true.
	self assert: (wordpiece tokenFrequencies keys asSet size = wordpiece tokenPositions keys size) equals: true.
	self assert: (wordpiece vocabulary ~= wordpiece tokenFrequencies keys asSet) equals: true.
	self assert: (wordpiece tokenFrequencies keys asSet = wordpiece tokenPositions keys asSet) equals: true.
	
	self assert: wordpiece vocabulary equals: #('l' '##o' '##w' '##e' '##r' 'n' '##s' '##t' 'wi' '##d' '##i' 'w' ) asSet.
	
	self assert: (wordpiece tokenFrequencies includes: 'w') equals: false .
	self assert: (wordpiece tokenFrequencies includes: '##i') equals: false .
	
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'l') equals: 7.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##o') equals: 7.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##w') equals: 13.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##e') equals: 17.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##r') equals: 2.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'n') equals: 6.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##s') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##t') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'wi') equals: 3.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##d') equals: 3.
]

{ #category : 'tests' }
TestWordPieceTrain >> testMergeOneStepRecomputePairs [

	|wordpiece|
	wordpiece := WordPieceTrain new.
	wordpiece corpus: self text2 .
	wordpiece computeVocabulary .
	wordpiece computePairs .
	wordpiece mergesOneStep .
	
	self assert: (wordpiece pairPositions keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairScores keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairPositions keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	self assert: (wordpiece pairScores keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	
	self assert: (wordpiece pairFrequencies includes: #('##i' '##d')) equals: false.
	self assert: (wordpiece pairFrequencies includes: #('w' '##i')) equals: false.
	
	self assert: wordpiece pairPositions keys asSet equals: #(#('l' '##o') #('##o' '##w') #('##w' '##e') #('##e' '##r') #('n' '##e') #('##e' '##w') #('##e' '##s') #('##s' '##t') 
	#('wi' '##d') #('##d' '##e') ) asSet.
	
	self assert: (wordpiece pairFrequencies occurrencesOf: #('l' '##o')) equals: 7.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##o' '##w')) equals: 7.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##w' '##e')) equals: 8.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##r')) equals: 2.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('n' '##e')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##w')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##s')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##s' '##t')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('wi' '##d')) equals: 3.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##d' '##e')) equals: 3.
	
	self assert: (wordpiece pairScores at: #('l' '##o')) equals: 7/(7*7)asFloat .
	self assert: (wordpiece pairScores at: #('##o' '##w')) equals: 7/(7*13)asFloat .
	self assert: (wordpiece pairScores at: #('##w' '##e')) equals: 8/(13*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##r')) equals: 2/(17*2)asFloat .
	self assert: (wordpiece pairScores at: #('n' '##e')) equals: 6/(6*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##w')) equals: 6/(17*13)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##s')) equals: 9/(17*9)asFloat .
	self assert: (wordpiece pairScores at: #('##s' '##t')) equals: 9/(9*9)asFloat .
	self assert: (wordpiece pairScores at: #('wi' '##d')) equals: 3/(3*3)asFloat .
	self assert: (wordpiece pairScores at: #('##d' '##e')) equals: 3/(3*17)asFloat .
]

{ #category : 'tests' }
TestWordPieceTrain >> testPairsAffectedByMerge [ 
	|wordpiece pair|
	
	wordpiece := WordPieceTrain new.
	wordpiece fromText: self text2 .
	pair:= #('##o' '##w').
	
	wordpiece pairsAffectedByMerging: pair .
	
	self assert: wordpiece affectedPairSet equals: #(#('l' '##o') #('##w' '##e') #('##e' '##w') #('##w' '##e'))asSet .
	
	
	
]

{ #category : 'tests' }
TestWordPieceTrain >> testThreeMergeOneStepIncreaseVocabulary [

	| wordpiece |
	wordpiece := WordPieceTrain new. 
	wordpiece fromText: self text2.
	
	self assert: wordpiece vocabulary size equals: 11.

	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	
	self assert: (wordpiece vocabulary includes: 'lo') equals: true.
	self assert: wordpiece vocabulary size equals: 14.
	
	self assert: (wordpiece vocabulary size ~= wordpiece tokenFrequencies keys size) equals: true.
	self assert: (wordpiece tokenFrequencies keys asSet size = wordpiece tokenPositions keys size) equals: true.
	self assert: (wordpiece vocabulary ~= wordpiece tokenFrequencies keys asSet) equals: true.
	self assert: (wordpiece tokenFrequencies keys asSet = wordpiece tokenPositions keys asSet) equals: true.
	
	self assert: wordpiece vocabulary equals: #('l' '##o' '##w' '##e' '##r' 'n' '##s' '##t' 'w' '##i' '##d' 'wi' 'wid' 'lo') asSet.
	
	self assert: (wordpiece tokenFrequencies includes: 'l') equals: false .
	self assert: (wordpiece tokenFrequencies includes: '##o') equals: false .
	
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'lo') equals: 7.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##w') equals: 13.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##e') equals: 17.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##r') equals: 2.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'n') equals: 6.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##s') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##t') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'wid') equals: 3.
]

{ #category : 'tests' }
TestWordPieceTrain >> testThreeMergeOneStepRecomputePairs [

	|wordpiece|
	wordpiece := WordPieceTrain new.
	wordpiece corpus: self text2 .
	wordpiece computeVocabulary .
	wordpiece computePairs .
	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	
	self assert: (wordpiece pairPositions keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairScores keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairPositions keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	self assert: (wordpiece pairScores keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	
	self assert: (wordpiece pairFrequencies includes: #('l' '##o')) equals: false.
	self assert: (wordpiece pairFrequencies includes: #('##o' '##w')) equals: false.
	
	self assert: wordpiece pairPositions keys asSet equals: #(#('lo' '##w') #('##w' '##e') #('##e' '##r') #('n' '##e') #('##e' '##w') #('##e' '##s') #('##s' '##t') 
	#('wid' '##e')) asSet.
	
	self assert: (wordpiece pairFrequencies occurrencesOf: #('lo' '##w')) equals: 7.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##w' '##e')) equals: 8.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##r')) equals: 2.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('n' '##e')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##w')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##s')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##s' '##t')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('wid' '##e')) equals: 3.
	
	self assert: (wordpiece pairScores at: #('lo' '##w')) equals: 7/(7*13)asFloat .
	self assert: (wordpiece pairScores at: #('##w' '##e')) equals: 8/(13*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##r')) equals: 2/(17*2)asFloat .
	self assert: (wordpiece pairScores at: #('n' '##e')) equals: 6/(6*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##w')) equals: 6/(17*13)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##s')) equals: 9/(17*9)asFloat .
	self assert: (wordpiece pairScores at: #('##s' '##t')) equals: 9/(9*9)asFloat .
	self assert: (wordpiece pairScores at: #('wid' '##e')) equals: 3/(3*17)asFloat .
]

{ #category : 'tests' }
TestWordPieceTrain >> testTwoMergeOneStepIncreaseVocabulary [

	| wordpiece |
	wordpiece := WordPieceTrain new. 
	wordpiece fromText: self text2.
	
	self assert: wordpiece vocabulary size equals: 11.

	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	
	self assert: (wordpiece vocabulary includes: 'wid') equals: true.
	self assert: wordpiece vocabulary size equals: 13.
	
	self assert: (wordpiece vocabulary size ~= wordpiece tokenFrequencies keys size) equals: true.
	self assert: (wordpiece tokenFrequencies keys asSet size = wordpiece tokenPositions keys size) equals: true.
	self assert: (wordpiece vocabulary ~= wordpiece tokenFrequencies keys asSet) equals: true.
	self assert: (wordpiece tokenFrequencies keys asSet = wordpiece tokenPositions keys asSet) equals: true.
	
	self assert: wordpiece vocabulary equals: #('l' '##o' '##w' '##e' '##r' 'n' '##s' '##t' 'w' '##i' '##d' 'wi' 'wid') asSet.
	
	self assert: (wordpiece tokenFrequencies includes: 'wi') equals: false .
	self assert: (wordpiece tokenFrequencies includes: '##d') equals: false .
	
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'l') equals: 7.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##o') equals: 7.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##w') equals: 13.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##e') equals: 17.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##r') equals: 2.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'n') equals: 6.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##s') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##t') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'wid') equals: 3.
]

{ #category : 'tests' }
TestWordPieceTrain >> testTwoMergeOneStepRecomputePairs [

	|wordpiece|
	wordpiece := WordPieceTrain new.
	wordpiece corpus: self text2 .
	wordpiece computeVocabulary .
	wordpiece computePairs .
	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	
	self assert: (wordpiece pairPositions keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairScores keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairPositions keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	self assert: (wordpiece pairScores keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	
	self assert: (wordpiece pairFrequencies includes: #('wi' '##d')) equals: false.
	self assert: (wordpiece pairFrequencies includes: #('##d' '##e')) equals: false.
	
	self assert: wordpiece pairPositions keys asSet equals: #(#('l' '##o') #('##o' '##w') #('##w' '##e') #('##e' '##r') #('n' '##e') #('##e' '##w') #('##e' '##s') #('##s' '##t') 
	#('wid' '##e')) asSet.
	
	self assert: (wordpiece pairFrequencies occurrencesOf: #('l' '##o')) equals: 7.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##o' '##w')) equals: 7.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##w' '##e')) equals: 8.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##r')) equals: 2.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('n' '##e')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##w')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##s')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##s' '##t')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('wid' '##e')) equals: 3.
	
	self assert: (wordpiece pairScores at: #('l' '##o')) equals: 7/(7*7)asFloat .
	self assert: (wordpiece pairScores at: #('##o' '##w')) equals: 7/(7*13)asFloat .
	self assert: (wordpiece pairScores at: #('##w' '##e')) equals: 8/(13*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##r')) equals: 2/(17*2)asFloat .
	self assert: (wordpiece pairScores at: #('n' '##e')) equals: 6/(6*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##w')) equals: 6/(17*13)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##s')) equals: 9/(17*9)asFloat .
	self assert: (wordpiece pairScores at: #('##s' '##t')) equals: 9/(9*9)asFloat .
	self assert: (wordpiece pairScores at: #('wid' '##e')) equals: 3/(3*17)asFloat .
]

{ #category : 'tests' }
TestWordPieceTrain >> testUpdate [ 
	| pair bpe|
	bpe := WordPieceTrain new.
	bpe fromText: self text2 .
	
	pair:= #('##w' '##e').
	
	self assert: (bpe tokenFrequencies occurrencesOf: '##w') equals: 13.
	self assert: (bpe tokenFrequencies occurrencesOf: '##e') equals: 17.
	self assert: (bpe tokenFrequencies occurrencesOf: '##r') equals: 2.
	self assert: (bpe tokenFrequencies occurrencesOf: 'l') equals: 7.
	self assert: (bpe tokenFrequencies occurrencesOf: '##o') equals: 7.
	self assert: (bpe tokenFrequencies occurrencesOf: 'n') equals: 6.
	self assert: (bpe tokenFrequencies occurrencesOf: '##s') equals: 9.
	self assert: (bpe tokenFrequencies occurrencesOf: '##t') equals: 9.
	self assert: (bpe tokenFrequencies occurrencesOf: 'w') equals: 3.
	self assert: (bpe tokenFrequencies occurrencesOf: '##i') equals: 3.
	self assert: (bpe tokenFrequencies occurrencesOf: '##d') equals: 3.
	
	self assert: bpe pairPositions keys asSet equals: #(#('l' '##o') #('##o' '##w') #('##w' '##e') #('##e' '##r') #('n' '##e') #('##e' '##w') #('##e' '##s') #('##s' '##t') 
	#('w' '##i') #('##i' '##d') #('##d' '##e') ) asSet.
	
	self assert: (bpe pairFrequencies occurrencesOf: #('l' '##o')) equals: 7.
	self assert: (bpe pairFrequencies occurrencesOf: #('##o' '##w')) equals: 7.
	self assert: (bpe pairFrequencies occurrencesOf: #('##w' '##e')) equals: 8.
	self assert: (bpe pairFrequencies occurrencesOf: #('##e' '##r')) equals: 2.
	self assert: (bpe pairFrequencies occurrencesOf: #('n' '##e')) equals: 6.
	self assert: (bpe pairFrequencies occurrencesOf: #('##e' '##w')) equals: 6.
	self assert: (bpe pairFrequencies occurrencesOf: #('##e' '##s')) equals: 9.
	self assert: (bpe pairFrequencies occurrencesOf: #('##s' '##t')) equals: 9.
	self assert: (bpe pairFrequencies occurrencesOf: #('w' '##i')) equals: 3.
	self assert: (bpe pairFrequencies occurrencesOf: #('##i' '##d')) equals: 3.
	self assert: (bpe pairFrequencies occurrencesOf: #('##d' '##e')) equals: 3.
	
	self assert: (bpe pairScores at: #('l' '##o')) equals: 7/(7*7)asFloat .
	self assert: (bpe pairScores at: #('##o' '##w')) equals: 7/(7*13)asFloat .
	self assert: (bpe pairScores at: #('##w' '##e')) equals: 8/(13*17)asFloat .
	self assert: (bpe pairScores at: #('##e' '##r')) equals: 2/(17*2)asFloat .
	self assert: (bpe pairScores at: #('n' '##e')) equals: 6/(6*17)asFloat .
	self assert: (bpe pairScores at: #('##e' '##w')) equals: 6/(17*13)asFloat .
	self assert: (bpe pairScores at: #('##e' '##s')) equals: 9/(17*9)asFloat .
	self assert: (bpe pairScores at: #('##s' '##t')) equals: 9/(9*9)asFloat .
	self assert: (bpe pairScores at: #('w' '##i')) equals: 3/(3*3)asFloat .
	self assert: (bpe pairScores at: #('##i' '##d')) equals: 3/(3*3)asFloat .
	self assert: (bpe pairScores at: #('##d' '##e')) equals: 3/(3*17)asFloat .
	
	bpe update: pair .
	
	self assert: (bpe tokenFrequencies occurrencesOf: '##w') equals: 5.
	self assert: (bpe tokenFrequencies occurrencesOf: '##we') equals: 8.
	self assert: (bpe tokenFrequencies occurrencesOf: '##e') equals: 9.
	self assert: (bpe tokenFrequencies occurrencesOf: '##r') equals: 2.
	self assert: (bpe tokenFrequencies occurrencesOf: 'l') equals: 7.
	self assert: (bpe tokenFrequencies occurrencesOf: '##o') equals: 7.
	self assert: (bpe tokenFrequencies occurrencesOf: 'n') equals: 6.
	self assert: (bpe tokenFrequencies occurrencesOf: '##s') equals: 9.
	self assert: (bpe tokenFrequencies occurrencesOf: '##t') equals: 9.
	self assert: (bpe tokenFrequencies occurrencesOf: 'w') equals: 3.
	self assert: (bpe tokenFrequencies occurrencesOf: '##i') equals: 3.
	self assert: (bpe tokenFrequencies occurrencesOf: '##d') equals: 3.
	
	self assert: (bpe pairFrequencies occurrencesOf: #('l' '##o')) equals: 7.
	self assert: (bpe pairFrequencies occurrencesOf: #('##o' '##w')) equals: 5.
	self assert: (bpe pairFrequencies occurrencesOf: #('##w' '##e')) equals: 0.
	self assert: (bpe pairFrequencies occurrencesOf: #('##o' '##we')) equals: 2.
	self assert: (bpe pairFrequencies occurrencesOf: #('##we' '##r')) equals: 2.
	self assert: (bpe pairFrequencies occurrencesOf: #('n' '##e')) equals: 6.
	self assert: (bpe pairFrequencies occurrencesOf: #('##e' '##we')) equals: 6.
	self assert: (bpe pairFrequencies occurrencesOf: #('##we' '##s')) equals: 6.
	self assert: (bpe pairFrequencies occurrencesOf: #('##e' '##s')) equals: 3.
	self assert: (bpe pairFrequencies occurrencesOf: #('##s' '##t')) equals: 9.
	self assert: (bpe pairFrequencies occurrencesOf: #('w' '##i')) equals: 3.
	self assert: (bpe pairFrequencies occurrencesOf: #('##i' '##d')) equals: 3.
	self assert: (bpe pairFrequencies occurrencesOf: #('##d' '##e')) equals: 3.
	
	self assert: bpe pairPositions keys asSet equals: #(#('l' '##o') #('##o' '##w') #('##o' '##we') #('##we' '##r') #('n' '##e') #('##e' '##we') #('##we' '##s') #('##s' '##t') 
	#('w' '##i') #('##i' '##d') #('##d' '##e') #('##e' '##s') ) asSet.
	
	self assert: (bpe pairScores at: #('l' '##o')) equals: 7/(7*7)asFloat .
	self assert: (bpe pairScores at: #('##o' '##w')) equals: 5/(7*5)asFloat .
	self assert: (bpe pairScores at: #('##o' '##we')) equals: 2/(7*8)asFloat .
	self assert: (bpe pairScores at: #('##we' '##r')) equals: 2/(8*2)asFloat .
	self assert: (bpe pairScores at: #('n' '##e')) equals: 6/(6*9)asFloat .
	self assert: (bpe pairScores at: #('##e' '##we')) equals: 6/(9*8)asFloat .
	self assert: (bpe pairScores at: #('##we' '##s')) equals: 6/(8*9)asFloat .
	self assert: (bpe pairScores at: #('##s' '##t')) equals: 9/(9*9)asFloat .
	self assert: (bpe pairScores at: #('w' '##i')) equals: 3/(3*3)asFloat .
	self assert: (bpe pairScores at: #('##i' '##d')) equals: 3/(3*3)asFloat .
	self assert: (bpe pairScores at: #('##d' '##e')) equals: 3/(3*9)asFloat .
	self assert: (bpe pairScores at: #('##e' '##s')) equals: 3/(9*9)asFloat .
	self assert: (bpe pairScores includesKey: #('##w' '##e')) equals: false.
	
	self assert: bpe affectedPairSet equals: #(#('##o' '##w') #('##e' '##w') #('n' '##e') #('##e' '##r') #('##e' '##s') #('##d' '##e')) asSet .
	
	
	
	
	
	
	
]

{ #category : 'tests' }
TestWordPieceTrain >> testUpdateAfterThreeMergeOneStepIncreaseVocabulary [

	| wordpiece |
	wordpiece := WordPieceTrain new. 
	wordpiece fromText: self text2.
	
	self assert: wordpiece vocabulary size equals: 11.

	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	wordpiece addToVocabulary: 'low'.
	wordpiece update: #('lo' '##w').
	
	self assert: (wordpiece vocabulary includes: 'low') equals: true.
	self assert: wordpiece vocabulary size equals: 15.
	
	self assert: (wordpiece vocabulary size ~= wordpiece tokenFrequencies keys size) equals: true.
	self assert: (wordpiece tokenFrequencies keys asSet size = wordpiece tokenPositions keys size) equals: true.
	self assert: (wordpiece vocabulary ~= wordpiece tokenFrequencies keys asSet) equals: true.
	self assert: (wordpiece tokenFrequencies keys asSet = wordpiece tokenPositions keys asSet) equals: true.
	
	self assert: wordpiece vocabulary equals: #('l' '##o' '##w' '##e' '##r' 'n' '##s' '##t' 'w' '##i' '##d' 'wi' 'wid' 'lo' 'low') asSet.
	
	self assert: (wordpiece tokenFrequencies includes: 'lo') equals: false .
	self assert: (wordpiece tokenFrequencies includes: '##w') equals: true.
	
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'low') equals: 7.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##w') equals: 6.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##e') equals: 17.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##r') equals: 2.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'n') equals: 6.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##s') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: '##t') equals: 9.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'wid') equals: 3.
]

{ #category : 'tests' }
TestWordPieceTrain >> testUpdateAfterThreeMergeOneStepRecomputePairs [

	|wordpiece|
	wordpiece := WordPieceTrain new.
	wordpiece corpus: self text2 .
	wordpiece computeVocabulary .
	wordpiece computePairs .
	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	wordpiece mergesOneStep .
	wordpiece update: #('lo' '##w').
	
	self assert: (wordpiece pairPositions keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairScores keys size = wordpiece pairFrequencies keys size) equals: true.
	self assert: (wordpiece pairPositions keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	self assert: (wordpiece pairScores keys asSet = wordpiece pairFrequencies keys asSet ) equals: true.
	
	self assert: (wordpiece pairFrequencies includes: #('lo' '##w')) equals: false.
	
	self assert: wordpiece pairPositions keys asSet equals: #( #('##w' '##e') #('low' '##e') #('##e' '##r') #('n' '##e') #('##e' '##w') #('##e' '##s') #('##s' '##t') 
	#('wid' '##e')) asSet.
	
	self assert: (wordpiece pairFrequencies occurrencesOf: #('low' '##e')) equals: 2.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##w' '##e')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##r')) equals: 2.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('n' '##e')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##w')) equals: 6.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##e' '##s')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('##s' '##t')) equals: 9.
	self assert: (wordpiece pairFrequencies occurrencesOf: #('wid' '##e')) equals: 3.
	
	self assert: (wordpiece pairScores at: #('low' '##e')) equals: 2/(7*17)asFloat .
	self assert: (wordpiece pairScores at: #('##w' '##e')) equals: 6/(6*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##r')) equals: 2/(17*2)asFloat .
	self assert: (wordpiece pairScores at: #('n' '##e')) equals: 6/(6*17)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##w')) equals: 6/(17*6)asFloat .
	self assert: (wordpiece pairScores at: #('##e' '##s')) equals: 9/(17*9)asFloat .
	self assert: (wordpiece pairScores at: #('##s' '##t')) equals: 9/(9*9)asFloat .
	self assert: (wordpiece pairScores at: #('wid' '##e')) equals: 3/(3*17)asFloat .
]

{ #category : 'tests' }
TestWordPieceTrain >> testUpdateToLettersAndLettersPosition [ 
	|wordpiece subword|
	wordpiece := WordPieceTrain new.
	
	self assert: wordpiece tokenFrequencies size equals: 0.
	self assert: wordpiece tokenPositions size equals: 0.
	
	subword := Token token: 'l' occurence: 1 position: 0.
	wordpiece addToTokenFrequenciesAndTokenPositions: subword .
	
	subword := Token token: 'l' occurence: 2 position: 3.
	wordpiece addToTokenFrequenciesAndTokenPositions: subword .
	
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'l') equals: 3.
	self assert: (wordpiece tokenPositions at: 'l') equals: #(0 3) asSet.
	
	subword := Token token: 'l' occurence: 1 position: 0.
	wordpiece updateTokenFrequenciesAndFrequenciesPositions: subword .
	
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'l') equals: 2.
	self assert: (wordpiece tokenPositions at: 'l') equals: #(3) asSet.
]

{ #category : 'tests' }
TestWordPieceTrain >> testaddToTokenFrequenciesAndTokenPositions [ 
	|wordpiece subword subword1 |
	wordpiece := WordPieceTrain new.
	
	self assert: wordpiece pairFrequencies size equals: 0.
	self assert: wordpiece pairPositions size equals: 0.
	self assert: wordpiece pairScores size equals: 0.
	
	subword := Token token: 'l' occurence: 2 position: 1.
	subword1 := Token token: 'd' occurence: 3 position: 4.
	wordpiece addNewPairFrom: subword and: subword1 .
	wordpiece addToTokenFrequenciesAndTokenPositions: subword .
	wordpiece addToTokenFrequenciesAndTokenPositions: subword1 .
	
	self assert: (wordpiece pairFrequencies occurrencesOf: #('l' 'd')) equals: 2.
	self assert: (wordpiece pairPositions at: #('l' 'd')) equals: #(#(1 4))asSet .
	self assert: (wordpiece pairScores size) equals: 0.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'l') equals: 2.
	self assert: (wordpiece tokenFrequencies occurrencesOf: 'd') equals: 3.
	self assert: (wordpiece tokenPositions at: 'l') equals: #(1)asSet.
	self assert: (wordpiece tokenPositions at: 'd') equals: #(4)asSet.
	
	wordpiece addNewPairScoresFrom: subword and: subword1 .
	
	self assert: (wordpiece pairScores at: #('l' 'd')) equals: 2/(2*3)asFloat.
	

]

{ #category : 'accessing structure variables' }
TestWordPieceTrain >> text2 [
	^ '
low low low low low
lower lower
newest newest newest newest newest newest 
widest widest widest'
]
