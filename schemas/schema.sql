-- Cloudflare D1 Database
-- enable or disable foreign key checks to allow clean drops
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS destiny_tracker;
DROP TABLE IF EXISTS talent_instances;
DROP TABLE IF EXISTS path_instances;
DROP TABLE IF EXISTS inventory_instances;
DROP TABLE IF EXISTS characters;
DROP TABLE IF EXISTS campaigns;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS talents;
DROP TABLE IF EXISTS paths;
DROP TABLE IF EXISTS destinies;
DROP TABLE IF EXISTS artifacts;
DROP TABLE IF EXISTS curios;
DROP TABLE IF EXISTS gear;

-- 1. USERS (Parent Table)
CREATE TABLE users (
    email TEXT PRIMARY KEY NOT NULL COLLATE NOCASE,
    name TEXT,
    passwordHash TEXT NOT NULL,
    createdDate TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 2. CAMPAIGNS (Parent of Characters)
CREATE TABLE campaigns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    campaign_owner TEXT NOT NULL,
    shareCode TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    createdDate TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (campaign_owner) REFERENCES users(email) ON DELETE CASCADE
);

-- 3. CHARACTERS (Parent of all instances and trackers)
CREATE TABLE characters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner TEXT NOT NULL,
    campaign INTEGER, -- Changed to INTEGER to match campaigns.id
    imgUrl TEXT,
    characterName TEXT NOT NULL,
    player TEXT NOT NULL,
    ancestry TEXT NOT NULL,
    ancestrySpecies TEXT NOT NULL,
    path TEXT NOT NULL,
    background TEXT,
    domains TEXT, 
    skills TEXT,
    maxGuard INTEGER DEFAULT 0 CHECK (maxGuard >= 0),
    currentGuard INTEGER DEFAULT 0 CHECK (currentGuard >= 0),
    armor INTEGER DEFAULT 0 CHECK (armor >= 0),
    maxBody INTEGER DEFAULT 0 CHECK (maxBody >= 0),
    currentBody INTEGER DEFAULT 0 CHECK (currentBody >= 0),
    maxSpeed INTEGER DEFAULT 0 CHECK (maxSpeed >= 0),
    currentSpeed INTEGER DEFAULT 0 CHECK (currentSpeed >= 0),
    maxMind INTEGER DEFAULT 0 CHECK (maxMind >= 0),
    currentMind INTEGER DEFAULT 0 CHECK (currentMind >= 0),
    maxSpirit INTEGER DEFAULT 0 CHECK (maxSpirit >= 0),
    currentSpirit INTEGER DEFAULT 0 CHECK (currentSpirit >= 0),
    blessings INTEGER DEFAULT 0 CHECK (blessings >= 0),
    curses INTEGER DEFAULT 0 CHECK (curses >= 0),
    doom INTEGER DEFAULT 0 CHECK (doom BETWEEN 0 AND 5),
    bodyStress INTEGER DEFAULT 0 CHECK (bodyStress IN (0, 1)),
    speedStress INTEGER DEFAULT 0 CHECK (speedStress IN (0, 1)),
    mindStress INTEGER DEFAULT 0 CHECK (mindStress IN (0, 1)),
    spiritStress INTEGER DEFAULT 0 CHECK (spiritStress IN (0, 1)),
    notes TEXT,
    FOREIGN KEY (owner) REFERENCES users(email) ON DELETE CASCADE,
    FOREIGN KEY (campaign) REFERENCES campaigns(id) ON DELETE SET NULL
);

-- 4. BASE DATA TABLES
CREATE TABLE destinies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE paths (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE talents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    flavorText TEXT,
    path_id INTEGER, -- Changed to INTEGER to match paths.id
    isCore INTEGER DEFAULT 0 CHECK (isCore IN (0, 1)),
    isMinor INTEGER DEFAULT 0 CHECK (isMinor IN (0, 1)),
    isMajor INTEGER DEFAULT 0 CHECK (isMajor IN (0, 1)),
    isPinnacle INTEGER DEFAULT 0 CHECK (isPinnacle IN (0, 1)),
    FOREIGN KEY (path_id) REFERENCES paths(id) ON DELETE CASCADE
);

-- 5. ITEM DEFINITIONS
CREATE TABLE IF NOT EXISTS gear (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    effect TEXT,
    cost INTEGER CHECK (cost >= 0),
    slots INTEGER CHECK (slots >= 0),
    special TEXT,
    stack INTEGER DEFAULT 1 CHECK (stack >= 0),
    isMinor INTEGER NOT NULL DEFAULT 0 CHECK (isMinor IN (0, 1)),
    hasClock INTEGER NOT NULL DEFAULT 0 CHECK (hasClock IN (0, 1)),
    [clockValue] INTEGER
);

CREATE TABLE curios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    source TEXT NOT NULL CHECK (source IN ('Ancient Magitech', 'Divine', 'Nightmare', 'Prototype Magitech', 'Void')),
    description TEXT,
    effect TEXT,
    slots INTEGER CHECK (slots >= 0)
);

CREATE TABLE artifacts (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    source TEXT NOT NULL CHECK (source IN ('Ancient Magitech', 'Divine', 'Nightmare', 'Prototype Magitech', 'Void')),
    description TEXT,
    effect TEXT,
    slots INTEGER CHECK (slots >= 0),
    hasDepletion INTEGER NOT NULL DEFAULT 0 CHECK (hasDepletion IN (0, 1)),
    depletionDie TEXT,
    depletionResult INTEGER CHECK (depletionResult >= 0),
    isMinor INTEGER NOT NULL DEFAULT 0 CHECK (isMinor IN (0, 1))
);

-- 6. INSTANCE & JUNCTION TABLES (Created last)
CREATE TABLE inventory_instances (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL,
    itemType TEXT NOT NULL CHECK (itemType IN ('artifact', 'curio', 'gear', 'weapon', 'armor')),
    isEquipped INTEGER NOT NULL DEFAULT 0 CHECK (isEquipped IN (0, 1)),
    baseItem TEXT NOT NULL,
    displayName TEXT,
    dmgOverride TEXT,
    descriptionOverride TEXT,
    slotOverride INTEGER CHECK (slotOverride >= 0),
    stackValue INTEGER CHECK (stackValue >= 0),
    specialOverride TEXT,
    createdDate TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
);

CREATE TABLE path_instances (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL,
    path_id INTEGER NOT NULL, -- Changed to INTEGER
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (path_id) REFERENCES paths(id) ON DELETE CASCADE
);


CREATE TABLE talent_instances (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL,
    talent_id INTEGER NOT NULL, -- Changed to INTEGER
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (talent_id) REFERENCES talents(id) ON DELETE CASCADE
);

CREATE TABLE destiny_tracker(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL,
    completed_beats TEXT DEFAULT '[]',
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
);