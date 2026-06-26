/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# The full √k approximate Carathéodory theorem (Maurey's empirical method)

This file proves the quantitative approximate Carathéodory theorem in a real inner
product space: any point `x = Σ pᵢ Vᵢ` of the convex hull of vectors of norm `≤ R`
is approximated by an average of `k` of them (with repetition) to within
`R/√k` — formally, `‖x - (1/k) Σ V(f j)‖² ≤ R²/k`.

The proof is Maurey's empirical (probabilistic) method over the product index set
`Ω = Fin k → ι` with the product weight `q ω = ∏ⱼ p(ωⱼ)`:

* the variance of the empirical mean is `τ/k` with `τ = Σ pᵢ‖x - Vᵢ‖² ≤ R²`
  (off-diagonal terms vanish by independence, `marg_off`; diagonal terms each
  contribute `τ`, `marg_diag`);
* the averaging principle then extracts one tuple achieving at most the mean.

-- !-- Lab Notes -- !--
Hypothesis: the `k = 1` base case of `Maurey.lean` upgrades to the full `R²/k`
rate via the variance of an average of `k` i.i.d. selections.

Experiment: introduced the product index `Fin k → ι`; reduced the empirical error
to a double sum of inner products; computed its expectation by marginalization
(`marg_diag`, `marg_off`). The factorization `Finset.prod_univ_sum` /
`Fintype.piFinset_univ` is the workhorse for summing over the product index.

Analysis: independence is the off-diagonal vanishing `marg_off`, which holds
because `Σ pᵢ•(x - Vᵢ) = 0` (the deviations are mean-zero); this is exactly the
`x = Σ pᵢ Vᵢ` hypothesis again. The diagonal marginalizes one coordinate at a
time, each free coordinate contributing a factor `Σ pᵢ = 1`.

Critique: brute-force `#eval` over square vertices found no violation of `R²/k`
(see `ComputationalEvidence.md`); the bound is a worst-case guarantee, not tight on
symmetric sets.

Synthesis: this is the quantitative companion to the contraction theorem — both
exhibit the `1/√k` vs `(1/λ)^k` faces of "refinement reduces error".
-- !-- end Lab Notes -- !--
-/

namespace ApproxCaratheodory.General

open scoped RealInnerProductSpace
open Finset

/-- Averaging principle: some index does at least as well as the weighted average. -/
theorem exists_le_weighted_average {ι : Type*} [Fintype ι] [Nonempty ι]
    (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) (g : ι → ℝ) :
    ∃ i, g i ≤ ∑ j, p j * g j := by
  obtain ⟨i₀, _, hi₀⟩ :=
    Finset.exists_min_image Finset.univ g Finset.univ_nonempty
  refine ⟨i₀, ?_⟩
  calc g i₀ = ∑ j, p j * g i₀ := by rw [← Finset.sum_mul, hsum, one_mul]
    _ ≤ ∑ j, p j * g j :=
        Finset.sum_le_sum fun j _ =>
          mul_le_mul_of_nonneg_left (hi₀ j (Finset.mem_univ j)) (hp j)

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

omit [Fintype ι] [DecidableEq ι] in
/-- The product weight is nonnegative. -/
theorem prod_weight_nonneg (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) {k : ℕ}
    (ω : Fin k → ι) : 0 ≤ ∏ j, p (ω j) :=
  Finset.prod_nonneg fun _ _ => hp _

omit [DecidableEq ι] in
/-- The product weight over the product index `Fin k → ι` sums to `1`. -/
theorem prod_weight_sum_one (p : ι → ℝ) (hsum : ∑ i, p i = 1) (k : ℕ) :
    ∑ ω : Fin k → ι, ∏ j, p (ω j) = 1 := by
  have h : ∑ ω : Fin k → ι, ∏ j, p (ω j) = ∏ _j : Fin k, ∑ i, p i := by
    rw [Finset.prod_univ_sum, Fintype.piFinset_univ]
  rw [h, hsum]; simp

omit [DecidableEq ι] in
/--
**Single-coordinate scalar marginalization.** Summing a quantity that depends
on one coordinate against the product weight marginalizes the others (each
contributing `Σ pᵢ = 1`). Proof idea: write the summand as `∏ⱼ Hⱼ(ωⱼ)` with
`H_a i = p i * φ i` and `H_j = p` for `j ≠ a`, apply `Finset.prod_univ_sum` and
`Fintype.piFinset_univ`, then `Finset.mul_prod_erase` to isolate the `a`-factor;
the remaining factors are each `∑ᵢ pᵢ = 1`.
-/
theorem marg_single (p : ι → ℝ) (hsum : ∑ i, p i = 1) {k : ℕ} (a : Fin k)
    (φ : ι → ℝ) :
    ∑ ω : Fin k → ι, (∏ j, p (ω j)) * φ (ω a) = ∑ i, p i * φ i := by
  convert Finset.prod_univ_sum ( fun _ => Finset.univ ) ( fun j i => ( if j = a then p i * φ i else p i ) ) |> Eq.symm using 1;
  · refine' Finset.sum_bij ( fun ω _ => fun i => ω i ) _ _ _ _ <;> simp +decide [ Finset.prod_ite, Finset.filter_ne', Finset.filter_eq' ];
    exact fun ω => by rw [ mul_right_comm, ← Finset.mul_prod_erase _ _ ( Finset.mem_univ a ) ] ;
  · rw [ Finset.prod_eq_mul_prod_diff_singleton ( Finset.mem_univ a ) ] ; aesop

omit [DecidableEq ι] in
/--
**Two-coordinate scalar marginalization (independence).** For distinct
coordinates the expectation factorizes. Same proof idea as `marg_single` with two
distinguished factors `H_a i = p i * φ i`, `H_b i = p i * ψ i`.
-/
theorem marg_scalar (p : ι → ℝ) (hsum : ∑ i, p i = 1) {k : ℕ} (a b : Fin k)
    (hab : a ≠ b) (φ ψ : ι → ℝ) :
    ∑ ω : Fin k → ι, (∏ j, p (ω j)) * (φ (ω a) * ψ (ω b))
      = (∑ i, p i * φ i) * (∑ i, p i * ψ i) := by
  have marg_two : ∑ ω : Fin k → ι, (∏ j, p (ω j)) * (φ (ω a) * ψ (ω b)) = (∏ j, (∑ i, (if j = a then p i * φ i else if j = b then p i * ψ i else p i))) := by
    rw [ Finset.prod_sum ];
    refine' Finset.sum_bij ( fun ω _ => fun j _ => ω j ) _ _ _ _ <;> simp +decide;
    · simp +decide [ funext_iff ];
    · exact fun b => ⟨ fun j => b j ( Finset.mem_univ j ), rfl ⟩;
    · intro ω; rw [ ← Finset.prod_erase_mul _ _ ( Finset.mem_univ a ), ← Finset.prod_erase_mul _ _ ( Finset.mem_erase_of_ne_of_mem ( Ne.symm hab ) ( Finset.mem_univ b ) ) ] ; simp +decide [ Finset.prod_ite, Finset.filter_eq', Finset.filter_ne' ] ; ring;
      grind;
  simp_all +decide [ Finset.prod_ite, Finset.filter_eq', Finset.filter_ne' ];
  grind

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

omit [DecidableEq ι] in
/-- **Diagonal marginalization.** The single-coordinate version applied to
`φ i = ⟪u i, u i⟫`. -/
theorem marg_diag (p : ι → ℝ) (hsum : ∑ i, p i = 1) {k : ℕ} (a : Fin k)
    (u : ι → E) :
    ∑ ω : Fin k → ι, (∏ j, p (ω j)) * ⟪u (ω a), u (ω a)⟫ = ∑ i, p i * ⟪u i, u i⟫ :=
  marg_single p hsum a (fun i => ⟪u i, u i⟫)

/--
**Off-diagonal marginalization (independence).** For distinct coordinates the
expectation of the inner product vanishes up to the product of means. Proof idea:
expand `⟪u(ω a), u(ω b)⟫` over `s,t` via indicators so the scalar lemma
`marg_scalar` applies coordinatewise, then reassemble with bilinearity
(`sum_inner`, `inner_sum`, `inner_smul_left`, `inner_smul_right`); equivalently
use `marg_scalar` with indicator functions to get the marginal weight `pₛ pₜ`.
-/
theorem marg_off (p : ι → ℝ) (hsum : ∑ i, p i = 1) {k : ℕ} (a b : Fin k)
    (hab : a ≠ b) (u : ι → E) :
    ∑ ω : Fin k → ι, (∏ j, p (ω j)) * ⟪u (ω a), u (ω b)⟫
      = ⟪∑ i, p i • u i, ∑ i, p i • u i⟫ := by
  -- Use the linearity of the inner product to expand both sides.
  have h_expand_lhs : ∑ ω : Fin k → ι, (∏ j, p (ω j)) * ⟪u (ω a), u (ω b)⟫ = ∑ s : ι, ∑ t : ι, ⟪u s, u t⟫ * (∑ ω : Fin k → ι, (∏ j, p (ω j)) * (if ω a = s then 1 else 0) * (if ω b = t then 1 else 0)) := by
    simp +decide only [mul_comm];
    simp +decide [ Finset.mul_sum _ _ _ ];
    simp +decide [ Finset.sum_comm ];
  -- Apply the marg_scalar lemma to the inner sum.
  have h_inner_sum : ∀ s t : ι, ∑ ω : Fin k → ι, (∏ j, p (ω j)) * (if ω a = s then 1 else 0) * (if ω b = t then 1 else 0) = p s * p t := by
    intro s t;
    have := marg_scalar p hsum a b hab ( fun i => if i = s then 1 else 0 ) ( fun i => if i = t then 1 else 0 );
    simpa [ mul_assoc ] using this
  -- Substitute this result back into the expanded left-hand side.
  rw [h_expand_lhs];
  simp +decide only [h_inner_sum, inner_sum, inner_smul_right, sum_inner, inner_smul_left];
  simp +decide only [mul_comm, real_inner_comm, Finset.mul_sum _ _ _];
  simp +decide [ mul_assoc, mul_comm ]

/--
**Expectation bound.** The product-weighted mean squared error of the empirical
average of `k` selections is at most `R²/k`.
-/
theorem expectation_bound (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (V : ι → E) (R : ℝ) (hR : ∀ i, ‖V i‖ ≤ R) {k : ℕ} (hk : 1 ≤ k) :
    ∑ ω : Fin k → ι, (∏ j, p (ω j)) *
        ‖(∑ i, p i • V i) - (k : ℝ)⁻¹ • ∑ j, V (ω j)‖ ^ 2 ≤ R ^ 2 / k := by
  -- Set x := ∑ i, p i • V i and u i := x - V i.
  set x := ∑ i, p i • V i
  set u : ι → E := fun i => x - V i;
  -- Three facts:
  -- (A) ∑ i, p i • u i = 0.
  have hA : ∑ i, p i • u i = 0 := by
    simp +decide [ u, Finset.sum_sub_distrib, smul_sub, ← Finset.sum_smul, hsum ];
    exact sub_self x
  -- (B) τ := ∑ i, p i * ⟪u i, u i⟫ satisfies τ ≤ R².
  have hτ : ∑ i, p i * ⟪u i, u i⟫ ≤ R ^ 2 := by
    -- By expanding the inner product and using the fact that $x = \sum_{i} p_i V_i$, we can simplify the expression.
    have h_expand : ∑ i, p i * ⟪u i, u i⟫ = ∑ i, p i * (‖V i‖^2 - 2 * ⟪x, V i⟫ + ‖x‖^2) := by
      simp +zetaDelta at *;
      simp +decide only [norm_sub_sq_real, real_inner_comm] ; congr ; ext ; ring;
    -- By expanding the inner product and using the fact that $x = \sum_{i} p_i V_i$, we can simplify the expression further.
    have h_expand_simplified : ∑ i, p i * (‖V i‖^2 - 2 * ⟪x, V i⟫ + ‖x‖^2) = ∑ i, p i * ‖V i‖^2 - ‖x‖^2 := by
      simp +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hsum ];
      have h_expand_simplified : ∑ i, p i * (2 * ⟪x, V i⟫) = 2 * ⟪x, ∑ i, p i • V i⟫ := by
        simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, inner_sum, inner_smul_right ];
      rw [ h_expand_simplified, real_inner_self_eq_norm_sq ] ; ring;
    -- Since ‖V i‖ ≤ R for all i, we have ‖V i‖^2 ≤ R^2.
    have h_norm_sq_le_R_sq : ∀ i, ‖V i‖^2 ≤ R^2 := by
      exact fun i => pow_le_pow_left₀ ( norm_nonneg _ ) ( hR i ) 2;
    exact h_expand.symm ▸ h_expand_simplified.symm ▸ le_trans ( sub_le_self _ ( sq_nonneg _ ) ) ( le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( h_norm_sq_le_R_sq i ) ( hp i ) ) ( by simp +decide [ ← Finset.sum_mul, hsum ] ) )
  -- (C) x - (k : ℝ)⁻¹ • ∑ j, V (ω j) = (k : ℝ)⁻¹ • ∑ j, u (ω j).
  have hC : ∀ ω : Fin k → ι, x - (k : ℝ)⁻¹ • ∑ j, V (ω j) = (k : ℝ)⁻¹ • ∑ j, u (ω j) := by
    simp +zetaDelta at *;
    simp +decide [ smul_sub, ← smul_assoc, ne_of_gt ( zero_lt_one.trans_le hk ) ];
    simp +decide [ ← Nat.cast_smul_eq_nsmul ℝ, ne_of_gt ( zero_lt_one.trans_le hk ) ];
  -- So LHS = ∑ ω, (∏ j, p (ω j)) * (((k : ℝ)⁻¹)^2 * ∑ a, ∑ b, ⟪u (ω a), u (ω b)⟫).
  have h_lhs : ∑ ω : Fin k → ι, (∏ j, p (ω j)) * ‖x - (k : ℝ)⁻¹ • ∑ j, V (ω j)‖ ^ 2 = (1 / (k : ℝ)) ^ 2 * ∑ a : Fin k, ∑ b : Fin k, ∑ ω : Fin k → ι, (∏ j, p (ω j)) * ⟪u (ω a), u (ω b)⟫ := by
    have h_lhs : ∀ ω : Fin k → ι, ‖x - (k : ℝ)⁻¹ • ∑ j, V (ω j)‖ ^ 2 = (1 / (k : ℝ)) ^ 2 * ∑ a : Fin k, ∑ b : Fin k, ⟪u (ω a), u (ω b)⟫ := by
      intro ω
      rw [hC ω]
      simp [norm_smul];
      simp +decide only [norm_eq_sqrt_real_inner, mul_pow];
      rw [ Real.sq_sqrt ( by rw [ real_inner_self_eq_norm_sq ] ; positivity ), sum_inner, Finset.sum_congr rfl fun i _ => inner_sum _ _ _ ] ; simp +decide [ Finset.mul_sum _ _ _, Finset.sum_mul ];
    simp +decide only [h_lhs, Finset.mul_sum _ _ _, mul_left_comm];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm );
  -- For the inner (a,b) term: if a = b it equals τ by marg_diag; if a ≠ b it equals ⟪∑ i, p i • u i, ∑ i, p i • u i⟫ = ⟪0,0⟫ = 0 by marg_off and fact (A).
  have h_inner : ∀ a b : Fin k, ∑ ω : Fin k → ι, (∏ j, p (ω j)) * ⟪u (ω a), u (ω b)⟫ = if a = b then ∑ i, p i * ⟪u i, u i⟫ else 0 := by
    intro a b; split_ifs with hab; simp +decide [ hab, marg_diag, marg_off, hA ] ;
    · convert marg_diag p hsum b u using 1; all_goals simp +decide only [real_inner_self_eq_norm_sq];
    · rw [ marg_off p hsum a b hab u, hA, inner_zero_left ];
  simp_all +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  rw [ inv_mul_eq_div, div_le_div_iff₀ ] <;> first | positivity | nlinarith;

/-- **Approximate Carathéodory theorem (Maurey's empirical method).**
Every point `x = Σ pᵢ Vᵢ` of the convex hull of vectors of norm `≤ R` is within
squared distance `R²/k` of an average of `k` of them (with repetition). -/
theorem maurey_sqrt [Nonempty ι] (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i, p i = 1) (V : ι → E) (R : ℝ) (hR : ∀ i, ‖V i‖ ≤ R)
    {k : ℕ} (hk : 1 ≤ k) :
    ∃ f : Fin k → ι,
      ‖(∑ i, p i • V i) - (k : ℝ)⁻¹ • ∑ j, V (f j)‖ ^ 2 ≤ R ^ 2 / k := by
  haveI : Nonempty (Fin k → ι) := ⟨fun _ => Classical.arbitrary ι⟩
  obtain ⟨f, hf⟩ :=
    exists_le_weighted_average (fun ω : Fin k → ι => ∏ j, p (ω j))
      (fun ω => prod_weight_nonneg p hp ω) (prod_weight_sum_one p hsum k)
      (fun ω => ‖(∑ i, p i • V i) - (k : ℝ)⁻¹ • ∑ j, V (ω j)‖ ^ 2)
  exact ⟨f, le_trans hf (expectation_bound p hp hsum V R hR hk)⟩

end ApproxCaratheodory.General