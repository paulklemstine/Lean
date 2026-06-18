# Future Directions: Closure Capacities as Submodular Energies

The file `Bridges/ClosureCapacitySubmodularity.lean` establishes a bridge from the
catalog's EML / closure-operator infrastructure (`SetClosureOperator`,
`FiniteClosureSystem`, `ProbeFamily`, `ClosureStableProbe`) to combinatorial
optimization: a monotone, normalized, closure-invariant capacity `μ` factors
through the closure operator and descends to a *submodular energy* `E` on the
closed-set lattice, whose minimizers form a sublattice. The following directions
extend that result. Each is precise and falsifiable.

## 1. Lovász extension and continuous convexity of the closed energy

A submodular function on a Boolean lattice admits a *Lovász extension* to the
hypercube `[0,1]^α` that is convex iff the function is submodular. We conjecture
that `submodular_on_closed` lifts to a convex Lovász extension defined on the order
polytope of the closed-set lattice, and that `minimizer_meet_join_stable` becomes
the statement that the face of minimizers of this convex extension is itself an
order polytope.

The key insight is that closure-invariance collapses the full hypercube onto the
order polytope of the *closed-set* sublattice, so the Lovász construction needs to
be performed only over closure classes rather than all of `2^α`.

Why now? The Lean proof already shows minimizers form a sublattice with a shared
minimum value; the convexity statement is the analytic shadow of exactly this
combinatorial fact, and Mathlib's `convexOn` and finite-sum machinery make the
extension formalizable without new foundations.

## 2. A min–max / strong-duality theorem for closure capacities

Submodular minimization enjoys strong duality (Edmonds): the minimum of a
submodular function equals the maximum of a linear functional over the base
polytope. We conjecture that for closure capacities the dual variable can be taken
*supported on a closure-stable probe family*, giving a duality
`min_{C closed} E(C) = max_{w ∈ B(μ)} ⟨w, χ⟩` where `w` ranges over probe-weighted
vectors.

The key insight is that the reconstruction theorem already says probe values
determine `E`; duality should then say the *optimal* dual certificate also lives in
probe space, turning reconstruction into an optimality certificate.

Why now? `reconstruction` is proven and `exists_minimizer` gives the primal
optimum; the only missing piece is the base-polytope side, which is a finite linear
program expressible with Mathlib's `Finset.sum` and `linarith`/LP duality lemmas.

## 3. Quantitative reconstruction error under approximate probes

Replace exact probe agreement by an `ε`-approximation: `|μ p − ν p| ≤ ε` for all
`p ∈ P`. We conjecture a Lipschitz-style bound `|μ s − ν s| ≤ ε` for every `s`
(not just probes) when `P` is closure-stable, and more sharply that the bound on
*energies of minimizers* is `2ε`-tight via the submodular law.

The key insight is that closure-invariance is an *exact* factorization, so
approximation error does not amplify along closure orbits — it transports
isometrically from probes to arbitrary sets.

Why now? The exact version `reconstruction` is a one-line `rw` through
`closure_inv`; replacing the equality by an inequality is a direct robustness
upgrade that `gcongr`/`abs_sub` can discharge, yielding a certified-robustness
bridge to the catalog's Lipschitz robustness lemmas.

## 4. Matroid rank as a canonical closure capacity

The rank function of a matroid is monotone, normalized, submodular, and *invariant
under matroid closure*. We conjecture that every matroid yields a `ClosureCapacity`
for its closure operator, so that `submodular_on_closed` recovers the matroid
submodular inequality and `minimizer_meet_join_stable` specializes to the lattice
of flats of minimal rank.

The key insight is that matroid flats are exactly the closed sets of the matroid
closure operator, so the abstract energy `E` *is* the rank function restricted to
flats — making matroids the canonical model of the whole framework.

Why now? Mathlib has a developing matroid library (`Matroid`, rank, closure, flats);
instantiating the `ClosureCapacity` structure from a matroid is a concrete glue
lemma that would connect this bridge to mainstream combinatorics.

## 5. Greedy optimality and the `(1 − 1/e)` guarantee for monotone capacities

For maximizing a monotone submodular function under a cardinality constraint, the
greedy algorithm achieves a `(1 − 1/e)` approximation. We conjecture that a greedy
procedure that adds, at each step, the closed superset maximizing marginal energy
gain attains the same guarantee for closure capacities, with the closed-set
sublattice structure ensuring greedy stays inside the feasible flat lattice.

The key insight is that closure-invariance means greedy never needs to leave the
closed-set lattice: each marginal gain `E(cl(C ∪ {x})) − E(C)` is well-defined and
the diminishing-returns inequality `submodular_on_closed` is precisely the
hypothesis the `(1 − 1/e)` analysis consumes.

Why now? The diminishing-returns inequality is already proven on closed sets;
formalizing the greedy bound is then a finite induction with `linarith` over the
marginal gains, a self-contained target that would give the catalog its first
certified approximation-algorithm guarantee.
