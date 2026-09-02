Extension { #name : 'CTTrie' }

{ #category : '*Tokenizer' }
CTTrie >> compressNode: currentNode ancestors: ancestors [

	| aNode |
	aNode := currentNode.
	ancestors reverse
		do: [ :aParent | 
			"If the node has a nil value, maybe I need to remove it and its ancestors. 
				If it is different than nil, I have nothing to do"
			aNode nodeValue isNil
				ifFalse: [ ^ self ].
			"If the node has children, that is good. We do not remove it"
			aNode children ifNotEmpty: [ ^ self ].
			aParent removeNode: aNode.
			aNode := aParent ]
]

{ #category : '*Tokenizer' }
CTTrie >> labelOfPathFromRootToANode: aCTTrieNode [ 
"Builds and returns the string label corresponding to the path from the trie root to the given node by concatenating
the characters along the path."

	|path|
	
	path := self pathFromRootToANode: aCTTrieNode .
	
	^ (String streamContents: [:stream |
    path do: [:each | stream nextPutAll: each character asString ]
])
]

{ #category : '*Tokenizer' }
CTTrie >> pathFromRootToANode: aCTTrieNode [ 

"This method allows finding the path from the root of the trie to the node given as a parameter."

	|currentNode path|
	
	currentNode := aCTTrieNode .
	path := OrderedCollection new .
	
	currentNode isRoot ifTrue: [ ^ nil ].
	
	[ currentNode isRoot ] whileFalse: [ 
	
		path add: currentNode .
		currentNode := currentNode parent .
		
		 ].
	
	^ path reverse 
]
