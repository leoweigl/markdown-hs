module Validation where

import StringUtils (stripLeadingSpaces)

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