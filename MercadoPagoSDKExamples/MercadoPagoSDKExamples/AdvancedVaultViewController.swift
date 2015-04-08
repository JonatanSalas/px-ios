//
//  AdvancedVaultViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 3/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import MercadoPagoSDK

class AdvancedVaultViewController : SimpleVaultViewController {
    
    @IBOutlet weak var installmentsCell : MPInstallmentsTableViewCell!
    var payerCosts : [PayerCost]?
    var selectedPayerCost : PayerCost? = nil
    var amount : Double = 0
    
    var selectedIssuer : Issuer? = nil
    var advancedCallback : ((paymentMethod: PaymentMethod, token: Token?, cardIssuerId: Int64?, installments: Int?) -> Void)?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(merchantPublicKey: String, merchantBaseUrl: String, merchantGetCustomerUri: String, merchantAccessToken: String, amount: Double, supportedPaymentTypes: [String], callback: ((paymentMethod: PaymentMethod, token: Token?, cardIssuerId: Int64?, installments: Int?) -> Void)?) {
        super.init(merchantPublicKey: merchantPublicKey, merchantBaseUrl: merchantBaseUrl, merchantGetCustomerUri: merchantGetCustomerUri, merchantAccessToken: merchantAccessToken, supportedPaymentTypes: supportedPaymentTypes, callback: nil)
        advancedCallback = callback
        self.amount = amount
    }
 
    override func getSelectionCallbackPaymentMethod() -> (paymentMethod : PaymentMethod) -> Void {
        return { (paymentMethod : PaymentMethod) -> Void in
            self.selectedCard = nil
            self.newCard = true
            self.selectedPaymentMethod = paymentMethod
            if paymentMethod.settings != nil && paymentMethod.settings.count > 0 {
                self.securityCodeLength = paymentMethod.settings![0].securityCode!.length!
                self.securityCodeRequired = self.securityCodeLength != 0
            }
            let newCardViewController = MercadoPago.startNewCardViewController(MercadoPago.PUBLIC_KEY, key: ExamplesUtils.MERCHANT_PUBLIC_KEY, paymentMethod: self.selectedPaymentMethod!, requireSecurityCode: self.securityCodeRequired, callback: self.getNewCardCallback())
            
            if self.selectedPaymentMethod!.isIssuerRequired() {
                let issuerViewController = MercadoPago.startIssuersViewController(ExamplesUtils.MERCHANT_PUBLIC_KEY, paymentMethod: self.selectedPaymentMethod!,
                    callback: { (issuer: Issuer) -> Void in
                        self.selectedIssuer = issuer
                        self.tableview.reloadData()
                        self.showViewController(newCardViewController, sender: self)
                })
                self.showViewController(issuerViewController, sender: self)
            } else {
                self.showViewController(newCardViewController, sender: self)
            }
        }
    }
 
    override func getNewCardCallback() -> (cardToken: CardToken) -> Void {
        return { (cardToken: CardToken) -> Void in
            self.selectedCardToken = cardToken
            self.bin = self.selectedCardToken?.getBin()
            if self.selectedPaymentMethod!.settings != nil && self.selectedPaymentMethod!.settings.count > 0 {
                self.securityCodeLength = self.selectedPaymentMethod!.settings![0].securityCode!.length!
                self.securityCodeRequired = self.securityCodeLength != 0
            }
            self.loadPayerCosts()
            self.navigationController!.popToViewController(self, animated: true)
        }
    }
    
    override func getCustomerPaymentMethodCallback(paymentMethodsViewController : PaymentMethodsViewController) -> (selectedCard: Card?) -> Void {
        return {(selectedCard: Card?) -> Void in
            if selectedCard != nil {
                self.selectedCard = selectedCard
                self.selectedPaymentMethod = self.selectedCard?.paymentMethod
                self.selectedIssuer = self.selectedCard?.issuer
                self.newCard = false
                self.bin = self.selectedCard?.firstSixDigits
                self.securityCodeLength = self.selectedCard!.securityCode!.length
                self.securityCodeRequired = self.securityCodeLength > 0
                self.loadPayerCosts()
                self.navigationController!.popViewControllerAnimated(true)
            } else {
                self.showViewController(paymentMethodsViewController, sender: self)
            }
        }
    }
    
    override func declareAndInitCells() {
        super.declareAndInitCells()
        var installmentsNib = UINib(nibName: "MPInstallmentsTableViewCell", bundle: MercadoPago.getBundle())
        self.tableview.registerNib(installmentsNib, forCellReuseIdentifier: "installmentsCell")
        self.installmentsCell = self.tableview.dequeueReusableCellWithIdentifier("installmentsCell") as MPInstallmentsTableViewCell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedCard == nil && !newCard {
            return 1
        }
        else if self.selectedPayerCost == nil {
            return 2
        } else if !securityCodeRequired {
            return 2
        }
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if (!newCard && self.selectedCard == nil) {
                self.emptyPaymentMethodCell = self.tableview.dequeueReusableCellWithIdentifier("emptyPaymentMethodCell") as MPPaymentMethodEmptyTableViewCell
                return self.emptyPaymentMethodCell
            } else {
                self.paymentMethodCell = self.tableview.dequeueReusableCellWithIdentifier("paymentMethodCell") as MPPaymentMethodTableViewCell
                if newCard {
                    self.paymentMethodCell.fillWithCardTokenAndPaymentMethod(self.selectedCardToken, paymentMethod: self.selectedPaymentMethod!)
                } else {
                    self.paymentMethodCell.fillWithCard(self.selectedCard)
                }
                return self.paymentMethodCell
            }
        } else if indexPath.row == 1 {
            self.installmentsCell = self.tableview.dequeueReusableCellWithIdentifier("installmentsCell") as MPInstallmentsTableViewCell
            self.installmentsCell.fillWithPayerCost(self.selectedPayerCost, amount: self.amount)
            return self.installmentsCell
        } else if indexPath.row == 2 {
            self.securityCodeCell = self.tableview.dequeueReusableCellWithIdentifier("securityCodeCell") as MPSecurityCodeTableViewCell
            self.securityCodeCell.fillWithPaymentMethod(self.selectedPaymentMethod!)
            self.securityCodeCell.securityCodeTextField.delegate = self
            return self.securityCodeCell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 2) {
            return 115
        }
        return 65
    }
    
    func loadPayerCosts() {
        self.view.addSubview(self.loadingView)
        let mercadoPago : MercadoPago = MercadoPago(publicKey: self.publicKey!)
        
        let issuerId = self.selectedIssuer != nil ? self.selectedIssuer!.id : nil
     
        mercadoPago.getInstallments(self.bin!, amount: self.amount, issuerId: issuerId, paymentTypeId: self.selectedPaymentMethod!.paymentTypeId!, success: {(installments: [Installment]?) -> Void in
            if installments != nil {
                self.payerCosts = installments![0].payerCosts
                self.tableview.reloadData()
                self.loadingView.removeFromSuperview()
            }
            }, failure: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        } else if indexPath.row == 1 {

            self.showViewController(MercadoPago.startInstallmentsViewController(payerCosts!, amount: amount, callback: { (payerCost: PayerCost?) -> Void in
                self.selectedPayerCost = payerCost
                self.tableview.reloadData()
                self.navigationController!.popToViewController(self, animated: true)
            }), sender: self)
        }
    }
    
    override func submitForm() {
        
        let mercadoPago : MercadoPago = MercadoPago(publicKey: self.publicKey!)
        
        // Create token
        if selectedCard != nil {
            
            let savedCardToken : SavedCardToken = SavedCardToken(cardId: String(format:"%ld",selectedCard!.id!), securityCode: securityCodeCell.securityCodeTextField.text)
            
            if savedCardToken.validate() {
                // Send card id to get token id
                self.view.addSubview(self.loadingView)
                mercadoPago.createToken(savedCardToken, success: {(token: Token?) -> Void in
                    self.advancedCallback!(paymentMethod: self.selectedPaymentMethod!, token: token, cardIssuerId: self.selectedIssuer?.id, installments: self.selectedPayerCost?.installments)
                }, failure: nil)
            } else {
                println("Invalid data")
                return
            }
        } else {
            self.selectedCardToken!.securityCode = self.securityCodeCell.securityCodeTextField.text
            self.view.addSubview(self.loadingView)
            mercadoPago.createNewCardToken(self.selectedCardToken!, success: {(token: Token?) -> Void in
                    self.advancedCallback!(paymentMethod: self.selectedPaymentMethod!, token: token, cardIssuerId: self.selectedIssuer?.id, installments: self.selectedPayerCost?.installments)
            }, failure: nil)
        }
    }
    
}