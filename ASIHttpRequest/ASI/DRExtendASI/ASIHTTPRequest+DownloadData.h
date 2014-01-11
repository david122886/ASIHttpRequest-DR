//
//  ASIHTTPRequest+DownloadData.h
//  ASIHttpRequest
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#define URLKey @"urlString"//用来区别每一个requestion
#define URLReceiveDataSize @"URLReceiveDataSize"
#define URLTotalDataSize @"URLTotalDataSize"
#define URLLocalPath @"URLLocalPath"
@interface ASIHTTPRequest(DownloadData)
//下载大文件
+(id)requestWithLargeDataURL:(NSURL *)newURL;
+(id)requestWithJsonDateURL:(NSURL *)newURL;

+(NSString*)getLargeFileSavePath;
+(NSString*)getLargeFileTempPath;
@end
