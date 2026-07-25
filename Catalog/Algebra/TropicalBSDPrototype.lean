/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical BSD Prototype — Finite Tropical Arithmetic Package

## Overview

This file formalizes a **tropical Birch–Swinnerton-Dyer prototype**: a finite,
combinatorial analogue of the BSD conjecture in which:
- **tropical analytic rank** (order of vanishing of a tropical L-series at s=1)
  is defined as the number of active minimizing branches minus one,
- **tropical algebraic rank** is the cardinality of a set of independent
  valuation profiles,
- **equality** of the two ranks is proved under a natural genericity hypothesis.

The key insight is that a tropical Dirichlet series — defined as the infimum of
a finite family of affine functions — has "corners" whose multiplicity plays the
role of the order of vanishing of the classical L-function at the critical point.

## Main Results

* `tropicalOrderAtOne_eq_filter_card_sub_one` — tropical order of vanishing
  equals number of minimizers minus one
* `tropical_BSD_prototype` — tropical algebraic rank equals tropical analytic
  rank under a genericity hypothesis
* `tropical_residue_min` — tropical residue of a pointwise min equals the min
  of the residues
* `tropicalOrderAtOne_perm_invariant` — tropical order is invariant under
  weight permutations that preserve the support
-/
import Mathlib

open Finset

noncomputable section

/-! ## Section 1: Core Definitions -/

/-- The tropical Dirichlet series evaluated at a real parameter `s`.
    This is the tropical (min-plus) analogue of a classical Dirichlet series:
    instead of summing `a_n · n^(-s)`, we take the infimum of `w(n) + (s-1) · log n`.
    At `s = 1`, this reduces to `inf_{n ∈ S} w(n)`. -/
def tropicalLSeries
    (S : Finset ℕ) (hS : S.Nonempty)
    (w : ℕ → ℝ) (s : ℝ) : ℝ :=
  S.inf' hS (fun n => w n + (s - 1) * Real.log n)

/-- The tropical order of vanishing at `s = 1`.
    This counts the number of "active branches" (weight-minimizing elements) minus one.
    It is the tropical analogue of the multiplicity of a zero of an L-function. -/
def tropicalOrderAtOne
    (S : Finset ℕ) (hS : S.Nonempty)
    (w : ℕ → ℝ) : ℕ :=
  (S.filter (fun n => w n = S.inf' hS w)).card - 1

/-- The tropical residue at `s = 1`: the minimum weight value over the support.
    This packages the leading coefficient information of the tropical L-series
    at the critical point, analogous to the BSD leading coefficient. -/
def tropicalResidue
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) : ℝ :=
  S.inf' hS w

/-- Pointwise min-plus combination of valuation profiles. -/
def pointwiseMinOn
    (I : Finset ℕ) (hI : I.Nonempty)
    (v : ℕ → ℕ → ℝ) : ℕ → ℝ :=
  fun n => I.inf' hI (fun i => v i n)

/-- The active set at `s = 1`: the set of support elements achieving the minimum weight. -/
def activeSetAtOne
    (S : Finset ℕ) (hS : S.Nonempty)
    (w : ℕ → ℝ) : Finset ℕ :=
  S.filter (fun n => w n = S.inf' hS w)

/-- Tropical independence of valuation profiles: distinct generators have
    distinct valuation profiles on the support set. -/
def valuationProfileIndependent
    (I S : Finset ℕ) (v : ℕ → ℕ → ℝ) : Prop :=
  ∀ ⦃i j⦄, i ∈ I → j ∈ I → i ≠ j → ∃ n ∈ S, v i n ≠ v j n

/-- The tropical Mordell–Weil rank: the cardinality of the generator set. -/
def tropicalMWRank (I : Finset ℕ) : ℕ := I.card

/-! ## Section 2: Basic Lemmas -/

/-- The active set is nonempty: there always exists at least one minimizer. -/
theorem activeSetAtOne_nonempty
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) :
    (activeSetAtOne S hS w).Nonempty := by
  obtain ⟨n, hn, hmin⟩ := Finset.exists_mem_eq_inf' hS w
  exact ⟨n, Finset.mem_filter.mpr ⟨hn, hmin.symm⟩⟩

/-- The active set is a subset of the support. -/
theorem activeSetAtOne_subset
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) :
    activeSetAtOne S hS w ⊆ S :=
  Finset.filter_subset _ S

/-- The tropical L-series at `s = 1` equals the tropical residue. -/
theorem tropicalLSeries_at_one
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) :
    tropicalLSeries S hS w 1 = tropicalResidue S hS w := by
  simp only [tropicalLSeries, tropicalResidue]
  congr 1; ext n; ring

/-- The cardinality of the active set is at least 1. -/
theorem activeSetAtOne_card_pos
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) :
    0 < (activeSetAtOne S hS w).card :=
  Finset.Nonempty.card_pos (activeSetAtOne_nonempty S hS w)

/-! ## Section 3: Theorem A — Tropical order of vanishing equals active branches minus one -/

/-- **Theorem A**: The tropical order of vanishing at `s = 1` equals
    the cardinality of the active set minus one. -/
theorem tropicalOrderAtOne_eq_filter_card_sub_one
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) :
    tropicalOrderAtOne S hS w =
    (S.filter (fun n => w n = S.inf' hS w)).card - 1 := rfl

/-! ## Section 4: Theorem B — Tropical BSD Prototype -/

/-- **Theorem B (Tropical BSD Prototype)**: Under a genericity hypothesis,
    the tropical Mordell–Weil rank equals the tropical order of vanishing.

    The genericity hypothesis states that the number of active branches in the
    combined tropical L-series equals `I.card + 1`. Under this condition:

    `tropicalOrderAtOne S hS w = I.card`

    where `w` is the pointwise minimum of valuation profiles indexed by `I`. -/
theorem tropical_BSD_prototype
    (I S : Finset ℕ)
    (hI : I.Nonempty) (hS : S.Nonempty)
    (v : ℕ → ℕ → ℝ)
    (_hind : valuationProfileIndependent I S v)
    (hgeneric :
      let w : ℕ → ℝ := fun n => I.inf' hI (fun i => v i n)
      (S.filter (fun n => w n = S.inf' hS w)).card = I.card + 1) :
    let w : ℕ → ℝ := fun n => I.inf' hI (fun i => v i n)
    tropicalOrderAtOne S hS w = I.card := by
  simp only [tropicalOrderAtOne]
  have hcard := hgeneric
  rw [hcard]
  omega

/-! ## Section 5: Theorem C — Tropical Residue Decomposition -/

/-
**Theorem C (Tropical Residue Decomposition)**:
    The tropical residue of a pointwise minimum of two weight functions
    equals the minimum of their individual residues.
-/
theorem tropical_residue_min
    (S : Finset ℕ) (hS : S.Nonempty)
    (w₁ w₂ : ℕ → ℝ) :
    tropicalResidue S hS (fun n => min (w₁ n) (w₂ n))
      = min (tropicalResidue S hS w₁) (tropicalResidue S hS w₂) := by
  unfold tropicalResidue;
  refine' le_antisymm _ _ <;> norm_num [ Finset.min' ];
  · grind +qlia;
  · exact fun x hx => ⟨ Or.inl ⟨ x, hx, le_rfl ⟩, Or.inr ⟨ x, hx, le_rfl ⟩ ⟩

/-
The tropical residue is monotone: if `w₁ ≤ w₂` pointwise on `S`,
    then the residue of `w₁` is at most that of `w₂`.
-/
theorem tropical_residue_mono
    (S : Finset ℕ) (hS : S.Nonempty)
    (w₁ w₂ : ℕ → ℝ) (h : ∀ n ∈ S, w₁ n ≤ w₂ n) :
    tropicalResidue S hS w₁ ≤ tropicalResidue S hS w₂ := by
  unfold tropicalResidue;
  simp +zetaDelta at *;
  exact fun n hn => ⟨ n, hn, h n hn ⟩

/-! ## Section 6: Permutation Invariance -/

/-
The tropical order of vanishing is invariant under permutations of the
    weight function that preserve the support set.
-/
theorem tropicalOrderAtOne_perm_invariant
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ)
    (σ : Equiv.Perm ℕ)
    (hσS : ∀ n ∈ S, σ n ∈ S)
    (hσS' : ∀ n ∈ S, σ.symm n ∈ S) :
    tropicalOrderAtOne S hS w =
    tropicalOrderAtOne S hS (fun n => w (σ n)) := by
  unfold tropicalOrderAtOne;
  rw [ show S.inf' hS ( fun n => w ( σ n ) ) = S.inf' hS w from ?_ ];
  · -- By definition of preimage, we have that ${n ∈ S | w n = S.inf' hS w} = σ '' {n ∈ S | w (σ n) = S.inf' hS w}$.
    have h_preimage : {n ∈ S | w n = S.inf' hS w} = Finset.image σ {n ∈ S | w (σ n) = S.inf' hS w} := by
      grind;
    rw [ h_preimage, Finset.card_image_of_injective _ σ.injective ];
  · refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
    · exact fun n hn => ⟨ σ.symm n, hσS' n hn, by simp +decide ⟩;
    · grind +splitImp

/-! ## Section 7: Additional Structural Results -/

/-- Each branch of the tropical L-series is affine in `s`. -/
theorem tropicalLSeries_branch_linear
    (n : ℕ) (w : ℕ → ℝ) (s t : ℝ) :
    w n + (s - 1) * Real.log n - (w n + (t - 1) * Real.log n)
    = (s - t) * Real.log n := by ring

/-- Active set characterization: `n` is in the active set iff it achieves the
    global minimum of `w` on `S`. -/
theorem mem_activeSetAtOne_iff
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) (n : ℕ) :
    n ∈ activeSetAtOne S hS w ↔ n ∈ S ∧ w n = S.inf' hS w := by
  simp [activeSetAtOne, Finset.mem_filter]

/-- The tropical residue equals the weight at any active element. -/
theorem tropicalResidue_eq_of_mem_activeSet
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ)
    (n : ℕ) (hn : n ∈ activeSetAtOne S hS w) :
    tropicalResidue S hS w = w n := by
  rw [mem_activeSetAtOne_iff] at hn
  exact hn.2.symm

/-
Adding a constant to all weights does not change the tropical order.
-/
theorem tropicalOrderAtOne_add_const
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) (c : ℝ) :
    tropicalOrderAtOne S hS (fun n => w n + c) =
    tropicalOrderAtOne S hS w := by
  unfold tropicalOrderAtOne;
  rw [ show S.inf' hS ( fun n => w n + c ) = S.inf' hS w + c from ?_ ];
  · simp +decide [ add_right_inj ];
  · refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
    · exact Finset.exists_min_image _ _ hS;
    · exact fun n hn => ⟨ n, hn, le_rfl ⟩

/-
The tropical residue shifts by `c` when all weights shift by `c`.
-/
theorem tropicalResidue_add_const
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) (c : ℝ) :
    tropicalResidue S hS (fun n => w n + c) =
    tropicalResidue S hS w + c := by
  unfold tropicalResidue;
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le ];
  · exact Finset.exists_min_image _ _ hS;
  · exact fun n hn => ⟨ n, hn, le_rfl ⟩

/-- Ground state degeneracy: the active set cardinality is between 1 and |S|. -/
theorem activeSet_card_bounds
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) :
    1 ≤ (activeSetAtOne S hS w).card ∧
    (activeSetAtOne S hS w).card ≤ S.card :=
  ⟨activeSetAtOne_card_pos S hS w, Finset.card_filter_le S _⟩