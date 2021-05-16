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
  (set-face-attribute 'default nil :font "Fira Code Retina" :height 140)

  ;; scroll one line at a time (less "jumpy" than defaults)
    
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
  
  (setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
    
  (setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
    
  (setq scroll-step 1) ;; keyboard scroll one line at a time

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
  :init (load-theme 'doom-gruvbox t))

(global-set-key (kbd "C-c t") 'counsel-load-theme)

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
      (setq dashboard-startup-banner "~/.emacs.d/logo/emacs-e.svg")
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
  (setq which-key-idle-delay 0.2))

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

    (add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")
    (require 'mu4e)

     (global-set-key (kbd "C-x e") 'mu4e)

     (setq mu4e-user-mail-address-list '("antofma97@gmail.com"))	

     ;; viewing options
     (setq mu4e-view-show-addresses t)
     ;; Do not leave message open after it has been sent
     (setq message-kill-buffer-on-exit t)
     ;; Don't ask for a 'context' upon opening mu4e
     (setq mu4e-context-policy 'pick-first)
     ;; Don't ask to quit
     (setq mu4e-confirm-quit nil)

     (setq mu4e-maildir-shortcuts
      '(("GmailAccounts/INBOX" . ?g)))

     ;; attachments will be automaically placed on the specified folder
     (setq mu4e-attachment-dir "~/Downloads/MailAttachments")
     ;; modify behavior when putting something in the trash (T flag) so as

     ;; to make it sync to the remote server. This code deals with the bug
     ;; that, whenever a message is marked with the trash label T,
     ;; offlineimap wont sync it back to the gmail servers.
     ;;
     ;; NOTE: Taken from
     ;; http://cachestocaches.com/2017/3/complete-guide-email-emacs-using-mu-and-/
     (defun remove-nth-element (nth list)
       (if (zerop nth) (cdr list)
         (let ((last (nthcdr (1- nth) list)))
           (setcdr last (cddr last))
           list)))
     (setq mu4e-marks (remove-nth-element 5 mu4e-marks))
     (add-to-list 'mu4e-marks
             '(trash
               :char ("d" . "▼")
               :prompt "dtrash"
               :dyn-target (lambda (target msg) (mu4e-get-trash-folder msg))
               :action (lambda (docid msg target)
                         (mu4e~proc-move docid
                                         (mu4e~mark-check-target target) "-N"))))

    ;; Context conf settings


     (setq mu4e-contexts
           `(
        ,(make-mu4e-context
          :name "Gmail Account"
          :match-func (lambda (msg)
                        (when msg
                          (mu4e-message-contact-field-matches
                           msg '(:from :to :cc :bcc) "antofma97@gmail.com")))

          :vars '(
                  (mu4e-trash-folder . "/GmailAccount/[Gmail].Trash")
                  (mu4e-refile-folder . "/GmailAccount/[Gmail].Archive")
                  (mu4e-drafts-folder . "/GmailAccount/[Gmail].Drafts")
                  (mu4e-sent-folder . "/GmailAccount/[Gmail].Sent Mail")
                  (user-mail-address  . "antofma97@gmail.com")
                  (user-full-name . "Antonio Petrillo")
                  (smtpmail-smtp-user . "antofma97")
                  (smtpmail-local-domain . "gmail.com")
                  (smtpmail-default-smtp-server . "smtp.gmail.com")
                  (smtpmail-smtp-server . "smtp.gmail.com")
                  (smtpmail-smtp-service . 587)
                  ))
        ))

     ;; Set how email is to be sent
     (setq send-mail-function (quote smtpmail-send-it))

;;       (require 'mu4e-alert)

;;       (setq mu4e-alert-interesting-mail-query "flag:unread AND maildir:/GmailAccount/INBOX ")
              

;;       (mu4e-alert-enable-mode-line-display)

;;       (defun refresh-mu4e-alert-mode-line ()
;;         (interactive)
;;         (mu4e~proc-kill)
;;         (async-shell-command "email_sync.sh")
;;         (mu4e-alert-enable-mode-line-display)
;;         )
;;
;;       (run-with-timer 0 3600 'refresh-mu4e-alert-mode-line)
;;
;;      ;; do not pop into view buffer window associated with async shell commands
;;      (add-to-list 'display-buffer-alist
;;              (cons "\\*Async Shell Command\\*.*" (cons #'display-buffer-no-window nil)))

   (use-package org
     :config
     (setq org-ellipsis " ▾"))

   (setq org-todo-keywords
       '((sequence "TODO" "IN-PROGRESS" "WAITING" "DONE")))

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
			 "~/Documents/org/agenda/agenda.org"))

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
   (lua        . t)
   (C          . t)
   (awk        . t)
   (sed        . t)
   (shell      . t)
   (haskell    . t)
   (java       . t)
   (plantuml   . t)))

(setq org-confirm-babel-evaluate nil
      org-src-preserve-indentation t)

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
