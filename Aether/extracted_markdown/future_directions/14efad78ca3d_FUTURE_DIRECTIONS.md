# FUTURE_DIRECTIONS.md — Complexity Barrier Lattice Research

## Synthesis

This cycle produced 12 fully proved theorems (zero sorry) formalizing the algebraic
structure of complexity barriers and their interactions with oracle separation,
circuit counting, and hierarchy collapse. The key structural insight is that
complexity barriers compose as a commutative monoid under max-ceiling composition,
and this algebraic structure is robust: oracle-dependent properties are closed under
Boolean operations (negation, conjunction), meaning the relativization barrier
cannot be circumvented by logical reformulation of the P vs NP question.

The Shannon counting argument was made constructive via Finset pigeonhole, and the
padding collapse theorem captures the common proof pattern behind results like
"P = NP ⟹ EXP = NEXP" at a fully abstract level. All proofs are machine-verified
in Lean 4 with Mathlib.

The main limitation is that these results operate at the structural/algebraic level
rather than proving concrete circuit lower bounds for specific functions. The next
cycle should push toward quantitative bounds.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `oracle_dependent_closed_negation` | proved | Relativization barrier is symmetric under negation |
| `oracle_dependent_not_absolute` | proved | Oracle-dependent properties are not absolute |
| `oracle_dependent_closed_conjunction` | proved | Oracle-dependent closure under conjunction |
| `barrier_composition_assoc` | proved | Barriers form a monoid (associativity) |
| `barrier_composition_comm` | proved | Barrier composition is commutative |
| `compose_no_technique_exceeds` | proved | No technique in composed barrier exceeds ceiling |
| `compose_blocks_iff` | proved | Composition blocks iff both components block |
| `card_boolFn` | proved | Cardinality of Boolean functions = 2^(2^n) |
| `shannon_counting_lower_bound` | proved | Pigeonhole for circuit lower bounds |
| `shannon_counting_explicit` | proved | Shannon bound with explicit cardinality |
| `ComplexityHierarchy.level_le` | proved | Hierarchy monotonicity extends to arbitrary gaps |
| `padding_collapse` | proved | Hierarchy collapse propagates upward |

## Research Directions

### Direction 1: Quantitative Circuit Size Bounds via Counting

**Hypothesis**: The number of Boolean circuits with at most s gates on n inputs is at most
(c · (n + s))^s for some explicit constant c, and therefore when s < 2^n / (2n),
there exists a Boolean function requiring more than s gates.

**Test**: Formalize `BoolCircuit.count_bounded` bounding the number of circuits of size ≤ s,
then combine with `shannon_counting_lower_bound` to get an explicit lower bound theorem
`∃ f : BoolFn n, ∀ C : BoolCircuit n, C.computedFn = f → C.size > s`.

**Why now**: The Shannon pigeonhole infrastructure is complete. What remains is purely the
circuit counting argument — bounding the number of distinct circuit DAGs of bounded size.

**If true**: Gives the first formalized quantitative circuit lower bound in Lean 4.
**If false**: Would reveal a flaw in our circuit model (possibly that our inductive type
over-counts or under-counts circuits).

The key insight is that the circuit counting bound is a pure combinatorial argument
about trees, separable from the Shannon pigeonhole which is already proved.

### Direction 2: Oracle Separation Instantiation (Baker-Gill-Solovay)

**Hypothesis**: There exist concrete oracle constructions (as functions ℕ → Bool) such that
one makes a specific oracle property true and another makes it false, instantiating
`oracle_dependent_closed_negation` with the actual P^A = NP^A and P^B ≠ NP^B constructions.

**Test**: Define `PeqNP_oracle : OracleProperty := fun O => P^O = NP^O` using a suitable
abstract model of oracle Turing machines, then construct specific oracles witnessing both
directions.

**Why now**: The abstract oracle framework is complete. The gap is defining what P^O and NP^O
mean concretely in our formalization.

**If true**: First formalized Baker-Gill-Solovay theorem in Lean 4.
**If false**: Would identify which aspects of oracle computation are hardest to formalize
(likely the definition of oracle Turing machines and their time complexity).

The key insight is that the abstract framework is in place; the challenge is purely
definitional — connecting abstract oracle properties to concrete complexity classes.

### Direction 3: Barrier Lattice with Strength Ordering

**Hypothesis**: The barrier composition operation, extended to track the full strength
function (not just the ceiling), forms a bounded lattice where the join is the current
compose and the meet is defined by min on ceilings. Furthermore, the lattice has a
natural partial order where B₁ ≤ B₂ iff B₁.ceiling ≤ B₂.ceiling, and this order
is compatible with the blocking relation.

**Test**: Define `ComplexityBarrier.meet` using min instead of max, prove it satisfies
barrier axioms, and prove the lattice laws (absorption, distributivity where applicable).

**Why now**: `barrier_composition_assoc` and `barrier_composition_comm` establish the monoid
structure. The meet operation is the natural next algebraic structure.

**If true**: Provides a complete algebraic theory of barrier interactions, enabling
automated reasoning about which combinations of barriers suffice to block a given target.
**If false**: Would mean barriers have a more complex algebraic structure than a lattice
(possibly a semilattice with additional conditions).

The key insight is that max and min on ℕ form a distributive lattice, and this structure
should lift to barriers.

### Direction 4: Padding Collapse with Explicit Padding Functions

**Hypothesis**: The abstract `padding_collapse` theorem can be instantiated with concrete
padding functions for the polynomial hierarchy, proving that if Σ_k^p = Π_k^p then
PH collapses to level k, using Lean's existing polynomial and complexity infrastructure.

**Test**: Define the polynomial hierarchy levels using alternating quantifiers over
polynomial-time predicates, construct explicit padding maps, verify the stability condition.

**Why now**: The abstract collapse infrastructure is complete. The remaining work is defining
the polynomial hierarchy concretely.

**If true**: First formalized polynomial hierarchy collapse theorem in Lean 4.
**If false**: Would reveal that formalizing alternating quantifier hierarchies in Lean
requires infrastructure not yet in Mathlib (e.g., a theory of polynomial-time computation).

The key insight is that `padding_collapse` already captures the inductive structure;
what remains is connecting it to concrete definitions.

### Direction 5: Communication Complexity Lower Bound for Inner Product

**Hypothesis**: The inner product function IP(x,y) = ⊕_i (x_i ∧ y_i) over F_2^n
requires Ω(n) bits of deterministic communication, provable via a monochromatic
rectangle argument combined with the parity sensitivity results already in the codebase.

**Test**: Define `innerProduct : BoolFn (2*n)`, prove that any monochromatic rectangle
for IP has at most 2^n elements, conclude that at least 2^n rectangles are needed,
giving communication complexity ≥ n.

**Why now**: The rectangle cover framework exists in `PvsNPFoundations.lean` and parity
sensitivity is proved in `CircuitComplexityBarriers.lean`. The inner product combines both.

**If true**: First formalized communication complexity lower bound in Lean 4, with direct
implications for circuit depth lower bounds via the Karchmer-Wigderson connection.
**If false**: Would indicate that the monochromatic rectangle counting argument needs
more careful handling of the F_2 structure.

The key insight is that inner product's communication complexity is exactly n, provable
by a rank argument over F_2 that translates to a rectangle counting argument.
