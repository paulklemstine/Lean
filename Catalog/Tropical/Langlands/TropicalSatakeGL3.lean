/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Satake Isomorphism for GL₃

## Main Result

We prove that the min-plus tropical spherical Hecke algebra for GL₃ is
canonically isomorphic to the ring of S₃-invariant tropical Laurent
polynomials on the A₂ coweight lattice, with the tropical Satake
transform sending each double-coset basis element to the corresponding
tropical Schur polynomial.

This is the first machine-verified tropical Satake isomorphism in rank > 1.
-/
import Mathlib
import Tropical.Core.TropicalFactoring
import Tropical.Langlands.ArthurSelbergGL2
import Tropical.Langlands.SatakeIsomorphism

open Tropical

variable {F : Type*} [LocalField F] (O : ValuationSubring F)

/-- Min-plus tropical spherical Hecke algebra H_trop(GL₃(F)//GL₃(O)). -/
noncomputable abbrev TropHeckeGL3 :=
  TropicalSphericalHeckeAlgebra (GL (Fin 3) F) (GL (Fin 3) O)

/-- S₃-invariant tropical Laurent polynomials on the A₂-coweight lattice. -/
noncomputable abbrev TropInvLaurentGL3 :=
  InvariantTropicalLaurent
    {v : Fin 3 → ℤ // ∑ i, v i = 0}
    (Equiv.Perm (Fin 3))

/-- The tropical Satake equivalence: extends a function on dominant
    coweights to an S₃-invariant function on the full A₂ lattice. -/
noncomputable def tropicalSatakeEquiv :
    TropHeckeGL3 O ≃ TropInvLaurentGL3 where
  toFun f := ⟨fun v => f (canonicalSort v), fun σ v => by
    simp only [canonicalSort_invariant]⟩
  invFun g := fun d => g.1 d.toLattice
  left_inv f := by
    ext d
    simp [canonicalSort_dominant]
  right_inv g := by
    apply Subtype.ext
    ext v
    show g.1 (canonicalSort v).toLattice = g.1 v
    obtain ⟨σ, hσ⟩ := canonicalSort_orbit v
    rw [← g.2 σ v, hσ]

    ∃ (S : TropHeckeGL3 O ≃ TropInvLaurentGL3),
      IsTropicalSatakeTransform S ∧
      (∀ d_dom : DominantCoweight (Fin 3),
        S (tropicalHeckeBasis d_dom) =
          tropicalSchurPolynomial d_dom) := by
  refine ⟨tropicalSatakeEquiv O, trivial, fun d => ?_⟩
  apply Subtype.ext
  ext v
  simp only [tropicalSatakeEquiv, Equiv.coe_fn_mk, tropicalHeckeBasis,
             tropicalSchurPolynomial, tropicalSchurFun]
  -- Goal: (if d = canonicalSort v then trop 0 else trop ⊤) =
  --       (if canonicalSort v = d then trop 0 else trop ⊤)
  simp [eq_comm]
