#!/usr/bin/python
#
# Script to import old (cron-based) LifeSlice data into the new (Sqlite, App) version.
#
#

import sys
import os
from os.path import expanduser
import re
import shutil
import tempfile

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

print "\n\n"
print bcolors.OKBLUE + "============================================================" + bcolors.ENDC
print bcolors.OKBLUE + "Importing old LifeSlice data. This may take a few minutes.  " + bcolors.ENDC
print bcolors.OKBLUE + "============================================================" + bcolors.ENDC
print "\n\n"

# Sample executino of sqlite update:
# sqlite3 /Users/stan/Library/Application\ Support/LifeSlice/lifeslice.sqlite

# do_file_migrate = False
do_file_migrate = True
do_sql_update = True
do_cron_update = True
do_erase_old_files = False

new_app_folder = expanduser("~/Library/Application Support/LifeSlice")
old_app_folder = expanduser("~/LifeSlice/data")

sqlite_database_file = new_app_folder + "/lifeslice.sqlite"
migrate_sql_file = "lifeslice_migrate.sql"
sql_file = open(migrate_sql_file, "w")

if not os.path.isfile(sqlite_database_file):
    sys.stderr.write("SQLite database file does not exist: %s\n" %(sqlite_database_file) )
    exit()

def file_get_contents(filename):
    """Helper function that just returns a file's contents."""
    with open(filename) as f:
        return f.read()

print "------------------------------------------------------------"
print "Copying webcam and screenshot files..."
print "------------------------------------------------------------"

for i in os.listdir(old_app_folder):
    filepath=old_app_folder+"/"+i
    
    # look for our type and date in the filename
    # e.g. filename migh be face_2012-08-29.jpg. Type is "face" and date is "2012-08-29"
    m = re.findall(r'^(face|screen|latlon|current)_(\d\d\d\d-\d\d-\d\dT\d\d-\d\d-\d\dZ[+-]\d+)', i)
    if len(m)>0:
        (datatype,datetime) = m[0]
    else:
        sys.stderr.write("/* could not get datetime from %s */\n" % i)
        continue
    # fix format of datetime. colons aren't allwed in filenames, so it isn't ISO date correct
    dl=list(datetime)
    dl[13]=':'
    dl[16]=':'
    datetime="".join(dl)
    
    print bcolors.OKBLUE + "    DATE & TIME: " + datetime + bcolors.ENDC;
    
    if datatype=='screen':
        #
        # screenshot
        #
        
        # move image to new location
        new_filepath = filepath.replace(old_app_folder,new_app_folder+"/screenshot")
        # sys.stderr.write(filepath+" ->\n"+new_filepath+"\n")
        if do_file_migrate:
#            shutil.copy2(filepath,new_filepath)
            shutil.move(filepath,new_filepath)
        
        # Generate new thumbnail
        new_thumbnail_filepath =  new_filepath.replace("/screenshot/","/screenshot_thumbs/")
        os.system("/usr/bin/sips --resampleWidth 120 '%s' --out '%s' > /dev/null 2>&1" % (new_filepath,new_thumbnail_filepath))
        if os.path.isfile(new_thumbnail_filepath):
#            sys.stderr.write("Created thumbnail.\n")
            pass
        else:
            sys.stderr.write("Error: Problem creating thumbnail:%s\n" % (new_thumbnail_filepath))
        
        #        # move thumbnail to new location
        #        old_thumbnail_filepath = filepath.replace("/data/","/reports/thumbnails/").replace(".png",".png.thumbnail.png")
        #        new_thumbnail_filepath =  new_filepath.replace("/screenshot/","/screenshot_thumbs/")
        #        sys.stderr.write(old_thumbnail_filepath+" -> "+new_thumbnail_filepath+"\n")
        #        if os.path.isfile(old_thumbnail_filepath):
        #            if do_file_migrate:
        #                shutil.copy2(old_thumbnail_filepath,new_thumbnail_filepath)
        #        else:
        #            # missing thumbnail
        #            sys.stderr.write("Thumbnail was missing for screenshot\n")
        
        # update database
        sql_file.write("INSERT OR REPLACE INTO screenshot(datetime,filename) VALUES ('%s','%s');\n" % (datetime,i))
    
    elif datatype=='latlon':
        #
        # latlon
        #
        try:
            f=file_get_contents(filepath).strip()
            lines=f.split("\n")
            (lat,lon)=lines[-1].split(',')
            if len(lines)>1:
                sys.stderr.write("extra lines:"+f+"\n"+"used:"+lat+","+lon+"\n")
            sql_file.write("INSERT OR REPLACE INTO location(datetime,lat,lon) VALUES ('%s','%s','%s');\n" % (datetime,lat,lon))
        except:
            sys.stderr.write("/* could not parse file contents of %s */\n" % filepath);
    
    elif datatype=='face':
        #
        # face
        #
        
        # move image to new location
        new_filepath = filepath.replace(old_app_folder,new_app_folder+"/webcam")
        # sys.stderr.write(filepath+" ->\n"+new_filepath+"\n")
        if do_file_migrate:
#            shutil.copy2(filepath,new_filepath)
            shutil.move(filepath,new_filepath)
        
        # Generate new thumbnail
        new_thumbnail_filepath = new_filepath.replace("/webcam/","/webcam_thumbs/")
        os.system("/usr/bin/sips --resampleWidth 120 '%s' --out '%s'  > /dev/null 2>&1" % (new_filepath,new_thumbnail_filepath))
        if os.path.isfile(new_thumbnail_filepath):
#            sys.stderr.write("Created thumbnail.\n")
            pass
        else:
            sys.stderr.write("Error: Problem creating thumbnail:%s\n" % (new_thumbnail_filepath))
        
        #        # move thumbnail to new location
        #        old_thumbnail_filepath = filepath.replace("/data/","/reports/thumbnails/").replace(".png",".png.thumbnail.png")
        #        new_thumbnail_filepath =  new_filepath.replace("/webcam/","/webcam_thumbs/")
        #        sys.stderr.write(old_thumbnail_filepath+" -> "+new_thumbnail_filepath+"\n")
        #        if os.path.isfile(old_thumbnail_filepath):
        #            if do_file_migrate:
        #                shutil.copy2(old_thumbnail_filepath,new_thumbnail_filepath)
        #        else:
        #            # missing thumbnail
        #            sys.stderr.write("Thumbnail was missing for webcam.\n")
        
        # update database
        sql_file.write("INSERT OR REPLACE INTO webcam(datetime,filename) VALUES ('%s','%s');\n" % (datetime,i))
    
    elif datatype=='current':
        #
        # current application and URL
        #
        try:
            x=file_get_contents(filepath).strip().split("\n")
            # x+=['']*(2-len(x)) # pad to len 2
            # (currentApp,currentURL)=x
            if len(x)>=1:
                currentApp = x[0].replace('alias ','')
            else:
                currentApp=''
            if len(x)>=2:
                currentURL = x[1]
            else:
                currentURL=''
            currentURL = currentURL.replace("'","''") # quote escaping
            sql_file.write("INSERT OR REPLACE INTO app(datetime,currentApp,currentURL) VALUES ('%s','%s','%s');\n" % (datetime,currentApp,currentURL))
            pass
        except:
            sys.stderr.write("Could not parse file contents of %s\n" % filepath);
        pass
# else:
# print i

sql_file.close()

if do_sql_update:
    print "------------------------------------------------------------"
    print "Updating database with webcam, screenshot, geo, and app data"
    print "(This will take time with seemingly nothing happening.)"
    print "------------------------------------------------------------"
    
    # We copy the existing database to a temp area, so we're not working on the live database
    temp_sqlite_database_file = sqlite_database_file + ".temp"
    shutil.copy2(sqlite_database_file,temp_sqlite_database_file)
    # Apply our changes to the database
    sys.stderr.write("\n/* Applying update to database*/\n" + "sqlite3 '%s' < '%s'" % (temp_sqlite_database_file,migrate_sql_file));
    
    os.system("sqlite3 '%s' < '%s'" % (temp_sqlite_database_file,migrate_sql_file))
    # Check the integrity
    # os.system("echo 'PRAGMA integrity_check;'  |sqlite3 '%s' > integrity_check.out")
    # Copy back
    os.rename(sqlite_database_file,sqlite_database_file+".pre_old_import.mysql")
    shutil.copy2(temp_sqlite_database_file,sqlite_database_file)

if do_erase_old_files and do_file_migrate:
    print "------------------------------------------------------------"
    print "Deleting old data"
    print "------------------------------------------------------------"
    # Erase all old data. (Defaults to OFF)
    os.system("rm -rf '%s'" % (old_app_folder))

if do_cron_update:
    print "------------------------------------------------------------"
    print "Removing the old hourly timer. (Cron job)"
    print "------------------------------------------------------------"
    # turn off cron job
    os.system("CRON_TEMP='/tmp/cron_temp';CRON_NEW='/tmp/cron_new';crontab -l >$CRON_TEMP;awk '$0!~/Lifeslice/ { print $0 }' $CRON_TEMP >$CRON_NEW;crontab $CRON_NEW;")
    os.system("~/LifeSlice/UN-INSTALL.command")

# Leave a little marker to indicate that we've done the import
os.system("touch '%s/SUCCESSFULLY_IMPORTED_FLAG.txt'" % (old_app_folder))

print "\n\n"
print bcolors.OKBLUE + "============================================================" + bcolors.ENDC
print bcolors.OKBLUE + "Finished!" + bcolors.ENDC
print bcolors.OKBLUE + "You can see your imported data by selecting 'Browse Life' from" + bcolors.ENDC
print bcolors.OKBLUE + "the LifeSlice menu. Thank you for using LifeSlice. " + bcolors.ENDC
print bcolors.OKBLUE + "-Stan" + bcolors.ENDC
print bcolors.OKBLUE + "============================================================" + bcolors.ENDC
print
print "(You may close this window now.)"

