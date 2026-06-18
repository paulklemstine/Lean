# Future Directions: Hypergraph Closure & the Length–Distance Identity

## Synthesis

This cycle extended the *proof phase transition* scaffolding of
`Catalog/Logic/ProofPhaseTransitions.lean` along two of its own predicted directions, turning
informal conjectures into proved, `sorry`-free Lean.

`Catalog/Logic/HypergraphDerivability.lean` realises **Direction 3** (multi-premise
theories). It replaces single-conclusion axioms `a → b` by directed-hypergraph axioms
`(P, b)` with a *set* of premises `P`, defines derivability as the least-fixed-point closure
operator `HDerivable`, and proves the four structural pillars carry over verbatim: the
**barrier lemma** `hderivable_barrier` (the universal non-derivability certificate), **double
monotonicity** in the axiom set and the seed set, the **idempotent cut law** `hderivable_cut`
(the closure operator is a genuine closure), and — crucially — the **bridge theorem**
`hderivable_singleton_iff`, which shows that on singleton-premise theories the hypergraph
closure collapses *exactly* to the catalog's `Derivable = ReflTransGen`. The hypergraph layer
is therefore a conservative generalization, not a different object.

`Catalog/Logic/ProofLength.lean` realises **Direction 2** (proof length = distance). It
refines `Derivable` with an explicit step counter, `DerivInSteps T n a b`, proves the
**length-forgetting bridge** `derivable_iff_derivInSteps` (`Derivable T a b ↔ ∃ n,
DerivInSteps T n a b`), shows step count is **preserved** under axiom extension
(`derivInSteps_mono_theory`, so minimum length is monotone non-increasing), and establishes
the **sharp length identity** `chain_derivInSteps_iff`: in the chain theory, `b` is derivable
from `a` in exactly `n` steps **iff** `b = a + n`. Corollary `chain_length_unique` pins the
extremal optimality: the explicit witness `chainPath_length` of the parent file is the
*unique* admissible length, hence the genuine graph distance.

## Results Summary

All declarations across both files are proved with `sorry = 0` and depend only on the
standard kernel axioms (`propext`, `Quot.sound`); `hderivable_barrier` and
`derivable_iff_derivInSteps` are even axiom-free. The barrier lemma generalizes with the same
one-line induction as the graph case, confirming the parent file's prediction that the
barrier is the reusable bottleneck tool. The chain identity is an *iff* with no inequality
slack, which is exactly the content that makes "length = distance" optimal rather than merely
an upper bound.

## Research Directions

### 1. Width-quantified threshold sharpening for random hypergraph theories

Place the product measure on width-`k` hyperaxioms over `Fin n` (each candidate
`(P, b)` with `|P| = k` present independently with probability `p`) and study
`ℙ[HDerivable T S (n-1)]`. Conjecture: the sharp-threshold window width is *monotone
decreasing* in `k`, mirroring random `k`-SAT. **The key insight is** that `hderivable_barrier`
already supplies the monotone non-derivability certificate uniformly in `k`, so the only
`k`-dependence lives in the second-moment/expansion estimate of the firing rule, isolating
exactly where width enters. *Why now?* Monotonicity in both the seed and the axiom set is
formalized (`hderivable_mono_source`, `hderivable_mono_theory`), giving the monotone Boolean
function on the hyperedge cube that Friedgut's theorem consumes. Falsifiable: exhibit a width
`k` whose empirical threshold window is *wider* than the `k = 1` graph case.

### 2. A counted barrier: length lower bounds from layered cuts

Strengthen `hderivable_barrier` to a *quantitative* form: if `C₀ ⊆ C₁ ⊆ ⋯ ⊆ C_d` is a chain
of barriers with the target only entering at layer `d`, then every derivation has length `≥
d`. Conjecture: this layered-cut method is *complete* for length lower bounds — the optimal
`d` equals the true derivation length for every finite theory. **The key insight is** that
`DerivInSteps` already exposes the counter the barrier method was missing, so a barrier
indexed by step count becomes a potential function whose level sets certify distance. *Why
now?* `chain_derivInSteps_iff` proves the identity in the extremal case and
`derivInSteps_mono_theory` shows the counter behaves monotonically, giving both the base case
and the monotonicity an induction on `d` needs. Falsifiable: find a finite theory where the
best layered-cut bound is strictly below the true minimum derivation length.

### 3. Idempotence ⇒ a Galois closure with a derivability matroid

`hderivable_cut` plus the two monotonicity lemmas show `S ↦ {a | HDerivable T S a}` is a
genuine closure operator. Conjecture: for finite singleton-premise theories this closure
satisfies the Steinitz exchange property, so derivability induces a **matroid** whose rank is
the number of strongly connected components on any reachable antichain. **The key insight is**
that the bridge theorem `hderivable_singleton_iff` reduces the closure to reflexive–transitive
reachability, where exchange is a reachability-merging argument rather than an algebraic one.
*Why now?* Idempotence, monotonicity, and extensivity (the three closure axioms) are now all
proved, so only the exchange axiom remains between us and a matroid structure theorem.
Falsifiable: exhibit a multi-premise theory whose closure violates exchange (expected — width
`≥ 2` should break the matroid, sharpening the boundary of direction 1).

### 4. Minimum derivation length as directed distance, in general theories

Generalize `chain_length_unique` beyond the chain: define `dist T a b` as the least `n` with
`DerivInSteps T n a b` and conjecture it equals the directed graph distance for *every*
theory, with a `List.IsChain` path of that exact length realising it. **The key insight is**
that `derivable_iff_derivInSteps` already factors derivability through the counter, so the
minimum is well-defined whenever derivability holds, and the constructive `chainPath` of the
parent file is the template for the realising path. *Why now?* The counted bridge and the
chain optimality result give both the existence of a finite length and a worked extremal
example; the remaining step is a `Derivable ↔ ∃ chain` length-faithful correspondence via
`List.IsChain`. Falsifiable: a theory where the minimum `DerivInSteps` length strictly exceeds
the directed graph distance.

### 5. Criticality refined by length: which axioms shorten proofs?

Combine this cycle with the parent file's `chain_axiom_critical`. Define an axiom's
*length-criticality* as the increase in minimum derivation length caused by deleting it
(`+∞` if it disconnects). Conjecture: at the random-theory critical density the length-
criticality distribution is heavy-tailed, the proof-complexity analogue of SAT backbones,
and `derivInSteps_mono_theory` forces it to be monotone (adding axioms never raises any
existing length-criticality). **The key insight is** that length-criticality is a discrete
derivative of the distance function in direction 4, so its tail behaviour is governed by
near-threshold min-cut statistics on the derivation hypergraph. *Why now?* Length-preserving
monotonicity is proved, supplying the monotonicity backbone, and the chain case gives the
unit-criticality baseline (`chain_length_unique`) to measure deviations against. Falsifiable:
measure the distribution at the critical density and show it is light-tailed.
