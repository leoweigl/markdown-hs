{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use newtype instead of data" -}
module Main where

import Config

-- Types & tag helpers

newtype HtmlTag = HtmlTag String

tagPair :: HtmlTag -> (String, String)
tagPair (HtmlTag a) = ("<" ++ a ++ ">", "</" ++ a ++ ">")

-- Main function

main :: IO ()
main = do
  a <- readFile mdFile
  let rawLines = lines a
      codeBlockLines = renderCodeBlocks (markCodeBlocks rawLines) False
      listLines = markListLines codeBlockLines
  writeFile htmlFile (unlines (renderLines (-1) listLines))

-- Block-level processing (lines -> grouped lines)

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

-- Line-level parsing (single line -> HTML)

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

-- Validation

isValidHeading :: String -> Bool
isValidHeading str =
  n == 0
    || case compare n 7 of
      LT -> case drop n str of
        [] -> True
        (x : xs) -> x == ' '
      _ -> False
  where
    n = countLeading '#' str

isListItem :: String -> Bool
isListItem str = case stripLeadingSpaces str of
  (x : y : xs) -> case (x, y) of
    ('-', ' ') -> True
    _ -> False
  _ -> False

countLeading :: Char -> String -> Int
countLeading char str = case str of
  (x : xs)
    | x == char -> 1 + countLeading char xs
    | otherwise -> 0
  _ -> 0

listLevel :: String -> Int
listLevel str =
  if not (isListItem str)
    then -1
    else div (countLeading ' ' str) 2

-- Inline formatting (bold/italic)

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

splitOnChar :: (Char -> Bool) -> String -> [String]
splitOnChar f str = case str of
  [] -> [""]
  (x : xs) ->
    if f x
      then "" : splitOnChar f xs
      else case splitOnChar f xs of
        (y : ys) -> (x : y) : ys
        _ -> error splitImpossible

splitOnString :: (String -> Bool) -> String -> [String]
splitOnString f str = case str of
  [] -> [""]
  (x : xs) -> case xs of
    [] -> [[x]]
    (y : ys) ->
      if f (x : [y])
        then "" : splitOnString f ys
        else case splitOnString f (y : ys) of
          (z : zs) -> (x : z) : zs
          _ -> error splitImpossible

splitImpossible :: String
splitImpossible = "split: impossible, recursive call never returns []"

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

-- Generic string utilities

stripLeadingChar :: Char -> String -> String
stripLeadingChar char str = case str of
  [] -> []
  (x : xs)
    | x == char -> stripLeadingChar char xs
    | otherwise -> str

stripLeadingSpaces :: String -> String
stripLeadingSpaces str = case str of
  [] -> []
  (x : xs)
    | x == ' ' -> stripLeadingSpaces xs
    | otherwise -> str

repeatTagPair :: String -> String -> Int -> [String]
repeatTagPair tag1 tag2 n =
  if n <= 0
    then []
    else tag1 : tag2 : repeatTagPair tag1 tag2 (n - 1)