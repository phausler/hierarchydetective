#import <AppKit/AppKit.h>
#import "HDScriptRunner.h"
#import "HDProperties.h"

@interface NSView (HDHelpers) <HDProperties>

@property (nonatomic, readonly) NSInteger pointerValue;
@property (nonatomic, readonly) NSString *viewControllerClass;
@property (nonatomic, readonly) NSArray *pathToRoot;

-(NSView *) getChildWithPointerValue:(NSInteger) pointerValue;

-(void) executeScript:(NSString *) script withCompletionHandler:(HDScriptExecutionCompletionHandler) handler;

@end
