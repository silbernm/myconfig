-- Copyright 2017-2018 Maximilian Huber <oss@maximilian-huber.de>
-- SPDX-License-Identifier: MIT
-- ~/.xmonad/xmonad.hs
-- needs xorg-xmessage for error messages
--
-- xmonad-extras from cabal
--
-- used software
--  dmenu        to start software
--  dwb          fast browser
--  scrot        screenshot tool
--  imagemagic   screenshot tool
--  slim         screenlock tool
--  xss-lock     automatic locking
--  unclutter    to hide mouse pointer
--  urxvt        terminal
--  xcalib       invert colors
--  xmobar       bar
--  pass         password manager
{-# OPTIONS_GHC -W -fwarn-unused-imports -fno-warn-missing-signatures #-}
{-# LANGUAGE CPP #-}

------------------------------------------------------------------------
-- Imports:
import           Data.Foldable (foldMap)
import           Data.Ratio ((%))
import           System.Exit ( exitSuccess )
import           System.IO ( hPutStrLn )
import           XMonad
import           Graphics.X11.ExtraTypes.XF86()

--------------------------------------------------------------------------------
-- Prompt

--------------------------------------------------------------------------------
-- Hooks
import           XMonad.Hooks.DynamicLog ( dynamicLogWithPP
                                         , PP(..)
                                         , xmobarColor
                                         , wrap )
import           XMonad.Hooks.EwmhDesktops ( fullscreenEventHook )
import           XMonad.Hooks.ManageDocks ( docks
                                          , avoidStrutsOn
                                          , ToggleStruts(..) )
import           XMonad.Hooks.ManageHelpers ( doCenterFloat )
import           XMonad.Hooks.UrgencyHook ( focusUrgent 
                                          , withUrgencyHook)
import           XMonad.Hooks.SetWMName ( setWMName )

--------------------------------------------------------------------------------
-- Util
import           XMonad.Util.Run ( runProcessWithInput, spawnPipe )
import           XMonad.Util.Types ( Direction2D(..) )

--------------------------------------------------------------------------------
-- Actions
import           XMonad.Actions.CycleWS ( nextWS, prevWS
                                        , toggleWS'
                                        , shiftToNext, shiftToPrev
                                        , nextScreen, prevScreen
                                        , shiftNextScreen, shiftPrevScreen
                                        , moveTo
                                        , Direction1D(..)
                                        , WSType( NonEmptyWS ) )
import           XMonad.Actions.GridSelect
import           XMonad.Actions.WindowGo ( runOrRaiseNext, raiseNext )

--------------------------------------------------------------------------------
-- Layouts
import           XMonad.Layout.BoringWindows( boringAuto
                                            , focusDown )
import           XMonad.Layout.Gaps (gaps)
import           XMonad.Layout.Named ( named )
import           XMonad.Layout.NoBorders ( smartBorders )
import           XMonad.Layout.Minimize ( minimize, minimizeWindow
                                        , MinimizeMsg(RestoreNextMinimizedWin) )
import           XMonad.Layout.MultiToggle
import           XMonad.Layout.MultiToggle.Instances
import           XMonad.Layout.PerScreen (ifWider)
import           XMonad.Layout.PerWorkspace ( modWorkspaces )
import           XMonad.Layout.ResizableTile ( ResizableTall(ResizableTall)
                                             , MirrorResize ( MirrorShrink
                                                            , MirrorExpand ) )
import           XMonad.Layout.Spacing (spacing)
import           XMonad.Layout.TwoPane (TwoPane(TwoPane))
import           XMonad.Layout.IM -- (withIM)

import           XMonad.Layout.IfMax

--------------------------------------------------------------------------------
-- misc
import qualified Data.Map                    as M
import qualified XMonad.StackSet             as W

--------------------------------------------------------------------------------
-- MyConfig
import XMonad.MyConfig.Utils
import XMonad.MyConfig.Common
import XMonad.MyConfig.Scratchpads
import XMonad.MyConfig.ToggleFollowFocus
import XMonad.MyConfig.Notify
import XMonad.MyConfig.MyLayoutLayer

------------------------------------------------------------------------
-- Key bindings:
myKeys conf =
  M.fromList $
  mapToWithModM conf $
       basicKBs
    ++ miscKBs
    ++ backlightControlKBs
    ++ systemctlKBs
  where
    basicKBs =
      [ ((ms_            , xK_Return), spawn $ XMonad.terminal conf)
      , ((msc, xK_Return), spawn "urxvtd -q -f -o &")
#if 1
      , ((m4m, xK_Return), windows W.swapMaster)
#else
      , ((m__, xK_Return), windows W.swapMaster)
#endif
      , ((m__, xK_q     ), spawn "xmonad --restart")
      , ((ms_, xK_q     ), spawn "xmonad --recompile && sleep 0.1 && xmonad --restart")
      , ((msc, xK_q     ), io exitSuccess)
      , ((m__, xK_p     ), spawn "`dmenu_path | yeganesh`")
      -- , ((m__, xK_x     ), shellPrompt defaultXPConfig)


      , ((ms_, xK_c     ), kill)

#if 0
      , ((m__, xK_Tab   ), windows W.focusDown)
      , ((m_c, xK_Tab   ), windows W.focusUp >> windows W.shiftMaster)
#else
      , ((m_c, xK_Tab   ), windows W.focusDown)
      , ((m__, xK_Tab   ), windows W.focusUp >> windows W.shiftMaster)
#endif
      , ((ms_, xK_Tab   ), focusDown)
      , ((m__, xK_u     ), focusUrgent)

      , ((m__, xK_j     ), windows W.focusDown)
      , ((m__, xK_k     ), windows W.focusUp)
      , ((ms_, xK_j     ), windows W.swapDown)
      , ((ms_, xK_k     ), windows W.swapUp)
      , ((m__, xK_o     ), spawn "urxvtc -e bash -c 'EDITOR=vim ranger'")
      , ((m_c, xK_Return), spawn "urxvtc -e zsh -c 'ssh vserver'")
      , ((ms_, xK_p     ), spawn "passmenu")]
      ++ switchWorkspaceKBs
      where
        switchWorkspaceKBs =
          -- mod-[1..9], Switch to workspace N
          -- mod-shift-[1..9], Move client to workspace N
          [((m, k), f i)
              | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0])
              , (f, m) <- [ (\i -> windows (W.greedyView i) >> popupCurDesktop, m__)
                          , (windows . W.shift, ms_) ]]
        {-
        switchPhysicalKBs =
          -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
          -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
          [((m .|. m__, k), screenWorkspace sc >>= flip whenJust (windows . f))
              | (k, sc) <- zip [xK_w, xK_e, xK_r] [0..]
              , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
         -}
    systemctlKBs =
      map (\(k,v) -> (k, spawn $ "systemctl " ++ v))
        [ ((ms_, xK_F10), "suspend")
        , ((msc, xK_F11), "reboot")
        , ((msc, xK_F12), "poweroff")]
    miscKBs =
      [ ((const 0,   0x1008ffa9), spawn "synclient TouchpadOff=$(synclient -l | grep -c 'TouchpadOff.*=.*0')")
      , ((m__, xK_s      ), spawn "find-cursor")
      , ((msc, xK_s      ), spawn "xdotool mousemove 0 0; synclient TouchpadOff=$(synclient -l | grep -c 'TouchpadOff.*=.*0')")
      , ((m__, xK_z      ), spawn "myautosetup.pl --onlyIfChanged")
      , ((ms_, xK_z      ), spawn "myautosetup.pl")
      , ((msc, xK_z      ), spawn "myautosetup.pl --rotate=left --primOutNr=1")
#if 1
      , ((ms_, xK_y      ), spawn "xset s activate") -- screenlocker
#else
      , ((ms_, xK_y      ), spawn "slimlock") -- screenlocker
#endif

#if 1
      -- invert Colors (does not work with retdshift)
      , ((m__,  xK_Home   ), spawn "xrandr-invert-colors")
#else
      , ((m__,  xK_Home   ), spawn "xcalib -i -a")
#endif

      , ((m__,  xK_Print  ), spawn "screenshot.sh")
         -- or:
         -- - "bash -c \"import -frame ~/screen_`date +%Y-%m-%d_%H-%M-%S`.png\"")
         -- - "mkdir -p ~/_screenshots/ && scrot ~/_screenshots/screen_%Y-%m-%d_%H-%M-%S.png -d 1"

      -- keyboard layouts
      , ((m__,  xK_F2     ), spawn "feh ~/.xmonad/neo/neo_Ebenen_1_2_3_4.png")
      , ((m__,  xK_F3     ), spawn "feh ~/.xmonad/neo/neo_Ebenen_1_2_5_6.png")]
      ++ volumeControlls
      where
        volumeControlls =
#if 1
-- pulseaudio
          map (\(k,args) -> ((const 0, k)
                         , runProcessWithInput "/home/mhuber/.xmonad/bin/mypamixer.sh" args ""
                           >>= myDefaultPopup . ("V: " ++)
                         ))
            [ (0x1008ff12, ["mute"])
            , (0x1008ff11, ["-10%"])
            , (0x1008ff13, ["+10%"])]
#else
-- alsa
          map (\(k,v) -> ((const 0, k)
                         , runProcessWithInput "/home/mhuber/.xmonad/bin/myamixer.sh" v ""
                           >>= myDefaultPopup
                         ))
            [ (0x1008ff12, ["toggle"])
            , (0x1008ff11, ["6dB-"])
            , (0x1008ff13, ["unmute","3dB+"])]
#endif
    backlightControlKBs =
      [((m__, xK_F1), spawnSelected def [ "xbacklight =50"
                                        , "xbacklight =25"
                                        , "xbacklight +10"
                                        , "xbacklight =75"
                                        , "xbacklight -10"
                                        , "xbacklight =10"
                                        , "xbacklight =5"
                                        , "xbacklight +1"
                                        , "xbacklight =3"
                                        , "xbacklight =100"
                                        , "xbacklight =1"
                                        , "xbacklight -1"
                                        , "xbacklight =0" ])]

------------------------------------------------------------------------
-- Window rules:
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = let
  baseHooks = (foldMap (\(a,cs) -> map (\c -> className =? c --> a) cs)
                             [ (doCenterFloat, ["Xmessage"
                                               ,"qemu","qemu-system-x86_64"
                                               ,"feh"
                                               ,"Zenity"
                                               ,"pinentry","Pinentry"
                                               ,"pavucontrol","Pavucontrol"
                                               ,"zoom"])
                             , (doFloat, ["MPlayer"
                                         ,"Onboard"])
                             , (doShift "web", ["Firefox"
                                               ,"Chromium","chromium-browser"])
                             , (doShift "10", ["franz","Franz"])
                             , (doShift "vbox", ["Virtualbox","VirtualBox"])
                             , (doShift "media", ["Steam"])
                             , (doIgnore, ["desktop_window"
                                          ,"kdesktop"]) ])
  -- see:
  -- - https://www.reddit.com/r/xmonad/comments/78uq0p/how_do_you_deal_with_intellij_idea_completion/?st=jgdc0si0&sh=7d79c956
  -- - https://youtrack.jetbrains.com/issue/IDEA-112015#comment=27-2498787
  ideaPopupHook = [ appName =? "sun-awt-X11-XWindowPeer" <&&> className =? "jetbrains-idea" --> doIgnore ]
  in composeAll (baseHooks ++ ideaPopupHook)

------------------------------------------------------------------------
-- Startup hook:
myStartupHook :: X ()
myStartupHook = do
  setWMName "LG3D"
  spawn "pkill unclutter; unclutter"
  spawn "xset s 900"

------------------------------------------------------------------------
-- Log hook:
myLogHook xmproc = let
  myXmobarPP = def { ppOutput  = hPutStrLn xmproc . shortenStatus
                   , ppCurrent = xmobarColor maincolor "" . wrap "<" ">"
                   , ppSort    = scratchpadPPSort
                   , ppTitle   = (" " ++) . xmobarColor maincolor ""
                   , ppVisible = xmobarColor maincolor ""
                   }
  in dynamicLogWithPP myXmobarPP

------------------------------------------------------------------------
-- General

normalcolor = "#333333" :: String
maincolor = "#ee9a00" :: String
myConfig xmproc = withUrgencyHook myUrgencyHook $
                  applyMyScratchpads $
                  applyMyFollowFocus $
                  applyMyLayoutModifications $
                  def { terminal           = "urxvtc"
                      , borderWidth        = 3
                      , modMask            = mod1Mask --  mod4Mask
                      , normalBorderColor  = normalcolor
                      , focusedBorderColor = maincolor
                      , keys               = myKeys
                      , layoutHook         = myLayout
                      , manageHook         = myManageHook
                      , startupHook        = myStartupHook
                      , logHook            = myLogHook xmproc
                      }

------------------------------------------------------------------------
-- Now run xmonad
main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc"
  xmonad $ myConfig xmproc
