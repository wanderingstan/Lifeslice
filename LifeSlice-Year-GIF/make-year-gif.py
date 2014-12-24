# Basically this script is for making a "year as animated gif" from LifeSlice images
# It geneerates 24 images, one for each hour in the day.
# Requires gifsicle 
# Requires imagemagick (convert)
# Requires progressbar
# Optionally can use find-face to determine if faces are present in image

import os
import sys
import fnmatch
import pprint
import logging
import subprocess
import tempfile
import datetime
# from progressbar import AnimatedMarker, Bar, BouncingBar, Counter, ETA, \
#                         FileTransferSpeed, FormatLabel, Percentage, \
#                         ProgressBar, ReverseBar, RotatingMarker, \
#                         SimpleProgress, Timer

target_year = 2014
final_animation_filename = '%04d.gif' % target_year
thumbs_dir = "./thumbs"
year_times_dir = "./year_at_times"
source_dir = "/Users/stan/Library/Application Support/LifeSlice/webcam_thumbs"
empty_gif = "blank.gif"
thumbnail_size = "60x45"
find_faces = False

def get_thumb_from_original(original_jpg, do_hour_gif_cache=True, extension="gif", find_faces=False):
    """
    Given a jpg of a lifeslice webcam shot in our orignal directory, create a small version and return
    its path.
    """
    source_jpg_file = os.path.join(source_dir,original_jpg)
    target_gif_file = os.path.join(thumbs_dir,original_jpg[:-4]+"."+extension) # bob.jpg --> bob.gif

    if (do_hour_gif_cache and os.path.isfile(target_gif_file)):
        # use the existing gif
        pass
    else:
        if find_faces:
            # Center image on the face
            command = ("./find-face --cascade=haarcascade_frontalface_default.xml --magickcenter '%s'" % source_jpg_file)
            shift_amount = subprocess.check_output(command,shell=True).split('\n')[0].strip() # e.g. "+3-37"
            target_pathname = original_jpg
        else:
            shift_amount=""

        if shift_amount:
            # found a face
            command = "convert '%s' -page %s -background black -flatten -resize %s -crop %s -repage %s '%s'" % (source_jpg_file, shift_amount, thumbnail_size,  thumbnail_size, thumbnail_size, target_gif_file)
        else:
            command = "convert '%s' -resize %s '%s'" % (source_jpg_file,  thumbnail_size, target_gif_file)
        # print command

        print("Command: %s", command)

        resize_output = subprocess.check_output(command,shell=True)
        # print resize_output

    return target_gif_file


def make_time_animation(year, target_time, target_animation_file, do_hour_gif_cache):
    """
    Create an image of all days in the year for a given time slice (hour) rendered in a grid. E.g. all days at 6pm. 
    """

    print "Creating image for %04d at %s" % (year, target_time)

    # delete existing animation, if there (gifsicle chokes otherwise)
    try:
        os.remove(target_animation_file)
    except:
        pass

    # create blank image of correct size
    subprocess.check_output("convert -size %s xc:black '%s'" % (thumbnail_size, empty_gif),shell=True)

    animation_gifs={}
    base=datetime.date(year,1,1)
    numdays=366

    # pbar = ProgressBar(widgets=[ETA(),' Processed:',Counter(), ' ',Timer(),' ', Percentage(), Bar('#'), ' ', ], maxval=numdays).start()
    day_gifs={}
    montage_command="montage "
    for (counter, date) in enumerate([ base + datetime.timedelta(days=x) for x in range(0,numdays) ]):
        # pbar.update(counter+1)
        sys.stdout.write('.')

        # try to load image for this date at the given time
        frame_files=fnmatch.filter(os.listdir(source_dir),"face_%04d-%02d-%02dT%s-??Z-????.jpg" % (year, date.month,date.day,target_time) )
            # % (date.month,date.day,target_time))
        if len(frame_files)==0: 
            frame_file = empty_gif
        else:
            frame_file = get_thumb_from_original(frame_files[0], extension="jpg")

        day_gifs[counter] = frame_file 
        montage_command += frame_file + " "

    # print(day_gifs)
    # TODO: Add date/time to the image. Why is this not working?
    # 21 is number of columns (or rows??)
    # montage_command += " -background black -font '/Library/Fonts/Arial.ttf' -pointsize 72 -fill white -label \"%02d:%02d wanderingstan.com\""

    # montage_command += " -background Black -fill white -font '/Library/Fonts/Arial.ttf' -pointsize 36 label:'%s at %s - LifeSlice' -gravity West  " % (year, target_time)

    montage_command += " -background gray -tile 21x -geometry +1+1 "


    montage_command += target_animation_file

    # print montage_command
    subprocess.check_output(montage_command,shell=True)
    print

    # "montage ../all-faces/*.jpg -background black -resize 25% -tile 59x -geometry +1+1 ../experiment/all.jpg"

# face_2012-12-26T12-30-????????.jpg
# face_2012-12-26T12-30-00Z-0800.jpg
# ~/Lifeslice/2012 Report/bin$ ls ../all-faces/face_2012-12-26T12-30-00Z-0800.jpg 
# print fnmatch.filter(os.listdir(source_dir),"face_2012-12-26T12-30-??Z-????.jpg")

def make_year_at_time_files(extension="gif"):
    year_at_time_files=[]
    for hour in range(0,24):

        # Add the hour
        time_file = os.path.join(year_times_dir,'%02d-00.%s' % (hour,extension))
        # time_file = os.path.join(year_times_dir,'lifeslice_hour_%04d.gif' % (hour*2))
        make_time_animation(target_year,'%02d-00' % hour, time_file, False)
        year_at_time_files.append(time_file)

        # # Add the half-hour
        # time_file = os.path.join(year_times_dir,'%02d-30.%s' % (hour,extension))
        # # time_file = os.path.join(year_times_dir,'lifeslice_hour_%04d.gif' % (hour*2 + 1))
        # make_time_animation(target_year,'%02d-30'%hour,time_file,False)
        # year_at_time_files.append(time_file)

    return year_at_time_files

def make_year_movie():
    # ffmpeg -f 1 -i /tmp/lifeslice_hour_%04d.png -c:v libx264 out.mp4
    year_at_time_files = make_year_at_time_files(extension="jpg")

    year_movie_filename = "year_%04d.avi" % target_year
    ffmpeg_command = "ffmpeg -r 4 -f image2 -pattern_type glob -i '%s/*.jpg' '%s'" % (year_times_dir, year_movie_filename)
    subprocess.check_output(ffmpeg_command, shell=True)
    print "Created %s" % year_movie_filename

def make_year_animated_gif():
    year_at_time_files = make_year_at_time_files(extension="jpg")

    year_gif_filename = "year_%04d.gif" % target_year
    target_animation_file=os.path.join(thumbs_dir, final_animation_filename)
    # gif_command = "gifsicle --loopcount=forever -d25 --colors 256 -S 60x45 " + " ".join(year_at_time_files) + " > " +target_animation_file
    gif_command = "convert -delay 35 -loop 0 '%s/*.jpg' '%s'" % (year_times_dir, year_gif_filename)
    make_gif_output = subprocess.check_output(gif_command,shell=True)


make_year_at_time_files(extension="jpg")

make_year_animated_gif()
