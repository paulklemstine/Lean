/-
# Strange Attractors as Algebraic Objects — IV. The Finite-Nerve Obstruction

This file is the **cross-domain bridge keystone** of the cycle.  It connects:

* the catalog's *quantum-contextuality nerve cohomology* — `CechContextuality.NerveGraph`
  with its first-cohomology rank `NerveGraph.cohomRank` (file
  `Catalog/Physics/CechContextualityCore.lean`), whose `H¹` is the **finitely
  generated** free abelian group `ℤ^{β₁}`; and
* the *dyadic solenoid invariant* `Dyadic = ℤ[1/2]` of file II, the first Čech
  cohomology of the doubling-map attractor, which is **not** finitely generated.

The synthesis is an honest no-go theorem: the cohomology of the solenoid can
*never* be the cohomology of a finite nerve graph.  This is the precise
algebraic-topological obstruction to modelling the Lorenz/solenoid attractor by
any *single* finite directed graph — one must pass to the inverse limit.

## Main results

* `nerveCohomology`                        — `H¹` of a finite nerve graph as `ℤ^{β₁}`.
* `nerveCohomology_fg`                      — it is finitely generated.
* `dyadic_not_addGroup_fg`                  — `ℤ[1/2]` is not finitely generated
  (subtype form of `Dyadic.not_fg`).
* `solenoid_not_finite_nerve_cohomology`    — **no finite nerve graph has `H¹`
  isomorphic to the solenoid's `H¹`.**

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The solenoid's cohomology is categorically out of
reach of finite nerves; an `AddEquiv` to any `ℤ^{β₁}` is impossible.
Experiment (Experimenter): Imported the catalog `NerveGraph.cohomRank` and the
file-II `Dyadic`.  `ℤ^{β₁}` is finitely generated (`inferInstance`); transported
finite generation across a hypothetical `AddEquiv` with `AddGroup.fg_of_surjective`,
landing a contradiction with `Dyadic.not_fg` via `AddGroup.fg_iff_addSubgroup_fg`.
Analysis (Analyst): The whole no-go is the *non-preservation* of finite
generation — a single algebraic invariant (`FG`) separates the finite-graph
world from the inverse-limit world.  "True, short once the FG plumbing is named."
Critique (Critic): Genuinely cross-domain (Physics nerve ↔ Applications dynamics)
and genuinely catalog-reusing (`CechContextuality.NerveGraph.cohomRank`,
`StrangeAttractors.Dyadic.not_fg`).  Not vacuous: the conclusion is a strong
negation quantified over *all* finite nerve graphs.
Synthesis (PI): "One finite graph is never enough" — exactly the mission's
inverse-limit thesis, certified.
-- !-- Lab Notes -- !--
-/
import Mathlib
import Catalog.Physics.CechContextualityCore
import Catalog.Applications.StrangeAttractors.DyadicSolenoid

namespace StrangeAttractors

open CechContextuality

/-- The first cohomology group `H¹` of a finite nerve graph, modelled as the
free abelian group `ℤ^{β₁}` of its cohomological rank. -/
abbrev nerveCohomology (G : NerveGraph) : Type := Fin G.cohomRank → ℤ

/-- The cohomology of a finite nerve graph is finitely generated. -/
theorem nerveCohomology_fg (G : NerveGraph) : AddGroup.FG (nerveCohomology G) :=
  inferInstance

/-- `ℤ[1/2]` is not finitely generated as an additive group (subtype form). -/
theorem dyadic_not_addGroup_fg : ¬ AddGroup.FG (Dyadic) := by
  rw [AddGroup.fg_iff_addSubgroup_fg]
  exact Dyadic.not_fg

/-- **The finite-nerve obstruction.**  No finite nerve graph has first cohomology
isomorphic to the dyadic solenoid's first cohomology `ℤ[1/2]`.  Hence the
solenoid/Lorenz-type attractor is not captured by any single finite directed
graph; the inverse limit is essential. -/
theorem solenoid_not_finite_nerve_cohomology (G : NerveGraph) :
    ¬ Nonempty (Dyadic ≃+ nerveCohomology G) := by
  rintro ⟨e⟩
  have hfgN : AddGroup.FG (nerveCohomology G) := nerveCohomology_fg G
  -- transport finite generation along the inverse equivalence
  have hfgD : AddGroup.FG (Dyadic) :=
    AddGroup.fg_of_surjective (f := e.symm.toAddMonoidHom) e.symm.surjective
  exact dyadic_not_addGroup_fg hfgD

end StrangeAttractors