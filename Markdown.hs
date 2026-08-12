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
  writeFile htmlFile (unlines (renderLines False (markListLines ls)))


-- Block-level processing (lines -> grouped lines)

markListLines :: [String] -> [(String, Bool)]
markListLines list = case list of
  [] -> []
  (x : xs) -> (x, isListItem x) : markListLines xs

renderLines :: Bool -> [(String, Bool)] -> [String]
renderLines wasLast list = case list of
  [] -> [b | wasLast]
  (x, y) : xs -> case (wasLast, y) of
    (True, True) -> parseListItem x : renderLines y xs
    (False, True) -> a : parseListItem x : renderLines y xs
    _ -> [b | wasLast] ++ fromMaybeError (parseLine x) : renderLines y xs
  where
    (a, b) = tagPair (HtmlTag "ul")


-- Line-level parsing (single line -> HTML)

parseLine :: String -> Maybe String
parseLine line = case line of
  [] -> Just "<br>"
  _ -> case (n, isValidHeading line, isListItem line) of
    (0, True, True) -> Just (parseItalic (parseBold (parseListItem line)))
    (0, True, _) -> Just (parseItalic (parseBold ("<p>" ++ line ++ "</p>")))
    (_, True, _) -> Just (parseItalic (parseBold ("<h" ++ show n ++ ">" ++ stripLeadingSpaces (stripLeadingChar '#' line) ++ "</h" ++ show n ++ ">")))
    (_, _, _) -> Nothing
  where
    n = countLeading '#' line

parseListItem :: String -> String
parseListItem str = case str of
  [] -> []
  (_ : _ : xs) -> a ++ parseItalic (parseBold xs) ++ b
  where
    (a, b) = tagPair (HtmlTag "li")

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
isListItem str = case str of
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