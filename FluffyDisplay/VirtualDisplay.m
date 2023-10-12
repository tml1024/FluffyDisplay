// -*- Mode: ObjC; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; fill-column: 100 -*-

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    descriptor.serialNum = 1;
    descriptor.productID = 1;
    descriptor.vendorID = 1;

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
