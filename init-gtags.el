;;; init-gtags.el --- Initial file for gtags in Emacs
;;
;;; Commentary:
;;
;; GTAGS - Gnu Global tagging system
;;

;;; Code:
(autoload 'gtags-mode "./gtags.el" "" t)

;; Setting to use vi style scroll key
;;(add-hook 'gtags-mode-hook
;;  '(lambda ()
;;        ; Local customization (overwrite key mapping)
;;        (define-key gtags-mode-map "\C-f" 'scroll-up)
;;        (define-key gtags-mode-map "\C-b" 'scroll-down)
;;))

;; Setting to make 'Gtags select mode' easy to see
(add-hook 'gtags-select-mode-hook
  '(lambda ()
        (setq hl-line-face 'underline)
        (hl-line-mode 1)
))

(add-hook 'c-mode-hook
  '(lambda ()
        (gtags-mode 1)))

(add-hook 'c++-mode-hook
  '(lambda ()
        (gtags-mode 1)))

(add-hook 'java-mode-hook
  '(lambda ()
        (gtags-mode 1)))

;; Customization
(setq gtags-suggested-key-mapping t)
(setq gtags-auto-update t)

;;
;; loop through all kinds of GTAGS results including tags, rtags, & symbols.
;; (i.e.: gtags-find-tag  gtags-find-rtag  gtags-find-symbol)
;;
(defun gtags-loop-thru-next ()
  "Find next matching tag, for GTAGS."
  (interactive)
  (let ((latest-gtags-buffer
         (car (delq nil  (mapcar (lambda (x) (and (string-match "GTAGS SELECT" (buffer-name x)) (buffer-name x)) )
                                 (buffer-list)) ))))
    (cond (latest-gtags-buffer
           (switch-to-buffer latest-gtags-buffer)
           (forward-line)
           (gtags-select-it nil))
          ) ))

(defun gtags-root-dir ()
    "Return GTAGS root directory or nil if doesn't exist."
    (with-temp-buffer
      (if (zerop (call-process "global" nil t nil "-pr"))
          (buffer-substring (point-min) (1- (point-max)))
           nil)))

(defun gtags-update ()
    "Make GTAGS incremental update."
    (call-process "global" nil nil nil "-u"))

(defun gtags-update-hook ()
    "Update GTAGS file for a group of files."
    (when (gtags-root-dir)
      (gtags-update)))

;; use GNU GLOBAL incremental update feature in after-save-hook
;; to keep synchronized the changes you made in source code and gtags database
(add-hook 'after-save-hook 'gtags-update-hook)

;; For projects with a huge amount of files, “global -u” can take a very long time to complete.
;; For changes in a single file, we can update the tags with “gtags --single-update” and do it in the background
(defun gtags-update-single (filename)
      "Update Gtags database for change in a single file."
      (interactive)
      (start-process "update-gtags" "update-gtags" "bash" "-c" (concat "cd " (gtags-root-dir) " ; gtags --single-update " filename )))

(defun gtags-update-current-file ()
      "Update Gtags database for change in a single file in current buffer."
      (defvar current-filename)
      (setq current-filename (replace-regexp-in-string (gtags-root-dir) "." (buffer-file-name (current-buffer))))
      (gtags-update-single current-filename)
      (message "Gtags updated for %s" current-filename))

(defun gtags-update-hook-current-file ()
      "Update GTAGS file incrementally upon saving a file."
      (when gtags-mode
        (when (gtags-root-dir)
          (gtags-update-current-file))))

(add-hook 'after-save-hook 'gtags-update-hook)

(provide 'init-gtags)
;;; init-gtags ends here
