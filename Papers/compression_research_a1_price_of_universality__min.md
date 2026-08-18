# Computational evidence — price of universality (Phase A, Question 1)

All numbers below were produced with Lean `#eval` (Float arithmetic) on the exact
combinatorial formula for the Shtarkov sum of a memoryless class,

`Cₛ(m, n) = Σ_{types (k₁,…,k_m), Σkᵢ = n} (n! / Πkᵢ!) · Π (kᵢ/n)^{kᵢ}`,

i.e. the sum over messages of the maximum-likelihood probability, grouped by
type.  They are *evidence*, not proof; every claim marked as a theorem below is
proved without `sorry` in `Catalog/Logic/PriceOfUniversality/`.

## 1. Binary memoryless class (`m = 2`)

| n | Cₛ | lower bound √n/4 (proved) | upper bound n+1 (proved) |
|---|------|------|------|
| 1 | 2.000 | 0.250 | 2 |
| 2 | 2.500 | 0.354 | 3 |
| 4 | 3.219 | 0.500 | 5 |
| 8 | 4.245 | 0.707 | 9 |
| 12 | 5.036 | 0.866 | 13 |
| 16 | 5.704 | 1.000 | 17 |

Observations.

* Both catalogued bounds hold on every computed instance.
* `Cₛ` tracks `√(πn/2)` closely (`n = 16`: `√(8π) = 5.013` vs `5.704`), i.e. the
  true growth is `½ log₂ n + O(1)` bits — the Rissanen rate for one free
  parameter.  The proved lower bound `√n/4` has the right *exponent* and loses
  only an additive constant (2 bits); the proved upper bound `n+1` has exponent
  `1` instead of `½`, i.e. it is off by a factor `2` in the coefficient of
  `log₂ n`, exactly as the literature's `d/2 · log n` predicts.

## 2. Ternary and quaternary alphabets: is the *dimension* right?

| n | Cₛ (m = 3) | (n+1)^(m−1) = (n+1)² | Cₛ (m = 4) | (n+1)³ |
|---|------|------|------|------|
| 2 | 4.500 | 9 | 7.000 | 27 |
| 4 | 7.219 | 25 | 13.656 | 125 |
| 6 | 9.775 | 49 | 21.099 | 343 |
| 8 | 12.245 | 81 | 29.225 | 729 |
| 10 | 14.660 | 121 | 37.961 | 1331 |
| 12 | 17.036 | 169 | — | — |

Observations.

* The dimension-corrected bound `Cₛ ≤ (n+1)^(#A−1)`
  (`shtarkovSum_iidClass_le_dim`, proved) holds everywhere and is far tighter
  than the previously catalogued `(n+1)^#A`.
* Growth is consistent with `Cₛ ≍ n^{(m−1)/2}`: for `m = 3` the data is close to
  linear in `n` (17.0 at `n = 12`), for `m = 4` close to `n^{3/2}`.  So the
  exponent `m − 1` in the proved upper bound is again exactly twice the truth —
  the same factor-2 gap as in the binary case, and the same one the literature
  has.

## 3. The tensorization/embedding claim

`shtarkovSum_power_le_iid` (proved) says the memoryless class over an alphabet
of size `2^k` contains the `k`-fold power of the binary memoryless class, so
`Cₛ(m = 4, n) ≥ Cₛ(m = 2, n)²`.

| n | Cₛ(m = 4) | Cₛ(m = 2)² |
|---|------|------|
| 2 | 7.000 | 6.250 |
| 4 | 13.656 | 10.360 |
| 6 | 21.099 | 14.248 |
| 8 | 29.225 | 18.020 |
| 10 | 37.961 | 21.718 |

The inequality holds on every instance, with slack that grows — consistent with
the honest statement in the file: the embedding recovers exponent
`k = log₂ #A` where the truth is `(#A − 1)/2`.

## 4. The parameter-sharing dichotomy

Independent parameters (`k` blocks of length `n = 4`, binary) versus one shared
parameter over the same `4k` symbols:

| k | log₂ Cₛ(power) = k·log₂ 3.219 | log₂ Cₛ(shared, n = 4k) ≤ log₂(4k+1) |
|---|------|------|
| 1 | 1.687 | 2.32 |
| 2 | 3.375 | 3.17 |
| 4 | 6.749 | 4.09 |
| 8 | 13.499 | 5.04 |
| 32 | 53.996 | 7.01 |

Linear versus logarithmic, exactly as `parameter_sharing_dichotomy` and
`sharing_gap_linear` state.  (The proved explicit gap `k/4` is stated from
`k ≥ 5000` because the proof routes through the crude `log₂ t ≤ 2.9 √t`
estimate; the numerics show the phenomenon starts immediately.)

## 5. No counterexample found

Every inequality that appears as a theorem in
`Catalog/Logic/PriceOfUniversality/` was tested on all instances above
(`m ∈ {2,3,4}`, `n ≤ 16`) before being formalised; no violation was observed.
