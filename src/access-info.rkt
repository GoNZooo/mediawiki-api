#lang racket/base

(provide user-agent)
(define user-agent
  "gonz' mediawiki-api bindings [http://github.com/GoNZooo/mediawiki-api]")

(provide wp/host)
(define wp/host "en.wikipedia.org")

(provide wp/url)
(define wp/url "/w/api.php?format=json")

(provide wp/url/search)
(define wp/url/search
  (string-append
    wp/url
    "&action=query&list=search&srsearch=~a&srprop=&srinfo="))

(provide wp/url/article)
(define wp/url/article
  (string-append
    wp/url
    "&action=query&titles=~a&prop=revisions&rvprop=content"))

(provide wp/url/extract)
(define wp/url/extract
  (string-append
    wp/url
    "&action=query&prop=extracts&exintro=&explaintext=&titles=~a"
    "&exsectionformat=plain&exsentences=4"))

(provide wp/port)
(define wp/port 443)
