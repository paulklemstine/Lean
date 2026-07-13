# Computational Evidence: Alexander polynomials as signed lattice-path sums

## Setup

We model a Laurent polynomial by its coefficient function `c : ℤ → ℤ`
(the coefficient of `tᵏ`). Two enumeration schemes:

- **unsigned** `areaGF`: coefficient of `tᵏ` = number of states of area `k` (≥ 0);
- **signed** `signedGF`: coefficient of `tᵏ` = signed count `∑_{a s = k} sign s`.

## The (2, 2k+1) torus-knot family

Reduced Alexander polynomial of the torus knot `T(2, 2k+1)`:

    Δ_k(t) = ∑_{i=-k}^{k} (-1)^{i+k} t^i,     torusAlex k i = if -k ≤ i ≤ k then (-1)^{i+k} else 0.

Small cases (coefficients from i = -k to k):

| k | coefficients (i = -k … k)      | knot        |
|---|--------------------------------|-------------|
| 0 | [1]                            | unknot      |
| 1 | [1, -1, 1]                     | trefoil     |
| 2 | [1, -1, 1, -1, 1]              | cinquefoil  |
| 3 | [1, -1, 1, -1, 1, -1, 1]       | T(2,7)      |

Verified: `torusAlex 1 = [1, -1, 1]` matches the reduced trefoil polynomial
`t - 1 + t⁻¹` of the earlier cycle.

## Numerical checks (all confirmed by `#eval`)

1. **Reciprocity (palindromicity)** `Δ_k(t) = Δ_k(t⁻¹)`: coefficient list is a
   palindrome for every k. ✓
2. **Normalization** `Δ_k(1) = ∑_i c_i = 1` for all k (alternating sum of
   `2k+1` terms with `+1` endpoints). ✓  — matches the knot-theoretic fact
   `Δ_K(1) = ±1`.
3. **Determinant** `|Δ_k(-1)| = ∑_i (-1)^i c_i = 2k+1`. For k = 1 → 3
   (trefoil determinant), k = 2 → 5, k = 3 → 7. ✓  — matches
   `det(T(2,2k+1)) = 2k+1`.
4. **Negativity** for every k ≥ 1 the coefficient at `i = k-1` is `-1 < 0`,
   so `Δ_k` is *not* an unsigned generating function. ✓

## Structural findings turned into theorems

- **Universality of the signed model.** Any finitely supported `c : ℤ → ℤ`
  equals `signedGF` of an explicit finite state family (states = `⨆_k {k}×range|c k|`,
  sign = `sign (c k)`, area = `k`). Hence the signed state sum captures *exactly*
  the integer Laurent polynomials, while `areaGF` captures only those with
  non-negative coefficients.
- **Connected sum = product.** The Cauchy product of two signed state sums is the
  signed state sum on the product state family (areas add, signs multiply),
  modelling `Δ_{K₁ # K₂} = Δ_{K₁} · Δ_{K₂}`. In particular `Δ(1)` is
  multiplicative, so any connected sum of `T(2,2k+1)` knots still has `Δ(1) = 1`.

No counterexamples to the (corrected, signed) conjecture were found. The only
failure is the *unsigned* conjecture, refuted structurally by the sign of a
single coefficient.
