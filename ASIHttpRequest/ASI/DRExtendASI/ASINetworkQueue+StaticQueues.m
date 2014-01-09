//
//  ASINetworkQueue+StaticQueues.m
//  ASIHttpRequest
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "ASINetworkQueue+StaticQueues.h"
static   ASINetworkQueue *uploadLargeDataQueue = nil;
static   ASINetworkQueue *dowloadLargeDataQueue = nil;
static   ASINetworkQueue *requestJsonDataQueue = nil;
@implementation ASINetworkQueue (StaticQueues)

//上传大数据专用
+(id)defaultUploadLargeDataQueue{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadLargeDataQueue = [[ASINetworkQueue alloc] init];
        [uploadLargeDataQueue setMaxConcurrentOperationCount:4];
        [uploadLargeDataQueue setShouldCancelAllRequestsOnFailure:NO];
        [uploadLargeDataQueue setShowAccurateProgress:YES];
        [uploadLargeDataQueue go];
    });
    return uploadLargeDataQueue;
}

+(id)defaultDownloadLargeDataQueue{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dowloadLargeDataQueue = [[ASINetworkQueue alloc] init];
        [dowloadLargeDataQueue setMaxConcurrentOperationCount:4];
        [dowloadLargeDataQueue setShouldCancelAllRequestsOnFailure:NO];
        [dowloadLargeDataQueue setShowAccurateProgress:YES];
        [dowloadLargeDataQueue reset];
        [dowloadLargeDataQueue go];
    });
    return dowloadLargeDataQueue;
}

+(id)defaultRequestJsonDataQueue{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestJsonDataQueue = [[ASINetworkQueue alloc] init];
        [requestJsonDataQueue setMaxConcurrentOperationCount:20];
        [requestJsonDataQueue setShouldCancelAllRequestsOnFailure:NO];
        [requestJsonDataQueue setShowAccurateProgress:YES];
        [requestJsonDataQueue go];
    });
    return requestJsonDataQueue;
}
@end
