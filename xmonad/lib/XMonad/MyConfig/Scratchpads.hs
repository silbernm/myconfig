-- Copyright 2017-2018 Maximilian Huber <oss@maximilian-huber.de>
-- SPDX-License-Identifier: MIT
module XMonad.MyConfig.Scratchpads
       ( applyMyScratchpads
       , scratchpadPPSort)
       where

import XMonad
import           XMonad.Util.EZConfig (additionalKeys)
import           XMonad.Util.NamedScratchpad ( NamedScratchpad(..)
                                             , customFloating , nonFloating
                                             , namedScratchpadAction
                                             , namedScratchpadFilterOutWorkspace
                                             , namedScratchpadManageHook )
import           XMonad.Hooks.DynamicLog ( def, PP(..))
import qualified XMonad.StackSet             as W

import XMonad.MyConfig.Common

applyMyScratchpads :: XConfig a -> XConfig a
applyMyScratchpads c = c { manageHook = manageHook c <+> scratchpadHook c
                         } `additionalKeys` (mapToWithModM c (scratchpadKBs c))

-- Scratchpads
--
scratchpads :: XConfig a -> [NamedScratchpad]
scratchpads c =
  let
    mkTermCmd name cmd = "SHLVL=0 " ++ (terminal c) ++ " -name " ++ name ++ " -e " ++ cmd
  in
    [ NS "scratchpad" (mkTermCmd "Scratchpad" "~/.xmonad/bin/tmux-scratch.sh")
        (resource =? "Scratchpad")
        (customFloating $ W.RationalRect (1/12) (1/10) (5/6) (4/5))
    , NS "ScratchWeb" "Chromium" (resource =? "Chromium") nonFloating
        {-(customFloating $ W.RationalRect (1/64) (3/128) (31/32) (31/32))-}
    , NS "ncmpcpp" (mkTermCmd "Ncmpcpp" "ncmpcpp")
        (resource =? "Ncmpcpp")
        (customFloating $ W.RationalRect (1/2) (1/5) (1/2) (4/5))
    , NS "notepad" "SHLVL=0 /usr/bin/emacsclient -a \"\" -nc ~/Sync/org/index.org"
        (resource =? "Notepad")
        (customFloating $ W.RationalRect (4/12) (3/20) (7/12) (4/5))
   , NS "ScratchMutt" (mkTermCmd "ScratchMutt" "bash -c \"~/bin/mailclient.sh\"")
       (resource =? "ScratchMutt")
       (customFloating $ W.RationalRect (1/24) (3/20) (5/6) (4/5))
   , NS "ScratchAlsa" (mkTermCmd "ScratchAlsa" "bash -c alsamixer")
       (resource =? "ScratchAlsa")
       (customFloating $ W.RationalRect (1/24) (3/20) (5/6) (4/5))
   , NS "ScratchHtop" (mkTermCmd "ScratchHtop" "bash -c htop")
       (resource =? "ScratchHtop")
       (customFloating $ W.RationalRect (1/10) (1/10) (4/5) (4/5))
   , NS "ScratchNMTUI" (mkTermCmd "ScratchHtop" "bash -c htop")
       (resource =? "ScratchNMTUI")
       (customFloating $ W.RationalRect (1/10) (1/10) (4/5) (4/5)) ]

scratchpadKBs c =
  map (\(k,d) -> (k, namedScratchpadAction (scratchpads c) d))
  [ ((m__, xK_minus), "scratchpad")
  , ((m__, xK_i    ), "ScratchWeb")
  , ((ms_, xK_i    ), "ScratchMutt")
  , ((m__, xK_n    ), "notepad")
  , ((ms_, 0xf6    ), "ncmpcpp")]

scratchpadHook c = namedScratchpadManageHook (scratchpads c)

scratchpadPPSort = (. namedScratchpadFilterOutWorkspace) <$> ppSort def
