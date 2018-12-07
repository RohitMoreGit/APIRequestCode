//
//  NetworkInterfaceWithBlock.h
//  iosMachineTest
//
//  Created by Sanjay on 29/06/18.
//  Copyright © 2018 testApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NetworkInterfaceWithBlock : NSObject
{
    
}
@property (strong, nonatomic) NSString *(^name)(NSString *);
@property (strong, nonatomic) NSArray *responceArray;
+(instancetype)shairedInstance;
-(void)sendAPIRequestWithMethodName : (NSString *)methodName parameter: (NSDictionary *)parameters completionHandler : (void (^)(NSArray *resultArray))completionHandler;

@end

