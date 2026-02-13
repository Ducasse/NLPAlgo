Extension { #name : 'CTTrieNode' }

{ #category : '*BPE4' }
CTTrieNode >> addChildWithLetter: aCharacter [
	| newTrie |
	
	newTrie := self class newWithCharacter: aCharacter.
	newTrie parent: self .
	self children 
		at: aCharacter 
		put: newTrie.
	^newTrie
]

{ #category : '*BPE4' }
CTTrieNode >> parent: aCTTrieNode [

	parent := aCTTrieNode 
]
