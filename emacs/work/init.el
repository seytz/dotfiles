;;; myemacs.el --- Work emacs config -*- lexical-binding: t -*-

;; Copyright (c) 2016-2018 Clement T.

;; Author: Clement T. <clement@trosa.io>
;; Maintainer: Clement T. <clement@trosa.io>
;; URL: https://github.com/iomonad/dotfiles
;; Created: January 2017
;; Keywords: config
;; Version: 0.1.1

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; iomonad's config file
;; Key points:
;;  - Global completion mode, backed by company
;;  - C/C++ mode with clang linter and completion engine
;;  - Clojure mode with cider
;;  - Orgmode for agenda and todolist organisation
;;  - Dockerfile mode
;;  - Enhanced scala mode with Ensime server mode (w/ company comp)
;;  - Elixir syntax mode
;;  - Optimised for dvorak layout (w/ Space Cadet shift modifier)
;;  - Linum mode with hacked side-bar

;;; Changelog:

;; 0.1.1: Config backup init.
;; 0.1.2: Cleanup unused packages (ensime due to Intellij Usage)
;;        and theme bump.

;;; Code:

(package-initialize)

(require 'org)
(require 'linum)
(require 'package)
(require 'whitespace)

;;
;; Package and Melpa configuration:
;;

(setq package-user-dir  (expand-file-name
			 (convert-standard-filename "packages")
			 user-emacs-directory)
      package-enable-at-startup nil
      package-archives '(("melpa"      . "http://melpa.org/packages/")
			 ("gnu"        . "http://elpa.gnu.org/packages/")
			 ("marmalade"  . "http://marmalade-repo.org/packages/")
			 ("org" . "http://orgmode.org/elpa/")))

(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
		    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))

(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;;
;; Vanilla emacs configuration:
;;

(defalias 'yes-or-no-p 'y-or-n-p) ; fck off

(setq debug-on-error t
      gc-cons-threshold 100000000
      load-prefer-newer t
      sentence-end-double-space nil
      frame-title-format "Emacs - %b"
      time-stamp-format "%:y-%02m-%02d %02H:%02M:%02S"
      inhibit-startup-message t
      inhibit-splash-screen t
      case-fold-search t
      kill-whole-line t
      require-final-newline t
      next-line-add-newlines nil
      backup-inhibited t
      make-backup-files nil
      auto-save-default nil
      auto-save-list-file-prefix nil
      vc-follow-symlinks t
      password-cache-expiry nil
      highlight-tabs t
      show-trailing-whitespace t
      whitespace-line-column 80
      whitespace-style '(tabs tab-mark face lines-tail)
      whitespace-global-modes '(not org-mode web-mode)
      uniquify-buffer-name-style 'forward uniquify-separator "/"
      backup-directory-alist `(("." . "~/.emacs.d/saves"))
      make-backup-files 1
      auto-save-list-file-prefix nil
      auto-save-default nil)

(setq debug-on-error nil)
(setq debug-on-quit nil)
(setq debug-on-message nil)

(electric-pair-mode 1) 					; Can be annoying
(setq create-lockfiles nil)
(setq show-paren-delay 0)
(setq blink-matching-paren 1)
(show-paren-mode 1)

;;
;; UI configuration:
;;

(set-face-foreground 'mode-line "white")
(set-face-background 'mode-line "#151515")
(set-face-background 'mode-line-inactive "black")
(set-face-foreground 'mode-line-inactive "#505050")
(display-time-mode)
(column-number-mode)
(line-number-mode)
(set-face-background 'vertical-border "black")
(set-face-foreground 'vertical-border (face-background 'vertical-border))
(setq scroll-step            2 ; Scrolling suxx
      scroll-conservatively 10000)


;;
;; Linum configuration:
;;


(set-face-attribute 'linum nil
                    :background "black")

(defface linum-current-line-face
  `((t :background "black"
       :foreground "white"))
  "Face for the currently active Line number")

(defvar my-linum-current-line-number 0)

(defun get-linum-format-string ()
  (setq-local my-linum-format-string
              (let ((w (length (number-to-string
                                (count-lines (point-min) (point-max))))))
                (concat " %" (number-to-string w) "d "))))

(add-hook 'linum-before-numbering-hook 'get-linum-format-string)

(defun my-linum-format (line-number)
  (propertize (format my-linum-format-string line-number) 'face
              (if (eq line-number my-linum-current-line-number)
                  'linum-current-line-face
                'linum)))

(setq linum-format 'my-linum-format)

(defadvice linum-update (around my-linum-update)
  (let ((my-linum-current-line-number (line-number-at-pos)))
    ad-do-it))

(ad-activate 'linum-update)

(global-linum-mode) ; Set global mode

;;
;; Whitespace remover hook:
;;

(setq whitespace-style '(face empty lines-tail trailing))
(global-whitespace-mode t)

;; Note: Added to the  C mode only ! Must be added to 'before-save-hook
;; to have a global effect

(add-hook 'c-mode-hook
	  (lambda ()
	    (add-to-list 'write-file-functions
			 'delete-trailing-whitespace)))

;;
;; Org Mode
;;

(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-cc" 'org-capture)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cb" 'org-iswitchb)

(setq org-directory "~/org/")
(setq org-default-notes-file (concat org-directory "bucket.org"))
(setq org-agenda-files '("~/org/scortex.org"))

(setq org-todo-keywords
      '((sequence "TODO(t)"
		  "WAIT(w@/!)"
		  "ONGOING"
		  "|"
		  "DONE(d!)"
		  "DELEGATED"
		  "CANCELED(c@)")))
(setq org-fast-tag-selection-include-todo t)

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/org/bucket.org")
               "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t))))

(setq org-agenda-dim-blocked-tasks nil)
(setq org-agenda-compact-blocks t)
(setq org-log-done t)

;;
;; Functions
;;

(defun save-all-buffers ()
  (interactive) ; Disable prompt
  (save-some-buffers t))

(defun indent-buffer ()
  "Indent the whole buffer."
  (interactive)
  (indent-region (point-min)
		 (point-max)))

;;
;; Custom keybinds
;;

(global-set-key (kbd "C-x s") 'save-all-buffers)
(global-set-key (kbd "C-c n") 'indent-buffer)

;;
;; Hooks
;;

(add-hook 'focus-out-hook 'save-all-buffer)

;;
;; Extra-Packages configurations:
;;

;; Company completion engine:

(use-package company :ensure t
  :init (setq company-auto-complete nil
              company-tooltip-flip-when-above t
              company-minimum-prefix-length 2
              company-tooltip-limit 20
              company-idle-delay 0.5)
  :config (global-company-mode 1) ; Set mode on every buffers
  :diminish company-mode)

(setq company-backends (delete 'company-semantic company-backends))

;;
;; Yasnippet mode
;;

(use-package yasnippet
  :ensure t)

(use-package yasnippet-snippets
  :ensure t)

(setq yas-snippet-dirs
      '("~/.emacs.d/snippets"))

(add-hook 'prog-mode-hook #'yas-minor-mode)

;;
;; Magit
;;

(use-package magit
  :ensure t)

;;
;; Python Mode
;;

(use-package elpy
  :ensure t
  :defer t
  :init
  (advice-add 'python-mode :before 'elpy-enable))

(use-package irony
  :ensure t)

(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)

(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; undotree

(use-package undo-tree
  :ensure t)
(global-undo-tree-mode)

(tool-bar-mode -1)

;; neotree

(use-package neotree
  :ensure t)
(global-set-key (kbd "C-x t") 'neotree-toggle)


;; SMEX

(use-package smex
  :ensure t)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

;; Elfeed

(use-package elfeed
  :ensure t)

(setq elfeed-feeds
      '(("https://lobste.rs/newest.rss" tech)
	("http://n-gate.com/index.rss" tech)
	("http://www.lemonde.fr/paris/rss_full.xml" news)
	("https://www.kernel.org/feeds/kdist.xml" kernel)
	("http://nullprogram.com/feed/" blog tech)
	))

(setf url-queue-timeout 30)
(global-set-key (kbd "C-x w") 'elfeed)

;;
;; CUSTOM SET VARIABLES
;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (elfeed yasnippet-snippets use-package undo-tree smex neotree magit irony elpy))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
