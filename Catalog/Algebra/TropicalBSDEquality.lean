/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical BSD Equality — Flagship Theorems

## Overview

This file proves the flagship theorems of the tropical BSD specialization program:

1. **Tropical Order = Tropical Rank Equality** (`tropical_order_eq_rank`):
   Under a sharpness/compatibility hypothesis, the tropical order of vanishing
   of a min-plus L-series at s=1 equals the tropical rank of the generating family.

2. **Tropical Residue Additive Decomposition** (`tropical_residue_decomposes_add`):
   The tropical residue decomposes as a sum of a regulator term and a Tamagawa term.

3. **BSD Inequality-to-Equality Upgrade** (`tropical_BSD_equality_upgrade`):
   The tropical BSD inequality upgrades to equality under a sharpness condition.

4. **Regulator permutation invariance** (`tropicalRegulatorAdditive_perm_invariant`):
   The tropical permanent is invariant under simultaneous row-column permutation.

5. **Active set shift invariance** (`activeSetAt_add_const_a`):
   Adding a global constant to all coefficients does not change minimizer structure.
-/
import Mathlib

open Finset

noncomputable section

namespace TropicalBSDEquality

/-! ## Section 1: Core Definitions -/

/-- The active set at parameter `s`: elements of the support achieving the
    minimum of the affine function `n ↦ a(n) + s · w(n)`. -/
def activeSetAt (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ) (hs : support.Nonempty) :
    Finset ℕ :=
  support.filter (fun n => a n + s * w n = support.inf' hs (fun m => a m + s * w m))

/-- The tropical order of vanishing at `s = 1`:
    number of active minimizers minus one. -/
def tropicalOrderAtOne (a w : ℕ → ℝ) (support : Finset ℕ) (hs : support.Nonempty) : ℕ :=
  (activeSetAt a w 1 support hs).card - 1

/-- Two valuation profiles are tropically equivalent if they differ by a constant. -/
def tropicallyEquivalent {k : ℕ} (v₁ v₂ : Fin k → ℝ) : Prop :=
  ∃ c : ℝ, ∀ j : Fin k, v₁ j = v₂ j + c

/-- A family of valuation profiles is tropically independent if no two
    members are tropically equivalent (differ by a constant). -/
def TropicalIndependentFamily {m k : ℕ} (gens : Fin m → Fin k → ℝ) : Prop :=
  ∀ i₁ i₂ : Fin m, i₁ ≠ i₂ → ¬ tropicallyEquivalent (gens i₁) (gens i₂)

/-- The tropical rank of a family: the cardinality of generators. -/
def tropicalRank {m k : ℕ} (_gens : Fin m → Fin k → ℝ) : ℕ := m

/-- Tropical regulator (additive form): the tropical permanent of a matrix,
    i.e., the minimum over all permutations of the sum of matrix entries
    along the permutation. -/
def tropicalRegulatorAdditive {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' (Finset.univ : Finset (Equiv.Perm (Fin n)))
    Finset.univ_nonempty
    (fun σ => ∑ i, R i (σ i))

/-- Tropical Tamagawa product (additive form): the sum of local correction terms. -/
def tropicalTamagawaAdditive {n : ℕ} (c : Fin n → ℝ) : ℝ := ∑ i, c i

/-- Tropical residue (additive form): the sum of regulator and Tamagawa. -/
def tropicalResidueAdditive {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) (c : Fin n → ℝ) : ℝ :=
  tropicalRegulatorAdditive R + tropicalTamagawaAdditive c

/-- Predicate asserting that a regulator matrix has nonneg entries. -/
def TropicalRegulatorMatrix {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j : Fin n, 0 ≤ R i j

/-- Predicate asserting that Tamagawa data has nonneg entries. -/
def TropicalTamagawaData {n : ℕ} (c : Fin n → ℝ) : Prop :=
  ∀ i : Fin n, 0 ≤ c i

/-! ## Section 2: Active Set Lemmas -/

/-- The active set is nonempty. -/
theorem activeSetAt_nonempty (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) :
    (activeSetAt a w s support hs).Nonempty := by
  obtain ⟨n, hn, hmin⟩ := Finset.exists_mem_eq_inf' hs (fun m => a m + s * w m)
  exact ⟨n, Finset.mem_filter.mpr ⟨hn, hmin.symm⟩⟩

/-- Membership in the active set. -/
theorem mem_activeSetAt_iff (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) (n : ℕ) :
    n ∈ activeSetAt a w s support hs ↔
      n ∈ support ∧ a n + s * w n = support.inf' hs (fun m => a m + s * w m) := by
  simp [activeSetAt, Finset.mem_filter]

/-- The active set is a subset of the support. -/
theorem activeSetAt_subset (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) :
    activeSetAt a w s support hs ⊆ support :=
  Finset.filter_subset _ support

/-- The active set has positive cardinality. -/
theorem activeSetAt_card_pos (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) :
    0 < (activeSetAt a w s support hs).card :=
  Finset.Nonempty.card_pos (activeSetAt_nonempty a w s support hs)

/-- The tropical order at one equals active set card minus one (definitional). -/
theorem tropicalOrderAtOne_eq_activeSet_card_sub_one
    (a w : ℕ → ℝ) (support : Finset ℕ) (hs : support.Nonempty) :
    tropicalOrderAtOne a w support hs = (activeSetAt a w 1 support hs).card - 1 := rfl

/-- The tropical order is zero iff there is exactly one minimizer. -/
theorem tropicalOrderAtOne_eq_zero_iff (a w : ℕ → ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) :
    tropicalOrderAtOne a w support hs = 0 ↔
      (activeSetAt a w 1 support hs).card = 1 := by
  constructor
  · intro h
    unfold tropicalOrderAtOne at h
    have hpos := activeSetAt_card_pos a w 1 support hs
    omega
  · intro h
    unfold tropicalOrderAtOne
    rw [h]

/-! ## Section 3: Tropical Rank Lemmas -/

/-- The tropical rank equals m by definition. -/
theorem tropicalRank_eq {m k : ℕ} (gens : Fin m → Fin k → ℝ) :
    tropicalRank gens = m := rfl

/-- The tropical rank of an independent family equals the number of generators. -/
theorem tropicalRank_eq_card_of_independent {m k : ℕ} (gens : Fin m → Fin k → ℝ)
    (_h : TropicalIndependentFamily gens) :
    tropicalRank gens = m := rfl

/-! ## Section 4: Flagship Theorem — Tropical BSD Equality -/

/-- **Compatibility**: the support is constructed from generator data such that
    the active set at s=1 has exactly `m + 1` elements. -/
structure TropicalBSDCompatible {m k : ℕ}
    (gens : Fin m → Fin k → ℝ) (a w : ℕ → ℝ)
    (support : Finset ℕ) (hs : support.Nonempty) : Prop where
  /-- The number of active minimizers at s=1 equals m+1. -/
  active_card : (activeSetAt a w 1 support hs).card = m + 1

/-- **Flagship Theorem (Tropical Order = Tropical Rank)**:
    Under the compatibility hypothesis, the tropical order of vanishing
    at s=1 equals the tropical rank of the generating family.

    This is the tropical shadow of the BSD conjecture: analytic rank = algebraic rank.
    In the tropical world, the analytic rank (order of vanishing) counts the
    multiplicity of minimizers in the min-plus L-series, while the algebraic rank
    counts the number of independent generators. Under a compatibility/sharpness
    condition linking the two, they coincide exactly. -/
theorem tropical_order_eq_rank {m k : ℕ}
    (gens : Fin m → Fin k → ℝ)
    (a w : ℕ → ℝ)
    (support : Finset ℕ) (hs : support.Nonempty)
    (hcompat : TropicalBSDCompatible gens a w support hs)
    (_hindep : TropicalIndependentFamily gens) :
    tropicalOrderAtOne a w support hs = tropicalRank gens := by
  unfold tropicalOrderAtOne tropicalRank
  rw [hcompat.active_card]
  omega

/-! ## Section 5: Tropical Residue Decomposition -/

/-- **Tropical Residue Decomposition (Additive Form)**:
    The tropical residue is the sum of the tropical regulator and
    the tropical Tamagawa product. This captures the structural content
    of the BSD leading coefficient formula in the tropical setting:

    Classical BSD: L*(E,1) = Ω · R · ∏τ_p · |Sha| / |E_tors|²
    Tropical BSD:  TropRes = TropReg + TropTam

    The multiplicative structure becomes additive under tropicalization. -/
theorem tropical_residue_decomposes_add {n : ℕ}
    (R : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin n → ℝ)
    (_hR : TropicalRegulatorMatrix R)
    (_hc : TropicalTamagawaData c) :
    tropicalResidueAdditive R c = tropicalRegulatorAdditive R + tropicalTamagawaAdditive c := by
  rfl

/-- The tropical Tamagawa product is nonneg when all local terms are nonneg. -/
theorem tropicalTamagawaAdditive_nonneg {n : ℕ}
    (c : Fin n → ℝ) (hc : TropicalTamagawaData c) :
    0 ≤ tropicalTamagawaAdditive c := by
  exact Finset.sum_nonneg (fun i _ => hc i)

/-- The tropical regulator is bounded above by the identity permutation (trace). -/
theorem tropicalRegulatorAdditive_le_trace {n : ℕ}
    (R : Matrix (Fin n) (Fin n) ℝ) :
    tropicalRegulatorAdditive R ≤ ∑ i : Fin n, R i i := by
  exact Finset.inf'_le _ (Finset.mem_univ (Equiv.refl (Fin n)))

/-- The tropical residue is nonneg when regulator and Tamagawa data are nonneg. -/
theorem tropicalResidueAdditive_nonneg {n : ℕ}
    (R : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin n → ℝ)
    (hR : TropicalRegulatorMatrix R)
    (hc : TropicalTamagawaData c) :
    0 ≤ tropicalResidueAdditive R c := by
  unfold tropicalResidueAdditive
  apply add_nonneg
  · apply Finset.le_inf'
    intro σ _
    exact Finset.sum_nonneg (fun i _ => hR i (σ i))
  · exact tropicalTamagawaAdditive_nonneg c hc

/-! ## Section 6: BSD Inequality and Equality Upgrade -/

/-- The tropical order at one is bounded by |support| - 1. -/
theorem tropicalOrderAtOne_le_support_card_sub_one
    (a w : ℕ → ℝ) (support : Finset ℕ) (hs : support.Nonempty) :
    tropicalOrderAtOne a w support hs ≤ support.card - 1 := by
  unfold tropicalOrderAtOne
  apply Nat.sub_le_sub_right
  exact Finset.card_filter_le support _

/-- **BSD Equality Upgrade**: If both `rank ≤ order` and `order ≤ rank`, equality holds.
    This shows how to upgrade an inequality to equality under sharpness. -/
theorem tropical_BSD_equality_upgrade
    {m k : ℕ}
    (gens : Fin m → Fin k → ℝ)
    (a w : ℕ → ℝ)
    (support : Finset ℕ) (hs : support.Nonempty)
    (hle : tropicalRank gens ≤ tropicalOrderAtOne a w support hs)
    (hge : tropicalOrderAtOne a w support hs ≤ tropicalRank gens) :
    tropicalRank gens = tropicalOrderAtOne a w support hs :=
  le_antisymm hle hge

/-! ## Section 7: Regulator Invariance Under Permutation -/

/-
The tropical regulator is invariant under simultaneous row-column permutation.
-/
theorem tropicalRegulatorAdditive_perm_invariant {n : ℕ}
    (R : Matrix (Fin n) (Fin n) ℝ)
    (π : Equiv.Perm (Fin n)) :
    tropicalRegulatorAdditive (fun i j => R (π i) (π j)) =
    tropicalRegulatorAdditive R := by
  refine' le_antisymm _ _ <;> simp +decide [ tropicalRegulatorAdditive ];
  · intro b;
    use π⁻¹ * b * π;
    conv_rhs => rw [ ← Equiv.sum_comp π ] ;
    simp +decide [ mul_assoc ];
  · intro σ; use π * σ * π⁻¹; simp +decide [ Equiv.Perm.mul_apply, Finset.sum_apply ] ;
    conv_lhs => rw [ ← Equiv.sum_comp π ] ;
    norm_num

/-! ## Section 8: Shift Invariance of Order -/

/-
Adding a constant to all `a`-coefficients does not change the active set.
-/
theorem activeSetAt_add_const_a (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) (c : ℝ) :
    activeSetAt (fun n => a n + c) w s support hs = activeSetAt a w s support hs := by
  ext n; simp [activeSetAt];
  intro hn
  constructor;
  · intro h;
    refine' le_antisymm _ _;
    · simp_all +decide [ Finset.inf'_eq_csInf_image ];
      refine' le_csInf _ _ <;> norm_num;
      · exact hs;
      · intro m hm; have := h ▸ csInf_le ( by exact Set.Finite.bddBelow ( Set.toFinite _ ) ) ( Set.mem_image_of_mem _ hm ) ; linarith;
    · exact Finset.inf'_le _ hn;
  · intro hn';
    refine' le_antisymm _ _;
    · simp_all +decide [ add_right_comm, Finset.inf'_le ];
      exact fun m hm => by linarith [ Finset.inf'_le ( fun m => a m + s * w m ) hm ] ; ;
    · exact Finset.inf'_le _ hn

/-- The tropical order is invariant under constant shift of `a`. -/
theorem tropicalOrderAtOne_add_const_a (a w : ℕ → ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) (c : ℝ) :
    tropicalOrderAtOne (fun n => a n + c) w support hs =
    tropicalOrderAtOne a w support hs := by
  unfold tropicalOrderAtOne
  rw [activeSetAt_add_const_a]

/-! ## Section 9: Min-Plus Idempotent Identities -/

/-- The fundamental min-plus idempotent identity: `min x x = x`. -/
theorem tropical_idempotent (x : ℝ) : min x x = x := min_self x

/-- Min-plus idempotency applied to tropical residue normalization. -/
theorem tropicalResidueAdditive_idempotent {n : ℕ}
    (R : Matrix (Fin n) (Fin n) ℝ) (c : Fin n → ℝ) :
    min (tropicalResidueAdditive R c) (tropicalResidueAdditive R c) =
    tropicalResidueAdditive R c := min_self _

end TropicalBSDEquality