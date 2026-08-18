module Main where

import BlockProcessing (markCodeBlocks, markHorizontalRules, markListLines, renderCodeBlocks, renderLines)
import Config

main :: IO ()
main = do
  a <- readFile mdFile
  let rawLines = lines a
      codeBlockLines = renderCodeBlocks (markCodeBlocks rawLines) False
      horizontalRules = markHorizontalRules codeBlockLines
      listLines = markListLines horizontalRules
  writeFile htmlFile (unlines (renderLines (-1) listLines))