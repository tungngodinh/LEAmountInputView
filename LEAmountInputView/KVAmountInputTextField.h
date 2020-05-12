//
//  KVAmountInputTextField.h
//  KiotViet
//
//  Created by cauca on 11/3/16.
//  Copyright © 2016 Citigo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    KVAmountInputTextFieldTypePercentage,
    KVAmountInputTextFieldTypeCurrency,
    KVAmountInputTextFieldTypeCurrencyUsingDecimal,
    KVAmountInputTextFieldTypeQuantity,
} KVAmountInputTextFieldType;

typedef void (^KVAmountInputTextFieldValueChanged)(NSNumber * amountValue);

@class KVAmountInputTextField;

/**
 *  The LEAmountInputTextFieldDelegate protocol defines the amount messages sent to a text field delegate. All of the methods of this protocol are optional.
 *
 *  Inherits from UITextFieldDelegate.
 */
@protocol KVAmountInputTextFieldDelegate <UITextFieldDelegate>

@optional

/**
 *  Asks the delegate whether the amount should be changed.
 *
 *  If you do not implement this method, the default return value is YES.
 *
 *  @param textField The text field object that is asking whether the amount should change.
 *  @param amount    The new amount.
 *
 *  @return YES if the amount should be changed or NO if it should not.
 */
- (BOOL)textField:(KVAmountInputTextField *)textField shouldChangeAmount:(NSNumber *)amount;

/**
 *  Tells the delegate that the amount changed. It does not call this method when you programmatically set the amount.
 *
 *  If you do not implement this method, the default return value is depend on the `type`.
 *  @param textField The text field object that is notifying you of the change.
 *  @param amount    The amount that was changed.
 */
- (void)textField:(KVAmountInputTextField *)textField didChangeAmount:(NSNumber *)amount;

/**
 *Summary
 *  Tells the delegate that editing stopped for the specified text field.
 *Discussion
 *  This method is called after the text field resigns its first responder status. You can use this method to update your delegate’s state information. For example, you might use this method to hide overlay views that should be visible only while editing.
 *  Implementation of this method by the delegate is optional. If your delegate also implements the textFieldDidEndEditing:reason: method, UIKit calls that method in preference to this one.
 */
- (void)textFieldDidEndEditing:(KVAmountInputTextField *)textField;

@end

@interface KVAmountInputTextField : UITextField

@property (nonatomic, assign) KVAmountInputTextFieldType type;

@property (nonatomic, weak) id<KVAmountInputTextFieldDelegate> delegate;

/**
 *  The amount value of the `KVAmountInputTextField`.
 *  This value is nulable depend on type.
 */
@property (nonatomic, strong) NSNumber *amount;
/**
 * Maximum of integer digit, default is 13
 */
@property (nonatomic, assign) NSUInteger maximumIntegerDigits;
/*!
 * The number formater of the `KVAmountInputTextField` text.
 * Default is format for currency number
 */
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

/**
 *  No value display text, orrcu clear textfield
 */
@property (nonatomic, assign) BOOL resetToZeroIfCleared;

/*!
 * The block return amountValue
 */
@property (nonatomic, copy) KVAmountInputTextFieldValueChanged valueChangedBlock;

- (instancetype)initWithFrame:(CGRect)frame andInputType:(KVAmountInputTextFieldType)type;
- (instancetype)initWithCoder:(NSCoder *)aDecoder andInputType:(KVAmountInputTextFieldType)type;



@end
