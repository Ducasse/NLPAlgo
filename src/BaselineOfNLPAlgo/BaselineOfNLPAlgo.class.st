Class {
	#name : 'BaselineOfNLPAlgo',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfNLPAlgo',
	#package : 'BaselineOfNLPAlgo'
}

{ #category : 'baselines' }
BaselineOfNLPAlgo >> baseline: spec [
    <baseline>
    spec for: #common do: [
			spec
				package: #'BPE4'.
			spec
				group: 'Core' with: #( 'BPE4' );
				group: 'default'
				with: #( 'BPE4' ) ]
]
