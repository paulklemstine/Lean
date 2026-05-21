/-
# Tropical Loss Landscape: Core Definitions and Theorems

This file formalizes **arithmetic universality classes in tropical degenerations
of neural loss landscapes**. The central insight is that a loss function expressed
as the maximum of finitely many affine forms has sublevel sets that are convex
polyhedra, and the combinatorial structure of which affine pieces are "active"
is controlled by valuation-theoretic data rather than analytic details.

## Main definitions

* `TropicalAffineFamily` — a finite family of affine forms `aᵢ · x + bᵢ`
* `affineEval` — evaluation of one affine form
* `tropMax` — the tropical (max-plus) loss: `maxᵢ (aᵢ · x + bᵢ)`
* `SublevelSet` — the sublevel set `{x | tropMax F x ≤ c}`
* `ActiveSet` — indices achieving the maximum at a point
* `ActiveSetComplex` — all realizable active sets (a combinatorial invariant)
* `TropicalPolynomialFamily` — a parametric polynomial family for tropicalization
* `tropicalize` — the map from polynomial families to tropical affine families
* `ValuationEquivalent` — two families have the same valuation profile
* `SameSignType` — arrangement-theoretic equivalence
* `ArithmeticUniversalityClass` — equivalence class under valuation equivalence

## Main results

* `mem_sublevel_iff_forall_le` — sublevel = intersection of halfspaces
* `sublevel_mono` — sublevel sets form a monotone filtration
* `tropMax_sublevel_convex` — sublevel sets are convex
* `activeSet_nonempty` — active sets are always nonempty
* `activeSet_iff_dominates` — characterization via pairwise dominance
* `tropMax_eq_of_valuationEquivalent` — valuation equivalence preserves tropMax
* `sublevelSet_eq_of_valuationEquivalent` — valuation equivalence preserves sublevel sets
* `activeSet_image_of_sameSignType` — sign type equivalence transports active sets
* `activeComplex_bij_of_sameSignType` — sign type equivalence gives active complex bijection
-/

import Mathlib

namespace TropicalLoss

/-! ## Tropical Affine Family -/

/-- A tropical affine family: a finite collection of affine forms `aᵢ · x + bᵢ`
over `ℚ` in `n` variables. -/
structure TropicalAffineFamily (n : ℕ) where
  ι : Type
  [instFintype : Fintype ι]
  [instDecEq : DecidableEq ι]
  [instNonempty : Nonempty ι]
  coeff : ι → Fin n → ℚ
  bias : ι → ℚ

attribute [instance] TropicalAffineFamily.instFintype
  TropicalAffineFamily.instDecEq TropicalAffineFamily.instNonempty

variable {n : ℕ}

/-- Evaluate the `i`-th affine form at point `x`. -/
def affineEval (F : TropicalAffineFamily n) (i : F.ι) (x : Fin n → ℚ) : ℚ :=
  (Finset.univ.sum fun j => F.coeff i j * x j) + F.bias i

/-- The tropical max loss: the maximum of all affine forms at a point. -/
noncomputable def tropMax (F : TropicalAffineFamily n) (x : Fin n → ℚ) : ℚ :=
  Finset.sup' Finset.univ ⟨Classical.arbitrary F.ι, Finset.mem_univ _⟩
    (fun i => affineEval F i x)

/-- The sublevel set at threshold `c`. -/
def SublevelSet (F : TropicalAffineFamily n) (c : ℚ) : Set (Fin n → ℚ) :=
  {x | tropMax F x ≤ c}

/-- The active set at a point: indices of affine forms achieving the maximum. -/
noncomputable def ActiveSet (F : TropicalAffineFamily n) (x : Fin n → ℚ) : Finset F.ι :=
  Finset.univ.filter (fun i => affineEval F i x = tropMax F x)

/-- The active set complex: collection of all realizable active sets. -/
def ActiveSetComplex (F : TropicalAffineFamily n) : Set (Finset F.ι) :=
  {S | ∃ x : Fin n → ℚ, ActiveSet F x = S}

/-- The active set complex restricted to a sublevel set. -/
def ActiveSetComplexSublevel (F : TropicalAffineFamily n) (c : ℚ) : Set (Finset F.ι) :=
  {S | ∃ x : Fin n → ℚ, x ∈ SublevelSet F c ∧ ActiveSet F x = S}

/-! ## Polynomial Families and Tropicalization -/

/-- A one-parameter polynomial family: `L_t(x) = ∑ᵢ cᵢ · t^{wᵢ} · x^{αᵢ}`. -/
structure TropicalPolynomialFamily (n : ℕ) where
  numTerms : ℕ
  numTerms_pos : 0 < numTerms
  getExp : Fin numTerms → Fin n → ℕ
  getCoeff : Fin numTerms → ℚ
  getWeight : Fin numTerms → ℤ

/-- Two polynomial families are valuation-equivalent if they have the same
exponent vectors, weights, and coefficient sign pattern. -/
def ValuationEquivalent (P Q : TropicalPolynomialFamily n) : Prop :=
  ∃ h : P.numTerms = Q.numTerms,
  (∀ i : Fin P.numTerms,
    P.getExp i = Q.getExp (i.cast h)) ∧
  (∀ i : Fin P.numTerms,
    P.getWeight i = Q.getWeight (i.cast h)) ∧
  (∀ i : Fin P.numTerms,
    P.getCoeff i > 0 ↔ Q.getCoeff (i.cast h) > 0)

/-- Tropicalization: sends each monomial `cᵢ · t^{wᵢ} · x^{αᵢ}` to
the affine form `⟨αᵢ, u⟩ + wᵢ`. -/
def tropicalize (P : TropicalPolynomialFamily n) : TropicalAffineFamily n where
  ι := Fin P.numTerms
  instFintype := Fin.fintype _
  instDecEq := instDecidableEqFin _
  instNonempty := ⟨⟨0, P.numTerms_pos⟩⟩
  coeff := fun i j => P.getExp i j
  bias := fun i => P.getWeight i

/-- An arithmetic universality class: an equivalence class of polynomial families
under valuation equivalence. -/
structure ArithmeticUniversalityClass (n : ℕ) where
  repr : TropicalPolynomialFamily n
  carrier : Set (TropicalPolynomialFamily n)
  mem_iff : ∀ P, P ∈ carrier ↔ ValuationEquivalent P repr

/-! ## Sign-Combinatorial Equivalence -/

/-- Two families have the same sign-combinatorial type if pairwise ordering
of affine forms agrees at every point. -/
def SameSignType (F G : TropicalAffineFamily n) (φ : F.ι ≃ G.ι) : Prop :=
  ∀ i j : F.ι, ∀ x : Fin n → ℚ,
    affineEval F i x ≤ affineEval F j x ↔
    affineEval G (φ i) x ≤ affineEval G (φ j) x

-- ============================================================================
-- PART II: SUBLEVEL SET THEORY
-- ============================================================================

/-! ## Sublevel Set Characterization -/

/-
**Sublevel-as-halfspace theorem**: A point belongs to the sublevel set
iff every individual affine form is at most `c`.
-/
theorem mem_sublevel_iff_forall_le
    (F : TropicalAffineFamily n) (c : ℚ) (x : Fin n → ℚ) :
    x ∈ SublevelSet F c ↔ ∀ i : F.ι, affineEval F i x ≤ c := by
  exact ⟨ fun hx i => le_trans ( Finset.le_sup' ( fun i => affineEval F i x ) ( Finset.mem_univ i ) ) hx, fun hx => Finset.sup'_le _ _ fun i _ => hx i ⟩

/-
**Monotonic filtration theorem**: Sublevel sets are monotone in the threshold.
-/
theorem sublevel_mono (F : TropicalAffineFamily n) {c d : ℚ} (hcd : c ≤ d) :
    SublevelSet F c ⊆ SublevelSet F d := by
  unfold SublevelSet; intro x hx; exact le_trans hx hcd;

/-
Each affine form is affine in `x`: the key linearity identity.
-/
theorem affineEval_convex_combination (F : TropicalAffineFamily n) (i : F.ι)
    (x y : Fin n → ℚ) (a b : ℚ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b = 1) :
    affineEval F i (fun j => a * x j + b * y j) =
    a * affineEval F i x + b * affineEval F i y := by
  unfold affineEval; simp +decide [ *, Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
  linear_combination -hab * F.bias i

/-
**Convexity theorem**: The sublevel set is convex.
This follows because it is an intersection of halfspaces.
-/
theorem tropMax_sublevel_convex (F : TropicalAffineFamily n) (c : ℚ) :
    Convex ℚ (SublevelSet F c) := by
  intro x hx y hy a b ha hb hab;
  convert mem_sublevel_iff_forall_le F c ( a • x + b • y ) |>.2 _;
  intro i;
  convert affineEval_convex_combination F i x y a b ha hb hab ▸ add_le_add ( mul_le_mul_of_nonneg_left ( mem_sublevel_iff_forall_le F c x |>.1 hx i ) ha ) ( mul_le_mul_of_nonneg_left ( mem_sublevel_iff_forall_le F c y |>.1 hy i ) hb ) using 1;
  rw [ ← add_mul, hab, one_mul ]

/-! ## Active Set Properties -/

/-
The active set is always nonempty.
-/
theorem activeSet_nonempty (F : TropicalAffineFamily n) (x : Fin n → ℚ) :
    (ActiveSet F x).Nonempty := by
  have h_exists_max : ∃ i : F.ι, ∀ j : F.ι, affineEval F j x ≤ affineEval F i x := by
    simpa using Finset.exists_max_image Finset.univ ( fun i => affineEval F i x ) ⟨ Classical.arbitrary F.ι, Finset.mem_univ _ ⟩;
  exact ⟨ h_exists_max.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_antisymm ( Finset.le_sup' ( f := fun i => affineEval F i x ) ( Finset.mem_univ h_exists_max.choose ) ) ( Finset.sup'_le _ _ fun i _ => h_exists_max.choose_spec i ) ⟩ ⟩

/-
Membership in the active set iff evaluation equals the max.
-/
theorem mem_activeSet_iff (F : TropicalAffineFamily n) (x : Fin n → ℚ) (i : F.ι) :
    i ∈ ActiveSet F x ↔ affineEval F i x = tropMax F x := by
  exact Finset.mem_filter.trans ( by aesop )

/-
**Active set characterization**: `i` is active iff it dominates all others.
-/
theorem activeSet_iff_dominates (F : TropicalAffineFamily n) (x : Fin n → ℚ) (i : F.ι) :
    i ∈ ActiveSet F x ↔ ∀ j : F.ι, affineEval F j x ≤ affineEval F i x := by
  constructor <;> intro h;
  · exact fun j => by rw [ mem_activeSet_iff ] at h; exact h.symm ▸ Finset.le_sup' ( fun i => affineEval F i x ) ( Finset.mem_univ j ) ;
  · exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_antisymm ( Finset.le_sup' ( fun i => affineEval F i x ) ( Finset.mem_univ i ) ) ( Finset.sup'_le _ _ fun j _ => h j ) ⟩

/-
Every affine evaluation is at most the tropical max.
-/
theorem affineEval_le_tropMax (F : TropicalAffineFamily n) (x : Fin n → ℚ) (i : F.ι) :
    affineEval F i x ≤ tropMax F x := by
  convert Finset.le_sup' ( fun j => affineEval F j x ) ( Finset.mem_univ i )

/-
The sublevel set is nonempty if the origin satisfies the threshold.
-/
theorem sublevel_nonempty_of_origin (F : TropicalAffineFamily n) (c : ℚ)
    (h : tropMax F 0 ≤ c) :
    (SublevelSet F c).Nonempty := by
  exact ⟨ 0, h ⟩

/-
The active set complex of a sublevel set grows monotonically.
-/
theorem activeSetComplex_mono (F : TropicalAffineFamily n) {c d : ℚ} (hcd : c ≤ d) :
    ActiveSetComplexSublevel F c ⊆ ActiveSetComplexSublevel F d := by
  exact fun S hS => by rcases hS with ⟨ x, hx₁, hx₂ ⟩ ; exact ⟨ x, sublevel_mono F hcd hx₁, hx₂ ⟩ ;

-- ============================================================================
-- PART III: VALUATION EQUIVALENCE AND UNIVERSALITY
-- ============================================================================

/-! ## Valuation Equivalence: Equivalence Relation -/

theorem ValuationEquivalent.refl (P : TropicalPolynomialFamily n) :
    ValuationEquivalent P P := by
  exact ⟨ rfl, fun i => rfl, fun i => rfl, fun i => Iff.rfl ⟩

theorem ValuationEquivalent.symm {P Q : TropicalPolynomialFamily n}
    (h : ValuationEquivalent P Q) :
    ValuationEquivalent Q P := by
  -- By definition of ValuationEquivalent, we need to show that there exists a length-preserving bijection h' such that for all i, the exponent, weight, and sign of the coefficients match.
  obtain ⟨h_len, h_exp, h_weight, h_sign⟩ := h;
  use h_len.symm;
  aesop;

theorem ValuationEquivalent.trans {P Q R : TropicalPolynomialFamily n}
    (hPQ : ValuationEquivalent P Q) (hQR : ValuationEquivalent Q R) :
    ValuationEquivalent P R := by
  rcases hPQ with ⟨hPQrefl, hPQexp, hPQweight, hPQpos⟩
  rcases hQR with ⟨hQRrefl, hQRexp, hQRweight, hQRpos⟩
  use hPQrefl.trans hQRrefl;
  grind +qlia

/-! ## Tropicalization Invariance -/

/-
Valuation-equivalent families produce the same tropicalization coefficients.
-/
theorem tropicalize_coeff_eq_of_valuationEquivalent
    {P Q : TropicalPolynomialFamily n}
    (h : ValuationEquivalent P Q)
    (i : Fin P.numTerms) (j : Fin n) :
    (tropicalize P).coeff i j =
    (tropicalize Q).coeff ⟨i.val, by obtain ⟨hlen, _⟩ := h; omega⟩ j := by
  obtain ⟨ hlen, hexps, hweights, hcoeffs ⟩ := h
  generalize_proofs at *;
  unfold tropicalize; aesop;

/-
Valuation-equivalent families produce the same tropicalization biases.
-/
theorem tropicalize_bias_eq_of_valuationEquivalent
    {P Q : TropicalPolynomialFamily n}
    (h : ValuationEquivalent P Q)
    (i : Fin P.numTerms) :
    (tropicalize P).bias i =
    (tropicalize Q).bias ⟨i.val, by obtain ⟨hlen, _⟩ := h; omega⟩ := by
  convert h.2.2.1 i using 1;
  unfold tropicalize; aesop;

/-
Valuation-equivalent families produce the same affine evaluations.
-/
theorem tropicalize_affineEval_eq
    {P Q : TropicalPolynomialFamily n}
    (h : ValuationEquivalent P Q) (i : Fin P.numTerms) (x : Fin n → ℚ) :
    affineEval (tropicalize P) i x =
    affineEval (tropicalize Q) ⟨i.val, by obtain ⟨hlen, _⟩ := h; omega⟩ x := by
  unfold affineEval;
  congr 1;
  · exact Finset.sum_congr rfl fun _ _ => congr_arg₂ _ ( tropicalize_coeff_eq_of_valuationEquivalent h _ _ ) rfl;
  · exact?

/-
**Core universality theorem**: Valuation-equivalent polynomial families
have identical tropical max functions after tropicalization.
-/
theorem tropMax_eq_of_valuationEquivalent
    {P Q : TropicalPolynomialFamily n}
    (h : ValuationEquivalent P Q) (x : Fin n → ℚ) :
    tropMax (tropicalize P) x = tropMax (tropicalize Q) x := by
  convert Finset.sup'_congr ( f := fun i => affineEval ( tropicalize P ) i x ) _ _ _ using 2;
  nontriviality;
  convert rfl;
  rotate_left;
  exact Finset.univ.image ( fun i : Fin Q.numTerms => ⟨ i.val, by obtain ⟨ hlen, _ ⟩ := h; omega ⟩ );
  exact fun i => affineEval ( tropicalize Q ) ⟨ i.val, by obtain ⟨ hlen, _ ⟩ := h; omega ⟩ x;
  all_goals norm_num [ Finset.ext_iff, tropMax ];
  exact fun i => ⟨ ⟨ i.val, by obtain ⟨ hlen, _ ⟩ := h; omega ⟩, rfl ⟩;
  · exact?;
  · grind

/-
**Sublevel set invariance**: Valuation-equivalent families have the same
sublevel sets after tropicalization.
-/
theorem sublevelSet_eq_of_valuationEquivalent
    {P Q : TropicalPolynomialFamily n}
    (h : ValuationEquivalent P Q) (c : ℚ) :
    SublevelSet (tropicalize P) c = SublevelSet (tropicalize Q) c := by
  simp +decide only [SublevelSet, tropMax_eq_of_valuationEquivalent h]

/-! ## Sign-Type Invariance -/

/-
Same sign type implies active sets are mapped by the equivalence.
-/
theorem activeSet_image_of_sameSignType
    {F G : TropicalAffineFamily n} {φ : F.ι ≃ G.ι}
    (h : SameSignType F G φ) (x : Fin n → ℚ) :
    (ActiveSet F x).map φ.toEmbedding = ActiveSet G x := by
  -- By definition of active set, we need to show that for any $i \in F.ι$, $i \in ActiveSet F x$ if and only if $\phi(i) \in ActiveSet G x$.
  ext i
  simp [ActiveSet];
  constructor <;> intro hi;
  · refine' le_antisymm _ _;
    · exact Finset.le_sup' ( fun i => affineEval G i x ) ( Finset.mem_univ i );
    · have h_le : ∀ j : G.ι, affineEval G j x ≤ affineEval G i x := by
        have h_le : ∀ j : F.ι, affineEval F j x ≤ affineEval F (φ.symm i) x := by
          exact fun j => hi ▸ affineEval_le_tropMax F x j;
        exact fun j => by simpa using h ( φ.symm j ) ( φ.symm i ) x |>.1 ( h_le _ ) ;
      exact Finset.sup'_le _ _ fun j _ => h_le j;
  · -- By definition of same sign type, we have that for all $j$, $affineEval F j x \leq affineEval F (φ.symm i) x$ if and only if $affineEval G (φ j) x \leq affineEval G i x$.
    have h_le : ∀ j : F.ι, affineEval F j x ≤ affineEval F (φ.symm i) x := by
      intro j
      have := h j (φ.symm i) x
      simp_all +decide [ SameSignType ];
      exact Finset.le_sup' ( fun i => affineEval G i x ) ( Finset.mem_univ _ );
    exact le_antisymm ( Finset.le_sup' ( fun i => affineEval F i x ) ( Finset.mem_univ _ ) ) ( Finset.sup'_le _ _ fun j hj => h_le j )

/-
Same sign type implies active complexes are in bijection.
-/
theorem activeComplex_bij_of_sameSignType
    {F G : TropicalAffineFamily n} {φ : F.ι ≃ G.ι}
    (h : SameSignType F G φ) :
    ∀ S : Finset F.ι,
      S ∈ ActiveSetComplex F ↔ S.map φ.toEmbedding ∈ ActiveSetComplex G := by
  intro S
  constructor
  intro hS
  obtain ⟨x, hx⟩ := hS
  use x
  have h_map : (ActiveSet F x).map φ.toEmbedding = ActiveSet G x := activeSet_image_of_sameSignType h x
  rw [hx] at h_map
  exact h_map.symm;
  rintro ⟨ x, hx ⟩;
  use x; simp_all +decide [ Finset.ext_iff ] ;
  have := activeSet_image_of_sameSignType h x; simp_all +decide [ Finset.ext_iff ] ;
  intro a; specialize this ( φ a ) ; aesop;

end TropicalLoss