import Mathlib

/-!
# The Tor functors: degree zero and vanishing for flat modules

`CategoryTheory.Tor C n` is the `n`-th left derived functor of the tensor product (derived in the
second variable). This file develops two basic facts about it in the category of modules:

* `Catalog.DerivedFunctors.torZeroIso`: `Tor₀(G, M) ≅ G ⊗ M`;
* `Catalog.DerivedFunctors.isZero_Tor_succ_of_flat`: **all higher Tor groups against a flat module
  vanish**, `Torₙ₊₁(G, M) = 0` whenever `G` is flat. The proof computes the left derived functor
  along an arbitrary projective resolution `P → M`, and uses that tensoring with a flat module is
  exact, hence commutes with homology; since `P` is exact in positive degrees the result follows.
* `Catalog.DerivedFunctors.not_flat_of_Tor_ne_zero`: the contrapositive, a nonvanishing higher Tor
  group is an obstruction to flatness.

Concrete consequences over `ℤ` are recorded at the end: all higher Tor groups against `ℚ` (a
torsion-free, hence flat, `ℤ`-module) and against `ℤ` itself vanish.
-/

universe u

open CategoryTheory MonoidalCategory Limits

namespace Catalog.DerivedFunctors

variable {R : Type u} [CommRing R]

/-- `Tor₀(G, M)` is just the tensor product `G ⊗ M`. -/
noncomputable def torZeroIso (G M : ModuleCat.{u} R) :
    ((Tor (ModuleCat.{u} R) 0).obj G).obj M ≅ G ⊗ M :=
  (((tensoringLeft (ModuleCat.{u} R)).obj G).leftDerivedZeroIsoSelf).app M

/-- **Higher Tor against a flat module vanishes.** -/
theorem isZero_Tor_succ_of_flat (G : ModuleCat.{u} R) [Module.Flat R G] (M : ModuleCat.{u} R)
    (n : ℕ) : IsZero (((Tor (ModuleCat.{u} R) (n + 1)).obj G).obj M) := by
  let P := ProjectiveResolution.of M
  let F := (tensoringLeft (ModuleCat.{u} R)).obj G
  have h1 : ((F.leftDerived (n + 1)).obj M) ≅
      ((F.mapHomologicalComplex (ComplexShape.down ℕ)).obj P.complex).homology (n + 1) :=
    P.isoLeftDerivedObj F (n + 1)
  have h2 : (((F.mapHomologicalComplex (ComplexShape.down ℕ)).obj P.complex).homology (n + 1)) ≅
      F.obj (P.complex.homology (n + 1)) := (P.complex.sc (n + 1)).mapHomologyIso F
  have h3 : IsZero (P.complex.homology (n + 1)) := by
    rw [← HomologicalComplex.exactAt_iff_isZero_homology]
    exact P.complex_exactAt_succ n
  exact (Functor.map_isZero F h3).of_iso (h1 ≪≫ h2)

/-- A nonvanishing higher Tor group obstructs flatness. -/
theorem not_flat_of_Tor_ne_zero (G M : ModuleCat.{u} R) (n : ℕ)
    (h : ¬ IsZero (((Tor (ModuleCat.{u} R) (n + 1)).obj G).obj M)) : ¬ Module.Flat R G :=
  fun _ => h (isZero_Tor_succ_of_flat G M n)

section Integers

/-- All higher Tor groups against `ℚ` vanish, since `ℚ` is a flat `ℤ`-module. -/
theorem isZero_Tor_succ_rat (M : ModuleCat.{0} ℤ) (n : ℕ) :
    IsZero (((Tor (ModuleCat.{0} ℤ) (n + 1)).obj (ModuleCat.of ℤ ℚ)).obj M) :=
  isZero_Tor_succ_of_flat _ M n

/-- All higher Tor groups against `ℤ` vanish. -/
theorem isZero_Tor_succ_int (M : ModuleCat.{0} ℤ) (n : ℕ) :
    IsZero (((Tor (ModuleCat.{0} ℤ) (n + 1)).obj (ModuleCat.of ℤ ℤ)).obj M) :=
  isZero_Tor_succ_of_flat _ M n

end Integers

end Catalog.DerivedFunctors