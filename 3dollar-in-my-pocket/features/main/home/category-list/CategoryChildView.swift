import UIKit

class CategoryChildView: BaseView {
    var category: StoreCategory!
    
    let descLabel1 = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 24)
    }
    
    let descLabel2 = UILabel().then {
        $0.text = "만나기 30초 전"
        $0.textColor = .black
        $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 24)
    }
    
    let nearOrderBtn = UIButton().then {
        $0.setTitle("거리순", for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
        $0.isSelected = true
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
    }
    
    let reviewOrderBtn = UIButton().then {
        $0.setTitle("리뷰순", for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
    }
    
    let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
        $0.tableFooterView = UIView()
        $0.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false
    }
    
    init(category: StoreCategory) {
        self.category = category
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setup() {
        backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
        addSubViews(descLabel1, descLabel2, nearOrderBtn, reviewOrderBtn, tableView)
    }
    
    override func bindConstraints() {
        descLabel1.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(41)
            make.left.equalToSuperview().offset(24)
        }
        
        descLabel2.snp.makeConstraints { (make) in
            make.centerY.equalTo(descLabel1.snp.centerY)
            make.left.equalTo(descLabel1.snp.right).offset(5)
        }
        
        reviewOrderBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-25)
            make.top.equalToSuperview().offset(49)
        }
        
        nearOrderBtn.snp.makeConstraints { (make) in
            make.right.equalTo(reviewOrderBtn.snp.left).offset(-16)
            make.centerY.equalTo(reviewOrderBtn.snp.centerY)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(descLabel1.snp.bottom).offset(5)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch category {
        case .BUNGEOPPANG:
            descLabel1.text = "붕어빵"
        case .GYERANPPANG:
            descLabel1.text = "계란빵"
        case .HOTTEOK:
            descLabel1.text = "호떡"
        case .TAKOYAKI:
            descLabel1.text = "타코야끼"
        default:
            descLabel1.text = "붕어빵"
        }
    }
}
