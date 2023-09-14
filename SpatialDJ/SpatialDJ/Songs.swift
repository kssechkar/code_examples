//
//  Songs.swift
//  SpatialDJ
//
//  Created by Kosta Sechkar on 27.05.2023.
//

import Foundation
import AVFoundation

var songs: [Song] = []

func configureSongs() {
        songs.append(Song(name: "Paris City Jazz",
                          Artist: "Bellaire",
                          BPM: 125.0,
                          Pitch: "Fm",
                          imageName: "cover1",
                          trackName: "Paris"))
        songs.append(Song(name: "Player",
                          Artist: "Mooqee",
                          BPM: 122.0,
                          Pitch: "Am",
                          imageName: "cover3",
                          trackName: "mooqee"))
}
struct Song {
    let name: String
    let Artist: String
    let BPM: Float
    let Pitch: String
    let imageName: String
    let trackName: String
    var cues: [AVAudioFramePosition?] = Array(repeating: nil, count: 4)
    
    
    
    var CurrPitchInd: Int
    var Maj: Bool
    
    
    init(name: String, Artist: String, BPM: Float, Pitch: String, imageName: String, trackName: String) {
        print(Pitch)
        let maj = (Pitch.last != "m")
        var ind: Int?
        if maj {
            ind = majorPitchDict[Pitch]
        } else {
            ind = minorPitchDict[Pitch]
        }
        self.name = name
        self.Artist =  Artist
        self.BPM = BPM
        self.Pitch = Pitch
        self.imageName = imageName
        self.trackName = trackName
        self.Maj = maj
        self.CurrPitchInd = ind!
        
    }
    
}
