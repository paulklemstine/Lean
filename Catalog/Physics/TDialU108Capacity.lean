import Mathlib
import Physics.TDialU108BandLoss
import Physics.TDialU108Deepening

/-!
# U108, cycle 3: exact plateau identifiability and a capacity bound for weak dial families

This file closes two of the conjectures raised by the first two cycles of the round-69 #2
thread (`TDIAL-U108-CONTINUES-FADE`, exp 544).

## 1. Exact identifiability of the plateau (Section 1)

`Physics.TDialU108BandLoss.plateau_of_geometric_deceleration` localises the plateau of a
decelerating fade inside `[s₀ − d₀/(1−r), s₀]`, and
`Physics.TDialU108Deepening.plateau_window_edge_attained` shows the lower edge is realised.
`plateau_set_exact` now determines the attainable set **exactly**:

> the plateaus of the admissible fades with initial value `s₀`, initial step `d₀ > 0` and
> deceleration ratio at most `r` are precisely the points of `[s₀ − d₀/(1−r), s₀ − d₀]`.

The upper edge of the localisation theorem is therefore *not* attained (the first step already
costs `d₀`), and every interior point is.  Consequence for the programme: a single rung plus a
ratio bound can never identify the plateau — the U108 forecast `[0.4362, 0.4621]` (after
correcting the upper edge) is the best possible, and a second ratio measurement is required.

## 2. Capacity of a family of weak dials (Section 2)

The U108 band loss invites the strategy "combine several sub-floor dials to re-enter the
band".  `dial_family_capacity` bounds in advance how many dials such a family can contain:
if `k` unit dials each correlate at least `ρ` with the rate and pairwise at most `c < ρ²`,
then

`k ≤ (1 − c) / (ρ² − c)`.

This is the Gram/packing companion of the angle triangle inequality
`Physics.TDialU108Deepening.corr_angle_triangle`: dials at a fixed angle from the rate live in
a spherical cap, and near-orthogonality inside a cap is a packing constraint.  At the U108
reading (`ρ = 0.488`, and the certified `c ≤ 0.9949`) the bound is vacuous — one cannot rule
out large families — whereas at the band floor with genuinely weakly-correlated dials
(`c ≤ 0.1`) it caps the family at `4` (`u108_capacity_at_floor`).
-/

namespace Catalog.Physics.TDialU108

open Real Set Filter RealInnerProductSpace

/-! ## Section 1. The attainable plateau set is exactly a closed interval -/

/-- Every point of `[s₀ − d₀/(1−r), s₀ − d₀]` is the plateau of an admissible fade. -/
theorem plateau_attainable {s0 d0 r L : ℝ} (hd : 0 < d0) (hr1 : r < 1)
    (hL1 : s0 - d0 / (1 - r) ≤ L) (hL2 : L ≤ s0 - d0) :
    ∃ s : ℕ → ℝ, (∀ n, s (n + 1) ≤ s n) ∧
      (∀ n, s (n + 1) - s (n + 2) ≤ r * (s n - s (n + 1))) ∧
      s 0 = s0 ∧ s 1 = s0 - d0 ∧ Tendsto s atTop (nhds L) := by
  have h1r : 0 < 1 - r := by linarith
  set D : ℝ := s0 - L with hD
  have hDd : d0 ≤ D := by rw [hD]; linarith
  have hDpos : 0 < D := lt_of_lt_of_le hd hDd
  have hDup : D ≤ d0 / (1 - r) := by rw [hD]; linarith
  set q : ℝ := 1 - d0 / D with hq
  have hq0 : 0 ≤ q := by
    rw [hq, sub_nonneg, div_le_one hDpos]; exact hDd
  have hq1 : q < 1 := by
    rw [hq]
    have : 0 < d0 / D := div_pos hd hDpos
    linarith
  have hqr : q ≤ r := by
    rw [hq, sub_le_iff_le_add, ← sub_le_iff_le_add']
    rw [le_div_iff₀ hDpos]
    calc (1 - r) * D ≤ (1 - r) * (d0 / (1 - r)) := by
          exact mul_le_mul_of_nonneg_left hDup h1r.le
      _ = d0 := by field_simp
  obtain ⟨h0, h1, hmono, hstep, hlim⟩ :=
    plateau_window_edge_attained s0 d0 q hq0 hq1 hd.le
  refine ⟨geoFade s0 d0 q, hmono, fun n => ?_, h0, h1, ?_⟩
  · have hnn : 0 ≤ geoFade s0 d0 q n - geoFade s0 d0 q (n + 1) := by
      have := hmono n; linarith
    have := hstep n
    nlinarith
  · have hval : s0 - d0 / (1 - q) = L := by
      have h1q : 1 - q = d0 / D := by rw [hq]; ring
      have hcancel : d0 / (d0 / D) = D := by field_simp
      rw [h1q, hcancel, hD]; ring
    rwa [hval] at hlim

/-- Conversely, the plateau of any admissible fade lies in that interval: the first step is
already spent, so the plateau cannot exceed `s₁`. -/
theorem plateau_mem_interval {s : ℕ → ℝ} {r L : ℝ} (hr1 : r < 1)
    (hmono : ∀ n, s (n + 1) ≤ s n)
    (hgeo : ∀ n, s (n + 1) - s (n + 2) ≤ r * (s n - s (n + 1)))
    (hlim : Tendsto s atTop (nhds L)) :
    s 0 - (s 0 - s 1) / (1 - r) ≤ L ∧ L ≤ s 1 := by
  have hanti : Antitone s := antitone_nat_of_succ_le hmono
  constructor
  · obtain ⟨L', hL', hb⟩ := plateau_of_geometric_deceleration hr1 hmono hgeo
    have hLL : L = L' := tendsto_nhds_unique hlim hL'
    have := (hb 0).2
    rw [hLL]; linarith
  · refine le_of_tendsto hlim ?_
    filter_upwards [eventually_ge_atTop 1] with n hn
    exact hanti hn

/-- **Exact identifiability.**  For a fade with initial value `s₀`, initial step `d₀ > 0` and
deceleration ratio at most `r < 1`, the set of possible plateaus is *exactly* the closed
interval `[s₀ − d₀/(1−r), s₀ − d₀]`.  One rung plus a ratio bound therefore determines the
plateau only up to an interval of length `d₀·r/(1−r)`; no sharper inference is available
without a second measurement. -/
theorem plateau_set_exact {s0 d0 r : ℝ} (hd : 0 < d0) (hr1 : r < 1) (L : ℝ) :
    (∃ s : ℕ → ℝ, (∀ n, s (n + 1) ≤ s n) ∧
        (∀ n, s (n + 1) - s (n + 2) ≤ r * (s n - s (n + 1))) ∧
        s 0 = s0 ∧ s 1 = s0 - d0 ∧ Tendsto s atTop (nhds L))
      ↔ (s0 - d0 / (1 - r) ≤ L ∧ L ≤ s0 - d0) := by
  constructor
  · rintro ⟨s, hmono, hgeo, h0, h1, hlim⟩
    have h := plateau_mem_interval hr1 hmono hgeo hlim
    rw [h0, h1] at h
    have e : s0 - (s0 - (s0 - d0)) = s0 - d0 := by ring
    exact ⟨by simpa [e] using h.1, by simpa [h1] using h.2⟩
  · rintro ⟨hL1, hL2⟩
    exact plateau_attainable hd hr1 hL1 hL2

/-- The corrected U108 window: with `s₀ = 0.488`, `d₀ = 0.0259` and `r ≤ 1/2`, the plateau is
attainable exactly on `[0.4362, 0.4621]`, of length `0.0259`.  The measured 120 rung
(`0.43636`) lies in it; the measured 116 rung (`0.4847`) does **not**, which is precisely the
non-antitone rebound isolated by `ladder_not_antitone`. -/
theorem u108_exact_window (L : ℝ) :
    (∃ s : ℕ → ℝ, (∀ n, s (n + 1) ≤ s n) ∧
        (∀ n, s (n + 1) - s (n + 2) ≤ (1/2 : ℝ) * (s n - s (n + 1))) ∧
        s 0 = 0.488 ∧ s 1 = 0.488 - 0.0259 ∧ Tendsto s atTop (nhds L))
      ↔ (0.4362 ≤ L ∧ L ≤ 0.4621) := by
  have h := plateau_set_exact (s0 := (0.488:ℝ)) (d0 := 0.0259) (r := 1/2) (by norm_num)
    (by norm_num) L
  rw [h]
  constructor
  · rintro ⟨h1, h2⟩; constructor <;> nlinarith
  · rintro ⟨h1, h2⟩; constructor <;> nlinarith

/-! ## Section 2. Capacity of a family of weak dials -/

/-- **Capacity bound for a dial family.**  If `k` unit dials each correlate at least `ρ ≥ 0`
with the (unit) rate direction and pairwise at most `c < ρ²`, then `k ≤ (1−c)/(ρ²−c)`.
Gram positivity of the family is the packing constraint; the proof compares the length of the
sum of the dials with its projection on the rate. -/
theorem dial_family_capacity {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {k : ℕ} (hk : 0 < k) (u : E) (hu : ‖u‖ = 1) (v : Fin k → E) (hv : ∀ i, ‖v i‖ = 1)
    (rho c : ℝ) (hrho : 0 ≤ rho) (hcv : ∀ i, rho ≤ ⟪v i, u⟫)
    (hpair : ∀ i j, i ≠ j → ⟪v i, v j⟫ ≤ c) (hlt : c < rho ^ 2) :
    (k : ℝ) ≤ (1 - c) / (rho ^ 2 - c) := by
  set S : E := ∑ i, v i with hS
  have hexp : ‖S‖ ^ 2 = ∑ i, ∑ j, ⟪v i, v j⟫ := by
    rw [← real_inner_self_eq_norm_sq, hS, sum_inner]
    exact Finset.sum_congr rfl fun i _ => inner_sum _ _ _
  have hterm : ∀ i j : Fin k, ⟪v i, v j⟫ ≤ c + (if i = j then 1 - c else 0) := by
    intro i j
    by_cases h : i = j
    · subst h; simp [hv i]
    · simp [h, hpair i j h]
  have hrow : ∀ i : Fin k, ∑ j, ⟪v i, v j⟫ ≤ (k : ℝ) * c + (1 - c) := by
    intro i
    calc ∑ j, ⟪v i, v j⟫ ≤ ∑ j : Fin k, (c + (if i = j then 1 - c else 0)) :=
          Finset.sum_le_sum fun j _ => hterm i j
      _ = (k : ℝ) * c + (1 - c) := by
          rw [Finset.sum_add_distrib]; simp [Finset.sum_ite_eq, mul_comm]
  have hupper : ‖S‖ ^ 2 ≤ (k : ℝ) * ((k : ℝ) * c + (1 - c)) := by
    rw [hexp]
    calc ∑ i, ∑ j, ⟪v i, v j⟫ ≤ ∑ _i : Fin k, ((k : ℝ) * c + (1 - c)) :=
          Finset.sum_le_sum fun i _ => hrow i
      _ = (k : ℝ) * ((k : ℝ) * c + (1 - c)) := by simp [mul_comm]; ring
  have hlow : (k : ℝ) * rho ≤ ⟪S, u⟫ := by
    rw [hS, sum_inner]
    calc (k : ℝ) * rho = ∑ _i : Fin k, rho := by simp [mul_comm]
      _ ≤ ∑ i, ⟪v i, u⟫ := Finset.sum_le_sum fun i _ => hcv i
  have hcs : ⟪S, u⟫ ≤ ‖S‖ := by
    have h := real_inner_le_norm S u
    rwa [hu, mul_one] at h
  have hkpos : (0:ℝ) < k := by exact_mod_cast hk
  have hnorm : (k : ℝ) * rho ≤ ‖S‖ := le_trans hlow hcs
  have hsq : ((k : ℝ) * rho) ^ 2 ≤ ‖S‖ ^ 2 := by
    nlinarith [norm_nonneg S, mul_nonneg hkpos.le hrho]
  have hkey : (k : ℝ) * (rho ^ 2 - c) ≤ 1 - c := by nlinarith [hsq.trans hupper]
  rw [le_div_iff₀ (by linarith)]
  exact hkey

/-- At the validated band floor `ρ = 0.55` with genuinely weak pairwise alignment `c ≤ 0.1`,
no more than four dials can be assembled: the "ensemble your way back into the band" strategy
is capacity limited. -/
theorem u108_capacity_at_floor {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {k : ℕ} (hk : 0 < k) (u : E) (hu : ‖u‖ = 1) (v : Fin k → E) (hv : ∀ i, ‖v i‖ = 1)
    (hcv : ∀ i, (0.55 : ℝ) ≤ ⟪v i, u⟫) (hpair : ∀ i j, i ≠ j → ⟪v i, v j⟫ ≤ 0.1) :
    k ≤ 4 := by
  have h := dial_family_capacity hk u hu v hv 0.55 0.1 (by norm_num) hcv hpair (by norm_num)
  have hk5 : (k : ℝ) < 5 := lt_of_le_of_lt h (by norm_num)
  have : k < 5 := by exact_mod_cast hk5
  omega

end Catalog.Physics.TDialU108