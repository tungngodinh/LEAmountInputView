//
//  KVAmountInputTextField.m
//  KiotViet
//
//  Created by cauca on 11/3/16.
//  Copyright © 2016 Citigo. All rights reserved.
//

#import <FontAwesomeKit/FontAwesomeKit.h>

#import "LENumberPad.h"
#import "KVAmountInputTextField.h"

#define NA_BACKSPACE_BUTTON_INDEX 11
#define NA_DOT_OR_THOUDSAND_BUTTON_INDEX 9

@interface KVAmountInputTextField()<LENumberPadDataSource, LENumberPadDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) LENumberPad *numberPad;

@end

@implementation KVAmountInputTextField

@synthesize delegate;

- (instancetype)initWithFrame:(CGRect)frame andInputType:(KVAmountInputTextFieldType)type {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpViewWithInputType:type];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder andInputType:(KVAmountInputTextFieldType)type {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpViewWithInputType:type];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpViewWithInputType:KVAmountInputTextFieldTypeCurrency];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpViewWithInputType:KVAmountInputTextFieldTypeCurrency];
    }
    return self;
}

- (void)setUpViewWithInputType:(KVAmountInputTextFieldType)type {
    self.inputView = self.numberPad;
    self.text = [self.numberFormatter stringFromNumber:self.amount];
    self.type = type;
    super.delegate = self;
}

- (NSString *)buttonTitleAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == NA_BACKSPACE_BUTTON_INDEX) {
        return [[FAKIonIcons backspaceOutlineIconWithSize:25.0] characterCode];
    } else if (indexPath.item == 10) {
        return @"0";
    } else if (indexPath.item == NA_DOT_OR_THOUDSAND_BUTTON_INDEX) {
        switch (self.type) {
            case KVAmountInputTextFieldTypePercentage:
            case KVAmountInputTextFieldTypeQuantity:
                return self.numberFormatter.decimalSeparator;
            case KVAmountInputTextFieldTypeCurrency:
                return @"000";
            default:
                break;
        }
    }
    return [NSString stringWithFormat:@"%d", (int)indexPath.item + 1];
}

#pragma mark - LENumberPadDataSource

- (NSInteger)numberOfColumnsInNumberPad:(LENumberPad *)numberPad {
    return 3;
}

- (NSInteger)numberOfRowsInNumberPad:(LENumberPad *)numberPad {
    return 4;
}

- (NSString *)numberPad:(LENumberPad *)numberPad buttonTitleForButtonAtIndexPath:(NSIndexPath *)indexPath {
    return [self buttonTitleAtIndexPath:indexPath];
}

- (UIColor *)numberPad:(LENumberPad *)numberPad buttonTitleColorForButtonAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor colorWithWhite:0.3f alpha:1.0f];
}

- (UIFont *)numberPad:(LENumberPad *)numberPad buttonTitleFontForButtonAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 11) {
        return [FAKIonIcons iconFontWithSize:24];
    }
    return [UIFont fontWithName:@"HelveticaNeue" size:24];
}

- (UIColor *)numberPad:(LENumberPad *)numberPad buttonBackgroundColorForButtonAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor whiteColor];
}

- (UIColor *)numberPad:(LENumberPad *)numberPad buttonBackgroundHighlightedColorForButtonAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor colorWithWhite:0.9f alpha:1.0f];
}

- (nullable SEL)numberPad:(LENumberPad *)numberPad touchDownActionForButtonAtIndexPath:(NSIndexPath *)indextPath {
    if (indextPath.row == NA_BACKSPACE_BUTTON_INDEX) {
        return @selector(onBackSpaceButtonTouchDown:);
    }
    return nil;
}

- (void)onBackSpaceButtonTouchDown:(UIButton *)sender {
    self.start = [NSDate date];
    [self changeValueWithButton:sender];
}

- (void)changeValueWithButton:(UIButton *)button {
    if (button.state != UIControlStateNormal ) {
        [self numberPad:self.numberPad didSelectButtonAtIndexPath:[NSIndexPath indexPathForRow:NA_BACKSPACE_BUTTON_INDEX
                                                                                     inSection:0]];
        CGFloat elapsed = MAX( 1, fabs( [self.start timeIntervalSinceNow]));
        CGFloat delay = 0.15 / elapsed;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeValueWithButton:button];
        });
    }
}


#pragma mark - LENumberPadDelegate

- (void)numberPad:(LENumberPad *)numberPad didSelectButtonAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *amount = @0;
    NSString *text = self.text;
    
    text = [text stringByReplacingOccurrencesOfString:self.numberFormatter.groupingSeparator withString:@""];
    
    if (indexPath.item == NA_BACKSPACE_BUTTON_INDEX) {
        if (text.length > 1) {
            text = [text substringToIndex:text.length - 1];
            amount = [self.numberFormatter numberFromString:text];
        } else {
            amount = nil;
        }
        
    } else if (indexPath.item == NA_DOT_OR_THOUDSAND_BUTTON_INDEX && [self shouldShowDot]) {
        if (![self.text containsString:self.numberFormatter.decimalSeparator]) {
            self.text = [self.text stringByAppendingString:self.numberFormatter.decimalSeparator];
        }
        return;
    } else {
        UIButton *button = [numberPad buttonAtIndexPath:indexPath];
        NSMutableString *string = [NSMutableString stringWithString:text];
        [string appendString:button.titleLabel.text];
        amount = [self.numberFormatter numberFromString:string];
        if (self.type == KVAmountInputTextFieldTypePercentage) {
            if ([amount doubleValue] > 100) {
                amount = @100;
            }
        }
        if (![self shouldChangeAmount:amount]) {
            return;
            
        }
    }
    self.amount = amount;
    [self didChangeAmount:amount];
}

#pragma mark - privates

- (BOOL)shouldShowDot {
    return self.type == KVAmountInputTextFieldTypeQuantity ||
    (self.type == KVAmountInputTextFieldTypePercentage && [self.amount doubleValue] < 100);
}

- (void)configDotOrThousandButton {
    UIButton *button = [self.numberPad buttonAtIndexPath:[NSIndexPath indexPathForRow:NA_DOT_OR_THOUDSAND_BUTTON_INDEX
                                                                            inSection:0]];
    if (self.type == KVAmountInputTextFieldTypePercentage ||
        self.type == KVAmountInputTextFieldTypeQuantity) {
        [button setTitle:self.numberFormatter.decimalSeparator forState:UIControlStateNormal];
        [button setTitle:self.numberFormatter.decimalSeparator forState:UIControlStateSelected];
    } else {
        [button setTitle:@"000" forState:UIControlStateNormal];
        [button setTitle:@"000" forState:UIControlStateSelected];
    }
}

- (BOOL)shouldChangeAmount:(NSNumber *)amount {
    // delegate is assigned
    if (self.delegate && [self.delegate respondsToSelector:@selector(textField:shouldChangeAmount:)]) {
        return [self.delegate textField:self shouldChangeAmount:self.amount];
    }
    switch (self.type) {
        case KVAmountInputTextFieldTypeCurrency:
            return YES;
            break;
        case KVAmountInputTextFieldTypeQuantity:
            return ![self reachMaximumFractionDigitsCharacters:self.text];
        case KVAmountInputTextFieldTypePercentage:
            return ![self reachMaximumFractionDigitsCharacters:self.text];
        default:
            break;
    }
    return NO;
}

- (BOOL)reachMaximumFractionDigitsCharacters:(NSString *)text {
    if ([text containsString:self.numberFormatter.decimalSeparator]) {
        NSRange range = [text rangeOfString:self.numberFormatter.decimalSeparator];
        if ([text isEqualToString:self.numberFormatter.decimalSeparator] ||
            text.length - range.location < self.numberFormatter.maximumFractionDigits + 1) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (void)didChangeAmount:(NSNumber *)amount
{
    if ([delegate respondsToSelector:@selector(textField:didChangeAmount:)]) {
        [delegate textField:self didChangeAmount:amount];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.resetToZeroIfCleared) {
        self.amount = @0;
        [self didChangeAmount:self.amount];
        return NO;
    } else {
        self.amount = nil;
        [self didChangeAmount:self.amount];
        if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
            return [self.delegate textFieldShouldClear:textField];
        }
        return NO;
    }
}

#pragma mark - Setter

- (void)setAmount:(NSNumber *)amount {
    if (amount) {
        self.text = [self.numberFormatter stringFromNumber:amount];
    } else {
        self.text = self.resetToZeroIfCleared ? @"0" : nil;
    }
}

- (void)setType:(KVAmountInputTextFieldType)type {
    _type = type;
    switch (type) {
        case KVAmountInputTextFieldTypeCurrency:
            _numberFormatter.maximumFractionDigits = 0;
            break;
        case KVAmountInputTextFieldTypeQuantity:
            _numberFormatter.maximumFractionDigits = 3;
            break;
        case KVAmountInputTextFieldTypePercentage:
            _numberFormatter.maximumFractionDigits = 2;
            break;
        default:
            break;
    }
    [self configDotOrThousandButton];
}

#pragma mark - Getter

- (NSNumber *)amount {
    return [self.numberFormatter numberFromString:self.text];
}

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.roundingMode = kCFNumberFormatterRoundUp;
        _numberFormatter.decimalSeparator = @".";
        _numberFormatter.groupingSeparator = @",";
    }
    return _numberFormatter;
}

- (LENumberPad *)numberPad {
    if (!_numberPad) {
        _numberPad = [[LENumberPad alloc] initWithFrame:CGRectZero];
        _numberPad.translatesAutoresizingMaskIntoConstraints = NO;
        _numberPad.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
        _numberPad.layer.borderWidth = 1.0f;
        _numberPad.dataSource = self;
        _numberPad.delegate = self;
    }
    return _numberPad;
}

@end
