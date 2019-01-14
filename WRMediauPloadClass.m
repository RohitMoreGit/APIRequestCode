//
//  WRMediauPloadClass.m
//  WikiReviews
//
//  Created by Sanjay on 07/09/16.
//  Copyright © 2016 leo. All rights reserved.
//

#import "WRMediauPloadClass.h"
#import "MBProgressHUD.h"

@implementation WRMediauPloadClass 
@synthesize mediaArray;

-(void)uploadMultipleImages:(NSArray *)uploadArray
{
    serialQueue = [[NSOperationQueue alloc]init];
    serialQueue.maxConcurrentOperationCount = 1;
    [serialQueue waitUntilAllOperationsAreFinished];
    
    count=0;
    mediaArray=[NSArray arrayWithArray:uploadArray];
    NSDictionary *mediaDict=[mediaArray objectAtIndex:count];

    NSString *medtype=[mediaDict valueForKey:kMediaType];
    
    NSData *data=[mediaDict valueForKey:@"mediaData"];
//    if ([medtype isEqualToString:KMediaVideo]) {
//        data=[mediaDict valueForKey:KMediaVideo];
//    }
    
    [self UploadMedia:nil imageData:data dataType:medtype forKey:[mediaDict valueForKey:@"key"] inclass:[mediaDict valueForKey:kKeyUrl] fileName:[mediaDict valueForKey:kKeyFilename] filePath:[mediaDict valueForKey:KKeyMediaPath]];

   
}

-(void)UploadMedia :(NSDictionary *)inParamsDict imageData:(NSData *)inData dataType:(NSString *)mediaType forKey:(NSString *)imageKey inclass :(NSString *)servrUrl fileName :(NSString *)filename filePath:(NSString *)filePath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        hud = [MBProgressHUD showHUDAddedTo:APP_DELEGATE.window animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        if (mediaArray.count) {
            hud.labelText =[NSString stringWithFormat:@"Uploading %ld/%lu",count+1,(unsigned long)mediaArray.count];
        }
        else{
            hud.labelText = @"Uploading...";
        }
        NSDictionary *frameDict = [NSDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]valueForKey:kKeyUIObjectFrame]];
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake([[frameDict valueForKey:kKeyUIObjectXValue] floatValue], [[frameDict valueForKey:kKeyUIObjectYValue] floatValue], [[frameDict valueForKey:kKeyUIObjectWidth] floatValue], [[frameDict valueForKey:kKeyUIObjectHeight] floatValue])];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setBackgroundColor:[UIColor colorWithRed:46.0f/255.0f green:180.0f/255.0f blue:197.0f/255.0f alpha:1.0]];
        [cancelButton addTarget:self action:@selector(cancelUploadTask) forControlEvents:UIControlEventTouchUpInside];
        [hud addSubview:cancelButton];
    });
    
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kServiceUrl@"%@",servrUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882646641449";
    NSString *contentTypeValue = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentTypeValue forHTTPHeaderField:@"Content-type"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"ios" forHTTPHeaderField:@"Devicetype"];
    if (APP_DELEGATE.userauthToken)
        [request setValue:[NSString stringWithFormat:@"Token %@", APP_DELEGATE.userauthToken] forHTTPHeaderField:@"Authorization"];
    NSString *latitude = [NSString localizedStringWithFormat:@"%f", APP_DELEGATE.currentLocation.coordinate.latitude];
    NSString *longitude = [NSString localizedStringWithFormat:@"%f", APP_DELEGATE.currentLocation.coordinate.longitude];
    NSString *deviceId= APP_DELEGATE.deviceToken;
    if (deviceId)
        [request setValue:deviceId forHTTPHeaderField:@"deviceId"];
    else
        [request setValue:@"848412345695845645" forHTTPHeaderField:@"deviceId"];
    
    [request setValue:latitude forHTTPHeaderField:@"latitude"];
    [request setValue:longitude forHTTPHeaderField:@"longitude"];
    
//    UIImage *image = [UIImage imageNamed:@"simImg.png"];
    NSData *imageData = inData;
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *param in inParamsDict) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: multipart/form-data\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", inParamsDict[param]] dataUsingEncoding:NSUTF8StringEncoding]];
        //   NSString *str = [[NSString alloc]initWithData:body encoding:NSUTF8StringEncoding];
    }
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file",filename] dataUsingEncoding:NSUTF8StringEncoding]];
//        if ([mediaType isEqualToString:KMediaVideo])
//            [body appendData:[@"Content-Type: video/mp4\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        else
//            [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([mediaType isEqualToString:KMediaVideo])
        {
           
//            if (!isNullObject(filePath)) {
//                 filename = [NSString stringWithFormat:@"__video.%@",[[filePath lastPathComponent] pathExtension]];
//                
//                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file",filename] dataUsingEncoding:NSUTF8StringEncoding]];
//            }
            
            
            NSString *mimetype  = [self mimeTypeForPath:filePath];
            
            
//            [body appendData:[@"Content-Type: video/x-m4v\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];

        }
        else  if ([mediaType isEqualToString:@"application"])
        {
            //For Document Upload
            //            'application/x-pdf',
            [body appendData:[@"Content-Type:  application/x-pdf\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            //            'application/pdf',
            [body appendData:[@"Content-Type:  application/pdf\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            //            .doc      application/msword
            //            .dot      application/msword
            [body appendData:[@"Content-Type:  application/msword\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            //            .docx     application/vnd.openxmlformats-officedocument.wordprocessingml.document
            [body appendData:[@"Content-Type:  application/vnd.openxmlformats-officedocument.wordprocessingml.document\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            //            .dotx     application/vnd.openxmlformats-officedocument.wordprocessingml.template
            //            .docm     application/vnd.ms-word.document.macroEnabled.12
            //            .dotm     application/vnd.ms-word.template.macroEnabled.12
            
            
            
            //            "application/msword","application/msword","application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            //            "application/vnd.openxmlformats-officedocument.wordprocessingml.template","application/vnd.ms-word.document.macroEnabled.12",
            //            "application/vnd.ms-word.template.macroEnabled.12","application/vnd.ms-excel","application/vnd.ms-excel","application/vnd.ms-excel",
            //            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet","application/vnd.openxmlformats-officedocument.spreadsheetml.template",
            //            "application/vnd.ms-excel.sheet.macroEnabled.12","application/vnd.ms-excel.template.macroEnabled.12",
            //            "application/vnd.ms-excel.addin.macroEnabled.12","application/vnd.ms-excel.sheet.binary.macroEnabled.12","application/vnd.ms-powerpoint",
            //            "application/vnd.ms-powerpoint","application/vnd.ms-powerpoint","application/vnd.ms-powerpoint",
            //            "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            //            "application/vnd.openxmlformats-officedocument.presentationml.template","application/vnd.openxmlformats-officedocument.presentationml.slideshow","application/vnd.ms-powerpoint.addin.macroEnabled.12",
            //            "application/vnd.ms-powerpoint.presentation.macroEnabled.12","application/vnd.ms-powerpoint.template.macroEnabled.12",
            //            "application/vnd.ms-powerpoint.slideshow.macroEnabled.12","application/vnd.ms-access",
            
        }
        else
        {
            [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    [serialQueue addOperationWithBlock:^{
        self.uploadTask = [self.session uploadTaskWithRequest:request fromData:body];
        [self.uploadTask resume];
    }];
    //self.uploadTask = [self.session uploadTaskWithRequest:request fromData:body];
    //[self.uploadTask resume];
}

-(void)cancelUploadTask
{
    [self.uploadTask cancel];
    [session invalidateAndCancel];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    NSLog(@"Sent %lld, Total sent %lld, Not Sent %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    float progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
    progress -= 0.1;
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.progressView setProgress:progress];
          hud.progress = progress;
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);
    NSLog(@"NSURLSession Starts to Receive Data%@",response);
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
//    NSLog(@"NSURLSession Receive Data%@",data);
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error=nil;
  id jsondata=   [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error
                  ];
    NSLog(@"String Data%@",str);
    if (error==nil) {
        response=jsondata;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [hud hide:YES];
 

        NSLog(@"URL Session Complete: %@", task.response.description);
        if(error != nil) {
            NSLog(@"Error %@",[error userInfo]);
            if (![[[error userInfo] objectForKey:@"NSLocalizedDescription"] isEqualToString:@"cancelled"]){
                    [Utils showOkAlertWithTitle:@"Oops!" message:@"Something went wrong.Please try again."];
                }
            

        } else {
            
                 if (response!=nil) {
                     NSLog(@"Uploading is Succesfull");
                     NSDictionary *respodata=[NSDictionary dictionaryWithObjectsAndKeys:response,kKeyResponseData, nil] ;
                   [[NSNotificationCenter defaultCenter] postNotificationName:kKeyNotificationImageUploadSuccessfull object:respodata userInfo:respodata];
                     count++;
                     if (count<mediaArray.count) {
                         
//                     if (mediaArray.count==count) {//if multiple images then do
//                         [[NSNotificationCenter defaultCenter] postNotificationName:kKeyNotificationImageUploadSuccessfull object:response];
//
//                     }
//                     else
                     {
                         NSDictionary *mediaDict=[mediaArray objectAtIndex:count];
                         
                         NSString *medtype=[mediaDict valueForKey:kMediaType];
                         NSData *data=[mediaDict valueForKey:@"mediaData"];
//                         if ([medtype isEqualToString:KMediaVideo]) {
//                             data=[mediaDict valueForKey:KMediaVideo];
//                         }
                         
                         [self UploadMedia:nil imageData:data dataType:medtype forKey:[mediaDict valueForKey:@"key"] inclass:[mediaDict valueForKey:@"url"] fileName:[mediaDict valueForKey:kKeyFilename] filePath:nil];
                         response=nil;
                     }
                     }
//                     else
//                         [[NSNotificationCenter defaultCenter] postNotificationName:kKeyNotificationImageUploadSuccessfull object:response];
                 }
                 else
                     [Utils showOkAlertWithTitle:@"Oops!" message:@"Something went wrong.Please try again."];
            }
       });
        
//        [MBProgressHUD hideHUDForView:APP_DELEGATE.window animated:YES];
}


- (NSURLSession *)session {
    
    if (!session) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    return session;
}

#pragma mark private Methods
- (NSString *)mimeTypeForPath:(NSString *)path {
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
//    assert(UTI != NULL);
    NSString *mimetype = @"video/x-m4v";
    if (UTI != NULL) {
        assert(UTI != nil);
         mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
        
        assert(mimetype != NULL);
        
        CFRelease(UTI);
    }
    
    
    
    return mimetype;
}

@end
