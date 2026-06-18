# FUTURE_DIRECTIONS — Berggren-Tree Closure Kernels and Info-Efficient Descent

## Synthesis

This cycle recast the Berggren tree of primitive Pythagorean triples as a
**finite closure-kernel dynamics** living in the *Bridges* domain, fusing four
catalog threads that had until now developed in isolation: the Berggren
generators and triple-probe of `Cryptography/BerggrenFingerprintRigidity.lean`,
the `SetClosureOperator` abstraction of `Bridges/AlgebraEMLReconstruction.lean`,
the geometric hypotenuse growth of `height_strict_mono_gen`, and the certified
`InfoEfficientAlgorithm` paradigm of `Computation/InfoEfficientAlgorithms.lean`.
The decisive structural insight was a change of representation: closure dynamics
on *raw triples* (adding one-step children) is extensive and monotone but
**fails idempotence** — re-closing produces grandchildren forever. Encoding a
node instead as a *word* `w : List (Fin 3)` and closing under **ancestors
(suffixes)** makes idempotence automatic, because ancestry is exactly the
reflexive–transitive suffix order. This is the concept's "saturation hypothesis"
discharged for free.

With that encoding, two independent potentials emerged. The **combinatorial
potential** (word length = tree depth) is an *exact* monovariant: each descent
step removes one generator, so the descent map terminates in precisely `depth`
steps — and we verified the generic `terminates_within_potential` bound is
saturated, not merely an upper bound (`berggrenDescent_complexity`). The
**geometric potential** (`tripleHeight`, the hypotenuse) is a *strict*
monovariant along proper descent, certifying that pruning toward the root
genuinely shrinks the lattice vectors (`proper_suffix_tripleHeight_lt`). Finally,
freeness of the Berggren semigroup upgrades the triple-probe into a
closure-determining invariant: equal probes iff equal singleton closures
(`probe_rigidity`, `closure_singleton_determines_triple`), bridging cryptographic
fingerprint rigidity to the closure framework.

What failed / what we learned: the naive triple-child closure was abandoned after
it broke idempotence — a clean negative result that pinned down *why* the word
encoding is the correct object. We also discovered that the catalog's
`Computation/InfoEfficientAlgorithms.lean` does not elaborate in the current
checkout (its dependency `Computation/AlgorithmicCertificate.lean` is absent), so
the certified-algorithm interface was re-stated self-containedly; repairing that
file is a concrete maintenance lead for the next cycle.

## Results Summary

- `suffixClosure_extensive`: proved — `S ⊆ cl S`; words are suffixes of themselves.
- `suffixClosure_monotone`: proved — closure respects set inclusion.
- `suffixClosure_idempotent`: proved — `cl (cl S) = cl S` via suffix transitivity; the crux that the word encoding makes the dynamics a genuine closure.
- `berggrenSuffixClosure`: proved — packages the above as a `SetClosureOperator BerggrenWord`, a Bridges-domain closure operator built directly on Pythagorean generators.
- `root_mem_suffixClosure`: proved — closure stability; every nonempty candidate family reconstructs the root `(3,4,5)`.
- `berggrenDescentAlgorithm`: proved — the descent as a certified `InfoEfficientAlgorithm` with potential = tree depth.
- `berggrenDescent_complexity`: proved — descent reaches the root in *exactly* `depth` steps (the potential bound is tight).
- `berggrenDescent_terminates`: proved — certified termination within `potential (init x)` steps.
- `suffix_tripleHeight_le`: proved — geometric potential weakly decreases along the closure (ancestors have no larger hypotenuse).
- `proper_suffix_tripleHeight_lt`: proved — strict decrease for proper ancestors.
- `probe_rigidity`: proved — equal triple probes force equal singleton closures (bridge to fingerprint rigidity).
- `closure_singleton_determines_triple`: proved — converse; the probe is a complete invariant on singleton closures.
- Triple-child closure on raw triples: disproved as a closure operator — extensive and monotone but not idempotent (motivating the word encoding).

## Research Directions

### Direction 1: Lorentz-filtered closures with a Galois connection
**Hypothesis**: Restricting the ancestor closure to words whose triples satisfy a
congruence/Lorentz-norm filter `Admissible` still yields a `SetClosureOperator`,
and the pair (closure, "admissible-generated") forms a Galois connection on the
candidate lattice.
**Test**: Define `clA S = {v | ∃ w ∈ S, v <:+ w ∧ Admissible v}`, attempt
extensive/monotone/idempotent; if extensivity fails on non-admissible seeds,
prove the Galois adjunction `clA S ⊆ T ↔ S ⊆ coreA T` instead.
The key insight is that admissibility commutes with suffixing exactly when the
filter is *ancestor-hereditary* (closed under taking suffixes), turning a static
predicate into a closure-compatible one. Why now: we already have a working
closure and `IsPositivePythagorean` is provably ancestor-hereditary, giving a
ready first instance.
**If true**: a parametric family of certified closures, one per filter, with
provable lattice-theoretic structure.
**If false**: identifies precisely which filters break closure, sharpening the
notion of admissibility.

### Direction 2: A two-potential complexity certificate (depth × height)
**Hypothesis**: The product/lexicographic combination of the combinatorial depth
and the geometric `tripleHeight` is itself a valid `InfoEfficientAlgorithm`
potential for *every* monotone pruning map (not just head-drop), giving a
complexity bound `O(depth)` with an explicit `5·3^depth`-type height envelope.
**Test**: Instantiate `InfoEfficientAlgorithm` with `potential = depth` but a
generalized `step` that drops any one generator, and prove descent using
`proper_suffix_tripleHeight_lt`.
The key insight is that the two monovariants are independent — depth controls the
*number* of steps while height controls the *size* of intermediate data — so they
certify time and space separately. Why now: both potentials are already proved
this cycle and `height_strict_mono_gen` supplies the strict geometric step.
**If true**: a genuine space–time certificate for Berggren reconstruction.
**If false**: reveals coupling between depth and height, e.g. a branch where
height stalls.

### Direction 3: Closure quotient = abelianization (Myhill–Nerode for Berggren)
**Hypothesis**: The equivalence "equal singleton closures" coincides exactly with
"equal words", but a coarser probe (hypotenuse only, `hypotenuseOfWord`) induces a
strictly larger congruence whose quotient is the abelianized generator profile.
**Test**: Compare `probe_rigidity` (full triple, injective) against a
hypotenuse-only probe; construct two distinct words with equal hypotenuse to
witness non-injectivity, then prove the quotient equals `abelianCount`.
The key insight is that *which* probe you close under selects the reconstruction
resolution — full triples give the free monoid, scalar fingerprints give its
abelianization. Why now: `fingerprint_injective_abelianized` and `abelianCount`
already exist in the imported file, so the quotient is one bridge-lemma away.
**If true**: a Myhill–Nerode-style minimal-quotient theorem connecting closures
to the catalog's reconstruction theme.
**If false**: the hypotenuse probe is secretly injective, a surprising rigidity
strengthening.

### Direction 4: Finset closure system with an explicit cardinality bound
**Hypothesis**: On `Finset BerggrenWord`, the ancestor closure satisfies
`(cl S).card ≤ ∑_{w ∈ S} (w.length + 1)`, giving a `FiniteClosureSystem`-style
instance with a certified size blow-up bound.
**Test**: Define the Finset version via `S.biUnion (suffixes)` and bound its card
by total suffix count; prove the closure axioms over `Finset`.
The key insight is that each word contributes at most `length + 1` ancestors, so
closure size is linear in total word length — an information-efficiency statement
about the *closure operator itself*, not just the descent. Why now: the Set-level
closure is proved, and `List` suffix enumeration is computable, making the Finset
lift mechanical.
**If true**: connects to `Bridges/AlgebraicEMLThermodynamicFormalism`'s
`FiniteClosureSystem` and enables Gibbs/pressure analysis on Berggren closures.
**If false**: exposes super-linear ancestor overlap requiring deduplication
analysis.

### Direction 5: Repair and reconnect the InfoEfficientAlgorithm catalog node
**Hypothesis**: `Computation/InfoEfficientAlgorithms.lean` can be made to elaborate
by supplying a minimal `Computation/AlgorithmicCertificate.lean`, after which
`berggrenDescentAlgorithm` can be re-expressed against the *canonical* catalog
structure rather than the local mirror, with no proof changes.
**Test**: Reconstruct the missing dependency from the symbols actually referenced
(grep shows the import is currently unused), rebuild the module, then swap the
import in this file and confirm the build.
The key insight is that the local re-statement of `InfoEfficientAlgorithm` is
*definitionally* the catalog one, so reconnection is a pure refactor that
strengthens cross-domain reuse without mathematical risk. Why now: this cycle
isolated the exact broken dependency and verified the interface compiles in
isolation.
**If true**: restores a catalog hub and lets future bridges import a single
canonical certificate.
**If false**: the missing file encoded nontrivial content, revealing hidden
assumptions in the info-efficiency framework.
