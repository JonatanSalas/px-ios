//
//  MockBuilder.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation

open class MockBuilder: NSObject {

    internal class var MOCK_PAYMENT_ID: String {
        return "1826290155"
    }

    class var PREF_ID_NO_EXCLUSIONS: String {
        return "NO_EXCLUSIONS"
    }

    class var PREF_ID_CC: String {
        return "ONLY_CREDIT_CARD"
    }

    class var PREF_ID_TICKET: String {
        return "ONLY_TICKET"
    }

    class var PREF_ID_PAGOFACIL: String {
        return "ONLY_PAGOFACIL"
    }

    class var MLA_PK: String {
        return "PK_MLA"
    }

    class var MLA_CURRENCY: String {
        return "ARS"
    }

    class var MLA_PAYMENT_TYPES: Set<String> {
        return [PaymentTypeId.CREDIT_CARD.rawValue, PaymentTypeId.TICKET.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue]
    }

    class var MERCHANT_ACCESS_TOKEN: String {
        return "MERCHANT_ACCESS_TOKEN"
    }

    class var CUSTOMER_ACCESS_TOKEN: String {
        return "ACCESS_TOKEN"
    }

    class var INSTALLMENT_AMOUNT: Double {
        return 100.0
    }

    class var AMEX_TEST_CARD_NUMBER: String {
        return "371180303257522"
    }

    class var MASTER_TEST_CARD_NUMBER: String {
        return "5031755734530604"
    }

    class var VISA_TEST_CARD_NUMBER: String {
        return "4170068810108020"
    }

    static let TEN = "10.00"
    static let HUNDRED = "100.00"
    static let THOUSAND = "1000.00"
    static let TEN_THOUSAND = "10000.00"
    static let MILLON = "1000000.00"
    static let OVER_MILLON = "10000000000.00"
    static let MILLIONS = "10000000000000000.00"

    static let HALF_HOUR_IN_MINS = 30 * 1000
    static let ONE_HOUR_IN_MINS = 60 * 1000
    static let TWENTY_HOURS_AND_FIFTEEN_MINS_IN_MINS = 1395 * 1000
    static let ONE_DAY_IN_MINS = 1440 * 1000
    static let TWO_DAY_IN_MINS = 2880 * 1000
    static let SEVEN_DAY_IN_MINS = 10080 * 1000
    static let HUNDRED_DAYS_IN_MINS = 144000 * 1000

    class func buildCheckoutPreference() -> CheckoutPreference {
        let preference = CheckoutPreference()
        preference._id = PREF_ID_NO_EXCLUSIONS
        preference.items = [self.buildItem("itemId", quantity: 1, unitPrice: 2559), self.buildItem("itemId2", quantity: 2, unitPrice: 10)]
        preference.payer = Payer.fromJSON(MockManager.getMockFor("Payer")!)
        return preference
    }

    class func buildItem(_ id: String, quantity: Int, unitPrice: Double) -> Item {
        return Item(_id: id, title : "item title", quantity: quantity, unitPrice: unitPrice)
    }

    class func buildPayer(_ id: String) -> Payer {
        let payer =  Payer()
        payer._id = id
        payer.email = "thisisanem@il.com"
        return payer
    }

    class func buildPreferencePaymentMethods() -> PaymentPreference {
        let preferencePM = PaymentPreference()
        preferencePM.defaultInstallments = 1
        preferencePM.defaultPaymentMethodId = "visa"
        preferencePM.excludedPaymentMethodIds = ["amex"]
        preferencePM.excludedPaymentTypeIds = self.getMockPaymentTypeIds()
        return preferencePM
    }

    class func buildPaymentMethod(_ id: String, name: String? = "", paymentTypeId: String? = "credit_card", multipleSettings: Bool? = false) -> PaymentMethod {
        var paymentMethod = PaymentMethod.fromJSON(MockManager.getMockFor("PaymentMethod")!)
        if multipleSettings == true {
            paymentMethod = PaymentMethod.fromJSON(MockManager.getMockFor("PaymentMethodMultipleSettings")!)
        }
        paymentMethod._id = id
        paymentMethod.name = name
        paymentMethod.paymentTypeId = paymentTypeId
        return paymentMethod
    }

    class func buildSecurityCode() -> SecurityCode {
        let securityCode = SecurityCode()
        securityCode.length = 3
        securityCode.mode = "mode"
        securityCode.cardLocation = "back"
        return securityCode
    }

    class func buildSetting() -> Setting {
        let setting = Setting()
        setting.binMask = MockBuilder.buildBinMask()
        setting.securityCode = MockBuilder.buildSecurityCode()
        setting.cardNumber = MockBuilder.buildCardNumber()
        return setting
    }

    class func buildIdentification() -> Identification {
        let identification = Identification(type: "type", number: "number")
        return identification
    }

    class func buildCard(paymentMethodId: String? = "paymentMethodId") -> Card {
        let card = Card()
        card.idCard = "4"
        card.firstSixDigits = "123456"
        card.lastFourDigits = "1234"
        card.expirationMonth = 4
        card.expirationYear = 20
        card.cardHolder = buildCardholder()
        card.securityCode = buildSecurityCode()
        card.securityCode?.cardLocation = "card_location"
        card.securityCode?.mode = "mode"
        card.securityCode?.length = 3
        card.paymentMethod = MockBuilder.buildPaymentMethod(paymentMethodId!)
        card.customerId = "customer_id"
        card.issuer = buildIssuer()
        return card
    }

    class func buildCustomerPaymentMethod(paymentMethodId: String, paymentTypeId: String) -> CustomerPaymentMethod {
        let customerPm = CustomerPaymentMethod()
        let pm = MockBuilder.buildPaymentMethod(paymentMethodId)
        customerPm.paymentMethod = pm
        customerPm.paymentMethodId = paymentMethodId
        customerPm.paymentMethodTypeId = paymentTypeId
        return customerPm
    }

    class func buildPayment(_ paymentMethodId: String, installments: Int? = 1, includeFinancingFee: Bool? = false, status: String? = "approved", statusDetail: String? = "approved") -> Payment {
        let payment = Payment()
        payment._id = self.MOCK_PAYMENT_ID
        payment.paymentMethodId = paymentMethodId
        payment.paymentTypeId = "credit_card"
        payment.status = status
        payment.installments = installments!
        payment.transactionDetails = TransactionDetails()
        payment.transactionDetails.installmentAmount = MockBuilder.INSTALLMENT_AMOUNT
        payment.statusDetail = statusDetail
        payment.feesDetails = [FeesDetail]()
        if includeFinancingFee != nil && includeFinancingFee! {
            let feesDetail = FeesDetail()
            feesDetail.type = "financing_fee"
            payment.feesDetails.append(feesDetail)
            let amount = MockBuilder.INSTALLMENT_AMOUNT * Double(installments!)
            payment.transactionDetails.totalPaidAmount =  amount + (amount * 0.20)
        }
        payment.payer = buildPayer("1")
        payment.card = buildCard()
        return payment
    }

    class func buildOffPayment(_ paymentMethodId: String, paymentTypeId: String? = "ticket") -> Payment {
        let payment = Payment()
        payment._id = self.MOCK_PAYMENT_ID
        payment.paymentMethodId = paymentMethodId
        payment.paymentTypeId = paymentTypeId
        payment.status = "pending"
        return payment
    }

    class func buildMastercardPayment(_ installments: Int? = 1, includeFinancingFee: Bool? = false, status: String? = "approved", statusDetail: String? = "approved") -> Payment {
        return MockBuilder.buildPayment("master", installments: installments, includeFinancingFee: includeFinancingFee, status: status, statusDetail: statusDetail)
    }

    class func buildVisaPayment(_ installments: Int? = 1, includeFinancingFee: Bool? = false, status: String? = "approved", statusDetail: String? = "approved") -> Payment {
        return MockBuilder.buildPayment("visa", installments: installments, includeFinancingFee: includeFinancingFee, status: status, statusDetail: statusDetail)
    }

    class func buildAmexPayment(_ installments: Int? = 1, includeFinancingFee: Bool? = false, status: String? = "approved", statusDetail: String? = "approved") -> Payment {
        return MockBuilder.buildPayment("visa", installments: installments, includeFinancingFee: includeFinancingFee, status: status, statusDetail: statusDetail)
    }

    class func buildPaymentMethodSearchItem(_ paymentMethodId: String, type: PaymentMethodSearchItemType? = nil) -> PaymentMethodSearchItem {
        let paymentMethodSearchItem = PaymentMethodSearchItem()
        paymentMethodSearchItem.idPaymentMethodSearchItem = paymentMethodId
        if type != nil {
            paymentMethodSearchItem.type = type
        }
        paymentMethodSearchItem.showIcon = true
        return paymentMethodSearchItem
    }

    class func buildPaymentMethodSearch(groups: [PaymentMethodSearchItem]? = nil, paymentMethods: [PaymentMethod]? = nil, customOptions: [CardInformation]? = nil) -> PaymentMethodSearch {
        let paymentMethodSearch = PaymentMethodSearch()
        paymentMethodSearch.groups = groups
        paymentMethodSearch.paymentMethods = paymentMethods
        paymentMethodSearch.customerPaymentMethods = customOptions
        return paymentMethodSearch
    }

    class func getMockPaymentMethods() -> [PaymentMethod] {
        return [self.buildPaymentMethod("amex"), self.buildPaymentMethod("oxxo")]
    }

    class func getMockPaymentTypeIds() -> Set<String> {
        return Set([PaymentTypeId.BITCOIN.rawValue, PaymentTypeId.ACCOUNT_MONEY.rawValue])
    }

    class func buildPaymentType() -> PaymentType {
        let creditCardPaymentTypeId = PaymentTypeId.CREDIT_CARD
        return PaymentType(paymentTypeId: creditCardPaymentTypeId)
    }

    class func buildToken() -> Token {
        let token = Token(_id: "tokenId", publicKey: MLA_PK, cardId: "cardId", luhnValidation: "luhn", status: "status", usedDate: "11", cardNumberLength: 16, creationDate: Date(), lastFourDigits: "1234", firstSixDigit: "123456", securityCodeLength: 3, expirationMonth: 11, expirationYear: 22, lastModifiedDate: Date(), dueDate: Date(), cardHolder: MockBuilder.buildCardholder())
        return token
    }

    class func buildCardToken() -> CardToken {
        let cardToken = CardToken()
        cardToken.cardholder = MockBuilder.buildCardholder()
        return cardToken
    }

    class func buildCardholder() -> Cardholder {
        let cardHolder = Cardholder()
        cardHolder.name = "name"
        cardHolder.identification = Identification()
        return cardHolder
    }

    class func buildCardNumber() -> CardNumber {
        let cardNumber = CardNumber()
        cardNumber.length = 4
        cardNumber.validation = "luhn"
        return cardNumber
    }

    class func buildPromo() -> Promo {
        let promo = Promo()
        promo.promoId = "promoId"
        promo.legals = "legals"
        promo.paymentMethods = [MockBuilder.buildPaymentMethod("idPaymentMethod")]
        return promo
    }

    class func buildBinMask() -> BinMask {
        let bin = BinMask()
        bin.pattern = "pattern"
        bin.exclusionPattern = "exclusion_pattern"
        bin.installmentsPattern = "installments_pattern"
        return bin
    }

    class func buildPayerCost(installments: Int = 1, installmentRate: Double = 10, hasCFT: Bool = false) -> PayerCost {
        let payerCost = PayerCost(installments: installments, installmentRate: installmentRate, labels: ["label"], minAllowedAmount: 10, maxAllowedAmount: 100, recommendedMessage: "", installmentAmount: 10, totalAmount: 10)

        if hasCFT {
            payerCost.labels = ["CFT_0,00%|TEA_0,00%"]
        }

        return payerCost
    }

    class func buildIssuer() -> Issuer {
        let issuer = Issuer()
        issuer._id = "id"
        issuer.name = "name"
        return issuer
    }

    class func buildPaymentOptionSelected(_ id: String) -> PaymentMethodOption {
        let option = PaymentMethodSearchItem()
        option.idPaymentMethodSearchItem = id
        option._description = "description"
        return option
    }

    class func buildCustomerPaymentMethod(_ id: String, paymentMethodId: String) -> CardInformation {
        let customOption = CustomerPaymentMethod()
        customOption._id = id
        customOption.paymentMethodId = paymentMethodId
        return customOption
    }

    class func buildPaymentData(paymentMethod: PaymentMethod) -> PaymentData {
        let paymentData = PaymentData()
        paymentData.paymentMethod = paymentMethod
        return paymentData
    }

    class func buildPaymentData(paymentMethodId: String, paymentMethodName: String?, paymentMethodTypeId: String?) -> PaymentData {
        let paymentData = PaymentData()
        paymentData.paymentMethod = MockBuilder.buildPaymentMethod(paymentMethodId, name: paymentMethodName, paymentTypeId: paymentMethodTypeId, multipleSettings: false)
        return paymentData
    }

    class func buildPaymentData(paymentMethodId: String = "visa", installments: Int = 0, installmentRate: Double = 0) -> PaymentData {
        let paymentData = PaymentData()
        paymentData.paymentMethod = MockBuilder.buildPaymentMethod(paymentMethodId)
        paymentData.issuer = MockBuilder.buildIssuer()
        paymentData.payerCost = MockBuilder.buildPayerCost(installments: installments, installmentRate: installmentRate)
        paymentData.token = MockBuilder.buildToken()
        return paymentData
    }

    class func buildPayment(_ paymentMethodId: String) -> Payment {
        let payment = Payment()
        payment.paymentMethodId = paymentMethodId
        payment.status = "status"
        payment.statusDetail = "status_detail"
        let payer = MockBuilder.buildPayer("payerid")
        payment.payer = payer
        return payment
    }

    class func buildPaymentResult(_ status: String? = "status", paymentMethodId: String) -> PaymentResult {
        let pm = MockBuilder.buildPaymentMethod(paymentMethodId)
        let paymentData = MockBuilder.buildPaymentData(paymentMethod: pm)
        let paymentResult = PaymentResult(status: status!, statusDetail: "detail", paymentData: paymentData, payerEmail: "email", id: "id", statementDescription: "description")
        return paymentResult
    }

    class func buildInstallment() -> Installment {
        let installment = Installment()
        let payerCost = MockBuilder.buildPayerCost()
        let payerCostNext = MockBuilder.buildPayerCost()
        installment.payerCosts = [payerCost, payerCostNext]
        return installment
    }

    class func buildDiscount() -> DiscountCoupon {
        let discount = DiscountCoupon()
        discount._id = "id"
        discount.amount_off = "20"
        discount.amount = 5
        return discount
    }

    class func buildAddress() -> Address {
        let address = Address(streetName: "street_name", streetNumber: 0, zipCode: "zip_code")
        return address
    }

    class func buildCustomer() -> Customer {
        let customer = Customer()
        customer.cards = [MockBuilder.buildCard(paymentMethodId: "visa")]
        customer.defaultCard = "0"
        customer._description = "description"
        customer.email = "email"
        customer.firstName = "first_name"
        customer.lastName = "last_name"
        customer._id = "id"
        customer.identification = buildIdentification()
        customer.liveMode = true
        customer.address = buildAddress()

        return customer
    }
    
    class func buildApiException(code: String) -> ApiException? {
        
        if code == ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue {
            return buildInvalidIdNumberApiException()
        }
    
        return nil
    }
    
    class func buildInvalidIdNumberApiException() -> ApiException {
        let apiException = ApiException()
        apiException.message = "Invalid cardholder.identification.number: 312322222 in site_id: MLV"
        apiException.error = "bad_request"
        apiException.status = 400
        
        var cause = [Cause]()
        let invalidIdCause = Cause()
        invalidIdCause._description = "Invalid parameter 'cardholder.identification.number'"
        invalidIdCause.code = "324"
        
        cause.append(invalidIdCause)
        apiException.cause = cause
        return apiException
    }

}
