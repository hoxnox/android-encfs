cmake_minimum_required(VERSION 3.0.0)
project(android-encfs)

option(ANDROID_TOOLCHAIN        "Path to Android toolchain" "/android/toolchain")
option(ANDROID_TOOLCHAIN_PREFIX "Prefix for utilites"       "")
option(VENDOR_DIR               "Local directory with dependencies" "")
set(STAGING_DIR "${CMAKE_BINARY_DIR}/staging")

########################################################################
# openssl

if (VENDOR_DIR)
	set(OPENSSL_URL "file:///${VENDOR_DIR}/openssl/openssl/openssl-1.0.1t.tar.gz")
else ()
	set(OPENSSL_URL "https://www.openssl.org/source/openssl-1.0.1t.tar.gz")
endif ()

include(ExternalProject)
ExternalProject_Add(openssl
	URL ${OPENSSL_URL}
	URL_HASH SHA256=4a6ee491a2fdb22e519c76fdc2a628bb3cec12762cd456861d207996c8a07088
	CONFIGURE_COMMAND ""
	BUILD_COMMAND "${PROJECT_SOURCE_DIR}/files/openssl-build.sh" "${ANDROID_TOOLCHAIN}" "${STAGING_DIR}"
	INSTALL_COMMAND ""
	BUILD_IN_SOURCE 1
)

########################################################################
# fuse

if (VENDOR_DIR)
	set(FUSE_URL "file:///${VENDOR_DIR}/libfuse/libfuse/fuse-2.9.7.tar.gz")
else ()
	set(FUSE_URL "https://github.com/libfuse/libfuse/releases/download/fuse-2.9.7/fuse-2.9.7.tar.gz")
endif ()

if (NOT ANDROID_TOOLCHAIN_PREFIX)
	execute_process(COMMAND /bin/bash -c "basename ${ANDROID_TOOLCHAIN}/bin/*gcc"
		OUTPUT_VARIABLE GCC_NAME_FROM_TOOLCHAIN)
	string(FIND ${GCC_NAME_FROM_TOOLCHAIN} "-" LAST_HYPEN REVERSE)
	string(SUBSTRING ${GCC_NAME_FROM_TOOLCHAIN} 0 ${LAST_HYPEN} ANDROID_TOOLCHAIN_PREFIX_CALCULATED)
	message(STATUS "Caclulated toolchain prefix: ${ANDROID_TOOLCHAIN_PREFIX_CALCULATED}")
	set(ANDROID_TOOLCHAIN_PREFIX ${ANDROID_TOOLCHAIN_PREFIX_CALCULATED})
endif ()

include(ExternalProject)
ExternalProject_Add(fuse
	URL ${FUSE_URL}
	URL_HASH SHA256=832432d1ad4f833c20e13b57cf40ce5277a9d33e483205fc63c78111b3358874
	PATCH_COMMAND patch -p1 < "${PROJECT_SOURCE_DIR}/files/fuse-2.9.7.patch"
	CONFIGURE_COMMAND ./configure CFLAGS=-D__ANDROID__ --disable-shared
		--enable-static --host=${ANDROID_TOOLCHAIN_PREFIX}
		--with-sysroot=${ANDROID_TOOLCHAIN}/sysroot
		--disable-shared --enable-static --disable-example
		--disable-util --prefix=<INSTALL_DIR>
	INSTALL_DIR ${STAGING_DIR}
	BUILD_IN_SOURCE 1
)

########################################################################
# encfs

if (VENDOR_DIR)
	set(ENCFS_URL "file:///${VENDOR_DIR}/vgough/encfs/encfs-1.9-rc1.tar.gz")
else ()
	set(ENCFS_URL "https://github.com/vgough/encfs/archive/v1.9-rc1.tar.gz")
endif ()

include(ExternalProject)
ExternalProject_Add(encfs
	URL ${ENCFS_URL}
	URL_HASH SHA256=ff16b824fdf613d69bb252fbe024a2ebcc9046e36fc639790182e19877067a44
	PATCH_COMMAND patch -p1 < "${PROJECT_SOURCE_DIR}/files/encfs-1.9-rc1.patch"
	CONFIGURE_COMMAND cmake -DCMAKE_C_FLAGS="-D__ANDROID__ -DBUILD_NLS=0 -fPIE -fPIC"
		-DCMAKE_EXE_LINKER_FLAGS="-pie" -DFUSE_USE_STATIC_LIBS=True
		-DCMAKE_C_COMPILER=${ANDROID_TOOLCHAIN}/bin/${ANDROID_TOOLCHAIN_PREFIX}-gcc
		-DCMAKE_CXX_COMPILER=${ANDROID_TOOLCHAIN}/bin/${ANDROID_TOOLCHAIN_PREFIX}-g++
		-DCMAKE_FIND_ROOT_PATH=${STAGING_DIR}
		-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
		-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> <SOURCE_DIR>
	DEPENDS openssl fuse
	INSTALL_DIR ${STAGING_DIR}
)

