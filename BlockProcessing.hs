module BlockProcessing where

import LineParsing (fromMaybeError, parseLine, parseListContent)
import StringUtils (countOccurrences, isOnlyCharOrSpace, prependToFirst, repeatTagPair)
import TagHelpers (HtmlTag (HtmlTag), tagPair)
import Validation (listLevel)

-- | Marks horizontal rules (three or more '-' or '*', spaces allowed) with True and replaces
-- the line with "<hr>". Non-rule lines stay untouched and protected lines are skipped.
markHorizontalRules :: [(String, Bool)] -> [(String, Bool)]
markHorizontalRules list = case list of
  [] -> []
  (x, y) : xs ->
    if not y && isHRule
      then ("<hr>", isHRule) : markHorizontalRules xs
      else (x, y) : markHorizontalRules xs
    where
      -- True if line is a rule by character occurrences of '-' or '*', otherwise False.
      isHRule = (isOnlyCharOrSpace '-' x && countOccurrences x '-' > 2) || (isOnlyCharOrSpace '*' x && countOccurrences x '*' > 2)

-- | Pairs each line with a Bool: True if the line is a code block fence, False otherwise.
markCodeBlocks :: [String] -> [(String, Bool)]
markCodeBlocks list = case list of
  [] -> []
  (x : xs) -> (x, take 3 x == "```") : markCodeBlocks xs

renderCodeBlocks :: [(String, Bool)] -> Bool -> [(String, Bool)]
renderCodeBlocks list blockActive = case list of
  [] -> [(closeC ++ closePre, True) | blockActive]
  [(x, False)]
    | blockActive -> [(x ++ closeC ++ closePre, True)]
  (x, False) : (_, True) : xs
    | blockActive -> (x ++ closeC ++ closePre, True) : renderCodeBlocks xs False
  (x, y) : xs -> case (blockActive, y) of
    (False, True) -> prependToFirst (openPre ++ openC) (renderCodeBlocks xs True)
    (True, True) -> (closeC ++ closePre, True) : renderCodeBlocks xs False
    (True, _) -> (x, True) : renderCodeBlocks xs True
    _ -> (x, False) : renderCodeBlocks xs False
  where
    (openPre, closePre) = tagPair (HtmlTag "pre")
    (openC, closeC) = tagPair (HtmlTag "code")

-- | Adds each line's list level (-1 if not a list item); the Bool marks
-- protected lines (code, rules) that 'renderLines' leaves untouched.
markListLines :: [(String, Bool)] -> [(String, Int, Bool)]
markListLines list = case list of
  [] -> []
  (x, y) : xs -> (x, listLevel x, y) : markListLines xs

-- | Takes a list with lines that are marked as lists, code or rules and renders
-- it to suitable HTML text and tags. Protected lines stay untouched, but open lists are closed.
-- The first argument is the list level of the previous line, or -1 if that line
-- was not a list item; start with -1 at the beginning of the file.
renderLines :: Int -> [(String, Int, Bool)] -> [String]
renderLines lastLevel list = case list of
  [] -> closeOpenLists
  (x, currentLevel, protected) : xs ->
    if protected
      -- protected block, close any open lists and forward -1 as list level
      then closeOpenLists ++ x : renderLines (-1) xs
      else case (wasLast, isCurrent, compare lastLevel currentLevel) of
        (_, True, LT) -> openUl : openLi : listItemRest
        (True, True, EQ) -> closeLi : openLi : listItemRest
        (True, True, GT) -> closingTags ++ closeLi : openLi : listItemRest
        (True, _, _) -> closingTags ++ noListItemRest
        -- not in a list, and last line was not a list item
        _ -> noListItemRest
    where
      isCurrent = currentLevel /= -1
      listItemRest = fromMaybeError (parseListContent x) : rest
      noListItemRest
        | isBlank = rest
        | otherwise = lineContent : rest
      closingTags = repeatTagPair closeLi closeUl (lastLevel - currentLevel)
      -- empty lines (see parseLine) produce no output
      isBlank = null lineContent
      lineContent = fromMaybeError (parseLine x)
      rest = renderLines currentLevel xs
  where
    wasLast = lastLevel /= -1
    (openUl, closeUl) = tagPair (HtmlTag "ul")
    (openLi, closeLi) = tagPair (HtmlTag "li")
    closeOpenLists = repeatTagPair closeLi closeUl (lastLevel + 1)

convert :: String -> String
convert file = unlines htmlLines
  where
    markedCodeBlocks = markCodeBlocks (lines file)
    codeBlocks = renderCodeBlocks markedCodeBlocks False
    horizontalRules = markHorizontalRules codeBlocks
    listLines = markListLines horizontalRules
    htmlLines = renderLines (-1) listLines