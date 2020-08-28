find_package(Vulkan REQUIRED)
find_program(GLSLC glslc HINTS ${VULKAN_SDK}/bin)
find_program(IBTOOL NAMES ibtool)

if (NOT Vulkan_FOUND)
    message(FATAL_ERROR "Vulkan not found")
endif()

if (NOT GLSLC)
    message(FATAL_ERROR "GLSLC not found")
endif()

if (NOT IBTOOL)
    message(FATAL_ERROR "IBTOOL not found")
endif()

string(REGEX MATCHALL "(.*)\\/(.*)" RESOURCE_MATCH ${Vulkan_LIBRARY})
set(MVK_LIB ${CMAKE_MATCH_1}/libMoltenVK.dylib)

function(compile_shader)
    set(options USE_RELATIVE_PATHS)
    set(oneValueArgs SHADER OUTPUT_PATH)
    set(multiValueArgs TARGET)
    cmake_parse_arguments(COMPILE_SHADER "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    string(REGEX MATCHALL "(.*)\\/(.*)" SHADER_MATCH ${COMPILE_SHADER_SHADER})
    set(SHADER_NAME ${CMAKE_MATCH_2})
    set(SHADER_OUT ${COMPILE_SHADER_OUTPUT_PATH}/${SHADER_NAME}.spv)
    add_custom_command(
        TARGET ${COMPILE_SHADER_TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${COMPILE_SHADER_OUTPUT_PATH}"
        COMMAND ${GLSLC} ${COMPILE_SHADER_SHADER} -o ${SHADER_OUT}
        COMMENT "Compiling SHADER\n source: ${COMPILE_SHADER_SHADER}\n target: ${SHADER_OUT}"
        DEPENDS ${COMPILE_SHADER_SHADER} vulkan
        VERBATIM)
endfunction(compile_shader)

function(copy_resource)
    set(options USE_RELATIVE_PATHS)
    set(oneValueArgs RESOURCE OUTPUT_PATH)
    set(multiValueArgs TARGET)
    cmake_parse_arguments(COPY_RESOURCE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    string(REGEX MATCHALL "(.*)\\/(.*)" RESOURCE_MATCH ${COPY_RESOURCE_RESOURCE})
    set(RESOURCE_NAME ${CMAKE_MATCH_2})
    set(RESOURCE_OUT ${COPY_RESOURCE_OUTPUT_PATH}/${RESOURCE_NAME})
    add_custom_command(
        TARGET ${COPY_RESOURCE_TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${COPY_RESOURCE_OUTPUT_PATH}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${COPY_RESOURCE_RESOURCE}" "${RESOURCE_OUT}"
        COMMENT "Copying RESOURCE\n source: ${COPY_RESOURCE_RESOURCE}\n target: ${RESOURCE_OUT}"
        DEPENDS ${COPY_RESOURCE_RESOURCE} vulkan
        VERBATIM)
endfunction(copy_resource)

function(compile_storyboard)
    set(oneValueArgs STORYBOARD OUTPUT_PATH)
    set(multiValueArgs TARGET)
    cmake_parse_arguments(COMPILE_STORYBOARD "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    string(REGEX MATCHALL "(.*)\\/(.*)" STORYBOARD_MATCH ${COMPILE_STORYBOARD_STORYBOARD})
    set(STORYBOARD_NAME ${CMAKE_MATCH_2})
    set(STORYBOARD_OUT "${COMPILE_STORYBOARD_OUTPUT_PATH}/${STORYBOARD_NAME}c")
    add_custom_command(
        TARGET ${COMPILE_STORYBOARD_TARGET} POST_BUILD
        COMMAND ${IBTOOL} --errors --warnings --notices --output-format human-readable-text --compile
            ${STORYBOARD_OUT}
            ${COMPILE_STORYBOARD_STORYBOARD}
        COMMENT "Compiling STORYBOARD\n source: ${COMPILE_STORYBOARD_STORYBOARD}\n target: ${STORYBOARD_OUT}"
        DEPENDS ${COMPILE_STORYBOARD_STORYBOARD}
        VERBATIM)
endfunction()
