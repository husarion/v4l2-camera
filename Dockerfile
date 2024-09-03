ARG ROS_DISTRO=humble
ARG PREFIX=

FROM ros:${ROS_DISTRO}-ros-base AS build

SHELL ["/bin/bash", "-c"]

ARG repo=foxglove_compressed_video_transport
ARG url=https://github.com/ros-misc-utilities/${repo}.git

WORKDIR /ros2_ws

# Clone the repository
RUN git clone --depth 1 -b master ${url} src/${repo} && \
    if [ -f src/${repo}/${repo}.repos ]; then \
      vcs import < src/${repo}/${repo}.repos; \
    fi

# Create a script to install runtime dependencies for final image
RUN apt update && \
    rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} --reinstall --simulate -y --dependency-types exec >> /rosdep_install.sh && \
    chmod +x /rosdep_install.sh

# Build the workspace
RUN apt update && \
    rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y  && \
    source /opt/ros/${ROS_DISTRO}/setup.bash && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    rm -rf build log src

FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-core

COPY --from=build /ros2_ws /ros2_ws
COPY --from=build /rosdep_install.sh /rosdep_install.sh

RUN apt update && \
    /rosdep_install.sh && \
    apt install -y \
      ffmpeg \
      libpulse-dev \
      libblas3 \
      libjpeg-turbo8-dev \
      ros-${ROS_DISTRO}-usb-cam \
      ros-${ROS_DISTRO}-cv-bridge \
      ros-${ROS_DISTRO}-image-transport \
      ros-${ROS_DISTRO}-image-transport-plugins \
      ros-${ROS_DISTRO}-ffmpeg-image-transport && \
    apt clean &&  \
    rm -rf /var/lib/apt/lists/*

RUN echo $(dpkg -s ros-$ROS_DISTRO-usb-cam | grep 'Version' | sed -r 's/Version:\s([0-9]+.[0-9]+.[0-9]+).*/\1/g') > /version.txt