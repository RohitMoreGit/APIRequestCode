//
//  NetworkInterfaceDelegate.h
//  runwithiwatch WatchKit App Extension
//
//  Created by Sanjay on 03/01/18.
//

#import <Foundation/Foundation.h>

@protocol networkInterfaceDelegate <NSObject>
-(void) didReceivedResponse:(NSMutableArray *) response withMethodName:(NSString *) methodName;
@end

@interface NetworkInterface : NSObject
{
    
}
@property (strong, nonatomic) id<networkInterfaceDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *responceDict;
@property (strong, nonatomic) NSMutableArray *responceArray;
-(void) setDelegate:(id<networkInterfaceDelegate>) delegate;
-(void) sendRequest:(NSString *) methodName withParams:(NSMutableDictionary *) parameters;
@end


