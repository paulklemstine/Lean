/-
  # The Alcubierre warp-drive metric: causal structure

  Alcubierre's warp-drive line element is

      ds² = -dt² + (dx - v_s f(r_s) dt)² + dy² + dz² ,

  i.e. a `3+1` (ADM) metric with unit lapse `α = 1`, flat spatial slices `γ_ij = δ_ij`
  and shift vector `β = (-v_s f(r_s), 0, 0)`.  Everything about the *pointwise* causal
  structure of this metric is controlled by the single scalar

      w := v_s · f(r_s)          ("local warp factor"),

  so this file develops the algebra and the causal theory of the one–parameter family
  of quadratic forms

      Q_w(u) = -(u⁰)² + (u¹ - w u⁰)² + (u²)² + (u³)² .

  Main results (all proved, no axioms beyond Mathlib's):

  * `metricMatrix_congr` / `det_metricMatrix` — the metric is, at every event and for every
    warp factor `w`, the pull-back of the Minkowski metric along a *unimodular* shear.
    Hence it is a genuine Lorentzian metric of signature `(-,+,+,+)` and determinant `-1`:
    the Alcubierre ansatz never degenerates, so `G_{μν} = 8π T_{μν}` determines a
    stress-energy tensor everywhere (see `AlcubierreEnergy.lean` for its sign).
  * `ship_tangent_unit`, `ship_proper_time` — the worldline of the ship, sitting at `f = 1`,
    is a *unit timelike* curve for **every** value of `v_s`, however large.  Its proper
    time equals coordinate time.
  * `apparent_ftl_without_local_ftl` — the combination that makes the warp drive
    interesting: arbitrarily large coordinate velocity, yet local speed `0` relative to the
    Eulerian observers, and every causal vector obeys the strict local speed bound
    `local_speed_lt_one`.
  * `no_closed_causal_curve` — chronology protection for the Alcubierre ansatz: **no**
    closed causal curve exists, for *any* warp profile whatsoever.  The proof is Rolle's
    theorem applied to the coordinate time `t`, which is a global time function because
    `g^{tt} = -1 < 0`.
  * `warp_horizon_falls_behind` — the causal-control obstruction: in the region where
    `f < 1 - 1/v_s` (present as soon as `v_s > 1`), every future-directed causal curve
    falls strictly behind the bubble centre.  This is the horizon that makes a
    superluminal bubble uncontrollable from inside.
-/

import Mathlib

open Matrix Set

namespace Catalog.Physics.Spacetime.Alcubierre

/-! ## The metric as a matrix -/

/-- The covariant components `g_{μν}` of the Alcubierre metric at an event where the
local warp factor is `w = v_s f(r_s)`, in coordinates `(t, x, y, z)`. -/
def metricMatrix (w : ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![w ^ 2 - 1, -w, 0, 0;
     -w,        1, 0, 0;
     0,         0, 1, 0;
     0,         0, 0, 1]

/-- The Minkowski metric `η = diag(-1,1,1,1)`. -/
def minkowskiMatrix : Matrix (Fin 4) (Fin 4) ℝ :=
  !![-1, 0, 0, 0;
      0, 1, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1]

/-- The unimodular shear `S_w : (t,x,y,z) ↦ (t, x - w t, y, z)` that trivialises the
Alcubierre metric. -/
def shearMatrix (w : ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1,  0, 0, 0;
     -w, 1, 0, 0;
     0,  0, 1, 0;
     0,  0, 0, 1]

/-- The line element `ds²` evaluated on a tangent vector `u`. -/
def lineElement (w : ℝ) (u : Fin 4 → ℝ) : ℝ := u ⬝ᵥ (metricMatrix w *ᵥ u)

@[simp] lemma lineElement_eq (w : ℝ) (u : Fin 4 → ℝ) :
    lineElement w u = -(u 0) ^ 2 + (u 1 - w * u 0) ^ 2 + (u 2) ^ 2 + (u 3) ^ 2 := by
  simp [lineElement, metricMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_four]
  ring

/-- **The Alcubierre metric is Minkowski in disguise, pointwise.**
At every event, `g = Sᵀ η S` for the shear `S = shearMatrix w`. -/
theorem metricMatrix_congr (w : ℝ) :
    (shearMatrix w)ᵀ * minkowskiMatrix * shearMatrix w = metricMatrix w := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    (simp [shearMatrix, minkowskiMatrix, metricMatrix, Matrix.mul_apply, Fin.sum_univ_four]
     try ring)

/-- The trivialising shear is unimodular: it preserves the spacetime volume element. -/
@[simp] theorem det_shearMatrix (w : ℝ) : (shearMatrix w).det = 1 := by
  simp [shearMatrix, Matrix.det_succ_row_zero, Fin.sum_univ_succ]

/-- `det g = -1` for every warp factor: the Alcubierre metric is nowhere degenerate,
so the Einstein tensor (and hence the required stress-energy) is defined everywhere. -/
@[simp] theorem det_metricMatrix (w : ℝ) : (metricMatrix w).det = -1 := by
  simp [metricMatrix, Matrix.det_succ_row_zero, Fin.sum_univ_succ, Fin.succAbove]
  ring

/-- Nondegeneracy in invertible form. -/
theorem isUnit_det_metricMatrix (w : ℝ) : IsUnit (metricMatrix w).det := by
  rw [det_metricMatrix]
  exact isUnit_one.neg

/-- **Lorentzian signature.**  For every warp factor the metric has signature `(-,+,+,+)`:
it is congruent to `η` through an invertible (indeed unimodular) matrix. -/
theorem lorentzian_signature (w : ℝ) :
    ∃ S : Matrix (Fin 4) (Fin 4) ℝ, S.det = 1 ∧ Sᵀ * minkowskiMatrix * S = metricMatrix w :=
  ⟨shearMatrix w, det_shearMatrix w, metricMatrix_congr w⟩

/-- The quadratic form is the Minkowski form of the sheared vector: this is the coordinate
version of `metricMatrix_congr`. -/
theorem lineElement_eq_minkowski (w : ℝ) (u : Fin 4 → ℝ) :
    lineElement w u
      = (shearMatrix w *ᵥ u) ⬝ᵥ (minkowskiMatrix *ᵥ (shearMatrix w *ᵥ u)) := by
  simp [shearMatrix, minkowskiMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_four]
  ring

/-! ## Causal vectors -/

/-- A tangent vector is causal when `ds² ≤ 0`. -/
def IsCausal (w : ℝ) (u : Fin 4 → ℝ) : Prop := lineElement w u ≤ 0

/-- A tangent vector is timelike when `ds² < 0`. -/
def IsTimelike (w : ℝ) (u : Fin 4 → ℝ) : Prop := lineElement w u < 0

theorem IsTimelike.isCausal {w : ℝ} {u : Fin 4 → ℝ} (h : IsTimelike w u) : IsCausal w u :=
  le_of_lt h

/-- A nonzero causal vector has nonzero time component: coordinate time is a global time
function (equivalently `g^{tt} = -1 < 0`). -/
theorem time_component_ne_zero {w : ℝ} {u : Fin 4 → ℝ} (hc : IsCausal w u)
    (hu : ¬ (u 0 = 0 ∧ u 1 = 0 ∧ u 2 = 0 ∧ u 3 = 0)) : u 0 ≠ 0 := by
  intro h0
  refine hu ⟨h0, ?_, ?_, ?_⟩ <;>
  · have hQ : lineElement w u ≤ 0 := hc
    rw [lineElement_eq, h0] at hQ
    nlinarith [sq_nonneg (u 1), sq_nonneg (u 2), sq_nonneg (u 3)]

/-- A timelike vector has nonzero time component. -/
theorem IsTimelike.time_ne_zero {w : ℝ} {u : Fin 4 → ℝ} (h : IsTimelike w u) : u 0 ≠ 0 := by
  intro h0
  have hQ : lineElement w u < 0 := h
  rw [lineElement_eq, h0] at hQ
  nlinarith [sq_nonneg (u 1), sq_nonneg (u 2), sq_nonneg (u 3)]

/-- **No local FTL.**  Relative to the Eulerian observers (whose four-velocity is
`n = (1, w, 0, 0)`), every timelike vector moves with speed strictly less than `1`:
the coordinate `x`-velocity is confined to the interval `(w - 1, w + 1)`. -/
theorem local_speed_lt_one {w : ℝ} {u : Fin 4 → ℝ} (h : IsTimelike w u) :
    |u 1 / u 0 - w| < 1 := by
  have h0 : u 0 ≠ 0 := h.time_ne_zero
  have hQ : -(u 0) ^ 2 + (u 1 - w * u 0) ^ 2 + (u 2) ^ 2 + (u 3) ^ 2 < 0 := by
    have := h; rwa [IsTimelike, lineElement_eq] at this
  have hsq : (u 1 / u 0 - w) ^ 2 < 1 := by
    have hpos : (0:ℝ) < (u 0) ^ 2 := by positivity
    have key : (u 1 - w * u 0) ^ 2 < (u 0) ^ 2 := by
      nlinarith [sq_nonneg (u 2), sq_nonneg (u 3)]
    have : (u 1 / u 0 - w) ^ 2 = (u 1 - w * u 0) ^ 2 / (u 0) ^ 2 := by
      field_simp
    rw [this, div_lt_one hpos]
    exact key
  exact (sq_lt_one_iff_abs_lt_one _).mp hsq

/-- The Eulerian observer four-velocity `n = (1, w, 0, 0)` is a unit timelike vector. -/
@[simp] theorem eulerian_unit (w : ℝ) : lineElement w ![1, w, 0, 0] = -1 := by
  simp [lineElement_eq]

theorem eulerian_timelike (w : ℝ) : IsTimelike w ![1, w, 0, 0] := by
  rw [IsTimelike, eulerian_unit]; norm_num

/-! ## The ship: superluminal coordinate speed with unit proper time -/

/-- **The ship's tangent vector is a unit timelike vector for every warp speed.**
At the centre of the bubble `f = 1`, so `w = v_s`, and the tangent to the worldline
`t ↦ (t, x_s(t), 0, 0)` with `dx_s/dt = v_s` is `(1, v_s, 0, 0)`. -/
@[simp] theorem ship_tangent_unit (v : ℝ) : lineElement v ![1, v, 0, 0] = -1 :=
  eulerian_unit v

/-- Consequently the ship's proper time equals coordinate time: it is *comoving* with the
Eulerian observers, at zero local speed, no matter how large `v_s` is. -/
theorem ship_proper_time (v : ℝ) : Real.sqrt (-(lineElement v ![1, v, 0, 0])) = 1 := by
  simp

/-- **Effective FTL without local FTL.**  For every warp speed `v_s` (superluminal or not)
the ship's four-velocity is unit timelike, its coordinate velocity is exactly `v_s`
(unbounded), and yet its velocity relative to the local Eulerian observer vanishes. -/
theorem apparent_ftl_without_local_ftl (v : ℝ) :
    IsTimelike v ![1, v, 0, 0] ∧
    (![1, v, 0, 0] : Fin 4 → ℝ) 1 / (![1, v, 0, 0] : Fin 4 → ℝ) 0 = v ∧
    |(![1, v, 0, 0] : Fin 4 → ℝ) 1 / (![1, v, 0, 0] : Fin 4 → ℝ) 0 - v| = 0 := by
  refine ⟨eulerian_timelike v, by norm_num, by norm_num⟩

/-- The corresponding statement in the *asymptotically flat* region `f = 0` (`w = 0`):
there the same coordinate velocity `v > 1` would be spacelike, i.e. forbidden.  This is
what the warp bubble buys. -/
theorem flat_region_forbids_superluminal {v : ℝ} (hv : 1 < v) :
    ¬ IsCausal 0 ![1, v, 0, 0] := by
  rw [IsCausal, lineElement_eq]
  push_neg
  have : (1:ℝ) < v ^ 2 := by nlinarith
  norm_num
  nlinarith

/-! ## Chronology protection: no closed causal curves -/

/-- **The Alcubierre ansatz admits no closed causal curve.**

Let `γ : ℝ → (Fin 4 → ℝ)` be a curve which is differentiable on `[0,1]` with tangent `u`,
whose tangent is causal for the (arbitrarily varying!) warp factor `w s` at each point and
never vanishes, and which closes up (`γ 0 = γ 1`).  This is impossible.

The mechanism: `g^{tt} = -1`, so the coordinate time `t` is a global time function; its
derivative along a causal curve never vanishes, contradicting Rolle's theorem. -/
theorem no_closed_causal_curve
    (γ u : ℝ → (Fin 4 → ℝ)) (w : ℝ → ℝ)
    (hderiv : ∀ s ∈ Icc (0:ℝ) 1, ∀ i, HasDerivAt (fun σ => γ σ i) (u s i) s)
    (hcausal : ∀ s ∈ Icc (0:ℝ) 1, IsCausal (w s) (u s))
    (hnonzero : ∀ s ∈ Icc (0:ℝ) 1, ¬ (u s 0 = 0 ∧ u s 1 = 0 ∧ u s 2 = 0 ∧ u s 3 = 0))
    (hclosed : γ 0 = γ 1) : False := by
  have hcont : ContinuousOn (fun σ => γ σ 0) (Icc (0:ℝ) 1) := fun s hs =>
    ((hderiv s hs 0).continuousAt).continuousWithinAt
  have hIoo : ∀ s ∈ Ioo (0:ℝ) 1, HasDerivAt (fun σ => γ σ 0) (u s 0) s := fun s hs =>
    hderiv s (Ioo_subset_Icc_self hs) 0
  obtain ⟨c, hc, hc0⟩ :=
    exists_hasDerivAt_eq_zero (f := fun σ => γ σ 0) (f' := fun s => u s 0)
      (by norm_num) hcont (show γ 0 0 = γ 1 0 by rw [hclosed]) hIoo
  exact hnonzero c (Ioo_subset_Icc_self hc)
    ⟨hc0, by
      have h := time_component_ne_zero (hcausal c (Ioo_subset_Icc_self hc))
        (fun hall => hnonzero c (Ioo_subset_Icc_self hc) hall)
      exact absurd hc0 h,
      by
      have h := time_component_ne_zero (hcausal c (Ioo_subset_Icc_self hc))
        (fun hall => hnonzero c (Ioo_subset_Icc_self hc) hall)
      exact absurd hc0 h,
      by
      have h := time_component_ne_zero (hcausal c (Ioo_subset_Icc_self hc))
        (fun hall => hnonzero c (Ioo_subset_Icc_self hc) hall)
      exact absurd hc0 h⟩

/-! ## The causal-control horizon of a superluminal bubble -/

/-- Along a future-directed causal curve the coordinate `x`-velocity is at most `w + 1`. -/
theorem coordinate_speed_le {w : ℝ} {u : Fin 4 → ℝ} (hc : IsCausal w u) (hf : 0 < u 0) :
    u 1 ≤ (w + 1) * u 0 := by
  have hQ : -(u 0) ^ 2 + (u 1 - w * u 0) ^ 2 + (u 2) ^ 2 + (u 3) ^ 2 ≤ 0 := by
    have := hc; rwa [IsCausal, lineElement_eq] at this
  nlinarith [sq_nonneg (u 2), sq_nonneg (u 3), sq_nonneg (u 1 - w * u 0 - u 0)]

/-- **Superluminal bubbles have a causal horizon.**

Consider the "outer" region where the shape function satisfies `w = v_s f ≤ v_s - 1 - δ`
with `δ > 0` — a region that necessarily exists whenever `v_s > 1`, since `f → 0` at
infinity.  Then along every future-directed causal curve confined to that region the
separation `x - v_s t` from the bubble centre is *strictly decreasing*: no causal influence
can keep up with the bubble, and in particular the ship cannot steer the front wall. -/
theorem warp_horizon_falls_behind
    (γ u : ℝ → (Fin 4 → ℝ)) (w : ℝ → ℝ) (v δ a b : ℝ) (hδ : 0 < δ)
    (hderiv : ∀ s ∈ Icc a b, ∀ i, HasDerivAt (fun σ => γ σ i) (u s i) s)
    (hcausal : ∀ s ∈ Icc a b, IsCausal (w s) (u s))
    (hfuture : ∀ s ∈ Icc a b, 0 < u s 0)
    (houter : ∀ s ∈ Icc a b, w s ≤ v - 1 - δ) :
    StrictAntiOn (fun s => γ s 1 - v * γ s 0) (Icc a b) := by
  have hderiv' : ∀ s ∈ Icc a b,
      HasDerivAt (fun σ => γ σ 1 - v * γ σ 0) (u s 1 - v * u s 0) s := by
    intro s hs
    exact ((hderiv s hs 1).sub (((hderiv s hs 0).const_mul v)))
  have hneg : ∀ s ∈ Icc a b, u s 1 - v * u s 0 < 0 := by
    intro s hs
    have h1 : u s 1 ≤ (w s + 1) * u s 0 := coordinate_speed_le (hcausal s hs) (hfuture s hs)
    have h2 : w s ≤ v - 1 - δ := houter s hs
    have h3 : 0 < u s 0 := hfuture s hs
    nlinarith
  have hcont : ContinuousOn (fun s => γ s 1 - v * γ s 0) (Icc a b) := fun s hs =>
    ((hderiv' s hs).continuousAt).continuousWithinAt
  apply strictAntiOn_of_hasDerivWithinAt_neg (convex_Icc a b) hcont
    (f' := fun s => u s 1 - v * u s 0)
  · intro s hs
    exact ((hderiv' s (interior_subset hs)).hasDerivWithinAt)
  · intro s hs
    exact hneg s (interior_subset hs)

end Catalog.Physics.Spacetime.Alcubierre