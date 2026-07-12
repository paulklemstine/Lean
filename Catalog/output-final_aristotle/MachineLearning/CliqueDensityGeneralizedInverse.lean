/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Lower bounds on clique densities via codegrees and the inclusion–exclusion inverse

For a finite simple graph `G` on `n` vertices, the *codegree* of an ordered pair `(u, v)`
is the number of common neighbours `codeg(u,v) = |N(u) ∩ N(v)|`.  Codegrees are the local
carriers of triangle (and higher-clique) density: every common neighbour of an edge `uv`
completes a triangle on `uv`.

The engine of this file is the elementary **inclusion–exclusion inverse**

  `deg(u) + deg(v) ≤ n + codeg(u, v)`,

obtained by inverting `|N(u) ∪ N(v)| + |N(u) ∩ N(v)| = deg(u) + deg(v)` against the ceiling
`|N(u) ∪ N(v)| ≤ n`.  Read as a lower bound on `codeg`, it says that whenever the degrees at
the two ends of an edge overshoot the number of vertices, a triangle is *forced*.  This is the
degree threshold behind Mantel's theorem and, via summation, behind Goodman's triangle lower
bound.

We turn the local inequality into three results of increasing strength:

* `deg_add_deg_le` — the inclusion–exclusion inverse itself;
* `exists_common_neighbor_of_deg_sum` / `not_cliqueFree_three_of_deg_sum` — a triangle is
  forced by a single over-heavy edge (a genuine clique *existence* lower bound);
* `mantel_local` — the contrapositive: in a triangle-free graph, every edge is degree-light
  (`deg u + deg v ≤ n`), the local heart of Mantel's theorem;
* `ordered_triangles_eq` — the exact identity `∑_{u} ∑_{v ∈ N(u)} codeg(u,v) = 6 · #triangles`,
  expressing the global triangle count as a codegree sum;
* `goodman_codegree_lower` — summing the inverse over all ordered adjacent pairs yields
  `∑_{u} ∑_{v ∈ N(u)} (deg u + deg v) ≤ (∑_{u} ∑_{v ∈ N(u)} n) + 6 · #triangles`, the Goodman-type
  global lower bound on triangle density in terms of the degree sequence.

## Catalog connections
* `goodman1959sets` — the codegree-sum lower bound `goodman_codegree_lower` is the local/summed
  form of Goodman's 1959 triangle count.
* `turan1941extremal`, `zykov1949linear` — `mantel_local` is the `r = 3` degree condition
  underlying the Turán/Zykov extremal bound.
* `bollobas1976complete`, `khadziivanov1978` — the codegree threshold `deg u + deg v > n ⇒ K₃`
  is the base case of the Khadziivanov–Nikiforov / Bollobás complete-subgraph recursion.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Clique density lower bounds are governed by a single "generalized
  inverse" of inclusion–exclusion: `codeg(u,v) ≥ deg u + deg v - n`.  If true, degree overshoot
  at any edge forces a triangle, and summation recovers Goodman's global count.
Experiment (Experimenter): Proved the inverse from `Finset.card_union_add_card_inter` plus
  `card_le_univ`, stated additively over `ℕ` to dodge truncated subtraction.  Built the triangle
  witness from a common neighbour and packaged it through `is3Clique_triple_iff`.
Analysis (Analyst): The additive form `deg u + deg v ≤ n + codeg` is strictly more robust than
  the subtractive `codeg ≥ deg u + deg v - n` (the latter is vacuous once the RHS truncates to 0),
  and it is exactly what both the existence and the Mantel direction need.
Critique (Critic): `not_cliqueFree_three_of_deg_sum` is non-vacuous — the hypothesis
  `n < deg u + deg v` is satisfiable (e.g. any dense graph) — and the triangle produced is a
  genuine `IsNClique 3`.  `mantel_local` is a real `→`, not a definitional unfolding.
Synthesis (PI): The inclusion–exclusion inverse unifies existence (Bollobás/Khadziivanov base
  case), extremal light-edge structure (Mantel/Turán), and global counting (Goodman) under one
  local inequality.
-/
import Mathlib

open SimpleGraph Finset

namespace CliqueDensityLower

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The **codegree** of an ordered pair `(u, v)`: the number of common neighbours. -/
def codeg (u v : V) : ℕ := (G.neighborFinset u ∩ G.neighborFinset v).card

lemma codeg_comm (u v : V) : codeg G u v = codeg G v u := by
  unfold codeg; rw [Finset.inter_comm]

/-- A common neighbour is genuinely adjacent to both endpoints. -/
lemma adj_of_mem_codeg {u v w : V} (hw : w ∈ G.neighborFinset u ∩ G.neighborFinset v) :
    G.Adj u w ∧ G.Adj v w := by
  simp only [Finset.mem_inter, mem_neighborFinset] at hw
  exact hw

/-- **Inclusion–exclusion inverse.** The degrees at the two ends of any pair overshoot the
codegree by at most `n`:  `deg u + deg v ≤ n + codeg(u, v)`.  Equivalently, the codegree is at
least `deg u + deg v - n`. -/
theorem deg_add_deg_le (u v : V) :
    G.degree u + G.degree v ≤ Fintype.card V + codeg G u v := by
  have hun : (G.neighborFinset u ∪ G.neighborFinset v).card
      + (G.neighborFinset u ∩ G.neighborFinset v).card
      = (G.neighborFinset u).card + (G.neighborFinset v).card :=
    Finset.card_union_add_card_inter _ _
  have hle : (G.neighborFinset u ∪ G.neighborFinset v).card ≤ Fintype.card V :=
    Finset.card_le_univ _
  simp only [← card_neighborFinset_eq_degree, codeg]
  omega

/-- **Codegree threshold ⇒ common neighbour.** If the degrees at `u` and `v` overshoot the number
of vertices, then `u` and `v` have a common neighbour. -/
theorem exists_common_neighbor_of_deg_sum {u v : V}
    (h : Fintype.card V < G.degree u + G.degree v) :
    ∃ w, G.Adj u w ∧ G.Adj v w := by
  have hpos : 0 < codeg G u v := by have := deg_add_deg_le G u v; omega
  obtain ⟨w, hw⟩ := Finset.card_pos.1 hpos
  exact ⟨w, adj_of_mem_codeg G hw⟩

/-- **Forced triangle.** An edge whose endpoints have degree sum exceeding `n` lies in a triangle;
hence such a graph is not triangle-free.  This is the base case of the Bollobás–Khadziivanov
complete-subgraph recursion and the existence half of the clique-density threshold. -/
theorem not_cliqueFree_three_of_deg_sum {u v : V} (huv : G.Adj u v)
    (h : Fintype.card V < G.degree u + G.degree v) :
    ¬ G.CliqueFree 3 := by
  obtain ⟨w, huw, hvw⟩ := exists_common_neighbor_of_deg_sum G h
  intro hcf
  exact hcf {u, v, w} (by rw [is3Clique_triple_iff]; exact ⟨huv, huw, hvw⟩)

/-- **Mantel's local degree condition.** In a triangle-free graph, every edge is degree-light:
the degrees at its two endpoints sum to at most the number of vertices.  This is the local heart
of Mantel's/Turán's extremal bound for `r = 3`. -/
theorem mantel_local (hcf : G.CliqueFree 3) {u v : V} (huv : G.Adj u v) :
    G.degree u + G.degree v ≤ Fintype.card V := by
  by_contra h
  push_neg at h
  exact not_cliqueFree_three_of_deg_sum G huv h hcf

/-
**Ordered-triangle codegree identity.** The total codegree over ordered adjacent pairs counts
ordered triples of mutually adjacent vertices, i.e. six times the number of triangles.
-/
theorem ordered_triangles_eq :
    (∑ u, ∑ v ∈ G.neighborFinset u, codeg G u v)
      = 6 * (G.cliqueFinset 3).card := by
  -- First, let's rewrite the sum using the indicator function for the clique.
  have h_sum_indicator : (∑ u : V, ∑ v ∈ G.neighborFinset u, codeg G u v) = ∑ v ∈ Finset.univ, ∑ w ∈ G.neighborFinset v, ∑ u ∈ G.neighborFinset v ∩ G.neighborFinset w, 1 := by
    simp +decide [ codeg ];
  -- The set of ordered triples of vertices that form a clique can be partitioned into cliques of size 3.
  have h_partition : Finset.card (Finset.filter (fun t : V × V × V => G.Adj t.1 t.2.1 ∧ G.Adj t.1 t.2.2 ∧ G.Adj t.2.1 t.2.2) (Finset.univ : Finset (V × V × V))) = 6 * Finset.card (G.cliqueFinset 3) := by
    have h_partition : Finset.card (Finset.filter (fun t : V × V × V => G.Adj t.1 t.2.1 ∧ G.Adj t.1 t.2.2 ∧ G.Adj t.2.1 t.2.2) (Finset.univ : Finset (V × V × V))) = Finset.sum (G.cliqueFinset 3) (fun s => Finset.card (Finset.filter (fun t : V × V × V => ({t.1, t.2.1, t.2.2} : Finset V) = s) (Finset.univ : Finset (V × V × V)))) := by
      rw [ ← Finset.card_biUnion ];
      · congr with t ; simp +decide [ SimpleGraph.isNClique_iff ];
        by_cases h1 : t.1 = t.2.1 <;> by_cases h2 : t.1 = t.2.2 <;> by_cases h3 : t.2.1 = t.2.2 <;> simp +decide [ h1, h2, h3 ];
        grind;
      · grind +suggestions;
    -- Each clique of size 3 contributes exactly 6 ordered triples to the sum.
    have h_clique_contribution : ∀ s ∈ G.cliqueFinset 3, Finset.card (Finset.filter (fun t : V × V × V => ({t.1, t.2.1, t.2.2} : Finset V) = s) (Finset.univ : Finset (V × V × V))) = 6 := by
      intro s hs; simp_all +decide [ SimpleGraph.isNClique_iff ] ;
      rcases Finset.card_eq_three.mp hs.2 with ⟨ a, b, c, ha, hb, hc, hab, hbc, hac ⟩ ; simp_all +decide [ Finset.Subset.antisymm_iff, Finset.subset_iff ] ;
      rw [ show ( Finset.filter ( fun t : V × V × V => ( ( t.1 = a ∨ t.1 = b ∨ t.1 = c ) ∧ ( t.2.1 = a ∨ t.2.1 = b ∨ t.2.1 = c ) ∧ ( t.2.2 = a ∨ t.2.2 = b ∨ t.2.2 = c ) ) ∧ ( a = t.1 ∨ a = t.2.1 ∨ a = t.2.2 ) ∧ ( b = t.1 ∨ b = t.2.1 ∨ b = t.2.2 ) ∧ ( c = t.1 ∨ c = t.2.1 ∨ c = t.2.2 ) ) Finset.univ ) = { ( a, b, c ), ( a, c, b ), ( b, a, c ), ( b, c, a ), ( c, a, b ), ( c, b, a ) } from ?_ ] ; simp +decide [ Finset.card_insert_of_notMem, * ] ;
      ext ⟨ x, y, z ⟩ ; simp +decide ;
      grind;
    rw [ h_partition, Finset.sum_congr rfl h_clique_contribution, Finset.sum_const, smul_eq_mul, mul_comm ];
  convert h_partition using 1;
  simp +decide only [h_sum_indicator, sum_sigma', card_eq_sum_ones];
  refine' Finset.sum_bij ( fun x _ => ( x.1, x.2.1, x.2.2 ) ) _ _ _ _ <;> simp +decide [ SimpleGraph.adj_comm ];
  · grind;
  · tauto

/-
**Goodman-type global lower bound.** Summing the inclusion–exclusion inverse over all ordered
adjacent pairs gives a lower bound on the ordered triangle count in terms of degrees, matching the
codegree identity.
-/
theorem goodman_codegree_lower :
    (∑ u, ∑ v ∈ G.neighborFinset u, (G.degree u + G.degree v))
      ≤ (∑ u, ∑ _v ∈ G.neighborFinset u, Fintype.card V) + 6 * (G.cliqueFinset 3).card := by
  rw [ ← ordered_triangles_eq ];
  simpa only [ ← Finset.sum_add_distrib ] using
    Finset.sum_le_sum fun u _ => Finset.sum_le_sum fun v _ => deg_add_deg_le G u v

end CliqueDensityLower