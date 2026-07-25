/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cycle-containing families over a binary alphabet (`b = 2`)

For the binary alphabet `Fin 2` the bipartite graph of a pair has only four
possible edges, and its **only** possible cycle is the 4-cycle of the complete
bipartite graph `K₂,₂`.  Hence a pair `(u, v)` is cycle-containing iff all four
"patterns" `(s, t) ∈ Fin 2 × Fin 2` occur among the coordinates — the classical
notion of two binary vectors being *qualitatively independent*.

We package this combinatorial criterion as `Shatter`, connect it to the genuine
graph-theoretic predicate `ContainsCycle` from `CycleFamilies.General` via
`shatter_containsCycle`, and use it to:

* `shatter_k_ge_four`      : a shattering pair forces `4 ≤ k` (sharp threshold);
* `shatter_snoc`           : shattering is preserved by extending vectors, so the
                              extremal function is monotone in `k`;
* `exists_cyclicFamily_card_three` : an explicit **genuinely cycle-containing**
                              family of three vectors at `k = 4`, matching the
                              exhaustively-computed maximum (see
                              `ComputationalEvidence.md`).

-- !-- Lab Notes -- !--
Hypothesis  : Over `Fin 2` the graph cycle condition is equivalent to "all four
              patterns appear" (qualitative independence), and the maximum cyclic
              family has sizes `1,1,3,4,10,15,…` for `k = 2,3,4,5,6,7`.
Experiment  : Brute-force max-clique enumeration produced the sequence above.
              Formally, `Shatter` says the coordinate map `i ↦ (u i, v i)` is onto
              `Fin 2 × Fin 2`; surjectivity onto a 4-element type forces `k ≥ 4`.
              The explicit triple `{0011, 0101, 0110}` was verified to be pairwise
              shattering by `decide`, then promoted to genuine `ContainsCycle` via
              the constructed 4-cycle walk `shatter_containsCycle`.
Analysis    : Lower bound `3` at `k = 4` is exact (brute force gives `3`); proving
              the matching *upper* bound `≤ 3` for `k = 4`, and the general formula
              `N₂(k)`, are open (recorded in FUTURE_DIRECTIONS).  The threshold and
              monotonicity are the clean, fully-formal facts.
Critique    : `decide` is used only for the finite verification of a *single*
              witness family, never as the proof of a structural theorem.  The
              structural theorems use `Fintype.card_le_of_surjective`, an explicit
              walk construction, and `Fin.snoc` case analysis.
Synthesis   : The binary world realises the general girth bound sharply and
              exhibits the first nontrivial cyclic families.
-/
import Novelty.CycleFamilies.General

open SimpleGraph Finset

namespace Catalog.Novelty.CycleFamilies

variable {k : ℕ}

/-- Two binary vectors *shatter* if all four patterns `(s, t)` occur among the
coordinates.  For `b = 2` this is exactly the condition that the bipartite graph
contains a cycle (its unique cycle is the `K₂,₂` 4-cycle). -/
def Shatter (u v : Fin k → Fin 2) : Prop := ∀ s t : Fin 2, ∃ i, u i = s ∧ v i = t

/-- A shattering pair forces the four patterns to appear, hence `k ≥ 4`. -/
theorem shatter_k_ge_four (u v : Fin k → Fin 2) (h : Shatter u v) : 4 ≤ k := by
  have hsurj : Function.Surjective (fun i => (u i, v i)) := by
    rintro ⟨s, t⟩
    obtain ⟨i, hi1, hi2⟩ := h s t
    exact ⟨i, by simp [hi1, hi2]⟩
  simpa [Fintype.card_prod] using Fintype.card_le_of_surjective _ hsurj

/-- A coordinate realising pattern `(a, c)` gives an edge `inl a — inr c`. -/
theorem adj_of_pat (u v : Fin k → Fin 2) (a c : Fin 2) (i : Fin k)
    (h1 : u i = a) (h2 : v i = c) :
    (pairGraph u v).Adj (Sum.inl a) (Sum.inr c) := by
  subst h1 h2
  rw [pairGraph, SimpleGraph.fromEdgeSet_adj]
  exact ⟨⟨i, rfl⟩, by simp⟩

/-- **Bridge to the genuine graph predicate.**  If a binary pair shatters then its
bipartite graph really does contain a cycle: we exhibit the 4-cycle
`inl 0 — inr 0 — inl 1 — inr 1 — inl 0`. -/
theorem shatter_containsCycle (u v : Fin k → Fin 2) (h : Shatter u v) :
    ContainsCycle u v := by
  obtain ⟨i00, e00u, e00v⟩ := h 0 0
  obtain ⟨i01, e01u, e01v⟩ := h 0 1
  obtain ⟨i10, e10u, e10v⟩ := h 1 0
  obtain ⟨i11, e11u, e11v⟩ := h 1 1
  have a00 := adj_of_pat u v 0 0 i00 e00u e00v
  have a01 := adj_of_pat u v 0 1 i01 e01u e01v
  have a10 := adj_of_pat u v 1 0 i10 e10u e10v
  have a11 := adj_of_pat u v 1 1 i11 e11u e11v
  intro hac
  refine hac (Walk.cons a00 (.cons a10.symm (.cons a11 (.cons a01.symm .nil)))) ?_
  rw [SimpleGraph.Walk.isCycle_def]
  refine ⟨?_, ?_, ?_⟩
  · rw [SimpleGraph.Walk.isTrail_def]
    simp only [SimpleGraph.Walk.edges_cons, SimpleGraph.Walk.edges_nil]
    decide
  · simp
  · simp only [SimpleGraph.Walk.support_cons, SimpleGraph.Walk.support_nil]
    decide

/-- Shattering is preserved by appending a coordinate (with arbitrary values):
the extremal function `k ↦ (max cyclic family size)` is monotone in `k`. -/
theorem shatter_snoc (u v : Fin k → Fin 2) (a b : Fin 2) (h : Shatter u v) :
    Shatter (Fin.snoc u a) (Fin.snoc v b) := by
  intro s t
  obtain ⟨i, hi1, hi2⟩ := h s t
  exact ⟨i.castSucc, by simpa using hi1, by simpa using hi2⟩

/-- An explicit pairwise-shattering triple of length-4 binary vectors. -/
def w1 : Fin 4 → Fin 2 := ![0, 0, 1, 1]
def w2 : Fin 4 → Fin 2 := ![0, 1, 0, 1]
def w3 : Fin 4 → Fin 2 := ![0, 1, 1, 0]

/-- The triple `{w1, w2, w3}` has three elements and every pair shatters. -/
theorem triple_pairwise_shatter :
    ∀ u ∈ ({w1, w2, w3} : Finset (Fin 4 → Fin 2)),
      ∀ v ∈ ({w1, w2, w3} : Finset (Fin 4 → Fin 2)), u ≠ v → Shatter u v := by
  intro u hu v hv huv
  simp only [Finset.mem_insert, Finset.mem_singleton] at hu hv
  rcases hu with rfl | rfl | rfl <;> rcases hv with rfl | rfl | rfl <;>
    first | exact absurd rfl huv | (simp only [Shatter]; decide)

/-- **Genuine lower bound at `k = 4`.**  There is a cycle-containing family of
three binary vectors of length 4 (each pair's bipartite graph really contains a
cycle), so the extremal function at `k = 4` is at least `3`. -/
theorem exists_cyclicFamily_card_three :
    ∃ C : Finset (Fin 4 → Fin 2), CyclicFamily C ∧ C.card = 3 := by
  refine ⟨{w1, w2, w3}, ?_, by decide⟩
  intro u hu v hv huv
  exact shatter_containsCycle u v (triple_pairwise_shatter u hu v hv huv)

end Catalog.Novelty.CycleFamilies