module Main where

import BlockProcessing (markCodeBlocks, markListLines, renderCodeBlocks, renderLines)
import Config

main :: IO ()
main = do
  a <- readFile mdFile
  let rawLines = lines a
      codeBlockLines = renderCodeBlocks (markCodeBlocks rawLines) False
      listLines = markListLines codeBlockLines
  writeFile htmlFile (unlines (renderLines (-1) listLines))