# FUTURE DIRECTIONS

## Synthesis

This cycle established the core algebraic theory of closure-stable probe systems,
proving that closure operators on sets are uniquely determined by—and algorithmically
recoverable from—separating probe families. The key technical achievement is the
**reconstruction theorem** (`closure_eq_probeClosed`): under the twin hypotheses of
closure-stability and probe-separation, the closure of any set `S` equals the set of
all points whose probe values are consistent with `S`. This converts an abstract
closure operator into a concrete intersection of preimages, yielding a directly
computable formula (`closure_eq_iInter_preimage`).

The proof architecture decomposed cleanly into four layers: monotonicity of probe images
(trivial), closure invariance of images (the heart of stability), soundness (closure
implies probe-consistency), and the reconstruction itself (separation closes the gap).
No step required deep Mathlib machinery—the proofs are essentially set-theoretic—which
suggests the framework is robust and portable. The **uniqueness corollary**
(`closure_eq_of_probe_eq`) shows that two closure operators sharing a separating probe
family must agree on every set, giving a Tannaka-style rigidity result.

All seven theorems are fully proved with zero `sorry`. The axioms used are only
`propext`, `Classical.choice`, and `Quot.sound`—standard and clean.

## Results Summary

- `probeSignature_mono`: proved — probe images are monotone in the set argument
- `probeSignature_cl_eq`: proved — closure-stable probes give identical signatures on S and cl S
- `closure_subset_probeClosed`: proved — soundness: cl S ⊆ probeClosed f S
- `closure_eq_probeClosed`: proved — **main reconstruction theorem**: cl S = probeClosed f S under stability + separation
- `probeClosed_of_isClosed`: proved — closed sets are probe-closed fixed points
- `closure_eq_of_probe_eq`: proved — uniqueness: two closure operators with the same separating probes must agree
- `closure_eq_iInter_preimage`: proved — algorithmic form: cl S = ⋂ i, f i ⁻¹' (f i '' S)

## Research Directions

### Direction 1: Finite decidable reconstruction with Fintype and DecidableEq

**Hypothesis**: When `α`, `ι`, and `β` are all `Fintype` with `DecidableEq`, the
probe-closed hull `probeClosed f S` is decidable, and one can define a computable
function `reconstructClosure : Finset α → Finset α` that agrees with `cl` on all inputs.

**Test**: Define the `Finset`-level analogue of `probeClosed`, prove it equals the
`Set`-level version under coercion, and show `Decidable (x ∈ probeClosed f S)`.

**Why now**: The current `closure_eq_iInter_preimage` gives the set-theoretic formula;
the missing piece is the decidability/computability certificate. The `Fintype` instances
and `Finset.filter` make this tractable.

**If true**: This gives a certified algorithm—a Lean program that computes closures from
probe data and is proved correct by construction.

**If false**: It would reveal that some step (e.g., checking membership in an image)
requires classical reasoning even in the finite case, which would be surprising and
informative about the boundary of constructive closure theory.

### Direction 2: Lattice isomorphism from probe equivalence

**Hypothesis**: If two finite closure systems `(α₁, cl₁)` and `(α₂, cl₂)` admit
probe families `f₁` and `f₂` with the same codomain `β` such that for every set
the probe signatures are equal (up to a bijection between the types), then the
lattices of closed sets are order-isomorphic.

**Test**: Define a map between closed-set lattices via the probe signature bijection,
and prove it is an `OrderIso`. The key insight is that `closure_eq_of_probe_eq`
already shows closure agreement on a single type; the cross-type version requires
lifting through a type equivalence.

**Why now**: `closure_eq_of_probe_eq` handles the single-type case. The generalization
to two types is the natural next step and would complete the "Tannaka" analogy.

**If true**: It would establish that probe families are complete invariants of closure
systems up to lattice isomorphism—a genuine Tannaka-style reconstruction.

**If false**: It would identify which structural information is lost by probes,
clarifying the limits of the probe abstraction.

### Direction 3: Minimal separating probe families

**Hypothesis**: For a finite closure system on `n` elements, the minimum number of
probes needed in a separating family is at most `n - 1` (analogous to the dimension
of a separating family of linear functionals on an `n`-dimensional space).

**Test**: Prove the upper bound by constructing an explicit separating family of
size `n - 1` for arbitrary finite closure systems, or find a counterexample.
The key insight is that each probe needs to "separate" one element from the rest,
and there are at most `n` elements to separate.

**Why now**: All the infrastructure for separation and closure-stability is in place;
the question reduces to a combinatorial counting argument on finite sets.

**If true**: It gives a tight complexity bound for the reconstruction algorithm.

**If false**: It reveals that closure systems can have more complex separation
structure than vector spaces, which would be interesting in its own right.

### Direction 4: Connection to Myhill–Nerode and automata quotients

**Hypothesis**: The probe-reconstruction framework specializes to the classical
Myhill–Nerode theorem when `α` is the set of states of a DFA, `cl` is the
right-congruence closure, and probes are the characteristic functions of accepted
languages from each state.

**Test**: Define the DFA specialization, prove that the Myhill–Nerode equivalence
classes correspond to probe-equivalence classes, and show the minimal automaton
arises as the quotient by `probeClosed`. The key insight is that closure-stability
of language probes is exactly the property that equivalent states accept the same
language—which is the definition of Myhill–Nerode equivalence.

**Why now**: The `ClosureSemimoduleSystem` in the catalog already has DFA-like
`step` and `output` fields. Connecting our reconstruction theorem to this
structure would validate the "bridge" claim concretely.

**If true**: It would demonstrate that the probe framework genuinely generalizes
classical automata theory, not just abstractly but with a direct specialization proof.

**If false**: It would identify where the closure-operator abstraction diverges from
the automata-theoretic setting, sharpening both frameworks.

### Direction 5: Weighted probe signatures and semiring-valued reconstruction

**Hypothesis**: When probes take values in a semiring `K` rather than a bare type `β`,
one can define a weighted probe signature `σ_K(S) : ι → K` (e.g., as a sum
`∑ x in S, f i x`) and prove an analogous reconstruction theorem: if the weighted
probes separate, then `cl S` is recovered from `σ_K(S)`.

**Test**: Define the weighted signature, prove monotonicity and closure invariance,
then state and prove the weighted reconstruction theorem. The key insight is that
the sum-based signature is a more algebraic object (a semimodule homomorphism)
and connects directly to the `ClosureSemimoduleSystem` framework in the catalog.

**Why now**: The current framework uses set-image signatures. Moving to semiring-valued
sums would connect to the `ThermoKoopmanObservable` and partition-function machinery
already in the catalog, completing the "semimodule" part of the bridge.

**If true**: It would unify the set-theoretic and algebraic approaches, showing that
closure reconstruction works in both the qualitative (set image) and quantitative
(semiring sum) settings.

**If false**: It would reveal that the passage from sets to semimodules requires
additional structure (e.g., cancellation, integrality), clarifying the algebraic
prerequisites for reconstruction.
