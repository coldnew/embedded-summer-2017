;;; makefile-script.el --- Building script for this doc

;; Copyright (c) 2017 Yen-Chin, Lee.
;;
;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:
;;
;; This file is desinged to used by Makefile.


;;; Bootstrap

(require 'package)                      ; built-in
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org"   . "http://orgmode.org/elpa/") t)

;; For important compatibility libraries like cl-lib
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))

;; This must come before configurations of installed packages.
;; Don't delete this line. If you don't want it, just comment it out by adding a
;; semicolon to the start of the line. You may delete these explanatory
;; comments.
(package-initialize)

;; Auto refresh packages info when no archive available.
(when (not package-archive-contents)
  (package-refresh-contents))

;; Install use-package
(package-install 'org-plus-contrib)     ; for org-mode 9.x
(package-install 'htmlize)

;; I want to color the parentheses
(package-install 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; 
(defvar config-path
  (file-name-directory (or load-file-name (buffer-file-name))))

;; load my-theme
(load (expand-file-name "coldnew-theme.el" config-path))
(load (expand-file-name "night-coldnew-theme.el" config-path))

;; use night-coldnew theme
(load-theme 'night-coldnew t)

;;; Code:

(require 'org)
(require 'ox-html)
(require 'htmlize)

;; Make sure we really use org-mode 9.x
(when (version< org-version "9.0.0")
  (format
   "
\e[1m\e[31mERROR:\e[0m

  makefile-script ONLY work on org-mode 9.x.

  Package info:

    emacs     : %s
    org-mode  : %s

"
   emacs-version
   org-version))

;; org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (clojure . t)
   (C . t)
   (shell . t)
   (ditaa . t)
   (dot . t)
   (plantuml . t)))


;; remove extra whitespace when generate html document
(defadvice org-html-paragraph (before org-html-paragraph-advice
				      (paragraph contents info) activate)
  "Join consecutive Chinese lines into a single long line without
unwanted space when exporting org-mode to html."
  (let* ((origin-contents (ad-get-arg 1))
	 (fix-regexp "[[:multibyte:]]")
	 (fixed-contents
	  (replace-regexp-in-string
	   (concat
	    "\\(" fix-regexp "\\) *\n *\\(" fix-regexp "\\)") "\\1\\2" origin-contents)))
    (ad-set-arg 1 fixed-contents)))

;; https://emacs.stackexchange.com/questions/9492/is-it-possible-to-export-content-of-subtrees-without-their-headings
(defun org-remove-headlines (backend)
  "Remove headlines with :no_title: tag."
  (org-map-entries (lambda () (delete-region (point-at-bol) (point-at-eol)))
		   "no_title"))

(add-hook 'org-export-before-processing-hook #'org-remove-headlines)


(defun generate-this-doc ()
  "Export the README.org to index.html."
  (find-file "README.org")
  (org-html-export-to-html)
  (rename-file "README.html" "index.html" 'ok-if-already-exists)
  ;; done and done
  (kill-emacs))

(provide 'makefile-script)
;;; makefile-script ends here