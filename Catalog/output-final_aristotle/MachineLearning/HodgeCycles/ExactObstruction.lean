/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exact homological obstruction for piecewise-linear decision surfaces

This file formalizes the linear-algebraic core of cellular homology in one
degree.  For a finite three-term chain complex `C₂ → C₁ → C₀`, it proves that
the middle Betti number is exactly the number of middle cells left after the
ranks of the incoming and outgoing boundary maps are removed.  Consequently,
homology is nonzero exactly when their rank sum is strictly smaller than the
middle chain-group dimension, and it is maximal exactly when both boundary maps
vanish.

For a finite cellular model of a ReLU decision surface over `ℚ`, the basis of
`C₁` consists of rational combinations of its linear faces.  Thus quotient
surjectivity is the precise chain-level representability statement; the exact
rank criterion identifies when such represented classes can be nontrivial.
-/

import Mathlib

open Module

namespace NeuralHodge

section

variable {F : Type*} [Field F]
variable {C₂ C₁ C₀ : Type*}
  [AddCommGroup C₂] [Module F C₂]
  [AddCommGroup C₁] [Module F C₁]
  [AddCommGroup C₀] [Module F C₀]
  [FiniteDimensional F C₁]
variable (d₂ : C₂ →ₗ[F] C₁) (d₁ : C₁ →ₗ[F] C₀)

/-- Cycles in the middle degree. -/
abbrev Cycles : Submodule F C₁ := LinearMap.ker d₁

/-- Boundaries, regarded as a subspace of cycles. -/
abbrev Boundaries : Submodule F (Cycles d₁) :=
  (LinearMap.range d₂).comap (LinearMap.ker d₁).subtype

/-- Middle homology. -/
abbrev Homology : Type _ := Cycles d₁ ⧸ Boundaries d₂ d₁

omit [FiniteDimensional F C₁] in
/-- Every homology class has a representative which is a cycle, hence a linear
combination of the chosen cellular basis. -/
theorem cellular_cycle_representative :
    Function.Surjective (Submodule.Quotient.mk : Cycles d₁ → Homology d₂ d₁) := by
  exact Submodule.Quotient.mk_surjective _

omit [FiniteDimensional F C₁] in
/-
The boundary subspace has the same dimension as the range of the incoming
map when the chain-complex equation holds.
-/
theorem finrank_boundaries_eq_range (hd : d₁.comp d₂ = 0) :
    finrank F (Boundaries d₂ d₁) = finrank F (LinearMap.range d₂) := by
  fapply LinearEquiv.finrank_eq;
  refine' ( LinearEquiv.ofBijective _ ⟨ _, _ ⟩ );
  refine' { toFun := fun x => ⟨ x.val, _ ⟩, map_add' := _, map_smul' := _ };
  all_goals simp +decide [ Function.Injective, Function.Surjective ];
  · exact x.2;
  · exact fun x => LinearMap.congr_fun hd x

/-
The exact middle Betti-rank formula.
-/
theorem betti_rank_formula (hd : d₁.comp d₂ = 0) :
    finrank F (Homology d₂ d₁) + finrank F (LinearMap.range d₁) +
        finrank F (LinearMap.range d₂) = finrank F C₁ := by
  have h_homology : finrank F (Homology d₂ d₁) = finrank F (LinearMap.ker d₁) - finrank F (LinearMap.range d₂) := by
    have h_homology : finrank F (Homology d₂ d₁) = finrank F (LinearMap.ker d₁) - finrank F (Boundaries d₂ d₁) := by
      rw [ eq_comm, tsub_eq_of_eq_add ];
      rw [ ← Submodule.finrank_quotient_add_finrank ];
    rw [ h_homology, finrank_boundaries_eq_range d₂ d₁ hd ];
  have := LinearMap.finrank_range_add_finrank_ker d₁;
  linarith [ Nat.sub_add_cancel ( show finrank F ( LinearMap.range d₂ ) ≤ finrank F ( LinearMap.ker d₁ ) from finrank_boundaries_eq_range d₂ d₁ hd ▸ Submodule.finrank_le _ ) ]

/-
The two differential ranks cannot use more dimensions than there are
middle cells.
-/
theorem rank_sum_le_middle (hd : d₁.comp d₂ = 0) :
    finrank F (LinearMap.range d₁) + finrank F (LinearMap.range d₂) ≤
      finrank F C₁ := by
  convert betti_rank_formula d₂ d₁ hd |> fun h => h.le.trans' _;
  grind +qlia

/-
Homology is nonzero exactly when the incoming and outgoing ranks fail to
exhaust the middle chain group.
-/
theorem homology_nonzero_iff_rank_sum_lt (hd : d₁.comp d₂ = 0) :
    0 < finrank F (Homology d₂ d₁) ↔
      finrank F (LinearMap.range d₁) + finrank F (LinearMap.range d₂) <
        finrank F C₁ := by
  grind +suggestions

/-
Homology vanishes exactly when the two differential ranks exhaust all
middle cells.
-/
theorem homology_zero_iff_rank_sum_eq (hd : d₁.comp d₂ = 0) :
    finrank F (Homology d₂ d₁) = 0 ↔
      finrank F (LinearMap.range d₁) + finrank F (LinearMap.range d₂) =
        finrank F C₁ := by
  grind +suggestions

/-
Middle homology has its largest possible dimension exactly when both maps
adjacent to the middle chain group vanish.
-/
theorem maximal_homology_iff_differentials_zero (hd : d₁.comp d₂ = 0) :
    finrank F (Homology d₂ d₁) = finrank F C₁ ↔ d₁ = 0 ∧ d₂ = 0 := by
  constructor;
  · intro h;
    have h_rank_sum_eq : finrank F (LinearMap.range d₁) + finrank F (LinearMap.range d₂) = 0 := by
      linarith [ NeuralHodge.betti_rank_formula d₂ d₁ hd ];
    simp_all +decide [ LinearMap.range_eq_bot ];
  · intro h
    have hd₁ : d₁ = 0 := by
      exact h.1
    have hd₂ : d₂ = 0 := by
      exact h.2;
    have := betti_rank_formula d₂ d₁ hd; simp_all +decide ;
    rw [ ← this, hd₁, hd₂, LinearMap.range_zero, LinearMap.range_zero, finrank_bot, finrank_bot, add_zero, add_zero ]

end

end NeuralHodge
end 
