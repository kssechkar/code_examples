import Foundation
import UIKit
import AVFoundation
import QuartzCore
import CoreMotion

let PRIMENUMS = [1: 1, 3: 2, 5: 3, 7: 4]

let song1_view = song1
let song2_view = song2

var cf_vol1: Float = 1
var cf_vol2: Float = 1


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var Controller: UIView!
    @IBOutlet var Deck1: UIView!
    @IBOutlet var Deck2: UIView!
    @IBOutlet var CrossFaderView: UIView!
    @IBOutlet var audioFormView: UIView!
    
    var audioSpaceView = AudioSpaceView(space: audioSpace)
    
    let motion = CMHeadphoneMotionManager()
    
    @IBOutlet var table: UITableView!
    
    var isSpatial: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSongs()
        configureDeck(deck: 1)
        configureDeck(deck: 2)
        configureCrossFader()
        do {
            try configureAudio()
        } catch {
            print("AUDIO ENGINE CANNOT BE STARTED")
            return
        }
        configureProgress(deck: 1)
        configureProgress(deck: 2)
        table.delegate = self
        table.dataSource = self
        
        self.audioSpaceView = AudioSpaceView(space: audioSpace)
        audioSpaceView.addAudioSource(audioSource: audioSource1)
        audioSpaceView.addAudioSource(audioSource: audioSource2)
        guard self.motion.isDeviceMotionAvailable else { return }

        self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            self?.processData(motion)
        })
    }
    
    func processData(_ data: CMDeviceMotion) {
        let angle = CGFloat(data.attitude.yaw)
        audioSpace.yaw = angle

        let deg = angle * CGFloat(180.0 / Double.pi)
        print(deg)
    }
    
    var progressViews = [UIProgressView(progressViewStyle: .default), UIProgressView(progressViewStyle: .default)]
    
    func configureProgress(deck: Int) {
        var multZer: CGFloat = 0
        if deck == 2 {
            multZer = 1
        }
        progressViews[deck - 1].frame = CGRect(x: 0, y: 0 + multZer * audioFormView.bounds.height / 2, width: audioFormView.frame.width, height: audioFormView.bounds.height / 2)
        progressViews[deck - 1].tintColor = UIColor.blue
        progressViews[deck - 1].trackTintColor = UIColor.lightGray
        progressViews[deck - 1].accessibilityHint = String(deck)
        progressTimers[deck-1] = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress(_:)), userInfo: nil, repeats: true)
        audioFormView.addSubview(progressViews[deck - 1])
    }
    
    @objc func updateProgress(_ sender: UIProgressView) {
        let deck = Int(sender.accessibilityHint ?? "1")
        guard let deck = deck else {
            return
        }
        var audioPlayer: AVAudioPlayerNode?
        if deck == 1 {
            audioPlayer = audioPlayer1
        } else if deck == 2 {
            audioPlayer = audioPlayer2
        }
        guard let audioPlayer = audioPlayer else {
            return
        }
        guard let audioFile = files[deck - 1] else {
            return
        }
        guard let lastRenderTime = audioPlayer.lastRenderTime, let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime) else {
                return
            }
            
        let currentTime = Double(playerTime.sampleTime) / playerTime.sampleRate
        let duration = Double(audioFile.length) / audioFile.processingFormat.sampleRate
        let progress = Float(currentTime / duration)
            
        progressViews[deck - 1].setProgress(progress, animated: true)
        
    }
    
    func loadUI( song: Song, deck: Int) {
        albumImageViews[deck - 1].image = UIImage(named: song.imageName)
        songNameLabels[deck - 1].text = song.name
        artistNameLabels[deck - 1].text = song.Artist
        pitchLabels[deck - 1].text = song.Pitch
        playPauseButtons[deck - 1].setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        for i in 0...3 {
            if song.cues[i] != nil {
                cueButtons[deck - 1].cue[i].setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
                cueButtons[deck - 1].cue[i].backgroundColor = CueColors[i]
            }
        }
    }
    
    let playPauseButtons = [UIButton(), UIButton()]
    let pitchButtons = [PitchButton(), PitchButton()]
    
    let pitchSyncButtons = [UIButton(), UIButton()]
    let bpmSyncButtons = [UIButton(), UIButton()]
    let spatialButtons = [UIButton(), UIButton()]
    
    let cueButtons = [CuePad(), CuePad()]
    
    let bpmSliders = [UISlider(), UISlider()]
    let volumeSliders = [UISlider(), UISlider()]
    private let albumImageViews = [UIImageView(), UIImageView()]
    
    private let songNameLabels = [UILabel(), UILabel()]
    
    
    private let artistNameLabels = [UILabel(), UILabel()]
    
    private let pitchLabels = [UILabel(), UILabel()]
    
    
    let crossFader = UISlider()

    
    
    func configureDeck(deck: Int) {
        for lbl in songNameLabels {
            lbl.textAlignment = .center
            lbl.numberOfLines = 0 // line wrap
        }
        for lbl in artistNameLabels {
            lbl.textAlignment = .center
            lbl.numberOfLines = 0 // line wrap
        }
        for img in albumImageViews {
            img.contentMode = .scaleAspectFill
        }
        
        var Deck: UIView!
        var nameXPos: CGFloat! = -1
        var volXPos: CGFloat! = -1
        var bpmXPos: CGFloat! = -1
        var centrMult = 1.0
        var multEven = -1.0
        if deck == 1 {
            multEven = 0
            Deck = Deck1
            nameXPos = 0
        } else if  deck == 2 {
            Deck = Deck2
            centrMult = -1.0
            nameXPos = Deck.bounds.maxX - Deck.frame.size.width / 7
        }
        let albumImageSize = Deck.frame.size.width / 4.5
        albumImageViews[deck - 1].frame = CGRect(x: Deck.bounds.midX + centrMult * albumImageSize / 2  + multEven * 50.0,
                                                 y: Deck.bounds.minY + 20.0,
                                                 width: albumImageSize,
                                                 height: albumImageSize)
        albumImageViews[deck - 1].image = UIImage(named: "no_song")
        Deck.addSubview(albumImageViews[deck - 1])
        
        
        songNameLabels[deck - 1].frame = CGRect(x: nameXPos,
                                                y: 0,
                                                width: Deck.frame.size.width / 7,
                                                height: 30)
        artistNameLabels[deck - 1].frame = CGRect(x: nameXPos,
                                                  y: 30,
                                                  width: Deck.frame.size.width / 7,
                                                  height: 30)
        songNameLabels[deck - 1].text = "no song"
        Deck.addSubview(songNameLabels[deck - 1])
        artistNameLabels[deck - 1].text = "N/A"
        Deck.addSubview(artistNameLabels[deck - 1])
        
        
        
        
        
        let playSize = Deck.frame.size.width / 12.5
        playPauseButtons[deck - 1].frame = CGRect(x: albumImageViews[deck - 1].frame.minX - 30,
                                                  y: albumImageViews[deck - 1].frame.maxY + 15,
                                                  width: playSize,
                                                  height: playSize)
        playPauseButtons[deck - 1].tag = deck
        playPauseButtons[deck - 1].addTarget(self, action: #selector(didTapPlayPauseButton(_:)), for: .touchUpInside)
        
        playPauseButtons[deck - 1].setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        playPauseButtons[deck - 1].tintColor = .black
        playPauseButtons[deck - 1].isUserInteractionEnabled = true
        Deck.addSubview(playPauseButtons[deck - 1])
        
        
        var spatialPos = albumImageViews[deck - 1].frame.minX - playSize / 1.5
        if deck % 2 == 0 {
            spatialPos = albumImageViews[deck - 1].frame.maxX
        }
        spatialButtons[deck - 1].frame = CGRect(x: spatialPos - centrMult * 30,
                                                  y: albumImageViews[deck - 1].frame.minY,
                                                width: playSize / 1.5,
                                                  height: playSize / 1.5)
        spatialButtons[deck - 1].tag = deck
        spatialButtons[deck - 1].addTarget(self, action: #selector(didTapSpatialButton), for: .touchUpInside)
        
        spatialButtons[deck - 1].setBackgroundImage(UIImage(systemName: "waveform.circle"), for: .normal)
        spatialButtons[deck - 1].tintColor = .black
        spatialButtons[deck - 1].isUserInteractionEnabled = true
        Deck.addSubview(spatialButtons[deck - 1])
        
        
        pitchSyncButtons[deck - 1].frame = CGRect(x: albumImageViews[deck - 1].frame.minX - 30 + playSize + 20.0,
                                                  y: albumImageViews[deck - 1].frame.maxY + 15,
                                                  width: playSize / 1.5,
                                                  height: playSize / 1.5)
        pitchSyncButtons[deck - 1].tag = deck
        pitchSyncButtons[deck - 1].addTarget(self, action: #selector(didTapSyncPitchButton(_:)), for: .touchUpInside)
        
        pitchSyncButtons[deck - 1].setBackgroundImage(UIImage(named: "sync"), for: .normal)
        pitchSyncButtons[deck - 1].tintColor = .black
        pitchSyncButtons[deck - 1].isUserInteractionEnabled = true
        Deck.addSubview(pitchSyncButtons[deck - 1])
        
        bpmSyncButtons[deck - 1].frame = CGRect(x: pitchSyncButtons[deck - 1].frame.maxX + 20,
                                                  y: albumImageViews[deck - 1].frame.maxY + 15,
                                                  width: playSize / 1.5,
                                                  height: playSize / 1.5)
        bpmSyncButtons[deck - 1].tag = deck
        bpmSyncButtons[deck - 1].addTarget(self, action: #selector(didTapSyncBpmButton(_:)), for: .touchUpInside)
        
        bpmSyncButtons[deck - 1].setBackgroundImage(UIImage(systemName: "clock.arrow.2.circlepath"), for: .normal)
        bpmSyncButtons[deck - 1].tintColor = .black
        bpmSyncButtons[deck - 1].isUserInteractionEnabled = true
        Deck.addSubview(bpmSyncButtons[deck - 1])
        
        let sliderHeight = 45.0
        if deck == 1 {
            multEven = 0
            volXPos = albumImageViews[deck - 1].frame.maxX
            bpmXPos = Deck.bounds.minX + 30.0
        } else if deck == 2 {
            volXPos = albumImageViews[deck - 1].frame.minX - albumImageViews[deck - 1].frame.width / 2 - 25.0
            bpmXPos = Deck.bounds.maxX - 120.0 - sliderHeight
        }
        volumeSliders[deck - 1].frame = CGRect(x: volXPos + multEven * sliderHeight,
                                               y: albumImageViews[deck - 1].frame.minY + 50.0,
                                               width: albumImageViews[deck - 1].frame.width,
                                               height: sliderHeight)
        volumeSliders[deck - 1].transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        volumeSliders[deck - 1].value = 0.5
        volumeSliders[deck - 1].tag = deck
        volumeSliders[deck - 1].maximumValue = 0.7
        volumeSliders[deck - 1].addTarget(self, action: #selector(didSlideVolumeSlider(_:)), for: .valueChanged)
        Deck.addSubview(volumeSliders[deck - 1])
        
        
        bpmSliders[deck - 1].frame = CGRect(x: bpmXPos,
                                            y: artistNameLabels[deck - 1].frame.maxY + 70.0,
                                            width: albumImageViews[deck - 1].frame.width,
                                            height: sliderHeight)
        bpmSliders[deck - 1].transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        bpmSliders[deck - 1].value = 0.5
        bpmSliders[deck - 1].tag = deck
        bpmSliders[deck - 1].addTarget(self, action: #selector(didSlideBpmSlider(_:)), for: .valueChanged)
        Deck.addSubview(bpmSliders[deck - 1])
        
        let pitchWidth = CGFloat(30.0)
        let pitchPad = CGFloat(30.0)
        
        pitchButtons[deck - 1].up.frame = CGRect(x: centrMult * pitchPad - multEven * (Deck.frame.width - pitchWidth),
                                                 y: artistNameLabels[deck - 1].frame.maxY + 50.0, width: pitchWidth, height: 30)
        pitchButtons[deck - 1].up.tag = deck
        pitchButtons[deck - 1].up.addTarget(self, action: #selector(didTapPitchButtonUp(_:)), for: .touchUpInside)
        
        pitchButtons[deck - 1].up.setBackgroundImage(UIImage(systemName: "arrow.up"), for: .normal)
        pitchButtons[deck - 1].up.tintColor = .black
        pitchButtons[deck - 1].up.isUserInteractionEnabled = true
        Deck.addSubview(pitchButtons[deck-1].up)
        
        pitchButtons[deck - 1].down.frame = CGRect(x: centrMult * pitchPad - multEven * (Deck.frame.width - pitchWidth),
                                                   y: pitchButtons[deck -  1].up.frame.maxY + 10.0, width: pitchWidth, height: 30)
        pitchButtons[deck - 1].down.tag = deck
        pitchButtons[deck - 1].down.addTarget(self, action: #selector(didTapPitchButtonDown(_:)), for: .touchUpInside)
        
        pitchButtons[deck - 1].down.setBackgroundImage(UIImage(systemName: "arrow.down"), for: .normal)
        pitchButtons[deck - 1].down.tintColor = .black
        pitchButtons[deck - 1].down.isUserInteractionEnabled = true
        Deck.addSubview(pitchButtons[deck-1].down)
        
        pitchLabels[deck - 1].frame = CGRect(x: nameXPos,
                                             y: artistNameLabels[deck-1].frame.maxY + 5,
                                             width: Deck.frame.size.width / 7,
                                                  height: 30)
        pitchLabels[deck - 1].text = "--"
        pitchLabels[deck - 1].textAlignment = .center
        Deck.addSubview(pitchLabels[deck - 1])
        
        let cueSize = playSize + 10
        let cueX = spatialButtons[deck - 1].frame.minX + multEven * 80 - (1 + multEven) * 70
        
        cueButtons[deck - 1].cue[0].frame = CGRect(x: cueX - centrMult * 2 * cueSize, y: 20, width: cueSize, height: cueSize)

        cueButtons[deck - 1].cue[0].tag = deck * 1
        
        cueButtons[deck - 1].cue[0].addTarget(self, action: #selector(didTapCueButton(_:)), for: .touchUpInside)
        cueButtons[deck - 1].cue[0].setBackgroundImage(UIImage(systemName: "arrowtriangle.down.circle"), for: .normal)
        cueButtons[deck - 1].cue[0].tintColor = .black
        cueButtons[deck - 1].cue[0].isUserInteractionEnabled = true
        Deck.addSubview(cueButtons[deck-1].cue[0])
        
        
        cueButtons[deck - 1].cue[1].frame = CGRect(x: cueButtons[deck - 1].cue[0].frame.maxX + 5, y: 20, width: cueSize, height: cueSize)

        cueButtons[deck - 1].cue[1].tag = deck * 3
        
        cueButtons[deck - 1].cue[1].addTarget(self, action: #selector(didTapCueButton(_:)), for: .touchUpInside)
        cueButtons[deck - 1].cue[1].setBackgroundImage(UIImage(systemName: "arrowtriangle.down.circle"), for: .normal)
        cueButtons[deck - 1].cue[1].tintColor = .black
        cueButtons[deck - 1].cue[1].isUserInteractionEnabled = true
        Deck.addSubview(cueButtons[deck-1].cue[1])
        
        
        cueButtons[deck - 1].cue[2].frame = CGRect(x: cueX - centrMult * 2 * cueSize, y: 25 + cueSize, width: cueSize, height: cueSize)

        cueButtons[deck - 1].cue[2].tag = deck * 5
        
        cueButtons[deck - 1].cue[2].addTarget(self, action: #selector(didTapCueButton(_:)), for: .touchUpInside)
        cueButtons[deck - 1].cue[2].setBackgroundImage(UIImage(systemName: "arrowtriangle.down.circle"), for: .normal)
        cueButtons[deck - 1].cue[2].tintColor = .black
        cueButtons[deck - 1].cue[2].isUserInteractionEnabled = true
        Deck.addSubview(cueButtons[deck-1].cue[2])
        
        
        cueButtons[deck - 1].cue[3].frame = CGRect(x: cueButtons[deck - 1].cue[1].frame.minX, y: cueButtons[deck - 1].cue[1].frame.maxY, width: cueSize, height: cueSize)

        cueButtons[deck - 1].cue[3].tag = deck * 7
        
        cueButtons[deck - 1].cue[3].addTarget(self, action: #selector(didTapCueButton(_:)), for: .touchUpInside)
        cueButtons[deck - 1].cue[3].setBackgroundImage(UIImage(systemName: "arrowtriangle.down.circle"), for: .normal)
        cueButtons[deck - 1].cue[3].tintColor = .black
        cueButtons[deck - 1].cue[3].isUserInteractionEnabled = true
        Deck.addSubview(cueButtons[deck-1].cue[3])
        
    }
    
    func configureCrossFader() {
        crossFader.frame = CGRect(x: CrossFaderView.bounds.minX,
                                  y: CrossFaderView.bounds.minY,
                                  width: CrossFaderView.frame.width,
                                  height: CrossFaderView.frame.height)
        crossFader.value = 0.5
        crossFader.tag = 1
        crossFader.addTarget(self, action: #selector(didSlideCrossFader(_:)), for: .valueChanged)
        CrossFaderView.addSubview(crossFader)
    }
    
    @objc func didTapCueButton(_ sender: UIButton) {
        var val = sender.tag
        let deck = abs(val % 2 - 2)
        val /= deck
        let cueInd = PRIMENUMS[val]!
        playFromCue(cueInd: cueInd, deck: deck, button: sender)
    }
    
    @objc func didTapSpatialButton() {
        if isSpatial {
            self.audioSpaceView.removeFromSuperview()
            isSpatial = false
        } else {
            self.audioSpaceView.frame = CGRect(x: Controller.frame.midX - 160.0, y: 15, width: Controller.frame.height - 70, height: Controller.frame.height - 70)
            Controller.addSubview(self.audioSpaceView)
            isSpatial = true
        }
        
    }
    
    @objc func didTapSyncPitchButton(_ sender: UIButton) {
        pitchSync(mode: "Default", deck: sender.tag)
        changePitchLabel(deck: sender.tag)
    }
    
    @objc func didTapSyncBpmButton(_ sender: UIButton) {
        bpmSync(deck: sender.tag)
        changePitchLabel(deck: sender.tag)
    }
    
    @objc func didTapPitchButtonDown(_ sender: UIButton) {
        let deck = sender.tag
        var timeChange: AVAudioUnitTimePitch!
        if deck == 1 {
            timeChange = timeChange1
        } else if deck == 2 {
            timeChange = timeChange2
        }
        timeChange.pitch -= 100
        changePitchLabel(deck: deck)
    }
    
    private func changePitchLabel(deck: Int) {
        var song: Song!
        var timeChange: AVAudioUnitTimePitch!
        if deck == 1 {
            song = song1
            timeChange = timeChange1
        } else if deck == 2 {
            song = song2
            timeChange = timeChange2
        }
        var pitchList = [String]()
        if song.Maj {
            pitchList = majorPitchList
        } else {
            pitchList = minorPitchList
        }
        var changedPos = song.CurrPitchInd + Int(timeChange.pitch) / 100
        if changedPos < 0 {
            changedPos = pitchList.count + changedPos
        }
        song.CurrPitchInd = changedPos
        pitchLabels[deck - 1].text = pitchList[changedPos % pitchList.count]
    }
    
    @objc func didTapPitchButtonUp(_ sender: UIButton) {
        let deck = sender.tag
        var timeChange: AVAudioUnitTimePitch!
        if deck == 1 {
            timeChange = timeChange1
        } else if deck == 2 {
            timeChange = timeChange2
        }
        timeChange.pitch += 100
        changePitchLabel(deck: deck)
    }
    
    @objc func didSlideCrossFader(_ sender: UISlider) {
        let curve = sender.tag
        let thresh: Float = 0.2
        if curve == 1 {
            audioPlayer1.volume = max(0,  1 - thresh - sender.value)
            audioPlayer2.volume = max(0, sender.value - thresh)
            cf_vol1 = audioPlayer1.volume
            cf_vol2 = audioPlayer2.volume
        }
        
        
    }
    
    @objc func didTapPlayPauseButton(_ sender: UIButton) {
        let deck = sender.tag
        if deck == 1 {
            if audioPlayer1.isPlaying {
                audioPlayer1.pause()
                playPauseButtons[deck - 1].setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                audioPlayer1.play()
                playPauseButtons[deck - 1].setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        } else if deck == 2 {
                if audioPlayer2.isPlaying {
                    audioPlayer2.pause()
                    playPauseButtons[deck - 1].setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
                    
                    // ANIMATION
                    
                    //                UIView.animate(withDuration: 0.2, animations: {
                    //                    self.albumImageViews[deck - 1].frame = CGRect(x: self.Deck2.frame.midX - self.Deck2.frame.size.width / 10,
                    //                                                              y: self.Deck2.frame.minY + 20.0,
                    //                                                              width: self.Deck2.frame.size.width / 5,
                    //                                                              height: self.Deck2.frame.size.width / 5)
                    //                })
                } else {
                    audioPlayer2.play()
                    playPauseButtons[deck - 1].setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
                }
            }
        }
        
   @objc func didSlideVolumeSlider(_ slider: UISlider) {
            var cf_vol: Float = 1
            let value = slider.value
            let deck = slider.tag
            var audioPlayer: AVAudioPlayerNode?
            if deck == 1 {
                cf_vol = cf_vol1
                audioPlayer = audioPlayer1
            } else if deck == 2 {
                cf_vol = cf_vol2
                audioPlayer = audioPlayer2
            }
            guard let audioPlayer = audioPlayer else {
                return
            }
            audioPlayer.volume = min(value, cf_vol)
        }
        
        
        @objc func didSlideBpmSlider(_ slider: UISlider) {
            let value = (1.5 - slider.value) * 1.1
            let deck = slider.tag
            var song: Song!
            var timeChange: AVAudioUnitTimePitch!
            if deck == 1 {
                song = song1
                timeChange = timeChange1
            } else if deck == 2 {
                song = song2
                timeChange = timeChange2
            }
            timeChange.rate = value
        }
        
        
        // Table
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return songs.count
        }
        
        
        // Loading songs
        
        @objc func Load1(_ sender: UIButton) {
            do {
                loadUI(song: songs[sender.tag], deck: 1)
                try loadAudio(song: songs[sender.tag], deck: 1)
            } catch {
                print("COULD NOT LOAD TRACK")
                return
            }
        }
    
    @objc func Load2(_ sender: UIButton) {
        do {
            loadUI(song: songs[sender.tag], deck: 2)
            try loadAudio(song: songs[sender.tag], deck: 2)
        } catch {
            print("COULD NOT LOAD TRACK")
            return
        }
    }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
            let song = songs[indexPath.row]
            // configure
            cell.Title.text = song.name
            cell.Artist.text = song.Artist
            cell.accessoryType = .disclosureIndicator
            cell.Cover.image = UIImage(named: song.imageName)
            cell.Title.font = UIFont(name: "Helvetica", size: 18)
            cell.Artist.font = UIFont(name: "Helvetica-Bold", size: 17)
            cell.BPM.text = "BPM: \(song.BPM)"
            cell.Pitch.text = "Pitch: \(song.Pitch)"
            cell.Load1.tag = indexPath.row
            cell.Load2.tag = indexPath.row
            cell.Load1.addTarget(self, action: #selector(Load1(_:)), for: .touchUpInside)
            cell.Load2.addTarget(self, action: #selector(Load2(_:)), for: .touchUpInside)
            
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
}

struct PitchButton {
    var up = UIButton()
    var down = UIButton()
}

struct CuePad {
    var cue: [UIButton] = [UIButton(), UIButton(), UIButton(), UIButton()]
}

