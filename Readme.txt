
Sample Attacks:
    1. CSRF attack with hidden XHR script
        Steps:
            a. Start vulnerable server:
                `racket vulnerable-site.rkt`
            b. Start server that hosts malicious html pages
                `python3 -m http.server`
            c. Open 'hidden-xhr-post.html'
                http://localhost:8000/hidden-xhr-post.html
                    (Or 'hidden-xhr-get.html')
            d. Confirm POST occurred in logs of 'vulnerable-site.rkt'
        Analysis:
            This attack is nice because once the victim opens the malicious
            page, it does not require any additional clicks from the user
            and the malicious request is made without the user's knowledge.
            This attack however relies on the vulnerable site to use a
            session cookie that has the SameSite attribute set to 'None'.
            If the vulnerable site makes updates to server state with GET
            requests, this attack cannot capitalize on that misconfiguration.
    2. CSRF attack with automatic form submission
        Steps:
            a. Start vulnerable server:
                `racket vulnerable-site.rkt`
            b. Start server that hosts malicious html pages
                `python3 -m http.server`
            c. Open 'auto-form-post.html'
                http://localhost:8000/auto-form-post.html
                    (Or 'auto-form-get.html')
            d. View request details once redirected to vulnerable site
        Analysis:
            This attack is nice because once the victim opens the malicious
            page, it does not require any additional clicks from the user.
            However, the user will realize that they have been redirected
            to the vulnerable site. Also, this attack relies on the
            vulnerable site to use a session cookie that has the SameSite
            attribute set to 'None'.
            When automatically making a POST request, only cookies that
            have set the SameSite attribute to 'None' and cookies that
            have not set the SameSite attribute and that were created
            within the last 2 minutes (see "Lax + Post" below) are sent.
            When automatically making a GET request, only cookies that
            have set the SameSite attribute to 'None' or 'Lax' and
            cookies that have not set the SameSite attribute and that
            were not created within the last 2 minutes are sent.
            This attack sends over additional cookies during a GET
            request as compared to a POST request; thus, if the
            vulnerable site makes updates to server state with GET
            requests, then this attack can capitalize on that
            misconfiguration.
    3. CORS attack
        Steps:
            a. Start vulnerable server:
                `racket vulnerable-site.rkt`
            b. Start server that hosts malicious html pages
                `python3 -m http.server`
            c. Open 'cors.html'
                http://localhost:8000/cors.html
            d. View the response from the vulnerable site on the
                'cors.html' page
        Analysis:
            This attack seems as though it may be pretty rare since
            it requires the vulnerable site to allow any domain to
            make cross origin requests.
            When making a CORS request, only the cookies that have
            set the SameSite attribute to 'None' are sent. This likely
            isn't an issue because if an application is set up to
            accept CORS requests, it likely also uses cookies that
            set the SameSite attribute to 'None'.

Notes:
    * Generating self-signed SSL certs for the Racket webserver
        See: https://stackoverflow.com/a/10176685/5832619
        Command to run:
        ```
        openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -nodes
        ```
    * Really no point to do a redirect post for a CSRF attack,
        since the same effect can be achieved with zero additional clicks
            See: https://portswigger.net/web-security/csrf
    * When loading an iframe, the browser only sends over cookies that
        set the SameSite attribute to 'None'.
            See: https://stackoverflow.com/a/66682802/5832619

Resources:
    * Portswigger
        - https://portswigger.net/web-security/cors
        - https://portswigger.net/web-security/csrf
    * https://github.com/johnnyodonnell/simple-https-server
    * https://github.com/johnnyodonnell/redirect-post
    * https://www.chromium.org/updates/same-site/faq/
        Contains interesting information about the "Lax + POST" mitigation
    * https://github.com/whatwg/fetch/issues/769

