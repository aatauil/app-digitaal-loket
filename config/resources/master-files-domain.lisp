(define-resource document-status ()
  :class (s-prefix "ext:DocumentStatus")
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :resource-base (s-url "http://data.lblod.info/document-statuses/")
  :features `(no-pagination-defaults include-uri)
  :on-path "document-statuses")

(define-resource file ()
  :class (s-prefix "nfo:FileDataObject")
  :properties `((:filename :string ,(s-prefix "nfo:fileName"))
                (:format :string ,(s-prefix "dct:format"))
                (:size :number ,(s-prefix "nfo:fileSize"))
                (:extension :string ,(s-prefix "dbpedia:fileExtension"))
                (:created :datetime ,(s-prefix "nfo:fileCreated")))
  :has-one `((file :via ,(s-prefix "nie:dataSource")
                   :inverse t
                   :as "download")
              (file-address :via ,(s-prefix "nie:dataSource")
                            :as "data-source")
              (data-container :via ,(s-prefix "task:hasFile")
                              :inverse t
                              :as "data-container")
              (email :via ,(s-prefix "email:hasEmail")
                  :as "email"))
  :resource-base (s-url "http://data.lblod.info/files/")
  :features `(no-pagination-defaults include-uri)
  :on-path "files")

(define-resource file-address ()
  :class (s-prefix "ext:FileAddress")
  :properties `((:address :url ,(s-prefix "ext:fileAddress")))
  :has-one `(
              (file :via ,(s-prefix "nie:dataSource")
                    :inverse t
                    :as "replicated-file"))
  :resource-base (s-url "http://data.lblod.info/file-addresses/")
  :features `(no-pagination-defaults include-uri)
  :on-path "file-addresses")

(define-resource remote-url ()
 :class (s-prefix "nfo:RemoteDataObject")
 :properties `((:address :url ,(s-prefix "nie:url"))
               (:created :datetime ,(s-prefix "dct:created"))
               (:modified :datetime ,(s-prefix "dct:modified"))
               (:download-status :url ,(s-prefix "adms:status"))
               (:creator :url ,(s-prefix "dct:creator"))
               )
 :has-one `(
   (file :via ,(s-prefix "nie:dataSource")
                  :inverse t
                  :as "download")
                  )
 :resource-base (s-url "http://lblod.data.gift/id/remote-urls/")
 :features `(include-uri)
 :on-path "remote-urls")

  ;; TODO: remote-url & remote-data-object are actually the same thing but they have slight differences as remote-data-object is used in harvester-frontend
  ;;       assess need for merging these 2 using remote-url as name and changing all models that use remote-data-object naming

(define-resource remote-data-object ()
  :class (s-prefix "nfo:RemoteDataObject")
  :properties `((:source :url ,(s-prefix "nie:url"))
                (:created :datetime ,(s-prefix "dct:created"))
                (:modified :datetime ,(s-prefix "dct:modified"))
                (:request-header :url ,(s-prefix "rpioHttp:requestHeader"))
                (:status :url ,(s-prefix "adms:status"))
                (:creator :url ,(s-prefix "dct:creator")))
  :has-one `((file :via ,(s-prefix "nie:dataSource")
              :inverse t
              :as "file")
            (harvesting-collection :via ,(s-prefix "dct:hasPart")
              :inverse t
              :as "harvesting-collection"))
  :resource-base (s-url "http://data.lblod.info/id/remote-data-objects/")
  :features `(include-uri)
  :on-path "remote-data-objects")