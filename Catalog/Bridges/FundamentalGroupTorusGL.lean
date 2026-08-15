/-
# The homotopy self-equivalence group of the `n`-torus is `GLₙ(ℤ)`

The `n`-dimensional torus is a `K(ℤⁿ,1)`.  Applying the main theorem of
`Catalog/Bridges/FundamentalGroupOuterAutomorphisms.lean` — the group of homotopy classes
of self-homotopy-equivalences of a `K(G,1)` is `Out G` — to the abelian group `ℤⁿ` gives

  `hAut(K(ℤⁿ,1)) ≅ Aut(ℤⁿ) ≅ GLₙ(ℤ)`

(`hEndUnitsTorusMulEquivGL`).  For `n = 1` this recovers the two degree `±1` self-maps of
the circle; for `n = 2` it is the classical statement that self-homotopy-equivalences of
the torus are classified by `GL₂(ℤ)`.

Along the way we record the dictionary `addAutMulEquivLinearEquiv` between additive
automorphisms of an abelian group and its `ℤ`-linear automorphisms.
-/
import Mathlib
import Bridges.FundamentalGroupCyclicSelfEquivalences
open CategoryTheory
open FundamentalGroupOut
open FundamentalGroupCyclic (mulAutMultiplicativeMulEquivAddAut)

namespace FundamentalGroupTorus

/-- Additive automorphisms of an abelian group are the same as its `ℤ`-linear
automorphisms. -/
def addAutMulEquivLinearEquiv (A : Type*) [AddCommGroup A] : AddAut A ≃* (A ≃ₗ[ℤ] A) where
  toFun e := e.toIntLinearEquiv
  invFun e := e.toAddEquiv
  left_inv _ := rfl
  right_inv _ := rfl
  map_mul' _ _ := rfl

/-- The algebraic model of the `n`-torus: the one-object groupoid of `ℤⁿ`. -/
abbrev TorusModel (n : ℕ) : Type := SingleObj (Multiplicative (Fin n → ℤ))

/-- **The homotopy self-equivalence group of the `n`-torus is `GLₙ(ℤ)`.** -/
noncomputable def hEndUnitsTorusMulEquivGL (n : ℕ) :
    (HEnd (TorusModel n))ˣ ≃* Matrix.GeneralLinearGroup (Fin n) ℤ :=
  (((hEndUnitsSingleObjMulEquivMulAut (Multiplicative (Fin n → ℤ))
        (fun x y => mul_comm x y)).trans
      (mulAutMultiplicativeMulEquivAddAut (Fin n → ℤ))).trans
    ((addAutMulEquivLinearEquiv (Fin n → ℤ)).trans
      (LinearMap.GeneralLinearGroup.generalLinearEquiv ℤ (Fin n → ℤ)).symm)).trans
    Matrix.GeneralLinearGroup.toLin.symm

/-- For the `2`-torus: `hAut(T²) ≅ GL₂(ℤ)`. -/
noncomputable def hEndUnitsTwoTorusMulEquivGL :
    (HEnd (TorusModel 2))ˣ ≃* Matrix.GeneralLinearGroup (Fin 2) ℤ :=
  hEndUnitsTorusMulEquivGL 2

/-- The shear matrices, an infinite family in `GL₂(ℤ)`. -/
def shear (n : ℤ) : Matrix.GeneralLinearGroup (Fin 2) ℤ where
  val := !![1, n; 0, 1]
  inv := !![1, -n; 0, 1]
  val_inv := by
    ext i j
    fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_succ]
  inv_val := by
    ext i j
    fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_succ]

theorem shear_injective : Function.Injective shear := by
  intro a b hab
  have h : ((shear a : Matrix (Fin 2) (Fin 2) ℤ)) 0 1
      = ((shear b : Matrix (Fin 2) (Fin 2) ℤ)) 0 1 := by rw [hab]
  simpa [shear] using h

/-- **The torus has infinitely many homotopy classes of self-homotopy-equivalences**, in
contrast with the circle (two) and with `K(ℤ/n,1)` (`φ(n)`): the shear matrices give
infinitely many distinct classes. -/
theorem infinite_hEnd_units_twoTorus : Infinite ((HEnd (TorusModel 2))ˣ) :=
  Infinite.of_injective (fun n : ℤ => hEndUnitsTwoTorusMulEquivGL.symm (shear n))
    (fun _ _ h => shear_injective (hEndUnitsTwoTorusMulEquivGL.symm.injective h))

end FundamentalGroupTorus