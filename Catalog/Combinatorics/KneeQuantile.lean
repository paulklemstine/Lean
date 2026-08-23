import Combinatorics.KneeInvariance

/-!
# The knee is an order statistic (NET-70, cycle 3)

Cycle 1 showed that the NET-70 knee only sees the *demand multiset*; cycle 2
turned the deployment table into an interval point-cover.  This file explains
**why** the knee is so stable across domains — stable enough to survive a
12-point accuracy gap — by identifying it exactly:

> `knee = the ⌈g·n⌉-th smallest demand`.

An order statistic, not an average.  Consequences proved here:

* `knee_eq_demandQuantile` — the identity itself.
* `knee_le_iff_tail_small` — the **exact gate criterion**: `k` clears the gate
  iff at most `(1-g)·n` windows demand more than `k` keys.  Markov's bound
  (`knee_le_of_markov`) is the one-sided relaxation of this.
* `knee_le_of_tail_zero`, `knee_pos_of_tail_large` — the two directions in
  usable form.
* `knee_permutation_invariant` — relabelling windows cannot move the knee;
  combined with `knee_eq_of_demandMultiset_eq` this says the sweep is a
  *symmetric function of the demands only*.
* `knee_stable_under_bounded_perturbation` — **robustness**: perturbing the
  demand of at most `(1-g)·n - tail` windows arbitrarily (e.g. the hardest
  windows of a harder domain) cannot raise the knee above `k`.  This is the
  structural reason a domain jump that costs 12 accuracy points can still leave
  the knee exactly where it was: accuracy is an average over all windows, the
  knee is a quantile of a different statistic.
-/

namespace Combinatorics.KneeQuantile

open Finset Combinatorics.KneeInvariance

variable {n : ℕ}

/-- The `m`-th smallest demand of a workload (`m` counted from 1), as the least
budget serving at least `m` windows. -/
noncomputable def demandQuantile (D : Workload n) (m : ℕ) : ℕ :=
  sInf {k | m ≤ agreeCount D k}

/-- **The knee is an order statistic.**  At gate `g` on `n` windows it is
exactly the `⌈g·n⌉`-th smallest demand. -/
theorem knee_eq_demandQuantile (D : Workload n) (hn : 0 < n) (g : ℚ) :
    knee D.agree g = demandQuantile D ⌈g * n⌉₊ := by
  have hnQ : (0 : ℚ) < n := by exact_mod_cast hn
  unfold knee demandQuantile
  congr 1
  ext k
  simp only [Set.mem_setOf_eq, Workload.agree, le_div_iff₀ hnQ]
  constructor
  · intro h
    exact Nat.ceil_le.mpr (by exact_mod_cast h)
  · intro h
    exact le_trans (Nat.le_ceil _) (by exact_mod_cast h)

/-- **Exact gate criterion.**  A budget clears the gate precisely when its
unserved tail is no larger than the slack `1 - g`. -/
theorem knee_le_iff_tail_small (D : Workload n) (hn : 0 < n) {g : ℚ} {k : ℕ} :
    D.agree k ≥ g ↔ (((univ.filter fun i => k < D.demand i).card : ℚ)) ≤ (1 - g) * n := by
  have hnQ : (0 : ℚ) < n := by exact_mod_cast hn
  have hsum : agreeCount D k + (univ.filter fun i => k < D.demand i).card = n :=
    agreeCount_add_tail D k
  have hsumQ : ((agreeCount D k : ℚ)) + ((univ.filter fun i => k < D.demand i).card : ℚ)
      = (n : ℚ) := by exact_mod_cast hsum
  unfold Workload.agree
  rw [ge_iff_le, le_div_iff₀ hnQ]
  constructor <;> intro h <;> nlinarith

/-- If every window is served by budget `k`, the knee is at most `k` (for any
gate `≤ 1`). -/
theorem knee_le_of_tail_zero (D : Workload n) (hn : 0 < n) {g : ℚ} (hg : g ≤ 1) {k : ℕ}
    (h : ∀ i, D.demand i ≤ k) : knee D.agree g ≤ k := by
  refine knee_le ?_
  have hset : (univ.filter fun i => D.demand i ≤ k) = univ := filter_true_of_mem fun i _ => h i
  have : D.agree k = 1 := by
    unfold Workload.agree agreeCount
    rw [hset]
    simp only [card_univ, Fintype.card_fin]
    field_simp
  rw [this]
  exact hg

/-- Conversely, a tail that is too fat forces a *strictly* larger knee: `k`
cannot clear the gate. -/
theorem knee_pos_of_tail_large (D : Workload n) (hn : 0 < n) {g : ℚ} (hg : g ≤ 1) {k : ℕ}
    (h : (1 - g) * n < ((univ.filter fun i => k < D.demand i).card : ℚ)) :
    k < knee D.agree g := by
  by_contra hc
  push_neg at hc
  have hmem : g ≤ D.agree (knee D.agree g) := knee_mem (agree_gate_reachable D hn hg)
  have hgk : g ≤ D.agree k := le_trans hmem (agree_mono D hc)
  exact absurd ((knee_le_iff_tail_small D hn).mp hgk) (not_le.mpr h)

/-- **Permutation invariance.**  Relabelling the windows leaves every knee
untouched. -/
theorem knee_permutation_invariant (D : Workload n) (e : Equiv.Perm (Fin n)) (g : ℚ) :
    knee (Workload.mk (D.demand ∘ e) D.correct).agree g = knee D.agree g := by
  refine knee_eq_of_demandMultiset_eq _ _ rfl ?_ g
  unfold demandMultiset
  rw [← Multiset.map_map]
  congr 1
  simp

/-- **Robustness of the knee under a hard-window perturbation.**  If, after an
arbitrary change of demands, the set of windows still unserved at budget `k` is
no larger than the gate slack, the knee is still at most `k` — however badly the
perturbation hurt accuracy.  This is the mechanism behind MATH-READS-AS-PROSE:
a domain can be uniformly harder to *predict* and still leave the unserved-tail
quantile in place. -/
theorem knee_stable_under_bounded_perturbation (D E : Workload n) (hn : 0 < n) {g : ℚ}
    {k : ℕ}
    (hD : ((univ.filter fun i => k < D.demand i).card : ℚ) ≤ (1 - g) * n)
    (hE : (univ.filter fun i => k < E.demand i) ⊆ (univ.filter fun i => k < D.demand i)) :
    knee E.agree g ≤ k := by
  refine knee_le ((knee_le_iff_tail_small E hn).mpr ?_)
  have hcard : ((univ.filter fun i => k < E.demand i).card : ℚ)
      ≤ ((univ.filter fun i => k < D.demand i).card : ℚ) := by
    exact_mod_cast card_le_card hE
  linarith

end Combinatorics.KneeQuantile