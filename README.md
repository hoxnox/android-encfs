Set of patches and cmake script to build [openssl](http://openssl.org),
[libfuse](https://github.com/libfuse/libfuse) and
[encfs](https://github.com/vgough/encfs) for Android.

Tested on Linux. Need some improvements to work on Windows.

## Building

1. Install Android NDK according to your OS
   [android NDK](https://developer.android.com/ndk/downloads/index.html)

2. Prepare standalone toolchain for you Android:

   ```sh
   /opt/android-ndk/build/tools/make-standalone-toolchain.sh --arch=arm \
   	--ndk-dir=/opt/android-ndk --install-dir=/home/user/devel/android/toolchain \
   	--platform=android-21 --system=linux-x86_64
   ```

3. Go to sources, configure and build:

   ```sh
   mkdir build && cd build
   cmake -DANDROID_TOOLCHAIN=/home/user/devel/android/toolchain ..
   make
   ```

## Building on standalone server

You can build on a standalone server (without Internet connection).
Create vendor directory with the following structure (links to download
you can see in CMakeLists.txt file):

```
vendor
├── libfuse
│   └── libfuse
│       └── fuse-2.9.7.tar.gz
├── openssl
│   └── openssl
│       └── openssl-1.0.1t.tar.gz
└── vgough
    └── encfs
            └── encfs-1.9-rc1.tar.gz
```

Use `VENDOR_DIR` during configuration:

   ```sh
   cmake -DANDROID_TOOLCHAIN=/home/user/devel/android/toolchain -DVENDOR_DIR=/home/user/vendor
   ```

