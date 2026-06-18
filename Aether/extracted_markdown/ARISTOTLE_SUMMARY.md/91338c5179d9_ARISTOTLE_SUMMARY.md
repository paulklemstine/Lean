# Summary of changes for run e599bc9b-61b8-4aa5-974d-dead748a515d
Completed the research cycle "The Borsuk–Ulam Theorem and Arrow-Style Impossibility: Social Choice Is Topology" with two compiling, sorry-free Lean 4 files plus a future-directions document, all under `Catalog/Computation/`.

## Deliverables

**`Catalog/Computation/BorsukUlamArrow.lean`** (cross-domain bridge file)
- `IsCircleFn` — models a continuous map S¹ → ℝ as a continuous, 2π-periodic real function, with antipode θ ↦ θ+π.
- `borsuk_ulam_one_dim` — the 1-D Borsuk–Ulam theorem (every continuous circle function has an antipodal coincidence f θ = f(θ+π)), proved honestly from the Intermediate Value Theorem.
- `no_continuous_decisive_swf` — the topological Arrow-style impossibility: no continuous, reversal-respecting (`swf(θ+π) = -swf θ`), decisive (`swf θ ≠ 0`) social welfare function exists.
- `reversal_axiom_satisfiable` — non-vacuity witness (`sin`).
- `borsuk_ulam_arrow_bridge` — the mandated two-domain bridge theorem: it combines `zmod_add_free` from the **Computation/Impossibility** catalog file (the antipodal ZMod 2 action is fixed-point free) with the IVT-built coincidence imported from the **Bridges/IntermediateValueBridge** file, exhibiting the forced social tie as the analytic shadow of an algebraically free involution.

**`Catalog/Computation/BorsukUlamArrowDichotomy.lean`** (companion)
- `socialWave θ = (-1)^⌊θ/π⌋` with periodicity, reversal, and decisiveness lemmas.
- `decisive_reversal_swf_exists` — dropping continuity restores a decisive reversal-respecting rule, showing the obstruction is purely topological.
- `socialWave_not_continuous` — the explicit "antipodal majority" is provably discontinuous, the discontinuity being *derived from* the impossibility theorem (no ε–δ argument).
- `swf_dichotomy` — every reversal-respecting rule is either not a continuous circle function or has a social tie.
- `tie_set_antipodal` — the tie set is antipode-stable.

**`Catalog/Computation/FUTURE_DIRECTIONS.md`** — five falsifiable conjectures derived from the cycle (full higher-dimensional Borsuk–Ulam, uniqueness of the obstructed axiom, structure of the tie set, equivariant S¹→S⁰ reformulation, Chichilnisky connectivity threshold), each with a "The key insight is…" sentence and a "Why now?" justification.

## Findings (honest scope)
The grandiose claim that Arrow's full (discrete) theorem is literally Borsuk–Ulam is false as stated — discrete Arrow is combinatorial. What is genuinely true and now formalized is the *continuous* impossibility: the Borsuk–Ulam method really does rule out continuous decisive antipode-reversing social rules, and continuity is the single load-bearing axiom (relaxing it yields the explicit square-wave model). Both files build cleanly; every main theorem is sorry-free and uses only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`). Each file contains the required Lab Notes blocks documenting the Hypothesize/Experiment/Analyze/Critique/Synthesize loop.

Note: a pre-existing unrelated broken reference in `Algebra/UltrametricCondNeg.lean` (it imports a missing `Algebra/SpectralNovelty/CutMetric.lean`) prevents a whole-project default build, but it is independent of this work; the two new modules build successfully on their own.