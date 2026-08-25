import Mathlib
import Computation.BinwidthUShiftProbe

/-!
# A binning-independent shape test for the mid-window hump

This is the analytic core of the named follow-up of exp 582 / paper 232: *replace the
histogram + local-quadratic-fit pipeline by a binning-free shape statement*.

The observation that makes this possible is an exact identity (`binVal_eq_slidingAvg`):
every histogram bin value of a curve `f` is a *sample of one and the same
offset-independent function*, the box-kernel sliding average

`slidingAvg f w x = w⁻¹ ∫_{x-w/2}^{x+w/2} f`.

Bin width `w` selects the kernel; the grid offset only selects **where** the kernel
average is sampled.  Consequently every question about "does the hump survive a change
of offset?" is a question about the sampling points, never about the statistic.

On top of that identity we prove that box averaging is a *shape-preserving* operator:

* `slidingAvg_symm` — it preserves reflection symmetry about the peak abscissa;
* `slidingAvg_concaveOn` — it preserves concavity;
* `slidingAvg_unimodal` — symmetric + concave gives exact unimodality, hence
* `slidingAvg_argmax` : the sliding average is maximised **exactly** at the true peak,
  for **every** bin width, and
* `binVal_le_peak` : every histogram cell of every grid is bounded by the single
  number `slidingAvg f w xs`, and
* `closest_bin_dominates` : for every offset the argmax bin is exactly the bin whose
  centre is closest to the peak.

The last statement upgrades the `O(w)` transport bound of `BinwidthUShiftProbe`
(`argmax_bin_near_peak`) to an *exact* rigid-transport law under a symmetry hypothesis,
and is the precise form in which the empirical "`vx + sh` pinned to `0.6482–0.6492`
across all five shifts" would be predicted.
-/

namespace Catalog.Computation.BinwidthUShiftShape

open Set MeasureTheory
open Catalog.Computation.BinwidthUShift

/-- The box-kernel sliding average: the binning-free statistic. -/
noncomputable def slidingAvg (f : ℝ → ℝ) (w x : ℝ) : ℝ :=
  w⁻¹ * ∫ s in (x - w / 2)..(x + w / 2), f s

/-! ### The identity that removes the grid offset from the discussion -/

/-- **Every histogram cell is a sample of the offset-free sliding average.**
The bin width chooses the kernel; the offset chooses only the sampling point. -/
theorem binVal_eq_slidingAvg (f : ℝ → ℝ) (o w : ℝ) (i : ℤ) :
    binVal f o w i = slidingAvg f w (binCenter o w i) := by
  unfold binVal binAvg slidingAvg binCenter
  congr 2 <;> ring

/-- Centred form of the sliding average. -/
theorem slidingAvg_centered (f : ℝ → ℝ) (w x : ℝ) :
    slidingAvg f w x = w⁻¹ * ∫ s in (-(w / 2))..(w / 2), f (x + s) := by
  unfold slidingAvg
  congr 1
  rw [intervalIntegral.integral_comp_add_left (fun s => f s) x]
  congr 1

/-! ### Shape preservation -/

/-- Box averaging preserves reflection symmetry about `xs`. -/
theorem slidingAvg_symm {f : ℝ → ℝ} {xs : ℝ} (hsym : ∀ x, f (2 * xs - x) = f x) (w x : ℝ) :
    slidingAvg f w (2 * xs - x) = slidingAvg f w x := by
  unfold slidingAvg
  congr 1
  have h1 : (∫ s in (2 * xs - x - w / 2)..(2 * xs - x + w / 2), f s)
      = ∫ s in (2 * xs - x - w / 2)..(2 * xs - x + w / 2), f (2 * xs - s) := by
    refine intervalIntegral.integral_congr ?_
    intro s _
    exact (hsym s).symm
  rw [h1, intervalIntegral.integral_comp_sub_left (fun s => f s) (2 * xs)]
  congr 1 <;> ring

/-- Box averaging preserves concavity. -/
theorem slidingAvg_concave {f : ℝ → ℝ} (hf : Continuous f) {w : ℝ} (hw : 0 < w)
    (hconc : ∀ x y a b : ℝ, 0 ≤ a → 0 ≤ b → a + b = 1 →
      a * f x + b * f y ≤ f (a * x + b * y)) :
    ∀ x y a b : ℝ, 0 ≤ a → 0 ≤ b → a + b = 1 →
      a * slidingAvg f w x + b * slidingAvg f w y ≤ slidingAvg f w (a * x + b * y) := by
  intro x y a b ha hb hab
  have hle : -(w / 2) ≤ w / 2 := by linarith
  have hix : IntervalIntegrable (fun s => f (x + s)) volume (-(w / 2)) (w / 2) :=
    (hf.comp (continuous_const.add continuous_id)).intervalIntegrable _ _
  have hiy : IntervalIntegrable (fun s => f (y + s)) volume (-(w / 2)) (w / 2) :=
    (hf.comp (continuous_const.add continuous_id)).intervalIntegrable _ _
  have hiz : IntervalIntegrable (fun s => f (a * x + b * y + s)) volume (-(w / 2)) (w / 2) :=
    (hf.comp (continuous_const.add continuous_id)).intervalIntegrable _ _
  have hsum : IntervalIntegrable (fun s => a * f (x + s) + b * f (y + s)) volume
      (-(w / 2)) (w / 2) := (hix.const_mul a).add (hiy.const_mul b)
  have hpt : ∀ s ∈ Icc (-(w / 2)) (w / 2),
      a * f (x + s) + b * f (y + s) ≤ f (a * x + b * y + s) := by
    intro s _
    have h := hconc (x + s) (y + s) a b ha hb hab
    have hs : a * s + b * s = s := by
      rw [← add_mul, hab, one_mul]
    have hre : a * (x + s) + b * (y + s) = a * x + b * y + s := by linarith [hs]
    rwa [hre] at h
  have hmono : (∫ s in (-(w / 2))..(w / 2), (a * f (x + s) + b * f (y + s)))
      ≤ ∫ s in (-(w / 2))..(w / 2), f (a * x + b * y + s) :=
    intervalIntegral.integral_mono_on hle hsum hiz hpt
  rw [intervalIntegral.integral_add (hix.const_mul a) (hiy.const_mul b),
    intervalIntegral.integral_const_mul, intervalIntegral.integral_const_mul] at hmono
  rw [slidingAvg_centered, slidingAvg_centered, slidingAvg_centered]
  have hwinv : 0 < w⁻¹ := by positivity
  nlinarith [hmono, hwinv]

/-- A symmetric concave function is unimodal: values decrease with distance from the
centre of symmetry. -/
theorem symm_concave_unimodal {g : ℝ → ℝ} {xs : ℝ}
    (hsym : ∀ x, g (2 * xs - x) = g x)
    (hconc : ∀ x y a b : ℝ, 0 ≤ a → 0 ≤ b → a + b = 1 →
      a * g x + b * g y ≤ g (a * x + b * y))
    {u v : ℝ} (huv : |u - xs| ≤ |v - xs|) : g v ≤ g u := by
  rcases eq_or_lt_of_le (abs_nonneg (v - xs)) with hv0 | hv0
  · -- `v = xs` forces `u = xs`
    have hvx : v = xs := by
      have h0 : |v - xs| = 0 := hv0.symm
      have := abs_eq_zero.mp h0; linarith
    have hux : u = xs := by
      have h0 : |u - xs| = 0 :=
        le_antisymm (by rw [← hv0] at huv; exact huv) (abs_nonneg _)
      have := abs_eq_zero.mp h0; linarith
    rw [hvx, hux]
  · -- write `u - xs` as a convex combination of `±(v - xs)`
    set t := v - xs with ht
    set r := u - xs with hr
    have habs : |r| ≤ |t| := huv
    have htpos : 0 < |t| := hv0
    have htne : t ≠ 0 := by
      intro h; rw [h] at htpos; simp at htpos
    have hdiv : |r / t| ≤ 1 := by
      rw [abs_div, div_le_one htpos]; exact habs
    have hd1 : -1 ≤ r / t := by linarith [neg_abs_le (r / t), hdiv]
    have hd2 : r / t ≤ 1 := le_trans (le_abs_self _) hdiv
    set lam := (1 / 2 : ℝ) + (r / t) / 2 with hlam
    have hla : 0 ≤ lam := by rw [hlam]; linarith
    have hlb : 0 ≤ 1 - lam := by rw [hlam]; linarith
    have hcomb : lam * (xs + t) + (1 - lam) * (xs - t) = u := by
      have e1 : lam * (xs + t) + (1 - lam) * (xs - t) = xs + (2 * lam - 1) * t := by ring
      have e2 : (2 * lam - 1) * t = r := by rw [hlam]; field_simp; ring
      rw [e1, e2, hr]; ring
    have hgsym : g (xs - t) = g (xs + t) := by
      have := hsym (xs + t)
      have he : 2 * xs - (xs + t) = xs - t := by ring
      rw [he] at this
      exact this
    have := hconc (xs + t) (xs - t) lam (1 - lam) hla hlb (by ring)
    rw [hcomb, hgsym] at this
    have hvv : xs + t = v := by rw [ht]; ring
    rw [hvv] at this
    nlinarith [this, hla, hlb]

/-! ### Consequences: exact binning-independence of the vertex -/

variable {f : ℝ → ℝ} {xs w : ℝ}

/-- **The sliding average is maximised exactly at the true peak, for every bin width.**
No `O(w)` slack: box averaging of a symmetric concave curve cannot move the vertex. -/
theorem slidingAvg_argmax (hf : Continuous f) (hw : 0 < w)
    (hsym : ∀ x, f (2 * xs - x) = f x)
    (hconc : ∀ x y a b : ℝ, 0 ≤ a → 0 ≤ b → a + b = 1 →
      a * f x + b * f y ≤ f (a * x + b * y)) (x : ℝ) :
    slidingAvg f w x ≤ slidingAvg f w xs := by
  refine symm_concave_unimodal (g := slidingAvg f w) (xs := xs)
    (slidingAvg_symm hsym w) (slidingAvg_concave hf hw hconc) ?_
  simp

/-- **A single number caps every cell of every grid.**  For all bin widths and all grid
offsets, no histogram cell can exceed the binning-free amplitude `slidingAvg f w xs`. -/
theorem binVal_le_peak (hf : Continuous f) (hw : 0 < w)
    (hsym : ∀ x, f (2 * xs - x) = f x)
    (hconc : ∀ x y a b : ℝ, 0 ≤ a → 0 ≤ b → a + b = 1 →
      a * f x + b * f y ≤ f (a * x + b * y)) (o : ℝ) (i : ℤ) :
    binVal f o w i ≤ slidingAvg f w xs := by
  rw [binVal_eq_slidingAvg]
  exact slidingAvg_argmax hf hw hsym hconc _

/-- **Exact rigid transport.**  For every grid offset, the bin whose centre is closer to
the true peak has the larger value.  Hence the argmax bin of every shifted grid is the
bin nearest the peak, and its absolute centre — not its label — is the invariant. -/
theorem closest_bin_dominates (hf : Continuous f) (hw : 0 < w)
    (hsym : ∀ x, f (2 * xs - x) = f x)
    (hconc : ∀ x y a b : ℝ, 0 ≤ a → 0 ≤ b → a + b = 1 →
      a * f x + b * f y ≤ f (a * x + b * y)) (o : ℝ) (i j : ℤ)
    (hij : |binCenter o w i - xs| ≤ |binCenter o w j - xs|) :
    binVal f o w j ≤ binVal f o w i := by
  rw [binVal_eq_slidingAvg, binVal_eq_slidingAvg]
  exact symm_concave_unimodal (g := slidingAvg f w) (xs := xs)
    (slidingAvg_symm hsym w) (slidingAvg_concave hf hw hconc) hij


/-! ### An exact closed form: the binning bias of a parabolic hump

For the canonical smooth hump `f s = c - k (s - xs)^2` the sliding average can be
computed exactly, and the answer separates completely into "shape" and "bin width":
the parabola is reproduced verbatim and the amplitude is deflated by exactly
`k w^2 / 12`, with **no** dependence on the grid offset.  This is the closed-form
version of the "estimator stricter than phenomenon" gap of exp 582: the width term is
a deterministic, computable deflation, not evidence against the feature. -/

theorem slidingAvg_quadratic (c k xs w x : ℝ) (hw : 0 < w) :
    slidingAvg (fun s => c - k * (s - xs) ^ 2) w x
      = c - k * ((x - xs) ^ 2 + w ^ 2 / 12) := by
  have hcont : Continuous fun s : ℝ => (s - xs) ^ 2 :=
    (continuous_id.sub continuous_const).pow 2
  have hquad : ∀ a b d : ℝ, (∫ s in a..b, (s - d) ^ 2) = ((b - d) ^ 3 - (a - d) ^ 3) / 3 := by
    intro a b d
    have h := intervalIntegral.integral_comp_sub_right (a := a) (b := b) (fun s : ℝ => s ^ 2) d
    simp only at h
    rw [h, integral_pow]
    norm_num
  have hI : (∫ s in (x - w / 2)..(x + w / 2), (c - k * (s - xs) ^ 2))
      = (∫ _s in (x - w / 2)..(x + w / 2), c)
        - ∫ s in (x - w / 2)..(x + w / 2), k * (s - xs) ^ 2 :=
    intervalIntegral.integral_sub intervalIntegrable_const
      ((continuous_const.mul hcont).intervalIntegrable _ _)
  unfold slidingAvg
  rw [hI, intervalIntegral.integral_const_mul, hquad, intervalIntegral.integral_const,
    smul_eq_mul]
  have hne : w ≠ 0 := ne_of_gt hw
  field_simp
  ring

/-- **Exact vertex preservation and exact amplitude deflation.**  For a parabolic hump
the box-averaged curve peaks exactly at `xs` for every bin width, with amplitude
`c - k w^2 / 12`.  Two bin widths therefore differ by the explicit, offset-free
quantity `k (w₁^2 - w₂^2)/12`. -/
theorem slidingAvg_quadratic_peak (c k xs w : ℝ) (hw : 0 < w) :
    slidingAvg (fun s => c - k * (s - xs) ^ 2) w xs = c - k * w ^ 2 / 12 := by
  rw [slidingAvg_quadratic c k xs w xs hw]; ring

theorem slidingAvg_quadratic_width_gap (c k xs w₁ w₂ : ℝ) (hw₁ : 0 < w₁) (hw₂ : 0 < w₂) :
    slidingAvg (fun s => c - k * (s - xs) ^ 2) w₁ xs
      - slidingAvg (fun s => c - k * (s - xs) ^ 2) w₂ xs
      = k * (w₂ ^ 2 - w₁ ^ 2) / 12 := by
  rw [slidingAvg_quadratic_peak c k xs w₁ hw₁, slidingAvg_quadratic_peak c k xs w₂ hw₂]
  ring


/-! ### A parameter-free curvature-sign certificate on the histogram

The local-quadratic fit of exp 582 needed three points *and* a non-degenerate curvature
estimate.  The discrete second difference of consecutive bin values needs neither: for a
concave curve it is nonpositive for **every** bin width and **every** grid offset, with
no fitted parameter to become degenerate.  This is the cheap end of the named follow-up
("binning-independent shape test"). -/

theorem slidingAvg_second_difference_nonpos (hf : Continuous f) (hw : 0 < w)
    (hconc : ∀ x y a b : ℝ, 0 ≤ a → 0 ≤ b → a + b = 1 →
      a * f x + b * f y ≤ f (a * x + b * y)) (x : ℝ) :
    slidingAvg f w (x + w) - 2 * slidingAvg f w x + slidingAvg f w (x - w) ≤ 0 := by
  have hmid : (1 / 2 : ℝ) * (x + w) + (1 / 2 : ℝ) * (x - w) = x := by ring
  have h := slidingAvg_concave hf hw hconc (x + w) (x - w) (1 / 2) (1 / 2)
    (by norm_num) (by norm_num) (by norm_num)
  rw [hmid] at h
  linarith

/-- The same certificate stated on the raw histogram: consecutive bin centres differ by
exactly one bin width, so the discrete curvature of the bin values of a concave curve is
nonpositive for every offset and every width. -/
theorem binVal_second_difference_nonpos (hf : Continuous f) (hw : 0 < w)
    (hconc : ∀ x y a b : ℝ, 0 ≤ a → 0 ≤ b → a + b = 1 →
      a * f x + b * f y ≤ f (a * x + b * y)) (o : ℝ) (i : ℤ) :
    binVal f o w (i + 1) - 2 * binVal f o w i + binVal f o w (i - 1) ≤ 0 := by
  have hup : binCenter o w (i + 1) = binCenter o w i + w := by
    unfold binCenter; push_cast; ring
  have hdn : binCenter o w (i - 1) = binCenter o w i - w := by
    unfold binCenter; push_cast; ring
  rw [binVal_eq_slidingAvg, binVal_eq_slidingAvg, binVal_eq_slidingAvg, hup, hdn]
  exact slidingAvg_second_difference_nonpos hf hw hconc _

end Catalog.Computation.BinwidthUShiftShape