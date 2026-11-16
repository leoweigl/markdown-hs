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

testPattern :: (String, String, String) -> (String, Bool)
testPattern (name, markdown, expHtml) =
  if convert markdown == expHtml
    then ("OK: " ++ name, True)
    else ("ERROR: " ++ name, False)

main :: IO ()
main = do
  mapM_ putStrLn infos
  putStrLn summary
  where
    results = map testPattern testData
    infos = map fst results
    passed = length (filter snd results)
    total = length results
    summary = show passed ++ " of " ++ show total ++ " tests passed"