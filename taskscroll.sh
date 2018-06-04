#!/bin/bash
# --------------------------------------------------------------------- #
# taskscroll 
#	A handy polybar script that scrolls through your taskwarrior
#	tasks periodically.
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
#
# TODO:
#
# --------------------------------------------------------------------- #

# 0. Define (or create) the configuration file
if [ ! -z "$XDG_CONFIG_HOME" ]; then
	CONFDIR="$XDG_CONFIG_HOME/taskscroll"
else
	CONFDIR="$HOME/.config/taskscroll"
fi

CONFILE="$CONFDIR/taskscroll.conf"

if [ ! -d "$CONFDIR" ]; then
        echo "Creating $CONFDIR"
        mkdir -p "$CONFDIR"
fi

if [ ! -f "$CONFILE" ];then
        echo "Creating $CONFILE"
        touch "$CONFILE"
fi

# 1. Grab the current task number
TASKNUM=`cat "$CONFILE"`

if [ -z "$TASKNUM" ]; then
	TASKNUM=1
fi

# 2. Grab the number of tasks
NUMTASKS=`task list | tail -1 | sed 's/\ tasks//g'`

if [ "$NUMTASKS" -eq 0 ]; then
	echo ""
	return	
fi

# 3. Check to see if the task number is larger than the number of tasks, if so reset to task 1
if [ "$TASKNUM" -gt "$NUMTASKS" ]; then
	TASKNUM=1
fi

# 4. Query taskwarrior and echo the description of the task 
echo `task $TASKNUM info | grep Description | sed 's/\Description   //g'`

# 5. Update the task number and save it to the configuration file 
TASKNUM=$(($TASKNUM + 1))
echo $TASKNUM > $CONFILE

