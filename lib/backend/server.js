const express = require("express")
const { Pool } = require("pg")
const cors = require("cors")

const app = express()
const port = process.env.PORT || 3000

// Middleware
app.use(cors())
app.use(express.json())

// Database connection
const pool = new Pool({
  connectionString:
    process.env.DATABASE_URL ||
    "postgresql://mipripity_v2_owner:pw_live_square-moon-79559388@ep-square-moon-79559388.us-east-1.aws.neon.tech/mipripity_v2?sslmode=require",
  ssl: {
    rejectUnauthorized: false,
  },
})

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    console.error("Error connecting to database:", err)
  } else {
    console.log("Connected to Neon PostgreSQL database")
    release()
  }
})

// Root endpoint
app.get("/", (req, res) => {
  res.json({ message: "Welcome to Mipripity API" })
})

// Routes

// Get all categories
app.get("/api/categories", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM categories ORDER BY name")
    res.json({ data: result.rows })
  } catch (err) {
    console.error("Error fetching categories:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Create a new listing
app.post("/api/listings", async (req, res) => {
  const { title, description, price, location, city, state, country, category_id, user_id, main_image_url } = req.body

  try {
    const result = await pool.query(
      `INSERT INTO listings (title, description, price, location, city, state, country, category_id, user_id, main_image_url, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())
       RETURNING id`,
      [title, description, price, location, city, state, country, category_id, user_id, main_image_url],
    )

    res.status(201).json({ id: result.rows[0].id })
  } catch (err) {
    console.error("Error creating listing:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Create demographic targets
app.post("/api/demographic_targets", async (req, res) => {
  const { listing_id, countries, states, lgas, age_group, social_class, occupations } = req.body

  try {
    await pool.query(
      `INSERT INTO demographic_targets (listing_id, countries, states, lgas, age_group, social_class, occupations, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())`,
      [
        listing_id,
        JSON.stringify(countries),
        JSON.stringify(states),
        JSON.stringify(lgas),
        age_group,
        social_class,
        JSON.stringify(occupations),
      ],
    )

    res.status(201).json({ success: true })
  } catch (err) {
    console.error("Error creating demographic targets:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Create urgency settings
app.post("/api/urgency_settings", async (req, res) => {
  const { listing_id, reason, deadline, is_active } = req.body

  try {
    await pool.query(
      `INSERT INTO urgency_settings (listing_id, reason, deadline, is_active, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [listing_id, reason, deadline, is_active],
    )

    res.status(201).json({ success: true })
  } catch (err) {
    console.error("Error creating urgency settings:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Create property features
app.post("/api/property_features", async (req, res) => {
  const { listing_id, feature_type, feature_value } = req.body

  try {
    await pool.query(
      `INSERT INTO property_features (listing_id, feature_type, feature_value, created_at)
       VALUES ($1, $2, $3, NOW())`,
      [listing_id, feature_type, feature_value],
    )

    res.status(201).json({ success: true })
  } catch (err) {
    console.error("Error creating property feature:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Create listing images
app.post("/api/listing_images", async (req, res) => {
  const { listing_id, image_url, is_main, display_order } = req.body

  try {
    await pool.query(
      `INSERT INTO listing_images (listing_id, image_url, is_main, display_order, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [listing_id, image_url, is_main, display_order],
    )

    res.status(201).json({ success: true })
  } catch (err) {
    console.error("Error creating listing image:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Create user
app.post("/api/users", async (req, res) => {
  const { email, password_hash, first_name, last_name, full_name, phone_number, whatsapp_link, avatar_url, user_type } =
    req.body

  try {
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, first_name, last_name, full_name, phone_number, whatsapp_link, avatar_url, user_type, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())
       RETURNING id`,
      [email, password_hash, first_name, last_name, full_name, phone_number, whatsapp_link, avatar_url, user_type],
    )

    res.status(201).json({ id: result.rows[0].id })
  } catch (err) {
    console.error("Error creating user:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Get user by email
app.get("/api/users", async (req, res) => {
  const { email } = req.query

  try {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email])
    res.json({ data: result.rows })
  } catch (err) {
    console.error("Error fetching user:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// User authentication
app.post("/api/auth/login", async (req, res) => {
  const { email, password_hash } = req.body

  try {
    const result = await pool.query("SELECT * FROM users WHERE email = $1 AND password_hash = $2", [
      email,
      password_hash,
    ])

    if (result.rows.length > 0) {
      res.json(result.rows[0])
    } else {
      res.status(401).json({ error: "Invalid credentials" })
    }
  } catch (err) {
    console.error("Error during authentication:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Get all listings
app.get("/api/listings", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT l.*, c.name as category_name, u.full_name as owner_name
      FROM listings l
      JOIN categories c ON l.category_id = c.id
      JOIN users u ON l.user_id = u.id
      ORDER BY l.created_at DESC
    `)
    res.json({ data: result.rows })
  } catch (err) {
    console.error("Error fetching listings:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

// Get listing by ID
app.get("/api/listings/:id", async (req, res) => {
  const { id } = req.params

  try {
    const listingResult = await pool.query(
      `
      SELECT l.*, c.name as category_name, u.full_name as owner_name, u.phone_number, u.whatsapp_link
      FROM listings l
      JOIN categories c ON l.category_id = c.id
      JOIN users u ON l.user_id = u.id
      WHERE l.id = $1
    `,
      [id],
    )

    if (listingResult.rows.length === 0) {
      return res.status(404).json({ error: "Listing not found" })
    }

    const listing = listingResult.rows[0]

    // Get images
    const imagesResult = await pool.query(
      `
      SELECT * FROM listing_images
      WHERE listing_id = $1
      ORDER BY display_order
    `,
      [id],
    )

    // Get features
    const featuresResult = await pool.query(
      `
      SELECT * FROM property_features
      WHERE listing_id = $1
    `,
      [id],
    )

    // Get demographic targets
    const demographicResult = await pool.query(
      `
      SELECT * FROM demographic_targets
      WHERE listing_id = $1
    `,
      [id],
    )

    // Get urgency settings
    const urgencyResult = await pool.query(
      `
      SELECT * FROM urgency_settings
      WHERE listing_id = $1
    `,
      [id],
    )

    res.json({
      ...listing,
      images: imagesResult.rows,
      features: featuresResult.rows,
      demographic_targets: demographicResult.rows.length > 0 ? demographicResult.rows[0] : null,
      urgency_settings: urgencyResult.rows.length > 0 ? urgencyResult.rows[0] : null,
    })
  } catch (err) {
    console.error("Error fetching listing details:", err)
    res.status(500).json({ error: "Internal server error" })
  }
})

app.listen(port, () => {
  console.log(`Server running on port ${port}`)
})
