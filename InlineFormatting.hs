module InlineFormatting where

import StringUtils (splitOnChar, splitOnString)
import TagHelpers (HtmlTag (HtmlTag), tagPair)

parseItalic :: String -> String
parseItalic line = case line of
  [] -> []
  _ -> concat (wrapMarkedSegments (withIndices (splitOnChar (== '*') line)) (HtmlTag "em"))

parseBold :: String -> String
parseBold line = case line of
  [] -> []
  _ -> concat (wrapMarkedSegments (withIndices (splitOnString (== "**") line)) (HtmlTag "strong"))

parseCode :: String -> String
parseCode line = case line of
  [] -> []
  _ -> concat (wrapSegments (withIndices (splitOnChar (== '`') line)))

withIndices :: [String] -> [(Int, String)]
withIndices list = case list of
  [] -> []
  _ -> zip [0 .. length list - 1] list

wrapMarkedSegments :: [(Int, String)] -> HtmlTag -> [String]
wrapMarkedSegments list tag = case list of
  [] -> []
  (x, y) : xs ->
    if even x
      then y : wrapMarkedSegments xs tag
      else case tagPair tag of
        (a, b) -> (a ++ y ++ b) : wrapMarkedSegments xs tag

wrapSegments :: [(Int, String)] -> [String]
wrapSegments list = case list of
  [] -> []
  (x, y) : xs ->
    if even x
      then parseItalic (parseBold y) : wrapSegments xs
      else openC : y : closeC : wrapSegments xs
  where
    (openC, closeC) = tagPair (HtmlTag "code")