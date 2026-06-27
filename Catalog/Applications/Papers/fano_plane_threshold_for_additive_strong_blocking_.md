# Computational Evidence — Fano-plane threshold for strong blocking sets (`h = 1`)

All computations were carried out *inside Lean* over the cyclic (Singer) model of the
Fano plane `PG(2,2)`: points `= ZMod 7`, lines `= {i, i+1, i+3}` (development of the
perfect difference set `{0,1,3} mod 7`). Every claim below is discharged by kernel
`decide` in `Catalog/Novelty/FanoStrongBlocking.lean`, so the "evidence" is itself
machine-verified rather than heuristic.

## 1. Small-case calculations

* Each of the 7 lines has exactly 3 points (`fanoLine_card`).
* Exhaustive search over all `2^7 = 128` point sets:
  * smallest set meeting every line in `≥ 2` points has size **6**;
  * no set of size `≤ 5` meets every line twice;
  * the explicit set `univ \ {0}` (size 6) works (`sb6_isStrongBlocking`).
* The extremal (size-6) strong blocking sets are exactly the **7** complements of a
  single point, `univ \ {p}` (`minimum_strongBlocking_iff`, `minimum_strongBlocking_count`).

## 2. Threshold vs. general formula

The general strong-blocking-set / minimal-code lower bound in `PG(k-1,q)` is `(k-1)(q+1)`.
For the Fano plane `k = 3`, `q = 2`: `(k-1)(q+1) = 2·3 = 6`, matching the computed
threshold exactly (`fano_threshold_eq_formula`). The Fano plane **saturates** the bound.

## 3. Counterexample hunt

The universal claim tested is "every strong blocking set has `≥ 6` points". The full
128-set enumeration found **no** counterexample (`strongBlocking_card_ge_six`). It also
found no strong blocking set of size `≤ 5`, confirming `6` is sharp.

## 4. Table (size `n` vs. existence of a size-`n` strong blocking set in `PG(2,2)`)

| n | strong blocking set exists? |
|---|------------------------------|
| ≤5 | no |
| 6 | yes (7 of them: `univ \ {p}`) |
| 7 | yes (`univ`) |

OEIS: the count `7` of minimum strong blocking sets equals the number of points/lines of
the Fano plane; no dedicated sequence was needed for this single finite instance.
