
-- Enable WAL mode for better performance
PRAGMA journal_mode=WAL;

-- Enable foreign key support to ensure data integrity
PRAGMA foreign_keys=ON;

-- BLOB is used to store UUIDv7 as primary keys in binary format
-- Table: user
CREATE TABLE user (
    id BLOB PRIMARY KEY,
    name TEXT NOT NULL DEFAULT 'Anonymous',
    surname TEXT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    salt TEXT NOT NULL,
    user_type TEXT NOT NULL CHECK (user_type IN ('admin', 'customer'))
);

-- Table: customer_detail
CREATE TABLE customer_detail (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id BLOB NOT NULL UNIQUE,
    phone_number TEXT,
    address TEXT,
    FOREIGN KEY (user_id) REFERENCES user(id)
);

-- Table: item
CREATE TABLE item (
    id BLOB PRIMARY KEY,
    description TEXT NOT NULL,
    unit_price REAL NOT NULL
);

-- Table: purchase ('order' not used to avoid using quotes)
CREATE TABLE putchase (
    id BLOB PRIMARY KEY,
    customer_id BLOB NOT NULL,
    purchase_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount REAL NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES user(id)
);

-- Table: purchase_item (junction table for purchase and item)
CREATE TABLE purchase_item (
    purchase_id BLOB NOT NULL,
    item_id BLOB NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    item_price_at_order REAL NOT NULL,
    PRIMARY KEY (purchase_id, item_id), -- Composite primary key
    FOREIGN KEY (purchase_id) REFERENCES purchase(id),
    FOREIGN KEY (item_id) REFERENCES item(id)
);

