/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.SparseSupport.Defs

/-!
# Sparse-Support Certificate Compression — Main Theorems

This file proves the core theorems connecting support geometry to Lorentzian
recognition complexity for matroid basis polynomials.

## Main Results

### Theorem 1: Support criterion for derivative survival
`derivative_survives_iff_dominated` — For a multiaffine homogeneous polynomial,
the derivative `∂^α p` is nonzero iff `α` is contained in some support element.

### Theorem 2: Quadratic leaves = independent (r-2)-sets
`quadraticLeaves_eq_indepSets` — For a matroid basis generating polynomial,
the number of nonzero quadratic leaves equals the number of independent (r-2)-sets.

### Theorem 3: Uniform matroid closed form
`quadraticLeaves_uniformMatroid` — For the uniform matroid U_{r,n},
the quadratic leaf count is exactly `C(n, r-2)`.

### Theorem 4: Support compression bound
`supportCompressedLeafCount_le_active_choose` — The quadratic leaf count
is bounded by `C(ω, r-2)` where `ω` is the number of active variables.

## Mathematical Significance

These results establish that the recursion tree for Lorentzian recognition of matroid
basis polynomials is secretly the independent-set complex in disguise. This transforms
certificate complexity from symbolic differentiation into combinatorial counting.
-/

open Finset BigOperators

namespace SparseSupport

variable {n : ℕ}

/-! ## Theorem 1: Support Criterion for Derivative Survival

For a multiaffine polynomial with support `s` (all elements are subsets of `Fin n` of
the same size `r`), a derivative of order `r-2` indexed by a subset `α` (with `|α| = r-2`)
produces a nonzero quadratic form if and only if `α ⊆ β` for some `β ∈ s`.

This is the compression mechanism: derivative survival is a pure support property.
No coefficient arithmetic is needed — only subset containment.

We formalize this at the combinatorial level. The polynomial-level statement follows
from the monomial lemma: ∂^α x^β ≠ 0 iff α ≤ β (componentwise), which for 0/1
exponent vectors is exactly α ⊆ β.
-/

/-- **Theorem 1**: A (r-2)-subset α is in the surviving derivative set if and only if
    it is contained in some support element and has the right cardinality.

    This is the combinatorial core of the derivative survival criterion. For multiaffine
    polynomials, nonvanishing of ∂^α p is equivalent to the existence of some β ∈ supp(p)
    with α ⊆ β. -/
theorem derivative_survives_iff_dominated
    (s : Finset (Finset (Fin n))) (k : ℕ)
    (α : Finset (Fin n)) :
    α ∈ SurvivingDerivSet s k ↔
      α ∈ Finset.univ.powersetCard k ∧ ∃ β ∈ s, α ⊆ β := by
  simp [SurvivingDerivSet]

/-- Equivalent characterization: α survives iff it has the right cardinality
    and is dominated. -/
theorem derivative_survives_iff_card_and_dominated
    (s : Finset (Finset (Fin n))) (k : ℕ)
    (α : Finset (Fin n)) :
    α ∈ SurvivingDerivSet s k ↔
      α.card = k ∧ ∃ β ∈ s, α ⊆ β := by
  simp [SurvivingDerivSet, Finset.mem_powersetCard]

/-! ## Connecting Surviving Derivatives to Independence

The key insight: for a basis family (matroid), a subset α is contained in some
basis (i.e., is independent) if and only if α survives as a derivative index.
This is almost by definition, but the formalization makes it precise.
-/

/-
For a basis family M, the surviving derivative set with respect to the
    basis support equals the set of independent subsets of size k.
-/
theorem survivingDerivSet_eq_indepSets
    (M : BasisFamily n) (k : ℕ) :
    SurvivingDerivSet M.bases k = M.indepSetsOfSize k := by
  ext α; simp [SurvivingDerivSet, BasisFamily.indepSetsOfSize, BasisFamily.Indep]

/-! ## Theorem 2: Quadratic Leaf Count = Independent (r-2)-Sets

For a matroid with rank r, the number of nonzero quadratic derivative leaves
of its basis generating polynomial equals the number of independent sets of
size r-2.
-/

/-
**Theorem 2**: The support-compressed leaf count for a basis family's support
    equals the number of independent sets of size (rank - 2).

    This is the conceptual center of the theory: Lorentzian recognition complexity
    for matroid basis polynomials is controlled by independent-set geometry.
-/
theorem quadraticLeaves_eq_indepSets
    (M : BasisFamily n) :
    supportCompressedLeafCount M.bases M.rank = (M.indepSetsOfSize (M.rank - 2)).card := by
  convert congr_arg Finset.card ( survivingDerivSet_eq_indepSets M ( M.rank - 2 ) ) using 1

/-! ## Theorem 3: Uniform Matroid Closed Form

For the uniform matroid U_{r,n}, every subset of size ≤ r is independent,
so every (r-2)-subset survives, giving C(n, r-2).
-/

/-- In the uniform matroid, every k-element subset (with k ≤ r) is independent. -/
theorem uniform_all_small_subsets_indep
    (r : ℕ) (hr : 0 < r) (hrn : r ≤ n)
    (I : Finset (Fin n)) (hI : I.card ≤ r) :
    (uniformBasisFamily r hr hrn).Indep I :=
  (uniformBasisFamily_indep_iff r hr hrn I).mpr hI

/-
The independent k-sets of the uniform matroid are exactly all k-element
    subsets, provided k ≤ r.
-/
theorem uniform_indepSetsOfSize_eq
    (r : ℕ) (hr : 0 < r) (hrn : r ≤ n)
    (k : ℕ) (hk : k ≤ r) :
    (uniformBasisFamily r hr hrn).indepSetsOfSize k = Finset.univ.powersetCard k := by
  ext I; simp [Finset.mem_powersetCard];
  exact ⟨ fun h => Finset.mem_powersetCard.mp ( Finset.mem_filter.mp h |>.1 ) |>.2, fun h => Finset.mem_filter.mpr ⟨ Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, h ⟩, by exact uniformBasisFamily_indep_iff r hr hrn I |>.2 ( by linarith ) ⟩ ⟩

/-
**Theorem 3**: For the uniform matroid U_{r,n}, the quadratic leaf count
    is exactly C(n, r-2).

    This is the first exact solved case and the sanity-check for the general theory.
    It follows from the general independent-set theorem plus the fact that every
    subset of size ≤ r is independent in the uniform matroid.
-/
theorem quadraticLeaves_uniformMatroid
    (r : ℕ) (h2 : 2 ≤ r) (hrn : r ≤ n) :
    supportCompressedLeafCount (uniformBasisFamily r (by omega) hrn).bases
      (uniformBasisFamily r (by omega) hrn).rank = Nat.choose n (r - 2) := by
  have := @quadraticLeaves_eq_indepSets;
  convert this ( uniformBasisFamily r ( by linarith ) hrn ) using 1;
  rw [ uniform_indepSetsOfSize_eq ];
  · simp +decide [ uniformBasisFamily ];
  · exact Nat.sub_le_of_le_add <| by linarith!;

/-! ## Theorem 4: Support Compression Bound

The surviving derivative count is bounded by C(ω, r-2) where ω is the
number of active variables (size of the union of support elements).
-/

/-
Any surviving α must be a subset of the active variables.
-/
theorem surviving_subset_activeVars
    (s : Finset (Finset (Fin n))) (k : ℕ)
    (α : Finset (Fin n)) (hα : α ∈ SurvivingDerivSet s k) :
    α ⊆ activeVariables s := by
  exact fun x hx => by rcases ( derivative_survives_iff_dominated s k α ) |>.1 hα with ⟨ _, ⟨ β, hβ, hαβ ⟩ ⟩ ; exact Finset.mem_biUnion.2 ⟨ β, hβ, hαβ hx ⟩ ;

/-
**Theorem 4**: The support-compressed leaf count is bounded by
    C(activeVariableCount, r-2).

    This shows that if only ω ≪ n variables appear in the support,
    the certification cost is O(C(ω, r-2)), not O(C(n, r-2)).
-/
theorem supportCompressedLeafCount_le_active_choose
    (s : Finset (Finset (Fin n))) (r : ℕ) :
    supportCompressedLeafCount s r ≤
      Nat.choose (activeVariableCount s) (r - 2) := by
  -- By definition of `SurvivingDerivSet`, every element in `SurvivingDerivSet s (r - 2)` is a subset of `activeVariables s` with cardinality `r - 2`.
  have h_subset : SurvivingDerivSet s (r - 2) ⊆ Finset.powersetCard (r - 2) (activeVariables s) := by
    exact fun x hx => Finset.mem_powersetCard.mpr ⟨ surviving_subset_activeVars _ _ _ hx, derivative_survives_iff_card_and_dominated _ _ _ |>.1 hx |>.1 ⟩;
  exact le_trans ( Finset.card_le_card h_subset ) ( by simp +decide [ activeVariableCount ] )

/-! ## Verified Algorithm: Support-Compressed Leaf Counting -/

/-- Compute nonzero quadratic leaves directly from support data,
    without differentiating the polynomial. This is the algorithmic
    heart of support compression. -/
def countNonzeroQuadraticLeavesFromSupport
    (s : Finset (Finset (Fin n))) (r : ℕ) : ℕ :=
  ((Finset.univ.powersetCard (r - 2)).filter fun α => ∃ β ∈ s, α ⊆ β).card

/-- The algorithm is correct: it computes the same value as
    supportCompressedLeafCount. -/
theorem countNonzeroQuadraticLeavesFromSupport_correct
    (s : Finset (Finset (Fin n))) (r : ℕ) :
    countNonzeroQuadraticLeavesFromSupport s r = supportCompressedLeafCount s r := by
  rfl

/-- For a basis family, the algorithm computes the independent (r-2)-set count. -/
theorem countFromSupport_eq_indep
    (M : BasisFamily n) :
    countNonzeroQuadraticLeavesFromSupport M.bases M.rank =
      (M.indepSetsOfSize (M.rank - 2)).card := by
  rw [countNonzeroQuadraticLeavesFromSupport_correct]
  exact quadraticLeaves_eq_indepSets M

end SparseSupport