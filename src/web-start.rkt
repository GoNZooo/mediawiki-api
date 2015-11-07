#lang racket/base

(require racket/string

         web-server/servlet
         web-server/servlet-env
         web-server/templates
         web-server/dispatch
         web-server/page
         web-server/http/bindings
         
         "slack.rkt"
         "search.rkt"
         
         "jeapostrophe/threading-arrow.rkt")

(define/page (slack-wiki-hook-response title)
  (response/full
    200 #"Okay"
    (current-seconds) TEXT/HTML-MIME-TYPE
    '()
    `(,(string->bytes/utf-8 (wiki-payload (keyword->info title))))))

(define (slack-request/wiki-hook/post request)
  (slack-wiki-hook-response request
                            (~> (request-bindings request)
                                (extract-binding/single 'text <>)
                                (string-split <> "!wiki ")
                                car)))

(define/page (ping-page)
  (response/full
    200 #"Okay"
    (current-seconds) TEXT/HTML-MIME-TYPE
    '()
    `(,(string->bytes/utf-8 "Pong!"))))

(define (request/ping request)
  (ping-page request))

(define-values (wikipedia-hook-hispatch wikipedia-page-url)
  (dispatch-rules
    [("ping") request/ping]
    [("wiki" "slack" "wiki-hook")
     #:method "post"
     slack-request/wiki-hook/post]))

(serve/servlet wikipedia-hook-hispatch
               #:port 8083
               #:listen-ip #f
               #:servlet-regexp #rx""
               #:command-line? #t
               #:extra-files-paths `("static")
               #:servlet-current-directory "./"
               )

