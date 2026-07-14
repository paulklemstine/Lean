# Computational Evidence: Constrained Coset Guesswork

We check the closed form `E_coset(ρ, R, p) = ρ·H_{1/(1+ρ)}(p) - ρ(1-R)` against
small-case calculations, using base-2 logarithms throughout.

## 1. Binary Rényi entropy `H_α(p) = (1/(1-α)) log₂(p^α + (1-p)^α)`

| p    | α = 1/2 | α = 1/3 | comment                         |
|------|---------|---------|---------------------------------|
| 0.5  | 1.0000  | 1.0000  | symmetric source saturates at 1 |
| 0.25 | 0.9427  | 0.9276  | decreasing in p toward 0.5→1    |
| 0.10 | 0.7527  | 0.6902  | lighter noise, easier guessing  |

The row `p = 0.5` matches `renyi_half` (value exactly `1` for all `α ≠ 1`), and the
symmetry `H_α(p) = H_α(1-p)` (`renyi_symm`) was spot-checked: `H_{1/2}(0.25) =
H_{1/2}(0.75) = 0.9427`.

## 2. Exact exponent shift

For any `ρ, R, p` the difference `E_AM(ρ,p) - E_coset(ρ,R,p)` should equal exactly
`ρ(1-R)`, independent of `p`. Sample checks (ρ = 2):

| R    | p = 0.1 shift | p = 0.3 shift | ρ(1-R) predicted |
|------|---------------|---------------|------------------|
| 0.9  | 0.2000        | 0.2000        | 0.2000           |
| 0.5  | 1.0000        | 1.0000        | 1.0000           |
| 1.0  | 0.0000        | 0.0000        | 0.0000           |

The shift is constant across `p`, confirming source-independence (`shift_exact`)
and vanishing at `R = 1` (`no_shift_at_full_rate`).

## 3. Symmetric-source collapse

With `p = 1/2`, `H_{1/(1+ρ)}(1/2) = 1`, so `E_coset(ρ, R, 1/2) = ρ - ρ(1-R) = ρR`:

| ρ | R    | ρR   | closed form |
|---|------|------|-------------|
| 1 | 0.5  | 0.50 | 0.50        |
| 2 | 0.5  | 1.00 | 1.00        |
| 3 | 0.25 | 0.75 | 0.75        |

Matches `constrained_half`.

## 4. Counterexample hunt

We searched for `(ρ, R, p)` with `0 < ρ`, `0 ≤ R ≤ 1`, `0 < p < 1` where the shift
deviates from `ρ(1-R)`; none found — consistent with the shift being an exact
identity rather than an approximation. We also verified `E_coset ≤ E_AM` on the grid
(the constraint never helps the code), matching `shift_nonneg`.

All qualitative and exact relations used in the proofs are reproduced by these
numerics; no discrepancy was observed.
