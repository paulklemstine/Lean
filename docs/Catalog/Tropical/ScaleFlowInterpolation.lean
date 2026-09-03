import Mathlib
import Tropical.ScaleFlowCore

/-!
# Monotone interpolation of knee chains: existence, failure of uniqueness, rigidity

`Tropical.ScaleFlowCore` shows that *given* a real knee profile `K₀ : ℝ≥0 → ℝ` the
octave shift extends to an action of `(ℝ≥0, +)` and that the extension is rigid.
This file settles the remaining question: **when does such a `K₀` exist, and how
unique is it?**  The measured object is only a sequence `K : ℕ → ℕ` of knees at the
octaves `512 · 2 ^ j`, so the extension problem is a *monotone interpolation*
problem.

Results.

* `plInterp` — the **ramp-basis interpolant**.  Writing `d i = K (i+1) − K i ≥ 0`
  for the octave increments, we set
  `K₀ t = K 0 + ∑_{i < ⌈t⌉} d i · ramp (t − i)` with `ramp x = min 1 (max x 0)`.
  Each summand is a nonnegative multiple of a monotone ramp, so monotonicity is
  structural rather than a case analysis on floors.
* `plInterp_monotone`, `plInterp_natCast` — it is monotone and interpolates.
* `monotone_interp_iff` — **the interpolation criterion**: a measured chain admits a
  monotone real profile through its cells *iff* the chain is monotone.  So the
  real-parameter extension of the octave shift exists exactly for the chains the
  discrete theory already admits; no measured table is lost, and a non-monotone
  table can never be interpolated.
* `ceilInterp`, `interp_not_unique` — **uniqueness fails**: the staircase
  interpolant `t ↦ K ⌈t⌉` is a second monotone interpolant, and for the NET-66 base
  chain the two disagree at the half-octave (`18` versus `20` keys).  Interpolation
  alone therefore does not determine intermediate model sizes.
* `eq_linear_of_monotone_of_additive` — the **Cauchy rigidity lemma**: a monotone
  additive `g : ℝ≥0 → ℝ` is linear, `g t = g 1 · t`.  Proved by the floor squeeze
  (`n·g t` is trapped between `⌊n t⌋·g 1` and `(⌊n t⌋+1)·g 1`), with no continuity
  assumption.
* `affine_of_monotone_of_stationary_increments` — the **generator theorem**: a
  monotone interpolant whose increments are translation invariant (the increment
  over an interval depends only on its length — the hallmark of a one-parameter
  flow) is *forced* to be affine, `K₀ t = K₀ 0 + δ·t`, with `δ = K₀ 1 − K₀ 0` the
  keys-per-octave rate.  Combined with `interp_not_unique` this pins the boundary
  exactly: monotonicity alone leaves a family of interpolants, monotonicity plus
  stationary increments leaves precisely one.
* `arith_interp_unique` — for an arithmetic base chain (the NET-66 case,
  `K j = k₀ + δ·j`) the unique stationary monotone interpolant is `k₀ + δ·t`, and by
  `ScaleFlowCore.ScaleFlow.eq_rshift` the whole real table is
  `k*(σ, t) = k₀ + δ·(t − σ)⁺`.
-/

namespace Tropical.ScaleFlowInterpolation

open Tropical.ScaleFlowCore Combinatorics.OctaveShiftLaw NNReal Finset

/-! ## The ramp basis -/

/-- The unit ramp: `0` below `0`, linear on `[0,1]`, `1` above `1`. -/
noncomputable def ramp (x : ℝ) : ℝ := min 1 (max x 0)

theorem ramp_nonneg (x : ℝ) : 0 ≤ ramp x := by
  unfold ramp
  rcases le_total x 0 with h | h
  · simp [max_eq_right h]
  · simp [max_eq_left h]
    linarith

theorem ramp_mono : Monotone ramp := fun _ _ h => min_le_min le_rfl (max_le_max h le_rfl)

theorem ramp_of_one_le {x : ℝ} (h : 1 ≤ x) : ramp x = 1 := by
  unfold ramp
  rw [max_eq_left (by linarith : (0:ℝ) ≤ x), min_eq_left h]

theorem ramp_half : ramp (1/2 : ℝ) = 1/2 := by
  unfold ramp; norm_num

/-! ## The ramp-basis interpolant -/

/-- The **ramp-basis interpolant** of a measured knee chain: piecewise linear
through the measured cells, written as a nonnegative combination of unit ramps. -/
noncomputable def plInterp (K : Chain) : RChain := fun t =>
  (K 0 : ℝ) + ∑ i ∈ range ⌈(t : ℝ)⌉₊, ((K (i + 1) : ℝ) - K i) * ramp ((t : ℝ) - i)

/-- Each ramp coefficient of a monotone chain is nonnegative. -/
theorem coeff_nonneg {K : Chain} (hK : Monotone K) (i : ℕ) : 0 ≤ ((K (i + 1) : ℝ) - K i) := by
  have := hK (Nat.le_succ i)
  have : (K i : ℝ) ≤ (K (i + 1) : ℝ) := by exact_mod_cast this
  linarith

/-- **The interpolant is monotone.** -/
theorem plInterp_monotone {K : Chain} (hK : Monotone K) : Monotone (plInterp K) := by
  intro t u htu
  have htuR : (t : ℝ) ≤ (u : ℝ) := by exact_mod_cast htu
  have hceil : ⌈(t : ℝ)⌉₊ ≤ ⌈(u : ℝ)⌉₊ := Nat.ceil_le_ceil htuR
  have step1 : ∑ i ∈ range ⌈(t : ℝ)⌉₊, ((K (i + 1) : ℝ) - K i) * ramp ((t : ℝ) - i)
      ≤ ∑ i ∈ range ⌈(t : ℝ)⌉₊, ((K (i + 1) : ℝ) - K i) * ramp ((u : ℝ) - i) := by
    refine Finset.sum_le_sum fun i _ => ?_
    exact mul_le_mul_of_nonneg_left (ramp_mono (by linarith)) (coeff_nonneg hK i)
  have step2 : ∑ i ∈ range ⌈(t : ℝ)⌉₊, ((K (i + 1) : ℝ) - K i) * ramp ((u : ℝ) - i)
      ≤ ∑ i ∈ range ⌈(u : ℝ)⌉₊, ((K (i + 1) : ℝ) - K i) * ramp ((u : ℝ) - i) := by
    have hsub : range ⌈(t : ℝ)⌉₊ ⊆ range ⌈(u : ℝ)⌉₊ := fun i hi =>
      mem_range.mpr (lt_of_lt_of_le (mem_range.mp hi) hceil)
    refine Finset.sum_le_sum_of_subset_of_nonneg hsub fun i _ _ => ?_
    exact mul_nonneg (coeff_nonneg hK i) (ramp_nonneg _)
  unfold plInterp
  linarith

/-- **The interpolant passes through the measured cells.** -/
theorem plInterp_natCast (K : Chain) (n : ℕ) : plInterp K (n : ℝ≥0) = (K n : ℝ) := by
  have hc : ((n : ℝ≥0) : ℝ) = (n : ℝ) := by simp
  unfold plInterp
  rw [hc, Nat.ceil_natCast]
  have hramp : ∀ i ∈ range n, ((K (i + 1) : ℝ) - K i) * ramp ((n : ℝ) - i)
      = ((K (i + 1) : ℝ) - K i) := by
    intro i hi
    have hi' : i + 1 ≤ n := mem_range.mp hi
    have : (1 : ℝ) ≤ (n : ℝ) - i := by
      have : ((i : ℝ) + 1) ≤ (n : ℝ) := by exact_mod_cast hi'
      linarith
    rw [ramp_of_one_le this, mul_one]
  rw [Finset.sum_congr rfl hramp, Finset.sum_range_sub (fun i => (K i : ℝ)) n]
  ring

/-! ## The interpolation criterion -/

/-- **Existence of the real-parameter extension.**  Every monotone measured chain
carries a monotone real knee profile through its cells; by
`ScaleFlowCore.ScaleFlow.ofProfile` this profile generates a full `(ℝ≥0,+)` scale
flow restricting to the measured table. -/
theorem monotone_interp_exists {K : Chain} (hK : Monotone K) :
    ∃ K0 : RChain, Monotone K0 ∧ ∀ n : ℕ, K0 (n : ℝ≥0) = (K n : ℝ) :=
  ⟨plInterp K, plInterp_monotone hK, plInterp_natCast K⟩

/-- Conversely, a monotone interpolant forces the measured chain to be monotone. -/
theorem monotone_of_interp {K : Chain} {K0 : RChain} (hmono : Monotone K0)
    (hint : ∀ n : ℕ, K0 (n : ℝ≥0) = (K n : ℝ)) : Monotone K := by
  intro a b hab
  have : K0 (a : ℝ≥0) ≤ K0 (b : ℝ≥0) := hmono (by exact_mod_cast hab)
  rw [hint a, hint b] at this
  exact_mod_cast this

/-- **The interpolation criterion.**  The scale action extends from `(ℕ,+)` to
`(ℝ≥0,+)` through a monotone profile exactly when the measured chain is monotone:
the continuous theory is available precisely on the tables the discrete theory
admits. -/
theorem monotone_interp_iff (K : Chain) :
    (∃ K0 : RChain, Monotone K0 ∧ ∀ n : ℕ, K0 (n : ℝ≥0) = (K n : ℝ)) ↔ Monotone K :=
  ⟨fun ⟨_, hm, hi⟩ => monotone_of_interp hm hi, monotone_interp_exists⟩

/-! ## Uniqueness fails: the staircase interpolant -/

/-- The **staircase interpolant**: round the context up to the next measured
octave.  It is monotone and passes through the measured cells. -/
noncomputable def ceilInterp (K : Chain) : RChain := fun t => (K ⌈(t : ℝ)⌉₊ : ℝ)

theorem ceilInterp_monotone {K : Chain} (hK : Monotone K) : Monotone (ceilInterp K) := by
  intro t u htu
  have h : (t : ℝ) ≤ (u : ℝ) := by exact_mod_cast htu
  unfold ceilInterp
  exact_mod_cast hK (Nat.ceil_le_ceil h)

theorem ceilInterp_natCast (K : Chain) (n : ℕ) : ceilInterp K (n : ℝ≥0) = (K n : ℝ) := by
  unfold ceilInterp
  norm_num

/-- **Monotone interpolation alone does not determine intermediate scales.**  For
the measured NET-66 base chain the ramp interpolant and the staircase interpolant
are both monotone and both hit every measured cell, yet at the half-octave they
disagree by four keys (`18` versus `20`). -/
theorem interp_not_unique :
    Monotone (plInterp net66Base) ∧ Monotone (ceilInterp net66Base) ∧
      (∀ n : ℕ, plInterp net66Base (n : ℝ≥0) = (net66Base n : ℝ)) ∧
      (∀ n : ℕ, ceilInterp net66Base (n : ℝ≥0) = (net66Base n : ℝ)) ∧
      plInterp net66Base (1/2 : ℝ≥0) = 18 ∧ ceilInterp net66Base (1/2 : ℝ≥0) = 20 := by
  refine ⟨plInterp_monotone net66Base_mono, ceilInterp_monotone net66Base_mono,
    plInterp_natCast net66Base, ceilInterp_natCast net66Base, ?_, ?_⟩
  · have hc : (((1/2 : ℝ≥0)) : ℝ) = (1/2 : ℝ) := by norm_num
    have hceil : ⌈((1/2 : ℝ≥0) : ℝ)⌉₊ = 1 := by
      rw [hc, Nat.ceil_eq_iff (by norm_num)]
      norm_num
    unfold plInterp
    rw [hceil, hc]
    norm_num [net66Base, ramp]
  · have hc : (((1/2 : ℝ≥0)) : ℝ) = (1/2 : ℝ) := by norm_num
    have hceil : ⌈((1/2 : ℝ≥0) : ℝ)⌉₊ = 1 := by
      rw [hc, Nat.ceil_eq_iff (by norm_num)]
      norm_num
    unfold ceilInterp
    rw [hceil]
    norm_num [net66Base]

/-! ## Cauchy rigidity: stationary increments force affinity -/

/-- **Cauchy rigidity on `ℝ≥0`.**  A monotone additive function is linear.  No
continuity, measurability or rationality assumption is used: the floor squeeze
`⌊n t⌋ · g 1 ≤ n · g t ≤ (⌊n t⌋ + 1) · g 1` does all the work. -/
theorem eq_linear_of_monotone_of_additive {g : ℝ≥0 → ℝ} (hmono : Monotone g)
    (hadd : ∀ x y : ℝ≥0, g (x + y) = g x + g y) (t : ℝ≥0) : g t = g 1 * t := by
  have hzero : g 0 = 0 := by
    have := hadd 0 0
    simp at this
    linarith
  have hnat : ∀ (n : ℕ) (x : ℝ≥0), g ((n : ℝ≥0) * x) = (n : ℝ) * g x := by
    intro n x
    induction n with
    | zero => simp [hzero]
    | succ n ih =>
        have : ((n : ℝ≥0) + 1) * x = (n : ℝ≥0) * x + x := by ring
        push_cast
        rw [this, hadd, ih]
        ring
  have hg1 : 0 ≤ g 1 := by
    have := hmono (show (0 : ℝ≥0) ≤ 1 by norm_num)
    linarith [hzero]
  -- the floor squeeze
  have key : ∀ n : ℕ, 0 < n → |g t - g 1 * t| ≤ g 1 / n := by
    intro n hn
    set m : ℕ := ⌊(n : ℝ) * (t : ℝ)⌋₊ with hm
    have hnt_nonneg : (0 : ℝ) ≤ (n : ℝ) * (t : ℝ) := by positivity
    have hlow : (m : ℝ) ≤ (n : ℝ) * t := Nat.floor_le hnt_nonneg
    have hhigh : (n : ℝ) * t < (m : ℝ) + 1 := Nat.lt_floor_add_one _
    have hlow' : ((m : ℝ≥0)) ≤ (n : ℝ≥0) * t := by
      have : ((m : ℝ≥0) : ℝ) ≤ (((n : ℝ≥0) * t : ℝ≥0) : ℝ) := by push_cast; exact hlow
      exact_mod_cast this
    have hhigh' : ((n : ℝ≥0)) * t ≤ ((m : ℝ≥0) + 1) := by
      have : ((((n : ℝ≥0)) * t : ℝ≥0) : ℝ) ≤ (((m : ℝ≥0) + 1 : ℝ≥0) : ℝ) := by
        push_cast; linarith
      exact_mod_cast this
    have hgm : g (m : ℝ≥0) = (m : ℝ) * g 1 := by
      have := hnat m 1
      simpa using this
    have hgm1 : g ((m : ℝ≥0) + 1) = ((m : ℝ) + 1) * g 1 := by
      have : ((m : ℝ≥0) + 1) = ((m + 1 : ℕ) : ℝ≥0) := by push_cast; ring
      rw [this]
      have := hnat (m + 1) 1
      simpa using this
    have hgnt : g ((n : ℝ≥0) * t) = (n : ℝ) * g t := hnat n t
    have h1 : (m : ℝ) * g 1 ≤ (n : ℝ) * g t := by
      have := hmono hlow'
      rw [hgm, hgnt] at this
      exact this
    have h2 : (n : ℝ) * g t ≤ ((m : ℝ) + 1) * g 1 := by
      have := hmono hhigh'
      rw [hgm1, hgnt] at this
      exact this
    have h3 : (m : ℝ) * g 1 ≤ (n : ℝ) * (t * g 1) := by
      have : (m : ℝ) * g 1 ≤ ((n : ℝ) * t) * g 1 := mul_le_mul_of_nonneg_right hlow hg1
      linarith [this]
    have h4 : (n : ℝ) * (t * g 1) ≤ ((m : ℝ) + 1) * g 1 := by
      have : ((n : ℝ) * t) * g 1 ≤ ((m : ℝ) + 1) * g 1 :=
        mul_le_mul_of_nonneg_right (le_of_lt hhigh) hg1
      linarith [this]
    have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
    have habs : |(n : ℝ) * g t - (n : ℝ) * (t * g 1)| ≤ g 1 := by
      rw [abs_le]
      constructor <;> linarith
    have : |(n : ℝ)| * |g t - t * g 1| ≤ g 1 := by
      rw [← abs_mul]
      calc |(n : ℝ) * (g t - t * g 1)| = |(n : ℝ) * g t - (n : ℝ) * (t * g 1)| := by ring_nf
        _ ≤ g 1 := habs
    rw [abs_of_pos hnpos] at this
    rw [mul_comm (g 1) ((t : ℝ)), le_div_iff₀ hnpos]
    linarith
  -- pass to the limit
  have hnonneg : (0 : ℝ) ≤ |g t - g 1 * t| := abs_nonneg _
  have hzero' : |g t - g 1 * t| ≤ 0 := by
    by_contra hcon
    push_neg at hcon
    obtain ⟨n, hnlt⟩ := exists_nat_gt (g 1 / |g t - g 1 * t|)
    have hnpos : (0 : ℝ) < (n : ℝ) := lt_of_le_of_lt (by positivity) hnlt
    have hn : 0 < n := by exact_mod_cast hnpos
    have hb := key n hn
    have : g 1 / |g t - g 1 * t| < n := hnlt
    have hlt : g 1 < |g t - g 1 * t| * n := by
      rw [div_lt_iff₀ hcon] at this
      linarith
    have : |g t - g 1 * t| ≤ g 1 / n := hb
    rw [le_div_iff₀ hnpos] at this
    linarith
  have : |g t - g 1 * t| = 0 := le_antisymm hzero' hnonneg
  have := abs_eq_zero.mp this
  linarith

/-- **The generator theorem.**  A monotone real profile whose increments are
*stationary* — the change over an interval depends only on the length of the
interval, the defining property of a one-parameter flow — is affine, and its slope
is the keys-per-octave rate `K₀ 1 − K₀ 0`. -/
theorem affine_of_monotone_of_stationary_increments {K0 : RChain} (hmono : Monotone K0)
    (hstat : ∀ t u : ℝ≥0, K0 (t + u) - K0 t = K0 u - K0 0) (t : ℝ≥0) :
    K0 t = K0 0 + (K0 1 - K0 0) * t := by
  set g : ℝ≥0 → ℝ := fun x => K0 x - K0 0 with hg
  have hgmono : Monotone g := fun a b hab => by
    simp only [hg]
    linarith [hmono hab]
  have hgadd : ∀ x y : ℝ≥0, g (x + y) = g x + g y := by
    intro x y
    have := hstat x y
    simp only [hg]
    linarith
  have := eq_linear_of_monotone_of_additive hgmono hgadd t
  simp only [hg] at this
  linarith

/-! ## Arithmetic base chains -/

/-- The **affine profile** `k₀ + δ·t`. -/
noncomputable def affineProfile (k0 delta : ℝ) : RChain := fun t => k0 + delta * t

theorem affineProfile_monotone {k0 delta : ℝ} (hδ : 0 ≤ delta) :
    Monotone (affineProfile k0 delta) := by
  intro a b hab
  have : ((a : ℝ)) ≤ (b : ℝ) := by exact_mod_cast hab
  simp only [affineProfile]
  nlinarith

theorem affineProfile_interpolates {k0 delta : ℝ} (K : Chain)
    (hK : ∀ j : ℕ, (K j : ℝ) = k0 + delta * j) (n : ℕ) :
    affineProfile k0 delta (n : ℝ≥0) = (K n : ℝ) := by
  simp only [affineProfile, hK n, NNReal.coe_natCast]

theorem affineProfile_stationary (k0 delta : ℝ) (t u : ℝ≥0) :
    affineProfile k0 delta (t + u) - affineProfile k0 delta t
      = affineProfile k0 delta u - affineProfile k0 delta 0 := by
  simp only [affineProfile, NNReal.coe_add, NNReal.coe_zero]
  ring

/-- **Existence and uniqueness for arithmetic base chains.**  For a measured chain
with constant octave increment `δ ≥ 0` the affine profile interpolates it, and it
is the *only* monotone interpolant with stationary increments.  The scale flow of
an arithmetic chain is therefore canonical: `k*(σ, t) = k₀ + δ·(t − σ)⁺`. -/
theorem arith_interp_unique {k0 delta : ℝ} (hδ : 0 ≤ delta) (K : Chain)
    (hK : ∀ j : ℕ, (K j : ℝ) = k0 + delta * j) :
    (Monotone (affineProfile k0 delta) ∧
      (∀ n : ℕ, affineProfile k0 delta (n : ℝ≥0) = (K n : ℝ)) ∧
      (∀ t u : ℝ≥0, affineProfile k0 delta (t + u) - affineProfile k0 delta t
        = affineProfile k0 delta u - affineProfile k0 delta 0)) ∧
    (∀ K0 : RChain, Monotone K0 → (∀ n : ℕ, K0 (n : ℝ≥0) = (K n : ℝ)) →
      (∀ t u : ℝ≥0, K0 (t + u) - K0 t = K0 u - K0 0) →
      ∀ t : ℝ≥0, K0 t = affineProfile k0 delta t) := by
  refine ⟨⟨affineProfile_monotone hδ, affineProfile_interpolates K hK,
    affineProfile_stationary k0 delta⟩, ?_⟩
  intro K0 hmono hint hstat t
  have h0 : K0 0 = k0 := by
    have := hint 0
    rw [hK 0] at this
    simpa using this
  have h1 : K0 1 = k0 + delta := by
    have := hint 1
    rw [hK 1] at this
    simpa using this
  have := affine_of_monotone_of_stationary_increments hmono hstat t
  rw [h0, h1] at this
  simp only [affineProfile]
  rw [this]
  ring

/-- The NET-66 base chain `16 + 4·j` is arithmetic, so its scale flow is the
canonical affine one. -/
theorem net66_arith (j : ℕ) : (net66Base j : ℝ) = 16 + 4 * j := by
  simp only [net66Base]
  push_cast
  ring

/-- The canonical NET-66 real profile: `K₀ t = 16 + 4·t` keys. -/
noncomputable def net66Profile : RChain := affineProfile 16 4

theorem net66Profile_unique :
    (Monotone net66Profile ∧ ∀ n : ℕ, net66Profile (n : ℝ≥0) = (net66Base n : ℝ)) ∧
      ∀ K0 : RChain, Monotone K0 → (∀ n : ℕ, K0 (n : ℝ≥0) = (net66Base n : ℝ)) →
        (∀ t u : ℝ≥0, K0 (t + u) - K0 t = K0 u - K0 0) → ∀ t : ℝ≥0, K0 t = net66Profile t := by
  obtain ⟨⟨hm, hi, _⟩, huniq⟩ := arith_interp_unique (by norm_num : (0:ℝ) ≤ 4) net66Base net66_arith
  exact ⟨⟨hm, hi⟩, huniq⟩

/-! ## The extension theorem in the form the measurement programme asks for -/

/-- **The real-parameter extension exists for every measured scale family.**  For
any family obeying the discrete exchange and boundary laws there is a monotone real
profile `K₀ : ℝ≥0 → ℝ` with `k*(σ, j) = K₀((j − σ)⁺)` on the whole measured table:
the scale action extends from `(ℕ,+)` to `(ℝ≥0,+)` without losing a single cell.
(For an arithmetic base chain `arith_interp_unique` shows the profile is moreover
unique among the stationary-increment ones.) -/
theorem exists_monotone_profile_of_family (F : ScaleFamily) :
    ∃ K0 : RChain, Monotone K0 ∧
      ∀ s j : ℕ, K0 ((j : ℝ≥0) - (s : ℝ≥0)) = (F.chain s j : ℝ) := by
  refine ⟨plInterp (F.chain 0), plInterp_monotone F.base_mono, ?_⟩
  intro s j
  rw [natCast_tsub, plInterp_natCast, F.apply_eq s j]

end Tropical.ScaleFlowInterpolation