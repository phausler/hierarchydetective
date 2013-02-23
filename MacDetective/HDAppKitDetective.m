#import "HDAppKitDetective.h"
#import "NSObject+HDSerialization.h"
#import "HDScriptArgument.h"
#import "NSView+HDHelpers.h"
#import "CALayer+HDHelpers.h"
#import "HDUtils.h"

@implementation HDAppKitDetective

#ifndef HD_MANUAL_LIFECYCLE_MANAGEMENT
+(void) load {
  @autoreleasepool {
    static dispatch_once_t onceToken;
    static HDAppKitDetective *detective = nil;
    dispatch_once(&onceToken, ^{
      detective = [[HDAppKitDetective alloc] init];
    });
  }
}
#endif

-(NSView *) findViewInAllWindows:(NSInteger) pointerValue {
  NSView *selectedView = nil;
  for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
    selectedView = [[window contentView] getChildWithPointerValue:pointerValue];
    if(selectedView != nil)
      break;
  }
  return selectedView;
}

-(void) processCommand:(HDMessage *)message withCompletionHandler:(HDCommandProcessCompletionHandler) completionHandler {
  switch (message.messageType) {
    
    case HDMessageTypeRequestEntireHierarchy:
      message.responseData = (id)[[NSApplication sharedApplication] windows];
      completionHandler(nil);
      break;
    
    case HDMessageTypeGetSufaceForNode:
    {
      if (![message.requestArguments isKindOfClass:[HDArgument class]]) {
        completionHandler(HDNSErrorWithMessage(@"Request arguments invalid"));
        break;
      }
      
      HDArgument* argument = (HDArgument *)message.requestArguments;
      message.responseData = [[self findViewInAllWindows:argument.pointerValue].layer
                              getPNGSurfaceRepresentation:CALayerSurfaceRepresentationTypeSelfOnly];
      completionHandler(nil);
    }
      break;
      
    case HDMessageTypeGetFullSurfaceForNode:
    {
      if (![message.requestArguments isKindOfClass:[HDArgument class]]) {
        completionHandler(HDNSErrorWithMessage(@"Request arguments invalid"));
        break;
      }
      
      HDArgument* argument = (HDArgument *)message.requestArguments;
      message.responseData = [[self findViewInAllWindows:argument.pointerValue].layer
                              getPNGSurfaceRepresentation:CALayerSurfaceRepresentationTypeFull];
      completionHandler(nil);
    }
      break;
      
    case HDMessageTypeUpdatePropertyForNode:
      completionHandler(HDNSErrorWithMessage(@"Unimplemented on the server"));
      break;
    
    case HDMessageTypeApplyScriptAtNode:
    {
      
      if (![message.requestArguments isKindOfClass:[HDScriptArgument class]]) {
        completionHandler(HDNSErrorWithMessage(@"Request arguments invalid"));
        break;
      }

      HDScriptArgument* argument = (HDScriptArgument *)message.requestArguments;
      [[self findViewInAllWindows:argument.pointerValue] executeScript:argument.script withCompletionHandler:^(NSError *error) {
        message.responseData =  (error == nil) ? @"Success" : error.domain;
        completionHandler(nil);
      }];
      
    }
      break;
    
    case HDMessageTypeUnknown:
      completionHandler(nil);
      break;
      
    default:
      completionHandler(HDNSErrorWithMessage(@"Unknown command"));
      break;
  }
}

-(NSString *) aspectName {
  return @"UIKit";
}

@end
