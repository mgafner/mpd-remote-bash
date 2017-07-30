# mpd-remote-bash
Bash script for remote controlling the MPD music player with [Home Assistant](https://home-assistant.io/)

## About Music Player Daemon

   * Website: https://www.musicpd.org/

## About MPD Remote Bash
mpd-remote-bash enables you to remote control mpd from a bash terminal on the same computer mpd is running on. This is useful for automation tasks. 
It also sends some information to the locally installed [Home Assistant](https://home-assistant.io/).

Beware: It works on mp3 files and writes mp3-tags!

Check the code before using it!

## Installation
#### Prerequisites
   * mpd bc eyed3 nc grep sed awk curl

#### Debian / Ubuntu
```
sudo apt-get install mpd bc eyed3 nc grep sed awk curl
```

## Usage
```
usage: mpd-remote-bash -g <info-to-get> 

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

  mpd-remote-bash -c play
  mpd-remote-bash -g title
  mpd-remote-bash -g status
  mpd-remote-bash -g playlists
  mpd-remote-bash -p <some-playlist>
  mpd-remote-bash -r 4

```

## License
mpd-remote-bash is free software, available under the [GNU General Public License, Version 3](http://www.gnu.org/licenses/gpl.html).

