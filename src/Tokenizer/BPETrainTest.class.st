Class {
	#name : 'BPETrainTest',
	#superclass : 'TestCase',
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'ressources' }
BPETrainTest >> rawCorpus [ 
	^ {'old' . 'old' . 'old' . 'old' . 'old' . 'old' . 'old' . 'older' . 'older' . 'older' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'lowest' . 'lowest' . 'lowest' . 'lowest'}
]

{ #category : 'tests' }
BPETrainTest >> testAddNewPairFrom [ 
	|bpe subword subword1 subword2 subword3|
	bpe:= BPETrain new.
	
	subword := Token token: 'a' occurence: 5 position: 1.
	subword1 := Token token: 'b' occurence: 5 position: 2.
	bpe addNewPairFrom: subword and: subword1 .
	
	self assert: bpe pairFrequencies size  equals: 5.
	self assert: (bpe pairFrequencies occurrencesOf: #(#a #b))  equals: 5. 
	self assert: (bpe pairPositions at:#(#a #b) ) size equals: 1.
	
	subword2 := Token token: 'c' occurence: 1 position: 0.
	subword3 := Token token: 'd' occurence: 2 position: 3.
	bpe addNewPairFrom: subword2 and: subword3 .
	
	self assert: bpe pairFrequencies size  equals: 6.
	self assert: (bpe pairFrequencies occurrencesOf: #(#c #d))  equals: 1.
	self assert: (bpe pairPositions at:#(#c #d) ) size equals: 1.
	
	subword := Token token: 'a' occurence: 5 position: 1.
	subword1 := Token token: 'b' occurence: 5 position: 2.
	bpe addNewPairFrom: subword and: subword1 .
	
	self assert: bpe pairFrequencies size  equals: 11.
	self assert: (bpe pairFrequencies occurrencesOf: #(#a #b))  equals: 10.
	self assert: (bpe pairPositions at:#(#a #b) ) size equals: 1.
	
	subword := Token token: 'a' occurence: 3 position: 4.
	subword1 := Token token: 'b' occurence: 3 position: 5.
	bpe addNewPairFrom: subword and: subword1 .
	
	self assert: bpe pairFrequencies size  equals: 14.
	self assert: (bpe pairFrequencies occurrencesOf: #(#a #b))  equals: 13.
	self assert: (bpe pairPositions at:#(#a #b) ) size equals: 2.
	
	
	
	
]

{ #category : 'tests' }
BPETrainTest >> testBuildVocabularyProducesCorrectVocabulary [

	| enc |
	enc := BPETrain new. 
	enc fromText: self text.
	self 
		assertCollection: enc vocabulary asSet
		hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'f' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
BPETrainTest >> testBuildVocabularyProducesCorrectVocabularyFromArray [

	| enc |
	enc := BPETrain new. 
	enc fromText: self rawCorpus .
	self 
		assertCollection: enc vocabulary asSet
		hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'f' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
BPETrainTest >> testBuildVocabularyProducesCorrectVocabularyText2 [

	| enc |
	enc := BPETrain new. 
	enc fromText: self text2.
	enc computeVocabulary.
	self assertCollection: enc vocabulary asSet hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
BPETrainTest >> testComputePairs [

	| enc |
	enc := BPETrain new. 
	enc fromText: self text.
	
	self assert: (enc pairFrequencies occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'s' .'t'}) equals: 13. 
	self assert: (enc pairFrequencies occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairFrequencies occurrencesOf: {'t' . '</t>'}) equals: 13. 
	
	self assert: enc pairFrequencies size equals: 114.
	self assert: enc pairFrequencies keys size equals: 15
]

{ #category : 'tests' }
BPETrainTest >> testComputePairsArray [

	| enc |
	enc := BPETrain new. 
	enc fromText: self rawCorpus .
	
	self assert: (enc pairFrequencies occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'s' .'t'}) equals: 13. 
	self assert: (enc pairFrequencies occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairFrequencies occurrencesOf: {'t' . '</t>'}) equals: 13. 
	
	self assert: enc pairFrequencies keys size equals: 15
]

{ #category : 'tests' }
BPETrainTest >> testComputePairsText2 [

	| enc |
	enc := BPETrain new. 
	enc fromText: self text2.
	
	self assert: (enc pairFrequencies occurrencesOf: {'e' .'s'}) equals: 9. 
	self assert: (enc pairFrequencies occurrencesOf: {'i'. 'd'}) equals: 3. 
	self assert: (enc pairFrequencies occurrencesOf: {'o' .'w'}) equals: 7. 
	self assert: (enc pairFrequencies occurrencesOf: {'s'. 't'}) equals: 9. 
	self assert: (enc pairFrequencies occurrencesOf: {'w'. 'e'}) equals: 8. 
	self assert: (enc pairFrequencies occurrencesOf: {'w'. 'i'}) equals: 3. 
	self assert: (enc pairFrequencies occurrencesOf: {'t'.'</t>'}) equals: 9. 

	 "#('lo' 't_' 'er' 'r_' 'st' 'wi' 'es' 'ne' 'ow' 'we' 'w_' 'id' 'de' 'ew')"
	self assert: enc pairFrequencies keys size equals: 14
]

{ #category : 'tests' }
BPETrainTest >> testFusion [ 
	|position pair bpe|
	bpe := BPETrain new.
	bpe fromText: self text.
	
	pair:= #('e' 's').
	position := (bpe pairPositions at: pair) asArray .
	
	self assert: position size equals: 2.
	
	self assert: (position at: 1) first value token equals: 'e'.
	self assert: (position at: 1) second value token equals: 's'.
	self assert: (position at: 2) first value token equals: 'e'.
	self assert: (position at: 2) second value token equals: 's'.
	
	position do: [ :each | bpe fusion: each ].
	
	self assert: (position at: 1) first value token equals: 'es'.
	self assert: (position at: 2) first value token equals: 'es'.
	
]

{ #category : 'tests' }
BPETrainTest >> testMergeOneStepAddMergeToMergeList [

	| enc |
	enc := BPETrain new. 
	enc fromText: self text.
	enc computeVocabulary.
	
	self assert: enc merges isEmpty.
	enc mergesOneStep .
	self assert: enc merges first equals: #('t' '</t>')->'t</t>'
]

{ #category : 'tests' }
BPETrainTest >> testMergeOneStepIncreaseVocabularyAndMerges [

	| enc mergeOldSize |
	enc := BPETrain new. 
	enc fromText: self text.
	
	self assert: enc vocabulary size equals: 12.
	mergeOldSize := enc merges size.
	enc mergesOneStep .
	self assert: (enc vocabulary includes: 't</t>').
	self assert: enc merges size equals: mergeOldSize + 1.
	self assert: enc vocabulary size equals: 13
]

{ #category : 'tests' }
BPETrainTest >> testMergeOneStepRecomputePairs [

	| enc|
	enc := BPETrain new. 
	enc fromText: self text.
	
	enc mergesOneStep .
	
	self assert: (enc pairFrequencies occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'s' . 't</t>'}) equals: 13. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairFrequencies occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc pairFrequencies occurrencesOf: {'w' . 'e'}) equals: 4. 
	self assert: (enc pairFrequencies occurrencesOf: {'n' . 'e'}) equals: 9. 
]

{ #category : 'tests' }
BPETrainTest >> testText3 [ 

	|b|
	b:= BPETrain new .
	b fromText: self text3 .
	
	self assert: (b pairFrequencies ) equals: #(#('a' 'a') #('a' 'a') #('a' 'a') #('a' '</t>') #('a' '</t>') #('b' 'a'))asBag .
	
	b mergesOneStep .
	
	self assert: (b pairFrequencies ) equals: #(#('aa' 'a') #('a' '</t>') #('aa' '</t>') #('b' 'aa'))asBag .
]

{ #category : 'tests' }
BPETrainTest >> testText4 [ 

	|b|
	b:= BPETrain new.
	b fromText: self text4 .
	
	self assert: b pairFrequencies equals: #(#('a' 'a') #('a' 'a') #('a' '</t>') #('b' 'a')  #('a' 'b') #('b' '</t>'))asBag .
	self assert: (b findPairToMerge) equals: #('a' 'a').
	
	b mergesOneStep .
	
	self assert: (b vocabulary includes: 'aa') equals: true.
	
	self assert: b pairFrequencies equals: #(#('aa' '</t>') #('b' 'aa') #('aa' 'b') #('b' '</t>'))asBag .
]

{ #category : 'tests' }
BPETrainTest >> testText5 [ 

	|b|
	b:= BPETrain new.
	b fromText: self text5 .
	
	self assert: b pairFrequencies equals: #(#('b' 'a') #('a' 'a') #('a' '</t>') #('a' 'a') #('a' '</t>') #('a' '</t>'))asBag .
	
	b mergesOneStep.
	
	self assert: b pairFrequencies equals: #(#('b' 'a') #('a' 'a</t>') #('a' 'a</t>'))asBag .
]

{ #category : 'tests' }
BPETrainTest >> testThreeMergeOneStepIncreaseVocabularyAndMerges [

	| enc mergeOldSize |
	enc := BPETrain new. 
	enc fromText: self text.
	
	self assert: enc vocabulary size equals: 12.
	mergeOldSize := enc merges size.
	enc mergesOneStep .
	enc mergesOneStep .
	enc mergesOneStep.
	self assert: (enc vocabulary includes: 't</t>').
	self assert: (enc vocabulary includes: 'es').
	self assert: (enc vocabulary includes: 'est</t>').
	self assert: enc merges size equals: mergeOldSize + 3.
	self assert: enc vocabulary size equals: 15.
]

{ #category : 'tests' }
BPETrainTest >> testThreeMergeOneStepRecomputePairs [

	| enc|
	enc := BPETrain new. 
	enc fromText: self text.
	
	enc mergesOneStep .
	enc mergesOneStep .
	enc mergesOneStep .
	
	self assert: (enc pairFrequencies occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'es' . 't</t>'}) equals: 0. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairFrequencies occurrencesOf: {'w' . 'est</t>'}) equals: 4. 
	self assert: (enc pairFrequencies occurrencesOf: {'f' . 'i'}) equals: 9.
	self assert: (enc pairFrequencies occurrencesOf: {'i' . 'n'}) equals: 9.
	self assert: (enc pairFrequencies occurrencesOf: {'n' . 'est</t>'}) equals: 9.
]

{ #category : 'tests' }
BPETrainTest >> testTrainOnVocabularySizeBatchSize [

	|b|
	b:= BPETrain trainOn: self text vocabularySize: 15 batchSize: 3.
	
	self assert: (b vocabulary includes: 'es') equals: true.
	self assert: (b vocabulary includes: 't</t>') equals: true.
	self assert: (b vocabulary includes: 'est</t>') equals: true.
	self assert: b vocabulary size equals: 15.
	
	b := BPETrain trainOn: self text vocabularySize: 20 batchSize: 3.
	
	self assert: (b vocabulary includes: 'es') equals: true.
	self assert: (b vocabulary includes: 't</t>') equals: true.
	self assert: (b vocabulary includes: 'est</t>') equals: true.
	self assert: (b vocabulary includes: 'ld') equals: true.
	self assert: (b vocabulary includes: 'old') equals: true.
	self assert: (b vocabulary includes: 'fi') equals: true.
	self assert: (b vocabulary includes: 'nest</t>') equals: true.
	self assert: (b vocabulary includes: 'finest</t>') equals: true.
	self assert: b vocabulary size equals: 20.
	
	
	
	
	

]

{ #category : 'tests' }
BPETrainTest >> testTwoMergeOneStepIncreaseVocabularyAndMerges [

	| enc mergeOldSize |
	enc := BPETrain new. 
	enc fromText: self text.
	
	self assert: enc vocabulary size equals: 12.
	mergeOldSize := enc merges size.
	enc mergesOneStep .
	enc mergesOneStep .
	self assert: (enc vocabulary includes: 't</t>').
	self assert: (enc vocabulary includes: 'es').
	self assert: enc merges size equals: mergeOldSize + 2.
	self assert: enc vocabulary size equals: 14.
]

{ #category : 'tests' }
BPETrainTest >> testTwoMergeOneStepRecomputePairs [

	| enc|
	enc := BPETrain new. 
	enc fromText: self text.
	
	enc mergesOneStep .
	enc mergesOneStep .
	
	self assert: (enc pairFrequencies occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairFrequencies occurrencesOf: {'es' . 't</t>'}) equals: 13. 
	self assert: (enc pairFrequencies occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairFrequencies occurrencesOf: {'w' . 'es'}) equals: 4. 
	self assert: (enc pairFrequencies occurrencesOf: {'n' . 'es'}) equals: 9. 
]

{ #category : 'tests' }
BPETrainTest >> testTwoMerges [

	| enc |
	enc := BPETrain new. 
	enc fromText: self text.
	enc computeVocabulary.
	enc mergesOneStep .
	enc mergesOneStep .
	
	self assert: enc merges first equals: #('t' '</t>')->'t</t>'. 
	self assert: enc merges second equals: #('e' 's')->'es'. 
]

{ #category : 'tests' }
BPETrainTest >> testUpdate [ 
	|position pair bpe|
	bpe := BPETrain new.
	bpe fromText: self text.
	
	pair:= #('l' 'd').
	position := (bpe pairPositions at: pair) .
	
	self assert: position size equals: 2.
	self assert: (bpe pairFrequencies occurrencesOf: pair) equals: 10.
	self assert: (bpe pairFrequencies occurrencesOf: #('o' 'l')) equals: 10. 
	self assert: (bpe pairFrequencies occurrencesOf: #('d' '</t>')) equals: 7.
	self assert: (bpe pairFrequencies occurrencesOf: #('d' 'e')) equals: 3. 
	self assert: (bpe pairPositions includesKey: pair) equals: true.
	self assert: (bpe pairPositions includesKey: #('o' 'l')) equals: true. 
	self assert: (bpe pairPositions includesKey: #('d' '</t>')) equals: true.
	self assert: (bpe pairPositions includesKey: #('d' 'e')) equals: true. 
	
	bpe update: pair .
	
	self assert: (bpe pairFrequencies occurrencesOf: pair) equals: 0.
	self assert: (bpe pairFrequencies occurrencesOf: #('o' 'l')) equals: 0. 
	self assert: (bpe pairFrequencies occurrencesOf: #('d' '</t>')) equals: 0.
	self assert: (bpe pairFrequencies occurrencesOf: #('d' 'e')) equals: 0. 
	self assert: (bpe pairPositions includesKey: pair) equals: false.
	self assert: (bpe pairPositions includesKey: #('o' 'l')) equals: false. 
	self assert: (bpe pairPositions includesKey: #('d' '</t>')) equals: false.
	self assert: (bpe pairPositions includesKey: #('d' 'e')) equals: false. 
	
	self assert: (bpe pairFrequencies occurrencesOf: #('o' 'ld')) equals: 10. 
	self assert: (bpe pairFrequencies occurrencesOf: #('ld' '</t>')) equals: 7.
	self assert: (bpe pairFrequencies occurrencesOf: #('ld' 'e')) equals: 3.
	self assert: (bpe pairPositions includesKey: #('o' 'ld')) equals: true. 
	self assert: (bpe pairPositions includesKey: #('ld' '</t>')) equals: true.
	self assert: (bpe pairPositions includesKey: #('ld' 'e')) equals: true.
	 

]

{ #category : 'tests' }
BPETrainTest >> testUpdatePairFrom [ 
	|bpe subword subword1|
	bpe:= BPETrain new.
	
	subword := Token token: 'a' occurence: 5 position: 1.
	subword1 := Token token: 'b' occurence: 5 position: 2.
	bpe addNewPairFrom: subword and: subword1 .
	
	subword := Token token: 'a' occurence: 3 position: 3.
	subword1 := Token token: 'b' occurence: 3 position: 4.
	bpe addNewPairFrom: subword and: subword1 .
	
	self assert: bpe pairFrequencies size  equals: 8.
	self assert: (bpe pairFrequencies occurrencesOf: #(#a #b))  equals: 8. 
	self assert: (bpe pairPositions at:#(#a #b) ) equals: #(#(1 2) #(3 4))asSet .
	
	subword := Token token: 'a' occurence: 5 position: 1.
	subword1 := Token token: 'b' occurence: 5 position: 2.
	bpe updatePairFrom: subword and: subword1 .
	
	self assert: bpe pairFrequencies size  equals: 3.
	self assert: (bpe pairFrequencies occurrencesOf: #(#a #b))  equals: 3. 
	self assert: (bpe pairPositions at:#(#a #b) ) equals: #(#(3 4))asSet .
	
	
	
	
	
	
]

{ #category : 'ressources' }
BPETrainTest >> text [
	^ 'old old old old old old old 
older older older
finest finest finest finest finest finest finest finest finest 
lowest lowest lowest lowest 
'
]

{ #category : 'ressources' }
BPETrainTest >> text2 [
	^ '
low low low low low
lower lower
newest newest newest newest newest newest 
widest widest widest'
]

{ #category : 'nil' }
BPETrainTest >> text3 [

	^'aaa baa'
]

{ #category : 'accessing structure variables' }
BPETrainTest >> text4 [

	^'aa baab'
]

{ #category : 'accessing structure variables' }
BPETrainTest >> text5 [ 

	^'baa aa a'
]
