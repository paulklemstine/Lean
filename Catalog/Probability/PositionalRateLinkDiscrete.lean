import Mathlib
import Probability.PositionalRateLinkHarmonic

/-!
# The discrete carrier converges to the harmonic positional law

Cycle 3 of the round-80 analysis: a bridge between the *arithmetic* carrier and
the *continuum* positional law used in the statistical model.

`Catalog/NumberTheory/FermatPositionDensity.lean` proved that the
self-divisibility carrier of the sieve polynomial has density exactly `1/j` at
position `j`, and that this produces a strict small-`j` excess between
consecutive blocks.  `Catalog/Probability/PositionalRateLinkHarmonic.lean`
introduced the continuum profile `harmCDF r u = log(1 + (r−1)u) / log r` and
proved its scale invariance and edge excess.  The present file closes the loop:
the *discrete* weight `∑ 1/j` over the leading part of a doubling window
converges, after normalisation, to exactly `harmCDF 2 u`.

Main results.

* `PositionalRateLink.harmonic_window_sum` – the harmonic difference
  `H b − H a` is the window weight `∑_{j ∈ [a, b)} 1/(j+1)`.
* `PositionalRateLink.tendsto_harmonic_diff` – `H(aL) − H(bL) → log (a/b)`;
  the Euler–Mascheroni constants cancel.
* `PositionalRateLink.tendsto_discrete_decile_harmCDF` – for each decile
  boundary `k ≤ 10`, the normalised discrete weight of the leading `k` deciles
  of the doubling window `(10L, 20L]` converges to `harmCDF 2 (k/10)`.
  In particular (`tendsto_discrete_edge_decile`) the leading decile converges to
  `log(11/10)/log 2 ≈ 0.1375`, strictly above the uniform value `1/10`: the
  observed edge-decile excess is the continuum limit of the `1/j` carrier, not
  an artefact of binning.
-/

open Filter Topology Real Finset

namespace PositionalRateLink

/-- The harmonic difference is exactly the `1/j` weight of a window of
positions. -/
theorem harmonic_window_sum {a b : ℕ} (hab : a ≤ b) :
    (harmonic b : ℚ) - harmonic a = ∑ i ∈ Finset.Ico a b, ((i : ℚ) + 1)⁻¹ := by
  have h := Finset.sum_Ico_eq_sub (fun i : ℕ => ((i : ℚ) + 1)⁻¹) hab
  simp only [harmonic]
  rw [h]
  push_cast
  ring

/-- Harmonic numbers along two arithmetic scalings differ, in the limit, by the
logarithm of the ratio: the Euler–Mascheroni constants cancel. -/
theorem tendsto_harmonic_diff (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
    Filter.Tendsto (fun L : ℕ => (harmonic (a * L) : ℝ) - (harmonic (b * L) : ℝ))
      Filter.atTop (𝓝 (Real.log (a / b : ℝ))) := by
  have hA : Filter.Tendsto (fun L : ℕ => (harmonic (a*L) : ℝ) - Real.log ((a*L : ℕ) : ℝ))
      Filter.atTop (𝓝 eulerMascheroniConstant) :=
    Real.tendsto_harmonic_sub_log.comp
      (Filter.tendsto_atTop_mono (fun L => Nat.le_mul_of_pos_left L ha) Filter.tendsto_id)
  have hB : Filter.Tendsto (fun L : ℕ => (harmonic (b*L) : ℝ) - Real.log ((b*L : ℕ) : ℝ))
      Filter.atTop (𝓝 eulerMascheroniConstant) :=
    Real.tendsto_harmonic_sub_log.comp
      (Filter.tendsto_atTop_mono (fun L => Nat.le_mul_of_pos_left L hb) Filter.tendsto_id)
  have hsub := hA.sub hB
  rw [sub_self] at hsub
  have hlim := hsub.add (tendsto_const_nhds (x := Real.log (a / b : ℝ)) (f := Filter.atTop (α := ℕ)))
  rw [zero_add] at hlim
  refine hlim.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop 0] with L hL
  have hLR : (0:ℝ) < (L : ℝ) := by exact_mod_cast hL
  have haR : (0:ℝ) < (a : ℝ) := by exact_mod_cast ha
  have hbR : (0:ℝ) < (b : ℝ) := by exact_mod_cast hb
  have h1 : ((a*L : ℕ) : ℝ) = (a:ℝ) * L := by push_cast; ring
  have h2 : ((b*L : ℕ) : ℝ) = (b:ℝ) * L := by push_cast; ring
  rw [h1, h2, Real.log_mul haR.ne' hLR.ne', Real.log_mul hbR.ne' hLR.ne',
    Real.log_div haR.ne' hbR.ne']
  ring

/-- **The discrete `1/j` carrier realises the harmonic positional law.**  In the
doubling window `(10L, 20L]`, the normalised `1/j` weight of the leading `k`
deciles converges, as `L → ∞`, to the continuum value `harmCDF 2 (k/10)`. -/
theorem tendsto_discrete_decile_harmCDF (k : ℕ) (hk : k ≤ 10) :
    Filter.Tendsto
      (fun L : ℕ => ((harmonic ((10 + k) * L) : ℝ) - (harmonic (10 * L) : ℝ))
        / ((harmonic (20 * L) : ℝ) - (harmonic (10 * L) : ℝ)))
      Filter.atTop (𝓝 (harmCDF 2 (k / 10 : ℝ))) := by
  have hnum := tendsto_harmonic_diff (10 + k) 10 (by omega) (by norm_num)
  have hden := tendsto_harmonic_diff 20 10 (by norm_num) (by norm_num)
  have hlog2 : Real.log ((20 : ℕ) / (10 : ℕ) : ℝ) = Real.log 2 := by norm_num
  rw [hlog2] at hden
  have hne : Real.log 2 ≠ 0 := (Real.log_pos (by norm_num)).ne'
  have hdiv := hnum.div hden hne
  have hval : Real.log (((10 + k : ℕ) : ℝ) / ((10 : ℕ) : ℝ)) / Real.log 2
      = harmCDF 2 (k / 10 : ℝ) := by
    have h1 : (((10 + k : ℕ) : ℝ) / ((10 : ℕ) : ℝ)) = 1 + ((2 : ℝ) - 1) * (k / 10 : ℝ) := by
      push_cast
      ring
    rw [harmCDF, h1]
  rw [← hval]
  exact hdiv

/-- The leading decile: the discrete carrier gives it weight
`log(11/10)/log 2 > 1/10` in the limit. -/
theorem tendsto_discrete_edge_decile :
    Filter.Tendsto
      (fun L : ℕ => ((harmonic (11 * L) : ℝ) - (harmonic (10 * L) : ℝ))
        / ((harmonic (20 * L) : ℝ) - (harmonic (10 * L) : ℝ)))
      Filter.atTop (𝓝 (harmCDF 2 (1 / 10 : ℝ))) := by
  have h := tendsto_discrete_decile_harmCDF 1 (by norm_num)
  norm_num at h ⊢
  exact h

/-- The limiting edge-decile weight of the discrete carrier strictly exceeds the
uniform value `1/10`. -/
theorem discrete_edge_decile_excess : 1 / 10 < harmCDF 2 (1 / 10 : ℝ) :=
  harmCDF_gt_id (by norm_num) (by norm_num) (by norm_num)

end PositionalRateLink