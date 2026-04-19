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
    character_id TEXT NOT NULL,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
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

-- Character Data
-- match destiny.json
DROP TABLE IF EXISTS destinies;
CREATE TABLE destinies (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT
);

-- match talent.json
DROP TABLE IF EXISTS talents;
CREATE TABLE talents (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    flavorText TEXT,
    path_id TEXT,
    isCore INTEGER DEFAULT 0 CHECK (isCore IN (0, 1)),
    isMinor INTEGER DEFAULT 0 CHECK (isMinor IN (0, 1)),
    isMajor INTEGER DEFAULT 0 CHECK (isMajor IN (0, 1)),
    isPinnacle INTEGER DEFAULT 0 CHECK (isPinnacle IN (0, 1)),
    -- on deletion of path delete all associated talents 
    -- (why would we need this, no idea, but good for consistency)
    FOREIGN KEY (path_id) REFERENCES paths(id) ON DELETE CASCADE
);

-- match path.json
DROP TABLE IF EXISTS paths;
CREATE TABLE paths (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- match pathInstance.json
-- Junction record that associates a specific path with a specific character
DROP TABLE IF EXISTS path_instances;
CREATE TABLE path_instances (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    character_id TEXT NOT NULL,
    path_id TEXT NOT NULL,
    -- Foreign Key Relationships
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (path_id) REFERENCES paths(id) ON DELETE CASCADE
);

-- match talentInstance.json
-- junction record that associates a specific talent with a specific character
DROP TABLE IF EXISTS talent_instances;
CREATE TABLE talent_instances (
    id TEXT PRIMARY KEY AUTOINCREMENTS,
    character_id TEXT NOT NULL,
    talent_id TEXT NOT NULL,
    -- Foreign Key Relationships
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (talent_id) REFERENCES talents(id) ON DELETE CASCADE
);

--match destinyTracker.json
-- junction record that associates a specific destiny with a specific character and allows
-- the character to track their destiny beats
CREATE TABLE destiny_tracker(
    id TEXT PRIMARY KEY AUTOINCREMENT,
    character_id TEXT NOT NULL,
    completed_beats TEXT DEFAULT '[]', -- JSON array of beat UUIDs
    -- delete all associated trackers when character is deleted
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
);

-- Campaigns and Characters

-- match campaign.json
DROP TABLE IF EXISTS campaigns;
CREATE TABLE campaigns (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    campaign_owner TEXT NOT NULL,
    shareCode TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    FOREIGN KEY (campaign_owner) REFERENCES users(email) ON DELETE CASCADE,
    createdDate TEXT DEFAULT CURRENT_TIMESTAMP
);

-- match characterSheet.json
CREATE TABLE characters (
    
    -- Identification & Ownership
    id TEXT PRIMARY KEY AUTOINCREMENT,
    owner TEXT NOT NULL,
    campaign TEXT,
    imgUrl TEXT,
    characterName TEXT NOT NULL,
    player TEXT NOT NULL,
    
    -- Foreign Key Relations
    -- delete all characters if user is deleted
    FOREIGN KEY (owner) REFERENCES users(email) ON DELETE CASCADE,
    -- do not delete campaign if user is deleted
    FOREIGN KEY (campaign) REFERENCES campaigns(id) ON DELETE SET NULL

    -- Character Definition
    ancestry TEXT NOT NULL,
    ancestrySpecies TEXT NOT NULL,
    -- on character deletion, delete associated Destiny Tracker record
    destiny FOREIGN KEY (id) REFERENCES destinyTracker(characterid) ON DELETE CASCADE,
    path TEXT NOT NULL,
    background TEXT,
    domains TEXT, -- JSON Array of Strings
    skills TEXT,  -- JSON Array of Strings

    -- Combat & Defense Stats
    maxGuard INTEGER DEFAULT 0 CHECK (maxGuard >= 0),
    currentGuard INTEGER DEFAULT 0 CHECK (currentGuard >= 0),
    armor INTEGER DEFAULT 0 CHECK (armor >= 0),

    -- Attribute Tracks
    maxBody INTEGER DEFAULT 0 CHECK (maxBody >= 0),
    currentBody INTEGER DEFAULT 0 CHECK (currentBody >= 0),
    maxSpeed INTEGER DEFAULT 0 CHECK (maxSpeed >= 0),
    currentSpeed INTEGER DEFAULT 0 CHECK (currentSpeed >= 0),
    maxMind INTEGER DEFAULT 0 CHECK (maxMind >= 0),
    currentMind INTEGER DEFAULT 0 CHECK (currentMind >= 0),
    maxSpirit INTEGER DEFAULT 0 CHECK (maxSpirit >= 0),
    currentSpirit INTEGER DEFAULT 0 CHECK (currentSpirit >= 0),

    -- Meta Trackers
    blessings INTEGER DEFAULT 0 CHECK (blessings >= 0),
    curses INTEGER DEFAULT 0 CHECK (curses >= 0),
    doom INTEGER DEFAULT 0 CHECK (doom BETWEEN 0 AND 5),

    -- Stress States (Booleans)
    bodyStress INTEGER DEFAULT 0 CHECK (bodyStress IN (0, 1)),
    speedStress INTEGER DEFAULT 0 CHECK (speedStress IN (0, 1)),
    mindStress INTEGER DEFAULT 0 CHECK (mindStress IN (0, 1)),
    spiritStress INTEGER DEFAULT 0 CHECK (spiritStress IN (0, 1)),

    -- Notes
    notes TEXT,

);