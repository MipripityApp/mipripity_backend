-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon_path VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  full_name VARCHAR(200),
  phone_number VARCHAR(20),
  whatsapp_link VARCHAR(255),
  avatar_url VARCHAR(255),
  user_type VARCHAR(50) DEFAULT 'regular',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create listings table
CREATE TABLE IF NOT EXISTS listings (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(15, 2),
  location VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100),
  category_id INTEGER REFERENCES categories(id),
  user_id INTEGER REFERENCES users(id),
  main_image_url VARCHAR(255),
  status VARCHAR(50) DEFAULT 'Available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create listing_images table
CREATE TABLE IF NOT EXISTS listing_images (
  id SERIAL PRIMARY KEY,
  listing_id INTEGER REFERENCES listings(id) ON DELETE CASCADE,
  image_url VARCHAR(255) NOT NULL,
  is_main BOOLEAN DEFAULT FALSE,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create property_features table
CREATE TABLE IF NOT EXISTS property_features (
  id SERIAL PRIMARY KEY,
  listing_id INTEGER REFERENCES listings(id) ON DELETE CASCADE,
  feature_type VARCHAR(100) NOT NULL,
  feature_value TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create demographic_targets table
CREATE TABLE IF NOT EXISTS demographic_targets (
  id SERIAL PRIMARY KEY,
  listing_id INTEGER REFERENCES listings(id) ON DELETE CASCADE,
  countries JSONB DEFAULT '[]',
  states JSONB DEFAULT '[]',
  lgas JSONB DEFAULT '[]',
  age_group VARCHAR(50) DEFAULT 'All',
  social_class VARCHAR(50) DEFAULT 'All',
  occupations JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create urgency_settings table
CREATE TABLE IF NOT EXISTS urgency_settings (
  id SERIAL PRIMARY KEY,
  listing_id INTEGER REFERENCES listings(id) ON DELETE CASCADE,
  reason TEXT,
  deadline VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default categories if they don't exist
INSERT INTO categories (name, description)
SELECT 'Residential', 'Residential properties for rent or sale'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Residential');

INSERT INTO categories (name, description)
SELECT 'Commercial', 'Commercial properties for rent or sale'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Commercial');

INSERT INTO categories (name, description)
SELECT 'Land', 'Land for sale or lease'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Land');

INSERT INTO categories (name, description)
SELECT 'Material', 'Construction and home materials'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Material');
