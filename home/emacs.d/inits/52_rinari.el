 ;; Interactively Do Things (highly recommended, but not strictly required)
(require 'ido)
(ido-mode t)

;; Rinari
(add-to-list 'load-path "~/path/to/your/elisp/rinari")
(require 'rinari)

(add-hook 'emacs-startup-hook
  (function (lambda ()
  (global-rinari-mode))))
