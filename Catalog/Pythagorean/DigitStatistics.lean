import Pythagorean.DigitPrefixToolkit

/-!
# Asymptotic digit statistics

We introduce the two statistics that a "digit law" for a real constant would have to talk
about: the counting functions of a fixed digit, and simple normality in base ten.

* `Pyth.digitCount x c M` — how many of the first `M` decimal digits of `x` equal `c`.
* `Pyth.SimplyNormalTen x` — every digit has asymptotic frequency `1/10`.
* `Pyth.NonzeroDensity x α` — the density of nonzero digits equals `α`.

The main lemmas here are the two *bridges* used later: a number whose nonzero digits have
density `0` is not simply normal (`Pyth.not_simplyNormal_of_density_zero`), and the
logarithmic counting bound needed for the sparse witnesses
(`Pyth.tendsto_natLog_div_atTop`).
-/

namespace Pyth

open Filter Real

/-! ## Counting functions -/

/-- The number of indices `m < M` whose `m`-th decimal digit of `x` equals `c`. -/
noncomputable def digitCount (x : ℝ) (c : Fin 10) (M : ℕ) : ℕ :=
  ((Finset.range M).filter (fun m => Real.digits x 10 m = c)).card

/-- The number of indices `m < M` whose `m`-th decimal digit of `x` is nonzero. -/
noncomputable def nonzeroCount (x : ℝ) (M : ℕ) : ℕ :=
  ((Finset.range M).filter (fun m => Real.digits x 10 m ≠ 0)).card

theorem digitCount_zero_add_nonzeroCount (x : ℝ) (M : ℕ) :
    digitCount x 0 M + nonzeroCount x M = M := by
  classical
  simp only [digitCount, nonzeroCount]
  rw [Finset.card_filter_add_card_filter_not (p := fun m => Real.digits x 10 m = 0)]
  exact Finset.card_range M

/-- `x` is *simply normal in base ten*: every digit occurs with asymptotic frequency `1/10`. -/
def SimplyNormalTen (x : ℝ) : Prop :=
  ∀ c : Fin 10, Tendsto (fun M : ℕ => (digitCount x c M : ℝ) / M) atTop (nhds (1 / 10))

/-- The asymptotic density of nonzero decimal digits of `x` equals `α`. -/
def NonzeroDensity (x : ℝ) (α : ℝ) : Prop :=
  Tendsto (fun M : ℕ => (nonzeroCount x M : ℝ) / M) atTop (nhds α)

/-! ## Density zero rules out simple normality -/

theorem tendsto_digitCount_zero_of_density_zero {x : ℝ} (h : NonzeroDensity x 0) :
    Tendsto (fun M : ℕ => (digitCount x 0 M : ℝ) / M) atTop (nhds 1) := by
  have hEq : ∀ᶠ M : ℕ in atTop,
      (digitCount x 0 M : ℝ) / M = 1 - (nonzeroCount x M : ℝ) / M := by
    filter_upwards [eventually_gt_atTop 0] with M hM
    have hMR : (M : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    have := digitCount_zero_add_nonzeroCount x M
    have : ((digitCount x 0 M : ℝ)) + (nonzeroCount x M : ℝ) = (M : ℝ) := by exact_mod_cast this
    field_simp
    linarith
  have : Tendsto (fun M : ℕ => 1 - (nonzeroCount x M : ℝ) / M) atTop (nhds (1 - 0)) :=
    tendsto_const_nhds.sub h
  rw [sub_zero] at this
  exact this.congr' (hEq.mono fun M hM => hM.symm)

/-- **Density zero forbids simple normality.**  A number whose nonzero digits have density `0`
has digit `0` with frequency `1 ≠ 1/10`. -/
theorem not_simplyNormal_of_density_zero {x : ℝ} (h : NonzeroDensity x 0) :
    ¬ SimplyNormalTen x := by
  intro hnorm
  have h1 := tendsto_digitCount_zero_of_density_zero h
  have h2 := hnorm 0
  have := tendsto_nhds_unique h1 h2
  norm_num at this

/-- **Density one forbids simple normality** as well: simple normality would force the density
of nonzero digits to be `9/10`. -/
theorem not_simplyNormal_of_density_one {x : ℝ} (h : NonzeroDensity x 1) :
    ¬ SimplyNormalTen x := by
  intro hnorm
  have h2 := hnorm 0
  -- digitCount 0 = M - nonzeroCount, hence its density tends to 0, contradicting 1/10
  have hEq : ∀ᶠ M : ℕ in atTop,
      (digitCount x 0 M : ℝ) / M = 1 - (nonzeroCount x M : ℝ) / M := by
    filter_upwards [eventually_gt_atTop 0] with M hM
    have hMR : (M : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    have h3 := digitCount_zero_add_nonzeroCount x M
    have h4 : ((digitCount x 0 M : ℝ)) + (nonzeroCount x M : ℝ) = (M : ℝ) := by exact_mod_cast h3
    field_simp
    linarith
  have h5 : Tendsto (fun M : ℕ => 1 - (nonzeroCount x M : ℝ) / M) atTop (nhds (1 - 1)) :=
    tendsto_const_nhds.sub h
  rw [sub_self] at h5
  have h6 : Tendsto (fun M : ℕ => (digitCount x 0 M : ℝ) / M) atTop (nhds 0) :=
    h5.congr' (hEq.mono fun M hM => hM.symm)
  have := tendsto_nhds_unique h6 h2
  norm_num at this

/-! ## A logarithmic counting bound -/

/-- `Nat.log 2 M / M → 0`: sparse (lacunary) digit patterns have density zero. -/
theorem tendsto_natLog_div_atTop :
    Tendsto (fun M : ℕ => (Nat.log 2 M : ℝ) / M) atTop (nhds 0) := by
  have hlog : Tendsto (fun x : ℝ => Real.log x / x) atTop (nhds 0) :=
    Real.isLittleO_log_id_atTop.tendsto_div_nhds_zero
  have h1 : Tendsto (fun M : ℕ => Real.log M / M) atTop (nhds 0) :=
    hlog.comp tendsto_natCast_atTop_atTop
  have h2 : Tendsto (fun M : ℕ => (Real.log 2)⁻¹ * (Real.log M / M)) atTop (nhds 0) := by
    have := h1.const_mul ((Real.log 2)⁻¹)
    simpa using this
  refine squeeze_zero' ?_ ?_ h2
  · filter_upwards [eventually_gt_atTop 0] with M hM
    positivity
  · filter_upwards [eventually_gt_atTop 0] with M hM
    have hM0 : (0:ℝ) < M := by exact_mod_cast hM
    have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    have hle : ((Nat.log 2 M : ℕ) : ℝ) * Real.log 2 ≤ Real.log M := by
      have h3 : (2:ℕ) ^ Nat.log 2 M ≤ M := Nat.pow_log_le_self 2 (by omega)
      have h4 : ((2:ℝ)) ^ (Nat.log 2 M) ≤ (M : ℝ) := by exact_mod_cast h3
      have h5 : Real.log ((2:ℝ) ^ (Nat.log 2 M)) ≤ Real.log M :=
        Real.log_le_log (by positivity) h4
      rwa [Real.log_pow] at h5
    rw [div_le_iff₀ hM0] at *
    have : ((Nat.log 2 M : ℕ) : ℝ) ≤ (Real.log 2)⁻¹ * Real.log M := by
      rw [le_inv_mul_iff₀ hlog2, mul_comm]
      exact hle
    calc ((Nat.log 2 M : ℕ) : ℝ) ≤ (Real.log 2)⁻¹ * Real.log M := this
      _ = (Real.log 2)⁻¹ * Real.log M / M * M := by field_simp
      _ = (Real.log 2)⁻¹ * (Real.log M / M) * M := by ring

end Pyth