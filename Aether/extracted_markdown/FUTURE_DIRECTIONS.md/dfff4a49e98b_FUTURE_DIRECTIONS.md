# Future Directions: The Proof Metric and the Proof-Length Phase Transition

## Synthesis

This cycle deepened the *proof phase transition* program by supplying the one structural
fact the earlier infrastructure was missing: **proof length composes additively**. The
catalog files `ProofPhaseTransitions`, `ProofPhaseTransitionsCompleteness`,
`ImplicationalThreshold`, and `HypergraphThreshold` had already established that
derivability is reflexive–transitive-closure reachability (a *preorder*), that the barrier
method is sound and complete, that derivability is a Kuratowski closure operator, and that
the length-graded predicate `DerivOfLen T a b k` pins the diameter of the chain theory to
`n`. What was absent was the *algebra of lengths*. The new file `ProofMetric.lean` closes
this gap with `derivOfLen_comp` (graded transitivity: an `m`-step derivation followed by an
`n`-step derivation is an `(m+n)`-step derivation) and harvests three consequences that
upgrade derivability from a preorder to a **geometry**: `minDerivLen` is a reflexive,
triangle-obeying ℕ-valued quasi-metric (`minDerivLen_self`, `minDerivLen_triangle`); the
chain theory realizes geodesics with *zero proof slack* (`minDerivLen_chain_eq`,
`minDerivLen_chain_geodesic`); and the lengths of closed derivations `a ⊢ a` form an
additive submonoid of ℕ (`loopLengths_add`, `loopLengths_zero`), opening a bridge to
numerical-semigroup structure.

## Results Summary

All results are fully proved (no `sorry`, axiom-clean) in `ProofMetric.lean`:

1. `derivOfLen_comp` — additive composition of length-graded derivations.
2. `minDerivLen_self` — the proof metric is reflexive (`d(a,a) = 0`).
3. `minDerivLen_triangle` — the directed triangle inequality `d(a,c) ≤ d(a,b) + d(b,c)`.
4. `minDerivLen_chain_eq` — on the chain, `d(a,b) = b - a`, sharpening the catalog diameter.
5. `minDerivLen_chain_geodesic` — on the chain the triangle inequality is an *equality*.
6. `loopLengths_add` / `loopLengths_zero` — loop lengths form an additive submonoid of ℕ.

Together these exhibit `minDerivLen T` as an asymmetric premetric on the atoms of *any*
implicational theory, with the chain as its zero-slack extremal geodesic.

---

## Direction 1 — The Frobenius signature of a proof-length phase transition

The loop-length submonoid `L(T,a) = {k | DerivOfLen T a a k}` is now known to be an
additive submonoid of ℕ. For the chain, `L = {0}` (no nontrivial loops); but in a theory
with two cycles through `a` of coprime lengths `p, q`, `L` becomes a numerical semigroup
with a finite **Frobenius number** `g(p,q) = pq - p - q`. The conjecture: in a random
implicational theory on `n` atoms with edge density `c/n`, the typical loop-length submonoid
through a fixed atom undergoes a sharp transition — below threshold `L = {0}` (a tree-like,
loop-free neighborhood), above threshold `L` is cofinite with Frobenius number `Θ(log n)`.
**The key insight is** that loop lengths are not an arbitrary set but a numerical semigroup,
so the *entire* phase transition can be read off a single integer invariant (the Frobenius
number) rather than from the unstructured derivability relation. **Why now?** We just proved
`loopLengths_add`, which is exactly the closure-under-addition axiom that makes `L` a
numerical semigroup; the Frobenius machinery in `Mathlib` (gcd, Chicken-McNugget) can now be
attached directly to a proof-theoretic object.

## Direction 2 — Strict triangle inequality detects shortcuts (a sharpness test)

The chain has `minDerivLen_chain_geodesic`: the triangle inequality is tight. The conjecture
is the converse-flavoured *sharpness* statement: a theory `T` admits a **proof shortcut**
(an atom triple with `d(a,c) < d(a,b) + d(b,c)`) **iff** `T` contains a derivation that is
not a sub-derivation of any geodesic through `b` — equivalently, iff the directed graph of
axioms has a non-induced shortest path. **The key insight is** that the slack
`d(a,b) + d(b,c) − d(a,c) ≥ 0`, now a theorem-level quantity, is a *computable certificate*
of redundancy: zero slack everywhere characterizes exactly the geodesic (tree/chain-like)
theories. **Why now?** With `minDerivLen_triangle` proved, "slack" is a well-defined ℕ-valued
function; we can state and test the equality case as a falsifiable dichotomy on finite
theories by `decide` (the chain decidability instance already exists in the catalog).

## Direction 3 — Hypergraph proof length and a multi-premise diameter law

`HypergraphThreshold` generalized *existence* of derivations to multi-premise rules via the
least fixed point `HDeriv`, but there is no length grading there yet. Conjecture: define
`HDerivOfLen R S a k` (a derivation tree of `a` of **height** `k`) and prove the
height-subadditivity law `height(a from premises) ≤ 1 + max over premises height(p)`,
yielding a *logarithmic* diameter for balanced hypergraph theories versus the *linear*
diameter of the chain. **The key insight is** that multi-premise rules turn the proof object
from a path into a *tree*, so the correct length measure is height, not edge count, and the
additive composition `derivOfLen_comp` should generalize to a `max`-plus (tropical)
composition. **Why now?** The single-premise bridge `hderiv_singlePremise_iff_derivable`
already certifies that the binary case embeds as the `m=1` slice; we can check that
`HDerivOfLen` restricted to single premises recovers `DerivOfLen` exactly, anchoring the
tropical generalization to this cycle's additive one.

## Direction 4 — The proof metric is a genuine `PseudoMetricSpace` on the closure quotient

We proved reflexivity and the directed triangle inequality, but `minDerivLen` is asymmetric
(`d(a,b) ≠ d(b,a)` in the chain). Conjecture: the *symmetrization*
`ρ(a,b) = max(d(a,b), d(b,a))` restricted to a single strongly-connected component (a
mutual-derivability class, where both `Derivable T a b` and `Derivable T b a` hold) is a
genuine `Mathlib` `PseudoMetricSpace`, and the closure operator `Cl` of
`ProofPhaseTransitionsCompleteness` is `1`-Lipschitz for it. **The key insight is** that
mutual derivability is exactly the equivalence relation that quotients the preorder into a
poset, and on each class the asymmetry collapses, so the proof-length geometry becomes a
bona-fide metric space that `Mathlib`'s topology can act on. **Why now?** With
`minDerivLen_self` and `minDerivLen_triangle` in hand, only symmetry and `d=0 ↔ =` remain to
instantiate `PseudoMetricSpace`; both are tractable on a strongly-connected component, and
the completeness/closure operator from the prior cycle gives the Lipschitz target.

## Direction 5 — Criticality index as a metric-jump and its monotonicity

The catalog proved single-axiom criticality for the chain (`chain_axiom_critical`). With a
proof metric available, define the **criticality index** of a derivable pair `a ⊢ b` as the
jump `δ(e) = minDerivLen (T \ e) a b − minDerivLen T a b` caused by deleting axiom `e` (with
`+∞` when deletion breaks derivability). Conjecture: `δ` is monotone under theory extension
(adding axioms can only *decrease* every criticality jump), and the number of axioms with
`δ = +∞` (the *bridges*) equals the number of edge-cuts in the axiom graph separating `a`
from `b` — a Menger-type min-cut/max-flow theorem for proofs. **The key insight is** that the
hand-built barrier cuts of the catalog are exactly the min-cuts dual to proof flows, so
criticality is governed by graph connectivity rather than by ad-hoc axiom inspection. **Why
now?** `minDerivLen_theory_anti` (catalog) already gives "proofs only get shorter," the base
case of jump-monotonicity, and `derivOfLen_comp` lets us splice flows; the
`not_derivable_iff_exists_barrier` completeness theorem supplies the cut side of the duality.
