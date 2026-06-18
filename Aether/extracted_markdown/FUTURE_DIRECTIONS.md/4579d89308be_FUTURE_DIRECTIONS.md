# Future Directions

Follow-up conjectures arising from `Catalog/Bridges/FunctorialThresholdComplex.lean`
("Functorial threshold complexes from tropical valuation objects via clique complexes of
sublevel graphs"). Each is stated to be **falsifiable** and **formalizable** in Lean 4
(Mathlib), and builds directly on the proved results
(`thresholdComplex_mono`, `ultra_reachable_iff`, `ultra_ball_isClique`,
`ultra_isosceles`, `sublevelGraph_inf`, `reachable_mono`).

## Conjecture 1 — Nerve/Euler collapse for ultrametric threshold complexes
For a **finite** ultrametric weight `w` on `V`, the threshold complex
`thresholdComplex w t` is a disjoint union of full simplices, one per connected component
of `sublevelGraph w t`. Consequently its combinatorial Euler characteristic
`∑_{s face, s ≠ ∅} (-1)^(|s|+1)` equals the number of components (each nonempty simplex
contributes `1`). **Testable form:** prove
`eulerChar (thresholdComplex w t) = (number of R_t-equivalence classes)`,
directly bridging to `Geometry/DiscreteGaussBonnet.lean`'s Euler-characteristic machinery.
A refutation would be any finite ultrametric whose threshold complex has a non-contractible
component.

## Conjecture 2 — Functor preserves arbitrary meets, and is a complete-lattice map
`sublevelGraph_inf` shows binary-meet preservation. Conjecture: for any nonempty family
`(tᵢ)` with an infimum, `sublevelGraph w (⨅ᵢ tᵢ) = ⨅ᵢ sublevelGraph w tᵢ` whenever the
order is a complete linear order (e.g. `ℝ` is not complete but `ℝ≥0∞`/`WithTop` is). Dually,
`sublevelGraph` does **not** preserve joins in general (edges appear strictly before the
sup of thresholds). **Testable form:** prove the meet version over `WithTop α` and exhibit a
3-point counterexample to the join version.

## Conjecture 3 — Isosceles rigidity characterizes ultrametricity
`ultra_isosceles` is one direction. Conjecture the **converse**: on a linear order, a
symmetric weight `w` with `w x x` minimal such that every triangle is isosceles-with-
longest-side-doubled (`w x y ≠ w x z → w y z = max (w x y) (w x z)`) satisfies the strong
triangle inequality, i.e. `IsUltraWeight w`. **Testable form:** prove
`(∀ x y z, w x y ≠ w x z → w y z = max (w x y) (w x z)) ∧ symm → IsUltraWeight w`.
This would upgrade `ultra_isosceles` to an iff and give a purely "triangle-local"
axiomatization of tropical valuations.

## Conjecture 4 — Persistence stability: bottleneck bound from ‖w − w'‖∞
For two weights `w, w'` with `sup_{x,y} |w x y − w' x y| ≤ δ`, the π₀-persistence
modules `t ↦ (components of sublevelGraph w t)` and for `w'` are `δ`-interleaved:
`reachable_mono` already gives one-sided shifts. **Testable form:** prove
`(sublevelGraph w t).Reachable x y → (sublevelGraph w' (t+δ)).Reachable x y`
and the symmetric statement, yielding an interleaving and hence a bottleneck-stability
theorem for the threshold filtration. This is the quantitative core promised by
`CategoricalTropicalUltrametric`'s "functorial bound transfer".

## Conjecture 5 — Clique number = ball cardinality in the ultrametric regime
For a finite ultrametric weight, the maximum clique size of `sublevelGraph w t` equals the
largest cardinality of a closed `t`-ball (by `ultra_ball_isClique` every ball is a clique,
and `ultra_connectedComponent_isClique` says components are exactly balls). **Testable
form:** prove `(sublevelGraph w t).cliqueNum = ⨆ c, (closedBall w c t).toFinset.card`.
A refutation would require a clique not contained in any single ball, which the
cluster-graph property forbids — so this is a sharp, decisive test of the §3 picture.
