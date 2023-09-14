import Foundation
import AVFoundation
import SwiftUI


//Variables

    //Style

let CueColors: [UIColor] = [.red, .blue, .yellow, .green]

    //Tech
let UI = ViewController()

let audioSpace = AudioSpace()
    

let engine = AVAudioEngine()
let audioPlayer1 = AVAudioPlayerNode()
let audioPlayer2 = AVAudioPlayerNode()

let audioSource1 = AudioSource(player: audioPlayer1, deck: 1)
let audioSource2 = AudioSource(player: audioPlayer2, deck: 2)

//let cueAudioPlayer = AVAudioPlayerNode()
//var cueOutputNode : AVAudioOutputNode?

var mixer : AVAudioMixerNode?
var outputNode : AVAudioOutputNode?
var eq1 : AVAudioUnitEQ?
let speedControl1 = AVAudioUnitVarispeed()
let speedControl2 = AVAudioUnitVarispeed()
var eq2 : AVAudioUnitEQ?
var timeChange1 = AVAudioUnitTimePitch()
var timeChange2 = AVAudioUnitTimePitch()
var startFramePosition: AVAudioFramePosition?
var startTime: AVAudioTime?
var files: [AVAudioFile?] =  [nil, nil]
var file2: AVAudioFile?

var song1: Song?
var song2: Song?

var progressTimers = [Timer(), Timer()]

let audioSession = AVAudioSession.sharedInstance()

//Functions

func configureAudio() throws {
    
    
    engine.attach(speedControl1)
    engine.attach(speedControl2)
    engine.attach(timeChange1)
    engine.attach(timeChange2)
    mixer = engine.mainMixerNode
    outputNode = engine.outputNode
    eq1 = AVAudioUnitEQ(numberOfBands: 3)
    guard let eq1 = eq1 else {
        print("NO EQ AVAILABLE")
        return
    }
    
    eq1.bands[0].filterType =  AVAudioUnitEQFilterType.parametric;
    eq1.bands[0].frequency = 100;
    
            
    eq1.bands[1].filterType =  AVAudioUnitEQFilterType.parametric;
    eq1.bands[1].frequency = 1000;
            
    eq1.bands[2].filterType =  AVAudioUnitEQFilterType.parametric;
    eq1.bands[2].frequency = 10000;
    engine.attach(audioPlayer1)
    engine.attach(eq1)
    engine.connect(audioPlayer1, to: timeChange1, format: nil)
    engine.connect(timeChange1, to: speedControl1, format: nil)
    engine.connect(speedControl1, to: eq1, format: nil)
    engine.connect(eq1, to: mixer!, format: nil)
    
    
    eq2 = AVAudioUnitEQ(numberOfBands: 3)
    guard let eq2 = eq2 else {
        print("NO EQ AVAILABLE")
        return
    }
    
    eq2.bands[0].filterType =  AVAudioUnitEQFilterType.parametric;
    eq2.bands[0].frequency = 100;
            
    eq2.bands[1].filterType =  AVAudioUnitEQFilterType.parametric;
    eq2.bands[1].frequency = 1000;
            
    eq2.bands[2].filterType =  AVAudioUnitEQFilterType.parametric;
    eq2.bands[2].frequency = 10000;
    engine.attach(audioPlayer2)
    engine.attach(eq2)
    engine.connect(audioPlayer2, to: timeChange2, format: nil)
    engine.connect(timeChange2, to: speedControl2, format: nil)
    
    engine.connect(speedControl2, to: eq2, format: nil)
    engine.connect(eq2, to: mixer!, format: nil)
    
    engine.connect(mixer!, to: outputNode!, format: nil)
    
    //engine.connect(cueAudioPlayer, to: cueOutputNode!, format: nil)
    
    engine.prepare()
    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
    try AVAudioSession.sharedInstance().setActive(true)
    audioSpace.addSource(audioSource: audioSource1)
    audioSpace.addSource(audioSource: audioSource2)
    UI.audioSpaceView.selectedNode = UI.audioSpaceView.lastAddedNode
    try engine.start()
}

func loadAudio(song: Song, deck: Int) throws {
    let urlString = Bundle.main.url(forResource: song.trackName, withExtension: "mp3")
    guard let urlString = urlString else {
        return
    }
    let file = try AVAudioFile(forReading: urlString)
    var timeChange = timeChange1
    if deck == 2 {
        timeChange = timeChange2
    }
    timeChange.rate = 1
    timeChange.pitch = 0
    

    if deck == 1 {
        song1 = song
    } else if deck == 2 {
        song2 = song
    }
    var audioPlayer = audioPlayer1
    if (deck == 2) {
        audioPlayer = audioPlayer2

    }
    if (deck == 1 && files[deck - 1] != nil || deck == 2 && files[deck - 1] != nil) {
        audioPlayer.stop()
        audioPlayer.removeTap(onBus: 0)
    }
    audioPlayer.scheduleFile(file, at: nil)
    audioPlayer.play()
    files[deck - 1] = file
}

func pitchSync(mode: String, deck: Int) {
    var current: Int
    var target: Int
    guard let song1 = song1 else {
        return
    }
    guard let song2 = song2 else {
        return
    }
    
    var timeChange = timeChange1
    if deck == 2 {
        timeChange = timeChange2
    }
    if deck == 1 {
        current = song1.CurrPitchInd
        target = song2.CurrPitchInd
    } else {
        current = song2.CurrPitchInd
        target = song1.CurrPitchInd
    }
    var to_add = Float(0.0)
    switch mode {
//    case "TERC":
//        var terc = min(find_pitch(mx: mx + 3, mn: mn),
//                         (find_pitch(mx: mx, mn: mn - 3)))
    default:
        to_add = Float(find_pitch(current: current, target: target))
    }
    timeChange.pitch += to_add * 100.0
}

private func find_pitch(current: Int, target: Int) -> Int {
    var plus: Int
    var minus: Int
    if current < target {
        plus = abs(target - current)
        minus = abs(current + NOTECNT - 1 - target)
    } else {
        plus = abs(NOTECNT - current + target)
        minus = abs(current - target)
    }
    if plus >= minus {
        return plus
    } else {
        return -1 * minus
    }
}

func bpmSync(deck: Int) {
    var current: Float
    var target: Float
    guard let song1 = song1 else {
        return
    }
    guard let song2 = song2 else {
        return
    }
    
    var timeChange = timeChange1
    if deck == 2 {
        timeChange = timeChange2
    }
    if deck == 1 {
        current = song1.BPM
        target = song2.BPM
    } else {
        current = song2.BPM
        target = song1.BPM
    }
    timeChange.rate *= target / current
}

func playFromCue(cueInd: Int, deck: Int, button: UIButton){
    if deck == 1 {
        if song1 == nil {
            return
        }
        if song1!.cues[cueInd - 1] == nil {
            setCue(curInd: cueInd, deck: deck, button: button)
            return
        }

        let totalFrames = files[deck - 1]?.length

        // Calculate the remaining length from the desired start position until the end
        let remainingLength = AVAudioFrameCount(totalFrames! - (song1!.cues[cueInd - 1]!))
        
        if audioPlayer1.isPlaying {
            audioPlayer1.stop()
            audioPlayer1.scheduleSegment(files[deck - 1]!, startingFrame: song1!.cues[cueInd - 1] ?? 0, frameCount: remainingLength, at: nil)
            audioPlayer1.play()
        } else {
            audioPlayer1.scheduleSegment(files[deck - 1]!, startingFrame: song1!.cues[cueInd - 1] ?? 0, frameCount: remainingLength, at: nil)
            audioPlayer1.play()
        }
    } else {
        if song2 == nil {
            return
        }
        if song2!.cues[cueInd - 1] == nil {
            setCue(curInd: cueInd, deck: deck, button: button)
            return
        }
        let totalFrames = files[deck - 1]?.length

        // Calculate the remaining length from the desired start position until the end
        let remainingLength = AVAudioFrameCount(totalFrames! - song2!.cues[cueInd - 1]!)
        
        if audioPlayer2.isPlaying {
            audioPlayer2.stop()
            audioPlayer2.scheduleSegment(files[deck - 1]!, startingFrame: song2!.cues[cueInd - 1] ?? 0, frameCount: remainingLength, at: nil)
            audioPlayer2.play()
        } else {
            audioPlayer2.scheduleSegment(files[deck - 1]!, startingFrame: song2!.cues[cueInd - 1] ?? 0, frameCount: remainingLength, at: nil)
            audioPlayer2.play()
        }
    }
}

func setCue(curInd: Int, deck: Int, button: UIButton) {
    button.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
    button.backgroundColor = CueColors[curInd - 1]
    if deck == 1 {
        let currentPosition = audioPlayer1.playerTime(forNodeTime: audioPlayer1.lastRenderTime!)!.sampleTime
        song1?.cues[curInd - 1] = currentPosition
    } else {
        let currentPosition = audioPlayer2.playerTime(forNodeTime: audioPlayer2.lastRenderTime!)!.sampleTime
        song2?.cues[curInd - 1] = currentPosition
    }
}

