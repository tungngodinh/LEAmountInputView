//
//  ViewController.m
//  LEAmountInputViewDemo
//
//  Created by Lasha Efremidze on 5/3/15.
//  Copyright (c) 2015 Lasha Efremidze. All rights reserved.
//

#import "ViewController.h"
#import "KVAmountInputTextField.h"

@interface ViewController () <KVAmountInputTextFieldDelegate>
@property (weak, nonatomic) IBOutlet KVAmountInputTextField *kvAmountTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;
@property (weak, nonatomic) IBOutlet UITextField *noValueDisplayTextField;
@property (weak, nonatomic) IBOutlet UILabel *resetToZeroLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.kvAmountTextField.delegate = self;
}

- (IBAction)amounTextFieldTypeChange:(id)sender {
    switch (self.typeSegment.selectedSegmentIndex) {
        case 0:
            [self.kvAmountTextField setType:KVAmountInputTextFieldTypeCurrency];
            break;
        case 1:
            [self.kvAmountTextField setType:KVAmountInputTextFieldTypePercentage];
            break;
        case 2:
            [self.kvAmountTextField setType:KVAmountInputTextFieldTypeQuantity];
        default:
            break;
    }
}

- (IBAction)resetToZero:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    self.kvAmountTextField.resetToZeroIfCleared = switchView.on;
    self.resetToZeroLabel.textColor = switchView.on ? self.view.tintColor : [UIColor lightGrayColor];
}

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
/*- (BOOL)textField:(KVAmountInputTextField *)textField shouldChangeAmount:(NSNumber *)amount {
    
}*/

/**
 *  Tells the delegate that the amount changed. It does not call this method when you programmatically set the amount.
 *
 *  If you do not implement this method, the default return value is depend on the `type`.
 *  @param textField The text field object that is notifying you of the change.
 *  @param amount    The amount that was changed.
 */
- (void)textField:(KVAmountInputTextField *)textField didChangeAmount:(NSNumber *)amount {
    NSLog(@"%@",amount);
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}
@end
