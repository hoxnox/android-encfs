#/bin/bash

export ANDROID_TOOLCHAIN=$1
export INSTALL_DIR=$2

export ANDROID_SYSROOT=${ANDROID_TOOLCHAIN}/sysroot
export ARCH=$(basename ${ANDROID_TOOLCHAIN}/bin/*gcc | cut -d- -f1)
if [[ $ARCH = "arm" ]]; then
	export MACHINE=armv7
else
	export MACHINE=$ARCH
fi
export SYSTEM=android
export CROSS_COMPILE=$(basename ${ANDROID_TOOLCHAIN}/bin/*gcc | cut -d- -f1,2,3 )-
export ANDROID_SYSROOT=${ANDROID_SYSROOT}
export ANDROID_API=android
export SYSROOT=${ANDROID_SYSROOT}
export NDK_SYSROOT=${ANDROID_SYSROOT}
export ANDROID_NDK_SYSROOT=${ANDROID_SYSROOT}
export ANDROID_DEV=${ANDROID_SYSROOT}/usr
export HOSTCC=gcc
export PATH=${ANDROID_TOOLCHAIN}/bin:${PATH}

./config no-rc2 no-rc4 no-rc5 no-idea no-camellia no-des no-cast       \
         no-md2 no-md4 no-ripemd no-mdc2 no-whirlpool no-patents       \
         no-dsa no-dh no-asm no-ssl2 no-ssl3 no-srp no-cms             \
         no-ec2m no-jpake no-ec_nistp_64_gcc_128                       \
         no-weak-ssl-ciphers no-sock no-krb5 no-ec no-ecdsa            \
         no-ecdh no-gost no-engine no-hw no-rsax no-sctp no-srtp       \
         no-rfc3779 no-montasm no-shared no-store no-unit-test         \
         no-zlib no-zlib-dynamic no-comp                               \
         --openssldir=${INSTALL_DIR}                                   \
    && make depend                                                     \
    && make build_libs                                                 \
    && mkdir -p ${INSTALL_DIR}/lib                                     \
    && mkdir -p ${INSTALL_DIR}/include                                 \
    && cp -rL include/* ${INSTALL_DIR}/include                          \
    && cp libcrypto.a ${INSTALL_DIR}/lib                               \
    && cp libssl.a ${INSTALL_DIR}/lib
