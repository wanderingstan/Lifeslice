# Basically this script is for making a "year as animated gif" from LifeSlice images
# It geneerates 24 images, one for each hour in the day.
# Requires imagemagick (convert)
# Optionally can use find-face to determine if faces are present in image

import os
import sys
import fnmatch
import pprint
import logging
import subprocess
import tempfile
import datetime


class LifeSliceYearMovie:

    def __init__(self, year):
        # set defaults
        self.lifeslice_dir = os.path.expanduser("~/Library/Application Support/LifeSlice/")
        self.target_year = year
        self.final_animation_filename = '%04d.gif' % (self.target_year)
        self.thumbs_dir = "./thumbs"
        self.year_times_dir = "./year_at_times"
        self.source_dir = os.path.join(self.lifeslice_dir, "webcam_thumbs")
        self.blank_image_name = "blank.png"
        self.empty_image_name = "empty.png"
        self.thumbnail_size = "60x45" # "23x17" 
        self.find_faces = False
        self.use_existing = False
        self.title_font_size = 60

        if not os.path.exists(self.year_times_dir):
            os.makedirs(self.year_times_dir)
        if not os.path.exists(self.thumbs_dir):
            os.makedirs(self.thumbs_dir)

        # TODO: Create the blank images with imagemagick
        # blank_command = "convert -size %s xc:white blank.png" % (thumbnail_size)
        # subprocess.check_output(blank_command,shell=True)


    def get_thumb_from_original(self, original_jpg, do_hour_gif_cache=True, extension="gif", find_faces=False):
        """
        Given a jpg of a lifeslice webcam shot in our orignal directory, create a small version and return
        its path.
        """
        source_jpg_file = os.path.join(self.source_dir, original_jpg)
        target_gif_file = os.path.join(self.thumbs_dir, original_jpg[:-4] + "." + extension) # bob.jpg --> bob.gif

        if os.path.isfile(target_gif_file) and self.use_existing:
            # If file already exists, we use it
            return target_gif_file

        if (do_hour_gif_cache and os.path.isfile(target_gif_file)):
            # use the existing gif
            pass
        else:
            if find_faces:
                # Center image on the face
                command = ("./find-face --cascade=haarcascade_frontalface_default.xml --magickcenter '%s'" % source_jpg_file)
                shift_amount = subprocess.check_output(command, shell=True).split('\n')[0].strip() # e.g. "+3-37"
                target_pathname = original_jpg
            else:
                shift_amount=""

            if shift_amount:
                # found a face
                command = "convert '%s' -page %s -background black -flatten -resize %s -crop %s -repage %s '%s'" % (source_jpg_file, shift_amount, thumbnail_size,  thumbnail_size, thumbnail_size, target_gif_file)
            else:
                # command = "convert '%s' -resize %s '%s'" % (source_jpg_file, self.thumbnail_size, target_gif_file)
                command = "convert '%s' -resize %s^ -gravity center -extent %s '%s'" % (source_jpg_file, self.thumbnail_size, self.thumbnail_size, target_gif_file)

            # print command

            #print("Command: %s", command)
            sys.stdout.write('-')

            resize_output = subprocess.check_output(command,shell=True)
            # print resize_output

        return target_gif_file


    def make_time_animation(self, year, target_time, target_animation_file, do_hour_gif_cache):
        """
        Create an image of all days in the year for a given time slice (hour) rendered in a grid. E.g. all days at 6pm. 
        """

        print "Creating image for %04d at %s" % (year, target_time)
        temp_file = '/tmp/tempimage.jpg'

        # Delete existing animation, if there (gifsicle chokes otherwise)
        try:
            os.remove(target_animation_file)
        except:
            pass

        # Create blank image of correct size
        subprocess.check_output("convert -size %s xc:black '%s'" % (self.thumbnail_size, self.blank_image_name),shell=True)

        animation_gifs = {}
        base = datetime.date(year,1,1)
        numdays = 366
        day_gifs = {}
        # montage_command = "montage -font '/Library/Fonts/Arial.ttf' "
        montage_command = "montage -font '/System/Library/Fonts/HelveticaNeue.dfont'  "

        # Add initial padding so days of week line up
        start_padding = base.weekday()
        for x in range(0, start_padding):
            day_gifs[x] = self.empty_image_name 
            montage_command += self.empty_image_name + " "

        # Add images for all our days
        for (counter, date) in enumerate([ base + datetime.timedelta(days=x) for x in range(0,numdays) ]):

            # Try to load image for this date at the given time
            frame_files = fnmatch.filter(os.listdir(self.source_dir),"face_%04d-%02d-%02dT%s-??Z-????.jpg" % (year, date.month, date.day, target_time))

            if len(frame_files) == 0: 
                if date.weekday() >= 5:
                    # if weekend, use different color
                    frame_file = self.empty_image_name
                else:
                    frame_file = self.blank_image_name
            else:
                frame_file = self.get_thumb_from_original(frame_files[0], extension="jpg")

            # Add to our list     
            day_gifs[counter + start_padding] = frame_file 
            montage_command += frame_file + " "

            # Simple notification
            sys.stdout.write('.')

        # TODO: Add date/time to the image. Why is this not working?
        # 21 is number of columns (or rows??)
        # montage_command += " -background black -font '/Library/Fonts/Arial.ttf' -pointsize 72 -fill white -label \"%02d:%02d wanderingstan.com\""
        # montage_command += " -background Black -fill white -font '/Library/Fonts/Arial.ttf' -pointsize 36 label:'%s at %s - LifeSlice' -gravity West  " % (year, target_time)

        montage_command += " -background '#222' -tile 21x -geometry +1+1 "
        montage_command += temp_file

        # Execute the command
        subprocess.check_output(montage_command,shell=True)

        # Overlay time info
        hour = int(target_time[0:2])
        pretty_hour = "%d%s" % (hour % 12, "am" if (hour < 12 ) else "pm")
        label_command = "convert '%s' -font '/Library/Fonts/Arial.ttf' -background Black -fill '#eee' -pointsize %d label:'%04d %s ' -gravity West  -append  -gravity southeast -pointsize %d -annotate 0 'lifeslice.wanderingstan.com'  '%s' " % (temp_file, self.title_font_size, year, pretty_hour, int(self.title_font_size/2), target_animation_file)
        subprocess.check_output(label_command, shell=True)

        # Debug stuff
        print
        # print(day_gifs)
        # print montage_command
        # print label_command


    def make_year_at_time_files(self, extension="gif"):
        self.year_at_time_files=[]
        for hour in range(0,24):

            # Add the hour
            time_file = os.path.join(self.year_times_dir, '%02d-00.%s' % (hour, extension))

            self.year_at_time_files.append(time_file)

            if self.use_existing and os.path.isfile(time_file):
                # Already exists
                print "Using existing files for %02d-00" % hour
                pass
            else:
                self.make_time_animation(self.target_year, '%02d-00' % hour, time_file, False)

            # # Add the half-hour
            # time_file = os.path.join(self.year_times_dir,'%02d-30.%s' % (hour,extension))
            # # time_file = os.path.join(self.year_times_dir,'lifeslice_hour_%04d.gif' % (hour*2 + 1))
            # make_time_animation(self.target_year,'%02d-30'%hour,time_file,False)
            # year_at_time_files.append(time_file)

        return self.year_at_time_files

    def make_year_movie(self):
        # ffmpeg -f 1 -i /tmp/lifeslice_hour_%04d.png -c:v libx264 out.mp4
        year_at_time_files = make_year_at_time_files(extension="jpg")

        year_movie_filename = "year_%04d.avi" % (self.target_year)
        ffmpeg_command = "ffmpeg -r 4 -f image2 -pattern_type glob -i '%s/*.jpg' '%s'" % (year_times_dir, year_movie_filename)
        subprocess.check_output(ffmpeg_command, shell=True)

        print "Created %s" % (year_movie_filename)

    def make_year_animated_gif(self):
        year_at_time_files = self.make_year_at_time_files(extension="jpg")

        year_gif_filename = "year_%04d.gif" % (self.target_year)
        target_animation_file=os.path.join(self.thumbs_dir, self.final_animation_filename)
        # gif_command = "gifsicle --loopcount=forever -d25 --colors 256 -S 60x45 " + " ".join(year_at_time_files) + " > " +target_animation_file
        gif_command = "convert -delay 35 -loop 0 '%s/*.jpg' '%s'" % (self.year_times_dir, year_gif_filename)
        make_gif_output = subprocess.check_output(gif_command, shell=True)


if __name__ == "__main__":
    year = LifeSliceYearMovie(2012)
    year.use_existing = False
    # year.make_year_at_time_files(extension="jpg")
    year.make_year_animated_gif()
