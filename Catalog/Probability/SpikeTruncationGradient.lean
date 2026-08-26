import Mathlib

/-!
# A monotone size density manufactures an "edge" component at a truncation
boundary — and only there

Fifth component of the round-85 resolution.  After the tiny-`v` stratum is
removed by the truncation `v ≥ 2^95`, a residual left-edge weight survives in
the *pooled* kept fit.  Stratifying by bit length localises it entirely in the
band `[96, 98)` adjacent to the truncation boundary, with nothing at `≥ 98`.
This file proves that such a pattern is exactly what a *monotone size density*
produces, with no positional mechanism at all.

Model.  A band of `2m` consecutive size cells carries weights `f 0, …, f (2m-1)`.
The "edge excess" is the lower half's mass minus the upper half's.

Main results.

* `Spike.Gradient.edgeExcess_nonneg` — for any antitone (nonincreasing) size
  density the edge excess is nonnegative: a spurious left-edge weight is
  automatic.
* `Spike.Gradient.edgeExcess_eq_zero_of_flat` — a flat density gives exactly
  zero edge excess: the effect is a gradient effect, not an edge effect.
* `Spike.Gradient.geometric_relativeEdge` — for the geometric density
  `f i = r ^ i` the *relative* edge excess is exactly `(1 − r^m)/(1 + r^m)`.
* `Spike.Gradient.relativeEdge_strictAnti` — that quantity is strictly
  decreasing in `r`: the flatter the local density, the weaker the apparent
  edge component.
* `Spike.Gradient.relativeEdge_le_linear` — the quantitative decay
  `(1 − r^m)/(1 + r^m) ≤ m (1 − r)`, so at fixed band width the apparent edge
  weight is `O(1 − r)`: it vanishes as the density flattens away from the
  truncation boundary.

Together with `Catalog/Probability/SpikeStratifiedEvidence.lean` (pooled
evidence ≤ stratified evidence + null gap) this identifies the surviving
"persistence" as a truncation-boundary size gradient.
-/

namespace Spike.Gradient

/-- Mass of the lower half of a band of `2m` size cells. -/
def lowerSum (f : ℕ → ℝ) (m : ℕ) : ℝ := ∑ i ∈ Finset.range m, f i

/-- Mass of the upper half of a band of `2m` size cells. -/
def upperSum (f : ℕ → ℝ) (m : ℕ) : ℝ := ∑ i ∈ Finset.Ico m (2 * m), f i

/-- The apparent left-edge excess of the band. -/
def edgeExcess (f : ℕ → ℝ) (m : ℕ) : ℝ := lowerSum f m - upperSum f m

theorem upperSum_eq (f : ℕ → ℝ) (m : ℕ) :
    upperSum f m = ∑ i ∈ Finset.range m, f (m + i) := by
  simp only [upperSum]
  rw [Finset.sum_Ico_eq_sum_range, show 2 * m - m = m by omega]

/-- **A nonincreasing size density always produces a nonnegative edge
excess.**  No positional mechanism is needed. -/
theorem edgeExcess_nonneg {f : ℕ → ℝ} (hf : ∀ i j, i ≤ j → f j ≤ f i) (m : ℕ) :
    0 ≤ edgeExcess f m := by
  simp only [edgeExcess, lowerSum, upperSum_eq]
  have : ∑ i ∈ Finset.range m, f (m + i) ≤ ∑ i ∈ Finset.range m, f i :=
    Finset.sum_le_sum fun i _ => hf i (m + i) (by omega)
  linarith

/-- A flat density gives exactly zero edge excess: the effect is driven by the
*gradient*, not by the edge. -/
theorem edgeExcess_eq_zero_of_flat (c : ℝ) (m : ℕ) :
    edgeExcess (fun _ => c) m = 0 := by
  simp [edgeExcess, lowerSum, upperSum_eq]

/-- Strict version: if the density strictly decreases across the band, the
apparent edge excess is strictly positive. -/
theorem edgeExcess_pos {f : ℕ → ℝ} (hf : ∀ i j, i ≤ j → f j ≤ f i) {m : ℕ} (hm : 0 < m)
    (hstrict : f (m + 0) < f 0) : 0 < edgeExcess f m := by
  simp only [edgeExcess, lowerSum, upperSum_eq]
  have hlt : ∑ i ∈ Finset.range m, f (m + i) < ∑ i ∈ Finset.range m, f i := by
    refine Finset.sum_lt_sum (fun i _ => hf i (m + i) (by omega)) ?_
    exact ⟨0, Finset.mem_range.mpr hm, hstrict⟩
  linarith

/-! ### The geometric (Dickman-like) local density -/

/-- The relative edge excess of a geometric density. -/
noncomputable def relativeEdge (r : ℝ) (m : ℕ) : ℝ := (1 - r ^ m) / (1 + r ^ m)

theorem geom_lowerSum (r : ℝ) (hr : r ≠ 1) (m : ℕ) :
    lowerSum (fun i => r ^ i) m = (1 - r ^ m) / (1 - r) := by
  simp only [lowerSum]
  rw [geom_sum_eq hr, div_eq_div_iff (sub_ne_zero.mpr hr) (sub_ne_zero.mpr (Ne.symm hr))]
  ring

theorem geom_upperSum (r : ℝ) (hr : r ≠ 1) (m : ℕ) :
    upperSum (fun i => r ^ i) m = r ^ m * ((1 - r ^ m) / (1 - r)) := by
  rw [upperSum_eq]
  have : ∑ i ∈ Finset.range m, r ^ (m + i) = r ^ m * ∑ i ∈ Finset.range m, r ^ i := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by rw [pow_add]
  rw [this, ← lowerSum, geom_lowerSum r hr m]

/-- **Exact relative edge excess of a geometric density.**  The apparent
left-edge weight of the band equals `(1 − r^m)/(1 + r^m)`, a pure function of
the local decay rate. -/
theorem geometric_relativeEdge (r : ℝ) (hr0 : 0 < r) (hr : r < 1) {m : ℕ} (hm : 0 < m) :
    edgeExcess (fun i => r ^ i) m
      / (lowerSum (fun i => r ^ i) m + upperSum (fun i => r ^ i) m)
      = relativeEdge r m := by
  have hrne : r ≠ 1 := ne_of_lt hr
  have hpos : 0 < 1 - r := by linarith
  have hrm : r ^ m < 1 := pow_lt_one₀ hr0.le hr (by omega)
  have hrmpos : 0 < r ^ m := pow_pos hr0 m
  have h1 : (0:ℝ) < 1 + r ^ m := by linarith
  simp only [edgeExcess, geom_lowerSum r hrne, geom_upperSum r hrne, relativeEdge]
  rw [div_eq_div_iff]
  · ring
  · have hrw : (1 - r ^ m) / (1 - r) + r ^ m * ((1 - r ^ m) / (1 - r))
        = (1 + r ^ m) * ((1 - r ^ m) / (1 - r)) := by ring
    rw [hrw]
    have : 0 < (1 - r ^ m) / (1 - r) := div_pos (by linarith) hpos
    exact ne_of_gt (mul_pos h1 this)
  · exact ne_of_gt h1

/-- The apparent edge weight is strictly decreasing in the local decay
parameter: flatter density, weaker edge. -/
theorem relativeEdge_strictAnti {r r' : ℝ} (hr0 : 0 ≤ r) (hlt : r < r')
    {m : ℕ} (hm : 0 < m) : relativeEdge r' m < relativeEdge r m := by
  have hr'0 : 0 ≤ r' := le_trans hr0 hlt.le
  have hpow : r ^ m < r' ^ m := pow_lt_pow_left₀ hlt hr0 (by omega)
  have h1 : (0:ℝ) < 1 + r ^ m := by positivity
  have h2 : (0:ℝ) < 1 + r' ^ m := by positivity
  simp only [relativeEdge]
  rw [div_lt_div_iff₀ h2 h1]
  nlinarith

/-- Quantitative decay: the apparent edge weight of a band of width `2m` is at
most `m (1 − r)`.  Away from the truncation boundary, where the size density is
locally flat (`r → 1`), it vanishes. -/
theorem relativeEdge_le_linear {r : ℝ} (hr0 : 0 ≤ r) (hr : r ≤ 1) (m : ℕ) :
    relativeEdge r m ≤ m * (1 - r) := by
  have hkey : 1 - r ^ m ≤ m * (1 - r) := by
    induction m with
    | zero => simp
    | succ k ih =>
        have hk : r ^ k ≤ 1 := pow_le_one₀ hr0 hr
        have : 1 - r ^ (k + 1) = (1 - r ^ k) + r ^ k * (1 - r) := by ring
        rw [this]
        have h2 : r ^ k * (1 - r) ≤ 1 * (1 - r) := by
          apply mul_le_mul_of_nonneg_right hk (by linarith)
        push_cast
        nlinarith
  have hrm : 0 ≤ r ^ m := pow_nonneg hr0 m
  have hden : (1:ℝ) ≤ 1 + r ^ m := by linarith
  have hnum : 0 ≤ 1 - r ^ m := by
    have : r ^ m ≤ 1 := pow_le_one₀ hr0 hr
    linarith
  calc relativeEdge r m = (1 - r ^ m) / (1 + r ^ m) := rfl
    _ ≤ (1 - r ^ m) / 1 := by
        apply div_le_div_of_nonneg_left hnum (by norm_num) hden
    _ = 1 - r ^ m := by ring
    _ ≤ m * (1 - r) := hkey

end Spike.Gradient