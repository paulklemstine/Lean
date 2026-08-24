/-
# When is there no epistasis?  The merge (exchange) axiom

The tropical model allows arbitrary monotone cost profiles
(`NetEpistasis.realizable_iff`), so an additivity law can only come from extra
*structure* on the path system.  This file isolates the exact structural
hypothesis that kills epistasis.

A path system is **mergeable** if any two paths admit a common refinement: a path
whose support is contained in the intersection of the two supports and whose loss
is no worse than the worse of the two.  Concretely: whatever two backup routes
can do separately, some route that depends only on the layers *both* of them need
can do as well.

Under mergeability:
* `cost_union_le_max_of_mergeable` — joint cost is bounded by the *maximum*, not
  even the sum, of the individual costs;
* `epi_nonpos_of_mergeable` — no super-additivity anywhere;
* `cost_le_sup_singleton_of_mergeable` — the cost of pruning any set is bounded
  by the largest solo cost, so per-layer budgets are safe.

Conversely a single super-additive pair certifies that mergeability fails, and
`merge_obstruction_of_superadditive` extracts the explicit obstruction: two
optimal backup routes whose common part is strictly worse than both.  This is the
formal content of "the two layers are co-adapted": their backups cannot be
merged.
-/
import Tropical.NetEpistasis.Core

namespace NetEpistasis

open Finset

variable {n : ℕ} {N : PrunableNet n}

/-- Any two paths admit a common refinement using only the layers both of them
need, at no extra loss. -/
def Mergeable (N : PrunableNet n) : Prop :=
  ∀ p q : N.ι, ∃ r : N.ι,
    N.supp r ⊆ N.supp p ∩ N.supp q ∧ N.loss r ≤ max (N.loss p) (N.loss q)

/-- Under the merge axiom the joint pruning cost is bounded by the maximum of the
individual costs. -/
theorem cost_union_le_max_of_mergeable (h : Mergeable N) (S T : Finset (Fin n)) :
    cost N (S ∪ T) ≤ max (cost N S) (cost N T) := by
  obtain ⟨p, hp, hpval⟩ := exists_netLoss_eq (N := N) S
  obtain ⟨q, hq, hqval⟩ := exists_netLoss_eq (N := N) T
  obtain ⟨r, hr, hrloss⟩ := h p q
  have hdisj : Disjoint (N.supp r) (S ∪ T) := by
    rw [Finset.disjoint_union_right]
    constructor
    · exact hp.mono_left (hr.trans Finset.inter_subset_left)
    · exact hq.mono_left (hr.trans Finset.inter_subset_right)
  have hle : netLoss N (S ∪ T) ≤ max (netLoss N S) (netLoss N T) := by
    calc netLoss N (S ∪ T) ≤ N.loss r := netLoss_le hdisj
      _ ≤ max (N.loss p) (N.loss q) := hrloss
      _ = max (netLoss N S) (netLoss N T) := by rw [hpval, hqval]
  rcases le_total (netLoss N S) (netLoss N T) with hst | hst
  · have : netLoss N (S ∪ T) ≤ netLoss N T := by rwa [max_eq_right hst] at hle
    have : cost N (S ∪ T) ≤ cost N T := by simp only [cost]; linarith
    exact this.trans (le_max_right _ _)
  · have : netLoss N (S ∪ T) ≤ netLoss N S := by rwa [max_eq_left hst] at hle
    have : cost N (S ∪ T) ≤ cost N S := by simp only [cost]; linarith
    exact this.trans (le_max_left _ _)

/-- Mergeable systems are sub-additive: no epistasis can appear. -/
theorem cost_union_le_add_of_mergeable (h : Mergeable N) (S T : Finset (Fin n)) :
    cost N (S ∪ T) ≤ cost N S + cost N T := by
  refine (cost_union_le_max_of_mergeable h S T).trans ?_
  rcases le_total (cost N S) (cost N T) with hst | hst
  · rw [max_eq_right hst]
    linarith [cost_nonneg (N := N) S]
  · rw [max_eq_left hst]
    linarith [cost_nonneg (N := N) T]

theorem epi_nonpos_of_mergeable (h : Mergeable N) (S T : Finset (Fin n)) :
    epi N S T ≤ 0 := by
  have := cost_union_le_add_of_mergeable h S T
  simp only [epi]
  linarith

/-- No mergeable system exhibits a super-additive pair. -/
theorem not_mergeable_of_superAdditive {S T : Finset (Fin n)} (h : SuperAdditive N S T) :
    ¬ Mergeable N := fun hm => absurd (epi_nonpos_of_mergeable hm S T) (not_le.mpr h)

/-- **The obstruction behind super-additivity.**  A super-additive pair produces
two optimal backup routes — one avoiding `S`, one avoiding `T` — whose common
part is *strictly worse* than both: their capabilities cannot be merged into a
route independent of the layers they disagree on. -/
theorem merge_obstruction_of_superadditive {S T : Finset (Fin n)} (h : SuperAdditive N S T) :
    ∃ p q : N.ι, Disjoint (N.supp p) S ∧ Disjoint (N.supp q) T ∧
      N.loss p = netLoss N S ∧ N.loss q = netLoss N T ∧
      ∀ r : N.ι, N.supp r ⊆ N.supp p ∩ N.supp q →
        max (N.loss p) (N.loss q) < N.loss r := by
  obtain ⟨p, hp, hpval⟩ := exists_netLoss_eq (N := N) S
  obtain ⟨q, hq, hqval⟩ := exists_netLoss_eq (N := N) T
  refine ⟨p, q, hp, hq, hpval, hqval, ?_⟩
  intro r hr
  by_contra hcon
  push_neg at hcon
  have hdisj : Disjoint (N.supp r) (S ∪ T) := by
    rw [Finset.disjoint_union_right]
    exact ⟨hp.mono_left (hr.trans Finset.inter_subset_left),
      hq.mono_left (hr.trans Finset.inter_subset_right)⟩
  have hle : netLoss N (S ∪ T) ≤ max (netLoss N S) (netLoss N T) := by
    calc netLoss N (S ∪ T) ≤ N.loss r := netLoss_le hdisj
      _ ≤ max (N.loss p) (N.loss q) := hcon
      _ = max (netLoss N S) (netLoss N T) := by rw [hpval, hqval]
  have hSle : netLoss N ∅ ≤ netLoss N S := netLoss_mono (Finset.empty_subset S)
  have hTle : netLoss N ∅ ≤ netLoss N T := netLoss_mono (Finset.empty_subset T)
  have hepi : epi N S T ≤ 0 := by
    simp only [epi, cost]
    rcases le_total (netLoss N S) (netLoss N T) with hst | hst
    · rw [max_eq_right hst] at hle; linarith
    · rw [max_eq_left hst] at hle; linarith
  exact absurd hepi (not_le.mpr h)

/-- Under the merge axiom, per-layer budgeting is safe: pruning any nonempty set
of layers costs no more than the worst single layer in it. -/
theorem cost_le_sup_singleton_of_mergeable (h : Mergeable N) {S : Finset (Fin n)}
    (hS : S.Nonempty) : cost N S ≤ S.sup' hS fun i => cost N {i} := by
  induction hS using Finset.Nonempty.cons_induction with
  | singleton a => simp
  | cons a s ha hs ih =>
      have hunion : cost N (Finset.cons a s ha) = cost N ({a} ∪ s) := by
        congr 1
        ext x; simp
      rw [Finset.sup'_cons hs, hunion]
      refine (cost_union_le_max_of_mergeable h {a} s).trans ?_
      have h1 : cost N {a} ≤ max (cost N {a}) (s.sup' hs fun i => cost N {i}) :=
        le_max_left _ _
      have h2 : cost N s ≤ max (cost N {a}) (s.sup' hs fun i => cost N {i}) :=
        le_trans ih (le_max_right _ _)
      exact max_le h1 h2

end NetEpistasis