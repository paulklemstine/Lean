# Computational evidence — U065 divisibility-mixture baseline

All numbers below were produced inside Lean (`#eval`) before the corresponding theorems
were formalised, and the exact-arithmetic ones are additionally re-checked by the kernel
in `Catalog/Computation/U065Evidence.lean` (`decide`, no `native_decide`).

## 1. Root counts of `j² ≡ N (mod p)` — small-case calculations

Concrete counts `X(a) = #{ j mod p : p ∣ j² − a }`:

| p  | `X(0), X(1), …, X(p−1)` | `∑ X` | `∑ (X−1)²` |
|----|--------------------------|-------|------------|
| 3  | 1, 2, 0                  | 3     | 2          |
| 5  | 1, 2, 0, 0, 2            | 5     | 4          |
| 7  | 1, 2, 2, 0, 2, 0, 0      | 7     | 6          |
| 11 | 1, 2, 0, 2, 2, 2, 0, 0, 0, 2, 0 | 11 | 10   |
| 13 | 1, 2, 0, 2, 2, 0, 0, 0, 0, 2, 2, 0, 2 | 13 | 12 |

Both columns match the formalised identities exactly: mean preservation
`∑ₐ X(a) = p` (`U065.sum_rootCount`, and `U065.sum_rootCountM` for arbitrary modulus)
and the variance identity `∑ₐ (X(a) − 1)² = p − 1` (`U065.sum_sq_rootCount_sub_one`).
The rate is therefore *mean-correct but maximally over-dispersed* — the naive
random-integer baseline is right on average and wrong for every individual `N`.

No OEIS lookup is relevant here: the sequences are `p` and `p − 1`.

## 2. Counterexample hunt for the generating identity

Claim tested: `∑ₐ c^X(a) = p·c + (p−1)(c−1)²/2` in exact rational arithmetic.

| p   | c   | LHS   | RHS   | equal |
|-----|-----|-------|-------|-------|
| 3   | 3/2 | 19/4  | 19/4  | true  |
| 5   | 3/2 | 8     | 8     | true  |
| 7   | 3/2 | 45/4  | 45/4  | true  |
| 11  | 3/2 | 71/4  | 71/4  | true  |
| 13  | 3/2 | 21    | 21    | true  |
| 3,5,7,11,13,101 | 1/2 | — | — | true (all) |

No counterexample was found; the identity is now a theorem
(`U065.sum_pow_rootCount`, itself a corollary of the functional identity
`U065.sum_apply_rootCount`).

## 3. Per-prime shares of the hump — the "no single carrier" table

Per-prime log-excess `ℓ_q = log(1 + (1 − 1/q)·X)`, `X = (c−1)²/(2c)`, and its share of
the total amplitude `A = ∑ ℓ_q`.

Four-prime model `{3,5,7,11}` at `c = 1.3095` (chosen so that `A` matches the measured
amplitude `0.1163`):

| q  | `ℓ_q`   | share  |
|----|---------|--------|
| 3  | 0.02409 | 0.2068 |
| 5  | 0.02884 | 0.2475 |
| 7  | 0.03087 | 0.2649 |
| 11 | 0.03271 | 0.2807 |
| **total** | **0.11651** | 1.0000 |

Largest share `0.281`, comfortably below the proved bound `3/(2k) = 0.375` and far below
the experiment's `60 %` win bar.  Six-prime model `{3,5,7,11,13,17}`: shares
`0.131 … 0.185`, bound `3/(2·6) = 0.25`.  This is the numerical face of
`U065.no_single_carrier`: shares are squeezed within a factor `3/2` of each other, so no
single small prime can ever be a carrier.

## 4. Calibration of the mixture spread from the hump amplitude

`humpAmp u δ = (ρ(u) + ρ(u−δ))/2 − ρ(u−δ/2)` with `ρ(u) = 1 − log u`, and
`δ = calibratedSpread u A` in closed form.  Round-trip check at `u = 2.5`:

| A      | calibrated δ | recomputed `humpAmp u δ` |
|--------|--------------|--------------------------|
| 0.0500 | 1.17879      | 0.0500                   |
| 0.1163 | 1.56488      | 0.1163                   |
| 0.3000 | 2.00904      | 0.3000                   |
| 1.0000 | 2.40916      | 1.0000                   |

Exact round-trip, as later proved in `U065.humpAmp_calibratedSpread`.  For the measured
amplitude `A = 0.1163` at `u = 2.5` the inferred mixture spread is `δ ≈ 1.565`, i.e.
`δ/u ≈ 0.626` (scale-free, `U065.calibratedSpread_scale`).

## 5. What the evidence does *not* show

The numbers above concern the model, not the raw experimental stream: no claim is made
here about the exp 588b data itself, which is not part of this project.  The formal
results are statements about the divisibility-mixture baseline model that the experiment
recommends; the numerical tables are consistency checks on that model.
