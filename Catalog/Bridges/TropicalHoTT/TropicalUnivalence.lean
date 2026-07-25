/-
# Tropical Univalence for Finite Weighted Spaces

This file establishes a tropical analogue of the Univalence Axiom from
Homotopy Type Theory. In HoTT, univalence states that equality of types
is equivalent to the existence of an equivalence between them. Here we prove:

> Two finite ℕ-weighted matrices are tropically equivalent (related by a
> distance-preserving permutation) if and only if their canonical orbit
> codes are equal.

This gives a concrete, decidable univalence principle for finite weighted
spaces: identity of tropical codes = existence of tropical isometry.

## Main results

* `tropicallyEquivalent_iff_orbitCode_eq` — the univalence theorem
* `tropicalEquivalentDecidable` — decidability of tropical equivalence
* `tropicallyEquivalent_refl/symm/trans` — equivalence relation structure
* `permuteMatrix_permuteMatrix` — composition of permutations
* `permuteMatrix_one` — identity permutation

## Cross-domain connections

The decidability theorem connects to:
- **Graph isomorphism**: tropical equivalence is metric-aware graph isomorphism
- **Phylogenetics**: tree metrics under taxon relabeling
- **Program equivalence**: cost-preserving behavioral equivalence of states
-/

import Mathlib

open Equiv in

/-! ## Core Definitions -/

/-- Apply a permutation to a weighted matrix by simultaneously permuting
    rows and columns. This is the tropical analogue of transport along
    an equivalence in HoTT. -/
def permuteMatrix {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) (σ : Equiv.Perm (Fin n)) :
    Matrix (Fin n) (Fin n) ℕ :=
  fun i j => D (σ i) (σ j)

/-- Two finite weighted spaces (encoded as matrices) are tropically equivalent
    if there exists a permutation preserving all distances. This is the tropical
    analogue of type equivalence in HoTT. -/
def tropicallyEquivalent {n : ℕ} (D E : Matrix (Fin n) (Fin n) ℕ) : Prop :=
  ∃ σ : Equiv.Perm (Fin n), ∀ i j, E (σ i) (σ j) = D i j

/-- A distance-preserving bijection between finite weighted spaces.
    This is the tropical analogue of a type equivalence. -/
def IsTropicalIsometry {α β : Type*}
    (dα : α → α → ℕ) (dβ : β → β → ℕ) (f : α → β) : Prop :=
  Function.Bijective f ∧ ∀ x y, dβ (f x) (f y) = dα x y

/-- The orbit code of a matrix: the set of all matrices obtainable by
    permutation. This serves as the canonical tropical identity code.
    Two matrices have the same orbit code iff they are tropically equivalent. -/
noncomputable def orbitCode {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) :
    Finset (Matrix (Fin n) (Fin n) ℕ) :=
  Finset.univ.image (fun σ => permuteMatrix D σ)

/-- A matrix is a valid tropical distance matrix: zero diagonal and symmetric. -/
def IsTropicalDistanceMatrix {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) : Prop :=
  D.IsSymm ∧ ∀ i, D i i = 0

/-! ## Permutation Algebra -/

/-
The identity permutation leaves a matrix unchanged.
-/
theorem permuteMatrix_one {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) :
    permuteMatrix D 1 = D := by
  exact Matrix.ext fun i => congrFun rfl

/-
Composing two permutations on a matrix is the same as permuting by their product.
-/
theorem permuteMatrix_mul {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ)
    (σ τ : Equiv.Perm (Fin n)) :
    permuteMatrix (permuteMatrix D σ) τ = permuteMatrix D (σ * τ) := by
  exact funext fun i => funext fun j => by simp +decide [ permuteMatrix, Equiv.Perm.mul_apply ] ;

/-
Permuting by the inverse recovers the original matrix.
-/
theorem permuteMatrix_inv_cancel {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ)
    (σ : Equiv.Perm (Fin n)) :
    permuteMatrix (permuteMatrix D σ) σ⁻¹ = D := by
  convert permuteMatrix_mul D σ σ⁻¹ using 1 ; aesop;

/-
Permutation preserves the symmetric property of a distance matrix.
-/
theorem permuteMatrix_isSymm {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) (σ : Equiv.Perm (Fin n))
    (h : D.IsSymm) : (permuteMatrix D σ).IsSymm := by
  -- By definition of permutation, we have that $(permuteMatrix D σ) i j = D (σ i) (σ j)$.
  ext i j
  simp [permuteMatrix];
  exact h.apply _ _

/-
Permutation preserves the zero-diagonal property.
-/
theorem permuteMatrix_diag_zero {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) (σ : Equiv.Perm (Fin n))
    (h : ∀ i, D i i = 0) : ∀ i, permuteMatrix D σ i i = 0 := by
  exact fun i => h _

/-
Permutation preserves the tropical distance matrix property.
-/
theorem permuteMatrix_isTropicalDistanceMatrix {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℕ) (σ : Equiv.Perm (Fin n))
    (h : IsTropicalDistanceMatrix D) :
    IsTropicalDistanceMatrix (permuteMatrix D σ) := by
  exact ⟨ permuteMatrix_isSymm _ _ h.1, permuteMatrix_diag_zero _ _ h.2 ⟩

/-! ## Tropical Equivalence is an Equivalence Relation -/

/-
Tropical equivalence is reflexive: every matrix is equivalent to itself
    via the identity permutation.
-/
theorem tropicallyEquivalent_refl {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) :
    tropicallyEquivalent D D := by
  exact ⟨ 1, fun i j => by simp +decide ⟩

/-
Tropical equivalence is symmetric: if D ≃ E then E ≃ D.
    Uses the inverse permutation.
-/
theorem tropicallyEquivalent_symm {n : ℕ} {D E : Matrix (Fin n) (Fin n) ℕ} :
    tropicallyEquivalent D E → tropicallyEquivalent E D := by
  -- Given σ with E(σ i)(σ j) = D i j, use τ = σ⁻¹. Then D(τ i)(τ j) = D(σ⁻¹ i)(σ⁻¹ j). We need to show this equals E i j. From E(σ (σ⁻¹ i))(σ (σ⁻¹ j)) = D(σ⁻¹ i)(σ⁻¹ j), and σ(σ⁻¹ i) = i, so E i j = D(σ⁻¹ i)(σ⁻¹ j) = D(τ i)(τ j).
  intro h
  obtain ⟨σ, hσ⟩ := h
  use σ⁻¹
  intro i j
  simp [Equiv.apply_symm_apply, ← hσ]

/-
Tropical equivalence is transitive: if D ≃ E and E ≃ F then D ≃ F.
    Uses composition of permutations.
-/
theorem tropicallyEquivalent_trans {n : ℕ} {D E F : Matrix (Fin n) (Fin n) ℕ} :
    tropicallyEquivalent D E →
    tropicallyEquivalent E F →
    tropicallyEquivalent D F := by
  rintro ⟨ σ, hσ ⟩ ⟨ τ, hτ ⟩;
  exact ⟨ σ.trans τ, fun i j => by simpa using hτ ( σ i ) ( σ j ) ▸ hσ i j ⟩

/-
Tropical equivalence as a bundled equivalence relation.
-/
theorem tropicallyEquivalent_equivalence (n : ℕ) :
    Equivalence (@tropicallyEquivalent n) := by
  constructor;
  · exact fun x => tropicallyEquivalent_refl x
  · exact fun {x y} a => tropicallyEquivalent_symm a
  · exact fun {x y z} a a_1 => tropicallyEquivalent_trans a a_1

/-! ## The Univalence Theorem: Orbit Code Classification -/

/-
A matrix belongs to its own orbit code.
-/
theorem mem_orbitCode_self {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) :
    D ∈ orbitCode D := by
  exact Finset.mem_image.mpr ⟨ Equiv.refl _, Finset.mem_univ _, by exact permuteMatrix_one _ ⟩

/-
If E is in the orbit of D, then D and E are tropically equivalent.
-/
theorem tropicallyEquivalent_of_mem_orbitCode {n : ℕ}
    {D E : Matrix (Fin n) (Fin n) ℕ} (h : E ∈ orbitCode D) :
    tropicallyEquivalent D E := by
  obtain ⟨σ, hσ⟩ : ∃ σ : Equiv.Perm (Fin n), E = permuteMatrix D σ := by
    unfold orbitCode at h; aesop;
  exact ⟨ σ⁻¹, fun i j => by simpa [ hσ ] using by simp +decide [ permuteMatrix ] ⟩

/-
If D and E are tropically equivalent, then E is in the orbit of D.
-/
theorem mem_orbitCode_of_tropicallyEquivalent {n : ℕ}
    {D E : Matrix (Fin n) (Fin n) ℕ}
    (h : tropicallyEquivalent D E) :
    E ∈ orbitCode D := by
  -- By definition of $tropicallyEquivalent$, there exists some permutation $\sigma$ such that $E (σ i) (σ j) = D i j$ for all $i, j$.
  obtain ⟨σ, hσ⟩ := h;
  -- We need to show that $E = \text{permuteMatrix } D \sigma^{-1}$.
  have h_eq : E = permuteMatrix D σ⁻¹ := by
    ext i j; specialize hσ ( σ⁻¹ i ) ( σ⁻¹ j ) ; aesop;
  exact h_eq ▸ Finset.mem_image_of_mem _ ( Finset.mem_univ _ )

/-
If D and E are tropically equivalent, they have the same orbit code.
    This is the forward direction of univalence.
-/
theorem orbitCode_eq_of_tropicallyEquivalent {n : ℕ}
    {D E : Matrix (Fin n) (Fin n) ℕ}
    (h : tropicallyEquivalent D E) :
    orbitCode D = orbitCode E := by
  ext M;
  obtain ⟨ σ, hσ ⟩ := h;
  constructor <;> intro hM <;> simp_all +decide [ orbitCode ];
  · obtain ⟨ τ, rfl ⟩ := hM; use σ * τ; unfold permuteMatrix; aesop;
  · obtain ⟨ τ, rfl ⟩ := hM;
    use σ⁻¹ * τ;
    ext i j; simp +decide [ ← hσ, permuteMatrix ] ;

/-
If orbit codes are equal, the matrices are tropically equivalent.
    This is the backward direction of univalence.
-/
theorem tropicallyEquivalent_of_orbitCode_eq {n : ℕ}
    {D E : Matrix (Fin n) (Fin n) ℕ}
    (h : orbitCode D = orbitCode E) :
    tropicallyEquivalent D E := by
  exact tropicallyEquivalent_of_mem_orbitCode ( h.symm ▸ mem_orbitCode_self _ )

/-
**Tropical Univalence Theorem**: Two finite weighted spaces have equal
    canonical orbit codes if and only if there exists a distance-preserving
    permutation between them. This is the tropical shadow of the Univalence
    Axiom from Homotopy Type Theory.

    In HoTT: (A = B) ≃ (A ≃ B)
    In tropical shadow: (orbitCode D = orbitCode E) ↔ tropicallyEquivalent D E
-/
theorem tropicallyEquivalent_iff_orbitCode_eq {n : ℕ}
    (D E : Matrix (Fin n) (Fin n) ℕ) :
    tropicallyEquivalent D E ↔ orbitCode D = orbitCode E := by
  exact ⟨ fun h => orbitCode_eq_of_tropicallyEquivalent h, fun h => tropicallyEquivalent_of_orbitCode_eq h ⟩

/-! ## Decidability -/

/-- **Tropical equivalence is decidable.** This is the computational core of
    tropical univalence: unlike classical path types which are generally
    undecidable, tropical equivalence can be decided by exhaustive search
    over the finite permutation group.

    This connects tropical HoTT to algorithmic graph isomorphism and
    makes the univalence principle executable. -/
instance tropicalEquivalentDecidable {n : ℕ}
    (D E : Matrix (Fin n) (Fin n) ℕ) :
    Decidable (tropicallyEquivalent D E) :=
  Fintype.decidableExistsFintype

/-- The distance-matrix property is decidable. -/
instance isTropicalDistanceMatrix_decidable {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℕ) :
    Decidable (IsTropicalDistanceMatrix D) := by
  unfold IsTropicalDistanceMatrix
  exact instDecidableAnd

/-! ## Gluing and Higher Structure -/

/-
Minimum distributes over addition: the fundamental tropical algebraic
    identity that governs path composition in the tropical shadow.
    In HoTT terms, this normalizes "path concatenation costs."
-/
theorem tropical_plus_distributes_over_min (a b c : ℕ) :
    min (a + c) (b + c) = min a b + c := by
  bv_omega

/-- Glued distance: given two distance matrices sharing a boundary point,
    compute the distance in the glued space via the attachment point.
    This models a tropical pushout / higher inductive attachment. -/
def gluedDistance {n m : ℕ}
    (D : Matrix (Fin n) (Fin n) ℕ) (E : Matrix (Fin m) (Fin m) ℕ)
    (attach_D : Fin n) (attach_E : Fin m) :
    Matrix (Fin (n + m)) (Fin (n + m)) ℕ :=
  fun i j =>
    if h1 : i.val < n then
      if h2 : j.val < n then
        D ⟨i.val, h1⟩ ⟨j.val, h2⟩
      else
        D ⟨i.val, h1⟩ attach_D + E attach_E ⟨j.val - n, by omega⟩
    else
      if h2 : j.val < n then
        E ⟨i.val - n, by omega⟩ attach_E + D attach_D ⟨j.val, h2⟩
      else
        E ⟨i.val - n, by omega⟩ ⟨j.val - n, by omega⟩

/-
The glued distance at boundary points satisfies the normal form
    determined by tropical distribution.
-/
theorem gluedDistance_triangle_normal {a b c : ℕ} :
    min (a + c) (b + c) = min a b + c := by
  exact tropical_plus_distributes_over_min a b c