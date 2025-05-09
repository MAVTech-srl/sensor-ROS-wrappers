docker build -t ghcr.io/mavtech-srl/livox_avia:0.1 -f Dockerfile .

DOCKER_ARGS+=("-v /tmp/.X11-unix:/tmp/.X11-unix")
DOCKER_ARGS+=("-v $HOME/.Xauthority:/home/rs/.Xauthority:rw")
DOCKER_ARGS+=("-e DISPLAY")
DOCKER_ARGS+=("-e NVIDIA_VISIBLE_DEVICES=all")
DOCKER_ARGS+=("-e NVIDIA_DRIVER_CAPABILITIES=all")
DOCKER_ARGS+=("--user 1000")
#DOCKER_ARGS+=("-e USER")
#DOCKER_ARGS+=("-e HOST_USER_UID=`id -u`")
#DOCKER_ARGS+=("-e HOST_USER_GID=`id -g`")

DOCKER_ARGS+=("-e NVIDIA_VISIBLE_DEVICES=nvidia.com/gpu=all,nvidia.com/pva=all")
DOCKER_ARGS+=("-v /usr/bin/tegrastats:/usr/bin/tegrastats")
DOCKER_ARGS+=("-v /tmp/:/tmp/")
DOCKER_ARGS+=("-v /usr/lib/aarch64-linux-gnu/tegra:/usr/lib/aarch64-linux-gnu/tegra")
DOCKER_ARGS+=("-v /usr/src/jetson_multimedia_api:/usr/src/jetson_multimedia_api")
DOCKER_ARGS+=("--pid=host")
DOCKER_ARGS+=("-v /usr/share/vpi3:/usr/share/vpi3")
DOCKER_ARGS+=("-v /dev/input:/dev/input")    
    
docker run -it --rm \
    --privileged \
    --network host \
    --ipc=host \
    ${DOCKER_ARGS[@]} \
    --runtime nvidia \
    ghcr.io/mavtech-srl/livox_avia:0.1

