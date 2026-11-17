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
    ),
    (
      "heading level 1",
      "# a",
      "<h1>a</h1>\n"
    ),
    (
      "heading level 6",
      "###### a",
      "<h6>a</h6>\n"
    ),
    (
      "heading level 7 (invalid)",
      "####### a",
      "<p>####### a</p>\n"
    ),
    (
      "heading with no white space",
      "#a",
      "<p>#a</p>\n"
    ),
    (
      "no heading, white space first letter",
      " hello",
      "<p> hello</p>\n"
    ),
    (
      "unordered list 1",
      "- a",
      "<ul>\n<li>\na\n</li>\n</ul>\n"
    ),
    (
      "unordered list 2",
      "- a\n- b",
      "<ul>\n<li>\na\n</li>\n<li>\nb\n</li>\n</ul>\n"
    ),
    (
      "unordered list two levels 1",
      "- a\n  - b",
      "<ul>\n<li>\na\n<ul>\n<li>\nb\n</li>\n</ul>\n</li>\n</ul>\n"
    ),
    (
      "unordered list two levels and back",
      "- a\n  - b\n- c",
      "<ul>\n<li>\na\n<ul>\n<li>\nb\n</li>\n</ul>\n</li>\n<li>\nc\n</li>\n</ul>\n"
    ),
    (
      "unordered list three levels and back",
      "- a\n  - b\n    - c\n- d",
      "<ul>\n<li>\na\n<ul>\n<li>\nb\n<ul>\n<li>\nc\n</li>\n</ul>\n</li>\n</ul>\n</li>\n<li>\nd\n</li>\n</ul>\n"
    )
    -- (
    --   "unordered list skipped list level",
    --   "- a\n    - b",
    --   "<ul>\n<li>\na\n<ul>\n<li>\n<ul>\n<li>\nb\n</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>\n"
    -- )
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