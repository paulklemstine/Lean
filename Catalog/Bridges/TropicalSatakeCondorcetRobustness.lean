/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# GL₃ Tropical Satake Condorcet Robustness

This file formalizes a robust multiclass certification theorem for Condorcet-style
aggregation of pairwise tropical Satake score gaps. The central result is that
robustness of each pairwise gap lifts to robustness of the entire tournament winner
relation, provided one class has a strictly positive margin against every opponent.

## Main results

* `condorcet_winner_stable`: if class `c` beats every opponent by margin at least `m`
  and pairwise gaps shift by at most `δ < m`, then `c` remains a Condorcet winner.
* `unique_of_condorcet_winner`: a Condorcet winner is unique (by skew-symmetry of gaps).
* `condorcet_winner_of_pairwise_margin`: combines the above into a single theorem.
* `gl3_tropical_condorcet_certified`: specializes to the GL₃ tropical Satake setting
  with explicit perturbation bound `2 * K * d * ε`.
* `not_condorcetStable_of_small_margin`: sharpness — if one margin is at most `δ` and
  an adversary can flip that gap, the Condorcet winner is destroyed.

## Key definitions

* `PairwiseGap`: the score difference `s c x - s j x`.
* `CondorcetWinner`: class `c` beats every other class in pairwise comparison.
* `UniqueCondorcetWinner`: `c` is a Condorcet winner and no other class is.
-/

noncomputable section

open Finset

/-! ### Definitions -/

/-- The pairwise score gap between class `c` and class `j` at input `x`. -/
def PairwiseGap {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ) (c j : C) (x : ι → ℝ) : ℝ :=
  s c x - s j x

/-- Class `c` is a Condorcet winner if it has strictly positive gap against every opponent. -/
def CondorcetWinner {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ) (c : C) (x : ι → ℝ) : Prop :=
  ∀ j, j ≠ c → 0 < PairwiseGap s c j x

/-- Class `c` is the unique Condorcet winner. -/
def UniqueCondorcetWinner {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ) (c : C) (x : ι → ℝ) : Prop :=
  CondorcetWinner s c x ∧ ∀ j, CondorcetWinner s j x → j = c

/-! ### Supporting lemmas -/

/-- The pairwise gap of a class against itself is zero. -/
lemma pairwiseGap_self {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ) (c : C) (x : ι → ℝ) :
    PairwiseGap s c c x = 0 := by
  unfold PairwiseGap; ring

/-- Skew-symmetry: swapping the arguments negates the gap. -/
lemma pairwiseGap_swap {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ) (i j : C) (x : ι → ℝ) :
    PairwiseGap s j i x = -PairwiseGap s i j x := by
  unfold PairwiseGap; ring

/-
If the absolute perturbation of a gap is at most `δ`, the perturbed gap is at least
the original gap minus `δ`.
-/
lemma le_pairwiseGap_of_abs_sub_le {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ) (i j : C) (x x' : ι → ℝ) (δ : ℝ)
    (h : |PairwiseGap s i j x' - PairwiseGap s i j x| ≤ δ) :
    PairwiseGap s i j x - δ ≤ PairwiseGap s i j x' := by
  linarith [ abs_le.mp h ]

/-! ### Main theorems -/

/-
**Condorcet winner stability**: if `c` beats every opponent by margin ≥ `m` and pairwise
gaps shift by at most `δ < m`, then `c` remains a Condorcet winner at the perturbed input.
-/
theorem condorcet_winner_stable {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ)
    (c : C) (x x' : ι → ℝ) (m δ : ℝ)
    (hmargin : ∀ j, j ≠ c → m ≤ PairwiseGap s c j x)
    (_hm : 0 < m)
    (hgap_c : ∀ j, j ≠ c → |PairwiseGap s c j x' - PairwiseGap s c j x| ≤ δ)
    (hδ : δ < m) :
    CondorcetWinner s c x' := by
  exact fun j hj => by linarith [ hmargin j hj, le_pairwiseGap_of_abs_sub_le s c j x x' δ ( hgap_c j hj ) ] ;

/-
**Uniqueness of Condorcet winners**: if `c` is a Condorcet winner, then no other class
can also be a Condorcet winner. This follows from skew-symmetry of pairwise gaps.
-/
theorem unique_of_condorcet_winner {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ)
    (c : C) (x : ι → ℝ)
    (hc : CondorcetWinner s c x) :
    ∀ j, CondorcetWinner s j x → j = c := by
  intro j hj; by_contra h; exact absurd ( hj c ( by aesop ) ) ( by linarith [ hc j ( by aesop ), pairwiseGap_swap s c j x, PairwiseGap s j c x ] ) ;

/-
**Full Condorcet robustness**: combining stability with uniqueness gives a unique
Condorcet winner at the perturbed input.
-/
theorem condorcet_winner_of_pairwise_margin {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ)
    (c : C) (x x' : ι → ℝ) (m δ : ℝ)
    (hmargin : ∀ j, j ≠ c → m ≤ PairwiseGap s c j x)
    (hm : 0 < m)
    (hgap : ∀ i j, i ≠ j → |PairwiseGap s i j x' - PairwiseGap s i j x| ≤ δ)
    (hδ : δ < m) :
    UniqueCondorcetWinner s c x' := by
  refine' ⟨ _, fun j hj => _ ⟩;
  · exact condorcet_winner_stable s c x x' m δ hmargin hm ( fun j hj => hgap c j ( Ne.symm hj ) ) hδ;
  · apply unique_of_condorcet_winner;
    convert condorcet_winner_stable s c x x' m δ hmargin hm _ hδ;
    · exact fun j hj => hgap c j hj.symm;
    · exact hj

/-
**Robust certificate with explicit radius**: if the minimum margin exceeds `2r` and
all pairwise gaps are Lipschitz with constant ≤ 1, then `c` is the unique Condorcet
winner in an `r`-ball around `x`.
-/
theorem condorcet_robust_of_min_margin {C ι : Type*} [Fintype C] [DecidableEq C] [Fintype ι]
    (s : C → (ι → ℝ) → ℝ)
    (c : C) (x : ι → ℝ) (r : ℝ)
    (hmargin : ∀ j, j ≠ c → 2 * r < PairwiseGap s c j x)
    (hstab : ∀ x' : ι → ℝ, ‖x' - x‖ ≤ r →
      ∀ i j, i ≠ j →
        |PairwiseGap s i j x' - PairwiseGap s i j x| ≤ r) :
    ∀ x' : ι → ℝ, ‖x' - x‖ ≤ r → UniqueCondorcetWinner s c x' := by
  intro x' hx';
  refine' ⟨ _, unique_of_condorcet_winner s c x' _ ⟩;
  · intro j hj;
    linarith [ abs_le.mp ( hstab x' hx' c j ( Ne.symm hj ) ), hmargin j hj ];
  · intro j hj;
    linarith [ abs_le.mp ( hstab x' hx' c j ( Ne.symm hj ) ), hmargin j hj ]

/-
**GL₃ tropical Satake Condorcet certified robustness**: specialization to the GL₃
tropical Satake setting with explicit perturbation bound `2 * K * d * ε`. The parameters
`K`, `d`, and `ε` represent the Lipschitz constant, dimension, and perturbation radius
from the tropical Satake score-gap robustness theorem.
-/
theorem gl3_tropical_condorcet_certified
    {C ι : Type*} [Fintype C] [DecidableEq C] [Fintype ι]
    (s : C → (ι → ℝ) → ℝ)
    (c : C) (x : ι → ℝ)
    (K d ε : ℝ)
    (hmargin : ∀ j, j ≠ c → 2 * K * d * ε < PairwiseGap s c j x)
    (hstab : ∀ x' : ι → ℝ, ‖x' - x‖ ≤ ε →
      ∀ i j, i ≠ j →
        |PairwiseGap s i j x' - PairwiseGap s i j x| ≤ 2 * K * d * ε) :
    ∀ x' : ι → ℝ, ‖x' - x‖ ≤ ε → UniqueCondorcetWinner s c x' := by
  intro x' hx';
  have h_perturbed_gap : ∀ j, j ≠ c → 0 < PairwiseGap s c j x' := by
    exact fun j hj => by linarith [ abs_le.mp ( hstab x' hx' c j ( Ne.symm hj ) ), hmargin j hj ] ;
  exact ⟨ h_perturbed_gap, fun j hj => unique_of_condorcet_winner s c x' ( by tauto ) j hj ⟩

/-! ### Sharpness / Converse -/

/-
**Sharpness of margin threshold**: if some opponent `j` has margin at most `δ` from `c`
and the adversary achieves a nonpositive gap at `x'`, then `c` is not a Condorcet winner
at `x'`, hence not a unique Condorcet winner either.
-/
theorem not_condorcetStable_of_small_margin {C ι : Type*} [Fintype C] [DecidableEq C]
    (s : C → (ι → ℝ) → ℝ)
    (c j : C) (x x' : ι → ℝ) (δ : ℝ)
    (hcj : j ≠ c)
    (_hsmall : PairwiseGap s c j x ≤ δ)
    (hflip : PairwiseGap s c j x' ≤ 0)
    (_hgap : ∀ i k, i ≠ k →
      |PairwiseGap s i k x' - PairwiseGap s i k x| ≤ δ) :
    ¬UniqueCondorcetWinner s c x' := by
  unfold UniqueCondorcetWinner CondorcetWinner at *;
  grind

end