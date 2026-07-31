import Mathlib

/-!
# Thermodynamic upper bounds for zero-point energy harvesting

This file gives a model-independent conservation-law bound.  `stored t` is usable
energy in the apparatus and its local environment before cycle `t`; `injected t`
is externally supplied work; and `harvested t` is useful energy delivered by the
cycle.  The balance law says that there is no unaccounted source.

The central result is a finite-horizon accounting identity.  Its consequences show
that total extracted energy cannot exceed external input plus the initially stored
energy, and that net extraction cannot exceed the initial reserve.  In particular,
a ground-state device with no external input harvests no energy.
-/

namespace ZeroPointHarvesting

/-- A discrete thermodynamic harvesting process, including its energy balance law. -/
structure Process where
  stored : ℕ → ℝ
  injected : ℕ → ℝ
  harvested : ℕ → ℝ
  stored_nonneg : ∀ t, 0 ≤ stored t
  injected_nonneg : ∀ t, 0 ≤ injected t
  harvested_nonneg : ∀ t, 0 ≤ harvested t
  balance : ∀ t, stored (t + 1) + harvested t = stored t + injected t

/-- Net useful energy exported through the first `N` cycles. -/
def Process.netExport (P : Process) (N : ℕ) : ℝ :=
  ∑ t ∈ Finset.range N, (P.harvested t - P.injected t)

/-- Exact finite-horizon conservation: initial storage plus all input equals final
storage plus all harvested output. -/
theorem finite_horizon_conservation (P : Process) (N : ℕ) :
    P.stored N + ∑ t ∈ Finset.range N, P.harvested t =
      P.stored 0 + ∑ t ∈ Finset.range N, P.injected t := by
  induction N with
  | zero => simp
  | succ n ih =>
    simp only [Finset.sum_range_succ]
    have balance_n := P.balance n
    linarith

/-- Absolute extraction bound: output is at most external input plus initial storage. -/
theorem harvested_le_initial_add_injected (P : Process) (N : ℕ) :
    (∑ t ∈ Finset.range N, P.harvested t) ≤
      P.stored 0 + ∑ t ∈ Finset.range N, P.injected t := by
  have h := finite_horizon_conservation P N
  linarith [P.stored_nonneg N]

/-- Net energy export can consume the initial reserve, but can never exceed it. -/
theorem netExport_le_initial (P : Process) (N : ℕ) :
    P.netExport N ≤ P.stored 0 := by
  unfold Process.netExport
  rw [Finset.sum_sub_distrib]
  have h := finite_horizon_conservation P N
  linarith [P.stored_nonneg N]

/-- A cyclic device, returning to its initial energy, has output exactly equal to
its external input over the cycle. -/
theorem cyclic_harvest_eq_injected (P : Process) (N : ℕ)
    (hcycle : P.stored N = P.stored 0) :
    (∑ t ∈ Finset.range N, P.harvested t) =
      ∑ t ∈ Finset.range N, P.injected t := by
  have h := finite_horizon_conservation P N
  linarith

/-- With no external input and no initial usable energy, no energy can be harvested
in any finite number of cycles. -/
theorem ground_state_no_harvest (P : Process)
    (hground : P.stored 0 = 0) (hinput : ∀ t, P.injected t = 0) (N : ℕ) :
    (∑ t ∈ Finset.range N, P.harvested t) = 0 := by
  have h := finite_horizon_conservation P N
  simp only [hground, Finset.sum_eq_zero (fun t _ => hinput t), zero_add] at h
  exact ((add_eq_zero_iff_of_nonneg (P.stored_nonneg N) (Finset.sum_nonneg (fun t _ => P.harvested_nonneg t))).mp h).2

/-- Pointwise form of the no-harvesting result: every cycle of an unpowered
zero-reserve device has zero output. -/
theorem ground_state_harvested_eq_zero (P : Process)
    (hground : P.stored 0 = 0) (hinput : ∀ t, P.injected t = 0) (t : ℕ) :
    P.harvested t = 0 := by
  have h := ground_state_no_harvest P hground hinput (t + 1)
  have hsum : ∑ t ∈ Finset.range (t + 1), P.harvested t = 0 := h
  have hmem : t ∈ Finset.range (t + 1) := Finset.mem_range.mpr (Nat.lt_succ_self t)
  exact Finset.sum_eq_zero_iff_of_nonneg (fun t _ => P.harvested_nonneg t) |>.mp hsum t hmem

/-- The average net power over `N > 0` cycles is bounded by the initial reserve
amortized over those cycles. -/
theorem average_net_power_le (P : Process) (N : ℕ) (hN : 0 < N) :
    P.netExport N / (N : ℝ) ≤ P.stored 0 / (N : ℝ) := by
  gcongr
  exact netExport_le_initial P N

/-- Uniform finite energy reserves force the average net output to fall below any
positive target rate on all sufficiently long horizons. -/
theorem eventual_average_net_power_lt (P : Process) (ε : ℝ) (hε : 0 < ε) :
    ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N →
      P.netExport N / (N : ℝ) < ε := by
  -- We use that P.netExport N / N ≤ P.stored 0 / N, and P.stored 0 / N → 0
  obtain ⟨N₀, hN₀⟩ : ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N → P.stored 0 / (N : ℝ) < ε := by
    rcases le_or_gt 0 (P.stored 0) with hstore_nonneg | hstore_neg
    · -- If stored 0 ≥ 0, we need N large enough that stored 0 / N < ε
      -- This happens when N > stored 0 / ε
      obtain ⟨M, hM⟩ := exists_nat_gt (P.stored 0 / ε)
      use max M 1
      intro N hN
      have hN_pos : 0 < N := by
        have : 1 ≤ N := Nat.le_trans (le_max_right _ _) hN
        exact Nat.lt_of_succ_le this
      have hN_cast_pos : (0 : ℝ) < N := Nat.cast_pos.mpr hN_pos
      have hN_gt : (N : ℝ) > P.stored 0 / ε := by
        have hM_le_N : (M : ℝ) ≤ (N : ℝ) := Nat.cast_le.mpr (le_trans (le_max_left _ _) hN)
        linarith
      rw [div_lt_iff₀ hN_cast_pos]
      calc ε * N > ε * (P.stored 0 / ε) := by nlinarith
        _ = P.stored 0 := by field_simp
    · -- If stored 0 < 0, then stored 0 / N < 0 < ε
      use 0
      intro N _
      exact lt_of_le_of_lt (div_nonpos_of_nonpos_of_nonneg (le_of_lt hstore_neg) (Nat.cast_nonneg _)) hε
  use N₀
  intro N hN
  by_cases hNpos : 0 < N
  · exact lt_of_le_of_lt (average_net_power_le P N hNpos) (hN₀ N hN)
  · have hN0 : N = 0 := le_antisymm (not_lt.mp hNpos) (Nat.zero_le _)
    subst hN0
    simp [Process.netExport]
    exact hε

end ZeroPointHarvesting