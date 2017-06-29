//
//  LEAmountInputViewDemoTests.m
//  LEAmountInputViewDemoTests
//
//  Created by cozo on 6/26/17.
//  Copyright © 2017 Lasha Efremidze. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+NANumberValidation.h"
#import "KVAmountInputTextField.h"

@interface LEAmountInputViewDemoTests : XCTestCase

@property (nonatomic, strong) KVAmountInputTextField *textField;

@end

@implementation LEAmountInputViewDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.textField = [[KVAmountInputTextField alloc] initWithFrame:CGRectZero andInputType:KVAmountInputTextFieldTypeQuantity];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReachMaxIntegerDigits {
    self.textField.type = KVAmountInputTextFieldTypeQuantity;
    NSDictionary *testStrings = @{@"1234567890123" : @(NO),
                                  @"12345678901234" : @(YES),
                                  @"1234567890123.123" : @(NO),
                                  @"1234567890123.2344" : @(YES),
                                  @"12345678901234.234" : @(YES),
                                  @"ABC123" : @(YES),
                                  @"" : @(YES),
                                  @"12,345,678,901,234" : @(YES),
                                  @"1,234,567,890,123.123" : @(NO),
                                  @"1,234,567,890,123.000" : @(NO),
                                  @"1,234,567,890,123.001" : @(NO)};
    for (NSString *key in testStrings.allKeys) {
        BOOL result = [key isInvalidStringForNumberFormatter:self.textField.numberFormatter];
        XCTAssertEqual((int)result, [[testStrings valueForKey:key] integerValue] , @"%@", key);
    }
}

- (void)testNoFractionReachMaxIntegerDigits {
    self.textField.type = KVAmountInputTextFieldTypeCurrency;
    NSDictionary *testStrings = @{@"1234567890123" : @(NO),
                                  @"12345678901234" : @(YES),
                                  @"90123.123" : @(YES),
                                  @"7890123.2344" : @(YES),
                                  @"12345678901234.234" : @(YES),
                                  @"ABC123" : @(YES),
                                  @"12,345,678,901,234" : @(YES),
                                  @"1,234,567,890,123.123" : @(YES),
                                  @"1,234,567,890,123.000" : @(YES),
                                  @"" : @(YES),
                                  @"1,234,567,890,123.001" : @(YES)};
    for (NSString *key in testStrings.allKeys) {
        BOOL result = [key isInvalidStringForNumberFormatter:self.textField.numberFormatter];
        XCTAssertEqual((int)result, [[testStrings valueForKey:key] integerValue] , @"%@", key);
    }
}

- (void)testPercentageReachMaxIntegerDigits {
    self.textField.type = KVAmountInputTextFieldTypePercentage;
    NSDictionary *testStrings = @{@"123" : @(NO),
                                  @"9999" : @(YES),
                                  @"99.123" : @(YES),
                                  @"99.13" : @(NO),
                                  @"" : @(YES),
                                  @"#$=" : @(YES),
                                  @"AB" : @(YES)};
    for (NSString *key in testStrings.allKeys) {
        BOOL result = [key isInvalidStringForNumberFormatter:self.textField.numberFormatter];
        XCTAssertEqual((int)result, [[testStrings valueForKey:key] integerValue] , @"%@", key);
    }
}

- (void)testAmounTextField {
    
    self.textField.type = KVAmountInputTextFieldTypeQuantity;
    XCTAssertEqual( [self.textField.numberFormatter numberFromString:@"9,999,999,999,999.999"].doubleValue, 9999999999999.999 , @"%@", self.textField.amount);
    NSDictionary *testStrings = @{@"9,999,999,999,999.999" : [NSNumber numberWithDouble:9999999999999.999],
                                  @"999,999,999,999.999" :  [NSNumber numberWithDouble:999999999999.999]};
    for (NSString *key in testStrings.allKeys) {
        XCTAssertEqual( [self.textField.numberFormatter numberFromString:key].doubleValue, [[testStrings valueForKey:key] doubleValue] , @"%@", self.textField.amount);
    }
}

- (void)testdecimalNumberTextField {

    NSDecimalNumberHandler *round = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:NO];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:[@"9,999,999,999,999.9999" stringByReplacingOccurrencesOfString:@"," withString:@""]];
    NSNumber *number = (NSNumber *)[decimalNumber decimalNumberByRoundingAccordingToBehavior:round];
    XCTAssertEqual(number.doubleValue, 9999999999999.999);
    
}
@end
