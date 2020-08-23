/*
* Vulkan Example base class
*
* Copyright (C) by Sascha Willems - www.saschawillems.de
*
* This code is licensed under the MIT license (MIT) (http://opensource.org/licenses/MIT)
*/

#pragma once

#include <iostream>
#include <chrono>
#include <sys/stat.h>

#define GLM_FORCE_RADIANS
#define GLM_FORCE_DEPTH_ZERO_TO_ONE
#define GLM_ENABLE_EXPERIMENTAL
#include <glm/glm.hpp>
#include <string>
#include <numeric>
#include <array>

#include "vulkan/vulkan.h"

#include "VulkanTools.h"

#include "VulkanInitializers.hpp"
#include "VulkanDevice.hpp"
#include "VulkanSwapChain.hpp"
#include "camera.hpp"

class VulkanExampleBase
{
private:
    std::string getWindowTitle();
    bool viewUpdated = false;
    uint32_t destWidth;
    uint32_t destHeight;
    bool resizing = false;
    void windowResize();
    void handleMouseMove(int32_t x, int32_t y);
    void nextFrame();
    void updateOverlay();
    void createPipelineCache();
    void createCommandPool();
    void createSynchronizationPrimitives();
    void initSwapchain();
    void setupSwapChain();
    void createCommandBuffers();
    void destroyCommandBuffers();
    std::string shaderDir = "glsl";
protected:
    // Returns the path to the root of the glsl or hlsl shader directory.
    std::string getShadersPath() const;

    // Frame counter to display fps
    uint32_t frameCounter = 0;
    uint32_t lastFPS = 0;
    std::chrono::time_point<std::chrono::high_resolution_clock> lastTimestamp;
    // Vulkan instance, stores all per-application states
    VkInstance instance;
    // Physical device (GPU) that Vulkan will ise
    VkPhysicalDevice physicalDevice;
    // Stores physical device properties (for e.g. checking device limits)
    VkPhysicalDeviceProperties deviceProperties;
    // Stores the features available on the selected physical device (for e.g. checking if a feature is available)
    VkPhysicalDeviceFeatures deviceFeatures;
    // Stores all available memory (type) properties for the physical device
    VkPhysicalDeviceMemoryProperties deviceMemoryProperties;
    /** @brief Set of physical device features to be enabled for this example (must be set in the derived constructor) */
    VkPhysicalDeviceFeatures enabledFeatures{};
    /** @brief Set of device extensions to be enabled for this example (must be set in the derived constructor) */
    std::vector<const char*> enabledDeviceExtensions;
    std::vector<const char*> enabledInstanceExtensions;
    /** @brief Optional pNext structure for passing extension structures to device creation */
    void* deviceCreatepNextChain = nullptr;
    /** @brief Logical device, application's view of the physical device (GPU) */
    VkDevice device;
    // Handle to the device graphics queue that command buffers are submitted to
    VkQueue queue;
    // Depth buffer format (selected during Vulkan initialization)
    VkFormat depthFormat;
    // Command buffer pool
    VkCommandPool cmdPool;
    /** @brief Pipeline stages used to wait at for graphics queue submissions */
    VkPipelineStageFlags submitPipelineStages = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
    // Contains command buffers and semaphores to be presented to the queue
    VkSubmitInfo submitInfo;
    // Command buffers used for rendering
    std::vector<VkCommandBuffer> drawCmdBuffers;
    // Global render pass for frame buffer writes
    VkRenderPass renderPass;
    // List of available frame buffers (same as number of swap chain images)
    std::vector<VkFramebuffer>frameBuffers;
    // Active frame buffer index
    uint32_t currentBuffer = 0;
    // Descriptor set pool
    VkDescriptorPool descriptorPool = VK_NULL_HANDLE;
    // List of shader modules created (stored for cleanup)
    std::vector<VkShaderModule> shaderModules;
    // Pipeline cache object
    VkPipelineCache pipelineCache;
    // Wraps the swap chain to present images (framebuffers) to the windowing system
    VulkanSwapChain swapChain;
    // Synchronization semaphores
    struct {
        // Swap chain image presentation
        VkSemaphore presentComplete;
        // Command buffer submission and execution
        VkSemaphore renderComplete;
    } semaphores;
    std::vector<VkFence> waitFences;
public:
    bool prepared = false;
    uint32_t width = 1280;
    uint32_t height = 720;

    /** @brief Last frame time measured using a high performance timer (if available) */
    float frameTimer = 1.0f;

    /** @brief Encapsulated physical and logical vulkan device */
    vks::VulkanDevice *vulkanDevice;

    /** @brief Example settings that can be changed e.g. by command line arguments */
    struct Settings {
        /** @brief Activates validation layers (and message output) when set to true */
        bool validation = false;
        /** @brief Set to true if fullscreen mode has been requested via command line */
        bool fullscreen = false;
        /** @brief Set to true if v-sync will be forced for the swapchain */
        bool vsync = false;
    } settings;

    VkClearColorValue defaultClearColor = { { 0.025f, 0.025f, 0.025f, 1.0f } };

    static std::vector<const char*> args;

    // Defines a frame rate independent timer value clamped from -1.0...1.0
    // For use in animations, rotations, etc.
    float timer = 0.0f;
    // Multiplier for speeding up (or slowing down) the global timer
    float timerSpeed = 0.25f;
    bool paused = false;

    Camera camera;
    glm::vec2 mousePos;

    std::string title = "Vulkan Example";
    std::string name = "vulkanExample";
    uint32_t apiVersion = VK_API_VERSION_1_0;

    struct {
        VkImage image;
        VkDeviceMemory mem;
        VkImageView view;
    } depthStencil;

    struct {
        glm::vec2 axisLeft = glm::vec2(0.0f);
        glm::vec2 axisRight = glm::vec2(0.0f);
    } gamePadState;

    struct {
        bool left = false;
        bool right = false;
        bool middle = false;
    } mouseButtons;

    // OS specific
    void* view;

    VulkanExampleBase(bool enableValidation = false);
    virtual ~VulkanExampleBase();
    /** @brief Setup the vulkan instance, enable required extensions and connect to the physical device (GPU) */
    bool initVulkan();

    void* setupWindow(void* view);
    /** @brief (Virtual) Creates the application wide Vulkan instance */
    virtual VkResult createInstance(bool enableValidation);
    /** @brief (Pure virtual) Render function to be implemented by the sample application */
    virtual void render() = 0;
    /** @brief (Virtual) Called when the camera view has changed */
    virtual void viewChanged();
    /** @brief (Virtual) Called after a key was pressed, can be used to do custom key handling */
    virtual void keyPressed(uint32_t);
    /** @brief (Virtual) Called after the mouse cursor moved and before internal events (like camera rotation) is handled */
    virtual void mouseMoved(double x, double y, bool &handled);
    /** @brief (Virtual) Called when the window has been resized, can be used by the sample application to recreate resources */
    virtual void windowResized();
    /** @brief (Virtual) Called when resources have been recreated that require a rebuild of the command buffers (e.g. frame buffer), to be implemente by the sample application */
    virtual void buildCommandBuffers();
    /** @brief (Virtual) Setup default depth and stencil views */
    virtual void setupDepthStencil();
    /** @brief (Virtual) Setup default framebuffers for all requested swapchain images */
    virtual void setupFrameBuffer();
    /** @brief (Virtual) Setup a default renderpass */
    virtual void setupRenderPass();
    /** @brief (Virtual) Called after the physical device features have been read, can be used to set features to enable on the device */
    virtual void getEnabledFeatures();

    /** @brief Prepares all Vulkan resources and functions required to run the sample */
    virtual void prepare();

    /** @brief Loads a SPIR-V shader file for the given shader stage */
    VkPipelineShaderStageCreateInfo loadShader(std::string fileName, VkShaderStageFlagBits stage);

    /** @brief Entry point for the main render loop */
    void renderLoop();

    /** Prepare the next frame for workload sumbission by acquiring the next swap chain image */
    void prepareFrame();
    /** @brief Presents the current image to the swap chain */
    void submitFrame();
    /** @brief (Virtual) Default image acquire + submission and command buffer submission function */
    virtual void renderFrame();
};

