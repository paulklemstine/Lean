import Catalog.Combinatorics.ForcingEdges.Basic

/-!
# Bicritical graphs and forcing edges

The paper's objects of study are **bricks**: `3`-connected, bicritical,
non-bipartite graphs.  This file isolates the *bicriticality* half of that
definition inside the involution model of `ForcingEdges.Basic` and records how it
interacts with forcing edges.

A graph `G` is **bicritical** when, for every pair of distinct vertices `u, v`,
the graph `G - u - v` has a perfect matching.  In the involution model this is
exactly the existence of an `IsPMdel G u v` witness for every `u ≠ v`.

The key consequence is a sharpening of the deletion characterisation of forcing
edges (`forcing_iff_unique_deletion`): in a bicritical graph *existence* of the
deleted matching is automatic, so an edge is forcing **iff** the deleted matching
is unique.

## Main results

* `Bicritical` — bicriticality in the involution model.
* `Bicritical.exists_pmdel` — the defining existence statement, unpacked.
* `bicritical_forcing_iff_unique_pmdel` — **main theorem**: in a bicritical graph,
  `uv` is forcing iff `uv` is an edge and any two perfect matchings of `G - u - v`
  coincide.
* `not_bicritical_of_forcing_isolating` — an obstruction: if deleting the two
  endpoints of *some* edge leaves *no* perfect matching, the graph is not
  bicritical (used to certify that small cycles are not bricks).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For the class of graphs the paper actually cares about
(bricks, which are bicritical), the deletion characterisation of forcing should
collapse from "`∃!` deleted matching" to plain "the deleted matching is unique",
because bicriticality hands us existence for free.

Experiment (Experimenter): We phrase bicriticality as `∀ u v, u ≠ v → ∃ h,
IsPMdel G u v h`, reusing the deletion predicate from `Basic`. Feeding the free
existence witness into `forcing_iff_unique_deletion` should turn the `ExistsUnique`
into a bare uniqueness clause.

Analysis (Analyst): The forward direction is immediate from the main theorem; the
reverse direction needs the bicritical existence witness to rebuild the `∃!`.
Uniqueness of the deleted matching is the genuine content — exactly the invariant
the paper tracks along b-invariant edges.

Critique (Critic): We must not silently assume the deleted graph is nonempty of
matchings on the forward direction — it is, but only because `Forcing` already
packages a matching through `uv`. The obstruction lemma
`not_bicritical_of_forcing_isolating` keeps the definition honest by exhibiting
how bicriticality can fail.

Synthesis (PI): Together with `Basic`, this gives the bicritical specialisation of
the forcing-edge calculus, the exact setting in which the paper's classification
of b-invariant forcing edges lives.
-- !-- Lab Notes -- !--
-/

namespace ForcingEdges

open Function

variable {V : Type*}

/-- `G` is **bicritical**: for every pair of distinct vertices `u, v`, the graph
`G - u - v` has a perfect matching (an `IsPMdel G u v` witness). -/
def Bicritical (G : SimpleGraph V) : Prop :=
  ∀ u v : V, u ≠ v → ∃ h, IsPMdel G u v h

theorem Bicritical.exists_pmdel {G : SimpleGraph V} (hG : Bicritical G) {u v : V}
    (hne : u ≠ v) : ∃ h, IsPMdel G u v h :=
  hG u v hne

/--
**Bicritical specialisation of the deletion characterisation.**
In a bicritical graph the existence of a perfect matching of `G - u - v` is
automatic, so the edge `uv` is forcing precisely when that deleted matching is
*unique*.
-/
theorem bicritical_forcing_iff_unique_pmdel [DecidableEq V] {G : SimpleGraph V}
    (hG : Bicritical G) (u v : V) :
    Forcing G u v ↔
      G.Adj u v ∧ ∀ h₁ h₂, IsPMdel G u v h₁ → IsPMdel G u v h₂ → h₁ = h₂ := by
  rw [forcing_iff_unique_deletion]
  constructor
  · rintro ⟨hadj, h₀, hpm₀, huniq⟩
    exact ⟨hadj, fun h₁ h₂ hh₁ hh₂ => (huniq h₁ hh₁).trans (huniq h₂ hh₂).symm⟩
  · rintro ⟨hadj, huniq⟩
    obtain ⟨h₀, hh₀⟩ := hG.exists_pmdel hadj.ne
    exact ⟨hadj, h₀, hh₀, fun h hh => huniq h h₀ hh hh₀⟩

/--
**Obstruction to bicriticality.**  If deleting the endpoints of some edge leaves a
graph with *no* perfect matching, then `G` is not bicritical.  (This is how one
certifies that graphs such as the `4`-cycle are not bricks.)
-/
theorem not_bicritical_of_forcing_isolating {G : SimpleGraph V} {u v : V}
    (hne : u ≠ v) (hno : ¬ ∃ h, IsPMdel G u v h) : ¬ Bicritical G := by
  intro hG
  exact hno (hG.exists_pmdel hne)

end ForcingEdges