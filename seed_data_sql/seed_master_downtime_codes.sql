-- Seed data for master.downtime_codes

BEGIN;

TRUNCATE TABLE master.downtime_codes RESTART IDENTITY CASCADE;

INSERT INTO master.downtime_codes
(down_id, down_code, description, category, threshold_sec, created_at)
VALUES
(1,  'No load',                         'Machine idle - no job',              'PROD',   600,  NOW()),
(2,  'Programming correction/Transfer', 'Program correction/transfer',        'PROD',   900,  NOW()),
(3,  'Insert index/Replacement',        'Insert indexing/replacement',        'TOOL',   300,  NOW()),
(4,  'Machine Breakdown',               'Mechanical/electrical failure',      'BRKD',  1200,  NOW()),
(5,  'No operator',                     'Operator unavailable',               'MAN',    600,  NOW()),
(6,  'Tool/Insert related problems',    'Tool or insert failure',             'TOOL',   600,  NOW()),
(7,  'Lunch/Breakfast',                 'Scheduled break',                    'PLAN',  1800,  NOW()),
(8,  'Spare & Consumables',             'Waiting for spares/consumables',     'MATL',   900,  NOW()),
(9,  'Power failure',                   'Power supply interruption',          'UTIL',  1200,  NOW()),
(10, 'Development',                     'Trial/development activity',         'DEV',    900,  NOW()),
(11, '2 Machine operating',             'Operator handling two machines',     'MAN',    600,  NOW()),
(12, 'Autonomous maintenance',          'Operator maintenance activity',      'MAINT',  900,  NOW()),
(13, 'Planned idle',                    'Scheduled idle time',                'PLAN',   900,  NOW()),
(14, 'Inspection',                      'Quality inspection',                 'MAINT',  600,  NOW()),
(15, 'Part cleaning/Other',             'Part cleaning/misc activity',        'PROD',   600,  NOW()),
(16, 'Preventive maintenance',          'Scheduled preventive maintenance',   'MAINT', 1200,  NOW());

-- Ensure sequence alignment
SELECT setval(
    pg_get_serial_sequence('master.downtime_codes', 'down_id'),
    (SELECT MAX(down_id) FROM master.downtime_codes)
);

COMMIT;
