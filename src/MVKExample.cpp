/*
 *  MVKExample.cpp
 *
 *  Copyright (c) 2016-2017 The Brenwill Workshop Ltd.
 *  This code is licensed under the MIT license (MIT) (http://opensource.org/licenses/MIT)
 */


#include "MVKExample.h"
#include "ScreenshotExample.hpp"

void MVKExample::renderFrame() {
    _vulkanExample->render();
}

void MVKExample::keyPressed(uint32_t keyCode) {
    _vulkanExample->keyPressed(keyCode);
}

MVKExample::MVKExample(void* view) {
    _vulkanExample = new ScreenshotExample();
    _vulkanExample->initVulkan();
    _vulkanExample->setupWindow(view);
    _vulkanExample->prepare();
}

MVKExample::~MVKExample() {
    delete _vulkanExample;
}
