//
//  VideoPlayerView.swift
//  CCSIMobile
//
//  Created by mac on 25/11/21.
//  Copyright © 2021 Milan Savaliya. All rights reserved.
//

import AVKit

protocol VideoPlayerViewDelegate: AnyObject {
    func videoLoaded()
}

final class VideoPlayerView: UIView {
    // MARK: - Constants
    private let timeObserverKeyPath: String = "timeControlStatus"

    // MARK: - Variables
    private var avPlayer: AVPlayer?
    private var avLayer: AVPlayerLayer?
    private weak var delegate: VideoPlayerViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        avLayer?.frame = self.bounds
    }

    // MARK: - Init & Deinit
    init(frame: CGRect, urlString: String, delegate: VideoPlayerViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate

        if let url = URL(string: urlString) {
            avPlayer = AVPlayer()

            guard let vplayer = avPlayer else { return }
            avLayer = AVPlayerLayer(player: vplayer)
            avLayer?.videoGravity = .resizeAspectFill

            guard let vl = avLayer else { return }
            layer.addSublayer(vl)

            avPlayer?.addObserver(self, forKeyPath: timeObserverKeyPath, options: [.old, .new], context: nil)

            let avItem = AVPlayerItem(url: url)
            vplayer.replaceCurrentItem(with: avItem)
            vplayer.play()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        if avPlayer?.observationInfo != nil {
            NotificationCenter.default.removeObserver(self)
        }
        avPlayer?.pause()
        avLayer?.player = nil
        avLayer?.removeFromSuperlayer()
        avPlayer = nil
        avLayer = nil
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let avPlayer = avPlayer, avPlayer.observationInfo != nil else { return }

        if keyPath == "timeControlStatus",
           let change = change,
           let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
           let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {

            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                if newStatus == .playing {
                    avPlayer.seek(to: .zero)
                    avPlayer.removeObserver(self, forKeyPath: timeObserverKeyPath)
                    delegate?.videoLoaded()
                }
            }

        }
    }

    // MARK: - Functions
    func playVideo() {
        avPlayer?.play()
    }

    func pauseVideo() {
        avPlayer?.pause()
    }
}
