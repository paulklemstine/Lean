import Mathlib
import Physics.TDialU108Capacity

/-!
# Rung budget for plateau identification (U108 ladder)

## Research context

`Catalog.Physics.TDialU108.plateau_set_exact` shows that a single measured rung
(`s₀`, `s₁ = s₀ − d₀`) together with a deceleration bound `r < 1` pins the plateau of an
admissible fade to *exactly* the interval `[s₀ − d₀/(1−r), s₀ − d₀]`, of length `d₀·r/(1−r)`.

This file generalises that statement to a measured **prefix** of arbitrarily many rungs and
turns the resulting interval length into an explicit experimental stopping rule.

Main results.

* `plateauSet_prefix_eq_Icc` — after measuring the rungs `p 0, …, p (m+1)` the admissible
  plateau set is *exactly* `[p (m+1) − r·dₘ/(1−r), p (m+1)]`, where `dₘ = p m − p (m+1)` is
  the last measured step.  Only the last step matters, and both endpoints are attained.
* `plateauLength_geoFade` — on the extremal (exactly geometric) ladder the interval length is
  `d₀·r^{m+1}/(1−r)`, and `plateauLength_geoFade_contracts` shows each extra rung contracts
  the interval by the factor *exactly* `r`.  The conjecture of the mission is confirmed on
  the worst-case ladder.
* `plateau_contraction_le` and `contraction_not_exact_in_general` — in general the contraction
  is at least as fast as `r`, and can be strictly faster: one extra rung can collapse the
  interval to a point.  The exact factor `r` is a worst-case law, not a universal one.
* `rung_budget_criterion` — closed-form stopping rule: `m` further rungs identify the plateau
  to within `ε` iff `⌈log(ε(1−r)/d₀)/log r⌉ − 1 ≤ m`.
* `u108_rung_budget_zero`, `u108_no_further_rungs_needed`, `u108_three_rungs_not_needed` —
  at the U108 reading (`d₀ = 0.0259`, `r = 1/2`, CI half-width `ε = 0.0445`) the budget
  evaluates to `0`.  The one-rung interval already has length `0.0259 < 0.0445`, so the
  mission's estimate of "three further rungs" is refuted: at the CI scale the plateau is
  already identified.  `u108_rung_budget_for_milli` prices the genuinely informative target
  `ε = 0.001` at exactly five further rungs.
-/

namespace Catalog.Combinatorics.PlateauRungBudget

open Real Set Filter
open Catalog.Physics.TDialU108 (geoFade)

/-! ## Section 1. Admissible fades and the plateau set of a measured prefix -/

/-- A fade is *admissible* for deceleration ratio `r` if it is antitone and its decrements
contract by at least the factor `r` at every step. -/
def AdmissibleFade (r : ℝ) (s : ℕ → ℝ) : Prop :=
  (∀ n, s (n + 1) ≤ s n) ∧ ∀ n, s (n + 1) - s (n + 2) ≤ r * (s n - s (n + 1))

/-- The set of plateaus (limits) consistent with the measured prefix `p 0, …, p M` and a
deceleration ratio `r`. -/
def plateauSet (r : ℝ) (p : ℕ → ℝ) (M : ℕ) : Set ℝ :=
  {L | ∃ s : ℕ → ℝ, AdmissibleFade r s ∧ (∀ k ≤ M, s k = p k) ∧ Tendsto s atTop (nhds L)}

/-- The width of the admissible-plateau interval after a prefix ending at index `m+1`. -/
noncomputable def plateauLength (r : ℝ) (p : ℕ → ℝ) (m : ℕ) : ℝ :=
  r * (p m - p (m + 1)) / (1 - r)

/-- The witness fade: follow the measured prefix up to index `M`, then decay geometrically at
the tail ratio `q` towards the target plateau `L`. -/
noncomputable def spliceFade (q L : ℝ) (p : ℕ → ℝ) (M : ℕ) : ℕ → ℝ :=
  fun n => if n ≤ M then p n else L + (p M - L) * q ^ (n - M)

lemma spliceFade_of_le {q L : ℝ} {p : ℕ → ℝ} {M n : ℕ} (h : M ≤ n) :
    spliceFade q L p M n = L + (p M - L) * q ^ (n - M) := by
  rcases eq_or_lt_of_le h with rfl | h
  · simp [spliceFade]
  · have hn : ¬ n ≤ M := by omega
    simp [spliceFade, hn]

lemma spliceFade_prefix {q L : ℝ} {p : ℕ → ℝ} {M k : ℕ} (h : k ≤ M) :
    spliceFade q L p M k = p k := by
  simp [spliceFade, h]

/-- The splice is an admissible fade whenever the prefix is admissible and the residual drop
`p (m+1) − L` is nonnegative and small enough that the first tail step respects the
deceleration bound. -/
lemma spliceFade_admissible {r q L : ℝ} {p : ℕ → ℝ} {m : ℕ} (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hqr : q ≤ r)
    (hpmono : ∀ k ≤ m, p (k + 1) ≤ p k)
    (hpgeo : ∀ k, k + 2 ≤ m + 1 → p (k + 1) - p (k + 2) ≤ r * (p k - p (k + 1)))
    (hD0 : 0 ≤ p (m + 1) - L)
    (hD1 : (p (m + 1) - L) * (1 - q) ≤ r * (p m - p (m + 1))) :
    AdmissibleFade r (spliceFade q L p (m + 1)) := by
  set M := m + 1 with hM
  set D : ℝ := p M - L with hD
  set s := spliceFade q L p M with hs
  have htail : ∀ n, M ≤ n → s n = L + D * q ^ (n - M) := fun n hn => spliceFade_of_le hn
  have hpre : ∀ k, k ≤ M → s k = p k := fun k hk => spliceFade_prefix hk
  constructor
  · intro n
    rcases le_or_gt (n + 1) M with h | h
    · rw [hpre _ h, hpre _ (by omega : n ≤ M)]
      exact hpmono n (by omega)
    · have hn : M ≤ n := by omega
      rw [htail _ (by omega), htail _ hn]
      have hk : n + 1 - M = (n - M) + 1 := by omega
      rw [hk, pow_succ]
      nlinarith [pow_nonneg hq0 (n - M), mul_nonneg hD0 (pow_nonneg hq0 (n - M))]
  · intro n
    rcases lt_trichotomy (n + 1) M with h | h | h
    · rw [hpre _ (by omega : n + 1 ≤ M), hpre _ (by omega : n + 2 ≤ M),
        hpre _ (by omega : n ≤ M)]
      exact hpgeo n (by omega)
    · have hnm : n = m := by omega
      subst hnm
      rw [hpre _ (le_refl M), hpre _ (by omega : n ≤ M), htail _ (by omega)]
      have e2 : n + 2 - M = 1 := by omega
      rw [e2, pow_one]
      have hPM : p M = L + D := by rw [hD]; ring
      rw [hPM]
      nlinarith
    · have hn : M ≤ n := by omega
      rw [htail _ (by omega), htail _ (by omega), htail _ hn]
      have e1 : n + 1 - M = (n - M) + 1 := by omega
      have e2 : n + 2 - M = (n - M) + 2 := by omega
      have hp1 : q ^ (n - M + 1) = q ^ (n - M) * q := pow_succ q _
      have hp2 : q ^ (n - M + 2) = q ^ (n - M) * q * q := by rw [pow_succ, pow_succ]
      rw [e1, e2, hp1, hp2]
      nlinarith [mul_nonneg (mul_nonneg (mul_nonneg (sub_nonneg.mpr hqr) hD0)
        (pow_nonneg hq0 (n - M))) (by linarith : (0:ℝ) ≤ 1 - q)]

lemma spliceFade_tendsto {q L : ℝ} {p : ℕ → ℝ} {M : ℕ} (hq0 : 0 ≤ q) (hq1 : q < 1) :
    Tendsto (spliceFade q L p M) atTop (nhds L) := by
  have hpow : Tendsto (fun n : ℕ => q ^ (n - M)) atTop (nhds 0) :=
    (tendsto_pow_atTop_nhds_zero_of_lt_one hq0 hq1).comp (tendsto_sub_atTop_nat M)
  have h := (hpow.const_mul (p M - L)).const_add L
  simp only [mul_zero, add_zero] at h
  refine h.congr' ?_
  filter_upwards [eventually_ge_atTop M] with n hn
  exact (spliceFade_of_le hn).symm

/-! ## Section 2. Exact plateau set after a measured prefix -/

/-- **Exact identifiability from an `m`-rung prefix.**  Fix a deceleration ratio `r ∈ [0,1)`
and a measured prefix `p 0, …, p (m+1)` that is itself admissible.  Then the set of plateaus
of admissible fades matching that prefix is *exactly* the closed interval
`[p (m+1) − r·dₘ/(1−r), p (m+1)]`, where `dₘ = p m − p (m+1)` is the last measured step.

This generalises `Catalog.Physics.TDialU108.plateau_set_exact` (the case `m = 0`) from one
measured rung to a prefix of any length: only the *last* measured step matters, and both
endpoints are attained. -/
theorem plateauSet_prefix_eq_Icc {r : ℝ} {p : ℕ → ℝ} {m : ℕ} (hr0 : 0 ≤ r) (hr1 : r < 1)
    (hpmono : ∀ k ≤ m, p (k + 1) ≤ p k)
    (hpgeo : ∀ k, k + 2 ≤ m + 1 → p (k + 1) - p (k + 2) ≤ r * (p k - p (k + 1))) :
    plateauSet r p (m + 1)
      = Icc (p (m + 1) - r * (p m - p (m + 1)) / (1 - r)) (p (m + 1)) := by
  have h1r : 0 < 1 - r := by linarith
  have hdm : 0 ≤ p m - p (m + 1) := by have := hpmono m (le_refl m); linarith
  ext L
  simp only [plateauSet, mem_setOf_eq, mem_Icc]
  constructor
  · rintro ⟨s, ⟨hmono, hgeo⟩, hpre, hlim⟩
    have hanti : Antitone s := antitone_nat_of_succ_le hmono
    have hsm : s (m + 1) = p (m + 1) := hpre _ (le_refl _)
    have hsm0 : s m = p m := hpre _ (by omega)
    have hup : L ≤ p (m + 1) := by
      rw [← hsm]
      refine le_of_tendsto hlim ?_
      filter_upwards [eventually_ge_atTop (m + 1)] with n hn
      exact hanti hn
    refine ⟨?_, hup⟩
    obtain ⟨L', hL', hb⟩ :=
      Catalog.Physics.TDialU108.plateau_of_geometric_deceleration hr1 hmono hgeo
    have hLL : L = L' := tendsto_nhds_unique hlim hL'
    have hbound := (hb (m + 1)).2
    have e : m + 1 + 1 = m + 2 := rfl
    rw [e] at hbound
    -- the next (unmeasured) step is at most `r · dₘ`
    have hstep : s (m + 1) - s (m + 2) ≤ r * (p m - p (m + 1)) := by
      have h := hgeo m
      rw [hsm, hsm0, e] at h
      linarith [hsm]
    have hmul : (s (m + 1) - L') * (1 - r) ≤ s (m + 1) - s (m + 2) :=
      (le_div_iff₀ h1r).mp hbound
    have hfin : (p (m + 1) - L) * (1 - r) ≤ r * (p m - p (m + 1)) := by
      have h := le_trans hmul hstep
      rwa [hsm, ← hLL] at h
    have hfin' : p (m + 1) - L ≤ r * (p m - p (m + 1)) / (1 - r) :=
      (le_div_iff₀ h1r).mpr hfin
    linarith
  · rintro ⟨hlo, hhi⟩
    have hD0 : 0 ≤ p (m + 1) - L := by linarith
    have hD1 : (p (m + 1) - L) * (1 - r) ≤ r * (p m - p (m + 1)) := by
      have h : p (m + 1) - L ≤ r * (p m - p (m + 1)) / (1 - r) := by linarith
      calc (p (m + 1) - L) * (1 - r)
          ≤ (r * (p m - p (m + 1)) / (1 - r)) * (1 - r) :=
            mul_le_mul_of_nonneg_right h h1r.le
        _ = r * (p m - p (m + 1)) := by field_simp
    exact ⟨spliceFade r L p (m + 1),
      spliceFade_admissible hr0 hr1 (le_refl r) hpmono hpgeo hD0 hD1,
      fun k hk => spliceFade_prefix hk, spliceFade_tendsto hr0 hr1⟩

/-- The admissible plateau set after an `m`-rung prefix is a nonempty interval of length
exactly `plateauLength r p m = r·dₘ/(1−r)`. -/
theorem plateauLength_prefix {r : ℝ} {p : ℕ → ℝ} {m : ℕ} (hr0 : 0 ≤ r) (hr1 : r < 1)
    (hpmono : ∀ k ≤ m, p (k + 1) ≤ p k)
    (hpgeo : ∀ k, k + 2 ≤ m + 1 → p (k + 1) - p (k + 2) ≤ r * (p k - p (k + 1))) :
    ∃ a b : ℝ, plateauSet r p (m + 1) = Icc a b ∧ b - a = plateauLength r p m ∧ a ≤ b := by
  have h1r : 0 < 1 - r := by linarith
  have hdm : 0 ≤ p m - p (m + 1) := by have := hpmono m (le_refl m); linarith
  refine ⟨p (m + 1) - r * (p m - p (m + 1)) / (1 - r), p (m + 1),
    plateauSet_prefix_eq_Icc hr0 hr1 hpmono hpgeo, by simp [plateauLength], ?_⟩
  have : 0 ≤ r * (p m - p (m + 1)) / (1 - r) :=
    div_nonneg (mul_nonneg hr0 hdm) h1r.le
  linarith

/-! ## Section 3. Contraction rate: exact on the extremal ladder, faster in general -/

/-- On the extremal ladder the length after `m` further rungs is `d₀·r^{m+1}/(1−r)`. -/
theorem plateauLength_geoFade (s0 d0 r : ℝ) (hr1 : r < 1) (m : ℕ) :
    plateauLength r (geoFade s0 d0 r) m = d0 * r ^ (m + 1) / (1 - r) := by
  have h1r : (1 : ℝ) - r ≠ 0 := by linarith
  simp only [plateauLength, geoFade, pow_succ]
  field_simp
  ring

/-- **The conjectured contraction factor is exact on the extremal ladder.**  Each further
measured rung of an exactly geometric fade multiplies the admissible plateau interval by
precisely `r`. -/
theorem plateauLength_geoFade_contracts (s0 d0 r : ℝ) (hr1 : r < 1) (m : ℕ) :
    plateauLength r (geoFade s0 d0 r) (m + 1) = r * plateauLength r (geoFade s0 d0 r) m := by
  rw [plateauLength_geoFade s0 d0 r hr1, plateauLength_geoFade s0 d0 r hr1]
  have h1r : (1 : ℝ) - r ≠ 0 := by linarith
  field_simp
  ring

/-- **In general the contraction is at least as fast as `r`.**  For any admissible prefix the
interval length after one more measured rung is at most `r` times the previous one. -/
theorem plateau_contraction_le {r : ℝ} {p : ℕ → ℝ} {m : ℕ} (hr0 : 0 ≤ r) (hr1 : r < 1)
    (hgeo : p (m + 1) - p (m + 2) ≤ r * (p m - p (m + 1))) :
    plateauLength r p (m + 1) ≤ r * plateauLength r p m := by
  have h1r : 0 < 1 - r := by linarith
  have hmul : r * (p (m + 1) - p (m + 2)) ≤ r * (r * (p m - p (m + 1))) :=
    mul_le_mul_of_nonneg_left hgeo hr0
  have hEq : r * (r * (p m - p (m + 1)) / (1 - r)) * (1 - r) = r * (r * (p m - p (m + 1))) := by
    field_simp
  simp only [plateauLength]
  rw [div_le_iff₀ h1r, hEq]
  exact hmul

/-- **The exact factor `r` is a worst-case law, not a universal one.**  There is an admissible
prefix on which one extra measured rung collapses the admissible plateau interval to a single
point, a contraction strictly faster than the factor `r`. -/
theorem contraction_not_exact_in_general {r d0 : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (hd : 0 < d0) :
    ∃ p : ℕ → ℝ, (∀ k ≤ 1, p (k + 1) ≤ p k) ∧
      (∀ k, k + 2 ≤ 2 → p (k + 1) - p (k + 2) ≤ r * (p k - p (k + 1))) ∧
      plateauLength r p 1 = 0 ∧ 0 < r * plateauLength r p 0 := by
  refine ⟨fun k => if k = 0 then d0 else 0, ?_, ?_, ?_, ?_⟩
  · intro k hk
    interval_cases k
    · simpa using hd.le
    · simp
  · intro k hk
    have : k = 0 := by omega
    subst this
    norm_num
    positivity
  · simp [plateauLength]
  · have h1r : 0 < 1 - r := by linarith
    simp only [plateauLength]
    norm_num
    positivity

/-! ## Section 4. The impossible branch: no deceleration certificate, no identification -/

/-- **Without a strict deceleration certificate the ladder is useless.**  If the only
hypothesis is `r = 1` (decrements non-increasing), then for *every* measured prefix whose
last step `dₘ` is positive the admissible plateau set is the whole half-line
`(−∞, p (m+1)]`: no finite number of measured rungs constrains the plateau from below.

Together with `rung_budget_criterion` this is the dichotomy of the programme: with a ratio
bound `r < 1` the plateau is identified after a finite, explicitly costed number of rungs;
with `r = 1` no ladder of any length identifies it. -/
theorem plateauSet_ratio_one_eq_Iic {p : ℕ → ℝ} {m : ℕ}
    (hpmono : ∀ k ≤ m, p (k + 1) ≤ p k)
    (hpgeo : ∀ k, k + 2 ≤ m + 1 → p (k + 1) - p (k + 2) ≤ 1 * (p k - p (k + 1)))
    (hdm : 0 < p m - p (m + 1)) :
    plateauSet 1 p (m + 1) = Iic (p (m + 1)) := by
  ext L
  simp only [plateauSet, mem_setOf_eq, mem_Iic]
  constructor
  · rintro ⟨s, ⟨hmono, _⟩, hpre, hlim⟩
    have hanti : Antitone s := antitone_nat_of_succ_le hmono
    have hsm : s (m + 1) = p (m + 1) := hpre _ (le_refl _)
    rw [← hsm]
    refine le_of_tendsto hlim ?_
    filter_upwards [eventually_ge_atTop (m + 1)] with n hn
    exact hanti hn
  · intro hL
    rcases eq_or_lt_of_le (by linarith : (0 : ℝ) ≤ p (m + 1) - L) with hD | hD
    · exact ⟨spliceFade 0 L p (m + 1),
        spliceFade_admissible le_rfl (by norm_num) (by norm_num) hpmono hpgeo (by linarith)
          (by nlinarith),
        fun k hk => spliceFade_prefix hk, spliceFade_tendsto le_rfl (by norm_num)⟩
    · set c : ℝ := min 1 ((p m - p (m + 1)) / (p (m + 1) - L)) with hc
      have hratio : 0 < (p m - p (m + 1)) / (p (m + 1) - L) := div_pos hdm hD
      have hc0 : 0 < c := lt_min one_pos hratio
      have hc1 : c ≤ 1 := min_le_left _ _
      have hcr : c ≤ (p m - p (m + 1)) / (p (m + 1) - L) := min_le_right _ _
      have hD1 : (p (m + 1) - L) * (1 - (1 - c)) ≤ 1 * (p m - p (m + 1)) := by
        have hstep : (p (m + 1) - L) * c
            ≤ (p (m + 1) - L) * ((p m - p (m + 1)) / (p (m + 1) - L)) :=
          mul_le_mul_of_nonneg_left hcr hD.le
        have hcancel : (p (m + 1) - L) * ((p m - p (m + 1)) / (p (m + 1) - L))
            = p m - p (m + 1) := by field_simp
        rw [hcancel] at hstep
        calc (p (m + 1) - L) * (1 - (1 - c)) = (p (m + 1) - L) * c := by ring
          _ ≤ p m - p (m + 1) := hstep
          _ = 1 * (p m - p (m + 1)) := by ring
      exact ⟨spliceFade (1 - c) L p (m + 1),
        spliceFade_admissible (by linarith) (by linarith) (by linarith) hpmono hpgeo
          (by linarith) hD1,
        fun k hk => spliceFade_prefix hk, spliceFade_tendsto (by linarith) (by linarith)⟩

/-! ## Section 5. The rung budget: a closed-form stopping rule -/

/-- The number of further rungs required to identify the plateau to within `ε`, as an
integer: `⌈log(ε(1−r)/d₀)/log r⌉ − 1`. -/
noncomputable def rungBudget (d0 r eps : ℝ) : ℤ :=
  ⌈Real.log (eps * (1 - r) / d0) / Real.log r⌉ - 1

/-- **Closed-form stopping rule.**  For an extremal (exactly geometric) ladder with initial
step `d₀ > 0` and ratio `r ∈ (0,1)`, measuring `m` further rungs identifies the plateau to
within `ε > 0` **iff** `m ≥ rungBudget d₀ r ε`. -/
theorem rung_budget_criterion {d0 r eps : ℝ} (hd : 0 < d0) (hr0 : 0 < r) (hr1 : r < 1)
    (heps : 0 < eps) (m : ℕ) :
    d0 * r ^ (m + 1) / (1 - r) ≤ eps ↔ rungBudget d0 r eps ≤ (m : ℤ) := by
  have h1r : 0 < 1 - r := by linarith
  set K : ℝ := eps * (1 - r) / d0 with hK
  have hKpos : 0 < K := div_pos (mul_pos heps h1r) hd
  have hlogr : Real.log r < 0 := Real.log_neg hr0 hr1
  have hpowpos : (0 : ℝ) < r ^ (m + 1) := pow_pos hr0 _
  have step1 : d0 * r ^ (m + 1) / (1 - r) ≤ eps ↔ r ^ (m + 1) ≤ K := by
    rw [div_le_iff₀ h1r, hK, le_div_iff₀ hd]
    constructor <;> intro h <;> nlinarith
  have step2 : r ^ (m + 1) ≤ K ↔ Real.log (r ^ (m + 1)) ≤ Real.log K :=
    (Real.log_le_log_iff hpowpos hKpos).symm
  have step3 : Real.log (r ^ (m + 1)) = ((m : ℝ) + 1) * Real.log r := by
    rw [Real.log_pow]; push_cast; ring
  have step4 : ((m : ℝ) + 1) * Real.log r ≤ Real.log K
      ↔ Real.log K / Real.log r ≤ (m : ℝ) + 1 := by
    rw [div_le_iff_of_neg hlogr]
  have step5 : Real.log K / Real.log r ≤ ((m : ℤ) + 1 : ℤ)
      ↔ ⌈Real.log K / Real.log r⌉ ≤ (m : ℤ) + 1 := (Int.ceil_le).symm
  rw [step1, step2, step3, step4]
  have hcast : ((m : ℝ) + 1) = (((m : ℤ) + 1 : ℤ) : ℝ) := by push_cast; ring
  rw [hcast, step5, rungBudget, ← hK]
  omega

/-! ## Section 6. The U108 instantiation -/

/-- The CI half-width of the U108 confidence interval `[0.445, 0.534]` is `0.0445`. -/
theorem u108_ci_halfwidth :
    (Catalog.Physics.TDialU108.ciU108.2 - Catalog.Physics.TDialU108.ciU108.1) / 2
      = (445 : ℚ) / 10000 := by
  simp [Catalog.Physics.TDialU108.ciU108]
  norm_num

/-- **The U108 rung budget is zero.**  With `d₀ = 0.0259`, `r = 1/2` and the CI half-width
`ε = 0.0445`, the closed-form budget evaluates to `0`: no further rung is needed.

The key numeric fact is `0.0445·(1−1/2)/0.0259 = 445/518 ∈ (1/2, 1)`, so the ratio of
logarithms lies in `(0,1]` and its ceiling is `1`. -/
theorem u108_rung_budget_zero : rungBudget 0.0259 (1/2) 0.0445 = 0 := by
  have hKval : (0.0445 : ℝ) * (1 - 1/2) / 0.0259 = 445 / 518 := by norm_num
  have hlogr : Real.log (1/2 : ℝ) < 0 := Real.log_neg (by norm_num) (by norm_num)
  have hlogK : Real.log ((445 : ℝ) / 518) < 0 := Real.log_neg (by norm_num) (by norm_num)
  have hle : Real.log (1/2 : ℝ) ≤ Real.log ((445 : ℝ) / 518) :=
    Real.log_le_log (by norm_num) (by norm_num)
  have hpos : 0 < Real.log ((445 : ℝ) / 518) / Real.log (1/2 : ℝ) := by
    rw [lt_div_iff_of_neg hlogr]; simpa using hlogK
  have hup : Real.log ((445 : ℝ) / 518) / Real.log (1/2 : ℝ) ≤ 1 := by
    rw [div_le_iff_of_neg hlogr]; simpa using hle
  have hceil : ⌈Real.log ((445 : ℝ) / 518) / Real.log (1/2 : ℝ)⌉ = 1 := by
    rw [Int.ceil_eq_iff]
    constructor
    · push_cast; linarith
    · push_cast; linarith
  rw [rungBudget, hKval, hceil]
  norm_num

/-- The single-rung interval already fits inside the CI half-width: `0.0259 < 0.0445`. -/
theorem u108_no_further_rungs_needed :
    plateauLength (1/2 : ℝ) (geoFade 0.488 0.0259 (1/2)) 0 < 445 / 10000 := by
  rw [plateauLength_geoFade _ _ _ (by norm_num : (1:ℝ)/2 < 1)]
  norm_num

/-- **Refutation of the mission estimate.**  Three further rungs are *not* required: the
budget is met already at `m = 0`, and the closed-form budget itself is `≤ 0` at the U108
numbers. -/
theorem u108_three_rungs_not_needed :
    plateauLength (1/2 : ℝ) (geoFade 0.488 0.0259 (1/2)) 0 < 445 / 10000 ∧
      rungBudget 0.0259 (1/2) 0.0445 ≤ 0 :=
  ⟨u108_no_further_rungs_needed, le_of_eq u108_rung_budget_zero⟩

/-- **A genuinely costed plan.**  To identify the plateau to within `ε = 0.001` (an order of
magnitude below the CI half-width) exactly five further rungs are needed: four are not
enough. -/
theorem u108_rung_budget_for_milli :
    plateauLength (1/2 : ℝ) (geoFade 0.488 0.0259 (1/2)) 5 ≤ 1/1000 ∧
      1/1000 < plateauLength (1/2 : ℝ) (geoFade 0.488 0.0259 (1/2)) 4 := by
  rw [plateauLength_geoFade _ _ _ (by norm_num : (1:ℝ)/2 < 1),
    plateauLength_geoFade _ _ _ (by norm_num : (1:ℝ)/2 < 1)]
  constructor <;> norm_num

end Catalog.Combinatorics.PlateauRungBudget