/-
# Transfer Theorems: Zero-Free Regions to Arithmetic Consequences

This module proves the core transfer theorems that connect zero-free region
hypotheses to concrete arithmetic consequences:

1. `zero_free_of_smaller_constant` — Region inheritance from a stronger zero-free region
2. `zero_free_vertical_strip` — Vertical strip corollary
3. `noZerosUpToHeight_of_logZeroFree` — Zero-count stabilization
4. `psiError_small_o_identity` — Prime error sublinearity (o(x) bound)

It imports definitions and barrier lemmas from the Defs and Barrier modules.
-/

import Mathlib

open Complex Real Filter Topology Asymptotics

/-! ## Definitions (from Defs module) -/

structure LogZeroFreeDatum' where
  F : ℂ → ℂ
  c : ℝ
  T0 : ℝ
  c_pos : 0 < c
  T0_nonneg : 0 ≤ T0
  zero_free :
    ∀ s : ℂ, T0 ≤ |s.im| →
      1 - c / Real.log (|s.im| + 2) < s.re →
      F s ≠ 0

def NoZerosUpToHeight' (F : ℂ → ℂ) (σ T : ℝ) : Prop :=
  ∀ s : ℂ, σ < s.re → |s.im| ≤ T → F s ≠ 0

structure PrimeCountingTransferDatum' where
  psiError : ℝ → ℝ
  A : ℝ
  B : ℝ
  A_pos : 0 < A
  B_pos : 0 < B
  transfer :
    ∀ x : ℝ, 2 ≤ x →
      |psiError x| ≤ A * x * Real.exp (-B * Real.sqrt (Real.log x))

/-! ## Barrier lemmas (from Barrier module) -/

private theorem log_pos_of_nonneg_add_two' {y : ℝ} (hy : 0 ≤ y) :
    0 < Real.log (y + 2) :=
  Real.log_pos (by linarith)

private theorem log_barrier_mono'
    {c y₁ y₂ : ℝ}
    (hc : 0 < c)
    (hy₁ : 0 ≤ y₁)
    (h12 : y₁ ≤ y₂) :
    1 - c / Real.log (y₁ + 2) ≤ 1 - c / Real.log (y₂ + 2) := by
  gcongr
  exact Real.log_pos (by linarith)

private theorem exp_neg_sqrt_log_decay'
    {B : ℝ} (hB : 0 < B) :
    Tendsto (fun x : ℝ => Real.exp (-B * Real.sqrt (Real.log x))) atTop (𝓝 0) := by
  norm_num [ Real.sqrt_eq_rpow ];
  exact Filter.Tendsto.const_mul_atTop hB ( tendsto_rpow_atTop ( by norm_num ) |> Filter.Tendsto.comp <| Real.tendsto_log_atTop )

/-! ## Theorem: Region Inheritance -/

/-
**Region Inheritance.** If F is zero-free in a region with constant c,
then it is zero-free in every strictly smaller region with constant c' ≤ c.
-/
theorem zero_free_of_smaller_constant
    (D : LogZeroFreeDatum')
    {c' : ℝ}
    (_hc' : 0 < c')
    (hcc' : c' ≤ D.c) :
    ∀ s : ℂ, D.T0 ≤ |s.im| →
      1 - c' / Real.log (|s.im| + 2) < s.re →
      D.F s ≠ 0 := by
  intro s hs h's;
  convert D.zero_free s hs _ using 1;
  exact lt_of_le_of_lt ( sub_le_sub_left ( div_le_div_of_nonneg_right hcc' <| Real.log_nonneg <| by linarith [ abs_nonneg s.im ] ) _ ) h's

/-! ## Theorem: Vertical Strip Corollary -/

/-
**Vertical Strip Corollary.** If |Im(s)| ≤ T, then the logarithmic
zero-free region implies a fixed vertical strip free of zeros.
-/
theorem zero_free_vertical_strip
    (D : LogZeroFreeDatum')
    {T : ℝ}
    (_hT0 : D.T0 ≤ T)
    (_hT : 0 ≤ T) :
    ∀ s : ℂ, D.T0 ≤ |s.im| → |s.im| ≤ T →
      1 - D.c / Real.log (T + 2) < s.re →
      D.F s ≠ 0 := by
  intro s hs1 hs2 hs3'';
  convert D.zero_free s hs1 _ using 1;
  refine' lt_of_le_of_lt _ hs3'';
  gcongr;
  · linarith [ D.c_pos ];
  · exact Real.log_pos ( by linarith [ abs_nonneg s.im ] )

/-! ## Theorem: Zero-Count Stabilization -/

/-
**Zero-Count Stabilization.** The logarithmic zero-free region implies
that there are no zeros of F in the induced half-strip (for heights ≥ T₀).
-/
theorem noZerosUpToHeight_of_logZeroFree
    (D : LogZeroFreeDatum')
    {T : ℝ}
    (hT0 : D.T0 ≤ T)
    (hT : 0 ≤ T) :
    ∀ s : ℂ, D.T0 ≤ |s.im| → 1 - D.c / Real.log (T + 2) < s.re → |s.im| ≤ T → D.F s ≠ 0 := by
  exact fun s hs₁ hs₂ hs₃ => zero_free_vertical_strip D hT0 hT s hs₁ hs₃ hs₂

/-! ## Theorem: Prime Error Sublinearity -/

/-
**Prime Error Sublinearity.** If the prime-counting error satisfies
  |ψ(x) - x| ≤ A · x · exp(-B · √(log x)),
then |ψ(x) - x| / x → 0 as x → ∞.
-/
theorem psiError_small_o_identity
    (D : PrimeCountingTransferDatum') :
    Tendsto (fun x : ℝ => |D.psiError x| / x) atTop (𝓝 0) := by
  -- For x ≥ 2, by D.transfer: |D.psiError x| ≤ D.A * x * exp(-D.B * √(log x)), so |D.psiError x| / x ≤ D.A * exp(-D.B * √(log x)).
  have h_bound : ∀ x ≥ 2, |D.psiError x| / x ≤ D.A * Real.exp (-D.B * Real.sqrt (Real.log x)) := by
    intro x hx; rw [ div_le_iff₀ ( by positivity ) ] ; linarith [ D.transfer x hx ] ;
  refine' squeeze_zero_norm' _ _;
  exacts [ fun x => D.A * Real.exp ( -D.B * Real.sqrt ( Real.log x ) ), Filter.eventually_atTop.mpr ⟨ 2, fun x hx => by rw [ Real.norm_of_nonneg ( by positivity ) ] ; exact h_bound x hx ⟩, by simpa using tendsto_const_nhds.mul ( Real.tendsto_exp_atBot.comp <| Filter.Tendsto.const_mul_atTop_of_neg ( neg_lt_zero.mpr <| D.B_pos ) <| by simpa only [ Real.sqrt_eq_rpow ] using tendsto_rpow_atTop ( by positivity ) |> Filter.Tendsto.comp <| Real.tendsto_log_atTop ) ]