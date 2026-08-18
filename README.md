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
- Unordered lists (`- item`)
- Inline Code (``Text with `code` in it``)
- Fenced Code Block (``Start/End Block with ``` ``)

Anything that doesn't match a supported pattern is marked with an HTML
comment (`<!-- Error: invalid line -->`) instead of failing silently.
 
## Requirements
 
- [GHC](https://www.haskell.org/ghc/) (tested with GHC 9.10.3)

## Build
 
```
ghc -outputdir build -o convert .\Main.hs  
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
missing: links, code blocks, ordered lists, nested lists, and blockquotes.
 
## Project structure
 
- `Markdown.hs` — parsing and HTML generation logic
- `Config.hs` — file path configuration