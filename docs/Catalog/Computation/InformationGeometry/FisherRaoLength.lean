import Mathlib
import Bridges.InformationGeometry.FisherMetric
import Computation.InformationGeometry.FisherInnerProduct

/-!
# The Fisher–Rao length of a path dominates the `L¹` distance of its endpoints

`Computation/InformationGeometry/FisherInnerProduct.lean` proves the pointwise
Cauchy–Schwarz bound `(∑ i, |v i|)² ≤ fisherForm p v v` for a probability vector
`p`.  This file integrates it: under explicit regularity hypotheses, for every
path `γ` in the open probability simplex with velocity `γ'`,

`∑ i, |γ 1 i − γ 0 i| ≤ ∫₀¹ √(fisherForm (γ t) (γ' t) (γ' t)) dt`,

that is, the Fisher–Rao length of the path is at least the `L¹` distance between
its endpoints (`InformationGeometry.l1_le_fisherRao_length`).

The regularity hypotheses are stated explicitly rather than being derived from a
smoothness assumption: differentiability of each coordinate on `[0,1]`,
interval integrability of the velocity coordinates and of the Fisher speed, and
membership of the path in the open simplex on `[0,1]`.
-/

noncomputable section

open Finset MeasureTheory

namespace InformationGeometry

variable {ι : Type*} [Fintype ι]

/-- The Fisher speed of a path at time `t`. -/
def fisherSpeed (γ γ' : ℝ → ι → ℝ) (t : ℝ) : ℝ :=
  Real.sqrt (fisherForm (γ t) (γ' t) (γ' t))

/-- The pointwise (infinitesimal) form of the bound: at a point of the simplex,
the `L¹` norm of a tangent vector is at most its Fisher length. -/
theorem l1_le_sqrt_fisherForm (p v : ι → ℝ) (hp : ∀ i, 0 < p i) (hps : ∑ i, p i = 1) :
    ∑ i, |v i| ≤ Real.sqrt (fisherForm p v v) := by
  have hnn : 0 ≤ ∑ i, |v i| := Finset.sum_nonneg fun i _ => abs_nonneg _
  have hsq := l1_sq_le_fisherForm p v hp hps
  exact (Real.le_sqrt hnn (fisherForm_nonneg p v hp)).mpr hsq

/-- **The Fisher–Rao length bound.**  For a path `γ` lying in the open
probability simplex on `[0,1]` with velocity `γ'`, the `L¹` distance between the
endpoints is at most the Fisher–Rao length of the path. -/
theorem l1_le_fisherRao_length (γ γ' : ℝ → ι → ℝ)
    (hderiv : ∀ i, ∀ t ∈ Set.Icc (0 : ℝ) 1, HasDerivAt (fun s => γ s i) (γ' t i) t)
    (hint : ∀ i, IntervalIntegrable (fun t => γ' t i) volume 0 1)
    (hspeed : IntervalIntegrable (fisherSpeed γ γ') volume 0 1)
    (hpos : ∀ t ∈ Set.Icc (0 : ℝ) 1, ∀ i, 0 < γ t i)
    (hsum : ∀ t ∈ Set.Icc (0 : ℝ) 1, ∑ i, γ t i = 1) :
    ∑ i, |γ 1 i - γ 0 i| ≤ ∫ t in (0 : ℝ)..1, fisherSpeed γ γ' t := by
  have h01 : (0 : ℝ) ≤ 1 := by norm_num
  have huIcc : Set.uIcc (0 : ℝ) 1 = Set.Icc 0 1 := Set.uIcc_of_le h01
  -- Fundamental theorem of calculus on each coordinate.
  have hftc : ∀ i, ∫ t in (0 : ℝ)..1, γ' t i = γ 1 i - γ 0 i := by
    intro i
    refine intervalIntegral.integral_eq_sub_of_hasDerivAt (f := fun s => γ s i)
      (fun x hx => ?_) (hint i)
    exact hderiv i x (huIcc ▸ hx)
  -- Coordinatewise: `|Δ| ≤ ∫ |γ'|`.
  have hcoord : ∀ i, |γ 1 i - γ 0 i| ≤ ∫ t in (0 : ℝ)..1, |γ' t i| := by
    intro i
    rw [← hftc i]
    exact intervalIntegral.abs_integral_le_integral_abs h01
  have habsint : ∀ i, IntervalIntegrable (fun t => |γ' t i|) volume 0 1 :=
    fun i => (hint i).abs
  have hsumint : IntervalIntegrable (fun t => ∑ i, |γ' t i|) volume 0 1 := by
    have hs := IntervalIntegrable.sum (μ := volume) (a := 0) (b := 1)
      (Finset.univ : Finset ι) (f := fun i t => |γ' t i|) fun i _ => habsint i
    have heq : (∑ i : ι, fun t => |γ' t i|) = fun t => ∑ i, |γ' t i| := by
      funext t
      simp [Finset.sum_apply]
    rwa [heq] at hs
  -- Sum the coordinate bounds and exchange sum and integral.
  have hstep1 : ∑ i, |γ 1 i - γ 0 i| ≤ ∫ t in (0 : ℝ)..1, ∑ i, |γ' t i| := by
    rw [intervalIntegral.integral_finset_sum (fun i _ => habsint i)]
    exact Finset.sum_le_sum fun i _ => hcoord i
  -- Compare with the Fisher speed pointwise.
  have hstep2 : (∫ t in (0 : ℝ)..1, ∑ i, |γ' t i|)
      ≤ ∫ t in (0 : ℝ)..1, fisherSpeed γ γ' t := by
    refine intervalIntegral.integral_mono_on h01 hsumint hspeed fun t ht => ?_
    exact l1_le_sqrt_fisherForm (γ t) (γ' t) (hpos t ht) (hsum t ht)
  exact hstep1.trans hstep2

/-- Reformulation in terms of the Fisher norm of the tangent space: if the path
`γ` passes through the points of the open simplex `p t` with velocity given by
tangent vectors `v t`, its Fisher–Rao length dominates the endpoint `L¹`
distance.  Here the speed is `‖v t‖` for the inner-product norm of
`FisherTangent (p t)`. -/
theorem l1_le_fisherRao_length_norm (γ γ' : ℝ → ι → ℝ)
    (P : ℝ → OpenSimplex ι) (V : ∀ t, FisherTangent (P t))
    (hP : ∀ t, (P t).prob = γ t) (hV : ∀ t, (V t).vec = γ' t)
    (hderiv : ∀ i, ∀ t ∈ Set.Icc (0 : ℝ) 1, HasDerivAt (fun s => γ s i) (γ' t i) t)
    (hint : ∀ i, IntervalIntegrable (fun t => γ' t i) volume 0 1)
    (hspeed : IntervalIntegrable (fun t => ‖V t‖) volume 0 1) :
    ∑ i, |γ 1 i - γ 0 i| ≤ ∫ t in (0 : ℝ)..1, ‖V t‖ := by
  have hnorm : ∀ t, ‖V t‖ = fisherSpeed γ γ' t := by
    intro t
    rw [norm_fisherTangent, fisherSpeed, hP t, hV t]
  have hspeed' : IntervalIntegrable (fisherSpeed γ γ') volume 0 1 := by
    simpa [funext hnorm] using hspeed
  have hpos : ∀ t ∈ Set.Icc (0 : ℝ) 1, ∀ i, 0 < γ t i := by
    intro t _ i
    have := (P t).prob_pos i
    rwa [hP t] at this
  have hsum : ∀ t ∈ Set.Icc (0 : ℝ) 1, ∑ i, γ t i = 1 := by
    intro t _
    have := (P t).prob_sum
    rwa [hP t] at this
  have := l1_le_fisherRao_length γ γ' hderiv hint hspeed' hpos hsum
  rwa [intervalIntegral.integral_congr (g := fisherSpeed γ γ') fun t _ => hnorm t]

end InformationGeometry

end