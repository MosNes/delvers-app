// import JSON files with seed data
import armorData from './armor_seed.json';

// pass in env from index.js to give access to the DB object
export const seedArmor = async (env) => {

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
        throw new Error("Error in seedArmor(): ", err);
    }
};

export const seedWeapon = async (env) => {
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
        throw new Error("Error in seedWeapon(): " + err.message);
    }
};

export const seedGear = async (env) => {
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
        throw new Error("Error in seedGear(): " + err.message);
    }
};

export const seedCurio = async (env) => {
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
        throw new Error("Error in seedCurio(): " + err.message);
    }
};

export const seedArtifact = async (env) => {
    const artifactString = JSON.stringify(artifactData);
    try {
        const result = await env.DB.prepare(`
        INSERT INTO artifacts (id, name, source, description, effect, slots, hasDepletion, depletionDie, depletionResult, isMinor)
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
        throw new Error("Error in seedArtifact(): " + err.message);
    }
};