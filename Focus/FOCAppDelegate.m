//
//  AppDelegate.m
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCAppDelegate.h"
#import "FOCDeviceProgramEntity.h"
#import "FOCDefaultProgramProvider.h"

@interface FOCAppDelegate ()

@end

@implementation FOCAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString* kFocusProgramEntity = @"Program";

static NSString* kAttrProgramId = @"programId";
static NSString* kAttrName = @"name";
static NSString* kAttrImageName = @"imageName";
static NSString* kAttrProgramMode = @"programMode";
static NSString* kAttrValid = @"valid";
static NSString* kAttrSham = @"sham";
static NSString* kAttrBipolar = @"bipolar";
static NSString* kAttrRandomCurrent = @"randomCurrent";
static NSString* kAttrRandomFrequency = @"randomFrequency";
static NSString* kAttrDuration = @"duration";
static NSString* kAttrCurrent = @"current";
static NSString* kAttrVoltage = @"voltage";
static NSString* kAttrShamDuration = @"shamDuration";
static NSString* kAttrCurrentOffset = @"currentOffset";
static NSString* kAttrMinFrequency = @"minFrequency";
static NSString* kAttrMaxFrequency = @"maxFrequency";
static NSString* kAttrFrequency = @"frequency";
static NSString* kAttrDutyCycle = @"dutyCycle";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.focusDeviceManager = [[FOCDeviceManager alloc] init];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Entering background!");
    
    // FIXME if playing program, maintain connection, otherwise close
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Entering foreground, refreshing BLE device state!");
    [_focusDeviceManager refreshDeviceState];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data stack

- (void)saveProgram
{
    FOCDeviceProgramEntity *entity = [FOCDefaultProgramProvider gamer];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *program = [NSEntityDescription
                                insertNewObjectForEntityForName:kFocusProgramEntity
                                inManagedObjectContext:_managedObjectContext];
    
    NSNumber *programId = [[NSNumber alloc] initWithInt:entity.programId];
    NSNumber *programMode = [FOCDeviceProgramEntity persistableValueFor:entity.programMode];
    
    [program setValue:programId forKey:kAttrProgramId];
    [program setValue:entity.name forKey:kAttrName];
    [program setValue:entity.imageName forKey:kAttrImageName];
    [program setValue:programMode forKey:kAttrProgramMode];
    
    [program setValue:entity.valid forKey:kAttrValid];
    [program setValue:entity.sham forKey:kAttrSham];
    [program setValue:entity.bipolar forKey:kAttrBipolar];
    [program setValue:entity.randomCurrent forKey:kAttrRandomCurrent];
    [program setValue:entity.randomFrequency forKey:kAttrRandomFrequency];
    
    [program setValue:entity.duration forKey:kAttrDuration];
    [program setValue:entity.current forKey:kAttrCurrent];
    [program setValue:entity.voltage forKey:kAttrVoltage];
    [program setValue:entity.shamDuration forKey:kAttrShamDuration];
    [program setValue:entity.currentOffset forKey:kAttrCurrentOffset];
    [program setValue:entity.minFrequency forKey:kAttrMinFrequency];
    [program setValue:entity.maxFrequency forKey:kAttrMaxFrequency];
    
    [program setValue:entity.frequency forKey:kAttrFrequency];
    [program setValue:entity.dutyCycle forKey:kAttrDutyCycle];
    
    NSError *error;
    
    if (![context save:&error]) {
        NSLog(@"Failed to save: %@", [error localizedDescription]);
    }
}

- (void)retrieveProgram
{
    NSManagedObjectContext *context = [self managedObjectContext];

    // TODO retrieve from core data
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.beardedhen.test" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    
    if (_managedObjectModel == nil) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FocusProgram" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"focus.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
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

@end
