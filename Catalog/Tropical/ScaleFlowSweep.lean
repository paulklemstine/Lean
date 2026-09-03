import Mathlib
import Tropical.ScaleFlowInterpolation

/-!
# The generator of the scale flow, and the 3B sweep between the 1.5B and 7B cells

`Tropical.ScaleFlowCore` extends the octave shift to an action of `(ℝ≥0, +)`;
`Tropical.ScaleFlowInterpolation` shows that a monotone real profile through the
measured cells exists exactly for monotone chains, and is *unique* once increments
are required to be stationary — for the arithmetic NET-66 chain it is
`K₀ t = 16 + 4·t`.  This file draws the two consequences the measurement programme
actually needs.

**1. The generator.**  Writing the real table in unclamped coordinates,

`kstar k₀ δ σ t = k₀ + δ · (t − σ)⁺`,

the one-parameter flow is differentiable off the clamp locus, with
`∂σ = −δ` and `∂t = +δ`: the *generator of the scale flow is the keys-per-octave
rate*, and the table satisfies the transport equation `∂σ k + ∂t k = 0`
(`transport_equation`).  Scale and context enter only through `t − σ`, i.e. through
the ratio `ctx / 2^σ`, now for real `σ`.

**2. The 3B sweep.**  The measured ladder is `0.5B → 1.5B` (scale index `0 → 1`)
and the law's prediction for `7B` is index `2`.  Interpolating the scale axis
log-linearly between the two anchors gives

`scaleIndex N = 1 + log (N / 1.5) / log (14/3)`,  `scaleIndex (3 / 2) = 1`, `scaleIndex 7 = 2`,

and the unmeasured 3B cell sits at `scaleIndex 3 = 1 + log 2 / log (14/3) ≈ 1.4500`.
The flow then *predicts* the whole 3B knee chain, and the prediction is pinned by
rigorous rational bounds rather than by floating-point arithmetic:

| ctx      | 512 | 1024 | 2048            | 4096            |
|----------|-----|------|-----------------|-----------------|
| 1.5B (σ=1) | 16 | 16   | 20              | 24              |
| **3B** (σ≈1.45) | **16** | **16** | **18.0–18.4 → 19** | **22.0–22.4 → 23** |
| 7B (σ=2) | 16  | 16   | 16              | 20              |

`sweep_3B_ctx2048` and `sweep_3B_ctx4096` prove the bracketing *and* the deployable
integer budgets `⌈·⌉ = 19` and `23`; `sweep_3B_flat_below` proves the 3B chain is
still flat at 512 and 1024, so the first upward break of the 3B model happens at
2048 — one *half* octave later than 1.5B, which is exactly the falsifiable content
of a real-parameter scale flow (a purely discrete action can only predict integer
translates, i.e. a break at 2048 *or* 4096, never a strictly intermediate budget of
19 keys).
-/

namespace Tropical.ScaleFlowSweep

open Tropical.ScaleFlowCore Tropical.ScaleFlowInterpolation
open Combinatorics.OctaveShiftLaw NNReal Real

/-! ## The real table in unclamped coordinates -/

/-- The **real knee table** `k*(σ, t) = k₀ + δ·(t − σ)⁺`, with both the scale
parameter and the context octave real. -/
noncomputable def kstar (k0 delta sigma t : ℝ) : ℝ := k0 + delta * max (t - sigma) 0

theorem kstar_of_le {k0 delta sigma t : ℝ} (h : t ≤ sigma) : kstar k0 delta sigma t = k0 := by
  simp [kstar, max_eq_right (by linarith : t - sigma ≤ 0)]

theorem kstar_of_ge {k0 delta sigma t : ℝ} (h : sigma ≤ t) :
    kstar k0 delta sigma t = k0 + delta * (t - sigma) := by
  simp [kstar, max_eq_left (by linarith : (0:ℝ) ≤ t - sigma)]

/-- The unclamped coordinates agree with the `ℝ≥0` scale flow of the affine
profile: `kstar` really is `rshift (affineProfile ..)`. -/
theorem kstar_eq_rshift (k0 delta : ℝ) (s t : ℝ≥0) :
    rshift (affineProfile k0 delta) s t = kstar k0 delta s t := by
  rw [rshift_eq_max]
  simp [affineProfile, kstar]

/-- The table is antitone in scale and monotone in context. -/
theorem kstar_antitone_scale {k0 delta : ℝ} (hδ : 0 ≤ delta) (t : ℝ) :
    Antitone fun sigma => kstar k0 delta sigma t := by
  intro a b hab
  have : max (t - b) 0 ≤ max (t - a) 0 := max_le_max (by linarith) le_rfl
  simp only [kstar]
  nlinarith

theorem kstar_monotone_ctx {k0 delta : ℝ} (hδ : 0 ≤ delta) (sigma : ℝ) :
    Monotone fun t => kstar k0 delta sigma t := by
  intro a b hab
  have : max (a - sigma) 0 ≤ max (b - sigma) 0 := max_le_max (by linarith) le_rfl
  simp only [kstar]
  nlinarith

/-- **The sweep bracket.**  An unmeasured model whose scale parameter lies between
two measured ones has its whole knee chain bracketed by the two measured chains. -/
theorem sweep_bracket {k0 delta s1 s s2 t : ℝ} (hδ : 0 ≤ delta) (h1 : s1 ≤ s) (h2 : s ≤ s2) :
    kstar k0 delta s2 t ≤ kstar k0 delta s t ∧ kstar k0 delta s t ≤ kstar k0 delta s1 t :=
  ⟨kstar_antitone_scale hδ t h2, kstar_antitone_scale hδ t h1⟩

/-! ## Restriction to the measured integer cells -/

theorem natCast_max (s j : ℕ) : (((j - s : ℕ) : ℝ)) = max ((j : ℝ) - s) 0 := by
  rcases le_total j s with h | h
  · rw [Nat.sub_eq_zero_of_le h, max_eq_right (by
      have : (j : ℝ) ≤ (s : ℝ) := by exact_mod_cast h
      linarith)]
    simp
  · rw [max_eq_left (by
      have : (s : ℝ) ≤ (j : ℝ) := by exact_mod_cast h
      linarith)]
    have : (s : ℝ) + ((j - s : ℕ) : ℝ) = (j : ℝ) := by
      rw [← Nat.cast_add, Nat.add_sub_cancel' h]
    linarith

/-- **The real flow restricts to the measured NET-66 table.**  At integer scale and
integer context octave the continuous table reproduces the discrete one, cell for
cell — including the measured 0.5B row `{16,20,24}` and the 1.5B row `{16,16,20}`. -/
theorem kstar_restricts (s j : ℕ) :
    kstar 16 4 (s : ℝ) (j : ℝ) = (net66.chain s j : ℝ) := by
  have hchain : net66.chain s j = net66Base (j - s) := net66.apply_eq s j
  rw [hchain]
  simp only [kstar, net66Base]
  rw [← natCast_max s j]
  push_cast
  ring

/-- Sanity: the measured cells themselves. -/
theorem kstar_measured_cells :
    kstar 16 4 0 0 = 16 ∧ kstar 16 4 0 1 = 20 ∧ kstar 16 4 0 2 = 24 ∧
      kstar 16 4 1 0 = 16 ∧ kstar 16 4 1 1 = 16 ∧ kstar 16 4 1 2 = 20 ∧
      kstar 16 4 2 2 = 16 ∧ kstar 16 4 2 3 = 20 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp [kstar] <;> norm_num

/-! ## The generator of the flow -/

/-- **The generator in the scale direction.**  Off the clamp locus the knee falls
at exactly the keys-per-octave rate as the model grows: `∂σ k* = −δ`. -/
theorem hasDerivAt_kstar_scale (k0 delta : ℝ) {sigma t : ℝ} (h : sigma < t) :
    HasDerivAt (fun x => kstar k0 delta x t) (-delta) sigma := by
  have hloc : (fun x => kstar k0 delta x t) =ᶠ[nhds sigma] fun x => k0 + delta * (t - x) := by
    filter_upwards [gt_mem_nhds h] with x hx
    exact kstar_of_ge (le_of_lt hx)
  have hd : HasDerivAt (fun x : ℝ => k0 + delta * (t - x)) (-delta) sigma := by
    have h1 : HasDerivAt (fun x : ℝ => t - x) (-1) sigma := by
      simpa using (hasDerivAt_id sigma).const_sub t
    simpa using ((h1.const_mul delta).const_add k0)
  exact hd.congr_of_eventuallyEq hloc

/-- **The generator in the context direction**: `∂t k* = +δ`. -/
theorem hasDerivAt_kstar_ctx (k0 delta : ℝ) {sigma t : ℝ} (h : sigma < t) :
    HasDerivAt (fun x => kstar k0 delta sigma x) delta t := by
  have hloc : (fun x => kstar k0 delta sigma x) =ᶠ[nhds t] fun x => k0 + delta * (x - sigma) := by
    filter_upwards [lt_mem_nhds h] with x hx
    exact kstar_of_ge (le_of_lt hx)
  have hd : HasDerivAt (fun x : ℝ => k0 + delta * (x - sigma)) delta t := by
    have h1 : HasDerivAt (fun x : ℝ => x - sigma) 1 t := by
      simpa using (hasDerivAt_id t).sub_const sigma
    simpa using ((h1.const_mul delta).const_add k0)
  exact hd.congr_of_eventuallyEq hloc

/-- **The transport equation.**  The knee table is constant along the flow
direction `(1,1)` of "one octave of scale per octave of context":
`∂σ k* + ∂t k* = 0`, with the two derivatives being `∓` the keys-per-octave rate.
This is the infinitesimal form of the exchange law. -/
theorem transport_equation (k0 delta : ℝ) {sigma t : ℝ} (h : sigma < t) :
    deriv (fun x => kstar k0 delta x t) sigma + deriv (fun x => kstar k0 delta sigma x) t = 0 := by
  rw [(hasDerivAt_kstar_scale k0 delta h).deriv, (hasDerivAt_kstar_ctx k0 delta h).deriv]
  ring

/-! ## Log-linear calibration of the real scale axis -/

/-- The **scale index** of a model of `N` billion parameters, calibrated
log-linearly on the two anchors of the octave-shift ladder: `1.5B ↦ 1`, `7B ↦ 2`. -/
noncomputable def scaleIndex (N : ℝ) : ℝ := 1 + Real.log (N / (3 / 2)) / Real.log (14 / 3)

theorem log_anchor_pos : 0 < Real.log (14 / 3) := Real.log_pos (by norm_num)

@[simp] theorem scaleIndex_anchor_small : scaleIndex (3 / 2) = 1 := by
  simp [scaleIndex]

@[simp] theorem scaleIndex_anchor_large : scaleIndex 7 = 2 := by
  have h : (7 : ℝ) / (3 / 2) = 14 / 3 := by norm_num
  rw [scaleIndex, h, div_self (ne_of_gt log_anchor_pos)]
  norm_num

/-- The calibration is strictly increasing in model size: a bigger model always has
a strictly larger scale parameter. -/
theorem scaleIndex_strictMonoOn : StrictMonoOn scaleIndex (Set.Ioi 0) := by
  intro a ha b hb hab
  have ha' : (0 : ℝ) < a := ha
  have hpos : (0 : ℝ) < a / (3 / 2) := by linarith
  have hlog : Real.log (a / (3 / 2)) < Real.log (b / (3 / 2)) :=
    Real.log_lt_log hpos (by linarith)
  have hdiv : Real.log (a / (3 / 2)) / Real.log (14 / 3)
      < Real.log (b / (3 / 2)) / Real.log (14 / 3) :=
    div_lt_div_of_pos_right hlog log_anchor_pos
  simp only [scaleIndex]
  linarith

/-- **The 3B scale parameter is strictly between the measured anchors**, with
explicit rational bounds: `1.4 < scaleIndex 3 < 1.5`. -/
theorem scaleIndex_3B_bounds : (7 : ℝ) / 5 < scaleIndex 3 ∧ scaleIndex 3 < 3 / 2 := by
  have hL : 0 < Real.log (14 / 3) := log_anchor_pos
  have h32 : (3 : ℝ) / (3 / 2) = 2 := by norm_num
  have hupper : (2 : ℝ) * Real.log 2 < Real.log (14 / 3) := by
    have h : Real.log ((2:ℝ) ^ 2) < Real.log (14 / 3) := Real.log_lt_log (by norm_num) (by norm_num)
    rw [Real.log_pow] at h
    push_cast at h
    linarith
  have hlower : (2 : ℝ) * Real.log (14 / 3) < 5 * Real.log 2 := by
    have h : Real.log ((14 / 3 : ℝ) ^ 2) < Real.log ((2:ℝ) ^ 5) :=
      Real.log_lt_log (by norm_num) (by norm_num)
    rw [Real.log_pow, Real.log_pow] at h
    push_cast at h
    linarith
  constructor
  · rw [scaleIndex, h32]
    rw [show (7 : ℝ) / 5 = 1 + 2 / 5 by norm_num]
    have : (2 : ℝ) / 5 < Real.log 2 / Real.log (14 / 3) := by
      rw [div_lt_div_iff₀ (by norm_num) hL]
      linarith
    linarith
  · rw [scaleIndex, h32]
    rw [show (3 : ℝ) / 2 = 1 + 1 / 2 by norm_num]
    have : Real.log 2 / Real.log (14 / 3) < 1 / 2 := by
      rw [div_lt_div_iff₀ hL (by norm_num)]
      linarith
    linarith

/-! ## The 3B knee chain -/

/-- The predicted 3B knee chain: the NET-66 flow evaluated at the interpolated
scale parameter `scaleIndex 3 ≈ 1.45`. -/
noncomputable def k3B (t : ℝ) : ℝ := kstar 16 4 (scaleIndex 3) t

/-- **The 3B chain is still flat at 512 and 1024.**  Exactly as for the 1.5B
model, the first two context cells cost the base budget of 16 keys. -/
theorem sweep_3B_flat_below : k3B 0 = 16 ∧ k3B 1 = 16 := by
  obtain ⟨hlo, hhi⟩ := scaleIndex_3B_bounds
  exact ⟨kstar_of_le (by linarith), kstar_of_le (by linarith)⟩

/-- **The 3B cell at ctx 2048.**  The interpolated knee is strictly between the
measured 7B cell (16 keys) and the measured 1.5B cell (20 keys), lies in the narrow
window `(18, 18.4)`, and therefore the deployable integer budget is `19` keys —
a value no purely discrete (integer-shift) model can produce. -/
theorem sweep_3B_ctx2048 :
    kstar 16 4 2 2 < k3B 2 ∧ k3B 2 < kstar 16 4 1 2 ∧
      18 < k3B 2 ∧ k3B 2 < 92 / 5 ∧ ⌈k3B 2⌉₊ = 19 := by
  obtain ⟨hlo, hhi⟩ := scaleIndex_3B_bounds
  have hval : k3B 2 = 16 + 4 * (2 - scaleIndex 3) := by
    rw [k3B, kstar_of_ge (by linarith)]
  have h1 : 18 < k3B 2 := by rw [hval]; linarith
  have h2 : k3B 2 < 92 / 5 := by rw [hval]; linarith
  refine ⟨?_, ?_, h1, h2, ?_⟩
  · rw [show kstar 16 4 2 2 = 16 by rw [kstar_of_le (le_refl _)]]
    linarith
  · rw [show kstar (16:ℝ) 4 1 2 = 20 by rw [kstar_of_ge (by norm_num)]; norm_num]
    linarith
  · rw [Nat.ceil_eq_iff (by norm_num)]
    constructor
    · push_cast; linarith
    · push_cast; linarith

/-- **The 3B cell at ctx 4096.**  The interpolated knee lies in `(22, 22.4)`,
strictly between the 7B cell (20 keys) and the 1.5B cell (24 keys); the deployable
budget is `23` keys. -/
theorem sweep_3B_ctx4096 :
    kstar 16 4 2 3 < k3B 3 ∧ k3B 3 < kstar 16 4 1 3 ∧
      22 < k3B 3 ∧ k3B 3 < 112 / 5 ∧ ⌈k3B 3⌉₊ = 23 := by
  obtain ⟨hlo, hhi⟩ := scaleIndex_3B_bounds
  have hval : k3B 3 = 16 + 4 * (3 - scaleIndex 3) := by
    rw [k3B, kstar_of_ge (by linarith)]
  have h1 : 22 < k3B 3 := by rw [hval]; linarith
  have h2 : k3B 3 < 112 / 5 := by rw [hval]; linarith
  refine ⟨?_, ?_, h1, h2, ?_⟩
  · rw [show kstar (16:ℝ) 4 2 3 = 20 by rw [kstar_of_ge (by norm_num)]; norm_num]
    linarith
  · rw [show kstar (16:ℝ) 4 1 3 = 24 by rw [kstar_of_ge (by norm_num)]; norm_num]
    linarith
  · rw [Nat.ceil_eq_iff (by norm_num)]
    constructor
    · push_cast; linarith
    · push_cast; linarith

/-- **The sweep is monotone in model size.**  Across the three sizes
`1.5B < 3B < 7B` the interpolated knee chain is antitone at every context, so the
interpolated deployment table never crosses a measured one. -/
theorem sweep_monotone_in_size (t : ℝ) :
    kstar 16 4 (scaleIndex 7) t ≤ k3B t ∧ k3B t ≤ kstar 16 4 (scaleIndex (3 / 2)) t := by
  obtain ⟨hlo, hhi⟩ := scaleIndex_3B_bounds
  have h7 : scaleIndex 3 ≤ scaleIndex 7 := by rw [scaleIndex_anchor_large]; linarith
  have h15 : scaleIndex (3 / 2) ≤ scaleIndex 3 := by rw [scaleIndex_anchor_small]; linarith
  exact ⟨kstar_antitone_scale (by norm_num) t h7, kstar_antitone_scale (by norm_num) t h15⟩

/-- **The falsifiable content of the continuous extension.**  At ctx 2048 the 3B
budget predicted by the flow is strictly larger than the 7B budget and strictly
smaller than the 1.5B budget, and it is *not* an integer cell of the discrete
table: no integer scale index reproduces it.  A measured 3B knee of 16 or 20 keys
at 2048 refutes the real-parameter extension; a measured 19 confirms it. -/
theorem sweep_3B_not_discrete : ∀ s : ℕ, kstar 16 4 (s : ℝ) 2 ≠ k3B 2 := by
  intro s
  obtain ⟨_, _, h1, h2, _⟩ := sweep_3B_ctx2048
  rcases le_or_gt 2 s with h | h
  · rw [kstar_of_le (by exact_mod_cast h)]
    intro hcon; rw [← hcon] at h1; norm_num at h1
  · have hs : s ≤ 1 := by omega
    have hsle : (s : ℝ) ≤ 1 := by exact_mod_cast hs
    rw [kstar_of_ge (by linarith)]
    intro hcon
    have : (16 : ℝ) + 4 * (2 - s) ≥ 20 := by linarith
    rw [hcon] at this
    linarith

end Tropical.ScaleFlowSweep