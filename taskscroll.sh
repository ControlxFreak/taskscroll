#!/bin/bash
# --------------------------------------------------------------------- #
# taskscroll
#	Scrolls through your taskwarrior tasks, formats and echos them back 
#	to you!  Awesome for polybar! 
#
# Anthony Trezza
# 04 June 2018
# anthony<delete_this>.t<remove_this>.trezza<destroy_this>@gmail.com
#
# License:
#      MIT License
#       
#       Copyright (c) 2018 Anthony Trezza
#
#       Permission is hereby granted, free of charge, to any person 
#       obtaining a copy of this software and associated documentation 
#       files (the "Software"), to deal in the Software without restriction,
#       including without limitation the rights to use, copy, modify, merge,
#       publish, distribute, sublicense, and/or sell copies of the Software, 
#       and to permit persons to whom the Software is furnished to do so, 
#       subject to the following conditions:
#       
#       The above copyright notice and this permission notice shall be 
#       included in all copies or substantial portions of the Software.
#
#       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
#       EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
#       OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
#       NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
#       BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
#       ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
#       CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#       SOFTWARE.
# 
# Change Log:
#	- 04 June 2018 trezza taskscroll's birthday <(^.^)>
#	- 04 June 2018 trezza Updated the location of the data file 
#				   to standard XDG notation (Issue #3)
#	- 04 June 2018 trezza added options to allow verbosity level selection
#				   (Issue #1)
#	- 04 June 2018 trezza added usage and help
#	- 04 June 2018 trezza added version number
#	- 07 June 2018 trezza added -c option for completing the current task
# TODO:
#	- 04 June 2018 trezza maybe this should be a format input instead of
#				   verbosity level? Think about it.
#	- 04 June 2018 trezza maybe add a -s option for sorting
# --------------------------------------------------------------------- #
VERSION=`cat VERSION`

# Utility Functions
function usage() {
	echo "Usage: "
	echo "	$0 [-hcv]"
	echo "	-h		Display help"
	echo "  -c      Complete the current task"
	echo "  -v 		Set the verbosity level (default 1)"
	echo "			0 - Silent Mode (do not echo anything but iterate task data as if it did)"
	echo "			1 - Description Mode ("Task k: <description>")"
	echo "			2 - Project Mode ("Task k: <project>:<description>")"
	echo "			3 - Due Date Mode ("Task k (Due on <date>): <project>:<description>")"
	echo "			4 - Urgency Mode ("Task k (Due on <date>, Urgency <urgency>: <project>:<description>")"
	echo "			(where k=task number)"
} # usage()

function help() {
	echo "TaskScroll: (Version: $VERSION)"
	echo "	Scrolls through your taskwarrior tasks, formats and echos them back to you!  Awesome for polybar!"
	echo""
	usage()
} # help()

function getTaskInfo(){
	task $TASKNUM info | grep "$1" | sed 's/\"$1"   //g'
} # getTaskInfo()

# Get the input options
VERBOSITY=1 # Default verbosity to just print the description of the next task
COMPLETETASK=false

while getopts ":hcv" opt; do
	case ${opt} in
		h )
			help
			exit 0
			;;
		c )
			COMPLETETASK=true
			;;
		v )
			VERBOSITY=${OPTARG}
			;;
		\? )
			echo "Invalid Input: -$OPTARG"
			usage
			exit 1
			;;
	esac
done

shift $((OPTIND -1))


# 0. Define (or create) the datafile
# 04 June 2018 trezza - Fixed location of data file (Issue #3)
if [ ! -z "$XDG_DATA_HOME" ]; then
	DATADIR="$XDG_DATA_HOME/taskscroll"
else
	DATADIR="$HOME/.local/share/taskscroll"
fi

if [ ! -d "$DATADIR" ]; then
        echo "Creating $DATADIR"
        mkdir -p "$DATADIR"
fi


DATAFILE="$DATADIR/tasknum"

if [ ! -f "$DATAFILE" ];then
        echo "Creating $DATAFILE"
        touch "$DATAFILE"
fi

# 1. Grab the current task number, if it is empty, default it to the first task.
TASKNUM=`cat "$DATAFILE"`

if [ -z "$TASKNUM" || "$TASKNUM" -lte 0 ]; then
	TASKNUM=1
fi

# 2. Grab the number of tasks, if there are no tasks - echo "No Tasks!"
NUMTASKS=`task list | tail -1 | sed 's/\ tasks//g'`

if [ "$NUMTASKS" -eq 0 ]; then
	echo "No Tasks!"
	return	
fi

# 3. Check to see if the task number is larger than the number of tasks, if so reset to task 1
if [ "$TASKNUM" -gt "$NUMTASKS" ]; then
	TASKNUM=1
fi

# 4. Query taskwarrior and echo the description of the task 
if [ $COMPLETETASK ]; then 

	task $TASKNUM done

else 
	PROJECT=getTaskInfo "Project"
	DESCRIPTION=getTaskInfo "Description"
	DUE=getTaskInfo "Due"
	URGENCY=getTaskInfo "Urgency"

	case ${VERBOSITY} in
		0 )
			;;
		1 )
			echo "Task $TASKNUM: $DESCRIPTION"
			;;
		2 )
			echo "Task $TASKNUM: $PROJECT: $DESCRIPTION"
			;;
		3 )
			echo "Task $TASKNUM (Due: $DUE): $PROJECT: $DESCRIPTION"
			;;
		4 )
			echo "Task $TASKNUM (Due: $DUE, Urgency: $URGENCY): $PROJECT: $DESCRIPTION"
			;;
		\? )
			echo "Unknown Verbosity!"
			usage
			exit 1
			;;
	esac
			
fi

# 5. Update the task number and save it to the configuration file 
TASKNUM=$(($TASKNUM +1))

echo $TASKNUM > $DATAFILE

