import XMonad
import System.IO
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Util.EZConfig

import XMonad.Hooks.ManageDocks (avoidStruts)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops

import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed 
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Spiral

import Data.Maybe (isJust, fromJust)

myTerminal         = "alacritty"
myFallbackTerminal = "cool-retro-term"
fallbackTerminal   = "konsole"
myLauncher         = "dmenu_run"
myFileManager      = "pcmanfm"
myBrowser          = "google-chrome-stable"
myEditor           = "emacs" -- maybe someday I can change it to vim, but I don't think so
emacs              = "emacs"
emacsExec          = emacs ++ " --eval "

myBorderWidth   = 2
myGaps          = 2

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myModMask       = mod4Mask

myWorkspaces    = map show [1..9]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..]

myNormalBorderColor  = "#6633f6"
myFocusedBorderColor = "#cc0dff"

myFont = "ttf: Fira Code,Fira Code Retina:style=Retina,Regular"

myKeys conf@(XConfig {XMonad.modMask = modKey}) = M.fromList $
    [((m .|. modKey, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

myAdditionalKeys = [ -- Basic keybindings
                     ("M-<Return>"  , spawn $ myTerminal) 
                   , ("M1-C-t"      , spawn $ myFallbackTerminal)
                   , ("M-d"         , spawn myLauncher)
                   , ("M-w"         , spawn myBrowser)
                   , ("M-e"         , spawn myEditor)
                   , ("M-S-<Return>", spawn myFileManager)
                   , ("M-S-q"       , kill)
                   , ("M-<Space>"   , sendMessage NextLayout)
                   , ("M-n"         , refresh)
                   , ("M-<Tab>"     , windows W.focusDown)
                   , ("M-S-<Tab>"   , windows W.focusUp)
                   , ("M-j"         , windows W.focusDown)
                   , ("M-k"         , windows W.focusUp)
                   , ("M-m"         , windows W.focusMaster)
                   , ("M-C-<Return>", windows W.swapMaster)
                   , ("M-S-j"       , windows W.swapDown)
                   , ("M-S-k"       , windows W.swapUp)
                   , ("M-h"         , sendMessage Shrink)
                   , ("M-l"         , sendMessage Expand)
                   , ("M-t"         , withFocused $ windows . W.sink)
                   , ("M-,"         , sendMessage (IncMasterN 1))
                   , ("M-."         , sendMessage (IncMasterN (-1)))
                   , ("M-S-x"       , io (exitWith ExitSuccess))
                   , ("M-x"         , spawn $ "xmonad --recompile && xmonad --restart")
                   , ("M-<Esc>"     , spawn $ "xkill")

                   -- Emacs integration
                   , ("C-e C-j"     , spawn (emacsExec ++ "'(dired nil)'" ))
                   , ("C-e C-x"     , spawn (emacsExec ++ "'(dired \"~/.xmonad\")'"))  -- open xmonad folder
                   , ("C-e C-e"     , spawn (emacsExec ++ "'(dired \"~/.emacs.d\")'")) -- open emacs folder
                   , ("C-e C-c"     , spawn (emacsExec ++ "'(dired \"~/.config\")'"))  -- open config folder
                   , ("C-e e"       , spawn (emacsExec ++ "'(eshell)'"))
                   , ("C-e t"       , spawn (emacsExec ++ "'(vterm)'"))
                   , ("C-e d"       , spawn (emacsExec ++ "'(dashboard-refresh-buffer)'"))

                   -- Terminal app
                   , ("M-a h"       , spawn (myTerminal ++ " -e htop"))
                   , ("M-a f"       , spawn (myTerminal ++ " -e ranger"))
                   , ("M-a u"       , spawn (myTerminal ++ " -e sudo pacman -Syyu"))
                   , ("M-a e"       , spawn (myTerminal ++ " -e nvim"))
                   ]

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    ]

myLayout = avoidStruts $ myTiledLayout ||| Mirror myTiledLayout ||| fibonacci ||| (noBorders Full) 

myTiledLayout = spacing myGaps (Tall nmaster delta ratio)
  where
    nmaster = 1
    ratio   = 1/2
    delta   = 2/100

fibonacci = spacing myGaps $ smartBorders $ spiral (6/7)

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore]

myLogHook = return ()

myStartupHook = do
    spawnOnce "picom --experimental-backend &"
    spawnOnce "feh --bg-scale ~/Pictures/wallpaper/haskell3.jpg &"
    spawnOnce "lxsession &"
    spawnOnce "udiskie &"
    spawnOnce "xmobar ~/.xmonad/xmobarrc"

myConfig = defaultConfig {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

        keys               = myKeys,
        mouseBindings      = myMouseBindings,

        layoutHook         = myLayout,
        manageHook         = myManageHook <+> manageDocks,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

main = do
  xmproc <- spawnPipe "xmobar  ~/.xmonad/xmobarrc"
  xmonad $ ewmh myConfig
    { handleEventHook = docksEventHook
    , logHook         = dynamicLogWithPP $ xmobarPP
                           { ppOutput          = \x -> hPutStrLn xmproc x
                           , ppCurrent         = xmobarColor "#992299" "" . wrap "[" "]"
                           , ppVisible         = xmobarColor "#992299" "" . clickable
                           , ppHidden          = xmobarColor "#905aed" "" . wrap "*" "" . clickable
                           , ppHiddenNoWindows = xmobarColor "#662266" "" . clickable
                           , ppTitle           = xmobarColor "#CCCCCC" "" . shorten 60
                           , ppSep             = "<fc=#666666> <fn=2>|</fn> </fc>"
                           , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!" 
                           , ppExtras          = [windowCount]
                           , ppOrder           = \(ws:l:t:ex) -> [ws,l] ++ ex ++ [t]
                           }
    } `additionalKeysP` myAdditionalKeys
