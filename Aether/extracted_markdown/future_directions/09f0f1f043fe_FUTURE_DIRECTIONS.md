# Future Directions — Neural Myhill–Nerode Quotients and Rips Filtrations

## Synthesis

This cycle constructed a working bridge between three previously disjoint corners of the
catalog: the coalgebraic Myhill–Nerode theory of neural observation systems
(`Bridges/CoalgebraicNeuralMyhillNerode.lean`), the Vietoris–Rips filtration machinery of
topological data analysis (`Applications/PoincareData/MetricFiltration.lean`), and the
metric/Lipschitz vocabulary of certified machine learning. The new file
`Catalog/Bridges/NeuralRipsInterleaving.lean` proves that observational behavior, restricted
to a finite observation budget `W`, defines a genuine **pseudometric** `behaviorDist` on the
state space — realized cleanly as the finite-product supremum metric *pulled back* along the
behavior embedding `s ↦ (fun w => neural_behavior N s w)` (`PseudoMetricSpace.induced`). The
decisive technical economy is that this reduces every global claim about filtrations to a
*per-context* ("stalk-level") inequality handled by `dist_pi_le_iff` and `dist_le_pi_dist`.

## Results summary

* **`behaviorDist` is a pseudometric** with the characterization
  `behaviorDist N W x y ≤ r ↔ ∀ w ∈ W, dist (neural_behavior N x w) (neural_behavior N y w) ≤ r`
  (`behaviorDist_le_iff`).
* **The Myhill–Nerode quotient relation descends**: zero behavior distance is exactly
  observational agreement on `W` (`behaviorDist_eq_zero_iff_agree`), the observation map
  descends (`behaviorDist_zero_observe`), and full behavioral equivalence collapses every
  budget metric (`behaviorDist_zero_of_equiv`).
* **Coalgebra morphisms are isometries** for `behaviorDist` (`behaviorDist_hom`).
* **Rips functoriality**: a reusable, domain-agnostic lemma `ripsGraph_hom_of_nonexpansive`
  (nonexpansive + injective ⟹ Rips-adjacency-preserving) specializes to
  `neural_ripsGraph_hom` and packages into the **filtration morphism**
  `neuralRipsFiltrationHom` (a graph homomorphism at every scale, same underlying map).
* **`2ε`-interleaving**: an `ε`-approximate simulation between two systems yields a `2ε`
  scale shift between their Rips filtrations (`behaviorDist_interleave`,
  `neural_rips_interleaving`).

All main results compile with `sorry = 0` and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research directions

### 1. From graph interleaving to a bottleneck stability theorem for π₀

The present `2ε`-interleaving lives at the level of single graphs and adjacency. The natural
next target is to lift it to the **persistence module of connected components** (`H₀`) of the
behavior Rips filtration and prove a hard stability bound: the bottleneck distance between the
π₀ persistence diagrams of two neural systems is at most `2ε` whenever their behaviors are
pointwise `ε`-close on the budget `W`. The key insight is that `neuralRipsFiltrationHom`
already supplies the two scale-shifted graph homomorphisms required by the algebraic
definition of an interleaving of persistence modules, so only the functor
`graph ↦ π₀ ↦ vector space` and the interleaving-implies-bottleneck inequality remain to be
formalized. Why now: the catalog's `BoltzmannBridge/Interleaving*.lean` files already contain
interleaving-to-bottleneck scaffolding for a different metric source, so this direction reuses
proven persistence infrastructure rather than building it from scratch — a falsifiable claim,
because a counterexample with bottleneck distance `> 2ε` would immediately refute it.

### 2. A universal property: the behavior quotient is the terminal nonexpansive compression

`behaviorDist_hom` shows morphisms are isometries and `behaviorDist_zero_of_equiv` shows the
Myhill–Nerode quotient refines every budget metric. This suggests the quotient
`MetricSpace` (mod `behaviorDist = 0`) is the **terminal object** among behavior-respecting
nonexpansive maps out of a fixed system: every such map factors uniquely and isometrically
through it. The key insight is that the catalog already proves *cardinality* minimality
(`neural_myhill_nerode_minimality`, `reachable_minimal_realization_cardinality_bound`), so the
metric universal property is the quantitative refinement of an established extensional fact.
Why now: with isometry of morphisms in hand, the only missing pieces are the quotient metric
instance and a factorization lemma; this is falsifiable because exhibiting two non-isometric
factorizations would break uniqueness.

### 3. Lipschitz transition operators and a contraction spectrum for robustness certificates

If the one-step transition `neural_derivative` is itself nonexpansive in an input metric, then
each symbol `a` acts as a `1`-Lipschitz endomorphism of `BehStates N W`, and iterating gives a
contraction/expansion exponent along input words. The key insight is that
`behaviorDist N W (step x a) (step y a) ≤ behaviorDist N W x y` should follow from the
right-congruence lemma `neural_equiv_step_invariant` upgraded to a quantitative
`behaviorDist`-contraction, turning behavioral equivalence into a *Lipschitz dynamical
system*. Why now: the catalog explicitly lists `lipschitz` and `robustness` as application
keywords and proves `cryptographic_neural_compression_preserves_certificates`, so a metric
contraction bound directly upgrades those qualitative certificates to quantitative
robustness radii. The conjecture is falsifiable: a transition that strictly expands
`behaviorDist` on a witnessed pair refutes the `1`-Lipschitz claim.

### 4. Budget monotonicity, directed colimits, and a local-to-global gluing theorem

`behaviorDist` is indexed by the observation budget `W`. Conjecture: it is **monotone** in
`W` (`W₁ ⊆ W₂ ⟹ behaviorDist N W₁ x y ≤ behaviorDist N W₂ x y`), the family forms a directed
system over the lattice of finite budgets, and its supremum/colimit is the full Myhill–Nerode
metric — so that *agreement on every finite budget glues to global behavioral equivalence*.
The key insight is that this is precisely a sheaf-style local-to-global statement whose
"sections agree locally ⟹ agree globally" step is exactly the catalog's
`finite_depth_refinement_stabilizes_sufficient`. Why now: monotonicity is a one-line
consequence of `dist_le_pi_dist` over the inclusion of index finsets, making the directed
colimit the first genuinely cohomological/limit-theoretic object reachable from this bridge.
It is falsifiable: a pair separated only at the colimit but at no finite budget would refute
the gluing claim.

### 5. A functor from neural systems to filtered graphs (and the obstruction to surjectivity)

The constructions assemble into a **functor** from the category of neural observation systems
with injective morphisms to the category of metric filtrations and filtration morphisms. The
key insight is that `neuralRipsFiltrationHom` is already functorial in the underlying map
(its naturality with `ripsGraph_mono` is definitional, recorded by
`neuralRipsFiltrationHom_underlying`), so identity- and composition-preservation are the only
laws left to verify. Why now: making this a literal `CategoryTheory.Functor` lets one ask the
sharp obstruction question — *which* filtration morphisms arise from neural morphisms — whose
answer is an obstruction class measuring the failure of a topological summary to be realized by
a coalgebra map. This is falsifiable: a filtration morphism provably not induced by any
injective neural morphism would pin down a nonzero obstruction.
