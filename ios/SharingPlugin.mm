#import "SharingPlugin.h"
#import "platform/log.h"

static UIViewController* rootViewController = nil;

@implementation SharingPlugin

// -----------------------------------------------------------------------------
// EXPOSED PLUGIN METHODS
// -----------------------------------------------------------------------------

- (void) share:(NSDictionary*)opts withRequestId:(NSNumber*)requestId {
    NSString* message = opts[@"message"];
    UIImage* image = nil;
    
    NSMutableArray* items = [[NSMutableArray alloc] initWithArray:@[message]];
    
    if (opts[@"image"]) {
        NSData* imageData = [[NSData alloc] initWithBase64EncodedString:opts[@"image"] options:0];
        image = [[UIImage alloc] initWithData:imageData];
        [items addObject:image];
    }


    // Create view controller for the activity
    UIActivityViewController* activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:items
                                            applicationActivities:nil];

    // Set activity types
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                         UIActivityTypePrint,
                                         UIActivityTypeAssignToContact];
    
    [activityVC setCompletionWithItemsHandler:^(NSString *activityType,
                                                BOOL completed,
                                                NSArray *returnedItems,
                                                NSError *activityError) {
        
        [[PluginManager get] dispatchJSResponse:@{@"completed": [NSNumber numberWithBool:completed]}
                                      withError:nil
                                   andRequestId:requestId];

    }];
    
//    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed){

//    }];

    [rootViewController presentViewController:activityVC
                                     animated:YES
                                   completion:nil];
}

// -----------------------------------------------------------------------------
// EXPOSED PLUGIN SYNCHRONOUS METHODS (with return value)
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// EXPOSED PLUGIN SYNCHRONOUS METHODS
// -----------------------------------------------------------------------------



// -----------------------------------------------------------------------------
// Helper functions
// -----------------------------------------------------------------------------



// -----------------------------------------------------------------------------
// GC PLUGIN INTERFACE
// -----------------------------------------------------------------------------

- (void) initializeWithManifest:(NSDictionary *)manifest appDelegate:(TeaLeafAppDelegate *)appDelegate {
    rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
}

- (void) applicationWillTerminate:(UIApplication *)app {

}

- (void) applicationDidBecomeActive:(UIApplication *)app {

}

- (void) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
}

// The plugin must call super dealloc.
- (void) dealloc {
  [super dealloc];
}

// The plugin must call super init.
- (id) init {
  self = [super init];
  if (!self) {
    return nil;
  }

  return self;
}


@end





