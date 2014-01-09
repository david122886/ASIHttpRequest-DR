//
//  ASINetworkQueue+StaticQueues.h
//  ASIHttpRequest
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "ASINetworkQueue.h"

@interface ASINetworkQueue (StaticQueues)

//上传大数据专用
+(id)defaultUploadLargeDataQueue;

//下载大数据专用
+(id)defaultDownloadLargeDataQueue;
//请求小数据使用
+(id)defaultRequestJsonDataQueue;
@end
