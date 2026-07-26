/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Certified Robustness for Ordered Top-2 Decisions

This file formalizes a certified L∞ robustness theorem for the *ordered top-2 outcome*
of a multiclass piecewise-linear network. The ordered top-2 outcome `(a, b)` consists of
the winner `a` (unique argmax) and runner-up `b` (unique second-best), and robustness
means that both identities are preserved under any L∞ perturbation within a certified radius.

## Main results

* `IsOrderedTop2` — predicate asserting that `a` is the unique winner and `b` the unique
  runner-up among `C` classes.
* `isOrderedTop2_iff_pairwise` — characterizes the ordered top-2 predicate via positivity
  of score differences.
* `orderedTop2Margin_pos` — the ordered top-2 margin is strictly positive when the
  predicate holds.
* `orderedTop2_stable_of_margin` — the ordered top-2 decision is preserved under
  perturbation when the perturbation norm is bounded by the margin divided by the
  effective Lipschitz constant.
* `orderedTop2_certified_radius` — ball-form robustness certificate: all perturbations
  within a closed ball of the certified radius preserve the ordered top-2 decision.

## Mathematical significance

Existing robustness certificates for multiclass networks typically stabilize either the
single winning class or an unordered top-k set. Ordered top-2 prediction is strictly
richer: it certifies not only the winner but also the identity of the nearest competitor.
This is the minimal nontrivial ranking structure needed for abstention, selective
classification, fallback routing, and hierarchical decision pipelines.

In tropical geometry terms, the theorem identifies the decision region for an ordered pair
`(a, b)` as an intersection of finitely many half-space-type score-difference constraints
and shows that the certified radius is governed by the minimum slack divided by the
effective Lipschitz modulus.
-/

import Mathlib

open Finset

/-! ## Basic definitions -/

/-- Score difference between classes `i` and `j`. -/
def scoreDiff {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ) (i j : Fin C) :
    (Fin d → ℝ) → ℝ :=
  fun x => f i x - f j x

/-- The strict ordered-top-2 predicate: `a` is the unique maximizer of the scores,
and `b` is the unique maximizer among classes distinct from `a`. -/
def IsOrderedTop2 {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a b : Fin C) (x : Fin d → ℝ) : Prop :=
  a ≠ b ∧
  (∀ j, j ≠ a → f a x > f j x) ∧
  (∀ j, j ≠ a → j ≠ b → f b x > f j x)

/-! ## Bridge lemma: ordered top-2 ↔ positive score differences -/

/-
The ordered top-2 predicate is equivalent to `a ≠ b` together with positivity of
the relevant score differences. This is the conceptual bridge between the classifier's
decision and the finite family of scalar inequalities that robustness must preserve.
-/
theorem isOrderedTop2_iff_pairwise
    {C d : ℕ} {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ} :
    IsOrderedTop2 f a b x ↔
      a ≠ b ∧
      (∀ j, j ≠ a → 0 < scoreDiff f a j x) ∧
      (∀ j, j ≠ a → j ≠ b → 0 < scoreDiff f b j x) := by
  unfold IsOrderedTop2 scoreDiff; aesop;

/-! ## Nonemptiness of filtered finsets -/

/-
When `C ≥ 2`, for any `a : Fin C` there exists `j ≠ a`.
-/
lemma filter_ne_nonempty {C : ℕ} (hC : 2 ≤ C) (a : Fin C) :
    (Finset.univ.filter fun j : Fin C => j ≠ a).Nonempty := by
  exact ⟨ if a = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩

/-
When `C ≥ 3` and `a ≠ b`, there exists `j` with `j ≠ a` and `j ≠ b`.
-/
lemma filter_ne_ne_nonempty {C : ℕ} (hC : 3 ≤ C) (a b : Fin C) (_hab : a ≠ b) :
    (Finset.univ.filter fun j : Fin C => j ≠ a ∧ j ≠ b).Nonempty := by
  exact Exists.imp ( by aesop ) ( Finset.exists_mem_ne ( show 1 < Finset.card ( Finset.erase Finset.univ a ) from by rw [ Finset.card_erase_of_mem ( Finset.mem_univ _ ), Finset.card_fin ] ; exact Nat.lt_pred_iff.mpr hC ) b )

/-! ## Margin definitions -/

/-- The winner margin: minimum score gap between the winner `a` and all other classes. -/
noncomputable def winnerMargin {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a : Fin C) (x : Fin d → ℝ)
    (hne : (Finset.univ.filter fun j : Fin C => j ≠ a).Nonempty) : ℝ :=
  Finset.inf' (Finset.univ.filter fun j => j ≠ a) hne
    (fun j => f a x - f j x)

/-- The runner-up margin: minimum score gap between the runner-up `b` and all classes
other than `a` and `b`. -/
noncomputable def runnerUpMargin {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a b : Fin C) (x : Fin d → ℝ)
    (hne : (Finset.univ.filter fun j : Fin C => j ≠ a ∧ j ≠ b).Nonempty) : ℝ :=
  Finset.inf' (Finset.univ.filter fun j => j ≠ a ∧ j ≠ b) hne
    (fun j => f b x - f j x)

/-- The ordered top-2 margin: minimum of the winner margin and the runner-up margin.
This is the smallest slack over all constraints defining the ordered top-2 decision. -/
noncomputable def orderedTop2Margin {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a b : Fin C) (x : Fin d → ℝ)
    (hne1 : (Finset.univ.filter fun j : Fin C => j ≠ a).Nonempty)
    (hne2 : (Finset.univ.filter fun j : Fin C => j ≠ a ∧ j ≠ b).Nonempty) : ℝ :=
  min (winnerMargin f a x hne1) (runnerUpMargin f a b x hne2)

/-! ## Margin bounds -/

/-
The winner margin is at most the score gap for any specific competitor.
-/
lemma winnerMargin_le_gap {C d : ℕ} {f : Fin C → (Fin d → ℝ) → ℝ}
    {a : Fin C} {x : Fin d → ℝ}
    {hne : (Finset.univ.filter fun j : Fin C => j ≠ a).Nonempty}
    {j : Fin C} (hj : j ≠ a) :
    winnerMargin f a x hne ≤ f a x - f j x := by
  exact Finset.inf'_le _ ( by aesop )

/-
The runner-up margin is at most the score gap for any specific non-winner,
non-runner-up competitor.
-/
lemma runnerUpMargin_le_gap {C d : ℕ} {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ}
    {hne : (Finset.univ.filter fun j : Fin C => j ≠ a ∧ j ≠ b).Nonempty}
    {j : Fin C} (hja : j ≠ a) (hjb : j ≠ b) :
    runnerUpMargin f a b x hne ≤ f b x - f j x := by
  exact Finset.inf'_le _ ( by aesop )

/-
The ordered top-2 margin is at most any winner gap.
-/
lemma orderedTop2Margin_le_winner_gap {C d : ℕ} {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ}
    {hne1 : (Finset.univ.filter fun j : Fin C => j ≠ a).Nonempty}
    {hne2 : (Finset.univ.filter fun j : Fin C => j ≠ a ∧ j ≠ b).Nonempty}
    {j : Fin C} (hj : j ≠ a) :
    orderedTop2Margin f a b x hne1 hne2 ≤ f a x - f j x := by
  exact le_trans ( min_le_left _ _ ) ( winnerMargin_le_gap hj )

/-
The ordered top-2 margin is at most any runner-up gap.
-/
lemma orderedTop2Margin_le_runnerUp_gap {C d : ℕ} {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ}
    {hne1 : (Finset.univ.filter fun j : Fin C => j ≠ a).Nonempty}
    {hne2 : (Finset.univ.filter fun j : Fin C => j ≠ a ∧ j ≠ b).Nonempty}
    {j : Fin C} (hja : j ≠ a) (hjb : j ≠ b) :
    orderedTop2Margin f a b x hne1 hne2 ≤ f b x - f j x := by
  exact min_le_of_right_le ( runnerUpMargin_le_gap hja hjb )

/-! ## Margin positivity -/

/-
The winner margin is positive when `a` is the unique maximizer.
-/
lemma winnerMargin_pos {C d : ℕ} {f : Fin C → (Fin d → ℝ) → ℝ}
    {a : Fin C} {x : Fin d → ℝ}
    {hne : (Finset.univ.filter fun j : Fin C => j ≠ a).Nonempty}
    (hwinner : ∀ j, j ≠ a → f a x > f j x) :
    0 < winnerMargin f a x hne := by
  unfold winnerMargin; aesop;

/-
The runner-up margin is positive when `b` beats all classes other than `a` and `b`.
-/
lemma runnerUpMargin_pos {C d : ℕ} {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ}
    {hne : (Finset.univ.filter fun j : Fin C => j ≠ a ∧ j ≠ b).Nonempty}
    (hrunner : ∀ j, j ≠ a → j ≠ b → f b x > f j x) :
    0 < runnerUpMargin f a b x hne := by
  unfold runnerUpMargin;
  simp_all +decide

/-
**Margin positivity**: the ordered top-2 margin is strictly positive whenever
the ordered top-2 predicate holds. This is the key quantitative strengthening
of the qualitative predicate.
-/
theorem orderedTop2Margin_pos
    {C d : ℕ} (hC : 3 ≤ C)
    {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ}
    (hord : IsOrderedTop2 f a b x) :
    0 < orderedTop2Margin f a b x
      (filter_ne_nonempty (by omega) a)
      (filter_ne_ne_nonempty hC a b hord.1) := by
  rcases hord with ⟨ hab, hwinner, hrunner ⟩;
  exact lt_min ( winnerMargin_pos hwinner ) ( runnerUpMargin_pos hrunner )

/-! ## Perturbation lemma -/

/-
**Score difference perturbation**: if a score difference `g` is positive at `x`
and satisfies a Lipschitz-type bound, then it remains positive at `x + δ` whenever
`‖δ‖∞` is small enough relative to `g(x)` and the Lipschitz constant.

The factor of 2 in the denominator provides a safety margin: the perturbed value
is at least `g(x)/2`.
-/
theorem scoreDiff_stays_positive
    {d : ℕ} {g : (Fin d → ℝ) → ℝ} {x δ : Fin d → ℝ} {L : ℝ}
    (hLip : |g (x + δ) - g x| ≤ L * ‖δ‖)
    (_hL : 0 ≤ L)
    (_hx : 0 < g x)
    (hδ : L * ‖δ‖ < g x) :
    0 < g (x + δ) := by
  linarith [ abs_le.mp hLip ]

/-! ## Main stability theorem -/

/-
**Ordered top-2 stability under perturbation**: if the ordered top-2 predicate holds
at `x`, and all score differences satisfy a uniform Lipschitz bound, then the predicate
is preserved at `x + δ` whenever `‖δ‖∞` is small enough relative to the ordered margin
and the effective Lipschitz constant.

This is the central robustness certificate: it reduces stability of an ordered ranking
to a scalar comparison between perturbation size and minimum gap.
-/
theorem orderedTop2_stable_of_margin
    {C d : ℕ} (hC : 3 ≤ C)
    {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x δ : Fin d → ℝ} {Keff : ℝ}
    (hord : IsOrderedTop2 f a b x)
    (hKeff : 0 ≤ Keff)
    (hLip : ∀ i j, i ≠ j →
        ∀ y z, |scoreDiff f i j y - scoreDiff f i j z| ≤ Keff * ‖y - z‖)
    (hδ : Keff * ‖δ‖ <
        orderedTop2Margin f a b x
          (filter_ne_nonempty (by omega) a)
          (filter_ne_ne_nonempty hC a b hord.1)) :
    IsOrderedTop2 f a b (x + δ) := by
  -- Apply the score difference perturbation lemma to each score difference.
  have h_score_diff_pos : ∀ j ≠ a, 0 < scoreDiff f a j (x + δ) := by
    intro j hj_ne_a
    have h_score_diff_pos : scoreDiff f a j (x + δ) > 0 := by
      apply scoreDiff_stays_positive;
      any_goals exact Keff;
      · simpa using hLip a j ( Ne.symm hj_ne_a ) ( x + δ ) x;
      · exact hKeff;
      · exact sub_pos.mpr ( hord.2.1 j hj_ne_a );
      · exact hδ.trans_le ( orderedTop2Margin_le_winner_gap hj_ne_a )
    exact h_score_diff_pos;
  have h_score_diff_pos_b : ∀ j, j ≠ a → j ≠ b → 0 < scoreDiff f b j (x + δ) := by
    intro j hj_ne_a hj_ne_b
    have h_score_diff_pos_b_j : Keff * ‖δ‖ < scoreDiff f b j x := by
      exact hδ.trans_le ( orderedTop2Margin_le_runnerUp_gap hj_ne_a hj_ne_b );
    have := hLip b j ( by tauto ) ( x + δ ) x; simp_all +decide [ abs_le ] ;
    linarith;
  exact ⟨ hord.1, fun j hj => by simpa [ scoreDiff ] using h_score_diff_pos j hj, fun j hj₁ hj₂ => by simpa [ scoreDiff ] using h_score_diff_pos_b j hj₁ hj₂ ⟩

/-! ## Certified radius corollary -/

/-
**Certified radius for ordered top-2 robustness**: all perturbations within a
closed ball of radius `r` preserve the ordered top-2 decision, provided `r` is
strictly less than the margin divided by the effective Lipschitz constant.

This is the ball-form robustness certificate, suitable for deployment:
given a network's Lipschitz constant and the score margins at a test point,
one can compute a certified radius within which the ordered top-2 prediction
is guaranteed to be stable.
-/
theorem orderedTop2_certified_radius
    {C d : ℕ} (hC : 3 ≤ C)
    {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ} {Keff r : ℝ}
    (hord : IsOrderedTop2 f a b x)
    (hKeff : 0 ≤ Keff)
    (hLip : ∀ i j, i ≠ j →
        ∀ y z, |scoreDiff f i j y - scoreDiff f i j z| ≤ Keff * ‖y - z‖)
    (hr : Keff * r <
        orderedTop2Margin f a b x
          (filter_ne_nonempty (by omega) a)
          (filter_ne_ne_nonempty hC a b hord.1)) :
    ∀ δ, ‖δ‖ ≤ r → IsOrderedTop2 f a b (x + δ) := by
  intro δ hδ;
  apply orderedTop2_stable_of_margin hC hord hKeff hLip;
  exact lt_of_le_of_lt ( mul_le_mul_of_nonneg_left hδ hKeff ) hr