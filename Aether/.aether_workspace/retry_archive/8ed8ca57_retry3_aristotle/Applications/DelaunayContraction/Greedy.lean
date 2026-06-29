/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# A deterministic, verifiable greedy procedure for approximate Carathéodory

The companion file `MaureyGeneral.lean` proves the approximate Carathéodory
theorem by Maurey's *probabilistic* (empirical) method: averaging over the
product index set shows that *some* tuple of `k` vertices approximates a convex
point `x = Σ pᵢ Vᵢ` to within `R²/k`. That is an existence ("heuristic")
statement: it asserts a good tuple exists without producing one.

This file transforms that heuristic into an explicit **deterministic procedure**
and proves a **sharper, exact error bound**. The procedure is the greedy
Frank–Wolfe-style selection over the current "Delaunay" vertex pool:

* maintain a running deviation sum `s₀ = 0`, `s_{t+1} = s_t + dev(iₜ)` where
  `dev i = Vᵢ - x` and `iₜ` is the vertex **minimizing** `‖s_t + dev i‖²`
  (`bestIdx`, a concrete arg-min — the linear-minimization step of the iterated
  refinement);
* the averaging engine ("you can always beat the weighted mean", here used in its
  deterministic arg-min form) gives the exact one-step inequality
  `‖s_{t+1}‖² ≤ ‖s_t‖² + τ` with the *variance* `τ = Σ pᵢ‖Vᵢ − x‖²`;
* induction yields `‖s_k‖² ≤ k·τ`, hence the empirical average of the `k`
  greedily chosen vertices satisfies

      ‖x − (1/k) Σⱼ V(greedyIdx j)‖²  ≤  τ / k  ≤  (R² − ‖x‖²)/k  ≤  R² / k.

The bound `τ/k` is **sharper** than the generic `R²/k` (it subtracts the squared
norm of `x`) and, unlike Maurey's method, it is attained by an **explicitly
constructed** sequence of vertices (`greedyIdx`), i.e. a verifiable algorithm
rather than an existence proof.

All results are proved with zero `sorry`s.
-/

namespace ApproxCaratheodory.Greedy

open scoped RealInnerProductSpace
open Finset
open Classical

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The deviation of vertex `i` from the target convex point `x = Σ pⱼ Vⱼ`. -/
noncomputable def dev (p : ι → ℝ) (V : ι → E) (i : ι) : E := V i - ∑ j, p j • V j

/-- The greedy (arg-min) selection: the vertex minimizing `‖s + dev i‖²`. This is
the deterministic linear-minimization step of the refinement procedure. -/
noncomputable def bestIdx (p : ι → ℝ) (V : ι → E) (s : E) : ι :=
  (Finset.exists_min_image Finset.univ (fun i => ‖s + dev p V i‖ ^ 2)
    Finset.univ_nonempty).choose

/-- The running sum of deviations produced by the greedy procedure:
`s₀ = 0`, `s_{t+1} = s_t + dev (bestIdx s_t)`. -/
noncomputable def greedySum (p : ι → ℝ) (V : ι → E) : ℕ → E
  | 0 => 0
  | (t + 1) => greedySum p V t + dev p V (bestIdx p V (greedySum p V t))

/-- The sequence of greedily chosen vertex indices. -/
noncomputable def greedyIdx (p : ι → ℝ) (V : ι → E) (t : ℕ) : ι :=
  bestIdx p V (greedySum p V t)

/-- The variance `τ = Σ pᵢ ‖Vᵢ − x‖²`, the exact per-step error increment. -/
noncomputable def tau (p : ι → ℝ) (V : ι → E) : ℝ := ∑ i, p i * ‖dev p V i‖ ^ 2

/--
`bestIdx` realizes the minimum: its squared error is no larger than any
vertex's.
-/
theorem bestIdx_spec (p : ι → ℝ) (V : ι → E) (s : E) (i : ι) :
    ‖s + dev p V (bestIdx p V s)‖ ^ 2 ≤ ‖s + dev p V i‖ ^ 2 := by
  exact Finset.exists_min_image Finset.univ ( fun i => ‖s + dev p V i‖ ^ 2 ) ( Finset.univ_nonempty ) |> fun h => h.choose_spec.2 i ( Finset.mem_univ i )

omit [Nonempty ι] in
/--
The weighted deviations cancel: `Σ pᵢ • dev i = 0` (because `x = Σ pⱼ Vⱼ`).
-/
theorem sum_weighted_dev_eq_zero (p : ι → ℝ) (hsum : ∑ i, p i = 1) (V : ι → E) :
    ∑ i, p i • dev p V i = 0 := by
  unfold dev
  simp [Finset.sum_sub_distrib, smul_sub, ← Finset.sum_smul, hsum]

omit [Nonempty ι] in
/--
**Averaging identity.** For any `s`, the weighted mean of `‖s + dev i‖²`
equals `‖s‖² + τ`. The cross term vanishes by `sum_weighted_dev_eq_zero`.
-/
theorem avg_sq_dev (p : ι → ℝ) (hsum : ∑ i, p i = 1) (V : ι → E) (s : E) :
    ∑ i, p i * ‖s + dev p V i‖ ^ 2 = ‖s‖ ^ 2 + tau p V := by
  simp only [tau]
  simp only [norm_add_sq_real, mul_add]
  simp only [sum_add_distrib]
  simp only [← Finset.sum_mul, hsum, one_mul]
  have h_inner : ∑ i, p i * (2 * ⟪s, dev p V i⟫) = 2 * ⟪s, ∑ i, p i • dev p V i⟫ := by
    simp only [inner_sum, inner_smul_right, Finset.mul_sum, mul_left_comm]
  rw [h_inner, sum_weighted_dev_eq_zero p hsum V, inner_zero_right, mul_zero, add_zero]

/--
**One greedy step.** The arg-min beats the weighted mean, so the squared
running sum grows by at most `τ`.
-/
theorem step_bound (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (V : ι → E) (s : E) :
    ‖s + dev p V (bestIdx p V s)‖ ^ 2 ≤ ‖s‖ ^ 2 + tau p V := by
  convert avg_sq_dev p hsum V s ▸ Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( bestIdx_spec p V s i ) ( hp i ) using 1;
  rw [ ← Finset.sum_mul, hsum, one_mul ]

/--
**Accumulated bound.** After `k` greedy steps, `‖s_k‖² ≤ k·τ`.
-/
theorem greedySum_sq_le (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (V : ι → E) (k : ℕ) :
    ‖greedySum p V k‖ ^ 2 ≤ (k : ℝ) * tau p V := by
  induction' k with k ih;
  · simp +decide [ greedySum ];
  · simpa [ add_mul ] using le_trans ( step_bound p hp hsum V _ ) ( by linarith )

omit [Nonempty ι] in
/--
The variance equals the weighted second moment minus `‖x‖²`.
-/
theorem tau_eq (p : ι → ℝ) (hsum : ∑ i, p i = 1) (V : ι → E) :
    tau p V = (∑ i, p i * ‖V i‖ ^ 2) - ‖∑ j, p j • V j‖ ^ 2 := by
  simp only [tau, dev]
  have h_expand : ∀ i, ‖V i - ∑ j, p j • V j‖ ^ 2
      = ‖V i‖ ^ 2 - 2 * ⟪V i, ∑ j, p j • V j⟫ + ‖∑ j, p j • V j‖ ^ 2 :=
    fun i => norm_sub_sq_real (V i) (∑ j, p j • V j)
  have h_cross : ∑ i, p i * (2 * ⟪V i, ∑ j, p j • V j⟫)
      = 2 * ‖∑ j, p j • V j‖ ^ 2 := by
    rw [show ∑ i, p i * (2 * ⟪V i, ∑ j, p j • V j⟫)
          = 2 * ⟪∑ i, p i • V i, ∑ j, p j • V j⟫ by
        rw [sum_inner, Finset.mul_sum]; simp [mul_left_comm, inner_smul_left]]
    rw [real_inner_self_eq_norm_sq]
  simp_rw [h_expand, mul_add, mul_sub]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, h_cross,
      ← Finset.sum_mul, hsum, one_mul]
  ring

omit [Nonempty ι] in
/--
The variance is bounded by `R²` when all vertices have norm `≤ R`.
-/
theorem tau_le_sq (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (V : ι → E) (R : ℝ) (hR : ∀ i, ‖V i‖ ≤ R) :
    tau p V ≤ R ^ 2 := by
  rw [ tau_eq p hsum V ];
  refine' le_trans ( sub_le_self _ ( sq_nonneg _ ) ) _;
  exact le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( pow_le_pow_left₀ ( norm_nonneg _ ) ( hR i ) 2 ) ( hp i ) ) ( by simp +decide [ ← Finset.sum_mul, hsum ] )

/--
The running sum equals the sum of chosen vertices minus `k` copies of `x`.
-/
theorem greedySum_eq (p : ι → ℝ) (V : ι → E) (k : ℕ) :
    greedySum p V k
      = (∑ t : Fin k, V (greedyIdx p V (t : ℕ))) - (k : ℝ) • ∑ j, p j • V j := by
  induction' k with k ih;
  · simp +decide [ greedySum ];
  · -- By definition of `greedySum`, we have `greedySum p V (k + 1) = greedySum p V k + dev p V (greedyIdx p V k)`.
    have h_step : greedySum p V (k + 1) = greedySum p V k + dev p V (greedyIdx p V k) := by
      rfl;
    simp_all +decide [ Fin.sum_univ_castSucc, dev ];
    rw [ add_smul, one_smul ] ; abel1

/--
The approximation error of the greedy average is `-(1/k)·s_k`.
-/
theorem error_eq (p : ι → ℝ) (V : ι → E) {k : ℕ} (hk : 1 ≤ k) :
    (∑ j, p j • V j) - (k : ℝ)⁻¹ • ∑ t : Fin k, V (greedyIdx p V (t : ℕ))
      = -((k : ℝ)⁻¹ • greedySum p V k) := by
  -- By definition of `greedySum`, we know that `greedySum p V k = (∑ t : Fin k, V (greedyIdx p V (t : ℕ))) - (k : ℝ) • (∑ j, p j • V j)`.
  have h_greedy_sum : greedySum p V k
      = (∑ t : Fin k, V (greedyIdx p V (t : ℕ))) - (k : ℝ) • (∑ j, p j • V j) :=
    greedySum_eq p V k
  simp [h_greedy_sum, smul_sub, smul_smul, Nat.cast_ne_zero.mpr (ne_of_gt hk)]

/--
**Deterministic approximate Carathéodory (sharp form).** The empirical average
of the `k` greedily chosen vertices approximates `x = Σ pⱼ Vⱼ` to within the exact
variance bound `τ/k`. This is an explicitly constructed witness, not a mere
existence statement.
-/
theorem greedy_caratheodory (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (V : ι → E) {k : ℕ} (hk : 1 ≤ k) :
    ‖(∑ j, p j • V j) - (k : ℝ)⁻¹ • ∑ t : Fin k, V (greedyIdx p V (t : ℕ))‖ ^ 2
      ≤ tau p V / k := by
  have hk0 : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hnorm :
      ‖(∑ j, p j • V j) - (k : ℝ)⁻¹ • ∑ t : Fin k, V (greedyIdx p V (t : ℕ))‖ ^ 2
        = ((k : ℝ) ^ 2)⁻¹ * ‖greedySum p V k‖ ^ 2 := by
    rw [error_eq p V hk, norm_neg, norm_smul, mul_pow, Real.norm_eq_abs, ← abs_pow,
      abs_of_nonneg (sq_nonneg _), inv_pow]
  rw [hnorm]
  calc ((k : ℝ) ^ 2)⁻¹ * ‖greedySum p V k‖ ^ 2
      ≤ ((k : ℝ) ^ 2)⁻¹ * ((k : ℝ) * tau p V) :=
        mul_le_mul_of_nonneg_left (greedySum_sq_le p hp hsum V k) (by positivity)
    _ = tau p V / k := by field_simp

/--
**Variance form.** With `‖Vᵢ‖ ≤ R`, the greedy average error is at most
`(R² − ‖x‖²)/k`, sharper than the generic `R²/k`.
-/
theorem greedy_caratheodory_variance (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i, p i = 1) (V : ι → E) (R : ℝ) (hR : ∀ i, ‖V i‖ ≤ R)
    {k : ℕ} (hk : 1 ≤ k) :
    ‖(∑ j, p j • V j) - (k : ℝ)⁻¹ • ∑ t : Fin k, V (greedyIdx p V (t : ℕ))‖ ^ 2
      ≤ (R ^ 2 - ‖∑ j, p j • V j‖ ^ 2) / k := by
  refine' le_trans ( greedy_caratheodory p hp hsum V hk ) _;
  rw [ tau_eq p hsum V ];
  gcongr;
  exact le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( pow_le_pow_left₀ ( norm_nonneg _ ) ( hR i ) 2 ) ( hp i ) ) ( by simp +decide [ ← Finset.sum_mul, hsum ] )

/--
**`R²/k` form.** The deterministic greedy procedure matches Maurey's
probabilistic `R²/k` rate while producing an explicit witness.
-/
theorem greedy_caratheodory_R (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i, p i = 1) (V : ι → E) (R : ℝ) (hR : ∀ i, ‖V i‖ ≤ R)
    {k : ℕ} (hk : 1 ≤ k) :
    ‖(∑ j, p j • V j) - (k : ℝ)⁻¹ • ∑ t : Fin k, V (greedyIdx p V (t : ℕ))‖ ^ 2
      ≤ R ^ 2 / k := by
  refine le_trans (greedy_caratheodory p hp hsum V hk) ?_
  gcongr
  exact tau_le_sq p hp hsum V R hR

end ApproxCaratheodory.Greedy