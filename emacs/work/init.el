;******************************************************************************;
;                                                                              ;
;                                                         :::      ::::::::    ;
;    init.el                                            :+:      :+:    :+:    ;
;                                                     +:+ +:+         +:+      ;
;    By: iomonad <iomonad@riseup.net>               +#+  +:+       +#+         ;
;                                                 +#+#+#+#+#+   +#+            ;
;    Created: 2018/07/14 10:14:47 by iomonad           #+#    #+#              ;
;    Updated: 2019/04/22 15:00:09 by iomonad          ###   ########.fr        ;
;                                                                              ;
;******************************************************************************;

(package-initialize)

(setq config_files "~/.emacs.d/site-lisp")
(setq load-path (append (list nil config_files) load-path))

(load "list.el")
(load "string.el")
(load "comments.el")
(load "header.el")

;; (autoload 'php-mode "php-mode" "Major mode for editing PHP code" t)
;; (add-to-list 'auto-mode-alist '("\\.php[34]?\\'\\|\\.phtml\\'" . php-mode))
; Set default emacs configuration
(set-language-environment "UTF-8")
;; (setq-default font-lock-global-modes nil)
(setq-default line-number-mode nil)
(setq-default tab-width 4)
(setq-default indent-tabs-mode t)
(global-set-key (kbd "DEL") 'backward-delete-char)
(setq-default c-backspace-function 'backward-delete-char)
(setq-default c-basic-offset 4)
(setq-default c-default-style "linux")
(setq-default tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60
                             64 68 72 76 80 84 88 92 96 100 104 108 112 116 120))
;;Load user configuration
(if (file-exists-p "~/.emacs.d/myemacs.el") (load-file "~/.emacs.d/myemacs.el"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(gud-gdb-command-name "gdb --annotate=1")
 '(large-file-warning-threshold nil)
 '(package-selected-packages
   (quote
	(request go-autocomplete go-mode distinguished-theme magit markdown-mode yasnippet-snippets ensime cider multiple-cursors company use-package)))
 '(safe-local-variable-values
   (quote
	((company-clang-arguments "-I/Users/ctrouill/Projects/ft_ssl/includes" "-I/Users/ctrouill/Projects/ft_ssl/libft/includes")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
