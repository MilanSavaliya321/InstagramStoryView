//
//  MyProgressView.swift
//  CCSIMobile
//
//  Created by mac on 25/11/21.
//  Copyright © 2021 Milan Savaliya. All rights reserved.
//

import UIKit

protocol SegmentedProgressBarDelegate: AnyObject {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarsFinished()
}

final class StoryProgressView: UIView {

    weak var delegate: SegmentedProgressBarDelegate?

    private var arrayBars: [UIProgressView] = []

    private var padding: CGFloat = 10.0

    private var leftRightSpace: CGFloat = 20.0

    private var hasDoneLayout = false

    private var currentAnimationIndex = 0

    private var timer: Timer?

    private var paused = false

    private var timerRunning = false

    init(arrayStories: Int) {
        super.init(frame: .zero)

        for _ in 0...arrayStories - 1 {
            let bar = UIProgressView()
            arrayBars.append(bar)
            addSubview(bar)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout { return }

        let barPadding = padding * CGFloat(arrayBars.count - 1)
        let leftSpace = leftRightSpace * 2
        let frameWidth = frame.width - barPadding - leftSpace
        let width = frameWidth / CGFloat(arrayBars.count)

        for (index, progressBar) in arrayBars.enumerated() {

            let segFrame = CGRect(x: (CGFloat(index) * (width + padding)) + leftRightSpace, y: 0, width: width, height: 20)
            progressBar.frame = segFrame
            progressBar.progress = 0.0
            progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 1)
            progressBar.tintColor = .white
            progressBar.backgroundColor = UIColor.lightGray
            progressBar.layer.cornerRadius = progressBar.frame.height / 2
        }

        hasDoneLayout = true
    }

    func animate(index: Int) {
        timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(updateProgressBar(_:)), userInfo: index, repeats: true)
        currentAnimationIndex = index
        timerRunning = true
    }

    @objc private func updateProgressBar(_ timer: Timer) {
        guard let selectdStoryIndex = timer.userInfo as? Int, let progressBar = arrayBars.get(at: selectdStoryIndex) else { return }
        progressBar.progress += 0.005
        progressBar.setProgress(progressBar.progress, animated: false)

        if progressBar.progress == 1.0 {
            next()
        }
    }

    private func next() {
        let newIndex = self.currentAnimationIndex + 1
        timer?.invalidate()
        if newIndex < arrayBars.count {
            animate(index: newIndex)
            delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        } else {
            delegate?.segmentedProgressBarsFinished()
        }
    }

    func pause() {
        if !paused {
            paused = true
            timer?.invalidate()
        }
    }

    func resume() {
        if paused {
            paused = false
            animate(index: currentAnimationIndex)
        }
    }

    func resetBar() {
        for i in arrayBars {
            i.progress = 0.0
        }
        timer?.invalidate()
        timerRunning = false
        currentAnimationIndex = 0
        paused = false
    }

    func skip() {
        paused = false
        guard let currentBar = arrayBars.get(at: currentAnimationIndex) else { return }
        currentBar.progress = 1.0
        self.next()
    }

    func rewind() {
        paused = false
        guard let currentBar = arrayBars.get(at: currentAnimationIndex) else { return }
        let newIndex = self.currentAnimationIndex - 1
        currentBar.progress = 0.0

        if newIndex < 0 {
            timer?.invalidate()
            delegate?.segmentedProgressBarsFinished()
            return
        }
        guard let prevBar = arrayBars.get(at: newIndex) else { return }
        prevBar.setProgress(0.0, animated: false)
        timer?.invalidate()
        animate(index: newIndex)
        delegate?.segmentedProgressBarChangedIndex(index: newIndex)
    }
}
