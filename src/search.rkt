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

(provide keyword->info)
(define (keyword->info keyword)
  (define title (search->title (search keyword)))

  (define image-data (images title))
  
  `#hash((title . ,title)
         (thumbnail . ,(images->thumbnail image-data))
         (original . ,(images->original image-data))
         (extract . ,(extract->text (extract title)))
         (link . ,(string-append "https://en.wikipedia.org/wiki/"
                                 (uri-encode title)))))

(define (images title
                 #:host [host wp/host]
                 #:url [url wp/url/images])
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

(define (images->thumbnail results)
  (define thumbnail
    (hash-ref (car (hash-values (hash-ref (hash-ref results
                                                    'query)
                                          'pages)))
              'thumbnail
              '#hash()))
  
  (hash-ref thumbnail
            'source
            ""))

(define (images->original results)
  (define original
    (hash-ref (car (hash-values (hash-ref (hash-ref results
                                                    'query)
                                          'pages)))
              'thumbnail
              '#hash()))
  
  (hash-ref original
            'original
            ""))

(module+ main
  (require racket/pretty)
  (pretty-print
    (images "Trello")))
