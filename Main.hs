module Main where

import BlockProcessing (markCodeBlocks, markhorizontalRules, markListLines, renderCodeBlocks, renderLines)
import Config

main :: IO ()
main = do
  a <- readFile mdFile
  let rawLines = lines a
      codeBlockLines = renderCodeBlocks (markCodeBlocks rawLines) False
      horizontalRules = markhorizontalRules codeBlockLines
      listLines = markListLines horizontalRules
  writeFile htmlFile (unlines (renderLines (-1) listLines))