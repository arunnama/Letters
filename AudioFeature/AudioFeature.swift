//
//  AudioFeature.swift
//  Letters
//
//  Created by Arun Kumar Nama on 3/9/23.
//

import AVFoundation

class TextToSpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Set the language
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
