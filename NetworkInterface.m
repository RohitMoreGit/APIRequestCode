//
//  NetworkInterfaceDelegate.m
//  runwithiwatch WatchKit App Extension
//
//  Created by Sanjay on 03/01/18.
//

#import "NetworkInterface.h"
#define BASE_URL @""
@implementation NetworkInterface

-(void)setDelegate:(id<networkInterfaceDelegate>)delegate
{
    self.delegate = delegate;
}

-(void) sendRequest:(NSString *) methodName withParams:(NSMutableDictionary *) parameters
{
    NSString *post = [NSString stringWithFormat:@"%@",[self prepareParameterString:parameters]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSString *mainUrl = [NSString stringWithFormat:@"%@/%@", BASE_URL, methodName];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:mainUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:1200];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task=[session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        
        if (error)
        {
            NSLog(@"\n Network Error : %@",error.localizedDescription);
        }
        else
        {
            if(data)
            {
                self.responceArray = [NSJSONSerialization JSONObjectWithData:data  options:0 error:nil];
                [self.delegate didReceivedResponse:self.responceArray withMethodName:methodName];
            }
            else
            {
                NSLog(@"Response nil.");
            }
        }
    }];
    [task resume];
}

-(NSString *) prepareParameterString:(NSMutableDictionary *) parameters
{
    NSString *parameterString = @"";
    
    int cnt = (int) [parameters count];
    
    for (id key in parameters)
    {
        //get value for key
        id value = [parameters valueForKey:key];
        if (cnt == 1)
        {
            //prepare parameter string for last key
            parameterString = [parameterString stringByAppendingFormat:@"%@=%@",key,value];
        }
        else
        {
            //prepare parameter string for key
            parameterString = [parameterString stringByAppendingFormat:@"%@=%@&",key,value];
        }
        cnt--;
    }
    return parameterString;
}

/* Method not in use.*/
-(NSString *) getMethodName:(NSURL *) url
{
    NSString *method = [NSString stringWithFormat:@"%@",[url lastPathComponent]];
    return method;
}

@end
