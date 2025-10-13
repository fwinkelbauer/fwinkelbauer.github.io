(when (version< emacs-version "28.1")
  (error "Unsupported version of Emacs"))

(require 'ox-publish)

(defun fw/join (&rest strings)
  "Join all non-nil strings."
  (string-join (remq nil strings) "\n"))

(defun fw/postamble (info)
  "Create a custom postamble."
  (let ((date (org-export-data (org-export-get-date info "%Y-%m-%d") info)))
    (fw/join (unless (string-empty-p date) (concat "<p class=\"date\">Published: " date "</p>"))
             "<footer>"
             "<p>© 2025 Florian Winkelbauer</p>"
             "</footer>")))

(defun fw/sitemap-format-entry (entry style project)
  "Add date to a sitemap entry."
  (let ((title (org-publish-find-title entry project))
        (date (org-publish-find-date entry project)))
    (format "%s - [[file:%s][%s]]"
            (format-time-string "%Y-%m-%d" date)
            entry
            title)))

(defun fw/filter-local-links (link backend info)
  "Filter that removes all the /index.html postfixes from links."
  (if (org-export-derived-backend-p backend 'html)
	  (replace-regexp-in-string "/index.html" "" link)))

(defun fw/publish-website ()
  "Publish my website."
  (let ((org-export-filter-link-functions '(fw/filter-local-links))
        (org-publish-project-alist
         `(("content"
            :base-directory "content/"
            :publishing-directory "artifacts/"
            :publishing-function org-html-publish-to-html
            :recursive nil)

           ("notes"
            :auto-sitemap t
            :base-directory "content/notes/"
            :publishing-directory "artifacts/notes/"
            :publishing-function org-html-publish-to-html
            :recursive t
            :sitemap-filename "index.org"
            :sitemap-style list
            :sitemap-title "Notes")

           ("posts"
            :auto-sitemap t
            :base-directory "content/posts/"
            :publishing-directory "artifacts/posts/"
            :publishing-function org-html-publish-to-html
            :recursive t
            :sitemap-filename "index.org"
            :sitemap-sort-files anti-chronologically
            :sitemap-format-entry fw/sitemap-format-entry
            :sitemap-style list
            :sitemap-title "Posts")

           ("projects"
            :base-directory "content/projects/"
            :publishing-directory "artifacts/projects/"
            :publishing-function org-html-publish-to-html
            :sitemap-filename "index.org")

           ("static"
            :base-directory "static/"
            :base-extension any
            :publishing-directory "artifacts/"
            :publishing-function org-publish-attachment
            :recursive t)

           ("florianwinkelbauer.com" :components ("content" "notes" "posts" "projects" "static"))))
        (org-export-time-stamp-file nil)
        (org-export-with-author nil)
        (org-export-with-section-numbers nil)
        (org-export-with-toc nil)
        (org-html-doctype "html5")
        (org-html-html5-fancy t)
        (org-html-head
         (fw/join "<meta name=\"author\" content=\"Florian Winkelbauer\">"
                  "<link rel=\"stylesheet\" href=\"/site.css\" type=\"text/css\">"))
        (org-html-head-include-default-style nil)
        (org-html-head-include-scripts nil)
        (org-html-mathjax-template "")
        (org-html-postamble 'fw/postamble)
        (org-html-preamble
         (fw/join "<nav>"
                  "<a href=\"/\">Home</a>"
                  "<a href=\"/notes\">Notes</a>"
                  "<a href=\"/posts\">Posts</a>"
                  "<a href=\"/projects\">Projects</a>"
                  "</nav>"))
        (org-html-self-link-headlines t)
        (org-html-validation-link nil)
        (org-publish-timestamp-directory ".org-timestamps/"))
    (org-publish "florianwinkelbauer.com" t)))

(fw/publish-website)
