# Future Directions — Tropical Closure Rank from Closure-Stable Probes

## Synthesis

This cycle built a genuine bridge between two previously disjoint catalog theories:
the closure-semimodule dynamics of `Bridges/AlgebraEMLClosureComputation.lean`
(`ClosureSemimoduleSystem`, `ProbeFamily`, `ClosureStableProbe`) and the
valuation-depth complexity measure of `Computation/PadicValuationDepth.lean`
(`ValuationDepthMeasure`, `vdepth_sum_le`). The artifact `Bridges/TropicalClosureRank.lean`
defines a **tropical closure cost** `ccost p val S = S.sup (fun x => val (p x))` on
finite probe supports and proves it is monotone (`ccost_mono`), tropically subadditive
(`ccost_union_le`), satisfies a closure certificate bound (`ccost_closure_cert`), and is
closure-invariant under closure-stable probes (`ccost_closure_invariant`). On the
computation side, `pcost` aggregates intrinsic `vdepth` over a probe family and
`vdepth_combine_le_pcost` turns `vdepth_sum_le` into a composition certificate.

## Results Summary

* `ccost_mono`, `ccost_union_le` — order/lattice layer, **independent of closure-stability**.
* `ccost_closure_cert`, `ccost_closure_invariant` — invariance layer, **consuming
  `ClosureStableProbe`** exactly once each, via witness transport `p x = p y`.
* `pcost_mono`, `pcost_union_le`, `vdepth_combine_le_pcost` — computation-side mirror,
  with the composition bound derived from `vdepth_sum_le`.

The central empirical finding is an **asymmetry**: the order structure lives entirely on
the computation side (`Finset.sup` over `ℕ`), while closure-stability is the precise and
only interface needed for the invariance layer.

## Bold, Falsifiable Directions

### 1. Closure-stability is *necessary* for closure-invariance (sharpness)
We proved closure-stability is *sufficient* for `ccost_closure_invariant`. Conjecture: it
is also necessary — there exists a `ClosureSemimoduleSystem` and a probe `p` that is *not*
closure-stable for which some finite `S ⊆ S' ⊆ closure S` has `ccost p val S' > ccost p val S`.
The key insight is that the only step using stability is the upper bound, so breaking the
witness-transport property `p x = p y` for a single closure-generated element with strictly
larger `val (p x)` immediately produces a counterexample. Why now: with the invariance
theorem in hand, the falsifier is a tiny finite system (e.g. `σ = Fin 2`, `closure {0} = {0,1}`,
`p 0 ≠ p 1`), which is directly checkable in Lean by `decide`, so the necessity direction is a
self-contained next deliverable.

### 2. A min-plus *semiring homomorphism* from supports to the tropical numbers
Conjecture: `S ↦ ccost p val S` extends to a lax morphism of min-plus structures, i.e.
`ccost (S ∪ T) = max (ccost S) (ccost T)` *with equality* (not just `≤` the sum), making
`ccost` a genuine tropical-additive functional, while inclusion gives the tropical order.
The key insight is that `Finset.sup_union` already yields the `⊔` (tropical `⊕`) identity
exactly; the subadditivity-by-sum statement we proved is a strict weakening. Why now: the
equality `ccost (S ∪ T) = ccost S ⊔ ccost T` is one `Finset.sup_union` rewrite away and would
upgrade the bridge from an inequality law to an algebraic identity, enabling a functorial
reading into Mathlib's `Tropical ℕ`.

### 3. Quantitative closure rank as a graded complexity hierarchy
Define `VAL_k` supports as those with `ccost p val S ≤ k` and conjecture a strict hierarchy:
for every `k` there is a closure-stable system whose closure operation forces a support of
rank exactly `k+1` from one of rank `k`. The key insight is that `ccost_closure_invariant`
freezes rank within a closure class, so any rank increase must come from *crossing* closure
classes — turning the rank into a well-defined invariant of closure-equivalence classes.
Why now: `PadicValuationDepth.lean` already contains `ValDepthClassSet` / `DepthWitness`
hierarchy-separation scaffolding, so the separation witnesses can be imported wholesale
rather than rebuilt.

### 4. Multi-probe tensor cost and an uncertainty bound
For a finite probe family `P` define a joint cost `Ccost P S = S.sup (fun x => P.sup (fun p => val (p x)))`
and conjecture a tropical uncertainty inequality relating `Ccost P` to the individual `ccost p`.
The key insight is that swapping the two `Finset.sup` orders is governed by `Finset.sup_comm`,
so the joint cost is symmetric in states and probes and should satisfy
`Ccost P S = (P ×ˢ S).sup (fun (p,x) => val (p x))`. Why now: `vdepth_combine_le_pcost`
already controls how *combining probes* interacts with cost, so the joint functional is the
natural arena to test whether probe-composition and support-union costs commute.

### 5. Closure cost descends to the Myhill–Nerode quotient
`AlgebraEMLClosureComputation.lean` builds a Myhill–Nerode-style minimal quotient from
`PostQuantumIndistinguishability`. Conjecture: `ccost` is constant on indistinguishability
classes and therefore descends to a well-defined complexity on the minimal quotient automaton.
The key insight is that closure-stability already equates probe values across closure, and
indistinguishability is defined exactly by equality of closure-probe value-sets, so the cost
should be a class invariant by the same witness-transport argument. Why now: both ingredients
(the quotient construction and the closure-invariant cost) now live in the same import graph,
so the descent theorem is a direct composition of existing results rather than new machinery.
