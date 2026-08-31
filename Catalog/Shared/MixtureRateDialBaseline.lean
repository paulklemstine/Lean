import Mathlib
import Shared.MixtureRateDialCells

/-!
# A flat-composition mixture baseline is a ray: it cannot absorb a positional excess (Part II)

Context: experiment 588c / paper 242.  A mid-window excess of the sieve hit
profile survived a `16`-cell divisibility mixture baseline
`PRED(t) = Σ_c κ_c · S_c(t)` with amplitude `0.1774 ± 0.0432` (`z = 4.11`) and
`0 %` removal relative to the single-`α` baseline.  Part I
(`Shared.MixtureRateDialCells`) proved the *structural* reason the mixture had no
positional freedom: the divisibility cell of `j² - N` is `210`-periodic in `j`,
so the class composition of a window is exactly the same wherever the window is.

This file proves the *algebraic* consequence — the theorem behind the slogan
**"divisibility is a rate dial, not a position dial"**.

* `mixPred_eq_smul` — flat composition collapses the whole `|C|`-parameter
  mixture family to a single scalar multiple of the common shape `B`.
* `mixture_family_eq_ray` — the set of achievable predictions is *exactly* the
  ray `{K · B}`; the mixture has one degree of freedom (a rate) and none in `t`.
* `mixPred_no_positional_freedom` — any two mixtures are proportional, pointwise
  in `t`.
* `relExcess_invariant`, `removal_eq_zero` — the residual's relative mid-window
  excess is *identical* to the one over the single-shape baseline: the removal
  fraction is exactly `0 %`, matching the measurement.
* `peak_position_invariant`, `argmax_invariant` — the peak stays at the same `t`.
* `mixture_cannot_fit_nonproportional` — if the measurement is not proportional
  to `B`, no mixture reproduces it.
* `mixPred_drift_bounds`, `excess_ratio_lower_bound_div` — the robust version:
  if composition is flat only up to a relative drift `δ`, the mixture can shrink
  the excess by at most the factor `(1-δ)/(1+δ)`.
* `absorption_requires_drift`, `drift_budget_measured` — the inverse, scale-free
  reading: absorbing a relative excess `ρ - 1` needs composition drift at least
  `(ρ-1)/(ρ+1)`, i.e. `8.1 %` for the measured excess against a measured drift of
  `0.269 %`.
* `H0_excess_survives_measured`, `H0_excess_beats_bar` — the registered verdict
  with the measured numbers: with the measured drift `δ = 0.269 %` and raw
  excess `0.1774`, the mixture residual excess is still `≥ 0.1710`, far above the
  registered bar `2 · SE = 0.0864` (and above the null-calibrated scale as well).
* `divisibility_mixture_excess_survives` — the capstone, with the mixture built
  from the *actual* `210`-periodic cell populations of Part I.
-/

namespace RateDial

open Finset

variable {C : Type*} [Fintype C]

/-! ## Flat composition and the mixture prediction -/

/-- A cell-resolved reference model has **flat composition** if every cell's
reference sum is a fixed fraction `w c` of one common positional shape `B`.
This is what Part I proves for the divisibility grid of `j² - N`. -/
def FlatComposition (S : C → ℝ → ℝ) (w : C → ℝ) (B : ℝ → ℝ) : Prop :=
  ∀ c t, S c t = w c * B t

/-- The mixture prediction `PRED(t) = Σ_c κ_c · S_c(t)`. -/
noncomputable def mixPred (κ : C → ℝ) (S : C → ℝ → ℝ) (t : ℝ) : ℝ := ∑ c, κ c * S c t

/-- The residual of a measured profile against a baseline. -/
noncomputable def resid (T P : ℝ → ℝ) (t : ℝ) : ℝ := T t / P t

/-- The relative excess of a residual between the peak `t₀` and a flank `t₁`
(the amplitude reported by the experiment). -/
noncomputable def relExcess (R : ℝ → ℝ) (t₀ t₁ : ℝ) : ℝ := R t₀ / R t₁ - 1

/-- **Collapse.**  Under flat composition every mixture is a scalar multiple of
the single common shape: the `|C|` rate parameters buy exactly one number. -/
theorem mixPred_eq_smul {S : C → ℝ → ℝ} {w : C → ℝ} {B : ℝ → ℝ}
    (hflat : FlatComposition S w B) (κ : C → ℝ) (t : ℝ) :
    mixPred κ S t = (∑ c, κ c * w c) * B t := by
  rw [mixPred, Finset.sum_mul]
  exact Finset.sum_congr rfl fun c _ => by rw [hflat c t]; ring

/-- **No positional freedom.**  Any two mixtures over a flat-composition grid are
proportional as functions of `t`. -/
theorem mixPred_no_positional_freedom {S : C → ℝ → ℝ} {w : C → ℝ} {B : ℝ → ℝ}
    (hflat : FlatComposition S w B) (κ κ' : C → ℝ) (s t : ℝ) :
    mixPred κ S t * mixPred κ' S s = mixPred κ S s * mixPred κ' S t := by
  rw [mixPred_eq_smul hflat, mixPred_eq_smul hflat, mixPred_eq_smul hflat,
    mixPred_eq_smul hflat]
  ring

/-- **The mixture family is a ray.**  If some cell has a nonzero share, the set
of achievable predictions is exactly `{K · B : K ∈ ℝ}` — one rate dial, no
positional dial. -/
theorem mixture_family_eq_ray [DecidableEq C] {S : C → ℝ → ℝ} {w : C → ℝ} {B : ℝ → ℝ}
    (hflat : FlatComposition S w B) {c₀ : C} (hc₀ : w c₀ ≠ 0) :
    {f : ℝ → ℝ | ∃ κ : C → ℝ, mixPred κ S = f} = {f : ℝ → ℝ | ∃ K : ℝ, f = fun t => K * B t} := by
  ext f
  constructor
  · rintro ⟨κ, rfl⟩
    exact ⟨∑ c, κ c * w c, funext fun t => mixPred_eq_smul hflat κ t⟩
  · rintro ⟨K, rfl⟩
    refine ⟨fun c => if c = c₀ then K / w c₀ else 0, funext fun t => ?_⟩
    rw [mixPred_eq_smul hflat]
    have hsum : (∑ c, (if c = c₀ then K / w c₀ else 0) * w c) = K := by
      rw [Finset.sum_eq_single c₀]
      · rw [if_pos rfl]
        field_simp
      · intro b _ hb; simp [hb]
      · intro h; exact absurd (Finset.mem_univ c₀) h
    rw [hsum]

/-! ## The residual is unchanged: removal is exactly zero -/

/-- The residual against a flat mixture is the residual against `B`, rescaled by
the single fitted rate `K`. -/
theorem resid_mix_eq {S : C → ℝ → ℝ} {w : C → ℝ} {B T : ℝ → ℝ}
    (hflat : FlatComposition S w B) (κ : C → ℝ) (t : ℝ) :
    resid T (mixPred κ S) t = resid T B t / (∑ c, κ c * w c) := by
  simp only [resid, mixPred_eq_smul hflat]
  rw [div_div, mul_comm (B t) (∑ c, κ c * w c)]

/-- **Invariance of the amplitude.**  The relative mid-window excess of the
residual over the mixture baseline equals the one over the single common shape:
the mixture removes none of it. -/
theorem relExcess_invariant {S : C → ℝ → ℝ} {w : C → ℝ} {B T : ℝ → ℝ}
    (hflat : FlatComposition S w B) (κ : C → ℝ) {t₀ t₁ : ℝ}
    (hK : (∑ c, κ c * w c) ≠ 0) (hT : T t₁ ≠ 0) (hB : B t₁ ≠ 0) :
    relExcess (resid T (mixPred κ S)) t₀ t₁ = relExcess (resid T B) t₀ t₁ := by
  have h1 : resid T B t₁ ≠ 0 := div_ne_zero hT hB
  simp only [relExcess, resid_mix_eq hflat]
  congr 1
  field_simp

/-- **Removal is exactly `0 %`** (the pre-named corroboration of the experiment). -/
theorem removal_eq_zero {S : C → ℝ → ℝ} {w : C → ℝ} {B T : ℝ → ℝ}
    (hflat : FlatComposition S w B) (κ : C → ℝ) {t₀ t₁ : ℝ}
    (hK : (∑ c, κ c * w c) ≠ 0) (hT : T t₁ ≠ 0) (hB : B t₁ ≠ 0) :
    relExcess (resid T (mixPred κ S)) t₀ t₁ - relExcess (resid T B) t₀ t₁ = 0 := by
  rw [relExcess_invariant hflat κ hK hT hB, sub_self]

/-- **The peak does not move.**  If `t₀` dominates the single-shape residual on a
set `W`, it dominates the mixture residual on `W` as well. -/
theorem peak_position_invariant {S : C → ℝ → ℝ} {w : C → ℝ} {B T : ℝ → ℝ}
    (hflat : FlatComposition S w B) (κ : C → ℝ) {W : Set ℝ} {t₀ : ℝ}
    (hK : 0 < ∑ c, κ c * w c)
    (hmax : ∀ t ∈ W, resid T B t ≤ resid T B t₀) :
    ∀ t ∈ W, resid T (mixPred κ S) t ≤ resid T (mixPred κ S) t₀ := by
  intro t ht
  rw [resid_mix_eq hflat, resid_mix_eq hflat]
  exact (div_le_div_iff_of_pos_right hK).mpr (hmax t ht)

/-- Strict version: a strict interior peak stays a strict interior peak. -/
theorem argmax_invariant {S : C → ℝ → ℝ} {w : C → ℝ} {B T : ℝ → ℝ}
    (hflat : FlatComposition S w B) (κ : C → ℝ) {t t₀ : ℝ}
    (hK : 0 < ∑ c, κ c * w c) (hlt : resid T B t < resid T B t₀) :
    resid T (mixPred κ S) t < resid T (mixPred κ S) t₀ := by
  rw [resid_mix_eq hflat, resid_mix_eq hflat]
  exact (div_lt_div_iff_of_pos_right hK).mpr hlt

/-- **Non-fittability.**  If the measurement is not proportional to the common
shape at two positions, then no mixture reproduces it. -/
theorem mixture_cannot_fit_nonproportional {S : C → ℝ → ℝ} {w : C → ℝ} {B T : ℝ → ℝ}
    (hflat : FlatComposition S w B) {t₀ t₁ : ℝ}
    (hnp : T t₀ * B t₁ ≠ T t₁ * B t₀) (κ : C → ℝ) :
    mixPred κ S ≠ T := by
  intro hEq
  apply hnp
  have h0 : T t₀ = (∑ c, κ c * w c) * B t₀ := by
    rw [← hEq]; exact mixPred_eq_smul hflat κ t₀
  have h1 : T t₁ = (∑ c, κ c * w c) * B t₁ := by
    rw [← hEq]; exact mixPred_eq_smul hflat κ t₁
  rw [h0, h1]; ring

/-! ## Robust version: composition flat only up to a relative drift `δ` -/

/-- With per-cell relative drift at most `δ`, the mixture is squeezed between
`(1-δ)` and `(1+δ)` times the exactly-flat prediction. -/
theorem mixPred_drift_bounds {S : C → ℝ → ℝ} {w : C → ℝ} {B : ℝ → ℝ} {κ : C → ℝ}
    {δ t : ℝ} (hκ : ∀ c, 0 ≤ κ c)
    (hdrift : ∀ c, |S c t - w c * B t| ≤ δ * (w c * B t)) :
    (1 - δ) * ((∑ c, κ c * w c) * B t) ≤ mixPred κ S t ∧
      mixPred κ S t ≤ (1 + δ) * ((∑ c, κ c * w c) * B t) := by
  have hlow : ∀ c, (1 - δ) * (w c * B t) ≤ S c t := by
    intro c
    have h := abs_le.mp (hdrift c)
    nlinarith [h.1]
  have hhigh : ∀ c, S c t ≤ (1 + δ) * (w c * B t) := by
    intro c
    have h := abs_le.mp (hdrift c)
    nlinarith [h.2]
  have hlowsum : (1 - δ) * ((∑ c, κ c * w c) * B t) = ∑ c, κ c * ((1 - δ) * (w c * B t)) := by
    rw [Finset.sum_mul, Finset.mul_sum]
    exact Finset.sum_congr rfl fun c _ => by ring
  have hhighsum : (1 + δ) * ((∑ c, κ c * w c) * B t) = ∑ c, κ c * ((1 + δ) * (w c * B t)) := by
    rw [Finset.sum_mul, Finset.mul_sum]
    exact Finset.sum_congr rfl fun c _ => by ring
  constructor
  · rw [hlowsum]
    exact Finset.sum_le_sum fun c _ => by
      exact mul_le_mul_of_nonneg_left (hlow c) (hκ c)
  · rw [hhighsum]
    exact Finset.sum_le_sum fun c _ => by
      exact mul_le_mul_of_nonneg_left (hhigh c) (hκ c)

/-- Multiplicative core of the robustness estimate: with `P₀ ≤ (1+δ)·K·B₀` and
`P₁ ≥ (1-δ)·K·B₁` and raw excess ratio `ρ = (T₀/B₀)/(T₁/B₁)`, the mixture
residual ratio is at least `ρ·(1-δ)/(1+δ)`. -/
theorem excess_ratio_lower_bound_mul {T0 T1 P0 P1 B0 B1 K δ ρ : ℝ}
    (hδ0 : 0 ≤ δ) (hδ1 : δ < 1) (hB0 : 0 < B0) (hB1 : 0 < B1)
    (hT0 : 0 ≤ T0) (hT1 : 0 < T1)
    (hP0le : P0 ≤ (1 + δ) * (K * B0)) (hP1ge : (1 - δ) * (K * B1) ≤ P1)
    (hρ : T0 * B1 = ρ * (T1 * B0)) :
    ρ * (1 - δ) * (T1 * P0) ≤ (1 + δ) * (T0 * P1) := by
  have hpos : 0 < T1 * B0 := mul_pos hT1 hB0
  have hρ0 : 0 ≤ ρ := by
    by_contra hc
    push_neg at hc
    nlinarith [mul_nonneg hT0 hB1.le]
  have h1δ : (0:ℝ) ≤ 1 - δ := by linarith
  have hA : 0 ≤ ρ * (1 - δ) * T1 := mul_nonneg (mul_nonneg hρ0 h1δ) hT1.le
  have step1 : ρ * (1 - δ) * (T1 * P0) ≤ ρ * (1 - δ) * (T1 * ((1 + δ) * (K * B0))) := by
    have h := mul_le_mul_of_nonneg_left hP0le hA
    linarith [h]
  have key : ρ * (1 - δ) * (T1 * ((1 + δ) * (K * B0))) = (1 + δ) * (T0 * ((1 - δ) * (K * B1))) := by
    have hsym : ρ * (T1 * B0) = T0 * B1 := hρ.symm
    calc ρ * (1 - δ) * (T1 * ((1 + δ) * (K * B0)))
        = (1 - δ) * (1 + δ) * K * (ρ * (T1 * B0)) := by ring
      _ = (1 - δ) * (1 + δ) * K * (T0 * B1) := by rw [hsym]
      _ = (1 + δ) * (T0 * ((1 - δ) * (K * B1))) := by ring
  have step3 : (1 + δ) * (T0 * ((1 - δ) * (K * B1))) ≤ (1 + δ) * (T0 * P1) :=
    mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hP1ge hT0) (by linarith)
  linarith [step1, key, step3]

/-- Division form of the robustness estimate. -/
theorem excess_ratio_lower_bound_div {T0 T1 P0 P1 B0 B1 K δ ρ : ℝ}
    (hδ0 : 0 ≤ δ) (hδ1 : δ < 1) (hB0 : 0 < B0) (hB1 : 0 < B1)
    (hT0 : 0 ≤ T0) (hT1 : 0 < T1) (hP0 : 0 < P0) (hP1 : 0 < P1)
    (hP0le : P0 ≤ (1 + δ) * (K * B0)) (hP1ge : (1 - δ) * (K * B1) ≤ P1)
    (hρ : T0 * B1 = ρ * (T1 * B0)) :
    ρ * (1 - δ) / (1 + δ) ≤ (T0 / P0) / (T1 / P1) := by
  have hmul := excess_ratio_lower_bound_mul (K := K) hδ0 hδ1 hB0 hB1 hT0 hT1 hP0le hP1ge hρ
  have hδpos : 0 < 1 + δ := by linarith
  have hkey : (T0 / P0) / (T1 / P1) = (T0 * P1) / (T1 * P0) := by
    field_simp
  rw [hkey]
  refine (div_le_div_iff₀ hδpos (mul_pos hT1 hP0)).mpr ?_
  nlinarith

/-! ## The registered verdict, with the measured numbers -/

/-- **H0: the excess survives the divisibility mixture.**  Measured drift
`δ = 0.269 %`, raw mid-window excess `ρ - 1 = 0.1774`.  Even allowing the
mixture the full benefit of the measured composition drift, the residual excess
is still at least `0.1710`. -/
theorem H0_excess_survives_measured {T0 T1 P0 P1 B0 B1 K : ℝ}
    (hB0 : 0 < B0) (hB1 : 0 < B1) (hT0 : 0 ≤ T0) (hT1 : 0 < T1)
    (hP0 : 0 < P0) (hP1 : 0 < P1)
    (hP0le : P0 ≤ (1 + 269/100000) * (K * B0))
    (hP1ge : (1 - 269/100000) * (K * B1) ≤ P1)
    (hρ : T0 * B1 = (11774/10000) * (T1 * B0)) :
    (1710 : ℝ)/10000 ≤ (T0 / P0) / (T1 / P1) - 1 := by
  have h := excess_ratio_lower_bound_div (δ := 269/100000) (ρ := 11774/10000) (K := K)
    (by norm_num) (by norm_num) hB0 hB1 hT0 hT1 hP0 hP1 hP0le hP1ge hρ
  have hnum : (1710 : ℝ)/10000 + 1 ≤ (11774/10000) * (1 - 269/100000) / (1 + 269/100000) := by
    norm_num
  linarith

/-- The surviving excess clears the registered bar `2 · SE = 2 · 0.0432` by a
factor of almost two — and also clears twice the null-calibrated standard error
`2 · 0.0411` used by the disclosed CTRL-B caveat. -/
theorem H0_excess_beats_bar {T0 T1 P0 P1 B0 B1 K : ℝ}
    (hB0 : 0 < B0) (hB1 : 0 < B1) (hT0 : 0 ≤ T0) (hT1 : 0 < T1)
    (hP0 : 0 < P0) (hP1 : 0 < P1)
    (hP0le : P0 ≤ (1 + 269/100000) * (K * B0))
    (hP1ge : (1 - 269/100000) * (K * B1) ≤ P1)
    (hρ : T0 * B1 = (11774/10000) * (T1 * B0)) :
    2 * (432/10000 : ℝ) < (T0 / P0) / (T1 / P1) - 1 ∧
      2 * (411/10000 : ℝ) < (T0 / P0) / (T1 / P1) - 1 := by
  have h := H0_excess_survives_measured (K := K) hB0 hB1 hT0 hT1 hP0 hP1 hP0le hP1ge hρ
  constructor <;> linarith

/-- **Drift budget (inverse form).**  A mixture can only absorb the excess
entirely if its composition drift is at least `(ρ - 1)/(ρ + 1)`, where `ρ` is the
raw excess ratio.  This is a scale-free necessary condition: it does not mention
the data geometry, so it transfers across bit lengths unchanged. -/
theorem absorption_requires_drift {T0 T1 P0 P1 B0 B1 K δ ρ : ℝ}
    (hδ0 : 0 ≤ δ) (hδ1 : δ < 1) (hB0 : 0 < B0) (hB1 : 0 < B1)
    (hT0 : 0 ≤ T0) (hT1 : 0 < T1) (hP0 : 0 < P0) (hP1 : 0 < P1)
    (hP0le : P0 ≤ (1 + δ) * (K * B0)) (hP1ge : (1 - δ) * (K * B1) ≤ P1)
    (hρ : T0 * B1 = ρ * (T1 * B0))
    (habs : (T0 / P0) / (T1 / P1) ≤ 1) :
    (ρ - 1) / (ρ + 1) ≤ δ := by
  have hbound := excess_ratio_lower_bound_div (K := K) hδ0 hδ1 hB0 hB1 hT0 hT1 hP0 hP1
    hP0le hP1ge hρ
  have hρ0 : 0 ≤ ρ := by
    by_contra hc
    push_neg at hc
    nlinarith [mul_nonneg hT0 hB1.le, mul_pos hT1 hB0]
  have hδpos : 0 < 1 + δ := by linarith
  have hle : ρ * (1 - δ) / (1 + δ) ≤ 1 := le_trans hbound habs
  have hmul : ρ * (1 - δ) ≤ 1 + δ := by
    rw [div_le_one hδpos] at hle
    linarith
  rw [div_le_iff₀ (by linarith : (0:ℝ) < ρ + 1)]
  nlinarith

/-- With the measured raw excess `ρ - 1 = 0.1774`, absorbing it needs a
composition drift of at least `8.1 %` — more than `30` times the measured
`0.269 %`. -/
theorem drift_budget_measured {T0 T1 P0 P1 B0 B1 K δ : ℝ}
    (hδ0 : 0 ≤ δ) (hδ1 : δ < 1) (hB0 : 0 < B0) (hB1 : 0 < B1)
    (hT0 : 0 ≤ T0) (hT1 : 0 < T1) (hP0 : 0 < P0) (hP1 : 0 < P1)
    (hP0le : P0 ≤ (1 + δ) * (K * B0)) (hP1ge : (1 - δ) * (K * B1) ≤ P1)
    (hρ : T0 * B1 = (11774/10000) * (T1 * B0))
    (habs : (T0 / P0) / (T1 / P1) ≤ 1) :
    (81 : ℝ)/1000 ≤ δ ∧ 30 * (269/100000 : ℝ) < δ := by
  have h := absorption_requires_drift (K := K) (ρ := 11774/10000) hδ0 hδ1 hB0 hB1 hT0 hT1
    hP0 hP1 hP0le hP1ge hρ habs
  norm_num at h
  constructor <;> linarith

/-! ## Capstone: the actual divisibility grid of `j² - N` -/

/-- The cell-resolved reference sums of the experiment: the population of cell
`c` in the window at position `t`, weighted by the common (Dickman) shape `B`. -/
noncomputable def cellRefSum (N : ℤ) (B : ℝ → ℝ) (c : Bool × Bool × Bool × Bool) (t : ℝ) : ℝ :=
  (windowCount N ⌊t⌋ c : ℝ) * B t

/-- Part I says exactly this: the divisibility grid has flat composition. -/
theorem cellRefSum_flatComposition (N : ℤ) (B : ℝ → ℝ) :
    FlatComposition (cellRefSum N B) (fun c => (windowCount N 0 c : ℝ)) B := by
  intro c t
  simp only [cellRefSum, windowCount_const N ⌊t⌋ c]

/-- **Capstone (paper 242).**  For the real `16`-cell divisibility grid of
`v = j² - N`, no choice of per-cell rates `κ` removes any part of the
mid-window excess: the residual excess over the fitted mixture equals the
residual excess over the plain shape `B`, so removal is exactly `0 %`.
Divisibility is a rate dial, not a position dial. -/
theorem divisibility_mixture_excess_survives (N : ℤ) (B T : ℝ → ℝ)
    (κ : Bool × Bool × Bool × Bool → ℝ) {t₀ t₁ : ℝ}
    (hK : (∑ c, κ c * (windowCount N 0 c : ℝ)) ≠ 0) (hT : T t₁ ≠ 0) (hB : B t₁ ≠ 0) :
    relExcess (resid T (mixPred κ (cellRefSum N B))) t₀ t₁ = relExcess (resid T B) t₀ t₁ :=
  relExcess_invariant (cellRefSum_flatComposition N B) κ hK hT hB

/-- Contrapositive reading of the capstone: a nonzero mid-window excess over the
plain shape forces a nonzero excess over *every* divisibility mixture. -/
theorem divisibility_mixture_cannot_flatten (N : ℤ) (B T : ℝ → ℝ)
    (κ : Bool × Bool × Bool × Bool → ℝ) {t₀ t₁ : ℝ}
    (hK : (∑ c, κ c * (windowCount N 0 c : ℝ)) ≠ 0) (hT : T t₁ ≠ 0) (hB : B t₁ ≠ 0)
    (hexc : relExcess (resid T B) t₀ t₁ ≠ 0) :
    relExcess (resid T (mixPred κ (cellRefSum N B))) t₀ t₁ ≠ 0 := by
  rw [divisibility_mixture_excess_survives N B T κ hK hT hB]
  exact hexc

end RateDial