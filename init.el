;;; Interface
(menu-bar-mode -1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(column-number-mode 1)
(setq column-number-indicator-zero-based nil)

(unless standard-display-table
  (setq standard-display-table (make-display-table)))
(set-display-table-slot standard-display-table 'vertical-border ?│)

;;; Editing
(electric-pair-mode 1)
(add-hook 'before-save-hook #'delete-trailing-whitespace)
(global-auto-revert-mode 1)
(global-hl-line-mode 1)
(setq make-backup-files nil
      create-lockfiles nil
      auto-save-default nil
      scroll-margin 6
      scroll-conservatively 101)

(defun my/flash-copied-region (beg end &rest _)
  (let ((ov (make-overlay beg end)))
    (overlay-put ov 'face 'highlight)
    (run-with-timer 0.15 nil #'delete-overlay ov)))
(advice-add 'kill-ring-save :before #'my/flash-copied-region)

;;; Completion
(add-hook 'prog-mode-hook #'completion-preview-mode)
(add-hook 'slime-repl-mode-hook #'completion-preview-mode)
(fido-vertical-mode 1)
(setq completions-detailed t
      isearch-lazy-count t
      xref-search-program 'ripgrep)

;;; Windows
(windmove-default-keybindings)
(repeat-mode 1)
(recentf-mode 1)

(which-key-mode 1)
(savehist-mode 1)
(save-place-mode 1)

;;; Terminal
(xterm-mouse-mode 1)
(setq xterm-extra-capabilities '(reportBackground setSelection))

;;; Pkgs
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file t)

;;; Colors
(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker t)
  (set-face-background 'default "unspecified-bg"))

;;; Common Lisp
(use-package slime
  :ensure t
  :init
  (setq inferior-lisp-program "sbcl")
  :config
  (slime-setup '(slime-fancy slime-quicklisp))
  (define-key slime-mode-map (kbd "C-x C-e") #'slime-eval-last-expression-in-repl))
