import Mathlib
import Bridges.CombinatorialBridge

/-!
# The forbidden induced subgraph `3K₂` and its complement `\overline{3K₂}`

This file formalises the two graphs at the heart of the characterisation of
*balanced distance-hereditary graphs*:

* `matching3` : the graph `3K₂`, three pairwise disjoint edges on six vertices
  (a perfect matching on `Fin 6`);
* `coMatching3` : its complement `\overline{3K₂}`, which is the octahedron, the
  complete tripartite graph `K_{2,2,2}` (a.k.a. the cocktail-party graph).

For the class of distance-hereditary graphs, being *balanced* is equivalent to
being `\overline{3K₂}`-free.  Understanding the structure of the single forbidden
graph `\overline{3K₂}` is therefore the geometric core of that theorem, and it is
what we develop rigorously here.

## Main results

* `coMatching3_adj_iff` — adjacency description of `\overline{3K₂}`: two vertices
  are adjacent iff they are distinct and lie in different matched pairs.
* `octahedronIso` — `\overline{3K₂}` is isomorphic to the complete tripartite
  graph `K_{2,2,2} = completeMultipartiteGraph (fun _ : Fin 3 => Fin 2)`.
* `coMatching3_regular` / `matching3_regular` — degree structure: `\overline{3K₂}`
  is `4`-regular, `3K₂` is `1`-regular.
* `coMatching3_nonadj_unique` — each vertex of `\overline{3K₂}` has a *unique*
  non-neighbour (its matched partner); this is the key metric rigidity used to
  prove `P₄`-freeness in `CographObstruction.lean`.
* `coMatching3_independent_card_le` — the independence number of `\overline{3K₂}`
  is at most `2`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The complement of a perfect matching on 6 vertices is
a highly symmetric graph; we conjectured it is exactly the octahedron `K_{2,2,2}`,
is `4`-regular, and — crucially — every vertex has a *unique* non-neighbour.

Experiment (Experimenter): We defined `3K₂` by `Adj i j ↔ i ≠ j ∧ i/2 = j/2`
(matched pairs `{0,1},{2,3},{4,5}`) and computed degrees and non-neighbour sets
over `Fin 6`.  Small-case evaluation confirmed `\overline{3K₂}` is `4`-regular and
that each vertex misses exactly one other vertex.

Analysis (Analyst): The "unique non-neighbour" property is the engine of the whole
theory: two non-neighbours of a fixed vertex must coincide.  This is precisely why
`\overline{3K₂}` contains no induced `P₄` (proved in the companion file) and hence
sits inside the distance-hereditary class as a genuine obstruction to balancedness.

Critique (Critic): We avoided stating the metric definition of "balanced" here to
keep every claim faithful and fully proved; balancedness is treated as the research
context (see `FUTURE_DIRECTIONS.md`).  The octahedron isomorphism is a real graph
isomorphism (not a definitional rename): `map_rel_iff'` genuinely matches two
different adjacency relations.

Synthesis: `\overline{3K₂} = K_{2,2,2}` is a `4`-regular octahedron in which every
vertex has a unique non-neighbour; these facts pin down its induced-subgraph
structure.
-/

open SimpleGraph

namespace BalancedDistanceHereditary

/-- `3K₂`: three pairwise disjoint edges on `Fin 6`, i.e. the perfect matching
whose edges are the pairs `{0,1}`, `{2,3}`, `{4,5}`.  Two vertices are adjacent iff
they are distinct and share the same "pair index" `i / 2`. -/
def matching3 : SimpleGraph (Fin 6) where
  Adj i j := i ≠ j ∧ i.val / 2 = j.val / 2
  symm := by intro i j ⟨h1, h2⟩; exact ⟨h1.symm, h2.symm⟩
  loopless := ⟨fun i h => h.1 rfl⟩

instance : DecidableRel matching3.Adj := fun i j => by unfold matching3; infer_instance

/-- `\overline{3K₂}`: the complement of `3K₂`, i.e. the octahedron / cocktail-party
graph `K_{2,2,2}`. -/
def coMatching3 : SimpleGraph (Fin 6) := matching3ᶜ

instance : DecidableRel coMatching3.Adj := fun i j => by unfold coMatching3; infer_instance

/-- Adjacency in `3K₂`. -/
@[simp] lemma matching3_adj_iff (i j : Fin 6) :
    matching3.Adj i j ↔ (i ≠ j ∧ i.val / 2 = j.val / 2) := Iff.rfl

/-- Adjacency in `\overline{3K₂}`: two distinct vertices are adjacent iff they lie
in different matched pairs. -/
lemma coMatching3_adj_iff (i j : Fin 6) :
    coMatching3.Adj i j ↔ (i ≠ j ∧ i.val / 2 ≠ j.val / 2) := by
  unfold coMatching3
  rw [compl_adj, matching3_adj_iff]
  constructor
  · rintro ⟨hne, hnadj⟩; exact ⟨hne, fun h => hnadj ⟨hne, h⟩⟩
  · rintro ⟨hne, hdiff⟩; exact ⟨hne, fun h => hdiff h.2⟩

/-- The equivalence `Fin 6 ≃ Σ _ : Fin 3, Fin 2` realising each vertex as
`(pair index, position within pair)`. -/
def vertexEquiv : Fin 6 ≃ (Σ _ : Fin 3, Fin 2) :=
  finProdFinEquiv.symm.trans (Equiv.sigmaEquivProd (Fin 3) (Fin 2)).symm

/-- **The octahedron identity.**  `\overline{3K₂}` is isomorphic to the complete
tripartite graph `K_{2,2,2}`.  This exhibits the forbidden graph as the complete
multipartite graph with three parts of size two. -/
noncomputable def octahedronIso :
    coMatching3 ≃g completeMultipartiteGraph (fun _ : Fin 3 => Fin 2) where
  toEquiv := vertexEquiv
  map_rel_iff' := by
    intro a b
    fin_cases a <;> fin_cases b <;> decide

/-- `\overline{3K₂}` is `4`-regular. -/
lemma coMatching3_regular : coMatching3.IsRegularOfDegree 4 := by
  intro v; fin_cases v <;> decide

/-- `3K₂` is `1`-regular (a perfect matching). -/
lemma matching3_regular : matching3.IsRegularOfDegree 1 := by
  intro v; fin_cases v <;> decide

/-- **Unique non-neighbour.**  In `\overline{3K₂}`, any two vertices that are both
non-adjacent (and unequal) to a fixed vertex `a` must coincide: every vertex has a
*unique* non-neighbour, namely its matched partner.  This metric rigidity is what
forces `P₄`-freeness. -/
lemma coMatching3_nonadj_unique :
    ∀ a c d : Fin 6, ¬ coMatching3.Adj a c → ¬ coMatching3.Adj a d →
      a ≠ c → a ≠ d → c = d := by decide

/-- **Independence number ≤ 2.**  Any set of pairwise non-adjacent vertices of
`\overline{3K₂}` has at most two elements (it must be contained in a single matched
pair).  Proof uses `CombinatorialBridge.subset_card_le`. -/
theorem coMatching3_independent_card_le (s : Finset (Fin 6))
    (hs : ∀ i ∈ s, ∀ j ∈ s, i ≠ j → ¬ coMatching3.Adj i j) :
    s.card ≤ 2 := by
  rcases s.eq_empty_or_nonempty with h | ⟨a, ha⟩
  · subst h; simp
  · -- every vertex of `s` lies in the matched pair of `a`
    have hsub : s ⊆ Finset.univ.filter (fun x : Fin 6 => x.val / 2 = a.val / 2) := by
      intro j hj
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      by_cases hja : j = a
      · subst hja; rfl
      · have := hs a ha j hj (fun h => hja h.symm)
        rw [coMatching3_adj_iff] at this
        push_neg at this
        exact (this (fun h => hja (h ▸ rfl))).symm
    calc s.card
        ≤ (Finset.univ.filter (fun x : Fin 6 => x.val / 2 = a.val / 2)).card :=
          CombinatorialBridge.subset_card_le hsub
      _ ≤ 2 := by fin_cases a <;> decide

end BalancedDistanceHereditary