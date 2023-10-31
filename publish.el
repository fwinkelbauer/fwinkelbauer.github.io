(require 'ox-publish)

(defun fw/join-lines (&rest strings)
  "Join all non-nil strings."
  (string-join (remq nil strings) "\n"))

(defun fw/postamble (info)
  "Create a custom postamble."
  (let ((date (org-export-data (org-export-get-date info "%Y-%m-%d") info)))
    (fw/join-lines (unless (string-empty-p date) (concat "<p class=\"date\">Published: " date "</p>"))
                   "<footer>"
                   "<p>Copyright 2023, Florian Winkelbauer. All rights reserved.</p>"
                   "</footer>")))

(defun fw/sitemap-format-entry (entry style project)
  "Add date to a sitemap entry."
  (cond ((not (directory-name-p entry))
         (format "%s - [[file:%s][%s]]"
                 (format-time-string "%Y-%m-%d" (org-publish-find-date entry project))
                 entry
                 (org-publish-find-title entry project)))
        ((eq style 'tree) (file-name-nondirectory (directory-file-name entry)))
        (t entry)))

(defun fw/publish-website ()
  "Publish my website"
  (let ((org-publish-project-alist
         `(("content"
            :base-directory "./content/"
            :publishing-directory "./public/"
            :publishing-function org-html-publish-to-html
            :recursive nil)

           ("notes"
            :auto-sitemap t
            :base-directory "./content/notes"
            :publishing-directory "./public/notes"
            :publishing-function org-html-publish-to-html
            :recursive t
            :sitemap-filename "index.org"
            :sitemap-title "Notes")

           ("posts"
            :auto-sitemap t
            :base-directory "./content/posts"
            :publishing-directory "./public/posts"
            :publishing-function org-html-publish-to-html
            :recursive t
            :sitemap-filename "index.org"
            :sitemap-sort-files anti-chronologically
            :sitemap-format-entry fw/sitemap-format-entry
            :sitemap-title "Posts")

           ("static"
            :base-directory "./static/"
            :base-extension any
            :publishing-directory "./public/"
            :publishing-function org-publish-attachment
            :recursive t)

           ("florianwinkelbauer.com" :components ("content" "notes" "posts" "static"))))
        (backup-inhibited t)
        (org-export-time-stamp-file nil)
        (org-export-with-author nil)
        (org-export-with-section-numbers nil)
        (org-export-with-toc nil)
        (org-html-doctype "html5")
        (org-html-html5-fancy t)
        (org-html-head
         (fw/join-lines "<meta name=\"author\" content=\"Florian Winkelbauer\">"
                        "<link rel=\"stylesheet\" href=\"/site.css\" type=\"text/css\">"))
        (org-html-head-include-default-style nil)
        (org-html-head-include-scripts nil)
        (org-html-postamble 'fw/postamble)
        (org-html-preamble
         (fw/join-lines "<nav>"
                        "<a href=\"/index.html\">Home</a>"
                        "<a href=\"/notes/index.html\">Notes</a>"
                        "<a href=\"/posts/index.html\">Posts</a>"
                        "<a href=\"/projects.html\">Projects</a>"
                        "</nav>"))
        (org-html-self-link-headlines t)
        (org-html-validation-link nil)
        (org-publish-timestamp-directory "./.org-timestamps/"))
    (org-publish "florianwinkelbauer.com" t)))

(fw/publish-website)
