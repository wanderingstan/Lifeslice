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


target_dir = "../animation"
source_dir = "../all-faces"
# temp_dir = tempfile.gettempdir()
temp_dir = "/tmp"
empty_gif = "blank.gif"
find_faces = False

def make_day_animation(target_date, target_animation_file, do_hour_gif_cache):

    # delete existing animation, if there (gifsicle chokes otherwise)
    try:
        os.remove(target_animation_file)
    except:
        pass

    # start with list of empty gifs (to be replaced with photos when we have them)
    animation_gifs={}
    for hour in range(0,24):
        animation_gifs["%0d-00" % hour] = empty_gif
        animation_gifs["%0d-30" % hour] = empty_gif

    # create blanks
    subprocess.check_output("convert -size 60x45 xc:black "+empty_gif,shell=True)

    # # Show time in blanks
    # for hour in range(0,24):
    #     time_empty_gif = "%02d-%s" % (hour,empty_gif)
    #     if not os.path.isfile(time_empty_gif):
    #         subprocess.check_output("convert -size 60x45 -gravity east -background black -fill gray caption:%d  %s" % (hour,time_empty_gif),shell=True)
    #     animation_gifs["%0d-00" % hour] = time_empty_gif
    #     animation_gifs["%0d-30" % hour] = time_empty_gif

    # get all images for a given day
    day_photo_files=fnmatch.filter(os.listdir(source_dir),"face_%sT??-??-????????.jpg" % (target_date))

    day_photo_files.sort()

    if len(day_photo_files)==0:
        print "No files found."
        return()

    # convert_to_gif_commands = map((lambda day_file:"convert '%s' -scale 25%% '%s.gif'" % (os.path.join(target_dir,day_file), os.path.join(temp_dir,day_file))),day_photo_files)
    # print convert_to_gif_commands

    # count=0
    # pbar = ProgressBar(widgets=self.progress_widgets, maxval=count(convert_to_gif_commands)).start()
    # for command in convert_to_gif_commands:
    #   subprocess.check_call(command,shell=True)
    #   count++
    #     pbar.update(count)

    pbar = ProgressBar(widgets=[ETA(),' Processed:',Counter(), ' ',Timer(),' ', Percentage(), Bar('#'), ' ', ], maxval=len(day_photo_files))
    pbar.start()
    for (counter, day) in enumerate(day_photo_files):
        # print day
        pbar.update(counter+1)

        source_jpg_file = os.path.join(source_dir,day)
        target_gif_file = os.path.join(temp_dir,day[:-4]+".gif")

        if (do_hour_gif_cache and os.path.isfile(target_gif_file)):
            # use the existing gif
            pass
        else:
            if find_faces:
                command = ("./find-face --cascade=haarcascade_frontalface_default.xml --magickcenter %s" % source_jpg_file)
                shift_amount = subprocess.check_output(command,shell=True).split('\n')[0].strip() # e.g. "+3-37"
                target_pathname = day
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

        # stick in animation
        animation_gifs[day[16:21]] = target_gif_file

    gifsicle_command = "gifsicle --loopcount=forever -d25  --colors 256 -S 60x45 "
    for key in sorted(animation_gifs.iterkeys()):
        # print "%s: %s" % (key, animation_gifs[key])
        gifsicle_command += animation_gifs[key] + " "
    gifsicle_command += " > "+target_animation_file

    # gifsicle to make the animated gif 
    # print gifsicle_command

    make_gif_output = subprocess.check_output(gifsicle_command,shell=True)


#
# Make animations for each day
#
f = open('2012-as-gifs.html', 'w')
f.write('<html><body style="background-color:black">')
numdays=366
main_pbar = ProgressBar(widgets=[ETA(),' Processed:',Counter(), ' ',Timer(),' ', Percentage(), Bar('#'), ' ', ], maxval=numdays)
main_pbar.start()
base = datetime.date(2012,1,1)
for (counter, date) in enumerate([ base + datetime.timedelta(days=x) for x in range(0,numdays) ]):
    target_date = "%04d-%02d-%02d" % (date.year,date.month,date.day)
    # print target_date
    target_animation_file = os.path.join(target_dir,target_date+'day_animation.gif')
    make_day_animation(target_date, target_animation_file, do_hour_gif_cache=True)
    f.write("<img src='%s' width='60' height='45' />\n" % (target_animation_file))
    if not (counter % (7*3)):
        f.write("<br/>")
    main_pbar.update(counter)
    print
f.write('</body></html>')
f.close()