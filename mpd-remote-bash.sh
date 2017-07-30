#!/bin/bash
#
# This file is part of mpd-remote-bash
# https://github.com/mgafner/mpd-remote-bash
#                                                                                
# mpd-remote-bash is free software: you can redistribute it and/or modify                 
# it under the terms of the GNU General Public License as published by            
# the Free Software Foundation, either version 3 of the License, or               
# (at your option) any later version.                                             
#                                                                                
# mpd-remote-bash is distributed in the hope that it will be useful,                      
# but WITHOUT ANY WARRANTY; without even the implied warranty of                  
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                   
# GNU General Public License for more details.                                    
#                                                                                
# You should have received a copy of the GNU General Public License               
# along with this code. If not, see <http://www.gnu.org/licenses/>.

SIGINT=2
MPD_SERVER="localhost 6600"
BASEPATH=/home/mgafner/Music
DEBUG=0

# Functions --------------------------------------------------------------------

# ------------------------------------------------------------------------------
check_requirements()
# ------------------------------------------------------------------------------
{
  # need to have these packets installed:
  # bc eyed3 nc grep sed awk curl
  echo ""
}

# ------------------------------------------------------------------------------
control_c()
# ------------------------------------------------------------------------------
#
# Description:  run if user hits control-c
#
# Parameter  :  none
#
# Output     :  logging
#
{
if [ $DEBUG -ge 3 ]; then set -x
fi

echo -e ""
}

# ------------------------------------------------------------------------------
usage()
# ------------------------------------------------------------------------------
#
# Description:  shows help text
# 
# Parameter  :  none
#
# Output     :  shows help text
#
{
cat << EOF

usage: $(basename $0) -g <info-to-get> 

OPTIONS:
  -c    command
	
	commands can be:
	  play
	  pause
          get-current-playlist
          list-playlists

  -g    get info
  -h    list all commands
  -p    set playlist
  -r    set rating in a range from 0 to 5

examples:

  $(basename $0) -c play
  $(basename $0) -g title
  $(basename $0) -g status
  $(basename $0) -g playlists
  $(basename $0) -p <some-playlist>
  $(basename $0) -r 4

EOF
return 0
}

# ------------------------------------------------------------------------------
runcmd()
# ------------------------------------------------------------------------------
{
  case $1 in
    next)
        echo -e "next\nclose" | nc $MPD_SERVER >/dev/null 2>&1
      ;;
    pause)
        echo -e "pause 1\nclose" | nc $MPD_SERVER >/dev/null 2>&1
      ;;
    play)
        echo -e "play\nclose" | nc $MPD_SERVER >/dev/null 2>&1
      ;;
    playpause)
        echo -e "pause\nclose" | nc $MPD_SERVER >/dev/null 2>&1
      ;;
    prev)
        echo -e "previous\nclose" | nc $MPD_SERVER >/dev/null 2>&1
      ;;
    stop)
        echo -e "stop\nclose" | nc $MPD_SERVER >/dev/null 2>&1
      ;;
    shuffle)
        echo -e "shuffle\nclose" | nc $MPD_SERVER >/dev/null 2>&1
      ;;
    *)
        echo -e "command $1 not known or not implemented"
        exit 1
      ;;
  esac
  return
}

# ------------------------------------------------------------------------------
setplaylist()
# ------------------------------------------------------------------------------
# $1 = Playlist name
{
  playlistobject=`echo -e "listplaylists\nclose" | nc localhost 6600 | grep $1 | sed -e "s/playlist: //"`
  if [ ! -z "$playlistobject" ]; then
    echo -e "clear\nclose" | nc $MPD_SERVER >/dev/null 2>&1
    echo -e "load $1\nclose" | nc $MPD_SERVER >/dev/null 2>&1
    shuffle
    echo -e "play\nclose" | nc $MPD_SERVER >/dev/null 2>&1
  fi
}

# ------------------------------------------------------------------------------
setvolume()
# set volume in a range of 0-100
# ------------------------------------------------------------------------------
{
  echo -e "setvol $1\nclose" | nc $MPD_SERVER >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
shuffle()
# ------------------------------------------------------------------------------
{
  echo -e "shuffle\nclose" | nc $MPD_SERVER >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
getinfo()
# ------------------------------------------------------------------------------
{
  case $1 in
    artist)
        echo -e "currentsong\nclose" | nc localhost 6600 | grep "^Artist:" | sed 's/Artist: //'
      ;;
    comment)
        filename=`echo -e "currentsong\nclose" | nc localhost 6600 | grep file: | sed 's/file: //'`
        fullname="$BASEPATH/$filename"
        comment=`eyeD3 --no-color "$fullname" | awk '/Comment: /{getline; print}'`
        echo -e $comment
      ;;
    filename)
        filename=`echo -e "currentsong\nclose" | nc localhost 6600 | grep file: | sed 's/file: //'`
        echo $filename
      ;;
    lastplayed)
        filename=`echo -e "currentsong\nclose" | nc localhost 6600 | grep file: | sed 's/file: //'`
        fullname="$BASEPATH/$filename"
        lastplayed=`eyeD3 --no-color "$fullname" | awk '/MPDS_LastPlayed/{getline; print}'`
        if [ ! -z "$lastplayed" ]; then
          echo -e $lastplayed
        else
          echo -e ""
        fi
      ;;
    mediainfo)
        filename=`echo -e "currentsong\nclose" | nc localhost 6600 | grep file: | sed 's/file: //'`
        fullname="$BASEPATH/$filename"
        eyeD3 --no-color "$fullname" 
      ;;
    playcount)
        filename=`echo -e "currentsong\nclose" | nc localhost 6600 | grep file: | sed 's/file: //'`
        fullname="$BASEPATH/$filename"
        playcount=`eyeD3 --no-color "$fullname" | awk '/FMPS_PlayCount]/{getline; print}'`
        if [ ! -z "$playcount" ]; then
          echo -e $playcount
        else
          echo -e 0
        fi
      ;;
    playlist)
        echo -e "not available from mpd"  
      ;;        
    playlists)
        echo -e "listplaylists\nclose" | nc $MPD_SERVER | grep playlist: | sed -e "s/playlist: //"
      ;;
    position)
        echo -e "not available from mpd"  
      ;;
    rating)
        filename=$(echo -e "currentsong\nclose" | nc localhost 6600 | grep file: | sed 's/file: //')
        fullname="$BASEPATH/$filename"
        rating=$(eyeD3 --no-color "$fullname" | awk '/FMPS_Rating]/{getline; print}')
        if [ ! -z "$rating" ]; then
          rating=$(echo -e "scale=0; $rating * 5" | bc)
          #show rating as integer:
          echo -e ${rating%.*}
        else
          echo -e 0
        fi
      ;;
    shuffle)
        shuffle
      ;;
    status)
        echo -e "status\nclose" | nc localhost 6600 | grep state: | sed 's/state: //'
      ;;
    title)
        echo -e "currentsong\nclose" | nc localhost 6600 | grep "^Title:" | sed 's/Title: //'
      ;;
    volume)
        echo -e "status\nclose" | nc localhost 6600 | grep volume: | sed 's/volume: //'
      ;;
    *)
        echo -e "command $1 not known or not implemented"
        exit 1
      ;;
  esac
  return
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

# trap keyboard interrupt (control-c)
trap control_c $SIGINT


# When you need an argument that needs a value, you put the ":" right after 
# the argument in the optstring. If your var is just a flag, withou any 
# additional argument, just leave the var, without the ":" following it.
#
# please keep letters in alphabetic order
#
while getopts ":c:g:hp:r:s:v:" OPTION
do
  case $OPTION in
    c)
      runcmd "$OPTARG"
      ;; 
    g)
      getinfo "$OPTARG"
      ;;
    h)
      usage
      exit 1
      ;;
    p)
      setplaylist "$OPTARG"
      ;;
    r)
      if [ ! -z "$OPTARG" ]; then
        filename=`echo -e "currentsong\nclose" | nc localhost 6600 | grep file: | sed 's/file: //'`
        fullname="$BASEPATH/$filename"
        #amarok/clementine ratings are internally from 0-1, so we have to calculate
        rating=`echo -e "scale=2; $OPTARG / 5" | bc`
        eyeD3 --no-color --user-text-frame=FMPS_Rating:$rating "$fullname"  >/dev/null 2>&1
        curl -X POST -H "ContentType: application/json" -d '{"state": "'"$OPTARG"'", "attributes": {"friendly_name": "Rating"}}' http://localhost:8123/api/states/sensor.mpd_rating
      else
        echo -e "Rating from 0 to 5 has to be given as argument"
      fi
      ;;
    v)
      setvolume "$OPTARG"
      ;;
    \?)
      usage
      exit 1
      ;;
    :)
      echo -e "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

