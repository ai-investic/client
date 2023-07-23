<script>
    let numStreet = '';
    let zipCode = '';
    let depCode = '';
    let typeLocalCode = '';
    let nbRooms = '';
    let nbLots = '';
    let actualFloorArea = '';
    let groundArea = '';

    let predictionResult = null;
    let isSubmitting = false;

    function handleSubmit() {
        isSubmitting = true;

        const apiUrl = `http://localhost:8000/predict?num_street=${numStreet}&zip_code=${zipCode}&dep_code=${depCode}&type_local_code=${typeLocalCode}&nb_rooms=${nbRooms}&nb_lots=${nbLots}&actual_floor_area=${actualFloorArea}&ground_area=${groundArea}`;

        fetch(apiUrl, {
            method: "GET",
            headers: {
                "content-type": "application/json",
                "accept": "application/json"
            }
        })
            .then(response => response.json())
            .then(data => {
                predictionResult = data;
                showModal(data);
                isSubmitting = false;
            })
            .catch(error => {
                console.error(error);
                isSubmitting = false;
            });
    }

    let modalIsVisible = false;

    function showModal(data) {
        predictionResult = data;
        modalIsVisible = true;
    }

    function closeModal() {
        modalIsVisible = false;
        predictionResult = null;
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
</script>

<div class="prediction">
    <form on:submit|preventDefault={handleSubmit}>
        <label>
            No voie:
            <input type="number" bind:value={numStreet} required/>
        </label>
        <label>
            Code postal:
            <input type="number" bind:value={zipCode} required/>
        </label>
        <label>
            Code département:
            <input type="number" bind:value={depCode} required/>
        </label>
        <label>
            Code type local:
            <input type="number" bind:value={typeLocalCode} required/>
        </label>
        <label>
            Nombre de pièces principales:
            <input type="number" bind:value={nbRooms} required/>
        </label>
        <label>
            Nombre de lots:
            <input type="number" bind:value={nbLots} required/>
        </label>
        <label>
            Surface réelle bâtie:
            <input type="number" bind:value={actualFloorArea} required/>
        </label>
        <label>
            Surface terrain:
            <input type="number" bind:value={groundArea} required/>
        </label>

        {#if isSubmitting}
            <button type="submit" disabled>En cours...</button>
        {:else}
            <button type="submit">Soumettre</button>
        {/if}
    </form>
    {#if predictionResult}
        <div class="modal" style={modalIsVisible ? 'display: block;' : 'display: none;'}>
            <div class="modal-content">
                <span class="close" on:click={closeModal}>&times;</span>
                <h2>Résultat de la prédiction :</h2>
                <pre style="color: red; font-weight: bold;">{formatPrice(predictionResult.prediction)} €</pre>
            </div>
        </div>
    {/if}
</div>

<style>
    body {
        background-color: #f2f2f2;
    }

    .prediction {
        display: flex;
        justify-content: center;
        align-items: center;
    }

    form {
        margin-top: 35px;
        width: 40%;
        max-width: 400px;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        background-color: #fff;
    }

    label {
        display: block;
        margin-bottom: 10px;
        font-weight: bold;
        color: #333;
    }

    input {
        width: 100%;
        padding: 10px;
        margin-bottom: 20px;
        border: 1px solid #ccc;
        border-radius: 5px;
        transition: border-color 0.3s ease;
    }

    input:focus {
        outline: none;
        border-color: #ff0000;
        box-shadow: 0 0 5px #ff0000;
    }

    button {
        width: 100%;
        padding: 12px;
        border: none;
        border-radius: 5px;
        background-color: #ff0000;
        color: #fff;
        font-weight: bold;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }

    button:hover {
        background-color: #ff0000;
    }

    .modal {
        display: none;
        position: fixed;
        z-index: 1;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.4);
    }

    .modal-content {
        background-color: #fefefe;
        margin: 15% auto;
        padding: 20px;
        border: 1px solid #888;
        border-radius: 10px;
        max-width: 80%;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }

    .close {
        color: #aaa;
        float: right;
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
    }

    .close:hover {
        color: #000;
    }
</style>
