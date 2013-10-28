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
