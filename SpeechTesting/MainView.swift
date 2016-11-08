//
//  MainView.swift
//  SpeechTesting
//
//  Created by Nathan Kellert on 11/4/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class MainView: UIView {
	
	@IBOutlet weak var speechButton: UIButton!
	@IBOutlet weak var resultLabel: UILabel!
	
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
			buttonValues = (false, false)
			resultLabel.numberOfLines = 0
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
}
