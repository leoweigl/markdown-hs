# markdown-hs
 
![Haskell](https://img.shields.io/badge/Haskell-5D4F85?style=flat&logo=haskell&logoColor=white)

A small Haskell project that converts a subset of Markdown into HTML.
 
This started as a learning project to practice core Haskell concepts —
pattern matching, recursion, `Maybe`-based error handling, and simple
recursive parsing — by building something practical from scratch.
 
## Features
 
- Headings (`#` to `######`)
- **Bold** text (`**text**`)
- *Italic* text (`*text*`)
- Unordered lists (`- item`)

Anything that doesn't match a supported pattern is marked with an HTML
comment (`<!-- Error: invalid line -->`) instead of failing silently.
 
## Requirements
 
- [GHC](https://www.haskell.org/ghc/) (tested with GHC 9.10.3)

## Build
 
```
ghc -o convert Markdown.hs
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