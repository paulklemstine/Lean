/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The greedy / maximum-degree bound for choosability

The topic conjecture "*every 3-colourable planar graph is 4-choosable*" is **false**
(Mirzakhani's 63-vertex 3-colourable planar graph is not 4-choosable).  Ordinary
colourability does **not** control choosability in general.  What *does* give an
unconditional upper bound on the list chromatic number is the **maximum degree**: this file
proves the list-colouring analogue of the greedy colouring bound.

Main result:

* `choosable_of_degree_lt` : if every vertex of a finite graph has degree `< k`, then the
  graph is `k`-choosable.  Equivalently, a graph of maximum degree `Δ` is `(Δ+1)`-choosable.

The proof is a genuine greedy induction (`greedy_partial`): colour the vertices one at a
time; when colouring a vertex `w`, at most `deg w < k` colours are forbidden by
already-coloured neighbours, so a colour remains available in its list of size `≥ k`.
-/
import Mathlib
import Combinatorics.ListChoosability.Defs

open SimpleGraph Finset

namespace ListChoosability

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- **Greedy partial colouring.**  For a graph in which every vertex has degree `< k` and a
list assignment with all lists of size `≥ k`, every finite set `S` of vertices admits a
proper `L`-colouring on `S` (the colouring is defined on all of `V` but only constrained on
`S`).  Proved by strong induction on `S`: remove a vertex `w`, colour the rest, then pick a
colour of `L w` avoiding the `< k` colours used by neighbours of `w`. -/
theorem greedy_partial (G : SimpleGraph V) [DecidableRel G.Adj] {k : ℕ}
    (hdeg : ∀ v, G.degree v < k) (L : V → Finset ℕ) (hL : ∀ v, k ≤ (L v).card) :
    ∀ S : Finset V, ∃ c : V → ℕ, (∀ v ∈ S, c v ∈ L v) ∧
      ∀ u ∈ S, ∀ v ∈ S, G.Adj u v → c u ≠ c v := by
  intro S
  induction S using Finset.strongInductionOn with
  | _ S ih =>
    rcases S.eq_empty_or_nonempty with hS | hS
    · exact ⟨fun _ => 0, by simp [hS], by simp [hS]⟩
    · obtain ⟨w, hw⟩ := hS
      obtain ⟨c', hc'mem, hc'adj⟩ := ih (S.erase w) (Finset.erase_ssubset hw)
      -- the colours forbidden for `w`: those already used by its neighbours in `S.erase w`
      set forbidden : Finset ℕ := ((S.erase w).filter (fun x => G.Adj w x)).image c' with hforb
      have hforbcard : forbidden.card < (L w).card := by
        calc forbidden.card
            ≤ ((S.erase w).filter (fun x => G.Adj w x)).card := Finset.card_image_le
          _ ≤ (G.neighborFinset w).card := by
              apply Finset.card_le_card
              intro x hx
              rw [Finset.mem_filter] at hx
              rw [mem_neighborFinset]
              exact hx.2
          _ = G.degree w := G.card_neighborFinset_eq_degree w
          _ < k := hdeg w
          _ ≤ (L w).card := hL w
      obtain ⟨a, haL, hanot⟩ := Finset.exists_mem_notMem_of_card_lt_card hforbcard
      refine ⟨Function.update c' w a, ?_, ?_⟩
      · intro v hv
        by_cases hvw : v = w
        · subst hvw; simpa using haL
        · rw [Function.update_of_ne hvw]
          exact hc'mem v (Finset.mem_erase.mpr ⟨hvw, hv⟩)
      · intro u hu v hv hadj
        by_cases huw : u = w <;> by_cases hvw : v = w
        · subst huw; subst hvw; exact absurd hadj G.irrefl
        · subst huw
          rw [Function.update_self, Function.update_of_ne hvw]
          intro heq
          apply hanot
          rw [hforb, heq]
          apply Finset.mem_image_of_mem
          rw [Finset.mem_filter]
          exact ⟨Finset.mem_erase.mpr ⟨hvw, hv⟩, hadj⟩
        · subst hvw
          rw [Function.update_of_ne huw, Function.update_self]
          intro heq
          apply hanot
          rw [hforb, ← heq]
          apply Finset.mem_image_of_mem
          rw [Finset.mem_filter]
          exact ⟨Finset.mem_erase.mpr ⟨huw, hu⟩, hadj.symm⟩
        · rw [Function.update_of_ne huw, Function.update_of_ne hvw]
          exact hc'adj u (Finset.mem_erase.mpr ⟨huw, hu⟩) v
            (Finset.mem_erase.mpr ⟨hvw, hv⟩) hadj

/-- **The greedy / maximum-degree choosability bound.**  If every vertex of a finite graph
has degree strictly less than `k`, then the graph is `k`-choosable.  In particular a graph
of maximum degree `Δ` is `(Δ + 1)`-choosable, and hence has list chromatic number at most
`Δ + 1`. -/
theorem choosable_of_degree_lt (G : SimpleGraph V) [DecidableRel G.Adj] {k : ℕ}
    (hdeg : ∀ v, G.degree v < k) : Choosable G k := by
  intro L hL
  obtain ⟨c, hmem, hadj⟩ := greedy_partial G hdeg L hL Finset.univ
  exact ⟨c, fun v => hmem v (Finset.mem_univ v),
    fun u v => hadj u (Finset.mem_univ u) v (Finset.mem_univ v)⟩

end ListChoosability

-- !-- Lab Notes -- !--
/-
## Lab Notes (Greedy)

**Hypothesis (Hypothesizer).**  Since colourability alone cannot bound choosability, what
*graph parameter* does?  Conjecture: the maximum degree does — a graph of maximum degree `Δ`
should be `(Δ+1)`-choosable, mirroring the greedy colouring bound `χ(G) ≤ Δ+1`.

**Experiment (Experimenter).**  We tested the greedy strategy by hand on paths and small
cycles: colouring vertices one at a time, each new vertex sees at most `deg < k` used colours
and has `k` candidates, so a free colour always survives.  This suggested the invariant used
in `greedy_partial`.

**Analysis (Analyst).**  The crux is the counting step: the set of forbidden colours at `w`
is the `c'`-image of its already-coloured neighbours, whose cardinality is `≤ deg w < k ≤
|L w|`, forcing a free colour via `exists_mem_notMem_of_card_lt_card`.  Strong induction on
the vertex set (`Finset.strongInductionOn`) rather than on the graph avoids all
subgraph-retyping pain.

**Failure analysis.**  A first instinct — induct on `Fintype.card V` by deleting a vertex —
fails because the induced subgraph changes the vertex type, breaking the degree hypothesis's
form.  Carrying a `Finset` of "vertices to colour" over a fixed `V` is the fix.

**Critique (Critic).**  The theorem is non-trivial (real induction + a cardinality
inequality) and axiom-clean.  It is *not* the topic conjecture, but it is the correct
unconditional replacement: it bounds the list chromatic number by `Δ+1`.

**Synthesis.**  `choosable_of_degree_lt` : `(∀ v, deg v < k) → Choosable G k`.
-/