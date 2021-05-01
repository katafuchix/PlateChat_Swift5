//
//  ProfileEdit.swift
//  PlateChat
//
//  Created by cano on 2018/08/13.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

struct ProfileEditViewModel {

    // MARK: - rx

    /// 読み込み中フラグ fetch中ならtrue
    var isLoading: Variable<Bool> = Variable(true)

    //var loginUser: Variable<LoginUser> = Variable(LoginUser())

    /// ニックネーム
    var nickName: Variable<String> = Variable<String>("")

    /// 性別
    var sex: Variable<Int> = Variable(0)

    /// 自己紹介文
    var profileText: Variable<String> = Variable<String>("")
}
