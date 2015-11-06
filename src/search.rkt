#lang racket/base

(require racket/port
         
         net/http-client
         net/uri-codec
         json

         "access-info.rkt")

(provide search)
(define (search keyword
                #:host [host wp/host]
                #:url [url wp/url/search])
  (define-values
    (response headers input-port)
    (http-sendrecv host
                   (format url (uri-encode keyword))
                   #:ssl? #t
                   #:port wp/port
                   #:method "GET"
                   #:headers
                   `(,(format "User-Agent: ~a"
                              user-agent)
                      "Content-Type: application/x-www-form-urlencoded")))
  
  (read-json input-port))

(define (article title
                 #:host [host wp/host]
                 #:url [url wp/url/article])
  (define-values
    (response headers input-port)
    (http-sendrecv host
                   (format url (uri-encode title))
                   #:ssl? #t
                   #:port wp/port
                   #:method "GET"
                   #:headers
                   `(,(format "User-Agent: ~a"
                              user-agent)
                      "Content-Type: application/x-www-form-urlencoded")))

  (read-json input-port))

(define (extract title
                 #:host [host wp/host]
                 #:url [url wp/url/extract])
  (define-values
    (response headers input-port)
    (http-sendrecv host
                   (format url (uri-encode title))
                   #:ssl? #t
                   #:port wp/port
                   #:method "GET"
                   #:headers
                   `(,(format "User-Agent: ~a"
                              user-agent)
                      "Content-Type: application/x-www-form-urlencoded")))

  (read-json input-port))

(define (search->title results)
  (hash-ref (car (hash-ref (hash-ref results
                                     'query)
                           'search))
            'title))

(define (extract->text results)
  (define pages (hash-ref (hash-ref results
                                    'query)
                          'pages))
  (hash-ref (hash-ref pages
                      (car (hash-keys pages)))
            'extract))

(define (keyword->extract keyword)
  (define title (search->title (search keyword)))
  
  `#hash((title . ,title)
         (extract . ,(extract->text (extract title)))
         (link . ,(string-append "https://en.wikipedia.org/wiki/"
                                 (uri-encode title)))))

(module+ main
  (require racket/pretty)
  (pretty-print
    (keyword->extract "pink floyd")))
