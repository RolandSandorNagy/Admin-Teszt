-- =========================================================
-- DATABASE SCRIPT (MySQL 8+)
-- =========================================================
-- 1) Create DB (optional)
-- CREATE DATABASE ci4_admin_test CHARACTER SET utf8mb4 COLLATE utf8mb4_hungarian_ci;
-- USE ci4_admin_test;

-- -------------------------
-- USERS (LOGIN)
-- -------------------------
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nickname VARCHAR(64) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY ux_users_nickname (nickname)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- -------------------------
-- MENUS (HIERARCHICAL)
-- -------------------------
CREATE TABLE IF NOT EXISTS menus (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(128) NOT NULL,
  url VARCHAR(255) NULL,
  parent_id BIGINT UNSIGNED NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_menus_parent
    FOREIGN KEY (parent_id) REFERENCES menus(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  KEY ix_menus_parent_sort (parent_id, sort_order),
  KEY ix_menus_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- -------------------------
-- EVENTS + TICKETS
-- -------------------------
CREATE TABLE IF NOT EXISTS esemenyek (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  starts_at DATETIME NOT NULL,
  venue VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_esemenyek_starts_at (starts_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

CREATE TABLE IF NOT EXISTS jegyek (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  esemeny_id BIGINT UNSIGNED NOT NULL,
  status ENUM('eladott','szabad','foglalt','nem_eladhato') NOT NULL DEFAULT 'szabad',
  price_gross DECIMAL(12,2) NOT NULL DEFAULT 0,
  reserved_until DATETIME NULL,
  sold_transaction_item_id BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_jegyek_esemeny
    FOREIGN KEY (esemeny_id) REFERENCES esemenyek(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  KEY ix_jegyek_esemeny_status (esemeny_id, status),
  KEY ix_jegyek_status (status),
  KEY ix_jegyek_reserved_until (reserved_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- -------------------------
-- TRANSACTIONS
-- -------------------------
CREATE TABLE IF NOT EXISTS tranzakciok (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('pending','successful','failed','refunded') NOT NULL DEFAULT 'pending',
  currency CHAR(3) NOT NULL DEFAULT 'HUF',
  total_gross DECIMAL(12,2) NOT NULL DEFAULT 0,
  customer_email VARCHAR(255) NULL,
  KEY ix_tr_status_created (status, created_at),
  KEY ix_tr_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

CREATE TABLE IF NOT EXISTS tranzakcio_elemek (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tranzakcio_id BIGINT UNSIGNED NOT NULL,
  item_type ENUM('ticket') NOT NULL DEFAULT 'ticket',
  jegy_id BIGINT UNSIGNED NULL,
  qty INT NOT NULL DEFAULT 1,
  unit_price_gross DECIMAL(12,2) NOT NULL DEFAULT 0,
  line_gross DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_tr_elem_tr
    FOREIGN KEY (tranzakcio_id) REFERENCES tranzakciok(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_tr_elem_jegy
    FOREIGN KEY (jegy_id) REFERENCES jegyek(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  KEY ix_tr_elem_tr (tranzakcio_id),
  KEY ix_tr_elem_jegy (jegy_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

CREATE TABLE IF NOT EXISTS tranzakcio_fizetesi_modok (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tranzakcio_id BIGINT UNSIGNED NOT NULL,
  fizetesi_mod ENUM('bankkartya','keszpenz','szepkartya','ajandekutalvany') NOT NULL,
  amount_gross DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_tr_pay_tr
    FOREIGN KEY (tranzakcio_id) REFERENCES tranzakciok(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  KEY ix_tr_pay_tr (tranzakcio_id),
  KEY ix_tr_pay_mode (fizetesi_mod),
  KEY ix_tr_pay_mode_tr (fizetesi_mod, tranzakcio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- =========================================================
-- DUMMY DATA
-- =========================================================

-- Menus
INSERT INTO menus (title, url, parent_id, sort_order) VALUES
('Dashboard', '/dashboard', NULL, 1),
('Események', NULL, NULL, 2),
('Esemény lista', '/events', 2, 1),
('Új esemény', '/events/create', 2, 2),
('Jegyek', NULL, NULL, 3),
('Jegyek lista', '/tickets', 5, 1);

-- Events
INSERT INTO esemenyek (name, starts_at, venue) VALUES
('Koncert A', '2026-01-10 19:00:00', 'Budapest'),
('Koncert B', '2026-02-05 20:00:00', 'Szeged'),
('Koncert C', '2026-02-20 18:00:00', 'Debrecen');

-- Tickets (sample)
INSERT INTO jegyek (esemeny_id, status, price_gross) VALUES
(1,'eladott',10000),(1,'eladott',10000),(1,'szabad',10000),(1,'foglalt',10000),
(2,'eladott',12000),(2,'szabad',12000),(2,'nem_eladhato',12000),
(3,'eladott',8000),(3,'eladott',8000),(3,'szabad',8000);

-- Transactions
INSERT INTO tranzakciok (created_at, status, total_gross, customer_email) VALUES
('2026-01-10 18:30:00','successful',20000,'a@a.hu'),
('2026-02-05 19:10:00','successful',12000,'b@b.hu'),
('2026-02-06 10:00:00','failed',   12000,'c@c.hu'),
('2026-02-20 17:40:00','successful',16000,'d@d.hu');

-- Transaction items
INSERT INTO tranzakcio_elemek (tranzakcio_id, item_type, jegy_id, qty, unit_price_gross, line_gross) VALUES
(1,'ticket',1,1,10000,10000),
(1,'ticket',2,1,10000,10000),
(2,'ticket',5,1,12000,12000),
(4,'ticket',8,1,8000,8000),
(4,'ticket',9,1,8000,8000);

-- Payments (multi-method supported)
INSERT INTO tranzakcio_fizetesi_modok (tranzakcio_id, fizetesi_mod, amount_gross) VALUES
(1,'bankkartya',15000),
(1,'ajandekutalvany',5000),
(2,'szepkartya',12000),
(4,'keszpenz',16000);

-- Optional: tie sold tickets to transaction items
UPDATE jegyek SET status='eladott', sold_transaction_item_id=1 WHERE id=1;
UPDATE jegyek SET status='eladott', sold_transaction_item_id=2 WHERE id=2;
UPDATE jegyek SET status='eladott', sold_transaction_item_id=3 WHERE id=5;
UPDATE jegyek SET status='eladott', sold_transaction_item_id=4 WHERE id=8;
UPDATE jegyek SET status='eladott', sold_transaction_item_id=5 WHERE id=9;

-- =========================================================
-- REQUIRED QUERIES
-- =========================================================

-- 1) Successful transactions in date range and how they were paid
SELECT
  p.fizetesi_mod,
  COUNT(DISTINCT t.id) AS successful_transactions
FROM tranzakciok t
JOIN tranzakcio_fizetesi_modok p ON p.tranzakcio_id = t.id
WHERE t.status = 'successful'
  AND t.created_at >= '2026-01-01 00:00:00'
  AND t.created_at <  '2026-03-01 00:00:00'
GROUP BY p.fizetesi_mod
ORDER BY successful_transactions DESC;

-- 2) Event utilization %
SELECT
  e.id,
  e.name,
  ROUND(
    100 * SUM(j.status='eladott') /
    NULLIF(SUM(j.status IN ('eladott','szabad','foglalt')), 0)
  , 2) AS kihasznaltsag_szazalek
FROM esemenyek e
JOIN jegyek j ON j.esemeny_id = e.id
GROUP BY e.id, e.name
ORDER BY kihasznaltsag_szazalek DESC;

-- 3) Daily sales count and gross revenue since 2026-01-01
SELECT
  DATE(t.created_at) AS nap,
  SUM(te.qty) AS eladott_db,
  SUM(te.line_gross) AS brutto_bevetel
FROM tranzakciok t
JOIN tranzakcio_elemek te ON te.tranzakcio_id = t.id
WHERE t.status='successful'
  AND t.created_at >= '2026-01-01 00:00:00'
GROUP BY DATE(t.created_at)
ORDER BY nap;

-- 4) Top 3 events by sold tickets
SELECT
  e.id,
  e.name,
  COUNT(*) AS eladott_jegyek
FROM esemenyek e
JOIN jegyek j ON j.esemeny_id = e.id
WHERE j.status='eladott'
GROUP BY e.id, e.name
ORDER BY eladott_jegyek DESC
LIMIT 3;
