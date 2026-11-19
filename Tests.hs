module Main where

import BlockProcessing (convert)

fence :: String
fence = replicate 3 '`'

testCases :: [(String, String, String)]
testCases =
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
    ( "heading level 1",
      "# a",
      "<h1>a</h1>\n"
    ),
    ( "heading level 6",
      "###### a",
      "<h6>a</h6>\n"
    ),
    ( "heading level 7 (invalid)",
      "####### a",
      "<p>####### a</p>\n"
    ),
    ( "heading with no white space",
      "#a",
      "<p>#a</p>\n"
    ),
    ( "no heading, white space first letter",
      " hello",
      "<p> hello</p>\n"
    ),
    ( "unordered list 1",
      "- a",
      "<ul>\n<li>\na\n</li>\n</ul>\n"
    ),
    ( "unordered list 2",
      "- a\n- b",
      "<ul>\n<li>\na\n</li>\n<li>\nb\n</li>\n</ul>\n"
    ),
    ( "unordered list two levels 1",
      "- a\n  - b",
      "<ul>\n<li>\na\n<ul>\n<li>\nb\n</li>\n</ul>\n</li>\n</ul>\n"
    ),
    ( "unordered list two levels and back",
      "- a\n  - b\n- c",
      "<ul>\n<li>\na\n<ul>\n<li>\nb\n</li>\n</ul>\n</li>\n<li>\nc\n</li>\n</ul>\n"
    ),
    ( "unordered list three levels and back",
      "- a\n  - b\n    - c\n- d",
      "<ul>\n<li>\na\n<ul>\n<li>\nb\n<ul>\n<li>\nc\n</li>\n</ul>\n</li>\n</ul>\n</li>\n<li>\nd\n</li>\n</ul>\n"
    ),
    ( "unordered list skipped list level",
      "- a\n    - b",
      "<ul>\n<li>\na\n<ul>\n<li>\n<ul>\n<li>\nb\n</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>\n"
    ),
    ( "unordered list skipped list level and back",
      "- a\n    - b\n- c",
      "<ul>\n<li>\na\n<ul>\n<li>\n<ul>\n<li>\nb\n</li>\n</ul>\n</li>\n</ul>\n</li>\n<li>\nc\n</li>\n</ul>\n"
    ),
    ( "list to code block",
      "- a\n" ++ fence ++ "\n- foo\n\n" ++ fence,
      "<ul>\n<li>\na\n</li>\n</ul>\n<pre><code>- foo\n</code></pre>\n"
    ),
    ( "bold",
      "**a**",
      "<p><strong>a</strong></p>\n"
    ),
    ( "italic",
      "*a*",
      "<p><em>a</em></p>\n"
    ),
    ( "bold and italic",
      "**a** und *b*",
      "<p><strong>a</strong> und <em>b</em></p>\n"
    ),
    ( "hr dashes",
      "---",
      "<hr>\n"
    ),
    ( "hr stars",
      "***",
      "<hr>\n"
    ),
    ( "hr with spaces",
      "- - -",
      "<hr>\n"
    ),
    ( "no hr with two dashes",
      "--",
      "<p>--</p>\n"
    ),
    ( "hr in code block",
      fence ++ "\n---\n" ++ fence,
      "<pre><code>---</code></pre>\n"
    ),
    ( "inline code protects bold",
      "`**x**`",
      "<p><code>**x**</code></p>\n"
    ),
    ( "list to paragraph",
      "- a\ntext",
      "<ul>\n<li>\na\n</li>\n</ul>\n<p>text</p>\n"
    ),
    ( "deep list to paragraph",
      "- a\n  - b\n    - c\ntext",
      "<ul>\n<li>\na\n<ul>\n<li>\nb\n<ul>\n<li>\nc\n</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>\n<p>text</p>\n"
    ),
    ( "list to hr",
      "- a\n---",
      "<ul>\n<li>\na\n</li>\n</ul>\n<hr>\n"
    ),
    ( "paragraphs with blank line",
      "a\n\nb",
      "<p>a</p>\n<p>b</p>\n"
    ),
    ( "empty input",
      "",
      ""
    ),
    ( "inline code",
      "foo `bar`",
      "<p>foo <code>bar</code></p>\n"
    ),
    -- known open issues: expected to fail for now
    ( "blank line in list (open)",
      "- a\n\n- b",
      "<ul>\n<li>\na\n</li>\n<li>\nb\n</li>\n</ul>\n"
    ),
    ( "bold around code (open)",
      "**`x`**",
      "<p><strong><code>x</code></strong></p>\n"
    )
  ]

runTest :: (String, String, String) -> (String, Bool)
runTest (name, markdown, expHtml) =
  if convHtml == expHtml
    then ("OK: " ++ name, True)
    else ("ERROR: " ++ name ++ "\nExpected: " ++ show expHtml ++ "\nConverted: " ++ show convHtml, False)
  where
    convHtml = convert markdown

main :: IO ()
main = do
  mapM_ putStrLn infos
  putStrLn summary
  where
    results = map runTest testCases
    infos = map fst results
    passed = length (filter snd results)
    total = length results
    summary = show passed ++ " of " ++ show total ++ " tests passed"