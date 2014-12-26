//
//  ADViewController.h
//  L25_buttons_calculator
//
//  Created by A D on 1/20/14.
//  Copyright (c) 2014 AD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOutletCollection;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) IBOutlet UIView *resultWindowView;

- (IBAction)touchDownButtonAction:(UIButton *)sender;
- (IBAction)onOfSwitchAction:(UISwitch *)sender;

@end
