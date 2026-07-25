import Mathlib

/-!
# The incidence-capacity obstruction for Hamilton covers

A *Hamilton cover* of a graph `G` is a family of two-regular spanning subgraphs
(disjoint unions of cycles, or in the connected case Hamilton cycles) whose union
contains every edge of `G`.  The central quantitative question about such covers is
their *size*: how few two-regular layers are needed to cover all edges?

This file isolates the **deterministic incidence-capacity obstruction** that
governs the lower bound.  Each two-regular layer contributes exactly `2` to the
degree of every vertex, so a vertex of degree `d` in `G` requires at least
`⌈d/2⌉` layers to accommodate its incident edges.  Taking the maximum over all
vertices gives the clean bound

    (number of layers) ≥ ⌈Δ(G) / 2⌉,

where `Δ(G)` is the maximum degree.  Written in natural-number arithmetic,
`⌈Δ/2⌉ = (Δ + 1) / 2`.

The obstruction is purely local and combinatorial — it makes no use of
randomness — yet it is exactly the quantity that the random-graph "optimal-cover
hitting time" conjecture predicts becomes achievable the moment the minimum
degree reaches two.  We also record the accompanying **local parity law**: at the
optimal layer count the per-vertex incidence slack is `Δ mod 2 ∈ {0, 1}`, the
"zero-or-one incidence defect" that any extension procedure must absorb.

## Main results

* `degree_le_two_mul_layers` — every vertex has `G.degree v ≤ 2 * k` for a
  `k`-layer two-regular cover.
* `maxDegree_le_two_mul_layers` — the maximum degree satisfies `Δ ≤ 2 * k`.
* `layers_ceil_lower_bound` — the incidence-capacity bound `⌈Δ/2⌉ ≤ k`.
* `optimal_incidence_defect` — the local parity law: `2 * ⌈Δ/2⌉ - Δ = Δ % 2`.
* `optimal_defect_le_one` — the incidence defect at the optimal count is `≤ 1`.
* `single_layer_cover_sharp` — sharpness: a single two-regular graph covers
  itself, meeting the bound with `Δ = 2`, `k = 1`.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the size of any two-regular (Hamilton) cover is
  bounded below by a purely local incidence count.  Conjecture: a `k`-layer
  cover forces `⌈Δ/2⌉ ≤ k`, and at `k = ⌈Δ/2⌉` the local excess is a `0/1`
  parity defect.
* Experiment (Experimenter): modelled a cover as `layers : Fin k → SimpleGraph V`
  with every layer two-regular and the union covering all edges of `G`.  The
  neighbourhood of `v` in `G` embeds into the union of the layer neighbourhoods,
  so `deg_G(v) ≤ Σ_i deg_{layers i}(v) = 2k` via `Finset.card_biUnion_le`.  The
  ceiling bound and parity law then follow by `omega`.
* Analysis (Analyst): the argument never uses connectivity or that the layers are
  single cycles — only two-regularity and coverage.  Hence the bound is the exact
  arithmetic capacity obstruction; any matching upper bound (the hard, global,
  random-graph direction) must realise this local target.  The parity law shows
  the only freedom at optimality is a single unit of slack at odd-degree vertices.
* Critique (Critic): we do NOT claim the hitting-time/achievability direction,
  which is genuinely probabilistic; we claim exactly the deterministic lower
  bound and its parity refinement, and we exhibit a sharp instance so the bound
  is not vacuous.  The hypotheses use `∃ i, (layers i).Adj v w` for coverage,
  which is precisely "every edge lies in some layer".
* Synthesis (PI): the incidence-capacity lower bound `⌈Δ/2⌉ ≤ k` plus the
  `Δ mod 2` parity defect together pin down the equality case, the exact content
  the random-graph conjectures build upon.
-/

open SimpleGraph Finset

namespace HamiltonCover

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- **Incidence-capacity bound, vertex form.**
If every edge of `G` lies in one of `k` two-regular layers, then every vertex has
degree at most `2 * k`: each layer can absorb only two incidences at each vertex. -/
theorem degree_le_two_mul_layers (G : SimpleGraph V) [DecidableRel G.Adj] {k : ℕ}
    (layers : Fin k → SimpleGraph V) [∀ i, DecidableRel (layers i).Adj]
    (hcov : ∀ v w, G.Adj v w → ∃ i, (layers i).Adj v w)
    (hreg : ∀ i v, (layers i).degree v = 2) (v : V) :
    G.degree v ≤ 2 * k := by
  have hsub : G.neighborFinset v ⊆ univ.biUnion (fun i => (layers i).neighborFinset v) := by
    intro w hw
    rw [mem_neighborFinset] at hw
    obtain ⟨i, hi⟩ := hcov v w hw
    simp only [mem_biUnion, mem_univ, true_and]
    exact ⟨i, by rw [mem_neighborFinset]; exact hi⟩
  calc G.degree v = (G.neighborFinset v).card := (G.card_neighborFinset_eq_degree v).symm
    _ ≤ (univ.biUnion (fun i => (layers i).neighborFinset v)).card := card_le_card hsub
    _ ≤ ∑ i : Fin k, ((layers i).neighborFinset v).card := card_biUnion_le
    _ = ∑ i : Fin k, (layers i).degree v := by
        refine Finset.sum_congr rfl (fun i _ => ?_)
        exact (layers i).card_neighborFinset_eq_degree v
    _ = ∑ _i : Fin k, 2 := Finset.sum_congr rfl (fun i _ => hreg i v)
    _ = 2 * k := by rw [Finset.sum_const]; simp [mul_comm]

/-- **Incidence-capacity bound, maximum-degree form.**
The maximum degree of a graph covered by `k` two-regular layers is at most `2k`. -/
theorem maxDegree_le_two_mul_layers (G : SimpleGraph V) [DecidableRel G.Adj] {k : ℕ}
    (layers : Fin k → SimpleGraph V) [∀ i, DecidableRel (layers i).Adj]
    (hcov : ∀ v w, G.Adj v w → ∃ i, (layers i).Adj v w)
    (hreg : ∀ i v, (layers i).degree v = 2) :
    G.maxDegree ≤ 2 * k := by
  rcases isEmpty_or_nonempty V with hV | hV
  · simp [SimpleGraph.maxDegree, Finset.univ_eq_empty]
  · obtain ⟨v, hv⟩ := G.exists_maximal_degree_vertex
    rw [hv]
    exact degree_le_two_mul_layers G layers hcov hreg v

/-- **The `⌈Δ/2⌉` lower bound on cover size.**
Any two-regular cover of `G` uses at least `⌈Δ(G)/2⌉ = (Δ + 1) / 2` layers.  This
is the sharp deterministic obstruction underlying the optimal-cover conjectures. -/
theorem layers_ceil_lower_bound (G : SimpleGraph V) [DecidableRel G.Adj] {k : ℕ}
    (layers : Fin k → SimpleGraph V) [∀ i, DecidableRel (layers i).Adj]
    (hcov : ∀ v w, G.Adj v w → ∃ i, (layers i).Adj v w)
    (hreg : ∀ i v, (layers i).degree v = 2) :
    (G.maxDegree + 1) / 2 ≤ k := by
  have h := maxDegree_le_two_mul_layers G layers hcov hreg
  omega

/-- **Local parity law at the optimal layer count.**
When the number of layers equals the optimum `⌈Δ/2⌉`, the incidence slack
`2 * (number of layers) − Δ` is exactly the parity `Δ mod 2`.  This is the
"zero-or-one incidence defect" that a completion procedure must absorb. -/
theorem optimal_incidence_defect (Δ : ℕ) :
    2 * ((Δ + 1) / 2) - Δ = Δ % 2 := by omega

/-- The optimal incidence defect is always `0` or `1`. -/
theorem optimal_defect_le_one (Δ : ℕ) : 2 * ((Δ + 1) / 2) - Δ ≤ 1 := by omega

/-- The defect vanishes exactly at even maximum degree. -/
theorem optimal_defect_zero_iff_even (Δ : ℕ) :
    2 * ((Δ + 1) / 2) - Δ = 0 ↔ Even Δ := by
  rw [optimal_incidence_defect, Nat.even_iff]

omit [DecidableEq V] in
/-- **Sharpness.**  A two-regular graph covers *itself* with a single layer,
so the bound `⌈Δ/2⌉ ≤ k` is attained: here `Δ = 2` and `k = 1`, and indeed
`⌈2/2⌉ = 1`.  Thus the incidence-capacity obstruction is not vacuous. -/
theorem single_layer_cover_sharp (G : SimpleGraph V) [DecidableRel G.Adj]
    (hreg : ∀ v, G.degree v = 2) (hne : Nonempty V) :
    (G.maxDegree + 1) / 2 = 1 ∧
      (∀ v w, G.Adj v w → ∃ i : Fin 1, (fun _ : Fin 1 => G) i |>.Adj v w) := by
  refine ⟨?_, fun v w h => ⟨0, h⟩⟩
  obtain ⟨v, hv⟩ := G.exists_maximal_degree_vertex
  rw [hv, hreg v]

end HamiltonCover