//
//  MainView.swift
//  SpeechTesting
//
//  Created by Nathan Kellert on 11/4/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit
import SwiftSiriWaveformView
class MainView: UIView {
	
	@IBOutlet weak var speechButton: UIButton!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var waveForm: SwiftSiriWaveformView!
	
	var didSetup = false
	var model: ViewModel!
	
	var buttonValues:(enabled: Bool, recording: Bool)! {
		didSet{
			speechButton.isEnabled = buttonValues.enabled
			buttonValues.recording == true ? speechButton.setTitle("Press To Stop", for: [.normal]) : speechButton.setTitle("Press To Listen", for: [.normal])
		}
	}
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		model = ViewModel()
		model.delegate = self
	}
	
	override func layoutSubviews() {
		self.waveForm.density = 1.0
		self.waveForm.amplitude = 1.0
			if !didSetup{
				buttonValues = (false, false)
				resultLabel.numberOfLines = 0
				didSetup = true
			}
	}
	
	@IBAction func buttonPressed(sender: UIButton){
		model.buttonPressed()
	}
}

extension MainView: ViewModelDelegate{
	
	func buttonStateChanged(enabled: Bool, recording: Bool) {
		buttonValues = (enabled, recording)
	}
	
	func wordsSaid(words: String) {
		resultLabel.text = words
	}
	
	func reset() {
		resultLabel.text = ""
	}
	
	func setAmplification(amplification: CGFloat) {
		DispatchQueue.main.async {
			self.waveForm.amplitude += amplification < 0 ? -amplification :  amplification
		}
	}
}
