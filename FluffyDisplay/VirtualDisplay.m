// -*- Mode: ObjC; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; fill-column: 100 -*-

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "CGVirtualDisplay.h"
#import "CGVirtualDisplayDescriptor.h"
#import "CGVirtualDisplayMode.h"
#import "CGVirtualDisplaySettings.h"

#import "VirtualDisplay.h"

static char *rot13(char *p) {
    char *result = strdup(p);
    p = result;
    while (*p) {
        if (*p >= 'A' && *p <= 'Z')
            *p = 'A' + ((*p - 'A' + 13) % 26);
        else if (*p >= 'a' && *p <= 'z')
            *p = 'a' + ((*p - 'a' + 13) % 26);
        p++;
    }
    return result;
}

id createVirtualDisplay(int width, int height, int ppi, NSString *name) {

    NSString *CGVirtualDisplaySettingsClassName = [NSString stringWithUTF8String:rot13("PTIveghnyQvfcynlFrggvatf")];
    Class CGVirtualDisplaySettingsClass = NSClassFromString(CGVirtualDisplaySettingsClassName);

    SEL alloc = NSSelectorFromString(@"alloc");
    CGVirtualDisplaySettings *settings =
        [((id (*)(id, SEL))[CGVirtualDisplaySettingsClass methodForSelector:alloc])(CGVirtualDisplaySettingsClass, alloc) init];

    settings.hiDPI = ppi >= 200;

    if (settings.hiDPI) {
        width /= 2;
        height /= 2;
    }

    NSString *CGVirtualDisplayDescriptorClassName = [NSString stringWithUTF8String:rot13("PTIveghnyQvfcynlQrfpevcgbe")];
    Class CGVirtualDisplayDescriptorClass = NSClassFromString(CGVirtualDisplayDescriptorClassName);

    CGVirtualDisplayDescriptor *descriptor =
        [((id (*)(id, SEL))[CGVirtualDisplayDescriptorClass methodForSelector:alloc])(CGVirtualDisplayDescriptorClass, alloc) init];
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

    NSString *CGVirtualDisplayClassName = [NSString stringWithUTF8String:rot13("PTIveghnyQvfcynl")];
    Class CGVirtualDisplayClass = NSClassFromString(CGVirtualDisplayClassName);

    CGVirtualDisplay *display =
        [((id (*)(id, SEL))[CGVirtualDisplayClass methodForSelector:alloc])(CGVirtualDisplayClass, alloc) initWithDescriptor:descriptor];

    NSString *CGVirtualDisplayModeClassName = [NSString stringWithUTF8String:rot13("PTIveghnyQvfcynlZbqr")];
    Class CGVirtualDisplayModeClass = NSClassFromString(CGVirtualDisplayModeClassName);

    CGVirtualDisplayMode *mode =
        [((id (*)(id, SEL))[CGVirtualDisplayModeClass methodForSelector:alloc])(CGVirtualDisplayModeClass, alloc) initWithWidth:descriptor.maxPixelsWide
                                                                                                                         height:descriptor.maxPixelsHigh
                                                                                                                    refreshRate:60];
    settings.modes = @[mode];

    if (![display applySettings:settings])
        return nil;

    return display;
}
