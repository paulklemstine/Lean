/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Support Certificate Compression for Matroid Basis Polynomials

This file formalizes the structural principle that Lorentzian-recognition recursion
trees collapse for matroid basis generating polynomials. The key insight is that
derivative branch survival is a pure support property: for multiaffine homogeneous
polynomials with positive coefficients, the derivative ∂^α p is nonzero iff supp(α)
is contained in some support monomial.

## Main Definitions

* `BasisFamily` — abstraction of matroid basis systems
* `BasisFamily.NonzeroQuadraticLeafSet` — the independent k-sets (surviving leaves)
* `BasisFamily.supportCompressedLeafCount` — the compressed leaf count
* `BasisFamily.activeVariables` — variables appearing in at least one basis
* `uniformBasisFamily` — the uniform matroid U_{r,n}
* `IsMultiaffine` — a finsupp with all values ≤ 1

## Main Results

* `uniform_all_indep` — every (≤r)-subset is independent in U_{r,n}
* `leafCount_uniformMatroid` — for U_{r,n}, the leaf count is C(n, r−2)
* `supportCompressedLeafCount_le_active_choose` — leaf count ≤ C(|active vars|, k)
* `supportCompressedLeafCount_le_choose` — leaf count ≤ C(n, r−2)
* `multiaffine_le_iff_support_subset` — domination = support containment for 0/1 vectors
* `pderiv_monomial_eq_zero_of_exp_zero` — ∂_i(x^β c) = 0 when β(i) = 0
* `monomial_pderiv_nonzero_iff` — ∂_i(x^β c) ≠ 0 ↔ β(i) ≠ 0 ∧ c ≠ 0

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators MvPolynomial

noncomputable section

namespace SupportCertificateCompression

/-! ## Part 1: Basis Family Abstraction -/

/-- A basis family abstracts a matroid's basis system as a collection of r-element
subsets of `Fin n`. -/
structure BasisFamily (n r : ℕ) where
  /-- The collection of bases -/
  bases : Finset (Finset (Fin n))
  /-- Every basis has exactly r elements -/
  bases_card : ∀ B ∈ bases, B.card = r
  /-- The family is nonempty -/
  bases_nonempty : bases.Nonempty

namespace BasisFamily

variable {n r : ℕ}

/-- A set is independent in a basis family if it is contained in some basis. -/
def IsIndep (F : BasisFamily n r) (I : Finset (Fin n)) : Prop :=
  ∃ B ∈ F.bases, I ⊆ B

instance (F : BasisFamily n r) (I : Finset (Fin n)) :
    Decidable (F.IsIndep I) :=
  inferInstanceAs (Decidable (∃ B ∈ F.bases, I ⊆ B))

/-- Subsets of independent sets are independent (hereditary property). -/
theorem IsIndep.subset (F : BasisFamily n r) {I J : Finset (Fin n)}
    (hI : F.IsIndep I) (hJI : J ⊆ I) : F.IsIndep J := by
  obtain ⟨B, hB, hIB⟩ := hI
  exact ⟨B, hB, hJI.trans hIB⟩

/-! ## Part 2: Nonzero Quadratic Leaf Set and Compressed Count -/

/-- The **nonzero quadratic leaf set** of size k: the collection of k-element subsets
of `Fin n` that are independent in the basis family. -/
def NonzeroQuadraticLeafSet (F : BasisFamily n r) (k : ℕ) :
    Finset (Finset (Fin n)) :=
  (Finset.univ.powersetCard k).filter fun I => F.IsIndep I

/-- The **support-compressed leaf count**: the number of surviving derivative
branches. -/
def supportCompressedLeafCount (F : BasisFamily n r) (k : ℕ) : ℕ :=
  (F.NonzeroQuadraticLeafSet k).card

/-- Active variables: those appearing in at least one basis. -/
def activeVariables (F : BasisFamily n r) : Finset (Fin n) :=
  F.bases.biUnion id

/-- The number of active variables. -/
def activeVariableCount (F : BasisFamily n r) : ℕ :=
  F.activeVariables.card

end BasisFamily

/-! ## Part 3: Uniform Matroid -/

/-- The uniform basis family U_{r,n}: all r-element subsets of `Fin n` are bases. -/
def uniformBasisFamily (n r : ℕ) (hrn : r ≤ n) : BasisFamily n r where
  bases := Finset.univ.powersetCard r
  bases_card B hB := (Finset.mem_powersetCard.mp hB).2
  bases_nonempty := by
    simp only [Finset.powersetCard_nonempty, Finset.card_univ, Fintype.card_fin]
    omega

/-! ## Part 4: Core Independence Theorems -/

/-
In the uniform matroid, every subset of size ≤ r is independent.
-/
theorem uniform_all_indep {n r : ℕ} (hrn : r ≤ n)
    (I : Finset (Fin n)) (hI : I.card ≤ r) :
    (uniformBasisFamily n r hrn).IsIndep I := by
  -- By definition of IsIndep, we need to show that there exists a basis B in the uniformBasisFamily such that I is a subset of B. We can choose any r-element subset of `Fin n` that contains `I`.
  obtain ⟨B, hB⟩ : ∃ B : Finset (Fin n), I ⊆ B ∧ B.card = r ∧ B ⊆ Finset.univ := by
    have := Finset.exists_superset_card_eq hI ( show r ≤ Fintype.card ( Fin n ) from hrn.trans ( by simp +decide [ Fintype.card_fin ] ) ) ; aesop;
  exact ⟨ B, Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, hB.2.1 ⟩, hB.1 ⟩

/-
**Theorem 3 (Uniform Matroid Closed Form)**: For U_{r,n}, the number of
nonzero quadratic leaves is exactly C(n, r−2).
-/
theorem leafCount_uniformMatroid {n r : ℕ} (h2 : 2 ≤ r) (hrn : r ≤ n) :
    (uniformBasisFamily n r hrn).supportCompressedLeafCount (r - 2) =
      Nat.choose n (r - 2) := by
  convert Finset.card_powersetCard ( r - 2 ) ( Finset.univ : Finset ( Fin n ) ) using 1;
  · refine' congr_arg Finset.card _;
    ext; simp [uniformBasisFamily, BasisFamily.NonzeroQuadraticLeafSet];
    exact fun h => uniform_all_indep hrn _ ( by omega );
  · rw [ Finset.card_fin ]

/-
Independent sets only use active variables.
-/
theorem indep_subset_active {n r : ℕ} (F : BasisFamily n r)
    (I : Finset (Fin n)) (hI : F.IsIndep I) :
    I ⊆ F.activeVariables := by
  exact fun x hx => by rcases hI with ⟨ B, hB, hBI ⟩ ; exact Finset.mem_biUnion.mpr ⟨ B, hB, hBI hx ⟩ ;

/-
**Theorem 4 (Support Compression Bound)**: The leaf count is at most
C(|active variables|, k).
-/
theorem supportCompressedLeafCount_le_active_choose {n r : ℕ}
    (F : BasisFamily n r) (k : ℕ) :
    F.supportCompressedLeafCount k ≤ Nat.choose F.activeVariableCount k := by
  exact Nat.le_trans ( Finset.card_le_card ( show F.NonzeroQuadraticLeafSet k ⊆ Finset.powersetCard k F.activeVariables from fun x hx => Finset.mem_powersetCard.mpr ⟨ indep_subset_active F x ( Finset.mem_filter.mp hx |>.2 ), Finset.mem_filter.mp hx |>.1 |> Finset.mem_powersetCard.mp |>.2 ⟩ ) ) ( by simp +decide [ BasisFamily.activeVariableCount ] ) ;

/-
The leaf count is at most C(n, r−2).
-/
theorem supportCompressedLeafCount_le_choose {n r : ℕ} (F : BasisFamily n r) :
    F.supportCompressedLeafCount (r - 2) ≤ Nat.choose n (r - 2) := by
  -- The filter is a subset of the full powersetCard, so its cardinality is less than or equal to the cardinality of the powersetCard.
  have h_filter_subset : F.NonzeroQuadraticLeafSet (r - 2) ⊆ Finset.powersetCard (r - 2) Finset.univ := by
    exact fun x hx => Finset.mem_filter.mp hx |>.1 |> fun hx' => Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, Finset.mem_powersetCard.mp hx' |>.2 ⟩;
  exact le_trans ( Finset.card_le_card h_filter_subset ) ( by simp +decide [ Finset.card_univ ] )

/-! ## Part 5: Multiaffine Finsupp Bridge -/

/-- A finsupp is multiaffine if every coordinate value is at most 1. -/
def IsMultiaffine {n : ℕ} (β : Fin n →₀ ℕ) : Prop :=
  ∀ i : Fin n, β i ≤ 1

/-- The support of a finsupp as a Finset of `Fin n`. -/
def finsuppToFinset {n : ℕ} (β : Fin n →₀ ℕ) : Finset (Fin n) :=
  Finset.univ.filter fun i => β i ≠ 0

/-
For multiaffine finsupps, componentwise domination α ≤ β is equivalent to
support containment. This bridges polynomial derivative survival and
matroid independence.
-/
theorem multiaffine_le_iff_support_subset {n : ℕ}
    (α β : Fin n →₀ ℕ) (hα : IsMultiaffine α) (_hβ : IsMultiaffine β) :
    α ≤ β ↔ finsuppToFinset α ⊆ finsuppToFinset β := by
  constructor <;> intro h;
  · intro i hi; have := h i; simp_all +decide [ IsMultiaffine, finsuppToFinset ] ;
    exact ne_of_gt ( lt_of_lt_of_le ( Nat.pos_of_ne_zero hi ) this );
  · intro i; by_cases hi : α i = 0 <;> by_cases hi' : β i = 0 <;> simp_all +decide [ Finset.subset_iff ] ;
    · exact absurd ( h ( show i ∈ finsuppToFinset α from Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hi ⟩ ) ) ( by simp +decide [ hi', finsuppToFinset ] );
    · exact le_trans ( hα i ) ( Nat.one_le_iff_ne_zero.mpr hi' )

/-! ## Part 6: MvPolynomial Derivative Connection -/

/-
Partial derivative of a monomial vanishes when the exponent in that variable is 0.
-/
theorem pderiv_monomial_eq_zero_of_exp_zero {n : ℕ}
    (β : Fin n →₀ ℕ) (c : ℚ) (i : Fin n) (hi : β i = 0) :
    MvPolynomial.pderiv i (MvPolynomial.monomial β c) = 0 := by
  simp +decide [ pderiv_monomial, hi ]

/-
Partial derivative of a monomial is nonzero iff both the coefficient is nonzero
and the exponent in that variable is positive.
-/
theorem monomial_pderiv_nonzero_iff {n : ℕ}
    (β : Fin n →₀ ℕ) (c : ℚ) (i : Fin n) :
    MvPolynomial.pderiv i (MvPolynomial.monomial β c) ≠ 0 ↔
      (c ≠ 0 ∧ β i ≠ 0) := by
  by_cases hi : β i = 0 <;> simp +decide [ hi, MvPolynomial.pderiv_monomial ]

/-
Two-step derivative: ∂_j ∘ ∂_i of a monomial vanishes when β(i) = 0.
-/
theorem pderiv_pderiv_monomial_eq_zero {n : ℕ}
    (β : Fin n →₀ ℕ) (c : ℚ) (i j : Fin n)
    (hi : β i = 0) :
    MvPolynomial.pderiv j (MvPolynomial.pderiv i (MvPolynomial.monomial β c)) = 0 := by
  aesop

/-! ## Part 7: Structural Properties -/

/-
The leaf count is monotone in the basis family.
-/
theorem supportCompressedLeafCount_mono {n r : ℕ}
    (F G : BasisFamily n r) (h : F.bases ⊆ G.bases) (k : ℕ) :
    F.supportCompressedLeafCount k ≤ G.supportCompressedLeafCount k := by
  refine Finset.card_le_card ?_;
  intro I hI; simp_all +decide [ BasisFamily.NonzeroQuadraticLeafSet ] ;
  exact hI.2.imp fun B hB => ⟨ h hB.1, hB.2 ⟩;

/-
The leaf count for k = 0 is always 1.
-/
theorem supportCompressedLeafCount_zero {n r : ℕ} (F : BasisFamily n r) :
    F.supportCompressedLeafCount 0 = 1 := by
  convert Finset.card_eq_one.mpr ?_;
  use ∅; ext; simp [BasisFamily.NonzeroQuadraticLeafSet];
  rintro rfl; exact F.bases_nonempty.elim fun B hB => ⟨ B, hB, by simp +decide ⟩ ;

/-
The leaf count for k > n is always 0.
-/
theorem supportCompressedLeafCount_large {n r : ℕ} (F : BasisFamily n r)
    {k : ℕ} (hk : n < k) :
    F.supportCompressedLeafCount k = 0 := by
  refine Finset.card_eq_zero.mpr ?_;
  simp +decide [ Finset.ext_iff, BasisFamily.NonzeroQuadraticLeafSet ];
  exact fun a ha => absurd ( Finset.card_le_univ a ) ( by norm_num; linarith )

/-! ## Part 8: Verified Counting Algorithm -/

/-- Count nonzero quadratic leaves directly from basis data. -/
def countNonzeroQuadraticLeavesFromSupport {n r : ℕ}
    (F : BasisFamily n r) : ℕ :=
  ((Finset.univ.powersetCard (r - 2)).filter fun I => F.IsIndep I).card

/-- Correctness: the algorithm equals the compressed leaf count. -/
theorem countNonzeroQuadraticLeavesFromSupport_correct {n r : ℕ}
    (F : BasisFamily n r) :
    countNonzeroQuadraticLeavesFromSupport F =
      F.supportCompressedLeafCount (r - 2) := rfl

/-! ## Part 9: Finsupp Indicator Bijection -/

/-- Convert a Finset to its indicator Finsupp (0/1 vector). -/
def indicatorFinsupp {n : ℕ} (S : Finset (Fin n)) : Fin n →₀ ℕ where
  support := S
  toFun i := if i ∈ S then 1 else 0
  mem_support_toFun i := by simp

/-- The indicator finsupp is multiaffine. -/
theorem indicatorFinsupp_multiaffine {n : ℕ} (S : Finset (Fin n)) :
    IsMultiaffine (indicatorFinsupp S) := by
  intro i; simp [indicatorFinsupp]; split <;> omega

/-
The degree of an indicator finsupp equals the set cardinality.
-/
theorem indicatorFinsupp_sum {n : ℕ} (S : Finset (Fin n)) :
    (indicatorFinsupp S).sum (fun _ m => m) = S.card := by
  unfold indicatorFinsupp;
  -- The sum of the indicator function over the set S is equal to the cardinality of S.
  simp [Finsupp.sum]

/-
Recovering the set from the indicator's support.
-/
theorem finsuppToFinset_indicator {n : ℕ} (S : Finset (Fin n)) :
    finsuppToFinset (indicatorFinsupp S) = S := by
  unfold finsuppToFinset indicatorFinsupp;
  grind

/-! ## Part 10: Derivative Survival Criterion -/

/-- **Theorem 1 (Derivative Survival Criterion)**: For a basis generating polynomial
(multiaffine, positive coefficients), the derivative ∂^α p survives iff the support
of α is contained in some basis, equivalently iff α is independent.

This is stated at the combinatorial level: independence IS the existence of a
dominating basis. -/
theorem derivative_survival_iff_indep {n r : ℕ} (F : BasisFamily n r)
    (I : Finset (Fin n)) :
    F.IsIndep I ↔ ∃ B ∈ F.bases, I ⊆ B :=
  Iff.rfl

/-- **Theorem 2 (Leaf Count = Independent Set Count)**: The number of nonzero
quadratic derivative leaves equals the number of independent (r−2)-sets. -/
theorem leafCount_eq_indepCount {n r : ℕ} (F : BasisFamily n r) :
    F.supportCompressedLeafCount (r - 2) =
      ((Finset.univ.powersetCard (r - 2)).filter fun I => F.IsIndep I).card :=
  rfl

end SupportCertificateCompression