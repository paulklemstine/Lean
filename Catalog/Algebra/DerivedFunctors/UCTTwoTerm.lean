import Algebra.DerivedFunctors.ZModResolution

/-!
# The universal coefficient theorem for a two-term free complex

Let `C` be the chain complex of free `ℤ`-modules

`⋯ → 0 → 0 → ℤ --(·k)--> ℤ`

constructed in `Algebra.DerivedFunctors.ZModResolution` (`resComplex k`), and let `G` be an
arbitrary `ℤ`-module.  Its homology is `H₀(C) = ZMod k` and `H₁(C) = 0` (for `k ≠ 0`).

The universal coefficient theorem for homology predicts, for the complex `G ⊗ C`, a short exact
sequence

`0 → G ⊗ Hₙ(C) → Hₙ(G ⊗ C) → Tor₁(G, Hₙ₋₁(C)) → 0`.

For this complex both extreme cases are visible and are proved here:

* `Catalog.DerivedFunctors.uctHomologyZeroIso`: in degree `0` the `Tor`-term is absent
  (`H₋₁ = 0`) and `H₀(G ⊗ C) ≅ G ⊗ H₀(C)`;
* `Catalog.DerivedFunctors.uctHomologyOneIso`: in degree `1` the tensor term is absent
  (`H₁(C) = 0`, see `Catalog.DerivedFunctors.isZero_resComplex_homology_one`) and the whole of
  `H₁(G ⊗ C)` is the correction term `Tor₁(G, H₀(C))`.

Both isomorphisms are obtained from the bundled projective resolution
`Catalog.DerivedFunctors.zmodProjectiveResolution` together with
`CategoryTheory.ProjectiveResolution.isoLeftDerivedObj`.
-/

open CategoryTheory Limits MonoidalCategory ZeroObject HomologicalComplex

namespace Catalog.DerivedFunctors

variable (k : ℕ)

/-- The homology of the two-term complex `⋯ → 0 → ℤ --(·k)--> ℤ` in degree `0` is `ZMod k`. -/
noncomputable def resComplexHomologyZeroIso (hk : k ≠ 0) :
    (resComplex k).homology 0 ≅ ModuleCat.of ℤ (ZMod k) :=
  haveI : QuasiIsoAt (resPi k) 0 := quasiIsoAt_resPi_zero k hk
  haveI : IsIso (HomologicalComplex.homologyMap (resPi k) 0) :=
    (quasiIsoAt_iff_isIso_homologyMap _ _).1 inferInstance
  asIso (HomologicalComplex.homologyMap (resPi k) 0) ≪≫
    HomologicalComplex.singleObjHomologySelfIso _ 0 _

/-- The two-term complex `⋯ → 0 → ℤ --(·k)--> ℤ` has vanishing homology in degree `1`
(multiplication by `k ≠ 0` is injective). -/
theorem isZero_resComplex_homology_one (hk : k ≠ 0) : IsZero ((resComplex k).homology 1) := by
  have h : (resComplex k).ExactAt 1 := by
    have := quasiIsoAt_resPi_succ k hk 0
    rw [quasiIsoAt_iff_exactAt' (resPi k) 1 (ChainComplex.exactAt_succ_single_obj _ 0)] at this
    exact this
  exact (HomologicalComplex.exactAt_iff_isZero_homology _ _).1 h

variable (G : ModuleCat.{0} ℤ)

/-- **Universal coefficient theorem in degree zero** for the two-term free complex:
since there is no homology in degree `-1`, the correction term vanishes and
`H₀(G ⊗ C) ≅ G ⊗ H₀(C)`. -/
noncomputable def uctHomologyZeroIso (hk : k ≠ 0) :
    (((tensorLeft G).mapHomologicalComplex (ComplexShape.down ℕ)).obj (resComplex k)).homology 0 ≅
      (tensorLeft G).obj ((resComplex k).homology 0) :=
  ((zmodProjectiveResolution k hk).isoLeftDerivedObj (tensorLeft G) 0).symm ≪≫
    (Functor.leftDerivedZeroIsoSelf (tensorLeft G)).app _ ≪≫
      (tensorLeft G).mapIso (resComplexHomologyZeroIso k hk).symm

/-- **Universal coefficient theorem in degree one** for the two-term free complex:
since `H₁(C) = 0`, the homology `H₁(G ⊗ C)` consists exactly of the correction term
`Tor₁(G, H₀(C))`. -/
noncomputable def uctHomologyOneIso (hk : k ≠ 0) :
    (((tensorLeft G).mapHomologicalComplex (ComplexShape.down ℕ)).obj (resComplex k)).homology 1 ≅
      ((Tor (ModuleCat.{0} ℤ) 1).obj G).obj ((resComplex k).homology 0) :=
  ((zmodProjectiveResolution k hk).isoLeftDerivedObj
      ((tensoringLeft (ModuleCat.{0} ℤ)).obj G) 1).symm ≪≫
    ((Tor (ModuleCat.{0} ℤ) 1).obj G).mapIso (resComplexHomologyZeroIso k hk).symm

end Catalog.DerivedFunctors