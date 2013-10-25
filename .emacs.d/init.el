;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; global
;;
(set-language-environment "Japanese")
;(setq scroll-preserve-screen-position t)
(setq indent-tabs-mode t)
(setq *c-indent-tabs-mode* nil)
(setq default-tab-width 4)
(setq tab-width 4)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq auto-save-list-file-name nil)
(setq auto-save-list-file-prefix nil)
(setq show-paren-mode t)
(setq transient-mark-mode nil)
(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)

(setq load-path (cons (expand-file-name "~/.emacs.d/site-lisp") load-path))
(setq load-path (cons (expand-file-name "~/.emacs.d/site-lisp/emacs-rails") load-path))
;(setq load-path (cons (expand-file-name "~/.rvm/src/ruby-1.9.3-p194/misc/") load-path))
;(setq load-path (append '((expand-file-name "~/.elisp")
;                         (expand-file-name "~/.elisp/emacs-rails")
;                         load-path)))
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; env depended
;;
(load "~/.emacs.env-init.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; colors
;;
;(set-foreground-color "black")
(set-foreground-color "FloralWhite")
;(set-background-color "old lace")
;(set-background-color "#F6F2FF")
;(set-background-color "DarkSlateGray")
(set-background-color "gray22")
(set-face-foreground 'modeline "honeydew1")
(set-face-background 'modeline "black")
(set-cursor-color "spring green")
(set-frame-parameter nil 'alpha 90)

;====================================
; tab, space view
;
(defface my-face-b-1 '((t (:background "gray"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)

(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(("\t" 0 my-face-b-2 append)
     ("　" 0 my-face-b-1 append)
     ("[ \t]+$" 0 my-face-u-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; window
;;
(if (boundp 'window-system)
    (setq initial-frame-alist
          (append (list
                   '(width . 80)
                   '(height . 60)
                   '(top . 0)
                   '(left . 0)
                   )
                  initial-frame-alist)))
(setq default-frame-alist initial-frame-alist)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; key-binding
;;
(global-set-key [f1] 'shell)
(global-set-key [M-f4] 'save-buffers-kill-emacs)
(global-set-key [S-f4] 'kill-buffer)
(global-set-key "\C-xg" 'goto-line)
(global-set-key "\C-x\C-g" 'grep-find)
;(global-set-key [mouse-2] 'goto-line)
(keyboard-translate ?\C-h ?\C-?)
(global-set-key "\C-h" nil)
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\C-z" 'scroll-down)
(global-set-key "\C-\M-y" 'insert-register)

(define-key ctl-x-map "p"
  #'(lambda (arg) (interactive "p") (other-window (- arg))))

 (global-set-key "\M-[" 'gtags-pop-stack)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; C mode
;;
(defun my-c-common-mode ()
;  (c-toggle-hungry-state 1))
    (c-set-style "stroustrup")
    (setq indent-tabs-mode nil)
    (c-set-offset 'innamespace 0)
;  (setq tab-width 4)
;  (setq c-basic-offset tab-width)
  )
(add-hook 'c-mode-common-hook 'my-c-common-mode)
(setq c-mode-hook
      '(lambda()
         (local-set-key "\C-x@h" 'hs-hide-block)
         (local-set-key "\C-x@s" 'hs-show-block)
         (gtags-mode 1)
         ))

(setq c++-mode-hook
      '(lambda()
         (local-set-key "\C-x@h" 'hs-hide-block)
         (local-set-key "\C-x@s" 'hs-show-block)
         (gtags-mode 1)
         ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Ruby mode
;;
(add-hook 'ruby-mode-hook
          '(lambda ()
             (setq tab-width 2)
;             (setq indent-tabs-mode 't)
             (setq indent-tabs-mode nil)
             (setq ruby-indent-level tab-width)
             (local-set-key "\C-c\C-q" 'indent-region)
))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rails
(defun try-complete-abbrev (old) (if (expand-abbrev) t nil))
(setq hippie-expand-try-functions-list
      '(try-complete-abbrev
        try-complete-file-name
        try-expand-dabbrev))
(setq rails-use-mongrel t)
(require 'rails)
(define-key rails-minor-mode-map "\C-c\C-p" 'rails-lib:run-primary-switch)
(define-key rails-minor-mode-map "\C-c\C-n" 'rails-lib:run-secondary-switch)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SCSS ??
(autoload 'scss-mode "scss-mode")
(setq scss-compile-at-save nil) ; for rails3.1
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))
(add-hook 'scss-mode-hook
          '(lambda ()
             (setq tab-width 2)
             (setq indent-tabs-mode nil)
             (local-set-key "\C-c\C-q" 'indent-region)
))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; dsvn
;;
(autoload 'svn-status "dsvn" "Run `svn status'." t)
(autoload 'svn-update "dsvn" "Run `svn update'." t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ac-mode
;;
(autoload 'ac-mode "ac-mode" "Minor mode for advanced completion." t nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; gtags
;;
;(setq load-path (cons (expand-file-name "~/.elisp") load-path))
(autoload 'gtags-mode "gtags" "Minor mode for global tags." t nil)
(setq gtags-mode-hook
      '(lambda()
         (local-set-key "\M-d" 'gtags-find-tag)
         (local-set-key "\M-r" 'gtags-find-rtag)
         (local-set-key "\M-s" 'gtags-find-symbol)
         (local-set-key "\M-p" 'gtags-find-pattern)
;        (local-set-key "\M-[" 'gtags-pop-stack)
         ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; imenu (autoload)
;;
(require 'imenu)
(defcustom imenu-modes
  '(emacs-lisp-mode c-mode c++-mode makefile-mode)
  "List of major modes for which Imenu mode should be used."
  :group 'imenu
  :type '(choice (const :tag "All modes" t)
                 (repeat (symbol :tag "Major mode"))))
(defun my-imenu-ff-hook ()
  "File find hook for Imenu mode."
  (if (member major-mode imenu-modes)
      (imenu-add-to-menubar "imenu")))
(add-hook 'find-file-hooks 'my-imenu-ff-hook t)

(global-set-key "\C-cg" 'imenu)

(set-face-attribute 'default nil
;:family "bitstream vera sans mono"
;:family "Lucida Console"
;:family "MONOSPACE"
 :family "Ricty"
 ;:family "Purisa"
 :height 130)

;; others
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

