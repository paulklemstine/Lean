import Shared.SpeculativeDecodingCostCurve

/-!
# The stopping depth as a canonical selector, and its monotonicity in acceptance

Cycle 5, the capstone of the NET-91 thread.  Cycles 1–4 produced three ingredients:

* throughput collapses at large depth (`exists_depth_collapse`);
* throughput is unimodal in depth, so greedy tuning is exact (`geom_greedy_depth_optimal`);
* the "deepening pays" frontier is monotone in acceptance (`depth_frontier_monotone`,
  `greedy_stop_antitone`).

Here they are combined into a single object: the **stopping depth**

`stopDepth a c = sInf {D | speedup a c (D+1) < speedup a c D}`,

the first depth at which one more drafted token stops paying.  It is well defined
(`stopSet_nonempty`), it is a *global* optimum, not merely a local one
(`stopDepth_optimal`), and it is monotone in the acceptance rate
(`stopDepth_mono_acceptance`).  That last statement is the sharpest formal version of the
NET-91 depth law: *a domain that accepts more should draft deeper, always*.

Instantiated at the measured 0.5B-draft cost, the selector returns
`stopDepth 0.477 0.118 = 2` for prose and `stopDepth 0.630 0.118 = 3` for code
(`prose_stopDepth_eq_two`, `code_stopDepth_eq_three`), a strict split
(`stopDepth_domain_split`).

-- !-- Lab Notes -- !--
Hypothesizer (cycle 5):
 (F1) [BOLD] There is a canonical depth selector, definable from the throughput curve
      alone, that is simultaneously globally optimal and monotone in acceptance.
 (F2) The selector is computable by one local test per depth — no grid search, no
      backtracking — which is what makes it deployable.
 (F3) The measured prose/code acceptances give different selector values, so the NET-91
      prescription is recovered as an equation rather than a fitted table.

Experimenter: F1–F3 formalised below, zero sorries.

Analyst: the only delicate point is well-definedness.  Unimodality alone does not give a
stopping depth — a curve that increases forever has none — so nonemptiness of the stopping
set is where the depth-collapse theorem of cycle 1 is genuinely needed; it is the formal
trace of the fact that sequential drafting on a CPU is never asymptotically free.

Critic: monotonicity is stated for `0 < a ≤ a' < 1` — at `a = 0` the profile is degenerate
(the drafter is useless and the selector returns `0`), and at `a = 1` the drafter is
perfect and the stopping set is empty, so both endpoints are genuinely excluded rather than
hidden.
-/

namespace SpecDecCPU

open Filter

/-- The set of depths at which one more drafted token fails to pay. -/
def stopSet (a c : ℝ) : Set ℕ := {D | speedup a c (D + 1) < speedup a c D}

/-- Depth collapse makes the stopping set nonempty: a throughput curve that never declined
would stay at or above its value `1` at depth `0`. -/
theorem stopSet_nonempty {a c : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (hc : 0 < c) :
    (stopSet a c).Nonempty := by
  by_contra hempty
  rw [Set.not_nonempty_iff_eq_empty] at hempty
  have hmono : ∀ D : ℕ, speedup a c D ≤ speedup a c (D + 1) := by
    intro D
    have : D ∉ stopSet a c := by rw [hempty]; exact Set.notMem_empty D
    simpa [stopSet, not_lt] using this
  have hall : ∀ d : ℕ, (1 : ℝ) ≤ speedup a c d := by
    intro d
    induction d with
    | zero => rw [speedup_zero]
    | succ n ih => exact le_trans ih (hmono n)
  obtain ⟨D, hD⟩ := exists_depth_collapse ha ha1 hc
  exact absurd (hall D) (not_le.2 (hD D le_rfl))

/-- The canonical draft depth: the first depth at which deepening stops paying. -/
noncomputable def stopDepth (a c : ℝ) : ℕ := sInf (stopSet a c)

theorem stopDepth_mem {a c : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (hc : 0 < c) :
    speedup a c (stopDepth a c + 1) < speedup a c (stopDepth a c) :=
  Nat.sInf_mem (stopSet_nonempty ha ha1 hc)

theorem le_stopDepth_improves {a c : ℝ} {k : ℕ} (hk : k < stopDepth a c) :
    speedup a c k ≤ speedup a c (k + 1) := by
  have : k ∉ stopSet a c := Nat.notMem_of_lt_sInf hk
  simpa [stopSet, not_lt] using this

/-- **The stopping depth is a global optimum.**  Every draft depth, however deep, is at
most as fast as the first non-improving one. -/
theorem stopDepth_optimal {a c : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (hc : 0 < c) :
    ∀ d : ℕ, speedup a c d ≤ speedup a c (stopDepth a c) :=
  geom_greedy_depth_optimal ha ha1.le hc.le (fun _ hk => le_stopDepth_improves hk)
    (stopDepth_mem ha ha1 hc)

/-- **The depth law.**  A domain with higher acceptance drafts at least as deep: the
canonical stopping depth is monotone in the acceptance rate. -/
theorem stopDepth_mono_acceptance {a a' c : ℝ} (ha : 0 < a) (haa : a ≤ a') (ha1 : a' < 1)
    (hc : 0 < c) : stopDepth a c ≤ stopDepth a' c := by
  have hmem : speedup a' c (stopDepth a' c + 1) < speedup a' c (stopDepth a' c) :=
    stopDepth_mem (ha.le.trans haa) ha1 hc
  exact Nat.sInf_le (greedy_stop_antitone ha haa hc.le hmem)

/-- A stopping depth is pinned by one decline and the absence of earlier ones. -/
theorem stopDepth_eq_of {a c : ℝ} {D : ℕ}
    (hD : speedup a c (D + 1) < speedup a c D)
    (hbelow : ∀ k < D, speedup a c k ≤ speedup a c (k + 1)) : stopDepth a c = D := by
  refine le_antisymm (Nat.sInf_le hD) ?_
  by_contra hlt
  push_neg at hlt
  have hmem : speedup a c (stopDepth a c + 1) < speedup a c (stopDepth a c) :=
    Nat.sInf_mem (s := stopSet a c) ⟨D, hD⟩
  exact absurd (hbelow _ hlt) (not_le.2 hmem)

/-- Prose at the small-draft cost: the canonical depth is `2`. -/
theorem prose_stopDepth_eq_two : stopDepth (477/1000) (118/1000) = 2 := by
  refine stopDepth_eq_of ?_ ?_
  · rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
    norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
  · intro k hk
    interval_cases k
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 0)
        (blockCost_pos (by norm_num) 1)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 1)
        (blockCost_pos (by norm_num) 2)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-- Code at the same cost: the canonical depth is `3`. -/
theorem code_stopDepth_eq_three : stopDepth (630/1000) (118/1000) = 3 := by
  refine stopDepth_eq_of ?_ ?_
  · rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
    norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
  · intro k hk
    interval_cases k
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 0)
        (blockCost_pos (by norm_num) 1)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 1)
        (blockCost_pos (by norm_num) 2)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 2)
        (blockCost_pos (by norm_num) 3)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-- **The NET-91 depth prescription as an equation.**  The canonical selector separates the
two domains strictly, and each value is a global optimum over all depths. -/
theorem stopDepth_domain_split :
    stopDepth (477/1000) (118/1000) < stopDepth (630/1000) (118/1000) ∧
    (∀ d : ℕ, speedup (477/1000) (118/1000) d ≤ speedup (477/1000) (118/1000) 2) ∧
    (∀ d : ℕ, speedup (630/1000) (118/1000) d ≤ speedup (630/1000) (118/1000) 3) := by
  refine ⟨?_, prose_optimal_depth_two, code_optimal_depth_three⟩
  rw [prose_stopDepth_eq_two, code_stopDepth_eq_three]
  norm_num

end SpecDecCPU