import commands

now_iso = commands.getoutput("date \"+%Y-%m-%dT%H:%M:%SZ%z\"")

last_run_iso = commands.getoutput("cat \"$HOME/Library/Application Support/LifeSlice/.APPLICATION_RUNNING_FLAG.txt\"")

prompt_applescript = """
tell application "Finder"
	activate
	set myReply to button returned of (display dialog "LifeSlice is not running. Would you like to re-start it?" )
end tell
"""

# Compare dates up to hour. 
# E.g. 2014-03-28T11 with 2014-03-28T12
if (now_iso[:13] != last_run_iso[:13]):

	# We're not current
	prompt_command = ("osascript -e '%s'" % prompt_applescript)
	user_response = commands.getoutput(prompt_command)
	if user_response == "OK":

		# Kill LifeSlice (in case it is hung)
		commands.getoutput("killall LifeSlice")

		# Restart the app (LifeSlice.app)
		commands.getoutput("open ../../..")

else:
	print "LifeSlice is running."
	print now_iso[:13], last_run_iso[:13]