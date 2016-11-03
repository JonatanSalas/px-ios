//
//  CallFourAuthTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/31/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class CallForAuthTableViewCell: CallbackCancelTableViewCell {

    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.addTarget(self, action: #selector(invokeCallback), for: .touchUpInside)
        // Initialization code
    }
    func fillCell(paymentMehtod: PaymentMethod){
        if let paymentMethodName = paymentMehtod.name {
            let message = ("Ya hable con %0 y me autorizó".localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)")
            self.button.setTitle(message, for: UIControlState.normal)
        }
    }
    func addSeparatorLineToTop(width: Double, y: Int){
        var lineFrame = CGRect(origin: CGPoint(x: 0,y :y), size: CGSize(width: width, height: 0.5))
        var line = UIView(frame: lineFrame)
        line.alpha = 0.6
        line.backgroundColor = UIColor.grayLight()
        addSubview(line)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
