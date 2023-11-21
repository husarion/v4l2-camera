ARG ROS_DISTRO=humble
ARG PREFIX=

FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-core

RUN apt update && apt install -y \
      ros-${ROS_DISTRO}-v4l2-camera \
      ros-${ROS_DISTRO}-image-transport-plugins && \
    apt clean &&  \
    rm -rf /var/lib/apt/lists/*

RUN echo $(dpkg -s ros-$ROS_DISTRO-v4l2-camera | grep 'Version' | sed -r 's/Version:\s([0-9]+.[0-9]+.[0-9]+).*/\1/g') > /version.txt