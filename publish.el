(when (version< emacs-version "28.1")
  (error "Unsupported version of Emacs"))

(require 'ox-publish)

(defun fw.com/join-lines (&rest strings)
  "Join all non-nil strings."
  (string-join (remq nil strings) "\n"))

(defun fw.com/postamble (info)
  "Create a custom postamble."
  (let ((date (org-export-data (org-export-get-date info "%Y-%m-%d") info)))
    (fw.com/join-lines (unless (string-empty-p date) (concat "<p class=\"date\">Published: " date "</p>"))
                       "<footer>"
                       "<p>Copyright 2025, Florian Winkelbauer. All rights reserved.</p>"
                       "</footer>")))

(defun fw.com/sitemap-format-entry (entry style project)
  "Add date to a sitemap entry."
  (cond ((not (directory-name-p entry))
         (format "%s - [[file:%s][%s]]"
                 (format-time-string "%Y-%m-%d" (org-publish-find-date entry project))
                 entry
                 (org-publish-find-title entry project)))
        ((eq style 'tree) (file-name-nondirectory (directory-file-name entry)))
        (t entry)))

(defun fw.com/get-article-output-path (org-file pub-dir)
  "Ensure an output path."
  (let ((article-dir (concat pub-dir
                             (downcase
                              (file-name-as-directory
                               (file-name-sans-extension
                                (file-name-nondirectory org-file)))))))

    (if (string-match "\\/index.org\\|\\/404.org$" org-file)
        pub-dir
      (progn
        (unless (file-directory-p article-dir)
          (make-directory article-dir t))
        article-dir))))

(defun fw.com/org-html-link (link contents info)
  "Removes file extension and changes the path into lowercase file:// links."
  (when (and (string= 'file (org-element-property :type link))
             (string= "org" (file-name-extension (org-element-property :path link))))
    (org-element-put-property link :path
                              (downcase
                               (file-name-sans-extension
                                (org-element-property :path link)))))

  (let ((exported-link (org-export-custom-protocol-maybe link contents 'html info)))
    (cond
     (exported-link exported-link)
     ((equal contents nil)
      (format "<a href=\"%s\">%s</a>"
              (org-element-property :raw-link link)
              (org-element-property :raw-link link)))
     ((string-prefix-p "/" (org-element-property :raw-link link))
      (format "<a href=\"%s\">%s</a>"
              (org-element-property :raw-link link)
              contents))
     (t (org-export-with-backend 'html link contents info)))))

(defun fw.com/org-html-publish-to-html (plist filename pub-dir)
  "Publish an org file to HTML, using the FILENAME as the output directory."
  (let ((article-path (fw.com/get-article-output-path filename pub-dir)))
    (cl-letf (((symbol-function 'org-export-output-file-name)
               (lambda (extension &optional subtreep pub-dir)
                 ;; The 404 page is a special case, it must be named "404.html"
                 (concat article-path
                         (if (string= (file-name-nondirectory filename) "404.org") "404" "index")
                         extension))))
      (org-publish-org-to 'site-html filename
                          (concat "." (or (plist-get plist :html-extension)
                                          org-html-extension
                                          "html"))
                          plist
                          article-path))))

(defun fw.com/publish-website ()
  "Publish my website"
  (let ((org-publish-project-alist
         `(("content"
            :base-directory "content/"
            :publishing-directory "artifacts/"
            :publishing-function fw.com/org-html-publish-to-html
            :recursive nil)

           ("notes"
            :auto-sitemap t
            :base-directory "content/notes/"
            :publishing-directory "artifacts/notes/"
            :publishing-function fw.com/org-html-publish-to-html
            :recursive t
            :sitemap-filename "index.org"
            :sitemap-title "Notes")

           ("posts"
            :auto-sitemap t
            :base-directory "content/posts/"
            :publishing-directory "artifacts/posts/"
            :publishing-function fw.com/org-html-publish-to-html
            :recursive t
            :sitemap-filename "index.org"
            :sitemap-sort-files anti-chronologically
            :sitemap-format-entry fw.com/sitemap-format-entry
            :sitemap-title "Posts")

           ("static"
            :base-directory "static/"
            :base-extension any
            :publishing-directory "artifacts/"
            :publishing-function org-publish-attachment
            :recursive t)

           ("florianwinkelbauer.com" :components ("content" "notes" "posts" "static"))))
        (org-export-time-stamp-file nil)
        (org-export-with-author nil)
        (org-export-with-section-numbers nil)
        (org-export-with-toc nil)
        (org-html-doctype "html5")
        (org-html-html5-fancy t)
        (org-html-head
         (fw.com/join-lines "<meta name=\"author\" content=\"Florian Winkelbauer\">"
                            "<link rel=\"stylesheet\" href=\"/site.css\" type=\"text/css\">"))
        (org-html-head-include-default-style nil)
        (org-html-head-include-scripts nil)
        (org-html-mathjax-template "")
        (org-html-postamble 'fw.com/postamble)
        (org-html-preamble
         (fw.com/join-lines "<nav>"
                            "<a href=\"/\">Home</a>"
                            "<a href=\"/notes\">Notes</a>"
                            "<a href=\"/posts\">Posts</a>"
                            "<a href=\"/projects\">Projects</a>"
                            "</nav>"))
        (org-html-validation-link nil)
        (org-publish-timestamp-directory ".org-timestamps/"))
    (org-publish "florianwinkelbauer.com" t)))

(org-export-define-derived-backend 'site-html 'html :translate-alist '((link . fw.com/org-html-link)))
(fw.com/publish-website)
