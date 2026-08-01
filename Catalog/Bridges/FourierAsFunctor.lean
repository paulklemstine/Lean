import Mathlib

/-!
# Fourier analysis as a functor: a finite-dimensional categorical model

This file isolates a rigorous algebraic core of the proposed bridge. Objects are coordinate
spaces `K^(Fin n)` and morphisms are matrices. Transposition realizes the contravariant
character-dual functor and gives an equivalence with the opposite category. A Fourier matrix
is an isomorphism, but the bold claim that Fourier matrices form a natural endomorphism for
*all* linear maps is false; an explicit two-dimensional counterexample is proved below.
-/

open CategoryTheory Matrix

universe u

namespace FourierAsFunctor

/-- A skeleton of finite free `K`-modules: object `n` represents `K^(Fin n)` and a
morphism `m ⟶ n` is an `n × m` matrix. -/
abbrev FinFreeMat (_K : Type u) := ℕ

namespace FinFreeMat

variable (K : Type u) [CommRing K]

instance : Category (FinFreeMat K) where
  Hom m n := Matrix (Fin n) (Fin m) K
  id n := 1
  comp A B := B * A
  assoc := by intros; exact (Matrix.mul_assoc _ _ _).symm
  id_comp := by intros; apply Matrix.mul_one
  comp_id := by intros; apply Matrix.one_mul

@[simp]
theorem comp_apply {l m n : FinFreeMat K}
    (A : l ⟶ m) (B : m ⟶ n) (i : Fin n) (j : Fin l) :
    (A ≫ B) i j = ∑ k, B i k * A k j := rfl

/-- Character duality on finite coordinate modules. On arrows it is matrix transposition,
so its variance is reversed exactly as in `Hom(-, K)`. -/
def dualFunctor : (FinFreeMat K)ᵒᵖ ⥤ FinFreeMat K where
  obj X := X.unop
  map f := f.unop.transpose
  map_id X := Matrix.transpose_one
  map_comp f g := by
    apply Matrix.ext; intro i j
    change (∑ k, f.unop j k * g.unop k i) = ∑ k, g.unop k i * f.unop j k
    exact Finset.sum_congr rfl (fun k _ => mul_comm (f.unop j k) (g.unop k i))

/-- The inverse-direction transpose functor. -/
def dualOpFunctor : FinFreeMat K ⥤ (FinFreeMat K)ᵒᵖ where
  obj X := Opposite.op X
  map f := Quiver.Hom.op f.transpose
  map_id X := by
    apply Quiver.Hom.unop_inj
    exact Matrix.transpose_one
  map_comp f g := by
    apply Quiver.Hom.unop_inj
    apply Matrix.ext; intro i j
    change (∑ k, g j k * f k i) = ∑ k, f k i * g j k
    exact Finset.sum_congr rfl (fun k _ => mul_comm (g j k) (f k i))

/-- Double character dualization is naturally isomorphic to the identity. -/
def doubleDualIso : dualOpFunctor K ⋙ dualFunctor K ≅ 𝟭 (FinFreeMat K) :=
  NatIso.ofComponents (fun X => Iso.refl X) (by
    intro X Y f
    change f.transpose.transpose ≫ 𝟙 Y = 𝟙 X ≫ f
    simp)

/-- The opposite-side double dual is also naturally the identity. -/
def oppositeDoubleDualIso : dualFunctor K ⋙ dualOpFunctor K ≅ 𝟭 ((FinFreeMat K)ᵒᵖ) :=
  NatIso.ofComponents (fun X => Iso.refl X) (by
    intro X Y f
    apply Quiver.Hom.unop_inj
    simp [dualFunctor, dualOpFunctor])

/-- Finite free character duality is a categorical equivalence. This is the exact
finite-coordinate analogue of Pontryagin biduality. -/
def dualEquivalence : (FinFreeMat K)ᵒᵖ ≌ FinFreeMat K :=
  @CategoryTheory.Equivalence.mk _ _ _ _ (dualFunctor K) (dualOpFunctor K)
    (oppositeDoubleDualIso K).symm (doubleDualIso K)

/-- The categorical contravariance equation: dualizing a composite reverses its factors. -/
theorem hom_contravariant {l m n : FinFreeMat K} (A : l ⟶ m) (B : m ⟶ n) :
    (dualFunctor K).map (B.op ≫ A.op) =
      (dualFunctor K).map B.op ≫ (dualFunctor K).map A.op := by
  simp

/-- The unnormalized discrete Fourier matrix. -/
def fourierMatrix (ω : K) (n : ℕ) : Matrix (Fin n) (Fin n) K :=
  fun j i => ω ^ (i.val * j.val)

end FinFreeMat

section ActualPontryaginDual

variable {A B C : Type*}
  [CommGroup A] [CommGroup B] [CommGroup C]
  [TopologicalSpace A] [TopologicalSpace B] [TopologicalSpace C]

/-- The actual circle-valued character construction `Hom(-, Circle)` reverses
composition. This is the functorial statement underlying Pontryagin duality. -/
theorem pontryagin_hom_contravariant (f : A →ₜ* B) (g : B →ₜ* C) :
    PontryaginDual.map (g.comp f) =
      (PontryaginDual.map f).comp (PontryaginDual.map g) := by
  exact PontryaginDual.map_comp g f

end ActualPontryaginDual

section RationalCounterexample

/-- The two-point Fourier matrix over `ℚ`. -/
def dftTwo : Matrix (Fin 2) (Fin 2) ℚ := FinFreeMat.fourierMatrix ℚ (-1) 2

/-- Its explicitly normalized inverse. -/
def idftTwo : Matrix (Fin 2) (Fin 2) ℚ := fun i j => (1 / 2) * dftTwo i j

/-- The two-point Fourier transform is genuinely invertible. -/
theorem dftTwo_mul_idftTwo : dftTwo * idftTwo = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> norm_num [dftTwo, idftTwo, FinFreeMat.fourierMatrix,
    Matrix.mul_apply, Fin.sum_univ_two]

/-- The inverse works on the other side as well. -/
theorem idftTwo_mul_dftTwo : idftTwo * dftTwo = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> norm_num [dftTwo, idftTwo, FinFreeMat.fourierMatrix,
    Matrix.mul_apply, Fin.sum_univ_two]

/-- Fourier inversion as an isomorphism in the matrix category. -/
def dftTwoIso : (2 : FinFreeMat ℚ) ≅ 2 where
  hom := dftTwo
  inv := idftTwo
  hom_inv_id := idftTwo_mul_dftTwo
  inv_hom_id := dftTwo_mul_idftTwo

/-- Projection onto the first coordinate. -/
def firstProjection : Matrix (Fin 2) (Fin 2) ℚ :=
  fun i j => if i = 0 ∧ j = 0 then 1 else 0

/-- **Disproof of unrestricted Fourier naturality.** The Fourier matrix does not commute
with every linear map, so the family of DFT matrices cannot be a natural endomorphism of
the identity functor on the category containing all linear maps. -/
theorem unrestricted_fourier_naturality_false :
    ¬ (∀ A : (2 : FinFreeMat ℚ) ⟶ 2, A ≫ dftTwo = dftTwo ≫ A) := by
  intro h
  have h01 := congr_fun (congr_fun (h firstProjection) (0 : Fin 2)) (1 : Fin 2)
  norm_num [FinFreeMat.comp_apply, dftTwo, firstProjection,
    FinFreeMat.fourierMatrix, Fin.sum_univ_two] at h01

/-- Coordinate support size, used for a precise test of a purported categorical
uncertainty principle. -/
def supportSize {n : ℕ} (v : Fin n → ℚ) : ℕ := Finset.univ.filter (v · ≠ 0) |>.card

/-- The first basis vector in dimension two. -/
def deltaZero : Fin 2 → ℚ := fun i => if i = 0 then 1 else 0

/-- **Disproof that contravariance alone implies an uncertainty bound.** The identity
transform coexists with the contravariant duality above, but a delta vector and its image
both have support one, violating the Fourier-style lower bound `2 ≤ |supp v| |supp Tv|`.
Thus uncertainty needs Fourier orthogonality/nondegeneracy, not variance alone. -/
theorem contravariance_alone_does_not_force_uncertainty :
    supportSize deltaZero * supportSize (id deltaZero) < 2 := by
  norm_num [supportSize, deltaZero, Finset.card_filter]

end RationalCounterexample

end FourierAsFunctor