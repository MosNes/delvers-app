-- Cloudflare D1 Database

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

-- paths table also includes Ancestry Talents
CREATE TABLE paths (
    name PRIMARY KEY TEXT NOT NULL,
    description TEXT,
    flavorText TEXT,
    isForbidden INTEGER DEFAULT 0 CHECK (isForbidden IN (0, 1)),
    isAncestry INTEGER DEFAULT 0 CHECK (isAncestry IN (0, 1))
);

CREATE TABLE talents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    flavorText TEXT,
    path_name TEXT,
    type TEXT NOT NULL CHECK (type IN ('Core','Minor', 'Major', 'Pinnacle', 'Ancestry')),
    picklist TEXT, -- stored as a JSON-formatted array string
    picklistHasObj INTEGER DEFAULT 0 CHECK (picklistHasObj IN (0, 1)), -- if true, picklist is an array of objects with name and description properties
    FOREIGN KEY (path_name) REFERENCES paths(name) ON DELETE CASCADE
);

CREATE TABLE fightingStyles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
);

CREATE TABLE rituals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    time TEXT NOT NULL,
    items TEXT NOT NULL,
)

CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    hasSpecialValue INTEGER DEFAULT 0 CHECK (hasSpecialValue IN (0, 1))
);

-- 5. ITEM DEFINITIONS
CREATE TABLE gear (
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


CREATE TABLE armor (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    cost INTEGER CHECK (cost >= 0),
    slots INTEGER CHECK (slots >= 0),
    special TEXT,
    tags TEXT, -- Stored as a JSON-formatted array string
    isMinor INTEGER NOT NULL DEFAULT 0 CHECK (isMinor IN (0, 1)),
    armor_value INTEGER DEFAULT 0 CHECK (armor_value >= 0)
);

CREATE TABLE weapons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    baseDmg TEXT, -- e.g., '2d6'
    cost INTEGER CHECK (cost >= 0),
    slots INTEGER CHECK (slots >= 0),
    special TEXT,
    tags TEXT, -- Stored as a JSON-formatted array string
    isMinor INTEGER NOT NULL DEFAULT 0 CHECK (isMinor IN (0, 1)),
    armor INTEGER DEFAULT 0 CHECK (armor >= 0)
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
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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

CREATE TABLE tag_junctions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    weapon_id INTEGER,
    armor_id INTEGER,
    inventory_instance_id INTEGER,
    special_value TEXT,
    CHECK (weapon_id IS NOT NULL OR armor_id IS NOT NULL OR inventory_instance_id IS NOT NULL),
    FOREIGN KEY (weapon_id) REFERENCES weapons(id) ON DELETE CASCADE,
    FOREIGN KEY (armor_id) REFERENCES armor(id) ON DELETE CASCADE,
    FOREIGN KEY (inventory_instance_id) REFERENCES inventory_instances(id) ON DELETE CASCADE
);

CREATE TABLE destiny_tracker(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL,
    completed_beats TEXT DEFAULT '[]',
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
);