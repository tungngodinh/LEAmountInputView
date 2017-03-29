//
//  KVAmountInputTextField.m
//  KiotViet
//
//  Created by cauca on 11/3/16.
//  Copyright © 2016 Citigo. All rights reserved.
//

#import <FontAwesomeKit/FontAwesomeKit.h>

#import "LEAmountInputView.h"
#import "KVAmountInputTextField.h"

@interface KVAmountInputTextField()<LENumberPadDataSource, LENumberPadDelegate>

@property (nonatomic, strong) LENumberPad *numberPad;
@property (nonatomic, strong) NSDate *start;

@end

@implementation KVAmountInputTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    self.inputView = self.numberPad;
    self.text = [self.numberFormater stringFromNumber:@(_amountValue)];
    
    UIButton *clearButton =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    FAKIonIcons *icon = [FAKIonIcons closeCircledIconWithSize:14];
    [icon setAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [clearButton setImage:[icon imageWithSize:CGSizeMake(14, 14)] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(onClearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.rightView = clearButton;
    self.rightView.contentMode = UIViewContentModeCenter;
    self.rightViewMode = UITextFieldViewModeWhileEditing;

}

- (void)onClearButtonTapped:(UIButton *)sender {
    self.amountValue = 0;
    self.text = @"0";
    if (self.valueChangedBlock) {
        self.valueChangedBlock(0, self.shouldShowDotKey);
    }
}

- (NSString *)buttonTitleAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 11) {
        return [[FAKIonIcons backspaceOutlineIconWithSize:25.0] characterCode];
    } else if (indexPath.item == 10) {
        return @"0";
    } else if (indexPath.item == 9) {
        return self.shouldShowDotKey ? @"." : @"000";
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
    if (indextPath.row == 11) {
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
        [self numberPad:self.numberPad didSelectButtonAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]];
        CGFloat elapsed = MAX( 1, fabs( [self.start timeIntervalSinceNow]));
        CGFloat delay = 0.15 / elapsed;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeValueWithButton:button];
        });
    }
}


#pragma mark - LENumberPadDelegate

- (void)numberPad:(LENumberPad *)numberPad didSelectButtonAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.text;
    text = [text stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    if (indexPath.item == 11) {
        if (text.length > 1) {
            text = [text substringToIndex:text.length - 1];
        } else {
            text = @"0";
        }

    } else {
        NSString *stringValue = [self buttonTitleAtIndexPath:indexPath];
        if ([self needAppendText:stringValue intext:text]) {
            text = [text stringByAppendingString:stringValue];
        }
    }
    
    double amount = [[self.numberFormater numberFromString:text] doubleValue];
    if (self.amountValue != amount) {
        self.amountValue = amount;
        if (self.valueChangedBlock) {
            self.valueChangedBlock(self.amountValue, self.shouldShowDotKey);
        }
    } else {
        self.text = text;
    }
}

- (BOOL)needAppendText:(NSString *)stringValue intext:(NSString *)text {
    if (self.shouldShowDotKey) {
        
        if (_amountValue == 100) {
            return NO;
        }
        
        NSInteger length = text.length;
        if ([text containsString:@"."]) {
            NSRange range = [text rangeOfString:@"."];
            if ([stringValue isEqualToString:@"."] || length - range.location == self.numberFormater.maximumFractionDigits + 1) {
                return NO;
            }
        }
        return _amountValue > 0
                || [[self.numberFormater numberFromString:stringValue] boolValue]
                || [stringValue isEqualToString:@"."]
                || length == self.numberFormater.maximumFractionDigits;
    }
    
    return _amountValue > 0 || [[self.numberFormater numberFromString:stringValue] boolValue];
}

#pragma mark - Setter

- (void)setShouldShowDotKey:(BOOL)shouldShowDotKey {
    _shouldShowDotKey = shouldShowDotKey;
    self.numberFormater.maximumFractionDigits = self.shouldShowDotKey ? 2 : 0;
    UIButton *button = [self.numberPad buttonAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0]];
    [button setTitle:_shouldShowDotKey ? @"." : @"000" forState:UIControlStateNormal];
    [button setTitle:_shouldShowDotKey ? @"." : @"000" forState:UIControlStateSelected];
}

- (void)setAmountValue:(double)amountValue {
    if (_amountValue != amountValue) {
        _amountValue = amountValue;
        self.text = [self.numberFormater stringFromNumber:@(_amountValue)];
    }
}

#pragma mark - Getter

- (NSNumberFormatter *)numberFormater {
    if (!_numberFormater) {
        _numberFormater = [[NSNumberFormatter alloc] init];
        _numberFormater.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormater.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormater.decimalSeparator = @".";
        _numberFormater.groupingSeparator = @",";
        _numberFormater.maximumFractionDigits = self.shouldShowDotKey ? 2 : 0;
    }
    return _numberFormater;
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
