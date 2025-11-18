;;; cargo-toml-helper.el --- Inline crate version and feature suggestions for Cargo.toml -*- lexical-binding: t; -*-

;; Author: Your Name
;; Version: 1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: rust, cargo, tools
;; URL: https://github.com/yourusername/cargo-toml-helper

;;; Commentary:

;; This package provides inline suggestions for crate versions and features
;; when editing Cargo.toml files, similar to crates.nvim in Neovim.
;;
;; Features:
;; - Show available versions for crates
;; - Display crate features
;; - Inline overlays with version information
;; - Update dependencies to latest versions
;; - Integration with company-mode for completion

;;; Code:

(require 'json)
(require 'url)
(require 'seq)

(defgroup cargo-toml-helper nil
  "Helper for Cargo.toml dependency management."
  :group 'tools
  :prefix "cargo-toml-helper-")

(defcustom cargo-toml-helper-cache-timeout 3600
  "Time in seconds to cache crate information."
  :type 'integer
  :group 'cargo-toml-helper)

(defcustom cargo-toml-helper-show-inline-versions t
  "Whether to show version information inline."
  :type 'boolean
  :group 'cargo-toml-helper)

(defcustom cargo-toml-helper-max-versions-display 5
  "Maximum number of versions to display in popups."
  :type 'integer
  :group 'cargo-toml-helper)

;;; Internal variables

(defvar cargo-toml-helper--cache (make-hash-table :test 'equal)
  "Cache for crate information.")

(defvar cargo-toml-helper--overlays nil
  "List of overlays created by cargo-toml-helper.")

;;; API functions

(defun cargo-toml-helper--fetch-crate-info (crate-name callback)
  "Fetch information for CRATE-NAME from crates.io and call CALLBACK with result."
  (let ((url (format "https://crates.io/api/v1/crates/%s" crate-name))
        (url-request-extra-headers '(("User-Agent" . "Emacs cargo-toml-helper"))))
    (url-retrieve
     url
     (lambda (status)
       (if (plist-get status :error)
           (message "Error fetching crate info for %s: %s" crate-name (plist-get status :error))
         (goto-char (point-min))
         (if (re-search-forward "\n\n" nil t)
             (condition-case err
                 (let* ((json-object-type 'hash-table)
                        (json-array-type 'list)
                        (json-key-type 'string)
                        (json-data (json-read))
                        (crate (gethash "crate" json-data))
                        (versions (gethash "versions" json-data)))
                   (if (and crate versions)
                       (funcall callback crate-name
                                (list :crate crate
                                      :versions versions))
                     (message "Invalid response structure for %s" crate-name)))
               (error (message "Error parsing JSON for %s: %s" crate-name err)))
           (message "No response body for %s" crate-name))))
     nil t)))

(defun cargo-toml-helper--get-crate-info (crate-name callback)
  "Get cached or fetch information for CRATE-NAME, then call CALLBACK."
  (let ((cached (gethash crate-name cargo-toml-helper--cache)))
    (if (and cached
             (< (- (time-to-seconds) (plist-get cached :timestamp))
                cargo-toml-helper-cache-timeout))
        (funcall callback crate-name (plist-get cached :data))
      ;; Fetch new data
      (cargo-toml-helper--fetch-crate-info
       crate-name
       (lambda (name data)
         (puthash name
                  (list :timestamp (time-to-seconds)
                        :data data)
                  cargo-toml-helper--cache)
         (funcall callback name data))))))

(defun cargo-toml-helper--parse-version (version-str)
  "Parse VERSION-STR into comparable format."
  (mapcar #'string-to-number (split-string version-str "\\.")))

(defun cargo-toml-helper--get-latest-version (versions)
  "Get the latest non-prerelease version from VERSIONS list."
  (let ((non-prerelease (seq-filter
                         (lambda (v)
                           (not (gethash "yanked" v)))
                         versions)))
    (when non-prerelease
      (gethash "num" (car non-prerelease)))))

(defun cargo-toml-helper--get-version-list (versions &optional limit)
  "Get list of version strings from VERSIONS, optionally LIMITED."
  (let ((filtered (seq-filter
                   (lambda (v)
                     (not (gethash "yanked" v)))
                   versions)))
    (mapcar (lambda (v) (gethash "num" v))
            (if limit
                (seq-take filtered limit)
              filtered))))

;;; Buffer parsing functions

(defun cargo-toml-helper--in-dependencies-section-p ()
  "Check if point is in a dependencies section."
  (save-excursion
    (beginning-of-line)
    (let ((section-regex "^\\[\\(dependencies\\|dev-dependencies\\|build-dependencies\\)\\]"))
      (and (not (looking-at "^\\["))
           (re-search-backward section-regex nil t)))))

(defun cargo-toml-helper--get-dependency-at-point ()
  "Get the dependency name and version at point."
  (save-excursion
    (beginning-of-line)
    (when (looking-at "^\\([a-zA-Z0-9_-]+\\)\\s-*=\\s-*\\(?:\"\\([^\"]*\\)\"\\|{.*version\\s-*=\\s-*\"\\([^\"]*\\)\"\\)")
      (let ((name (match-string 1))
            (version (or (match-string 2) (match-string 3))))
        (list :name name :version version :pos (point))))))

(defun cargo-toml-helper--get-all-dependencies ()
  "Get all dependencies in the current buffer."
  (save-excursion
    (goto-char (point-min))
    (let (deps)
      (while (re-search-forward "^\\([a-zA-Z0-9_-]+\\)\\s-*=\\s-*\\(?:\"\\([^\"]*\\)\"\\|{.*version\\s-*=\\s-*\"\\([^\"]*\\)\"\\)" nil t)
        (when (cargo-toml-helper--in-dependencies-section-p)
          (push (list :name (match-string 1)
                      :version (or (match-string 2) (match-string 3))
                      :pos (line-beginning-position))
                deps)))
      (nreverse deps))))

;;; Overlay functions

(defun cargo-toml-helper--clear-overlays ()
  "Clear all cargo-toml-helper overlays."
  (mapc #'delete-overlay cargo-toml-helper--overlays)
  (setq cargo-toml-helper--overlays nil))

(defun cargo-toml-helper--create-version-overlay (line-end crate-name latest-version current-version)
  "Create an overlay at LINE-END showing version info for CRATE-NAME."
  (let ((ov (make-overlay line-end line-end)))
    (overlay-put ov 'after-string
                 (propertize
                  (format "  ← latest: %s%s"
                          latest-version
                          (if (and current-version
                                   (not (string= current-version latest-version)))
                              (format " (current: %s)" current-version)
                            ""))
                  'face '(:foreground "#888888" :slant italic)))
    (push ov cargo-toml-helper--overlays)))

;;; Interactive commands

;;;###autoload
(defun cargo-toml-helper-show-versions ()
  "Show available versions for the crate at point."
  (interactive)
  (let ((dep (cargo-toml-helper--get-dependency-at-point)))
    (if (not dep)
        (message "No dependency found at point")
      (let ((crate-name (plist-get dep :name)))
        (message "Fetching versions for %s..." crate-name)
        (cargo-toml-helper--get-crate-info
         crate-name
         (lambda (name data)
           (let* ((versions (plist-get data :versions))
                  (version-list (when versions
                                  (cargo-toml-helper--get-version-list
                                   versions
                                   cargo-toml-helper-max-versions-display))))
             (if version-list
                 (let ((msg (format "Available versions for %s:\n%s"
                                    name
                                    (mapconcat (lambda (v) (format "  • %s" v))
                                               version-list
                                               "\n"))))
                   (message "%s" msg)
                   ;; Also show in a temporary buffer for better readability
                   (with-output-to-temp-buffer "*Crate Versions*"
                     (princ msg)))
               (message "No versions found for %s" name)))))))))

;;;###autoload
(defun cargo-toml-helper-update-to-latest ()
  "Update the dependency at point to the latest version."
  (interactive)
  (let ((dep (cargo-toml-helper--get-dependency-at-point)))
    (if (not dep)
        (message "No dependency found at point")
      (let ((crate-name (plist-get dep :name)))
        (message "Fetching latest version for %s..." crate-name)
        (cargo-toml-helper--get-crate-info
         crate-name
         (lambda (name data)
           (let* ((versions (plist-get data :versions))
                  (latest (cargo-toml-helper--get-latest-version versions)))
             (if latest
                 (save-excursion
                   (beginning-of-line)
                   (when (re-search-forward "\"\\([^\"]*\\)\"" (line-end-position) t)
                     (replace-match latest nil nil nil 1)
                     (message "Updated %s to version %s" name latest)))
               (message "No latest version found for %s" name)))))))))

;;;###autoload
(defun cargo-toml-helper-show-features ()
  "Show available features for the crate at point."
  (interactive)
  (let ((dep (cargo-toml-helper--get-dependency-at-point)))
    (if (not dep)
        (message "No dependency found at point")
      (let ((crate-name (plist-get dep :name)))
        (message "Fetching features for %s..." crate-name)
        (cargo-toml-helper--get-crate-info
         crate-name
         (lambda (name data)
           (let* ((versions (plist-get data :versions))
                  (latest-version (when versions (elt versions 0)))
                  (features (when latest-version
                              (gethash "features" latest-version))))
             (if (and features (> (hash-table-count features) 0))
                 (let ((feature-list nil))
                   (maphash (lambda (k v) (push k feature-list)) features)
                   (setq feature-list (sort feature-list #'string<))
                   (let ((msg (format "Available features for %s:\n%s"
                                      name
                                      (mapconcat (lambda (f) (format "  • %s" f))
                                                 feature-list
                                                 "\n"))))
                     (message "%s" msg)
                     ;; Also show in a temporary buffer for better readability
                     (with-output-to-temp-buffer "*Crate Features*"
                       (princ msg))))
               (message "No features found for %s" name)))))))))

;;;###autoload
(defun cargo-toml-helper-update-all-outdated ()
  "Update all outdated dependencies in the buffer."
  (interactive)
  (let ((deps (cargo-toml-helper--get-all-dependencies))
        (updated 0))
    (if (not deps)
        (message "No dependencies found")
      (message "Checking %d dependencies..." (length deps))
      (dolist (dep deps)
        (let ((name (plist-get dep :name))
              (current-version (plist-get dep :version))
              (pos (plist-get dep :pos)))
          (cargo-toml-helper--get-crate-info
           name
           (lambda (crate-name data)
             (let* ((versions (plist-get data :versions))
                    (latest (cargo-toml-helper--get-latest-version versions)))
               (when (and latest
                          current-version
                          (not (string= current-version latest)))
                 (save-excursion
                   (goto-char pos)
                   (when (re-search-forward "\"\\([^\"]*\\)\"" (line-end-position) t)
                     (replace-match latest nil nil nil 1)
                     (setq updated (1+ updated))
                     (message "Updated %s: %s → %s" crate-name current-version latest))))))))))))

;;;###autoload
(defun cargo-toml-helper-refresh-inline-versions ()
  "Refresh inline version information for all dependencies."
  (interactive)
  (when cargo-toml-helper-show-inline-versions
    (cargo-toml-helper--clear-overlays)
    (let ((deps (cargo-toml-helper--get-all-dependencies)))
      (dolist (dep deps)
        (let ((name (plist-get dep :name))
              (current-version (plist-get dep :version))
              (pos (plist-get dep :pos)))
          (cargo-toml-helper--get-crate-info
           name
           (lambda (crate-name data)
             (let* ((versions (plist-get data :versions))
                    (latest (cargo-toml-helper--get-latest-version versions)))
               (when latest
                 (save-excursion
                   (goto-char pos)
                   (cargo-toml-helper--create-version-overlay
                    (line-end-position)
                    crate-name
                    latest
                    current-version)))))))))))

;;; Company integration

(defun cargo-toml-helper-company-backend (command &optional arg &rest ignored)
  "Company backend for crate name completion."
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'cargo-toml-helper-company-backend))
    (prefix (and (derived-mode-p 'toml-mode 'conf-toml-mode)
                 (cargo-toml-helper--in-dependencies-section-p)
                 (company-grab-symbol)))
    (candidates
     (cons :async
           (lambda (callback)
             (let ((url (format "https://crates.io/api/v1/crates?q=%s&per_page=10" arg))
                   (url-request-extra-headers '(("User-Agent" . "Emacs cargo-toml-helper"))))
               (url-retrieve
                url
                (lambda (status)
                  (goto-char (point-min))
                  (when (re-search-forward "\n\n" nil t)
                    (let* ((json-data (json-read))
                           (crates (gethash "crates" json-data))
                           (names (mapcar (lambda (c) (gethash "name" c))
                                          (append crates nil))))
                      (funcall callback names))))
                nil t)))))))

;;; Minor mode

(defvar cargo-toml-helper-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-v") #'cargo-toml-helper-show-versions)
    (define-key map (kbd "C-c C-u") #'cargo-toml-helper-update-to-latest)
    (define-key map (kbd "C-c C-f") #'cargo-toml-helper-show-features)
    (define-key map (kbd "C-c C-r") #'cargo-toml-helper-refresh-inline-versions)
    (define-key map (kbd "C-c C-a") #'cargo-toml-helper-update-all-outdated)
    map)
  "Keymap for `cargo-toml-helper-mode'.")

;;;###autoload
(define-minor-mode cargo-toml-helper-mode
  "Minor mode for Cargo.toml editing with inline version suggestions."
  :lighter " CargoHelper"
  :keymap cargo-toml-helper-mode-map
  (if cargo-toml-helper-mode
      (progn
        ;; Enable the mode
        (when cargo-toml-helper-show-inline-versions
          (cargo-toml-helper-refresh-inline-versions))
        (add-hook 'after-save-hook #'cargo-toml-helper-refresh-inline-versions nil t))
    ;; Disable the mode
    (cargo-toml-helper--clear-overlays)
    (remove-hook 'after-save-hook #'cargo-toml-helper-refresh-inline-versions t)))

;;;###autoload
(defun cargo-toml-helper-setup ()
  "Set up cargo-toml-helper for Cargo.toml files."
  (when (and buffer-file-name
             (string-match-p "Cargo\\.toml\\'" buffer-file-name))
    (cargo-toml-helper-mode 1)))

(provide 'cargo-toml-helper)

;;; cargo-toml-helper.el ends here
