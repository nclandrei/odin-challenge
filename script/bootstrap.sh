#!/bin/bash
set -e

echo "Setting up your development environment..."

# Check if PostgreSQL is installed
if ! command -v psql >/dev/null 2>&1; then
    echo "PostgreSQL is not installed. Please install PostgreSQL before continuing."
    exit 1
fi

# Check if Ruby is installed
if ! command -v ruby >/dev/null 2>&1; then
    echo "Ruby is not installed. Please install Ruby before continuing."
    exit 1
fi

# Check if Bundler is installed
if ! command -v bundle >/dev/null 2>&1; then
    echo "Bundler is not installed. Installing bundler..."
    gem install bundler
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    
    # Try to generate random keys if openssl is available
    if command -v openssl >/dev/null 2>&1; then
        echo "Generating secure random keys for Rails master key, Devise and JWT using OpenSSL..."
        RAILS_MASTER_KEY=$(openssl rand -hex 64)
        DEVISE_KEY=$(openssl rand -hex 64)
        JWT_KEY=$(openssl rand -hex 64)
    else
        echo "OpenSSL not found. Please manually set RAILS_MASTER_KEY, DEVISE_SECRET_KEY and DEVISE_JWT_SECRET_KEY in .env"
        RAILS_MASTER_KEY="replace_with_secure_key"
        DEVISE_KEY="replace_with_secure_key"
        JWT_KEY="replace_with_secure_key"
    fi
    
    cat > .env << EOL
RACK_ATTACK_SENSITIVE_ENDPOINTS_REQUEST_LIMIT=10
RACK_ATTACK_NON_SENSITIVE_ENDPOINTS_REQUEST_LIMIT=300
JWT_ACCESS_TOKEN_EXPIRATION_IN_HOURS=1
JWT_REFRESH_TOKEN_EXPIRATION_IN_HOURS=168
RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
DEVISE_SECRET_KEY=${DEVISE_KEY}
DEVISE_JWT_SECRET_KEY=${JWT_KEY}
EOL

    if [ "$DEVISE_KEY" = "replace_with_secure_key" ]; then
        echo "WARNING: Please edit .env and set secure values for RAILS_MASTER_KEY, DEVISE_SECRET_KEY and DEVISE_JWT_SECRET_KEY"
    else
        echo "Generated secure random keys and added them to .env"
    fi
fi

echo "Installing dependencies..."
bundle install

echo "Setting up database..."
bin/rails db:create
bin/rails db:migrate

echo "Setting up test database..."
bin/rails db:test:prepare

echo "Setup complete! You can now start the server with:"
echo "rails server"
