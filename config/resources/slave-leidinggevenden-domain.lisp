;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LEIDINGGEVENDEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; this is a shared domain file, maintained in https://github.com/lblod/domain-files
(define-resource bestuursfunctie ()
  :class (s-prefix "lblodlg:Bestuursfunctie")
  :has-one `((bestuursfunctie-code :via ,(s-prefix "org:role")
                                   :as "rol")
             (contact-punt :via ,(s-prefix "schema:contactPoint")
                           :as "contactinfo"))
  :has-many `((bestuursorgaan :via ,(s-prefix "lblodlg:heeftBestuursfunctie")
                             :inverse t
                             :as "bevat-in"))
  :resource-base (s-url "http://data.lblod.info/id/bestuursfuncties/")
  :features '(include-uri)
  :on-path "bestuursfuncties")

(define-resource functionaris ()
  :class (s-prefix "lblodlg:Functionaris")
  :properties `((:start :datetime ,(s-prefix "mandaat:start"))
                (:einde :datetime ,(s-prefix "mandaat:einde")))
  :has-one `((bestuursfunctie :via ,(s-prefix "org:holds")
                              :as "bekleedt")
             (functionaris-status-code :via ,(s-prefix "mandaat:status")
                                     :as "status")
             (persoon :via ,(s-prefix "mandaat:isBestuurlijkeAliasVan")
                      :as "is-bestuurlijke-alias-van"))
  :resource-base (s-url "http://data.lbod.info/id/functionarissen/")
  :features '(include-uri)
  :on-path "functionarissen")

(define-resource contact-punt ()
  :class (s-prefix "schema:ContactPoint")
  :properties `((:aanschrijfprefix :language-string-set ,(s-prefix "vcard:honorific-prefix"))
                (:email :string ,(s-prefix "schema:email"))
                (:fax :string ,(s-prefix "schema:faxNumber"))
                (:naam :string ,(s-prefix "foaf:name"))
                (:website :url ,(s-prefix "foaf:page"))
                (:telefoon :string ,(s-prefix "schema:telephone")))
  :has-one `((adres :via ,(s-prefix "locn:address")
                 :as "adres"))
  :features '(include-uri)
  :resource-base (s-url "http://data.lbod.info/id/contact-punten/")
:on-path "contact-punten")

(define-resource adres ()
  :class (s-prefix "locn:Address")
  :properties `((:busnummer :string ,(s-prefix "adres:Adresvoorstelling.huisnummer"))
                (:huisnummer-suffix :string ,(s-prefix "adres:AdresVoorstelling.busnummer"))
                (:straatnaam :language-string-set ,(s-prefix "locn:thoroughfare"))
                (:postcode :string ,(s-prefix "locn:postCode"))
                (:gemeentenaam :language-string-set ,(s-prefix "adres:gemeentenaam"))
                (:land :language-string-set ,(s-prefix "adres:land"))
                (:locatieaanduiding :string ,(s-prefix "locn:locatorDesignator"))
                (:locatienaam :language-string-set ,(s-prefix "locn:locatorName"))
                (:postbus :string ,(s-prefix "locn:poBox"))
                (:postnaam :string ,(s-prefix "locn:postName"))
                (:volledig-adres :language-string-set ,(s-prefix "locn:fullAddress"))
                (:adres-register-id :number ,(s-prefix "lblodlg:adresRegisterId"))
                (:adres-register-uri :url ,(s-prefix "lblodlg:adresRegisterUri")))
  :features '(include-uri)
  :resource-base (s-url "http://data.lbod.info/id/adressen/")
  :on-path "adressen")

(define-resource functionaris-status-code ()
  :class (s-prefix "lblodlg:FunctionarisStatusCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/functionarisStatusCode/")
  :features '(include-uri)
  :on-path "functionaris-status-codes")
