# ARG BASE_IMAGE=nvcr.io/nvidia/l4t-jetpack:r36.4.0
ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/mavtech-srl/sensor-ROS-wrappers.git"

ARG DEBIAN_FRONTEND=noninteractive

# Install requirements for building librealsense SDK
RUN apt-get update \
    && apt-get install -qq -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libssl-dev \
    libusb-1.0-0-dev \
    pkg-config \
    libgtk-3-dev \
    libglfw3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \    
    curl \
    python3 \
    python3-dev \
    ca-certificates \
    libusb-1.0-0 \
    udev \
    apt-transport-https \
    ca-certificates \
    wget \
    software-properties-common

# BE CAREFUL WITH THE SOFTWARE VERSIONS!!
#       Camera FW is v5.15.0.2 -> librealsense needs to be v2.54.1 and ROS2 Wrapper needs to be 4.54.1!!! Check in Github releases!

RUN wget https://github.com/IntelRealSense/librealsense/archive/refs/tags/v2.54.1.tar.gz -O librealsense.tar.gz \
    && mkdir librealsense \
    && tar -zxf librealsense.tar.gz -C librealsense --strip-components=1\
    && rm librealsense.tar.gz \
    && cd librealsense && \
    mkdir build && \
    cd build && \
    cmake \
        -DBUILD_EXAMPLES=true \
        -DFORCE_RSUSB_BACKEND=true \
        -DBUILD_WITH_CUDA=false \
        -DCMAKE_BUILD_TYPE=release \
        -DBUILD_PYTHON_BINDINGS=bool:true \
        -DPYTHON_EXECUTABLE=/usr/bin/python3 \
        -DPYTHON_INSTALL_DIR=$(python3 -c 'import sys; print(f"/usr/lib/python{sys.version_info.major}.{sys.version_info.minor}/dist-packages")') \
        ../ && \
    make -j$(($(nproc)-1)) && \
    make install && \
    cd ../ && \
    cp ./config/99-realsense-libusb.rules /etc/udev/rules.d/ && \
    rm -rf librealsense
    
# RUN python3 -c 'import pyrealsense2'

# Install ROS2

ARG ROS_DISTRO=humble

RUN locale
RUN apt-get update && apt-get install -y locales
RUN locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && export LANG=en_US.UTF-8

RUN locale

RUN add-apt-repository universe
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu \
         $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y ros-${ROS_DISTRO}-ros-base \
    ros-dev-tools \
    python3-colcon-common-extensions

ARG USERNAME=rs
ENV USERNAME=${USERNAME}
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# # Delete user if it exists in container (e.g Ubuntu Noble: ubuntu)
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

# # Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Install realsense ROS2 wrapper

WORKDIR /home/${USERNAME}/ros2_ws/
RUN mkdir -p src && cd src/ && \
    wget https://github.com/IntelRealSense/realsense-ros/archive/refs/tags/4.54.1.tar.gz -O rs_ros.tar.gz \
    && tar -zxf rs_ros.tar.gz \
    && rm rs_ros.tar.gz 
RUN rosdep init \
    && rosdep update \
    && rosdep install -i --from-path src --rosdistro $ROS_DISTRO --skip-keys=librealsense2 -y

# https://robotics.stackexchange.com/questions/91133/create-dockerfile-for-ros2-package-ament-cmake-error
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
    && colcon build \
    && . install/setup.sh

RUN mkdir -p /opt/realsense/
COPY ./hotplug-realsense.sh /opt/realsense/hotplug-realsense.sh
COPY ./99-realsense-libusb-custom.rules /etc/udev/rules.d/99-realsense-libusb-custom.rules

COPY ./ros_entrypoint.sh /
RUN chmod +x /ros_entrypoint.sh && /ros_entrypoint.sh
ENTRYPOINT [ "/bin/bash", "/ros_entrypoint.sh" ]
CMD ["bash"]