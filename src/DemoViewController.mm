/*
 *  DemoViewController.mm
 *
 *  Copyright (c) 2016-2017 The Brenwill Workshop Ltd.
 *  This code is licensed under the MIT license (MIT) (http://opensource.org/licenses/MIT)
 */

#import "DemoViewController.h"
#import <QuartzCore/CAMetalLayer.h>

#include "ScreenshotExample.hpp"
#include "imgui_impl_osx.h"


const std::string getAssetPath()
{
    return [NSBundle.mainBundle.resourcePath stringByAppendingString:@"/data/"].UTF8String;
}

const std::string getOutputPath()
{
    return NSBundle.mainBundle.bundlePath.UTF8String;
}

/** Rendering loop callback function for use with a CVDisplayLink. */
static CVReturn DisplayLinkCallback(
    CVDisplayLinkRef displayLink,
    const CVTimeStamp * now,
    const CVTimeStamp * outputTime,
    CVOptionFlags flagsIn,
    CVOptionFlags * flagsOut,
    void * target
)
{
    ((ScreenshotExample *) target)->preDraw();
    auto potato = (__bridge NSView *) ((ScreenshotExample *) target)->getView();
    ImGui_ImplOSX_NewFrame(potato);
    ((ScreenshotExample *) target)->draw();
    return kCVReturnSuccess;
}


#pragma mark -
#pragma mark DemoViewController

@implementation DemoViewController
{
    ScreenshotExample * _screenshotExample;
    CVDisplayLinkRef _displayLink;
}

/** Since this is a single-view app, initialize Vulkan during view loading. */
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.wantsLayer = YES;        // Back the view with a layer created by the makeBackingLayer method.

    _screenshotExample = new ScreenshotExample();
    _screenshotExample->initVulkan();
    _screenshotExample->setupWindow((__bridge void *) self.view);
    _screenshotExample->prepare();
    ImGui_ImplOSX_Init();
    _screenshotExample->postPrepare();

    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(_displayLink, &DisplayLinkCallback, _screenshotExample);
    CVDisplayLinkStart(_displayLink);
}

- (void)dealloc {
    CVDisplayLinkRelease(_displayLink);
    delete _screenshotExample;
    //    [super dealloc];
}

// Handle input
- (void)keyDown:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
    _screenshotExample->keyPressed(theEvent.keyCode);
}

- (void)keyUp:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)mouseDown:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)mouseUp:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)mouseMoved:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)mouseDragged:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)mouseEntered:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)mouseExited:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)rightMouseUp:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)rightMouseDragged:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)otherMouseDown:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)otherMouseUp:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}

- (void)otherMouseDragged:(NSEvent *)theEvent {
    auto potato = (__bridge NSView *) _screenshotExample->getView();
    ImGui_ImplOSX_HandleEvent(theEvent, potato);
}
@end


#pragma mark -
#pragma mark DemoView

@implementation DemoView

/** Indicates that the view wants to draw using the backing layer instead of using drawRect:.  */
- (BOOL)wantsUpdateLayer { return YES; }

/** Returns a Metal-compatible layer. */
+ (Class)layerClass { return [CAMetalLayer class]; }

/** If the wantsLayer property is set to YES, this method will be invoked to return a layer instance. */
- (CALayer *)makeBackingLayer {
    CALayer * layer = [self.class.layerClass layer];
    CGSize viewScale = [self convertSizeToBacking:CGSizeMake(1.0, 1.0)];
    layer.contentsScale = MIN(viewScale.width, viewScale.height);
    return layer;
}

- (BOOL)acceptsFirstResponder { return YES; }

@end
