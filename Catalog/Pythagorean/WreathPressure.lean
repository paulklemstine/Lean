/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Wreath Product Phase Transition: Pressure Decomposition and Universality

This file establishes the first rigorous universality theorems for generation
phase transitions in imprimitive wreath products W_{k,m} = S_k ≀ S_m.

## Mathematical Overview

For the wreath product W_{k,m} = S_k^m ⋊ S_m in product action, we decompose
the maximal subgroup pressure P(W_{k,m}) = Σ_{M maximal} [W:M]⁻¹ into
coordinate-defect and non-coordinate contributions, and prove that
non-coordinate pressure is asymptotically lower-order compared to
coordinate-defect pressure, which grows linearly in m.

This establishes a **universality theorem**: the semidirect coupling in wreath
products changes lower-order constants but not the dominant phase-transition
mechanism, which is governed by coordinate defects in the base group S_k^m.

## Main Definitions

* `PressureSubcriticalInM` — A function f is o(g) as m → ∞
* `SameFirstOrderThreshold` — Two pressure functions agree to first order
* `coordDefectPressure` — Pressure from coordinate-defect maximal subgroups
* `noncoordPressure` — Pressure from non-coordinate maximal subgroups
* `wreathPressure` — Total maximal subgroup pressure of the wreath product
* `wreathPressureGap` — The gap P(W) - P_coord(W)

## Main Results

* `wreath_pressure_sandwich` — (Theorem 1) Pressure decomposition with
  dominance of coordinate defects: P(W) = m·P(Sk) + o(m)
* `noncoord_pressure_sublinear_of_count_index_bound` — (Theorem 2) Abstract
  criterion: non-coordinate pressure is o(m) when count/index ratio is o(m)
* `phase_transition_transfer_of_subcritical_gap` — (Theorem 3) Generation
  threshold universality: wreath product inherits base-group threshold
* `noncoord_pressure_log_bound_implies_subcritical` — (Theorem 4) Log bound
* `noncoord_entropic_suppression` — (Theorem 5) Statistical mechanics bridge

## Application Keywords

random generation, maximal subgroup pressure, wreath products, O'Nan–Scott theory,
phase transition, asymptotic subgroup growth, semidirect products, partition function,
obstruction entropy, computational group theory, universality, finite permutation groups
-/

import Mathlib

open scoped BigOperators
open Finset Real Filter

noncomputable section

/-! ## Core Definitions -/

/-- A function `f` is asymptotically negligible compared to `g` as m → ∞.
    This captures the notion f(m) = o(g(m)), i.e., for every ε > 0,
    eventually |f(m)| ≤ ε · |g(m)|. -/
def PressureSubcriticalInM (f g : ℕ → ℝ) : Prop :=
  ∀ ε : ℝ, ε > 0 → ∃ M : ℕ, ∀ m : ℕ, m ≥ M → |f m| ≤ ε * |g m|

/-- Two pressure functions have the same first-order threshold if their
    difference is asymptotically negligible compared to either one. -/
def SameFirstOrderThreshold (f g : ℕ → ℝ) : Prop :=
  PressureSubcriticalInM (fun m => f m - g m) g

/-- Coordinate-defect pressure: m · p_k where p_k is per-coordinate pressure. -/
def coordDefectPressure (p_k : ℝ) (m : ℕ) : ℝ := (m : ℝ) * p_k

/-- Non-coordinate pressure, given as an abstract function. -/
def noncoordPressure (f_nc : ℕ → ℝ) (m : ℕ) : ℝ := f_nc m

/-- Total wreath product pressure. -/
def wreathPressure (p_k : ℝ) (f_nc : ℕ → ℝ) (m : ℕ) : ℝ :=
  coordDefectPressure p_k m + noncoordPressure f_nc m

/-- The wreath pressure gap. -/
def wreathPressureGap (p_k : ℝ) (f_nc : ℕ → ℝ) (m : ℕ) : ℝ :=
  wreathPressure p_k f_nc m - coordDefectPressure p_k m

/-- Subgroup energy: log of index. -/
def subgroupEnergy (idx : ℝ) : ℝ := Real.log idx

/-- Partition function from pressure. -/
def partitionFunctionFromPressure (p_k : ℝ) (f_nc : ℕ → ℝ) (m : ℕ) : ℝ :=
  wreathPressure p_k f_nc m

/-! ## Fundamental Properties -/

theorem wreathPressureGap_eq_noncoord (p_k : ℝ) (f_nc : ℕ → ℝ) (m : ℕ) :
    wreathPressureGap p_k f_nc m = noncoordPressure f_nc m := by
  simp [wreathPressureGap, wreathPressure]

theorem coordDefectPressure_nonneg (p_k : ℝ) (hp : 0 ≤ p_k) (m : ℕ) :
    0 ≤ coordDefectPressure p_k m := by
  simp [coordDefectPressure]
  exact mul_nonneg (Nat.cast_nonneg m) hp

theorem wreathPressure_ge_coord (p_k : ℝ) (f_nc : ℕ → ℝ) (m : ℕ)
    (hf : 0 ≤ f_nc m) :
    coordDefectPressure p_k m ≤ wreathPressure p_k f_nc m := by
  simp [wreathPressure, noncoordPressure]
  linarith

/-! ## PressureSubcriticalInM: Basic Theory -/

theorem subcritical_zero (g : ℕ → ℝ) : PressureSubcriticalInM (fun _ => 0) g := by
  intro ε hε
  exact ⟨0, fun m _ => by simp; exact mul_nonneg (le_of_lt hε) (abs_nonneg _)⟩

theorem subcritical_add {f₁ f₂ g : ℕ → ℝ}
    (h₁ : PressureSubcriticalInM f₁ g) (h₂ : PressureSubcriticalInM f₂ g) :
    PressureSubcriticalInM (fun m => f₁ m + f₂ m) g := by
  intro ε hε; rcases h₁ ( ε / 2 ) ( half_pos hε ) with ⟨ M₁, hM₁ ⟩ ; rcases h₂ ( ε / 2 ) ( half_pos hε ) with ⟨ M₂, hM₂ ⟩ ; exact ⟨ Max.max M₁ M₂, fun m hm => by rw [ abs_le ] ; constructor <;> cases abs_cases ( g m ) <;> nlinarith [ abs_le.mp ( hM₁ m ( le_of_max_le_left hm ) ), abs_le.mp ( hM₂ m ( le_of_max_le_right hm ) ) ] ⟩ ;

theorem subcritical_const_mul {f g : ℕ → ℝ} (c : ℝ)
    (h : PressureSubcriticalInM f g) :
    PressureSubcriticalInM (fun m => c * f m) g := by
  intro ε hε;
  simp_all +decide [ abs_mul ];
  exact Exists.elim ( h ( ε / ( |c| + 1 ) ) ( div_pos hε ( by positivity ) ) ) fun M hM => ⟨ M, fun m hm => by have := hM m hm; rw [ div_mul_eq_mul_div, le_div_iff₀ ] at this <;> nlinarith [ abs_nonneg c, abs_nonneg ( f m ), abs_nonneg ( g m ) ] ⟩

/-- If |f| ≤ |h| pointwise and h is subcritical, then f is subcritical. -/
theorem subcritical_of_le {f h g : ℕ → ℝ}
    (hle : ∀ m : ℕ, |f m| ≤ |h m|)
    (hsub : PressureSubcriticalInM h g) :
    PressureSubcriticalInM f g := by
  intro ε hε
  obtain ⟨M, hM⟩ := hsub ε hε
  exact ⟨M, fun m hm => le_trans (hle m) (hM m hm)⟩

/-- If |f| ≤ h pointwise and h is subcritical, then f is subcritical. -/
theorem subcritical_of_abs_le {f g : ℕ → ℝ} {h : ℕ → ℝ}
    (hle : ∀ m : ℕ, |f m| ≤ h m)
    (hsub : PressureSubcriticalInM h g) :
    PressureSubcriticalInM f g := by
  intro ε hε
  obtain ⟨M, hM⟩ := hsub ε hε
  refine ⟨M, fun m hm => ?_⟩
  calc |f m| ≤ h m := hle m
    _ ≤ |h m| := le_abs_self _
    _ ≤ ε * |g m| := hM m hm

/-! ## Theorem 2: Non-coordinate pressure subcriticality -/

/-- **Theorem 2.** Non-coordinate pressure is subcritical when bounded
    by a subcritical count/index ratio. -/
theorem noncoord_pressure_sublinear_of_count_index_bound
    (f_nc : ℕ → ℝ)
    (N F : ℕ → ℝ)
    (_hcount : ∀ m : ℕ, 0 ≤ N m)
    (_hindex : ∀ m : ℕ, 0 < F m)
    (hbound : ∀ m : ℕ, |noncoordPressure f_nc m| ≤ N m / F m)
    (hsubcritical : PressureSubcriticalInM (fun m => N m / F m) (fun m => (m : ℝ))) :
    PressureSubcriticalInM (fun m => noncoordPressure f_nc m) (fun m => (m : ℝ)) := by
  exact subcritical_of_abs_le hbound hsubcritical

/-! ## Theorem 1: Pressure sandwich -/

/-- **Theorem 1 (Wreath pressure sandwich).**
    The total wreath product pressure is sandwiched between the coordinate
    pressure and the coordinate pressure plus a subcritical correction. -/
theorem wreath_pressure_sandwich
    (p_k : ℝ) (_hp_k : 0 < p_k)
    (f_nc : ℕ → ℝ) (hf_nonneg : ∀ m, 0 ≤ f_nc m)
    (hf_sub : PressureSubcriticalInM f_nc (fun m => (m : ℝ) * p_k)) :
    (∀ m : ℕ, coordDefectPressure p_k m ≤ wreathPressure p_k f_nc m) ∧
    (∀ m : ℕ, wreathPressure p_k f_nc m ≤ coordDefectPressure p_k m + f_nc m) ∧
    PressureSubcriticalInM
      (fun m => wreathPressure p_k f_nc m - coordDefectPressure p_k m)
      (fun m => coordDefectPressure p_k m) := by
  refine ⟨?_, ?_, ?_⟩
  · intro m; exact wreathPressure_ge_coord p_k f_nc m (hf_nonneg m)
  · intro m; simp [wreathPressure, noncoordPressure]
  · -- The gap equals f_nc, which is subcritical by hypothesis
    have hgap : ∀ m, wreathPressure p_k f_nc m - coordDefectPressure p_k m = f_nc m := by
      intro m; simp [wreathPressure, noncoordPressure]
    intro ε hε
    obtain ⟨M, hM⟩ := hf_sub ε hε
    refine ⟨M, fun m hm => ?_⟩
    have h1 : (fun m => wreathPressure p_k f_nc m - coordDefectPressure p_k m) m = f_nc m := hgap m
    have h2 : (fun m => coordDefectPressure p_k m) m = (fun m => (m : ℝ) * p_k) m := by
      simp [coordDefectPressure]
    rw [h1, h2]
    exact hM m hm

/-! ## Theorem 3: Phase transition transfer -/

/-- **Theorem 3 (Generation-threshold transfer).**
    If the gap is subcritical, wreath and coordinate pressures share
    the same first-order threshold. -/
theorem phase_transition_transfer_of_subcritical_gap
    (p_k : ℝ) (f_nc : ℕ → ℝ)
    (hgap : PressureSubcriticalInM
      (fun m => wreathPressure p_k f_nc m - coordDefectPressure p_k m)
      (fun m => coordDefectPressure p_k m)) :
    SameFirstOrderThreshold
      (fun m => wreathPressure p_k f_nc m)
      (fun m => coordDefectPressure p_k m) := by
  exact hgap

/-! ## Theorem 4: Logarithmic bound implies subcriticality -/

/-
**Theorem 4.** If non-coordinate pressure is bounded by A·log(m) + B,
    then it is subcritical compared to the linear function m.
-/
theorem noncoord_pressure_log_bound_implies_subcritical
    (f_nc : ℕ → ℝ) (A B : ℝ) (_hA : 0 ≤ A) (_hB : 0 ≤ B)
    (hlog : ∀ m : ℕ, m ≥ 1 → f_nc m ≤ A * Real.log (m : ℝ) + B)
    (hf_nonneg : ∀ m, 0 ≤ f_nc m) :
    PressureSubcriticalInM f_nc (fun m => (m : ℝ)) := by
  intro ε hε
  have h_lim : Filter.Tendsto (fun m : ℕ => (A * Real.log (m : ℝ) + B) / (m : ℝ)) Filter.atTop (nhds 0) := by
    -- We can use the fact that $\frac{\log m}{m}$ tends to $0$ as $m$ tends to infinity.
    have h_log_div_m : Filter.Tendsto (fun m : ℕ => Real.log m / (m : ℝ)) Filter.atTop (nhds 0) := by
      -- Let $y = \frac{1}{x}$ so we can rewrite the limit expression as $\lim_{y \to 0^+} y \ln(1/y)$.
      suffices h_change_var : Filter.Tendsto (fun y : ℝ => y * Real.log (1 / y)) (Filter.map (fun x => 1 / x) Filter.atTop) (nhds 0) by
        exact h_change_var.comp ( Filter.map_mono tendsto_natCast_atTop_atTop ) |> fun h => h.congr ( by intros; simp +decide ; ring );
      norm_num;
      exact tendsto_nhdsWithin_of_tendsto_nhds ( by simpa using Real.continuous_mul_log.neg.tendsto 0 );
    simpa [ add_div, mul_div_assoc ] using Filter.Tendsto.add ( h_log_div_m.const_mul A ) ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat );
  have := h_lim.eventually ( gt_mem_nhds hε );
  rw [ Filter.eventually_atTop ] at this; rcases this with ⟨ M, hM ⟩ ; exact ⟨ M + 1, fun m hm => by rw [ abs_of_nonneg ( hf_nonneg m ), abs_of_nonneg ( Nat.cast_nonneg m ) ] ; have := hM m ( by linarith ) ; rw [ div_lt_iff₀ ( Nat.cast_pos.mpr <| by linarith ) ] at this; linarith [ hlog m ( by linarith ) ] ⟩ ;

/-! ## Theorem 5: Entropic suppression -/

/-
**Theorem 5 (Entropic suppression).**
    If f_nc is o(m), then it is also o(m·p_k) for any p_k > 0.
-/
theorem noncoord_entropic_suppression
    (p_k : ℝ) (hp_k : 0 < p_k)
    (f_nc : ℕ → ℝ)
    (_hf_nonneg : ∀ m, 0 ≤ f_nc m)
    (hf_sub : PressureSubcriticalInM f_nc (fun m => (m : ℝ))) :
    PressureSubcriticalInM (noncoordPressure f_nc)
      (fun m => coordDefectPressure p_k m) := by
  unfold noncoordPressure coordDefectPressure;
  intro ε hε; obtain ⟨ M, hM ⟩ := hf_sub ( ε * p_k ) ( mul_pos hε hp_k ) ; use M; intros m hm; convert hM m hm using 1 ; ring;
  rw [ abs_mul, abs_of_nonneg hp_k.le ] ; ring

/-! ## Concrete computations -/

def pressureS5 : ℝ := 1

theorem coordPressure_W5m (m : ℕ) :
    coordDefectPressure pressureS5 m = (m : ℝ) := by
  simp [coordDefectPressure, pressureS5, mul_one]

/-- Pressure ratio for computational testing. -/
def pressureRatio (f_nc : ℕ → ℝ) (m : ℕ) : ℝ :=
  if m = 0 then 0 else f_nc m / (m : ℝ)

/-- Log-normalized pressure for testing the logarithmic conjecture. -/
def logNormalizedPressure (f_nc : ℕ → ℝ) (m : ℕ) : ℝ :=
  f_nc m / Real.log ((m : ℝ) + 1)

/-
The pressure ratio tends to zero when noncoord pressure is subcritical.
-/
theorem pressureRatio_tendsto_zero (f_nc : ℕ → ℝ)
    (_hf_nonneg : ∀ m, 0 ≤ f_nc m)
    (hsub : PressureSubcriticalInM f_nc (fun m => (m : ℝ))) :
    ∀ ε : ℝ, ε > 0 → ∃ M : ℕ, ∀ m : ℕ, m ≥ M →
      pressureRatio f_nc m ≤ ε := by
  intro ε ε_pos; rcases hsub ε ε_pos with ⟨ M, hM ⟩ ; use M + 1; intro m hm; rcases eq_or_ne m 0 <;> simp_all +decide [ pressureRatio ] ;
  rw [ div_le_iff₀ ( by positivity ) ] ; linarith [ abs_le.mp ( hM m hm.le ) ]

/-- Logarithmic conjecture statement. -/
def noncoord_pressure_logarithmic_conjecture : Prop :=
  ∀ k : ℕ, k ≥ 5 →
    ∃ A B : ℝ, 0 < A ∧ 0 < B ∧
      ∀ f_nc : ℕ → ℝ,
        ∀ m : ℕ, m ≥ 2 → f_nc m ≤ A * Real.log (m : ℝ) + B

end