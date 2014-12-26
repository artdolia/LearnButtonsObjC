//
//  ADViewController.m
//  L25_buttons_calculator
//
//  Created by A D on 1/20/14.
//  Copyright (c) 2014 AD. All rights reserved.
//

#import "ADViewController.h"

@interface ADViewController ()

@property (strong, nonatomic) NSArray *offGreetings;
@property (assign, nonatomic) CGFloat result;
@property (strong, nonatomic) NSMutableString *detailedResultString;    //string to display in details (upper) label
@property (strong, nonatomic) NSMutableString *resultString;             //string to display in main result view (lower)
@property (assign, nonatomic) NSInteger lastInput;                      //flag to limit double operator input and to limit backspace actions
@property (assign, nonatomic) NSInteger mathOperation;
@property (assign, nonatomic) BOOL numberWithDecimal;

@end

typedef enum {
    ButtonTypeClear     = 12,
    ButtonTypeDelete    = 13,
    ButtonTypeMultiply  = 14,
    ButtonTypeDevide    = 15,
    ButtonTypeSubstract = 16,
    ButtonTypeAdd       = 17,
    ButtonTypeEqual     = 18,
    ButtonTypeDPoint    = 19
}ButtonType;

typedef enum{
    LastInputDecimalPoint   = 1 << 0,
    LastInputNumber         = 1 << 1,
    LastInputOperator       = 1 << 2,
    LastInputEqual          = 1 << 3
}LastInput;

typedef enum{
    
    MathOperationEmpty      = 1 << 0,
    MathOperationMultiply   = 1 << 1,
    MathOperationDevide     = 1 << 2,
    MathOperationSubstract  = 1 << 3,
    MathOperationAdd        = 1 << 4
    
}MathOperation;

@implementation ADViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetResultViews];
    
    self.mathOperation = MathOperationEmpty;
    
    self.resultString = [NSMutableString string];
    self.detailedResultString = [NSMutableString string];

    self.offGreetings = [NSArray arrayWithObjects:@"В столбик пробовал?", @"Не дай убить талант математика!", @"Пожалей батарейку!", nil];
    
    for(UIButton *button in self.buttonsOutletCollection){
        
        if(button.tag > 0 && button.tag <= 10){
            
            button.backgroundColor = [UIColor yellowColor];
        }else{
            
            button.backgroundColor = [UIColor greenColor];
        }

        button.layer.cornerRadius = CGRectGetHeight(button.bounds) / 2;
        button.layer.borderColor = ([UIColor blackColor].CGColor);
        button.layer.borderWidth = 1.f;
    }
    
    self.resultWindowView.layer.borderWidth = 1.5f;
    self.resultWindowView.layer.cornerRadius = 2.f;
    self.resultWindowView.layer.borderColor = ([UIColor blackColor].CGColor);
}


#pragma mark - Actions

- (IBAction)touchDownButtonAction:(UIButton *)sender {

    //switch is On and number input is allowed
    if(self.onOffSwitch.isOn && self.lastInput != LastInputEqual && sender.tag > 0  && sender.tag < 12){

        [self numberButtonAction:sender];
    
    //switch is Off
    }else if (!self.onOffSwitch.isOn){
        
        self.upperLabel.text = [self.offGreetings objectAtIndex:(int)(arc4random()%3)];
        self.lowerLabel.text = [NSString stringWithFormat:@""];
    
    //operator button pressed
    }else {
        
        [self operatorButtonAction:sender];
    }
}


- (void) operatorButtonAction:(UIButton *) button{
    
    NSString *tmpString = [NSString string];
    
    if(button.tag == ButtonTypeClear){
        
        [self resetResultViews];
    
    }else if(button.tag == ButtonTypeDelete){
        
        if ((self.lastInput == LastInputNumber || self.lastInput == LastInputDecimalPoint) && [self.resultString length] > 0) {
        
            [self.detailedResultString deleteCharactersInRange:NSMakeRange([self.detailedResultString length] - 1, 1)];
            self.upperLabel.text = self.detailedResultString;
            
            [self.resultString deleteCharactersInRange:NSMakeRange([self.resultString length] - 1, 1)];
            self.lowerLabel.text = self.resultString;
            
            if ([self.resultString length] == 0) {
                self.lowerLabel.text = [NSMutableString stringWithFormat:@"0"];
            }
        }
    
    }else if(button.tag == ButtonTypeEqual && self.lastInput != LastInputOperator &&
             self.mathOperation != MathOperationEmpty && self.lastInput != LastInputEqual){
        
        [self calculateResult];
        
        if(self.numberWithDecimal || self.mathOperation == MathOperationDevide){
            
            tmpString = [NSString stringWithFormat:@" = %.2f", self.result];
            self.lowerLabel.text = [NSMutableString stringWithFormat:@"%.2f", self.result];
            
        }else{
            
            tmpString = [NSString stringWithFormat:@" = %.0f", self.result];
            self.lowerLabel.text = [NSMutableString stringWithFormat:@"%.0f", self.result];
        }
        
        [self.detailedResultString appendString: tmpString];
        self.upperLabel.text = self.detailedResultString;
        
        self.lastInput = LastInputEqual;
        
    }else if(self.lastInput != LastInputOperator){
        
        [self handleButtonWithTag:button.tag];
    }
}


- (void) handleButtonWithTag:(NSInteger) buttonTag{
    
    //the operator button pressed first time
    if(self.mathOperation == MathOperationEmpty){
        
        //append the operator to the text of the upper view
        [self setTheOperatorAndAppendToUpperLabelForTag:buttonTag];
        self.upperLabel.text = self.detailedResultString;
        
        //store the string typed so far as a result
        self.result = [self.resultString floatValue];
        
    //operator is in place and it is not "Equal"
    }else if(self.mathOperation != MathOperationEmpty && buttonTag != ButtonTypeEqual && self.lastInput != LastInputEqual){
        
        NSLog(@" != equal");
        
        [self calculateResult];
        
        //self.upperLabel.text = [NSMutableString stringWithFormat:@""];
        
        if(self.numberWithDecimal || self.mathOperation == MathOperationDevide){
            
            self.detailedResultString = [NSMutableString stringWithFormat:@"%.2f", self.result];
            //self.lowerLabel.text = [NSMutableString stringWithFormat:@"%.2f", self.result];
        }else{
            self.detailedResultString = [NSMutableString stringWithFormat:@"%.0f", self.result];
            //self.lowerLabel.text = [NSMutableString stringWithFormat:@"%.0f", self.result];
        
        }
        
        [self setTheOperatorAndAppendToUpperLabelForTag:buttonTag];
        self.upperLabel.text = self.detailedResultString;
    
    //the result was calculated with "Equal" button
    }else if(self.lastInput == LastInputEqual && buttonTag != ButtonTypeEqual){
        
        //self.detailedResultString = [NSMutableString stringWithFormat:@""];
        
        
        if(self.numberWithDecimal || self.mathOperation == MathOperationDevide){
            
            self.detailedResultString = [NSMutableString stringWithFormat:@"%.2f", self.result];
            //self.lowerLabel.text = [NSMutableString stringWithFormat:@""]; //%.2f", self.result];
        }else{
            
            NSLog(@"result = %f", self.result);
            
            self.detailedResultString = [NSMutableString stringWithFormat:@"%.0f", self.result];
            //self.lowerLabel.text = [NSMutableString stringWithFormat:@""];//, self.result];
        }

        NSLog(@"afterEqual = %@", self.upperLabel.text);
        [self setTheOperatorAndAppendToUpperLabelForTag:buttonTag];
        self.upperLabel.text = self.detailedResultString;
    }
    
    self.resultString = [NSMutableString stringWithFormat:@""];
    self.lowerLabel.text = self.resultString;
    self.lastInput = LastInputOperator;
    //self.mathOperation = MathOperationMultiply;
}


- (void) numberButtonAction:(UIButton *) button{
    
    if (button.tag == 11 && self.lastInput != LastInputDecimalPoint) {
    
        [self.resultString appendString:@"."];
        [self.detailedResultString appendString:@"."];
        self.lastInput = LastInputDecimalPoint;
        self.numberWithDecimal = YES;
   
    }else if (button.tag != 11 && button.tag != 10){
        
        [self.resultString appendString:[NSString stringWithFormat:@"%ld", (long)button.tag]];
        [self.detailedResultString appendString:[NSString stringWithFormat:@"%ld", (long)button.tag]];
        self.lastInput = LastInputNumber;
    
    }else if (button.tag == 10){
        
        [self.resultString appendString:@"0"];
        [self.detailedResultString appendString:@"0"];
        self.lastInput = LastInputNumber;
    }

    self.lowerLabel.text = self.resultString;
    self.upperLabel.text = self.detailedResultString;
}


- (IBAction)onOfSwitchAction:(UISwitch *)sender {

    [self resetResultViews];
}


#pragma mark - Private Methods

- (void) setTheOperatorAndAppendToUpperLabelForTag:(NSInteger) buttonTag{
    
    //append the operator to the text of the upper view
    if (buttonTag == ButtonTypeMultiply) {
        
        [self.detailedResultString appendString:[NSString stringWithFormat:@" x "]];
        self.mathOperation = MathOperationMultiply;
        
    }else if(buttonTag == ButtonTypeSubstract){
        
        [self.detailedResultString appendString:[NSString stringWithFormat:@" - "]];
        self.mathOperation = MathOperationSubstract;
        
    }else if(buttonTag == ButtonTypeDevide){
        
        [self.detailedResultString appendString:[NSString stringWithFormat:@" / "]];
        self.mathOperation = MathOperationDevide;
        
    }else if(buttonTag == ButtonTypeAdd){
        
        [self.detailedResultString appendString:[NSString stringWithFormat:@" + "]];
        self.mathOperation = MathOperationAdd;
    }
}


- (void) resetResultViews{
    
    self.upperLabel.text = [NSString stringWithFormat:@""];
    self.lowerLabel.text = self.onOffSwitch.isOn ? [NSString stringWithFormat:@"0"]: [NSString stringWithFormat:@""];
    self.result = 0.f;
    self.mathOperation = MathOperationEmpty;
    
    self.detailedResultString = [NSMutableString stringWithFormat:@""];
    self.resultString = [NSMutableString stringWithFormat:@""];
    self.numberWithDecimal = NO;
    self.lastInput = 0;
}
- (void) calculateResult{

    if (self.mathOperation == MathOperationAdd) {
        
        self.result += [self.resultString floatValue];
        
    }else if(self.mathOperation == MathOperationMultiply) {
        
        self.result *= [self.resultString floatValue];
        
    }else if(self.mathOperation == MathOperationDevide) {
    
        self.result /= [self.resultString floatValue];
        
        
    }else if(self.mathOperation == MathOperationSubstract) {
        
        self.result -= [self.resultString floatValue];
    }
    
}

@end
