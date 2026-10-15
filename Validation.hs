module Validation where

import StringUtils (stripLeadingSpaces)

isValidHeading :: String -> Bool
isValidHeading str =
  n == 0
    || case compare n 7 of
      LT -> case drop n str of
        [] -> True
        (x : _) -> x == ' '
      _ -> False
  where
    n = countLeading '#' str

-- | True if the line is a list item. "-" and "- " are not list items.
-- Content made of spaces only still counts ("-   ").
isListItem :: String -> Bool
isListItem str = case stripLeadingSpaces str of
  (x : y : xs) | not (null xs) -> case (x, y) of
    ('-', ' ') -> True
    _ -> False
  _ -> False

countLeading :: Char -> String -> Int
countLeading char str = case str of
  (x : xs)
    | x == char -> 1 + countLeading char xs
    | otherwise -> 0
  _ -> 0

-- | Returns the indentation level of a list item, -1 if it's not a list item.
-- One level per two leading spaces.
listLevel :: String -> Int
listLevel str =
  if not (isListItem str)
    then -1
    else div (countLeading ' ' str) 2