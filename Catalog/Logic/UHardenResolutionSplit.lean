/-
# The u-hardening split: how much of a cross-window gate effect is *resolution*?
## (paper 168, exp 501, four-cell design `window {240, 960} × u {2.5, 3.5}`)

Round-45 #2 reports a four-cell experiment on a threshold ("`u`-gate") statistic:

| window `N` | measured drop `Δ(N)` when the gate is hardened from `u = 2.5` to `u = 3.5` |
|-----------:|:-----------------------------------|
| `240`      | `+0.1073`  CI `[0.0973, 0.1148]`   |
| `960`      | `+0.0636`  CI `[0.0597, 0.0680]`   |
| `D = Δ(240) − Δ(960)` | `+0.0437`  CI `[0.0346, 0.0533]`  |

and reads the outcome as *"mostly intrinsic threshold reweighting, with a real ~41 %
minority from per-`N` rank resolution"*, the `41 %` being `D / Δ(240)`.

This file builds the order-theoretic model that makes "resolution component" a definite
notion, and then audits that reading.  Nothing here is statistics: every empirical number
enters only as a hypothesis on a real variable, and every conclusion is a theorem about
those hypotheses.

**The model.**  On a window of `N` items only the rates `k/N` are realisable, so a gate at
level `θ` acts at the next grid point above `θ`: `gridUp N θ = ⌈θN⌉/N`
(`Logic.UHarden.gridUp`).  The *measured* response is `qResp S N θ = S (gridUp N θ)` for
the underlying smooth response `S`, and the *resolution residual* is
`resid S N θ = S θ − qResp S N θ`.

**Structure (§1–§3).**  `gridUp` is a grid rounding: `θ ≤ gridUp N θ < θ + 1/N`
(`gridUp_ge`, `gridUp_lt_add`), it is monotone in `θ` (`gridUp_mono`), 1-Lipschitz up to one
rank step (`gridUp_dist_le`) and *decreases along divisibility-refined grids*
(`gridUp_refine`), so for an antitone response the residual is nonnegative and shrinks
under refinement (`resid_nonneg`, `resid_refine_le`) — the `960` cell of the design really
is a refinement of the `240` cell.  With a Lipschitz response the residual is `O(1/N)`
(`resid_abs_le`) and the measured response converges to the smooth one (`qResp_tendsto`).

**The identity that justifies the named follow-up (§4).**  If the two gates are *held
fixed across windows* ("decouple `B` from `vmed`"), the intrinsic drop cancels identically
and the cross-window difference is *pure resolution* (`cross_window_pure_resolution`),
whence `|D| ≤ 2L(1/N₁ + 1/N₂)` (`cross_window_abs_le`).  In the *nested* design the gates
move with the window, and the extra confound is bounded by `2L(ε + 1/N₂)` in the gate drift
`ε` (`nested_cross_window_bound`) — the paper's own caveat, quantified.

**Audit (§5).**  Four findings, all proved:

* `p168_lipschitz_floor` — a decoupled cross-window difference as large as the CI lower end
  `0.0346` forces the smooth response to have Lipschitz constant `≥ 3.32` over the strip,
  since `|D| ≤ L/96` at `(N₁, N₂) = (240, 960)`.  A flat response cannot produce this `D`.
* `resolution_alone_can_produce_cross_window` — conversely, a perfectly *linear* response
  (no intrinsic window dependence whatsoever) already yields `D > 0` in an explicit
  instance.  So a nonzero `D` does **not** by itself certify anything intrinsic.
* `p168_both_hypotheses_fail` — on the reported intervals the resolution component of the
  coarse cell is strictly positive (H2 "none" fails) and the recovery `D/Δ(240)` is strictly
  below `1/2` (H1 "most" fails): the "NEITHER" verdict is robust, not a point-estimate
  artifact.
* `p168_intrinsic_share_le`, `p168_intrinsic_share_ge` — under the paper's own
  "residual `∝ 1/N`, smooth mass per offset unchanged" reading, Richardson extrapolation
  from the two cells gives the intrinsic level `I = (4Δ(960) − Δ(240))/3`
  (`richardson_intrinsic`), and the reported intervals pin the *intrinsic share*
  `I/Δ(240)` to `[9/25, 3/5] = [0.36, 0.60]`.  The measured `41 %` resolution share
  understates the extrapolated one by exactly `4/3` (`richardson_resolution_share`), so the
  headline "mostly intrinsic" is **not certified** — at the point estimates it is reversed
  (`p168_point_intrinsic_minority`).

`Logic.UHarden` is self-contained: it needs only `Mathlib`.
-/
import Mathlib

namespace Logic.UHarden

open Filter Topology

/-! ## 1.  The rank grid of a window -/

/-- The gate level actually realised on a window of `N` items: only rates `k/N` occur, so a
nominal level `θ` is rounded **up** to the next realisable rate. -/
noncomputable def gridUp (N : ℕ) (θ : ℝ) : ℝ := (⌈θ * N⌉ : ℝ) / N

/-- The realised gate is never below the nominal gate. -/
theorem gridUp_ge {N : ℕ} (hN : 0 < N) (θ : ℝ) : θ ≤ gridUp N θ := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  rw [gridUp, le_div_iff₀ hN']
  exact Int.le_ceil _

/-- The realised gate overshoots by less than one rank step `1/N`. -/
theorem gridUp_lt_add {N : ℕ} (hN : 0 < N) (θ : ℝ) : gridUp N θ < θ + 1 / N := by
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  rw [gridUp, div_lt_iff₀ hN']
  have h := Int.ceil_lt_add_one (θ * N)
  have hrw : (θ + 1 / N) * N = θ * N + 1 := by field_simp
  rw [hrw]
  exact h

/-- The realised gate is within one rank step of the nominal gate. -/
theorem gridUp_sub_le {N : ℕ} (hN : 0 < N) (θ : ℝ) : |gridUp N θ - θ| ≤ 1 / N := by
  have h1 := gridUp_ge hN θ
  have h2 := (gridUp_lt_add hN θ).le
  rw [abs_of_nonneg (by linarith)]
  linarith

/-- Rounding to the grid is monotone in the nominal level. -/
theorem gridUp_mono {N : ℕ} (hN : 0 < N) : Monotone (gridUp N) := by
  intro a b hab
  have hN' : (0 : ℝ) < N := by exact_mod_cast hN
  have hceil : ⌈a * (N : ℝ)⌉ ≤ ⌈b * (N : ℝ)⌉ := Int.ceil_le_ceil (by nlinarith)
  have hcast : ((⌈a * (N : ℝ)⌉ : ℤ) : ℝ) ≤ ((⌈b * (N : ℝ)⌉ : ℤ) : ℝ) := by exact_mod_cast hceil
  unfold gridUp
  gcongr

/-- Rounding to the grid is `1`-Lipschitz up to a single rank step: two gates a distance
`ε` apart are realised a distance at most `ε + 1/N` apart on the same window. -/
theorem gridUp_dist_le {N : ℕ} (hN : 0 < N) (a b : ℝ) :
    |gridUp N a - gridUp N b| ≤ |a - b| + 1 / N := by
  have ha1 := gridUp_ge hN a
  have ha2 := (gridUp_lt_add hN a).le
  have hb1 := gridUp_ge hN b
  have hb2 := (gridUp_lt_add hN b).le
  have hab := abs_le.mp (le_refl |a - b|)
  rw [abs_le]
  constructor <;> linarith [neg_abs_le (a - b), le_abs_self (a - b)]

/-- **Grid refinement.**  A window of `M·c` items refines a window of `M` items: its grid
contains the coarser grid, so the realised gate is never higher.  The `240 → 960` step of
the four-cell design is the case `c = 4`. -/
theorem gridUp_refine {M c : ℕ} (hM : 0 < M) (hc : 0 < c) (θ : ℝ) :
    gridUp (M * c) θ ≤ gridUp M θ := by
  have hM' : (0 : ℝ) < M := by exact_mod_cast hM
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hMc : (0 : ℝ) < (M : ℝ) * c := mul_pos hM' hc'
  have hle : θ * M ≤ (⌈θ * (M : ℝ)⌉ : ℝ) := Int.le_ceil _
  have hkey : ⌈θ * ((M : ℝ) * c)⌉ ≤ ⌈θ * (M : ℝ)⌉ * (c : ℤ) := by
    rw [Int.ceil_le]
    push_cast
    nlinarith
  have hcast : ((⌈θ * ((M : ℝ) * c)⌉ : ℤ) : ℝ) ≤ ((⌈θ * (M : ℝ)⌉ : ℤ) : ℝ) * c := by
    exact_mod_cast hkey
  unfold gridUp
  push_cast
  rw [div_le_div_iff₀ hMc hM']
  nlinarith

/-! ## 2.  Measured response, residual, and the gate drop -/

/-- A response curve `S` is `L`-Lipschitz (the only regularity the audit uses). -/
def LipBound (S : ℝ → ℝ) (L : ℝ) : Prop := ∀ x y : ℝ, |S x - S y| ≤ L * |x - y|

/-- A Lipschitz bound is nonnegative. -/
theorem LipBound.nonneg {S : ℝ → ℝ} {L : ℝ} (h : LipBound S L) : 0 ≤ L := by
  have h1 := h 0 1
  norm_num at h1
  linarith [abs_nonneg (S 0 - S 1)]

/-- The response actually measured on a window of `N` items at nominal gate `θ`. -/
noncomputable def qResp (S : ℝ → ℝ) (N : ℕ) (θ : ℝ) : ℝ := S (gridUp N θ)

/-- The **resolution residual**: smooth response minus measured response. -/
noncomputable def resid (S : ℝ → ℝ) (N : ℕ) (θ : ℝ) : ℝ := S θ - qResp S N θ

/-- The **gate drop** measured on a window of `N` items when the gate is hardened from
`θ₁` to `θ₂` (`θ₁ < θ₂`, e.g. `u = 2.5 ↦ u = 3.5`). -/
noncomputable def gateDrop (S : ℝ → ℝ) (N : ℕ) (θ₁ θ₂ : ℝ) : ℝ :=
  qResp S N θ₁ - qResp S N θ₂

/-- The **intrinsic drop**: the same quantity for an infinitely resolved window. -/
noncomputable def gateDropInf (S : ℝ → ℝ) (θ₁ θ₂ : ℝ) : ℝ := S θ₁ - S θ₂

/-- The exact decomposition of a measured drop into intrinsic part and residual terms. -/
theorem gateDrop_eq (S : ℝ → ℝ) (N : ℕ) (θ₁ θ₂ : ℝ) :
    gateDrop S N θ₁ θ₂ = gateDropInf S θ₁ θ₂ - resid S N θ₁ + resid S N θ₂ := by
  unfold gateDrop gateDropInf resid qResp; ring

/-- For an antitone response the residual is nonnegative: rounding the gate up can only
lose mass. -/
theorem resid_nonneg {S : ℝ → ℝ} (hS : Antitone S) {N : ℕ} (hN : 0 < N) (θ : ℝ) :
    0 ≤ resid S N θ :=
  sub_nonneg.mpr (hS (gridUp_ge hN θ))

/-- **Refinement shrinks the residual.**  Passing from a window of `M` items to one of
`M·c` items can only reduce the resolution residual, for any antitone response. -/
theorem resid_refine_le {S : ℝ → ℝ} (hS : Antitone S) {M c : ℕ} (hM : 0 < M) (hc : 0 < c)
    (θ : ℝ) : resid S (M * c) θ ≤ resid S M θ := by
  have h := hS (gridUp_refine hM hc θ)
  unfold resid qResp
  linarith

/-- **The residual is `O(1/N)`.**  A Lipschitz response cannot hide a large residual. -/
theorem resid_abs_le {S : ℝ → ℝ} {L : ℝ} (hLip : LipBound S L) {N : ℕ} (hN : 0 < N)
    (θ : ℝ) : |resid S N θ| ≤ L / N := by
  have h1 : |resid S N θ| ≤ L * |gridUp N θ - θ| := by
    unfold resid qResp
    have := hLip θ (gridUp N θ)
    rwa [abs_sub_comm θ (gridUp N θ)] at this
  have h2 : L * |gridUp N θ - θ| ≤ L * (1 / N) :=
    mul_le_mul_of_nonneg_left (gridUp_sub_le hN θ) hLip.nonneg
  calc |resid S N θ| ≤ L * |gridUp N θ - θ| := h1
    _ ≤ L * (1 / N) := h2
    _ = L / N := by ring

/-! ## 3.  Infinite resolution as a limit -/

/-- **Consistency of the measured response.**  For a Lipschitz response the response
measured on a window of `N` items converges to the smooth response as `N → ∞`: the
resolution component of any gate statistic vanishes in the limit. -/
theorem qResp_tendsto {S : ℝ → ℝ} {L : ℝ} (hLip : LipBound S L) (θ : ℝ) :
    Tendsto (fun N : ℕ => qResp S N θ) atTop (𝓝 (S θ)) := by
  have hres : Tendsto (fun N : ℕ => resid S N θ) atTop (𝓝 0) := by
    refine squeeze_zero_norm' ?_ (tendsto_const_div_atTop_nhds_zero_nat L)
    filter_upwards [eventually_gt_atTop 0] with N hN
    simpa [Real.norm_eq_abs] using resid_abs_le hLip hN θ
  have hsub := (tendsto_const_nhds (α := ℕ) (x := S θ) (f := atTop)).sub hres
  simpa [resid] using hsub

/-! ## 4.  Cross-window differences: decoupled versus nested designs -/

/-- The cross-window difference `D` of the two measured drops, gates held fixed. -/
noncomputable def crossWindow (S : ℝ → ℝ) (N₁ N₂ : ℕ) (θ₁ θ₂ : ℝ) : ℝ :=
  gateDrop S N₁ θ₁ θ₂ - gateDrop S N₂ θ₁ θ₂

/-- **The decoupled design measures pure resolution.**  If the two gates are held fixed
across the two windows — the named follow-up "decouple `B` from `vmed`" — then the
intrinsic drop cancels identically and `D` is a difference of resolution residuals only. -/
theorem cross_window_pure_resolution (S : ℝ → ℝ) (N₁ N₂ : ℕ) (θ₁ θ₂ : ℝ) :
    crossWindow S N₁ N₂ θ₁ θ₂ =
      (resid S N₂ θ₁ - resid S N₁ θ₁) - (resid S N₂ θ₂ - resid S N₁ θ₂) := by
  unfold crossWindow gateDrop resid qResp; ring

/-- **Size of the decoupled cross-window difference.**  It is bounded by the two rank
steps: `|D| ≤ 2L(1/N₁ + 1/N₂)`. -/
theorem cross_window_abs_le {S : ℝ → ℝ} {L : ℝ} (hLip : LipBound S L) {N₁ N₂ : ℕ}
    (h1 : 0 < N₁) (h2 : 0 < N₂) (θ₁ θ₂ : ℝ) :
    |crossWindow S N₁ N₂ θ₁ θ₂| ≤ 2 * (L / N₁ + L / N₂) := by
  have e := cross_window_pure_resolution S N₁ N₂ θ₁ θ₂
  have a11 := abs_le.mp (resid_abs_le hLip h1 θ₁)
  have a12 := abs_le.mp (resid_abs_le hLip h1 θ₂)
  have a21 := abs_le.mp (resid_abs_le hLip h2 θ₁)
  have a22 := abs_le.mp (resid_abs_le hLip h2 θ₂)
  rw [e, abs_le]
  constructor <;> linarith [a11.1, a11.2, a12.1, a12.2, a21.1, a21.2, a22.1, a22.2]

/-- Perturbing both gates by at most `ε` perturbs a measured drop by at most
`2L(ε + 1/N)`. -/
theorem gateDrop_gate_perturb {S : ℝ → ℝ} {L eps : ℝ} (hLip : LipBound S L) {N : ℕ}
    (hN : 0 < N) {a₁ a₂ b₁ b₂ : ℝ} (hd1 : |a₁ - b₁| ≤ eps) (hd2 : |a₂ - b₂| ≤ eps) :
    |gateDrop S N a₁ a₂ - gateDrop S N b₁ b₂| ≤ 2 * (L * (eps + 1 / N)) := by
  have hL := hLip.nonneg
  have hg1 : |gridUp N a₁ - gridUp N b₁| ≤ eps + 1 / N :=
    (gridUp_dist_le hN a₁ b₁).trans (by linarith)
  have hg2 : |gridUp N a₂ - gridUp N b₂| ≤ eps + 1 / N :=
    (gridUp_dist_le hN a₂ b₂).trans (by linarith)
  have hs1 : |S (gridUp N a₁) - S (gridUp N b₁)| ≤ L * (eps + 1 / N) :=
    (hLip _ _).trans (mul_le_mul_of_nonneg_left hg1 hL)
  have hs2 : |S (gridUp N a₂) - S (gridUp N b₂)| ≤ L * (eps + 1 / N) :=
    (hLip _ _).trans (mul_le_mul_of_nonneg_left hg2 hL)
  have e : gateDrop S N a₁ a₂ - gateDrop S N b₁ b₂ =
      (S (gridUp N a₁) - S (gridUp N b₁)) - (S (gridUp N a₂) - S (gridUp N b₂)) := by
    unfold gateDrop qResp; ring
  have b1 := abs_le.mp hs1
  have b2 := abs_le.mp hs2
  rw [e, abs_le]
  constructor <;> linarith [b1.1, b1.2, b2.1, b2.2]

/-- **The nested design is confounded.**  If the gates themselves move with the window
(because the strip bound `B` is tied to `vmed`, and the windows are nested), the
cross-window difference picks up a gate-drift term on top of the resolution terms.  With
drift at most `ε` the whole difference is bounded by `2L(1/N₁ + 1/N₂) + 2L(ε + 1/N₂)`, so a
nested `D` can be produced by drift alone: sample size and bound growth are not separable
in this design. -/
theorem nested_cross_window_bound {S : ℝ → ℝ} {L eps : ℝ} (hLip : LipBound S L)
    {N₁ N₂ : ℕ} (h1 : 0 < N₁) (h2 : 0 < N₂) {a₁ a₂ b₁ b₂ : ℝ}
    (hd1 : |a₁ - b₁| ≤ eps) (hd2 : |a₂ - b₂| ≤ eps) :
    |gateDrop S N₁ a₁ a₂ - gateDrop S N₂ b₁ b₂|
      ≤ 2 * (L / N₁ + L / N₂) + 2 * (L * (eps + 1 / N₂)) := by
  have hsplit : gateDrop S N₁ a₁ a₂ - gateDrop S N₂ b₁ b₂ =
      crossWindow S N₁ N₂ a₁ a₂ + (gateDrop S N₂ a₁ a₂ - gateDrop S N₂ b₁ b₂) := by
    unfold crossWindow; ring
  have hc := cross_window_abs_le hLip h1 h2 a₁ a₂
  have hdft := gateDrop_gate_perturb hLip h2 hd1 hd2
  calc |gateDrop S N₁ a₁ a₂ - gateDrop S N₂ b₁ b₂|
      ≤ |crossWindow S N₁ N₂ a₁ a₂| + |gateDrop S N₂ a₁ a₂ - gateDrop S N₂ b₁ b₂| := by
        rw [hsplit]; exact abs_add_le _ _
    _ ≤ 2 * (L / N₁ + L / N₂) + 2 * (L * (eps + 1 / N₂)) := by linarith

/-! ## 5.  Auditing the paper-168 reading -/

/-- **A large cross-window difference forces a steep response.**  In the decoupled design
at `(N₁, N₂) = (240, 960)` one has `|D| ≤ L/96`, so the CI lower end `D ≥ 0.0346` certifies
a Lipschitz floor `L ≥ 3.32` for the smooth response across the strip: the effect cannot
come from a flat response with a lucky grid. -/
theorem p168_lipschitz_floor {S : ℝ → ℝ} {L : ℝ} (hLip : LipBound S L) {θ₁ θ₂ : ℝ}
    (hD : (346 : ℝ) / 10000 ≤ crossWindow S 240 960 θ₁ θ₂) : (332 : ℝ) / 100 ≤ L := by
  have h := cross_window_abs_le hLip (show 0 < 240 by norm_num) (show 0 < 960 by norm_num) θ₁ θ₂
  have hle : crossWindow S 240 960 θ₁ θ₂ ≤ 2 * (L / ((240 : ℕ) : ℝ) + L / ((960 : ℕ) : ℝ)) :=
    (le_abs_self _).trans h
  norm_num at hle
  linarith

/-- **Resolution alone can manufacture a cross-window difference.**  For the linear (hence
maximally "smooth", intrinsically window-independent) response `S x = −x`, the two windows
`N = 2` and `N = 4` already report different drops for the *same* pair of gates.  A nonzero
`D` therefore certifies nothing intrinsic on its own; only its *size* relative to `L/N`
does. -/
theorem resolution_alone_can_produce_cross_window :
    crossWindow (fun x => -x) 2 4 0 (1 / 4) = 1 / 4 := by
  unfold crossWindow gateDrop qResp gridUp
  norm_num

/-- The witness response of `resolution_alone_can_produce_cross_window` is antitone and
`1`-Lipschitz, so it satisfies every regularity hypothesis used above. -/
theorem witness_regular :
    Antitone (fun x : ℝ => -x) ∧ LipBound (fun x : ℝ => -x) 1 := by
  refine ⟨fun a b h => by simpa using h, fun x y => ?_⟩
  rw [show -x - -y = -(x - y) by ring, abs_neg, one_mul]

/-- **Both pre-stated hypotheses fail, on the whole reported box.**  With `Δ(240)` in its
CI, `Δ(960)` in its CI and `D` in its (paired) CI: `D > 0`, so quadrupling the window does
*not* remove the effect (H2 fails); and `2D < Δ(240)`, so quadrupling recovers strictly
less than half of the drop (H1 fails).  The "NEITHER" verdict is not a point-estimate
artifact. -/
theorem p168_both_hypotheses_fail {I r1 r2 d1 d2 : ℝ}
    (hr2 : 0 ≤ r2) (hm1 : d1 = I + r1) (hm2 : d2 = I + r2)
    (h1' : d1 ≤ 1148 / 10000) (h2 : (597 : ℝ) / 10000 ≤ d2) (hpos : 0 < d1)
    (hD : (346 : ℝ) / 10000 ≤ d1 - d2) :
    0 < r1 ∧ (d1 - d2) / d1 < 1 / 2 := by
  refine ⟨by rw [hm1, hm2] at hD; linarith, ?_⟩
  rw [div_lt_div_iff₀ hpos (by norm_num : (0:ℝ) < 2)]
  linarith

/-- **Richardson extrapolation of the two cells.**  If the resolution residual of the drop
obeys the paper's own `1/N` reading (smooth mass per offset unchanged, only rate
granularity changing), then the two cells determine the intrinsic level exactly:
`I = (4Δ(960) − Δ(240))/3`, and the resolution part of the coarse cell is
`(4/3)(Δ(240) − Δ(960))`. -/
theorem richardson_intrinsic {I c d1 d2 : ℝ} (hm1 : d1 = I + c / 240)
    (hm2 : d2 = I + c / 960) : I = (4 * d2 - d1) / 3 ∧ c / 240 = 4 / 3 * (d1 - d2) := by
  have hq : c / 960 = (c / 240) / 4 := by ring
  rw [hq] at hm2
  constructor <;> linarith

/-- **The measured recovery understates the resolution share by exactly `4/3`.**  The
reported `41 % = D/Δ(240)` is the *between-cell* recovery; the resolution share of the
coarse cell implied by the `1/N` model is `(4/3)·41 % ≈ 54 %`. -/
theorem richardson_resolution_share {I c d1 d2 : ℝ} (hd1 : d1 ≠ 0) (hm1 : d1 = I + c / 240)
    (hm2 : d2 = I + c / 960) : (c / 240) / d1 = 4 / 3 * ((d1 - d2) / d1) := by
  have h := (richardson_intrinsic hm1 hm2).2
  rw [h]
  field_simp

/-- **Upper bound on the intrinsic share.**  On the reported CIs, the extrapolated
intrinsic level is at most `3/5` of the measured coarse drop. -/
theorem p168_intrinsic_share_le {I c d1 d2 : ℝ} (hm1 : d1 = I + c / 240)
    (hm2 : d2 = I + c / 960)
    (h1 : (973 : ℝ) / 10000 ≤ d1) (h2' : d2 ≤ 680 / 10000) : I ≤ 3 / 5 * d1 := by
  have hI := (richardson_intrinsic hm1 hm2).1
  rw [hI]
  linarith

/-- **Lower bound on the intrinsic share.**  On the reported CIs, the extrapolated
intrinsic level is at least `9/25 = 0.36` of the measured coarse drop.  Together with
`p168_intrinsic_share_le` the intrinsic share is pinned to `[0.36, 0.60]`: "mostly
intrinsic" (`> 1/2`) is *consistent with*, but not *certified by*, the four cells. -/
theorem p168_intrinsic_share_ge {I c d1 d2 : ℝ} (hm1 : d1 = I + c / 240)
    (hm2 : d2 = I + c / 960)
    (h1' : d1 ≤ 1148 / 10000) (h2 : (597 : ℝ) / 10000 ≤ d2) : 9 / 25 * d1 ≤ I := by
  have hI := (richardson_intrinsic hm1 hm2).1
  rw [hI]
  linarith

/-- **At the point estimates the headline is reversed.**  With `Δ(240) = 0.1073` and
`Δ(960) = 0.0636`, the `1/N` model gives an intrinsic level `I ≈ 0.0490` that is a strict
*minority* of the coarse drop (`2I < Δ(240)`), while still being positive.  So the reported
`41 %` resolution minority becomes a `54 %` resolution majority once the residual surviving
at `N = 960` is extrapolated away. -/
theorem p168_point_intrinsic_minority {I c : ℝ}
    (hm1 : (1073 : ℝ) / 10000 = I + c / 240) (hm2 : (636 : ℝ) / 10000 = I + c / 960) :
    0 < I ∧ 2 * I < 1073 / 10000 := by
  have hI := (richardson_intrinsic hm1 hm2).1
  constructor <;> rw [hI] <;> norm_num

end Logic.UHarden