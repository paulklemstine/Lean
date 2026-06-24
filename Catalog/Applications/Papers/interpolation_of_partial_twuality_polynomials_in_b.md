# Computational Evidence — Partial-Twuality Polynomials of Set Systems

This note records the small-case computation that guided the formal development in
`Twist.lean`, `Interpolation.lean`, and `Examples.lean`.

## 1. Object under study

For a ground set `E` and a feasible set `F ⊆ E`, the partial-twuality polynomial is

  `P_{E,F}(z) = Σ_{A ⊆ E} z^{|F ∆ A|}`,

with coefficient `ptCoeff E F k = #{A ⊆ E : |F ∆ A| = k}`.

## 2. Small-case calculations

Because `A ↦ F ∆ A` is a bijection of `2^E`, the multiset `{|F ∆ A| : A ⊆ E}` equals
`{|B| : B ⊆ E}`. Hence the coefficient of `z^k` is `C(|E|, k)` regardless of `F`:

| `|E|` | coefficient vector `(ptCoeff k)_{k=0..|E|}` | polynomial |
|-------|---------------------------------------------|------------|
| 0     | (1)                                         | `1`        |
| 1     | (1, 1)                                       | `1 + z`    |
| 2     | (1, 2, 1)                                     | `1 + 2z + z²` |
| 3     | (1, 3, 3, 1)                                  | `(1+z)³`   |

Verified in Lean for `|E| = 2`, `F = {0}` by `decide` (`Examples.Eex_coeffs`):
coefficients `(1, 2, 1)`.

## 3. Interpolation check (counterexample hunt)

Claim: the support `{k : ptCoeff k > 0}` is the contiguous interval `[0, |E|]` (no gaps).
Since every coefficient is a binomial `C(|E|, k) > 0` for `0 ≤ k ≤ |E|`, no internal zero
can occur. A gap would require some `C(|E|, k) = 0` with `0 < k < |E|`, which never happens.
**No counterexample exists at the single-feasible-set level** — proved abstractly in
`ptCoeff_interpolating`.

The Yan–Jin counterexamples to the GMT interpolating conjecture therefore cannot arise
from the twist mechanism on one feasible set; they require the *interaction of several
feasible sets* through the delta-matroid width invariant. This pinpoints where future
work must concentrate (see `FUTURE_DIRECTIONS.md`).

## 4. OEIS

The coefficient rows are exactly Pascal's triangle, OEIS A007318, first rows
`1; 1,1; 1,2,1; 1,3,3,1; …`. This identification (each partial-twuality polynomial of a
single feasible set equals `(1+z)^{|E|}`) is the structural reason interpolation is
automatic, and is reflected in `twuality_spectrum`.

## 5. Twist invariance

Computed `ptCoeff E (F ∆ B) = ptCoeff E F` for several `B ⊆ E`; coefficients are
unchanged. Formalised as `ptCoeff_twist_invariant` via the involutive bijection
`A ↦ B ∆ A`.
