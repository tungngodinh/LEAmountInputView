//
//  KVValidationString.h
//  LEAmountInputViewDemo
//
//  Created by cozo on 6/26/17.
//  Copyright © 2017 Lasha Efremidze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KVValidationString)

- (BOOL)isInvalidStringForNumberFormatter:(NSNumberFormatter *)numberFormatter;

@end
