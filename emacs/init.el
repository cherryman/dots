;; -*- lexical-binding: t; -*-

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

(global-display-line-numbers-mode)
(modify-syntax-entry ?_ "w")

(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil
      browse-url-browser-function 'browse-url-firefox
      browse-url-new-window-flag  t
      browse-url-firefox-new-window-is-tab t
      browse-url-firefox-program "firefox-nightly")

(use-package gnu-elpa-keyring-update)

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-material t))

(use-package all-the-icons)

(use-package general
  :config
  (defun backward-kill-line (arg)
    (interactive "p")
    (kill-line (- 1 arg)))

  (defun forward-kill-line (arg)
    (interactive "p")
    (kill-line (+ 1 arg)))

  ;; Unbind unused keys
  (general-def
    "C-u" nil
    "C-h" nil

    ; Unbind SPC for use as vim leader
    :states '(normal visual motion)
    "SPC" nil
    )

  (general-def
    "C-w" #'backward-kill-word
    "C-u" #'backward-kill-line
    "C-k" #'forward-kill-line
    "C-S-v" #'clipboard-yank
    "<escape>" #'keyboard-escape-quit
    ))

(use-package org
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
    '((C . t)
      (python . t)))

  (defun org-agenda-reload ()
    (save-window-excursion (org-agenda nil "a")))

  (defun org-agenda-reload-timer ()
    (run-with-idle-timer 900 t #'org-agenda-reload))

  (setq org-directory "~/doc"
        org-agenda-files '("~/doc")
        org-default-notes-file "~/doc/notes.org"
        org-adapt-indentation nil
        org-log-done 'time
        org-agenda-todo-ignore-with-date t
        org-tags-column 0))

(use-package org-chef)

(use-package dashboard
  :config
  (setq dashboard-set-heading-icons t
        dashboard-set-file-icons nil
        dashboard-banner-logo-title ""
        dashboard-startup-banner 'logo
        dashboard-set-init-info nil
        dashboard-set-footer nil

        dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (agenda . 5)))
  (dashboard-setup-startup-hook))

(use-package paren
  :config
  (setq show-paren-delay 0
        show-paren-highlight-openparen t
        show-paren-when-point-inside-paren t
        show-paren-when-point-in-periphery t)
  (show-paren-mode))

(use-package smartparens
  :config
  (require 'smartparens-config)
  (setq sp-highlight-pair-overlay nil
        sp-highlight-wrap-overlay nil
        sp-highlight-wrap-tag-overlay nil
        sp-escape-quotes-after-insert nil
        sp-max-prefix-length 25
        sp-max-pair-length 4)
  (smartparens-global-mode))

(use-package ivy
  :config
  (setq ivy-use-virtual-buffers t
        enable-recursive-minibuffers t)
  (ivy-mode))

(use-package counsel
  :config
  (counsel-mode))

(use-package swiper)

(use-package ivy-rich
  :after (ivy counsel)
  :config
  (ivy-rich-mode))

(use-package projectile
  :config
  (projectile-mode))

(use-package magit)

(use-package flycheck)

(use-package evil
  :init
  ;; Required for evil-collection
  (setq evil-want-integration t
        evil-want-keybinding nil)

  :general
  (:states '(normal)
           "C-g" #'evil-show-file-info)

  (:states '(normal visual)
           "SPC u" #'universal-argument
           "SPC w" #'evil-window-map
           "SPC h" help-map
           "C-u"   #'evil-scroll-up)

  (:states '(insert)
           "C-u" #'evil-delete-back-to-indentation
           "TAB" #'tab-to-tab-stop)

  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-escape
  :config
  (setq evil-escape-key-sequence "jk")
  (evil-escape-mode))

(use-package evil-commentary
  :config (evil-commentary-mode))

(use-package evil-surround
  :config (global-evil-surround-mode 1))

(use-package evil-org
  :after org
  :general
  ("C-c a" #'org-agenda)
  (:states '(normal visual)
           "g x" #'org-open-at-point)
  :init
  (add-hook 'org-mode-hook #'evil-org-mode)
  :config
  (add-hook 'evil-org-mode-hook
    (lambda ()
      (evil-org-set-key-theme '(navigation insert textobjects additional calendar))))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))
