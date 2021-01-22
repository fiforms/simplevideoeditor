# simplevideoeditor
A Simple Front-end to FFMPEG to cut and concatenate videos. This is a very simple script written in AutoIt (https://www.autoitscript.com/site/autoit/) to automate some common tasks that I like to do im FFMPEG. I use it to do fast, lossless cutting of video clips from my mobile phone, digital camera, drone etc. It uses FFMPEG's features to cut the video stream on keyframes and copy the audio and video lossless. There's also a "Concatenate" feature and "Multiplex" feature to strip and add audio to the video file. With these features, you can do simple editing of large video files without re-encoding. 

# Caveats: 
*Cutting on keyframes isn't precise, as FFMPEG must search backward from the given time to find the nearest keyframe. Depending on the video file, this may add a few seconds of video before the start of audio, leading to the audio being out of sync later on. 
*Concatenation requires that all video files are exactly the same (i.e. produced by the same device/software with the same settings). Otherwise, the resulting file is unplayable.


# Using SimpleVideoEditor
You must first install ffmpeg. This script expects ffmpeg.exe to reside in "C:\Program Files (x86)\ffmpeg\ffmpeg.exe". Future versions will allow customization of this path. You can download ffmpeg here: https://ffmpeg.org/download.html
