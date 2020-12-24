import UIKit
import RxSwift

protocol ReviewModalDelegate: class {
  
  func onTapClose()
  func onReviewSuccess()
}

class ReviewModalVC: BaseVC {
  
  weak var deleagete: ReviewModalDelegate?
  
  let viewModel: ReviewModalViewModel
  
  private lazy var reviewModalView = ReviewModalView(frame: self.view.frame)
  
  
  init(storeId: Int) {
    self.viewModel = ReviewModalViewModel(reviewService: ReviewService(), storeId: storeId)
    super.init(nibName: nil, bundle: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(storeId: Int) -> ReviewModalVC {
    return ReviewModalVC(storeId: storeId).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = reviewModalView
    
    self.addObservers()
  }
  
  override func bindViewModel() {
    // Bind input
    self.reviewModalView.star1.rx.tap
      .map { 1 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.star2.rx.tap
      .map { 2 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.star3.rx.tap
      .map { 3 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.star4.rx.tap
      .map { 4 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.star5.rx.tap
      .map { 5 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.reviewTextView.rx.text.orEmpty
      .bind(to: self.viewModel.input.contents)
      .disposed(by: disposeBag)
    
    self.reviewModalView.registerButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapRegister)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.reviewModalView.showLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.dismissOnSaveReview
      .observeOn(MainScheduler.instance)
      .bind { [weak self] _ in
        self?.deleagete?.onReviewSuccess()
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.showHTTPErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.reviewModalView.closeButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismissModal)
      .disposed(by: disposeBag)
  }
  
  private func addObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  private func dismissModal() {
    self.deleagete?.onTapClose()
  }
  
  @objc func keyboardWillShow(_ sender: Notification) {
    guard let userInfo = sender.userInfo as? [String:Any] else {return}
    guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
    
    self.reviewModalView.contentView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.cgRectValue.height)
  }
  
  @objc func keyboardWillHide(_ sender: Notification) {
    self.reviewModalView.contentView.transform = .identity
  }
}
