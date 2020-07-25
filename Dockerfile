FROM ubuntu:18.04

WORKDIR "/"

# Run system software update
RUN apt-get update
RUN apt-get upgrade -y

# Install system dependencies
RUN apt-get install -y wget unzip

################### SFML ###################

RUN apt-get install -y libsfml-dev

################### EIGEN ###################

RUN apt-get install -y libeigen3-dev

################### OPENCV ###################

WORKDIR "/usr/local/share"
# Install dependencies for OpenCV
RUN apt-get install -y build-essential
RUN apt-get install -y cmake git libgtk2.0-dev pkg-config libavcodec-dev \
	libavformat-dev libswscale-dev libtbb2 libtbb-dev libjpeg-dev \
	libpng-dev libtiff-dev libdc1394-22-dev

# Download OpenCV tarball
RUN wget -O /tmp/3.4.7.zip https://github.com/opencv/opencv/archive/3.4.7.zip

# Unpack OpenCV tarball
RUN unzip /tmp/3.4.7.zip

# Download OpenCV contrib modules
RUN git clone https://github.com/opencv/opencv_contrib
WORKDIR "/usr/local/share/opencv_contrib"
RUN git checkout 3.4.7

# Enable only specific contrib modules
RUN mkdir enabled_modules
RUN cp -r modules/aruco enabled_modules/
WORKDIR "/usr/local/share"

# Configure OpenCV build
WORKDIR "/usr/local/share/opencv-3.4.7"
RUN mkdir build
WORKDIR "/usr/local/share/opencv-3.4.7/build"
RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DENABLE_PRECOMPILED_HEADERS=OFF \
	-DOPENCV_EXTRA_MODULES_PATH=/usr/local/share/opencv_contrib/enabled_modules/ \
	-DBUILD_OPENEXR=OFF -DWITH_OPENEXR=OFF -DBUILD_PROTOBUF=OFF \
	-DWITH_PROTOBUF=OFF\
	..

# Build OpenCV
# (note we can't use a parallel build here because Docker seems to have some kind of
#  memory leak bug when doing parallel builds. So unfortunately this will be slow)
RUN make

# Install OpenCV
RUN make install

WORKDIR "/"

################### CATCH2 ###################
WORKDIR "/usr/local/share"

# Download Catch2
RUN git clone https://github.com/catchorg/catch2

# Configure Catch2
WORKDIR "/usr/local/share/catch2"
RUN mkdir build
WORKDIR "/usr/local/share/catch2/build"
RUN cmake ..

# Build Catch2
RUN make

# Install Catch2
RUN make install

WORKDIR "/"

################### LIDAR ###################

WORKDIR "/usr/local/share"

# Download the URG Lidar library
RUN git clone https://github.com/andrewbriand/urg_library-1.2.5.git
WORKDIR "/usr/local/share/urg_library-1.2.5"

# Build URG library
RUN make

# Install URG library
RUN make install

WORKDIR "/"
