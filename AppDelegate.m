//
//  AppDelegate.m
//  Run2Geo
//
//  Created by Dhanraj Bhandari on 11/08/15.
//
//

#import "AppDelegate.h"

#import "R2GHomeViewController.h"
#import "R2GLeftMenuViewController.h"
#import "R2GBaseViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize drawerController;
@synthesize userLocation;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
     //check app open by push message or not);
    if (launchOptions != nil)
    {
        //opened from a push notification when the app is closed
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        RGLog(@"KILLAPPLOG\n%@",userInfo);
        
       // [[[UIAlertView alloc]initWithTitle:@"Push notification" message:userInfo.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
        [[FBSDKApplicationDelegate sharedInstance] application:application
                                 didFinishLaunchingWithOptions:launchOptions];
        
        //Check here app open by which push Facebook, or app push notification
        [self pushTapAction:userInfo];
        
    }
    
  //  [[Fabric sharedSDK] setDebug: YES];
    
    [Fabric with:@[[Crashlytics class]]];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    @try{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }@catch(NSException *e){}@finally{}
    
    //Defualt setting for navigation color
    [UINavigationBar appearance ].barTintColor =kNavigationBarNewBG;
   
    
    if ([[UINavigationBar appearance] respondsToSelector:@selector(setTranslucent:)])
    {
        [[UINavigationBar appearance]setTranslucent:NO];
    }
    // [UINavigationBar appearance].translucent=NO;
    
    //Check here first time launch or not
    [self setupDefaultVaules];
    
    //Check background app refresh for real event track
    [self checkBackgroundAppRefresh];
    
    //Register device for push notification
    [self registerForPushNotification];
    self.normalRunNotification = [[NSMutableArray alloc]init];
    return YES;
}
// setup first time launch
-(void)setupDefaultVaules{
    
    NSString *str =[[NSUserDefaults standardUserDefaults] valueForKey:kKeyDistanceUnit];
    if (str==nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO ]  forKey:kKeyIsLogin];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kKeyEmail];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kKeyMobileNumber];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:3] forKey:kKeyDistanceUnit];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:kKeyIsPace];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:3] forKey:kKeyDelayTime];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:kKeyIsRunTraking];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:kKeyShuffleSongStatus];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kKeyLoopSongStatus];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],kKeyDoNotDisturb,[NSNumber numberWithInt:0],kKeyalert, nil] forKey:kKeyUserSetting];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
    }else
    {
        NSNumber *lat= [NSNumber numberWithDouble:[[[[NSUserDefaults standardUserDefaults] valueForKey:kKeyUserLocation] valueForKey:kKeyLatitude] doubleValue]];
        
        NSNumber *lng= [NSNumber numberWithDouble:[[[[NSUserDefaults standardUserDefaults] valueForKey:kKeyUserLocation] valueForKey:kKeyLongitude] doubleValue]];
        
        self.userLocation =[NSMutableDictionary dictionaryWithObjectsAndKeys:lat,kKeyLatitude,lng,kKeyLongitude, nil];
        
    }
    //FOr Average Pace setting foe development purpose
    
    //    NSNumber *selectedNum =  [[NSUserDefaults standardUserDefaults] valueForKey:kKeyAvgPace];
    //    if (selectedNum==nil)
    //    {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:10] forKey:kKeyAvgPace];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:5] forKey:kKeyCurrentPace];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //    }
    
    
    //        NSNumber *selectedNum =  [[NSUserDefaults standardUserDefaults] valueForKey:kkeyGPSStrongValue];
    //        if (selectedNum==nil)
    //        {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:6] forKey:kkeyGPSStrongValue];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:32] forKey:kKeyGPSAverageValue];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //        }
    
}
 //Register device for push notification
-(void)registerForPushNotification{
    if (!([[[NSUserDefaults standardUserDefaults] valueForKey:kKeyDeviceToken] length]>0))
    {
        self.isRegistered=NO;
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |UIUserNotificationTypeBadge |
             UIUserNotificationTypeSound categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound )];
        }
    }
}

//cehck app open from push touch and process acording
-(void)pushTapAction:(NSDictionary *)userInfo{
    
    @try{
        if (userInfo != nil)
        {
            NSDictionary *appNotify = [NSDictionary dictionaryWithDictionary:[userInfo objectForKey:@"aps"]];
            //Check here app notification
            if ([appNotify objectForKey:kKeyAppNotify] && [[appNotify objectForKey:kKeyAppNotify] count]) {
                //Check here is there any data in realated to event
                if ([[appNotify objectForKey:kKeyAppNotify] objectForKey:kKeyEventId] && [[[appNotify objectForKey:kKeyAppNotify] valueForKey:kKeyEventId] length]) {
                    //Set data for redirect Event page from home page
                    SharedClass.notificationInfo = [[NSMutableDictionary alloc]initWithDictionary:[appNotify valueForKey:kKeyAppNotify]];
                }
                
            }else{
                //No any app push then its Facebook push
                [self performSelector:@selector(showFacebookAd:) withObject:userInfo afterDelay:6.0];
                
            }
        }
    }@catch(NSException *e){
        RGLog(@"Error in push message.:%@",[e description]);
    }
}
-(void)showFacebookAd:(NSDictionary *)userInfo
{
    FBNotificationsManager *notificationsManager = [FBNotificationsManager sharedManager];
    RGLog(@"KILLMGR\n%@",notificationsManager);
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kKeyIsLogin]boolValue])
    {
        [notificationsManager presentPushCardForRemoteNotificationPayload:userInfo
                                                       fromViewController:nil
                                                               completion:^(FBNCardViewController * _Nullable viewController, NSError * _Nullable error) {
                                                                   if (error) {
                                                                       RGLog(@"KILLERROR\n%@",error);
                                                                       //completionHandler(UIBackgroundFetchResultFailed);
                                                                   } else {
                                                                       RGLog(@"KILLSUCESS");
                                                                       // completionHandler(UIBackgroundFetchResultNewData);
                                                                   }
                                                               }];

    }
    
    
}
//Check here app is support for background refresh
-(void)checkBackgroundAppRefresh{
    
    //Check background app refresh for real event track
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok =[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:ok];
        [self.window.rootViewController presentViewController:alertVc animated:YES completion:nil];
        
        
    } else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:@"The functions of this app are limited because the Background App Refresh is disable." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok =[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:ok];
        [self.window.rootViewController presentViewController:alertVc animated:YES completion:nil];
        
    }
}
//For Facebook
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.absoluteString rangeOfString:@"run2geo://run2geo"].location != NSNotFound) {
        NSNotification *notification =  [NSNotification notificationWithName:@"run2geoLaunchNotification" object:nil userInfo:@{@"URL":url}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return YES;
    }else
    {    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    }
}

-(void)saveFitbitCode:(NSURL *)url
{
    NSString *strUrl =[NSString stringWithFormat:@"%@",url];
    NSRange range1 = [strUrl rangeOfString:@"code="];
    NSRange range2 = [strUrl rangeOfString:@"#_=_"];
    
    
    NSRange rSub = NSMakeRange(range1.location + range1.length, range2.location - range1.location - range1.length);
    NSString *sub = [strUrl substringWithRange:rSub];
    
    if(sub != nil && sub.length)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:sub forKey:@"auth_code"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"callRequest" object:nil userInfo:nil];
    }
}

#pragma mark-Remote notification delegate
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    RGLog(@"Device Token= %@",token);
//    [[[UIAlertView alloc]initWithTitle:token message:token delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
//    NSLog(@"%@",token);
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kKeyDeviceToken];
    
    [[NSUserDefaults standardUserDefaults] setValue:deviceToken forKey:kKeyDeviceTokenData];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //For ad notification
    [FBSDKAppEvents setPushNotificationsDeviceToken:deviceToken];
    
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //For simulator work
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kKeyDeviceToken];//d7d268c2bd2118179cade5eea993c9e3d893ac3d58016843c4387c1ecd6ec020 //bbb16d059462a69021db4e4700236bd77d2d6a614712f6601aebf3d94f54b0f4
    [[NSUserDefaults standardUserDefaults] setValue:[NSData data] forKey:kKeyDeviceTokenData];

    [[NSUserDefaults standardUserDefaults] synchronize];

    
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"NotificationInfo=%@",userInfo);
 //   [[[UIAlertView alloc]initWithTitle:@"Push notification" message:userInfo.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kKeyIsLogin]boolValue])
    {
        //Check here app open by which push Facebook, or app push notification
        [self pushTapAction:userInfo];
        /*
        FBNotificationsManager *notificationsManager = [FBNotificationsManager sharedManager];
        [notificationsManager presentPushCardForRemoteNotificationPayload:userInfo
                                                       fromViewController:nil
                                                               completion:^(FBNCardViewController * _Nullable viewController, NSError * _Nullable error) {
                                                                   if (error) {
                                                                       //completionHandler(UIBackgroundFetchResultFailed);
                                                                   } else {
                                                                       // completionHandler(UIBackgroundFetchResultNewData);
                                                                   }
                                                               }];
        */
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark -
#pragma mark - Update Notification hub
#pragma mark -

-(void)registerDeviceOnNotificationHub:(NSString *)userId
{
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:HUBLISTENACCESS
                                                             notificationHubPath:HUBNAME];
    
    [hub registerNativeWithDeviceToken:[[NSUserDefaults standardUserDefaults] valueForKey:kKeyDeviceTokenData] tags: [NSSet setWithObject:userId] completion:^(NSError* error) {
        if (error != nil) {
            RGLog(@"Error registering for notifications: %@", error);
        }
        else {
            RGLog(@"registered for notifications: %@", userId);
            self.isRegistered=YES;
        }
    }];

}
-(void)unRegisterOnNotificationHub
{
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:HUBLISTENACCESS
                                                             notificationHubPath:HUBNAME];
    [hub unregisterNativeWithCompletion:^(NSError *error) {
        
        RGLog(@"Unregister device .error=%@",error);
        self.isRegistered=NO;
        
    }];
}
#pragma mark -
#pragma mark - Drawer controller
#pragma mark -
-(void)loadHomeView
{
   // R2GHomeViewController *homeObj=[[UIStoryboard storyboardWithName:@"Main" bundle: nil]instantiateViewControllerWithIdentifier:@"HomeViewID"];
    
    R2GBaseViewController *homeObj =[[UIStoryboard storyboardWithName:@"Main" bundle: nil]instantiateViewControllerWithIdentifier:@"HomeBaseViewID"];
    
    UINavigationController *centerNavObj=[[UINavigationController alloc]initWithRootViewController:homeObj];
    
    R2GLeftMenuViewController *leftObj=[[UIStoryboard storyboardWithName:@"Main" bundle: nil]instantiateViewControllerWithIdentifier:@"LeftMenuViewID"];
    
    self.drawerController =[[MMDrawerController alloc]initWithCenterViewController:centerNavObj leftDrawerViewController:leftObj];
    
    
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumLeftDrawerWidth:kLeftDrawerWidth];
    //For view seperator line change in library
    [self.drawerController setShowsShadow:YES];
    
    
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningCenterView|MMOpenDrawerGestureModePanningNavigationBar];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningDrawerView|MMCloseDrawerGestureModeTapNavigationBar|MMCloseDrawerGestureModePanningCenterView];
    [self.drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeNavigationBarOnly];
    
//    [self.drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawController, MMDrawerSide drawerSide, CGFloat percentVisible) {
//        
//        MMDrawerControllerDrawerVisualStateBlock block;
//        block = [[MMExampleDrawerVisualStateManager sharedManager]
//                 drawerVisualStateBlockForDrawerSide:drawerSide];
//        if(block){
//            block(drawController, drawerSide, percentVisible);
//        }
//        
//    }];
//    
//    [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeSlideAndScale];
    
    //[UIView animateWithDuration:0.2 animations:^{
        [self.window setRootViewController:self.drawerController];
   // }];
   
    
}
-(void)loadInitialView
{
    
    
    UINavigationController *initialNavObj =[[UIStoryboard storyboardWithName:@"Main" bundle: nil]instantiateViewControllerWithIdentifier:@"InitialRootViewID"];
    
    [self.window setRootViewController:initialNavObj];
    
    self.drawerController=nil;
    
    [self.window makeKeyAndVisible];
}

-(NSString *)filePath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/RunFile.txt",
                          documentsDirectory];
    return fileName;
        
    
}

#pragma mark -
#pragma mark - Core Data stack
#pragma mark -

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.leotechnosoft.Run2Geo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Run2Geo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
   
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Run2Geo.sqlite"];
    NSError *error = nil;
    
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    //Implement on when new version publish
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };
    
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
       abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
#warning work here or check here private or main cuncurrency type required
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(void)deleteDuplicateRun:(NSDate *) timeStamp
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp == %@", timeStamp];
    [fetch setPredicate:predicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    // if(result.count>0) {
    
    for (int i=1; i<result.count; i++)
    {
        Run *deletedRun=(Run*)[result objectAtIndex:i];
        [self.managedObjectContext deleteObject:deletedRun];
        
        RGLog(@"duplicate run delete !!");
    }
    
    [self.managedObjectContext save:nil];
    // }
}
-(BOOL)isDuplicateRun:(NSDate *) timeStamp
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp == %@",timeStamp];
    [fetch setPredicate:predicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    if (result.count>1)
    {
        return YES;
    }else
    {
        return NO;
    }
}

-(BOOL)isRunPresentInDB:(NSNumber *) distance withCompTime:(NSNumber *)second
{
   // NSString *distStr = [NSString stringWithFormat:@"%f",[distance floatValue]];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
  //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"distance.stringValue == %@",distance.stringValue ];
    
    
    
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"(distance.floatValue  >= %f AND distance.floatValue  <= %f) AND (duration == %@)",
                  distance.floatValue - 5.00, distance.floatValue + 5.00,second];
    [fetch setPredicate:predicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    if (result.count>0)
    {
        return YES;
    }else
    {
        return NO;
    }
}

-(NSArray *)fetchiWatchRunFromCoreData
{
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"(runtype == %@ OR runtype == %@) AND issaved == %@",kOutdoorRun,kIndoorRun,[NSNumber numberWithInt:0]];
    [fetch setPredicate:predicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    if (result.count>0)
    {
        return result;
    }
    else
    {
        return nil;
    }
}

-(void)updateiWatchRunIsSaveStatus
{
    NSBatchUpdateRequest *update = [NSBatchUpdateRequest batchUpdateRequestWithEntityName:@"Run"];
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"(runtype == %@ OR runtype == %@) AND issaved == %@",kOutdoorRun,kIndoorRun,[NSNumber numberWithInt:0]];
    [update setPredicate:predicate];
    
    update.propertiesToUpdate = @{
                                  @"issaved" : [NSNumber numberWithInt:1]
                                  };
    update.resultType = NSUpdatedObjectsCountResultType;
    NSBatchUpdateResult *updateRes = (NSBatchUpdateResult *)[self.managedObjectContext executeRequest:update error:nil];
    NSLog(@"%@ objects updated", updateRes.result);
    
    /*
     NSBatchUpdateRequest *req = [[NSBatchUpdateRequest alloc] initWithEntityName:@"MyObject"];
     req.predicate = [NSPredicate predicateWithFormat:@"read == %@", @(NO)];
     req.propertiesToUpdate = @{
     @"read" : @(YES)
     };
     req.resultType = NSUpdatedObjectsCountResultType;
     NSBatchUpdateResult *res = (NSBatchUpdateResult *)[self.managedObjectContext executeRequest:req error:nil];
     NSLog(@"%@ objects updated", res.result);
     
     */
}

-(NSArray *)checkNormalRunNotificationData:(NSMutableArray *)notificationList{
    
    //for save notyfication type "NotifictiononNormalRunWithTrackingStart" to NSUserdefault
    for (NSDictionary *dict in notificationList)
    {
        if([dict valueForKey:kKeyUserEventRunID] && [[dict valueForKey:kKeyRequestType] integerValue] == NotifictiononNormalRunWithTrackingStart){
            // Check object already present in self.normalRunNotification array
            if(self.normalRunNotification.count){
                for(NSDictionary *normalRunDict in self.normalRunNotification)
                {
                    if([[dict valueForKey:kKeyUserEventRunID] integerValue] == [[normalRunDict valueForKey:kKeyUserEventRunID] integerValue]){
                        // Don't add same object.
                    }
                    else{
                        [self.normalRunNotification addObject:dict];
                        [[NSUserDefaults standardUserDefaults]setObject:self.normalRunNotification forKey:kKeyNormalRunNotificationDetail];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
            else{
                [self.normalRunNotification addObject:dict];
                [[NSUserDefaults standardUserDefaults]setObject:self.normalRunNotification forKey:kKeyNormalRunNotificationDetail];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    return nil;
}
@end
