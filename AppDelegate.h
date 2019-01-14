//
//  AppDelegate.h
//  Run2Geo
//
//  Created by Dhanraj Bhandari on 11/08/15.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import <FBNotifications/FBNotifications.h>

#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "HubInfo.h"

#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

}
@property (nonatomic)  BOOL     isRegistered;

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong) MMDrawerController  *drawerController;

@property (nonatomic, strong) NSMutableDictionary   *userLocation;
@property (nonatomic, strong) NSMutableArray *normalRunNotification;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
-(void)deleteDuplicateRun:(NSDate *) timeStamp;
-(BOOL)isDuplicateRun:(NSDate *) timeStamp;
-(BOOL)isRunPresentInDB:(NSNumber *) distance withCompTime:(NSNumber *)second;
-(NSArray *)fetchiWatchRunFromCoreData;
-(void)updateiWatchRunIsSaveStatus;
//Register on AZURE notification hub
-(void)registerDeviceOnNotificationHub:(NSString *)userId;
-(void)unRegisterOnNotificationHub;

- (NSURL *)applicationDocumentsDirectory;

-(void)loadHomeView;
-(void)loadInitialView;
-(NSString *)filePath;
-(NSArray *)checkNormalRunNotificationData : (NSMutableArray *)notificationList;
@end

