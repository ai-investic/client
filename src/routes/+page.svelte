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

    const formatNumber = (priceString) => {
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

        let content;
        try {
            const data = await graphQLClient.request(
                gql`
                    query GetCityPropertyStats($municipality: String) {
                          getCityPropertyStats(municipality: $municipality) {
                                Appartement {
                                      avgPrice
                                      avgRooms
                                      avgBuiltArea
                                      avgLandArea
                                      maxPrice
                                      maxRooms
                                      maxBuiltArea
                                      maxLandArea
                                      minPrice
                                      minRooms
                                      minBuiltArea
                                      minLandArea
                                }
                                land {
                                      avgPrice
                                      avgRooms
                                      avgBuiltArea
                                      avgLandArea
                                      maxPrice
                                      maxRooms
                                      maxBuiltArea
                                      maxLandArea
                                      minPrice
                                      minRooms
                                      minBuiltArea
                                      minLandArea
                                }
                                Maison {
                                      avgPrice
                                      avgRooms
                                      avgBuiltArea
                                      avgLandArea
                                      maxPrice
                                      maxRooms
                                      maxBuiltArea
                                      maxLandArea
                                      minPrice
                                      minRooms
                                      minBuiltArea
                                      minLandArea
                                }
                          }
                    }
                `,
                {"municipality": name_param},
            );

            const propertyStats = data.getCityPropertyStats;

            content = `
                  <div>
                        <h3>${name_param}</h3>
                        <h4>Appartement</h4>
                        <h5>Moyenne</h5>
                        <span>
                            Le prix moyen d'un appartement à ${name_param} est de ${formatNumber(propertyStats.Appartement.avgPrice)}€.
                            Il possède en moyenne ${formatNumber(propertyStats.Appartement.avgRooms)} pièces principales pour une surface de
                            ${formatNumber(propertyStats.Appartement.avgBuiltArea)} m2 et un terrain de ${formatNumber(propertyStats.Appartement.avgLandArea)} m2.
                        </span>
                        <h5>Le plus cher</h5>
                        <span>
                            L'appartement le plus cher de ${name_param} est de ${formatNumber(propertyStats.Appartement.maxPrice)} €.
                            Il possède en moyenne ${formatNumber(propertyStats.Appartement.maxRooms)} pièces principales pour une surface de
                            ${formatNumber(propertyStats.Appartement.maxBuiltArea)} m2 et un terrain de ${formatNumber(propertyStats.Appartement.maxLandArea)} m2.
                        </span>
                        <h5>Le moins cher</h5>
                        <span>
                            L'appartement le moins cher de ${name_param} est de  ${formatNumber(propertyStats.Appartement.minPrice)} €.
                            Il possède en moyenne ${formatNumber(propertyStats.Appartement.minRooms)} pièces principales pour une surface de
                            ${formatNumber(propertyStats.Appartement.minBuiltArea)} m2 et un terrain de ${formatNumber(propertyStats.Appartement.minLandArea)} m2.
                        </span>
                        <h4>Maison</h4>
                        <h5>Moyenne</h5>
                        <span>
                            Le prix moyen d'une maison à ${name_param} est de ${formatNumber(formatNumber(propertyStats.Maison.avgPrice))}€.
                            Elle possède en moyenne ${formatNumber(propertyStats.Maison.avgRooms)} pièces principales pour une surface de
                            ${formatNumber(propertyStats.Maison.avgBuiltArea)} m2 et un terrain de ${formatNumber(propertyStats.Maison.avgLandArea)} m2.
                        </span>
                        <h5>Le plus cher</h5>
                        <span>
                            La maison la plus chère de ${name_param} est de ${formatNumber(formatNumber(propertyStats.Maison.maxPrice))} €.
                            Elle possède en moyenne ${formatNumber(propertyStats.Maison.maxRooms)} pièces principales pour une surface de
                            ${formatNumber(propertyStats.Maison.maxBuiltArea)} m2 et un terrain de ${formatNumber(propertyStats.Maison.maxLandArea)} m2.
                        </span>
                        <h5>Le moins cher</h5>
                        <span>
                            La maison la moins chère de ${name_param} est de  ${formatNumber(propertyStats.Maison.minPrice)} €.
                            Il possède en moyenne ${formatNumber(propertyStats.Maison.minRooms)} pièces principales pour une surface de
                            ${formatNumber(propertyStats.Maison.minBuiltArea)} m2 et un terrain de ${formatNumber(propertyStats.Maison.minLandArea)} m2.
                        </span>
                        <h4>Terrain</h4>
                        <h5>Moyenne</h5>
                        <span>
                            Le prix moyen d'un terrain à ${name_param} est de ${formatNumber(propertyStats.land.avgPrice)}€
                            pour une surface de ${formatNumber(propertyStats.land.avgLandArea)} m2.
                        </span>
                        <h5>Le plus cher</h5>
                        <span>
                            Le terrain le plus cher de ${name_param} est de ${formatNumber(propertyStats.land.maxPrice)} €.
                            pour une surface de ${formatNumber(propertyStats.land.maxLandArea)} m2.
                        </span>
                        <h5>Le moins cher</h5>
                        <span>
                            Le terrain le moins cher de ${name_param} est de  ${formatNumber(propertyStats.land.minPrice)} €.
                            pour une surface de ${formatNumber(propertyStats.land.minLandArea)} m2.
                        </span>
                  </div>
            `;
        } catch (error) {
            content = `
                  <div>
                        <h3>${name_param}</h3>
                        <p>Nous ne possédons pas suffisamment de données pour traiter cette ville.</p>
                  </div>
            `;
        }

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
