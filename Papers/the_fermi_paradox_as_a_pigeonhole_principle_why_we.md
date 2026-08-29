# Computational Evidence — Fermi / pigeonhole occupancy model

All numbers below are **exact rational computations** produced by
`Catalog/Pythagorean/FermiPigeonhole/Evidence.lean` (`#eval` in `ℚ`, full
enumeration of the sample space `(Fin N → Option (Fin T))`).  They were used to
sanity-check every inequality *before* it was formalised.

## 1. Model and notation

* `N` habitable sites, each independently civilized with probability `p`;
* a civilized site is assigned one of `T` epochs uniformly;
* an outcome is `f : Fin N → Option (Fin T)`, with weight
  `∏ i, w(f i)`, `w none = 1 - p`, `w (some e) = p / T`.

Sample-space sizes: `(T+1)^N`, e.g. `3^3 = 27`, `4^4 = 256`, `6^2 = 36`.

## 2. Normalisation

| `N` | `T` | `p`  | total mass |
|-----|-----|------|------------|
| 3   | 2   | 1/5  | `1`        |
| 4   | 3   | 1/10 | `1`        |

Matches the proved `prb_univ`.

## 3. Contact probability versus the proved bound `(N² − N)·p²/T`

| `N` | `T` | `p`  | exact `P(contact)` | bound        | ratio |
|-----|-----|------|--------------------|--------------|-------|
| 3   | 2   | 1/5  | `7/125 = 0.05600`  | `3/25 = 0.12`| 0.47  |
| 4   | 3   | 1/10 | `191/10000 = 0.01910` | `1/25 = 0.04` | 0.48 |
| 2   | 5   | 1/2  | `1/20 = 0.05000`   | `1/10 = 0.1` | 0.50  |

The bound holds in every case.  The systematic factor `≈ 1/2` is exactly the
slack of summing over *ordered* pairs; the `N = 2` row shows this is sharp
(`0.05` versus `0.1`), so the bound cannot be improved beyond a factor of two by
this method.

## 4. Contact decays like `1/T` (`N = 3`, `p = 1/5`)

| `T` | exact `P(contact)`      | `T · P(contact)` |
|-----|-------------------------|------------------|
| 2   | `7/125 = 0.056000`      | `0.11200`        |
| 3   | `43/1125 = 0.038222`    | `0.11467`        |
| 4   | `29/1000 = 0.029000`    | `0.11600`        |

`T · P` is nearly constant: more time (more holes) makes contact *rarer*, exactly
as the proved bound predicts.

## 5. Lifeless cosmos: `(1 − p)^N` and Bernoulli

`N = 3`, `T = 2`, `p = 1/5`: exact `P(lifeless) = 64/125 = 0.512`, equal to
`(1 − p)^N = 0.512` (matches `prb_lifeless`) and above `1 − N p = 0.4`
(matches `prb_lifeless_ge`).

## 6. Two-sided first-moment estimate

`N = 4`, `T = 3`, `p = 1/10`: exact `P(someone exists) = 3439/10000 = 0.3439`,
between the Bonferroni lower bound `N p − (N p)²/2 = 0.32` and the union bound
`N p = 0.4`.  Both proved bounds are confirmed and neither is vacuous.

## 7. Expected number of empty epochs versus `T − N p`

| `N` | `T` | `p`  | exact `E[#empty epochs]`      | bound `T − N p` |
|-----|-----|------|-------------------------------|-----------------|
| 3   | 2   | 1/5  | `729/500 = 1.45800`           | `1.4`           |
| 4   | 3   | 1/10 | `707281/270000 = 2.61956`     | `2.6`           |

Matches `expected_empty_epochs_ge`, and shows the bound is tight to `O(p²)`.

## 8. Counterexample hunt

No counterexample was found to any of the formalised inequalities across all
enumerated parameter combinations (`N ≤ 4`, `T ≤ 5`, `p ∈ {1/10, 1/5, 1/2}`).
The one place where naive intuition fails is the *unordered vs ordered pair*
factor of two documented in §3; the formal statements are stated with the
ordered-pair count `N² − N`, so they remain correct.

## 9. OEIS

No integer sequence arises here: all quantities are polynomial in `p` with
denominators `T^k`, and the relevant combinatorial counts are the elementary
`N² − N` (A002378, oblong numbers, shifted) and `T(2L − 1)`.  No OEIS lookup was
needed beyond that identification.
