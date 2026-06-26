# Computational Evidence — Natural Proofs Barrier core

The barrier formalized here is a finite counting law over the space of truth
tables `Tbl m = Fin m → Bool` (`|Tbl m| = 2^(2ⁿ)` when `m = 2ⁿ`). The relevant
quantities are exact rational densities, so the "evidence" is a handful of exact
small-case computations confirming the hypotheses are satisfiable (non-vacuity).

## 1. Densities of the "not all-false" test (`nonConstFalse`)

`accRandom (nonConstFalse m) = (2^m - 1) / 2^m` (all tables except the unique
all-false table).

| m | #truth tables = 2^m | #passing test | density        |
|---|---------------------|---------------|----------------|
| 0 | 1                   | 0             | 0              |
| 1 | 2                   | 1             | 1/2            |
| 2 | 4                   | 3             | 3/4            |
| 3 | 8                   | 7             | 7/8            |
| 4 | 16                  | 15            | 15/16          |

Observation: density `> 0` exactly when `m ≥ 1`, matching the load-bearing
hypothesis `1 ≤ m` in `Examples.density_nonconstant_pos`. For `m = 0` the lone
table *is* all-false, so the test is empty — the boundary case the Critic flagged.

## 2. Membership-test advantage for a seed-bounded generator

For a generator `G : S → Tbl m` the membership test `notInImage G` has advantage
`accRandom (notInImage G) - accGen G (notInImage G) = (2^m - |image G|)/2^m`
(usefulness forces the second term to `0`).

Example: `S = Fin 1`, `m = 2`, `G ≡ allFalse`. Then `|image G| = 1`, advantage
`= (4 - 1)/4 = 3/4 > 0`, confirming `image_test_distinguishes` is non-vacuous
(strict positivity) and `card S = 1 < 4 = card (Tbl 2)`.

## 3. Counterexample hunt

- Claim tested: "advantage of a useful test can be `0`." Refuted by §2 whenever
  `|image G| < 2^m`; the membership test always achieves strictly positive
  advantage. No counterexample to the proved theorems was found.
- Claim tested: "largeness alone (without usefulness) forces a distinguisher."
  Refuted in principle — a large test that also accepts every generator output
  has `accGen = accRandom`, advantage `0`. This is why `barrier` needs the
  pseudorandomness clause, not just largeness; consistent with the formal
  statement.

## Why this suffices

The theorems are universally quantified over the finite type `Tbl m` and proved
symbolically (via `Finset` cardinalities and `div_pos`), so exhaustive numeric
search is neither needed nor meaningful beyond confirming non-vacuity and the
boundary at `m = 0`. The small-case table above is exactly the evidence the
formal `Examples` witnesses encode.
