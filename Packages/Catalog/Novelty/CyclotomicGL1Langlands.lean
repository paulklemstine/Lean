/-
# The GL(1) Langlands correspondence for cyclotomic extensions of `ℚ`

This file builds the explicit group isomorphism realizing the abelian (GL(1)) Langlands
correspondence in its sharpest classical form: the **cyclotomic case** over `ℚ`.

For a modulus `n` the two sides are:

* **Automorphic / Hecke side**: `DirichletCharacter n = (ZMod n)ˣ →* ℂˣ`, the Dirichlet
  characters mod `n`.
* **Galois side**: `CyclotomicGaloisCharacter n = (CyclotomicField n ℚ ≃ₐ[ℚ] CyclotomicField n ℚ) →* ℂˣ`,
  the 1-dimensional complex representations of `Gal(ℚ(ζₙ)/ℚ)`.

The bridge is the Artin reciprocity isomorphism `(ZMod n)ˣ ≃* Gal(ℚ(ζₙ)/ℚ)`
(`IsCyclotomicExtension.autEquivPow`).  Over `ℚ` the required irreducibility of
`cyclotomic n ℚ` is automatic (`Polynomial.cyclotomic.irreducible_rat`), so the whole
correspondence holds unconditionally for every modulus `n`.

Main constructions and results:

* `CyclotomicGL1.frobeniusIso` — the reciprocity isomorphism `(ZMod n)ˣ ≃* Gal(ℚ(ζₙ)/ℚ)`.
* `CyclotomicGL1.frobeniusIso_zeta` — its defining property: `frobeniusIso k` sends the
  canonical root of unity `ζ` to `ζ ^ (k.val)`.
* `CyclotomicGL1.galois_abelian` — `Gal(ℚ(ζₙ)/ℚ)` is abelian.
* `CyclotomicGL1.dirichletToGalois` / `CyclotomicGL1.galoisToDirichlet` — the two directions
  of the correspondence, with the round-trip identities
  `dirichletToGalois_galoisToDirichlet`, `galoisToDirichlet_dirichletToGalois`, and
  `dirichletToGalois_bijective`.
* `CyclotomicGL1.correspondence` — the correspondence packaged as a group isomorphism
  `DirichletCharacter n ≃* CyclotomicGaloisCharacter n`.
-/
import Mathlib

open Polynomial

namespace CyclotomicGL1

variable (n : ℕ) [NeZero n]

/-- A **Dirichlet character** mod `n`: a group homomorphism `(ZMod n)ˣ →* ℂˣ`. -/
abbrev DirichletCharacter := (ZMod n)ˣ →* ℂˣ

/-- A **1-dimensional Galois character** of `Gal(ℚ(ζₙ)/ℚ)`: a group homomorphism
`(CyclotomicField n ℚ ≃ₐ[ℚ] CyclotomicField n ℚ) →* ℂˣ`. -/
abbrev CyclotomicGaloisCharacter :=
  (CyclotomicField n ℚ ≃ₐ[ℚ] CyclotomicField n ℚ) →* ℂˣ

/-- Over `ℚ`, the `n`-th cyclotomic polynomial is irreducible (for `n ≠ 0`).  This is the
hypothesis needed to invoke `IsCyclotomicExtension.autEquivPow`. -/
theorem cyclotomic_irreducible_rat : Irreducible (cyclotomic n ℚ) :=
  cyclotomic.irreducible_rat (Nat.pos_of_ne_zero (NeZero.ne n))

/-- **Artin reciprocity, cyclotomic case.**  The reciprocity isomorphism
`(ZMod n)ˣ ≃* Gal(ℚ(ζₙ)/ℚ)`, obtained as the inverse of `IsCyclotomicExtension.autEquivPow`.
Over `ℚ` it exists for every `n` because `cyclotomic n ℚ` is irreducible. -/
noncomputable def frobeniusIso :
    (ZMod n)ˣ ≃* (CyclotomicField n ℚ ≃ₐ[ℚ] CyclotomicField n ℚ) :=
  (IsCyclotomicExtension.autEquivPow (CyclotomicField n ℚ)
    (cyclotomic_irreducible_rat n)).symm

/-- **Defining property of the reciprocity map.**  The automorphism `frobeniusIso k` acts on
the canonical primitive `n`-th root of unity `ζ` by raising it to the power `k.val`. -/
theorem frobeniusIso_zeta (k : (ZMod n)ˣ) :
    frobeniusIso n k (IsCyclotomicExtension.zeta n ℚ (CyclotomicField n ℚ))
      = (IsCyclotomicExtension.zeta n ℚ (CyclotomicField n ℚ)) ^ ((k : ZMod n).val) := by
  set L := CyclotomicField n ℚ with hL
  have hζ := IsCyclotomicExtension.zeta_spec n ℚ L
  have hspec := hζ.autToPow_spec ℚ (frobeniusIso n k)
  have e : hζ.autToPow ℚ (frobeniusIso n k) = k := by
    have h2 : (IsCyclotomicExtension.autEquivPow L (cyclotomic_irreducible_rat n))
        (frobeniusIso n k) = k :=
      (IsCyclotomicExtension.autEquivPow L (cyclotomic_irreducible_rat n)).apply_symm_apply k
    simpa [IsCyclotomicExtension.autEquivPow_apply] using h2
  rw [e] at hspec
  exact hspec.symm

/-- **Abelianness of the Galois group.**  `Gal(ℚ(ζₙ)/ℚ)` is commutative — the structural
fact that makes GL(1) (abelian) class field theory apply.  Commutativity is transported from
that of `(ZMod n)ˣ` along the injective map `autEquivPow`. -/
theorem galois_abelian (a b : CyclotomicField n ℚ ≃ₐ[ℚ] CyclotomicField n ℚ) :
    a * b = b * a := by
  apply (IsCyclotomicExtension.autEquivPow (CyclotomicField n ℚ)
    (cyclotomic_irreducible_rat n)).injective
  rw [map_mul, map_mul, mul_comm]

/-- Commutativity of `Gal(ℚ(ζₙ)/ℚ)`, packaged as a `Std.Commutative` fact for `(· * ·)`. -/
instance galois_mul_comm :
    Std.Commutative
      (α := CyclotomicField n ℚ ≃ₐ[ℚ] CyclotomicField n ℚ) (· * ·) :=
  ⟨galois_abelian n⟩

/-- **Hecke → Galois.**  Send a Dirichlet character `χ` to the Galois character
`χ ∘ frobeniusIso⁻¹`, i.e. precompose with the reciprocity map. -/
noncomputable def dirichletToGalois (χ : DirichletCharacter n) :
    CyclotomicGaloisCharacter n :=
  χ.comp (frobeniusIso n).symm.toMonoidHom

/-- **Galois → Hecke.**  Send a Galois character `ψ` to the Dirichlet character
`ψ ∘ frobeniusIso`, i.e. precompose with the reciprocity map. -/
noncomputable def galoisToDirichlet (ψ : CyclotomicGaloisCharacter n) :
    DirichletCharacter n :=
  ψ.comp (frobeniusIso n).toMonoidHom

/-- Round trip Galois → Hecke → Galois is the identity. -/
theorem dirichletToGalois_galoisToDirichlet (ψ : CyclotomicGaloisCharacter n) :
    dirichletToGalois n (galoisToDirichlet n ψ) = ψ := by
  ext x
  simp [dirichletToGalois, galoisToDirichlet]

/-- Round trip Hecke → Galois → Hecke is the identity. -/
theorem galoisToDirichlet_dirichletToGalois (χ : DirichletCharacter n) :
    galoisToDirichlet n (dirichletToGalois n χ) = χ := by
  ext x
  simp [dirichletToGalois, galoisToDirichlet]

/-- The Hecke → Galois map is a bijection. -/
theorem dirichletToGalois_bijective :
    Function.Bijective (dirichletToGalois n) :=
  ⟨Function.LeftInverse.injective (galoisToDirichlet_dirichletToGalois n),
   Function.RightInverse.surjective (dirichletToGalois_galoisToDirichlet n)⟩

/-- **The GL(1) Langlands correspondence (cyclotomic case).**  The group of Dirichlet
characters mod `n` is isomorphic, as a group, to the group of 1-dimensional complex
representations of `Gal(ℚ(ζₙ)/ℚ)`.  The isomorphism is `χ ↦ χ ∘ (reciprocity map)`. -/
noncomputable def correspondence :
    DirichletCharacter n ≃* CyclotomicGaloisCharacter n where
  toFun := dirichletToGalois n
  invFun := galoisToDirichlet n
  left_inv := galoisToDirichlet_dirichletToGalois n
  right_inv := dirichletToGalois_galoisToDirichlet n
  map_mul' a b := by ext x; simp [dirichletToGalois]

end CyclotomicGL1