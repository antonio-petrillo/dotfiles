(require 'package)
(setq package-archives '(("melpa"        . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                           ("elpa"         . "https://elpa.gnu.org/packages/")
                           ("org"          . "https://orgmode.org/elpa")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)

;; ensure all the package included with use-package
(setq use-package-always-ensure t)

;; hide scroll bar, menu bar, tool bar
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

;; remove initial buffer
(setq inhibit-startup-message t)

;; enable line numbers
(column-number-mode t)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; don't use line numbers in certain mode
(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
		    treemacs-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; don't create lockfile, I know what file I'm gonna edit
(setq create-lockfiles nil)

;; don't make backup files
;; (setq make-backup-files nil)

;; change bakcup directory
(setq backup-directory-alist '(("." . "~/.emacs.d/.backup")))

;; username and email
(setq user-full-name "Antonio Petrillo"
      user-mail-address "antonio.petrillo4@studenti.unina.it")

;; type yes or no require to much effort
(fset 'yes-or-no-p 'y-or-n-p)

;; use fira code fonts
(set-face-attribute 'default nil :font "Fira Code Retina" :height 180)

(use-package evil
  :init
  (setq evil-want-integration  t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll   t)
  (setq evil-want-C-i-jump   nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-set-initial-state 'message-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; paste
(defun paste-from-clipboard ()
  (interactive)
  (setq x-select-enable-clipboard t)
  (yank)
  (setq x-select-enable-clipboard nil))

;; defining a keybinding
(global-set-key (kbd "C-c C-p") 'paste-from-clipboard)

;; copy
(defun copy-to-clipboard ()
  (interactive)
  (setq x-select-enable-clipboard t)
  (kill-ring-save (region-beginning) (region-end))
  (setq x-select-enable-clipboard nil))

;; defining a keybinding
(global-set-key (kbd "C-c C-y") 'copy-to-clipboard)

(global-set-key (kbd "C-x C-z") 'undo)
;;(global-set-key (kbd "C-z") 'undo)
;;(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 15))
  
(use-package doom-themes
  :init (load-theme 'doom-one t))

(use-package page-break-lines
  :ensure t
  :diminish (page-break-lines-mode))

(use-package dashboard
  :init
  (progn
    (setq dashboard-items '((recents   . 5)
                            (bookmarks . 5)))
    (setq dashboard-show-shortcuts nil)
    (setq dashboard-center-content nil)
    (setq dashboard-banner-logo-title "EMACS")
    (setq dashboard-set-files-icons t)
    (setq dashboard-set-heading-icons t)
    (setq dashboard-startup-banner "~/.emacs.d/logo/emacs_e.png")
    (setq dashboard-set-navigator t))
  :config
  (dashboard-setup-startup-hook))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
				    ("pdf" . "zathura")
                                ("jpg" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package which-key
  :init (which-key-mode 1)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :config
  (add-hook 'prog-mode-hook #'rainbow-mode)
)

(use-package beacon
  :config
  (beacon-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package vterm
  :init
  (setq vterm-module-cmake-args "-DUSE_SYSTEM_LIBVTERM=no")
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))



(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/uni/code")
    (setq projectile-project-search-path '("~/uni/code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-read-string-input             'from-child-frame
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-user-mode-line-format         nil
          treemacs-user-header-line-format       nil
          treemacs-width                         35
          treemacs-workspace-switch-cleanup      nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :after (treemacs dired)
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package org
  :config
  (setq org-ellipsis " ▾"))

(require 'org-tempo)

(use-package evil-org
  :after (evil org)
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
	    (lambda ()
	      (evil-org-set-key-theme '(navigation
					insert
					textobject
					additional
					calendar)))))

(global-set-key (kbd "C-c a") 'org-agenda)

(setq org-log-mode t)
(setq org-agenda-files '("~/Documents/org/agenda/notes.org"
                         "~/Documents/org/agenda/agenda.org"
                         "~/Documents/org/agenda/uni.org"))

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))
  
(setq org-startup-folded t)
(setq org-startup-indented t)
(setq org-startup-with-inline-images t)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (eshell     . t)
   (C          . t)
   (awk        . t)
   (sed        . t)
   (shell      . t)
   (haskell    . t)
   (java       . t)
   (plantuml   . t)))
   
(setq org-confirm-babel-evaluate nil)

(defun literate-config/tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.emacs.d/emacs.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'literate-config/tangle-config)))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-j" . ivy-next-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-j" . ivy-next-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (counsel-mode 1))

(use-package helm)
(require 'helm-config)
(setq helm-split-window-in-side t
      helm-move-to-line-cycle-in-source t)

;; most of the emacs prompt become helm-prompt
;(helm-mode 1)

;; list buffers (Emacs way)
;(global-set-key (kbd "C-x b") 'helm-buffers-list)

;; list buffers (VIM way)
;(define-key evil-ex-map "b" 'helm-buffers-list)

;; bookmarks menu
;(global-set-key (kbd "C-x r b") 'helm-bookmarks)

;; use helm for calculation
(global-set-key (kbd "M-c") 'helm-calcul-expression)

;; imporoved Occur (find stuff on buffer with regexp)
;; ieplace the default isearch keybinding
;(global-set-key (kbd "C-s") 'helm-occur)

;; improved M-x menu
;(global-set-key (kbd "M-x") 'helm-M-x) 
;; finding files with helm
;(global-set-key (kbd "C-x C-f") 'helm-find-files)

;; show kill ring, pick something to paste
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
