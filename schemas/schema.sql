-- Cloudflare D1 Database uses SQLite commands
-- SQLite stores INTEGERs as Integers 0=False, 1=True
-- SQLite stores DateTime values as Text strings in ISO8601 format

-- match SQL schemas to JSON schemas in schemas directory

--   ---------Inventory---------
-- match to gear.json
DROP TABLE IF EXISTS gear;
CREATE TABLE  IF NOT EXISTS gear (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    effect TEXT,
    cost INTEGER CHECK (cost >= 0),
    slots INTEGER CHECK (slots >= 0),
    special TEXT,
    -- minimum of 1 for stack
    stack INTEGER DEFAULT 1 CHECK (stack >= 0),
    isMinor INTEGER NOT NULL DEFAULT 0 CHECK (is_active IN (0, 1)),
    hasclock INTEGER NOT NULL DEFAULT 0 CHECK (is_active IN (0, 1)),
    clockValue REAL
);

-- match to curio.json
DROP TABLE IF EXISTS curios;
CREATE TABLE curios (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    -- limit to source types
    source TEXT NOT NULL CHECK (
        source IN ('Ancient Magitech', 'Divine', 'Nightmare', 'Prototype Magitech', 'Void')
    ),
    description TEXT,
    effect TEXT,
    slots INTEGER CHECK (slots >= 0)
);

-- match to artifact.json
DROP TABLE IF EXISTS artifacts;
CREATE TABLE artifacts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    source TEXT NOT NULL CHECK (
        source IN ('Ancient Magitech', 'Divine', 'Nightmare', 'Prototype Magitech', 'Void')
    ),
    description TEXT,
    effect TEXT,
    slots INTEGER CHECK (slots >= 0),
    hasDepletion INTEGER NOT NULL DEFAULT 0 CHECK (is_active IN (0, 1)),
    depletionDie TEXT, -- e.g., '1d6' or '1d10'
    depletionResult INTEGER CHECK (depletionResult >= 0),
    isMinor INTEGER NOT NULL DEFAULT 0 CHECK (is_active IN (0, 1))
);

-- match to weapon.json
DROP TABLE IF EXISTS weapons;
CREATE TABLE weapons (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    baseDmg TEXT, -- e.g., '2d6'
    cost INTEGER CHECK (cost >= 0),
    slots INTEGER CHECK (slots >= 0),
    special TEXT,
    tags TEXT, -- Stored as a JSON-formatted array string
    isMinor INTEGER NOT NULL DEFAULT 0 CHECK (is_active IN (0, 1)),
    armor INTEGER DEFAULT 0 CHECK (armor >= 0)
);

--match to armor.json
DROP TABLE IF EXISTS armor;
CREATE TABLE armor (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    cost INTEGER CHECK (cost >= 0),
    slots INTEGER CHECK (slots >= 0),
    special TEXT,
    tags TEXT, -- Stored as a JSON-formatted array string
    isMinor INTEGER NOT NULL DEFAULT 0 CHECK (is_active IN (0, 1)),
    armor_value INTEGER DEFAULT 0 CHECK (armor_value >= 0)
);

--match to itemInstance.json
DROP TABLE IF EXISTS inventory_instances;
CREATE TABLE inventory_instances (
    id TEXT PRIMARY KEY,
    FOREIGN KEY (characterId) REFERENCES characters(id) ON DELETE CASCADE
    type TEXT NOT NULL CHECK (
        type IN ('artifact', 'curio', 'gear', 'weapon', 'armor')
    ),
    isEquipped INTEGER NOT NULL DEFAULT 0 CHECK (is_active IN (0, 1)),
    baseItem TEXT NOT NULL, -- The ID from the specific item table
    displayName TEXT,
    dmgOverride TEXT,
    descriptionOverride TEXT,
    slotOverride INTEGER CHECK (slotOverride >= 0),
    stackValue INTEGER CHECK (stackValue >= 0),
    specialOverride TEXT,
    createdDate TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Users
-- match user.json
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    email TEXT PRIMARY KEY NOT NULL COLLATE NOCASE,
    name TEXT,
    passwordHash TEXT NOT NULL,
    createdDate TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Campaigns and Characters

-- match campaign.json
DROP TABLE IF EXISTS campaigns;
CREATE TABLE campaigns (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    campaignOwner TEXT NOT NULL,
    shareCode TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    FOREIGN KEY (campaignOwner) REFERENCES users(email) ON DELETE CASCADE,
    createdDate TEXT DEFAULT CURRENT_TIMESTAMP
);

-- match characterSheet.json
