/-
# Balanced splitting trees: logarithmic-discrepancy fair schedules for *any* number of clients

`Novelty.FairScheduleTreeSchedules` proves that the recursive Bresenham schedule of a
splitting tree keeps every client within `depth T` services of its ideal share, and applies
this to perfectly balanced trees over `2 ^ d` clients.  This file removes the power-of-two
restriction.

For an arbitrary client count `n` we build the balanced tree `bal w base n`, which splits the
`n` clients into `⌊n/2⌋` and `⌈n/2⌉` and recurses.  Its depth is at most `Nat.clog 2 n`, so
the main theorem

  `STree.bal_isFair : IsFair (sched (bal w 0 k)) w k (total w k * Nat.clog 2 k)`

says: **for every client count `k ≥ 1` and every profile of positive rates, there is an
explicit schedule whose normalised discrepancy never exceeds `⌈log₂ k⌉`** — a bound that is
completely independent of the rates themselves, in contrast with the `Θ(R)` discrepancy of
the exact-rate block schedule.

The file also records two sharp *waiting-time* bounds for the two-client Bresenham schedule:
each client is served at least once in every window of `⌈R / rate⌉ ` consecutive slots.
-/
import Novelty.FairScheduleTreeSchedules
import Mathlib.Data.Nat.Log

namespace FairSchedule

lemma le_ceilDiv_mul {R a : ℕ} (ha : 0 < a) : R ≤ (R + a - 1) / a * a := by
  have hdm : a * ((R + a - 1) / a) + (R + a - 1) % a = R + a - 1 := Nat.div_add_mod _ _
  have hmod : (R + a - 1) % a < a := Nat.mod_lt _ ha
  have h := Nat.mul_comm a ((R + a - 1) / a)
  omega

/-- **Bresenham waiting bound, fast client.**  Client `0`, of rate `a`, is served at least
once in every window of `⌈R/a⌉` consecutive slots. -/
theorem bres_window_zero {a R : ℕ} (ha : 0 < a) (haR : a ≤ R) (t : ℕ) :
    ∃ s, t ≤ s ∧ s < t + (R + a - 1) / a ∧ bres a R s = 0 := by
  have hR : 0 < R := lt_of_lt_of_le ha haR
  have hga : R ≤ (R + a - 1) / a * a := le_ceilDiv_mul ha
  have hstep : t * a / R < (t + (R + a - 1) / a) * a / R := by
    have h1 : (t + (R + a - 1) / a) * a = t * a + (R + a - 1) / a * a := by ring
    have h2 : t * a + R ≤ (t + (R + a - 1) / a) * a := by omega
    calc t * a / R < t * a / R + 1 := by omega
      _ = (t * a + R) / R := by rw [Nat.add_div_right _ hR]
      _ ≤ (t + (R + a - 1) / a) * a / R := Nat.div_le_div_right h2
  have hlt : schedCnt (bres a R) 0 t < schedCnt (bres a R) 0 (t + (R + a - 1) / a) := by
    rw [bres_cnt0 haR hR, bres_cnt0 haR hR]
    exact hstep
  exact exists_of_schedCnt_lt hlt

/-- **Bresenham waiting bound, slow client.**  Client `1`, of rate `R - a`, is served at least
once in every window of `⌈R/(R-a)⌉` consecutive slots. -/
theorem bres_window_one {a R : ℕ} (haR : a < R) (t : ℕ) :
    ∃ s, t ≤ s ∧ s < t + (R + (R - a) - 1) / (R - a) ∧ bres a R s = 1 := by
  have hR : 0 < R := by omega
  have hb : 0 < R - a := by omega
  set b := R - a with hbdef
  set g := (R + b - 1) / b with hg
  have hgb : R ≤ g * b := le_ceilDiv_mul hb
  have hg1 : 1 ≤ g := by
    rcases Nat.eq_zero_or_pos g with h | h
    · rw [h] at hgb; simp at hgb; omega
    · exact h
  have hga : (t + g) * a ≤ t * a + (g - 1) * R := by
    have hgab : g * b = g * R - g * a := by
      rw [hbdef, Nat.mul_sub]
    have hga' : g * a ≤ g * R := Nat.mul_le_mul_left g (le_of_lt haR)
    have h2 : (t + g) * a = t * a + g * a := by ring
    have h3 : (g - 1) * R = g * R - R := by
      rw [Nat.sub_mul, one_mul]
    omega
  have hstep : (t + g) * a / R ≤ t * a / R + (g - 1) := by
    calc (t + g) * a / R ≤ (t * a + (g - 1) * R) / R := Nat.div_le_div_right hga
      _ = t * a / R + (g - 1) := by rw [Nat.add_mul_div_right _ _ hR]
  have hdle : ∀ u : ℕ, u * a / R ≤ u := by
    intro u
    calc u * a / R ≤ u * R / R := Nat.div_le_div_right (Nat.mul_le_mul_left u (le_of_lt haR))
      _ = u := by rw [Nat.mul_div_cancel _ hR]
  have hlt : schedCnt (bres a R) 1 t < schedCnt (bres a R) 1 (t + g) := by
    rw [bres_cnt1 (le_of_lt haR) hR, bres_cnt1 (le_of_lt haR) hR]
    have h1 := hdle t
    have h2 := hdle (t + g)
    omega
  exact exists_of_schedCnt_lt hlt

end FairSchedule

namespace FairSchedule
namespace STree

open Finset

/-- The balanced splitting tree over the `n` clients `base, …, base + n - 1`. -/
def bal (w : ℕ → ℕ) : ℕ → ℕ → STree
  | base, 0 => leaf base (w base)
  | base, 1 => leaf base (w base)
  | base, (n + 2) =>
      node (bal w base ((n + 2) / 2)) (bal w (base + (n + 2) / 2) ((n + 2) - (n + 2) / 2))
  decreasing_by all_goals omega

lemma bal_succ_succ (w : ℕ → ℕ) (base n : ℕ) :
    bal w base (n + 2) =
      node (bal w base ((n + 2) / 2)) (bal w (base + (n + 2) / 2) ((n + 2) - (n + 2) / 2)) := by
  rw [bal]

lemma depth_bal (w : ℕ → ℕ) : ∀ n base, depth (bal w base n) ≤ Nat.clog 2 n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro base
    match n with
    | 0 => simp [bal, depth]
    | 1 => simp [bal, depth]
    | (m + 2) =>
      rw [bal_succ_succ, depth]
      have h1 := ih ((m + 2) / 2) (by omega) base
      have h2 := ih ((m + 2) - (m + 2) / 2) (by omega) (base + (m + 2) / 2)
      have harg : (m + 2 + 2 - 1) / 2 = (m + 2) - (m + 2) / 2 := by omega
      have hkey : Nat.clog 2 (m + 2) = Nat.clog 2 ((m + 2) - (m + 2) / 2) + 1 := by
        rw [Nat.clog_of_two_le (by norm_num) (by omega), harg]
      have hmono : Nat.clog 2 ((m + 2) / 2) ≤ Nat.clog 2 ((m + 2) - (m + 2) / 2) :=
        Nat.clog_mono_right 2 (by omega)
      omega

lemma labels_bal (w : ℕ → ℕ) :
    ∀ n base, 0 < n → labels (bal w base n) = Finset.Ico base (base + n) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro base hn
    match n with
    | 0 => omega
    | 1 => ext x; simp [bal, labels]
    | (m + 2) =>
      rw [bal_succ_succ, labels, ih ((m + 2) / 2) (by omega) base (by omega),
        ih ((m + 2) - (m + 2) / 2) (by omega) (base + (m + 2) / 2) (by omega),
        show base + (m + 2) / 2 + ((m + 2) - (m + 2) / 2) = base + (m + 2) by omega]
      exact Finset.Ico_union_Ico_eq_Ico (by omega) (by omega)

lemma wt_bal (w : ℕ → ℕ) :
    ∀ n base, 0 < n → wt (bal w base n) = ∑ j ∈ Finset.Ico base (base + n), w j := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro base hn
    match n with
    | 0 => omega
    | 1 => simp [bal, wt]
    | (m + 2) =>
      rw [bal_succ_succ, wt, ih ((m + 2) / 2) (by omega) base (by omega),
        ih ((m + 2) - (m + 2) / 2) (by omega) (base + (m + 2) / 2) (by omega),
        ← Finset.sum_union (Finset.Ico_disjoint_Ico_consecutive _ _ _),
        Finset.Ico_union_Ico_eq_Ico (by omega) (by omega),
        show base + (m + 2) / 2 + ((m + 2) - (m + 2) / 2) = base + (m + 2) by omega]

lemma rate_bal (w : ℕ → ℕ) :
    ∀ n base i, 0 < n →
      rate (bal w base n) i = if i ∈ Finset.Ico base (base + n) then w i else 0 := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro base i hn
    match n with
    | 0 => omega
    | 1 =>
      by_cases h : i = base
      · simp [bal, rate, h]
      · simp [bal, rate, h]
    | (m + 2) =>
      simp only [bal_succ_succ, rate]
      rw [ih ((m + 2) / 2) (by omega) base i (by omega),
        ih ((m + 2) - (m + 2) / 2) (by omega) (base + (m + 2) / 2) i (by omega)]
      simp only [Finset.mem_Ico]
      by_cases h1 : base ≤ i ∧ i < base + (m + 2) / 2
      · rw [if_pos h1, if_neg (by omega), if_pos (by omega)]
        omega
      · by_cases h2 : base + (m + 2) / 2 ≤ i ∧ i < base + (m + 2) / 2 + ((m + 2) - (m + 2) / 2)
        · rw [if_neg h1, if_pos h2, if_pos (by omega)]
          omega
        · rw [if_neg h1, if_neg h2, if_neg (by omega)]

lemma WF_bal (w : ℕ → ℕ) :
    ∀ n base, 0 < n → (∀ j ∈ Finset.Ico base (base + n), 0 < w j) → WF (bal w base n) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro base hn hpos
    match n with
    | 0 => omega
    | 1 =>
      have h1 : bal w base 1 = leaf base (w base) := by rw [bal]
      rw [h1]
      exact hpos base (by simp)
    | (m + 2) =>
      rw [bal_succ_succ]
      refine ⟨ih ((m + 2) / 2) (by omega) base (by omega) ?_,
        ih ((m + 2) - (m + 2) / 2) (by omega) (base + (m + 2) / 2) (by omega) ?_, ?_⟩
      · intro j hj
        simp only [Finset.mem_Ico] at hj
        exact hpos j (by simp only [Finset.mem_Ico]; omega)
      · intro j hj
        simp only [Finset.mem_Ico] at hj
        exact hpos j (by simp only [Finset.mem_Ico]; omega)
      · rw [labels_bal w _ _ (by omega), labels_bal w _ _ (by omega), Finset.disjoint_left]
        intro x hx hx'
        simp only [Finset.mem_Ico] at hx hx'
        omega

/-- **Logarithmic fairness for any number of clients and any positive rate profile.** -/
theorem bal_isFair {k : ℕ} {w : ℕ → ℕ} (hk : 0 < k) (hpos : ∀ j < k, 0 < w j) :
    IsFair (sched (bal w 0 k)) w k (total w k * Nat.clog 2 k) := by
  have hWF : WF (bal w 0 k) := WF_bal w k 0 hk (by
    intro j hj
    simp only [Finset.mem_Ico] at hj
    exact hpos j (by omega))
  have hwt : wt (bal w 0 k) = total w k := by
    rw [wt_bal w k 0 hk, Nat.zero_add, total, pre, Finset.range_eq_Ico]
  intro i hi t
  have h := tree_disc hWF i t
  rw [hwt, rate_bal w k 0 i hk, if_pos (by simp only [Finset.mem_Ico]; omega)] at h
  have hd : (depth (bal w 0 k) : ℤ) ≤ (Nat.clog 2 k : ℤ) := by
    exact_mod_cast depth_bal w k 0
  have hR : (0:ℤ) ≤ (total w k : ℤ) := Int.natCast_nonneg _
  push_cast
  calc |(total w k : ℤ) * schedCnt (sched (bal w 0 k)) i t - (w i : ℤ) * t|
      ≤ (total w k : ℤ) * (depth (bal w 0 k) : ℤ) := h
    _ ≤ (total w k : ℤ) * (Nat.clog 2 k : ℤ) := by
        exact mul_le_mul_of_nonneg_left hd hR

/-- Three clients with arbitrary positive rates admit an explicit schedule whose normalised
discrepancy never exceeds `2 = ⌈log₂ 3⌉`. -/
theorem three_client_log_fair {w : ℕ → ℕ} (hpos : ∀ j < 3, 0 < w j) :
    IsFair (sched (bal w 0 3)) w 3 (total w 3 * 2) := by
  have h := bal_isFair (k := 3) (w := w) (by norm_num) hpos
  have hc : Nat.clog 2 3 = 2 := by decide
  rwa [hc] at h

end STree
end FairSchedule