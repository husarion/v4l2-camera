from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, OpaqueFunction
from launch_ros.actions import Node, PushRosNamespace
from launch.substitutions import EnvironmentVariable, LaunchConfiguration


def launch_setup(context, *args, **kwargs):
    params_file = LaunchConfiguration("params_file").perform(context)
    ffmpeg_params_file = LaunchConfiguration("ffmpeg_params_file").perform(context)
    # foxglove_params_file = LaunchConfiguration("foxglove_params_file").perform(context)
    video_device = LaunchConfiguration("video_device").perform(context)

    camera_node = Node(
        package="usb_cam",
        executable="usb_cam_node_exe",
        # name="camera",
        parameters=[
            {
                "video_device": video_device,
            },
            params_file,
            ffmpeg_params_file,
            # foxglove_params_file,
        ],
        output="screen",
    )

    return [camera_node]

def generate_launch_description():
    return LaunchDescription(
        [
            DeclareLaunchArgument(
                "params_file",
                default_value="/camera_params.yaml",
                description="Full path to the Camera parameters file",
            ),
            DeclareLaunchArgument(
                "ffmpeg_params_file",
                default_value="/ffmpeg_params.yaml",
                description="Full path to the FFMPEG plugin parameters file",
            ),
            # DeclareLaunchArgument(
            #     "foxglove_params_file",
            #     default_value="/foxglove_params.yaml",
            #     description="Full path to the foxglove plugin parameters file",
            # ),
            DeclareLaunchArgument(
                "video_device",
                default_value="/dev/video0",
                description="Path to the video device file.",
            ),
            OpaqueFunction(function=launch_setup),
        ]
    )