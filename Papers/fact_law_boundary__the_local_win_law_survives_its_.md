# Computational Evidence — rho detector boundary and the automorphism cliff

Exploratory Python scan (not machine-checked; the Lean files are the verified artefacts).
Detector models are exactly those formalised in `Catalog/Novelty/RhoDetectorBoundary.lean`:
Floyd = 3 evaluations + 1 comparison per index, stops at first `i>0` with `μ ≤ i`, `λ | i`;
Brent (power-of-two) = 1 evaluation + 1 comparison per step, stops in first round `K` with
`μ < 2^K`, `λ ≤ 2^K`, at offset `λ`.

## 1. Counted vs uncounted channel, `x²+c` mod primes `p ∈ [2000, 2400)`, `c ∈ {1,3}`, `x₀ = 2`

| instances | Brent evals ≥ Floyd evals | Floyd comps > Brent comps | mean brent/floyd (evals) | max |
|---|---|---|---|---|
| 108 | **0** | **0** | 0.6577 | 0.9846 |

Consistent with the proved `brentEvals_lt_floydEvals` (strict, every rho shape) and
`floydComps_le_brentComps`.  (The measured 0.733 of the uploaded report uses a different
per-operation accounting; only the *sign* of the comparison is claimed formally.)

## 2. Sharpness family (pure cycles, `μ = 0`, `λ = 2^m + 1`)

| λ | Floyd evals / comps | Brent evals / comps |
|---|---|---|
| 3 | 9 / 3 | 6 / 6 |
| 5 | 15 / 5 | 12 / 12 |
| 9 | 27 / 9 | 24 / 24 |
| 17 | 51 / 17 | 48 / 48 |
| 33 | 99 / 33 | 96 / 96 |

Counted saving is always exactly 3; uncounted overrun is `2^(m+1) − 2`.  Proved as
`pure_cycle_counts`; consequence `exists_brent_loses_wallclock`.

## 3. Automorphism cliff, `x^E + c`, `p ∈ [2000,2400)`, median over `c ∈ {1,3,5}` of `T/√p`

| E | gcd(E,p−1)=1 (permutation) | gcd>1 (compression) |
|---|---|---|
| 2 | n/a (never coprime) | 1.190 |
| 3 | **23.202** | 0.817 |

At `p = 65537`, `c = 1`, `x₀ = 2`: closure time `T = 172` for `E = 2`, `T = 53484` for `E = 3`
(ratio ≈ 311 for this single seed; the report's 104.9× is an average over its runs).
Formal counterparts: `rhoMap_bijective_iff`, `cube_map_permutes_F65537`,
`closureTime_rhoMap_le`, `square_map_compresses_F65537`, `closureTime_successor`.

OEIS: not applicable (no integer sequence is the object of study).
Counterexample hunt: none found for the formal claims above.
