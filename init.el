;;; -*- lexical-binding: t; -*-

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
;; Pacotes antigos (ex.: gruber-darker-theme) não têm o cookie de lexical-binding.
(require 'warnings)
(add-to-list 'warning-suppress-log-types '(files missing-lexbind-cookie))
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
  :defer t                              ; carrega ao abrir um .lisp ou no M-x slime
  :init
  (setq inferior-lisp-program "sbcl")
  :config
  (slime-setup '(slime-fancy slime-quicklisp))
  (define-key slime-mode-map (kbd "C-x C-e") #'slime-eval-last-expression-in-repl))

;;; Dashboard
(defvar my/dashboard-logo
  '("███████╗███╗   ███╗ █████╗  ██████╗███████╗"
    "██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝"
    "█████╗  ██╔████╔██║███████║██║     ███████╗"
    "██╔══╝  ██║╚██╔╝██║██╔══██║██║     ╚════██║"
    "███████╗██║ ╚═╝ ██║██║  ██║╚██████╗███████║"
    "╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝"))

;; Colunas de cada letra (E M A C S) no logo e a cor de cada uma,
;; tiradas do xemacs_color_meadow_light.svg.
(defvar my/dashboard-logo-faces
  '((0 8 (:foreground "#2d717d"))
    (8 19 (:foreground "#9e4c4d"))
    (19 27 (:foreground "#ac5701"))
    (27 35 (:foreground "#4b6697"))
    (35 43 (:foreground "#6d5b90"))))

(defun my/dashboard--center (text width)
  (insert (make-string (max 0 (/ (- width (string-width text)) 2)) ?\s) text "\n"))

(defun my/dashboard--items ()
  (require 'project)
  (require 'bookmark)
  (bookmark-maybe-load-default-file)
  (list
   (list "" "Recent Files" "r"
         (mapcar (lambda (f) (list (abbreviate-file-name f) 'file f))
                 (seq-take recentf-list 5)))
   (list "" "Projects" "p"
         (mapcar (lambda (d) (list (abbreviate-file-name d) 'project d))
                 (seq-take (project-known-project-roots) 5)))
   (list "" "Bookmarks" "m"
         (mapcar (lambda (b)
                   (list (format "%s - %s" b (abbreviate-file-name
                                              (or (bookmark-get-filename b) "")))
                         'bookmark b))
                 (seq-take (bookmark-all-names) 5)))))

(defun my/dashboard--open (button)
  (let ((target (button-get button 'my-target)))
    (pcase (button-get button 'my-kind)
      ('file (find-file target))
      ('project (project-switch-project target))
      ('bookmark (bookmark-jump target)))))

(defun my/dashboard--goto (kind)
  (goto-char (point-min))
  (let (button)
    (while (and (setq button (next-button (point)))
                (not (eq (button-get button 'my-kind) kind)))
      (goto-char button))
    (when button (goto-char button))))

(defun my/dashboard-render (&rest _)
  (let* ((inhibit-read-only t)
         (win (get-buffer-window (current-buffer)))
         (width (if win (window-width win) (frame-width)))
         (height (if win (window-body-height win) (- (frame-height) 2)))
         (sections (my/dashboard--items))
         (names (apply #'append (mapcar (lambda (s) (mapcar #'car (nth 3 s))) sections)))
         (block-width (apply #'max 20 (mapcar (lambda (n) (+ 2 (string-width n))) names)))
         (indent (make-string (max 0 (/ (- width block-width) 2)) ?\s)))
    (erase-buffer)
    (dolist (line my/dashboard-logo)
      (let ((colored (copy-sequence line)))
        (dolist (seg my/dashboard-logo-faces)
          (put-text-property (nth 0 seg) (nth 1 seg) 'face (nth 2 seg) colored))
        (my/dashboard--center colored width)))
    (insert "\n")
    (my/dashboard--center (propertize "Welcome to Emacs!" 'face 'bold) width)
    (insert "\n")
    (my/dashboard--center
     (propertize (format "%d packages installed. Emacs started in %s."
                         (length package-activated-list)
                         (emacs-init-time "%.2f seconds"))
                 'face '(italic shadow))
     width)
    (insert "\n")
    (dolist (s sections)
      (insert indent
              (propertize (format "%s %s: " (nth 0 s) (nth 1 s)) 'face 'font-lock-comment-face)
              (format "(%s)" (nth 2 s)) "\n")
      (if (nth 3 s)
          (dolist (item (nth 3 s))
            (insert indent "  ")
            (insert-text-button (nth 0 item) 'face 'default 'follow-link t
                                'my-kind (nth 1 item) 'my-target (nth 2 item)
                                'action #'my/dashboard--open)
            (insert "\n"))
        (insert indent "  " (propertize "none yet" 'face 'shadow) "\n"))
      (insert "\n"))
    (my/dashboard--center
     (propertize "While any text editor can save your files, only Emacs can save your soul"
                 'face 'shadow)
     width)
    (goto-char (point-min))
    (insert (make-string (max 0 (/ (- height (count-lines (point-min) (point-max))) 2)) ?\n))
    (goto-char (point-min))
    (forward-button 1 nil nil t)))

(defun my/dashboard--resize (win)
  (with-current-buffer (window-buffer win)
    (my/dashboard-render)))

(defvar-keymap my/dashboard-mode-map
  :parent special-mode-map
  "TAB" #'forward-button
  "<backtab>" #'backward-button
  "r" (lambda () (interactive) (my/dashboard--goto 'file))
  "p" (lambda () (interactive) (my/dashboard--goto 'project))
  "m" (lambda () (interactive) (my/dashboard--goto 'bookmark)))

(define-derived-mode my/dashboard-mode special-mode "Dashboard"
  (setq-local revert-buffer-function #'my/dashboard-render)
  (add-hook 'window-size-change-functions #'my/dashboard--resize nil t))

(defun my/dashboard ()
  (interactive)
  (let ((buf (get-buffer-create "*dashboard*")))
    (with-current-buffer buf
      (my/dashboard-mode)
      (my/dashboard-render))
    buf))

(setq initial-buffer-choice #'my/dashboard)
