Class {
	#name : 'WordPieceEncoderTest',
	#superclass : 'TestCase',
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'tests' }
WordPieceEncoderTest >> testComputeFailureLinkAndFailurePop [

	|w|
	w := WordPieceEncoder new .
	w vocabulary addAll: { 'a' . 'abcdx' . '##b' . '##c' . '##cdy' . '##dz' } . 
	w buildTrieAndInitializeFailureData .
	w computeFailureLinkAndFailurePop.
	
	self assert: ( w failureLink at: ( w trie rootNode )) equals: nil .
	self assert: ( w failurePop at: ( w trie rootNode )) equals: #()asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: '#' )) equals: nil .
	self assert: (w failurePop at: ( w trie findPrefix: '#' )) equals: #()asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: '##' )) equals: nil .
	self assert: (w failurePop at: ( w trie findPrefix: '##' )) equals: #()asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: 'a' )) equals: ( w trie findPrefix: '##' ) .
	self assert: (w failurePop at: ( w trie findPrefix: 'a' )) equals: { 'a' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: 'ab' )) equals: ( w trie findPrefix: '##b' ) .
	self assert: (w failurePop at: ( w trie findPrefix: 'ab' )) equals: { 'a' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: 'abc' )) equals: ( w trie findPrefix: '##c' ) .
	self assert: (w failurePop at: ( w trie findPrefix: 'abc' )) equals: { 'a' . '##b' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: 'abcd' )) equals: ( w trie findPrefix: '##cd' ) .
	self assert: (w failurePop at: ( w trie findPrefix: 'abcd' )) equals: { 'a' . '##b' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: 'abcdx' )) equals: ( w trie findPrefix: '##' ) .
	self assert: (w failurePop at: ( w trie findPrefix: 'abcdx' )) equals: { 'abcdx' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: '##b' )) equals: ( w trie findPrefix: '##' ) .
	self assert: (w failurePop at: ( w trie findPrefix: '##b' )) equals: { '##b' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: '##c' )) equals: ( w trie findPrefix: '##' ) .
	self assert: (w failurePop at: ( w trie findPrefix: '##c' )) equals: { '##c' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: '##cd' )) equals: ( w trie findPrefix: '##d' ) .
	self assert: (w failurePop at: ( w trie findPrefix: '##cd' )) equals: { '##c' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: '##cdy' )) equals: ( w trie findPrefix: '##' ) .
	self assert: (w failurePop at: ( w trie findPrefix: '##cdy' )) equals: { '##cdy' }asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: '##d' )) equals: nil .
	self assert: (w failurePop at: ( w trie findPrefix: '##d' )) equals: #()asOrderedCollection .
	self assert: (w failureLink at: ( w trie findPrefix: '##dz' )) equals: ( w trie findPrefix: '##' ) .
	self assert: (w failurePop at: ( w trie findPrefix: '##dz' )) equals: { '##dz' }asOrderedCollection .
]

{ #category : 'tests' }
WordPieceEncoderTest >> testComputeTrieFromVocabulary [ 

	| w c d e |
	w := WordPieceEncoder new .
	w vocabulary addAll: { 'dog' . 'cat' . '##' . 'cow' . '.' . '=' } asSet .
	w buildTrieAndInitializeFailureData.
	c := w trie rootNode children keys asSet .
	
	self assert: c equals: { $d . $c . $# . $. . $= . $$ . $~ . $` . $! . $@ . $% . $^ . $^ . $& . $* . $( . $) . $_ . $- . $= . $+ . ${ . $} . $[ . $] . $; . $: . $' . $" . $, . $< . $. . $> . $/ . $? . $\ . $| } asSet .
	
	c := w trie rootNode children at: $c .
	d := c children at: $o .
	e := d children at: $w .
	
	self assert: c children keys asSet equals: { $a . $o } asSet .
	self assert: c parent isRoot equals: true .
	self assert: d children keys asSet equals: { $w } asSet .
	self assert: d parent isNode equals: true .
	self assert: d parent character equals: $c .
	self assert: e children size equals: 0 .
	self assert: e isLeaf equals: true .
	self assert: e nodeValue equals: 'cow' .
	
	c := w trie rootNode children at: $d .
	
	self assert: c children keys asSet equals: { $o } asSet .
	self assert: c parent isRoot equals: true .
	
	c := w trie rootNode children at: $# .
	
	self assert: c children keys asSet equals: { $# } asSet .
	self assert: c parent isRoot equals: true .


	
	
	
]

{ #category : 'tests' }
WordPieceEncoderTest >> testE2EWordPiece [

	|w string|
	
	w := WordPieceEncoder new .
	w vocabulary addAll: {'##a' . '##b'. '##c'. '##d'. '##e'. '##f'. '##g'. '##h'. '##i'. '##k'.
 '##l'. '##m'. '##n'. '##o'. '##p'. '##r'. '##s'. '##t'. '##u'. '##v'. '##w'. '##y'. '##z'. ','. '.'. 'C'. 'F'. 'H'.
 'T'. 'a'. 'b'. 'c'. 'g'. 'h'. 'i'. 's'. 't'. 'u'. 'w'. 'y'. 'ab'. '##fu'. 'Fa'. 'Fac'. '##ct'. '##ful'. '##full'. '##fully'.
 'Th'. 'ch'. '##hm'. 'cha'. 'chap'. 'chapt'. '##thm'. 'Hu'. 'Hug'. 'Hugg'. 'sh'. 'th'. 'is'. '##thms'. '##za'. '##zat'.
 '##ut'} . 
	w buildTrieAndInitializeFailureData .
	w computeFailureLinkAndFailurePop.
	string := 'This is the Hugging Face course!' .
	
	self assert: ( w encodeText: 'Hugging' ) equals: { 'Hugg'. '##i'. '##n'. '##g' } asOrderedCollection .
	self assert: ( w encodeText: 'course.' ) equals: { 'c'. '##o'. '##u'. '##r'. '##s'. '##e' . '.' } asOrderedCollection .
	self assert: ( w encodeText: 'axe' ) equals: { '<UNK>' } asOrderedCollection .
	self assert: ( w encodeText: 'alex' ) equals: { '<UNK>' } asOrderedCollection .
	self assert: ( w encodeText: 'Hello.' ) equals: { 'H'. '##e'. '##l'. '##l'. '##o'. '.' } asOrderedCollection .
	self assert: ( w encodeText: 'x' ) equals: { '<UNK>' } asOrderedCollection .
	self assert: ( w encodeText: '!' ) equals: { '<UNK>' } asOrderedCollection .
	self assert: ( w encodeText: 'course!' ) equals: { 'c'. '##o'. '##u'. '##r'. '##s'. '##e' . '<UNK>' } asOrderedCollection .
	self assert: ( w encodeText: string ) equals: { 'Th'. '##i'. '##s'. 'is'. 'th'. '##e'. 'Hugg' . '##i'. '##n'. '##g'. 'Fac'. '##e'. 'c'. '##o'. '##u'. '##r'. '##s'.
 '##e'. '<UNK>' } asOrderedCollection .
	self assert: ( w encodeText: 'course!course!' ) equals: { 'c'. '##o'. '##u'. '##r'. '##s'. '##e' . '<UNK>' . 'c'. '##o'. '##u'. '##r'. '##s'. '##e' . '<UNK>' } asOrderedCollection .
	self assert: ( w encodeText: 'course.course.' ) equals: { 'c'. '##o'. '##u'. '##r'. '##s'. '##e' . '.' . 'c'. '##o'. '##u'. '##r'. '##s'. '##e' . '.' } asOrderedCollection .
	self assert: ( w encodeText: 'course.!' ) equals: { 'c'. '##o'. '##u'. '##r'. '##s'. '##e' . '.' . '<UNK>' } asOrderedCollection .
]

{ #category : 'tests' }
WordPieceEncoderTest >> testIsWordBoundaryAtIn [

	|w vocabulary string|
	
	w := WordPieceEncoder new .
	w vocabulary addAll: {'##a' . '##b'. '##c'. '##d'. '##e'. '##f'. '##g'. '##h'. '##i'. '##k'.
 '##l'. '##m'. '##n'. '##o'. '##p'. '##r'. '##s'. '##t'. '##u'. '##v'. '##w'. '##y'. '##z'. ','. '.'. 'C'. 'F'. 'H'.
 'T'. 'a'. 'b'. 'c'. 'g'. 'h'. 'i'. 's'. 't'. 'u'. 'w'. 'y'. 'ab'. '##fu'. 'Fa'. 'Fac'. '##ct'. '##ful'. '##full'. '##fully'.
 'Th'. 'ch'. '##hm'. 'cha'. 'chap'. 'chapt'. '##thm'. 'Hu'. 'Hug'. 'Hugg'. 'sh'. 'th'. 'is'. '##thms'. '##za'. '##zat'.
 '##ut'} .
	w buildTrieAndInitializeFailureData .
	w computeFailureLinkAndFailurePop.
	string := 'Resoudre cette equation: x**2+x:=0;1'.
	
	self assert: ( w isWordBoundaryAt: 36 in: string ) equals: true .
	self assert: ( w isWordBoundaryAt: 35 in: string ) equals: true .
	self assert: ( w isWordBoundaryAt: 4 in: string ) equals: false .
	self assert: ( w isWordBoundaryAt: 15 in: string ) equals: true .
	self assert: ( w isWordBoundaryAt: 24 in: string ) equals: true .
	self assert: ( w isWordBoundaryAt: 29 in: string ) equals: true .
	
]

{ #category : 'tests' }
WordPieceEncoderTest >> testLinMaxMatch [ 

	|w string |
	
	w := WordPieceEncoder new .
	w vocabulary addAll: { 'a' . 'abcdx' . '##b' . '##c' . '##cdy' . '##dz' } .
	w buildTrieAndInitializeFailureData .
	w computeFailureLinkAndFailurePop.
	string := 'abcdz' .
	
	self assert: ( w encodeWord: string ) equals: { 'a' . '##b' . '##c' . '##dz' } asOrderedCollection .
	
	string := 'abcdx' .
	
	self assert: ( w encodeWord: string ) equals: { 'abcdx' } asOrderedCollection .
	
	string := 'abcd' .
	
	self assert: ( w encodeWord: string ) equals: { '<UNK>' } asOrderedCollection .
	
	string := 'a' .
	
	self assert: ( w encodeWord: string ) equals: { 'a' } asOrderedCollection .
	
	string := 'b' .
	
	self assert: ( w encodeWord: string ) equals: { '<UNK>' } asOrderedCollection .
	
	
	
	
]

{ #category : 'tests' }
WordPieceEncoderTest >> testLoadVocabulary [

	|w|
	w:=WordPieceEncoder new.
	w loadVocabulary: 'vocabulary'.
	
	self assert: w vocabulary equals: {'##d' . 'w' . 'lo' . '##w' . '##est' . '##ew' . '##e' . '##er' . 'wi' . 'l' . '##r' . '##st' . 'new' . '##s' . 'wid' . 'newest' . 'lower' . 'widest' . 'n' . '##t' . 'low' . '##o' . '##i'} asSet 
	
]

{ #category : 'tests' }
WordPieceEncoderTest >> testMatchLoopFromIn [

	|w string r|
	
	w := WordPieceEncoder new .
	w vocabulary addAll: { 'a' . 'abcdx' . '##b' . '##c' . '##cdy' . '##dz' } .
	w buildTrieAndInitializeFailureData .
	w computeFailureLinkAndFailurePop.
	r := w trie rootNode findChildWithString: $# .
	r := r findChildWithString: $# .
	string := 'abcdz ' .
	
	self assert: ( w matchLoopFrom: 1 in: string ) equals: { { 'a' . '##b' . '##c' . '##dz' } asOrderedCollection . r . 6 }
]

{ #category : 'tests' }
WordPieceEncoderTest >> testTrie [ 

	| w c d e |
	w := WordPieceEncoder new .
	w vocabulary addAll: { 'dog' . 'cat' . '##' . 'cow' } .
	w buildTrieAndInitializeFailureData.
	c := w trie rootNode children keys asSet .
	
	self assert: c equals: { $d . $c . $# . $. . $= . $$ . $~ . $` . $! . $@ . $% . $^ . $^ . $& . $* . $( . $) . $_ . $- . $= . $+ . ${ . $} . $[ . $] . $; . $: . $' . $" . $, . $< . $. . $> . $/ . $? . $\ . $|} asSet .
	
	c := w trie rootNode children at: $c .
	d := c children at: $o .
	e := d children at: $w .
	
	self assert: c children keys asSet equals: { $a . $o } asSet .
	self assert: c parent isRoot equals: true .
	self assert: d children keys asSet equals: { $w } asSet .
	self assert: d parent isNode equals: true .
	self assert: d parent character equals: $c .
	self assert: e children size equals: 0 .
	self assert: e isLeaf equals: true .
	self assert: e nodeValue equals: 'cow' .
	
	c := w trie rootNode children at: $d .
	
	self assert: c children keys asSet equals: { $o } asSet .
	self assert: c parent isRoot equals: true .
	
	c := w trie rootNode children at: $# .
	
	self assert: c children keys asSet equals: { $# } asSet .
	self assert: c parent isRoot equals: true .
	
	
	
]
