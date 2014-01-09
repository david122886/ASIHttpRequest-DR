//
//  DownloadDataButton.m
//  ASIHttpRequest
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "DownloadDataButton.h"
#import "ASIHTTPRequest+DownloadData.h"
#import "ASINetworkQueue+StaticQueues.h"
@interface DownloadDataButton()
@property (nonatomic,strong) ASIHTTPRequest *request;
@property (nonatomic,assign) long long fileTotalSize;
@property (nonatomic,strong) UIProgressView *progressView;
@end

@implementation DownloadDataButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addTargetMethod];
    }
    return self;
}

-(void)addTargetMethod{
    self.progressView.frame = (CGRect){0,CGRectGetHeight(self.frame)-5,CGRectGetWidth(self.frame),5};
    [self addSubview:self.progressView];
    [self addTarget:self action:@selector(downloadBtClicked) forControlEvents:UIControlEventTouchUpInside];
}

-(void)downloadBtClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDataButton:didSelectedWithStatus:)]) {
        [self.delegate downloadDataButton:self didSelectedWithStatus:self.downloadFileStatus];
    }
    switch (self.downloadFileStatus) {
         case DownloadDataButtonStatus_Downloaded:
        case DownloadDataButtonStatus_Downloading:
        {
            
            break;
        }
        case DownloadDataButtonStatus_UnDownload:
        case DownloadDataButtonStatus_Pause:
        {
            self.downloadFileStatus = DownloadDataButtonStatus_Downloading;
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDataButton:didStartDownloadFileWithSavePath:)]) {
                [self.delegate downloadDataButton:self didStartDownloadFileWithSavePath:self.localPath];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_DidStartDownload object:self userInfo:@{URLKey: self.downloadFileURL.absoluteString}];
            NSString *fileName = [self.downloadFileURL lastPathComponent];
            self.request = [ASIHTTPRequest requestWithLargeDataURL:self.downloadFileURL];
            NSString *path = [[ASIHTTPRequest getLargeFileSavePath] stringByAppendingPathComponent:fileName];
            self.localPath = path;
            [self.request setDownloadDestinationPath:path];
            [self.request setTemporaryFileDownloadPath:[[ASIHTTPRequest getLargeFileTempPath] stringByAppendingPathComponent:fileName]];
            __weak DownloadDataButton *weakSelf = self;
            NSString *url = self.downloadFileURL.absoluteString;
            [self.request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
                DownloadDataButton *tempSelf = weakSelf;
                if (tempSelf) {
                    if (tempSelf.delegate && [tempSelf.delegate respondsToSelector:@selector(downloadDataButton:withFileDownloadedSize:withFileTotalSize:)]) {
                        [tempSelf.delegate downloadDataButton:tempSelf withFileDownloadedSize:size withFileTotalSize:total];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_Progress object:tempSelf userInfo:@{URLKey: url,@"size":[NSNumber numberWithLongLong:size],@"total":[NSNumber numberWithLongLong:total]}];
                NSLog(@"%llu,%llu",size,total);
            }];
            [self.request setDownloadProgressDelegate:self.progressView];
            [self.request setDidFinishSelector:@selector(requestDidFinished:)];
            [self.request setDidFailSelector:@selector(requestDidFailure:)];
            [self.request setDelegate:self];
            NSLog(@"%@",self.localPath);
            [[ASINetworkQueue defaultDownloadLargeDataQueue] addOperation:self.request];
            break;
        }
        default:
            break;
    }
}
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
    self.downloadFileStatus = DownloadDataButtonStatus_Downloaded;
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDataButton:didFinishedDownloadFileWithSavePath:)]) {
        [self.delegate downloadDataButton:self didFinishedDownloadFileWithSavePath:self.localPath];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_DidFinished object:self userInfo:@{URLKey: self.downloadFileURL.absoluteString}];
}

-(void)requestDidFailure:(ASIHTTPRequest*)request{
    self.downloadFileStatus = DownloadDataButtonStatus_Downloaded;
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDataButton:didfailure:)]) {
        [self.delegate downloadDataButton:self didfailure:@"下载失败"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadDataButton_Notification_Failure object:self userInfo:@{URLKey: self.downloadFileURL.absoluteString}];
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

-(void)setDownloadFileURL:(NSURL *)downloadFileURL{
    _downloadFileURL = downloadFileURL;
    if (self.request && _downloadFileURL == downloadFileURL && [_downloadFileURL.absoluteString isEqualToString:downloadFileURL.absoluteString]) {
        [self.request clearDelegatesAndCancel];
        self.request = nil;
    }
    if (!self.request) {
        self.downloadFileStatus = DownloadDataButtonStatus_UnDownload;
    }
}

-(void)setDownloadFileStatus:(DownloadDataButtonStatus)downloadFileStatus{
    _downloadFileStatus = downloadFileStatus;
    switch (downloadFileStatus) {
        case DownloadDataButtonStatus_UnDownload:
        {
            [self setTitle:@"点击下载" forState:UIControlStateNormal];
            break;
        }
        case DownloadDataButtonStatus_Downloading:
        {
            [self setTitle:@"正在下载" forState:UIControlStateNormal];
            break;
        }
        case DownloadDataButtonStatus_Pause:
        {
            [self setTitle:@"继续下载" forState:UIControlStateNormal];
            break;
        }
        case DownloadDataButtonStatus_Downloaded:
        {
            [self setTitle:@"下载完成" forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}


#pragma mark --

-(void)dealloc{
    if (self.request) {
        [self.request clearDelegatesAndCancel];
        self.request = nil;
    }
}
@end
