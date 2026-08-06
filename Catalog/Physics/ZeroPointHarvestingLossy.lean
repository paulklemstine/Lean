import Mathlib

/-!
# Lossy zero-point harvesting: dissipation-sharpened extraction bounds and tightness

This file continues the model-independent thermodynamic analysis of a proposed
"zero-point energy harvesting" apparatus.  The previous development
(`Physics/ZeroPointHarvesting.lean`) modelled a device by three nonnegative real
sequences — stored usable energy, injected work and harvested output — subject to
a per-cycle balance law with no unaccounted source.

Here we implement two of the natural extensions of that development:

* **Lossy devices.**  A fourth nonnegative sequence `dissipated` records energy
  irreversibly lost per cycle.  The balance law becomes
  `stored (t+1) + harvested t + dissipated t = stored t + injected t`,
  and every extraction bound is sharpened by the total dissipation.
* **Rate units.**  An explicit positive cycle duration `τ` turns cycle counts into
  physical elapsed time, so average power is energy per unit time.

In addition we settle the **tightness** question left open by the previous cycle:
the absolute bound `harvested ≤ stored 0 + injected` and the net-export bound
`netExport ≤ stored 0` are attained, and we characterise exactly when equality
holds (final storage and total dissipation both vanish).  Strict inequality holds
as soon as a single cycle dissipates energy.

The chain of results is cumulative: each theorem is proved from the previous ones,
starting with the finite-horizon conservation identity `lossy_conservation`.

The lossless theory is recovered as the special case `dissipated ≡ 0`
(see the `Lossless` section), so nothing from the previous cycle is lost.
-/

namespace ZeroPointHarvestingLossy

/-- A discrete thermodynamic harvesting process **with dissipation**.

`stored t` is the usable energy held by the apparatus and its local environment
before cycle `t`; `injected t` is externally supplied work; `harvested t` is
useful energy delivered by cycle `t`; `dissipated t` is energy irreversibly lost
during cycle `t`.  The balance law encodes that there is no unaccounted source. -/
structure LossyProcess where
  stored : ℕ → ℝ
  injected : ℕ → ℝ
  harvested : ℕ → ℝ
  dissipated : ℕ → ℝ
  stored_nonneg : ∀ t, 0 ≤ stored t
  injected_nonneg : ∀ t, 0 ≤ injected t
  harvested_nonneg : ∀ t, 0 ≤ harvested t
  dissipated_nonneg : ∀ t, 0 ≤ dissipated t
  balance : ∀ t, stored (t + 1) + harvested t + dissipated t = stored t + injected t

namespace LossyProcess

variable (P : LossyProcess)

/-- Total useful energy delivered over the first `N` cycles. -/
def totalHarvested (N : ℕ) : ℝ := ∑ t ∈ Finset.range N, P.harvested t

/-- Total externally injected work over the first `N` cycles. -/
def totalInjected (N : ℕ) : ℝ := ∑ t ∈ Finset.range N, P.injected t

/-- Total irreversibly dissipated energy over the first `N` cycles. -/
def totalDissipated (N : ℕ) : ℝ := ∑ t ∈ Finset.range N, P.dissipated t

/-- Net useful energy exported through the first `N` cycles. -/
def netExport (N : ℕ) : ℝ := P.totalHarvested N - P.totalInjected N

lemma totalHarvested_nonneg (N : ℕ) : 0 ≤ P.totalHarvested N :=
  Finset.sum_nonneg fun t _ => P.harvested_nonneg t

lemma totalInjected_nonneg (N : ℕ) : 0 ≤ P.totalInjected N :=
  Finset.sum_nonneg fun t _ => P.injected_nonneg t

lemma totalDissipated_nonneg (N : ℕ) : 0 ≤ P.totalDissipated N :=
  Finset.sum_nonneg fun t _ => P.dissipated_nonneg t

end LossyProcess

open LossyProcess

/-! ## Step 1: the conservation identity -/

/-- **Finite-horizon conservation with losses.**  Initial storage plus all injected
work equals final storage plus all harvested output plus all dissipation. -/
theorem lossy_conservation (P : LossyProcess) (N : ℕ) :
    P.stored N + P.totalHarvested N + P.totalDissipated N =
      P.stored 0 + P.totalInjected N := by
  induction N with
  | zero => simp [LossyProcess.totalHarvested, LossyProcess.totalInjected,
      LossyProcess.totalDissipated]
  | succ n ih =>
    simp only [LossyProcess.totalHarvested, LossyProcess.totalInjected,
      LossyProcess.totalDissipated, Finset.sum_range_succ] at *
    have hb := P.balance n
    linarith

/-! ## Step 2: sharpened extraction bounds -/

/-- **Dissipation-sharpened absolute extraction bound.**  The harvested output is at
most the initial reserve plus the external input, *minus* everything dissipated. -/
theorem harvested_le_initial_add_injected_sub_dissipated (P : LossyProcess) (N : ℕ) :
    P.totalHarvested N ≤ P.stored 0 + P.totalInjected N - P.totalDissipated N := by
  have h := lossy_conservation P N
  linarith [P.stored_nonneg N]

/-- The classical (unsharpened) absolute extraction bound, a corollary of the
sharpened one. -/
theorem harvested_le_initial_add_injected (P : LossyProcess) (N : ℕ) :
    P.totalHarvested N ≤ P.stored 0 + P.totalInjected N := by
  have h := harvested_le_initial_add_injected_sub_dissipated P N
  linarith [P.totalDissipated_nonneg N]

/-- **Dissipation-sharpened net-export bound.**  Net exported energy is at most the
initial reserve less the total dissipation. -/
theorem netExport_le_initial_sub_dissipated (P : LossyProcess) (N : ℕ) :
    P.netExport N ≤ P.stored 0 - P.totalDissipated N := by
  have h := harvested_le_initial_add_injected_sub_dissipated P N
  simp only [LossyProcess.netExport]
  linarith

/-- Net export never exceeds the initial reserve. -/
theorem netExport_le_initial (P : LossyProcess) (N : ℕ) :
    P.netExport N ≤ P.stored 0 := by
  have h := netExport_le_initial_sub_dissipated P N
  linarith [P.totalDissipated_nonneg N]

/-- Dissipation itself is bounded by the available energy budget. -/
theorem dissipated_le_budget (P : LossyProcess) (N : ℕ) :
    P.totalDissipated N ≤ P.stored 0 + P.totalInjected N := by
  have h := harvested_le_initial_add_injected_sub_dissipated P N
  linarith [P.totalHarvested_nonneg N]

/-- The stored energy at any horizon is bounded by the initial reserve plus the
input received so far. -/
theorem stored_le_initial_add_injected (P : LossyProcess) (N : ℕ) :
    P.stored N ≤ P.stored 0 + P.totalInjected N := by
  have h := lossy_conservation P N
  linarith [P.totalHarvested_nonneg N, P.totalDissipated_nonneg N]

/-! ## Step 3: cyclic and ground-state devices -/

/-- **Cyclic devices.**  A device returning to its initial energy delivers exactly
its external input minus the dissipated energy: no free lunch, and a strict loss
whenever the device is lossy. -/
theorem cyclic_harvest_eq_injected_sub_dissipated (P : LossyProcess) (N : ℕ)
    (hcycle : P.stored N = P.stored 0) :
    P.totalHarvested N = P.totalInjected N - P.totalDissipated N := by
  have h := lossy_conservation P N
  rw [hcycle] at h
  linarith

/-- **Kelvin–Planck form.**  A cyclic device receiving no external work delivers no
useful output and dissipates nothing. -/
theorem cyclic_unpowered_no_output (P : LossyProcess) (N : ℕ)
    (hcycle : P.stored N = P.stored 0) (hinput : ∀ t, P.injected t = 0) :
    P.totalHarvested N = 0 ∧ P.totalDissipated N = 0 := by
  have hinj : P.totalInjected N = 0 :=
    Finset.sum_eq_zero fun t _ => hinput t
  have h := cyclic_harvest_eq_injected_sub_dissipated P N hcycle
  rw [hinj] at h
  have hsum : P.totalHarvested N + P.totalDissipated N = 0 := by linarith
  exact (add_eq_zero_iff_of_nonneg (P.totalHarvested_nonneg N)
    (P.totalDissipated_nonneg N)).mp hsum

/-- **Ground state.**  An unpowered device with no initial usable energy harvests
nothing and dissipates nothing over any finite horizon. -/
theorem ground_state_no_harvest (P : LossyProcess)
    (hground : P.stored 0 = 0) (hinput : ∀ t, P.injected t = 0) (N : ℕ) :
    P.totalHarvested N = 0 ∧ P.totalDissipated N = 0 := by
  have hinj : P.totalInjected N = 0 := Finset.sum_eq_zero fun t _ => hinput t
  have h := lossy_conservation P N
  rw [hground, hinj] at h
  have hsum : P.totalHarvested N + P.totalDissipated N = 0 := by
    linarith [P.stored_nonneg N, P.totalHarvested_nonneg N, P.totalDissipated_nonneg N]
  exact (add_eq_zero_iff_of_nonneg (P.totalHarvested_nonneg N)
    (P.totalDissipated_nonneg N)).mp hsum

/-- Pointwise ground-state statement: every individual cycle of an unpowered
zero-reserve device has zero output. -/
theorem ground_state_harvested_eq_zero (P : LossyProcess)
    (hground : P.stored 0 = 0) (hinput : ∀ t, P.injected t = 0) (t : ℕ) :
    P.harvested t = 0 := by
  have h := (ground_state_no_harvest P hground hinput (t + 1)).1
  exact (Finset.sum_eq_zero_iff_of_nonneg fun s _ => P.harvested_nonneg s).mp h t
    (Finset.mem_range.mpr (Nat.lt_succ_self t))

/-! ## Step 4: equality analysis and tightness -/

/-- **Equality characterisation for the net-export bound.**  A device exports its
entire initial reserve exactly when it ends with empty storage and has dissipated
nothing. -/
theorem netExport_eq_initial_iff (P : LossyProcess) (N : ℕ) :
    P.netExport N = P.stored 0 ↔ P.stored N = 0 ∧ P.totalDissipated N = 0 := by
  have h := lossy_conservation P N
  constructor
  · intro heq
    simp only [LossyProcess.netExport] at heq
    have hsum : P.stored N + P.totalDissipated N = 0 := by linarith
    exact (add_eq_zero_iff_of_nonneg (P.stored_nonneg N) (P.totalDissipated_nonneg N)).mp hsum
  · rintro ⟨hs, hd⟩
    simp only [LossyProcess.netExport]
    rw [hs, hd] at h
    linarith

/-- **Strictness from a single lossy cycle.**  If any cycle inside the horizon
dissipates energy, the net-export bound is strict. -/
theorem netExport_lt_initial_of_dissipation (P : LossyProcess) (N : ℕ) (t : ℕ)
    (ht : t < N) (hpos : 0 < P.dissipated t) :
    P.netExport N < P.stored 0 := by
  have hlt : 0 < P.totalDissipated N :=
    Finset.sum_pos' (fun i _ => P.dissipated_nonneg i)
      ⟨t, Finset.mem_range.mpr ht, hpos⟩
  have h := netExport_le_initial_sub_dissipated P N
  linarith

/-- **Tightness construction.**  For every reserve `E ≥ 0` there is a lossless
process with initial storage `E`, no external input, that exports exactly `E`
over any nonempty horizon.  Hence the bound `netExport ≤ stored 0` is attained. -/
theorem exists_tight_process (E : ℝ) (hE : 0 ≤ E) :
    ∃ P : LossyProcess, P.stored 0 = E ∧ (∀ t, P.injected t = 0) ∧
      (∀ t, P.dissipated t = 0) ∧ ∀ N : ℕ, 0 < N → P.netExport N = E := by
  refine ⟨{ stored := fun t => if t = 0 then E else 0
            injected := fun _ => 0
            harvested := fun t => if t = 0 then E else 0
            dissipated := fun _ => 0
            stored_nonneg := by intro t; by_cases h : t = 0 <;> simp [h, hE]
            injected_nonneg := by intro t; norm_num
            harvested_nonneg := by intro t; by_cases h : t = 0 <;> simp [h, hE]
            dissipated_nonneg := by intro t; norm_num
            balance := by
              intro t
              rcases Nat.eq_zero_or_pos t with rfl | ht
              · norm_num
              · have h1 : t ≠ 0 := ht.ne'
                simp [h1] }, by simp, fun _ => rfl, fun _ => rfl, ?_⟩
  intro N hN
  simp only [LossyProcess.netExport, LossyProcess.totalHarvested, LossyProcess.totalInjected]
  have : ∑ t ∈ Finset.range N, (if t = 0 then E else 0) = E := by
    rw [Finset.sum_ite_eq' (Finset.range N) 0 (fun _ => E)]
    simp [Finset.mem_range.mpr hN]
  simp [this]

/-- The tight process of `exists_tight_process` also attains the absolute
extraction bound `harvested ≤ stored 0 + injected` with equality. -/
theorem exists_tight_harvest (E : ℝ) (hE : 0 ≤ E) :
    ∃ P : LossyProcess, ∀ N : ℕ, 0 < N →
      P.totalHarvested N = P.stored 0 + P.totalInjected N := by
  obtain ⟨P, hs, hinj, _, hnet⟩ := exists_tight_process E hE
  refine ⟨P, fun N hN => ?_⟩
  have hI : P.totalInjected N = 0 := Finset.sum_eq_zero fun t _ => hinj t
  have := hnet N hN
  simp only [LossyProcess.netExport, hI, sub_zero] at this
  rw [this, hs, hI, add_zero]

/-! ## Step 5: conversion efficiency -/

/-- The conversion efficiency over `N` cycles: useful output divided by the total
energy budget (initial reserve plus injected work). -/
noncomputable def LossyProcess.efficiency (P : LossyProcess) (N : ℕ) : ℝ :=
  P.totalHarvested N / (P.stored 0 + P.totalInjected N)

/-- **Efficiency is at most one**, and is reduced by the dissipated fraction. -/
theorem efficiency_le_one_sub_dissipated_fraction (P : LossyProcess) (N : ℕ)
    (hbud : 0 < P.stored 0 + P.totalInjected N) :
    P.efficiency N ≤ 1 - P.totalDissipated N / (P.stored 0 + P.totalInjected N) := by
  have h := harvested_le_initial_add_injected_sub_dissipated P N
  have hD : P.totalDissipated N / (P.stored 0 + P.totalInjected N) *
      (P.stored 0 + P.totalInjected N) = P.totalDissipated N :=
    div_mul_cancel₀ _ hbud.ne'
  rw [LossyProcess.efficiency, div_le_iff₀ hbud, sub_mul, one_mul, hD]
  linarith

/-- No device converts more than its entire energy budget. -/
theorem efficiency_le_one (P : LossyProcess) (N : ℕ)
    (hbud : 0 < P.stored 0 + P.totalInjected N) :
    P.efficiency N ≤ 1 := by
  have h := efficiency_le_one_sub_dissipated_fraction P N hbud
  have hd : 0 ≤ P.totalDissipated N / (P.stored 0 + P.totalInjected N) :=
    div_nonneg (P.totalDissipated_nonneg N) hbud.le
  linarith

/-- A device with a strictly lossy cycle has efficiency strictly below one. -/
theorem efficiency_lt_one_of_dissipation (P : LossyProcess) (N : ℕ)
    (hbud : 0 < P.stored 0 + P.totalInjected N) (t : ℕ) (ht : t < N)
    (hpos : 0 < P.dissipated t) :
    P.efficiency N < 1 := by
  have hlt : 0 < P.totalDissipated N :=
    Finset.sum_pos' (fun i _ => P.dissipated_nonneg i)
      ⟨t, Finset.mem_range.mpr ht, hpos⟩
  have h := efficiency_le_one_sub_dissipated_fraction P N hbud
  have hd : 0 < P.totalDissipated N / (P.stored 0 + P.totalInjected N) :=
    div_pos hlt hbud
  linarith

/-! ## Step 6: rate units — average power with a physical cycle duration -/

/-- Average net power over `N` cycles, each of physical duration `τ > 0`. -/
noncomputable def LossyProcess.avgPower (P : LossyProcess) (τ : ℝ) (N : ℕ) : ℝ :=
  P.netExport N / (N * τ)

/-- **Average power bound in physical units.**  The average net power delivered
over `N` cycles of duration `τ` is at most the initial reserve amortised over the
elapsed time `N * τ`, further reduced by the dissipated energy. -/
theorem avgPower_le (P : LossyProcess) (τ : ℝ) (hτ : 0 < τ) (N : ℕ) (hN : 0 < N) :
    P.avgPower τ N ≤ (P.stored 0 - P.totalDissipated N) / (N * τ) := by
  have hpos : (0 : ℝ) < (N : ℝ) * τ :=
    mul_pos (by exact_mod_cast hN) hτ
  unfold LossyProcess.avgPower
  gcongr
  exact netExport_le_initial_sub_dissipated P N

/-- **Vanishing average power.**  For any positive target power `ε` there is an
elapsed-time threshold beyond which the average net power of the device is below
`ε`: sustained extraction at a fixed positive rate is impossible. -/
theorem eventual_avgPower_lt (P : LossyProcess) (τ : ℝ) (hτ : 0 < τ) (ε : ℝ) (hε : 0 < ε) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N → P.avgPower τ N < ε := by
  obtain ⟨M, hM⟩ := exists_nat_gt (P.stored 0 / (ε * τ))
  refine ⟨max M 1, lt_of_lt_of_le Nat.zero_lt_one (le_max_right _ _), fun N hN => ?_⟩
  have hN1 : 0 < N := lt_of_lt_of_le Nat.zero_lt_one (le_trans (le_max_right _ _) hN)
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN1
  have hprod : (0 : ℝ) < (N : ℝ) * τ := mul_pos hNR hτ
  have hMN : (M : ℝ) ≤ (N : ℝ) := by
    exact_mod_cast le_trans (le_max_left _ _) hN
  have hkey : P.stored 0 < ε * ((N : ℝ) * τ) := by
    have h1 : P.stored 0 / (ε * τ) < (N : ℝ) := lt_of_lt_of_le hM hMN
    have hετ : 0 < ε * τ := mul_pos hε hτ
    have := (div_lt_iff₀ hετ).mp h1
    nlinarith
  have hle : P.avgPower τ N ≤ P.stored 0 / ((N : ℝ) * τ) := by
    unfold LossyProcess.avgPower
    gcongr
    exact netExport_le_initial P N
  refine lt_of_le_of_lt hle ?_
  rw [div_lt_iff₀ hprod]
  linarith

/-! ## Step 7: the lossless theory as a special case -/

section Lossless

variable (P : LossyProcess) (hloss : ∀ t, P.dissipated t = 0)

include hloss in
lemma totalDissipated_eq_zero (N : ℕ) : P.totalDissipated N = 0 :=
  Finset.sum_eq_zero fun t _ => hloss t

include hloss in
/-- For a lossless device the conservation identity takes the familiar form of the
previous development. -/
theorem lossless_conservation (N : ℕ) :
    P.stored N + P.totalHarvested N = P.stored 0 + P.totalInjected N := by
  have h := lossy_conservation P N
  rw [totalDissipated_eq_zero P hloss N] at h
  linarith

include hloss in
/-- For a lossless cyclic device output equals input exactly. -/
theorem lossless_cyclic_harvest_eq_injected (N : ℕ) (hcycle : P.stored N = P.stored 0) :
    P.totalHarvested N = P.totalInjected N := by
  have h := cyclic_harvest_eq_injected_sub_dissipated P N hcycle
  rw [totalDissipated_eq_zero P hloss N] at h
  linarith

end Lossless

end ZeroPointHarvestingLossy