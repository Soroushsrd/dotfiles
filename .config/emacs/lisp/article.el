;;; article.el --- Latest article capturer for emacs -*- lexical-binding: t; -*-
;;; Commentary:
;; This package provides a means to capture the latest articles on emacs from some specific blogs
;;; Code:

(defvar my/watched-sites
  '(("Irreal" . "https://irreal.org/blog/"))
  "Alist of (NAME . URL) for sites to check.")

(defvar my/latest-articles '()
  "Alist of (NAME . (TITLE . URL)) populated after fetching.")

(defvar my/pending-fetches 0)

(defun my/parse-entry-title (buf)
  "Return (TITLE . URL) for the first entry-title found in BUF."
  (with-current-buffer buf
    (goto-char (point-min))
    (search-forward "\n\n" nil t)
    (let* ((dom (libxml-parse-html-region (point) (point-max) nil t))
           (h2 (car (dom-by-class dom "entry-title")))
           (a (when h2 (car (dom-by-tag h2 'a)))))
      (when a
        (cons (string-trim (dom-text a))
              (dom-attr a 'href))))))

(defun my/fetch-site (name url)
  "Fetch URL, parse it, and store result under NAME in my/latest-articles."
  (cl-incf my/pending-fetches)
  (url-retrieve url
                (lambda (status)
                  (cl-decf my/pending-fetches)
                  (if (plist-get status :error)
                      (message "my/fetch-site: error fetching %s: %s" name
                               (plist-get status :error))
                    (let ((result (my/parse-entry-title (current-buffer))))
                      (if result
                          (setf (alist-get name my/latest-articles nil nil #'equal)
                                result)
                        (message "my/fetch-site: could not parse %s" name))))
                  (kill-buffer (current-buffer))
                  (when (zerop my/pending-fetches)
                    (dashboard-refresh-buffer)))
                nil t t))

(defun my/fetch-all-sites ()
  "Kick off async fetches for all sites in my/watched-sites."
  (dolist (site my/watched-sites)
    (my/fetch-site (car site) (cdr site))))

(defun my/render-latest-articles ()
  "Insert latest articles into current buffer."
  (if (null my/latest-articles)
      (insert "  No articles fetched yet.\n")
    (dolist (entry my/latest-articles)
      (let* ((name (car entry))
             (title (cadr entry))
             (url (cddr entry))
             (display (format "  [%s] %s\n" name title)))
        (insert-text-button
         display
         'action (lambda (_) (browse-url url))
         'follow-link t
         'help-echo url)))))

(defun my/dashboard-insert-articles (_list-size)
  "Dashboard widget: insert latest articles."
  (insert "  Latest Articles:\n")
  (my/render-latest-articles))

(add-to-list 'dashboard-item-generators
             '(articles . my/dashboard-insert-articles))
(add-to-list 'dashboard-items '(articles . 5) t)

(add-hook 'emacs-startup-hook #'my/fetch-all-sites)

(provide 'article)
;;; article.el ends here
