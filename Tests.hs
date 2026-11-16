module Main where

import BlockProcessing (convert)

fence :: String
fence = replicate 3 '`'

testData :: [(String, String, String)]
testData =
  [ ( "closed codeblock",
      "a\n" ++ fence ++ "\ncode\n" ++ fence,
      "<p>a</p>\n<pre><code>code</code></pre>\n"
    ),
    ( "open codeblock at end",
      "a\n" ++ fence ++ "\ncode\n",
      "<p>a</p>\n<pre><code>code</code></pre>\n"
    ),
    ( "fence as last line",
      "a\n" ++ fence,
      "<p>a</p>\n<pre><code></code></pre>\n"
    ),
    ( "empty codeblock",
      fence ++ "\n" ++ fence,
      "<pre><code></code></pre>\n"
    ),
    ( "multiple line code block",
      "a\n" ++ fence ++ "\ncode\nother code\n" ++ fence,
      "<p>a</p>\n<pre><code>code\nother code</code></pre>\n"
    )
  ]

testPattern :: (String, String, String) -> String
testPattern (name, markdown, expHtml) =
  if convert markdown == expHtml
    then "OK: " ++ name
    else "ERROR: " ++ name

main :: IO ()
main = mapM_ (putStrLn . testPattern) testData