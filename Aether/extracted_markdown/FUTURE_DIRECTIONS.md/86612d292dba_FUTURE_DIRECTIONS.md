# Future Directions — Tropical Closure Envelopes and Helly-Type Separation

The file `Catalog/Bridges/TropicalClosureEnvelope.lean` recasts an abstract
finitary closure operator as a *max-plus semimodule envelope*: a probe family
`ev : α → ι → ℝ` sends each state to an evaluation vector, the **envelope** of a
set `S` is the principal down-set of the tropical join `⨆_{s∈S} ev s`, and we
proved (a) the envelope is a genuine `SetClosureOperator`, (b) a tropical
Farkas/separation theorem with *Helly number one* (`notInEnvelope_iff`,
`helly_number_one`), (c) a representation theorem for closed sets
(`envClosed_iff`), and (d) the geometric bridge that closed sets are
`ev`-preimages of tropically convex sets (`boxBelow_isTropConvex`,
`envelope_eq_preimage_box`). The following directions extend this frontier; each
is stated so that it can be *falsified* by a single concrete counterexample.

## 1. Exact characterization of envelope-representable closure operators

Not every finite closure operator is of the form `Envelope ev`. Conjecture: a
closure operator `cl` on a finite type is representable by some real probe family
iff its lattice of closed sets is *both* intersection-closed (automatic) *and*
"join-saturated as a down-set" — equivalently, `cl S` is always the down-set of
`S` under the preorder `a ⪯ b ↔ ev a ≤ ev b` induced by *some* `ev`. The key
insight is that `Envelope`-closed sets are precisely principal down-sets of joins,
so representability is a purely order-theoretic property of the closed-set
lattice, not of the operator's syntax. Why now? We already have
`envClosed_iff` pinning down the closed sets exactly; the missing step is to turn
that fixed-point description into a lattice-embedding criterion, which is a finite
combinatorial statement amenable to the subagent.

## 2. Minimal probe dimension (tropical rank of a closure operator)

For a representable `cl`, define its *tropical rank* as the least `|ι|` admitting
`Envelope ev = cl`. Conjecture: the tropical rank equals the width (size of the
largest antichain) of the poset of join-irreducible closed sets, mirroring the
Develin–Sturmfels tropical-rank/Dilworth picture. The key insight is that each
probe contributes exactly one separating coordinate (Helly number one), so the
number of probes needed is governed by how many *independent* separations the
closed-set lattice forces — a Dilworth-type invariant. Why now? The
`helly_number_one` theorem already isolates "one probe per separation"; counting
the irredundant separations is the natural next quantitative theorem and connects
directly to the catalog's `TropicalPersistenceRealizationDuality` rank invariants.

## 3. Generalization to arbitrary ordered idempotent semirings

We proved `notInEnvelope_iff_generalized` for any `LinearOrder` of scalars. The
deeper conjecture: the *whole* package (closure-operator axioms, representation
theorem, tropical convexity of `boxBelow`) lifts to evaluation in any complete
linearly ordered additive commutative monoid, and the convexity proof needs only
`max s t = 0 → s ≤ 0 ∧ t ≤ 0` plus translation-monotonicity of `+`. The key
insight is that every step of the real-valued proof used *only* order and
`a + b ≤ a' + b'` monotonicity, never completeness or subtraction, so the bridge
is semiring-agnostic. Why now? The generalized separation lemma already compiles
verbatim over `LinearOrder`; promoting `boxBelow_isTropConvex` to a typeclass-
parametrized statement is a direct, well-scoped formalization target.

## 4. Algorithmic certificate extraction with complexity bound

Turn `notInEnvelope_iff` into a verified decision procedure: for finite `ι` and
finite `S`, searching the `|ι|` probes either returns a separating index (a
non-membership certificate) or confirms membership, in `O(|ι|·|S|)` comparisons.
Conjecture: this is *optimal* — no representation can certify non-membership with
fewer than one probe-vs-`S` scan in the worst case. The key insight is that the
biconditional `notInEnvelope_iff` is constructive: its forward direction *is* the
certificate-producing algorithm, so soundness and completeness are already proved;
only the complexity statement and optimality lower bound remain. Why now? The
catalog's `AlgebraEMLClosureComputation` provides the closure-membership setting
this would make computational, and the certificate search is short enough that a
`Decidable` instance plus a counting lemma is within immediate reach.

## 5. Dual envelopes and a Galois connection between probe families and closures

Define the *dual envelope* using `min`/coordinatewise lower joins, and conjecture
a Galois connection: the maps `ev ↦ Envelope ev` and `cl ↦ {separating probes of
cl}` form an antitone Galois connection whose closed objects are exactly the
representable closure operators of Direction 1. The key insight is that adding
probes can only shrink the envelope (more separating halfspaces ⇒ smaller closed
sets), giving the order-reversing half of a Galois connection for free, while the
representation theorem supplies the round-trip identity on representable operators.
Why now? The catalog already houses Galois/Tannaka-style reconstruction
(`AlgebraEMLReconstruction`, `ThermodynamicGalois`); phrasing probe→closure as a
Galois connection unifies our tropical bridge with that existing reconstruction
machinery and is a clean lattice-theoretic theorem to formalize next.
