function(compile_shader)
    set(options USE_RELATIVE_PATHS)
    set(oneValueArgs SHADER OUTPUT_PATH)
    set(multiValueArgs TARGET)
    cmake_parse_arguments(COMPILE_SHADER "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
    string(REGEX MATCHALL "(.*)\\/(.*)" SHADER_MATCH ${COMPILE_SHADER_SHADER})
    set(SHADER_NAME ${CMAKE_MATCH_2})
    message(STATUS "target: ${COMPILE_SHADER_TARGET}")
    message(STATUS "shader: ${COMPILE_SHADER_SHADER}")
    message(STATUS "output path: ${COMPILE_SHADER_OUTPUT_PATH}")
    set(SHADER_OUT ${COMPILE_SHADER_OUTPUT_PATH}/${SHADER_NAME}.spv)
    add_custom_command(
        OUTPUT ${SHADER_OUT}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${COMPILE_SHADER_OUTPUT_PATH}"
        COMMAND ${GLSLC} ${COMPILE_SHADER_SHADER} -o ${SHADER_OUT}
        COMMENT "Compiling ${COMPILE_SHADER_SHADER} to ${SHADER_OUT}"
        DEPENDS ${COMPILE_SHADER_SHADER}
        VERBATIM
    )
    add_custom_target(${TARGET}_compile_shader_${SHADER_NAME} ALL DEPENDS ${SHADER_OUT})
    add_dependencies(${COMPILE_SHADER_TARGET} ${TARGET}_compile_shader_${SHADER_NAME})
endfunction(compile_shader)

function(copy_resource)
    set(options USE_RELATIVE_PATHS)
    set(oneValueArgs RESOURCE OUTPUT_PATH)
    set(multiValueArgs TARGET)
    cmake_parse_arguments(COPY_RESOURCE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
    string(REGEX MATCHALL "(.*)\\/(.*)" RESOURCE_MATCH ${COPY_RESOURCE_RESOURCE})
    set(RESOURCE_NAME ${CMAKE_MATCH_2})
    message(STATUS "target: ${COPY_RESOURCE_TARGET}")
    message(STATUS "resource: ${COPY_RESOURCE_RESOURCE}")
    message(STATUS "output path: ${COPY_RESOURCE_OUTPUT_PATH}")
    set(RESOURCE_OUT ${COPY_RESOURCE_OUTPUT_PATH}/${RESOURCE_NAME})
    add_custom_command(
        OUTPUT ${RESOURCE_OUT}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${COPY_RESOURCE_OUTPUT_PATH}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${COPY_RESOURCE_RESOURCE}" "${RESOURCE_OUT}"
        COMMENT "Copying ${COPY_RESOURCE_RESOURCE} to ${RESOURCE_OUT}"
        DEPENDS ${COPY_RESOURCE_RESOURCE}
        VERBATIM
    )
    add_custom_target(${TARGET}_copy_resource_${RESOURCE_NAME} ALL DEPENDS ${RESOURCE_OUT})
    add_dependencies(${COPY_RESOURCE_TARGET} ${TARGET}_copy_resource_${RESOURCE_NAME})
endfunction(copy_resource)
