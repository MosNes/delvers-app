-- PostgreSQL / Supabase schema
-- Converted from schemas/schema.sql (Cloudflare D1 / SQLite)

-- Extensions (enable in Supabase SQL editor if not already present)
CREATE EXTENSION IF NOT EXISTS "citext";

-- 1. USERS (Parent Table)
CREATE TABLE users (
    email citext PRIMARY KEY NOT NULL,
    name text,
    "passwordHash" text NOT NULL,
    "createdDate" timestamptz NOT NULL DEFAULT now()
);

-- 2. CAMPAIGNS (Parent of Characters)
CREATE TABLE campaigns (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_owner citext NOT NULL REFERENCES users(email) ON DELETE CASCADE,
    "shareCode" text NOT NULL UNIQUE,
    name text NOT NULL,
    description text,
    "createdDate" timestamptz NOT NULL DEFAULT now()
);

-- 3. CHARACTERS (Parent of all instances and trackers)
CREATE TABLE characters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    owner citext NOT NULL REFERENCES users(email) ON DELETE CASCADE,
    campaign uuid REFERENCES campaigns(id) ON DELETE SET NULL,
    "imgUrl" text,
    "characterName" text NOT NULL,
    player text NOT NULL,
    ancestry text NOT NULL,
    "ancestrySpecies" text NOT NULL,
    path text NOT NULL,
    background text,
    domains text,
    skills text,
    talents text,
    advances text,
    "minorAdvances" integer NOT NULL DEFAULT 0 CHECK ("minorAdvances" >= 0),
    "majorAdvances" integer NOT NULL DEFAULT 0 CHECK ("majorAdvances" >= 0),
    "pinnacleAdvances" integer NOT NULL DEFAULT 0 CHECK ("pinnacleAdvances" >= 0),
    "maxGuard" integer NOT NULL DEFAULT 0 CHECK ("maxGuard" >= 0),
    "currentGuard" integer NOT NULL DEFAULT 0 CHECK ("currentGuard" >= 0),
    armor integer NOT NULL DEFAULT 0 CHECK (armor >= 0),
    "maxBody" integer NOT NULL DEFAULT 0 CHECK ("maxBody" >= 0),
    "currentBody" integer NOT NULL DEFAULT 0 CHECK ("currentBody" >= 0),
    "maxSpeed" integer NOT NULL DEFAULT 0 CHECK ("maxSpeed" >= 0),
    "currentSpeed" integer NOT NULL DEFAULT 0 CHECK ("currentSpeed" >= 0),
    "maxMind" integer NOT NULL DEFAULT 0 CHECK ("maxMind" >= 0),
    "currentMind" integer NOT NULL DEFAULT 0 CHECK ("currentMind" >= 0),
    "maxSpirit" integer NOT NULL DEFAULT 0 CHECK ("maxSpirit" >= 0),
    "currentSpirit" integer NOT NULL DEFAULT 0 CHECK ("currentSpirit" >= 0),
    blessings integer NOT NULL DEFAULT 0 CHECK (blessings >= 0),
    curses integer NOT NULL DEFAULT 0 CHECK (curses >= 0),
    doom integer NOT NULL DEFAULT 0 CHECK (doom BETWEEN 0 AND 5),
    "bodyStress" boolean NOT NULL DEFAULT false,
    "speedStress" boolean NOT NULL DEFAULT false,
    "mindStress" boolean NOT NULL DEFAULT false,
    "spiritStress" boolean NOT NULL DEFAULT false,
    notes text
);

CREATE INDEX idx_characters_owner ON characters(owner);
CREATE INDEX idx_characters_campaign ON characters(campaign);

-- 4. BASE DATA TABLES
CREATE TABLE destinies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text
);

-- paths table also includes Ancestry Talents
CREATE TABLE paths (
    name text PRIMARY KEY NOT NULL,
    description text,
    "flavorText" text,
    "isForbidden" boolean NOT NULL DEFAULT false,
    "isAncestry" boolean NOT NULL DEFAULT false
);

CREATE TABLE talents (
    name text PRIMARY KEY NOT NULL,
    description text,
    "flavorText" text,
    path_name text NOT NULL REFERENCES paths(name) ON DELETE CASCADE,
    type text NOT NULL CHECK (type IN ('Core', 'Minor', 'Major', 'Pinnacle', 'Ancestry')),
    "hasPicklist" boolean NOT NULL DEFAULT false,
    "picklistValues" text,
    "picklistHasObj" boolean NOT NULL DEFAULT false,
    "isRepeatable" boolean NOT NULL DEFAULT false
);

CREATE TABLE advances (
    name text PRIMARY KEY NOT NULL,
    talent_name text NOT NULL REFERENCES talents(name) ON DELETE CASCADE,
    description text,
    "isRepeatable" boolean NOT NULL DEFAULT false,
    "dataSource" text
);

CREATE TABLE fighting_styles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text NOT NULL
);

CREATE TABLE rituals (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    time text NOT NULL,
    items text NOT NULL
);

CREATE TABLE tags (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    "hasSpecialValue" boolean NOT NULL DEFAULT false
);

-- 5. ITEM DEFINITIONS
CREATE TABLE gear (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    effect text,
    cost integer CHECK (cost >= 0),
    slots integer CHECK (slots >= 0),
    special text,
    stack integer NOT NULL DEFAULT 1 CHECK (stack >= 0),
    "isMinor" boolean NOT NULL DEFAULT false,
    "hasClock" boolean NOT NULL DEFAULT false,
    "clockValue" integer
);

CREATE TABLE armor (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    cost integer CHECK (cost >= 0),
    slots integer CHECK (slots >= 0),
    special text,
    tags text,
    "isMinor" boolean NOT NULL DEFAULT false,
    armor_value integer NOT NULL DEFAULT 0 CHECK (armor_value >= 0)
);

CREATE TABLE weapons (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    "baseDmg" text,
    cost integer CHECK (cost >= 0),
    slots integer CHECK (slots >= 0),
    special text,
    tags text,
    "isMinor" boolean NOT NULL DEFAULT false,
    armor integer NOT NULL DEFAULT 0 CHECK (armor >= 0)
);

CREATE TABLE curios (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    source text NOT NULL CHECK (source IN ('Ancient Magitech', 'Divine', 'Nightmare', 'Prototype Magitech', 'Void')),
    description text,
    effect text,
    slots integer CHECK (slots >= 0)
);

CREATE TABLE artifacts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    source text NOT NULL CHECK (source IN ('Ancient Magitech', 'Divine', 'Nightmare', 'Prototype Magitech', 'Void')),
    description text,
    effect text,
    slots integer CHECK (slots >= 0),
    "hasDepletion" boolean NOT NULL DEFAULT false,
    "depletionDie" text,
    "depletionResult" integer CHECK ("depletionResult" >= 0),
    "isMinor" boolean NOT NULL DEFAULT false
);

-- 6. INSTANCE & JUNCTION TABLES (Created last)
CREATE TABLE inventory_instances (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id uuid NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    "itemType" text NOT NULL CHECK ("itemType" IN ('artifact', 'curio', 'gear', 'weapon', 'armor')),
    "isEquipped" boolean NOT NULL DEFAULT false,
    "baseItem" text NOT NULL,
    "displayName" text,
    "dmgOverride" text,
    "descriptionOverride" text,
    "slotOverride" integer CHECK ("slotOverride" >= 0),
    "stackValue" integer CHECK ("stackValue" >= 0),
    "specialOverride" text,
    "createdDate" timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_inventory_instances_character_id ON inventory_instances(character_id);

CREATE TABLE path_instances (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id uuid NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    path_name text NOT NULL REFERENCES paths(name) ON DELETE CASCADE
);

CREATE INDEX idx_path_instances_character_id ON path_instances(character_id);

CREATE TABLE talent_instances (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id uuid NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    talent_name text NOT NULL REFERENCES talents(name) ON DELETE CASCADE
);

CREATE INDEX idx_talent_instances_character_id ON talent_instances(character_id);

CREATE TABLE tag_junctions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    weapon_id uuid REFERENCES weapons(id) ON DELETE CASCADE,
    armor_id uuid REFERENCES armor(id) ON DELETE CASCADE,
    inventory_instance_id uuid REFERENCES inventory_instances(id) ON DELETE CASCADE,
    special_value text,
    CHECK (
        weapon_id IS NOT NULL
        OR armor_id IS NOT NULL
        OR inventory_instance_id IS NOT NULL
    )
);

CREATE INDEX idx_tag_junctions_weapon_id ON tag_junctions(weapon_id);
CREATE INDEX idx_tag_junctions_armor_id ON tag_junctions(armor_id);
CREATE INDEX idx_tag_junctions_inventory_instance_id ON tag_junctions(inventory_instance_id);

CREATE TABLE destiny_tracker (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id uuid NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    completed_beats text NOT NULL DEFAULT '[]'
);

CREATE INDEX idx_destiny_tracker_character_id ON destiny_tracker(character_id);
