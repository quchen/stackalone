#!/usr/bin/env stack
{- stack
    --resolver lts-8.0
    --install-ghc
    runghc
    --package process
    --package base
    --package text
    --
    -hide-all-packages
-}

{-# OPTIONS_GHC -Wall -Wcompat #-}
{-# LANGUAGE OverloadedStrings #-}


module Main (main) where

import           Data.Semigroup
import           Data.Text      (Text)
import qualified Data.Text      as T
import qualified Data.Text.IO   as T
import           System.Exit
import           System.Process



stackaloneDir :: FilePath
stackaloneDir = ".stackalone"

main :: IO ()
main = do
    mkdir stackaloneDir
    packages <- getAllPackageDeps
    unpackPackages packages
    generateStackYaml packages
    pure ()

mkdir :: FilePath -> IO ()
mkdir dirname = callCommand ("mkdir -p " ++ dirname)

getAllPackageDeps :: IO [(Text, Text)]
getAllPackageDeps = do
    (exitCode, stdOut, stdErr) <- readCreateProcessWithExitCode
        (proc "stack"
              [ "list-dependencies"
              , "--external"
              , "--test"
              , "--bench"
              , "--no-include-base"
              , "--prune", "ghc" ])
        { cwd = Just stackaloneDir }
        ""
    case exitCode of
        ExitSuccess ->
            let outputLines = T.lines (T.pack stdOut)
                extractPackage = (\[package, version] -> (package, version)) . T.splitOn " "
            in pure (map extractPackage outputLines)
        ExitFailure err -> error ("Error getting deps (" ++ show err ++ ") - STDERR: " ++ stdErr)

unpackPackages :: [(Text, version)] -> IO ()
unpackPackages packages =
    let command = "stack unpack " <> T.unpack (T.unwords (map (\(p,_) -> p) packages))
    in readCreateProcess (shell command) { cwd = Just stackaloneDir } "" *> pure ()

generateStackYaml :: [(Text, Text)] -> IO ()
generateStackYaml packages = T.putStrLn (mconcat (map stackYamlify packages))
  where
    stackYamlify (name, version) = T.unlines
        [ "- location: " <> T.pack stackaloneDir <> "/" <> name <> "-" <> version
        , "  extra-dep: true" ]
