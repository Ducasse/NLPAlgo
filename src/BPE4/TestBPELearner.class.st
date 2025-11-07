Class {
	#name : 'TestBPELearner',
	#superclass : 'TestCase',
	#category : 'BPE4',
	#package : 'BPE4'
}

{ #category : 'ressources' }
TestBPELearner >> rawCorpus [ 
	^ {'old' . 'old' . 'old' . 'old' . 'old' . 'old' . 'old' . 'older' . 'older' . 'older' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'lowest' . 'lowest' . 'lowest' . 'lowest'}
]

{ #category : 'tests' }
TestBPELearner >> testBuildVocabularyProducesCorrectVocabulary [

	| enc |
	enc := BPELearner new. 
	enc fromText: self text.
	self 
		assertCollection: enc vocabulary asSet
		hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'f' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
TestBPELearner >> testBuildVocabularyProducesCorrectVocabularyFromArray [

	| enc |
	enc := BPELearner new. 
	enc fromText: self rawCorpus .
	self 
		assertCollection: enc vocabulary asSet
		hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'f' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
TestBPELearner >> testBuildVocabularyProducesCorrectVocabularyText2 [

	| enc |
	enc := BPELearner new. 
	enc fromText: self text2.
	enc computeVocabulary.
	self assertCollection: enc vocabulary asSet hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
TestBPELearner >> testComputePairs [

	| enc |
	enc := BPELearner new. 
	enc fromText: self text.
	
	self assert: (enc pairs occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'s' .'t'}) equals: 13. 
	self assert: (enc pairs occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc pairs occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairs occurrencesOf: {'t' . '</t>'}) equals: 13. 
	
	self assert: enc pairs size equals: 114.
	self assert: enc pairs keys size equals: 15
]

{ #category : 'tests' }
TestBPELearner >> testComputePairsArray [

	| enc |
	enc := BPELearner new. 
	enc fromText: self rawCorpus .
	
	self assert: (enc pairs occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'s' .'t'}) equals: 13. 
	self assert: (enc pairs occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc pairs occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairs occurrencesOf: {'t' . '</t>'}) equals: 13. 
	
	self assert: enc pairs keys size equals: 15
]

{ #category : 'tests' }
TestBPELearner >> testComputePairsText2 [

	| enc |
	enc := BPELearner new. 
	enc fromText: self text2.
	
	self assert: (enc pairs occurrencesOf: {'e' .'s'}) equals: 9. 
	self assert: (enc pairs occurrencesOf: {'i'. 'd'}) equals: 3. 
	self assert: (enc pairs occurrencesOf: {'o' .'w'}) equals: 7. 
	self assert: (enc pairs occurrencesOf: {'s'. 't'}) equals: 9. 
	self assert: (enc pairs occurrencesOf: {'w'. 'e'}) equals: 8. 
	self assert: (enc pairs occurrencesOf: {'w'. 'i'}) equals: 3. 
	self assert: (enc pairs occurrencesOf: {'t'.'</t>'}) equals: 9. 

	 "#('lo' 't_' 'er' 'r_' 'st' 'wi' 'es' 'ne' 'ow' 'we' 'w_' 'id' 'de' 'ew')"
	self assert: enc pairs keys size equals: 14
]

{ #category : 'tests' }
TestBPELearner >> testMergeOneStepAddMergeToMergeList [

	| enc |
	enc := BPELearner new. 
	enc fromText: self text.
	enc computeVocabulary.
	
	self assert: enc merges isEmpty.
	enc mergesOneStep .
	self assert: enc merges first equals: #('t' '</t>')->'t</t>'
]

{ #category : 'tests' }
TestBPELearner >> testMergeOneStepIncreaseVocabularyAndMerges [

	| enc mergeOldSize |
	enc := BPELearner new. 
	enc fromText: self text.
	
	self assert: enc vocabulary size equals: 12.
	mergeOldSize := enc merges size.
	enc mergesOneStep .
	self assert: (enc vocabulary includes: 't</t>').
	self assert: enc merges size equals: mergeOldSize + 1.
	self assert: enc vocabulary size equals: 13
]

{ #category : 'tests' }
TestBPELearner >> testMergeOneStepRecomputePairs [

	| enc|
	enc := BPELearner new. 
	enc fromText: self text.
	
	enc mergesOneStep .
	
	self assert: (enc pairs occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairs occurrencesOf: {'s' . 't</t>'}) equals: 13. 
	self assert: (enc pairs occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairs occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc pairs occurrencesOf: {'w' . 'e'}) equals: 4. 
	self assert: (enc pairs occurrencesOf: {'n' . 'e'}) equals: 9. 
]

{ #category : 'test - tokenisation' }
TestBPELearner >> testPrepareFrom [

	| bpeLearner b |
	bpeLearner := BPELearner new.
	b := bpeLearner prepareWordsFrom: self rawCorpus.
	self assert: b class equals: Bag.
	self flag: #betterTest
]

{ #category : 'test - tokenisation' }
TestBPELearner >> testPrepareFromText [

	| bpeLearner b |
	bpeLearner := BPELearner new.
	b := bpeLearner prepareWordsFromText: self text.
	self assert: b class equals: Bag.
	self flag: #betterTest
]

{ #category : 'tests' }
TestBPELearner >> testTwoMerges [

	| enc |
	enc := BPELearner new. 
	enc fromText: self text.
	enc computeVocabulary.
	enc mergesOneStep .
	enc mergesOneStep .
	
	self assert: enc merges first equals: #('t' '</t>')->'t</t>'. 
	self assert: enc merges second equals: #('e' 's')->'es'. 
]

{ #category : 'ressources' }
TestBPELearner >> text [
	^ 'old old old old old old old 
older older older
finest finest finest finest finest finest finest finest finest 
lowest lowest lowest lowest 
'
]

{ #category : 'ressources' }
TestBPELearner >> text2 [
	^ '
low low low low low
lower lower
newest newest newest newest newest newest 
widest widest widest'
]
