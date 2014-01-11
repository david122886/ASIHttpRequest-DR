//
//  DownloadDataButton.m
//  ASIHttpRequest
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "DownloadDataButton.h"

@interface DownloadDataButton()
@property (nonatomic,assign) long long fileTotalSize;
@property (nonatomic,strong) UIProgressView *progressView;
@property (strong,nonatomic) NSURL *downloadFileURL;//下载文件的地址
@property (assign,nonatomic) BOOL isPostNotification;//设置是否有通知事件
@property (strong,nonatomic) UIAlertView *alert;
@end

@implementation DownloadDataButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)addTargetMethod{
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.progressView.frame = (CGRect){0,CGRectGetHeight(self.frame)-3,CGRectGetWidth(self.frame),5};
    [self addTarget:self action:@selector(downloadBtClicked) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDateProgress:) name:DownloadDataButton_Notification_Progress object:nil];
}

-(void)setDownloadUrl:(NSURL*)url withDownloadStatus:(DownloadDataButtonStatus)status withIsPostNotification:(BOOL)isPost{
    NSArray *arr = [[ASINetworkQueue defaultDownloadLargeDataQueue] operations];
    NSLog(@"%d",[arr count]);
    [self addTargetMethod];
    self.downloadFileStatus = status;
    if (self.downloadFileURL &&  ![self.downloadFileURL.absoluteString isEqualToString:url.absoluteString]) {
        [self pauseDownloadData];
        self.downloadFileStatus = DownloadDataButtonStatus_Pause;
    }
    self.downloadFileURL = url;
    self.isPostNotification = isPost;
}

-(void)updateDateProgress:(NSNotification*)notification{
    if ([[notification.userInfo objectForKey:URLKey] isEqualToString:self.downloadFileURL.absoluteString]) {
        NSNumber *size = [notification.userInfo objectForKey:URLReceiveDataSize];
        NSNumber *total = [notification.userInfo objectForKey:URLTotalDataSize];
        double value = (double)size.longLongValue/total.longLongValue;
        self.progressView.progress = value;
        NSLog(@"%@:%0.4f,%llu,%llu",self.downloadFileURL.absoluteString,value,size.longLongValue,total.longLongValue);
    }
}

-(void)startDownloadData{
    ASIHTTPRequest *que = [self getRequestFromQueueWithInfo:self.downloadFileURL.absoluteString];
    if (que) {
        return;
    }
    self.downloadFileStatus = DownloadDataButtonStatus_Downloading;
    NSString *fileName = [self.downloadFileURL lastPathComponent];
    NSString *path = [[ASIHTTPRequest getLargeFileSavePath] stringByAppendingPathComponent:fileName];
    _localPath = path;
    if (self.isPostNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_DidStartDownload object:nil userInfo:@{URLKey: self.downloadFileURL.absoluteString,URLLocalPath:path}];
    }
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithLargeDataURL:self.downloadFileURL];
    [request setDownloadDestinationPath:path];
    [request setTemporaryFileDownloadPath:[[ASIHTTPRequest getLargeFileTempPath] stringByAppendingPathComponent:fileName]];
//    __weak DownloadDataButton *weakSelf = self;
//    __weak NSString *url = self.downloadFileURL.absoluteString;
//    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
//        DownloadDataButton *tempSelf = weakSelf;
//        NSString *tempUrl = url;
//        if (tempSelf && tempSelf.isPostNotification) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_Progress object:nil userInfo:@{URLKey: tempUrl,URLReceiveDataSize:[NSNumber numberWithLongLong:size],URLTotalDataSize:[NSNumber numberWithLongLong:total]}];
//        }
//        NSLog(@"%@,%llu,%llu",tempUrl,size,total);
//    }];
    [request setDownloadProgressDelegate:self.progressView];
    [request setDidFinishSelector:@selector(requestDidFinished:)];
    [request setDidFailSelector:@selector(requestDidFailure:)];
    [request setDelegate:self];
    NSLog(@"%@",self.localPath);
    [[ASINetworkQueue defaultDownloadLargeDataQueue] addOperation:request];
}

-(void)continueDownloadData{
    ASIHTTPRequest *request = [self getRequestFromQueueWithInfo:self.downloadFileURL.absoluteString];
    if (request) {
        self.downloadFileStatus = DownloadDataButtonStatus_Downloading;
        return;
    }else{
        [self startDownloadData];
    }
}

-(void)pauseDownloadData{
    self.downloadFileStatus = DownloadDataButtonStatus_Pause;
    ASIHTTPRequest *request = [self getRequestFromQueueWithInfo:self.downloadFileURL.absoluteString];
    if (request) {
        [request setDelegate:nil];
        [request clearDelegatesAndCancel];
    }
    if (self.isPostNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_Pause object:nil userInfo:@{URLKey: self.downloadFileURL.absoluteString,URLLocalPath:self.localPath}];
    }
}

-(void)cancelDownloadData{
    ASIHTTPRequest *request = [self getRequestFromQueueWithInfo:self.downloadFileURL.absoluteString];
    if (request) {
        [request setDelegate:nil];
        [request clearDelegatesAndCancel];
    }
}


-(ASIHTTPRequest*)getRequestFromQueueWithInfo:(NSString*)info{
    ASINetworkQueue *queue = [ASINetworkQueue defaultDownloadLargeDataQueue];
    for (ASIHTTPRequest *request in queue.operations) {
        if ( info && [info isEqualToString:[request.userInfo objectForKey:URLKey]]) {
            return request;
        }
    }
    return nil;
}

-(void)downloadBtClicked{
    switch (self.downloadFileStatus) {
        case DownloadDataButtonStatus_UnDownload:
        {
            [self startDownloadData];
            break;
        }
        case DownloadDataButtonStatus_Downloading:
        {
            self.alert = [[UIAlertView alloc] initWithTitle:@"" message:@"正在下载中..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"取消下载",@"取消", nil];
            self.alert.tag = DownloadDataButtonStatus_Downloading;
            break;
        }
        case DownloadDataButtonStatus_Pause:
        {
            self.alert = [[UIAlertView alloc] initWithTitle:@"" message:@"是否继续下载" delegate:self cancelButtonTitle:nil otherButtonTitles:@"继续下载",@"取消", nil];
            self.alert.tag = DownloadDataButtonStatus_Pause;
            break;
        }
        case DownloadDataButtonStatus_Downloaded:
        {
            break;
        }
            
        default:
            break;
    }
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case DownloadDataButtonStatus_UnDownload:
        {
            break;
        }
        case DownloadDataButtonStatus_Downloading:
        {
            if (buttonIndex == 0) {
                [self pauseDownloadData];
            }
            break;
        }
        case DownloadDataButtonStatus_Pause:
        {
            if (buttonIndex == 0) {
                [self continueDownloadData];
            }
            break;
        }
        case DownloadDataButtonStatus_Downloaded:
        {
            break;
        }
            
        default:
            break;
    }
}
#pragma mark --
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark requestDelegate
-(void)requestDidFinished:(ASIHTTPRequest*)request{
    if ([[request.userInfo objectForKey:URLKey] isEqualToString:self.downloadFileURL.absoluteString]) {
        self.downloadFileStatus = DownloadDataButtonStatus_Downloaded;
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_DidFinished object:nil userInfo:@{URLKey: self.downloadFileURL.absoluteString,URLLocalPath:self.localPath}];
    }
    
}

-(void)requestDidFailure:(ASIHTTPRequest*)request{
    if ([[request.userInfo objectForKey:URLKey] isEqualToString:self.downloadFileURL.absoluteString]) {
        if (self.downloadFileStatus != DownloadDataButtonStatus_Pause) {
            self.downloadFileStatus = DownloadDataButtonStatus_UnDownload;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_Failure object:nil userInfo:@{URLKey: self.downloadFileURL.absoluteString,URLLocalPath:self.localPath}];
    }
}
#pragma mark --

#pragma mark property
-(UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _progressView;
}

-(void)setDownloadFileStatus:(DownloadDataButtonStatus)downloadFileStatus{
    _downloadFileStatus = downloadFileStatus;
   
    switch (downloadFileStatus) {
        case DownloadDataButtonStatus_UnDownload:
        {
            [self addSubview:self.progressView];
            [self setTitle:@"点击下载" forState:UIControlStateNormal];
            break;
        }
        case DownloadDataButtonStatus_Downloading:
        {
            
            [self addSubview:self.progressView];
            [self setTitle:@"正在下载" forState:UIControlStateNormal];
            break;
        }
        case DownloadDataButtonStatus_Pause:
        {
             [self addSubview:self.progressView];
            [self setTitle:@"继续下载" forState:UIControlStateNormal];
            break;
        }
        case DownloadDataButtonStatus_Downloaded:
        {
            [self.progressView removeFromSuperview];
            [self setTitle:@"下载完成" forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}


#pragma mark --

@end
