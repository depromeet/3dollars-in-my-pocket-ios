import UIKit
import RxSwift

class StoreDetailPhotoCollectionCell: BaseTableViewCell {
  
  static let registerId = "\(StoreDetailPhotoCell.self)"
  
  let photos = PublishSubject<[String]>()
  let photoCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 72, height: 72)
    $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    $0.collectionViewLayout = layout
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundColor = .clear
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.setupCollectionView()
  }
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    self.contentView.addSubViews(photoCollectionView)
    self.setupCollectionView()
  }
  
  override func bindConstraints() {
    self.photoCollectionView.snp.makeConstraints { make in
      make.left.right.top.bottom.equalToSuperview()
      make.height.equalTo(100)
    }
  }
  
  func bind(photos: [String]) {
    self.photos.onNext(photos)
  }
  
  private func setupCollectionView() {
    self.photoCollectionView.register(
      StoreDetailPhotoCell.self,
      forCellWithReuseIdentifier: StoreDetailPhotoCell.registerId
    )
    self.photos.bind(to: self.photoCollectionView.rx.items(
      cellIdentifier: StoreDetailPhotoCell.registerId,
      cellType: StoreDetailPhotoCell.self
    )) { row, url, cell in
      cell.bind(url: url)
    }.disposed(by: disposeBag)
  }
  
}
