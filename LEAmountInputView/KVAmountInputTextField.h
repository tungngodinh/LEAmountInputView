//
//  KVAmountInputTextField.h
//  KiotViet
//
//  Created by cauca on 11/3/16.
//  Copyright © 2016 Citigo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KVAmountInputTextFieldValueChanged)(double amountValue, BOOL shouldShowDotKey);

@interface KVAmountInputTextField : UITextField

/*!
 * Option show dotkey or double zero key in numpad.
 */
@property (nonatomic, assign) BOOL shouldShowDotKey;

/**
 *  The amount value of the `KVAmountInputTextField`.
 */
@property (nonatomic, assign) double amountValue;

/*!
 * The number formater of the `KVAmountInputTextField` text.
 */
@property (nonatomic, strong) NSNumberFormatter *numberFormater;

/*!
 * The block return amountValue
 */
@property (nonatomic, copy) KVAmountInputTextFieldValueChanged valueChangedBlock;

@end
