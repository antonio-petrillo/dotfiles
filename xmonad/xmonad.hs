import XMonad
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Util.SpawnOnce
import XMonad.Util.Run

import XMonad.Hooks.ManageDocks (avoidStruts)

import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed 
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Spiral

myTerminal      = "termite"
myLauncher      = "dmenu_run"
myFileManager   = "pcmanfm"
myBrowser       = "vivaldi-stable"
myEditor        = "emacs"

myBorderWidth   = 2
myGaps          = 2

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myModMask       = mod4Mask

myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

myNormalBorderColor  = "#6633f6"
myFocusedBorderColor = "#cc0dff"

myFont = "ttf: Fira Code,Fira Code Retina:style=Retina,Regular"

myKeys conf@(XConfig {XMonad.modMask = modKey}) = M.fromList $
    [ ((modKey , xK_Return), spawn $ XMonad.terminal conf)
    , ((modKey,                 xK_d     ), spawn myLauncher)
    , ((modKey,                 xK_w     ), spawn myBrowser)
    , ((modKey,                 xK_e     ), spawn myEditor)
    , ((modKey .|. shiftMask,   xK_Return), spawn myFileManager)
    , ((modKey .|. shiftMask,   xK_q     ), kill)
    , ((modKey,                 xK_space ), sendMessage NextLayout)
    , ((modKey .|. shiftMask,   xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modKey,                 xK_n     ), refresh)
    , ((modKey,                 xK_Tab   ), windows W.focusDown)
    , ((modKey .|. shiftMask,   xK_Tab   ), windows W.focusUp)
    , ((modKey,                 xK_j     ), windows W.focusDown)
    , ((modKey,                 xK_k     ), windows W.focusUp  )
    , ((modKey,                 xK_m     ), windows W.focusMaster)
    , ((modKey .|. controlMask, xK_Return), windows W.swapMaster)
    , ((modKey .|. shiftMask,   xK_j     ), windows W.swapDown)
    , ((modKey .|. shiftMask,   xK_k     ), windows W.swapUp )
    , ((modKey,                 xK_h     ), sendMessage Shrink)
    , ((modKey,                 xK_l     ), sendMessage Expand)
    , ((modKey,                 xK_t     ), withFocused $ windows . W.sink) -- push window back into tiling
    , ((modKey,                 xK_comma ), sendMessage (IncMasterN 1))
    -- toggle the status bar gap (used with avoidStruts from Hooks.ManageDocks)
    -- , ((modKey , xK_b ), sendMessage ToggleStruts)
    , ((modKey .|. shiftMask,   xK_x     ), io (exitWith ExitSuccess))
    , ((modKey,                 xK_x     ), restart "xmonad" True)
    ]
    ++
    [((m .|. modKey, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    ]

myLayout = avoidStruts $ myTiledLayout ||| Mirror myTiledLayout ||| fibonacci ||| Full 

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
    spawnOnce "picom &"
    spawnOnce "feh --bg-scale ~/Pictures/wallpaper/haskell.png &"
    spawnOnce "lxsession &"
    spawnOnce "udiskie &" 
    spawnOnce "xmobar &"

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
        manageHook         = myManageHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

main = do
  xmproc <- spawnPipe "xmobar  $HOME/.xmobarrc"
  xmonad myConfig
