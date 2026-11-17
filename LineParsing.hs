module LineParsing where

import InlineFormatting (parseCode)
import StringUtils (stripLeadingChar, stripLeadingSpaces)
import TagHelpers (HtmlTag (HtmlTag), tagPair)
import Validation (countLeading, isValidHeading)

parseLine :: String -> String
parseLine line = case line of
  -- empty line: no output; renderLines skips empty results
  [] -> ""
  _ ->
    if isValidHeading line
      then openH ++ parseCode (stripLeadingSpaces (stripLeadingChar '#' line)) ++ closeH
      else openP ++ parseCode line ++ closeP
  where
    n = countLeading '#' line
    (openH, closeH) = tagPair (HtmlTag ("h" ++ show n))
    (openP, closeP) = tagPair (HtmlTag "p")

-- | Drops the marker ("- ") and parses the rest.
-- Nothing if there is no content after the marker (e.g. "", "-", "- ").
parseListContent :: String -> Maybe String
parseListContent str = case stripLeadingSpaces str of
  (_ : _ : xs) | not (null xs) -> Just (parseCode xs)
  _ -> Nothing

fromMaybeError :: Maybe String -> String
fromMaybeError str = case str of
  Just s -> s
  _ -> "<!-- Error: invalid line -->"