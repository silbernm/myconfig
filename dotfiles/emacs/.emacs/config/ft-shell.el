(add-hook 'sh-mode '(lambda ()
                      (load "folding" 'nomessage 'noerror)
                      (folding-mode-add-find-file-hook)
                      (folding-add-to-marks-list 'sh-mode "{{{" "}}}" nil t)))

(add-hook 'sh-mode-hook (lambda () (setq tab-width 2
                                         ;; sh-basic-offset 4
                                         indent-tabs-mode nil)))
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.aliasrc\\'" . sh-mode))
