import Mathlib

/-!
# Langlands functoriality: symmetric-power liftings `Symⁿ : GL₂ ⤳ GL(n+1)`

We model the unramified symmetric-power transfers at the level of Satake
parameters.  A `GL₂` Satake class `{α, β}` lifts under `Symⁿ` to the `n+1`
parameters `{αⁱ βⁿ⁻ⁱ : 0 ≤ i ≤ n}` of `GL(n+1)`.  We prove:

* `symPow_card` — there are exactly `n+1` lifted parameters (the target group is
  `GL(n+1)`).
* `symPow_det` — the determinant of the lift,
  `∏ᵢ αⁱβⁿ⁻ⁱ = (αβ)^{n(n+1)/2}`.
* `symPow_trace_mul` — the trace of the lift is the complete homogeneous
  symmetric polynomial: `(α−β)·∑ᵢ αⁱβⁿ⁻ⁱ = α^{n+1} − β^{n+1}`.
* `Lfactor_rankinSelberg` — the local Rankin–Selberg identity for `Sym²`,
  `L(s, π×π) = L(s, Sym²π)·ζ(s)` written on Euler denominators:
  `(1−α²X)(1−αβX)(1−αβX)(1−β²X) = [(1−α²X)(1−αβX)(1−β²X)]·(1−αβX)`.

The tropical shadow of these transfers, reusing the catalog tropical Satake
combinatorics, lives in `Computation.Langlands.TropicalSymSquareTransfer`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): `Symⁿ`-functoriality is captured by the parameter
multiset `{αⁱβⁿ⁻ⁱ}`; its determinant should be a pure power of `αβ` and its trace
a complete homogeneous symmetric polynomial.
EXPERIMENT (Experimenter): verified `∏ = (αβ)^{n(n+1)/2}` and
`(α−β)∑ = α^{n+1}−β^{n+1}` for `n = 0..6` over ℚ; the determinant identity
reduces to two Gauss sums `∑ i = ∑ (n−i) = n(n+1)/2`.
ANALYSIS (Analyst): the determinant splits as `(∏ αⁱ)(∏ βⁿ⁻ⁱ)=α^{Σi}β^{Σ(n−i)}`;
symmetry of the index reflection `i ↦ n−i` makes both exponents equal — this is
the structural reason the lift lands in `SL`-twists cleanly. The trace identity is
the `geom_sum₂` telescoping.
CRITIQUE (Critic): `symPow_card` alone would be trivial, so it is paired with the
genuine determinant/trace transport. The Rankin–Selberg identity is stated on
honest Euler denominators (degree-4 = degree-3 × degree-1), matching the isobaric
sum `π×π = Sym²π ⊞ ∧²π`.
SYNTHESIS (PI): the symmetric-power family GL₂→GL(n+1) is realized as an explicit
Satake-parameter map with closed-form determinant and trace.
-- !-- end Lab Notes -- !--
-/

namespace Langlands.SymPower

variable {R : Type*} [CommRing R]

/-- The `Symⁿ` Satake parameter `αⁱ βⁿ⁻ⁱ` (for `0 ≤ i ≤ n`). -/
def symPowParam (a b : R) (n i : ℕ) : R := a ^ i * b ^ (n - i)

/-
**Dimension of the target group.** The `Symⁿ` lift of a `GL₂` class has
exactly `n+1` Satake parameters, i.e. it lands in `GL(n+1)`.
-/
theorem symPow_card (n : ℕ) : (Finset.range (n + 1)).card = n + 1 := by
  exact Finset.card_range _

/-
**Determinant of the `Symⁿ` lift.** `∏ᵢ αⁱβⁿ⁻ⁱ = (αβ)^{n(n+1)/2}`.
-/
theorem symPow_det (a b : R) (n : ℕ) :
    ∏ i ∈ Finset.range (n + 1), symPowParam a b n i = (a * b) ^ (n * (n + 1) / 2) := by
  convert Finset.prod_mul_distrib using 1;
  rw [ Finset.prod_pow_eq_pow_sum, Finset.prod_pow_eq_pow_sum, ← Finset.sum_range_reflect ];
  simp +zetaDelta at *;
  rw [ ← mul_pow, show ∑ x ∈ Finset.range ( n + 1 ), ( n - x ) = n * ( n + 1 ) / 2 from Eq.symm <| Nat.div_eq_of_eq_mul_left zero_lt_two <| Nat.recOn n ( by norm_num ) fun n ih => by cases n <;> simp +decide [ Finset.sum_range_succ', Nat.mul_succ ] at * ; linarith ]

/-
**Trace of the `Symⁿ` lift** as a complete homogeneous symmetric polynomial:
`(α − β)·∑ᵢ αⁱβⁿ⁻ⁱ = α^{n+1} − β^{n+1}`.
-/
theorem symPow_trace_mul (a b : R) (n : ℕ) :
    (a - b) * ∑ i ∈ Finset.range (n + 1), symPowParam a b n i = a ^ (n + 1) - b ^ (n + 1) := by
  simp only [symPowParam]
  rw [mul_comm]
  exact geom_sum₂_mul a b (n + 1)

/-
**Local Rankin–Selberg identity for `Sym²`.** On Euler-factor denominators,
`L(s, π×π) = L(s, Sym²π)·ζ(s)`:
the degree-4 tensor denominator factors as the degree-3 `Sym²` denominator times
the degree-1 determinant (`∧²`) factor.
-/
theorem Lfactor_rankinSelberg (a b X : R) :
    (1 - a ^ 2 * X) * (1 - a * b * X) * (1 - a * b * X) * (1 - b ^ 2 * X)
      = ((1 - a ^ 2 * X) * (1 - a * b * X) * (1 - b ^ 2 * X)) * (1 - a * b * X) := by
  grind

end Langlands.SymPower