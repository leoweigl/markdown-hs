# markdown-hs
 
![Haskell](https://img.shields.io/badge/Haskell-5D4F85?style=flat&logo=haskell&logoColor=white)
![Markdown](https://img.shields.io/badge/Markdown-000000?style=flat&logo=markdown&logoColor=white)
![HTML](https://img.shields.io/badge/HTML-E34F26?style=flat&logo=html5&logoColor=white)
![GHC](https://img.shields.io/badge/GHC-9.10.3-5e5086?logo=haskell&logoColor=white)

![Release](https://img.shields.io/github/v/tag/leoweigl/markdown-hs)
![License](https://img.shields.io/github/license/leoweigl/markdown-hs)
![Repo Size](https://img.shields.io/github/repo-size/leoweigl/markdown-hs)
![Last Commit](https://img.shields.io/github/last-commit/leoweigl/markdown-hs)

A small Haskell project that converts a subset of Markdown into HTML.
 
This started as a learning project to practice core Haskell concepts —
pattern matching, recursion, `Maybe`-based error handling, and simple
recursive parsing — by building something practical from scratch.
 
## Features
 
- Headings (`#` to `######`)
- **Bold** text (`**text**`)
- *Italic* text (`*text*`)
- Unordered lists (`- item`), including nested lists (2 spaces of indentation per level)
- Horizontal rules (`---` or `***`)
- Inline Code (``Text with `code` in it``)
- Fenced Code Block (``Start/End Block with ``` ``)

Anything that doesn't match a supported pattern is marked with an HTML
comment (`<!-- Error: invalid line -->`) instead of failing silently.
 
## Requirements
 
- [GHC](https://www.haskell.org/ghc/) (tested with GHC 9.10.3)

## Build
 
```
ghc -Wall -outputdir build -o convert .\Main.hs  
```
 
## Usage
 
```
./convert
```
 
The program reads from `input.md` and writes the converted HTML to
`output.html` in the current directory.
 
See [`example.md`](./example.md) for a sample input file covering all
supported features — copy it to `input.md` to try it out:
 
```
cp example.md input.md
./convert
```
 
## Limitations
 
This is a learning project, not a full Markdown implementation. Notably
missing: links, ordered lists, and blockquotes.

Behavior worth knowing:

- Every non-empty line becomes its own paragraph; empty lines only separate
  blocks and produce no output.
- A blank line ends a list, so two lists separated by an empty line are
  rendered as two separate lists.
- A line with only the marker (`-` or `- `) is not a list item and is
  rendered as a paragraph.
- Nesting is based on indentation: one level per two leading spaces.
 
## Documentation

The functions are documented with Haddock comments. To generate the HTML
documentation into `docs/` (ignored by git):

```
haddock --html -o docs Main.hs BlockProcessing.hs LineParsing.hs InlineFormatting.hs Validation.hs StringUtils.hs TagHelpers.hs Config.hs
```

## Project structure
 
- `Main.hs` — entry point: reads the input file and chains the processing steps
- `BlockProcessing.hs` — block-level handling (code blocks, horizontal rules, lists)
- `LineParsing.hs` — single-line parsing (headings, paragraphs, list content)
- `InlineFormatting.hs` — inline formatting (bold, italic, inline code)
- `Validation.hs` — checks for headings and list items, list nesting level
- `StringUtils.hs` — string helper functions
- `TagHelpers.hs` — HTML tag helpers
- `Config.hs` — file path configuration