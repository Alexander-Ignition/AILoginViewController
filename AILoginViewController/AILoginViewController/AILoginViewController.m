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

@implementation AILoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @weakify(self)
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
    
    NSArray *validTextFieldSignals = @[validUsernameSignal, validPasswordSignal];
    [[RACSignal combineLatest:validTextFieldSignals reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {
        return @([usernameValid boolValue] && [passwordValid boolValue]);
    }] subscribeNext:^(NSNumber *signupActive) {
        @strongify(self)
        self.authButton.enabled = [signupActive boolValue];
    }];
    
    
    [[[[self.authButton rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        
        @strongify(self)
        self.authButton.enabled = NO;
        [self startAuthSignal];
        
    }] flattenMap:^RACSignal *(id value) {
        
        @strongify(self)
        return [self authSignal];
        
    }] subscribeNext:^(NSNumber *signedIn) {
        
        @strongify(self)
        [self successAuthSignal:nil];
        
    } error:^(NSError *error) {
        
        @strongify(self)
        [self failureAuthSignal:nil];
        
    } completed:^{
        
        @strongify(self)
        self.authButton.enabled = YES;
        [self stopAuthSignal];
    }];
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

- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(void(^)(BOOL))completeBlock {
    
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
