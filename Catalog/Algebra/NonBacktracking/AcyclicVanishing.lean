import Algebra.NonBacktracking.CyclePositivity

/-!
# Forests have identically vanishing non-backtracking trace

`Algebra.NonBacktracking.CyclePositivity` shows that a cycle in `G` forces some positive
power of the Hashimoto matrix to have positive trace. Here we prove the converse
implication, completing the characterisation

`G.IsAcyclic ↔ ∀ n ≥ 1, trace (B ^ n) = 0`.

The mathematical content is that a *closed* non-backtracking walk cannot exist in a
forest. The proof turns a cyclic list of darts into an honest `SimpleGraph.Walk`; the
non-backtracking condition says exactly that consecutive edges of that walk differ, and
in an acyclic graph such a walk is a path (`SimpleGraph.IsAcyclic.isPath_iff_isChain`).
A closed path is trivial, so the walk has length `0`, contradicting `n ≥ 1`.

## Main results

* `Hashimoto.exists_walk_of_dartChain` — a composable list of darts is the dart list of a
  walk (the inverse construction to `SimpleGraph.Walk.darts`);
* `Hashimoto.isChain_ne_edges_of_isChain_nbAdj` — non-backtracking dart chains have
  chains of pairwise-consecutively-distinct edges;
* `Hashimoto.trace_hashimoto_pow_eq_zero_of_isAcyclic` — forests kill all positive
  powers of `B`;
* `Hashimoto.isAcyclic_iff_trace_hashimoto_pow_eq_zero` — the resulting characterisation;
* `Hashimoto.closedNBWalks_eq_empty_of_isAcyclic` — the combinatorial form: a forest has
  no rooted closed non-backtracking walk of positive length.
-/

open Finset SimpleGraph List

namespace Hashimoto

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

/-! ## Reconstructing a walk from its darts -/

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- **Darts to walks.** A list of darts in which consecutive darts are composable is the
dart list of a walk between the prescribed endpoints. This inverts
`SimpleGraph.Walk.darts`. -/
lemma exists_walk_of_dartChain :
    ∀ (c : List G.Dart) (a b : V),
      List.IsChain (fun d d' : G.Dart => d.toProd.2 = d'.toProd.1) c →
      (∀ d ∈ c.head?, d.toProd.1 = a) →
      (∀ d ∈ c.getLast?, d.toProd.2 = b) →
      (c = [] → a = b) →
      ∃ p : G.Walk a b, p.darts = c := by
  intro c
  induction c with
  | nil =>
      intro a b _ _ _ hab
      obtain rfl := hab rfl
      exact ⟨Walk.nil, rfl⟩
  | cons d t ih =>
      intro a b hchain hhead hlast _
      have ha : d.toProd.1 = a := hhead d (by simp)
      subst ha
      rw [List.isChain_cons] at hchain
      cases t with
      | nil =>
          have hb : d.toProd.2 = b := hlast d (by simp)
          subst hb
          exact ⟨Walk.cons d.adj Walk.nil, by simp⟩
      | cons d' t' =>
          have hcomp : d.toProd.2 = d'.toProd.1 := hchain.1 d' (by simp)
          obtain ⟨p, hp⟩ := ih d.toProd.2 b hchain.2
            (by intro x hx; simp only [List.head?_cons, Option.mem_def,
                  Option.some.injEq] at hx; subst hx; exact hcomp.symm)
            (by
              intro x hx
              refine hlast x ?_
              rwa [List.getLast?_cons_cons])
            (by simp)
          exact ⟨Walk.cons d.adj p, by simp [hp]⟩

/-! ## Non-backtracking means consecutive edges differ -/

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Non-backtracking adjacent darts have different underlying edges. -/
lemma edge_ne_of_nbAdj {d d' : G.Dart} (h : NBAdj G d d') : d.edge ≠ d'.edge := by
  intro he
  rw [SimpleGraph.Dart.edge, SimpleGraph.Dart.edge, Sym2.eq_iff] at he
  rcases he with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact d.adj.ne (by rw [h1, ← h.1])
  · exact h.2 h1.symm

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- A non-backtracking chain of darts induces a chain of consecutively distinct edges. -/
lemma isChain_ne_edges_of_isChain_nbAdj {c : List G.Dart} (h : List.IsChain (NBAdj G) c) :
    List.IsChain (· ≠ ·) (c.map (fun d => d.edge)) := by
  induction c with
  | nil => simp
  | cons d t ih =>
      rw [List.isChain_cons] at h
      rw [List.map_cons, List.isChain_cons]
      refine ⟨?_, ih h.2⟩
      intro y hy
      rw [List.head?_map, Option.mem_def, Option.map_eq_some_iff] at hy
      obtain ⟨d', hd', rfl⟩ := hy
      exact edge_ne_of_nbAdj (h.1 d' hd')

/-! ## Vanishing of the trace on forests -/

/-- **From cyclic dart words to closed walks.** A cyclically non-backtracking word of `n`
darts is the dart list of a closed walk of length `n` whose consecutive edges differ. -/
lemma exists_closed_walk_of_mem_nbCycles {n : ℕ} (hn : 1 ≤ n) {c : List G.Dart}
    (hc : c ∈ nbCycles G n) :
    ∃ (v : V) (p : G.Walk v v), p.length = n ∧ List.IsChain (· ≠ ·) p.edges := by
  obtain ⟨hlen, hchain, hseam⟩ := (mem_nbCycles hn).1 hc
  have hne : c ≠ [] := by
    intro h
    rw [h] at hlen
    simp at hlen
    omega
  obtain ⟨d₀, hd₀⟩ : ∃ d, c.head? = some d := by
    cases c with
    | nil => exact absurd rfl hne
    | cons x t => exact ⟨x, rfl⟩
  obtain ⟨dl, hdl⟩ : ∃ d, c.getLast? = some d := by
    cases hcl : c.getLast? with
    | none => exact absurd (List.getLast?_eq_none_iff.1 hcl) hne
    | some d => exact ⟨d, rfl⟩
  have hclose : dl.toProd.2 = d₀.toProd.1 := (hseam dl hdl d₀ hd₀).1
  obtain ⟨p, hp⟩ := exists_walk_of_dartChain (G := G) c d₀.toProd.1 d₀.toProd.1
    (hchain.imp fun _ _ h => h.1)
    (by intro x hx; rw [hd₀] at hx; simp only [Option.mem_def, Option.some.injEq] at hx;
        rw [← hx])
    (by intro x hx; rw [hdl] at hx; simp only [Option.mem_def, Option.some.injEq] at hx;
        rw [← hx]; exact hclose)
    (fun h => absurd h hne)
  refine ⟨d₀.toProd.1, p, ?_, ?_⟩
  · rw [← hlen, ← hp, p.length_darts]
  · rw [show p.edges = p.darts.map (fun d => d.edge) from rfl, hp]
    exact isChain_ne_edges_of_isChain_nbAdj hchain

/-- **Forests have no closed non-backtracking walks.** If `G` is acyclic then every
positive power of its Hashimoto matrix has zero trace. -/
theorem trace_hashimoto_pow_eq_zero_of_isAcyclic (hG : G.IsAcyclic) {n : ℕ} (hn : 1 ≤ n) :
    (hashimoto G ^ n).trace = 0 := by
  rw [trace_hashimoto_pow_eq_card_nbCycles G hn, Finset.card_eq_zero,
    Finset.eq_empty_iff_forall_notMem]
  intro c hc
  obtain ⟨v, p, hlen, hedges⟩ := exists_closed_walk_of_mem_nbCycles hn hc
  have hnil : p = Walk.nil := (Walk.isPath_iff_eq_nil p).1 ((hG.isPath_iff_isChain p).2 hedges)
  rw [hnil] at hlen
  simp only [Walk.length_nil] at hlen
  omega

/-- **The non-backtracking trace sequence detects cycles exactly.** A finite simple graph
is a forest if and only if every positive power of its Hashimoto matrix has zero trace,
i.e. iff it has no rooted closed non-backtracking walk of positive length. -/
theorem isAcyclic_iff_trace_hashimoto_pow_eq_zero :
    G.IsAcyclic ↔ ∀ n : ℕ, 1 ≤ n → (hashimoto G ^ n).trace = 0 :=
  ⟨fun hG _ hn => trace_hashimoto_pow_eq_zero_of_isAcyclic hG hn, isAcyclic_of_trace_eq_zero⟩

/-- Combinatorial form: a forest has no rooted closed non-backtracking walk of positive
length. -/
theorem closedNBWalks_eq_empty_of_isAcyclic (hG : G.IsAcyclic) {n : ℕ} (hn : 1 ≤ n) :
    closedNBWalks G n = ∅ := by
  rw [← Finset.card_eq_zero, ← trace_hashimoto_pow]
  exact trace_hashimoto_pow_eq_zero_of_isAcyclic hG hn

end Hashimoto