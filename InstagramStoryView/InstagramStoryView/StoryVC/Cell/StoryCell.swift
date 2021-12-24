//
//  StoryCell.swift
//  CCSIMobile
//
//  Created by mac on 25/11/21.
//  Copyright © 2021 Milan Savaliya. All rights reserved.
//
import UIKit

protocol StoryPreviewProtocol: AnyObject {
    func didStoryViewEnd()
}

final class StoryCell: UICollectionViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak private var btnText: UIButton!
    @IBOutlet weak private var viewProgress: UIView!
    @IBOutlet weak private var imgSnap: UIImageView!
    @IBOutlet weak private var videoView: UIView!
    @IBOutlet weak private var indicatorView: UIActivityIndicatorView!

    // MARK: - Properties
    weak var delegate: StoryPreviewProtocol?
    var progressBar: StoryProgressView?
    var story: [SnapsModle]?
    var parentStoryIndex: Int = 0
    private var requestCount = 0
    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    private var videoPlayerView: VideoPlayerView?
    private var longGesture: UILongPressGestureRecognizer!

    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeGestureRecognizer(longGesture)
        dataTask?.cancel()
        progressBar?.resetBar()
    }

    // MARK: - Function
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touch(_:)))
        self.addGestureRecognizer(tapGesture)

        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longGesture.minimumPressDuration = 0.2
        btnText.layer.cornerRadius = btnText.frame.height / 2
    }

    private func setupTitle() {
//        guard let urlStory = story?.get(at: index)?.url else { return }
    }

    func initProgressbar() {
        progressBar = StoryProgressView(arrayStories: story?.count ?? 0)
        progressBar?.delegate = self
        progressBar?.frame = CGRect(x: 0, y: 0, width: frame.width, height: 4)
        viewProgress.subviews.forEach { $0.removeFromSuperview() }
        viewProgress.addSubview(progressBar!)
    }

    private func loadImageFromUrl(urlString: String, completion: ((Bool) -> Void)?) {
        if let url = URL(string: urlString) {
            dataTask = defaultSession.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imgSnap.image = UIImage(data: data)
                        completion?(true)
                    }
                } else {
                    completion?(false)
                }
            }
            dataTask?.resume()

        } else {
            completion?(false)
        }
    }

    private func requestImage(url: String) {
        self.removeGestureRecognizer(longGesture)
        requestCount += 1
        loadImageFromUrl(urlString: url) { (_) in
            DispatchQueue.main.async {
                self.requestCount -= 1
                self.progressBar?.resume()
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
                self.addGestureRecognizer(self.longGesture)
            }
        }
    }

    func loadImage(urlString: String) {
        videoView.isHidden = true
        imgSnap.isHidden = false
        imgSnap.image = nil
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        progressBar?.pause()
        requestCount = requestCount == 0 ? 1 : 0
        if requestCount != 0 {
            dataTask?.cancel()
        }
        requestImage(url: urlString)
    }

    func resetVideoView() {
        videoView.subviews.forEach({ $0.removeFromSuperview() })
        videoPlayerView = nil
    }

    func loadVideo(urlString: String) {
        self.removeGestureRecognizer(longGesture)
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        progressBar?.pause()
        videoView.isHidden = false
        imgSnap.isHidden = true
        resetVideoView()
        videoPlayerView = VideoPlayerView(frame: contentView.bounds, urlString: urlString, delegate: self)
        videoView.addSubViewWithAutolayout(subView: videoPlayerView!)
    }

    // MARK: - IBAction & Action
    @objc private func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            videoPlayerView?.pauseVideo()
            progressBar?.pause()
        } else if sender.state == .ended {
            videoPlayerView?.playVideo()
            progressBar?.resume()
        }
    }

    @objc private func touch(_ sender: UITapGestureRecognizer) {
        let touch = sender.location(in: self)
        let screenWidthOneThird = self.frame.width / 3
        let absoluteTouch = touch.x

        if absoluteTouch < screenWidthOneThird {
            progressBar?.rewind()
        } else {
            progressBar?.skip()
        }
    }
}

// MARK: - SegmentedProgressBarDelegate
extension StoryCell: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        guard let urlStory = story?.get(at: index)?.url else { return }
        if let title = story?.get(at: index)?.title {
            lblTitle.text = title
        }
        if story?.get(at: index)?.type == "image" {
            loadImage(urlString: urlStory)
        } else {
            loadVideo(urlString: urlStory)
        }
    }

    func segmentedProgressBarsFinished() {
        prepareForReuse()
        delegate?.didStoryViewEnd()
    }
}

// MARK: - VideoPlayerViewDelegate & Video Functions
extension StoryCell: VideoPlayerViewDelegate {

    func videoLoaded() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        progressBar?.resume()
        self.addGestureRecognizer(longGesture)
    }
}
