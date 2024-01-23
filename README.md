# rando-fortune
Load a random fortune from a file in Emacs without needing fortune(1) 

Designed for the times when you don't have access to the fortune command and hence cannot use the normal fortune package and need something written in Elisp.

In testing with `benchmark-call` it actually appears to be quicker than `fortune.el`.

## How to use

```
(require 'rando-fortune)

;; Set location to a file
(setq fortune-file "~/.fortunes/quotes")

;; Set location to a whole directory, file is prioritised if both are set
(setq fortune-dir "~/.fortunes/")

;; Get your fortune, also accepts an argument of a file or directory
;; name and searches that with priority over fortune-file or fortune-dir
(rando-fortune)

;; Or run interactively
M-x rando-fortune
```

## Bugs

The caching has been tested but not very hard so its possible bugs exist.
