//
//  RegistProfileViewModel.swift
//  PlateChat
//
//  Created by cano on 2019/01/04.
//  Copyright © 2019 deskplate. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RegistProfileViewModel {
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
