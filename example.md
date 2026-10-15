# Welcome to markdown-hs

This is a small Haskell project that converts a subset of **Markdown** into HTML.

## Features

The converter currently supports the following:

- Headings from level 1 to 6
- **Bold** text using double asterisks
- *Italic* text using single asterisks
- Unordered lists, like this one
  - including nested lists
- `Inline code` using backticks
- Fenced code blocks
- Horizontal rules

```
main :: IO ()
main = putStrLn "Hello, markdown-hs"
```

---

### Why Haskell?

Building this project was a great way to practice *pattern matching*, **recursion**, and working with the `Maybe` type for error handling.

## Try it yourself

- Clone the repository
- Run `ghc -Wall -outputdir build -o convert Main.hs`
- Execute `./convert`
That's it! Check `output.html` to see the result.