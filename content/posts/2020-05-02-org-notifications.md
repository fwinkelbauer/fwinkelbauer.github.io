---
title: "Org-Mode Calendar Notifications"
date: 2020-05-02
---

I was wondering if I could create notifactions for my calendar entries in
org-mode on Windows and Linux and it turns out, that the setup isn't that
complex.

The `appt` module can display notifications for specific appointments, so we
need to export org-mode entries as appointments:

``` emacs-lisp
(require 'appt)
(appt-activate t)

(defun fw/org-agenda-to-appt ()
  "Rebuild all appt reminders using org."
  (interactive)
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

(fw/org-agenda-to-appt)
(add-hook 'org-agenda-finalize-hook 'fw/org-agenda-to-appt)
```

The above snippet will create appointments when Emacs boots up and every time
when we open `org-agenda`. The `appt` notifactions appear in a mini-buffer,
which disappears after a few seconds. We can get persistant notifactions by
using a different "backend" such as the Windows 10 notifactions area (via the
PowerShell module [BurntToast][burnt]) or the Linux command line tool
`notify-send`:

``` emacs-lisp
(defun fw/appt-disp-linux (min-to-app new-time msg)
  "A custom `appt-disp-window-function' which uses `notifications'."
  (require 'notifications)
  (notifications-notify :title msg :timeout 0))

(defun fw/appt-disp-windows (min-to-app new-time msg)
  "A custom `appt-disp-window-function' which uses the PowerShell module 'BurntToast'"
  (shell-command
   (concat "powershell.exe -Command \"New-BurntToastNotification -Text '" msg "'\"")))

(when (eq system-type 'gnu/linux)
  (progn
    (setq appt-display-format 'window)
    (setq appt-disp-window-function (function fw/appt-disp-linux))
    (setq appt-delete-window-function (lambda nil))))

(when (eq system-type 'windows-nt)
  (progn
    (setq appt-display-format 'window)
    (setq appt-disp-window-function (function fw/appt-disp-windows))
    (setq appt-delete-window-function (lambda nil))))
```

[burnt]: https://github.com/Windos/BurntToast
