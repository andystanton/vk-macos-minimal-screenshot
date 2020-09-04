cmake_minimum_required(VERSION 3.14)
project(vk-macos-minimal-screenshot)

include("cmake/vk-base.cmake")

# Dependencies

add_subdirectory(external/glm)

# Configure bundle

set(MACOSX_BUNDLE_GUI_IDENTIFIER "vk.macos.minimal.screenshot")
set(MACOSX_BUNDLE_BUNDLE_NAME ${PROJECT_NAME})
set(MACOSX_BUNDLE_PRINCIPAL_CLASS NSApplication)
set(MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/macos/MacOSXBundleInfo.plist.in")

# Create imgui lib

add_library(
    imgui
        external/imgui/imgui.cpp
        external/imgui/imgui_draw.cpp
        external/imgui/imgui_demo.cpp
        external/imgui/imgui_widgets.cpp
        external/imgui/examples/imgui_impl_vulkan.cpp
        external/imgui/examples/imgui_impl_osx.mm)

target_include_directories(imgui PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/external/imgui)
target_include_directories(imgui PRIVATE ${Vulkan_INCLUDE_DIRS})

set_source_files_properties(
    external/imgui/examples/imgui_impl_osx.mm
    PROPERTIES
        COMPILE_FLAGS "-fobjc-arc")

set_target_properties(
    imgui
    PROPERTIES
        LINKER_LANGUAGE CXX
        CXX_STANDARD 17)

# Add executable

add_executable(
    screenshot MACOSX_BUNDLE
        src/ScreenshotExample.cpp
        src/VulkanTools.cpp
        src/DemoViewController.mm
        src/main.m)

set_source_files_properties(
    src/main.m
    src/DemoViewController.mm
    PROPERTIES
        COMPILE_FLAGS "-fobjc-arc")

set_target_properties(
    screenshot
    PROPERTIES
        LINKER_LANGUAGE CXX
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/macos/MacOSXBundleInfo.plist.in"
        CXX_STANDARD 17)

target_compile_definitions(screenshot PRIVATE VK_USE_PLATFORM_MACOS_MVK)
target_include_directories(screenshot PRIVATE ${Vulkan_INCLUDE_DIRS} external/imgui/examples)

target_link_libraries(
    screenshot
    glm
    imgui
    ${Vulkan_LIBRARIES}
    "-framework Cocoa"
    "-framework QuartzCore")

# Compile storyboard

compile_storyboard(
    TARGET screenshot
    STORYBOARD ${CMAKE_CURRENT_SOURCE_DIR}/macos/Resources/Main.storyboard
    OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/screenshot.app/Contents/Resources)

# Compile shaders and add to bundle

compile_shader(
    TARGET screenshot
    SHADER "${CMAKE_CURRENT_SOURCE_DIR}/shader/triangle.vert"
    OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/screenshot.app/Contents/Resources/data/shaders/glsl/triangle")
compile_shader(
    TARGET screenshot
    SHADER "${CMAKE_CURRENT_SOURCE_DIR}/shader/triangle.frag"
    OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/screenshot.app/Contents/Resources/data/shaders/glsl/triangle")

# Copy resources to bundle

copy_resource(
    TARGET screenshot
    RESOURCE "${MVK_LIB}"
    OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/screenshot.app/Contents/Frameworks")
copy_resource(
    TARGET screenshot
    RESOURCE "${Vulkan_LIBRARY}"
    OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/screenshot.app/Contents/MacOS")
copy_resource(
    TARGET screenshot
    RESOURCE "${CMAKE_CURRENT_SOURCE_DIR}/macos/Resources/vulkan/MoltenVK_icd.json"
    OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/screenshot.app/Contents/Resources/vulkan/icd.d")
