module Main where

import BlockProcessing (convert)
import Config

main :: IO ()
main = do
  markdown <- readFile mdFile
  writeFile htmlFile (convert markdown)