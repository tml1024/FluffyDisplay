// -*- Mode: ObjC; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; fill-column: 100 -*-

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "CGVirtualDisplay.h"
#import "CGVirtualDisplayDescriptor.h"
#import "CGVirtualDisplayMode.h"
#import "CGVirtualDisplaySettings.h"

#import "VirtualDisplay.h"

id createVirtualDisplay(int width, int height, int ppi, BOOL hiDPI, NSString *name) {

    CGVirtualDisplaySettings *settings = [[CGVirtualDisplaySettings alloc] init];
    settings.hiDPI = hiDPI;

    CGVirtualDisplayDescriptor *descriptor = [[CGVirtualDisplayDescriptor alloc] init];
    descriptor.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    descriptor.name = name;

    // See System Preferences > Displays > Color > Open Profile > Apple display native information
    descriptor.whitePoint = CGPointMake(0.3125, 0.3291);
    descriptor.bluePrimary = CGPointMake(0.1494, 0.0557);
    descriptor.greenPrimary = CGPointMake(0.2559, 0.6983);
    descriptor.redPrimary = CGPointMake(0.6797, 0.3203);
    descriptor.maxPixelsHigh = height;
    descriptor.maxPixelsWide = width;
    descriptor.sizeInMillimeters = CGSizeMake(25.4 * width / ppi, 25.4 * height / ppi);
    descriptor.serialNum = 0;
    descriptor.productID = 0;
    descriptor.vendorID = 0;

    CGVirtualDisplay *display = [[CGVirtualDisplay alloc] initWithDescriptor:descriptor];

    if (settings.hiDPI) {
        width /= 2;
        height /= 2;
    }
    CGVirtualDisplayMode *mode = [[CGVirtualDisplayMode alloc] initWithWidth:width
                                                                      height:height
                                                                 refreshRate:60];
    settings.modes = @[mode];

    if (![display applySettings:settings])
        return nil;

    return display;
}
