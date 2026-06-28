import Applications.StarRamsey.Threshold

/-!
# Graph-level consequences of the exact star–Ramsey threshold

Using the sharp local dichotomy from `Threshold.lean`, we obtain the **forcing direction** of
the star–Ramsey theorem for arbitrary finite simple graphs, together with the explicit
complete-graph threshold.

* `StarRamsey.Graph.hasMonoStar_of_degree` — if some vertex of `G` has degree exceeding
  `∑ (t j - 1)`, then *every* `q`-edge-colouring of `G` contains a monochromatic star
  `K_{1,t j}`.
* `StarRamsey.Graph.completeGraph_hasMonoStar` — the complete graph `K_N` forces a
  monochromatic star as soon as `N ≥ (∑ (t j - 1)) + 2`.

The edge-colouring is modelled as a total function `col : Sym2 V → Fin q`; only its values on
genuine edges matter.  A monochromatic star at `v` in colour `j` is recorded by `starDeg`, the
number of `j`-coloured edges incident to `v`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The local threshold transfers to graphs with the maximum degree
playing the role of `#E`.  Forcing should hold the instant ONE vertex is over capacity; the
matching converse (a global colouring avoiding all stars when the max degree is under capacity)
should be strictly harder because edges are shared between two endpoints.

Experiment (Experimenter): `hasMonoStar_of_degree` follows by rewriting `G.degree v` as the
incident-edge count and invoking `StarRamsey.forcingF` on `G.neighborFinset v` with the
restricted colouring `w ↦ col s(v,w)`.  The complete-graph corollary plugs in
`SimpleGraph.complete_graph_degree : (completeGraph V).degree v = card V - 1` and finishes with
`omega`.  Both `sorry`-free.

Analysis (Analyst): The forcing side is purely local and needs no structure on `G`.  The
*converse* — global avoidance below capacity — is NOT proved here: it is equivalent to an
edge-decomposition of `G` into colour classes of bounded maximum degree (a de Werra / balanced
edge-colouring statement), which genuinely uses the global structure of the host and is exactly
where the `s`-connector parameter and the `max_j t_j` correction of the original conjecture
enter.  This mirrors `AFLMatching/Bounds.lean`, where the *local/greedy* matching bound is
clean but the global AFL constant requires extra structure.

Critique (Critic): `completeGraph_hasMonoStar` takes a witness vertex `v : Fin N`; the bound
`(∑ (t j - 1)) + 2 ≤ N` already forces `N ≥ 2`, so a vertex exists, but we keep `v` explicit to
avoid a vacuous `Nonempty (Fin N)` side-goal and to keep the statement constructive.

Synthesis (PI): The forcing half of the star–Ramsey theorem, fully verified at the level of
arbitrary finite graphs and specialised to `K_N`, with the global converse precisely isolated
as the remaining (structure-dependent) ingredient.
-/

open Finset

namespace StarRamsey.Graph

variable {V : Type*} [Fintype V] [DecidableEq V] {q : ℕ}

/-- Local count of colour-`j` edges incident to `v` in graph `G` under edge-colouring `col`. -/
def starDeg (G : SimpleGraph V) [DecidableRel G.Adj] (col : Sym2 V → Fin q)
    (v : V) (j : Fin q) : ℕ :=
  ((G.neighborFinset v).filter (fun w => col s(v, w) = j)).card

/-- `G` contains a monochromatic star `K_{1,t j}` under colouring `col`: some vertex has at
least `t j` incident edges of some colour `j`. -/
def HasMonoStar (G : SimpleGraph V) [DecidableRel G.Adj] (col : Sym2 V → Fin q)
    (t : Fin q → ℕ) : Prop :=
  ∃ v j, t j ≤ starDeg G col v j

/-- **Graph star forcing.** If some vertex of `G` has degree exceeding `∑ (t j - 1)`, then
every edge-colouring of `G` contains a monochromatic star `K_{1,t j}`. -/
theorem hasMonoStar_of_degree (G : SimpleGraph V) [DecidableRel G.Adj]
    (t : Fin q → ℕ) (col : Sym2 V → Fin q) (v : V)
    (hdeg : (∑ j, (t j - 1)) + 1 ≤ G.degree v) :
    HasMonoStar G col t := by
  have hd : G.degree v = (G.neighborFinset v).card :=
    (SimpleGraph.card_neighborFinset_eq_degree G v).symm
  rw [hd] at hdeg
  obtain ⟨j, hj⟩ := StarRamsey.forcingF (G.neighborFinset v) t (fun w => col s(v, w)) hdeg
  exact ⟨v, j, hj⟩

/-- **Complete-graph star forcing.** On the complete graph `K_N`, if
`N ≥ (∑ (t j - 1)) + 2` then every `q`-edge-colouring contains a monochromatic star. -/
theorem completeGraph_hasMonoStar (N : ℕ) (t : Fin q → ℕ)
    (col : Sym2 (Fin N) → Fin q)
    (hN : (∑ j, (t j - 1)) + 2 ≤ N) (v : Fin N) :
    HasMonoStar (SimpleGraph.completeGraph (Fin N)) col t := by
  apply hasMonoStar_of_degree _ t col v
  rw [SimpleGraph.complete_graph_degree, Fintype.card_fin]
  omega

end StarRamsey.Graph