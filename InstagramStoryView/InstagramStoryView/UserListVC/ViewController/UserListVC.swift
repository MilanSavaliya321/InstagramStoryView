//
//  UserListVC.swift
//  CCSIMobile
//
//  Created by mac on 08/11/21.
//  Copyright © 2021 Milan Savaliya. All rights reserved.
//
import UIKit

final class UserListVC: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak private var clvCards: UICollectionView!

    // MARK: - Properties
    private var arrayStories: [StoryModel] = []

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Function
    private func setupUI() {
        title = "Instagram"
        createData()
        setupCollectionView()
    }

    private func createData() {
//        let arrSnaps = [[SnapsModle(title: "A1", type: "video", url: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_640_3MG.mp4"),
//                         SnapsModle(title: "A2", type: "image", url: "https://picsum.photos/200/300"),
//                         SnapsModle(title: "A3", type: "image", url: "https://picsum.photos/200/300")],
//
//                        [SnapsModle(title: "B1", type: "image", url: "https://picsum.photos/200/300"),
//                         SnapsModle(title: "B2", type: "image", url: "https://picsum.photos/200/300")],
//
//                        [SnapsModle(title: "C1", type: "image", url: "https://picsum.photos/200/300"),
//                         SnapsModle(title: "C2", type: "image", url: "https://picsum.photos/200/300"),
//                         SnapsModle(title: "C3", type: "image", url: "https://picsum.photos/200/300")],
//
//                        [SnapsModle(title: "D1", type: "image", url: "https://picsum.photos/200/300"),
//                         SnapsModle(title: "D2", type: "image", url: "https://picsum.photos/200/300")]
//        ]

        let arrSnaps = [[SnapsModle(title: "A1", type: "video", url: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_640_3MG.mp4"),
                         SnapsModle(title: "A2", type: "image", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Altja_j%C3%B5gi_Lahemaal.jpg/900px-Altja_j%C3%B5gi_Lahemaal.jpg"),
                         SnapsModle(title: "A3", type: "image", url: "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg")],

                        [SnapsModle(title: "B1", type: "image", url: "https://cdn.pixabay.com/photo/2015/12/01/20/28/road-1072821__340.jpg"),
                         SnapsModle(title: "B2", type: "image", url: "https://cdn.wallpapersafari.com/5/12/K4tMkR.jpg")],

                        [SnapsModle(title: "C1", type: "image", url: "https://iso.500px.com/wp-content/uploads/2016/03/stock-photo-142984111.jpg"),
                         SnapsModle(title: "C2", type: "image", url: "https://images.pexels.com/photos/414102/pexels-photo-414102.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"),
                         SnapsModle(title: "C3", type: "image", url: "https://cdn.pixabay.com/photo/2018/01/14/23/12/nature-3082832_1280.jpg")],

                        [SnapsModle(title: "D1", type: "image", url: "https://pbs.twimg.com/media/E9YJOcmWQAczMrY.jpg"),
                         SnapsModle(title: "D2", type: "image", url: "https://shotkit.com/wp-content/uploads/2021/01/nature-photography.jpg")]
        ]

        for i in 0..<arrSnaps.count {
            arrayStories.append(StoryModel(title: "s\(i)", story: arrSnaps[i]))
        }
    }

    private func setupCollectionView() {
        clvCards.delegate = self
        clvCards.dataSource = self
        clvCards.register(UINib(nibName: "UserCardsCell", bundle: nil), forCellWithReuseIdentifier: "UserCardsCell")
        clvCards.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension UserListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrayStories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCardsCell", for: indexPath) as? UserCardsCell else {
            return UICollectionViewCell()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 20 - 30 - 20 ) / 3.4
        let height = width * 1 / 1
        return CGSize(width: floor(width), height: ceil(height))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let aboutPlaceholderVc = StoryVC(arrayStories: arrayStories, selectedStoryIndex: indexPath.row)
        aboutPlaceholderVc.modalPresentationStyle = .overFullScreen
        present(aboutPlaceholderVc, animated: true, completion: nil)
    }
}
