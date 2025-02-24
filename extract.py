import os
import subprocess

video_path = "Opt1-MarionetteMovements.mov"
output_folder = "naruto-motion-game/frames"

# extract frames as tif images
ffmpeg_command = [
    "ffmpeg",
    "-i", video_path, # input video file
    "-vf", "fps=30", # adj frame extraction rate (30 FPS)
    os.path.join(output_folder, "%d.tif")
]

try:
    subprocess.run(ffmpeg_command, check=True)
    print(f"Frames saved in: {output_folder}")
except subprocess.CalledProcessError as e:
    print("Error extracting frames:", e)
