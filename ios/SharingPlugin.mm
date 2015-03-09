#import "SharingPlugin.h"
#import "platform/log.h"

static UIViewController* rootViewController = nil;


/**
 * Code from
 * http://stackoverflow.com/questions/7905432/how-to-get-orientation-dependent-height-and-width-of-the-screen
 * for orientation dependent width/height to center on iPad.
 */
@interface UIApplication (AppDimensions)
+(CGSize) currentSize;
+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation UIApplication (AppDimensions)

+(CGSize) currentSize
{
  return [UIApplication sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation
{
  CGSize size = [UIScreen mainScreen].bounds.size;
  UIApplication *application = [UIApplication sharedApplication];
  if (UIInterfaceOrientationIsLandscape(orientation))
  {
    size = CGSizeMake(size.height, size.width);
  }
  if (application.statusBarHidden == NO)
  {
    size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
  }
  return size;
}

@end

@implementation SharingPlugin

// -----------------------------------------------------------------------------
// EXPOSED PLUGIN METHODS
// -----------------------------------------------------------------------------

- (void) share:(NSDictionary*)opts withRequestId:(NSNumber*)requestId {
    UIImage* image = nil;
    NSURL* url = nil;
    NSString* message = opts[@"message"];
    NSMutableArray* items = [[NSMutableArray alloc] initWithArray:@[message]];

    if (opts[@"url"]) {
      // URLWithString will return nil if url is malformed
      url = [NSURL URLWithString:opts[@"url"]];
      if (url != nil) {
        [items addObject:url];
      }
    }

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

    // iOS 8 and later
    if ([activityVC respondsToSelector:@selector(setCompletionWithItemsHandler:)]) {
      [activityVC setCompletionWithItemsHandler:^(NSString *activityType,
                                                  BOOL completed,
                                                  NSArray *returnedItems,
                                                  NSError *activityError) {

        [[PluginManager get] dispatchJSResponse:@{@"completed": [NSNumber numberWithBool:completed]}
                                      withError:nil
                                   andRequestId:requestId];

      }];
    } else {
      // iOS 7 / earlier
      [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        [[PluginManager get] dispatchJSResponse:@{@"completed": [NSNumber numberWithBool:completed]}
                                      withError:nil
                                   andRequestId:requestId];
      }];
    }


    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
      // iPhone
      [rootViewController presentViewController:activityVC animated:YES completion:nil];
    } else {
      // iPad
      // Change Rect to position Popover
      UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
      CGSize size = [UIApplication currentSize];
      CGFloat x = size.width / 2;
      CGFloat y = size.height * 0.95;

      [popup presentPopoverFromRect:CGRectMake(x - 1, y, 2, 1)
                             inView:rootViewController.view
           permittedArrowDirections:UIPopoverArrowDirectionDown
                           animated:YES];
    }
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





