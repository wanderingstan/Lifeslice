# Basically this script is for making a "year as animated gif" from LifeSlice images

import os
import sys
import fnmatch
import pprint
import logging
import subprocess
import tempfile
import datetime
from progressbar import AnimatedMarker, Bar, BouncingBar, Counter, ETA, \
                        FileTransferSpeed, FormatLabel, Percentage, \
                        ProgressBar, ReverseBar, RotatingMarker, \
                        SimpleProgress, Timer

final_animation_filename = '2012.gif'
target_dir = "../animation"
source_dir = "../all-faces"
# temp_dir = tempfile.gettempdir()
temp_dir = "/tmp"
empty_gif = "blank.gif"
find_faces = False


def get_gif_from_original(original_jpg, do_hour_gif_cache=True, find_faces=False):
    """
    Given a jpg of a lifeslice webcam shot in our orignal directory, create a small gif version and return
    its path.
    """
    source_jpg_file = os.path.join(source_dir,original_jpg)
    target_gif_file = os.path.join(target_dir,original_jpg[:-4]+".gif") # bob.jpg --> bob.gif

    if (do_hour_gif_cache and os.path.isfile(target_gif_file)):
        # use the existing gif
        pass
    else:
        if find_faces:
            command = ("./find-face --cascade=haarcascade_frontalface_default.xml --magickcenter %s" % source_jpg_file)
            shift_amount = subprocess.check_output(command,shell=True).split('\n')[0].strip() # e.g. "+3-37"
            target_pathname = original_jpg
        else:
            shift_amount=""

        if shift_amount:
            # found a face
            command = "convert %s -page %s -background black -flatten -resize 60x45 -crop 60x45 -repage 60x45 %s" % (source_jpg_file, shift_amount, target_gif_file)
        else:
            command = "convert %s -resize 60x45 %s" % (source_jpg_file, target_gif_file)
        # print command

        resize_output = subprocess.check_output(command,shell=True)
        # print resize_output

    return target_gif_file


def make_time_animation(target_time, target_animation_file, do_hour_gif_cache):
    """
    Create a GIF of all days in the year, with a given time slice rendered. E.g. all days at 6pm. 
    """

    # delete existing animation, if there (gifsicle chokes otherwise)
    try:
        os.remove(target_animation_file)
    except:
        pass

    # create blank
    subprocess.check_output("convert -size 60x45 xc:black %s" % (empty_gif),shell=True)

    animation_gifs={}
    base = datetime.date(2012,1,1)
    numdays=366

    pbar = ProgressBar(widgets=[ETA(),' Processed:',Counter(), ' ',Timer(),' ', Percentage(), Bar('#'), ' ', ], maxval=numdays).start()
    day_gifs={}
    montage_command="montage "
    for (counter, date) in enumerate([ base + datetime.timedelta(days=x) for x in range(0,numdays) ]):
        pbar.update(counter+1)

        # try to load image for this date at the given time
        frame_files=fnmatch.filter(os.listdir(source_dir),"face_2012-%02d-%02dT%s-??Z-????.jpg" % (date.month,date.day,target_time) )
            # % (date.month,date.day,target_time))
        if len(frame_files)==0: 
            frame_file = empty_gif
        else:
            frame_file = get_gif_from_original(frame_files[0])

        day_gifs[counter] = frame_file 
        montage_command += frame_file + " "

    # print(day_gifs)
    montage_command += "-background black -pointsize 72 -fill white -label \"%02d:%02d wanderingstan.com\" -tile 21x -geometry +1+1 %s" % (date.month,date.day,target_animation_file)
    print montage_command
    subprocess.check_output(montage_command,shell=True)

    # "montage ../all-faces/*.jpg -background black -resize 25% -tile 59x -geometry +1+1 ../experiment/all.jpg"

# face_2012-12-26T12-30-????????.jpg
# face_2012-12-26T12-30-00Z-0800.jpg
# ~/Lifeslice/2012 Report/bin$ ls ../all-faces/face_2012-12-26T12-30-00Z-0800.jpg 
# print fnmatch.filter(os.listdir(source_dir),"face_2012-12-26T12-30-??Z-????.jpg")

gifsicle_files=[]
for hour in range(0,24):
    time_file = os.path.join(temp_dir,'%02d-00.gif'%hour)
    make_time_animation('%02d-00'%hour,time_file,False)
    gifsicle_files.append(time_file)

    time_file = os.path.join(temp_dir,'%02d-30.gif'%hour)
    make_time_animation('%02d-30'%hour,time_file,False)
    gifsicle_files.append(time_file)

target_animation_file=os.path.join(target_dir, final_animation_filename)
gifsicle_command = "gifsicle --loopcount=forever -d25 --colors 256 -S 60x45 " + " ".join(gifsicle_files) + " > " +target_animation_file
make_gif_output = subprocess.check_output(gifsicle_command,shell=True)
