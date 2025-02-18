-- These tables are used by barricade to manage authentication

-- migrate:up
CREATE TABLE users (
    id SERIAL PRIMARY KEY, 
    email VARCHAR NOT NULL UNIQUE, 
    first_name VARCHAR, 
    last_name VARCHAR, 
    hashed_password VARCHAR NOT NULL, 
    reset_password_selector VARCHAR,
    reset_password_verifier_hash VARCHAR,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE sessions (
    id SERIAL PRIMARY KEY, 
    session_verifier VARCHAR NOT NULL, 
    user_id INT NOT NULL, 
    otp_code_encrypted VARCHAR NOT NULL,
    otp_code_attempts INTEGER NOT NULL DEFAULT 0,
    otp_code_confirmed BOOLEAN NOT NULL DEFAULT false,
    otp_code_sent BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Give access to the application user, the application user has no access to 
-- The sessions table and therefore cannot fake a login.
GRANT SELECT, UPDATE ON users TO ft_application;
GRANT SELECT ON users_id_seq TO ft_application;

-- Give access to the readonly user
GRANT SELECT ON sessions, users, users_id_seq, sessions_id_seq TO ft_readonly;

-- Give access to authentication user
GRANT SELECT, INSERT, UPDATE, DELETE ON sessions TO ft_authentication;
GRANT USAGE, SELECT ON sessions_id_seq TO ft_authentication;
GRANT SELECT, INSERT, UPDATE ON users TO ft_authentication;
GRANT USAGE, SELECT ON users_id_seq TO ft_authentication;

-- Manage the updated_at column
SELECT updated_at('users');

-- migrate:down
DROP TABLE users;
DROP TABLE sessions;