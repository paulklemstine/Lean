# Future Directions — Finite Closure Systems as Probe Semimodules

Cycle artifact: `Catalog/Bridges/AlgebraEMLProbeReconstruction.lean`
(8 theorems, 0 `sorry` on results; standard axioms only).

## Synthesis

This cycle built a clean bridge from the **algebraic / EML closure-operator
infrastructure** (`Bridges.AlgebraEMLReconstruction.SetClosureOperator`,
`ClosedSet`, and the engine lemma `closure_eq_sInf_closed_eq`) to an
**observational reconstruction theory**. The organizing idea is the *probe
signature*: attach to each set `s` the family of probe evaluations
`signature P s = fun i => P i s`. We proved that closure-stable probes cannot
distinguish `s` from `cl s` (`signature_closureStable`), and that a *separating*
probe family makes equality of closed sets recoverable from signatures alone
(`signature_inj_closed_iff`).

The technical heart is the **canonical kernel-probe family**: index probes by
closed sets ("kernels") `D` and let the probe report containment `s ⊆ D`. These
probes are simultaneously closure-stable (`canonicalProbe_stable`) — because
closed kernels absorb closures of their subsets — *and* separating
(`canonicalProbe_separates`), recovered by evaluating a closed set's signature
at the kernel equal to itself. This combination is exactly what lets us turn raw
probe data into an explicit reconstruction: `reconstruct_signature_eq_closure`
shows the closure of any set is the intersection of all probe-certified closed
supersets, i.e. `reconstruct (signature s) = cl s`, which specializes
`closure_eq_sInf_closed_eq` into a correct, signature-driven pipeline. Closed
sets are precisely the fixed points of this pipeline
(`reconstruct_signature_closed`).

Two structural results expose the *idempotent-semimodule* nature of the image:
the signature map is an order embedding of the closed-set lattice
(`signature_le_iff`), and the image is closed under coordinatewise idempotent
meet — the `∧` of two signatures is again a signature, namely that of
`cl (A ∪ B)` (`signature_meet_closed`). Nothing failed structurally this cycle;
the main friction was infrastructural (the project's source lives under a nested
`Catalog/` tree) rather than mathematical. The proofs are short, which is itself
informative: it says the "reconstruction certificate" content of a finite
closure system is fully carried by the abstract EML axioms, with no extra
hypotheses (finiteness, semiring structure, decidability) needed for the core
representation theorems.

## Results Summary

- `signature_closureStable`: proved — closure-stable probe families assign equal signatures to `s` and `cl s`; observations cannot see inside the closure.
- `signature_inj_closed_iff`: proved — under a separating family, closed sets are equal iff their signatures are equal (equality is an observational check).
- `canonicalProbe_stable`: proved — the containment-in-a-closed-kernel probes are closure-stable.
- `canonicalProbe_separates`: proved — the kernel probes separate closed sets, giving a concrete simultaneously-stable-and-separating family.
- `reconstruct_signature_eq_closure`: proved — **reconstruction theorem**: `reconstruct (signature s) = cl s`, a correct pipeline from probe data to closure certificates; extends `closure_eq_sInf_closed_eq`.
- `reconstruct_signature_closed`: proved — closed sets are exactly the fixed points of `reconstruct ∘ signature`.
- `signature_le_iff`: proved — the signature map is an order embedding of the closed-set lattice.
- `signature_meet_closed`: proved — the image is closed under coordinatewise idempotent meet (`∧`), realized by `cl (A ∪ B)`.

## Research Directions

### Direction 1: Computable reconstruction on finite carriers
**Hypothesis**: For `[Fintype α] [DecidableEq α]` and a closure operator on
`Finset α`, there is a `Finset`-valued, decidable `reconstructFin` such that
`reconstructFin (sigFin s) = clFin s`, computed by intersecting only the closed
kernels appearing in the (finite) signature support.
**Test**: Define `reconstructFin` over `Finset α`, prove the equality, and
`#eval` it on a small lattice (e.g. divisor closure on `Fin n`) to confirm it
returns `clFin s` and runs without `Classical`. The key insight is that on a
finite carrier the canonical kernel index `{D // ClosedSet cl D}` is itself
finite, so the abstract `⋂₀` collapses to a `Finset.inf` over closed sets.
**Why now**: This cycle's `reconstruct_signature_eq_closure` already pins the
mathematical content; only a finite/decidable repackaging remains, and the
catalog's `FiniteClosureSystem` (Finset-based) supplies the right interface.
**If true**: yields an executable observations-to-closure algorithm with a
machine-checked correctness proof — the "algorithmic normal form" promised by
the concept. **If false**: the obstruction would localize exactly where
decidability of `ClosedSet` fails, sharpening which closure systems are
effectively reconstructible.

### Direction 2: Finite extremal basis of probes (meet-irreducible kernels)
**Hypothesis**: Every closure in a finite system is generated by its
meet-irreducible closed sets: `cl s = ⋂ {D ∈ MeetIrreducible | s ⊆ D}`, and this
is the minimum-cardinality separating kernel-probe family.
**Test**: Define meet-irreducibility for `ClosedSet`, prove the restricted
intersection still equals `cl s`, and prove minimality (no proper subfamily
separates). The key insight is that redundant kernels are exactly the
meet-reducible ones, so `signature_meet_closed` lets us discard them without
losing reconstruction power. **Why now**: `signature_meet_closed` already shows
the image is meet-closed, which is precisely the structure needed to define and
exploit meet-irreducibles. **If true**: a finite-basis theorem (the concept's
stronger target) with an explicit canonical probe basis. **If false**: there is
a finite closure system whose reconstruction needs more than its
meet-irreducibles, contradicting the lattice-theoretic folklore and exposing a
genuinely new phenomenon.

### Direction 3: Bundled `OrderEmbedding` and lattice isomorphism onto the image
**Hypothesis**: The map `C ↦ signature (canonicalProbe cl) C` extends to a
bundled `OrderEmbedding` from the closed-set lattice (ordered by `⊆`) into the
product order `ClosedIdx cl → Prop` (with `OrderDual` to fix variance), and is a
lattice isomorphism onto its image with meet `∧` and join `cl (· ∪ ·)`.
**Test**: Construct the `OrderEmbedding`/`OrderIso` term and discharge the
`map_rel_iff'` field using `signature_le_iff`; derive `map_inf`/`map_sup` from
`signature_meet_closed` and a dual join lemma. The key insight is that
`signature_le_iff` already supplies the `≤`-reflecting condition, so only the
bundling and the join half are missing. **Why now**: the two order facts proved
this cycle are exactly the embedding's defining data. **If true**: upgrades the
informal "order embedding" claim to a reusable Mathlib-style `OrderIso`, letting
downstream files transport lattice results across the bridge. **If false**: the
failure must be in the join direction, indicating the image is only a
meet-semilattice and not a sublattice.

### Direction 4: Robustness of reconstruction under probe perturbation
**Hypothesis**: If two probe families agree on all kernels containing `cl s`
(an "ε-equal signature" with ε measured by symmetric difference of certified
kernel sets), then their reconstructions of `s` coincide; more strongly,
`reconstruct` is monotone and Lipschitz-stable in the certified-kernel set.
**Test**: State reconstruction as a function of the certified-kernel set, prove
monotonicity (`⊆` of kernel sets ⇒ `⊇` of reconstructions) and a stability
bound, reusing the catalog's `lipschitz_certified_robustness_identity` template.
The key insight is that `reconstruct` is literally `⋂₀` over a set of kernels, so
its behavior under perturbing that set is pure intersection monotonicity. **Why
now**: this cycle isolated `reconstruct` as a clean set-indexed intersection,
making perturbation analysis a direct corollary rather than a new theory. **If
true**: connects the bridge to the catalog's certified-robustness / post-quantum
separator theme with quantitative guarantees. **If false**: identifies a closure
system where small observational error causes a discontinuous jump in the
reconstructed closure — a concrete fragility certificate.

### Direction 5: Semiring-valued probes and the `ClosureSemimoduleSystem` bridge
**Hypothesis**: The Prop-valued kernel probes generalize to `K`-valued probes
for an idempotent semiring `K` (e.g. tropical `ℝ≥0` with `min`/`+`), with the
signature living in a `K`-semimodule and reconstruction realized by an
idempotent-`inf` over coordinates; the Boolean theory of this cycle is the
`K = Prop` special case, and the `ClosureSemimoduleSystem.ClosureStableProbe`
predicate coincides with `ProbeStable` on the induced set-closure.
**Test**: Define the `K`-valued signature and an idempotent-meet reconstruction,
prove `signature_closureStable` and a reconstruction identity for closure-stable
`K`-probes, and prove the coincidence with `ClosureStableProbe` from
`Bridges/AlgebraEMLClosureComputation.lean`. The key insight is that the only
property of `Prop` used this cycle is being an idempotent meet-semilattice, which
every idempotent semiring's additive structure provides. **Why now**: the
catalog already defines `ClosureSemimoduleSystem`, `ProbeFamily`, and
`ClosureStableProbe`, but no theorem yet links them to exact reconstruction;
this cycle supplies the Boolean prototype to imitate. **If true**: a genuine
algebra↔EML semimodule reconstruction theorem over arbitrary idempotent
semirings, the deepest form of the concept's bridge. **If false**: pinpoints the
extra axiom (beyond idempotent-additivity) that Prop silently uses, clarifying
how far the semimodule analogy actually reaches.
