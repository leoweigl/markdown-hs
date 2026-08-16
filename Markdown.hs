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
  let ls = lines a
  writeFile htmlFile (unlines (renderLines (-1) (markListLines ls)))

-- Block-level processing (lines -> grouped lines)

markListLines :: [String] -> [(String, Int)]
markListLines list = case list of
  [] -> []
  (x : xs) -> (x, listLevel x) : markListLines xs

renderLines :: Int -> [(String, Int)] -> [String]
renderLines lastLevel list = case list of
  [] -> [closeLi ++ closeUl | wasLast]
  (x, currentLevel) : xs -> case (wasLast, currentLevel /= -1, compare lastLevel currentLevel) of
    (True, True, LT) -> openUl : openLi : parseListContent x : renderLines currentLevel xs
    (_, True, LT) -> openUl : openLi : parseListContent x : renderLines currentLevel xs
    (True, True, EQ) -> closeLi : openLi : parseListContent x : renderLines currentLevel xs
    (True, True, GT) -> repeatTagPair closeLi closeUl (lastLevel - currentLevel) ++ closeLi : openLi : parseListContent x : renderLines currentLevel xs
    (True, _, _) -> repeatTagPair closeLi closeUl (lastLevel - currentLevel) ++ fromMaybeError (parseLine x) : renderLines currentLevel xs
    (_, _, _) -> [closeUl | wasLast] ++ fromMaybeError (parseLine x) : renderLines currentLevel xs
  where
    wasLast = lastLevel /= -1
    (openUl, closeUl) = tagPair (HtmlTag "ul")
    (openLi, closeLi) = tagPair (HtmlTag "li")

-- Line-level parsing (single line -> HTML)

parseLine :: String -> Maybe String
parseLine line = case line of
  [] -> Just "<br>"
  _ -> case (n, isValidHeading line) of
    (0, True) -> Just (parseItalic (parseBold ("<p>" ++ line ++ "</p>")))
    (_, True) -> Just (parseItalic (parseBold ("<h" ++ show n ++ ">" ++ stripLeadingSpaces (stripLeadingChar '#' line) ++ "</h" ++ show n ++ ">")))
    (_, _) -> Nothing
  where
    n = countLeading '#' line

parseListContent :: String -> String
parseListContent str = case stripLeadingSpaces str of
  [] -> []
  (_ : _ : xs) -> parseItalic (parseBold xs)

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