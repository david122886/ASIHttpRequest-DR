//
//  DownloadDataButton.h
//  ASIHttpRequest
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import <UIKit/UIKit.h>
//下载进度
#define DownloadDataButton_Notification_Progress @"DownloadDataButton_Notification_Progress"
//下载完成时通知
#define DownloadDataButton_Notification_DidFinished @"DownloadDataButton_Notification_DidFinished"
//开始下载时通知
#define DownloadDataButton_Notification_DidStartDownload @"DownloadDataButton_Notification_DidStartDownload"

#define DownloadDataButton_Notification_Failure @"DownloadDataButton_Notification_Failure"
/*
 实现文件下载功能
 */
typedef enum {//文件状态
    DownloadDataButtonStatus_UnDownload,//没有下载
    DownloadDataButtonStatus_Downloading,//正在下载
    DownloadDataButtonStatus_Downloaded,//下载完成
    DownloadDataButtonStatus_Pause//暂停下载
}DownloadDataButtonStatus;
@protocol DownloadDataButtonDelegate;
@interface DownloadDataButton : UIButton
@property (strong,nonatomic) NSURL *downloadFileURL;//下载文件的地址
@property (strong,nonatomic) NSString *localPath;
@property (assign,nonatomic) DownloadDataButtonStatus downloadFileStatus;//文件下载状态
@property (assign,nonatomic) BOOL isPostNotification;//设置是否有通知事件
@property (weak,nonatomic) id<DownloadDataButtonDelegate> delegate;
-(void)addTargetMethod;
@end

@protocol DownloadDataButtonDelegate <NSObject>

-(void)downloadDataButton:(DownloadDataButton*)button didStartDownloadFileWithSavePath:(NSString*)localFilePath;
-(void)downloadDataButton:(DownloadDataButton*)button didFinishedDownloadFileWithSavePath:(NSString*)localFilePath;
-(void)downloadDataButton:(DownloadDataButton*)button didfailure:(NSString*)errorMsg;
-(void)downloadDataButton:(DownloadDataButton*)button withFileDownloadedSize:(long long)downloadSize withFileTotalSize:(long long)totalFileSize;
-(void)downloadDataButton:(DownloadDataButton*)button didSelectedWithStatus:(DownloadDataButtonStatus)status;
@end