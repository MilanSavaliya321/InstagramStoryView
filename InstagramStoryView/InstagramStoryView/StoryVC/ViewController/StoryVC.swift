//
//  StoryVC.swift
//  CCSIMobile
//
//  Created by mac on 25/11/21.
//  Copyright © 2021 Milan Savaliya. All rights reserved.
//
import UIKit

final class StoryVC: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak private var clvStoryView: UICollectionView!

    // MARK: - Properties
    private var needsDelayedScrolling = false
    private var firstLaunch = true
    private var selectedStoryIndex = 0
    private var arrayStories: [StoryModel] = []
    private var currentStoryIndex: Int?
    private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var displayBlurAtHeight: CGFloat = 200

    // MARK: - Init
    init(arrayStories: [StoryModel], selectedStoryIndex: Int) {
        self.selectedStoryIndex = selectedStoryIndex
        self.arrayStories = arrayStories
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        needsDelayedScrolling = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsDelayedScrolling {
            needsDelayedScrolling = !needsDelayedScrolling
            let indexPath = IndexPath(item: selectedStoryIndex, section: 0)
            clvStoryView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let cell = clvStoryView.visibleCells.get(at: 0) as? StoryCell else { return }
        cell.progressBar?.resetBar()
    }

    // MARK: - Function
    private func setupUI() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(self.swipeDown(_:)))
        view.addGestureRecognizer(recognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        setupCollectionView()
    }

    private func setupCollectionView() {
        clvStoryView.delegate = self
        clvStoryView.dataSource = self
        clvStoryView.register(UINib(nibName: "StoryCell", bundle: nil), forCellWithReuseIdentifier: "StoryCell")
        clvStoryView.isPagingEnabled = true
    }

    private func panGestureStateChnage(touchPoint: CGPoint) {
        if touchPoint.y - initialTouchPoint.y > 0 {
            clvStoryView.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y + 0, width: clvStoryView.frame.size.width, height: clvStoryView.frame.size.height)
            view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1 - (touchPoint.y - initialTouchPoint.y) / displayBlurAtHeight)
        }
    }

    private func panGestureStateCancelledAndEnded(touchPoint: CGPoint) {
        if touchPoint.y - initialTouchPoint.y > displayBlurAtHeight {
            dismiss(animated: true, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = .black
                self.clvStoryView.frame = CGRect(x: 0, y: 0, width: self.clvStoryView.frame.size.width, height: self.clvStoryView.frame.size.height)
            })
        }
    }

    private func scrollDidEndDeceleratingAndDidEndScrollAnimation() {
        clvStoryView.isUserInteractionEnabled = true
        var cell: StoryCell
        let visibleCells = clvStoryView.visibleCells

        if visibleCells.count > 1 {
            guard let mostVisableCell = scrollToMostVisibleCell(), let storyCell =  clvStoryView.cellForItem(at: mostVisableCell) as? StoryCell else { return }
            cell = storyCell
        } else {
            guard let storyCell = visibleCells.first as? StoryCell else { return }
            cell = storyCell
        }

        if cell.parentStoryIndex != currentStoryIndex {
            cell.progressBar?.resetBar()
            cell.progressBar?.animate(index: 0)
            cell.progressBar?.delegate?.segmentedProgressBarChangedIndex(index: 0)
            currentStoryIndex = cell.parentStoryIndex
        }
    }

    // MARK: - IBAction & Action
    @objc private func swipeDown(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: view?.window)
        if sender.state == .began {
            initialTouchPoint = touchPoint
        } else if sender.state == .changed {
            panGestureStateChnage(touchPoint: touchPoint)
        } else if sender.state == .ended || sender.state == .cancelled {
            panGestureStateCancelledAndEnded(touchPoint: touchPoint)
        }
    }

    @objc private func appMovedToBackground() {
        guard let cell = clvStoryView.visibleCells.get(at: 0) as? StoryCell else { return }
        cell.progressBar?.pause()
    }
}

// MARK: - CollectionView DataSource
extension StoryVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrayStories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as? StoryCell else {
            return .init() }

        cell.parentStoryIndex = indexPath.row
        cell.story = arrayStories.get(at: indexPath.row)?.story
        cell.initProgressbar()
        cell.delegate = self

        if firstLaunch && selectedStoryIndex == indexPath.row {
            cell.progressBar?.resetBar()
            cell.progressBar?.animate(index: 0)
            firstLaunch = false
            currentStoryIndex = selectedStoryIndex
        }

        if let item = arrayStories.get(at: indexPath.row)?.story.get(at: 0) {
            cell.lblTitle.text = item.title
        }

        if arrayStories[indexPath.row].story.get(at: 0)?.type == "image" {
            if let videoURL = arrayStories.get(at: indexPath.row)?.story.get(at: 0)?.url {
                cell.loadImage(urlString: videoURL)
            }
        } else {
            if let videoURL = arrayStories.get(at: indexPath.row)?.story.get(at: 0)?.url {
                cell.loadVideo(urlString: videoURL)
            }
        }

        return cell
    }
}

// MARK: - CollectionView FlowLayout Delegate
extension StoryVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: clvStoryView.frame.width, height: clvStoryView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidEndDeceleratingAndDidEndScrollAnimation()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if selectedStoryIndex == 0 && !firstLaunch {
            clvStoryView.isUserInteractionEnabled = false
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDidEndDeceleratingAndDidEndScrollAnimation()
    }

    func scrollToMostVisibleCell() -> IndexPath? {
        let visibleRect = CGRect(origin: clvStoryView.contentOffset, size: clvStoryView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath: IndexPath = clvStoryView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath
        } else {
            return nil
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let oldCell = cell as? StoryCell else { return }
        oldCell.progressBar?.resetBar()
    }
}

// MARK: - StoryCell delegates
extension StoryVC: StoryPreviewProtocol {
    func didStoryViewEnd() {
        dismiss(animated: true, completion: nil)
    }
}
