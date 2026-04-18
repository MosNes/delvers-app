-- match to gear.json
DROP TABLE IF EXISTS gear-items;
CREATE TABLE  IF NOT EXISTS gear-items (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    effect TEXT,
    cost INTEGER CHECK (cost >= 0),
    slots INTEGER CHECK (slots >= 0),
    special TEXT,
    -- minimum of 1 for stack
    stack INTEGER DEFAULT 1 CHECK (stack >= 0),
    isMinor BOOLEAN,
    hasclock BOOLEAN,
    clockValue REAL
);

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
    isMinor BOOLEAN,
    armor INTEGER DEFAULT 0 CHECK (armor >= 0)
);