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

;; ruby-electric.el
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))
;; FIXME
(defun ruby-insert-end ()
  (interactive)
  (insert "end")
  (ruby-indent-line t)
  (end-of-line))
