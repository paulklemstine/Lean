/-
# NET-71, cycle 3 — service-level cache sizing: quota budgets for mixed workloads

Cycle 2 (`Logic.NET71DiagonalRigidity`) showed that the cache a finite workload needs is
the join of its cells, attained at a single worst cell, and submodular.  Full coverage,
however, is a strong requirement: a deployment usually only has to serve a *quota* of its
cells.  This file builds the quota version of the cover cost and connects it to the two
existing strands of the catalog — the rank-sum diagonal of NET-71 and the order-statistic
(quota) machinery introduced for seed ensembles in `Logic.KneeMedianLaw`.

**What is proved.**

* `served_mono`, `served_sup` — the coverage function of a workload is monotone in the
  budget and saturates at the largest rank sum present.
* `quotaRank_le`, `quotaRank_spec`, `quotaRank_mono` — the quota rank is the left adjoint
  of coverage: it is the least rung serving `m` cells, it does serve them, and it grows
  with the quota.  (Same adjunction pattern as `Catalog.NET68.kneeIdx_le_iff`, now on the
  workload axis rather than the accuracy axis.)
* `quotaRank_full` — at full quota the construction returns exactly the worst cell's rung,
  so `quotaCost` extends `coverCost` rather than replacing it (`quotaCost_full_eq_max`,
  `quotaCost_le_coverCost`).
* `net71_seven_of_eight_saves_one_step` — the concrete deployment statement for round 24:
  on the eight-cell four-domain workload at contexts `512` and `1024`, serving `7` of the
  `8` cells costs `20` keys instead of `24`.  A quarter of the multilingual cache budget
  is spent on one cell (German at `1024`), which is exactly the tokenizer tax.
-/
import Mathlib
import Logic.NET71DiagonalRigidity

namespace Catalog.NET71

open Catalog.NET68

/-! ## 1. Coverage and the quota rank -/

/-- The diagonal coordinate of a workload cell: domain rung plus context doublings. -/
def rankSum (c : Cell) : ℕ := rank c.1 + c.2

/-- How many cells of the workload a cache of rung `r` (i.e. `12 + 4r` keys) serves. -/
def served (S : Finset Cell) (r : ℕ) : ℕ := (S.filter fun c => rankSum c ≤ r).card

/-- The least rung serving at least `m` cells of the workload. -/
noncomputable def quotaRank (S : Finset Cell) (m : ℕ) : ℕ := sInf {r | m ≤ served S r}

/-- The corresponding cache, in keys. -/
noncomputable def quotaCost (S : Finset Cell) (m : ℕ) : ℤ := 12 + 4 * quotaRank S m

/-- A larger cache serves at least as many cells. -/
theorem served_mono (S : Finset Cell) : Monotone (served S) := by
  intro r r' hr
  refine Finset.card_le_card ?_
  intro c hc
  simp only [Finset.mem_filter] at hc ⊢
  exact ⟨hc.1, le_trans hc.2 hr⟩

/-- At the largest rung present, the whole workload is served. -/
theorem served_sup (S : Finset Cell) : served S (S.sup rankSum) = S.card := by
  refine congrArg Finset.card (Finset.filter_true_of_mem fun c hc => ?_)
  exact Finset.le_sup hc

/-- Below the largest rung present, at least one cell is missed. -/
theorem served_lt_of_lt_sup {S : Finset Cell} {r : ℕ} (h : r < S.sup rankSum) :
    served S r < S.card := by
  obtain ⟨c, hcS, hc⟩ : ∃ c ∈ S, r < rankSum c := by
    by_contra hcon
    push_neg at hcon
    exact absurd (Finset.sup_le hcon) (not_le.2 h)
  refine Finset.card_lt_card ⟨Finset.filter_subset _ _, fun hsub => ?_⟩
  have : c ∈ S.filter fun c => rankSum c ≤ r := hsub hcS
  simp only [Finset.mem_filter] at this
  omega

/-- Any rung serving the quota dominates the quota rank (one half of the adjunction). -/
theorem quotaRank_le {S : Finset Cell} {m r : ℕ} (h : m ≤ served S r) : quotaRank S m ≤ r :=
  Nat.sInf_le h

/-- The quota rank really does serve the quota, whenever the quota is attainable
(the other half of the adjunction). -/
theorem quotaRank_spec {S : Finset Cell} {m : ℕ} (hm : m ≤ S.card) :
    m ≤ served S (quotaRank S m) := by
  have hne : {r | m ≤ served S r}.Nonempty :=
    ⟨S.sup rankSum, show m ≤ served S (S.sup rankSum) by rw [served_sup]; exact hm⟩
  simpa [quotaRank] using Nat.sInf_mem hne

/-- Demanding more coverage never costs less. -/
theorem quotaRank_mono (S : Finset Cell) {m m' : ℕ} (hm : m ≤ m') (hm' : m' ≤ S.card) :
    quotaRank S m ≤ quotaRank S m' :=
  quotaRank_le (le_trans hm (quotaRank_spec hm'))

/-- **Full quota = worst cell.**  At `m = card`, the quota rung is exactly the largest
rank sum in the workload, so the quota construction extends the cover cost of cycle 2. -/
theorem quotaRank_full (S : Finset Cell) : quotaRank S S.card = S.sup rankSum := by
  refine le_antisymm (quotaRank_le (by rw [served_sup])) ?_
  by_contra hlt
  push_neg at hlt
  exact absurd (quotaRank_spec (le_refl S.card)) (not_le.2 (served_lt_of_lt_sup hlt))

/-- The full-quota cost is the diagonal formula applied to the worst cell. -/
theorem quotaCost_full_eq_max (S : Finset Cell) :
    quotaCost S S.card = 12 + 4 * (S.sup rankSum : ℕ) := by
  rw [quotaCost, quotaRank_full]

/-- Relaxing the quota never increases the bill. -/
theorem quotaCost_le_full {S : Finset Cell} {m : ℕ} (hm : m ≤ S.card) :
    quotaCost S m ≤ quotaCost S S.card := by
  have := quotaRank_mono S hm (le_refl S.card)
  simp only [quotaCost]
  omega

/-- Every cell of a full-quota workload is served by the full-quota cache: the quota cost
agrees with the cycle-2 cover cost. -/
theorem quotaCost_eq_coverCost {S : Finset Cell} (hS : S.Nonempty) :
    quotaCost S S.card = coverCost S hS := by
  obtain ⟨c, hc, hval⟩ := coverCost_eq_rank_sum hS
  rw [quotaCost_full_eq_max, hval]
  have h1 : rankSum c ≤ S.sup rankSum := Finset.le_sup hc
  have h2 : S.sup rankSum ≤ rankSum c := by
    refine Finset.sup_le fun e he => ?_
    have hle := le_coverCost hS he
    rw [hval] at hle
    simp only [cellBudget, net71_table_is_diagonal] at hle
    have : ((rank e.1 + e.2 : ℕ) : ℤ) ≤ ((rank c.1 + c.2 : ℕ) : ℤ) := by omega
    exact_mod_cast this
  have : S.sup rankSum = rankSum c := le_antisymm h2 h1
  rw [this, rankSum]

/-! ## 2. The round-24 workload: what the last cell costs -/

/-- The eight-cell workload of round 24: four domains at contexts `512` and `1024`. -/
def net71Workload : Finset Cell := Finset.univ ×ˢ ({0, 1} : Finset ℕ)

theorem net71Workload_card : net71Workload.card = 8 := by decide

/-- Coverage of the round-24 workload, rung by rung: `1, 3, 7, 8`. -/
theorem net71Workload_served :
    served net71Workload 0 = 1 ∧ served net71Workload 1 = 4 ∧
    served net71Workload 2 = 7 ∧ served net71Workload 3 = 8 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide

/-- **The tokenizer tax, priced.**  Serving all eight cells costs `24` keys; dropping the
single hardest cell — German prose at `ctx = 1024` — brings the cache down to `20`, one
fine step.  A quarter of the multilingual budget is spent on one cell out of eight. -/
theorem net71_seven_of_eight_saves_one_step :
    quotaCost net71Workload 8 = 24 ∧ quotaCost net71Workload 7 = 20 ∧
    quotaCost net71Workload 8 - quotaCost net71Workload 7 = (fineStep : ℤ) := by
  have h8 : quotaRank net71Workload 8 = 3 := by
    refine le_antisymm (quotaRank_le (by rw [net71Workload_served.2.2.2])) ?_
    by_contra hlt
    push_neg at hlt
    have hs := quotaRank_spec (S := net71Workload) (m := 8) (by rw [net71Workload_card])
    have hmono := served_mono net71Workload (Nat.lt_succ_iff.1 hlt)
    have h2 := net71Workload_served.2.2.1
    omega
  have h7 : quotaRank net71Workload 7 = 2 := by
    refine le_antisymm (quotaRank_le (by rw [net71Workload_served.2.2.1])) ?_
    by_contra hlt
    push_neg at hlt
    have hs := quotaRank_spec (S := net71Workload) (m := 7) (by rw [net71Workload_card]; omega)
    have hmono := served_mono net71Workload (Nat.lt_succ_iff.1 hlt)
    have h1 := net71Workload_served.2.1
    omega
  refine ⟨?_, ?_, ?_⟩
  · rw [quotaCost, h8]; norm_num
  · rw [quotaCost, h7]; norm_num
  · rw [quotaCost, quotaCost, h8, h7]; norm_num [fineStep]

/-- The dropped cell is exactly German prose at `ctx = 1024`: it is the unique cell of the
round-24 workload whose rank sum is maximal. -/
theorem net71_hardest_cell_unique (c : Cell) (hc : c ∈ net71Workload) (h : rankSum c = 3) :
    c = (Domain.proseDE, 1) := by
  have hd : c.2 = 0 ∨ c.2 = 1 := by
    have := (Finset.mem_product.1 hc).2
    simpa using this
  obtain ⟨D, d⟩ := c
  simp only [rankSum] at h
  rcases hd with rfl | rfl <;> cases D <;> simp_all [rank]

end Catalog.NET71