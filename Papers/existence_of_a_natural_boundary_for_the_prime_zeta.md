# Computational Evidence — Prime-Ideal Zeta of an Imaginary Quadratic Field (Gaussian case)

This note records the numerical evidence underpinning the formal results in
`Catalog/Novelty/ImaginaryQuadraticPrimeZeta.lean` and
`Catalog/Novelty/ImaginaryQuadraticPrimeZetaGeneral.lean`.

## 1. The object

For `K = ℚ(i)` (discriminant `-4`, class number `1`) the prime-ideal zeta
function is

```
P_{ℚ(i)}(s) = ∑_{𝔭 ⊂ ℤ[i]} N(𝔭)^{-s}
            = 2^{-s}  +  ∑_{p ≡ 1 (4)} 2·p^{-s}  +  ∑_{p ≡ 3 (4)} p^{-2s},
```

from the `p mod 4` splitting law in the Gaussian integers:
`2` ramifies (norm 2), `p ≡ 1 (4)` splits into two primes of norm `p`, and
`p ≡ 3 (4)` is inert (one prime of norm `p²`).

## 2. Small-case splitting table (first rational primes)

| p  | p mod 4 | type     | prime ideals above p          | term at exponent s |
|----|---------|----------|-------------------------------|--------------------|
| 2  | —       | ramified | (1+i), N = 2                  | `2^{-s}`           |
| 3  | 3       | inert    | (3),   N = 9                  | `3^{-2s}`          |
| 5  | 1       | split    | (2+i),(2−i), N = 5 each       | `2·5^{-s}`         |
| 7  | 3       | inert    | (7),   N = 49                 | `7^{-2s}`          |
| 11 | 3       | inert    | (11),  N = 121                | `11^{-2s}`         |
| 13 | 1       | split    | (3+2i),(3−2i), N = 13 each    | `2·13^{-s}`        |
| 17 | 1       | split    | (4+i),(4−i),  N = 17 each     | `2·17^{-s}`        |
| 19 | 3       | inert    | (19),  N = 361                | `19^{-2s}`         |

## 3. Partial sums (computed in Lean with `Float`, primes `p < N`)

Reproducible with the `#eval` snippet recorded below (run under `import Mathlib`).

| s    | N = 200 | N = 5000 | N = 50000 | behaviour                          |
|------|---------|----------|-----------|------------------------------------|
| 2.0  | —       | 0.3705   | —         | converges (region `s > 1`)         |
| 1.5  | —       | 0.7192   | —         | converges (region `s > 1`)         |
| 1.0  | 1.7721  | 2.2201   | 2.4569    | grows slowly (≈ log log, edge `s=1`)|
| 0.5  | 7.3810  | 22.696   | 53.582    | diverges (floor `s = 1/2`)         |

* The `s = 0.5` column grows without bound — this is the *proved* divergence
  `gaussPrimeZeta_not_summable_of_le_half`, driven by the inert norm-`p²` ideals.
* The `s = 1.0` column grows extremely slowly: consistent with divergence at the
  true abscissa `s = 1`, whose rate is governed by `∑_{p ≡ 1 (4)} 2/p` (≈ a
  `log log` divergence). This is the *conjectural* part (needs Dirichlet density),
  not formalised; see `FUTURE_DIRECTIONS.md`.

```lean
import Mathlib
def gterm (s : Float) (p : Nat) : Float :=
  if p == 2 then (2.0)^(-s)
  else if p % 4 == 1 then 2.0 * (Float.ofNat p)^(-s)
  else (Float.ofNat p)^(-(2.0*s))
def primesBelow (N : Nat) : List Nat := (List.range N).filter Nat.Prime
def psum (s : Float) (N : Nat) : Float := ((primesBelow N).map (gterm s)).foldl (·+·) 0.0
#eval psum 2.0 5000   -- 0.3705
#eval psum 0.5 50000  -- 53.582  (diverges)
#eval psum 1.0 50000  -- 2.4569  (slow divergence at the abscissa)
```

## 4. OEIS connections

* Number of integral ideals of `ℤ[i]` of norm `n`: `r₂(n)/4` where `r₂` counts
  representations as a sum of two squares; the ideal-counting function is
  **A004018**-related (`A002654` counts ideals of norm `n`). Its Dirichlet series
  is the Dedekind zeta `ζ_{ℚ(i)}(s) = ζ(s)·L(s, χ₋₄)`.
* The split/inert pattern is governed by the non-principal character mod 4,
  `χ₋₄` = **A101455** (`1,0,−1,0,1,0,−1,…`): `p` splits iff `χ₋₄(p) = +1`,
  is inert iff `χ₋₄(p) = −1`.

## 5. Counterexample hunt (sanity, no counterexample expected)

* Upper bound `term ≤ 2·p^{-s}` (used for convergence) — tested termwise for all
  primes `p < 50000` at `s ∈ {0.5, 1.0, 1.5, 2.0}`: holds in every case.
* Lower bound `p^{-2s} ≤ term` (used for divergence) — tested termwise over the
  same range: holds in every case.
Both inequalities are the formally proved pointwise lemmas
`gaussTerm_le` / `gaussTerm_ge`, so no counterexample exists.

## 6. Take-away

The numerics confirm the proved abscissa bracket `[1/2, 1]`: unconditional
divergence at `s = 1/2`, unconditional convergence for `s > 1`, and the slow
edge growth at `s = 1` matching the conjectural sharp abscissa.
