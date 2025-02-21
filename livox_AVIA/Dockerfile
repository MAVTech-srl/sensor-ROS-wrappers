#################################
#   Librealsense Builder Stage  #
#################################


ARG BASE_IMAGE=nvcr.io/nvidia/l4t-jetpack:r36.4.0
FROM ${BASE_IMAGE} AS livox-ros-wrapper

# To avoid waiting for input during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Builder dependencies installation
RUN apt-get update \
&& apt-get install -qq -y --no-install-recommends \
build-essential \
cmake \
git \
apt-transport-https \
ca-certificates \
wget \
software-properties-common \
curl
# && rm -rf /var/lib/apt/lists/*


# Download sources
WORKDIR /usr/src

# I need to use a forked repo of livox sdk since the original gives errors when compiling due to missing
# #include <memory> line in thread_base.h file
# RUN git clone https://github.com/Livox-SDK/Livox-SDK.git \ 
RUN git clone https://github.com/shenxw0127/Livox-SDK-24.04.git ./Livox-SDK \
    && cd Livox-SDK \
    && cd build && cmake .. \
    && make -j4 \
    && make install

# Install ROS2 base

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
    python3-colcon-common-extensions \
    nano \
    ros-humble-perception-pcl

ARG USERNAME=rosdev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# # Delete user if it exists in container (e.g Ubuntu Noble: ubuntu)
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

# # Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME 


WORKDIR /home/${USERNAME}/ros2_ws/
RUN mkdir -p src && cd src/ && \
    git clone https://github.com/Livox-SDK/livox_ros2_driver.git ./livox_ros2_driver

COPY ./livox_lidar_config.json /home/${USERNAME}/ros2_ws/src/livox_ros2_driver/livox_ros2_driver/config/livox_lidar_config.json
COPY ./livox_lidar_msg_launch.py /home/${USERNAME}/ros2_ws/src/livox_ros2_driver/livox_ros2_driver/launch/livox_lidar_msg_launch.py

# RUN . /opt/ros/humble/setup.sh \
#     && cd src/livox_ros_driver2 && ./build.sh humble
# RUN . install/setup.sh && . install/local_setup.sh
RUN . /opt/ros/humble/setup.sh && colcon build

ENV SHELL="/bin/bash"

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
COPY ./ros_entrypoint.sh /
# RUN chmod +x /ros_entrypoint.sh && /ros_entrypoint.sh
ENTRYPOINT [ "/bin/bash", "/ros_entrypoint.sh" ]
CMD ["bash"]
