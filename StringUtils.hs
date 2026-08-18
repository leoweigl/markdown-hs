module StringUtils where

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

isOnlyCharOrSpace :: Char -> String -> Bool
isOnlyCharOrSpace char str = case str of
  [] -> True
  (x : xs) -> (x == char || x == ' ') && isOnlyCharOrSpace char xs

countOccurences :: String -> Char -> Int
countOccurences str char = case str of
  [] -> 0
  (x : xs) ->
    if x == char
      then 1 + countOccurences xs char
      else countOccurences xs char