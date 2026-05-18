/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Satake Top-2 Margin Theorem for GL₃ Hecke Score Classifiers

This file formalizes a sharp robustness theorem for top-2 label sets determined by
score triples `x : Fin 3 → ℝ`. The key results are:

1. **Unique top-2 set characterization**: A unique top-2 set exists iff there is a unique
   "bottom" class strictly below the other two.

2. **Perturbation stability**: If the minimum gap from the excluded class to the top-2 set
   exceeds `2ε`, then any coordinatewise `ε`-perturbation preserves the top-2 set.

3. **Sharp converse**: If one member of the top-2 set has margin at most `2ε` over the
   excluded class, then there exists an `ε`-perturbation destroying the top-2 set.

4. **Max-plus transfer**: For max-plus linear score models (tropical Satake reconstructions),
   test-family perturbation of size `η` induces score perturbation of size at most `η`,
   giving a concrete robustness certificate.

## Mathematical context

For GL₃ tropical Satake classifiers, scores are computed as max-plus linear forms on
a finite test family. The top-2 label set identifies the two most plausible classes.
Robustness of this label set under perturbation of the test valuations is the key
certification property. The sharp threshold is governed by the gap between the second
and third ordered scores—equivalently, the minimum separation between the excluded
class and the top-2 pair.
-/

open Finset

namespace TropicalSatake

/-! ## Core definitions -/

/-- A set `A ⊆ Fin 3` is a top-2 set for score vector `x` if it has cardinality 2
and every member of `A` scores strictly above every non-member. -/
def IsTop2Set (x : Fin 3 → ℝ) (A : Finset (Fin 3)) : Prop :=
  A.card = 2 ∧ ∀ i ∈ A, ∀ j ∉ A, x j < x i

/-- Top-2 stability under score perturbation: there exists a top-2 set for `x` that
remains a top-2 set for every `y` within coordinatewise distance `ε`. -/
def Top2StableUnderScorePerturbation (x : Fin 3 → ℝ) (ε : ℝ) : Prop :=
  ∃ A : Finset (Fin 3), IsTop2Set x A ∧
    ∀ y : Fin 3 → ℝ, (∀ i, |y i - x i| ≤ ε) → IsTop2Set y A

/-! ## Finite enumeration helpers for Fin 3 -/

/-- Every element of `Fin 3` is 0, 1, or 2. -/
private lemma fin3_cases (i : Fin 3) : i = 0 ∨ i = 1 ∨ i = 2 := by
  fin_cases i <;> simp

/-
Any two-element subset of `Fin 3` has a unique complement element.
-/
lemma card_two_compl_singleton (A : Finset (Fin 3)) (hA : A.card = 2) :
    ∃! c : Fin 3, c ∉ A := by
  fin_cases A <;> simp_all +decide;
  · simp +decide [ ExistsUnique ];
  · simp +decide [ ExistsUnique ];
  · simp +decide [ ExistsUnique ]

/-! ## Section 1: Unique top-2 set characterization -/

/-
A unique top-2 set exists iff there is a unique bottom class strictly below
all others. This is the cleanest characterization for `Fin 3`.
-/
theorem unique_top2Set_iff_exists_unique_bottom (x : Fin 3 → ℝ) :
    (∃! A : Finset (Fin 3), IsTop2Set x A) ↔
    ∃! c : Fin 3, ∀ i : Fin 3, i ≠ c → x c < x i := by
  constructor;
  · rintro ⟨ A, hA₁, hA₂ ⟩;
    obtain ⟨ c, hc₁, hc₂ ⟩ := card_two_compl_singleton A hA₁.1;
    refine' ⟨ c, _, _ ⟩;
    · exact fun i hi => hA₁.2 i ( by specialize hc₂ i; aesop ) c hc₁;
    · intro y hy; specialize hA₂ ( Finset.univ.erase y ) ; simp_all +decide [ IsTop2Set ] ;
      grind;
  · rintro ⟨ c, hc₁, hc₂ ⟩;
    use Finset.univ.erase c;
    refine' ⟨ ⟨ _, _ ⟩, _ ⟩;
    · fin_cases c <;> trivial;
    · grind;
    · rintro A ⟨ hA₁, hA₂ ⟩;
      fin_cases A <;> simp +decide at hA₁ ⊢;
      · fin_cases c <;> simp +decide [ Fin.forall_fin_succ ] at *;
        · linarith;
        · linarith;
      · fin_cases c <;> simp +decide [ Fin.forall_fin_succ ] at *;
        · linarith;
        · linarith;
      · fin_cases c <;> simp +decide [ Fin.forall_fin_succ ] at *;
        · linarith;
        · linarith

/-
Equivalent formulation: a unique top-2 set exists iff there is a class `c`
with positive margin to all other classes.
-/
theorem unique_top2Set_iff_positive_pair_margin (x : Fin 3 → ℝ) :
    (∃! A : Finset (Fin 3), IsTop2Set x A) ↔
    ∃ c : Fin 3, (∀ i : Fin 3, i ≠ c → 0 < x i - x c) := by
  convert unique_top2Set_iff_exists_unique_bottom x using 1;
  constructor <;> intro h;
  · obtain ⟨ c, hc ⟩ := h;
    use c;
    grind;
  · exact ⟨ h.exists.choose, fun i hi => sub_pos.mpr ( h.exists.choose_spec i hi ) ⟩

/-! ## Section 2: Top-2 stability under coordinatewise perturbation -/

/-
Key inequality lemma: if `2ε < x a - x c` and both coordinates are perturbed
by at most `ε`, then `y c < y a`.
-/
lemma perturbed_order_preserved {xa xc ya yc ε : ℝ}
    (_hε : 0 ≤ ε)
    (hgap : 2 * ε < xa - xc)
    (ha : |ya - xa| ≤ ε)
    (hc : |yc - xc| ≤ ε) :
    yc < ya := by
  linarith [ abs_le.mp ha, abs_le.mp hc ]

/-
**Sharp sufficient condition for top-2 stability.**
If the minimum margin from the excluded class to each member of the top-2 set
exceeds `2ε`, then the top-2 set is stable under `ε`-perturbations.
-/
theorem top2_stable_of_pairwise_margin_gt_two_eps
    (x : Fin 3 → ℝ) (ε : ℝ) (hε : 0 ≤ ε) :
    (∃ c : Fin 3, ∀ i : Fin 3, i ≠ c → 2 * ε < x i - x c) →
    Top2StableUnderScorePerturbation x ε := by
  intro h
  obtain ⟨c, hc⟩ := h
  use Finset.univ.erase c;
  constructor;
  · constructor <;> simp +decide [ Finset.card_erase_of_mem, Finset.mem_erase, Finset.mem_univ ];
    exact fun i hi => by linarith [ hc i hi ] ;
  · intro y hy; constructor <;> simp_all +decide [ Finset.card_erase_of_mem ] ;
    exact fun i hi => by linarith [ abs_le.mp ( hy i ), abs_le.mp ( hy c ), hc i hi ] ;

/-
**Sharp converse: existence of a counterperturbation.**
If one member of a top-2 set has margin at most `2ε` over the excluded class,
there exists an `ε`-perturbation destroying the top-2 property.
-/
theorem exists_top2_counterperturbation
    (x : Fin 3 → ℝ) (A : Finset (Fin 3)) (ε : ℝ)
    (hA : IsTop2Set x A) (hε : 0 ≤ ε) :
    (∃ a ∈ A, ∃ c, c ∉ A ∧ x a - x c ≤ 2 * ε) →
    ∃ y : Fin 3 → ℝ,
      (∀ i, |y i - x i| ≤ ε) ∧
      ¬ IsTop2Set y A := by
  intro h
  obtain ⟨a, haA, c, hcA, hmargin⟩ := h
  use fun i => if i = a then x a - ε else if i = c then x c + ε else x i;
  grind +locals

/-! ## Section 3: Finite test-family score model and Lipschitz transfer -/

/-- A finite test-family score model: scores for 3 classes are computed from
test valuations `v : ℕ → ℝ`, with a Lipschitz bound `K` relating
test-valuation drift to score drift. -/
structure FiniteTestScoreModel where
  /-- The finite set of test indices -/
  T : Finset ℕ
  /-- Score function: given a class and test valuations, produces a score -/
  score : Fin 3 → (ℕ → ℝ) → ℝ
  /-- Lipschitz constant -/
  K : ℝ
  /-- Lipschitz constant is non-negative -/
  K_nonneg : 0 ≤ K
  /-- Lipschitz property: coordinatewise bounded test drift implies bounded score drift -/
  lipschitz : ∀ v w : ℕ → ℝ, ∀ η : ℝ, 0 ≤ η →
    (∀ t ∈ T, |v t - w t| ≤ η) →
    ∀ i : Fin 3, |score i v - score i w| ≤ K * η

/-- The score vector induced by a test valuation. -/
def modelScores (M : FiniteTestScoreModel) (v : ℕ → ℝ) : Fin 3 → ℝ :=
  fun i => M.score i v

/-
**Lipschitz transfer theorem**: if the score margin exceeds `2 * K * η`,
then the top-2 set is preserved under any `η`-perturbation of test valuations.
-/
theorem top2_stable_of_test_family_margin
    (M : FiniteTestScoreModel) (v w : ℕ → ℝ) (η : ℝ)
    (hη : 0 ≤ η)
    (hvw : ∀ t ∈ M.T, |v t - w t| ≤ η) :
    (∃ c : Fin 3, ∀ i : Fin 3, i ≠ c →
      2 * (M.K * η) < modelScores M v i - modelScores M v c) →
    ∃ A : Finset (Fin 3),
      IsTop2Set (modelScores M v) A ∧
      IsTop2Set (modelScores M w) A := by
  rintro ⟨ c, hc ⟩;
  refine' ⟨ Finset.univ.erase c, ⟨ _, _ ⟩, ⟨ _, _ ⟩ ⟩ <;> simp_all +decide;
  · exact fun i hi => by linarith [ hc i hi, show 0 ≤ M.K * η by exact mul_nonneg M.K_nonneg hη ] ;
  · intro i hi; have := M.lipschitz v w η hη hvw i; have := M.lipschitz v w η hη hvw c; simp_all +decide [ abs_le ] ;
    linarith! [ hc i hi ]

/-! ## Section 4: Max-plus linear score model -/

/-- Auxiliary: max-plus scores are well-defined when weight sets are nonempty. -/
lemma maxPlusScore_image_nonempty
    (W : Fin 3 → Finset (ℕ × ℝ)) (hne : ∀ i, (W i).Nonempty)
    (v : ℕ → ℝ) (i : Fin 3) :
    ((W i).image (fun p => v p.1 + p.2)).Nonempty :=
  Finset.Nonempty.image (hne i) _

/-- Max-plus score for class `i`: the maximum of `v t + w` over all `(t, w) ∈ W i`.
This is the tropical analogue of a linear score function.
Requires each weight set to be nonempty. -/
noncomputable def MaxPlusScore'
    (W : Fin 3 → Finset (ℕ × ℝ)) (hne : ∀ i, (W i).Nonempty)
    (v : ℕ → ℝ) : Fin 3 → ℝ :=
  fun i => ((W i).image (fun p => v p.1 + p.2)).max'
    (maxPlusScore_image_nonempty W hne v i)

/-
**Max-plus 1-Lipschitz property**: if every test valuation changes by at most `η`,
then every max-plus score changes by at most `η`.
-/
theorem maxplus_score_coordinate_lipschitz
    (T : Finset ℕ) (W : Fin 3 → Finset (ℕ × ℝ))
    (hW : ∀ i : Fin 3, ∀ p ∈ W i, p.1 ∈ T)
    (hne : ∀ i : Fin 3, (W i).Nonempty)
    (v w : ℕ → ℝ) (η : ℝ) (_hη : 0 ≤ η)
    (hvw : ∀ t ∈ T, |v t - w t| ≤ η) :
    ∀ i : Fin 3, |MaxPlusScore' W hne v i - MaxPlusScore' W hne w i| ≤ η := by
  unfold MaxPlusScore';
  norm_num [ abs_le ];
  intro i;
  constructor <;> intros y x x_1 hx hy <;> subst hy;
  · linarith [ abs_le.mp ( hvw x ( hW i _ hx ) ), Finset.le_max' ( image ( fun p => v p.1 + p.2 ) ( W i ) ) _ ( Finset.mem_image_of_mem _ hx ) ];
  · linarith [ abs_le.mp ( hvw x ( hW i _ hx ) ), Finset.le_max' ( image ( fun p => w p.1 + p.2 ) ( W i ) ) ( w x + x_1 ) ( Finset.mem_image_of_mem _ hx ) ]

/-
**Max-plus top-2 robustness corollary**: for max-plus score models with test-family
perturbation bounded by `η`, if the margin exceeds `2η` then the top-2 set is stable.
-/
theorem maxplus_top2_stable_of_margin_gt_two_eta
    (T : Finset ℕ) (W : Fin 3 → Finset (ℕ × ℝ))
    (hW : ∀ i : Fin 3, ∀ p ∈ W i, p.1 ∈ T)
    (hne : ∀ i : Fin 3, (W i).Nonempty)
    (v w : ℕ → ℝ) (η : ℝ) (hη : 0 ≤ η)
    (hvw : ∀ t ∈ T, |v t - w t| ≤ η) :
    (∃ c : Fin 3, ∀ i : Fin 3, i ≠ c →
      2 * η < MaxPlusScore' W hne v i - MaxPlusScore' W hne v c) →
    ∃ A : Finset (Fin 3),
      IsTop2Set (MaxPlusScore' W hne v) A ∧
      IsTop2Set (MaxPlusScore' W hne w) A := by
  rintro ⟨ c, hc ⟩;
  refine' ⟨ Finset.univ \ { c }, _, _ ⟩ <;> simp_all +decide [ IsTop2Set ];
  · exact ⟨ by fin_cases c <;> trivial, fun i hi => by linarith [ hc i hi ] ⟩;
  · -- By the Lipschitz property, we have |MaxPlusScore' W hne v i - MaxPlusScore' W hne w i| ≤ η for all i.
    have h_lip : ∀ i, |MaxPlusScore' W hne v i - MaxPlusScore' W hne w i| ≤ η := by
      apply maxplus_score_coordinate_lipschitz;
      exacts [ fun i p hp => hW i _ _ hp, hη, hvw ];
    exact ⟨ by fin_cases c <;> trivial, fun i hi => by linarith [ abs_le.mp ( h_lip i ), abs_le.mp ( h_lip c ), hc i hi ] ⟩

end TropicalSatake