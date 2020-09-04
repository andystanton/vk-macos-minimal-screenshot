#pragma once

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

#include "VulkanTools.hpp"
#include "imgui.h"
#include "imgui_impl_vulkan.h"

#include "VulkanInitializers.hpp"
#include "VulkanDevice.hpp"
#include "VulkanSwapChain.hpp"

class ScreenshotExample
{
public:
    struct Vertex
    {
        float position[3];
        float color[3];
    };

    struct
    {
        VkDeviceMemory memory; // Handle to the device memory for this buffer
        VkBuffer buffer;       // Handle to the Vulkan buffer object that the memory is bound to
    } vertices;

    struct
    {
        VkDeviceMemory memory;
        VkBuffer buffer;
        uint32_t count;
    } indices;

    struct
    {
        VkDeviceMemory memory;
        VkBuffer buffer;
        VkDescriptorBufferInfo descriptor;
    } uniformBufferVS;

    struct
    {
        glm::mat4 projectionMatrix;
        glm::mat4 modelMatrix;
        glm::mat4 viewMatrix;
    } uboVS;

    VkPipelineLayout pipelineLayout;
    VkPipeline pipeline;
    VkDescriptorSetLayout descriptorSetLayout;
    VkDescriptorSet descriptorSet;
    VkSemaphore presentCompleteSemaphore;
    VkSemaphore renderCompleteSemaphore;

    bool doScreenshot = false;

    ScreenshotExample();
    ~ScreenshotExample();
    void draw();
    void preDraw();
    void keyPressed(uint32_t keycode);
    void prepare();
    void postPrepare();
    bool initVulkan();
    void * setupWindow(void * view);
    void * getView();
private:
    bool prepared = false;
    uint32_t width = 800;
    uint32_t height = 600;

    vks::VulkanDevice * vulkanDevice;

    glm::mat4 viewMatrix;
    glm::mat4 projectionMatrix;

    std::string name = "screenshotExample";
    uint32_t apiVersion = VK_API_VERSION_1_0;

    void * view;
    VkInstance instance;
    VkPhysicalDevice physicalDevice;
    VkPhysicalDeviceProperties deviceProperties;
    VkPhysicalDeviceFeatures deviceFeatures;
    VkPhysicalDeviceMemoryProperties deviceMemoryProperties;
    VkPhysicalDeviceFeatures enabledFeatures {};
    std::vector<const char *> enabledDeviceExtensions;
    std::vector<const char *> enabledInstanceExtensions;
    void * deviceCreatepNextChain = nullptr;
    VkDevice device;
    VkQueue queue;
    VkCommandPool cmdPool;
    std::vector<VkCommandBuffer> drawCmdBuffers;
    VkRenderPass renderPass;
    std::vector<VkFramebuffer> frameBuffers;
    uint32_t currentBuffer = 0;
    VkDescriptorPool descriptorPool = VK_NULL_HANDLE;
    std::vector<VkShaderModule> shaderModules;
    VulkanSwapChain swapChain;
    std::vector<VkFence> waitFences;

    ImGuiContext * imguiContext;
    ImGui_ImplVulkan_InitInfo imgui_vulkan_info;
    bool windowOpen;

    void createCommandPool();
    void createSynchronizationPrimitives();
    void initSwapchain();
    void setupSwapChain();
    void createCommandBuffers();
    void saveScreenshot(const char * filename);
    static std::string getShadersPath();
    uint32_t getMemoryTypeIndex(uint32_t typeBits, VkMemoryPropertyFlags properties);
    void prepareSynchronizationPrimitives();
    VkCommandBuffer getCommandBuffer(bool begin);
    void destroyCommandBuffers();
    void prepareVertices(bool useStagingBuffers);
    void setupDescriptorPool();
    void setupDescriptorSetLayout();
    void setupDescriptorSet();
    void setupFrameBuffer();
    void setupRenderPass();
    VkShaderModule loadSPIRVShader(std::string filename);
    void preparePipelines();
    void prepareUniformBuffers();
    void updateUniformBuffers();
    VkResult createInstance(bool enableValidation);
    void beginRenderPassAndCommandBuffer(uint32_t i);
    void completeRenderPassAndCommandBuffer(uint32_t i);
};
