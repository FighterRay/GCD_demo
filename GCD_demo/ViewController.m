//
//  ViewController.m
//  GCD_demo
//
//  Created by 张润峰 on 16/5/7.
//  Copyright © 2016年 张润峰. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextView *resultsTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ViewController

- (NSString *)fetchSomethingFromServer {
    [NSThread sleepForTimeInterval:1];
    return @"Hello World";
}

- (NSString *)processData:(NSString *)data{
    [NSThread sleepForTimeInterval:1];
    return [data uppercaseString];
}

- (NSString *)calculateFirstResult:(NSString *)data {
    [NSThread sleepForTimeInterval:1];
    return [NSString stringWithFormat:@"\"Hello World\"'s number of chars: %lu", (unsigned long)[data length]];
}

- (NSString *)calculateSecondResult:(NSString *)data {
    [NSThread sleepForTimeInterval:1];
    return [data stringByReplacingOccurrencesOfString:@"E" withString:@"e"];
}

- (IBAction)doWork:(id)sender {
    self.resultsTextView.text = @"";
    NSDate *startTime = [NSDate date];
    self.startButton.enabled = NO;
    [self.spinner startAnimating];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString *fetchedData = [self fetchSomethingFromServer];
        NSString *processedData = [self processData:fetchedData];
        __block NSString *firstResult;
        __block NSString *secondResult;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, queue, ^{
            firstResult = [self calculateFirstResult:processedData];
            NSLog(@"1");
        });
        dispatch_group_async(group, queue, ^{
            secondResult = [self calculateSecondResult:processedData];
            NSLog(@"2");
        });
        dispatch_group_notify(group, queue, ^{
            NSString *resultsSummary = [NSString stringWithFormat:@"First result : \n\t%@\nSecond result : \n\t%@", firstResult, secondResult];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultsTextView.text = resultsSummary;
                self.startButton.enabled = YES;
                [self.spinner stopAnimating];
            });
            NSDate *endTime = [NSDate date];
            NSLog(@"Completed in %f secondes", [endTime timeIntervalSinceDate:startTime]);
        });
    });
}

@end

