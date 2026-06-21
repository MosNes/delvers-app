-- =============================================================================
-- Row Level Security (Supabase)
-- Policies use auth.uid() (matches public.user_profiles.auth_id and characters.owner).
-- Campaign peers: read-only SELECT on characters and linked instance/tracker/junction rows.
-- Reference catalog tables: authenticated read-only.
-- Campaign owners (campaign_owner) have full CRUD on their campaigns; participants have read-only SELECT.
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
ALTER TABLE beats ENABLE ROW LEVEL SECURITY;
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
-- campaigns: owner full access; participants read-only
-- -----------------------------------------------------------------------------
CREATE POLICY "campaigns_select_owner"
    ON campaigns FOR SELECT
    TO authenticated
    USING (campaign_owner = auth.uid());

CREATE POLICY "campaigns_insert_owner"
    ON campaigns FOR INSERT
    TO authenticated
    WITH CHECK (campaign_owner = auth.uid());

CREATE POLICY "campaigns_update_owner"
    ON campaigns FOR UPDATE
    TO authenticated
    USING (campaign_owner = auth.uid())
    WITH CHECK (campaign_owner = auth.uid());

CREATE POLICY "campaigns_delete_owner"
    ON campaigns FOR DELETE
    TO authenticated
    USING (campaign_owner = auth.uid());

CREATE POLICY "campaigns_select_participant"
    ON campaigns FOR SELECT
    TO authenticated
    USING (public.user_participates_in_campaign(id));

-- -----------------------------------------------------------------------------
-- Reference catalog: authenticated read-only
-- -----------------------------------------------------------------------------
CREATE POLICY "destinies_select_authenticated"
    ON destinies FOR SELECT TO authenticated USING (true);

CREATE POLICY "beats_select_authenticated"
    ON beats FOR SELECT TO authenticated USING (true);

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

-- =============================================================================
-- Table-level GRANT statements
-- "permission denied for table X" means the role lacks a basic GRANT —
-- this fires before RLS even runs and has nothing to do with policies.
-- Tables created via raw SQL bypass Supabase's automatic grant setup, so
-- grants must be applied explicitly.
--
-- Run these once in the Supabase SQL editor after applying this file, or
-- include them in your migration. The ALTER DEFAULT PRIVILEGES line covers
-- any tables added in future migrations.
-- =============================================================================

-- User-owned tables: full CRUD for authenticated
GRANT SELECT, INSERT, UPDATE, DELETE ON user_profiles        TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON campaigns            TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON characters           TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON advances             TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON inventory_instances  TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON path_instances       TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON talent_instances     TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON tag_junctions        TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON destiny_tracker      TO authenticated;

-- Reference / catalog tables: read-only for authenticated and anon
GRANT SELECT ON armor           TO authenticated, anon;
GRANT SELECT ON artifacts       TO authenticated, anon;
GRANT SELECT ON beats           TO authenticated, anon;
GRANT SELECT ON curios          TO authenticated, anon;
GRANT SELECT ON destinies       TO authenticated, anon;
GRANT SELECT ON fighting_styles TO authenticated, anon;
GRANT SELECT ON gear            TO authenticated, anon;
GRANT SELECT ON paths           TO authenticated, anon;
GRANT SELECT ON rituals         TO authenticated, anon;
GRANT SELECT ON tags            TO authenticated, anon;
GRANT SELECT ON talents         TO authenticated, anon;
GRANT SELECT ON weapons         TO authenticated, anon;

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
