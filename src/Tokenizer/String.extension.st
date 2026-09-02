Extension { #name : 'String' }

{ #category : '*Tokenizer' }
String >> isPunctuation [ 

	^ { ';' . '.' . ':' . '!' . '?' . '<' . '>' . '@' . '[' . ']' . '_' . '{' . '}' . '|' . '/' . '\' . '~' . '"' . '$' . '%' . '&' . '^' . '(' . ')' . '*' . '+' . '-' . ',' . '''' } asSet includes: self
]
