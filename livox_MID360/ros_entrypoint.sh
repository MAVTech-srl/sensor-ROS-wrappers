#!/bin/bash

# add sourcing to .bashrc
echo "export ROS_DISTRO=humble" >> ~/.bashrc
echo "source /opt/ros/\$ROS_DISTRO/setup.bash" >> ~/.bashrc
echo "source ~/ros2_ws/install/local_setup.bash" >> ~/.bashrc

# setup ros2 environment
export ROS_DISTRO=humble
source /opt/ros/"$ROS_DISTRO"/setup.bash --
source ~/ros2_ws/install/local_setup.bash --

ros2 launch livox_ros_driver2 msg_MID360_launch.py

exec "$@"
