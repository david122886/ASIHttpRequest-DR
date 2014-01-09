//
//  ViewController.m
//  ASIHttpRequest
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequestHeader.h"
#import "DownloadDataButton.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)downlBtClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://lms.finance365.com/data/course/6/181/937/20130505173238317.mp4"];
    NSString *fileName = [url lastPathComponent];
    ASIHTTPRequest *  request = [ASIHTTPRequest requestWithLargeDataURL:url];
    
//    NSString *fileName = [[NSURL URLWithString:@"http://lms.finance365.com/data/course/6/181/934/20130507213520063.mp4"] lastPathComponent];
//    ASIHTTPRequest *  request = [ASIHTTPRequest requestWithLargeDataURL:[NSURL URLWithString:@"http://lms.finance365.com/data/course/6/181/934/20130507213520063.mp4"]];
    NSString *path = [[ASIHTTPRequest getLargeFileSavePath] stringByAppendingPathComponent:fileName];
    NSLog(@"%@",path);
    [request setDownloadDestinationPath:path];
    [request setTemporaryFileDownloadPath:[[ASIHTTPRequest getLargeFileTempPath] stringByAppendingPathComponent:fileName]];
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
         NSLog(@"%llu",size);
    }];
    [[ASINetworkQueue defaultDownloadLargeDataQueue] addOperation:request];
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DownloadDataButton *button = [[DownloadDataButton alloc] initWithFrame:(CGRect){20,20,100,44}];
    [self.view addSubview:button];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"下载" forState:UIControlStateNormal];
//    [button setDownloadFileURL:[NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/w%3D2048/sign=ff86e9268882b9013dadc43347b5a877/f3d3572c11dfa9ecba69941660d0f703918fc168.jpg"]];
    NSURL *url = [NSURL URLWithString:@"http://lms.finance365.com/data/course/6/181/937/20130505173238317.mp4"];
    [button setDownloadFileURL:url];
//    NSLog(@"%@",[ASIHTTPRequest getLargeFileTempPath]);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
