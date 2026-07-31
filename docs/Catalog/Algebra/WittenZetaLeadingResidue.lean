import Mathlib

/-!
# Universal leading residues for Witten zeta functions

This file formalizes the algebraic and asymptotic core of the leading-residue formula in
J. Matuzas, *A universal leading-residue formula for Witten zeta functions*.

The analytic notion used here is the one-sided real leading residue
`lim s → s₀+ (s-s₀) f(s)`.  This is the precise local datum needed both by the
normalization argument and by the representation-counting constant.
-/

open scoped BigOperators Topology
open Filter Finset

namespace WittenZeta

/-- Numerical invariants entering the universal residue formula.  The top invariant degree is the
Coxeter number, so `properDegrees` records only the other `rank - 1` degrees. -/
structure RootInvariants where
  rank : ℕ
  rank_pos : 0 < rank
  coxeter : ℕ
  coxeter_gt_one : 1 < coxeter
  properDegrees : Fin (rank - 1) → ℕ
  properDegrees_pos : ∀ i, 0 < properDegrees i
  properDegrees_lt : ∀ i, properDegrees i < coxeter
  weylOrder : ℕ
  weylOrder_pos : 0 < weylOrder
  cartanDet : ℕ
  cartanDet_pos : 0 < cartanDet

/-- The critical exponent `2 / h`. -/
noncomputable def RootInvariants.criticalExponent (D : RootInvariants) : ℝ :=
  2 / D.coxeter

/-- The gamma quotient appearing in the universal formula. -/
noncomputable def RootInvariants.gammaQuotient (D : RootInvariants) : ℝ :=
  (∏ i, Real.Gamma (1 - (D.properDegrees i : ℝ) / D.coxeter)) /
    Real.Gamma (1 - 1 / (D.coxeter : ℝ)) ^ D.rank

/-- The universal value of the leading residue of Au's normalized Witten zeta function. -/
noncomputable def RootInvariants.universalLeadingResidue (D : RootInvariants) : ℝ :=
  (2 * (2 * Real.pi) ^ ((D.rank : ℝ) / 2) * Real.sqrt D.cartanDet /
      ((D.coxeter : ℝ) * D.weylOrder)) * D.gammaQuotient

/-- A one-sided real formulation of a leading residue at `s₀`.
It says `(s-s₀)f(s)` tends to `R` as `s` approaches `s₀` from the right. -/
def HasLeadingResidueAt (f : ℝ → ℝ) (s₀ R : ℝ) : Prop :=
  Tendsto (fun s ↦ (s - s₀) * f s) (𝓝[>] s₀) (𝓝 R)

/-- Every gamma argument in the universal quotient is positive. -/
theorem proper_gamma_arguments_pos (D : RootInvariants) (i : Fin (D.rank - 1)) :
    0 < 1 - (D.properDegrees i : ℝ) / D.coxeter := by
  have h1 : (D.properDegrees i : ℝ) < D.coxeter := Nat.cast_lt.mpr (D.properDegrees_lt i)
  have h2 : (0 : ℝ) < D.coxeter := Nat.cast_pos.mpr (lt_trans zero_lt_one D.coxeter_gt_one)
  linarith [div_lt_one h2 |>.mpr h1]

/-- The denominator gamma argument is positive. -/
theorem coxeter_gamma_argument_pos (D : RootInvariants) :
    0 < 1 - 1 / (D.coxeter : ℝ) := by
  have h : (1 : ℝ) < D.coxeter := mod_cast D.coxeter_gt_one
  have hp : (0 : ℝ) < D.coxeter := by linarith
  rw [sub_pos, div_lt_one hp]
  exact h

/-- The universal gamma quotient is strictly positive. -/
theorem gammaQuotient_pos (D : RootInvariants) : 0 < D.gammaQuotient := by
  unfold RootInvariants.gammaQuotient
  apply div_pos
  · apply Finset.prod_pos
    intro i _
    exact Real.Gamma_pos_of_pos (proper_gamma_arguments_pos D i)
  · exact pow_pos (Real.Gamma_pos_of_pos (coxeter_gamma_argument_pos D)) _

/-- The universal leading residue is strictly positive, hence in particular nonzero. -/
theorem universalLeadingResidue_pos (D : RootInvariants) :
    0 < D.universalLeadingResidue := by
  have gammaQuotient_pos : 0 < D.gammaQuotient := by
    unfold RootInvariants.gammaQuotient
    apply div_pos
    · apply Finset.prod_pos
      intro i _
      exact Real.Gamma_pos_of_pos (proper_gamma_arguments_pos D i)
    · apply pow_pos
      exact Real.Gamma_pos_of_pos (coxeter_gamma_argument_pos D)
  unfold RootInvariants.universalLeadingResidue
  apply mul_pos
  · apply div_pos
    · apply mul_pos
      · apply mul_pos
        · norm_num
        · exact Real.rpow_pos_of_pos (mul_pos two_pos Real.pi_pos) _
      · exact Real.sqrt_pos.mpr (Nat.cast_pos.mpr D.cartanDet_pos)
    · exact mul_pos (Nat.cast_pos.mpr (lt_trans zero_lt_one D.coxeter_gt_one))
        (Nat.cast_pos.mpr D.weylOrder_pos)
  · exact gammaQuotient_pos

/-- Multiplying a Dirichlet series by the analytic normalization `K^s` multiplies its leading
residue by `K^s₀`.  This is equation (5) of the paper at the level of local limits. -/
theorem hasLeadingResidueAt_rpow_mul {f : ℝ → ℝ} {s₀ R K : ℝ} (hK : 0 < K)
    (hf : HasLeadingResidueAt f s₀ R) :
    HasLeadingResidueAt (fun s ↦ K ^ s * f s) s₀ (K ^ s₀ * R) := by
  unfold HasLeadingResidueAt at *
  have h1 : Tendsto (fun s => (K : ℝ) ^ s) (𝓝 s₀) (𝓝 (K ^ s₀)) := by
    exact Real.continuous_const_rpow hK.ne' |>.continuousAt
  have h2 : Tendsto (fun s => (K : ℝ) ^ s * ((s - s₀) * f s)) (𝓝[>] s₀) (𝓝 (K ^ s₀ * R)) := by
    exact Tendsto.mul (h1.mono_left nhdsWithin_le_nhds) hf
  convert h2 using 1
  all_goals funext s; ring

/-- If `ξ(s) = K⁻ˢ ζ(s)`, then a leading residue formula for `ξ` gives the corresponding formula
for the ordinary Witten zeta function `ζ`. -/
theorem ordinary_residue_from_normalized {ξ ζ : ℝ → ℝ} {s₀ R K : ℝ} (hK : 0 < K)
    (hnorm : ∀ s, ζ s = K ^ s * ξ s) (hξ : HasLeadingResidueAt ξ s₀ R) :
    HasLeadingResidueAt ζ s₀ (K ^ s₀ * R) := by
  have hzeta_eq : ζ = fun s => K ^ s * ξ s := funext hnorm
  rw [hzeta_eq]
  exact hasLeadingResidueAt_rpow_mul hK hξ

/-- The direct counting constant is `h/2` times the ordinary leading residue. -/
noncomputable def RootInvariants.countingConstant (D : RootInvariants) (K : ℝ) : ℝ :=
  ((D.coxeter : ℝ) / 2) * (K ^ D.criticalExponent * D.universalLeadingResidue)

/-- The paper's two descriptions of the counting constant agree. -/
theorem countingConstant_eq_half_coxeter_mul (D : RootInvariants) (K Rζ : ℝ)
    (hRζ : Rζ = K ^ D.criticalExponent * D.universalLeadingResidue) :
    D.countingConstant K = (D.coxeter : ℝ) / 2 * Rζ := by
  simp [RootInvariants.countingConstant, hRζ]

/-- Algebraic identity behind the strict-subcritical calculation for proper parabolic strata.
The variables `componentRank` and `componentCoxeter` encode the irreducible components of a
proper parabolic subsystem. -/
theorem parabolic_defect_identity {ι : Type*} [Fintype ι]
    (rank coxeter : ℝ) (componentRank componentCoxeter : ι → ℝ) (hcoxeter : coxeter ≠ 0) :
    (2 / coxeter) *
          (rank * coxeter / 2 - ∑ a, componentRank a * componentCoxeter a / 2) -
        (rank - ∑ a, componentRank a) =
      ∑ a, componentRank a * (1 - componentCoxeter a / coxeter) := by
  field_simp
  simp (config := { decide := true }) [mul_comm coxeter, Finset.sum_mul, mul_sub]
  field_simp
  ring_nf
  simp [mul_comm, Finset.mul_sum]
  simp [mul_assoc, mul_comm (2 : ℝ)]

/-- Proper parabolic components have a strictly positive total defect whenever at least one
component has positive rank.  This is the strict inequality used to control boundary faces. -/
theorem parabolic_defect_pos {ι : Type*} [Fintype ι] [Nonempty ι]
    (coxeter : ℝ) (componentRank componentCoxeter : ι → ℝ)
    (hRank : ∀ a, 0 < componentRank a)
    (hCoxeter : ∀ a, componentCoxeter a < coxeter)
    (hcoxeter : 0 < coxeter) :
    0 < ∑ a, componentRank a * (1 - componentCoxeter a / coxeter) := by
  apply Finset.sum_pos
  · intro a _
    apply mul_pos (hRank a)
    exact sub_pos.mpr (by rw [div_lt_one hcoxeter]; exact hCoxeter a)
  · exact Finset.univ_nonempty

/-- The metric factors cancel: if the Gram determinant contributes
`√det(C) · ∏ℓᵢ` and the discriminant scaling contributes `∏ℓᵢ`, their quotient is `√det(C)`.
This is the algebraic content of equations (17)--(19) in the paper. -/
theorem metric_factor_cancellation {cartanSqrt lengthProduct gramSqrt discriminantScale : ℝ}
    (hLengths : 0 < lengthProduct)
    (hGram : gramSqrt = cartanSqrt * lengthProduct)
    (hScale : discriminantScale = lengthProduct) :
    discriminantScale⁻¹ / gramSqrt⁻¹ = cartanSqrt := by
  rw [hScale, hGram]
  field_simp [hLengths.ne']

/-- The universal formula is invariant under root-system duality once the standard duality
invariants (rank, Coxeter number, degrees, Weyl order, and Cartan determinant) are identified. -/
theorem universalLeadingResidue_dual
    (D E : RootInvariants)
    (hrank : D.rank = E.rank)
    (hcoxeter : D.coxeter = E.coxeter)
    (hdegrees : HEq D.properDegrees E.properDegrees)
    (hweyl : D.weylOrder = E.weylOrder)
    (hdet : D.cartanDet = E.cartanDet) :
    D.universalLeadingResidue = E.universalLeadingResidue := by
  rcases D with ⟨rank, rank_pos, coxeter, coxeter_gt_one, degrees,
    degrees_pos, degrees_lt, weylOrder, weylOrder_pos, cartanDet, cartanDet_pos⟩
  rcases E with ⟨rank', rank_pos', coxeter', coxeter_gt_one', degrees',
    degrees_pos', degrees_lt', weylOrder', weylOrder_pos', cartanDet', cartanDet_pos'⟩
  dsimp at hrank hcoxeter hdegrees hweyl hdet ⊢
  subst rank'
  subst coxeter'
  subst weylOrder'
  subst cartanDet'
  have hdegrees' : degrees = degrees' := eq_of_heq hdegrees
  subst degrees'
  rfl

end WittenZeta