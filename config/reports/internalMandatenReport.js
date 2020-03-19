import {generateReportFromData, batchedQuery} from '../helpers.js';


export default {
  cronPattern: '0 0 4 * * 6',
  name: 'internalMandatenReport',
  execute: async () => {
    const reportData = {
      title: 'Internal Mandaten Report',
      description: 'Internal Mandaten Report',
      filePrefix: 'internalMandatenReport'
    };
    console.log('Generate Internal Mandaten Report');

    const queryStringPart1 = `
      PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
      PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
      PREFIX persoon: <http://data.vlaanderen.be/ns/persoon#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX org: <http://www.w3.org/ns/org#>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
      PREFIX regorg: <https://www.w3.org/ns/regorg#>

      SELECT DISTINCT (?s AS ?mandataris) ?start ?eind ?rangorde ?status WHERE {
        ?s a mandaat:Mandataris .
        OPTIONAL { ?s mandaat:start ?start . }
        OPTIONAL { ?s mandaat:einde ?eind . }
        OPTIONAL { ?s mandaat:rangorde ?rangorde . }
        OPTIONAL { ?s mandaat:status ?status . }

      }
    `;

    const queryResponsePart1 = await batchedQuery(queryStringPart1);
    const dataPart1 = queryResponsePart1.results.bindings.reduce( (acc, row) => {
      acc[getSafeValue(row, 'mandataris')] = {
        mandataris: getSafeValue(row, 'mandataris'),
        start: getSafeValue(row, 'start'),
        eind: getSafeValue(row, 'eind'),
        rangorde: getSafeValue(row, 'rangorde'),
        status: getSafeValue(row, 'status'),
        voornaam: getSafeValue(row, 'voornaam'),
        achternaam: getSafeValue(row, 'achternaam'),
        roepnaam: getSafeValue(row, 'roepnaam'),
        geslacht: getSafeValue(row, 'geslacht'),
        geboortedatum: getSafeValue(row, 'geboortedatum')
      };
      return acc;
    }, {});

    const queryStringPart2 = `
      PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
      PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
      PREFIX persoon: <http://data.vlaanderen.be/ns/persoon#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX org: <http://www.w3.org/ns/org#>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
      PREFIX regorg: <https://www.w3.org/ns/regorg#>
      SELECT DISTINCT (?s AS ?mandataris) ?voornaam ?achternaam ?roepnaam ?geslacht ?geboortedatum WHERE {
        ?s a mandaat:Mandataris .
        OPTIONAL {
          ?s mandaat:isBestuurlijkeAliasVan ?persoon .
          OPTIONAL { ?persoon foaf:familyName ?achternaam . }
          OPTIONAL { ?persoon persoon:gebruikteVoornaam ?voornaam . }
          OPTIONAL { ?persoon foaf:name ?roepnaam . }
          OPTIONAL { ?persoon persoon:geslacht ?geslacht }
          OPTIONAL { ?persoon persoon:heeftGeboorte/persoon:datum ?geboortedatum }
        }
      }
    `

    const queryResponsePart2 = await batchedQuery(queryStringPart2);
    const dataPart2 = queryResponsePart2.results.bindings.reduce( (acc, row) => {
      let dataPart = {
        mandataris: getSafeValue(row, 'mandataris'),
        voornaam: getSafeValue(row, 'voornaam'),
        achternaam: getSafeValue(row, 'achternaam'),
        roepnaam: getSafeValue(row, 'roepnaam'),
        geslacht: getSafeValue(row, 'geslacht'),
        geboortedatum: getSafeValue(row, 'geboortedatum')
      };
      acc[getSafeValue(row, 'mandataris')] = Object.assign(dataPart, dataPart1[getSafeValue(row, 'mandataris')]);
      return acc;
    }, {});

    const queryStringPart3 = `
      PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
      PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
      PREFIX persoon: <http://data.vlaanderen.be/ns/persoon#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX org: <http://www.w3.org/ns/org#>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
      PREFIX regorg: <https://www.w3.org/ns/regorg#>

      SELECT DISTINCT (?s AS ?mandataris) ?bestuursfunctieLabel ?bestuursorgaanLabel ?bestuursorgaanClassificatieLabel ?bestuurseenheidLabel ?bestuurseenheidClassificatieLabel ?werkingsgebiedLabel ?werkingsgebiedNiveau WHERE {
        ?s a mandaat:Mandataris .

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
      }
    `;
    const queryResponsePart3 = await batchedQuery(queryStringPart3);

    const dataPart3 = queryResponsePart3.results.bindings.reduce( (acc, row) => {
      let dataPart = {
        bestuursfunctieLabel: getSafeValue(row, 'bestuursfunctieLabel'),
        bestuursorgaanLabel: getSafeValue(row, 'bestuursorgaanLabel'),
        bestuursorgaanClassificatieLabel: getSafeValue( row, 'bestuursorgaanClassificatieLabel'),
        bestuurseenheidLabel: getSafeValue(row, 'bestuurseenheidLabel'),
        bestuurseenheidClassificatieLabel: getSafeValue(row, 'bestuurseenheidClassificatieLabel'),
        werkingsgebiedLabel: getSafeValue(row, 'werkingsgebiedLabel'),
        werkingsgebiedNiveau: getSafeValue(row, 'werkingsgebiedNiveau')
      };
      acc[getSafeValue(row, 'mandataris')] = Object.assign(dataPart, dataPart2[getSafeValue(row, 'mandataris')]);
      return acc;
    }, {});


    const queryStringPart4 = `
      PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
      PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
      PREFIX persoon: <http://data.vlaanderen.be/ns/persoon#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX org: <http://www.w3.org/ns/org#>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
      PREFIX regorg: <https://www.w3.org/ns/regorg#>

      SELECT DISTINCT (?s AS ?mandataris) ?fractieNaam WHERE {
        ?s a mandaat:Mandataris .

        OPTIONAL {
          ?s org:hasMembership/org:organisation ?fractie .
          OPTIONAL { ?fractie regorg:legalName ?fractieNaam . }
        }
      }
    `;

  const queryResponsePart4 = await batchedQuery(queryStringPart4);
    const dataPart4 = queryResponsePart4.results.bindings.reduce( (acc, row) => {
      let dataPart = {
        fractieNaam: getSafeValue(row, 'fractieNaam')
      };
      acc[getSafeValue(row, 'mandataris')] = Object.assign(dataPart, dataPart3[getSafeValue(row, 'mandataris')]);
      return acc;
    }, {});

    await generateReportFromData(Object.values(dataPart4), [
      'mandataris', 'start', 'eind', 'rangorde', 'status', 'voornaam', 'achternaam', 'roepnaam',
      'bestuursfunctieLabel', 'bestuursorgaanLabel', 'bestuursorgaanClassificatieLabel', 'bestuurseenheidLabel',
      'bestuurseenheidClassificatieLabel', 'werkingsgebiedLabel', 'werkingsgebiedNiveau', 'fractieNaam', 'geslacht',
      'geboortedatum'
    ], reportData);
  }
};

function getSafeValue(entry, property){
  return entry[property] ? entry[property].value: null;
}
