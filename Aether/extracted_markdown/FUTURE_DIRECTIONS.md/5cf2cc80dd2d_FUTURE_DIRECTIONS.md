# Future Directions

Follow-up conjectures arising from `Catalog/Bridges/ValuationDepthTropicalFunctor.lean`
(the 1-Lipschitz functor `depthTropObj`/`depthTropFunctor` from valuation-depth measures
`DepthCarrier` into tropical valuation objects `TropObj`, with the unit-cost laws
`depth (x ⊕ y) ≤ max (depth x) (depth y) + 1`).

Each conjecture is stated so that it can be made a precise Lean theorem (or disproved by
an explicit `DepthCarrier` witness) in a follow-up cycle.

## C1. Sharp unbalanced-tree bound (height is the *only* cost)
For every `DepthCarrier X` and every `t : OpTree X.K`,
`depth (t.eval X.add) ≤ maxLeafDepth depth t + ⌈log₂ (numLeaves t)⌉` is **false in general**
for unbalanced trees, but the *optimal reassociation* of the same multiset of leaves
satisfies it. Conjecture: there is a rebalancing operator `rebalance : OpTree K → OpTree K`
preserving `eval X.add` up to depth and achieving `height (rebalance t) = ⌈log₂ (numLeaves t)⌉`,
giving `depth (t.eval X.add) ≤ maxLeafDepth depth t + ⌈log₂ (numLeaves t)⌉` whenever `X.add`
is associative and commutative on depth values. Testable: prove or find an associative
`DepthCarrier` where no reassociation beats the height bound.

## C2. The unit cost is the unique Lipschitz constant of the bridge
Conjecture: among all constants `c : ℕ`, the law `depth (x ⊕ y) ≤ max (depth x) (depth y) + c`
holds for *every* `ValuationDepthMeasure`-derived carrier iff `c ≥ 1`, and `c = 1` is
attained (`witnessCarrier`). Formalize "the Lipschitz constant of `depthTropFunctor` equals 1"
and prove `c = 0` is refuted exactly by `not_strict_ultrametric_witness`. This pins the
functor's constant intrinsically rather than by construction.

## C3. Idempotent completion / strictification
Conjecture: every `DepthCarrier X` admits a universal *strict* (idempotent, `≤ max`) quotient
`Strictify X` with a 1-Lipschitz comparison map `X → Strictify X` that is initial among
morphisms to strict carriers (`IsStrict`). Equivalently, the inclusion of strict carriers
into all depth carriers has a left adjoint. Testable: construct `Strictify` (e.g. collapse
the `+1` slack by saturating depth under `add`) and prove the universal property, or exhibit
an `X` with no strict reflection.

## C4. Composition depth = max, not sum (UltrametricCompositionLaw functoriality)
The source file's `UltrametricCompositionLaw` posits `vdepth (f ∘ g) ≤ max + 1`. Conjecture:
the combination-tree theorem `depth_eval_add_le` has a *compositional* analogue: for a
composition tree whose nodes are `∘` and whose leaves carry `UltrametricCompositionLaw`
depths, `depth (eval ∘ t) ≤ maxLeafDepth depth t + height t`, and balanced composition of
`2^n` maps of depth `d` has depth exactly `d + n`. This would extend the 1-Lipschitz functor
from `(add, mul)` to `(∘)`, unifying it with `UltrametricCompositionLaw.vdepth_iterate_succ`.

## C5. Hensel certificate is a balanced tree (quantitative bridge)
Conjecture: the `HenselIterationComplexity` certificate (`newton_steps = log₂ target + 1`)
is the image under `depthTropFunctor` of a balanced `OpTree` of height `log₂ target` built
from a single quadratic-doubling step. Precisely: there is a `DepthCarrier` of Hensel states
in which the depth of the `n`-step lift equals the height of `balanced step n`, so
`depth_balanced_overhead_tight` *recovers* `HenselConvergenceData.precision_exponential`
and `speedup_ratio`. Testable: build the Hensel `DepthCarrier` and prove the depth of the
`k`-fold doubling tree equals `k`, matching `precision_exponential`'s `2^k` bound.
