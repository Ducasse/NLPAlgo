Class {
	#name : 'Preprocessing1',
	#superclass : 'Preprocessing',
	#category : 'Tokenizer',
	#package : 'Tokenizer'
}

{ #category : 'pretokenisation' }
Preprocessing1 >> preprocessText: text [
    | result start i size char |
    
    result := OrderedCollection new.
    size := text size.
    start := 1.
    i := 1.
    
    [ i <= size ] whileTrue: [
        char := text at: i.
        
        (char isSeparator or: [ char isPunctuation ] )
            ifTrue: [
                start < i ifTrue: [
                    result add: (text copyFrom: start to: i - 1)
                ].
                
                char isPunctuation ifTrue: [
                    result add: char asString 
                ].
                
                i := i + 1.
                start := i
            ]
            ifFalse: [
                i := i + 1
            ]
    ].
    
    start <= size ifTrue: [
        result add: (text copyFrom: start to: size)
    ].
    
    ^ result asArray
]
