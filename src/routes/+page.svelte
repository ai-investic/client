<script>
    import {onMount} from 'svelte';
    import gql from 'graphql-tag';
    import {GraphQLClient} from 'graphql-request';

    const graphQLClient = new GraphQLClient('http://172.17.0.1:5789/graphql');

    let mapContainer;
    let map;
    let currentInfoWindow = null;

    function initMap() {
        const options = {
            center: {lat: 48.8587741, lng: 2.2069771},
            zoom: 10,
        };

        map = new google.maps.Map(mapContainer, options);
    }

    const formatPrice = (priceString) => {
        const price = parseFloat(priceString);

        if (isNaN(price)) {
            throw new Error("Le prix fourni n'est pas un nombre valide.");
        }

        const [integerPart, decimalPart] = price.toFixed(2).split(".");
        const formattedIntegerPart = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, " ");

        return `${formattedIntegerPart}.${decimalPart}`;
    };

    function getPolygonCenter(polygon) {
        let bounds = new google.maps.LatLngBounds();

        polygon.getPath().forEach((point) => {
            bounds.extend(point);
        });

        return bounds.getCenter();
    }

    async function showPolygonInfo(polygon, name_param) {
        if (currentInfoWindow) {
            currentInfoWindow.close();
        }

        const infoWindow = new google.maps.InfoWindow({
            content: `
              <div>
                <h3>${name_param}</h3>
                <p>Traitement en cours...</p>
              </div>
            `,
        });

        currentInfoWindow = infoWindow;

        infoWindow.setPosition(getPolygonCenter(polygon));
        infoWindow.open(map);

        let property_value;
        try {
            const data = await graphQLClient.request(
                gql`
                    query GetCityAvgPropertyValue($municipality: String) {
                      getCityAvgPropertyValue(municipality: $municipality)
                    }
                `,
                {"municipality": name_param},
            );

            property_value = `En moyenne une propriété coûte ${formatPrice(data.getCityAvgPropertyValue)} € dans cette ville.`;
        } catch (error) {
            property_value = "Nous ne possédons pas suffissament de données pour traiter cette ville.";
        }

        const content = `
            <div>
              <h3>${name_param}</h3>
              <p>${property_value}</p>
            </div>
        `;

        infoWindow.setContent(content);
    }


    function addMunicipalityPolygon(coordinates, name_param) {
        const polygon = new google
            .maps
            .Polygon(
                {
                    paths: coordinates,
                    strokeColor: '#FF0000',
                    strokeOpacity: 0.8,
                    strokeWeight: 2,
                    fillColor: '#FF0000',
                    fillOpacity: 0.35,
                }
            )
        ;

        polygon.setMap(map);

        google
            .maps
            .event
            .addListener(
                polygon,
                "click",
                () => showPolygonInfo(
                    polygon,
                    name_param,
                ),
            )
        ;
    }

    onMount(() => {
        if (typeof google !== 'undefined') initMap();

        const deparments = [
            {"numero": "01", "nom": "Ain"},
            {"numero": "02", "nom": "Aisne"},
            {"numero": "03", "nom": "Allier"},
            {"numero": "04", "nom": "Alpes-de-Haute-Provence"},
            {"numero": "05", "nom": "Hautes-Alpes"},
            {"numero": "06", "nom": "Alpes-Maritimes"},
            {"numero": "07", "nom": "Ardèche"},
            {"numero": "08", "nom": "Ardennes"},
            {"numero": "09", "nom": "Ariège"},
            {"numero": "10", "nom": "Aube"},
            {"numero": "11", "nom": "Aude"},
            {"numero": "12", "nom": "Aveyron"},
            {"numero": "13", "nom": "Bouches-du-Rhône"},
            {"numero": "14", "nom": "Calvados"},
            {"numero": "15", "nom": "Cantal"},
            {"numero": "16", "nom": "Charente"},
            {"numero": "17", "nom": "Charente-Maritime"},
            {"numero": "18", "nom": "Cher"},
            {"numero": "19", "nom": "Corrèze"},
            {"numero": "2A", "nom": "Corse-du-Sud"},
            {"numero": "2B", "nom": "Haute-Corse"},
            {"numero": "21", "nom": "Côte-d'Or"},
            {"numero": "22", "nom": "Côtes-d'Armor"},
            {"numero": "23", "nom": "Creuse"},
            {"numero": "24", "nom": "Dordogne"},
            {"numero": "25", "nom": "Doubs"},
            {"numero": "26", "nom": "Drôme"},
            {"numero": "27", "nom": "Eure"},
            {"numero": "28", "nom": "Eure-et-Loir"},
            {"numero": "29", "nom": "Finistère"},
            {"numero": "30", "nom": "Gard"},
            {"numero": "31", "nom": "Haute-Garonne"},
            {"numero": "32", "nom": "Gers"},
            {"numero": "33", "nom": "Gironde"},
            {"numero": "34", "nom": "Hérault"},
            {"numero": "35", "nom": "Ille-et-Vilaine"},
            {"numero": "36", "nom": "Indre"},
            {"numero": "37", "nom": "Indre-et-Loire"},
            {"numero": "38", "nom": "Isère"},
            {"numero": "39", "nom": "Jura"},
            {"numero": "40", "nom": "Landes"},
            {"numero": "41", "nom": "Loir-et-Cher"},
            {"numero": "42", "nom": "Loire"},
            {"numero": "43", "nom": "Haute-Loire"},
            {"numero": "44", "nom": "Loire-Atlantique"},
            {"numero": "45", "nom": "Loiret"},
            {"numero": "46", "nom": "Lot"},
            {"numero": "47", "nom": "Lot-et-Garonne"},
            {"numero": "48", "nom": "Lozère"},
            {"numero": "49", "nom": "Maine-et-Loire"},
            {"numero": "50", "nom": "Manche"},
            {"numero": "51", "nom": "Marne"},
            {"numero": "52", "nom": "Haute-Marne"},
            {"numero": "53", "nom": "Mayenne"},
            {"numero": "54", "nom": "Meurthe-et-Moselle"},
            {"numero": "55", "nom": "Meuse"},
            {"numero": "56", "nom": "Morbihan"},
            {"numero": "57", "nom": "Moselle"},
            {"numero": "58", "nom": "Nièvre"},
            {"numero": "59", "nom": "Nord"},
            {"numero": "60", "nom": "Oise"},
            {"numero": "61", "nom": "Orne"},
            {"numero": "62", "nom": "Pas-de-Calais"},
            {"numero": "63", "nom": "Puy-de-Dôme"},
            {"numero": "64", "nom": "Pyrénées-Atlantiques"},
            {"numero": "65", "nom": "Hautes-Pyrénées"},
            {"numero": "66", "nom": "Pyrénées-Orientales"},
            {"numero": "67", "nom": "Bas-Rhin"},
            {"numero": "68", "nom": "Haut-Rhin"},
            {"numero": "69", "nom": "Rhône"},
            {"numero": "70", "nom": "Haute-Saône"},
            {"numero": "71", "nom": "Saône-et-Loire"},
            {"numero": "72", "nom": "Sarthe"},
            {"numero": "73", "nom": "Savoie"},
            {"numero": "74", "nom": "Haute-Savoie"},
            {"numero": "75", "nom": "Paris"},
            {"numero": "76", "nom": "Seine-Maritime"},
            {"numero": "77", "nom": "Seine-et-Marne"},
            {"numero": "78", "nom": "Yvelines"},
            {"numero": "79", "nom": "Deux-Sèvres"},
            {"numero": "80", "nom": "Somme"},
            {"numero": "81", "nom": "Tarn"},
            {"numero": "82", "nom": "Tarn-et-Garonne"},
            {"numero": "83", "nom": "Var"},
            {"numero": "84", "nom": "Vaucluse"},
            {"numero": "85", "nom": "Vendée"},
            {"numero": "86", "nom": "Vienne"},
            {"numero": "87", "nom": "Haute-Vienne"},
            {"numero": "88", "nom": "Vosges"},
            {"numero": "89", "nom": "Yonne"},
            {"numero": "90", "nom": "Territoire de Belfort"},
            {"numero": "91", "nom": "Essonne"},
            {"numero": "92", "nom": "Hauts-de-Seine"},
            {"numero": "93", "nom": "Seine-Saint-Denis"},
            {"numero": "94", "nom": "Val-de-Marne"},
            {"numero": "95", "nom": "Val-d'Oise"},
            {"numero": "971", "nom": "Guadeloupe"},
            {"numero": "972", "nom": "Martinique"},
            {"numero": "973", "nom": "Guyane"},
            {"numero": "974", "nom": "La Réunion"},
            {"numero": "976", "nom": "Mayotte"}
        ]

        async function processElements() {
            for (const department of deparments) {
                await graphQLClient
                    .request(
                        gql`
                          query MunicipalitiesByDep($dep: String!) {
                            municipalitiesByDep(dep: $dep) {
                              name
                              geometry {
                                type
                                coordinates
                              }
                            }
                          }
                        `,
                        {"dep": department.numero},
                    )
                    .then(data => {
                        for (const municipality of data.municipalitiesByDep) {
                            const geometryType = municipality.geometry.type;
                            const coordinates = municipality.geometry.coordinates;
                            console.log(municipality)
                            if (geometryType === "Polygon") {
                                addMunicipalityPolygon(
                                    coordinates[0].map(([lng, lat]) => ({lat, lng})),
                                    municipality.name,
                                );
                            } else if (geometryType === "MultiPolygon") {
                                coordinates.forEach(polygonCoordinates => {
                                    addMunicipalityPolygon(
                                        polygonCoordinates[0].map(([lng, lat]) => ({lat, lng})),
                                        municipality.name,
                                    );
                                });
                            }
                        }
                    })
                    .catch(error => {
                        console.log(error);
                        throw error;
                    })
                ;
            }
        }

        processElements();

    });
</script>

<div class="map-container" bind:this={mapContainer}></div>

<style>
    .map-container {
        width: 100%;
        min-height: 98vh;
    }
</style>
