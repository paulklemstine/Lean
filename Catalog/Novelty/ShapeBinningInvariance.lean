import Mathlib
import Novelty.ShapeTestMonotoneDecline

/-!
# Binning cannot manufacture a mode

Cycle-3 companion to `Novelty.ShapeTestMonotoneDecline`. The absolute-shape channel was
re-run "with zero binning" precisely because binning is suspected of distorting shape. Here we
prove that the suspicion is unfounded in one direction: **equal-width block averages of a
strictly declining continuous shape are themselves strictly declining**, so a binned profile
can never display an interior peak that the underlying shape does not have.

* `block_integral_strictAnti` — general statement for a continuous strictly antitone shape.
* `blockMean`, `rateT_blockMean_strictAnti` — the power-law deciles are strictly declining.
* `rateT_blockMean_isGreatest_first` — the first bin dominates every later bin.
* `rateT_blockMean_no_interior_peak` — no bin strictly between the first and the last can be a
  maximum, the discrete analogue of `rateT_no_interiorMode`.
-/

open Set Real intervalIntegral

namespace ShapeTestMonotoneDecline

/-! ## 1. Block integrals of a declining shape -/

/-- Shifting a window to the right strictly decreases the integral of a strictly declining
continuous shape. -/
theorem block_integral_strictAnti {f : ℝ → ℝ} {s t h : ℝ}
    (hcont : ContinuousOn f (Icc s (t + h))) (hanti : StrictAntiOn f (Icc s (t + h)))
    (hst : s < t) (hh : 0 < h) :
    (∫ x in t..(t + h), f x) < ∫ x in s..(s + h), f x := by
  have hsub : ∀ x ∈ Icc (0:ℝ) h, s + x ∈ Icc s (t + h) := by
    intro x hx; exact ⟨by linarith [hx.1], by linarith [hx.2]⟩
  have hsub' : ∀ x ∈ Icc (0:ℝ) h, t + x ∈ Icc s (t + h) := by
    intro x hx; exact ⟨by linarith [hx.1], by linarith [hx.2]⟩
  have hshift1 : (∫ x in (0:ℝ)..h, f (s + x)) = ∫ x in s..(s + h), f x := by
    simp
  have hshift2 : (∫ x in (0:ℝ)..h, f (t + x)) = ∫ x in t..(t + h), f x := by
    simp
  rw [← hshift1, ← hshift2]
  refine intervalIntegral.integral_lt_integral_of_continuousOn_of_le_of_exists_lt hh
    (hcont.comp (by fun_prop) hsub') (hcont.comp (by fun_prop) hsub) ?_ ?_
  · intro x hx
    exact (hanti (hsub x ⟨hx.1.le, hx.2⟩) (hsub' x ⟨hx.1.le, hx.2⟩) (by linarith)).le
  · exact ⟨0, ⟨le_rfl, hh.le⟩, hanti (hsub 0 ⟨le_rfl, hh.le⟩) (hsub' 0 ⟨le_rfl, hh.le⟩)
      (by linarith)⟩

/-! ## 2. Power-law bins -/

theorem rateT_continuousOn {C a s e : ℝ} (hs : -1 < s) :
    ContinuousOn (rateT C a) (Icc s e) := by
  apply ContinuousOn.mul continuousOn_const
  apply ContinuousOn.rpow_const
  · fun_prop
  · intro x hx
    left
    have h1 : (0:ℝ) < 1 + x := by have := hx.1; linarith
    linarith

/-- The mean of the shape over the `k`-th bin `[l + k h, l + (k+1) h]`. -/
noncomputable def blockMean (f : ℝ → ℝ) (l h : ℝ) (k : ℕ) : ℝ :=
  (1 / h) * ∫ x in (l + k * h)..(l + k * h + h), f x

/-- **Power-law bins are strictly declining, whatever the bin width.** -/
theorem rateT_blockMean_strictAnti {C a l h : ℝ} (hC : 0 < C) (ha : 0 < a) (hl : -1 < l)
    (hh : 0 < h) : StrictAnti (blockMean (rateT C a) l h) := by
  intro j k hjk
  have hjl : -1 < l + (j : ℝ) * h := by
    have : (0:ℝ) ≤ (j : ℝ) * h := by positivity
    linarith
  have hlt : l + (j : ℝ) * h < l + (k : ℝ) * h := by
    have : (j : ℝ) < (k : ℝ) := by exact_mod_cast hjk
    nlinarith
  have hcont : ContinuousOn (rateT C a) (Icc (l + (j : ℝ) * h) (l + (k : ℝ) * h + h)) :=
    rateT_continuousOn hjl
  have hanti : StrictAntiOn (rateT C a) (Icc (l + (j : ℝ) * h) (l + (k : ℝ) * h + h)) :=
    rateT_strictAntiOn_window hC ha hjl
  have hint := block_integral_strictAnti hcont hanti hlt hh
  simp only [blockMean]
  exact mul_lt_mul_of_pos_left hint (by positivity)

/-- The first bin dominates every later bin. -/
theorem rateT_blockMean_isGreatest_first {C a l h : ℝ} (hC : 0 < C) (ha : 0 < a) (hl : -1 < l)
    (hh : 0 < h) (n : ℕ) :
    IsGreatest (blockMean (rateT C a) l h '' Iic n) (blockMean (rateT C a) l h 0) := by
  refine ⟨⟨0, Nat.zero_le n, rfl⟩, ?_⟩
  rintro _ ⟨k, _, rfl⟩
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · exact le_rfl
  · exact (rateT_blockMean_strictAnti hC ha hl hh hk).le

/-- **No binning of the power law shows an interior peak**: every bin strictly inside the
range is strictly beaten by the first bin. -/
theorem rateT_blockMean_no_interior_peak {C a l h : ℝ} (hC : 0 < C) (ha : 0 < a) (hl : -1 < l)
    (hh : 0 < h) (n k : ℕ) (hk : 0 < k) :
    ¬ (∀ j ≤ n, blockMean (rateT C a) l h j ≤ blockMean (rateT C a) l h k) := by
  intro hmax
  have h0 := hmax 0 (Nat.zero_le n)
  have hlt : blockMean (rateT C a) l h k < blockMean (rateT C a) l h 0 :=
    rateT_blockMean_strictAnti hC ha hl hh hk
  linarith

end ShapeTestMonotoneDecline