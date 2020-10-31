(add-to-list 'default-frame-alist '(font . "monospace-14"))
(tool-bar-mode -1)
(menu-bar-mode -1)
(global-display-line-numbers-mode)

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
  '(("melpa" . "http://melpa.org/packages/")))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-material t))

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config (evil-collection-init))

(use-package evil-commentary
  :ensure t
  :config (evil-commentary-mode))

(use-package evil-magit
  :ensure t
  :after (evil magit))

(use-package evil-surround
  :ensure t
  :config (global-evil-surround-mode 1))

(use-package magit
  :ensure t)

(use-package smartparens
  :ensure t
  :config
  (setq smartparens-strict-mode t)
  (smartparens-global-mode 1))
