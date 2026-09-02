Extension { #name : 'CTTrieNode' }

{ #category : '*Tokenizer' }
CTTrieNode >> addChildWithLetter: aCharacter [
	| newTrie |
	
	newTrie := self class newWithCharacter: aCharacter.
	newTrie parent: self .
	self children 
		at: aCharacter 
		put: newTrie.
	^newTrie
]

{ #category : '*Tokenizer' }
CTTrieNode >> parent: aCTTrieNode [

	parent := aCTTrieNode 
]
