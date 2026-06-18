# Future Directions — Closure-stable probes as a Galois bridge

## Synthesis

`Catalog/Bridges/ClosureProbeGalois.lean` upgrades the closure/probe machinery of
`Bridges/AlgebraEMLClosureComputation.lean` from a collection of isolated
inequalities into a genuine *order-theoretic adjunction*. For a closure operator
`c = M.closure` and a probe family `P` we defined the **support signature**
`Supp P A` (probes switched on somewhere by `A`) and its dual **extractor**
`Ext P s` (the largest region whose entire support sits inside `s`). The crux is
that existential ("switched-on") support is *sup-preserving*, so `Supp` is the
**lower** adjoint of a `GaloisConnection`, and `Ext ∘ Supp` is automatically a
closure operator built purely from probe data.

The bridge to the *given* closure then splits cleanly across exactly two
hypotheses: closure-stability of probes gives `c A ⊆ Ext(Supp A)`, while a
point/closed-set separation axiom gives the reverse. Together they yield:

* `closure_recovery` — `c A = Ext P (Supp P A)`: closure reconstructed from boolean support;
* `profile_invariance` — `Supp P A = Supp P B ↔ c A = c B`: support is a complete fingerprint;
* `galois_insertion_on_closed` — the maps restrict to an order-reflecting bijection between closed sets and realized signatures (the Galois insertion);
* `recovery_fails_without_separation` — separation is necessary, not decorative.

## Results summary

Five `sorry`-free theorems (standard axioms only), fully general over an
arbitrary semiring `K` with **no finiteness hypothesis** — strictly more general
than the originally proposed finite-`X` framing.

## Research directions

### 1. Tropical refinement: from boolean support to min-plus valuation signatures
Replace the boolean `Supp P A : Set (σ → K)` by a min-plus valued signature
`tSupp P A : (σ → K) → WithTop ℕ`, recording for each probe the *least depth* at
which it switches on across `A` (using the `PadicValuationDepth` valuation/depth
intuition from `Computation/PadicValuationDepth.lean`). Conjecture: the boolean
theory is the `⊤`-thresholding of the tropical theory, i.e. for every threshold
`t`, `{p | tSupp P A p ≤ t}` is the boolean support of a derived closure, and the
tropical `(tSupp, tExt)` pair is again a Galois connection in the min-plus order.
**The key insight is** that thresholding a min-plus signature is itself a monotone
(Galois) operation, so the entire boolean adjunction should arise as a *level set*
of a single graded adjunction, refining `closure_recovery` into a depth-stratified
recovery. **Why now?** Both ingredients already exist in the catalog
(`ClosureProbeGalois` boolean layer + `PadicValuationDepth` valuation layer); the
only missing piece is the order-compatibility lemma between them, which is a finite
inductive argument. Falsifiable: exhibit a closure system where some threshold
level fails to be a closure operator.

### 2. Counting closed sets via realized signatures (finite spectra)
For finite `σ` and a separating closure-stable family, `galois_insertion_on_closed`
makes `C ↦ Supp P C` an injection from closed sets into `Set (σ → K)`. Conjecture:
the number of closed sets equals the number of *realized* support signatures, and
this count is computable as the cardinality of the image of `Supp` on singletons'
closures, giving an algorithm linear in `|σ|·|P.probes|`. **The key insight is**
that closed sets are exactly the fixed points of `Ext ∘ Supp`, and the insertion
turns "enumerate closed sets" into "enumerate distinct probe-support vectors,"
a hashable invariant. **Why now?** The injection is already proven; what remains
is to package it as a `Fintype.card` equality and a `Decidable` enumeration.
Falsifiable: a finite closure system whose closed-set count differs from its
realized-signature count would refute separation-completeness.

### 3. Weakest separating family and a minimality theorem
The separation axiom `SeparatesClosed` is sufficient for recovery; conjecture it
is also *necessary and characterizable*: a closure-stable family `P` satisfies
`closure_recovery` for all `A` **iff** `P` separates points from closed sets, and
among all such families there is a canonical minimal one (the "irreducible probes"
indexed by meet-irreducible closed sets). **The key insight is** that the failure
witness `recovery_fails_without_separation` is not an edge case but the extreme
point of a lattice of families, so separation should be the exact frontier between
recovery and collapse. **Why now?** We already have both the positive
(`closure_recovery`) and negative (`recovery_fails_without_separation`) endpoints;
the conjecture asks to prove they are tight, which is a contrapositive of the
existing inclusions. Falsifiable: a non-separating family that nonetheless
recovers closure would break the "iff."

### 4. Functoriality: closure simulations induce maps of support semilattices
`AlgebraEMLClosureComputation.lean` defines `ClosureSimulation` between closure
semimodule systems. Conjecture: a simulation `f : M₁ → M₂` that pulls back probes
(`p ↦ p ∘ f`) induces a monotone map of support signatures commuting with `Supp`,
making `Supp` a *functor* from the category of closure systems (and simulations)
to the category of support semilattices, and the Galois insertion a natural
transformation. **The key insight is** that `Supp` is defined purely from
"a probe is nonzero somewhere," a condition stable under pullback, so naturality
should reduce to `evalWord`/simulation commutation already proven in the catalog.
**Why now?** The simulation API and the support API now both exist; bridging them
is the natural next composition and would connect Bridges to category-theoretic
infrastructure. Falsifiable: a simulation under which support fails to commute
would refute functoriality.

### 5. Distributive / matroid structure of the realized signature lattice
Conjecture: when the underlying closure operator is a *matroid* (exchange
property), the lattice of realized support signatures is geometric (atomistic,
semimodular), and conversely non-semimodularity of the signature lattice detects
violation of exchange. This turns probe-support data into a computable test for
the matroid axioms. **The key insight is** that `galois_insertion_on_closed`
transports the entire closed-set lattice *isomorphically* onto realized
signatures, so any lattice-theoretic property of closed sets (semimodularity,
distributivity) is faithfully mirrored — and therefore *decidable from probe
data alone*. **Why now?** With the order-iso on closed sets in hand, importing
Mathlib's matroid/`GeometricLattice` API onto signatures is a direct transport.
Falsifiable: a matroid closure whose signature lattice is non-semimodular, or a
non-matroid closure whose signature lattice is geometric, would refute the
equivalence.
