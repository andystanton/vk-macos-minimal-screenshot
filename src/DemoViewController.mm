/*
 *  DemoViewController.mm
 *
 *  Copyright (c) 2016-2017 The Brenwill Workshop Ltd.
 *  This code is licensed under the MIT license (MIT) (http://opensource.org/licenses/MIT)
 */

#import "DemoViewController.h"
#import <QuartzCore/CAMetalLayer.h>

#include "ScreenshotExample.hpp"


const std::string getAssetPath() {
    return [NSBundle.mainBundle.resourcePath stringByAppendingString: @"/data/"].UTF8String;
}

const std::string getOutputPath() {
    return NSBundle.mainBundle.bundlePath.UTF8String;
}

/** Rendering loop callback function for use with a CVDisplayLink. */
static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink,
                                    const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime,
                                    CVOptionFlags flagsIn,
                                    CVOptionFlags* flagsOut,
                                    void* target) {
    ((ScreenshotExample*)target)->render();
    return kCVReturnSuccess;
}


#pragma mark -
#pragma mark DemoViewController

@implementation DemoViewController {
    ScreenshotExample * _screenshotExample;
    CVDisplayLinkRef _displayLink;
}

/** Since this is a single-view app, initialize Vulkan during view loading. */
-(void) viewDidLoad {
	[super viewDidLoad];

	self.view.wantsLayer = YES;		// Back the view with a layer created by the makeBackingLayer method.

    _screenshotExample = new ScreenshotExample();
    _screenshotExample->initVulkan();
    _screenshotExample->setupWindow((__bridge void *) self.view);
    _screenshotExample->prepare();

    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(_displayLink, &DisplayLinkCallback, _screenshotExample);
    CVDisplayLinkStart(_displayLink);
}

-(void) dealloc {
    CVDisplayLinkRelease(_displayLink);
    delete _screenshotExample;
//    [super dealloc];
}

// Handle keyboard input
-(void) keyDown:(NSEvent*) theEvent {
    _screenshotExample->keyPressed(theEvent.keyCode);
}

@end


#pragma mark -
#pragma mark DemoView

@implementation DemoView

/** Indicates that the view wants to draw using the backing layer instead of using drawRect:.  */
-(BOOL) wantsUpdateLayer { return YES; }

/** Returns a Metal-compatible layer. */
+(Class) layerClass { return [CAMetalLayer class]; }

/** If the wantsLayer property is set to YES, this method will be invoked to return a layer instance. */
-(CALayer*) makeBackingLayer {
    CALayer* layer = [self.class.layerClass layer];
    CGSize viewScale = [self convertSizeToBacking: CGSizeMake(1.0, 1.0)];
    layer.contentsScale = MIN(viewScale.width, viewScale.height);
    return layer;
}

-(BOOL) acceptsFirstResponder { return YES; }

@end
