-- PostgreSQL / Supabase schema
-- Converted from schemas/schema.sql (Cloudflare D1 / SQLite)
-- WARNING: Drops and recreates all public app tables. Destroys existing data.

-- Auth triggers (recreated below)
DROP TRIGGER IF EXISTS on_auth_user_email_updated ON auth.users;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Tables (children first; CASCADE clears remaining FK dependencies)
DROP TABLE IF EXISTS
    tag_junctions,
    destiny_tracker,
    talent_instances,
    path_instances,
    inventory_instances,
    characters,
    campaigns,
    advances,
    talents,
    paths,
    gear,
    armor,
    weapons,
    curios,
    artifacts,
    fighting_styles,
    rituals,
    tags,
    beats,
    destinies,
    user_profiles
CASCADE;

-- Extensions (enable in Supabase SQL editor if not already present)
CREATE EXTENSION IF NOT EXISTS "citext";

-- 1. USER PROFILES (Parent Table) — linked to Supabase Auth via auth_id
CREATE TABLE user_profiles (
    auth_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email citext NOT NULL UNIQUE,
    name text,
    "createdDate" timestamptz NOT NULL DEFAULT now()
);

-- 2. CAMPAIGNS (Parent of Characters)
CREATE TABLE campaigns (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_owner uuid NOT NULL REFERENCES user_profiles(auth_id) ON DELETE CASCADE,
    "shareCode" text NOT NULL UNIQUE,
    name text NOT NULL,
    description text,
    "createdDate" timestamptz NOT NULL DEFAULT now()
);

-- 3. CHARACTERS (Parent of all instances and trackers)
CREATE TABLE characters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    owner uuid NOT NULL REFERENCES user_profiles(auth_id) ON DELETE CASCADE,
    campaign uuid REFERENCES campaigns(id) ON DELETE SET NULL,
    "imgUrl" text,
    "characterName" text NOT NULL,
    player text NOT NULL,
    ancestry text NOT NULL,
    "ancestrySpecies" text NOT NULL,
    path text NOT NULL,
    background text,
    domains jsonb,
    skills jsonb,
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

-- Indexes for faster queries on the characters table
CREATE INDEX idx_characters_owner ON characters(owner);
CREATE INDEX idx_characters_campaign ON characters(campaign);

-- 4. BASE DATA TABLES
CREATE TABLE destinies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text
);

CREATE TABLE beats (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type text NOT NULL CHECK (type IN ('Minor', 'Major', 'Pinnacle')),
    destiny_id uuid NOT NULL REFERENCES destinies(id) ON DELETE CASCADE,
    description text
);

-- Index for faster lookups of beats by destiny
CREATE INDEX idx_beats_destiny_id ON beats(destiny_id);

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
    tags jsonb,
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
    tags jsonb,
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
    "item_config" jsonb NOT NULL DEFAULT '{}'::jsonb,
    "createdDate" timestamptz NOT NULL DEFAULT now()
);

-- Indexes for faster queries on the inventory_instances table, e.g. finding all inventory items for a character
CREATE INDEX idx_inventory_instances_character_id ON inventory_instances(character_id);

CREATE TABLE path_instances (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id uuid NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    path_name text NOT NULL REFERENCES paths(name) ON DELETE CASCADE
);

-- Indexes for faster queries on the path_instances table, e.g. finding all path instances for a character
CREATE INDEX idx_path_instances_character_id ON path_instances(character_id);

CREATE TABLE talent_instances (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id uuid NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    talent_name text NOT NULL REFERENCES talents(name) ON DELETE CASCADE,
    value jsonb DEFAULT NULL
);

-- Indexes for faster queries on the talent_instances table, e.g. finding all talent instances for a character
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

-- Indexes for faster queries on the tag_junctions table, e.g. finding all tag junctions for a weapon, armor, or inventory instance
CREATE INDEX idx_tag_junctions_weapon_id ON tag_junctions(weapon_id);
CREATE INDEX idx_tag_junctions_armor_id ON tag_junctions(armor_id);
CREATE INDEX idx_tag_junctions_inventory_instance_id ON tag_junctions(inventory_instance_id);

CREATE TABLE destiny_tracker (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id uuid NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    destiny text,                      -- currently selected destiny (by name); intentionally NOT a FK
    completed_beats jsonb NOT NULL DEFAULT '[]'::jsonb,  -- array of beat objects, may span multiple destinies
    UNIQUE (character_id)              -- one tracker per character → enables upsert on conflict
);

-- Indexes for faster queries on the destiny_tracker table, e.g. finding the destiny tracker for a character
CREATE INDEX idx_destiny_tracker_character_id ON destiny_tracker(character_id);

-- =============================================================================
-- Supabase Auth → public.user_profiles sync
-- A profile row is created only when auth.users has a non-empty email (required on user_profiles).
-- =============================================================================
CREATE OR REPLACE FUNCTION public.upsert_user_profile_from_auth(
    p_auth_id uuid,
    p_email text,
    p_name text DEFAULT ''
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF p_email IS NULL OR btrim(p_email) = '' THEN
        RETURN;
    END IF;

    INSERT INTO public.user_profiles (auth_id, email, name)
    VALUES (
        p_auth_id,
        btrim(p_email)::citext,
        COALESCE(NULLIF(btrim(p_name), ''), '')
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        name = COALESCE(NULLIF(EXCLUDED.name, ''), public.user_profiles.name);
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM public.upsert_user_profile_from_auth(
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', '')
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_auth_user_email_updated()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM public.upsert_user_profile_from_auth(
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', '')
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER on_auth_user_email_updated
    AFTER UPDATE OF email ON auth.users
    FOR EACH ROW
    WHEN (
        NEW.email IS NOT NULL
        AND btrim(NEW.email) <> ''
        AND (OLD.email IS NULL OR btrim(OLD.email) = '' OR OLD.email IS DISTINCT FROM NEW.email)
    )
    EXECUTE FUNCTION public.handle_auth_user_email_updated();

