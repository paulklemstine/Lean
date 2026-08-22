import Algebra.NonBacktracking.AcyclicVanishing

/-!
# The non-backtracking trace sequence sees the girth

`Algebra.NonBacktracking.AcyclicVanishing` shows that a closed non-backtracking walk
cannot exist in a forest. Here we localise that statement: a closed non-backtracking walk
of length `n` only uses `n` edges, and the spanning subgraph formed by those edges is
therefore a graph with a cycle of length at most `n`. Consequently

`trace (B ^ n) ≠ 0 → girth G ≤ n`,

and since a shortest cycle contributes a closed non-backtracking walk of its own length
(`Hashimoto.one_le_trace_of_isCycle`), the girth is exactly the first index at which the
non-backtracking trace sequence becomes nonzero.

## Main results

* `Hashimoto.egirth_le_of_isChain_ne_edges` — a closed walk of positive length with
  consecutively distinct edges forces `egirth G ≤ length`;
* `Hashimoto.egirth_le_of_trace_ne_zero` — `trace (B ^ n) ≠ 0 → egirth G ≤ n`;
* `Hashimoto.trace_hashimoto_pow_eq_zero_of_lt_egirth` — the trace vanishes below the
  girth;
* `Hashimoto.one_le_trace_hashimoto_pow_girth` — at the girth the trace is positive;
* `Hashimoto.girth_eq_sInf_trace_ne_zero` — `girth G = min {n ≥ 1 : trace (B ^ n) ≠ 0}`
  for a graph containing a cycle.
-/

open Finset SimpleGraph List

namespace Hashimoto

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

omit [DecidableRel G.Adj] in
/-- **A short cyclically reduced closed walk forces a short cycle.** If `p` is a closed
walk of positive length whose consecutive edges differ, then `G` has a cycle of length at
most `p.length`. The proof restricts to the spanning subgraph spanned by the `≤ p.length`
edges of `p`: were it acyclic, `p` would be a path there, hence trivial. -/
lemma egirth_le_of_isChain_ne_edges {v : V} (p : G.Walk v v) (hp : 1 ≤ p.length)
    (hedges : List.IsChain (· ≠ ·) p.edges) : G.egirth ≤ p.length := by
  classical
  set H : SimpleGraph V := SimpleGraph.fromEdgeSet {e | e ∈ p.edges} with hH
  have hHG : H ≤ G := by
    intro a b hab
    rw [hH, SimpleGraph.fromEdgeSet_adj] at hab
    exact p.edges_subset_edgeSet hab.1
  have hpe : ∀ e ∈ p.edges, e ∈ H.edgeSet := by
    intro e he
    induction e using Sym2.ind with
    | _ a b =>
        have hadj : G.Adj a b := p.edges_subset_edgeSet he
        rw [hH]
        simp [he, hadj.ne]
  have hHacyc : ¬ H.IsAcyclic := by
    intro hacyc
    have h1 : (p.transfer H hpe).IsPath :=
      (hacyc.isPath_iff_isChain _).2 (by rw [p.edges_transfer hpe]; exact hedges)
    have h2 : p.transfer H hpe = Walk.nil := (Walk.isPath_iff_eq_nil _).1 h1
    have h3 := p.length_transfer hpe
    rw [h2] at h3
    simp only [Walk.length_nil] at h3
    omega
  obtain ⟨a, q, hq⟩ : ∃ (a : V) (q : H.Walk a a), q.IsCycle := by
    by_contra hcon
    push_neg at hcon
    exact hHacyc fun a q hq => hcon a q hq
  have hsub : q.edges.toFinset ⊆ p.edges.toFinset := by
    intro e he
    simp only [List.mem_toFinset] at he ⊢
    have hmem : e ∈ H.edgeSet := q.edges_subset_edgeSet he
    rw [hH, SimpleGraph.edgeSet_fromEdgeSet] at hmem
    exact hmem.1
  have hlen : q.length ≤ p.length :=
    calc q.length = q.edges.length := q.length_edges.symm
      _ = q.edges.toFinset.card := (List.toFinset_card_of_nodup hq.isTrail.edges_nodup).symm
      _ ≤ p.edges.toFinset.card := Finset.card_le_card hsub
      _ ≤ p.edges.length := List.toFinset_card_le _
      _ = p.length := p.length_edges
  calc G.egirth ≤ ((q.mapLe hHG).length : ℕ∞) := egirth_le_length (hq.mapLe hHG)
    _ = (q.length : ℕ∞) := by simp
    _ ≤ (p.length : ℕ∞) := by exact_mod_cast hlen

/-- **A nonzero non-backtracking trace bounds the girth.** If `trace (B ^ n) ≠ 0` then `G`
has a cycle of length at most `n`. -/
theorem egirth_le_of_trace_ne_zero {n : ℕ} (hn : 1 ≤ n) (h : (hashimoto G ^ n).trace ≠ 0) :
    G.egirth ≤ n := by
  rw [trace_hashimoto_pow_eq_card_nbCycles G hn, Ne, Finset.card_eq_zero,
    ← Ne, ← Finset.nonempty_iff_ne_empty] at h
  obtain ⟨c, hc⟩ := h
  obtain ⟨v, p, hlen, hchain⟩ := exists_closed_walk_of_mem_nbCycles hn hc
  have := egirth_le_of_isChain_ne_edges p (by omega) hchain
  rwa [hlen] at this

/-- **The trace vanishes below the girth.** There is no closed non-backtracking walk
shorter than the shortest cycle. -/
theorem trace_hashimoto_pow_eq_zero_of_lt_egirth {n : ℕ} (hn : 1 ≤ n) (h : (n : ℕ∞) < G.egirth) :
    (hashimoto G ^ n).trace = 0 := by
  by_contra hc
  exact absurd (egirth_le_of_trace_ne_zero hn hc) (not_le.2 h)

/-- **At the girth the trace is positive.** A graph with a cycle has a rooted closed
non-backtracking walk whose length is the girth. -/
theorem one_le_trace_hashimoto_pow_girth (hG : ¬ G.IsAcyclic) :
    1 ≤ (hashimoto G ^ G.girth).trace := by
  obtain ⟨a, q, hq, hlen⟩ := exists_girth_eq_length.2 hG
  rw [hlen]
  exact one_le_trace_of_isCycle q hq

/-- **The girth is the first nonzero index of the non-backtracking trace sequence.** For a
graph containing a cycle,
`girth G = min { n ≥ 1 : trace (B ^ n) ≠ 0 }`. -/
theorem girth_eq_sInf_trace_ne_zero (hG : ¬ G.IsAcyclic) :
    G.girth = sInf {n : ℕ | 1 ≤ n ∧ (hashimoto G ^ n).trace ≠ 0} := by
  have h3 : 3 ≤ G.girth := three_le_girth hG
  have hmem : G.girth ∈ {n : ℕ | 1 ≤ n ∧ (hashimoto G ^ n).trace ≠ 0} := by
    refine ⟨by omega, ?_⟩
    have := one_le_trace_hashimoto_pow_girth hG
    omega
  refine le_antisymm ?_ (Nat.sInf_le hmem)
  refine le_csInf ⟨G.girth, hmem⟩ ?_
  rintro n ⟨hn, hne⟩
  have hle : G.egirth ≤ (n : ℕ∞) := egirth_le_of_trace_ne_zero hn hne
  have hfin : G.egirth ≠ ⊤ := by
    intro htop
    exact hG (egirth_eq_top.1 htop)
  have : (G.girth : ℕ∞) ≤ (n : ℕ∞) := by
    rwa [SimpleGraph.girth, ENat.coe_toNat hfin]
  exact_mod_cast this

end Hashimoto