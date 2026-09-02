import Physics.SphericalCapPowerCeilingHolder

/-!
# The optimal smooth crossing test is a correlation against the contrast direction

Fourth cycle of the spherical-cap analysis.  Cycles 1–3 established the sample-size-free
ceiling `L·√(2ε)`, its sharpness (witnessed by a *distance* statistic), the alignment window
and the capacity of the U84 cap.  The question left open by the review was practical: among
statistics that a physicist would actually compute — correlations against some direction —
*which one is best*, and how much does it lose against the ceiling?

The answer is clean: correlate against the **contrast direction** `(û − v̂)/‖û − v̂‖`.  That
statistic is a correlation, is `1`-Lipschitz on the sphere, and attains the ceiling exactly.
On the recorded U84 configuration it separates the two hypotheses by the full chordal distance,
which is at least the recorded margin `0.008` and at most `√2/100`, whereas correlating against
the response `w` gives exactly `0.008`.  So the contrast test is optimal among smooth tests,
but — and this is the punchline of the whole analysis — even the optimal smooth test is still
capped at `√2/100 = 0.0141…`, far below the separation `1` achieved by the discontinuous
rank/threshold statistic.

## Main results

* `contrast_unit`, `contrast_test_attains_chord` — the contrast direction is a unit vector and
  the correlation against it separates `û` and `v̂` by exactly `chord u v`.
* `smooth_test_optimum` — that value is simultaneously an upper bound for every statistic that
  is `1`-Lipschitz on the sphere: the maximum over the smooth class is *exactly* the chordal
  distance, attained by a correlation statistic.
* `u84_optimal_smooth_test` — the U84 instance, with the two-sided numeric window
  `0.008 ≤ chord ≤ √2/100` and the optimality clause.
* `u84_contrast_beats_response_correlation` — the contrast test is at least as good as the
  recorded response correlation, and the ceiling caps the improvement at a factor `√2/100 /
  0.008 = 1.7678`.
-/

open Finset
open Catalog.Algebra.ZeroFitDialU72Parity

namespace Catalog.Physics.SphericalCapPowerCeiling

variable {n : ℕ}

/-! ## 1. The contrast direction -/

/-- The (unnormalised) contrast of two directions. -/
noncomputable def contrastRaw (u v : Fin n → ℝ) : Fin n → ℝ := fun i => nz u i - nz v i

/-- The contrast direction `(û − v̂)/‖û − v̂‖`. -/
noncomputable def contrast (u v : Fin n → ℝ) : Fin n → ℝ := nz (contrastRaw u v)

lemma chord_eq_nrm_contrastRaw (u v : Fin n → ℝ) : chord u v = nrm (contrastRaw u v) := rfl

/-- The contrast direction is a unit vector whenever the two hypotheses differ. -/
theorem contrast_unit (u v : Fin n → ℝ) (h : dot (contrastRaw u v) (contrastRaw u v) ≠ 0) :
    dot (contrast u v) (contrast u v) = 1 :=
  dot_nz_self _ h

/-- **The contrast test attains the chordal distance.**  Correlating against
`(û − v̂)/‖û − v̂‖` separates the two hypotheses by exactly `chord u v`. -/
theorem contrast_test_attains_chord (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    (h : dot (contrastRaw u v) (contrastRaw u v) ≠ 0) :
    corr (nz u) (contrast u v) - corr (nz v) (contrast u v) = chord u v := by
  have hnD : 0 < nrm (contrastRaw u v) := nrm_pos h
  have hce : dot (contrast u v) (contrast u v) = 1 := contrast_unit u v h
  have hnc : nrm (contrast u v) = 1 := by rw [nrm, hce, Real.sqrt_one]
  have hnu : nrm (nz u) = 1 := nrm_nz u hu
  have hnv : nrm (nz v) = 1 := nrm_nz v hv
  have hcu : corr (nz u) (contrast u v) = dot (nz u) (contrast u v) := by
    rw [corr, hnu, hnc]; norm_num
  have hcv : corr (nz v) (contrast u v) = dot (nz v) (contrast u v) := by
    rw [corr, hnv, hnc]; norm_num
  have hsub : dot (nz u) (contrast u v) - dot (nz v) (contrast u v)
      = dot (contrastRaw u v) (contrast u v) :=
    (dot_sub_left (nz u) (nz v) (contrast u v)).symm
  have hval : dot (contrastRaw u v) (contrast u v) = nrm (contrastRaw u v) := by
    have hexp : dot (contrastRaw u v) (contrast u v)
        = dot (contrastRaw u v) (contrastRaw u v) / nrm (contrastRaw u v) := by
      simp only [dot, contrast, nz]
      rw [Finset.sum_div]
      exact Finset.sum_congr rfl (fun i _ => by ring)
    rw [hexp, ← nrm_sq (contrastRaw u v), sq, mul_div_assoc, div_self (ne_of_gt hnD), mul_one]
  rw [hcu, hcv, hsub, hval, chord_eq_nrm_contrastRaw]

/-- **The smooth optimum is exactly the chordal distance.**  A correlation statistic attains
it, and no statistic that is `1`-Lipschitz on the sphere can exceed it. -/
theorem smooth_test_optimum (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    (h : dot (contrastRaw u v) (contrastRaw u v) ≠ 0) :
    (∃ e : Fin n → ℝ, dot e e = 1 ∧
        |corr (nz u) e - corr (nz v) e| = chord u v) ∧
      (∀ F : (Fin n → ℝ) → ℝ, IsLipSphere 1 F → |F (nz u) - F (nz v)| ≤ chord u v) := by
  constructor
  · refine ⟨contrast u v, contrast_unit u v h, ?_⟩
    rw [contrast_test_attains_chord u v hu hv h]
    exact abs_of_nonneg (chord_nonneg u v)
  · intro F hF
    have := hF (nz u) (nz v) (dot_nz_self u hu) (dot_nz_self v hv)
    rwa [one_mul, ← chord] at this

/-! ## 2. The U84 instance -/

/-- **The optimal smooth test at U84.**  On the catalog configuration the contrast correlation
separates the two hypotheses by the full chordal distance, which lies between the recorded
margin `0.008` and the cap radius `√2/100`; and no `1`-Lipschitz statistic does better. -/
theorem u84_optimal_smooth_test :
    ∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      corr u w = 558 / 1000 ∧ corr v w = 55 / 100 ∧
      ∃ e : Fin 2 → ℝ, dot e e = 1 ∧
        corr (nz u) e - corr (nz v) e = chord u v ∧
        (8 : ℝ) / 1000 ≤ chord u v ∧ chord u v ≤ Real.sqrt 2 / 100 ∧
        ∀ F : (Fin 2 → ℝ) → ℝ, IsLipSphere 1 F → |F (nz u) - F (nz v)| ≤ chord u v := by
  obtain ⟨u, v, w, hu, hv, hw, huw, hvw, huv⟩ :=
    Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  have hmargin : (8 : ℝ) / 1000 ≤ chord u v := by
    have h := corr_diff_le_chord u v w hu hv hw
    have h2 : (8 : ℝ) / 1000 ≤ |corr u w - corr v w| := by
      rw [huw, hvw, show (558 : ℝ) / 1000 - 55 / 100 = 8 / 1000 by norm_num]
      exact le_of_eq (abs_of_nonneg (by norm_num)).symm
    linarith
  have hchordpos : 0 < chord u v := by linarith
  have hraw : dot (contrastRaw u v) (contrastRaw u v) ≠ 0 := by
    intro hzero
    have : chord u v = 0 := by
      rw [chord_eq_nrm_contrastRaw, nrm, hzero, Real.sqrt_zero]
    linarith
  have hcap : chord u v ≤ Real.sqrt 2 / 100 := by
    have h := chord_le_sqrt_two_mul u v hu hv (eps := 1 / 10000) (by linarith)
    rwa [show Real.sqrt (2 * (1 / 10000 : ℝ)) = Real.sqrt 2 / 100 from u84_cap_radius] at h
  refine ⟨u, v, w, hu, hv, hw, huw, hvw, contrast u v, contrast_unit u v hraw,
    contrast_test_attains_chord u v hu hv hraw, hmargin, hcap, ?_⟩
  exact (smooth_test_optimum u v hu hv hraw).2

/-- **The contrast test dominates the recorded response correlation, but not by much.**  Its
separation is at least the recorded margin `0.008` and at most `√2/100`, so the achievable
improvement over the recorded reading gap is capped at a factor `1.7678`. -/
theorem u84_contrast_beats_response_correlation :
    ∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      |corr (nz u) w - corr (nz v) w| = 8 / 1000 ∧
      ∃ e : Fin 2 → ℝ, dot e e = 1 ∧
        |corr (nz u) w - corr (nz v) w| ≤ |corr (nz u) e - corr (nz v) e| ∧
        |corr (nz u) e - corr (nz v) e| ≤ 1.7678 * |corr (nz u) w - corr (nz v) w| := by
  obtain ⟨u, v, w, hu, hv, hw, huw, hvw, huv⟩ :=
    Catalog.Novelty.TDialU84ApproachNotCrossed.crossing_states_indistinguishable
  have hread : |corr (nz u) w - corr (nz v) w| = 8 / 1000 := by
    rw [corr_nz_left u w hu, corr_nz_left v w hv, huw, hvw,
      show (558 : ℝ) / 1000 - 55 / 100 = 8 / 1000 by norm_num]
    exact abs_of_nonneg (by norm_num)
  have hmargin : (8 : ℝ) / 1000 ≤ chord u v := by
    have h := corr_diff_le_chord u v w hu hv hw
    have hread' : |corr u w - corr v w| = 8 / 1000 := by
      rw [corr_nz_left u w hu, corr_nz_left v w hv] at hread
      exact hread
    linarith [hread'.ge, h]
  have hraw : dot (contrastRaw u v) (contrastRaw u v) ≠ 0 := by
    intro hzero
    have hz : chord u v = 0 := by
      rw [chord_eq_nrm_contrastRaw, nrm, hzero, Real.sqrt_zero]
    linarith
  have hcap : chord u v ≤ Real.sqrt 2 / 100 := by
    have h := chord_le_sqrt_two_mul u v hu hv (eps := 1 / 10000) (by linarith)
    rwa [show Real.sqrt (2 * (1 / 10000 : ℝ)) = Real.sqrt 2 / 100 from u84_cap_radius] at h
  have hcontrast : |corr (nz u) (contrast u v) - corr (nz v) (contrast u v)| = chord u v := by
    rw [contrast_test_attains_chord u v hu hv hraw]
    exact abs_of_nonneg (chord_nonneg u v)
  have hs2 : Real.sqrt 2 < 1.41424 := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  refine ⟨u, v, w, hu, hv, hw, hread, contrast u v, contrast_unit u v hraw, ?_, ?_⟩
  · rw [hread, hcontrast]; exact hmargin
  · rw [hread, hcontrast]; linarith [hcap, hs2]

end Catalog.Physics.SphericalCapPowerCeiling