#!/bin/sh

# add sourcing to .bashrc
echo "export ROS_DISTRO=humble" >> ~/.bashrc
echo "source /opt/ros/\$ROS_DISTRO/setup.bash" >> ~/.bashrc
echo "source ~/ros2_ws/install/local_setup.bash" >> ~/.bashrc

# setup ros2 environment
export ROS_DISTRO=humble
source /opt/ros/"$ROS_DISTRO"/setup.bash --
source ~/ros2_ws/install/local_setup.bash --

ros2 launch realsense2_camera rs_launch.py enable_accel:=true enable_gyro:=true pointcloud.enable:=true unite_imu_method:=2 align_depth.enable:=true enable_sync:=true

exec "$@"
