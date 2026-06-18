# Future Directions: Algebraic Closure Systems as Tropical Semimodules

The file `Bridges/AlgebraTropicalClosureHull.lean` establishes that the closed sets of
any extensive–monotone–idempotent closure operator form a canonical **idempotent
hull algebra**: a commutative monoid under tropical addition `a ⊕ b = cl(a ∪ b)` (join)
and under tropical product `a ⊗ b = a ∩ b` (meet), with both operations idempotent, an
unconditional sub-distributive inequality `(a⊗b) ⊕ (a⊗c) ⊆ a⊗(b⊕c)`, exact distributivity
under an isolated `DistributiveClosure` hypothesis, a finite-generation representation of
every closed set by its singleton hulls, and one-shot termination of iterated hull
generation. The following directions extend this Algebra ↔ Tropical bridge. Each is
stated so that it can be confirmed or refuted by a concrete Lean construction.

## 1. Bundle the hull algebra as a Mathlib `IdemCommMonoid` / `Semilattice` and a lattice

Right now the additive and multiplicative comm-monoid structures are proved separately,
together with the idempotence laws `add_idem` and `mul_idem`. The next step is to package
these into the genuine order-theoretic object: give `ClosedSets cl` the order `a ≤ b ↔ a.1
⊆ b.1`, prove that `a ⊕ b` is the *join* and `a ⊗ b` is the *meet*, and conclude a
`Lattice (ClosedSets cl)` instance (in fact a `CompleteLattice`, since closed sets are
closed under arbitrary intersection). **The key insight is** that the two idempotent
monoids of the file are not independent algebraic accidents but the two halves of a single
lattice order, with `⊕`/`⊗` being join/meet — so the absorption laws `a ⊗ (a ⊕ b) = a`
become provable and the structure becomes a bounded lattice with `0 = cl ∅` and `1 = univ`.
**Why now?** The monoid laws, idempotence, and the `add_val`/`mul_val` simp lemmas are
already in place, so building the `Lattice` instance is a direct, falsifiable assembly
step — and if absorption fails to be provable from the current operations, that itself
pins down exactly which extra closure axiom the lattice structure needs.

## 2. Characterise `DistributiveClosure` as distributivity of the closed-set lattice

The file isolates `DistributiveClosure cl` as the precise hypothesis turning the
sub-distributive inequality into equality, and the worked `discreteClosure` example shows
it can hold. The conjecture: `DistributiveClosure cl` holds **iff** the closed-set lattice
of §1 (Direction 1) is a `DistribLattice`, and this in turn fails for the smallest
non-distributive lattices `M₃` and `N₅` realised as closure systems on a 5-element set.
**The key insight is** that `DistributiveClosure` is not an ad-hoc analytic condition but
exactly the order-theoretic distributive law transported through the hull operations, so
the entire Birkhoff theory of distributive lattices becomes available as a classification
of which closure operators yield genuine idempotent *semirings* rather than mere
semimodules. **Why now?** `M₃`/`N₅` are finite and explicitly constructible, so a single
`decide`-style Lean example can refute distributivity for a concrete closure operator and
confirm the "only if" direction, while the discrete-closure example already witnesses the
"if" direction.

## 3. From hull algebra to honest tropical convexity over `ℝ ∪ {∞}`

The current algebra is purely order-theoretic. The natural geometric continuation is to
equip a finite ground set with a tropical (min-plus) module structure on `(ℝ ∪ {∞})ⁿ` and
define the tropical convex hull operator `tcl(S)` = set of all min-plus combinations of
points of `S`. The conjecture: `tcl` satisfies the three `SetClosureOperator` axioms, and
moreover satisfies `DistributiveClosure`, so its closed sets — the tropical polytopes —
are an instance of the idempotent *semiring* of Direction 2. **The key insight is** that
tropical convex hull is literally a min-plus closure operator, so the abstract hull algebra
proved here is the exact algebraic skeleton of tropical convexity and the embedding
`ClosedSets tcl ↪ (ℝ∪{∞})ⁿ`-semimodule is the promised Algebra → Tropical bridge made
geometric. **Why now?** Mathlib already carries `Tropical` and `WithTop ℝ` with their
ordered-semiring API, so `tcl` can be defined directly and its three closure axioms
discharged by `min`/`add` monotonicity lemmas, giving a concrete, testable nontrivial
model of the framework rather than only the discrete one.

## 4. Quantitative one-shot reconstruction via closure-stable probes

`iterate_closure_stable` proves the hull-generation loop converges after a single step.
The catalog's `ClosureStableProbe` and `InfoEfficientAlgorithm.terminates_within_potential`
(in `Computation/InfoEfficientAlgorithms.lean`) suggest a quantitative refinement: model
hull generation as an `InfoEfficientAlgorithm` whose state is the current generated set,
whose potential is `Fintype.card α - (generated set).card` on a finite ground type, and
prove that a closure-stable probe family reconstructs the closed set in at most
`card α` steps, with the trace being *optimal* among algorithms compatible with the
closure axioms. **The key insight is** that closure idempotence makes hull generation the
extreme case of monotone-potential descent — the potential drops to a fixed point in one
"closure jump" — so the abstract termination theorem refines into a sharp complexity bound
that ties the Algebra bridge to the existing Computation framework. **Why now?** The
`InfoEfficientAlgorithm` scaffold and its termination lemma already exist in the catalog,
so this is a matter of instantiating that structure with the hull operator and proving the
card-monotonicity step, which is finite and decidable.

## 5. Functoriality: closure-preserving maps as homomorphisms of hull algebras

The catalog's `ClosurePreservingEnd` (in `Bridges/AlgebraEMLReconstruction.lean`) packages
endomorphisms `f` with `f '' (cl s) ⊆ cl (f '' s)`. The conjecture: every such `f` induces
a map `ClosedSets cl → ClosedSets cl'` (via `C ↦ cl' (f '' C)`) that is a homomorphism for
tropical addition and *lax* for tropical product, i.e. `F(a ⊕ b) = F a ⊕ F b` and
`F(a ⊗ b) ⊆ F a ⊗ F b`, with equality under a `DistributiveClosure`-style hypothesis.
**The key insight is** that the Tannaka-style reconstruction already proven for closure
operators in the catalog is precisely a statement about morphisms in the category whose
objects are these hull algebras, so the hull algebra upgrades the reconstruction theorems
from a property of single operators to a genuine functor `Closure ⥤ IdemSemimodule`.
**Why now?** `ClosurePreservingEnd`, its identity, and its composition are already verified
in the catalog, so defining the induced map and proving the additive-homomorphism law is a
short, self-contained extension that immediately connects three existing catalog files
(`AlgebraEMLReconstruction`, `AlgebraEMLClosureComputation`, and the new hull file).
