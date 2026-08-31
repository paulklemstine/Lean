/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Prefix optimality of deferral under a relation quota

Experiment 559 (round-73 #2, `ADAPT-NULL-EQUALIZER / SKIP-FLIP-WINS`) ended with the
deployment recommendation *defer, don't sieve deeper*: a dial threshold `θ = q20` skipped
`28.3%` of the work while retaining `89.5%` of the relations.  `AdaptiveQSSkipFlip.lean`
proved the sign of that flip (throughput never falls, and strictly rises once a genuinely
worse target is deferred), and `AdaptiveQSThresholdTradeoff.lean` proved the honest
boundary (total retained yield falls with the threshold).

What was left open — and is what a deployment actually has to decide — is the *policy
space*: the sieve must collect a quota `Q` of relations, and one may in principle pick any
subset `K ⊆ s` of targets to work on.  This file closes that question:

* `exists_max_sum_card_subset` — a maximal-yield subset of each fixed cardinality exists;
* `separated_of_max_sum` — **every** such maximiser is *separated*: each retained target
  beats every deferred one.  This is an exchange argument, and it is the reason a sort is
  enough: no maximiser can be "interleaved" with the deferred set.
* `exists_separated_of_quota` — any quota-feasible schedule is dominated, at the same cost,
  by a separated one;
* `exists_separated_minimal_feasible` — the **minimum-work** quota-feasible schedule can
  always be taken separated;
* `separated_subset_keepSet`, `keepSet_sum_ge_of_separated` — a separated set is contained
  in a dial threshold set `keepSet s r θ` at `θ = min` of its own rates, and that threshold
  set is again quota-feasible;
* `quota_threshold_policy` — the capstone: whenever the quota is attainable at all, it is
  attained by a *single threshold* on the rate dial, and that threshold policy has
  throughput at least that of sieving everything.

So the deployment's policy space collapses from `2^|s|` subsets to one real number: the
skip-flip's `θ` is not just a good heuristic, it is the shape of the optimum.  The
hypotheses are exactly "rates are nonnegative" — no calibration, no independence.
-/
import Mathlib
import Probability.AdaptiveQSAllocation
import Probability.AdaptiveQSSkipFlip

namespace Probability.AdaptiveQS

open Finset

variable {ι : Type*} [DecidableEq ι]

/-! ## Separated schedules -/

/-- A retained set `T ⊆ s` is **separated** when every retained target has rate at least
that of every deferred target: `T` sits at the top of the rate order. -/
def Separated (s T : Finset ι) (r : ι → ℝ) : Prop :=
  ∀ i ∈ T, ∀ j ∈ s, j ∉ T → r j ≤ r i

omit [DecidableEq ι] in
/-- **Existence of a best schedule of a given size.**  Among the (finitely many) subsets of
`s` with exactly `k` targets there is one of maximal total rate. -/
theorem exists_max_sum_card_subset (s : Finset ι) (r : ι → ℝ) {k : ℕ} (hk : k ≤ s.card) :
    ∃ T ⊆ s, T.card = k ∧ ∀ K ⊆ s, K.card = k → ∑ i ∈ K, r i ≤ ∑ i ∈ T, r i := by
  obtain ⟨T, hT, hmax⟩ :=
    Finset.exists_max_image (s.powersetCard k) (fun T => ∑ i ∈ T, r i)
      (Finset.powersetCard_nonempty.mpr hk)
  rw [Finset.mem_powersetCard] at hT
  exact ⟨T, hT.1, hT.2, fun K hKs hKc => hmax K (Finset.mem_powersetCard.mpr ⟨hKs, hKc⟩)⟩

/-- **The exchange argument.**  A maximal-yield schedule of its own size is separated: if a
retained target were beaten by a deferred one, swapping the two would keep the cost and
raise the yield.  This is what makes "sort by the dial and truncate" optimal rather than
merely convenient. -/
theorem separated_of_max_sum {s T : Finset ι} {r : ι → ℝ} (hTs : T ⊆ s)
    (hmax : ∀ K ⊆ s, K.card = T.card → ∑ i ∈ K, r i ≤ ∑ i ∈ T, r i) :
    Separated s T r := by
  intro i hi j hj hjT
  by_contra hcon
  push_neg at hcon
  have hjnot : j ∉ T.erase i := fun h => hjT (Finset.mem_of_mem_erase h)
  have hcard : (insert j (T.erase i)).card = T.card := by
    rw [Finset.card_insert_of_notMem hjnot, Finset.card_erase_of_mem hi]
    have h1 : 1 ≤ T.card := Finset.card_pos.mpr ⟨i, hi⟩
    omega
  have hsub : insert j (T.erase i) ⊆ s := by
    intro x hx
    rcases Finset.mem_insert.mp hx with rfl | hx
    · exact hj
    · exact hTs (Finset.mem_of_mem_erase hx)
  have hsum : ∑ x ∈ insert j (T.erase i), r x = r j + ∑ x ∈ T.erase i, r x :=
    Finset.sum_insert hjnot
  have herase : ∑ x ∈ T.erase i, r x = (∑ x ∈ T, r x) - r i := Finset.sum_erase_eq_sub hi
  have hle := hmax _ hsub hcard
  rw [hsum, herase] at hle
  linarith

/-! ## Quota feasibility -/

omit [DecidableEq ι] in
/-- **Any schedule is dominated by a separated one of the same cost.**  If some set of `k`
targets collects the quota `Q`, then the best set of `k` targets does too, and it is
separated. -/
theorem exists_separated_of_quota {s K : Finset ι} {r : ι → ℝ} {Q : ℝ}
    (hKs : K ⊆ s) (hQ : Q ≤ ∑ i ∈ K, r i) :
    ∃ T ⊆ s, T.card = K.card ∧ Q ≤ ∑ i ∈ T, r i ∧ Separated s T r := by
  obtain ⟨T, hTs, hTc, hTmax⟩ :=
    exists_max_sum_card_subset s r (k := K.card) (Finset.card_le_card hKs)
  classical
  refine ⟨T, hTs, hTc, le_trans hQ (hTmax K hKs rfl), ?_⟩
  exact separated_of_max_sum hTs (by rw [hTc]; exact hTmax)

omit [DecidableEq ι] in
/-- **The minimum-work quota schedule is a sorted prefix.**  If the quota is attainable at
all, then it is attained by a set `T` that (i) is of minimal cardinality among all
quota-feasible sets and (ii) is separated — every target it works on beats every target it
defers.  The deployment therefore never has to search the subset lattice. -/
theorem exists_separated_minimal_feasible {s : Finset ι} {r : ι → ℝ} {Q : ℝ}
    (hfeas : ∃ K ⊆ s, Q ≤ ∑ i ∈ K, r i) :
    ∃ T ⊆ s, Q ≤ ∑ i ∈ T, r i ∧ Separated s T r ∧
      ∀ K ⊆ s, Q ≤ ∑ i ∈ K, r i → T.card ≤ K.card := by
  classical
  set P : ℕ → Prop := fun n => ∃ K ⊆ s, K.card = n ∧ Q ≤ ∑ i ∈ K, r i with hP
  have hex : ∃ n, P n := by
    obtain ⟨K, hKs, hKQ⟩ := hfeas
    exact ⟨K.card, K, hKs, rfl, hKQ⟩
  obtain ⟨K, hKs, hKc, hKQ⟩ : P (Nat.find hex) := Nat.find_spec hex
  obtain ⟨T, hTs, hTc, hTQ, hTsep⟩ := exists_separated_of_quota hKs hKQ
  refine ⟨T, hTs, hTQ, hTsep, ?_⟩
  intro K' hK's hK'Q
  have hmin : Nat.find hex ≤ K'.card := Nat.find_min' hex ⟨K', hK's, rfl, hK'Q⟩
  omega

/-! ## A separated schedule is a dial threshold -/

omit [DecidableEq ι] in
/-- A separated set is contained in the threshold set of the rate dial at its own minimal
rate: separated schedules *are* threshold schedules. -/
theorem separated_subset_keepSet {s T : Finset ι} {r : ι → ℝ} (hTs : T ⊆ s)
    (hT : T.Nonempty) :
    T ⊆ keepSet s r (T.inf' hT r) := by
  intro i hi
  rw [keepSet, Finset.mem_filter]
  exact ⟨hTs hi, Finset.inf'_le r hi⟩

omit [DecidableEq ι] in
/-- The threshold set of a separated schedule collects at least as many relations: passing
from a separated schedule to the dial threshold that induces it can only add targets whose
rate equals the threshold, so quota feasibility is preserved. -/
theorem keepSet_sum_ge_of_separated {s T : Finset ι} {r : ι → ℝ} (hTs : T ⊆ s)
    (hT : T.Nonempty) (hnonneg : ∀ i ∈ s, 0 ≤ r i) :
    ∑ i ∈ T, r i ≤ ∑ i ∈ keepSet s r (T.inf' hT r), r i := by
  refine Finset.sum_le_sum_of_subset_of_nonneg (separated_subset_keepSet hTs hT) ?_
  intro i hi _
  exact hnonneg i (Finset.mem_of_mem_filter i hi)

/-- **Capstone: the quota is met by a single threshold, and thresholding pays.**
Whenever the relation quota `Q` is attainable by some subset of the targets, there is a
threshold `θ` on the rate dial such that the retained set `keepSet s r θ` still meets the
quota, and its throughput (relations per unit of sieve work) is at least that of working on
every target.  The whole policy space collapses to the one number `θ`. -/
theorem quota_threshold_policy {s : Finset ι} {r : ι → ℝ} {Q : ℝ}
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) (hQ : 0 < Q) (hfeas : ∃ K ⊆ s, Q ≤ ∑ i ∈ K, r i) :
    ∃ θ : ℝ, Q ≤ ∑ i ∈ keepSet s r θ, r i ∧
      throughput s r ≤ throughput (keepSet s r θ) r := by
  obtain ⟨T, hTs, hTQ, _, _⟩ := exists_separated_minimal_feasible hfeas
  have hT : T.Nonempty := by
    rcases Finset.eq_empty_or_nonempty T with rfl | h
    · simp only [Finset.sum_empty] at hTQ
      exact absurd hTQ (not_le.mpr hQ)
    · exact h
  refine ⟨T.inf' hT r, le_trans hTQ (keepSet_sum_ge_of_separated hTs hT hnonneg), ?_⟩
  have hKne : (keepSet s r (T.inf' hT r)).Nonempty :=
    hT.mono (separated_subset_keepSet hTs hT)
  exact skip_throughput_ge (concordant_self s r) _ hKne

/-- **Strict form.**  If in addition the threshold really defers a worse target, the
throughput strictly improves — the deployment gain is not a boundary artefact. -/
theorem quota_threshold_policy_strict {s : Finset ι} {r : ι → ℝ} {θ : ℝ}
    {i₀ j₀ : ι} (hi₀ : i₀ ∈ keepSet s r θ) (hj₀ : j₀ ∈ skipSet s r θ) (hlt : r j₀ < r i₀) :
    throughput s r < throughput (keepSet s r θ) r :=
  skip_throughput_gt (concordant_self s r) θ hi₀ hj₀ hlt

/-! ## Lab notes — a machine-checked three-target instance

Rates `r = (3, 1, 0)` on `s = {0, 1, 2} ⊆ ℕ` with quota `Q = 3`.  The minimum-work feasible
schedule is the single top target `{0}`: one target instead of three, i.e. `66.7%` of the
work deferred at `100%` of the quota, and the throughput rises from `4/3` to `3`.  Every
number below is proved, not asserted. -/

/-- The lab-note rate vector `(3, 1, 0)` on the targets `0, 1, 2`. -/
noncomputable def prefixLabRate : ℕ → ℝ := fun i => if i = 0 then 3 else if i = 1 then 1 else 0

/-- **The minimum-work quota schedule for the lab instance.**  `{0}` meets the quota `3`,
uses one of the three targets, and no smaller schedule can meet it. -/
theorem labnote_quota_minimal :
    ({0} : Finset ℕ) ⊆ ({0, 1, 2} : Finset ℕ) ∧
      (3 : ℝ) ≤ ∑ i ∈ ({0} : Finset ℕ), prefixLabRate i ∧
      ({0} : Finset ℕ).card = 1 ∧
      ∀ K ⊆ ({0, 1, 2} : Finset ℕ), (3 : ℝ) ≤ ∑ i ∈ K, prefixLabRate i → 1 ≤ K.card := by
  refine ⟨by decide, by norm_num [prefixLabRate], rfl, ?_⟩
  intro K _ hKQ
  by_contra hcon
  push_neg at hcon
  interval_cases h : K.card
  · rw [Finset.card_eq_zero] at h
    subst h
    simp only [Finset.sum_empty] at hKQ
    linarith

/-- **The measured deployment gain of the lab instance.**  Working on all three targets
gives throughput `4/3`; deferring the two weak targets gives `3`. -/
theorem labnote_throughput :
    throughput ({0, 1, 2} : Finset ℕ) prefixLabRate = 4 / 3 ∧
      throughput ({0} : Finset ℕ) prefixLabRate = 3 := by
  constructor
  · rw [throughput]
    norm_num [prefixLabRate, Finset.sum_insert, Finset.mem_insert]
  · rw [throughput]
    norm_num [prefixLabRate]

end Probability.AdaptiveQS