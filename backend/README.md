# Backend – CodeIgniter 4 API

Ez a backend egy CodeIgniter 4 alapú REST API, amely a Vue 3 frontend számára biztosítja
az autentikációt, a dinamikus menürendszert, valamint a MySQL feladatban kért adatmodellt és lekérdezéseket.

---

# Technológia

- PHP 8+
- CodeIgniter 4
- MySQL 8 / MariaDB
- Session alapú autentikáció
- Globálisan engedélyezett CSRF védelem (SPA kompatibilis megoldással)

---

# Indítás

```bash
composer install
cp env .env
# Állítsd be az adatbázis kapcsolatot a .env fájlban
php spark serve
```

Alapértelmezett elérés:
```
http://localhost:8080
```

---

# API Felépítés

A backend JSON alapú REST API-kat biztosít:

- `POST /api/login`
- `POST /api/logout`
- `GET /api/me`
- `GET /api/menu`
- `POST /api/menu`
- `GET /api/csrf`

Az autentikáció session alapon történik.
Az admin végpontok csak bejelentkezett felhasználó számára érhetők el.

---

# CSRF védelem (SPA kompatibilis)

A CSRF globálisan engedélyezett a CodeIgniter filter rendszerében.

Mivel a frontend egy SPA alkalmazás, a backend biztosít egy külön CSRF token endpointot:

```
GET /api/csrf
```

Ez visszaadja az aktuális `csrf_hash()` értéket, amelyet a frontend minden nem-GET kéréshez
`X-CSRF-TOKEN` headerben küld vissza.

Ez stabil és framework-kompatibilis megoldás SPA környezetben.

---

# Adatmodell (MySQL)

Az adatbázis séma a `database.sql` fájlban található.

A modell célja, hogy:
- támogassa a több fizetési módos tranzakciókat
- kezelje az eseményekhez tartozó jegyek státuszát
- lehetővé tegye az eladási és kihasználtsági statisztikák számítását

---

## 1. users

A bejelentkezéshez szükséges tábla.

**Fő mezők:**
- `nickname` (unique)
- `password_hash`
- `is_active`

A jelszó bcrypt hash formában kerül tárolásra.

---

## 2. menus

Hierarchikus menürendszerhez szükséges tábla.

**Fontos mezők:**
- `parent_id` (önhivatkozó foreign key)
- `sort_order`
- `is_active`

A `parent_id` lehetővé teszi a tetszőleges mélységű, rekurzívan felépített menüstruktúrát.

Indexek:
- `(parent_id, sort_order)` gyors rendezéshez
- `is_active` gyors szűréshez

---

## 3. esemenyek

Az eseményeket tárolja.

**Fő mezők:**
- `name`
- `starts_at`
- `venue`

Index a `starts_at` mezőn az időalapú lekérdezésekhez.

---

## 4. jegyek

Az eseményekhez tartozó jegyeket tartalmazza.

**Fontos mezők:**
- `esemeny_id`
- `status` (ENUM: eladott, szabad, foglalt, nem_eladhato)
- `price_gross`
- `reserved_until`

A jegyek száma reprezentálja az esemény kapacitását.

Indexek:
- `(esemeny_id, status)`
- `status`
- `reserved_until`

---

## 5. tranzakciok

A vásárlásokat tárolja.

**Fő mezők:**
- `status` (pending, successful, failed, refunded)
- `created_at`
- `total_gross`

Indexek a státusz + dátum alapú lekérdezésekhez.

---

## 6. tranzakcio_elemek

Egy tranzakcióhoz tartozó tételek.

Kapcsolat:
- `tranzakcio_id` → tranzakciok
- `jegy_id` → jegyek

Lehetővé teszi a több jegyet tartalmazó vásárlásokat.

---

## 7. tranzakcio_fizetesi_modok

Több fizetési mód támogatása.

Egy tranzakció több sorral rendelkezhet ebben a táblában,
így megvalósul a több fizetési móddal történő kiegyenlítés.

---

# MySQL lekérdezések

A `database.sql` fájl végén találhatók a feladatban kért lekérdezések:

1. Sikeres tranzakciók fizetési mód szerinti bontásban
2. Események kihasználtsága százalékban
3. Napi eladási statisztika
4. Top 3 esemény eladott jegyek alapján

---

# Tervezési döntések

- Normalizált adatmodell
- Idegen kulcsokkal biztosított integritás
- Lekérdezésekhez optimalizált indexelés
- Több fizetési mód támogatás
- ENUM mezők a státuszokhoz (egyszerű és hatékony kezelés)

A cél egy tiszta, jól strukturált, tesztelhető adatmodell volt,
amely megfelel a feladatban megadott riportolási igényeknek.
