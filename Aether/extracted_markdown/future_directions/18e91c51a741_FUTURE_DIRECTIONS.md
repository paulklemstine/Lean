# Future Directions: Thermodynamic Proof Complexity

## Synthesis

This cycle established a small but fully verified core of the **Thermodynamic Proof
System** (TPS) framework, split across two Lean files in `MachineLearning/`:
`ThermodynamicProofComplexity.lean` (energetics + incompressibility) and
`ThermodynamicDecisionBounds.lean` (algorithmic work lower bounds). The organizing
idea is to read a statement's minimal proof length `n` as a number of bits and assign
it the Landauer erasure work `tcost T n = T · log 2 · n`, the thermodynamic cost of
discarding that information at temperature `T`. Everything else is forced by this one
definition.

Two structurally independent strands emerged and then glued cleanly. The **energetics**
strand shows the cost spectrum is an arithmetic ladder: `tcost_step` proves rungs are
separated by *exactly* one Landauer quantum `T · log 2`, `tcost_strictMono` makes the
ladder strictly increasing, and `tcost_unbounded` makes it Archimedean-unbounded. The
**incompressibility** strand is a single geometric-sum pigeonhole: `geomSum_two_lt`
(`∑_{k<n} 2^k < 2^n`) feeds `shortDesc_card_lt`, giving `compressible_image_lt` (any
decoder of short descriptions reproduces `< 2^n` strings) and `incompressible_exists`
(an incompressible string therefore always exists). Because incompressibility holds at
*every* length while unboundedness *selects* a length, the capstone
`expensive_incompressible` is a clean conjunction with no extra work. The one design
decision that paid off repeatedly was keeping incompressibility universal in `n` rather
than asymptotic.

The cross-domain payoff is `decision_work_bound`: the proof of the sorting lower bound
never touched factorials — it used only `k ≤ 2^c` (a depth-`c` binary decision tree has
`≤ 2^c` leaves) and monotonicity of `log`. Abstracting the leaf count `k` turns one
lemma into a whole family: `thermodynamic_sorting_bound` (`k = n!`) and
`thermodynamic_searching_bound` (`k = n`) are now one-line instances, and selection
(`k = C(n,j)`) is immediate. The failure mode we kept hitting and fixing was
Mathlib-name collisions (`geom_lt`) and folding inductions into cardinality rewrites;
factoring pure arithmetic facts out as standalone lemmas resolved both.

## Results Summary

- `tcost_step`: proved — consecutive cost levels differ by exactly the Landauer quantum `T · log 2`.
- `tcost_strictMono`: proved — at positive temperature, thermodynamic cost is strictly increasing in proof length.
- `tcost_unbounded`: proved — a Chaitin-type statement: no energy budget bounds all cost levels.
- `geomSum_two_lt`: proved — the geometric bound `∑_{k<n} 2^k < 2^n` underlying all incompressibility counting.
- `shortDesc_card_lt`: proved — there are strictly fewer short descriptions (`2^n − 1`) than length-`n` strings (`2^n`).
- `compressible_image_lt`: proved — any decoder of descriptions of length `< n` reproduces strictly fewer than `2^n` strings.
- `incompressible_exists`: proved — an incompressible (maximally expensive) length-`n` string always exists.
- `expensive_incompressible`: proved — capstone: at some length, cost exceeds any budget AND incompressible strings exist.
- `decision_work_bound`: proved — master lemma: distinguishing `k` outcomes with `c` comparisons costs `≥ T · log k`.
- `thermodynamic_sorting_bound`: proved — comparison sorting of `n` elements costs `≥ T · log(n!)` of work.
- `thermodynamic_searching_bound`: proved — ordered searching among `n` items costs `≥ T · log n` of work.

## Research Directions

### Direction 1: Tight incompressibility fraction, not just existence
**Hypothesis**: For a decoder reading descriptions of length `≤ n − c`, the compressible
set has cardinality `≤ 2^{n−c+1} − 1`, so the incompressible fraction is `≥ 1 − 2^{1−c}`.
**Test**: Replace the `< n` threshold in `ShortDesc` by `≤ n − c` and recompute
`shortDesc_card_lt` as an exact geometric-sum cardinality; check `incompressible fraction
≥ 1 − 2^{1−c}` by dividing by `2^n`. Enumerate decoders for `n ≤ 12` and confirm no valid
decoder beats the bound.
**Why now**: `geomSum_two_lt` already isolates the exact counting lemma; upgrading `<` to
a parametrized geometric-sum bound needs no new Mathlib infrastructure.
**If true**: Incompressibility becomes the generic case with quantified density, not a
boundary curiosity — a verified density form of the Kolmogorov counting argument.
**If false**: A decoder beating `2^{1−c}` would expose an unexpected description-sharing
structure, refining what "short description" should mean.

### Direction 2: A thermodynamic complexity zoo with provable separations
**Hypothesis**: Cost classes `TPS[f] = { φ : tcost T (len φ) ≤ f(|φ|) }` form a strict,
gapless, linearly ordered hierarchy whose separations are exact multiples of `T · log 2`.
**Test**: Attach two concrete `len` functions (e.g. propositional-tautology vs.
arithmetic encodings) and prove their minimal-length functions diverge using
`tcost_strictMono` + `tcost_unbounded`. A bounded ratio between two encodings refutes
separation for that pair.
**Why now**: The ordered, gapless, unbounded spectrum is already verified; only concrete
`len` instances remain — a finite, computable comparison.
**If true**: A complexity zoo with *exact* (not asymptotic) separations, unusual among
complexity-theoretic hierarchies.
**If false**: A collapse `TPS[f] = TPS[f·ω]` would reveal a hidden compression mechanism
linking the two encodings.

### Direction 3: Selection and the full comparison lower-bound family
**Hypothesis**: `decision_work_bound` specialized to `k = C(n, j)` reproduces the
information-theoretic lower bound for `j`-selection, so sorting/searching/selection are
all instances of one thermodynamic law.
**Test**: Add `thermodynamic_selection_bound` as the `k = Nat.choose n j` instance
(`Nat.choose_pos` supplies `1 ≤ k`), and compare `T · log C(n,j)` against the known
selection lower bounds. A mismatch beyond the `log 2` rounding gap refutes the unification.
**Why now**: `decision_work_bound` is already parametric in the leaf count `k`; the
selection instance is a one-line specialization exactly like the sorting one.
**If true**: A single reusable cross-domain lemma subsumes the classical comparison-tree
lower bounds under Landauer's principle.
**If false**: A selection task violating `k ≤ 2^c` would mean comparisons are not the
right "bit" unit there, sharpening the model's scope.

### Direction 4: Energy landscape ruggedness from Hamming geometry
**Hypothesis**: With `E(s)` the Hamming distance from `s` to the nearest valid proof, the
number of strict local minima of `E` on `{0,1}^n` grows exponentially in `n` whenever the
valid set is sparse — the regime guaranteed by `incompressible_exists`.
**Test**: For `n ≤ 15`, enumerate strings, mark valid proofs from a toy resolution system,
compute `E`, count strict local minima, and fit `a · c^n`. If `c ≤ 1`, refuted. Formally,
bound the valid set via `compressible_image_lt` and lower-bound trapped vertices.
**Why now**: `compressible_image_lt` gives the verified sparsity input a local-minima
counting argument needs; the landscape claim is the geometric shadow of the counting one.
**If true**: Connects incompressibility to provable hardness of local proof search.
**If false**: Sparse valid sets without rugged landscapes would mean Hamming geometry
alone cannot explain search hardness.

### Direction 5: Quantum proofs save at most a polynomial factor of work
**Hypothesis**: For a quantum TPS whose proofs are density matrices on `{0,1}^n`,
`tcost_quantum(φ) ≥ tcost_classical(φ) / poly(|φ|)`.
**Test**: Model the verifier as extracting `≤ n` classical bits (Holevo cap) and reuse
the `expensive_incompressible` counting on the extracted certificates; pick a family
(e.g. graph non-isomorphism) and compute the cost ratio. A super-polynomial ratio refutes
the bound and flags genuine quantum thermodynamic advantage.
**Why now**: The classical core (`tcost`, `incompressible_exists`,
`expensive_incompressible`) is fully parametric in the proof-string type, so substituting
quantum proof objects is a clean extension rather than a rebuild.
**If true**: A thermodynamic no-free-lunch theorem bounding quantum proof speedups.
**If false**: An identified family with super-polynomial savings is exactly a quantum
thermodynamic advantage worth isolating.
