# Welcome to markdown-hs
 
This is a small Haskell project that converts a subset of **Markdown** into HTML.
 
## Features
 
The converter currently supports the following:
 
- Headings from level 1 to 6
- **Bold** text using double asterisks
- *Italic* text using single asterisks
- Unordered lists, like this one

### Why Haskell?
 
Building this project was a great way to practice *pattern matching*, **recursion**, and working with the `Maybe` type for error handling.
 
## Try it yourself
 
- Clone the repository
- Run `ghc -o convert Markdown.hs`
- Execute `./convert`
That's it! Check `output.html` to see the result.