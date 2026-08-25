import Mathlib
import Computation.SpectralUnfoldingGapStatistics
import Computation.SpectralPoissonVsGUE

/-!
# Quantitative separation: Kolmogorov–Smirnov distances from the rigid spectrum

The qualitative statement "the unfolded quadratic spectrum is neither Poisson nor GUE"
is upgraded here to an *explicit, `n`-independent* lower bound on the Kolmogorov–Smirnov
distance between the empirical spacing distribution of the unfolded quadratic spectrum
and each of the two universality classes:

* `picket_vs_poisson_KS` : the KS distance to the Poisson law is at least `1/3`;
* `picket_vs_gue_KS` : the KS distance to the GUE (Wigner surmise) law is at least
  `1/12`.

Both are witnessed at the single spacing threshold `t = 1/2`, where the rigid spectrum
has *no* gaps while both universality classes have a definite positive probability of a
spacing below `1/2`.  The GUE bound needs a quantitative lower bound for the Wigner
surmise CDF, `gue_cdf_half_lower_bound`, obtained by monotonicity of the Gaussian factor
on `[0, 1/2]`.
-/

namespace Catalog.Computation.SpectralKS

open Catalog.Computation.SpectralUnfolding Catalog.Computation.SpectralPoissonGUE
open Real MeasureTheory Set
open scoped Topology

/-- The Poisson spacing CDF. -/
noncomputable def poissonGapCDF (t : ℝ) : ℝ := 1 - Real.exp (-t)

/-- The GUE (Wigner surmise) spacing CDF. -/
noncomputable def gueGapCDF (t : ℝ) : ℝ := ∫ s in Ioc (0 : ℝ) t, gueGapPdf s

lemma poissonGapCDF_eq (t : ℝ) (ht : 0 ≤ t) :
    ∫ s in Ioc (0 : ℝ) t, poissonGapPdf s = poissonGapCDF t := poisson_cdf_eq t ht

/-- At threshold `1/2` the Poisson law already assigns probability at least `1/3` to a
spacing below `1/2`. -/
lemma poissonGapCDF_half_lower_bound : (1 : ℝ) / 3 ≤ poissonGapCDF (1 / 2) := by
  have h : (1 : ℝ) + 1 / 2 ≤ Real.exp (1 / 2) := by
    have := Real.add_one_le_exp (1 / 2 : ℝ)
    linarith
  have hpos : (0 : ℝ) < Real.exp (1 / 2) := Real.exp_pos _
  have hinv : Real.exp (-(1 / 2 : ℝ)) ≤ 2 / 3 := by
    rw [Real.exp_neg, inv_le_comm₀ hpos (by norm_num)]
    linarith
  rw [poissonGapCDF]
  linarith

/-- A quantitative lower bound for the Wigner-surmise CDF at `1/2`, obtained by bounding
the Gaussian factor below by its value at the right endpoint. -/
lemma gue_cdf_half_lower_bound :
    (4 / (3 * π ^ 2)) * Real.exp (-(1 / π)) ≤ gueGapCDF (1 / 2) := by
  have hpi : 0 < π := Real.pi_pos
  have hcont : Continuous gueGapPdf := by
    unfold gueGapPdf
    fun_prop
  have hmono : ∀ s ∈ Set.Icc (0 : ℝ) (1 / 2),
      (32 / π ^ 2 * Real.exp (-(1 / π))) * s ^ 2 ≤ gueGapPdf s := by
    intro s hs
    obtain ⟨hs0, hs1⟩ := hs
    have hexp : Real.exp (-(1 / π)) ≤ Real.exp (-(4 / π) * s ^ 2) := by
      apply Real.exp_le_exp.mpr
      have hs2 : s ^ 2 ≤ 1 / 4 := by nlinarith
      have hb : (4 / π) * s ^ 2 ≤ (4 / π) * (1 / 4) :=
        mul_le_mul_of_nonneg_left hs2 (by positivity)
      have h4 : (4 / π) * (1 / 4) = 1 / π := by field_simp
      have hrw : -(4 / π) * s ^ 2 = -((4 / π) * s ^ 2) := by ring
      rw [hrw]
      linarith
    rw [gueGapPdf]
    have hcoef : (0 : ℝ) ≤ 32 / π ^ 2 * s ^ 2 := by positivity
    nlinarith [hexp, hcoef]
  have hint1 : IntervalIntegrable (fun s : ℝ => (32 / π ^ 2 * Real.exp (-(1 / π))) * s ^ 2)
      volume 0 (1 / 2) := (by fun_prop : Continuous _).intervalIntegrable _ _
  have hint2 : IntervalIntegrable gueGapPdf volume 0 (1 / 2) := hcont.intervalIntegrable _ _
  have hle := intervalIntegral.integral_mono_on (by norm_num : (0 : ℝ) ≤ 1 / 2)
    hint1 hint2 hmono
  have hcalc : ∫ s in (0 : ℝ)..(1 / 2), (32 / π ^ 2 * Real.exp (-(1 / π))) * s ^ 2
      = (4 / (3 * π ^ 2)) * Real.exp (-(1 / π)) := by
    rw [intervalIntegral.integral_const_mul, integral_pow]
    field_simp
    ring
  rw [gueGapCDF, ← intervalIntegral.integral_of_le (by norm_num : (0 : ℝ) ≤ 1 / 2)]
  rw [← hcalc]
  exact hle

/-- The numerical form of the previous bound: the GUE law assigns probability at least
`1/12` to a spacing below `1/2`. -/
lemma gueGapCDF_half_ge : (1 : ℝ) / 12 ≤ gueGapCDF (1 / 2) := by
  have hpi1 : (3.14 : ℝ) < π := Real.pi_gt_d2
  have hpi2 : π < 3.15 := Real.pi_lt_d2
  have hexp : (1 : ℝ) - 1 / π ≤ Real.exp (-(1 / π)) := by
    have := Real.add_one_le_exp (-(1 / π))
    linarith
  have hπinv : 1 / π ≤ 1 / 3 := by
    rw [div_le_div_iff₀ (by linarith) (by norm_num)]
    linarith
  have hlow : (1 : ℝ) / 12 ≤ (4 / (3 * π ^ 2)) * Real.exp (-(1 / π)) := by
    have h1 : (2 : ℝ) / 3 ≤ Real.exp (-(1 / π)) := by linarith
    have h2 : (4 : ℝ) / (3 * π ^ 2) ≥ 4 / (3 * 3.15 ^ 2) := by
      apply div_le_div_of_nonneg_left (by norm_num) (by positivity)
      nlinarith
    nlinarith [h1, h2, Real.exp_pos (-(1 / π))]
  linarith [gue_cdf_half_lower_bound]

/-- **Quantitative non-Poisson-ness.**  For every window size the empirical spacing
distribution of the unfolded quadratic spectrum is at Kolmogorov–Smirnov distance at
least `1/3` from the Poisson law. -/
theorem picket_vs_poisson_KS (n : ℕ) (hn : 0 < n) :
    (1 : ℝ) / 3 ≤ |gapCDF unfoldedQuad n (1 / 2) - poissonGapCDF (1 / 2)| := by
  rw [unfoldedQuad_gapCDF_eq_zero n hn (1 / 2) (by norm_num), zero_sub, abs_neg]
  have hle : poissonGapCDF (1 / 2) ≤ 1 := by
    rw [poissonGapCDF]
    have := Real.exp_pos (-(1 / 2 : ℝ))
    linarith
  rw [abs_of_nonneg (by linarith [poissonGapCDF_half_lower_bound])]
  exact poissonGapCDF_half_lower_bound

/-- **Quantitative non-GUE-ness.**  For every window size the empirical spacing
distribution of the unfolded quadratic spectrum is at Kolmogorov–Smirnov distance at
least `1/12` from the GUE (Wigner surmise) law. -/
theorem picket_vs_gue_KS (n : ℕ) (hn : 0 < n) :
    (1 : ℝ) / 12 ≤ |gapCDF unfoldedQuad n (1 / 2) - gueGapCDF (1 / 2)| := by
  rw [unfoldedQuad_gapCDF_eq_zero n hn (1 / 2) (by norm_num), zero_sub, abs_neg]
  rw [abs_of_nonneg (by linarith [gueGapCDF_half_ge])]
  exact gueGapCDF_half_ge

end Catalog.Computation.SpectralKS