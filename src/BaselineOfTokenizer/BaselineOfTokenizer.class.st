Class {
	#name : 'BaselineOfTokenizer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTokenizer',
	#package : 'BaselineOfTokenizer'
}

{ #category : 'baselines' }
BaselineOfTokenizer >> baseline: spec [
    <baseline>
    spec for: #common do: [
			spec
				package: #'Tokenizer'.
			spec
				group: 'Core' with: #( 'Tokenizer' );
				group: 'default'
				with: #( 'Tokenizer' ) ]
]
