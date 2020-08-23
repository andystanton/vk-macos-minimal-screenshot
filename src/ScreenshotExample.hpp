#pragma once

#include "VulkanExampleBase.h"

class ScreenshotExample: public VulkanExampleBase
{
public:
    // Vertex layout used in this example
    struct Vertex {
        float position[3];
        float color[3];
    };

    // Vertex buffer and attributes
    struct {
        VkDeviceMemory memory; // Handle to the device memory for this buffer
        VkBuffer buffer;       // Handle to the Vulkan buffer object that the memory is bound to
    } vertices;

    // Index buffer
    struct {
        VkDeviceMemory memory;
        VkBuffer buffer;
        uint32_t count;
    } indices;

    // Uniform buffer block object
    struct {
        VkDeviceMemory memory;
        VkBuffer buffer;
        VkDescriptorBufferInfo descriptor;
    }  uniformBufferVS;

    // For simplicity we use the same uniform block layout as in the shader:
    //
    //	layout(set = 0, binding = 0) uniform UBO
    //	{
    //		mat4 projectionMatrix;
    //		mat4 modelMatrix;
    //		mat4 viewMatrix;
    //	} ubo;
    //
    // This way we can just memcopy the ubo data to the ubo
    // Note: You should use data types that align with the GPU in order to avoid manual padding (vec4, mat4)
    struct {
        glm::mat4 projectionMatrix;
        glm::mat4 modelMatrix;
        glm::mat4 viewMatrix;
    } uboVS;

    // The pipeline layout is used by a pipline to access the descriptor sets
    // It defines interface (without binding any actual data) between the shader stages used by the pipeline and the shader resources
    // A pipeline layout can be shared among multiple pipelines as long as their interfaces match
    VkPipelineLayout pipelineLayout;

    // Pipelines (often called "pipeline state objects") are used to bake all states that affect a pipeline
    // While in OpenGL every state can be changed at (almost) any time, Vulkan requires to layout the graphics (and compute) pipeline states upfront
    // So for each combination of non-dynamic pipeline states you need a new pipeline (there are a few exceptions to this not discussed here)
    // Even though this adds a new dimension of planing ahead, it's a great opportunity for performance optimizations by the driver
    VkPipeline pipeline;

    // The descriptor set layout describes the shader binding layout (without actually referencing descriptor)
    // Like the pipeline layout it's pretty much a blueprint and can be used with different descriptor sets as long as their layout matches
    VkDescriptorSetLayout descriptorSetLayout;

    // The descriptor set stores the resources bound to the binding points in a shader
    // It connects the binding points of the different shaders with the buffers and images used for those bindings
    VkDescriptorSet descriptorSet;


    // Synchronization primitives
    // Synchronization is an important concept of Vulkan that OpenGL mostly hid away. Getting this right is crucial to using Vulkan.

    // Semaphores
    // Used to coordinate operations within the graphics queue and ensure correct command ordering
    VkSemaphore presentCompleteSemaphore;
    VkSemaphore renderCompleteSemaphore;

    // Fences
    // Used to check the completion of queue operations (e.g. command buffer execution)
    std::vector<VkFence> waitFences;

    bool screenshotSaved = false;
    bool doScreenshot = false;

    ScreenshotExample();
    ~ScreenshotExample() override;
    void render() override;
    void viewChanged() override;
    uint32_t getMemoryTypeIndex(uint32_t typeBits, VkMemoryPropertyFlags properties);
    void prepareSynchronizationPrimitives();
    VkCommandBuffer getCommandBuffer(bool begin);
    void flushCommandBuffer(VkCommandBuffer commandBuffer);
    void buildCommandBuffers() override;
    void draw();
    void prepareVertices(bool useStagingBuffers);
    void setupDescriptorPool();
    void setupDescriptorSetLayout();
    void setupDescriptorSet();
    void setupDepthStencil() override;
    void setupFrameBuffer() override;
    void setupRenderPass() override;
    VkShaderModule loadSPIRVShader(std::string filename);
    void preparePipelines();
    void prepareUniformBuffers();
    void updateUniformBuffers();
    void prepare() override;
    void keyPressed(uint32_t uint_32) override;
private:
    void saveScreenshot(const char * filename);
};
