import Combinatorics.FisherSimplexCurvature

/-!
# A negatively curved control model for the curvature machinery

The companion file `Combinatorics.FisherSimplexCurvature` proves that the
Fisher–Rao geometry of the trinomial (finite-support) model has *constant Gauss
curvature `+1/4`*.  A sceptical reader is entitled to ask whether the sign is an
artefact of the index conventions baked into `TrinomialFisher.riemann` and
`TrinomialFisher.sectional`.

This file settles that: **running the exact same machinery** on the Poincaré
upper half-plane `g = y⁻²(dx² + dy²)` returns `K = -1`.  Hence the sign
convention is calibrated, and the `+1/4` of the simplex is a genuine positive
curvature, not a bookkeeping accident.

The same staged discipline is used: `dgH` is *proved* to be the derivative of
`gH`, `chrH` is *proved* to be the raised Levi-Civita symbol (which by
`TrinomialFisher.levi_civita_unique` is the only torsion-free compatible choice),
and `dchrH` is *proved* to be the derivative of `chrH`.
-/

open Finset TrinomialFisher

noncomputable section

namespace HyperbolicControl

/-- The Poincaré half-plane metric `g = y⁻² (dx² + dy²)`. -/
def gH : Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, _, y => 1 / y ^ 2
  | 0, 1, _, _ => 0
  | 1, 0, _, _ => 0
  | 1, 1, _, y => 1 / y ^ 2

/-- Closed form for `∂_k g_ij` of the half-plane metric. -/
def dgH : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 1, 0, 0, _, y => -2 / y ^ 3
  | 1, 1, 1, _, y => -2 / y ^ 3
  | _, _, _, _, _ => 0

theorem dgH_symm (k i j : Fin 2) (x y : ℝ) : dgH k i j x y = dgH k j i x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

/-- `dgH 0` really is the `x`-derivative of `gH`: the metric does not depend on `x`. -/
theorem hasDerivAt_gH_fst (i j : Fin 2) (x y : ℝ) :
    HasDerivAt (fun t => gH i j t y) (dgH 0 i j x y) x := by
  fin_cases i <;> fin_cases j <;> simp only [gH, dgH] <;> exact hasDerivAt_const x _

/-- `dgH 1` really is the `y`-derivative of `gH`. -/
theorem hasDerivAt_gH_snd (i j : Fin 2) (x y : ℝ) (hy : y ≠ 0) :
    HasDerivAt (fun t => gH i j x t) (dgH 1 i j x y) y := by
  have key : HasDerivAt (fun t : ℝ => 1 / t ^ 2) (-2 / y ^ 3) y := by
    refine ((hasDerivAt_const y (1 : ℝ)).div (hasDerivAt_pow 2 y)
      (pow_ne_zero 2 hy)).congr_deriv ?_
    field_simp
    ring
  fin_cases i <;> fin_cases j <;> simp only [gH, dgH]
  · exact key
  · exact hasDerivAt_const y _
  · exact hasDerivAt_const y _
  · exact key

/-- Christoffel symbols of the first kind of the half-plane metric. -/
def chrLowH (i j l : Fin 2) (x y : ℝ) : ℝ :=
  (dgH i j l x y + dgH j i l x y - dgH l i j x y) / 2

theorem chrLowH_symm (i j l : Fin 2) (x y : ℝ) : chrLowH i j l x y = chrLowH j i l x y := by
  simp only [chrLowH, dgH_symm l i j]
  ring

theorem dgH_eq_chrLowH_add (k i j : Fin 2) (x y : ℝ) :
    dgH k i j x y = chrLowH k i j x y + chrLowH k j i x y := by
  simp only [chrLowH, dgH_symm i k j, dgH_symm j k i, dgH_symm k i j]
  ring

/-- `chrLowH` is the unique torsion-free metric-compatible connection for `gH`,
by the general Koszul uniqueness theorem. -/
theorem chrLowH_unique (G : Fin 2 → Fin 2 → Fin 2 → ℝ) (x y : ℝ)
    (hGsym : ∀ i j l, G i j l = G j i l)
    (hcompat : ∀ k i j, dgH k i j x y = G k i j + G k j i) (i j l : Fin 2) :
    G i j l = chrLowH i j l x y :=
  levi_civita_unique (fun k i j => dgH k i j x y) G hGsym hcompat i j l

/-- The inverse half-plane metric `g^{ij} = y² δ^{ij}`. -/
def gInvH : Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, _, y => y ^ 2
  | 0, 1, _, _ => 0
  | 1, 0, _, _ => 0
  | 1, 1, _, y => y ^ 2

theorem gInvH_mul_gH (i j : Fin 2) (x y : ℝ) (hy : y ≠ 0) :
    ∑ l : Fin 2, gInvH i l x y * gH l j x y = if i = j then 1 else 0 := by
  fin_cases i <;> fin_cases j <;> simp only [Fin.sum_univ_two, gInvH, gH] <;> norm_num <;>
    field_simp

/-- Christoffel symbols of the second kind of the half-plane metric, in closed form. -/
def chrH : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 1, _, y => -1 / y
  | 0, 1, 0, _, y => -1 / y
  | 1, 0, 0, _, y => 1 / y
  | 1, 1, 1, _, y => -1 / y
  | _, _, _, _, _ => 0

/-- `chrH` is the raised Levi-Civita connection of the half-plane metric. -/
theorem chrH_eq_raise (k i j : Fin 2) (x y : ℝ) (hy : y ≠ 0) :
    chrH k i j x y = ∑ l : Fin 2, gInvH k l x y * chrLowH i j l x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;>
    simp only [chrH, chrLowH, dgH, gInvH, Fin.sum_univ_two] <;> field_simp <;> ring

/-- Closed form for `∂_d Γ^k_{ij}` of the half-plane metric. -/
def dchrH : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 1, 0, 0, 1, _, y => 1 / y ^ 2
  | 1, 0, 1, 0, _, y => 1 / y ^ 2
  | 1, 1, 0, 0, _, y => -1 / y ^ 2
  | 1, 1, 1, 1, _, y => 1 / y ^ 2
  | _, _, _, _, _, _ => 0

theorem hasDerivAt_chrH_fst (k i j : Fin 2) (x y : ℝ) :
    HasDerivAt (fun t => chrH k i j t y) (dchrH 0 k i j x y) x := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chrH, dchrH] <;>
    exact hasDerivAt_const x _

theorem hasDerivAt_chrH_snd (k i j : Fin 2) (x y : ℝ) (hy : y ≠ 0) :
    HasDerivAt (fun t => chrH k i j x t) (dchrH 1 k i j x y) y := by
  have key : HasDerivAt (fun t : ℝ => -1 / t) (1 / y ^ 2) y := by
    refine (hasDerivAt_constDiv (-1) y hy).congr_deriv ?_
    ring
  have key' : HasDerivAt (fun t : ℝ => 1 / t) (-1 / y ^ 2) y := hasDerivAt_constDiv 1 y hy
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chrH, dchrH]
  · exact hasDerivAt_const y _
  · exact key
  · exact key
  · exact hasDerivAt_const y _
  · exact key'
  · exact hasDerivAt_const y _
  · exact hasDerivAt_const y _
  · exact key

/-- The Gauss curvature of the Poincaré half-plane, computed with exactly the same
`riemann`/`sectional` machinery used for the statistical simplex. -/
def hyperbolicCurvature (x y : ℝ) : ℝ :=
  sectional (fun i j => gH i j x y) (fun k i j => chrH k i j x y)
    (fun d k i j => dchrH d k i j x y)

/-- **Calibration theorem.**  The same machinery returns `K = -1` on the Poincaré
half-plane.  Together with `TrinomialFisher.gaussianCurvature_eq` this shows that
the `+1/4` obtained for the trinomial model is a genuine *positive* curvature. -/
theorem hyperbolicCurvature_eq (x y : ℝ) (hy : y ≠ 0) :
    hyperbolicCurvature x y = -1 := by
  simp only [hyperbolicCurvature, sectional, riemann, Fin.sum_univ_two, gH, chrH, dchrH]
  field_simp
  ring

/-- The two models are geometrically incomparable: no point of the half-plane has
the curvature of the statistical simplex. -/
theorem hyperbolic_ne_simplex (x y u v : ℝ) (hy : y ≠ 0)
    (hu : u ≠ 0) (hv : v ≠ 0) (huv : 1 - u - v ≠ 0) :
    hyperbolicCurvature x y ≠ gaussianCurvature u v := by
  rw [hyperbolicCurvature_eq x y hy, gaussianCurvature_eq u v hu hv huv]
  norm_num

end HyperbolicControl