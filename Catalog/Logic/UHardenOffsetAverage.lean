/-
# Where the `1/N` law comes from: the offset-averaged resolution bias
## (paper 168 / exp 501, cycle 3 — built on `Logic.UHardenResolutionSplit`)

Cycles 1–2 *assumed* the paper's reading that the resolution part of a measured gate drop
scales like `c/N` ("smooth mass per offset unchanged, only rate granularity changing"), and
used it for Richardson extrapolation and for the third-cell prediction.  This file
**derives** that law, and in doing so fixes the sign of `c`.

**Setup.**  The nominal gate sits somewhere inside a rank cell; where exactly is an
accident of the population.  Averaging a quantity over the offset of the gate inside one
cell is `cellAvg N f = N ∫₀^{1/N} f t dt` (`Logic.UHarden.cellAvg`).

**The three computations.**
* `cellAvg_qResp` — the *measured* response is constant in the offset: inside a cell it is
  always `S((k+1)/N)`.  Rank granularity destroys all offset information.
* `cellAvg_smooth_linear` — the *smooth* response averages to its cell midpoint value,
  `A − L(k/N + 1/(2N))`, whenever `S` is linear across the cell.
* `cellAvg_resid_locally_linear` — hence the offset-averaged residual is exactly `L/(2N)`.
  This is the `c/N` law, with `c = L/2` identified as *half the local slope*, not fitted.

**The consequence for paper 168.**  For a drop across two gates with local slopes `L₁`
(soft gate, `u = 2.5`) and `L₂` (hard gate, `u = 3.5`), the offset-averaged measured drop
exceeds the offset-averaged intrinsic drop by exactly `(L₂ − L₁)/(2N)`
(`cellAvg_drop_bias`).  Therefore a measured drop that *shrinks* as the window grows —
which is what `D = Δ(240) − Δ(960) > 0` reports — requires `L₂ > L₁`
(`hard_gate_steeper_iff`): the response must be **steeper at the hard gate than at the soft
gate**.  For a survival curve with a decreasing density across the strip the opposite holds,
`L₂ < L₁`, which would give `D < 0`.  So on the offset-averaged model the reported sign of
`D` is a genuine constraint on the population, not a free parameter — and a run whose
score density decays across the strip cannot produce it by resolution alone.  Combined with
`Logic.UHarden.nested_cross_window_bound`, this is the cleanest statement of the caveat
recorded with the round: in the nested design the observed sign is more easily explained by
gate drift (`B` growing with `vmed`) than by rank granularity.
-/
import Logic.UHardenResolutionSplit

namespace Logic.UHarden

open MeasureTheory intervalIntegral

/-! ## 1.  Averaging over the gate offset inside one rank cell -/

/-- The average of `f` over the offset of the gate inside one rank cell of width `1/N`. -/
noncomputable def cellAvg (N : ℕ) (f : ℝ → ℝ) : ℝ := N * ∫ t in (0:ℝ)..(1 / N), f t

/-- The elementary integral used throughout: `∫₀^b (C − Lt) dt = Cb − Lb²/2`. -/
theorem integral_affine (C L b : ℝ) : ∫ t in (0:ℝ)..b, (C - L * t) = C * b - L * b ^ 2 / 2 := by
  rw [intervalIntegral.integral_sub _root_.intervalIntegrable_const
      ((intervalIntegral.intervalIntegrable_id).const_mul L),
    intervalIntegral.integral_const_mul, integral_id, intervalIntegral.integral_const]
  simp only [smul_eq_mul]
  ring

/-- Inside the cell `(k/N, (k+1)/N]` every gate is realised at the same rate `(k+1)/N`. -/
theorem gridUp_cell {N : ℕ} (hN : 0 < N) (k : ℤ) {t : ℝ} (ht0 : 0 < t) (ht1 : t ≤ 1 / N) :
    gridUp N ((k : ℝ) / N + t) = ((k : ℝ) + 1) / N := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have harg : ((k : ℝ) / N + t) * N = t * N + k := by field_simp; ring
  have h1 : (0 : ℝ) < t * N := mul_pos ht0 hN'
  have h2 : t * N ≤ 1 := by rw [le_div_iff₀ hN'] at ht1; linarith
  have hceil : ⌈((k : ℝ) / N + t) * N⌉ = 1 + k := by
    rw [harg, Int.ceil_add_intCast]
    have : ⌈t * (N : ℝ)⌉ = 1 := by
      rw [Int.ceil_eq_iff]
      constructor
      · push_cast; linarith
      · push_cast; linarith
    rw [this]
  unfold gridUp
  rw [hceil]
  push_cast
  ring

/-! ## 2.  The three cell averages -/

/-- **Granularity destroys offset information.**  The measured response is constant across
the cell: its offset average is the value at the realised rate `(k+1)/N`. -/
theorem cellAvg_qResp (S : ℝ → ℝ) {N : ℕ} (hN : 0 < N) (k : ℤ) :
    cellAvg N (fun t => qResp S N ((k : ℝ) / N + t)) = S (((k : ℝ) + 1) / N) := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have hpos : (0 : ℝ) < 1 / N := by positivity
  have hcongr : ∫ t in (0:ℝ)..(1 / N), qResp S N ((k : ℝ) / N + t)
      = ∫ _t in (0:ℝ)..(1 / N), S (((k : ℝ) + 1) / N) := by
    refine intervalIntegral.integral_congr_ae (Filter.Eventually.of_forall ?_)
    intro t ht
    rw [Set.uIoc_of_le hpos.le] at ht
    simp only [qResp, gridUp_cell hN k ht.1 ht.2]
  unfold cellAvg
  rw [hcongr, intervalIntegral.integral_const]
  simp only [smul_eq_mul, sub_zero]
  field_simp

/-- **The smooth response averages to its cell midpoint.**  If `S` is linear with slope
`−L` across the cell, its offset average is `A − L(k/N + 1/(2N))`. -/
theorem cellAvg_smooth_linear {S : ℝ → ℝ} {A L : ℝ} {N : ℕ} (hN : 0 < N) (k : ℤ)
    (hloc : ∀ x ∈ Set.Icc ((k : ℝ) / N) (((k : ℝ) + 1) / N), S x = A - L * x) :
    cellAvg N (fun t => S ((k : ℝ) / N + t)) = A - L * ((k : ℝ) / N + 1 / (2 * N)) := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have hpos : (0 : ℝ) < 1 / N := by positivity
  have hcongr : ∫ t in (0:ℝ)..(1 / N), S ((k : ℝ) / N + t)
      = ∫ t in (0:ℝ)..(1 / N), ((A - L * ((k : ℝ) / N)) - L * t) := by
    refine intervalIntegral.integral_congr ?_
    intro t ht
    rw [Set.uIcc_of_le hpos.le] at ht
    have hmem : (k : ℝ) / N + t ∈ Set.Icc ((k : ℝ) / N) (((k : ℝ) + 1) / N) := by
      constructor
      · linarith [ht.1]
      · have : (k : ℝ) / N + 1 / N = ((k : ℝ) + 1) / N := by ring
        linarith [ht.2, this.ge, this.le]
    show S ((k : ℝ) / N + t) = A - L * ((k : ℝ) / N) - L * t
    rw [hloc _ hmem]; ring
  unfold cellAvg
  rw [hcongr, integral_affine]
  field_simp
  ring

/-- **The `1/N` law, derived.**  For a response linear across the cell, the offset-averaged
resolution residual is exactly `L/(2N)`: half the local slope, divided by the window size.
The paper's `c/N` ansatz is therefore correct with `c = L/2`. -/
theorem cellAvg_resid_locally_linear {S : ℝ → ℝ} {A L : ℝ} {N : ℕ} (hN : 0 < N) (k : ℤ)
    (hloc : ∀ x ∈ Set.Icc ((k : ℝ) / N) (((k : ℝ) + 1) / N), S x = A - L * x) :
    cellAvg N (fun t => resid S N ((k : ℝ) / N + t)) = L / (2 * N) := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have hpos : (0 : ℝ) < 1 / N := by positivity
  have hend : S (((k : ℝ) + 1) / N) = A - L * (((k : ℝ) + 1) / N) := by
    refine hloc _ ⟨?_, le_refl _⟩
    rw [div_le_div_iff₀ hN' hN']
    nlinarith
  have hcongr : ∫ t in (0:ℝ)..(1 / N), resid S N ((k : ℝ) / N + t)
      = ∫ t in (0:ℝ)..(1 / N), (L / N - L * t) := by
    refine intervalIntegral.integral_congr_ae (Filter.Eventually.of_forall ?_)
    intro t ht
    rw [Set.uIoc_of_le hpos.le] at ht
    have hmem : (k : ℝ) / N + t ∈ Set.Icc ((k : ℝ) / N) (((k : ℝ) + 1) / N) := by
      constructor
      · linarith [ht.1]
      · have h : (k : ℝ) / N + 1 / N = ((k : ℝ) + 1) / N := by ring
        linarith [ht.2, h.ge, h.le]
    simp only [resid, qResp, gridUp_cell hN k ht.1 ht.2, hloc _ hmem, hend]
    field_simp
    ring
  unfold cellAvg
  rw [hcongr, integral_affine]
  field_simp
  ring

/-! ## 3.  The bias of a measured drop, and the sign it forces -/

/-- **Offset-averaged bias of a gate drop.**  With local slopes `L₁` at the soft gate and
`L₂` at the hard gate, the measured drop overstates the smooth drop by exactly
`(L₂ − L₁)/(2N)` on average over the gate offset. -/
theorem cellAvg_drop_bias {S : ℝ → ℝ} {A₁ L₁ A₂ L₂ : ℝ} {N : ℕ} (hN : 0 < N) (k₁ k₂ : ℤ)
    (hloc1 : ∀ x ∈ Set.Icc ((k₁ : ℝ) / N) (((k₁ : ℝ) + 1) / N), S x = A₁ - L₁ * x)
    (hloc2 : ∀ x ∈ Set.Icc ((k₂ : ℝ) / N) (((k₂ : ℝ) + 1) / N), S x = A₂ - L₂ * x) :
    (cellAvg N (fun t => qResp S N ((k₁ : ℝ) / N + t))
        - cellAvg N (fun t => qResp S N ((k₂ : ℝ) / N + t)))
      - (cellAvg N (fun t => S ((k₁ : ℝ) / N + t)) - cellAvg N (fun t => S ((k₂ : ℝ) / N + t)))
      = (L₂ - L₁) / (2 * N) := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have h1 := cellAvg_qResp S hN k₁
  have h2 := cellAvg_qResp S hN k₂
  have h3 := cellAvg_smooth_linear hN k₁ hloc1
  have h4 := cellAvg_smooth_linear hN k₂ hloc2
  have he1 : S (((k₁ : ℝ) + 1) / N) = A₁ - L₁ * (((k₁ : ℝ) + 1) / N) := by
    refine hloc1 _ ⟨?_, le_refl _⟩
    rw [div_le_div_iff₀ hN' hN']
    nlinarith
  have he2 : S (((k₂ : ℝ) + 1) / N) = A₂ - L₂ * (((k₂ : ℝ) + 1) / N) := by
    refine hloc2 _ ⟨?_, le_refl _⟩
    rw [div_le_div_iff₀ hN' hN']
    nlinarith
  rw [h1, h2, h3, h4, he1, he2]
  field_simp
  ring

/-- **The sign of the window effect fixes the local geometry.**  On the offset-averaged
model, the measured drop exceeds the smooth drop — equivalently, the drop shrinks as the
window grows, which is the reported `D > 0` — **iff** the response is steeper at the hard
gate than at the soft gate. -/
theorem hard_gate_steeper_iff {S : ℝ → ℝ} {A₁ L₁ A₂ L₂ : ℝ} {N : ℕ} (hN : 0 < N) (k₁ k₂ : ℤ)
    (hloc1 : ∀ x ∈ Set.Icc ((k₁ : ℝ) / N) (((k₁ : ℝ) + 1) / N), S x = A₁ - L₁ * x)
    (hloc2 : ∀ x ∈ Set.Icc ((k₂ : ℝ) / N) (((k₂ : ℝ) + 1) / N), S x = A₂ - L₂ * x) :
    (cellAvg N (fun t => S ((k₁ : ℝ) / N + t)) - cellAvg N (fun t => S ((k₂ : ℝ) / N + t)))
        < (cellAvg N (fun t => qResp S N ((k₁ : ℝ) / N + t))
          - cellAvg N (fun t => qResp S N ((k₂ : ℝ) / N + t)))
      ↔ L₁ < L₂ := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have hbias := cellAvg_drop_bias hN k₁ k₂ hloc1 hloc2
  constructor
  · intro h
    have hpos : 0 < (L₂ - L₁) / (2 * N) := by rw [← hbias]; linarith
    have := (div_pos_iff.mp hpos)
    rcases this with ⟨hnum, _⟩ | ⟨_, hden⟩
    · linarith
    · nlinarith
  · intro h
    have hpos : 0 < (L₂ - L₁) / (2 * N) := div_pos (by linarith) (by positivity)
    linarith [hbias]

end Logic.UHarden