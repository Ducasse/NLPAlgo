Class {
	#name : 'TestBPEApplier',
	#superclass : 'TestCase',
	#category : 'BPE4',
	#package : 'BPE4'
}

{ #category : 'ressources' }
TestBPEApplier >> bagResult [

	| bag |
	bag := Bag new.
	bag
		add: { 'low'. '</t>' } asOrderedCollection 
		withOccurrences: 5;
		add: { 'low'. 'e'. 'r'. '</t>' } asOrderedCollection
		withOccurrences: 2;
		add: { 'n'. 'e'. 'w'. 'est</t>' } asOrderedCollection
		withOccurrences: 6;
		add: { 'w'. 'i'. 'd'. 'est</t>' } asOrderedCollection
		withOccurrences: 3.
	^ bag
]

{ #category : 'ressources' }
TestBPEApplier >> rawCorpus [ 
	^ {'old' . 'old' . 'old' . 'old' . 'old' . 'old' . 'old' . 'older' . 'older' . 'older' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'lowest' . 'lowest' . 'lowest' . 'lowest'}
]

{ #category : 'tests' }
TestBPEApplier >> testApplyRules [

	| bpeApplier bpeLearner |
	bpeLearner := BPELearner new.
	bpeLearner fromText: self text.
	12 timesRepeat: [ bpeLearner mergesOneStep ].
	bpeApplier := BPEApplier new.
	bpeApplier fromText: self text2.
	bpeApplier computePairs.
	bpeApplier applyRulesFrom: bpeLearner.
	self assert: bpeApplier tokens equals: self bagResult
]

{ #category : 'ressources' }
TestBPEApplier >> text [
	^ 'old old old old old old old 
lower lower lower
finest finest finest finest finest finest finest finest finest 
lowest lowest lowest lowest 
'
]

{ #category : 'ressources' }
TestBPEApplier >> text2 [
	^ '
low low low low low
lower lower
newest newest newest newest newest newest 
widest widest widest'
]
