import os, os.path
import argparse
import fnmatch

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
    description="""
Remove all black images.
""",
    epilog="""
Contact Stan James (stan@wanderingstan.com) with any questions.""")
parser.add_argument(
    '--directory', 
    default='.',
    help='Directory to use. Defaults to current.')

args = parser.parse_args()

# Should probably do this without loading every filename first #todo
for filepath in fnmatch.filter(os.listdir(args.directory),"face*.jpg"):
    fullpath = os.path.join(args.directory, filepath)
    if os.path.getsize(fullpath) < 25*1024:
        # os.remove(fullpath)

        mean =  float(os.popen('convert %s -format "%%[mean]" info:' % (fullpath)).read())
        print ("%s is small with mean of %f" % (fullpath,mean))
        if mean<1.0:
            print "and all BLACK!"
            # os.remove(fullpath)
            os.rename(fullpath,os.path.join(args.directory,'black',filepath))

# mean=`convert image -format "%[mean]" info:`
# if [ "$mean" = 0 ]; then
# echo "totally black image"
# else
# echo "not totally black image"
# fi
