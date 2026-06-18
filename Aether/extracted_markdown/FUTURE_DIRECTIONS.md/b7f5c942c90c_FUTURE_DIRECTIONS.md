# FUTURE_DIRECTIONS — Closure Extremal/Tropical Reconstruction

File produced this cycle: `Catalog/Bridges/ClosureExtremalTropicalReconstruction.lean`
(built on `Bridges.AlgebraEMLReconstruction`).

## Synthesis

This cycle opened a new Algebra–Bridges–Tropical connection by recovering each *closed
set* of a finite closure system from its **extremal generators**, rather than recovering
the *closure operator* from probe families / endomorphism monoids as the existing catalog
pipeline does (`reconstructsClosure`, `closure_eq_of_sameClosedSets`,
`closure_eq_of_endMonoid_eq` in `AlgebraEMLReconstruction.lean`). The central object is
`IsExtremal cl x s := x ∈ s ∧ x ∉ cl (s \ {x})`, the convex-geometry notion of an extreme
point, and its support `extremals cl s`. The headline result `closure_extremals_eq` is the
Krein–Milman theorem for finite convex geometries: under the anti-exchange axiom, every
closed set equals the closure of its extremal support. We then packaged the closed sets as
an idempotent commutative monoid under the join `s ⊕ t := cl (s ∪ t)` with unit `cl ∅`,
together with a Boolean (tropical `{0,1}`) scalar action — the additive part of an
idempotent semimodule — and showed the extremal support is subadditive under `⊕`
(`extremals_join_subset`), the structural fact behind certifying set equality by comparing
supports (`closed_eq_iff_extremals_eq`).

What survived and why: the *unconditional* lemmas (extremals lie in every generator,
extremal support contained in every generator, monotone inheritance of extremality) carried
no hypotheses and fed everything downstream. The decisive engine was `crux_extremal`: a
maximal-closed-avoider argument turning anti-exchange into "any point added to a closed set
is extremal in the result". Notably, neither the existence theorem nor its converse needed
the usual `cl ∅ = ∅` convex-geometry axiom — the minimal-generator route (existence) and
the two-generator intersection trick (converse) both avoid it.

What failed / the boundary: a naive induction on `|s|` for Krein–Milman stalls, because
deleting a point from a closed set need not leave it closed; the minimal-generator + crux
route sidesteps this. The Critic produced a genuine counterexample (`reconstruction_fails`)
on `Fin 2` with the collapsing closure `s ↦ if s = ∅ then ∅ else univ`, where `univ` is
closed but has no extreme points, so `cl (extremals univ) = ∅ ≠ univ`. This shows
anti-exchange is *necessary*, and combined with the proved converse
(`antiExchange_of_extremals_generate`) yields the exact dividing line
`antiExchange_iff_extremals_generate`: anti-exchange holds **iff** extremal reconstruction
holds for every closed set. The directions below push on the parts that are still partial:
support subadditivity is only an inclusion, the semimodule is only the additive/Boolean
fragment, and reconstruction is currently an existence/uniqueness statement, not yet a
verified extraction algorithm with complexity bounds.

## Results Summary

- `extremal_mem_self`: proved — extreme points are members (definitional sanity check).
- `extremals_subset`: proved — extremal support is a subset of the set.
- `closure_absorb_union`: proved — `cl (cl A ∪ B) = cl (A ∪ B)`, the algebraic workhorse.
- `extremal_mem_generator`: proved — every extreme point lies in *every* generator (unconditional lower bound).
- `extremals_subset_generator`: proved — set form: support ⊆ every generator.
- `closure_extremals_subset`: proved — closure of the support stays inside a closed set.
- `extremal_of_extremal_superset`: proved — extremality is inherited by sub-closed-sets containing the point.
- `extremals_join_subset`: proved — extremal support is subadditive under the join `⊕` (tropical bridge).
- `exists_min_generator`: proved — finite closed sets have a minimum-cardinality generator.
- `exists_max_closed_avoiding`: proved — maximal closed set containing `C` and avoiding `x` exists.
- `crux_extremal`: proved — anti-exchange engine: a point added to a closed set is extremal in the result.
- `closure_extremals_eq`: proved — **Krein–Milman**: under anti-exchange, closed sets = closure of their extremal support.
- `extremals_unique_min_generator`: proved — under anti-exchange the support is THE unique minimal generator.
- `closed_eq_iff_extremals_eq`: proved — reconstruction certificate: equality of closed sets ⇔ equality of supports.
- `ClosedSubtype.{cjoin,cbot,cjoin_comm,cjoin_assoc,cbot_cjoin,cjoin_cbot,cjoin_idem}` and the `CommMonoid` instance: proved — closed sets form an idempotent commutative monoid.
- `ClosedSubtype.{bsmul,bsmul_true,bsmul_false,bsmul_cjoin}`: proved — Boolean/tropical scalar action distributes over the join (idempotent semimodule fragment).
- `Counterexample.reconstruction_fails`: proved (disproof of the *unconditional* statement) — without anti-exchange, extremal reconstruction can fail (collapsing closure on `Fin 2`).
- `antiExchange_of_extremals_generate`: proved — converse of Krein–Milman: extremal reconstruction everywhere ⇒ anti-exchange.
- `antiExchange_iff_extremals_generate`: proved — characterization: anti-exchange ⇔ extremal reconstruction for all closed sets.

## Research Directions

### Direction 1: Exact extremal-support additivity under the join
**Hypothesis**: Under anti-exchange, `extremals cl (cl (s ∪ t)) = (extremals cl s ∪ extremals cl t) ∩ extremals cl (cl (s ∪ t))` fails in general, but the sharper law `extremals cl (s' ⊕ t') ⊆ extremals cl s' ∪ extremals cl t'` is *tight* and is an equality exactly when `s'` and `t'` are "extremally independent" (no extreme point of one lies in the closure of the other's support). The key insight is that the proved inclusion `extremals_join_subset` is the join half of a valuation-like identity, and its defect measures exactly the extreme points absorbed when two closed sets merge.
**Test**: Formalize an `ExtremallyIndependent` predicate and prove the inclusion becomes equality under it; disprove unconditional equality with a 3-point convex geometry where a midpoint becomes non-extreme after the join.
**Why now**: `extremals_join_subset` already gives one direction unconditionally, and `closed_eq_iff_extremals_eq` shows supports are the right invariant; only the merge law is missing.
**If true**: Supports become a (sub)additive functor from the `⊕`-monoid to finite sets — a tropical "support map" enabling compositional reconstruction.
**If false**: The defect set itself is a new invariant of convex geometries worth isolating and bounding.

### Direction 2: A verified extraction algorithm with complexity certificate
**Hypothesis**: There is a terminating procedure `extract : Finset α → Finset α` with `cl ↑(extract g) = cl ↑g` and `extract g = (extremals cl (cl ↑g)).toFinset` under anti-exchange, running in `O(|α|²)` closure evaluations. The key insight is that the minimal generator produced abstractly by `exists_min_generator` can be realized concretely by greedily deleting redundant points, and `crux_extremal` certifies that the greedy fixpoint is exactly the extremal support.
**Test**: Define the greedy deletion as a `Finset` recursion, prove correctness via `closure_extremals_eq` and `extremals_subset_generator`, and prove a `≤ |α|` bound on the number of deletion rounds.
**Why now**: `exists_min_generator` + `extremals_unique_min_generator` pin down the *target* of the algorithm; what remains is to make the search constructive and bound it.
**If true**: Turns the existence theorem into an executable, certified reconstruction pipeline — the algorithmic payoff promised by the bridge.
**If false**: Indicates the minimal generator is not greedily reachable, separating anti-exchange from stronger "shelling"/accessibility axioms.

### Direction 3: Full idempotent semimodule over a general bounded idempotent semiring
**Hypothesis**: `ClosedSubtype cl` is not merely a `CommMonoid` but a semimodule over any bounded distributive (idempotent) semiring `K` via `k • s := if k = 0 then cl ∅ else s` extended to a lattice action, and the join `⊕` makes it a `SemilatticeSup` with `OrderBot`. The key insight is that the Boolean action `bsmul` already verified is the rank-1 shadow of a genuine `K`-action whenever `K`'s idempotent addition matches the closed-set join.
**Test**: Build the `SemilatticeSup`/`OrderBot` instance on `ClosedSubtype cl` (order = ⊆) and an `OrderedAddCommMonoid`-style structure; attempt a `Module`-like bundling and identify the minimal axioms on `K` that go through.
**Why now**: The additive monoid, idempotence (`cjoin_idem`), and Boolean scalars (`bsmul_cjoin`) are all proved; only the order layer and a general scalar ring are missing.
**If true**: Places finite closure systems squarely inside the catalog's tropical/idempotent-module world, enabling reuse of `ClosureMorita.ClosureSemimodule` transport lemmas.
**If false**: Pinpoints which distributivity law of closure operators fails, distinguishing convex geometries from matroids at the module level.

### Direction 4: Anti-exchange transport across closure-preserving maps
**Hypothesis**: A closure-preserving endomorphism `f` (in the sense of `IsClosurePreserving` from `AlgebraEMLReconstruction`) sends extreme points to extreme points whenever `f` is injective and anti-exchange holds, i.e. `f '' extremals cl s ⊆ extremals cl (cl (f '' s))`. The key insight is that `extremal_mem_generator` is preserved by any map that reflects generators, so injectivity plus closure-preservation should transport the entire reconstruction certificate.
**Test**: Prove the image inclusion for injective closure-preserving `f`; find a non-injective counterexample collapsing two extreme points.
**Why now**: The endomorphism-monoid machinery already exists in the imported file, and `closed_eq_iff_extremals_eq` gives a clean invariant to transport.
**If true**: Connects extremal reconstruction to the Tannakian endomorphism-monoid reconstruction already in the catalog, unifying the two reconstruction paradigms.
**If false**: Shows extremal support is a strictly finer invariant than the closed-set lattice under morphisms, motivating a "support-preserving" subcategory.

### Direction 5: Carathéodory-style bound on extremal support size
**Hypothesis**: In a convex geometry of "convex dimension" `d` (longest chain of closed sets minus 1), every closed set's extremal support and minimal generator have size controlled by `d`, and `finiteGeneratorRank cl s = (extremals cl s).ncard` under anti-exchange. The key insight is that `finiteGeneratorRank` (already defined in `AlgebraEMLReconstruction`) must coincide with the extremal-support cardinality precisely when minimal generators are unique, which `extremals_unique_min_generator` guarantees.
**Test**: Prove `finiteGeneratorRank cl s = (extremals cl s).ncard` under anti-exchange by combining uniqueness with `finiteGeneratorRank_spec`/`finiteGeneratorRank_minimal`; then relate this to a chain-length invariant.
**Why now**: Both `finiteGeneratorRank` and `extremals_unique_min_generator` now exist, so the identification is a short bridge rather than new theory.
**If true**: Gives a computable, certified rank for closed sets equal to their extremal count — a dimension theory for finite convex geometries.
**If false**: Reveals closures where the minimal generator rank undercounts extreme points, i.e. anti-exchange fails subtly, sharpening the counterexample family.
