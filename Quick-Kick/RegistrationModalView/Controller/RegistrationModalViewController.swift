//
//  RefistrationModalViewController.swift
//  Quick-Kick
//
//  Created by 장상경 on 12/17/24.
//

import UIKit
import SnapKit

// 킥보드 등록을 모달뷰 컨트롤러
final class RegistrationModalViewController: UIViewController {
    
    private var latitude: Double?
    private var longitude: Double?
    private var address: String?
    
    private var _typeSeleted: Bool = false
    private var _haveNickNameText: Bool = false
    private var _sendNickName: String?
    private var _kickboardType: Bool?
    
    private let textField = RegistrationTextField()
    private let typeButton = KickboardTypeButton()
    private let addButton = RegistrationButton()
    
    // MARK: - RegistrationModalViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTypeButton()
        setupTextField()
        setupAddButton()
    }
    
    // MARK: - RegistrationModalViewController UI Setting Method
    /// 텍스트필드를 세팅하는 메소드
    private func setupTextField() {
        self.textField.registrationDelegate = self
        view.addSubview(self.textField)
        
        self.textField.snp.makeConstraints {
            $0.top.equalTo(self.typeButton.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(120)
        }
    }
    
    /// 킥보드 타입 버튼을 세팅하는 메소드
    private func setupTypeButton() {
        self.typeButton.registrationDelegate = self
        view.addSubview(self.typeButton)
        
        self.typeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(170)
            $0.width.equalTo(320)
        }
    }
    
    /// 등록하기 버튼을 세팅하는 메소드
    private func setupAddButton() {
        self.addButton.registrationDelegate = self
        view.addSubview(self.addButton)
        
        self.addButton.snp.makeConstraints {
            $0.top.equalTo(self.textField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
            $0.width.equalTo(320)
        }
    }
    
    private func completeRegistrationAlert(_ completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "등록 완료", message: "내 킥보드가 Quick하게\n저장되었습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion()
        })
        
        self.present(alert, animated: true)
    }
    
    func editKickboardData(_ type: Bool, _ text: String) {
        self.typeButton.updateData(type)
        self.textField.updateData(text)
    }
    
    /// 킥보드 등록 탭에서 + 버튼 눌렀을 때 주소 정보 전달 받는 메소드
    func setAddressInfo(_ latitude: Double, _ longitude: Double, _ address: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
}

// MARK: RegistrationViewDelegate Method
extension RegistrationModalViewController: RegistrationViewDelegate {
    var sendNickName: String? {
        get { self._sendNickName }
        set { self._sendNickName = newValue }
    }
    
    var kickboardType: Bool? {
        get { self._kickboardType }
        set { self._kickboardType = newValue }
    }
    
    func savedKickboardData() {
        guard let latitude, let longitude, let address, let nickName = _sendNickName, let type = _kickboardType else { return }
        
        let kickboardData = KickboardDTO(nickName: nickName,
                                         isSaddled: type,
                                         isOccupied: false,
                                         startTime: nil,
                                         endTime: nil,
                                         latitude: latitude,
                                         longitude: longitude,
                                         address: address
        )
        
        CoreDataManager.shared.create(with: kickboardData)
        
        completeRegistrationAlert() { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true)
        }
        
        print(CoreDataManager.shared.fetch().last)
    }
    
    var typeSeleted: Bool {
        get { return self._typeSeleted }
        set { self._typeSeleted = newValue }
    }
    
    var haveNickNameText: Bool {
        get { return self._haveNickNameText }
        set { self._haveNickNameText = newValue }
    }
    
    /// 등록하기 버튼을 활성화 하는 메소드
    func activateButton() {
        guard self.typeSeleted, self.haveNickNameText else {
            self.addButton.activateButton(false)
            return
        }
        
        self.addButton.activateButton(true)
    }
}

