import Mathlib
import Probability.F1TightnessCore

/-!
# Discretisation bias of the slack factor (paper 250, next-cycle item)

The measured slack factor is computed on a finite cell grid (27 cells), while
the profile it summarises is a continuum density.  The exact identity
`gapX p = (M+1)/(2·M·E_x + 1)` of `Probability.F1TightnessCore` isolates the
grid dependence in a single scalar function, and this file settles its
behaviour: at a fixed mean probe position `E < 1/2` the finite-grid slack is
**strictly below** the continuum value `1/(2E)`, increases with the number of
cells, and converges to it.  Consequently a finite-grid estimate of the F1
slack is conservative.

Main results.

* `gapXofM` — the grid-dependent slack `X_M(E) = (M+1)/(2ME+1)`.
* `gapX_eq_gapXofM` — it is the slack of any profile with mean position `E`.
* `gapXofM_lt_continuum` — `X_M(E) < 1/(2E)` for every `M`, when `E < 1/2`.
* `gapXofM_strictMono` — `X_M(E)` strictly increases in the number of cells.
* `gapXofM_tendsto` — `X_M(E) → 1/(2E)`.
* `finite_grid_underestimates` — the packaged statement: the reported slack is
  a strict lower bound for the continuum slack of the same profile.
-/

open Filter

namespace F1Tightness

/-- The slack factor of an `M`-cell grid at mean probe position `E`. -/
noncomputable def gapXofM (E : ℝ) (M : ℕ) : ℝ := ((M : ℝ) + 1) / (2 * (M : ℝ) * E + 1)

/-- Any `M`-cell profile with mean position `E` has slack `X_M(E)`. -/
theorem gapX_eq_gapXofM {M : ℕ} {p : Fin M → ℝ} (hM : 0 < M) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : gapX p = gapXofM (meanPos p) M :=
  gapX_eq_meanPos hM hp hsum

theorem gapXofM_pos {E : ℝ} (hE : 0 < E) (M : ℕ) : 0 < gapXofM E M := by
  unfold gapXofM
  have hden : 0 < 2 * (M : ℝ) * E + 1 := by positivity
  positivity

/-- **The finite grid underestimates the slack.**  For a front-loaded mean
position the `M`-cell slack is strictly below the continuum value `1/(2E)`. -/
theorem gapXofM_lt_continuum {E : ℝ} (hE0 : 0 < E) (hE : E < 1 / 2) (M : ℕ) :
    gapXofM E M < 1 / (2 * E) := by
  have hden : 0 < 2 * (M : ℝ) * E + 1 := by positivity
  have hM : (0 : ℝ) ≤ (M : ℝ) := Nat.cast_nonneg M
  unfold gapXofM
  rw [div_lt_div_iff₀ hden (by positivity)]
  nlinarith

/-- The finite-grid slack increases with the number of cells. -/
theorem gapXofM_strictMono {E : ℝ} (hE0 : 0 < E) (hE : E < 1 / 2) :
    StrictMono (gapXofM E) := by
  have hstep : ∀ M : ℕ, gapXofM E M < gapXofM E (M + 1) := by
    intro M
    have hM : (0 : ℝ) ≤ (M : ℝ) := Nat.cast_nonneg M
    have hden1 : 0 < 2 * (M : ℝ) * E + 1 := by positivity
    have hden2 : 0 < 2 * ((M : ℝ) + 1) * E + 1 := by positivity
    unfold gapXofM
    push_cast
    rw [div_lt_div_iff₀ hden1 (by positivity)]
    nlinarith
  exact strictMono_nat_of_lt_succ hstep

/-- The finite-grid slack converges to the continuum slack. -/
theorem gapXofM_tendsto {E : ℝ} (hE0 : 0 < E) :
    Tendsto (gapXofM E) atTop (nhds (1 / (2 * E))) := by
  have hinv : Tendsto (fun M : ℕ => 1 / (M : ℝ)) atTop (nhds 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hnum : Tendsto (fun M : ℕ => 1 + 1 / (M : ℝ)) atTop (nhds 1) := by
    simpa using (tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).add hinv
  have hden : Tendsto (fun M : ℕ => 2 * E + 1 / (M : ℝ)) atTop (nhds (2 * E)) := by
    simpa using (tendsto_const_nhds (x := 2 * E) (f := atTop (α := ℕ))).add hinv
  have hne : (2 : ℝ) * E ≠ 0 := by positivity
  have hdiv := hnum.div hden hne
  refine hdiv.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with M hM
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  show (1 + 1 / (M : ℝ)) / (2 * E + 1 / (M : ℝ)) = gapXofM E M
  unfold gapXofM
  rw [div_eq_div_iff (by positivity) (by positivity)]
  field_simp

/-- **Packaged statement.**  The slack reported on an `M`-cell grid is a strict
lower bound for the continuum slack of a front-loaded profile, and the two agree
in the refinement limit. -/
theorem finite_grid_underestimates {M : ℕ} {p : Fin M → ℝ} (hM : 0 < M)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i : Fin M, p i = 1)
    (hE0 : 0 < meanPos p) (hE : meanPos p < 1 / 2) :
    gapX p < 1 / (2 * meanPos p) := by
  rw [gapX_eq_gapXofM hM hp hsum]
  exact gapXofM_lt_continuum hE0 hE M

end F1Tightness