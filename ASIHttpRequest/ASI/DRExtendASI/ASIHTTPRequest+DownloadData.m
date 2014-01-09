//
//  ASIHTTPRequest+DownloadData.m
//  ASIHttpRequest
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "ASIHTTPRequest+DownloadData.h"
#import "ASIDownloadCache.h"
@implementation ASIHTTPRequest(DownloadData)
+(id)requestWithLargeDataURL:(NSURL *)newURL{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:newURL];
    //设置保存路径
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
//    [request setTemporaryFileDownloadPath:[ASIHTTPRequest getLargeFileTempPath]];
//    [request setDownloadDestinationPath:[ASIHTTPRequest getLargeFileSavePath]];
    
    //设置断点续传
    [request setAllowResumeForFileDownloads:YES];
    
    //设置区别标记
    request.userInfo = @{URLKey: newURL.absoluteString};
    
    //设置缓存策略,永久保存
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setShouldAttemptPersistentConnection:YES];
    [request setShouldResetDownloadProgress:YES];
    return request;
}

+(id)requestWithJsonDateURL:(NSURL *)newURL{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:newURL];
     request.userInfo = @{URLKey: newURL.absoluteString};
    
    return request;
}

+(NSString*)getLargeFileSavePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path =  [[paths objectAtIndex:0] stringByAppendingPathComponent:@"DRLargeDataCache"];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if (![fileManage fileExistsAtPath:path isDirectory:nil]) {
        [fileManage createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
+(NSString*)getLargeFileTempPath{
    NSString *path =  [NSTemporaryDirectory() stringByAppendingPathComponent:@"DRLargeDataCache"];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if (![fileManage fileExistsAtPath:path isDirectory:nil]) {
        [fileManage createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
@end
