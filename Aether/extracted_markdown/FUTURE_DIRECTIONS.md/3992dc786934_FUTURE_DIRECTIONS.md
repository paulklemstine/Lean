# Future Directions — Topological Vaught Dichotomy

## Synthesis

This cycle attacked Vaught's Conjecture through its *topological* incarnation. The
conjecture itself ("a countable first-order theory has countably many or exactly
`2^ℵ₀` countable models") is open in full generality, and so is its modern
topological form (the orbit-counting dichotomy for arbitrary Polish group
actions). What *is* a ZFC theorem — and what turned out to be cleanly
formalizable — is the **perfect set property for closed sets in Polish spaces**:
the dichotomy "countable or `≥ 𝔠`" with no cardinality strictly in between. This
is the positive core on which every serious attack on Vaught's conjecture rests
(Cantor–Bendixson derivative, Morley's analysis of the type space).

The decisive structural insight is that the entire dichotomy collapses onto a
single cardinal inequality. Mathlib's `IsClosed.exists_nat_bool_injection_of_not_countable`
packages Cantor–Bendixson plus a Cantor scheme into a continuous injection of the
Cantor space `ℕ → Bool` into any uncountable closed set; once that injection is in
hand, `cantorSpace_mk : #(ℕ → Bool) = 𝔠` and `Cardinal.mk_le_of_injective` finish
the job in two lines. Everything else (whole-space form, exact-cardinality
refinement, the concrete `ℝ` instance, and the model-theoretic bridge) is a
specialization of that one lemma.

What failed/where the boundary sits: the canonical "space of countable models" is
the Cantor space, but Mathlib deliberately does **not** register a global
`PolishSpace (ℕ → Bool)` instance (the product metric would create a diamond), so
the cleanest corollary had to be re-routed through `ℝ` (`mk_real`). More
fundamentally, the model-theoretic bridge `completeType_dichotomy` must *assume*
the Stone space `CompleteType T β` is Polish: Mathlib has the type-space topology
and total separation, but **not** its compactness (the compactness theorem) or
metrizability. That missing instance is precisely where Morley's theorem does its
real work, and it is the natural next target.

## Results Summary

- `cantorSpace_mk`: proved — `#(ℕ → Bool) = 𝔠`, pinning the cardinality of the Cantor-scheme witness.
- `polishClosed_countable_or_continuum_le`: proved — MAIN: a closed subset of a Polish space is countable or has `≥ 𝔠` points (perfect set property / topological Vaught core).
- `polish_countable_or_continuum_le`: proved — whole-space form: a Polish space has countably many or `≥ 𝔠` points.
- `polishClosed_dichotomy_exact`: proved — with a `#α ≤ 𝔠` ceiling, "≥ 𝔠" sharpens to "= 𝔠", the exact "countable or continuum".
- `real_closed_dichotomy`: proved — classical concrete instance: closed subsets of `ℝ` are countable or of cardinality `𝔠`.
- `completeType_dichotomy`: proved — model-theoretic bridge: closed sets of complete types over a countable theory obey the dichotomy whenever the Stone space is Polish.
- `analyticVaught_conjecture`: conjecture (sorry) — the dichotomy for analytic sets (Suslin's PSP), not yet reduced to the closed case.
- `orbitVaught_conjecture`: conjecture (sorry) — the genuinely open orbit-counting form, in Cantor-coded shape.

## Research Directions

### Direction 1: Make the Stone space of types Polish for countable languages
**Hypothesis**: For a countable language `L` and countable `β`, `CompleteType T β`
is a compact, metrizable, second-countable (hence Polish) space, so
`completeType_dichotomy` discharges *unconditionally* and yields the exact
"countable or `2^ℵ₀` complete types".
**Test**: Build `CompactSpace (CompleteType T β)` from the model-theoretic
compactness theorem (or from `IsClosed` in `Sentence → Bool` under Stone duality),
add `SecondCountableTopology` from countability of `L[[β]].Sentence`, and derive
metrizability of a compact Hausdorff second-countable space.
**Why now**: This cycle reduced the model-theoretic question entirely to "is the
Stone space Polish?" — the only missing instance. Mathlib already supplies the
topology and total separation.
**If true**: Vaught's dichotomy holds verbatim for the count of complete
1-types/n-types in any countable theory — the first fully unconditional
model-theoretic instance.
**If false**: It would expose a non-compactness phenomenon in Mathlib's type
topology (likely a definitional mismatch), itself worth documenting.

### Direction 2: Analytic perfect set property (discharge `analyticVaught_conjecture`)
**Hypothesis**: Every analytic subset of a Polish space is countable or contains a
perfect set, hence has cardinality `𝔠`.
**Test**: Prove `MeasureTheory.AnalyticSet C → C.Countable ∨ 𝔠 ≤ #C` via a Cantor
scheme adapted to a Suslin representation (a tree of approximations), reusing the
`CantorScheme`/`inducedMap` machinery that already powers the closed case.
**Why now**: The closed-set proof here is *exactly* the perfect-set kernel; the
analytic case is the same Cantor scheme run over a Suslin tree, so the
infrastructure is one generalization away.
**If true**: Extends the dichotomy to the full definable hierarchy used in
descriptive set theory, covering orbit equivalence classes that are analytic.
**If false** (in some model without choice/large cardinals): pinpoints the exact
set-theoretic strength needed, sharpening the ZFC boundary.

### Direction 3: Cantor space as a first-class Polish witness
**Hypothesis**: One can register (locally, via `letI`) `PolishSpace (ℕ → Bool)`
through `PiNat.metricSpace` + completeness + second countability, giving a
diamond-free *bundled* statement `cantorClosed_dichotomy`.
**Test**: Assemble `MetricSpace`, `CompleteSpace`, `SecondCountableTopology` for
`ℕ → Bool` from `PiNat`, prove `#C = 𝔠` for closed `C`, and check no instance
diamond leaks into downstream proofs.
**Why now**: We hit this wall directly — the only reason the natural "space of
models" corollary was replaced by `ℝ`. The components all exist in `PiNat`.
**If true**: Restores the most natural statement of the dichotomy on the space
that literally codes countable structures.
**If false**: Confirms the diamond hazard and validates the `ℝ`-routing choice.

### Direction 4: The Cantor–Bendixson rank as a quantitative witness
**Hypothesis**: A closed set is countable iff its Cantor–Bendixson derivative
sequence terminates at a countable ordinal with empty residual; the residual
(perfect kernel) is nonempty exactly in the `𝔠` case.
**Test**: Formalize the transfinite derivative `C^{(α)}` and prove
`C.Countable ↔ ∃ α, C^{(α)} = ∅`, turning the binary dichotomy into a ranked
invariant.
**Why now**: `exists_countable_union_perfect_of_isClosed` already gives the
perfect-kernel decomposition in one step; iterating it transfinitely is the
natural refinement and connects to the Logic catalog's ordinal machinery
(`StronglyCriticalOrdinals`, `TransfiniteRefinement`).
**If true**: Provides the *rank* that Morley's theorem assigns to scattered
theories, the quantitative skeleton of Vaught's analysis.
**If false**: Would indicate the derivative does not stabilize as expected — a red
flag about the formalized definition.

### Direction 5: Towards the open orbit conjecture (`orbitVaught_conjecture`)
**Hypothesis**: If a continuous action of a Polish group `G` on a Polish space
`X` has all orbits closed (a "smooth" or "tame" action), then the number of
orbits is countable or `𝔠`.
**Test**: Show the orbit space (quotient by a closed-orbit equivalence relation)
embeds into a Polish space and apply `polishClosed_dichotomy_exact`; the genuinely
open part is dropping "closed orbits".
**Why now**: The closed-orbit special case is *already within reach* of this
cycle's theorems — it isolates exactly which hypothesis (closedness of orbits)
must be removed to reach the open frontier.
**If true**: Settles the tame fragment of the topological Vaught conjecture and
makes precise what remains open (non-smooth actions, where `E_0`-type obstructions
live).
**If false**: A counterexample with closed orbits would be a sensational
refutation; far more likely it teaches us the embedding step needs Borel rather
than continuous structure.
