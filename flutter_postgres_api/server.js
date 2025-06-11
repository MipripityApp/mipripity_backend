const express = require('express');
const cors = require('cors');
require('dotenv').config();

const propertyRoutes = require('./routes/properties');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => res.send('Mipripity API is live'));
app.use('/api/properties', propertyRoutes);

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
