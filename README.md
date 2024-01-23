# rando-fortune
Load a random fortune from a file in Emacs without needing fortune(1) 

Designed for the handful of times when you don't have access to the fortune command and hence cannot use the normal fortune package and need something written in Elisp.

It's much slower because it rebuilds the entry indexes every time it opens a file, it should cache those somewhere but it doesn't.

## How to use

```
(require 'rando-fortune)

;; Set location
(setq fortune-file "~/.fortunes/quotes")

;; Get your fortune, also accepts an argument of a filename and searches that
(rando-fortune)

;; Or run interactively
M-x rando-fortune
```

## Bugs

You should if at all possible use the normal fortune package included with Emacs, as long as you have a fortune binary.
