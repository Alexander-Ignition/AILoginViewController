//
//  AILoginViewController.h
//  AILoginViewController
//
//  Created by Alexander Ignition on 18.12.14.
//  Copyright (c) 2014 Alexander Ignition. All rights reserved.
//

@import UIKit;

@class RACSignal;

@interface AILoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *authButton;

- (BOOL)isValidUsername:(NSString *)username;
- (BOOL)isValidPassword:(NSString *)password;

- (void)textField:(UITextField *)textField isValid:(BOOL)valid;

- (RACSignal *)authSignal;

- (void)startAuthSignal;
- (void)stopAuthSignal;

- (void)successAuthSignal:(id)object;
- (void)failureAuthSignal:(NSError *)error;

@end
