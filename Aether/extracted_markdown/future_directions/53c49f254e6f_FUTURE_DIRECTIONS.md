# Future Directions — Tropical fixed-point signatures for finite closure systems

Source artifact: `Catalog/Bridges/TropicalClosureSignatures.lean`
(self-contained, `import Mathlib` only; builds with `sorry = 0` and only the
standard axioms `propext, Classical.choice, Quot.sound`).

## Synthesis

This cycle built a concrete, working bridge between **finite closure systems**
(the `FiniteClosureSystem` interface used across the catalog's EML/closure files,
e.g. `Bridges/AlgebraicEMLThermodynamicFormalism.lean`,
`Bridges/AlgebraEMLReconstruction.lean`) and the **tropical / min-plus** world.
The central object is the *tropical transfer operator*

  `T(w)(x) = inf_{ S : x ∈ cl S } ( sup_{a ∈ S} w a )`

acting on extended-integer weight functions `w : α → WithBot (WithTop ℤ)`.
We proved that `T` is monotone (`transfer_mono`), contractive in the tropical
order (`transfer_le`, i.e. `T w ≤ w`), and a genuine **tropical projector**
(`transfer_idem`, `T (T w) = T w`). The projector structure rests entirely on
one finitary fact, isolated as `transfer_subadd`: the operator output is
sub-additive along the closure, `T(w)(x) ≤ sup_{a∈S} T(w)(a)` whenever
`x ∈ cl S`. This is *exactly* closure idempotence transported to the semimodule
of weights, and it is the load-bearing lemma for the whole framework.

Two structural payoffs followed. First, a clean **fixed-point classification**
(`transfer_fixed_iff`): `T w = w` iff `w` is sub-additive along the closure,
which is the precise sense in which fixed points "descend to the poset of
principal closed sets". Second, a **reconstruction theorem**
(`cl_eq_of_transfer_eq`): two finite closure systems with the same transfer
operator have identical closures. The reconstruction key is a single tropical
probe family, the `{0,⊤}`-indicator `probeWeight S`, for which
`T(probeWeight S)(x) ≤ 0 ↔ x ∈ cl S` (`transfer_probe_iff`); a finite family of
tropical probes therefore recovers the entire closed-set lattice.

What worked: choosing `WithBot (WithTop ℤ)` (both `⊥` and `⊤`) so that
`Finset.sup` and `Finset.inf` are unconditionally defined; this removed every
empty-certificate edge case that a one-sided `WithTop` codomain would have
forced. What we deliberately avoided: real-valued/capacity or p-adic profile
machinery already in flight elsewhere in the catalog — the integer tropical
semiring keeps everything finitary, decidable, and reconstructible. The one
genuine subtlety was inf-attainment over the finite nonempty certificate set,
needed both for `transfer_subadd` and for the forward direction of
`transfer_probe_iff`; `Finset.exists_min_image` / `Finset.exists_mem_eq_inf'`
handle it.

## Results Summary

- `transfer_mono`: proved — `T` is monotone in the weight (composition of two
  monotone finite lattice operations `sup` then `inf`).
- `transfer_le`: proved — `T` is contractive, `T(w)(x) ≤ w x`; closure
  extensivity becomes tropical extensivity via the cheap certificate `{x}`.
- `transfer_subadd`: proved — `T(w)` is sub-additive along the closure; the
  finitary engine behind idempotence and the fixed-point criterion.
- `transfer_idem`: proved — `T` is a tropical projector, `T (T w) = T w`; the
  framework's defining "tropical idempotent endomorphism" property.
- `transfer_fixed_iff`: proved — fixed points of `T` are exactly the weights
  monotone/sub-additive along the closure (descend to principal closed sets).
- `probe_sup_le_iff`: proved — `R.sup (probeWeight S) ≤ 0 ↔ R ⊆ S`; the
  indicator calculus underlying probing.
- `transfer_probe_iff`: proved — `T(probeWeight S)(x) ≤ 0 ↔ x ∈ cl S`; one
  probe detects closure membership.
- `cl_eq_of_transfer_eq`: proved — reconstruction: equal transfer operators
  force equal closures (hence equal closed-set lattices).

## Research Directions

### Direction 1: Galois adjunction between `T` and a tropical interior/kernel
**Hypothesis**: There is a deflationary, monotone, idempotent *kernel* operator
`K` on weights (a tropical interior) such that `(T, K)` form an order-adjoint
pair whose common image is the lattice of closure-monotone signatures; the
fixed points of `T` and of `K` coincide.
**Test**: Define `K(w)(x) = sup_{ S : x ∈ coresystem } inf_{a∈S} w a` against the
dual (kernel/interior) operator of the closure, prove `K w ≥ w`-dual /
idempotence in Lean, then prove `T w = w ↔ K w = w` reusing
`transfer_fixed_iff`. A disproof would exhibit a finite closure system where the
two fixed-point sets differ.
**Why now**: We already have the projector half (`transfer_idem`) and an exact
fixed-point criterion (`transfer_fixed_iff`); the catalog's
`Algebra/EMLClosureUnification/Core.lean` provides `IsEMLKernelOn` and the
Galois fixed-point duality template to mirror.
**The key insight is** that a closure operator and its order-dual interior should
induce *adjoint* tropical idempotents, so the closure↔interior duality becomes a
min-plus Galois connection on the weight semimodule.
**If true**: closure systems acquire a full tropical Galois geometry (closed
weights vs. open weights), enabling duality-based reconstruction with strictly
fewer probes.
**If false**: it pinpoints that closure idempotence does not transport to the
co-side, isolating exactly which axiom (monotonicity vs. idempotence) breaks the
symmetry.

### Direction 2: Quantitative reconstruction — minimal probe families
**Hypothesis**: For a closure system on `α` with `n = |α|`, the closed-set
lattice is already determined by the probe family `{ probeWeight S : |S| ≤ k }`
for `k` equal to the maximal size of a minimal generator (the "Carathéodory
number" of the closure), and not by any smaller `k`.
**Test**: Strengthen `cl_eq_of_transfer_eq` to quantify over a restricted probe
set, prove sufficiency for `k = ` generator bound, and construct a two-system
counterexample showing necessity (closures agreeing on all `≤ k−1`-probes but
differing on one `k`-set).
**Why now**: `transfer_probe_iff` shows each membership fact `x ∈ cl S` is read
off from a single probe `probeWeight S`; the open question is purely how few `S`
suffice, which is now a concrete finite optimization rather than a definitional
matter.
**The key insight is** that reconstruction cost is governed by closure
*generation complexity*, so the tropical signature has an intrinsic "bandwidth"
equal to the Carathéodory number.
**If true**: gives an algorithm that reconstructs a closure from
polynomially-many (in the generator bound) tropical probes.
**If false**: reveals closure systems whose tropical signature is irreducibly
high-dimensional, a tropical analogue of high VC-dimension.

### Direction 3: Functoriality under closure morphisms
**Hypothesis**: A closure-preserving map `f : α → β` (one with
`f '' cl_α S ⊆ cl_β (f '' S)`) induces a tropical intertwiner
`T_β ∘ f_* = f_* ∘ T_α` on pushforward weights, making `T` a functor from a
category of finite closure systems to tropical projector semimodules.
**Test**: Formalize the morphism condition, define the pushforward on weights,
and prove the intertwining square commutes, reusing `transfer_subadd` to handle
the certificate transport. A counterexample would be a monotone-but-not-closure
map breaking the square.
**Why now**: All our proofs already manipulate certificates `S` through
`cl`-monotonicity and idempotence; the same certificate-gluing argument that
powers `transfer_subadd` is exactly what a functoriality square needs.
**The key insight is** that the certificate-union construction used for
idempotence is natural in the closure system, so `T` is not just an operator but
a functor.
**If true**: upgrades the bridge from an invariant to a full functorial
encoding, enabling transport of tropical spectral data along closure morphisms.
**If false**: identifies the minimal extra hypothesis (e.g. surjectivity or
generator preservation) needed for naturality.

### Direction 4: Tropical eigen-spectrum and probe energy minimization
**Hypothesis**: The fixed points of `T` are precisely the minimizers of a
tropical "probe energy" functional `E(w) = sup_x (w x - T(w)(x))` (which is
`≥ 0` by contractivity and `= 0` exactly on fixed points), and the supports of
the minimal-energy fixed points are exactly the closed sets.
**Test**: Define `E` in Lean over `WithBot (WithTop ℤ)`, prove `E(w) ≥ 0`
(immediate from `transfer_le`) and `E(w) = 0 ↔ T w = w` (from
`transfer_fixed_iff`), then characterize support sets of fixed points and match
them to `{ S | cl S = S }`.
**Why now**: `transfer_le` gives the nonnegativity of the energy for free and
`transfer_fixed_iff` gives the zero-set; only the support/closed-set
correspondence remains.
**The key insight is** that closure-stable probes are tropical eigenvectors
(`T w = w`), i.e. the zero-energy states, so "closed set" = "support of a
ground-state tropical signature".
**If true**: realizes the concept's promised "probe energy ⇒ closed sets"
variational principle, connecting to the catalog's thermodynamic-formalism files
(`closurePressure`, Gibbs fixed points) at zero temperature.
**If false**: shows the energy functional is too coarse and a refined,
multi-level (Collatz–Wielandt style) tropical eigenvalue is required.

### Direction 5: Beyond finiteness — algebraic (finitary) closure operators
**Hypothesis**: The projector identity `T (T w) = T w` and the reconstruction
theorem survive when `α` is infinite but `cl` is *finitary* (algebraic), provided
weights are bounded below, with `inf` taken over the directed set of finite
certificates.
**Test**: Replace `Fintype α` by an algebraic-closure hypothesis (every element
of `cl S` lies in `cl` of a finite subset of `S`, cf.
`AlgebraEMLReconstruction.algebraicLike_finite_witness`), reformulate `transfer`
with a `sInf`/`iInf`, and attempt `transfer_subadd`; the boundary is inf
attainment, which finiteness currently supplies.
**Why now**: Every proof here used finiteness in exactly one place —
inf-attainment over certificates — so the precise obstruction to generalizing is
already localized.
**The key insight is** that finiteness was only ever a proxy for the *finitary*
(compactness) axiom of closure, so algebraicity, not cardinality, is the true
hypothesis.
**If true**: extends tropical signatures to matroids, ideal/submodule closures,
and topological-style closures of unbounded size.
**If false**: produces an explicit infinite finitary closure where `T` fails to
be idempotent, sharply delimiting the finitary frontier of the bridge.
