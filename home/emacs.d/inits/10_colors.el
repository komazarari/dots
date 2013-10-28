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
