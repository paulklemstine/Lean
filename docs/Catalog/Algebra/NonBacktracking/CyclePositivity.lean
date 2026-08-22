import Algebra.NonBacktracking.VertexCycles

/-!
# Cycles make the non-backtracking trace positive

The trace formula turns a purely graph-theoretic statement — "`G` contains a cycle" —
into an algebraic one about the Hashimoto matrix `B`.

## Main results

* `Hashimoto.one_le_trace_of_nodup_cyclic` — a closed cyclically adjacent vertex word of
  length at least three with distinct letters contributes a rooted closed
  non-backtracking walk, so `1 ≤ trace (B ^ m)`.
* `Hashimoto.one_le_trace_of_isCycle` — every cycle of length `m` in `G` forces
  `1 ≤ trace (B ^ m)`.
* `Hashimoto.isAcyclic_of_trace_eq_zero` — conversely, if all traces `trace (B ^ n)`
  vanish for `n ≥ 1` then `G` is acyclic. Together with `Hashimoto.trace_hashimoto_pow`
  this says: the non-backtracking trace sequence detects the presence of cycles.
-/

open Finset SimpleGraph List

namespace Hashimoto

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

/-! ## Distinct letters give no backtracking -/

omit [Fintype V] [DecidableEq V] in
/-- In a word of length at least three with pairwise distinct letters, no letter equals
the letter two positions later (cyclically). -/
lemma forall₂_ne_rotate_two_of_nodup {u : List V} (h3 : 3 ≤ u.length) (hnd : u.Nodup) :
    Forall₂ (· ≠ ·) (u.rotate 2) u := by
  rw [List.forall₂_iff_get]
  refine ⟨by simp, ?_⟩
  intro i h₁ h₂ hEq
  rw [List.get_rotate] at hEq
  rw [hnd.get_inj_iff] at hEq
  have hmod : (i + 2) % u.length = i := by simpa [Fin.ext_iff] using hEq
  rcases lt_or_ge (i + 2) u.length with h | h
  · rw [Nat.mod_eq_of_lt h] at hmod; omega
  · have hsub : (i + 2) % u.length = i + 2 - u.length := by
      rw [Nat.mod_eq_sub_mod h, Nat.mod_eq_of_lt (by omega)]
    omega

/-- **Cyclic words give closed non-backtracking walks.** -/
theorem one_le_trace_of_nodup_cyclic {u : List V} (h3 : 3 ≤ u.length) (hnd : u.Nodup)
    (hadj : Forall₂ G.Adj u (u.rotate 1)) :
    1 ≤ (hashimoto G ^ u.length).trace := by
  rw [trace_hashimoto_pow_eq_card_cyclicNBVertexSeqs G (by omega)]
  rw [Nat.one_le_iff_ne_zero, ← Nat.pos_iff_ne_zero, Finset.card_pos]
  exact ⟨u, (mem_cyclicNBVertexSeqs (by omega)).2
    ⟨rfl, hadj, forall₂_ne_rotate_two_of_nodup h3 hnd⟩⟩

/-! ## From cycles in the graph -/

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- The support of a walk ends at its endpoint. -/
lemma getLast?_support {u v : V} (p : G.Walk u v) : p.support.getLast? = some v := by
  induction p with
  | nil => simp
  | @cons a b c h q ih =>
      rw [SimpleGraph.Walk.support_cons]
      have hne : q.support ≠ [] := by simp [SimpleGraph.Walk.support_ne_nil]
      cases hq : q.support with
      | nil => exact absurd hq hne
      | cons x t =>
          rw [List.getLast?_cons_cons]
          rw [hq] at ih
          exact ih

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- The vertex word of a closed walk is cyclically adjacent. -/
lemma forall₂_adj_rotate_support_tail {v : V} (p : G.Walk v v) (hp : 1 ≤ p.length) :
    Forall₂ G.Adj p.support.tail (p.support.tail.rotate 1) := by
  have hlen : p.support.tail.length = p.length := by
    have := p.length_support
    simp [List.length_tail, this]
  have hne : p.support.tail ≠ [] := by
    intro h
    rw [h] at hlen
    simp at hlen
    omega
  have hchainAll : IsChain G.Adj p.support := p.isChain_adj_support
  rw [p.support_eq_cons, List.isChain_cons] at hchainAll
  refine (isChain_seam_iff_forall₂_rotate hne).1 ⟨hchainAll.2, ?_⟩
  intro x hx y hy
  have hlast : p.support.tail.getLast? = some v := by
    have h1 : p.support.getLast? = some v := getLast?_support p
    rw [p.support_eq_cons, RelWalkCount.getLast?_cons_of_ne_nil _ hne] at h1
    exact h1
  rw [hlast] at hx
  have hxv : x = v := by simpa using hx.symm
  subst hxv
  exact hchainAll.1 y hy

/-- **Every cycle forces a positive non-backtracking trace.** If `p` is a cycle of length
`m` in `G`, then `trace (B ^ m) ≥ 1`. -/
theorem one_le_trace_of_isCycle {v : V} (p : G.Walk v v) (hp : p.IsCycle) :
    1 ≤ (hashimoto G ^ p.length).trace := by
  have h3 : 3 ≤ p.length := hp.three_le_length
  have hlen : p.support.tail.length = p.length := by
    have := p.length_support
    simp [List.length_tail, this]
  have hmain := one_le_trace_of_nodup_cyclic (u := p.support.tail)
    (by omega) hp.support_nodup (forall₂_adj_rotate_support_tail p (by omega))
  rwa [hlen] at hmain

/-- **Acyclicity detector.** If every positive power of the Hashimoto matrix has zero
trace — equivalently, `G` has no rooted closed non-backtracking walk of positive
length — then `G` is acyclic. -/
theorem isAcyclic_of_trace_eq_zero
    (h : ∀ n : ℕ, 1 ≤ n → (hashimoto G ^ n).trace = 0) : G.IsAcyclic := by
  intro v p hp
  have h3 : 3 ≤ p.length := hp.three_le_length
  have hpos := one_le_trace_of_isCycle p hp
  rw [h p.length (by omega)] at hpos
  omega

/-- Contrapositive form: a graph with a cycle has a rooted closed non-backtracking walk
of positive length. -/
theorem exists_closedNBWalk_of_not_isAcyclic (h : ¬ G.IsAcyclic) :
    ∃ n : ℕ, 1 ≤ n ∧ 1 ≤ (closedNBWalks G n).card := by
  by_contra hcon
  push_neg at hcon
  refine h (isAcyclic_of_trace_eq_zero fun n hn => ?_)
  rw [trace_hashimoto_pow]
  have := hcon n hn
  omega

end Hashimoto