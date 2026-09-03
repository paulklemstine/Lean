/-
# Sharp resolution accounting for nested windows, and a falsifiable third-cell prediction
## (paper 168 / exp 501, cycle 2 — built on `Logic.UHardenResolutionSplit`)

Cycle 1 (`Logic.UHardenResolutionSplit`) modelled the `u`-gate statistic on a window of `N`
items by the rank-grid rounding `gridUp N θ = ⌈θN⌉/N`, split a measured gate drop into an
intrinsic part and a resolution residual, and audited the paper-168 reading of the
four-cell design.  Its cross-window bound `|D| ≤ 2L(1/N₁ + 1/N₂)` was generic: it never
used the fact that the design's two windows are **nested**, `960 = 240·4`.

This file exploits nestedness and closes the loop with matching bounds.

**1.  The nested bound is twice as strong and ignores the fine window.**  For an antitone
`L`-Lipschitz response and `N₂ = N₁·c`, the residuals are ordered
(`resid_refine_le`), so every bracket in the residual decomposition lies in `[−L/N₁, 0]`
and hence `|D| ≤ L/N₁` (`cross_window_nested_abs_le`) — no `N₂` dependence at all.  At
`(240, 960)` the reported CI lower end `D ≥ 0.0346` therefore certifies
`L ≥ 8.30` (`p168_lipschitz_floor_nested`), a factor `2.5` sharper than cycle 1's `3.32`.

**2.  The bound is tight within `4/3`.**  The explicit linear response `S x = −Lx` with
gates `0` and `1/960` realises `D = L/320` exactly (`cross_window_linear_witness`), so the
certificate `L ≥ 240·D` recovers exactly `3/4` of the true slope
(`p168_floor_recovers_three_quarters`).  Upper and lower bounds match to the factor `4/3`:
this is the exact price of not knowing where in its rank cell the gate sits.

**3.  A necessary structural condition.**  A *positive* nested `D` forces the coarse grid to
move the **hard** gate: `gridUp N₂ θ₂ < gridUp N₁ θ₂` (`cross_window_pos_hard_gate_moves`).
A run in which the `u = 3.5` gate happens to sit on a grid point of both windows cannot
produce `D > 0` at all (`cross_window_nonpos_of_hard_gate_fixed`) — a cheap diagnostic for
the follow-up experiment.

**4.  How often does resolution matter?**  Inside one coarse rank cell the two grids agree
exactly on a sub-cell of relative length `1/c`: `grids_agree_iff` characterises the
agreement set as an interval of length `1/(N₁c)`, of Lebesgue measure `1/(N₁c)`
(`agreement_cell_volume`).  For a uniformly placed gate the `240 → 960` refinement changes
the realised gate with probability exactly `3/4`.

**5.  A falsifiable prediction.**  Under the paper's own `1/N` residual reading the drop is
affine in `1/N`, so a *third* nested cell at `N = 3840` is completely determined by the two
measured ones: `Δ(3840) = (5Δ(960) − Δ(240))/4` (`third_window_prediction`), numerically
`0.0527`, and confined to `[0.0459, 0.0607]` by the reported CIs
(`p168_third_window_interval`).  A measured `Δ(3840)` outside that interval refutes the
`1/N` reading — and with it the `41 %`-versus-`54 %` share arithmetic of cycle 1.
-/
import Logic.UHardenResolutionSplit

namespace Logic.UHarden

open MeasureTheory

/-! ## 1.  The nested cross-window bound -/

/-- **Nested windows: a sharper, fine-window-free bound.**  When `N₂ = N₁·c` refines `N₁`
and the response is antitone and `L`-Lipschitz, the cross-window difference of the two
measured drops obeys `|D| ≤ L/N₁`.  (Cycle 1's generic bound was `2L(1/N₁ + 1/N₂)`, i.e.
`2.5×` weaker at `(240, 960)`.) -/
theorem cross_window_nested_abs_le {S : ℝ → ℝ} {L : ℝ} (hS : Antitone S)
    (hLip : LipBound S L) {M c : ℕ} (hM : 0 < M) (hc : 0 < c) (θ₁ θ₂ : ℝ) :
    |crossWindow S M (M * c) θ₁ θ₂| ≤ L / M := by
  have hMc : 0 < M * c := Nat.mul_pos hM hc
  have e := cross_window_pure_resolution S M (M * c) θ₁ θ₂
  have hr1 : 0 ≤ resid S (M * c) θ₁ := resid_nonneg hS hMc θ₁
  have hr2 : 0 ≤ resid S (M * c) θ₂ := resid_nonneg hS hMc θ₂
  have hf1 : resid S (M * c) θ₁ ≤ resid S M θ₁ := resid_refine_le hS hM hc θ₁
  have hf2 : resid S (M * c) θ₂ ≤ resid S M θ₂ := resid_refine_le hS hM hc θ₂
  have hb1 := abs_le.mp (resid_abs_le hLip hM θ₁)
  have hb2 := abs_le.mp (resid_abs_le hLip hM θ₂)
  rw [e, abs_le]
  constructor <;> linarith [hb1.1, hb1.2, hb2.1, hb2.2]

/-- **Refined Lipschitz floor for paper 168.**  Because `960 = 240·4`, the reported CI lower
end `D ≥ 0.0346` forces `L ≥ 8.30` for the smooth response across the strip. -/
theorem p168_lipschitz_floor_nested {S : ℝ → ℝ} {L : ℝ} (hS : Antitone S)
    (hLip : LipBound S L) {θ₁ θ₂ : ℝ}
    (hD : (346 : ℝ) / 10000 ≤ crossWindow S 240 960 θ₁ θ₂) : (83 : ℝ) / 10 ≤ L := by
  have h960 : (960 : ℕ) = 240 * 4 := by norm_num
  rw [h960] at hD
  have h := cross_window_nested_abs_le hS hLip (show 0 < 240 by norm_num)
    (show 0 < 4 by norm_num) θ₁ θ₂
  have hle : crossWindow S 240 (240 * 4) θ₁ θ₂ ≤ L / ((240 : ℕ) : ℝ) := (le_abs_self _).trans h
  norm_num at hle
  linarith

/-! ## 2.  Matching lower bound: an explicit linear witness -/

/-- **The nested bound is attained up to `4/3`.**  For the linear response `S x = −Lx`, the
soft gate `0` and the hard gate `1/960`, the two windows of the design report drops
`L/240` and `L/960`, so `D = L/320` exactly. -/
theorem cross_window_linear_witness (L : ℝ) :
    crossWindow (fun x => -(L * x)) 240 960 0 (1 / 960) = L / 320 := by
  unfold crossWindow gateDrop qResp gridUp
  norm_num
  ring

/-- The witness response is antitone and `|L|`-Lipschitz for `L ≥ 0`. -/
theorem linear_witness_regular {L : ℝ} (hL : 0 ≤ L) :
    Antitone (fun x : ℝ => -(L * x)) ∧ LipBound (fun x : ℝ => -(L * x)) L := by
  refine ⟨fun a b hab => by simp only [neg_le_neg_iff]; nlinarith, fun x y => ?_⟩
  have : -(L * x) - -(L * y) = -(L * (x - y)) := by ring
  rw [this, abs_neg, abs_mul, abs_of_nonneg hL]

/-- **The certificate recovers exactly three quarters of the truth.**  On the linear
witness, the floor `240·D` extracted by `p168_lipschitz_floor_nested` equals `(3/4)L`:
upper and lower bounds on what a two-cell nested design can learn about the slope match to
the factor `4/3`. -/
theorem p168_floor_recovers_three_quarters (L : ℝ) :
    240 * crossWindow (fun x => -(L * x)) 240 960 0 (1 / 960) = 3 / 4 * L := by
  rw [cross_window_linear_witness]
  ring

/-! ## 3.  A necessary structural condition for a positive nested `D` -/

/-- **A positive nested `D` moves the hard gate.**  If the coarse and fine windows report
different drops with `D > 0`, then the coarse grid must place the *hard* gate strictly
above the fine grid: `gridUp (M·c) θ₂ < gridUp M θ₂`. -/
theorem cross_window_pos_hard_gate_moves {S : ℝ → ℝ} (hS : Antitone S) {M c : ℕ}
    (hM : 0 < M) (hc : 0 < c) {θ₁ θ₂ : ℝ} (hD : 0 < crossWindow S M (M * c) θ₁ θ₂) :
    gridUp (M * c) θ₂ < gridUp M θ₂ := by
  have e := cross_window_pure_resolution S M (M * c) θ₁ θ₂
  have hf1 : resid S (M * c) θ₁ ≤ resid S M θ₁ := resid_refine_le hS hM hc θ₁
  have hstrict : resid S (M * c) θ₂ < resid S M θ₂ := by rw [e] at hD; linarith
  have hne : gridUp (M * c) θ₂ ≠ gridUp M θ₂ := by
    intro h
    rw [resid, resid, qResp, qResp, h] at hstrict
    exact lt_irrefl _ hstrict
  exact lt_of_le_of_ne (gridUp_refine hM hc θ₂) hne

/-- **Contrapositive diagnostic.**  If the hard gate happens to be realised identically on
both windows, no positive cross-window difference is possible. -/
theorem cross_window_nonpos_of_hard_gate_fixed {S : ℝ → ℝ} (hS : Antitone S) {M c : ℕ}
    (hM : 0 < M) (hc : 0 < c) {θ₁ θ₂ : ℝ} (hfix : gridUp (M * c) θ₂ = gridUp M θ₂) :
    crossWindow S M (M * c) θ₁ θ₂ ≤ 0 := by
  by_contra h
  push_neg at h
  exact absurd hfix (ne_of_lt (cross_window_pos_hard_gate_moves hS hM hc h))

/-! ## 4.  How often refinement changes the realised gate -/

/-- **The agreement set inside a coarse rank cell.**  For a gate in the first coarse cell
`(0, 1/M]`, the fine window `M·c` realises the *same* gate exactly when the gate lies in the
last fine sub-cell `(1/M − 1/(Mc), 1/M]`. -/
theorem grids_agree_iff {M c : ℕ} (hM : 0 < M) (hc : 0 < c) {θ : ℝ} (hpos : 0 < θ)
    (hle : θ ≤ 1 / M) :
    gridUp (M * c) θ = gridUp M θ ↔ 1 / M - 1 / (M * c) < θ := by
  have hM' : (0 : ℝ) < M := by exact_mod_cast hM
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hprod : ((M * c : ℕ) : ℝ) = (M : ℝ) * c := by push_cast; ring
  have hthM : θ * M ≤ 1 := by rw [le_div_iff₀ hM'] at hle; linarith
  have hcoarse : gridUp M θ = 1 / M := by
    unfold gridUp
    have h1 : ⌈θ * (M : ℝ)⌉ = 1 := by
      rw [Int.ceil_eq_iff]
      constructor
      · push_cast; nlinarith
      · push_cast; linarith
    rw [h1]; norm_num
  have hupper : θ * ((M : ℝ) * c) ≤ c := by nlinarith
  have hfine : gridUp (M * c) θ = (⌈θ * ((M : ℝ) * c)⌉ : ℝ) / ((M : ℝ) * c) := by
    unfold gridUp; rw [hprod]
  have key : 1 / (M : ℝ) - 1 / ((M : ℝ) * c) = ((c : ℝ) - 1) / ((M : ℝ) * c) := by
    field_simp
  rw [hfine, hcoarse]
  constructor
  · intro h
    have hceq : ((⌈θ * ((M : ℝ) * c)⌉ : ℤ) : ℝ) = c := by
      field_simp at h
      rw [mul_assoc] at h
      linarith
    have hlt := Int.ceil_lt_add_one (θ * ((M : ℝ) * c))
    rw [hceq] at hlt
    rw [key, div_lt_iff₀ (by positivity)]
    linarith
  · intro h
    rw [key, div_lt_iff₀ (by positivity)] at h
    have hceil : ⌈θ * ((M : ℝ) * c)⌉ = (c : ℤ) := by
      rw [Int.ceil_eq_iff]
      constructor
      · push_cast; linarith
      · push_cast; linarith
    rw [hceil]
    push_cast
    field_simp

/-- **Measure of the agreement set.**  Inside a coarse rank cell of length `1/M`, the gates
whose realisation is unchanged by the `c`-fold refinement form an interval of length
`1/(Mc)`: a uniformly placed gate is moved by the refinement with probability `1 − 1/c`
(`3/4` for the `240 → 960` step). -/
theorem agreement_cell_volume (M c : ℕ) :
    volume (Set.Ioc (1 / (M : ℝ) - 1 / ((M : ℝ) * c)) (1 / (M : ℝ)))
      = ENNReal.ofReal (1 / ((M : ℝ) * c)) := by
  rw [Real.volume_Ioc]
  congr 1
  ring

/-! ## 5.  The falsifiable third-cell prediction -/

/-- **Third-cell prediction.**  If the drop is affine in the rank step (`Δ(N) = I + c/N`,
the paper's own "smooth mass per offset unchanged" reading), then the two measured cells
determine the next nested cell exactly: `Δ(3840) = (5Δ(960) − Δ(240))/4`. -/
theorem third_window_prediction {I c d1 d2 d3 : ℝ} (hm1 : d1 = I + c / 240)
    (hm2 : d2 = I + c / 960) (hm3 : d3 = I + c / 3840) : d3 = (5 * d2 - d1) / 4 := by
  have h1 : c / 960 = (c / 240) / 4 := by ring
  have h2 : c / 3840 = (c / 240) / 16 := by ring
  rw [h1] at hm2
  rw [h2] at hm3
  linarith

/-- **The prediction is falsifiable.**  Propagating the reported CIs through
`third_window_prediction`, a fourth-cell run at `N = 3840` must report a drop in
`[0.0459, 0.0607]`; anything outside refutes the `1/N` residual model on which both the
paper's `41 %` and cycle 1's extrapolated `54 %` resolution shares rest. -/
theorem p168_third_window_interval {I c d1 d2 d3 : ℝ} (hm1 : d1 = I + c / 240)
    (hm2 : d2 = I + c / 960) (hm3 : d3 = I + c / 3840)
    (h1 : (973 : ℝ) / 10000 ≤ d1) (h1' : d1 ≤ 1148 / 10000)
    (h2 : (597 : ℝ) / 10000 ≤ d2) (h2' : d2 ≤ 680 / 10000) :
    (459 : ℝ) / 10000 ≤ d3 ∧ d3 ≤ 607 / 10000 := by
  have h := third_window_prediction hm1 hm2 hm3
  constructor <;> rw [h] <;> linarith

end Logic.UHarden