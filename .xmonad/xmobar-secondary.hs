-- http://projects.haskell.org/xmobar/
-- I use Font Awesome 5 fonts in this config for unicode "icons".  On Arch Linux,
-- install this package from the AUR to get these fonts: otf-font-awesome-5-free

Config { font    = "xft:3270SemiNarrow Nerd Font:size=12:regular:antialias=true"
       , additionalFonts = [ "xft:Mononoki Nerd Font:pixelsize=11:antialias=true:hinting=true"
                           , "xft:Font Awesome 5 Free Solid:pixelsize=12"
                           , "xft:Font Awesome 5 Brands:pixelsize=12"
                           ]
       , bgColor = "#282c34"
       , fgColor = "#ff6c6b"
--       , position = Static { xpos = 0 , ypos = 0, width = 1920, height = 24 }
       , lowerOnStart = True
       , hideOnStart = False
       , allDesktops = False
       , persistent = True
       , iconRoot = "/home/dt/.xmonad/xpm/"  -- default: "."
       , commands = [
                    Run UnsafeStdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = " <icon=haskell_20.xpm/>   <fc=#666666>|</fc> %UnsafeStdinReader% }"
       }

