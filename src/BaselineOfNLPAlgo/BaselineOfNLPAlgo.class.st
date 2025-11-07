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
				package: #'WordPiece'.
			spec
				group: 'Core' with: #( 'BPE4' 'WordPiece' );
				group: 'default'
				with: #( 'BPE4' 'WordPiece') ]
]
