module LineParsing where

import InlineFormatting (parseCode)
import StringUtils (stripLeadingChar, stripLeadingSpaces)
import TagHelpers (HtmlTag (HtmlTag), tagPair)
import Validation (countLeading, isValidHeading)

parseLine :: String -> Maybe String
parseLine line = case line of
  [] -> Just "<br>"
  _ -> case (n, isValidHeading line) of
    (0, True) -> Just (openP ++ parseCode line ++ closeP)
    (_, True) -> Just (openH ++ parseCode (stripLeadingSpaces (stripLeadingChar '#' line)) ++ closeH)
    (_, _) -> Nothing
  where
    n = countLeading '#' line
    (openH, closeH) = tagPair (HtmlTag ("h" ++ show n))
    (openP, closeP) = tagPair (HtmlTag "p")

parseListContent :: String -> String
parseListContent str = case stripLeadingSpaces str of
  [] -> []
  (_ : _ : xs) -> parseCode xs

fromMaybeError :: Maybe String -> String
fromMaybeError str = case str of
  Just s -> s
  _ -> "<!-- Error: invalid line -->"