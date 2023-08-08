;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(make-directory "~/doc/org" 'parents)
(make-directory "~/doc/org/roam" 'parents)

(setq doom-font (font-spec :family "monospace" :size 15)
      org-directory "~/doc/org/"
      org-roam-directory "~/doc/org/roam"
      company-idle-delay nil)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-material)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(map! :map global-map
      "C-S-v" 'clipboard-yank
      "M-h" 'evil-window-left
      "M-j" 'evil-window-down
      "M-k" 'evil-window-up
      "M-l" 'evil-window-right
      :n "C-l" 'evil-ex-nohighlight

      (:leader :prefix-map ("n" . "notes")
        :desc "Browse notes"       "f" #'+default/browse-notes
        :desc "Find file in notes" "F" #'+default/find-in-notes
      )
)

(set-irc-server! "irc.libera.chat"
  `(:tls t
    :port 6697
    :nick ,(+pass-get-user "irc.libera.chat")
    :sasl-username ,(+pass-get-user "irc.libera.chat")
    :sasl-password (lambda (&rest _) (+pass-get-secret "irc.libera.chat"))
    ))

(keymap-global-unset "<mouse-2>")

(after! org (setq
  org-blank-before-new-entry '((heading . nil) (plain-list-item . nil))
  org-startup-folded 'fold
  org-catch-invisible-edits 'error
  org-log-done 'note

  org-capture-templates `(
    ("t" "Todo" entry (file +org-capture-todo-file)
      "* TODO %?\n" :prepend t)
    ("T" "Todo with link" entry (file +org-capture-todo-file)
      "* TODO %?\n%i\n%a" :prepend t)
    ("n" "Notes" entry (file+headline +org-capture-notes-file "Inbox")
      "* %u %?\n%i\n%a")
    ("j" "Journal" entry (file+olp+datetree +org-capture-journal-file)
      "* %U %?\n%i\n%a" :prepend t)
    ("r" "Recipe" entry (file "recipes.org")
      "* %^{Title: }\n  :PROPERTIES:\n  :source-url: %^{Url: }\n  :END:\n** Ingredients\n   %?\n** Directions\n\n")
    ("l" "Link" entry (file +org-capture-todo-file)
      "* TODO [[%:link][%:description]]\n" :immediate-finish t)

    ("p" "Templates for projects")
    ("pt" "Project-local todo" entry (file+headline +org-capture-project-todo-file "Inbox")
      "* TODO %?\n%i\n%a" :prepend t)
    ("pn" "Project-local notes" entry (file+headline +org-capture-project-notes-file "Inbox")
      "* %U %?\n%i\n%a" :prepend t)
    ("pc" "Project-local changelog" entry (file+headline +org-capture-project-changelog-file "Unreleased")
      "* %U %?\n%i\n%a" :prepend t)

    ("o" "Centralized templates for projects")
    ("ot" "Project todo" entry #'+org-capture-central-project-todo-file "* TODO %?\n %i\n %a" :heading "Tasks" :prepend nil)
    ("on" "Project notes" entry #'+org-capture-central-project-notes-file "* %U %?\n %i\n %a" :heading "Notes" :prepend t)
    ("oc" "Project changelog" entry #'+org-capture-central-project-changelog-file "* %U %?\n %i\n %a" :heading "Changelog" :prepend t)
  )

  org-todo-keywords '(
    (sequence
      "STRT(s)"  ; A task that is in progress
      "WAIT(w)"  ; Something external is holding up this task
      "HOLD(h)"  ; This task is paused/on hold because of me
      "NEXT(n)"  ; An unconfirmed and unapproved task or notion
      "TODO(t)"  ; A task that needs doing & is ready to do
      "|"
      "KILL(k)"  ; Task was cancelled, aborted or is no longer applicable
      "DONE(d)"  ; Task successfully completed
    )

    (sequence
      "[ ](T)"   ; A task that needs doing
      "[-](S)"   ; Task is in progress
      "[?](W)"   ; Task is being held up or paused
      "|"
      "[X](D)"   ; Task was completed
    )

    (sequence
      "|"
      "OKAY(o)"
      "YES(y)"
      "NO(n)"
    )
  )

  org-todo-keyword-faces '(
    ("[-]"  . +org-todo-active)
    ("[?]"  . +org-todo-onhold)
    ("STRT" . +org-todo-active)
    ("HOLD" . +org-todo-onhold)
    ("WAIT" . +org-todo-onhold)
    ("NEXT" . "#9099ff")
    ("NO"   . +org-todo-cancel)
    ("KILL" . org-done)
  )

  org-agenda-sorting-strategy '(
    (agenda habit-down time-up priority-down category-keep)
    (todo todo-state-up priority-down category-keep)
    (tags priority-down category-keep)
    (search category-keep)
  )
))

(after! org-roam (org-roam-db-autosync-mode))
(after! org-protocol (setq org-protocol-default-template-key "l"))
