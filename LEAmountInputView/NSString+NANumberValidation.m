//
//  KVValidationString.m
//  LEAmountInputViewDemo
//
//  Created by cozo on 6/26/17.
//  Copyright © 2017 Lasha Efremidze. All rights reserved.
//

#import "NSString+NANumberValidation.h"

@implementation NSString (KVValidationString)

- (BOOL)isInvalidStringForNumberFormatter:(NSNumberFormatter *)numberFormatter {
    if ([numberFormatter numberFromString:self] == nil) {
        return YES;
    }
    NSString *text = [self stringByReplacingOccurrencesOfString:[numberFormatter groupingSeparator] withString:@""];
    if (numberFormatter.maximumFractionDigits == 0 && [text containsString:@"."]) {
        return YES;
    } else if (([text containsString:@"."] && text.length > (numberFormatter.maximumIntegerDigits + numberFormatter.maximumFractionDigits + 1)) ||
        (![text containsString:@"."] && text.length > numberFormatter.maximumIntegerDigits)) {
        return YES;
    } else if ([text containsString:@"."]) {
        NSRange range = [self rangeOfString:numberFormatter.decimalSeparator];
        return self.length - (range.location + 1) > numberFormatter.maximumFractionDigits;
    }
    return NO;
}
@end
