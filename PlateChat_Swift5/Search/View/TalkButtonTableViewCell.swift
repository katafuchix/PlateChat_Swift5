//
//  TalkButtonTableViewCell.swift
//  PlateChat
//
//  Created by cano on 2018/09/23.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TalkButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var talkButton: UIButton!
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
