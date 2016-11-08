//
//  ViewModel.swift
//  SpeechTesting
//
//  Created by Nathan Kellert on 11/4/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit
import Speech

protocol ViewModelDelegate {
	func buttonStateChanged(enabled: Bool, recording: Bool)
	func wordsSaid(words: String)
	func reset()
}


class ViewModel: NSObject {
	
	private var recognizer: SFSpeechRecognizer!
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask: SFSpeechRecognitionTask?
	private let audioEngine = AVAudioEngine()
	
	public var delegate: ViewModelDelegate?
	
	override init(){
		super.init()
		recognizer = SFSpeechRecognizer()
		getAuthorization()
	}
	
	private func getAuthorization(){
		SFSpeechRecognizer.requestAuthorization { authStatus in
			/* The callback may not be called on the main thread. Add an
			operation to the main queue to update the record button's state.
			*/
			OperationQueue.main.addOperation {
				switch authStatus {
				case .authorized:
					self.delegate?.buttonStateChanged(enabled: true, recording: false)
				case .denied:
					self.delegate?.buttonStateChanged(enabled: false, recording: false)
				case .restricted:
					self.delegate?.buttonStateChanged(enabled: false, recording: false)
				case .notDetermined:
					self.delegate?.buttonStateChanged(enabled: false, recording: false)
				}
			}
		}
	}
	
	private func startRecording() {
		
		// Cancel the previous task if it's running.
		if let recognitionTask = recognitionTask {
			recognitionTask.cancel()
			self.recognitionTask = nil
		}
		
		let audioSession = AVAudioSession.sharedInstance()
		do{
			try audioSession.setCategory(AVAudioSessionCategoryRecord)
			try audioSession.setMode(AVAudioSessionModeMeasurement)
			try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
		}catch{
			print("shit failed")
		}
		
		recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
		
		guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
		guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
		
		// Configure request so that results are returned before audio recording is finished
		recognitionRequest.shouldReportPartialResults = true
		
		// A recognition task represents a speech recognition session.
		// We keep a reference to the task so that it can be cancelled.
		recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
			var isFinal = false
			
			if let result = result {
				self.delegate?.wordsSaid(words: result.bestTranscription.formattedString)
				isFinal = result.isFinal
			}
			
			if error != nil || isFinal {
				self.audioEngine.stop()
				inputNode.removeTap(onBus: 0)
				
				self.recognitionRequest = nil
				self.recognitionTask = nil
				
				self.delegate?.buttonStateChanged(enabled: true, recording: false)
				if error != nil{
					print(error!)
				}
			}
		}
		
		let recordingFormat = inputNode.outputFormat(forBus: 0)
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
			self.recognitionRequest?.append(buffer)
		}
		
		audioEngine.prepare()
		
		do{
			try audioEngine.start()
			self.delegate?.buttonStateChanged(enabled: true, recording: true)
		}catch{
			self.delegate?.buttonStateChanged(enabled: true, recording: false)
		}
		
	}
	
	public func buttonPressed(){
		if audioEngine.isRunning{
			audioEngine.stop()
			recognitionRequest?.endAudio()
			self.delegate?.buttonStateChanged(enabled: true, recording: false)
		}else{
			delegate?.reset()
			self.delegate?.buttonStateChanged(enabled: false, recording: false)
			startRecording()
		}
	}
}

extension ViewModel: SFSpeechRecognizerDelegate{
	
	func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
		if !available{
			self.delegate?.buttonStateChanged(enabled: false, recording: false)
		}
	}
}


