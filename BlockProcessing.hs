module BlockProcessing where

import LineParsing (fromMaybeError, parseLine, parseListContent)
import StringUtils (repeatTagPair)
import TagHelpers (HtmlTag (HtmlTag), tagPair)
import Validation (listLevel)

markCodeBlocks :: [String] -> [(String, Bool)]
markCodeBlocks list = case list of
  [] -> []
  (x : xs) -> (x, take 3 x == "```") : markCodeBlocks xs

renderCodeBlocks :: [(String, Bool)] -> Bool -> [(String, Bool)]
renderCodeBlocks list blockActive = case list of
  [] -> [(closeC ++ closePre, True) | blockActive]
  (x, y) : xs -> case (blockActive, y) of
    (False, True) -> (openPre ++ openC, protected) : renderCodeBlocks xs True
    (True, True) -> (closeC ++ closePre, protected) : renderCodeBlocks xs False
    (True, _) -> (x, protected) : renderCodeBlocks xs True
    _ -> (x, protected) : renderCodeBlocks xs False
    where
      protected = blockActive || y
  where
    (openPre, closePre) = tagPair (HtmlTag "pre")
    (openC, closeC) = tagPair (HtmlTag "code")

-- bool is for protected items
markListLines :: [(String, Bool)] -> [(String, Int, Bool)]
markListLines list = case list of
  [] -> []
  (x, y) : xs -> (x, listLevel x, y) : markListLines xs

renderLines :: Int -> [(String, Int, Bool)] -> [String]
renderLines lastLevel list = case list of
  [] -> [closeLi ++ closeUl | wasLast]
  (x, currentLevel, protected) : xs ->
    if protected
      then x : renderLines currentLevel xs
      else case (wasLast, isCurrent, compare lastLevel currentLevel) of
        (_, True, LT) -> openUl : openLi : listItemRest
        (True, True, EQ) -> closeLi : openLi : listItemRest
        (True, True, GT) -> closingTags ++ closeLi : openLi : listItemRest
        (True, _, _) -> closingTags ++ noListItemRest
        (_, _, _) -> [closeUl | wasLast] ++ noListItemRest
    where
      isCurrent = currentLevel /= -1
      listItemRest = parseListContent x : renderLines currentLevel xs
      noListItemRest = fromMaybeError (parseLine x) : renderLines currentLevel xs
      closingTags = repeatTagPair closeLi closeUl (lastLevel - currentLevel)
  where
    wasLast = lastLevel /= -1
    (openUl, closeUl) = tagPair (HtmlTag "ul")
    (openLi, closeLi) = tagPair (HtmlTag "li")