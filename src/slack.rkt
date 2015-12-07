#lang racket/base

(require json)

(provide wiki-payload)
(define (wiki-payload info)
  (define thumbnail (hash-ref info 'thumbnail))
  (define original (hash-ref info 'original))
  (jsexpr->string
   `#hash((text . " ")
          (attachments .
                       (#hash((text . ,(hash-ref info 'extract))
                              (fallback . ,(hash-ref info 'extract))
                              (title . ,(hash-ref info 'title))
                              (title_link . ,(hash-ref info 'link))
                              (thumb_url . ,(hash-ref info 'thumbnail))
                              (image_url . ,(hash-ref info 'original))))))))

