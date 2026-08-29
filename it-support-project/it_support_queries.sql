-- ============================================
-- IT Support Ticket Analysis - Schema & KPI Queries
-- Author: [Ad Soyad]
-- Database: PostgreSQL (it_support)
-- ============================================


-- ============================================
-- SECTION 1: SCHEMA
-- ============================================
CREATE TABLE agents (
    agent_id     VARCHAR(10) PRIMARY KEY,
    agent_name   VARCHAR(100),
    team         VARCHAR(50),
    location     VARCHAR(50)
);


CREATE TABLE tickets (
    ticket_id            VARCHAR(15),
    opened_at            TIMESTAMP,
    closed_at            TIMESTAMP,
    category             VARCHAR(50),
    priority             VARCHAR(20),
    status               VARCHAR(20),
    sla_target_hours     INTEGER,
    resolution_hours     NUMERIC(8,1),
    satisfaction_score   NUMERIC(3,0),
    channel              VARCHAR(20),
    requester_department VARCHAR(50),
    agent_id             VARCHAR(10) REFERENCES agents(agent_id)
);


-- ============================================
-- SECTION 2: DATA LOAD CHECKS (after CSV import)
-- ============================================
SELECT COUNT(*) FROM tickets;                        -- should be 5040 
SELECT COUNT(*) FROM tickets WHERE closed_at IS NULL; -- ~175 open ticket
SELECT COUNT(*) FROM tickets;                         -- 5040
SELECT COUNT(DISTINCT ticket_id) FROM tickets;        -- 5000 -> 40 duplicates found!


-- ============================================
-- SECTION 3: CLEANING (fix empty strings)
-- ============================================
UPDATE tickets SET channel = NULL WHERE channel = '';

-- ============================================
-- SECTION 4: KPI QUERIES
-- ============================================

-- 1) Ticket count by priority (Öncelik başına ticket sayısı)
SELECT priority, COUNT(*) AS total_tickets
FROM tickets
GROUP BY priority
ORDER BY total_tickets DESC;

-- 2) Average resolution time by category (Kategori bazında ortalama çözüm süresi (saat))
SELECT category, ROUND(AVG(resolution_hours), 1) AS avg_resolution_h
FROM tickets
WHERE resolution_hours IS NOT NULL
GROUP BY category
ORDER BY avg_resolution_h DESC;

-- 3)Overall SLA compliance (%) ( Genel SLA uyum oranı (%))
SELECT ROUND(100.0 * SUM(CASE WHEN resolution_hours <= sla_target_hours
                              THEN 1 ELSE 0 END) / COUNT(*), 1) AS sla_met_pct
FROM tickets
WHERE resolution_hours IS NOT NULL;









