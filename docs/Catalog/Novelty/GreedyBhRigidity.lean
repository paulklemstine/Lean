import Novelty.GreedyBhSets

/-!
# Chain rigidity for the greedy `B_h` process, and a degree drop

`Novelty/GreedyDifferenceCubic.lean` showed that the greedy *Sidon* chain is **rigid**: a
value that is still admissible at stage `n` is automatically larger than everything already
chosen, so the ordering clause built into the greedy predicate costs nothing.  That rigidity
turned a step-by-step summation of window widths into a single global pigeonhole and lowered
the growth bound from quartic to cubic.

This file transports both halves of that argument to the greedy `B_h` process of
`Novelty/GreedyBhSets.lean`.  The transport is possible because the step criterion
`isBh_insert_of_notMem_bhBad` there was deliberately stated *without* an ordering hypothesis:
a candidate avoiding the weighted obstruction set `bhBad A h` may sit anywhere.

The payoff is a degree drop.  The companion file bounds the greedy `B_h` sequence by
`(n+1)·(h·((h+1)(n+1)^h)² + 1)`, of degree `2h + 1`, because it adds one window per step.
Here a single pigeonhole over `{0, …, n + h((h+1)(n+1)^h)²}` gives

  `a_h(n) ≤ n + h·((h+1)(n+1)^h)²`,

of degree `2h`.

## Main results

* `card_bhBad_le'` — the obstruction count in terms of `|A|` alone.
* `exists_valid_le_bh` — **global pigeonhole**: every `B_h` set of size `n` admits a new
  element at most `n + h((h+1)(n+1)^h)²`, with no ordering constraint.
* `greedyBh_valid_gt` — **chain rigidity at level `h`**: an admissible value for
  `greedySetBh h n` exceeds every element already chosen.
* `greedySeqBh_le_deg2h` — **degree-`2h` upper bound**, replacing the degree-`2h+1` bound.
* `greedySeqBh_sandwich_sharp` — the sharpened sandwich, degree `h` below and degree `2h`
  above.
* `greedySeqBh_two_le` — the specialisation to `h = 2`, a quartic bound for the greedy
  Sidon sequence obtained purely from the `B_h` machinery (the dedicated argument in
  `GreedyDifferenceCubic.lean` does better, which quantifies the loss in the generic route).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): rigidity of a greedy chain should be a formal consequence of
  (i) monotonicity of the defining property under subsets and (ii) minimality of the earlier
  choice, hence should hold verbatim at every level `h`, not just for Sidon sets (`h = 2`).
Experiment (Experimenter): the induction of `greedy_valid_gt` transported with no new ideas,
  using `IsBh.subset` in place of `IsSidon.mono`.  The pigeonhole then needed only the count
  `#(bhBad A h) ≤ h·((h+1)(|A|+1)^h)²`, already available, plus `#A` extra slots to dodge
  `A` itself.  Result: degree `2h` instead of `2h + 1`.
Analysis (Analyst): the degree gained is exactly the one lost by summing windows, confirming
  that per-step accumulation — not the obstruction count — was the wasteful part of the
  original bound.  The lower bound is still degree `h`, so a factor-two gap in the exponent
  remains; numerically (`A046185`, `A046186`) the truth looks like degree `2h - 1`.
Critique (Critic): the hypothesis `m ∉ greedySetBh h n` is load-bearing — for `m` already in
  the set the conclusion is false — and rigidity is a statement about the greedy chain, not
  about arbitrary `B_h` sets (`{0, 3}` is `B_2` and admits `1`).  The `h = 0` and `h = 1`
  cases are not degenerate here: the bound is still proved, it is just weak.
Synthesis (PI): greedy `B_h` avoidance is a global minimisation, and its counting bound has
  degree `2h`.
-/

namespace GreedyBh

open Finset BhDifference

/-! ## 1. The obstruction count in terms of the cardinality -/

/-- The weighted obstruction set has at most `h·((h+1)(|A|+1)^h)²` elements. -/
theorem card_bhBad_le' (A : Finset ℕ) (h : ℕ) :
    #(bhBad A h) ≤ h * ((h + 1) * (#A + 1) ^ h) ^ 2 := by
  refine le_trans (card_bhBad_le A h) ?_
  exact Nat.mul_le_mul_left h (Nat.pow_le_pow_left (card_sumsUpTo_le A h) 2)

/-! ## 2. A global pigeonhole for the greedy `B_h` step -/

/-- **Global pigeonhole.**  Any `B_h` set `A` of size `n` admits a new element
`m ≤ n + h((h+1)(n+1)^h)²`, with no constraint relating `m` to the elements of `A`. -/
theorem exists_valid_le_bh {A : Finset ℕ} {h : ℕ} (hA : IsBh h A) :
    ∃ m ≤ #A + h * ((h + 1) * (#A + 1) ^ h) ^ 2, m ∉ A ∧ IsBh h (insert m A) := by
  classical
  set n := #A with hn
  set B := h * ((h + 1) * (n + 1) ^ h) ^ 2 with hB
  set W : Finset ℕ := Finset.range (n + B + 1) with hW
  have hcardW : #W = n + B + 1 := by rw [hW, Finset.card_range]
  set Bad : Finset ℕ := A ∪ bhBad A h with hBad
  have hcardBad : #Bad ≤ n + B := by
    have h1 : #(bhBad A h) ≤ B := card_bhBad_le' A h
    have h2 : #Bad ≤ #A + #(bhBad A h) := Finset.card_union_le _ _
    omega
  have hex : ∃ m ∈ W, m ∉ Bad := by
    by_contra hcon
    push_neg at hcon
    have : #W ≤ #Bad := Finset.card_le_card hcon
    omega
  obtain ⟨m, hmW, hmBad⟩ := hex
  have hmlt : m < n + B + 1 := by simpa [hW] using hmW
  have hmA : m ∉ A := fun hmem => hmBad (Finset.mem_union_left _ hmem)
  have hmbad : m ∉ bhBad A h := fun hmem => hmBad (Finset.mem_union_right _ hmem)
  exact ⟨m, by omega, hmA, isBh_insert_of_notMem_bhBad hA hmbad⟩

/-! ## 3. Chain rigidity at level `h` -/

/-- **Chain rigidity for the greedy `B_h` process.**  Every value still admissible at stage
`n` is larger than everything already chosen: the greedy `B_h` chain never leaves a usable
value behind, so the ordering clause in `GoodNextBh` is not a restriction. -/
theorem greedyBh_valid_gt (h : ℕ) : ∀ (n m : ℕ), m ∉ greedySetBh h n →
    IsBh h (insert m (greedySetBh h n)) → ∀ a ∈ greedySetBh h n, a < m
  | 0, m, _, _ => by simp [greedySetBh]
  | n + 1, m, hmA, hBh => by
      have hsub : insert m (greedySetBh h n) ⊆ insert m (greedySetBh h (n + 1)) := by
        intro x hx
        rcases Finset.mem_insert.mp hx with rfl | hx
        · exact Finset.mem_insert_self _ _
        · exact Finset.mem_insert_of_mem
            (by rw [greedySetBh_succ]; exact Finset.mem_insert_of_mem hx)
      have hmn : m ∉ greedySetBh h n := fun hmem => hmA (by
        rw [greedySetBh_succ]; exact Finset.mem_insert_of_mem hmem)
      have hBh' : IsBh h (insert m (greedySetBh h n)) := hBh.subset hsub
      have hgt := greedyBh_valid_gt h n m hmn hBh'
      have hgood : GoodNextBh h (greedySetBh h n) m := ⟨hgt, hBh'⟩
      have hle : greedySeqBh h n ≤ m :=
        Nat.sInf_le (s := {m | GoodNextBh h (greedySetBh h n) m}) hgood
      have hne : greedySeqBh h n ≠ m := fun hEq => hmA (by
        rw [greedySetBh_succ, ← hEq]; exact Finset.mem_insert_self _ _)
      intro a ha
      rcases Finset.mem_insert.mp (by rwa [greedySetBh_succ] at ha) with rfl | ha'
      · omega
      · exact hgt a ha'

/-! ## 4. The degree drop -/

/-- **Degree-`2h` upper bound for the greedy `B_h` sequence**:
`a_h(n) ≤ n + h·((h+1)(n+1)^h)²`, one degree better than the summed-window bound. -/
theorem greedySeqBh_le_deg2h (h n : ℕ) :
    greedySeqBh h n ≤ n + h * ((h + 1) * (n + 1) ^ h) ^ 2 := by
  obtain ⟨m, hmle, hmA, hmBh⟩ := exists_valid_le_bh (greedySetBh_isBh h n)
  rw [card_greedySetBh] at hmle
  have hgt := greedyBh_valid_gt h n m hmA hmBh
  have hgood : GoodNextBh h (greedySetBh h n) m := ⟨hgt, hmBh⟩
  exact le_trans (Nat.sInf_le (s := {m | GoodNextBh h (greedySetBh h n) m}) hgood) hmle

/-- **Sharpened sandwich for greedy `B_h` growth**: a degree-`h` lower bound and a
degree-`2h` upper bound. -/
theorem greedySeqBh_sandwich_sharp (h n : ℕ) :
    (n + 1).choose h ≤ h * greedySeqBh h n + 1 ∧
      greedySeqBh h n ≤ n + h * ((h + 1) * (n + 1) ^ h) ^ 2 :=
  ⟨choose_le_greedySeqBh h n, greedySeqBh_le_deg2h h n⟩

/-- The `h = 2` specialisation: the greedy `B_2` (Sidon) sequence obtained from the generic
`B_h` machinery satisfies `a(n) ≤ n + 2·(3(n+1)²)²`, i.e. a quartic bound.  The dedicated
argument of `GreedyDifferenceCubic.lean` gives a cubic bound, so the loss in the generic
route is exactly one degree. -/
theorem greedySeqBh_two_le (n : ℕ) : greedySeqBh 2 n ≤ n + 18 * (n + 1) ^ 4 := by
  have h := greedySeqBh_le_deg2h 2 n
  have hr : 2 * ((2 + 1) * (n + 1) ^ 2) ^ 2 = 18 * (n + 1) ^ 4 := by ring
  omega

end GreedyBh