-- Create Enums
CREATE TYPE business_type AS ENUM ('restaurant', 'clothing', 'service', 'beauty', 'education', 'medical', 'retail', 'etc');
CREATE TYPE project_status AS ENUM ('draft', 'completed', 'archived');
CREATE TYPE content_type AS ENUM ('text_ad', 'image_gen', 'background_removal', 'sketch_to_image');

-- Create Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    business_type business_type NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create Stores table
CREATE TABLE stores (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    brand_name VARCHAR(255) NOT NULL,
    brand_tone VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create Projects table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status project_status DEFAULT 'draft' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create Contents table
CREATE TABLE contents (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    type content_type NOT NULL,
    original_image_path VARCHAR(255),
    result_image_path VARCHAR(255),
    ad_copy TEXT,
    user_prompt TEXT,
    ai_config JSONB,
    generation_time INTEGER,
    is_success BOOLEAN DEFAULT TRUE NOT NULL,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_business_type ON users(business_type);
CREATE INDEX idx_stores_user_id ON stores(user_id);
CREATE INDEX idx_projects_store_id ON projects(store_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_contents_project_id ON contents(project_id);
CREATE INDEX idx_contents_type ON contents(type);
