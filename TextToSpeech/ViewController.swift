//
//  ViewController.swift
//  TextToSpeech
//
//  Created by Vaibhav on 1/21/19.
//  Copyright © 2019 FAHM. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var textView_Text: UITextView!
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        speechSynthesizer.delegate = self as! AVSpeechSynthesizerDelegate
    }


    @IBAction func btnSpeechTapped(_ sender: Any) {
        let speechUtterance = AVSpeechUtterance(string: textView_Text.text)
        speechUtterance.rate = 0.40 //AVSpeechUtteranceMaximumSpeechRate //0.30
        speechUtterance.pitchMultiplier = 1.2
        
        speechSynthesizer.speak(speechUtterance)
    
    }
}

