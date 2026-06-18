# FUTURE_DIRECTIONS.md — The Complexity Barrier Lattice

## Synthesis

This cycle contributes a single self-contained Lean 4 file,
`Catalog/Logic/ComplexityBarrierLattice.lean`, that formalizes the *algebraic skeleton*
shared by several complexity-theoretic phenomena. Rather than attacking concrete circuit
lower bounds, it isolates the structural facts that any such theory must satisfy and proves
them to completion (zero `sorry`, only the standard `propext` / `Classical.choice` /
`Quot.sound` axioms).

Three threads are developed and joined:

1. **Barriers as a commutative monoid.** A `ComplexityBarrier` is a ceiling together with a
   finite set of techniques bounded by that ceiling. Composition (max of ceilings, union of
   technique sets) is proved commutative and associative with the empty barrier as identity
   (`compose_comm`, `compose_assoc`, `compose_emptyBarrier`, `emptyBarrier_compose`), and the
   blocking relation distributes over composition (`compose_blocks_iff`).

2. **Relativization is Boolean-robust only under negation.** Oracle-dependent properties
   (true under some oracle, false under another) are closed under negation
   (`oracle_dependent_closed_negation`) and never absolute (`oracle_dependent_not_absolute`),
   capturing the symmetry of the Baker–Gill–Solovay barrier. Crucially we also prove the
   *negative* boundary result `oracle_dependent_not_closed_conjunction`: closure fails for
   conjunction, so negation is the genuine Boolean closure law.

3. **Counting and collapse.** The Boolean-function space has cardinality `2 ^ (2 ^ n)`
   (`card_boolFn`), giving an abstract Shannon pigeonhole `shannon_counting_lower_bound`: any
   indexed family of circuits smaller than this misses some function. Independently,
   `padding_collapse` shows that one local collapse plus upward stability forces a monotone
   hierarchy to be constant above that level — the skeleton behind `P = NP ⟹ EXP = NEXP`.

The deliberate limitation is that these are *structural* results; they describe the shape of
the theory without yet exhibiting a concrete hard function or a concrete oracle. The
directions below push toward that quantitative content.

## Research Directions

### Direction 1: A concrete circuit-counting bound to instantiate the Shannon pigeonhole

**Conjecture.** The number of Boolean circuits on `n` inputs using at most `s` binary gates
is bounded by `(c · (n + s)) ^ (2s)` for an explicit constant `c`; hence whenever
`(c · (n + s)) ^ (2s) < 2 ^ (2 ^ n)` there is a Boolean function computed by no circuit of
size `≤ s`. This turns `shannon_counting_lower_bound` from an abstract statement about an
arbitrary index type into a genuine size lower bound.

**Test (falsifiable).** Define an inductive `BoolCircuit n`, a `size` measure, and a
`Fintype` instance for "circuits of size `≤ s`". Prove the cardinality bound by induction on
`s`, then feed `Fintype.card {C // C.size ≤ s}` into `shannon_counting_lower_bound`. The
conjecture is false if the inductive type over- or under-counts (e.g. counts isomorphic DAGs
separately in a way that breaks the arithmetic).

**The key insight is** that the counting step is a pure combinatorial fact about labelled
DAGs, fully separable from the pigeonhole, which is already proved here.

**Why now?** The pigeonhole half is finished and axiom-clean; only the self-contained
counting lemma remains, and it needs no new Mathlib infrastructure.

### Direction 2: Instantiating oracle-dependence (Baker–Gill–Solovay)

**Conjecture.** There is an oracle property `P` — intended to read as "`P^O = NP^O`" under a
suitable abstract oracle machine model — that is `OracleDependent`, witnessed by two
explicit oracles `ℕ → Bool`. By `oracle_dependent_closed_negation`, the negated question is
equally unresolvable by relativizing methods.

**Test (falsifiable).** Define an abstract oracle-machine cost model, define `P^O` and `NP^O`
as predicate classes, and construct (a) a collapsing oracle and (b) a separating oracle via
diagonalization. Discharge `OracleDependent P` using the framework here. It fails if the
chosen cost model cannot simultaneously support both witnesses.

**The key insight is** that the abstract closure laws are already in place, so the residual
difficulty is purely *definitional*: pinning down `P^O`/`NP^O` and their time bounds.

**Why now?** `OracleDependent` and its negation-closure give the exact interface the
construction must hit, so the target is sharply specified.

### Direction 3: From monoid to bounded lattice on barriers

**Conjecture.** Adding a `meet` (min of ceilings, intersection of technique sets) makes
`ComplexityBarrier` a bounded distributive lattice under `(compose, meet)`, with the empty
barrier as bottom and the blocking relation order-compatible: `B₁ ≤ B₂ → (B₁.blocks t →
B₂.blocks t)`.

**Test (falsifiable).** Define `meet`, verify the barrier invariant survives it, and prove
absorption and distributivity by reducing to the distributive-lattice laws of `(max, min)`
on `ℕ` and `(∪, ∩)` on `Finset ℕ`. It fails if the `bounded` invariant forces a side
condition that breaks one absorption law (in which case barriers are only a semilattice with
extra structure).

**The key insight is** that `(max, min)` on `ℕ` and `(∪, ∩)` on `Finset` are each
distributive lattices, and this structure should lift componentwise to barriers.

**Why now?** `compose_comm` and `compose_assoc` already establish the join semilattice; the
meet is the immediate next algebraic layer.

### Direction 4: Instantiating `padding_collapse` for a concrete hierarchy

**Conjecture.** With `L k` the `k`-th level of an alternating polynomial-time quantifier
hierarchy, a level equality `L k = L (k+1)` satisfies the upward-stability hypothesis of
`padding_collapse`, so `Σ_k = Π_k` collapses every higher level to level `k`.

**Test (falsifiable).** Define `L : ℕ → Set _` via alternating quantifiers over a
polynomial-time predicate relation, prove the stability hypothesis by an explicit padding map,
and apply `padding_collapse`. It fails if formalizing the alternation requires a theory of
polynomial-time computation not expressible without further Mathlib development.

**The key insight is** that `padding_collapse` already encapsulates the entire inductive
argument; only the stability hypothesis needs a concrete padding witness.

**Why now?** The abstract collapse lemma is proved and axiom-clean, reducing the remaining
work to a single concrete hypothesis.

### Direction 5: Negation-closure as the unique Boolean closure law

**Conjecture.** Among the binary Boolean connectives, *only* those equivalent to negation /
biconditional preserve `OracleDependent` for all inputs; conjunction, disjunction, and
implication each admit explicit counterexamples (we already prove the conjunction case).

**Test (falsifiable).** For each connective, either prove closure or exhibit two
oracle-dependent properties whose combination is constant (mirroring
`oracle_dependent_not_closed_conjunction` with the oracles `O ↦ (O 0 = true)` and
`O ↦ (O 0 = false)`). The conjecture is false if some connective beyond the
negation/xor family turns out to be closed.

**The key insight is** that a connective preserves oracle-dependence exactly when it is
*sensitive* on both arguments over the witnessing oracle bits, which is a finite Boolean
check.

**Why now?** The counterexample template is already in the file; extending it to a full
classification is a short, self-contained combinatorial sweep over 16 connectives.
