# Computational evidence: seven-state connectivity of `CanonicalMotion`

All numbers below were subsequently re-derived inside Lean by kernel evaluation
(`decide`) in `Catalog/Novelty/SonicCounterpointConnectivity.lean`; the tables
here only record the exploratory pass that suggested the statements.

## 1. The canonical motion table

The canonical realization of a consonance `i` is the dyad `(0, semitones i)`:
the bass is frozen at pitch `0`. Hence for a canonical motion `i → j`

* both intervals are consonant by construction,
* `Stepwise` reduces to `|semitones j - semitones i| ≤ 2` (the bass does not move),
* `SimilarMotion` is impossible (similar motion requires *both* voices to move),
  so the perfect-consonance clause is vacuous.

So `CanonicalMotion i j ⟺ |semitones j - semitones i| ≤ 2`.

Consonance ladder: `0, 3, 4, 7, 8, 9, 12`. Consecutive gaps: `3, 1, 3, 1, 1, 3`.

Adjacency table (`•` = legal one-step motion):

|        | 0 | 3 | 4 | 7 | 8 | 9 | 12 |
|--------|---|---|---|---|---|---|----|
| **0**  | • |   |   |   |   |   |    |
| **3**  |   | • | • |   |   |   |    |
| **4**  |   | • | • |   |   |   |    |
| **7**  |   |   |   | • | • | • |    |
| **8**  |   |   |   | • | • | • |    |
| **9**  |   |   |   | • | • | • |    |
| **12** |   |   |   |   |   |   | •  |

Edge count `1 + 4 + 9 + 1 = 15`, matching the catalog's
`allCanonicalMotions_card = 15`.

## 2. Counterexample hunt

The table is block diagonal, so the relation is already an equivalence relation
and its reflexive-transitive closure adds nothing. Reachable ordered pairs: 15
out of 49; **34 ordered pairs are unreachable**. The smallest explicit
refutation is `unison → octave` (registers `0` and `3`).

Blocks ("registers"): `{0}`, `{3,4}`, `{7,8,9}`, `{12}` — four strongly
connected components.

## 3. Step-width sweep (union-find over the ladder)

| width `w` | components | blocks |
|-----------|------------|--------|
| 0 | 7 | `{0} {3} {4} {7} {8} {9} {12}` |
| 1 | 4 | `{0} {3,4} {7,8,9} {12}` |
| 2 | 4 | `{0} {3,4} {7,8,9} {12}` |
| 3 | 1 | `{0,3,4,7,8,9,12}` |
| 4 | 1 | `{0,3,4,7,8,9,12}` |
| 5 | 1 | `{0,3,4,7,8,9,12}` |
| 6 | 1 | `{0,3,4,7,8,9,12}` |

The transition is sharp at `w = 3`, i.e. exactly the largest consecutive gap of
the ladder — the observation that became the general gap-graph criterion
`conn_iff_consecutiveGapBound`.

## 4. Free-bass rescue path

Letting the bass move restores connectivity at the historical width `2`. The
contrary-motion spine

```
(0,0) → (-1,2) → (-1,3) → (-2,5) → (-2,6) → (-2,7) → (-3,9)
```

realizes intervals `0, 3, 4, 7, 8, 9, 12`; each step moves each voice by at
most two semitones, every sonority is consonant, and no step is similar motion
between two perfect consonances (the two perfect-to-perfect transitions
`4 → 7` and `9 → 12` are contrary). This became `spine` and
`consonances_connected_with_free_bass`.

## 5. OEIS

No interesting sequence arises: the data are the fixed finite vectors above
(component counts `7, 4, 4, 1, 1, …`), which are artifacts of a single
seven-element ladder rather than a growing family, so no OEIS lookup applies.
