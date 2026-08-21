/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Consequences of the walk counts for the normalised spectral moments

The combinatorics of `Combinatorics.EvenWalkPolynomial` pays off analytically:

* `expect_normalizedMoment_even_le`: **every** even normalised moment of the
  symmetric Rademacher ensemble is bounded, at every finite `N`, by a purely
  combinatorial constant — the total number of even closed walk shapes of that
  length.  This is the tightness half of the semicircle law, and it holds at all
  orders (previously only orders `2` and `4` were available).
* `expect_normalizedMoment_six` and `tendsto_expected_sixthMoment`: the expected
  sixth normalised moment equals `(N-1)(5N² - 15N + 11)/N³` exactly, and converges
  to the sixth moment `C₃ = 5` of the semicircle law.  Together with
  `RademacherWigner.expect_normalizedMoment_odd` this extends the moment-method
  verification of the semicircle law from order four to order six.
-/
import Combinatorics.EvenWalkPolynomial

open Matrix BigOperators Filter Topology Finset EvenWalks

namespace RademacherWigner

variable {N : ℕ}

/-- **Uniform bound on all even normalised moments.**  For every `k` and every `N`,
the expected `(2k+2)`-nd normalised spectral moment is at most the number of even
closed walk shapes of length `2k+2`, a constant independent of `N`. -/
theorem expect_normalizedMoment_even_le (N k : ℕ) (hN : 0 < N) :
    expect (fun g : Config N => WignerBridge.normalizedMoment (W g) (2 * k + 2))
      ≤ ((∑ r ∈ Finset.range (k + 3), surjEvenWalkCount r (2 * k + 2) : ℕ) : ℝ) := by
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hpow : (Real.sqrt (N : ℝ))⁻¹ ^ (2 * k + 2) = ((N : ℝ)⁻¹) ^ (k + 1) := by
    rw [show 2 * k + 2 = 2 * (k + 1) by ring, pow_mul, sqrt_inv_sq]
  have hrw : ∀ g : Config N, WignerBridge.normalizedMoment (W g) (2 * k + 2)
      = (1 / (N : ℝ) * ((N : ℝ)⁻¹) ^ (k + 1)) * ((W g) ^ (2 * k + 2)).trace := by
    intro g
    rw [WignerBridge.normalizedMoment_eq, card_fin_config, hpow]
  simp only [hrw]
  rw [expect_const_mul]
  have htr : expect (fun g : Config N => ((W g) ^ (2 * k + 2)).trace)
      = (evenClosedWalkCount N (2 * k + 2) : ℝ) :=
    expect_trace_pow_eq_evenClosedWalkCount (N := N) (2 * k + 1)
  rw [htr]
  have hconst : (1 / (N : ℝ) * ((N : ℝ)⁻¹) ^ (k + 1)) = ((N : ℝ) ^ (k + 2))⁻¹ := by
    rw [inv_pow, one_div, ← mul_inv]
    congr 1
    ring
  rw [hconst, inv_mul_eq_div, div_le_iff₀ (by positivity)]
  exact_mod_cast evenClosedWalkCount_le N k

/-- **Expected normalised sixth spectral moment**, exactly:
`(N-1)(5N² - 15N + 11)/N³`. -/
theorem expect_normalizedMoment_six (N : ℕ) (hN : 0 < N) :
    expect (fun g : Config N => WignerBridge.normalizedMoment (W g) 6)
      = ((N : ℝ) - 1) * (5 * (N : ℝ) ^ 2 - 15 * (N : ℝ) + 11) / (N : ℝ) ^ 3 := by
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  have hpow : (Real.sqrt (N : ℝ))⁻¹ ^ 6 = ((N : ℝ)⁻¹) ^ 3 := by
    rw [show (6 : ℕ) = 2 * 3 from rfl, pow_mul, sqrt_inv_sq]
  have hrw : ∀ g : Config N, WignerBridge.normalizedMoment (W g) 6
      = (1 / (N : ℝ) * ((N : ℝ)⁻¹) ^ 3) * ((W g) ^ 6).trace := by
    intro g
    rw [WignerBridge.normalizedMoment_eq, card_fin_config, hpow]
  simp only [hrw]
  rw [expect_const_mul, expect_trace_W_six]
  field_simp

/-- **Semicircle law, order six (in expectation).**  The expected sixth moment of the
empirical spectral distribution of `W/√N` converges to the sixth moment `C₃ = 5` of
the semicircle law. -/
theorem tendsto_expected_sixthMoment :
    Tendsto (fun N : ℕ => expect (fun g : Config N => WignerBridge.normalizedMoment (W g) 6))
      atTop (𝓝 (WignerSemicircle.semicircleMoment 6)) := by
  have hsc : WignerSemicircle.semicircleMoment 6 = 5 := by
    have h := WignerSemicircle.semicircleMoment_two_mul 3
    rw [show 2 * 3 = 6 from rfl, catalan_three] at h
    rw [h]
    norm_num
  rw [hsc]
  have hlim : Tendsto
      (fun N : ℕ => 5 - 20 * (1 / (N : ℝ)) + 26 * (1 / (N : ℝ)) ^ 2 - 11 * (1 / (N : ℝ)) ^ 3)
      atTop (𝓝 5) := by
    have h : Tendsto (fun N : ℕ => (1 : ℝ) / (N : ℝ)) atTop (𝓝 0) :=
      tendsto_one_div_atTop_nhds_zero_nat
    have h2 : Tendsto
        (fun N : ℕ => (5 : ℝ) - 20 * (1 / (N : ℝ)) + 26 * (1 / (N : ℝ)) ^ 2
          - 11 * (1 / (N : ℝ)) ^ 3) atTop
        (𝓝 (5 - 20 * 0 + 26 * 0 ^ 2 - 11 * 0 ^ 3)) :=
      (((tendsto_const_nhds.sub (tendsto_const_nhds.mul h)).add
        (tendsto_const_nhds.mul (h.pow 2))).sub (tendsto_const_nhds.mul (h.pow 3)))
    simpa using h2
  refine hlim.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with N hN
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  rw [expect_normalizedMoment_six N hN]
  field_simp
  ring

end RademacherWigner