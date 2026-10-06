cmake_minimum_required(VERSION 3.20)

project(DXVision
    VERSION 0.1.0
    LANGUAGES CXX
)

option(DXV_BUILD_TESTS "Build DXVision tests" OFF)

set(DXV_ROOT_DIR        ${CMAKE_CURRENT_SOURCE_DIR})
set(DXV_INCLUDE_DIR     ${DXV_ROOT_DIR}/include)
set(DXV_SRC_DIR         ${DXV_ROOT_DIR}/src)
set(DXV_SHADER_SRC_DIR  ${DXV_ROOT_DIR}/shaders)
set(DXV_BIN_DIR         ${DXV_ROOT_DIR}/bin)
set(DXV_SHADER_BIN_DIR  ${DXV_BIN_DIR}/shaders)

set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS 1 CACHE INTERNAL "Suppress dev warnings")

file(MAKE_DIRECTORY ${DXV_SHADER_BIN_DIR})

set(DXV_HEADERS
    ${DXV_INCLUDE_DIR}/dxvision.h
    ${DXV_INCLUDE_DIR}/dxv_device.h
    ${DXV_INCLUDE_DIR}/dxv_pipeline.h
    ${DXV_INCLUDE_DIR}/dxv_constants.h
    ${DXV_INCLUDE_DIR}/dxv_texture.h
    ${DXV_INCLUDE_DIR}/dxv_errors.h
    ${DXV_INCLUDE_DIR}/dxv_utils.h
    ${DXV_INCLUDE_DIR}/dxv_math.h
)

set(DXV_SOURCES
    ${DXV_SRC_DIR}/dxvision.cpp
    ${DXV_SRC_DIR}/dxv_device.cpp
    ${DXV_SRC_DIR}/dxv_pipeline.cpp
    ${DXV_SRC_DIR}/dxv_constants.cpp
    ${DXV_SRC_DIR}/dxv_texture.cpp
    ${DXV_SRC_DIR}/dxv_errors.cpp
    ${DXV_SRC_DIR}/dxv_utils.cpp
)

if(EXISTS "${DXV_SRC_DIR}/dxv_capture.cpp")
    list(APPEND DXV_SOURCES ${DXV_SRC_DIR}/dxv_capture.cpp)
endif()

# ------------------------------------------------------------
# Shader compilation using DXC (DX11: DXBC output)
# ------------------------------------------------------------

find_program(DXC_EXECUTABLE dxc REQUIRED)

set(DXV_SHADER_SOURCES
    fullscreen_vs.hlsl
    blur_ps.hlsl
    distortion_ps.hlsl
    chromatic_ps.hlsl
    composite_ps.hlsl
)

set(DXV_SHADER_OUTPUTS "")

function(dxv_add_shader SHADER_NAME PROFILE)
    set(src "${DXV_SHADER_SRC_DIR}/${SHADER_NAME}")
    get_filename_component(base "${SHADER_NAME}" NAME_WE)
    set(out "${DXV_SHADER_BIN_DIR}/${base}.cso")

    add_custom_command(
        OUTPUT ${out}
        COMMAND ${DXC_EXECUTABLE}
                -T ${PROFILE}
                -Fo ${out}
                ${src}
        DEPENDS ${src}
        COMMENT "Compiling HLSL shader ${SHADER_NAME} -> ${out}"
        VERBATIM
    )

    set(DXV_SHADER_OUTPUTS ${DXV_SHADER_OUTPUTS} ${out} PARENT_SCOPE)
endfunction()

dxv_add_shader(fullscreen_vs.hlsl vs_5_0)
dxv_add_shader(blur_ps.hlsl        ps_5_0)
dxv_add_shader(distortion_ps.hlsl  ps_5_0)
dxv_add_shader(chromatic_ps.hlsl   ps_5_0)
dxv_add_shader(composite_ps.hlsl   ps_5_0)

add_custom_target(DXVisionShaders ALL
    DEPENDS ${DXV_SHADER_OUTPUTS}
)

# ------------------------------------------------------------
# DXVision library
# ------------------------------------------------------------

add_library(DXVision SHARED
    ${DXV_SOURCES}
    ${DXV_HEADERS}
)

add_dependencies(DXVision DXVisionShaders)

target_include_directories(DXVision
    PUBLIC
        ${DXV_INCLUDE_DIR}
)

target_compile_features(DXVision PUBLIC cxx_std_20)

target_compile_definitions(DXVision
    PRIVATE DXV_BUILD_DLL
)

# ------------------------------------------------------------
# Output directories
# ------------------------------------------------------------
set_target_properties(DXVision PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY         ${DXV_BIN_DIR}
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${DXV_BIN_DIR}
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${DXV_BIN_DIR}
    ARCHIVE_OUTPUT_DIRECTORY         ${DXV_BIN_DIR}
    LIBRARY_OUTPUT_DIRECTORY         ${DXV_BIN_DIR}
)

# ------------------------------------------------------------
# DirectX / Windows libraries
# ------------------------------------------------------------
if(MSVC)
    target_compile_definitions(DXVision PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

target_link_libraries(DXVision
    PRIVATE
        d3d11
        dxgi
        d3dcompiler
)

# ------------------------------------------------------------
# Install + CMake package config
# ------------------------------------------------------------
include(CMakePackageConfigHelpers)
set(CMAKE_INSTALL_PREFIX "D:/DLLs/CMkL.build/

set(DXV_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/include")
set(DXV_INSTALL_LIB_DIR     "${CMAKE_INSTALL_PREFIX}/lib")
set(DXV_INSTALL_CMAKE_DIR   "${CMAKE_INSTALL_PREFIX}/lib/cmake/DXVision")

install(TARGETS DXVision
    EXPORT DXVisionTargets
    RUNTIME DESTINATION ${DXV_INSTALL_LIB_DIR}
    LIBRARY DESTINATION ${DXV_INSTALL_LIB_DIR}
    ARCHIVE DESTINATION ${DXV_INSTALL_LIB_DIR}
)

install(DIRECTORY ${DXV_INCLUDE_DIR}/
    DESTINATION ${DXV_INSTALL_INCLUDE_DIR}
)

install(DIRECTORY ${DXV_SHADER_BIN_DIR}/
    DESTINATION ${DXV_INSTALL_LIB_DIR}/shaders
)

install(EXPORT DXVisionTargets
    FILE DXVisionTargets.cmake
    NAMESPACE DXVision::
    DESTINATION ${DXV_INSTALL_CMAKE_DIR}
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/DXVisionConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DXVisionConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/DXVisionConfig.cmake"
    INSTALL_DESTINATION ${DXV_INSTALL_CMAKE_DIR}
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/DXVisionConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/DXVisionConfigVersion.cmake"
    DESTINATION ${DXV_INSTALL_CMAKE_DIR}
)

if(DXV_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()