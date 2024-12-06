//
//  MesaageComposerComponent.swift
//  CometChatSwift
//
//  Created by admin on 12/08/22.
//  Copyright © 2022 MacMini-03. All rights reserved.
//

import UIKit
import CometChatSDK
import CometChatUIKitSwift

class MesaageComposerComponent: UIViewController {

    @IBOutlet weak var messageCompser: CometChatMessageComposer!
    @IBOutlet weak var messageComposerContainer: UIView!
    
    func setupView() {
        DispatchQueue.main.async {
            self.messageCompser.set(controller: self)
            let blurredView = self.blurView(view: self.view)
            self.view.addSubview(blurredView)
            self.view.sendSubviewToBack(blurredView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupView()
    }

    public override func loadView() {
        let loadedNib = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
    }
    
    func setupUI() {
        self.view.backgroundColor = .systemFill
        messageComposerContainer.roundViewCorners([.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner], radius: 20)
        messageComposerContainer.dropShadow()
    }
    
    @IBAction func onCloseClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

