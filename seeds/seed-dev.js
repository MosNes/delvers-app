// import env for env.DB Binding for any functions that need access to DB
import { env } from "cloudflare:workers";

// import JSON files with seed data
import armorData from './armor_seed.json';
import weaponData from './weapon_seed.json';
import tagData from './tag_seed.json';
import gearData from './gear_seed.json';
import curioData from './curio_seed.json';
import artifactData from './artifact_seed.json';
import talentData from './talent_seed.json';

//--------------------------------------INVENTORY ITEMS----------------------------------------------------------

// pass in env from index.js to give access to the DB object
export const seedArmor = async () => {

    // stringify seed data
    const armorString = JSON.stringify(armorData);

    try {
        // use json_extract() method to seed each row of the table by looping over the JSON file
        const result = await env.DB.prepare(`
        INSERT INTO armor (name, description, cost, slots, special, tags, isMinor, armor_value)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.description'),
            json_extract(value, '$.cost'),
            json_extract(value, '$.slots'),
            json_extract(value, '$.special'),
            json_extract(value, '$.tags'),
            json_extract(value, '$.isMinor'),
            json_extract(value, '$.armor_value')

        FROM json_each(?1)
        `).bind(armorString).run();

        return result;
    } catch (err) {
        throw new Error("Error in seedArmor(): ",err);
    }
};

export const seedWeapon = async () => {
    const weaponString = JSON.stringify(weaponData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO weapons (name, description, baseDmg, cost, slots, special, tags, isMinor, armor)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.description'),
            json_extract(value, '$.baseDmg'),
            json_extract(value, '$.cost'),
            json_extract(value, '$.slots'),
            json_extract(value, '$.special'),
            json_extract(value, '$.tags'),
            json_extract(value, '$.isMinor'),
            json_extract(value, '$.armor')
        FROM json_each(?1)
        `).bind(weaponString).run();
        return result;
    } catch (err) {
        throw new Error("Error in seedWeapon(): " +err);
    }
};

export const seedGear = async () => {
    const gearString = JSON.stringify(gearData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO gear (name, description, effect, cost, slots, special, stack, isMinor, hasClock, clockValue)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.description'),
            json_extract(value, '$.effect'),
            json_extract(value, '$.cost'),
            json_extract(value, '$.slots'),
            json_extract(value, '$.special'),
            json_extract(value, '$.stack'),
            json_extract(value, '$.isMinor'),
            json_extract(value, '$.hasClock'),
            json_extract(value, '$.clockValue')
        FROM json_each(?1)
        `).bind(gearString).run();
        return result;
    } catch (err) {
        throw new Error("Error in seedGear(): " +err);
    }
};

export const seedCurio = async () => {
    const curioString = JSON.stringify(curioData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO curios (name, source, description, effect, slots)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.source'), 
            json_extract(value, '$.description'),
            json_extract(value, '$.effect'),
            json_extract(value, '$.slots')
        FROM json_each(?1)
        `).bind(curioString).run();
        return result;
    } catch (err) {
        throw new Error("Error in seedCurio(): " +err);
    }
};

export const seedArtifact = async () => {
    const artifactString = JSON.stringify(artifactData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO artifacts (name, source, description, effect, slots, hasDepletion, depletionDie, depletionResult, isMinor)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.source'), 
            json_extract(value, '$.description'),
            json_extract(value, '$.effect'),
            json_extract(value, '$.slots'),
            json_extract(value, '$.hasDepletion'),
            json_extract(value, '$.depletionDie'),
            json_extract(value, '$.depletionResult'),
            json_extract(value, '$.isMinor')
        FROM json_each(?1)
        `).bind(artifactString).run();
        return result;
    } catch (err) {
        throw new Error("Error in seedArtifact(): " +err);
    }
};

//--------------------------------------PATHS, TALENTS, DESTINIES----------------------------------------------------------

export const seedPath = async () => {
    const pathString = JSON.stringify(pathData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO paths (name, description, flavorText, isForbidden, isAncestry)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.description'),
            json_extract(value, '$.flavorText'),
            json_extract(value, '$.isForbidden'),
            json_extract(value, '$.isAncestry')
        FROM json_each(?1)
        `).bind(pathString).run();
        return result;
    } catch (err) {
        throw new Error("Error in seedPath(): " +err);
    }
};

// need to make sure path_name aligns with paths inserted in previous step
export const seedTalent = async () => {
    const talentString = JSON.stringify(talentData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO talents (name, description, flavorText, path_name, picklistValues, picklistHasObj, isRepeatable, type, hasPicklist)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.description'),
            json_extract(value, '$.flavorText'),
            json_extract(value, '$.path_name'),
            json_extract(value, '$.picklistValues'),
            json_extract(value, '$.picklistHasObj'),
            json_extract(value, '$.isRepeatable'),
            json_extract(value, '$.type'),
            json_extract(value, '$.hasPicklist')
        FROM json_each(?1)
        `).bind(talentString).run();
        return result;
    } catch (err) {
        throw new Error("Error in seedTalent(): " +err);
    }
};

export const seedDestiny = async () => {
    const destinyString = JSON.stringify(destinyData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO destinies (name, description)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.description')
        FROM json_each(?1)
        `).bind(destinyString).run();
        return result;
    } catch (err) {
        throw new Error("Error in seedDestiny(): " +err);
    }
};

export const seedTag = async () => {
    const tagString = JSON.stringify(tagData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO tags (name, description, hasSpecialValue)
        SELECT 
            json_extract(value, '$.name'), 
            json_extract(value, '$.description'),
            json_extract(value, '$.hasSpecialValue')
        FROM json_each(?1)
        `).bind(tagString).run();
        return result;
    } catch (err) {
        throw new Error("Error in seedTag(): " +err);
    }
};

// #region agent log
fetch('http://127.0.0.1:7404/ingest/2d4e9d71-11c8-44e4-9942-b525874d6801',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'6de2c2'},body:JSON.stringify({sessionId:'6de2c2',location:'seed-dev.js:module-tail',message:'seed-dev finished evaluating',data:{typeofSeedTalent:typeof seedTalent,typeofSeedPath:typeof seedPath,typeofSeedDestiny:typeof seedDestiny},timestamp:Date.now(),hypothesisId:'H1'})}).catch(()=>{});
// #endregion
