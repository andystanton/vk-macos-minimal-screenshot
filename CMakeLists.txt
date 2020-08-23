cmake_minimum_required(VERSION 3.14)
project(vk-macos-minimal-screenshot)

include("cmake/vk-utils.cmake")

# Dependencies

add_subdirectory(external/glm)

find_package(Vulkan REQUIRED)
if (NOT Vulkan_FOUND)
    message(FATAL_ERROR "Vulkan not found")
endif ()
string(REGEX MATCHALL "(.*)\\/(.*)" RESOURCE_MATCH ${Vulkan_LIBRARY})
set(MVK_LIB ${CMAKE_MATCH_1}/libMoltenVK.dylib)

find_program(GLSLC glslc HINTS ${VULKAN_SDK}/bin)
if (NOT GLSLC)
    message(FATAL_ERROR "GLSLC not found")
endif ()

find_program(IBTOOL NAMES ibtool)
if (NOT IBTOOL)
    message(FATAL_ERROR "IBTOOL not found")
endif ()

# Configure bundle

set(MACOSX_BUNDLE_GUI_IDENTIFIER "vk.macos.minimal.screenshot")
set(MACOSX_BUNDLE_BUNDLE_NAME ${PROJECT_NAME})
set(MACOSX_BUNDLE_PRINCIPAL_CLASS NSApplication)
set(MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/macos/MacOSXBundleInfo.plist.in")

# Add executable

add_executable(
    screenshot MACOSX_BUNDLE
    src/VulkanExampleBase.cpp
    src/ScreenshotExample.cpp
    src/VulkanTools.cpp
    src/DemoViewController.mm
    src/main.m
    src/MVKExample.cpp
    ${CMAKE_SOURCE_DIR}/macos/Resources/Main.storyboard)

set_source_files_properties(
    src/main.m
    src/DemoViewController.mm
    PROPERTIES COMPILE_FLAGS "-fobjc-arc")
set_source_files_properties(
    ${CMAKE_SOURCE_DIR}/macos/Resources/Main.storyboard
    PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
set_target_properties(
    screenshot
    PROPERTIES LINKER_LANGUAGE CXX
               MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/macos/MacOSXBundleInfo.plist.in"
               CXX_STANDARD 17)

target_compile_definitions(screenshot PRIVATE VK_USE_PLATFORM_MACOS_MVK)
target_include_directories(screenshot PRIVATE ${Vulkan_INCLUDE_DIRS})

target_link_libraries(
    screenshot
    glm
    ${Vulkan_LIBRARIES}
    "-framework Cocoa"
    "-framework Metal"
    "-framework CoreVideo"
    "-framework QuartzCore")

# Compile storyboard

add_custom_command(
    TARGET screenshot
    POST_BUILD
    COMMAND ${IBTOOL} --errors --warnings --notices --output-format human-readable-text --compile
        ${CMAKE_CURRENT_BINARY_DIR}/screenshot.app/Contents/Resources/Main.storyboardc
        ${CMAKE_SOURCE_DIR}/macos/Resources/Main.storyboard
    COMMENT "Compiling xib")

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
    RESOURCE "${CMAKE_CURRENT_SOURCE_DIR}/src/MoltenVK_icd.json"
    OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/screenshot.app/Contents/Resources/vulkan/icd.d")
