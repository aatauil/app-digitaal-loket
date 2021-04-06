;; Official model from https://data.vlaanderen.be/doc/applicatieprofiel/besluit-subsidie/#Participatie
;; and https://github.com/redpencilio/data.gift/blob/master/data/static/vocabularies/lblodSubsidie

(define-resource subsidy-measure-consumption ()
  :class (s-prefix "subsidie:SubsidiemaatregelConsumptie")
  :has-one `((subsidy-request :via ,(s-prefix "prov:wasGeneratedBy")
                       :as "subsidy-request")
             (subsidy-measure-offer :via ,(s-prefix "transactie:isInstantieVan")
                                       :as "subsidy-measure-offer")
             (subsidy-application-flow :via ,(s-prefix "cpsv:follows")
                                        :as "subsidy-application-flow")
             (subsidy-application-flow-step :via ,(s-prefix "common:active")
                                             :as "active-subsidy-application-flow-step")
             (subsidy-measure-consumption-status :via ,(s-prefix "adms:status")
                     :as "status"))
  :has-many `((participation :via ,(s-prefix "m8g:hasParticipation")
                            :as "participations")
              (application-form :via ,(s-prefix "dct:source")
                                :as "application-forms"))
  :resource-base (s-url "http://data.lblod.info/id/subsidy-measure-consumptions/")
  :features '(include-uri)
  :on-path "subsidy-measure-consumptions")

(define-resource subsidy-measure-consumption-status ()
  ;;subclass of Skos:Concept, because mu-resource has still no ineritance.
  ;; make sure to add skos:Concept too when creating migrations
  :class (s-prefix "lblodSubsidie:SubsidiemaatregelConsumptieStatus")
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :resource-base (s-url "http://data.lblod.info/id/subsidy-measure-consumption-statuses/")
  :features '(include-uri)
  :on-path "subsidy-measure-consumption-statuses")

(define-resource subsidy-request ()
  :class (s-prefix "subsidie:Aanvraag")
  :properties `((:date-of-request :date ,(s-prefix "subsidie:aanvraagdatum")))
  :has-one `((monetary-amount :via ,(s-prefix "subsidie:aangevraagdBedrag")
                                 :as "requested-amount")
             (subsidy-measure-consumption :via ,(s-prefix "prov:generated")
                               :as "subsidy-measure-consumption"))
  :resource-base (s-url "http://data.lblod.info/id/subsidy-requests/")
  :features '(include-uri)
  :on-path "subsidy-requests")

(define-resource monetary-amount ()
  :class (s-prefix "schema:MonetaryAmount")
  :properties `((:value :number ,(s-prefix "schema:value"))
                (:currency :string ,(s-prefix "schema:currency")))
  :resource-base (s-url "http://data.lblod.info/id/monetary-amounts/")
  :features '(include-uri)
  :on-path "monetary-amounts")

(define-resource subsidy-measure-offer ()
  :class (s-prefix "subsidie:SubsidiemaatregelAanbod")
  :properties `((:title :string ,(s-prefix "dct:title")))
  :has-many `((criterion :via ,(s-prefix "m8g:hasCriterion")
                        :as "criteria")
             (subsidy-procedural-step :via ,(s-prefix "cpsv:follows")
                                    :as "subsidy-procedural-steps")
             (subsidy-measure-offer-series :via ,(s-prefix "lblodSubsidie:heeftReeks")
                                             :as "series"))
  :resource-base (s-url "http://lblod.data.info/id/subsidy-measure-offers/")
  :features '(include-uri)
  :on-path "subsidy-measure-offers")

(define-resource subsidy-measure-offer-series ()
  :class (s-prefix "lblodSubsidie:SubsidiemaatregelAanbodReeks")
  :properties `((:title :string ,(s-prefix "dct:title"))
                (:description :string ,(s-prefix "dct:description")))
  :has-one `((subsidy-application-flow :via ,(s-prefix "common:active")
                                        :as "active-application-flow")
             (period-of-time :via ,(s-prefix "mobiliteit:periode")
                      :as "period")
             (subsidy-measure-offer :via ,(s-prefix "lblodSubsidie:heeftReeks")
                                       :inverse t
                                       :as "subsidy-measure-offer"))
  :has-many `((subsidy-procedural-step :via ,(s-prefix "lblodSubsidie:heeftSubsidieprocedurestap")
                                     :as "subsidy-procedural-steps"))
  :resource-base (s-url "http://lblod.data.info/id/subsidy-measure-offer-series/")
  :features '(include-uri)
  :on-path "subsidy-measure-offer-series")

(define-resource subsidy-application-flow ()
  :class (s-prefix "lblodSubsidie:ApplicationFlow")
  :has-one `((subsidy-measure-offer-series :via ,(s-prefix "xkos:belongsTo")
                                             :as "subsidy-measure-offer-series")
             (subsidy-application-flow-step :via ,(s-prefix "xkos:next")
                                             :as "first-application-step"))
  :has-many `((subsidy-application-flow-step :via ,(s-prefix "dct:isPartOf")
                                              :inverse t
                                              :as "defined-steps"))
  :resource-base (s-url "http://lblod.data.info/id/subsidy-application-flows/")
  :on-path "subsidy-application-flows")

(define-resource subsidy-application-flow-step ()
  :class (s-prefix "lblodSubsidie:ApplicationStep")
  :properties `((:order :integer ,(s-prefix "qb:order")))
  :has-one `((file :via ,(s-prefix "dct:source")
                   :as "form-specification")
             (subsidy-procedural-step :via ,(s-prefix "dct:references")
                                    :as "subsidy-procedural-step")
             (subsidy-application-flow :via ,(s-prefix "dct:isPartOf")
                                        :as "application-flow")
             (subsidy-application-flow-step :via ,(s-prefix "xkos:previous")
                                             :as "previous-application-step")
             (subsidy-application-flow-step :via ,(s-prefix "xkos:next")
                                             :as "next-application-step"))
             ;;TODO:add CRITERION, but we need better feeling with the cases we need to support
  :resource-base (s-url "http://lblod.data.info/id/subsidy-application-flow-steps/")
  :on-path "subsidy-application-flow-steps")

(define-resource subsidy-procedural-step ()
  :class (s-prefix "subsidie:Subsidieprocedurestap")
  :properties `((:description :string ,(s-prefix "dct:description"))
                (:type :uri-set ,(s-prefix "subsidie:Subsidieprocedurestap.type")))
  :has-one `((period-of-time :via ,(s-prefix "mobiliteit:periode")
                      :as "period")
             (subsidy-measure-offer-series :via ,(s-prefix "lblodSubsidie:heeftSubsidieprocedurestap")
                                             :inverse t
                                              :as "subsidy-measure-offer-series")
             (subsidy-measure-offer :via ,(s-prefix "cpsv:follows")
                                       :inverse t
                                       :as "subsidy-measure-offer"))
  :resource-base (s-url "http://data.lblod.info/id/subsidy-procedural-steps/")
  :features '(include-uri)
  :on-path "subsidy-procedural-steps")

(define-resource period-of-time ()
  :class (s-prefix "m8g:PeriodOfTime")
  :properties `((:begin :datetime ,(s-prefix "m8g:startTime"))
                (:end :datetime ,(s-prefix "m8g:endTime")))
  :resource-base (s-url "http://data.lblod.info/id/periods-of-time/")
  :features '(include-uri)
  :on-path "periods-of-time")

(define-resource criterion ()
  :class (s-prefix "m8g:Criterion")
  :properties `((:name :string ,(s-prefix "dct:title"))
                (:type :uri-set ,(s-prefix "m8g:criterionType")))
  :has-one `((requirement-group :via ,(s-prefix "m8g:fulfilledByRequirementGroup")
                             :as "requirement-groups")
             (subsidy-procedural-step :via ,(s-prefix "dct:isPartOf")
                                    :as "subsidieprocedurestap"))
  :resource-base (s-url "http://data.lblod.info/id/criteria/")
  :features '(include-uri)
  :on-path "criteria")

(define-resource requirement-group ()
  :class (s-prefix "m8g:RequirementGroup")
  :has-one `((criterion-requirement :via ,(s-prefix "m8g:hasCriterionRequirement")
                             :as "criterion-requirement"))
  :resource-base (s-url "http://data.lblod.info/id/requirement-groups/")
  :features '(include-uri)
  :on-path "requirement-groups")

(define-resource criterion-requirement ()
  :class (s-prefix "m8g:CriterionRequirement")
  :has-one `((period-of-time :via ,(s-prefix "m8g:applicableInPeriodOfTime")
                      :as "applicable-period"))
  :resource-base (s-url "http://data.lblod.info/id/criterion-requirements/")
  :features '(include-uri)
  :on-path "criterion-requirements")


(define-resource participation ()
  :class (s-prefix "m8g:Participation")
  :properties `((:description :string ,(s-prefix "dct:description"))
                (:role :uri-set ,(s-prefix "m8g:role")))
  :has-one `((bestuurseenheid :via ,(s-prefix "m8g:playsRole")
                            :inverse t
                            :as "participating-bestuurseenheid"))
  :resource-base (s-url "http://data.lblod.info/id/participations/")
  :features '(include-uri)
  :on-path "participations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dirty space: per subsidy, custom fields are asked, they are
;; kept here.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-resource application-form ()
  :class (s-prefix "lblodSubsidie:ApplicationForm")
  :properties `((:created :datetime ,(s-prefix "dct:created"))
                (:modified :datetime ,(s-prefix "dct:modified"))
                (:is-collaboration :url ,(s-prefix "lblodSubsidie:isCollaboration"))
                (:total-amount :float ,(s-prefix "lblodSubsidie:totalAmount")))
  :has-one `((subsidy-application-flow-step :via ,(s-prefix "dct:isPartOf")
                                             :as "subsidy-application-flow-step")
             (contact-punt :via ,(s-prefix "schema:contactPoint")
                           :as "contactinfo")
             (bank-account :via ,(s-prefix "schema:bankAccount")
                           :as "bank-account")
             (time-block :via ,(s-prefix "lblodSubsidie:timeBlock")
                         :as "time-block")
             (application-form-table :via ,(s-prefix "lblodSubsidie:applicationFormTable")
                                     :as "application-form-table")
             (engagement-table :via ,(s-prefix "lblodSubsidie:engagementTable")
                                     :as "engagement-table")
             (gebruiker :via ,(s-prefix "ext:lastModifiedBy")
                        :as "last-modifier")
             (gebruiker :via ,(s-prefix "dct:creator")
                        :as "creator")
             (submission-document-status :via ,(s-prefix "adms:status")
                                         :as "status"))
  :has-many `((bestuurseenheid :via ,(s-prefix "lblodSubsidie:collaborator")
                                      :as "collaborators"))
  :resource-base (s-url "http://data.lblod.info/id/application-forms/")
  :features '(include-uri)
  :on-path "application-forms")

(define-resource bank-account ()
  :class (s-prefix "schema:BankAccount")
  :properties `((:bank-account-number :string ,(s-prefix "schema:identifier")))
  :has-one `((file :via ,(s-prefix "dct:hasPart")
                   :as "confirmation-letter"))
  :resource-base (s-url "http://data.lblod.info/id/bank-accounts/")
  :features '(include-uri)
  :on-path "bank-accounts")

;;TODO still needed?
(define-resource time-block () ;; subclass of skos:Concept
  :class (s-prefix "gleif:Period")
  :properties `((:naam :string ,(s-prefix "dct:title"))
                (:label :string ,(s-prefix "skos:prefLabel"))
                (:start :date ,(s-prefix "gleif:hasStart"))
                (:end :date ,(s-prefix "gleif:hasEnd")))
  :has-one `((time-block :via ,(s-prefix "ext:submissionPeriod")
                         :as "submission-period")
             (concept-scheme :via ,(s-prefix "skos:inScheme")
                             :as "concept-scheme"))
  :resource-base (s-url "http://lblod.data.info/id/concepts/")
  :features '(include-uri)
  :on-path "time-blocks")

(define-resource application-form-table ()
  :class (s-prefix "lblodSubsidie:ApplicationFormTable")
  :has-many `((application-form-entry :via ,(s-prefix "ext:applicationFormEntry")
                                      :as "application-form-entries"))
  :resource-base (s-url "http://data.lblod.info/id/application-form-tables/")
  :features '(include-uri)
  :on-path "application-form-tables")

(define-resource application-form-entry ()
  :class (s-prefix "ext:ApplicationFormEntry")
  :properties `((:actor-name :string ,(s-prefix "ext:actorName"))
                (:number-children-for-full-day :number ,(s-prefix "ext:numberChildrenForFullDay"))
                (:number-children-for-half-day :number ,(s-prefix "ext:numberChildrenForHalfDay"))
                (:number-children-per-infrastructure :number ,(s-prefix "ext:numberChildrenPerInfrastructure"))
                (:created :datetime ,(s-prefix "dct:created")))
  :resource-base (s-url "http://data.lblod.info/id/application-form-entries/")
  :features '(include-uri)
  :on-path "application-form-entries")

(define-resource engagement-table ()
  :class (s-prefix "lblodSubsidie:EngagementTable")
  :has-many `((engagement-entry :via ,(s-prefix "ext:engagementEntry")
                                      :as "engagement-entries"))
  :resource-base (s-url "http://data.lblod.info/id/engagement-tables/")
  :features '(include-uri)
  :on-path "engagement-tables")

(define-resource engagement-entry ()
  :class (s-prefix "ext:EngagementEntry")
  :properties `((:target :string ,(s-prefix "ext:target"))
                (:existing-staff :number ,(s-prefix "ext:existingStaff"))
                (:additional-staff :number ,(s-prefix "ext:additionalStaff"))
                (:volunteers :number ,(s-prefix "ext:volunteers"))
                (:estimated-cost :number ,(s-prefix "ext:estimatedCost")))
  :resource-base (s-url "http://data.lblod.info/id/engagement-entries/")
  :features '(include-uri)
  :on-path "engagement-entries")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End Dirty space
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
