//
//  WRMediauPloadClass.h
//  WikiReviews
//
//  Created by Sanjay on 07/09/16.
//  Copyright © 2016 leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WRMediauPloadClass : NSObject <NSURLSessionDelegate>
{
    NSURLSession *session;
    MBProgressHUD *hud;
    NSDictionary *response;
    NSInteger count;
    NSOperationQueue *serialQueue;
  
}
@property (strong, nonatomic) NSNumber *xValue;
@property (strong, nonatomic) NSNumber *yValue;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong,nonatomic) NSURLSessionUploadTask *uploadTask;
@property (strong, nonatomic) NSData *resumeData;
@property (strong, nonatomic) NSArray *mediaArray;
@property (strong, nonatomic) UIButton *cancelButton;
@property (weak, nonatomic) UIProgressView *progressView;

-(void)UploadMedia :(NSDictionary *)inParamsDict imageData:(NSData *)inData dataType:(NSString *)mediaType forKey:(NSString *)imageKey inclass :(NSString *)servrUrl fileName :(NSString *)filename filePath:(NSString *)filePath;

-(void)uploadMultipleImages:(NSArray *)MediaArray;
@end
