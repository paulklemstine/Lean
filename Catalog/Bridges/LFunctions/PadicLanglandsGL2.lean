/-
# p-adic Langlands for GL₂(ℚ_p): a foundational chain

This file develops a self-contained chain of results around the two sides of the
**p-adic Langlands correspondence for `GL₂(ℚ_p)`**:

* the **automorphic / `GL₂` side**: the group `GL₂(K)` over a field `K`
  (specialised to `K = ℚ_p = Padic p`), its scalar centre, the determinant
  character, and the abelian (`GL₁`) part of the correspondence;
* the **Galois side**: `2`-dimensional representations `ρ : G →* GL₂(ℚ_p)` of an
  abstract group `G` (a stand-in for `Gal(ℚ̄_p/ℚ_p)`), their determinant
  characters, and the compatibility of determinants with character twists.

The chain, each step feeding the next:

1. `matrix_two_cayley_hamilton` — the explicit Cayley–Hamilton identity for `2×2`
   matrices, `M * M = tr M • M - det M • 1` (the characteristic polynomial of a
   `2`-dimensional representation).
2. `matrix_two_adjugate` — the adjugate identity `M * (tr M • 1 - M) = det M • 1`,
   deduced from (1); it exhibits the inverse of a `GL₂` element.
3. `diagGL`, `diagGL_det`, `det_surjective` — the determinant `GL₂(K) →* Kˣ` is
   surjective.
4. `detCharCorrespondence` — the resulting bijection between characters of `Kˣ`
   and characters of `GL₂(K)` that are trivial on `SL₂(K) = ker det`.  This is the
   abelian (`GL₁`) shadow of the local Langlands correspondence: twisting
   characters of `GL₂` are exactly characters of `Kˣ`.
5. `scalarGL`, `scalarGL_det`, `scalarGL_comm` — the central scalar embedding
   `Kˣ →* GL₂(K)` and its determinant (the squaring map).
6. `twistRep`, `twistRep_det` — twisting a `2`-dimensional representation by a
   character multiplies the determinant character by the square of the twisting
   character, `det(χ ⊗ ρ) = χ² · det ρ`, the standard Galois-side compatibility.
7. p-adic specialisations (`Padic p = ℚ_p`) of the above.

Everything is proved from `Mathlib` with no axioms beyond the standard ones.
-/
import Mathlib

open Matrix Polynomial

namespace PadicLanglandsGL2

/-! ## The characteristic polynomial of a 2-dimensional representation -/

variable {K : Type*} [Field K]

/-- **Cayley–Hamilton for `2×2` matrices.**  Every `2×2` matrix satisfies its own
characteristic polynomial `X² - (tr M) X + (det M)`.  On the Galois side this is
the relation satisfied by the image of Frobenius in a `2`-dimensional
representation. -/
theorem matrix_two_cayley_hamilton (M : Matrix (Fin 2) (Fin 2) K) :
    M * M = M.trace • M - M.det • (1 : Matrix (Fin 2) (Fin 2) K) := by
  have h := Matrix.aeval_self_charpoly M
  rw [Matrix.charpoly_fin_two] at h
  simp only [map_sub, map_add, map_mul, aeval_X, aeval_C,
    Algebra.algebraMap_eq_smul_one, smul_one_mul, sq] at h
  linear_combination (norm := module) h

/-- **The adjugate identity for `2×2` matrices**, deduced from Cayley–Hamilton:
`M * (tr M • 1 - M) = det M • 1`.  When `det M` is a unit this expresses the
inverse of `M` as a polynomial in `M`, the mechanism behind invertibility in
`GL₂`. -/
theorem matrix_two_adjugate (M : Matrix (Fin 2) (Fin 2) K) :
    M * (M.trace • (1 : Matrix (Fin 2) (Fin 2) K) - M)
      = M.det • (1 : Matrix (Fin 2) (Fin 2) K) := by
  have h := matrix_two_cayley_hamilton M
  rw [mul_sub, mul_smul_comm, mul_one, h]
  module

/-! ## The determinant character is surjective -/

/-- The diagonal element `diag(u, 1)` of `GL₂(K)` attached to a unit `u : Kˣ`. -/
noncomputable def diagGL (u : Kˣ) : GL (Fin 2) K where
  val := Matrix.diagonal ![(u : K), 1]
  inv := Matrix.diagonal ![((u⁻¹ : Kˣ) : K), 1]
  val_inv := by
    rw [Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
    congr 1; ext i; fin_cases i <;> simp
  inv_val := by
    rw [Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
    congr 1; ext i; fin_cases i <;> simp

/-- The determinant of `diag(u, 1)` is `u`. -/
theorem diagGL_det (u : Kˣ) : Matrix.GeneralLinearGroup.det (diagGL u) = u := by
  ext; rw [GeneralLinearGroup.val_det_apply]; simp [diagGL]

/-- **The determinant is a surjective homomorphism `GL₂(K) →* Kˣ`.**  This is the
`GL₂ ↠ GL₁` reciprocity underlying the abelian part of the correspondence. -/
theorem det_surjective :
    Function.Surjective (Matrix.GeneralLinearGroup.det : GL (Fin 2) K →* Kˣ) :=
  fun u => ⟨diagGL u, diagGL_det u⟩

/-- Membership in `ker det` is exactly the `SL₂(K)` condition `det = 1`. -/
theorem mem_det_ker_iff (g : GL (Fin 2) K) :
    g ∈ (Matrix.GeneralLinearGroup.det (n := Fin 2) (R := K)).ker
      ↔ (g : Matrix (Fin 2) (Fin 2) K).det = 1 := by
  rw [MonoidHom.mem_ker, ← Units.val_eq_one, GeneralLinearGroup.val_det_apply]

/-- **The abelian (`GL₁`) part of the local Langlands correspondence.**

For any target group `A`, the determinant induces a bijection between
homomorphisms `Kˣ →* A` and homomorphisms `GL₂(K) →* A` that are trivial on
`SL₂(K) = ker det`.  Concretely: the "twisting characters" of `GL₂(K)` are
exactly the characters of `Kˣ`, pulled back along the determinant. -/
noncomputable def detCharCorrespondence {A : Type*} [Group A] :
    { f : GL (Fin 2) K →* A //
        (Matrix.GeneralLinearGroup.det (n := Fin 2) (R := K)).ker ≤ f.ker } ≃ (Kˣ →* A) :=
  MonoidHom.liftOfSurjective _ det_surjective

/-- Pulling a character of `Kˣ` back along `det` and restricting to `Kˣ` again
recovers the original character: the correspondence is a genuine inverse. -/
@[simp] theorem detCharCorrespondence_comp {A : Type*} [Group A]
    (f) : (detCharCorrespondence f).comp
      (Matrix.GeneralLinearGroup.det (n := Fin 2) (R := K)) = (f : GL (Fin 2) K →* A) :=
  MonoidHom.liftOfRightInverse_comp _ (Function.surjInv det_surjective)
    (Function.rightInverse_surjInv det_surjective) f

/-- Precomposition with the (surjective) determinant is injective on characters:
distinct characters of `Kˣ` give distinct twists of `GL₂(K)`. -/
theorem detChar_injective {A : Type*} [Group A] :
    Function.Injective
      (fun χ : Kˣ →* A => χ.comp (Matrix.GeneralLinearGroup.det (n := Fin 2) (R := K))) :=
  fun _ _ h => (MonoidHom.cancel_right det_surjective).1 h

/-! ## The scalar (central) embedding `Kˣ →* GL₂(K)` -/

/-- The central scalar embedding `Kˣ →* GL₂(K)`, `u ↦ u • 1`. -/
noncomputable def scalarGL : Kˣ →* GL (Fin 2) K :=
  Units.map (Matrix.scalar (Fin 2)).toMonoidHom

/-- The determinant of the scalar matrix `u • 1` is `u²`: the central character
enters the determinant squared. -/
theorem scalarGL_det (a : Kˣ) : Matrix.GeneralLinearGroup.det (scalarGL a) = a ^ 2 := by
  ext
  rw [GeneralLinearGroup.val_det_apply]
  simp [scalarGL, Units.map, sq]

/-- Scalar matrices are central in `GL₂(K)`. -/
theorem scalarGL_comm (a : Kˣ) (g : GL (Fin 2) K) :
    scalarGL a * g = g * scalarGL a := by
  ext i j
  simp only [scalarGL, Units.map]
  show (Matrix.scalar (Fin 2) (a : K) * (g : Matrix (Fin 2) (Fin 2) K)) i j
     = ((g : Matrix (Fin 2) (Fin 2) K) * Matrix.scalar (Fin 2) (a : K)) i j
  rw [Matrix.scalar_commute _ (fun r => Commute.all _ _)]

/-! ## The Galois side: 2-dimensional representations and twists -/

variable {G : Type*} [Group G]

/-- **Twisting a `2`-dimensional representation by a character.**  Given a
representation `ρ : G →* GL₂(K)` and a character `χ : G →* Kˣ`, the twist
`χ ⊗ ρ` sends `g` to `χ(g) • ρ(g)`.  Because scalars are central this is again a
homomorphism. -/
noncomputable def twistRep (χ : G →* Kˣ) (ρ : G →* GL (Fin 2) K) : G →* GL (Fin 2) K where
  toFun g := scalarGL (χ g) * ρ g
  map_one' := by simp
  map_mul' g h := by
    simp only [map_mul, mul_assoc]
    rw [← mul_assoc (scalarGL (χ h)), scalarGL_comm (χ h) (ρ g),
        mul_assoc (ρ g) (scalarGL (χ h)) (ρ h)]

/-- The determinant character of a `2`-dimensional representation `ρ`, i.e.
`det ∘ ρ : G →* Kˣ`.  Under local class field theory this is the central
character of the corresponding `GL₂` representation. -/
noncomputable def detRep (ρ : G →* GL (Fin 2) K) : G →* Kˣ :=
  (Matrix.GeneralLinearGroup.det (n := Fin 2) (R := K)).comp ρ

/-- **Determinant of a twist.**  Twisting by `χ` multiplies the determinant
character by `χ²`:  `det(χ ⊗ ρ) = χ² · det ρ`.  This is the standard
compatibility between the determinant of a Galois representation and character
twists in the Langlands correspondence. -/
theorem twistRep_det (χ : G →* Kˣ) (ρ : G →* GL (Fin 2) K) (g : G) :
    detRep (twistRep χ ρ) g = (χ g) ^ 2 * detRep ρ g := by
  simp only [detRep, twistRep, MonoidHom.comp_apply, MonoidHom.coe_mk, OneHom.coe_mk,
    map_mul, scalarGL_det]

/-! ## Specialisation to `K = ℚ_p = Padic p` -/

section Padic

variable (p : ℕ) [hp : Fact p.Prime]

/-- Over `ℚ_p`, the determinant `GL₂(ℚ_p) →* ℚ_pˣ` is surjective. -/
theorem padic_det_surjective :
    Function.Surjective
      (Matrix.GeneralLinearGroup.det : GL (Fin 2) (Padic p) →* (Padic p)ˣ) :=
  det_surjective

/-- Over `ℚ_p`, Cayley–Hamilton for `2×2` matrices. -/
theorem padic_matrix_two_cayley_hamilton (M : Matrix (Fin 2) (Fin 2) (Padic p)) :
    M * M = M.trace • M - M.det • (1 : Matrix (Fin 2) (Fin 2) (Padic p)) :=
  matrix_two_cayley_hamilton M

/-- **The abelian part of p-adic Langlands for `GL₂(ℚ_p)`**: characters of
`GL₂(ℚ_p)` trivial on `SL₂(ℚ_p)` are in bijection with characters of `ℚ_pˣ`. -/
noncomputable def padicDetCharCorrespondence {A : Type*} [Group A] :
    { f : GL (Fin 2) (Padic p) →* A //
        (Matrix.GeneralLinearGroup.det (n := Fin 2) (R := Padic p)).ker ≤ f.ker }
      ≃ ((Padic p)ˣ →* A) :=
  detCharCorrespondence

/-- Over `ℚ_p`, the determinant of a twist of a `2`-dimensional Galois
representation by a character `χ` is `χ²` times the original determinant. -/
theorem padic_twistRep_det (χ : G →* (Padic p)ˣ) (ρ : G →* GL (Fin 2) (Padic p)) (g : G) :
    detRep (twistRep χ ρ) g = (χ g) ^ 2 * detRep ρ g :=
  twistRep_det χ ρ g

end Padic

end PadicLanglandsGL2