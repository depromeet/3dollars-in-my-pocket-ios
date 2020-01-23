import UIKit
import RxSwift
import GoogleMaps

protocol ModifyDelegate: class {
    func onModifySuccess()
}

class ModifyVC: BaseVC {
    
    private lazy var modifyView = ModifyView(frame: self.view.frame)
    weak var delegate: ModifyDelegate?
    
    var store: Store!
    var viewModel = ModifyViewMode()
    var locationManager = CLLocationManager()
    var deleteVC: DeleteModalVC?
    
    private let imagePicker = UIImagePickerController()
    private var selectedImageIndex = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    static func instance(store: Store) -> ModifyVC {
        return ModifyVC.init(nibName: nil, bundle: nil).then {
            $0.store = store
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = modifyView
        
        setupImageCollectionView()
        setupMenuTableView()
        setupKeyboardEvent()
        setupLocationManager()
        setupGoogleMap()
        setupStore()
    }
    
    override func bindViewModel() {
        modifyView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        modifyView.deleteBtn.rx.tap.bind { [weak self] in
            if let vc = self {
                vc.deleteVC = DeleteModalVC.instance(storeId: vc.store.id!).then {
                    $0.deleagete = self
                }
                vc.modifyView.addBgDim()
                vc.present(vc.deleteVC!, animated: true)
            }
        }.disposed(by: disposeBag)
        
        modifyView.nameField.rx.text.bind { [weak self] (inputText) in
            self?.modifyView.setFieldEmptyMode(isEmpty: inputText!.isEmpty)
            self?.viewModel.btnEnable.onNext(())
        }.disposed(by: disposeBag)
        
        modifyView.myLocationBtn.rx.tap.bind {
            self.locationManager.startUpdatingLocation()
        }.disposed(by: disposeBag)
        
        modifyView.registerBtn.rx.tap.bind { [weak self] in
            if let storeId = self?.store.id,
                let storeName = self?.modifyView.nameField.text!,
                let images = self?.viewModel.imageList,
                let latitude = self?.modifyView.mapView.camera.target.latitude,
                let longitude = self?.modifyView.mapView.camera.target.longitude,
                let menus = self?.viewModel.menuList {
                let store = Store.init(latitude: latitude, longitude: longitude, storeName: storeName, menus: menus)

                LoadingViewUtil.addLoadingView()
                StoreService.updateStore(storeId: storeId, store: store, images: images) { (response) in
                    switch response.result {
                    case .success(_):
                        self?.delegate?.onModifySuccess()
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        if let vc = self {
                            AlertUtils.show(controller: vc, title: "Update store error", message: error.localizedDescription)
                        }
                    }
                    LoadingViewUtil.removeLoadingView()
                }
            } else {
                AlertUtils.show(controller: self, message: "올바른 내용을 작성해주세요.")
            }
        }.disposed(by: disposeBag)
        
        viewModel.btnEnable
            .map { [weak self] (_) in
                if let vc = self {
                    return !vc.modifyView.nameField.text!.isEmpty
                } else {
                    return false
                }
        }
        .bind(to: modifyView.registerBtn.rx.isEnabled)
        .disposed(by: disposeBag)
    }
    
    private func setupStore() {
        modifyView.setImageCount(count: store.images.count)
        modifyView.setMenuCount(count: store.menus.count)
        modifyView.setCategory(category: store.category)
        modifyView.setTitle(title: store.storeName!)
        modifyView.setRepoter(repoter: store.repoter!.nickname!)
    }
    
    private func setupImageCollectionView() {
        imagePicker.delegate = self
        modifyView.imageCollection.dataSource = self
        modifyView.imageCollection.delegate = self
        modifyView.imageCollection.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.registerId)
    }
    
    private func setupMenuTableView() {
        viewModel.menuList = store.menus
        modifyView.menuTableView.delegate = self
        modifyView.menuTableView.dataSource = self
        modifyView.menuTableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.registerId)
    }
    
    private func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupGoogleMap() {
        modifyView.mapView.isMyLocationEnabled = true
    }
    
    @objc func onShowKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.modifyView.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 50
        self.modifyView.scrollView.contentInset = contentInset
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.modifyView.scrollView.contentInset = contentInset
    }
}

extension ModifyVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.imageList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.registerId, for: indexPath) as? ImageCell else {
            return BaseCollectionViewCell()
        }
        
        if indexPath.row < self.viewModel.imageList.count {
            cell.setImage(image: self.viewModel.imageList[indexPath.row])
        } else {
            cell.setImage(image: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 104, height: 104)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageIndex = indexPath.row
        AlertUtils.showImagePicker(controller: self, picker: self.imagePicker)
    }
}

extension ModifyVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if selectedImageIndex == self.viewModel.imageList.count {
                self.viewModel.imageList.append(image)
            } else {
                self.viewModel.imageList[selectedImageIndex] = image
            }
        }
        self.modifyView.imageCollection.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ModifyVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.menuList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.registerId, for: indexPath) as? MenuCell else {
            return BaseTableViewCell()
        }
        
        if indexPath.row < self.viewModel.menuList.count {
            cell.setMenu(menu: self.viewModel.menuList[indexPath.row])
        }
        
        cell.nameField.rx.controlEvent(.editingDidEnd).bind { [weak self] in
            let name = cell.nameField.text!
            
            if !name.isEmpty {
                let menu = Menu.init(name: name)
                
                if indexPath.row == self?.viewModel.menuList.count {
                    self?.viewModel.menuList.append(menu)
                    self?.modifyView.menuTableView.reloadData()
                    self?.view.layoutIfNeeded()
                } else {
                    self?.viewModel.menuList[indexPath.row].name = name
                }
            }
        }.disposed(by: disposeBag)
        
        cell.descField.rx.controlEvent(.editingChanged).bind { [weak self] in
            let name = cell.nameField.text!
            let desc = cell.descField.text!
            
            if !name.isEmpty && !desc.isEmpty {
                let menu = Menu.init(name: name, price: desc)
                
                if let _ = self?.viewModel.menuList[indexPath.row] {
                    self?.viewModel.menuList[indexPath.row] = menu
                }
            }
            
        }.disposed(by: disposeBag)
        return cell
    }
}

extension ModifyVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let position = GMSCameraPosition.init(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, zoom: 15)
        
        self.modifyView.mapView.camera = position
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
    }
}

extension ModifyVC: DeleteModalDelegate {
    func onRequest() {
        deleteVC?.dismiss(animated: true, completion: nil)
        self.modifyView.removeBgDim()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func onTapClose() {
        deleteVC?.dismiss(animated: true, completion: nil)
        self.modifyView.removeBgDim()
    }
}

