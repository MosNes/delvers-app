import armorData from './armor_seed.json';

// manually recreated __dirname for use inside ESM module

// pass in env from index.js to give access to the DB object
export const seedArmor = async (env) => {
    // import JSON file containing record data
    // const filePath = new URL('./armor_seed.json', import.meta.url);
    // console.log("-------------FILE PATH-------------------",filePath);
    // const jsonString = readFileSync(filePath, 'utf8');

    const armorString = JSON.stringify(armorData)

    console.log("-------------------ARMOR STRING------------------------", armorString);

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
}
