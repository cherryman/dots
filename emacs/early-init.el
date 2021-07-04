;; -*- lexical-binding: t; -*-
;; See https://github.com/hlissner/doom-emacs/blob/develop/docs/faq.org#how-does-doom-start-up-so-quickly

;; Avoid garbage collection at startup
(setq gc-cons-threshold most-positive-fixnum ; 2^61 bytes
      gc-cons-percentage 0.6)
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq gc-cons-threshold 16777216 ; 16mb
          gc-cons-percentage 0.1)))

;; Unset file-name-handler-alist temporarily
(defvar _--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq file-name-handler-alist _--file-name-handler-alist)))

(dolist
  (x (list '(font . "monospace-14")
           '(menu-bar-lines . 0)
           '(tool-bar-liens . 0)
           '(vertical-scroll-bars . nil)))
  (push x default-frame-alist))

(setq package-enable-at-startup nil
      frame-inhibit-implied-resize t
      menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)
