const express = require('express');
const axios = require('axios');

const app = express();
const PORT = 3000;

const API_URL = 'https://ecohuerta.ar/ecotienda/api';
const AUTH = 'Basic Q0pTUTlQSDJRWE5UVEMxTFRBWThGV1VQTlFRTEZOS1g6';

app.get('/productos', async (req, res) => {
  try {
    const page = parseInt(req.query.page || '1');
    const limit = 5;
    const offset = (page - 1) * limit;

    const response = await axios.get(
      `${API_URL}/products?output_format=JSON&limit=${limit}&offset=${offset}`,
      {
        headers: {
          Authorization: AUTH,
        },
      }
    );

    let lista = [];

    if (response.data && response.data.products) {

    if (Array.isArray(response.data.products)) {
        lista = response.data.products;
    } else if (response.data.products.product) {
        lista = response.data.products.product;
    }

    } else {
    console.log("RESPUESTA INVALIDA:");
    console.log(response.data);
    }

    let productos = [];

    for (let prod of lista) {

      await new Promise(r => setTimeout(r, 200)); // evita bloqueo

      const detalle = await axios.get(
        `${API_URL}/products/${prod.id}?output_format=JSON`,
        {
          headers: {
            Authorization: AUTH,
          },
        }
      );

      let p = detalle.data.product;
      console.log("NAME RAW:");
      console.log(JSON.stringify(p.name, null, 2));

      let idImagen = null;
      try {
        idImagen = p.associations.images[0].id;
      } catch {}

      let nombre = 'Sin nombre';

        try {
        if (Array.isArray(p.name?.language)) {
            nombre = p.name.language[0].value;
        } else if (typeof p.name?.language === 'object') {
            nombre = p.name.language.value;
        } else if (typeof p.name?.language === 'string') {
            nombre = p.name.language;
        }
        } catch {}

        productos.push({
        id: p.id,
        nombre: nombre,
        precio: p.price,
        id_imagen: idImagen,
        });
    }

    res.json(productos);

  } catch (error) {
    console.log("ERROR BACKEND COMPLETO:");
    console.log(error.response?.data || error.message);
    res.status(500).json({ error: 'Error backend' });
  }
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});