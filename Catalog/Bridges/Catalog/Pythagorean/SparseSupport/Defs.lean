/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Sparse-Support Certificate Compression — Core Definitions

This file defines the combinatorial framework for support-compressed
Lorentzian recognition of matroid basis generating polynomials.

## Key Insight

For a multiaffine homogeneous polynomial of degree `r`, a derivative of order `r - 2`
is nonzero if and only if the derivative multi-index is dominated by some support element.
In the multiaffine case, this means `α ⊆ β` for some `β ∈ s`.

For matroid basis polynomials, derivative survival is equivalent to independence,
and the quadratic leaf count equals the number of independent (r-2)-sets.

## Main Definitions

* `SurvivingDerivSet` — The (r-2)-subsets producing nonzero quadratic derivatives
* `supportCompressedLeafCount` — Count of surviving derivative leaves
* `activeVariables` — Variables appearing in the support
* `BasisFamily` — Abstract matroid via basis exchange axiom
* `BasisFamily.Indep` — Independent sets (subsets of bases)
* `uniformBasisFamily` — The uniform matroid U_{r,n}
-/

open Finset BigOperators

namespace SparseSupport

variable {n : ℕ}

/-! ## Surviving Derivative Sets -/

/-- The set of `k`-element subsets of `Fin n` that are contained in some
    member of the support family `s`. These correspond to derivative
    multi-indices that produce nonzero results for a multiaffine polynomial. -/
def SurvivingDerivSet (s : Finset (Finset (Fin n))) (k : ℕ) : Finset (Finset (Fin n)) :=
  (Finset.univ.powersetCard k).filter fun α => ∃ β ∈ s, α ⊆ β

/-- The number of surviving quadratic derivative leaves for a degree-`r` polynomial. -/
def supportCompressedLeafCount (s : Finset (Finset (Fin n))) (r : ℕ) : ℕ :=
  (SurvivingDerivSet s (r - 2)).card

/-! ## Active Variables -/

/-- The set of variables that appear in at least one support element. -/
def activeVariables (s : Finset (Finset (Fin n))) : Finset (Fin n) :=
  s.biUnion id

/-- The number of active variables (support width). -/
def activeVariableCount (s : Finset (Finset (Fin n))) : ℕ :=
  (activeVariables s).card

/-! ## Abstract Matroid via Basis Exchange -/

/-- A basis family on `Fin n`: a nonempty equicardinal family of subsets
    satisfying the symmetric basis exchange axiom.

    This is the standard finite matroid axiomatization via bases. -/
structure BasisFamily (n : ℕ) where
  /-- The collection of bases -/
  bases : Finset (Finset (Fin n))
  /-- The common rank -/
  rank : ℕ
  /-- The family is nonempty -/
  nonempty : bases.Nonempty
  /-- All bases have the same cardinality -/
  equicard : ∀ B ∈ bases, B.card = rank
  /-- Basis exchange axiom: for B₁, B₂ bases and e ∈ B₁ \ B₂,
      there exists f ∈ B₂ \ B₁ such that (B₁ \ {e}) ∪ {f} is a basis. -/
  exchange : ∀ B₁ ∈ bases, ∀ B₂ ∈ bases, ∀ e ∈ B₁ \ B₂,
    ∃ f ∈ B₂ \ B₁, (B₁.erase e ∪ {f}) ∈ bases

/-- A set `I` is independent in a basis family if it is a subset of some basis. -/
def BasisFamily.Indep (M : BasisFamily n) (I : Finset (Fin n)) : Prop :=
  ∃ B ∈ M.bases, I ⊆ B

/-- Independence is decidable for a basis family. -/
instance BasisFamily.decidableIndep (M : BasisFamily n) (I : Finset (Fin n)) :
    Decidable (M.Indep I) :=
  inferInstanceAs (Decidable (∃ B ∈ M.bases, I ⊆ B))

/-- The set of independent sets of a given size `k`. -/
def BasisFamily.indepSetsOfSize (M : BasisFamily n) (k : ℕ) : Finset (Finset (Fin n)) :=
  (Finset.univ.powersetCard k).filter fun I => M.Indep I

/-- Subsets of independent sets are independent. -/
theorem BasisFamily.Indep.subset {M : BasisFamily n} {I J : Finset (Fin n)}
    (hJ : M.Indep J) (hIJ : I ⊆ J) : M.Indep I := by
  obtain ⟨B, hB, hJB⟩ := hJ
  exact ⟨B, hB, hIJ.trans hJB⟩

/-- Every basis is independent. -/
theorem BasisFamily.basis_indep {M : BasisFamily n} {B : Finset (Fin n)}
    (hB : B ∈ M.bases) : M.Indep B :=
  ⟨B, hB, Subset.rfl⟩

/-- An independent set can be extended to a basis. -/
theorem BasisFamily.Indep.exists_basis_superset {M : BasisFamily n} {I : Finset (Fin n)}
    (hI : M.Indep I) : ∃ B ∈ M.bases, I ⊆ B := hI

/-! ## Uniform Basis Family -/

/-- The uniform basis family `U_{r,n}`: every `r`-element subset of `Fin n` is a basis.
    This is the uniform matroid. -/
noncomputable def uniformBasisFamily (r : ℕ) (hr : 0 < r) (hrn : r ≤ n) : BasisFamily n where
  bases := Finset.univ.powersetCard r
  rank := r
  nonempty := by
    rw [Finset.powersetCard_nonempty]
    simp; omega
  equicard := by
    intro B hB
    exact (Finset.mem_powersetCard.mp hB).2
  exchange := by
    intro B₁ hB₁ B₂ hB₂ e he
    have hB₁card := (Finset.mem_powersetCard.mp hB₁).2
    have hB₂card := (Finset.mem_powersetCard.mp hB₂).2
    have hne : (B₂ \ B₁).Nonempty := by
      rw [Finset.nonempty_iff_ne_empty]
      intro h
      have hsub : B₂ ⊆ B₁ := Finset.sdiff_eq_empty_iff_subset.mp h
      have hsdiff_card : (B₁ \ B₂).card + (B₁ ∩ B₂).card = B₁.card :=
        Finset.card_sdiff_add_card_inter B₁ B₂
      have hinter : (B₁ ∩ B₂).card = B₂.card := by
        rw [Finset.inter_eq_right.mpr hsub]
      have : 1 ≤ (B₁ \ B₂).card := Finset.one_le_card.mpr ⟨e, he⟩
      omega
    obtain ⟨f, hf⟩ := hne
    exact ⟨f, hf, Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, by
      have : e ∈ B₁ := (Finset.mem_sdiff.mp he).1
      have : f ∉ B₁ := (Finset.mem_sdiff.mp hf).2
      rw [Finset.card_union_of_disjoint (by simp [Finset.disjoint_singleton_right, Finset.mem_erase, *])]
      simp [Finset.card_erase_of_mem ‹e ∈ B₁›, Finset.card_singleton]
      omega⟩⟩

/-
In the uniform matroid, every subset of size ≤ r is independent.
-/
theorem uniformBasisFamily_indep_iff (r : ℕ) (hr : 0 < r) (hrn : r ≤ n)
    (I : Finset (Fin n)) :
    (uniformBasisFamily r hr hrn).Indep I ↔ I.card ≤ r := by
  constructor <;> intro hI;
  · obtain ⟨ B, hB₁, hB₂ ⟩ := hI;
    exact le_trans ( Finset.card_le_card hB₂ ) ( by simpa using ( uniformBasisFamily r hr hrn ).equicard B hB₁ ▸ le_rfl );
  · -- Since $|I| \leq r$, we can extend $I$ to a basis of size $r$.
    obtain ⟨J, hJ⟩ : ∃ J : Finset (Fin n), I ⊆ J ∧ J.card = r := by
      have h_card : ∃ J : Finset (Fin n), J.card = r - I.card ∧ Disjoint I J := by
        have h_card : ∃ J : Finset (Fin n), J ⊆ Finset.univ \ I ∧ J.card = r - I.card := by
          exact Finset.exists_subset_card_eq ( by simpa [ Finset.card_sdiff ] using by omega );
        exact ⟨ h_card.choose, h_card.choose_spec.2, Finset.disjoint_left.mpr fun x hx hx' => Finset.mem_sdiff.mp ( h_card.choose_spec.1 hx' ) |>.2 hx ⟩;
      obtain ⟨ J, hJ₁, hJ₂ ⟩ := h_card; use I ∪ J; simp_all +decide [ Finset.disjoint_iff_inter_eq_empty ] ;
    exact ⟨ J, Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, hJ.2 ⟩, hJ.1 ⟩

end SparseSupport