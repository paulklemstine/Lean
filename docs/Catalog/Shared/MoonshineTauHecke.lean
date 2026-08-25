import Mathlib
import Shared.MoonshineJExpansion

/-!
# Integrality of the `j`-quotient, and verified Hecke/Ramanujan data for `τ`

Second research cycle on top of `Shared.MoonshineJExpansion`.  That file
computed, inside the kernel, the head of the `q`-expansion of `j = E₄³/Δ` and
the first eight Ramanujan tau values.  Here we extract the structure behind
those computations.

* **Integrality.** `MoonshineTauHecke.exists_unique_jQuot`: the eta product
  `deltaPart m = ∏_{k≤m}(1-q^k)^24` is a *unit* of `ℤ⟦X⟧`, so the equation
  `deltaPart m · f = E₄³` has a unique solution `f = jQuot m` **over `ℤ`**.  No
  denominators appear: the coefficients of `q·j` are integers by pure formal
  algebra, and `MoonshineTauHecke.coeff_jQuot_head` identifies the first eight
  of them with the verified table.
* **Stability.** `MoonshineTauHecke.jQuot_stable`: the solution does not depend
  on the truncation `m` of the eta product below degree `N` once `m ≥ N - 1`, so
  "the" `q`-expansion of `j` is well defined coefficientwise without any
  analytic input.
* **Hecke relations.** `MoonshineTauHecke.tau_hecke_mul`,
  `tau_hecke_prime_square`, `tau_hecke_eight`: the multiplicativity
  `τ(2)τ(3) = τ(6)` and the recursions `τ(4) = τ(2)² - 2¹¹`,
  `τ(8) = τ(2)τ(4) - 2¹¹τ(2)` hold for the coefficients *produced by the eta
  product*, i.e. they are verified consequences of the computation rather than
  quoted facts.
* **Ramanujan's congruence.** `MoonshineTauHecke.tau_ramanujan_congruence`:
  `τ(n) ≡ σ₁₁(n) (mod 691)` for every `n ≤ 8`, again on the computed values.
* **Lehmer's question.** `MoonshineTauHecke.tau_ne_zero_below_nine`: the computed
  `τ(n)` are non-zero for `n ≤ 8` — the first verified window of Lehmer's open
  non-vanishing conjecture.

Every statement below is about `coeff n (deltaPart m)` or about the honest
power series `E4`, so nothing is asserted on the strength of tabulated data.
-/

namespace MoonshineTauHecke

open Finset PowerSeries MoonshineJ

/-! ## 1. The integral quotient `E₄³ / (Δ/q)` -/

/-- The unique power series `f` over `ℤ` with `deltaPart m · f = E₄³`. -/
noncomputable def jQuot (m : ℕ) : PowerSeries ℤ := Ring.inverse (deltaPart m) * E4 ^ 3

theorem deltaPart_mul_jQuot (m : ℕ) : deltaPart m * jQuot m = E4 ^ 3 := by
  rw [jQuot, ← mul_assoc, Ring.mul_inverse_cancel _ (isUnit_deltaPart m), one_mul]

/-- **Integrality and uniqueness.**  Dividing `E₄³` by the eta product stays
inside `ℤ⟦X⟧`, and the quotient is unique. -/
theorem exists_unique_jQuot (m : ℕ) : ∃! f : PowerSeries ℤ, deltaPart m * f = E4 ^ 3 := by
  refine ⟨jQuot m, deltaPart_mul_jQuot m, ?_⟩
  intro f hf
  have hcancel : deltaPart m * f = deltaPart m * jQuot m := by
    rw [hf, deltaPart_mul_jQuot]
  obtain ⟨u, hu⟩ := isUnit_deltaPart m
  rw [← hu] at hcancel
  exact (mul_right_injective₀ (Units.ne_zero u)) hcancel

/-- The quotient is independent of the truncation of the eta product, below the
degrees the truncation controls. -/
theorem jQuot_stable {N m m' : ℕ} (h : N ≤ m + 1) (h' : N ≤ m' + 1) :
    AgreeBelow N (jQuot m) (jQuot m') := by
  have hprod : AgreeBelow N (deltaPart m * jQuot m) (deltaPart m * jQuot m') := by
    have h1 : AgreeBelow N (deltaPart m * jQuot m) (E4 ^ 3) := by
      rw [deltaPart_mul_jQuot m]
    have h2 : AgreeBelow N (deltaPart m' * jQuot m') (E4 ^ 3) := by
      rw [deltaPart_mul_jQuot m']
    have h3 : AgreeBelow N (deltaPart m * jQuot m') (deltaPart m' * jQuot m') :=
      (deltaPart_stable h h').mul (AgreeBelow.refl N (jQuot m'))
    exact h1.trans (h2.symm.trans h3.symm)
  exact AgreeBelow.cancel_left (isUnit_deltaPart m) hprod

/-- The head of the integral quotient is the verified table
`1, 744, 196884, 21493760, …`. -/
theorem coeff_jQuot_head {m : ℕ} (hm : 7 ≤ m) (n : ℕ) (hn : n < 8) :
    coeff n (jQuot m) = cf jT n := by
  have h := j_coefficients_unique (jQuot m) hm (by rw [deltaPart_mul_jQuot m])
  rw [h n hn, coeff_jSeries]

/-- **Integral head coefficient of `j`.**  The `1A` entry `c(1) = 196884` of the
Monstrous-Moonshine head table, as a coefficient of the integral quotient. -/
theorem coeff_jQuot_two {m : ℕ} (hm : 7 ≤ m) : coeff 2 (jQuot m) = 196884 := by
  rw [coeff_jQuot_head hm 2 (by norm_num)]
  decide

/-! ## 2. Hecke relations on the computed tau values

`coeff n (deltaPart m) = τ(n+1)`, so the following are the classical relations
`τ(2)τ(3) = τ(6)`, `τ(4) = τ(2)² - 2¹¹` and `τ(8) = τ(2)τ(4) - 2¹¹τ(2)`. -/

/-- Multiplicativity of `τ` at coprime arguments, instance `2 · 3 = 6`. -/
theorem tau_hecke_mul {m : ℕ} (hm : 7 ≤ m) :
    coeff 1 (deltaPart m) * coeff 2 (deltaPart m) = coeff 5 (deltaPart m) := by
  rw [tau_values hm 1 (by norm_num), tau_values hm 2 (by norm_num),
    tau_values hm 5 (by norm_num)]
  decide

/-- The Hecke recursion at a prime square, instance `τ(4) = τ(2)² - 2¹¹`. -/
theorem tau_hecke_prime_square {m : ℕ} (hm : 7 ≤ m) :
    coeff 3 (deltaPart m) = coeff 1 (deltaPart m) ^ 2 - 2 ^ 11 := by
  rw [tau_values hm 1 (by norm_num), tau_values hm 3 (by norm_num)]
  decide

/-- The Hecke recursion at a prime cube, instance
`τ(8) = τ(2)τ(4) - 2¹¹ τ(2)`. -/
theorem tau_hecke_eight {m : ℕ} (hm : 7 ≤ m) :
    coeff 7 (deltaPart m) = coeff 1 (deltaPart m) * coeff 3 (deltaPart m)
      - 2 ^ 11 * coeff 1 (deltaPart m) := by
  rw [tau_values hm 1 (by norm_num), tau_values hm 3 (by norm_num),
    tau_values hm 7 (by norm_num)]
  decide

/-! ## 3. Ramanujan's congruence and Lehmer's question -/

/-- **Ramanujan's congruence, verified window.**  For every `n ≤ 8` the computed
value `τ(n)` satisfies `τ(n) ≡ σ₁₁(n) (mod 691)`. -/
theorem tau_ramanujan_congruence {m : ℕ} (hm : 7 ≤ m) (n : ℕ) (hn : n < 8) :
    (691 : ℤ) ∣ (coeff n (deltaPart m) - ((∑ d ∈ (n + 1).divisors, d ^ 11 : ℕ) : ℤ)) := by
  rw [tau_values hm n hn]
  interval_cases n <;> decide

/-- **Lehmer's non-vanishing question, verified window.**  The computed `τ(n)`
are non-zero for `n ≤ 8`. -/
theorem tau_ne_zero_below_nine {m : ℕ} (hm : 7 ≤ m) (n : ℕ) (hn : n < 8) :
    coeff n (deltaPart m) ≠ 0 := by
  rw [tau_values hm n hn]
  interval_cases n <;> decide

/-- The alternating sign pattern of `τ` on the first few even arguments:
`τ(2) < 0 < τ(3)`, `τ(4) < 0 < τ(5)`. -/
theorem tau_sign_pattern {m : ℕ} (hm : 7 ≤ m) :
    coeff 1 (deltaPart m) < 0 ∧ 0 < coeff 2 (deltaPart m) ∧
      coeff 3 (deltaPart m) < 0 ∧ 0 < coeff 4 (deltaPart m) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [tau_values hm 1 (by norm_num)]; decide
  · rw [tau_values hm 2 (by norm_num)]; decide
  · rw [tau_values hm 3 (by norm_num)]; decide
  · rw [tau_values hm 4 (by norm_num)]; decide

/-- The Ramanujan–Deligne bound `|τ(p)| ≤ 2 p^{11/2}` in its squared form
`τ(p)² ≤ 4 p¹¹`, verified at `p = 2, 3, 5, 7`. -/
theorem tau_deligne_bound_small {m : ℕ} (hm : 7 ≤ m) :
    coeff 1 (deltaPart m) ^ 2 ≤ 4 * 2 ^ 11 ∧
      coeff 2 (deltaPart m) ^ 2 ≤ 4 * 3 ^ 11 ∧
      coeff 4 (deltaPart m) ^ 2 ≤ 4 * 5 ^ 11 ∧
      coeff 6 (deltaPart m) ^ 2 ≤ 4 * 7 ^ 11 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [tau_values hm 1 (by norm_num)]; decide
  · rw [tau_values hm 2 (by norm_num)]; decide
  · rw [tau_values hm 4 (by norm_num)]; decide
  · rw [tau_values hm 6 (by norm_num)]; decide

end MoonshineTauHecke