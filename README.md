# Odin challenge

Hello, guys! I'm Andrei-Mihai Nicolae, thanks for taking the time to review my code! :-)

## Requirements

Before setting up the application, ensure you have the following installed:

- **Ruby**: Version specified in `.ruby-version` (`ruby-3.4.1`)
- **PostgreSQL**: As the database for the application
- **OpenSSL**: For generating secure keys (optional but recommended); if not installed, you have to set the `RAILS_MASTER_KEY`, `DEVISE_SECRET_KEY` and `DEVISE_JWT_SECRET_KEY` in the `.env` file manually. You can take a look at `.env.example` for the correct format.

## Bootstrap the Application

I've written a script to bootstrap the application. You can run it by executing `sh ./script/bootstrap.sh` inside the root directory of the project. This script will:

- Install bundler if not already installed.
- Create a `.env` file if it doesn't exist.
- Generate secure random keys for Rails master key, Devise and JWT using OpenSSL (if available)
- Install dependencies using Bundler.
- Create the database and run migrations.
- Create the test database and run migrations.

## Start the Server

Use the command `rails s` to start the Rails server.

## Run Tests
   - Execute `rails t` to run the full test suite.
   - Unit tests are located in `test/controllers` and `test/models`.
   - A full integration test is available in `test/integration`.
   - If you want to run tests with coverage, you can run `COVERAGE=true railt t`.

## Coverage

The coverage report is generated by SimpleCov and can be found in `coverage/index.html`. At the moment, the coverage is 100%.

## cURL requests

I have created a `curl_requests.txt` file where you can find the cURL requests for all the endpoints so you can play around with the API.

## Design Decisions

- **CORS Handling**:
  - Utilized `rack-cors` to manage Cross-Origin Resource Sharing (CORS) and prevent CORS attacks. This ensures that only requests from allowed origins can access the API. This can be found inside `config/initializers/cors.rb`.

- **Rate Limiting**:
  - Implemented `rack-attack` to provide rate limiting. This helps protect the application from abuse by limiting the number of requests a client can make in a given time period. I've also made a distinction between sensitive and non-sensitive endpoints, so that sensitive endpoints are protected by a higher rate limit. This can be found inside `config/initializers/rack_attack.rb`.

- **Authentication**:
  - Used Devise for authentication, configuring it in API mode, as it is one of the most popular authentication libraries for Rails.
  - Chose JSON Web Tokens (JWT) for authentication instead of cookies since this is a headless application where the frontend and backend are decoupled. While cookies can work well for both traditional and modern applications, JWTs provide a simpler solution for our specific use case of a lightweight API backend, as they don't require CSRF protection or complex cookie configurations.
  - Added refresh tokens to enhance security and user experience. Refresh tokens allow users to obtain new access tokens without re-authenticating, reducing the need for frequent logins while still maintaining security through short-lived access tokens.
  - The JWT approach aligns well with the goal of building a lightweight backend API, as it doesn't require maintaining session state on the server and works seamlessly across different frontend technologies.

- **API Response Middleware**:
  - Implemented a custom middleware to standardize API responses across the application. This ensures consistent response formats for both successful operations and errors.
  - All responses follow a predictable structure with appropriate HTTP status codes, making it easier for clients to handle responses.
  - Error responses include detailed messages and validation errors when applicable, helping developers quickly identify and fix issues.
  - Success responses consistently wrap data in a standardized format, improving API predictability and maintainability.
  - The middleware can be found in `app/middleware/api_response_middleware.rb` and is automatically applied to all API endpoints.

- **Data Protection & Leak Prevention**:
  - Sensitive data like passwords are never returned in API responses. Such sensitive data is also encrypted in the database.
  - Error messages are sanitized in production to avoid leaking implementation details
  - Strong parameter filtering ensures only permitted data is processed
  - Logging excludes sensitive parameters like passwords and tokens

- **Dependency Management**:
  - All gem versions are explicitly pinned in the Gemfile to ensure consistent behavior across different environments and prevent unexpected issues from gem updates.
  - This makes the application more stable and reproducible, as every installation will use the exact same gem versions.
  - When updates are needed, they can be carefully evaluated and tested before being implemented.

- **Code Style & Consistency**:
  - Follows Ruby and Rails style conventions using RuboCop
  - Consistent code style makes the codebase easier to maintain and understand

- **Internationalization (I18n)**:
  - All messages and responses are internationalized using Rails I18n
  - Supports multiple languages through locale files in `config/locales/`

## Known Limitations and Areas for Improvement

- **Security Enhancements**:
  - While JWTs are secure, ensure that the secret keys are stored securely and rotated periodically.
  - If app was much larger, we could consider implementing additional security measures such as IP whitelisting or two-factor authentication.

- **Caching**:
  - We could implement caching to improve performance, especially for endpoints that return frequently requested data, but for the time being, our simple application doesn't need it :-D
