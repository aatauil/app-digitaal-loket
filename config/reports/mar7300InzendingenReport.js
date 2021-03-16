import {generateReportFromData} from '../helpers.js';
import { querySudo as query } from '@lblod/mu-auth-sudo';

export default {
  cronPattern: '0 0 23 * * *',
  name: 'mar7300InzendingenReport',
  execute: async () => {
    const reportData = {
      title: 'Inzendingen of type MAR7300',
      description: 'Information about inzendingen of type MAR7300',
      filePrefix: 'mar7300-inzendingen'
    };
    console.log('Generate MAR7300 Inzendingen Report');

    const queryString = `
      PREFIX toezicht: <http://mu.semte.ch/vocabularies/ext/supervision/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX nmo: <http://www.semanticdesktop.org/ontologies/2007/03/22/nmo#>
      PREFIX dct: <http://purl.org/dc/terms/>
      PREFIX prov: <http://www.w3.org/ns/prov#>
      PREFIX eli: <http://data.europa.eu/eli/ontology#>
      PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX lblodBesluit: <http://lblod.data.gift/vocabularies/besluit/>
      PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
      PREFIX nie: <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#>
      PREFIX nfo: <http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#>

      select ?sessionDate ?sentDate ?bestuursorgaan ?dateOfEntryInForce ?datePublication ?dateNoLongerInForce ?dateSessionStartedAtTime ?attachmentName ?hasAdditionalTaxRate ?taxRateAmount ?inzending where {
        GRAPH ?g {
          ?inzending a toezicht:InzendingVoorToezicht ;
            toezicht:nomenclature <http://data.lblod.info/Nomenclature/0ce2d45f1bb5414e7cd4d9de7929097e7278260434ded0b16d336bb407e9f0ec> ;
            toezicht:decisionType <http://data.lblod.info/DecisionType/5b3955cc006323233e711c482f3a6bf39a8d3eba6bbdb2c672bdfcf2b2985b03> ;
            toezicht:regulationType <http://data.lblod.info/RegulationType/ef35b053c004a25069c58090d967ade753dd02586b0f76b916a0ca82b7294d0b> ;
            toezicht:sessionDate ?sessionDate;
            nmo:sentDate ?sentDate.
          ?submission dct:source ?inzending ;
            prov:generated ?form .
          ?form eli:passed_by ?orgaanInTijd ;
            eli:first_date_entry_in_force ?dateOfEntryInForce ;
            eli:date_no_longer_in_force ?dateNoLongerInForce ;
            ext:sessionStartedAtTime ?dateSessionStartedAtTime ;
            dct:hasPart ?attachment .

          OPTIONAL { ?form eli:date_publication ?datePublication . }
          OPTIONAL { ?form ext:taxRateAmount ?taxRateAmount . }
          OPTIONAL { ?form lblodBesluit:hasAdditionalTaxRate ?hasAdditionalTaxRate . }
        }
        GRAPH ?h {
          ?orgaanInTijd mandaat:isTijdspecialisatieVan/skos:prefLabel ?bestuursorgaan .
        }
        GRAPH ?i {
          ?attachment nie:url|nfo:fileName ?attachmentName .
        }
      }
      ORDER BY DESC(?sentDate)
    `;
    const queryResponse = await query(queryString);
    const data = queryResponse.results.bindings.map((inzendingen) => ({
      sessionDate: inzendingen.sessionDate.value,
      sentDate: inzendingen.sentDate.value,
      bestuursorgaan: inzendingen.bestuursorgaan.value,
      dateOfEntryInForce: inzendingen.dateOfEntryInForce.value,
      datePublication: inzendingen.datePublication.value,
      dateNoLongerInForce: inzendingen.dateNoLongerInForce.value,
      dateSessionStartedAtTime: inzendingen.dateSessionStartedAtTime.value,
      attachmentName: inzendingen.attachmentName.value,
      hasAdditionalTaxRate: inzendingen.hasAdditionalTaxRate ? inzendingen.hasAdditionalTaxRate.value : '',
      taxRateAmount: inzendingen.taxRateAmount ? inzendingen.taxRateAmount.value : ''
    }));
    await generateReportFromData(data, [
      'sessionDate',
      'sentDate',
      'bestuursorgaan',
      'dateOfEntryInForce',
      'datePublication',
      'dateNoLongerInForce',
      'dateSessionStartedAtTime',
      'attachmentName',
      'hasAdditionalTaxRate',
      'taxRateAmount'
    ], reportData);
  }
};

