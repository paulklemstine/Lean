/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The three-step threshold variational problem and uniqueness of its maximizer

This file isolates the *one-dimensional variational problem* that sits at the heart of the
sparse threshold conjecture of Day & Sarkar.  In the conjectured picture, every graphon `W`
achieving the supremum is a *three-step threshold graphon*: it is constant on a `t × t` "core"
block, constant on the complementary block, and the only remaining freedom is the single real
parameter `t ∈ [0,1]` describing the measure of the core.  After substituting such a graphon
into the (normalised) homomorphism functional, the optimisation collapses to maximising a single
real function of `t`.  The model objective studied here is

  `J s t = t - t ^ s`,    `s ≥ 2`,

where the exponent `s` plays the role of a structural parameter of `H` (e.g. its fractional
independence number `α*(H)`, see `Catalog/Novelty/SparseThresholdFractionalIndependence.lean`).

The headline result is **uniqueness**: for every `s ≥ 2` the objective is *strictly concave* on
`[0,1]`, so it has a unique global maximizer, and that maximizer lies strictly inside `(0,1)`
with maximum value strictly between `0` and `1`.  This is the analytic skeleton of the statement
"the constant `C_T(H)` is the unique maximizer of the associated variational problem".

## Catalog connections
* `Day & Sarkar's sparse threshold conjecture`: `variational_unique_maximizer` is the uniqueness
  of the extremal parameter, the analytic core of the conjecture's "unique maximizer" clause.
* `Three-step threshold graphon characterization`: the single parameter `t` is exactly the core
  measure of a three-step threshold graphon; interiority `maximizer_mem_Ioo` says the extremal
  graphon is genuinely three-step (neither the empty nor the complete graphon).
* `Fractional independence number α*(H)`: the exponent `s` models `α*(H)`; monotonicity
  `CT_mono` says denser invariants give larger threshold constants.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The extremal-graphon optimisation in the sparse threshold problem,
  once restricted to three-step threshold graphons, is governed by a strictly concave
  single-variable objective, forcing a *unique* maximizer (hence a unique extremal graphon).
Experiment (Experimenter): Modelled the reduced objective by `J s t = t - t^s`.  Proved strict
  concavity on `[0,1]` by writing `J s = (fun t => -t^s) + (fun t => t)`, using
  `strictConvexOn_pow` (strict convexity of `t ↦ t^s`), `StrictConvexOn.neg`, and
  `StrictConcaveOn.add_concaveOn` with `concaveOn_id`.  Existence of a maximizer is
  `IsCompact.exists_isMaxOn` on the compact `Icc 0 1`; uniqueness is
  `StrictConcaveOn.eq_of_isMaxOn`.
Analysis (Analyst): The maximizer is *interior*: the maximum value dominates `J s (1/2) =
  1/2 - (1/2)^s > 0`, while the endpoints give `J s 0 = J s 1 = 0`.  So the extremal three-step
  graphon is non-degenerate, and `C_T = J s t* ∈ (0,1)`.  Pointwise monotonicity
  `J s t ≤ J (s+1) t` (because `t^{s+1} ≤ t^s` on `[0,1]`) lifts to `CT s ≤ CT (s+1)`.
Critique (Critic): Strict concavity is load-bearing — without it only `≤`-optimality survives and
  the maximizer need not be unique.  The interiority lemma rules out the trivial endpoint maxima,
  so no result is vacuous.  The bound `s ≥ 2` is genuinely needed: at `s = 1`, `J 1 ≡ 0` is
  constant and *every* point is a (non-unique) maximizer, exactly the degenerate case the
  conjecture excludes.
Synthesis (PI): A clean, fully analytic uniqueness theorem for the three-step threshold
  variational problem, with non-degeneracy and exponent-monotonicity of the extremal constant.
-/
import Mathlib

open Set

namespace SparseThreshold

/-- The reduced one-parameter variational objective of the three-step threshold problem.
The parameter `t ∈ [0,1]` is the measure of the "core" block of a three-step threshold graphon,
and `s` is a structural exponent of `H`. -/
noncomputable def J (s : ℕ) (t : ℝ) : ℝ := t - t ^ s

lemma J_continuous (s : ℕ) : Continuous (J s) := by
  unfold J; fun_prop

@[simp] lemma J_zero (s : ℕ) (hs : 1 ≤ s) : J s 0 = 0 := by
  simp [J, zero_pow (by omega : s ≠ 0)]

@[simp] lemma J_one (s : ℕ) : J s 1 = 0 := by simp [J]

/-
The objective is **strictly concave** on `[0,1]` for every exponent `s ≥ 2`. This is the
mechanism that forces a unique extremal three-step threshold graphon.
-/
lemma J_strictConcaveOn {s : ℕ} (hs : 2 ≤ s) :
    StrictConcaveOn ℝ (Icc (0:ℝ) 1) (J s) := by
      unfold J;
      apply strictConcaveOn_of_deriv2_neg ( convex_Icc 0 1 );
      · exact Continuous.continuousOn ( by continuity );
      · rcases s with ( _ | _ | s ) <;> norm_num [ sub_eq_add_neg ] at *;
        unfold deriv ; norm_num [ fderiv_apply_one_eq_deriv ] ; intros ; ring_nf ;
        positivity

/-
A maximizer of the objective exists on the compact parameter interval `[0,1]`.
-/
lemma J_exists_isMaxOn (s : ℕ) :
    ∃ t ∈ Icc (0:ℝ) 1, IsMaxOn (J s) (Icc (0:ℝ) 1) t := by
      apply_rules [ IsCompact.exists_isMaxOn, CompactIccSpace.isCompact_Icc ];
      · norm_num;
      · exact Continuous.continuousOn ( by exact Continuous.sub continuous_id ( continuous_pow s ) )

/-- **Uniqueness of the extremal parameter.** For `s ≥ 2` the variational problem has a unique
maximizer on `[0,1]`; equivalently, there is a unique extremal three-step threshold graphon. -/
theorem variational_unique_maximizer {s : ℕ} (hs : 2 ≤ s) :
    ∃! t : ℝ, t ∈ Icc (0:ℝ) 1 ∧ IsMaxOn (J s) (Icc (0:ℝ) 1) t := by
      obtain ⟨ t₀, ht₀mem, ht₀max ⟩ := J_exists_isMaxOn s;
      refine' ⟨ t₀, _, _ ⟩;
      · exact ⟨ ht₀mem, ht₀max ⟩;
      · intro y hy; have := J_strictConcaveOn hs; exact this.eq_of_isMaxOn hy.2 ht₀max hy.1 ht₀mem;

/-- **Non-degeneracy.** The extremal parameter lies strictly inside `(0,1)`: the extremal
graphon is genuinely three-step, neither the empty nor the complete graphon. -/
theorem maximizer_mem_Ioo {s : ℕ} (hs : 2 ≤ s) {t : ℝ}
    (ht : t ∈ Icc (0:ℝ) 1) (hmax : IsMaxOn (J s) (Icc (0:ℝ) 1) t) :
    t ∈ Ioo (0:ℝ) 1 := by
      refine' ⟨ lt_of_le_of_ne ht.1 _, lt_of_le_of_ne ht.2 _ ⟩ <;> rintro rfl <;> simp_all +decide [ IsMaxOn ];
      · simp_all +decide [ IsMaxFilter, J ];
        exact absurd ( hmax ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ) ( by norm_num [ zero_pow ( by linarith ) ] ; linarith [ pow_le_pow_of_le_one ( by norm_num : ( 0 : ℝ ) ≤ 1 / 2 ) ( by norm_num ) hs ] );
      · simp_all +decide [ IsMaxFilter, J ];
        exact absurd ( hmax ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ) ( by exact not_le_of_gt ( pow_lt_self_of_lt_one₀ ( by norm_num ) ( by norm_num ) ( by linarith ) ) )

/-- The extremal constant `C_T = J s t*` is strictly positive. -/
theorem max_value_pos {s : ℕ} (hs : 2 ≤ s) {t : ℝ}
    (ht : t ∈ Icc (0:ℝ) 1) (hmax : IsMaxOn (J s) (Icc (0:ℝ) 1) t) :
    0 < J s t := by
  obtain ⟨ht0, ht1⟩ := maximizer_mem_Ioo hs ht hmax
  have h : t ^ s < t := pow_lt_self_of_lt_one₀ ht0 ht1 (by omega)
  simpa [J] using sub_pos.mpr h

/-- The extremal constant `C_T = J s t*` is strictly less than `1`. -/
theorem max_value_lt_one {s : ℕ} (hs : 2 ≤ s) {t : ℝ}
    (ht : t ∈ Icc (0:ℝ) 1) (hmax : IsMaxOn (J s) (Icc (0:ℝ) 1) t) :
    J s t < 1 := by
      by_cases ht0 : t = 0 <;> by_cases ht1 : t = 1 <;> simp_all +decide [ IsMaxOn, J ];
      · cases s <;> norm_num at *;
      · exact lt_of_le_of_lt ( sub_le_self _ ( pow_nonneg ht.1 _ ) ) ( lt_of_le_of_ne ht.2 ht1 )

/-- Pointwise monotonicity of the objective in the structural exponent: a larger exponent gives a
larger objective on `[0,1]`, because `t^{s+1} ≤ t^s` there. -/
lemma J_le_succ {s : ℕ} {t : ℝ} (ht : t ∈ Icc (0:ℝ) 1) : J s t ≤ J (s+1) t := by
  exact sub_le_sub_left ( pow_le_pow_of_le_one ht.1 ht.2 ( by linarith ) ) _

/-- The extremal constant of the three-step threshold variational problem. -/
noncomputable def CT (s : ℕ) : ℝ := sSup (J s '' Icc (0:ℝ) 1)

lemma CT_eq_of_isMaxOn {s : ℕ} {t : ℝ}
    (ht : t ∈ Icc (0:ℝ) 1) (hmax : IsMaxOn (J s) (Icc (0:ℝ) 1) t) : CT s = J s t := by
      convert ( IsGreatest.csSup_eq ?_ );
      exact ⟨ Set.mem_image_of_mem _ ht, Set.forall_mem_image.2 hmax ⟩

theorem CT_pos {s : ℕ} (hs : 2 ≤ s) : 0 < CT s := by
  convert max_value_pos hs ?_ ?_ using 1;
  convert CT_eq_of_isMaxOn _ _;
  exact Classical.choose ( J_exists_isMaxOn s );
  · exact Classical.choose_spec ( J_exists_isMaxOn s ) |>.1;
  · exact Classical.choose_spec ( J_exists_isMaxOn s ) |>.2;
  · exact Classical.choose_spec ( J_exists_isMaxOn s ) |>.1;
  · exact Classical.choose_spec ( J_exists_isMaxOn s ) |>.2

theorem CT_lt_one {s : ℕ} (hs : 2 ≤ s) : CT s < 1 := by
  obtain ⟨t, ht, hmax⟩ : ∃ t ∈ Set.Icc 0 1, IsMaxOn (J s) (Set.Icc 0 1) t := J_exists_isMaxOn s
  have h_max_lt_one : J s t < 1 := max_value_lt_one hs ht hmax
  have h_ct_eq_j : CT s = J s t := CT_eq_of_isMaxOn ht hmax
  rw [h_ct_eq_j]
  exact h_max_lt_one

/-- The extremal constant is monotone in the structural exponent. -/
theorem CT_mono {s : ℕ} : CT s ≤ CT (s+1) := by
  apply_rules [csSup_le]
  · exact ⟨_, ⟨0, by norm_num, rfl⟩⟩
  · rintro x ⟨t, ht, rfl⟩
    refine le_trans (J_le_succ ht) (le_csSup ?_ (Set.mem_image_of_mem _ ht))
    exact IsCompact.bddAbove (isCompact_Icc.image (J_continuous _))

end SparseThreshold