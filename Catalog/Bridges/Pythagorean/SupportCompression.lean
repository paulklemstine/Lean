/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Sparse-Support Certificate Compression for Matroid Basis Polynomials

This file formalizes the structural principle that Lorentzian recognition
recursion trees collapse for matroid basis generating polynomials. The key
insight is that the surviving derivative branches in the recursive Lorentzian
recognition algorithm are governed not by ambient monomial counts, but by
the independent-set geometry of the underlying matroid.

## Main Definitions

* `NonzeroDerivativeLeafSet` — The set of k-element subsets contained in some
  member of a family of sets (derivative branches that survive)
* `supportCompressedLeafCount` — The cardinality of the nonzero derivative leaf set
* `activeVariableSet` — The union of all variables appearing in the support
* `activeVariableCount` — The size of the active variable set

## Main Results

* `nonzeroDerivativeLeafSet_eq_indep` — For matroid bases, surviving derivative
  leaves are exactly the independent sets of the given size
* `supportCompressedLeafCount_uniformBases` — Exact closed form: for uniform
  matroids, the quadratic leaf count equals C(n, r-2)
* `supportCompressedLeafCount_le_active_choose` — Upper bound by C(|active vars|, k)

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators Classical

noncomputable section

namespace SupportCompression

variable {n : ℕ}

/-! ## Core Definitions -/

/-- The set of k-element subsets of `Fin n` that are contained in some member
of a given family `bases`. In the context of Lorentzian recognition, these are
the derivative branches that produce nonzero results: a multiindex α of degree k
yields a nonzero derivative of a multiaffine polynomial iff supp(α) ⊆ some
support element, which for basis generating polynomials means supp(α) is
contained in some basis. -/
def NonzeroDerivativeLeafSet (bases : Finset (Finset (Fin n))) (k : ℕ) :
    Finset (Finset (Fin n)) :=
  ((univ : Finset (Fin n)).powersetCard k).filter fun I =>
    ∃ B ∈ bases, I ⊆ B

/-- The support-compressed leaf count: the number of k-element subsets that are
contained in some member of the family. This is the correct complexity measure
for recursive Lorentzian recognition. -/
def supportCompressedLeafCount (bases : Finset (Finset (Fin n))) (k : ℕ) : ℕ :=
  (NonzeroDerivativeLeafSet bases k).card

/-- The set of all variables (elements of `Fin n`) that appear in at least one
member of the family. -/
def activeVariableSet (bases : Finset (Finset (Fin n))) : Finset (Fin n) :=
  bases.biUnion id

/-- The number of active variables. -/
def activeVariableCount (bases : Finset (Finset (Fin n))) : ℕ :=
  (activeVariableSet bases).card

/-- The uniform basis family: all r-element subsets of `Fin n`. This corresponds
to the uniform matroid U_{r,n}. -/
def uniformBases (r : ℕ) : Finset (Finset (Fin n)) :=
  (univ : Finset (Fin n)).powersetCard r

/-- Verified algorithm: count nonzero quadratic leaves directly from support data.
This avoids symbolic differentiation entirely. -/
def countNonzeroQuadraticLeavesFromSupport
    (bases : Finset (Finset (Fin n))) (r : ℕ) : ℕ :=
  supportCompressedLeafCount bases (r - 2)

/-! ## Membership Characterization -/

/-- Simplified membership: an element belongs to `NonzeroDerivativeLeafSet` iff
it is a k-element subset of `Fin n` that is contained in some member of the family. -/
theorem mem_nonzeroDerivativeLeafSet_iff'
    {bases : Finset (Finset (Fin n))} {k : ℕ} {I : Finset (Fin n)} :
    I ∈ NonzeroDerivativeLeafSet bases k ↔
      I.card = k ∧ ∃ B ∈ bases, I ⊆ B := by
  simp [NonzeroDerivativeLeafSet, mem_filter, mem_powersetCard, subset_univ]

/-! ## Matroid Bridge: Independence = Containment in a Base -/

/-
For a matroid M on Fin n, the set of k-element subsets contained in some
base equals the set of k-element independent sets.

This connects the combinatorial leaf set to matroid independence. In Mathlib,
`M.Indep I ↔ ∃ B, M.IsBase B ∧ I ⊆ B` is the definition.
-/
theorem nonzeroDerivativeLeafSet_eq_indep
    (M : Matroid (Fin n))
    (_hE : M.E = Set.univ)
    (bases : Finset (Finset (Fin n)))
    (hbases : ∀ B : Finset (Fin n), B ∈ bases ↔ M.IsBase (↑B : Set (Fin n)))
    {k : ℕ} :
    NonzeroDerivativeLeafSet bases k =
      ((univ : Finset (Fin n)).powersetCard k).filter fun (I : Finset (Fin n)) =>
        M.Indep (↑I) := by
  ext I;
  constructor <;> intro hI <;> simp_all +decide [ NonzeroDerivativeLeafSet ];
  · obtain ⟨ B, hB₁, hB₂ ⟩ := hI.2; exact hB₁.indep.subset ( by aesop ) ;
  · obtain ⟨ B, hB ⟩ := hI.2.exists_isBase_superset;
    exact ⟨ Finset.univ.filter fun x => x ∈ B, by simpa [ Finset.coe_filter ] using hB.1, fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hB.2 hx ⟩ ⟩

/-! ## Uniform Matroid: Exact Closed Form -/

/-
Every (r-2)-element subset of Fin n is contained in some r-element subset,
provided r ≤ n and 2 ≤ r. This is the key combinatorial fact for the uniform
matroid closed form.
-/
theorem subset_exists_superset_of_card
    {r : ℕ} (hr : 2 ≤ r) (hrn : r ≤ n)
    {I : Finset (Fin n)} (hI : I.card = r - 2) :
    ∃ B ∈ uniformBases (n := n) r, I ⊆ B := by
  have := Finset.exists_subset_card_eq ( show 2 ≤ Finset.card ( Finset.univ \ I ) from ?_ );
  · obtain ⟨ t, ht₁, ht₂ ⟩ := this; use I ∪ t; simp_all +decide [ Finset.subset_iff, uniformBases ] ;
    rw [ Finset.card_union_of_disjoint ( Finset.disjoint_left.mpr fun x hx₁ hx₂ => ht₁ hx₂ hx₁ ), hI, ht₂ ] ; omega;
  · simp_all +decide [ Finset.card_sdiff ] ; omega;

/-
For the uniform matroid U_{r,n}, the nonzero derivative leaf set at degree
(r-2) is the entire set of (r-2)-element subsets.
-/
theorem nonzeroDerivativeLeafSet_uniformBases
    {r : ℕ} (hr : 2 ≤ r) (hrn : r ≤ n) :
    NonzeroDerivativeLeafSet (uniformBases (n := n) r) (r - 2) =
      (univ : Finset (Fin n)).powersetCard (r - 2) := by
  grind +suggestions

/-
**Theorem 3 (Uniform Matroid Closed Form).**
For the uniform matroid U_{r,n}, the number of nonzero quadratic derivative
leaves equals C(n, r-2).
-/
theorem supportCompressedLeafCount_uniformBases
    {r : ℕ} (hr : 2 ≤ r) (hrn : r ≤ n) :
    supportCompressedLeafCount (uniformBases (n := n) r) (r - 2) =
      n.choose (r - 2) := by
  convert congr_arg Finset.card ( nonzeroDerivativeLeafSet_uniformBases hr hrn ) using 1;
  simp +decide [ Finset.card_univ ]

/-! ## Upper Bound by Active Variable Count -/

/-
Any set in the nonzero derivative leaf set is contained in the active
variable set.
-/
theorem nonzeroDerivativeLeaf_subset_active
    {bases : Finset (Finset (Fin n))} {k : ℕ}
    {I : Finset (Fin n)} (hI : I ∈ NonzeroDerivativeLeafSet bases k) :
    I ⊆ activeVariableSet bases := by
  unfold NonzeroDerivativeLeafSet at hI;
  unfold activeVariableSet;
  grind

/-
The nonzero derivative leaf set is contained in the powerset of the active
variable set.
-/
theorem nonzeroDerivativeLeafSet_subset_active_powersetCard
    {bases : Finset (Finset (Fin n))} {k : ℕ} :
    NonzeroDerivativeLeafSet bases k ⊆
      (activeVariableSet bases).powersetCard k := by
  grind +suggestions

/-
**Theorem 4 (Support Compression Bound).**
For any family of sets, the number of k-element subsets contained in some member
is at most C(|active variables|, k).
-/
theorem supportCompressedLeafCount_le_active_choose
    {bases : Finset (Finset (Fin n))} {k : ℕ} :
    supportCompressedLeafCount bases k ≤
      (activeVariableCount bases).choose k := by
  convert Finset.card_le_card ( nonzeroDerivativeLeafSet_subset_active_powersetCard ) using 1;
  rw [ Finset.card_powersetCard, activeVariableCount ]

/-! ## Monotonicity Properties -/

/-
The nonzero derivative leaf set is monotone in the family of bases.
-/
theorem nonzeroDerivativeLeafSet_mono
    {bases₁ bases₂ : Finset (Finset (Fin n))} {k : ℕ}
    (h : bases₁ ⊆ bases₂) :
    NonzeroDerivativeLeafSet bases₁ k ⊆ NonzeroDerivativeLeafSet bases₂ k := by
  intro I hI;
  unfold NonzeroDerivativeLeafSet at *; aesop;

/-
The leaf count is monotone in the family of bases.
-/
theorem supportCompressedLeafCount_mono
    {bases₁ bases₂ : Finset (Finset (Fin n))} {k : ℕ}
    (h : bases₁ ⊆ bases₂) :
    supportCompressedLeafCount bases₁ k ≤ supportCompressedLeafCount bases₂ k := by
  exact Finset.card_le_card ( nonzeroDerivativeLeafSet_mono h )

/-! ## Verified Algorithm Correctness -/

/-- The verified counting algorithm is correct. -/
theorem countNonzeroQuadraticLeavesFromSupport_correct
    (bases : Finset (Finset (Fin n))) (r : ℕ) :
    countNonzeroQuadraticLeavesFromSupport bases r =
      supportCompressedLeafCount bases (r - 2) := by
  rfl

/-! ## Empty and Trivial Cases -/

/-
The leaf set of an empty family is empty.
-/
theorem nonzeroDerivativeLeafSet_empty (k : ℕ) :
    NonzeroDerivativeLeafSet (∅ : Finset (Finset (Fin n))) k = ∅ := by
  unfold NonzeroDerivativeLeafSet; aesop;

/-
The leaf count of an empty family is zero.
-/
theorem supportCompressedLeafCount_empty (k : ℕ) :
    supportCompressedLeafCount (∅ : Finset (Finset (Fin n))) k = 0 := by
  convert Finset.card_eq_zero.mpr ( nonzeroDerivativeLeafSet_empty k )

/-
For k = 0, the leaf set contains exactly the empty set (if the family
is nonempty).
-/
theorem nonzeroDerivativeLeafSet_zero
    {bases : Finset (Finset (Fin n))} (hne : bases.Nonempty) :
    NonzeroDerivativeLeafSet bases 0 = {∅} := by
  ext I; simp [NonzeroDerivativeLeafSet];
  exact fun h => ⟨ _, hne.choose_spec, h.symm ▸ Finset.empty_subset _ ⟩

/-
For k = 0 and nonempty family, the leaf count is 1.
-/
theorem supportCompressedLeafCount_zero
    {bases : Finset (Finset (Fin n))} (hne : bases.Nonempty) :
    supportCompressedLeafCount bases 0 = 1 := by
  rw [ show supportCompressedLeafCount bases 0 = ( NonzeroDerivativeLeafSet bases 0 ).card by rfl, nonzeroDerivativeLeafSet_zero hne, Finset.card_singleton ]

/-! ## Leaf Count Bounded by Ambient Count -/

/-
The support-compressed leaf count is always at most C(n, k),
the ambient worst-case count.
-/
theorem supportCompressedLeafCount_le_ambient
    {bases : Finset (Finset (Fin n))} {k : ℕ} :
    supportCompressedLeafCount bases k ≤ n.choose k := by
  exact le_trans ( Finset.card_le_card <| Finset.filter_subset _ _ ) ( by simp +decide [ Finset.card_univ, Finset.card_powersetCard ] )

end SupportCompression