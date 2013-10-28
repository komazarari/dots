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
