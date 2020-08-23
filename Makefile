.PHONY : all prepare clean build run

# variables
type:=debug

# constants
override cmake_build_type_release:=Release
override cmake_build_type_debug:=Debug
override cmake_build_type_minsizerel:=MinSizeRel
override cmake_build_type_relwithdebinfo:=RelWithDebInfo
override cmake_build_type:=$(cmake_build_type_$(type))
override cmake_build_type_arg:=$(shell echo $(cmake_build_type) | tr '[:lower:]' '[:upper:]')
override cmake_build_generator:='Unix Makefiles'
override build_path:=cmake-build-$(type)
override target:=screenshot
override os:=$(shell uname)
override valid_types:=release debug relwithdebinfo minsizerel
override cores:=$(shell sysctl -n hw.ncpu)

all: | build

clean:
	@rm -rf $(build_path)

prepare:
	@cmake -S . -B $(build_path) -DCMAKE_BUILD_TYPE=$(cmake_build_type_arg) -G $(cmake_build_generator);

build: prepare
	@cmake --build $(build_path) --target $(target) -- -j$(cores);

run: build
	@cd $(build_path) && open $(target).app
	@echo "\nProcessed finished with exit code $$?"
