//
//  RegisterViewModel.swift
//  ParentDemo
//
//  Created by ahmed gado on 10/5/20.
//  Copyright © 2020 ahmed gado. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Firebase

class RegisterViewModel {
    var nameBehavior = BehaviorRelay<String>(value: "")
    var emailBehavior = BehaviorRelay<String>(value: "")
    var passwordBehavior = BehaviorRelay<String>(value: "")
    var confiemPasswordBehavior = BehaviorRelay<String>(value: "")
    
    var loadingBehavior = BehaviorRelay<Bool>(value: false)
    
    private var registerModelSubject = PublishSubject<[String: Any]>()
    var registerModelObserver : Observable<[String: Any]> {
        return registerModelSubject
    }
    
    private var childModelSubject = PublishSubject<[ChildModel]>()
    
    var childModelObservable : Observable<[ChildModel]>{
        return childModelSubject
    }
    var user = [ChildModel]()

    var isEmailValid : Observable<Bool>{
        return emailBehavior.asObservable().map { (email) -> Bool in
            let isEmaillEmpty = email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return isEmaillEmpty
        }
    }
    
    var isPasswordValid : Observable<Bool>{
        return passwordBehavior.asObservable().map { (password) -> Bool in
            let isPasswordEmpty = password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return isPasswordEmpty
        }
    }
    
    var isConfirmPasswordValid : Observable<Bool>{
        return confiemPasswordBehavior.asObservable().map { (password) -> Bool in
            let isPasswordEmpty = password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return isPasswordEmpty
        }
    }
    
    var isSaveButtonEnabel : Observable<Bool>{
        return Observable.combineLatest(isEmailValid , isPasswordValid , isConfirmPasswordValid){(isEmailEmpty , isPassworlEmpty , isConfirmPasswordEmpty) in
            let loginValid = !isEmailEmpty && !isPassworlEmpty && !isConfirmPasswordEmpty
            return loginValid
            
        }
    }
    // MARK: - getRegister
    func getRegister(successed : @escaping (String) -> Void){
        loadingBehavior.accept(true)
        Auth.auth().createUser(withEmail: emailBehavior.value, password: passwordBehavior.value ) { [weak self](success, error) in
            guard let self = self else {return}
            self.loadingBehavior.accept(false)
            if error == nil {
                // success
                print(success ?? "success")
                guard let userId = success?.user.uid else {return}
                self.addDataRef(uid: userId)
                UserDefaults.standard.set(userId, forKey: "id")
                UserDefaults.standard.synchronize()
                successed(userId)
            }else {
                // error
                print(error?.localizedDescription ?? "error")
            }
        }
        
    }
    // MARK: - addDataRef
    func addDataRef(uid : String) {
        let reference = Database.database().reference()
        let user = reference.child(Constants.uSERSPARENT).child(uid)
        let value:[String: Any] = [Constants.iD : uid , Constants.nAME: self.nameBehavior.value , Constants.eMail : self.emailBehavior.value ]
        user.setValue(value)
        self.registerModelSubject.onNext(value)
    }
    
    //
    // MARK: - featchChild
    func featchChild(successed : @escaping ([ChildModel]) -> Void){
        loadingBehavior.accept(true)
        let ref = Database.database().reference().child(Constants.uSERSCHILD)
        ref.observe(.childAdded, with: {[weak self] (snapchot) in
            guard let self = self else {return}
            print(snapchot)
            self.loadingBehavior.accept(false)
            if let dict = snapchot.value as? [String:Any] {
                self.user.removeAll()
                self.user.append(ChildModel(id: dict[Constants.iD] as! String, name: dict[Constants.nAMEChild] as? String , email: dict[Constants.eMailCHILD] as? String, lat: dict[Constants.lATCHILD] as? Double, lang: dict[Constants.lANGCHILD] as? Double))
                
                print(self.user.count)
                if self.user.count > 0 {
                    self.childModelSubject.onNext(self.user)
                    successed(self.user)
                }else {
                    print("No Child")
                }
            }
            }, withCancel: nil)
    }
}
