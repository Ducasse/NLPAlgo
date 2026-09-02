Extension { #name : 'Character' }

{ #category : '*Tokenizer' }
Character >> isPunctuation [ 

	^ { $; . $. . $: . $! . $? . $< . $> . $@ . $[ . $] . $_ . ${ . $} . $| . $/ . $\ . $~ . $" . $$ . $% . $& . $^ . $( . $) . $* . $+ . $- . $, . $' } asSet includes: self
]
