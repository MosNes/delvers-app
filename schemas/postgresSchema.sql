-- PostgreSQL / Supabase schema
-- Converted from schemas/schema.sql (Cloudflare D1 / SQLite)

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

-- Indexes for faster queries on the characters table
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
    talent_name text NOT NULL REFERENCES talents(name) ON DELETE CASCADE
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
    completed_beats text NOT NULL DEFAULT '[]'
);

-- Indexes for faster queries on the destiny_tracker table, e.g. finding the destiny tracker for a character
CREATE INDEX idx_destiny_tracker_character_id ON destiny_tracker(character_id);

-- =============================================================================
-- Supabase Auth → public.user_profiles sync (runs on sign-up / first OAuth identity creation)
-- =============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.user_profiles (auth_id, email, name)
    VALUES (
        NEW.id,
        NEW.email::citext,
        COALESCE(NEW.raw_user_meta_data->>'name', '')
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        name = COALESCE(NULLIF(EXCLUDED.name, ''), public.user_profiles.name);
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- Row Level Security (Supabase)
-- Policies use auth.uid() (matches public.user_profiles.auth_id and characters.owner).
-- Campaign peers: read-only SELECT on characters and linked instance/tracker/junction rows.
-- Reference catalog tables: authenticated read-only.
-- Campaign owner CRUD on campaigns is not included; use service_role or add policies later.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.user_owns_character(character_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM characters c
        WHERE c.id = character_uuid
          AND c.owner = auth.uid()
    );
$$;

-- User has at least one character in the given campaign
CREATE OR REPLACE FUNCTION public.user_participates_in_campaign(campaign_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM characters c
        WHERE c.campaign = campaign_uuid
          AND c.owner = auth.uid()
    );
$$;

-- Another user's character is visible when both share a non-null campaign
CREATE OR REPLACE FUNCTION public.user_shares_campaign_with_character(target_character_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM characters target
        WHERE target.id = target_character_uuid
          AND target.campaign IS NOT NULL
          AND EXISTS (
              SELECT 1
              FROM characters mine
              WHERE mine.owner = auth.uid()
                AND mine.campaign = target.campaign
          )
    );
$$;

CREATE OR REPLACE FUNCTION public.user_owns_inventory_instance(instance_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM inventory_instances ii
        WHERE ii.id = instance_uuid
          AND public.user_owns_character(ii.character_id)
    );
$$;

-- Inventory instance belongs to a character in a campaign the current user shares
CREATE OR REPLACE FUNCTION public.user_shares_campaign_with_inventory_instance(instance_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM inventory_instances ii
        WHERE ii.id = instance_uuid
          AND public.user_shares_campaign_with_character(ii.character_id)
    );
$$;

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE characters ENABLE ROW LEVEL SECURITY;
ALTER TABLE destinies ENABLE ROW LEVEL SECURITY;
ALTER TABLE paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE talents ENABLE ROW LEVEL SECURITY;
ALTER TABLE advances ENABLE ROW LEVEL SECURITY;
ALTER TABLE fighting_styles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rituals ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE gear ENABLE ROW LEVEL SECURITY;
ALTER TABLE armor ENABLE ROW LEVEL SECURITY;
ALTER TABLE weapons ENABLE ROW LEVEL SECURITY;
ALTER TABLE curios ENABLE ROW LEVEL SECURITY;
ALTER TABLE artifacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE path_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE talent_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE tag_junctions ENABLE ROW LEVEL SECURITY;
ALTER TABLE destiny_tracker ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- user_profiles: full access to own row (auth_id = auth.uid())
-- -----------------------------------------------------------------------------
CREATE POLICY "user_profiles_select_own"
    ON user_profiles FOR SELECT
    TO authenticated
    USING (auth_id = auth.uid());

CREATE POLICY "user_profiles_insert_own"
    ON user_profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth_id = auth.uid());

CREATE POLICY "user_profiles_update_own"
    ON user_profiles FOR UPDATE
    TO authenticated
    USING (auth_id = auth.uid())
    WITH CHECK (auth_id = auth.uid());

CREATE POLICY "user_profiles_delete_own"
    ON user_profiles FOR DELETE
    TO authenticated
    USING (auth_id = auth.uid());

-- -----------------------------------------------------------------------------
-- characters: full access to rows where owner = auth.uid()
-- -----------------------------------------------------------------------------
CREATE POLICY "characters_select_own"
    ON characters FOR SELECT
    TO authenticated
    USING (owner = auth.uid());

CREATE POLICY "characters_insert_own"
    ON characters FOR INSERT
    TO authenticated
    WITH CHECK (owner = auth.uid());

CREATE POLICY "characters_update_own"
    ON characters FOR UPDATE
    TO authenticated
    USING (owner = auth.uid())
    WITH CHECK (owner = auth.uid());

CREATE POLICY "characters_delete_own"
    ON characters FOR DELETE
    TO authenticated
    USING (owner = auth.uid());

-- Read-only: other players' characters in a shared campaign
CREATE POLICY "characters_select_campaign_peers"
    ON characters FOR SELECT
    TO authenticated
    USING (public.user_shares_campaign_with_character(id));

-- Leaving a campaign: owner may set campaign to NULL (full update policy above also applies)
CREATE POLICY "characters_leave_campaign"
    ON characters FOR UPDATE
    TO authenticated
    USING (owner = auth.uid())
    WITH CHECK (
        owner = auth.uid()
        AND campaign IS NULL
    );

-- -----------------------------------------------------------------------------
-- campaigns: read-only for campaigns the user has a character in
-- -----------------------------------------------------------------------------
CREATE POLICY "campaigns_select_participant"
    ON campaigns FOR SELECT
    TO authenticated
    USING (public.user_participates_in_campaign(id));

-- -----------------------------------------------------------------------------
-- Reference catalog: authenticated read-only
-- -----------------------------------------------------------------------------
CREATE POLICY "destinies_select_authenticated"
    ON destinies FOR SELECT TO authenticated USING (true);

CREATE POLICY "paths_select_authenticated"
    ON paths FOR SELECT TO authenticated USING (true);

CREATE POLICY "talents_select_authenticated"
    ON talents FOR SELECT TO authenticated USING (true);

CREATE POLICY "advances_select_authenticated"
    ON advances FOR SELECT TO authenticated USING (true);

CREATE POLICY "fighting_styles_select_authenticated"
    ON fighting_styles FOR SELECT TO authenticated USING (true);

CREATE POLICY "rituals_select_authenticated"
    ON rituals FOR SELECT TO authenticated USING (true);

CREATE POLICY "tags_select_authenticated"
    ON tags FOR SELECT TO authenticated USING (true);

CREATE POLICY "gear_select_authenticated"
    ON gear FOR SELECT TO authenticated USING (true);

CREATE POLICY "armor_select_authenticated"
    ON armor FOR SELECT TO authenticated USING (true);

CREATE POLICY "weapons_select_authenticated"
    ON weapons FOR SELECT TO authenticated USING (true);

CREATE POLICY "curios_select_authenticated"
    ON curios FOR SELECT TO authenticated USING (true);

CREATE POLICY "artifacts_select_authenticated"
    ON artifacts FOR SELECT TO authenticated USING (true);

-- -----------------------------------------------------------------------------
-- Character-scoped instance tables (via user_owns_character)
-- -----------------------------------------------------------------------------
CREATE POLICY "inventory_instances_select_own"
    ON inventory_instances FOR SELECT
    TO authenticated
    USING (public.user_owns_character(character_id));

CREATE POLICY "inventory_instances_insert_own"
    ON inventory_instances FOR INSERT
    TO authenticated
    WITH CHECK (public.user_owns_character(character_id));

CREATE POLICY "inventory_instances_update_own"
    ON inventory_instances FOR UPDATE
    TO authenticated
    USING (public.user_owns_character(character_id))
    WITH CHECK (public.user_owns_character(character_id));

CREATE POLICY "inventory_instances_delete_own"
    ON inventory_instances FOR DELETE
    TO authenticated
    USING (public.user_owns_character(character_id));

CREATE POLICY "path_instances_select_own"
    ON path_instances FOR SELECT
    TO authenticated
    USING (public.user_owns_character(character_id));

CREATE POLICY "path_instances_insert_own"
    ON path_instances FOR INSERT
    TO authenticated
    WITH CHECK (public.user_owns_character(character_id));

CREATE POLICY "path_instances_update_own"
    ON path_instances FOR UPDATE
    TO authenticated
    USING (public.user_owns_character(character_id))
    WITH CHECK (public.user_owns_character(character_id));

CREATE POLICY "path_instances_delete_own"
    ON path_instances FOR DELETE
    TO authenticated
    USING (public.user_owns_character(character_id));

CREATE POLICY "talent_instances_select_own"
    ON talent_instances FOR SELECT
    TO authenticated
    USING (public.user_owns_character(character_id));

CREATE POLICY "talent_instances_insert_own"
    ON talent_instances FOR INSERT
    TO authenticated
    WITH CHECK (public.user_owns_character(character_id));

CREATE POLICY "talent_instances_update_own"
    ON talent_instances FOR UPDATE
    TO authenticated
    USING (public.user_owns_character(character_id))
    WITH CHECK (public.user_owns_character(character_id));

CREATE POLICY "talent_instances_delete_own"
    ON talent_instances FOR DELETE
    TO authenticated
    USING (public.user_owns_character(character_id));

CREATE POLICY "destiny_tracker_select_own"
    ON destiny_tracker FOR SELECT
    TO authenticated
    USING (public.user_owns_character(character_id));

CREATE POLICY "destiny_tracker_insert_own"
    ON destiny_tracker FOR INSERT
    TO authenticated
    WITH CHECK (public.user_owns_character(character_id));

CREATE POLICY "destiny_tracker_update_own"
    ON destiny_tracker FOR UPDATE
    TO authenticated
    USING (public.user_owns_character(character_id))
    WITH CHECK (public.user_owns_character(character_id));

CREATE POLICY "destiny_tracker_delete_own"
    ON destiny_tracker FOR DELETE
    TO authenticated
    USING (public.user_owns_character(character_id));

-- -----------------------------------------------------------------------------
-- Campaign peers: read-only access to party members' instance / tracker rows
-- (same campaign as one of the current user's characters; campaign must be set)
-- -----------------------------------------------------------------------------
CREATE POLICY "inventory_instances_select_campaign_peers"
    ON inventory_instances FOR SELECT
    TO authenticated
    USING (public.user_shares_campaign_with_character(character_id));

CREATE POLICY "path_instances_select_campaign_peers"
    ON path_instances FOR SELECT
    TO authenticated
    USING (public.user_shares_campaign_with_character(character_id));

CREATE POLICY "talent_instances_select_campaign_peers"
    ON talent_instances FOR SELECT
    TO authenticated
    USING (public.user_shares_campaign_with_character(character_id));

CREATE POLICY "destiny_tracker_select_campaign_peers"
    ON destiny_tracker FOR SELECT
    TO authenticated
    USING (public.user_shares_campaign_with_character(character_id));

-- -----------------------------------------------------------------------------
-- tag_junctions: full access when linked to own inventory instance
-- -----------------------------------------------------------------------------
CREATE POLICY "tag_junctions_select_own_inventory"
    ON tag_junctions FOR SELECT
    TO authenticated
    USING (
        inventory_instance_id IS NOT NULL
        AND public.user_owns_inventory_instance(inventory_instance_id)
    );

CREATE POLICY "tag_junctions_select_campaign_peers_inventory"
    ON tag_junctions FOR SELECT
    TO authenticated
    USING (
        inventory_instance_id IS NOT NULL
        AND public.user_shares_campaign_with_inventory_instance(inventory_instance_id)
    );

CREATE POLICY "tag_junctions_insert_own_inventory"
    ON tag_junctions FOR INSERT
    TO authenticated
    WITH CHECK (
        inventory_instance_id IS NOT NULL
        AND public.user_owns_inventory_instance(inventory_instance_id)
    );

CREATE POLICY "tag_junctions_update_own_inventory"
    ON tag_junctions FOR UPDATE
    TO authenticated
    USING (
        inventory_instance_id IS NOT NULL
        AND public.user_owns_inventory_instance(inventory_instance_id)
    )
    WITH CHECK (
        inventory_instance_id IS NOT NULL
        AND public.user_owns_inventory_instance(inventory_instance_id)
    );

CREATE POLICY "tag_junctions_delete_own_inventory"
    ON tag_junctions FOR DELETE
    TO authenticated
    USING (
        inventory_instance_id IS NOT NULL
        AND public.user_owns_inventory_instance(inventory_instance_id)
    );
