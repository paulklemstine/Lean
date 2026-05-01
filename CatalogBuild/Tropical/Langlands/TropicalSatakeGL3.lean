/-! # CatalogBuild.Tropical.Langlands.TropicalSatakeGL3

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 4
-/

import Mathlib
import Tropical.Core.TropicalFactoring
import Tropical.Langlands.ArthurSelbergGL2
import Tropical.Langlands.SatakeIsomorphism

noncomputable section

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


theorem tropical_satake_isomorphism_GL3 :
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

end
