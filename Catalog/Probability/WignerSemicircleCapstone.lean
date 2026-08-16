/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Capstone corollaries of the Wigner semicircle development

This file collects the consequences of the exact mean/variance computations of
`Probability.WignerSecondMomentConcentration` in the three forms in which the
semicircle law is usually stated:

* a **quantitative finite-`N` Chebyshev rate** for the deviation of the second
  spectral moment (`gprob_secondMoment_deviation_le`);
* **`L²` convergence** of the second spectral moment to the semicircle value
  `C₁ = 1` (`tendsto_L2_secondMoment`);
* the **eigenvalue-level** restatement, i.e. the statement about the empirical
  spectral distribution itself rather than about traces
  (`gexpect_eigenvalue_secondMoment`).

We also record the Rademacher ensemble as an explicit instance of the universal
convergence-in-probability theorem.
-/
import Probability.WignerOddMoments

open Matrix BigOperators Finset Filter Topology
open scoped Classical

namespace WignerUniversal

variable {S : Type*} [Fintype S] {N : ℕ}

/-! ### A quantitative finite-dimensional deviation bound -/

/-- **Explicit Chebyshev rate.**  At every finite `N` and every threshold `t > 0`,
the probability that the second spectral moment deviates from its exact mean
`1 - 1/N` by at least `t` is at most `2(m₄-1)(N-1) / (N³ t²)`: the deviation
probability decays like `N⁻²`. -/
theorem gprob_secondMoment_deviation_le (L : EntryLaw S) (N : ℕ) (hN : 0 < N)
    (t : ℝ) (ht : 0 < t) :
    gprob L (Finset.univ.filter (fun ω : Conf N S =>
        t ≤ |WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ))|))
      ≤ 2 * (L.m4 - 1) * ((N : ℝ) - 1) / ((N : ℝ) ^ 3 * t ^ 2) := by
  have hcheb := chebyshev L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) 2)
    (1 - 1 / (N : ℝ)) t ht
  rw [variance_normalizedMoment_two L N hN] at hcheb
  have hmain : gprob L (Finset.univ.filter (fun ω : Conf N S =>
      t ≤ |WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ))|))
      ≤ (2 * (L.m4 - 1) * ((N : ℝ) - 1) / (N : ℝ) ^ 3) / t ^ 2 :=
    (le_div_iff₀ (pow_pos ht 2)).2 (by rw [mul_comm]; exact hcheb)
  rwa [div_div] at hmain

/-! ### `L²` convergence of the second spectral moment -/

/-- The exact mean-square error of the second spectral moment about the semicircle
value `1`: it is the variance plus the squared bias `1/N²`. -/
theorem gexpect_secondMoment_mse (L : EntryLaw S) (N : ℕ) (hN : 0 < N) :
    gexpect L (fun ω : Conf N S =>
        (WignerBridge.normalizedMoment (GW L ω) 2 - 1) ^ 2)
      = 2 * (L.m4 - 1) * ((N : ℝ) - 1) / (N : ℝ) ^ 3 + (1 / (N : ℝ)) ^ 2 := by
  have hrw : ∀ ω : Conf N S,
      (WignerBridge.normalizedMoment (GW L ω) 2 - 1) ^ 2
        = (WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ))) ^ 2
          + ((-2 / (N : ℝ)) * (WignerBridge.normalizedMoment (GW L ω) 2 - (1 - 1 / (N : ℝ)))
            + (1 / (N : ℝ)) ^ 2) := by
    intro ω; ring
  simp only [hrw]
  rw [gexpect_add, gexpect_add, gexpect_const_mul, gexpect_const,
    variance_normalizedMoment_two L N hN,
    gexpect_sub L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) 2)
      (fun _ => 1 - 1 / (N : ℝ)),
    gexpect_normalizedMoment_two L N hN, gexpect_const]
  ring

/-- **`L²` convergence.**  The second moment of the empirical spectral distribution
of `W/√N` converges to the semicircle second moment `C₁ = 1` in mean square. -/
theorem tendsto_L2_secondMoment (L : EntryLaw S) :
    Tendsto (fun N : ℕ => gexpect L (fun ω : Conf N S =>
        (WignerBridge.normalizedMoment (GW L ω) 2
          - WignerSemicircle.semicircleMoment 2) ^ 2)) atTop (𝓝 0) := by
  have hlim : Tendsto (fun N : ℕ =>
      2 * (L.m4 - 1) * ((1 / (N : ℝ)) ^ 2 - (1 / (N : ℝ)) ^ 3)
        + (1 / (N : ℝ)) ^ 2) atTop (𝓝 0) := by
    have h : Tendsto (fun N : ℕ => (1 : ℝ) / (N : ℝ)) atTop (𝓝 0) :=
      tendsto_one_div_atTop_nhds_zero_nat
    have h2 := ((tendsto_const_nhds (x := 2 * (L.m4 - 1))).mul
      ((h.pow 2).sub (h.pow 3))).add (h.pow 2)
    simpa using h2
  refine hlim.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with N hN
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  rw [WignerSemicircle.semicircleMoment_two, gexpect_secondMoment_mse L N hN]
  field_simp

/-! ### The eigenvalue-level statement -/

/-- The statement at the level of the empirical spectral distribution: the expected
average of `(λᵢ/√N)²` over the spectrum equals `1 - 1/N` exactly. -/
theorem gexpect_eigenvalue_secondMoment (L : EntryLaw S) (N : ℕ) (hN : 0 < N) :
    gexpect L (fun ω : Conf N S =>
        (1 / (N : ℝ)) *
          ∑ i, ((GW_isHermitian L ω).eigenvalues i / Real.sqrt (N : ℝ)) ^ 2)
      = 1 - 1 / (N : ℝ) := by
  have hrw : ∀ ω : Conf N S,
      (1 / (N : ℝ)) * ∑ i, ((GW_isHermitian L ω).eigenvalues i / Real.sqrt (N : ℝ)) ^ 2
        = WignerBridge.normalizedMoment (GW L ω) 2 := by
    intro ω
    rw [WignerBridge.normalizedMoment_eq_sum_eigenvalues (GW_isHermitian L ω) 2]
    simp
  simp only [hrw]
  exact gexpect_normalizedMoment_two L N hN

/-! ### The Rademacher ensemble as an instance -/

/-- The symmetric sign ensemble satisfies the second-moment semicircle law in
probability, with the universal constant `m₄ = 1`. -/
theorem tendsto_gprob_secondMoment_deviation_rademacher (eps : ℝ) (heps : 0 < eps) :
    Tendsto (fun N : ℕ => gprob rademacherLaw (Finset.univ.filter (fun ω : Conf N Bool =>
        eps ≤ |WignerBridge.normalizedMoment (GW rademacherLaw ω) 2
          - WignerSemicircle.semicircleMoment 2|)))
      atTop (𝓝 0) :=
  tendsto_gprob_secondMoment_deviation rademacherLaw eps heps

/-- For the Rademacher ensemble the variance of the second spectral moment vanishes
identically: the second moment is perfectly self-averaging (`m₄ = 1`). -/
theorem variance_normalizedMoment_two_rademacher (N : ℕ) (hN : 0 < N) :
    gexpect rademacherLaw (fun ω : Conf N Bool =>
        (WignerBridge.normalizedMoment (GW rademacherLaw ω) 2 - (1 - 1 / (N : ℝ))) ^ 2) = 0 := by
  rw [variance_normalizedMoment_two rademacherLaw N hN, rademacherLaw_m4]
  ring

/-! ### A deterministic spectral-edge lower bound -/

/-- **Every** realisation of the Rademacher sign ensemble has a rescaled eigenvalue
of square at least `1 - 1/N`; there is no exceptional configuration.  This is a
deterministic consequence of the exact self-averaging second moment: the spectral
radius of `W/√N` is at least `√(1 - 1/N)`, so in the limit the spectrum always
reaches out to distance at least `1` from the origin. -/
theorem exists_large_eigenvalue_rademacher (g : RademacherWigner.Config N) (hN : 0 < N) :
    ∃ i, 1 - 1 / (N : ℝ) ≤
      ((RademacherWigner.W_isHermitian g).eigenvalues i / Real.sqrt (N : ℝ)) ^ 2 := by
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hsum : ∑ i, ((RademacherWigner.W_isHermitian g).eigenvalues i / Real.sqrt (N : ℝ)) ^ 2
      = (N : ℝ) * (1 - 1 / (N : ℝ)) := by
    have h := RademacherWigner.esd_secondMoment g hN
    rw [← h]
    field_simp
  have hne : (Finset.univ : Finset (Fin N)).Nonempty := by
    rw [Finset.univ_nonempty_iff]
    exact ⟨⟨0, hN⟩⟩
  have hle : ∑ _i : Fin N, (1 - 1 / (N : ℝ))
      ≤ ∑ i, ((RademacherWigner.W_isHermitian g).eigenvalues i / Real.sqrt (N : ℝ)) ^ 2 := by
    rw [hsum, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  obtain ⟨i, -, hi⟩ := Finset.exists_le_of_sum_le hne hle
  exact ⟨i, hi⟩

end WignerUniversal