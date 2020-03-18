import {generateReportFromData, batchedQuery} from '../helpers.js';
import { querySudo as query } from '@lblod/mu-auth-sudo';

export default {
  cronPattern: '0 15 22 * * 6',
  name: 'internalMandatenReport',
  execute: async () => {
    const reportData = {
      title: 'Internal Mandaten Report',
      description: 'Internal Mandaten Report',
      filePrefix: 'internalMandatenReport'
    };
    console.log('Generate Internal Mandaten Report');
    const queryString = `
      PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
      PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
      PREFIX persoon: <http://data.vlaanderen.be/ns/persoon#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX org: <http://www.w3.org/ns/org#>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
      PREFIX regorg: <https://www.w3.org/ns/regorg#>
      
      SELECT DISTINCT (?s AS ?mandataris) ?start ?eind ?rangorde ?status ?voornaam ?achternaam ?roepnaam ?bestuursfunctieLabel ?bestuursorgaanLabel ?bestuursorgaanClassificatieLabel ?bestuurseenheidLabel ?bestuurseenheidClassificatieLabel ?werkingsgebiedLabel ?werkingsgebiedNiveau ?fractieNaam ?geslacht ?geboortedatum WHERE {
        ?s a mandaat:Mandataris .
        OPTIONAL { ?s mandaat:start ?start . }
        OPTIONAL { ?s mandaat:einde ?eind . }
        OPTIONAL { ?s mandaat:rangorde ?rangorde . }
        OPTIONAL { ?s mandaat:status ?status . }
      
      
        OPTIONAL {
          ?s mandaat:isBestuurlijkeAliasVan ?persoon .
          OPTIONAL { ?persoon foaf:familyName ?achternaam . }
          OPTIONAL { ?persoon persoon:gebruikteVoornaam ?voornaam . }
          OPTIONAL { ?persoon foaf:name ?roepnaam . }
          OPTIONAL { ?persoon persoon:geslacht ?geslacht }
          OPTIONAL { ?persoon persoon:heeftGeboorte/persoon:datum ?geboortedatum }
        }
      
        OPTIONAL {
          ?s org:holds ?mandaat .
          OPTIONAL {
            ?mandaat org:role ?bestuursfunctie .
            OPTIONAL { ?bestuursfunctie skos:prefLabel ?bestuursfunctieLabel . }
          }
      
          OPTIONAL {
            ?mandaat ^org:hasPost ?bestuursorgaanInTijd .
            ?bestuursorgaanInTijd mandaat:isTijdspecialisatieVan ?bestuursorgaan .
            OPTIONAL { ?bestuursorgaan skos:prefLabel ?bestuursorgaanLabel . }
            OPTIONAL {
              ?bestuursorgaan besluit:classificatie ?bestuursorgaanClassificatie .
              OPTIONAL { ?bestuursorgaanClassificatie skos:prefLabel ?bestuursorgaanClassificatieLabel }
            }
      
            OPTIONAL {
              ?bestuursorgaan besluit:bestuurt ?bestuurseenheid .
              OPTIONAL { ?bestuurseenheid skos:prefLabel ?bestuurseenheidLabel . }
              OPTIONAL {
                ?bestuurseenheid besluit:classificatie ?bestuurseenheidClassificatie .
                OPTIONAL { ?bestuurseenheidClassificatie skos:prefLabel ?bestuurseenheidClassificatieLabel . }
              }
              OPTIONAL {
                ?bestuurseenheid besluit:werkingsgebied ?werkingsgebied .
                OPTIONAL { ?werkingsgebied rdfs:label ?werkingsgebiedLabel . }
                OPTIONAL { ?werkingsgebied ext:werkingsgebiedNiveau ?werkingsgebiedNiveau . }
              }
            }
          }
        }
      
        OPTIONAL {
          ?s org:hasMembership/org:organisation ?fractie .
          OPTIONAL { ?fractie regorg:legalName ?fractieNaam . }
        }
      
        OPTIONAL {
          ?s mandaat:beleidsdomein ?beleids .
          OPTIONAL { ?beleids skos:prefLabel ?beleidsdomeinLabel . }
          BIND(CONCAT(?beleidsdomeinLabel, " (", STR(?beleids), ")") as ?beleidsdomein)
        }
      } 
    `;
    const queryResponse = await batchedQuery(queryString);
    const data = queryResponse.results.bindings.map((row) => {
      return {
        mandataris: row.mandataris.value,
        start: row.start.value,
        eind: row.eind.value,
        rangorde: row.rangorde.value,
        status: row.status.value,
        voornaam: row.voornaam.value,
        achternaam: row.achternaam.value,
        roepnaam: row.roepnaam.value,
        bestuursfunctieLabel: row.bestuursfunctieLabel.value,
        bestuursorgaanLabel: row.bestuursorgaanLabel.value,
        bestuursorgaanClassificatieLabel: row.bestuursorgaanClassificatieLabel.value,
        bestuurseenheidLabel: row.bestuurseenheidLabel.value,
        bestuurseenheidClassificatieLabel: row.bestuurseenheidClassificatieLabel.value,
        werkingsgebiedLabel: row.werkingsgebiedLabel.value,
        werkingsgebiedNiveau: row.werkingsgebiedNiveau.value,
        fractieNaam: row.fractieNaam.value,
        geslacht: row.geslacht.value,
        geboortedatum: row.geboortedatum.value,
      };
    });
    await generateReportFromData(data, [
      'mandataris', 'start', 'eind', 'rangorde', 'status', 'voornaam', 'achternaam', 'roepnaam', 
      'bestuursfunctieLabel', 'bestuursorgaanLabel', 'bestuursorgaanClassificatieLabel', 'bestuurseenheidLabel',
      'bestuurseenheidClassificatieLabel', 'werkingsgebiedLabel', 'werkingsgebiedNiveau', 'fractieNaam', 'geslacht',
      'geboortedatum'
    ], reportData);
  }
};
