# Future Directions: Closure-Stable Probe Reconstruction

The new file `Catalog/Bridges/ProbeGaloisReconstruction.lean` establishes an
*algorithmic Galois correspondence* between closure systems and families of
closure-stable probes. Concretely it proves that a closure-stable probe family
`P` reconstructs a genuine `SetClosureOperator` (`reconstructedOperator`); that
its closed sets are exactly the probe-detected sets (`closed_iff_detected`); that
probe-equivalent families induce identical closures
(`reconstructClosure_eq_of_sameDetects`); that every closure operator is
recovered exactly by its canonical probe family
(`reconstructClosure_canonical_eq`, `galois_left_inverse`,
`detected_canonical_roundtrip`); and that separating families make singletons
closed (`separating_singletons_closed`). The directions below extend this
foundation. Each is stated so that it could be refuted by a single explicit
counterexample, and each connects to existing catalog infrastructure.

## 1. The reconstruction map is a Galois insertion onto Moore families

Conjecture: the pair of maps `cl ↦ canonicalProbeFamily cl` and
`P ↦ reconstructedOperator P hP` forms a *Galois insertion* between the complete
lattice of `SetClosureOperator α` (ordered pointwise) and the complete lattice of
Moore families (intersection-closed `Set (Set α)` ordered by inclusion), with the
operator side as the reflective core. In particular `galois_left_inverse` is the
counit identity, and on Moore families `detected_canonical_roundtrip` is the unit
identity, so the correspondence is an order isomorphism when probe families are
quotiented by detection-equivalence.

The key insight is that `detected_canonical_roundtrip` already shows the family
side round-trips *on the detected predicate*, so the only missing ingredient is
monotonicity of both maps plus the fact that detection-equivalence classes are in
bijection with Moore families — a finite, checkable lattice statement rather than
a new analytic estimate.

Why now? The catalog's `closure_eq_of_sameClosedSets` gives uniqueness of the
operator from its closed-set lattice, which is exactly the injectivity half of an
order isomorphism; pairing it with the new constructive surjection
`reconstructClosure_canonical_eq` closes the loop with no remaining technical
debt.

## 2. Finite probe complexity equals the height of the closed-set lattice

Conjecture: for `Fintype α`, the minimum number of probes needed for a separating
closure-stable family that reconstructs a given operator `cl` equals the number
of meet-irreducible closed sets of `cl` (equivalently the number of "arrows" in
its closed-set lattice). Falsifiable: exhibit an operator on a 3- or 4-element
type whose meet-irreducible count differs from the minimal separating probe
count.

The key insight is that each meet-irreducible closed set is precisely a closed
set that cannot be obtained as an intersection of strictly larger detected sets,
so it must be certified by a dedicated probe — turning a counting question about
probes into the well-understood combinatorics of join/meet-irreducibles in finite
lattices.

Why now? `closureComplexity` and `finiteGeneratorRank` in
`AlgebraEMLReconstruction.lean` already supply minimal-generator machinery for the
dual (generation) side; the probe side is the order-theoretic mirror and reuses
the same `Nat.find`-based minimality idiom, so the formalization cost is low.

## 3. Closure-stability is detected by pairwise probe intersections

Conjecture: a probe family `P` is closure-stable (`ClosureStable P`) if and only
if it is *binary* closure-stable — closed only under intersections of pairs of
detected sets — provided the detected family is finite or directed-complete. This
would reduce an `∀ S : Set (Set α)` quantifier to a decidable pairwise check,
making `ClosureStable` algorithmically verifiable on finite types. Falsifiable: a
finite family closed under pairwise but not triple intersections.

The key insight is that arbitrary `⋂₀ S` over a finite detected family factors
through iterated binary meets, so binary stability propagates by induction on
`|S|`; the empty and singleton cases are exactly the `univ`-detection and
reflexivity facts already used inside `canonical_closureStable`.

Why now? The proof of `canonical_closureStable` shows intersection-closure is the
only nontrivial Moore-family axiom in play, and `Finset.induction` over detected
sets is directly available, so the reduction is a structural induction rather than
new mathematics.

## 4. A semimodule-valued probe space recovers weighted closure operators

Conjecture: replacing the boolean probe `Set α → Prop` by a semimodule-valued
probe `Set α → K` (over a semiring `K`, in the language of
`ClosureSemimoduleSystem` and `ProbeFamily σ K` from
`AlgebraEMLClosureComputation.lean`) and defining detection as "the probe is
constant on the set's saturation", the reconstruction map yields exactly the
closure operator whose closed sets are the joint level sets of the probes. The
boolean theory of this file is the `K = Prop`/two-element case. Falsifiable:
a `K`-probe family whose reconstructed level-set operator violates idempotence.

The key insight is that level sets of any family of functions are automatically
closed under arbitrary intersection — a Moore family for free — so the
`ClosureStable` hypothesis becomes a *theorem* in the semimodule setting rather
than an assumption, exactly as the catalog's `ClosureStableProbe` already
intends.

Why now? `AlgebraEMLClosureComputation.lean` already defines `ProbeFamily σ K`,
`ClosureStableProbe`, and `PostQuantumIndistinguishability` over a `Semiring K`;
bridging them to the operator-level `reconstructedOperator` would connect the two
catalog files that currently develop closure-by-probes in parallel without a
formal link.

## 5. Probe-indistinguishability is the Myhill–Nerode congruence of the closure

Conjecture: define two points `x, y : α` to be probe-indistinguishable when every
detected set contains both or neither. Then probe-indistinguishability is an
equivalence relation whose classes are the atoms of the closed-set lattice, and
the quotient `α / ∼` carries the *minimal* separating closure-stable probe family
reconstructing `cl` — a Myhill–Nerode-style minimization for closure systems.
Falsifiable: a closure operator whose indistinguishability quotient fails to be
separating after quotienting.

The key insight is that `separating_singletons_closed` already proves the
converse extreme (separation ⇒ singletons are atoms); the conjecture says the
quotient by indistinguishability *forces* this separation, so minimization and
separation are two faces of the same congruence collapse.

Why now? `AlgebraEMLClosureComputation.lean` is explicitly framed around
Myhill–Nerode minimal-quotient reconstruction from observables, and this file now
supplies the matching operator-level closed-set lattice; the quotient
construction is the natural bridge and reuses Mathlib's `Setoid`/`Quotient` API
with no new analytic content.
