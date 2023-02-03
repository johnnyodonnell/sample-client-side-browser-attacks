#lang racket

(require web-server/servlet
         web-server/servlet-env)


(define parse-headers
  (lambda (req sep)
    (string-join
      (map
        (lambda (header)
          (string-append
            (symbol->string (car header))
            ": "
            (cdr header)))
        (request-headers req))
      sep)))

(define parse-request
  (lambda (req sep)
    (string-join
      (list
        "<h3>Request details:</h3>"
        (string-join
          (list
            (bytes->string/utf-8
              (request-method req))
            (path->string
              (url->path (request-uri req))))
          " ")
        (parse-headers req sep)
        )
      sep)))

(define get-origin
  (lambda (req)
    (let ([origin
            (findf
              (lambda (header)
                (equal?
                  (symbol->string
                    (car header))
                  "origin"))
              (request-headers req))])
      (if origin
        (cdr origin)
        "https://localhost:8443"))))

; Taken from
; https://docs.racket-lang.org/web-server/http.html#%28def._%28%28lib._web-server%2Fhttp%2Fresponse-structs..rkt%29._response%29%29
(define server
  (lambda (req)
    (displayln
      (parse-request req "\n"))
    (displayln "")
    (response/output
      (lambda (op)
        (write-bytes
          (string->bytes/utf-8
            (parse-request req "<br />"))
          op))
      #:headers (list
                  (header
                    #"Set-Cookie"
                    #"default=default")
                  (header
                    #"Set-Cookie"
                    #"lax=lax; SameSite=Lax")
                  (header
                    #"Set-Cookie"
                    #"strict=strict; SameSite=Strict")
                  (header
                    #"Set-Cookie"
                    #"none=none; SameSite=None; Secure")
                  (header
                    #"Access-Control-Allow-Origin"
                    (string->bytes/utf-8
                      (get-origin req)))
                  (header
                    #"Access-Control-Allow-Credentials"
                    #"true")))))

(serve/servlet server
               #:port 8443
               #:launch-browser? #f
               #:servlet-regexp #rx""
               #:listen-ip "0.0.0.0"
               #:ssl? #t
               #:ssl-cert "ssl-keys/cert.pem"
               #:ssl-key "ssl-keys/key.pem")

