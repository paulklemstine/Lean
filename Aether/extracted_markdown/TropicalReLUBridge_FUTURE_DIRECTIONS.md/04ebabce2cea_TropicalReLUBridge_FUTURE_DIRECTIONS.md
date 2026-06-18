# Future Directions — Tropical Geometry of ReLU Networks

This cycle closed the proof gap in the ReLU ↔ tropical-rational dictionary. The new
file `MachineLearning/TropicalReLUBridge.lean` proves, with zero `sorry` and only the
standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

* `affine_isTropPoly`, `IsTropPoly.sup`, `IsTropPoly.add`, `IsTropPoly.smul_nonneg`,
  `IsTropPoly.relu` — the tropical semiring closure of the piecewise-affine class
  (`max` = tropical `+`, pointwise `+` = tropical `×`, nonnegative scaling, ReLU);
* `sup'_add_sup'` — the max-plus distributive law that *is* "tropical multiplication";
* `affEval_convexOn`, `IsTropPoly.convexOn` — every tropical polynomial is a convex
  piecewise-linear function;
* `reluNet_isTropRational` — **the main bridge**: every one-hidden-layer ReLU network
  output is a difference of two tropical polynomials;
* `decisionBoundary_eq_locus`, `decisionBoundary_on_tropHypersurface` — the decision
  boundary of a tropical-rational classifier is an equality locus that lies on the
  tropical hypersurface (non-smooth locus) of the combined tropical polynomial.

These extend the catalog's tropical-ML line (`MachineLearning.TropicalGating`, which
collapses a *fixed route* to a single affine map; `MachineLearning.TropicalScalingLaws`;
`MachineLearning.DepthSeparation`) by tracking the *entire* piecewise-affine cell
structure across a ReLU layer rather than one cell at a time.

The directions below are concrete, falsifiable next steps.

---

## Direction 1 — Deep networks: closure under composition of tropical rational maps

The current bridge handles one hidden layer. The conjecture is that the class
`IsTropRational` is closed under the layer map of a ReLU network: composing a
tropical-rational vector map with an affine map and a ReLU is again tropical rational,
so **every** finite-depth ReLU network computes a tropical rational function, and the
number of linear regions is bounded by the Newton-polytope mixed volume of the two
tropical polynomials.

The key insight is that composition pushes through the max-plus *distributive law*
`sup'_add_sup'` already proven here: a ReLU of a difference `p - q` equals
`max(p, q) - q`, and `max(p, q)` is a tropical polynomial by `IsTropPoly.sup`, so the
whole layer stays inside `{tropical poly} - {tropical poly}` with no new machinery —
only careful bookkeeping of the vector-valued case.

Why now? The single-layer theorem `reluNet_isTropRational` is in place and the closure
lemmas (`.sup`, `.add`, `.smul_nonneg`, `.relu`) are exactly the inductive step; the
remaining work is a clean `Fin L`-indexed induction over depth, which is mechanical
given the base case is finished.

A falsifiable sub-claim: define `tropDegree` (the cardinality of a minimal generating
affine family) and conjecture `tropDegree(layer ∘ f) ≤ tropDegree(f) · width`. A single
hand-built 2-layer network whose region count exceeds this product would refute it.

---

## Direction 2 — A tight region-count bound via Newton polytopes

`IsTropPoly.convexOn` shows each tropical polynomial is convex, hence its graph is the
upper envelope of finitely many hyperplanes whose domains of linearity are the cells of
a polyhedral complex dual to a Newton polytope. The conjecture is that the number of
linear regions of a tropical-rational map `p - q` equals the number of vertices of the
mixed subdivision of `Newt(p) + Newt(q)` (Minkowski sum), giving an *exact* count, not
just the classical `O(width^depth)` upper bound.

The key insight is that `IsTropPoly.add` already realizes tropical multiplication as the
**Minkowski sum of index families** (the `S ×ˢ T` image construction in the proof): the
combinatorics of regions is therefore literally the combinatorics of that product,
which is the definition of a mixed subdivision.

Why now? The Minkowski-sum index construction is no longer a sketch — it is the actual
proof term of `IsTropPoly.add`, so the polytope bookkeeping can be read straight off the
formalization rather than re-derived.

A falsifiable sub-claim: for generic single-hidden-layer nets of width `n` in dimension
`d`, the region count is exactly `∑_{k=0}^{d} C(n, k)`. A random sample disagreeing with
this formula (computed by counting sign patterns) would refute it.

---

## Direction 3 — Sharpening the hypersurface bridge to an exact equality

`decisionBoundary_on_tropHypersurface` proves *containment*: boundary points lie on the
tropical hypersurface of `max(p, q)`. The conjecture is that, under a genericity
hypothesis (no two affine pieces of `p ∪ q` are parallel and the optimal pieces are
unique off a measure-zero set), the decision boundary equals the part of the tropical
hypersurface where the two simultaneously-maximal pieces come from *different* parts
(one from `p`, one from `q`).

The key insight is that the witnesses `abp ∈ Sp` and `abq ∈ Sq` produced in the current
proof already encode the "tie between a `p`-piece and a `q`-piece" — promoting them from
existence to a *characterization* only needs uniqueness of maximizers, a generic
condition expressible as the complement of finitely many lower-dimensional faces.

Why now? The hard direction (boundary ⊆ hypersurface) is finished with explicit
witnesses; the reverse inclusion is a short argument once a genericity predicate is
chosen, so the theorem is one well-posed hypothesis away from an iff.

A falsifiable sub-claim: for a generic 2-piece-vs-2-piece classifier in ℝ², the decision
boundary is a connected polygonal curve with exactly one breakpoint. A generic example
with two breakpoints would refute the connectivity claim.

---

## Direction 4 — Quantitative convexity defect = tropical rank

A pure tropical *polynomial* is convex (`IsTropPoly.convexOn`); a tropical *rational*
function `p - q` generally is not. Conjecture: the failure of convexity is controlled by
the smaller of the two tropical degrees — precisely, `p - q` is a difference of a convex
and a convex function (a "DC function") whose nonconvexity "rank" equals the minimal
number of affine pieces needed in `q`. This turns expressivity into a single integer.

The key insight is that `reluNet_isTropRational` splits the network by the *sign of the
output weights*, and the negative-weight part is exactly the subtracted polynomial `q`;
its piece-count is therefore a network-architecture quantity (number of negatively-wired
hidden units), making the abstract "tropical rank" directly measurable from weights.

Why now? The explicit `p`/`q` split in the finished proof of `reluNet_isTropRational`
gives a canonical (if not yet minimal) representative for `q`, so the rank can be defined
and upper-bounded immediately, with minimality as the open refinement.

A falsifiable sub-claim: a one-hidden-layer net with all output weights `≥ 0` computes a
*convex* function. (This one is provable now from the existing lemmas and is a good first
checkpoint — its negation for some nonnegative-weight net would expose a bug in the
convexity development.)

---

## Direction 5 — Cross-domain: tropical sparsity meets the Cauchy-kernel sparsity bound

`MachineLearning.StereographicAttention.Sparsity` proves a Markov sparsity bound for the
Cauchy attention kernel (`τ · #active ≤ Σ scores ≤ N`). Conjecture: the *same* counting
principle applies to ReLU activation patterns via the tropical picture — at input `x`,
the number of hidden units that are "active" (`affEval > 0`) is at most the number of
affine pieces of `max(p, q)` attaining the max within an additive slack `τ`, giving a
data-dependent activation-sparsity certificate for ReLU layers analogous to attention
sparsity.

The key insight is that both phenomena are the same `Finset.sup'` Markov argument: the
attention proof bounds `#{i : score i ≥ τ}` by total mass, and the tropical proof bounds
`#{i : affEval (piece i) x ≥ sup' − τ}` by the gap structure of the tropical polynomial —
the active set is a sublevel set of the *defect from the maximum*, exactly the object the
attention file already controls.

Why now? The attention sparsity backbone (`cauchy_sparsity_markov`) and the tropical
`sup'` machinery (`sup'_add_sup'`, `IsTropPoly.convexOn`) are both formalized in the same
`MachineLearning` library, so a shared `Finset.sup'`-defect lemma can be factored out and
reused across attention and ReLU — a genuine cross-domain unification.

A falsifiable sub-claim: for inputs with all pairwise pre-activation gaps `> τ`, at most
one hidden unit is `τ`-near the tropical maximum. A constructed input with two units
within `τ` of the max despite large pairwise gaps would refute the gap-to-sparsity link.
