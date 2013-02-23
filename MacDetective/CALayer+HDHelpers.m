#import "CALayer+HDHelpers.h"
#import "NSMutableArray+Queue.h"
#import <AppKit/AppKit.h>

@implementation CALayer (HDHelpers)

-(NSInteger) pointerValue {
  return (NSInteger) self;
}

-(NSArray *) subviews {
  return self.sublayers;
}

-(NSArray *) pathToRoot {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  id currentObject = self;
  do {
    [array addObject:NSStringFromClass([currentObject class])];
  } while((currentObject = [currentObject superlayer]));
  return array;
}

-(NSString *) viewControllerClass {
  NSString *delegateClassName = nil;
  if (self.delegate != nil) {
    delegateClassName  = NSStringFromClass([self.delegate class]);
  }
  return (delegateClassName == nil) ? @"" : delegateClassName;
}

-(NSData *) getPNGSurfaceRepresentation:(CALayerSurfaceRepresentationType) type {
  NSMutableArray* opacityArray = [[NSMutableArray alloc] init];
  
  if (type == CALayerSurfaceRepresentationTypeSelfOnly) {
    for (CALayer* sublayer in self.sublayers) {
      if (sublayer.delegate != nil) {
        [opacityArray enqueue:@(sublayer.opacity)];
        sublayer.opacity = 0;
      }
    }
  }

  CGSize maxRect = CGSizeMake(6144, 6144);
  BOOL tooBigToRender = (self.bounds.size.width > maxRect.width) || (self.bounds.size.height > maxRect.height);
  
  NSBitmapImageRep *bitmapRep = nil;
  if (!tooBigToRender) {
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 32, self.bounds.size.width * 8, colorspace, kCGBitmapByteOrder32Little);
    [self renderInContext:ctx];
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
  }
  
  if (type == CALayerSurfaceRepresentationTypeSelfOnly) {
    for (CALayer* sublayer in self.sublayers) {
      if (sublayer.delegate != nil) {
        sublayer.opacity = [(NSNumber *)[opacityArray dequeue] floatValue];
      }
    }
  }
  return [bitmapRep representationUsingType:NSPNGFileType properties:nil];
}

-(CALayer *) getChildWithPointerValue:(NSInteger) pointerValue {
  if((NSInteger)self == pointerValue)
    return self;
  
  for(CALayer *view in self.sublayers) {
    CALayer *foundView = [view getChildWithPointerValue:pointerValue];
    if (foundView != nil) {
      return foundView;
    }
  }
  
  return nil;
}

-(NSArray *) serializableProperties {
  return @[
    @"pointerValue",
    @"bounds",
    @"frame",
    @"subviews",
    @"classHierarchy",
    @"viewControllerClass",
    @"pathToRoot"
  ];
}

@end
