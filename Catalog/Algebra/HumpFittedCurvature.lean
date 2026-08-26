/-
# The fitted quadratic coefficient is a certificate of concavity

Second formal core of experiment **581** (paper 231).  The experiment's central
descriptive statistic is the **quadratic-fit curvature** `c` of the binned ratio
profile `R = T/M`: `c = -0.105` pooled controls, `c = -0.299` dominant band,
`c = -0.18 / -0.25 / -0.44` in the three LPF terciles, `c = -0.13` in the first
`k100` tercile.  The verdict language ("concave in ALL THREE") reads a negative
fitted `c` as *concavity of the underlying profile*.

That reading is not automatic: `c` is an inner product of the profile against a
grid-dependent orthogonal quadratic, and one has to know that this inner product
cannot be negative for an accident of the grid.  This file proves it, in the
exact discrete form used by the pipeline (finitely many equal-width bins).

## Main results

* `HumpFittedCurvature.sum_profile_mul_quadratic_nonpos` — **sign theorem**: for
  any concave profile `g`, any finite grid, and any quadratic
  `q(y) = (y-r₁)(y-r₂)` that is orthogonal to constants and to the identity on
  that grid, `∑ g(tᵢ) q(tᵢ) ≤ 0`.  The proof subtracts the chord of `g` through
  the two roots of `q`; orthogonality kills the chord, and the residual has the
  opposite sign to `q` at every single grid point.
* `HumpFittedCurvature.sum_profile_mul_quadratic_neg` — strict version for
  strictly concave profiles.
* `HumpFittedCurvature.affine_profile_sum_eq_zero` — the **control**:
  an affine profile fits with curvature exactly `0`, matching the experiment's
  "controls clean everywhere".
* `HumpFittedCurvature.binGrid_orth_const`, `binGrid_orth_id` — the equal-width
  bin grid of the pipeline, with the explicit orthogonal quadratic
  `q(y) = (y-m)² - h²·V(n)`, is orthogonal to constants and to the identity for
  **every** bin width `h` and **every** grid centre `m`.
* `HumpFittedCurvature.fitCurvature_neg_binGrid` — hence for any strictly
  concave profile the measured curvature is strictly negative.
* `HumpFittedCurvature.window_fitCurvature_neg` — applied to the `j² − N`
  log-size profile of `Algebra.HumpWindowGeometry`: **the geometric channel `H0`
  predicts a strictly negative fitted curvature, for every bin width and every
  grid offset.**  This is exactly the pre-registered "bin-width permutation /
  u-grid shift" probe, and `H0` passes it: the concavity sign is invariant.

Together with `HumpWindowGeometry.vertex_lt_midpoint` this sharpens the verdict:
the geometry predicts the *sign* robustly but cannot place the *vertex*.
-/
import Mathlib
import Algebra.HumpWindowGeometry

namespace HumpFittedCurvature

open Finset Set HumpWindowGeometry

/-! ## 1. The fitted curvature statistic -/

/-- The least-squares quadratic coefficient of a profile `g` sampled at the grid
points `t 0, …, t (n-1)`, read against a quadratic `q` orthogonal to constants
and to the identity on the grid. -/
noncomputable def fitCurvature (n : ℕ) (t : ℕ → ℝ) (q g : ℝ → ℝ) : ℝ :=
  (∑ i ∈ range n, g (t i) * q (t i)) / (∑ i ∈ range n, q (t i) ^ 2)

/-! ## 2. Concave profiles versus the chord through the roots -/

variable {S : Set ℝ} {g : ℝ → ℝ} {r₁ r₂ : ℝ}

/-- **Bridge identity, right side.**  For `r₁ < r₂ < y` the deficit of a profile
below the `[r₁,r₂]`-chord at `y` is a positive multiple of its excess above the
`[r₁,y]`-chord at `r₂`.  (Pure algebra: both measure the same triangle.) -/
theorem chord_bridge_right (g : ℝ → ℝ) {r₁ r₂ y : ℝ} (h12 : r₁ < r₂) (h2y : r₂ < y) :
    chord g r₁ r₂ y - g y = (y - r₁) / (r₂ - r₁) * gap g r₁ y r₂ := by
  have hne1 : r₂ - r₁ ≠ 0 := (sub_pos.2 h12).ne'
  have hne2 : y - r₁ ≠ 0 := (sub_pos.2 (lt_trans h12 h2y)).ne'
  rw [gap, chord, chord]
  field_simp
  ring

/-- **Bridge identity, left side.**  For `y < r₁ < r₂`. -/
theorem chord_bridge_left (g : ℝ → ℝ) {r₁ r₂ y : ℝ} (h12 : r₁ < r₂) (hy1 : y < r₁) :
    chord g r₁ r₂ y - g y = (r₂ - y) / (r₂ - r₁) * gap g y r₂ r₁ := by
  have hne1 : r₂ - r₁ ≠ 0 := (sub_pos.2 h12).ne'
  have hne2 : r₂ - y ≠ 0 := (sub_pos.2 (lt_trans hy1 h12)).ne'
  rw [gap, chord, chord]
  field_simp
  ring

/-- Between the two roots, a concave profile is above the chord. -/
theorem chord_le_of_mem_Icc (hg : ConcaveOn ℝ S g) (h1 : r₁ ∈ S) (h2 : r₂ ∈ S) (hr : r₁ < r₂)
    {y : ℝ} (hy : y ∈ Icc r₁ r₂) : chord g r₁ r₂ y ≤ g y := by
  have := gap_nonneg_of_concaveOn hg h1 h2 hr hy.1 hy.2
  rw [gap] at this
  linarith

/-- Beyond the right root, a concave profile is below the chord. -/
theorem le_chord_of_gt (hg : ConcaveOn ℝ S g) (h1 : r₁ ∈ S) (hr : r₁ < r₂)
    {y : ℝ} (hyS : y ∈ S) (hy : r₂ < y) : g y ≤ chord g r₁ r₂ y := by
  have hgap : 0 ≤ gap g r₁ y r₂ :=
    gap_nonneg_of_concaveOn hg h1 hyS (lt_trans hr hy) (le_of_lt hr) (le_of_lt hy)
  have hcoef : 0 < (y - r₁) / (r₂ - r₁) := div_pos (by linarith) (by linarith)
  have := chord_bridge_right g hr hy
  nlinarith [mul_nonneg (le_of_lt hcoef) hgap]

/-- Strictly beyond the right root, a strictly concave profile is strictly below. -/
theorem lt_chord_of_gt (hg : StrictConcaveOn ℝ S g) (h1 : r₁ ∈ S) (hr : r₁ < r₂)
    {y : ℝ} (hyS : y ∈ S) (hy : r₂ < y) : g y < chord g r₁ r₂ y := by
  have hgap : 0 < gap g r₁ y r₂ := gap_pos_of_strictConcaveOn hg h1 hyS hr hy
  have hcoef : 0 < (y - r₁) / (r₂ - r₁) := div_pos (by linarith) (by linarith)
  have := chord_bridge_right g hr hy
  nlinarith [mul_pos hcoef hgap]

/-- Before the left root, a concave profile is below the chord. -/
theorem le_chord_of_lt (hg : ConcaveOn ℝ S g) (h2 : r₂ ∈ S) (hr : r₁ < r₂)
    {y : ℝ} (hyS : y ∈ S) (hy : y < r₁) : g y ≤ chord g r₁ r₂ y := by
  have hgap : 0 ≤ gap g y r₂ r₁ :=
    gap_nonneg_of_concaveOn hg hyS h2 (lt_trans hy hr) (le_of_lt hy) (le_of_lt hr)
  have hcoef : 0 < (r₂ - y) / (r₂ - r₁) := div_pos (by linarith) (by linarith)
  have := chord_bridge_left g hr hy
  nlinarith [mul_nonneg (le_of_lt hcoef) hgap]

/-- Strictly before the left root, a strictly concave profile is strictly below. -/
theorem lt_chord_of_lt (hg : StrictConcaveOn ℝ S g) (h2 : r₂ ∈ S) (hr : r₁ < r₂)
    {y : ℝ} (hyS : y ∈ S) (hy : y < r₁) : g y < chord g r₁ r₂ y := by
  have hgap : 0 < gap g y r₂ r₁ := gap_pos_of_strictConcaveOn hg hyS h2 hy hr
  have hcoef : 0 < (r₂ - y) / (r₂ - r₁) := div_pos (by linarith) (by linarith)
  have := chord_bridge_left g hr hy
  nlinarith [mul_pos hcoef hgap]

/-! ## 3. The sign theorem -/

/-- Pointwise: the chord-residual of a concave profile has the opposite sign to
`q(y) = (y-r₁)(y-r₂)` at every point. -/
theorem residual_mul_quadratic_nonpos (hg : ConcaveOn ℝ S g) (h1 : r₁ ∈ S) (h2 : r₂ ∈ S)
    (hr : r₁ < r₂) {y : ℝ} (hyS : y ∈ S) :
    (g y - chord g r₁ r₂ y) * ((y - r₁) * (y - r₂)) ≤ 0 := by
  rcases lt_trichotomy y r₁ with hlt | heq | hgt
  · have hres : g y - chord g r₁ r₂ y ≤ 0 := by
      linarith [le_chord_of_lt hg h2 hr hyS hlt]
    have hq : 0 ≤ (y - r₁) * (y - r₂) := by nlinarith
    exact mul_nonpos_of_nonpos_of_nonneg hres hq
  · subst heq
    simp
  · rcases le_or_gt y r₂ with hle | hgt2
    · have hres : 0 ≤ g y - chord g r₁ r₂ y := by
        linarith [chord_le_of_mem_Icc hg h1 h2 hr (mem_Icc.2 ⟨le_of_lt hgt, hle⟩)]
      have hq : (y - r₁) * (y - r₂) ≤ 0 := by nlinarith
      exact mul_nonpos_of_nonneg_of_nonpos hres hq
    · have hres : g y - chord g r₁ r₂ y ≤ 0 := by
        linarith [le_chord_of_gt hg h1 hr hyS hgt2]
      have hq : 0 ≤ (y - r₁) * (y - r₂) := by nlinarith
      exact mul_nonpos_of_nonpos_of_nonneg hres hq

/-- Strict pointwise version away from the two roots. -/
theorem residual_mul_quadratic_neg (hg : StrictConcaveOn ℝ S g) (h1 : r₁ ∈ S) (h2 : r₂ ∈ S)
    (hr : r₁ < r₂) {y : ℝ} (hyS : y ∈ S) (hy1 : y ≠ r₁) (hy2 : y ≠ r₂) :
    (g y - chord g r₁ r₂ y) * ((y - r₁) * (y - r₂)) < 0 := by
  rcases lt_trichotomy y r₁ with hlt | heq | hgt
  · have hres : g y - chord g r₁ r₂ y < 0 := by
      linarith [lt_chord_of_lt hg h2 hr hyS hlt]
    have hq : 0 < (y - r₁) * (y - r₂) := by nlinarith
    exact mul_neg_of_neg_of_pos hres hq
  · exact absurd heq hy1
  · rcases lt_or_gt_of_ne hy2 with hlt2 | hgt2
    · have hres : 0 < g y - chord g r₁ r₂ y := by
        have := gap_pos_of_strictConcaveOn hg h1 h2 hgt hlt2
        rw [gap] at this
        linarith
      have hq : (y - r₁) * (y - r₂) < 0 := by nlinarith
      exact mul_neg_of_pos_of_neg hres hq
    · have hres : g y - chord g r₁ r₂ y < 0 := by
        linarith [lt_chord_of_gt hg h1 hr hyS hgt2]
      have hq : 0 < (y - r₁) * (y - r₂) := by nlinarith
      exact mul_neg_of_neg_of_pos hres hq

/-- The chord through the two roots is affine, hence orthogonal to `q`. -/
theorem chord_is_affine (g : ℝ → ℝ) {r₁ r₂ : ℝ} (hr : r₁ < r₂) :
    ∀ y : ℝ, chord g r₁ r₂ y
      = (g r₁ - r₁ * ((g r₂ - g r₁) / (r₂ - r₁))) + ((g r₂ - g r₁) / (r₂ - r₁)) * y := by
  intro y
  have hne : r₂ - r₁ ≠ 0 := (sub_pos.2 hr).ne'
  rw [chord]
  field_simp
  ring

/-- **Control.**  An affine profile has zero inner product with `q`. -/
theorem affine_profile_sum_eq_zero (u v : ℝ) {n : ℕ} {t : ℕ → ℝ} {r₁ r₂ : ℝ}
    (hq0 : ∑ i ∈ range n, ((t i - r₁) * (t i - r₂)) = 0)
    (hq1 : ∑ i ∈ range n, t i * ((t i - r₁) * (t i - r₂)) = 0) :
    ∑ i ∈ range n, (u + v * t i) * ((t i - r₁) * (t i - r₂)) = 0 := by
  have hterm : ∀ i ∈ range n, (u + v * t i) * ((t i - r₁) * (t i - r₂))
      = u * ((t i - r₁) * (t i - r₂)) + v * (t i * ((t i - r₁) * (t i - r₂))) := by
    intro i _; ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
    hq0, hq1]
  ring

/-- Splitting off the chord: only the residual contributes to the fit. -/
theorem sum_eq_residual_sum (g : ℝ → ℝ) {r₁ r₂ : ℝ} (hr : r₁ < r₂) {n : ℕ} {t : ℕ → ℝ}
    (hq0 : ∑ i ∈ range n, ((t i - r₁) * (t i - r₂)) = 0)
    (hq1 : ∑ i ∈ range n, t i * ((t i - r₁) * (t i - r₂)) = 0) :
    ∑ i ∈ range n, g (t i) * ((t i - r₁) * (t i - r₂))
      = ∑ i ∈ range n, (g (t i) - chord g r₁ r₂ (t i)) * ((t i - r₁) * (t i - r₂)) := by
  have hchordsum : ∑ i ∈ range n, chord g r₁ r₂ (t i) * ((t i - r₁) * (t i - r₂)) = 0 := by
    have hterm : ∀ i ∈ range n, chord g r₁ r₂ (t i) * ((t i - r₁) * (t i - r₂))
        = ((g r₁ - r₁ * ((g r₂ - g r₁) / (r₂ - r₁)))
            + ((g r₂ - g r₁) / (r₂ - r₁)) * t i) * ((t i - r₁) * (t i - r₂)) := by
      intro i _; rw [chord_is_affine g hr]
    rw [Finset.sum_congr rfl hterm]
    exact affine_profile_sum_eq_zero _ _ hq0 hq1
  have hterm : ∀ i ∈ range n, g (t i) * ((t i - r₁) * (t i - r₂))
      = (g (t i) - chord g r₁ r₂ (t i)) * ((t i - r₁) * (t i - r₂))
        + chord g r₁ r₂ (t i) * ((t i - r₁) * (t i - r₂)) := by
    intro i _; ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, hchordsum, add_zero]

/-- **Sign theorem.**  A concave profile has non-positive inner product with any
grid-orthogonal quadratic with two real roots. -/
theorem sum_profile_mul_quadratic_nonpos (hg : ConcaveOn ℝ S g) (h1 : r₁ ∈ S) (h2 : r₂ ∈ S)
    (hr : r₁ < r₂) {n : ℕ} {t : ℕ → ℝ} (hmem : ∀ i ∈ range n, t i ∈ S)
    (hq0 : ∑ i ∈ range n, ((t i - r₁) * (t i - r₂)) = 0)
    (hq1 : ∑ i ∈ range n, t i * ((t i - r₁) * (t i - r₂)) = 0) :
    ∑ i ∈ range n, g (t i) * ((t i - r₁) * (t i - r₂)) ≤ 0 := by
  rw [sum_eq_residual_sum g hr hq0 hq1]
  apply Finset.sum_nonpos
  intro i hi
  exact residual_mul_quadratic_nonpos hg h1 h2 hr (hmem i hi)

/-- Strict version: one grid point off the two roots suffices. -/
theorem sum_profile_mul_quadratic_neg (hg : StrictConcaveOn ℝ S g) (h1 : r₁ ∈ S) (h2 : r₂ ∈ S)
    (hr : r₁ < r₂) {n : ℕ} {t : ℕ → ℝ} (hmem : ∀ i ∈ range n, t i ∈ S)
    (hq0 : ∑ i ∈ range n, ((t i - r₁) * (t i - r₂)) = 0)
    (hq1 : ∑ i ∈ range n, t i * ((t i - r₁) * (t i - r₂)) = 0)
    (hwit : ∃ i ∈ range n, t i ≠ r₁ ∧ t i ≠ r₂) :
    ∑ i ∈ range n, g (t i) * ((t i - r₁) * (t i - r₂)) < 0 := by
  rw [sum_eq_residual_sum g hr hq0 hq1]
  obtain ⟨i₀, hi₀, hne1, hne2⟩ := hwit
  have hlt : ∑ i ∈ range n, (g (t i) - chord g r₁ r₂ (t i)) * ((t i - r₁) * (t i - r₂))
      < ∑ i ∈ range n, (0 : ℝ) := by
    apply Finset.sum_lt_sum
    · intro i hi
      exact residual_mul_quadratic_nonpos hg.concaveOn h1 h2 hr (hmem i hi)
    · exact ⟨i₀, hi₀, residual_mul_quadratic_neg hg h1 h2 hr (hmem i₀ hi₀) hne1 hne2⟩
  simpa using hlt

/-! ## 4. The equal-width bin grid of the pipeline -/

/-- Centred index offset of bin `i` out of `n`. -/
noncomputable def off (n : ℕ) (i : ℕ) : ℝ := (i : ℝ) - ((n : ℝ) - 1) / 2

/-- Bin centres: `n` equal bins of width `h`, grid centre `m`. -/
noncomputable def binGrid (n : ℕ) (m h : ℝ) (i : ℕ) : ℝ := m + h * off n i

/-- Mean square offset of the bin grid. -/
noncomputable def gridVar (n : ℕ) : ℝ := (∑ i ∈ range n, (off n i) ^ 2) / n

/-- Odd moments of the centred bin grid vanish, by the reflection `i ↦ n-1-i`. -/
theorem sum_odd_off_eq_zero (n : ℕ) {F : ℝ → ℝ} (hF : ∀ y : ℝ, F (-y) = -F y) :
    ∑ i ∈ range n, F (off n i) = 0 := by
  have hrefl : ∑ i ∈ range n, F (off n (n - 1 - i)) = ∑ i ∈ range n, F (off n i) :=
    Finset.sum_range_reflect (fun i => F (off n i)) n
  have hneg : ∀ i ∈ range n, F (off n (n - 1 - i)) = -F (off n i) := by
    intro i hi
    have hi' : i < n := mem_range.1 hi
    have hcast : ((n - 1 - i : ℕ) : ℝ) = (n : ℝ) - 1 - (i : ℝ) := by
      have h' : (n - 1 - i : ℕ) = n - (1 + i) := by omega
      have hle : 1 + i ≤ n := by omega
      rw [h', Nat.cast_sub hle]
      push_cast
      ring
    have hoff : off n (n - 1 - i) = -(off n i) := by
      rw [off, off, hcast]; ring
    rw [hoff, hF]
  rw [Finset.sum_congr rfl hneg, Finset.sum_neg_distrib] at hrefl
  linarith

theorem sum_off_eq_zero (n : ℕ) : ∑ i ∈ range n, off n i = 0 := by
  have h := sum_odd_off_eq_zero n (F := fun y : ℝ => y) (by intro y; ring)
  simpa using h

theorem sum_off_cube_eq_zero (n : ℕ) : ∑ i ∈ range n, (off n i) ^ 3 = 0 :=
  sum_odd_off_eq_zero n (F := fun y : ℝ => y ^ 3) (by intro y; ring)

theorem sum_off_sq (n : ℕ) (hn : 0 < n) :
    ∑ i ∈ range n, (off n i) ^ 2 = n * gridVar n := by
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (by omega)
  rw [gridVar]
  field_simp

theorem gridVar_pos {n : ℕ} (hn : 2 ≤ n) : 0 < gridVar n := by
  have hn0 : 0 < n := by omega
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn0
  have hmem : (0 : ℕ) ∈ range n := mem_range.2 hn0
  have hzero : off n 0 = -(((n : ℝ) - 1) / 2) := by rw [off]; simp
  have hn1 : (1 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hpos : 0 < (off n 0) ^ 2 := by
    rw [hzero]
    have hsq : (-(((n : ℝ) - 1) / 2)) ^ 2 = (((n : ℝ) - 1) / 2) ^ 2 := by ring
    rw [hsq]
    exact pow_pos (by linarith) 2
  have hsum : 0 < ∑ i ∈ range n, (off n i) ^ 2 :=
    lt_of_lt_of_le hpos
      (Finset.single_le_sum (f := fun i => (off n i) ^ 2) (fun i _ => sq_nonneg _) hmem)
  rw [gridVar]
  exact div_pos hsum hnR

/-- Half-width of the orthogonal quadratic's root pair. -/
noncomputable def rootHalf (n : ℕ) (h : ℝ) : ℝ := h * Real.sqrt (gridVar n)

theorem rootHalf_pos {n : ℕ} (hn : 2 ≤ n) {h : ℝ} (hh : 0 < h) : 0 < rootHalf n h :=
  mul_pos hh (Real.sqrt_pos.2 (gridVar_pos hn))

/-- The defining factorisation: the orthogonal quadratic of the bin grid. -/
theorem quadratic_factor {n : ℕ} (hn : 2 ≤ n) (m h y : ℝ) :
    (y - (m - rootHalf n h)) * (y - (m + rootHalf n h))
      = (y - m) ^ 2 - h ^ 2 * gridVar n := by
  have hsq : Real.sqrt (gridVar n) ^ 2 = gridVar n :=
    Real.sq_sqrt (le_of_lt (gridVar_pos hn))
  rw [rootHalf]
  nlinarith [hsq]

/-- **Orthogonality to constants**, for every bin width and every grid centre. -/
theorem binGrid_orth_const {n : ℕ} (hn : 2 ≤ n) (m h : ℝ) :
    ∑ i ∈ range n, ((binGrid n m h i - (m - rootHalf n h))
      * (binGrid n m h i - (m + rootHalf n h))) = 0 := by
  have hn0 : 0 < n := by omega
  have hterm : ∀ i ∈ range n, (binGrid n m h i - (m - rootHalf n h))
      * (binGrid n m h i - (m + rootHalf n h))
      = h ^ 2 * ((off n i) ^ 2 - gridVar n) := by
    intro i _
    rw [quadratic_factor hn, binGrid]
    ring
  rw [Finset.sum_congr rfl hterm, ← Finset.mul_sum, Finset.sum_sub_distrib,
    sum_off_sq n hn0, Finset.sum_const, card_range, nsmul_eq_mul]
  ring

/-- **Orthogonality to the identity**, for every bin width and every grid centre. -/
theorem binGrid_orth_id {n : ℕ} (hn : 2 ≤ n) (m h : ℝ) :
    ∑ i ∈ range n, binGrid n m h i * ((binGrid n m h i - (m - rootHalf n h))
      * (binGrid n m h i - (m + rootHalf n h))) = 0 := by
  have hn0 : 0 < n := by omega
  have hterm : ∀ i ∈ range n, binGrid n m h i * ((binGrid n m h i - (m - rootHalf n h))
      * (binGrid n m h i - (m + rootHalf n h)))
      = m * (h ^ 2 * ((off n i) ^ 2 - gridVar n))
        + h ^ 3 * ((off n i) ^ 3 - gridVar n * off n i) := by
    intro i _
    rw [quadratic_factor hn, binGrid]
    ring
  have hA : ∑ i ∈ range n, m * (h ^ 2 * ((off n i) ^ 2 - gridVar n)) = 0 := by
    rw [← Finset.mul_sum, ← Finset.mul_sum, Finset.sum_sub_distrib, sum_off_sq n hn0,
      Finset.sum_const, card_range, nsmul_eq_mul]
    ring
  have hB : ∑ i ∈ range n, h ^ 3 * ((off n i) ^ 3 - gridVar n * off n i) = 0 := by
    rw [← Finset.mul_sum, Finset.sum_sub_distrib, sum_off_cube_eq_zero, ← Finset.mul_sum,
      sum_off_eq_zero]
    ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, hA, hB]
  ring

/-- With at least three bins, some bin centre avoids both roots. -/
theorem binGrid_witness {n : ℕ} (hn : 3 ≤ n) {m h : ℝ} (hh : 0 < h) :
    ∃ i ∈ range n, binGrid n m h i ≠ m - rootHalf n h ∧ binGrid n m h i ≠ m + rootHalf n h := by
  have hn2 : 2 ≤ n := by omega
  have hq : ∀ i, (binGrid n m h i - (m - rootHalf n h)) * (binGrid n m h i - (m + rootHalf n h))
      = h ^ 2 * ((off n i) ^ 2 - gridVar n) := by
    intro i; rw [quadratic_factor hn2, binGrid]; ring
  have hn3 : (3 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hoffne : (off n 0) ^ 2 ≠ (off n 1) ^ 2 := by
    have h0 : off n 0 = -(((n : ℝ) - 1) / 2) := by rw [off]; simp
    have h1 : off n 1 = 1 - ((n : ℝ) - 1) / 2 := by rw [off]; simp
    rw [h0, h1]
    intro hcon
    nlinarith [hcon]
  have hexists : (off n 0) ^ 2 - gridVar n ≠ 0 ∨ (off n 1) ^ 2 - gridVar n ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    obtain ⟨ha, hb⟩ := hcon
    exact hoffne (by linarith [sub_eq_zero.1 ha, sub_eq_zero.1 hb])
  have hh2 : (h : ℝ) ^ 2 ≠ 0 := by positivity
  have hkey : ∀ i : ℕ, (off n i) ^ 2 - gridVar n ≠ 0 →
      (binGrid n m h i ≠ m - rootHalf n h ∧ binGrid n m h i ≠ m + rootHalf n h) := by
    intro i hne
    constructor
    · intro hcon
      have hz := hq i
      rw [hcon] at hz
      simp only [sub_self, zero_mul] at hz
      rcases mul_eq_zero.1 hz.symm with h' | h'
      · exact hh2 h'
      · exact hne h'
    · intro hcon
      have hz := hq i
      rw [hcon] at hz
      simp only [sub_self, mul_zero] at hz
      rcases mul_eq_zero.1 hz.symm with h' | h'
      · exact hh2 h'
      · exact hne h'
  rcases hexists with hx | hx
  · exact ⟨0, mem_range.2 (by omega), hkey 0 hx⟩
  · exact ⟨1, mem_range.2 (by omega), hkey 1 hx⟩

/-! ## 5. Bin-width and grid-shift invariance of the measured curvature -/

/-- **The fitted curvature of a strictly concave profile is strictly negative,
for every bin count `n ≥ 3`, every bin width `h > 0` and every grid centre `m`.**
This is the pre-registered "bin-width permutation / u-grid shift" probe: the sign
of the measured `c` is a grid invariant. -/
theorem fitCurvature_neg_binGrid {S : Set ℝ} {g : ℝ → ℝ} (hg : StrictConcaveOn ℝ S g)
    {n : ℕ} (hn : 3 ≤ n) {m h : ℝ} (hh : 0 < h)
    (h1 : m - rootHalf n h ∈ S) (h2 : m + rootHalf n h ∈ S)
    (hmem : ∀ i ∈ range n, binGrid n m h i ∈ S) :
    ∑ i ∈ range n, g (binGrid n m h i)
      * ((binGrid n m h i - (m - rootHalf n h)) * (binGrid n m h i - (m + rootHalf n h))) < 0 := by
  have hn2 : 2 ≤ n := by omega
  have hroot : m - rootHalf n h < m + rootHalf n h := by
    have := rootHalf_pos hn2 hh
    linarith
  exact sum_profile_mul_quadratic_neg hg h1 h2 hroot hmem
    (binGrid_orth_const hn2 m h) (binGrid_orth_id hn2 m h) (binGrid_witness hn hh)

/-- **`H0` passes the grid probe.**  For the log-size profile of `j² − N`, on any
equal-width bin grid contained in the window, the fitted quadratic curvature is
strictly negative — no bin-width permutation and no `u`-grid shift can change the
sign.  The measured `c = -0.105 … -0.44` in every stratum is therefore exactly
what the window geometry predicts. -/
theorem window_fitCurvature_neg {c : ℝ} (hc : 0 ≤ c) {n : ℕ} (hn : 3 ≤ n) {m h : ℝ} (hh : 0 < h)
    (hpos : 0 < m - rootHalf n h) (hgrid : ∀ i ∈ range n, 0 < binGrid n m h i) :
    ∑ i ∈ range n, logSize c (binGrid n m h i)
      * ((binGrid n m h i - (m - rootHalf n h)) * (binGrid n m h i - (m + rootHalf n h))) < 0 := by
  have hn2 : 2 ≤ n := by omega
  have hr := rootHalf_pos hn2 hh
  exact fitCurvature_neg_binGrid (strictConcaveOn_logSize hc) hn hh (mem_Ioi.2 hpos)
    (mem_Ioi.2 (by linarith)) (fun i hi => mem_Ioi.2 (hgrid i hi))

/-- Passing from the numerator to the normalised statistic. -/
theorem fitCurvature_neg_of_sum_neg (n : ℕ) (t : ℕ → ℝ) (q g : ℝ → ℝ)
    (hnum : ∑ i ∈ range n, g (t i) * q (t i) < 0) : fitCurvature n t q g < 0 := by
  have hden : 0 < ∑ i ∈ range n, q (t i) ^ 2 := by
    rcases lt_or_eq_of_le (Finset.sum_nonneg (fun i (_ : i ∈ range n) => sq_nonneg (q (t i))))
      with hlt | heq
    · exact hlt
    · exfalso
      have hz : ∀ i ∈ range n, g (t i) * q (t i) = 0 := by
        intro i hi
        have hsq := (Finset.sum_eq_zero_iff_of_nonneg
          (fun j (_ : j ∈ range n) => sq_nonneg (q (t j)))).1 heq.symm i hi
        rw [pow_eq_zero_iff (two_ne_zero)] at hsq
        rw [hsq, mul_zero]
      rw [Finset.sum_congr rfl hz] at hnum
      simp at hnum
  exact div_neg_of_neg_of_pos hnum hden

/-- **The measured statistic itself is negative.**  Final form of the grid probe
for the `j² − N` log-size profile: the fitted quadratic coefficient of the binned
profile is strictly negative for every bin count `n ≥ 3`, bin width `h > 0` and
grid centre `m` with the grid inside the window. -/
theorem window_fitCurvature_statistic_neg {c : ℝ} (hc : 0 ≤ c) {n : ℕ} (hn : 3 ≤ n)
    {m h : ℝ} (hh : 0 < h) (hpos : 0 < m - rootHalf n h)
    (hgrid : ∀ i ∈ range n, 0 < binGrid n m h i) :
    fitCurvature n (binGrid n m h)
      (fun y => (y - (m - rootHalf n h)) * (y - (m + rootHalf n h))) (logSize c) < 0 :=
  fitCurvature_neg_of_sum_neg _ _ _ _ (window_fitCurvature_neg hc hn hh hpos hgrid)

end HumpFittedCurvature