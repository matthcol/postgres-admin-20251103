# Statistiques PostgreSQL
Sélectivité = nombre de valeurs distinctes / nombre total de lignes

Sélectivité entre 0 et 1 => 1 = Unique, tend vers 0 si tt le temps la meme

En PostgreSQL, les statistiques de sélectivité sont dans plusieurs vues système (recap de Claude AI):

## 1. `pg_stats` - Vue principale (recommandée)

```sql
SELECT 
    tablename,
    attname AS column_name,
    n_distinct,  -- Nombre de valeurs distinctes (estimé)
    null_frac,   -- Fraction de valeurs NULL
    avg_width,   -- Largeur moyenne en bytes
    correlation  -- Corrélation physique
FROM pg_stats
WHERE tablename = 'ma_table'
  AND schemaname = 'public';
```

## 2. Calcul de la sélectivité

```sql
-- Sélectivité réelle (calcul exact)
SELECT 
    attname,
    n_distinct,
    CASE 
        WHEN n_distinct > 0 THEN n_distinct / (SELECT reltuples FROM pg_class WHERE relname = 'ma_table')
        WHEN n_distinct < 0 THEN ABS(n_distinct)  -- Négatif = proportion
        ELSE NULL
    END AS selectivite
FROM pg_stats
WHERE tablename = 'ma_table'
  AND schemaname = 'public';
```

## 3. Détails avec `pg_class`

```sql
SELECT 
    c.relname AS table_name,
    c.reltuples AS nb_lignes_estimees,
    s.attname AS column_name,
    s.n_distinct,
    CASE 
        WHEN s.n_distinct > 0 THEN s.n_distinct / c.reltuples
        WHEN s.n_distinct < 0 THEN ABS(s.n_distinct)
        ELSE NULL
    END AS selectivite
FROM pg_stats s
JOIN pg_class c ON s.tablename = c.relname
WHERE s.tablename = 'ma_table'
  AND s.schemaname = 'public';
```

## 4. Valeurs les plus fréquentes

```sql
SELECT 
    attname,
    most_common_vals,      -- Valeurs les plus courantes
    most_common_freqs,     -- Leurs fréquences
    n_distinct
FROM pg_stats
WHERE tablename = 'ma_table';
```

## 5. Mise à jour des statistiques

```sql
-- Forcer la mise à jour des statistiques
ANALYZE ma_table;

-- Ou pour toute la base
ANALYZE;

-- Analyse verbose pour voir les détails
ANALYZE VERBOSE ma_table;
```

## 6. Statistiques détaillées d'une colonne

```sql
SELECT 
    schemaname,
    tablename,
    attname,
    null_frac,
    avg_width,
    n_distinct,
    most_common_vals::text,
    most_common_freqs::text,
    correlation
FROM pg_stats
WHERE tablename = 'users'
  AND attname = 'email'
  AND schemaname = 'public';
```

## 7. Identifier les colonnes peu sélectives

```sql
SELECT 
    tablename,
    attname,
    CASE 
        WHEN n_distinct > 0 THEN n_distinct
        WHEN n_distinct < 0 THEN ABS(n_distinct) * (SELECT reltuples FROM pg_class WHERE relname = tablename)
    END AS valeurs_distinctes_estimees,
    CASE 
        WHEN n_distinct > 0 THEN n_distinct / (SELECT reltuples FROM pg_class WHERE relname = tablename)
        WHEN n_distinct < 0 THEN ABS(n_distinct)
    END AS selectivite
FROM pg_stats
WHERE schemaname = 'public'
  AND tablename = 'ma_table'
ORDER BY selectivite DESC;
```

## Note importante sur `n_distinct`

- **Positif** : nombre absolu de valeurs distinctes (ex: 1000)
- **Négatif** : proportion de valeurs distinctes (ex: -0.5 = 50% de valeurs uniques)
- **-1** : toutes les valeurs sont uniques (sélectivité = 1.0)

## Exemple complet

```sql
-- Analyse complète d'une table
SELECT 
    attname AS colonne,
    n_distinct AS valeurs_distinctes,
    ROUND(
        CASE 
            WHEN n_distinct > 0 THEN n_distinct / c.reltuples
            WHEN n_distinct < 0 THEN ABS(n_distinct)
            ELSE 0
        END, 
        4
    ) AS selectivite,
    null_frac AS pct_null,
    correlation
FROM pg_stats s
JOIN pg_class c ON s.tablename = c.relname
WHERE s.tablename = 'users'
  AND s.schemaname = 'public'
ORDER BY selectivite DESC;
```

**Pensez à exécuter `ANALYZE` régulièrement pour garder les statistiques à jour !** 📊

SELECT 
    COUNT(DISTINCT colonne)::float / COUNT(*)::float AS selectivite,
    COUNT(DISTINCT colonne) AS valeurs_distinctes,
    COUNT(*) AS total_lignes
FROM ma_table;

SELECT 
    tablename,
    attname AS column_name,
    n_distinct,  -- Nombre de valeurs distinctes (estimé)
    null_frac,   -- Fraction de valeurs NULL
    avg_width,   -- Largeur moyenne en bytes
    correlation  -- Corrélation physique
FROM pg_stats
WHERE tablename = 'ma_table'
  AND schemaname = 'public';

  SELECT 
    attname,
    most_common_vals,      -- Valeurs les plus courantes
    most_common_freqs,     -- Leurs fréquences
    n_distinct
FROM pg_stats
WHERE tablename = 'ma_table';

-- Forcer la mise à jour des statistiques
ANALYZE ma_table;

-- Ou pour toute la base
ANALYZE;

-- Analyse verbose pour voir les détails
ANALYZE VERBOSE ma_table;

SELECT 
    schemaname,
    tablename,
    attname,
    null_frac,
    avg_width,
    n_distinct,
    most_common_vals::text,
    most_common_freqs::text,
    correlation
FROM pg_stats
WHERE tablename = 'users'
  AND attname = 'email'
  AND schemaname = 'public';

  -- Forcer un nombre absolu
ALTER TABLE ma_table ALTER COLUMN ma_colonne SET (n_distinct = 150);

-- Forcer un ratio
ALTER TABLE ma_table ALTER COLUMN ma_colonne SET (n_distinct = -0.5);

-- Revenir à l'auto
ALTER TABLE ma_table ALTER COLUMN ma_colonne RESET (n_distinct);

SELECT 
    tablename,
    attname,
    n_distinct,
    CASE 
        WHEN n_distinct > 0 THEN '❌ Peu sélectif (< 10%)'
        WHEN n_distinct < -0.5 THEN '✅ Très sélectif (> 50%)'
        WHEN n_distinct < -0.1 THEN '⚠️ Moyennement sélectif (10-50%)'
        ELSE '❓ Cas particulier'
    END AS evaluation_index
FROM pg_stats
WHERE tablename = 'ma_table'
  AND schemaname = 'public';

  -- Trouver les index inutiles (sur colonnes peu sélectives)
SELECT 
    i.tablename,
    i.indexname,
    s.n_distinct,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS taille_index,
    CASE 
        WHEN s.n_distinct > 0 THEN '⚠️ Index probablement inefficace'
        WHEN s.n_distinct > -0.1 THEN '⚠️ Sélectivité limite'
        ELSE '✅ OK'
    END AS evaluation
FROM pg_indexes i
JOIN pg_class c ON i.indexname = c.relname
JOIN pg_stats s ON s.tablename = i.tablename 
    AND s.attname = ANY(string_to_array(
        regexp_replace(pg_get_indexdef(c.oid), '.*\((.*)\)', '\1'), 
        ', '
    ))
WHERE i.schemaname = 'public'
  AND s.n_distinct > 0  -- Index sur colonnes peu sélectives
ORDER BY pg_relation_size(i.indexrelid) DESC;

-- Colonne avec WHERE fréquent sur une valeur rare
SELECT * FROM commandes WHERE statut = 'en_erreur';
-- Si 'en_erreur' = 0.1% des lignes, l'index est utile !
-- Même si n_distinct = 5 (positif)

-- Solution: index partiel
CREATE INDEX idx_commandes_erreur 
ON commandes(statut) 
WHERE statut = 'en_erreur';
```

## Résumé du raccourci
```
n_distinct > 0     → ❌ Rarement bon pour index classique
n_distinct < -0.01 → ⚠️ À évaluer selon les requêtes
n_distinct < -0.3  → ✅ Bon candidat pour index
n_distinct ≈ -1    → ✅✅ Excellent pour index (quasi unique)