//
//  AILoginViewController.m
//  AILoginViewController
//
//  Created by Alexander Ignition on 18.12.14.
//  Copyright (c) 2014 Alexander Ignition. All rights reserved.
//

#import "AILoginViewController.h"

#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface AILoginViewController ()

@property (strong, nonatomic) RACSubject *textFieldReturnPressed;

@end


@implementation AILoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @weakify(self)
    
    
    // Valid UITextField
    
    RACSignal *validUsernameSignal = [self.usernameTextField.rac_textSignal map:^NSNumber *(NSString *text) {
        @strongify(self)
        return @([self isValidUsername:text]);
    }];
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal map:^NSNumber *(NSString *text) {
        @strongify(self)
        return @([self isValidPassword:text]);
    }];
    
    [validUsernameSignal subscribeNext:^(NSNumber *usernameValid) {
        @strongify(self)
        [self textField:self.usernameTextField isValid:usernameValid.boolValue];
    }];
    [validPasswordSignal subscribeNext:^(NSNumber *passwordValid) {
        @strongify(self)
        [self textField:self.passwordTextField isValid:passwordValid.boolValue];
    }];
    
    
    // Valid UITextField for Auth Button
    
    NSArray *validTextFieldSignals = @[validUsernameSignal, validPasswordSignal];
    [[RACSignal combineLatest:validTextFieldSignals reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {
        
        return @(usernameValid.boolValue && passwordValid.boolValue);
        
    }] subscribeNext:^(NSNumber *signupActive) {
        
        @strongify(self)
        self.authButton.enabled = signupActive.boolValue;
    }];
    
    
    // Auth Command
    
    RACCommand *authCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *authButton) {
        
        @strongify(self)
        self.authButton.enabled = NO;
        [self startAuthSignal];
        
        return [[[[self authSignal] doNext:^(id x) {
            
            @strongify(self)
            [self successAuthSignal:x];
            
        }] doError:^(NSError *error) {
            
            @strongify(self)
            [self failureAuthSignal:error];
            
        }] doCompleted:^{
            
            @strongify(self)
            self.authButton.enabled = YES;
            [self stopAuthSignal];
        }];
    }];
    
    
    // Auth Button Action
    
    [[self.authButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [authCommand execute:sender];
    }];
    
    
    // UITextField
    
    self.textFieldReturnPressed = [RACSubject subject];
    
    [self.textFieldReturnPressed subscribeNext:^(UITextField *textField) {
        
        @strongify(self)
        
        UITextField *username = self.usernameTextField;
        UITextField *password = self.passwordTextField;
        
        if ([textField isEqual:username]) {
            [password becomeFirstResponder];
            
        } else if ([textField isEqual:password]) {
            [password resignFirstResponder];
            
            UIButton *authButton = self.authButton;
            if (authButton.enabled == YES) {
                [authCommand execute:authButton];
            }
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textFieldReturnPressed sendNext:textField];
    return YES;
}

#pragma mark - Validation

- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 1;
}

- (void)textField:(UITextField *)textField isValid:(BOOL)valid {
    textField.textColor = (valid) ? [UIColor blackColor] : [[UIColor redColor] colorWithAlphaComponent:0.5];
}

#pragma mark - Authorization

- (RACSignal *)authSignal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text complete:^(BOOL success) {
            [subscriber sendNext:@(success)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(void(^)(BOOL))completeBlock
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        BOOL success = [username isEqualToString:@"user"] && [password isEqualToString:@"password"];
        completeBlock(success);
    });
}

- (void)startAuthSignal {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopAuthSignal {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)successAuthSignal:(id)object {
    NSLog(@"%s object = %@", __PRETTY_FUNCTION__, object);
}

- (void)failureAuthSignal:(NSError *)error {
    NSLog(@"%s error = %@", __PRETTY_FUNCTION__, error);
}

@end
