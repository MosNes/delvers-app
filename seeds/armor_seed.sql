-- seeds initial armor records
INSERT INTO armor (id, name, description, cost, slots, special, tags, isMinor, armor_value)
VALUES
(1, 'Delver''s Outfit', 'Hardy travel and exploration outfit with Academy livery.',0,0,NULL,'[]',1,0),
(2, 'Light Armor','Protective garments of leather and heavy cloth. Light and flexible.',1,1,NULL,'[]',0,1),
(3, 'Medium Armor', 'Light armor reinforced with scale or chain mail and small metal plates and a helmet.',1,2,NULL, '["Bulky"]', 0, 2),
(4, 'Heavy Armor', 'Metal plate armor and helm.',2, 2, 'Cannot benefit from long rests while wearing, takes a few minutes to don and doff. Only available to 2nd years and above.',
'["Bulky"]',0, 3)