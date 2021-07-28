-- http://projects.haskell.org/xmobar/
-- I use Font Awesome 5 fonts in this config for unicode "icons".  On Arch Linux,
-- install this p                    , Run Com "/home/dt/.local/bin/pacupdate" [] "pacupdate" 36000ackage from the AUR to get these fonts: otf-font-awesome-5-free

Config { font    = "xft:3270SemiNarrow Nerd Font:size=12:regular:antialias=true"
       , additionalFonts = [ "xft:Mononoki Nerd Font:pixelsize=11:antialias=true:hinting=true"
                           , "xft:Font Awesome 5 Free Solid:pixelsize=12"
                           , "xft:Font Awesome 5 Brands:pixelsize=12"
                           ]
       , bgColor = "#282c34"
       , fgColor = "#ff6c6b"
       --, position = Static { xpos = 0 , ypos = 0, width = 2560, height = 24 }
       , position = TopW L 97
       , lowerOnStart = True
       , hideOnStart = False
       , allDesktops = False
       , persistent = True
       , iconRoot = "~/.xmonad/xpm/"  -- default: "."
       , commands = [
                    -- Time and date
                      Run Date "<fn=2>\xf017</fn>  %b %d %Y - (%H:%M) " "date" 50
                      -- Network up and down
                    , Run Network "wlp3s0" ["-t", "<fn=2>\xf0ab</fn>  <rx>kb  <fn=2>\xf0aa</fn>  <tx>kb"] 20
                      -- Cpu usage in percent
                    , Run Cpu ["-t", "<fn=2>\xf108</fn>  cpu: (<total>%)","-H","50","--high","red"] 20
                      -- Ram used number and percent
                    , Run Memory ["-t", "<fn=2>\xf233</fn>  mem: <used>M (<usedratio>%)"] 20
                      -- Disk space free
                    , Run DiskU [("/", "<fn=2>\xf0c7</fn>  hdd: <free> free")] [] 60
                      -- Runs custom script to check for pacman updates.
                      -- This script is in my dotfiles repo in .local/bin.
                    , Run Com "/home/mazon/.scripts/pacupdate" [] "pacupdate" 36000
                      -- Runs a standard shell command 'uname -r' to get kernel version
                    , Run Com "uname" ["-r"] "" 3600
                    , Run UnsafeStdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "<icon=haskell_20.xpm/>   <fc=#666666>|</fc> %UnsafeStdinReader% }{  <fc=#666666>|</fc>  <fc=#b3afc2><fn=3></fn>  <action=`alacritty -e htop`>%uname%</action> </fc> <fc=#666666>|</fc>  <fc=#ecbe7b> <action=`alacritty -e htop`>%cpu%</action> </fc> <fc=#666666>|</fc>  <fc=#ff6c6b> <action=`alacritty -e htop`>%memory%</action> </fc> <fc=#666666>|</fc>  <fc=#51afef> <action=`alacritty -e htop`>%disku%</action> </fc> <fc=#666666>|</fc>  <fc=#98be65> <action=`alacritty -e sudo iftop`>%wlp3s0%</action> </fc> <fc=#666666>|</fc>   <fc=#c678dd><fn=2></fn>  <action=`alacritty -e sudo pacman -Syu`>%pacupdate%</action> </fc> <fc=#666666>|</fc>  <fc=#46d9ff> <action=`alacritty -e htop`>%date%</action>  </fc>"
       }

