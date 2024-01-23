;;; rando-fortune.el --- Load a random fortune from a file without needing fortune(1) -*- lexical-binding: t -*-

;; Copyright 2024 - Twitchy Ears

;; Author: Twitchy Ears https://github.com/twitchy-ears/
;; URL: https://github.com/twitchy-ears/rando-fortune
;; Version: 0.1
;; Package-Requires ((emacs "24.1"))
;; Keywords: games

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; History
;;
;; 2024-01-22 - initial version

;;; Commentary:

;; (require 'rando-fortune)
;;
;; ;; Set location
;; (setq fortune-file "~/.fortunes/quotes")
;;
;; ;; Get your fortune
;; (rando-fortune)

;; TODO:
;;
;; Should really save the indexes into a variable along with the mtime
;; of the file so it only has to calculate them the first time and if
;; the file changes.

;;; Code:
(require 'cl-lib)

(defun rando-fortune (&optional filename)
  "Takes an argument FILENAME which it presumes to be a fortune
file (i.e. a series of entries divided with lines which just
contain the single character %)

Reads the file, finds the locations of the entries, and choose
one at random.

If called interactively it produces this as a message and also
returns the string, if called from elisp simply returns the
string.

Intended for use on systems that lack a fortune(1).  if you have
a fortune binary you should use that and the fortune package,
this is much much slower because it builds its index each time."

  (interactive)

  ;; Blank argument try for existing variables from fortune.el
  (cond
   ((and (not filename)
         (boundp 'fortune-file)
         (file-exists-p fortune-file))
    (setq filename fortune-file))
   ((and (not filename)
         (boundp 'fortune-dir)
         (file-accessible-directory-p fortune-dir))
    (setq filename fortune-dir)))

  ;; If we've been given a directory choose files at random and try
  ;; and avoid any compiled .dat fortune files.
  (when (file-accessible-directory-p filename)
    (let ((file-list (cl-remove-if (lambda (k)
                                     (or (string-match ".dat$" k)
                                         (not (file-readable-p k))
                                         (not (file-regular-p k))))
                                   (directory-files filename t))))
      (setq filename (nth (random (length file-list)) file-list))))

  ;; Actually pick fortune
  (when (file-exists-p filename)
    (let ((boundaries '(1))
          (max-number nil)
          (last-choice nil))
      
      (with-temp-buffer
        (insert-file-literally filename)
        (goto-char (point-min))

        (while (not (eobp))
          (forward-line)
          (beginning-of-line)
          (let ((curr-line (string-trim (thing-at-point 'line))))
            (when (string-match-p "^%$" curr-line)
              ;; (message "Found '%s'" curr-line)
              (save-excursion
                (forward-line)
                (beginning-of-line)
                (setq boundaries (cons (point) boundaries))))))

        (end-of-buffer)
        (setq boundaries (cons (point) boundaries))

        ;; max-number is the random number we generate up to.  Length
        ;; is 1 based, nth is 0 based, and we have the start/end
        ;; markers so remove 1 from the max-number so we never
        ;; generate the last marker as thats eobp and not a %
        ;;
        ;; last-choice is the last valid choice to make in a 0 indexed
        ;; nth call, and hence needs to be -2 to be the nth item that
        ;; actually occurs before the end.
        (setq max-number (- (length boundaries) 1))
        (setq last-choice (- (length boundaries) 2))
        
        ;; (message "got %s boundaries so generating between 0 and %i" (length boundaries) max-number)
        (setq boundaries (reverse boundaries))
        ;; (message "boundaries: %s" boundaries)
        
        (let* ((choice (random max-number))
               (start (nth choice boundaries))

               ;; The last marker is the EOF exactly, otherwise its a % that
               ;; you need to walk back over the \n of
               (end (if (= choice last-choice)
                        (nth (+ 1 choice) boundaries)
                      (- (nth (+ 1 choice) boundaries) 2)))
               
               (fort (string-trim
                      (buffer-substring-no-properties start end))))
          
          (when (called-interactively-p 'any)
            (message "%s" fort))
          
          fort)))))

(provide 'rando-fortune)
