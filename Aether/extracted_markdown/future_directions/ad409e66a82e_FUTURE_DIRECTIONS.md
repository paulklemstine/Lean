# FUTURE_DIRECTIONS.md — The Complexity-Barrier Lattice

## Synthesis

This cycle promoted the *commutative-monoid* view of complexity barriers (established in the
catalog: `barrier_composition_assoc`, `barrier_composition_comm`, `compose_blocks_iff`) to a
full **distributive lattice**. The decisive move was to recognise that max-ceiling composition
is only the *join* of a two-sided algebra: there is a dual *meet* given by min-ceiling
composition, and together the `ceiling` map carries the barrier algebra homomorphically onto
the distributive lattice `(ℕ, max, min)`.

The new file `Catalog/Logic/BarrierLattice.lean` proves this completely (zero `sorry`):
commutativity, associativity, idempotence, both absorption laws, and distributivity all hold
on ceilings, while the blocking relation reveals a clean logical duality — a join blocks a
target iff *both* components block it (∧), a meet blocks iff *either* does (∨), and blocking
is antitone in the ceiling order. A cross-domain bridge (`shannon_barrier_incomplete`,
`card_boolFn`) connects the lattice back to Shannon counting: a finite technique inventory is
always incomplete below `2 ^ 2 ^ n`, furnishing exactly the hard targets the lattice reasons
about.

The structural payoff is conceptual unification: relativization, naturalization, and counting
obstructions are not isolated facts but *points of one distributive lattice*, and Boolean
reformulations of the P-vs-NP question correspond to lattice operations on barriers. The main
limitation remains that the theory is structural — it organises obstructions algebraically
rather than producing concrete superpolynomial lower bounds.

## Results Summary

| Theorem | Status | Significance |
|---|---|---|
| `join_blocks_iff` | proved | Join blocks ⇔ both components block (∧ duality) |
| `meet_blocks_iff` | proved | Meet blocks ⇔ either component blocks (∨ duality) |
| `blocks_of_le_of_blocks` | proved | Blocking is antitone in the ceiling order |
| `join_comm_ceiling`, `meet_comm_ceiling` | proved | Commutativity of join/meet |
| `join_assoc_ceiling`, `meet_assoc_ceiling` | proved | Associativity of join/meet |
| `join_idem_ceiling`, `meet_idem_ceiling` | proved | Idempotence of join/meet |
| `join_meet_absorb`, `meet_join_absorb` | proved | Both absorption laws |
| `join_distrib_meet_ceiling` | proved | Distributivity ⇒ *distributive* lattice |
| `card_boolFn` | proved | `\|BoolFn n\| = 2 ^ 2 ^ n` |
| `shannon_barrier_incomplete` | proved | Finite technique inventory omits a hard function |

## Research Directions

### Direction 1: Promote the ceiling homomorphism to a bundled `DistribLattice` instance

**Hypothesis.** The quotient of `Barrier` by ceiling-equality carries a genuine Mathlib
`DistribLattice` instance, with `⊔ = join`, `⊓ = meet`, and `≤ = Barrier.le`, such that the
`ceiling` map becomes a `LatticeHom` onto `ℕ`.

**Test.** Define `BarrierClass := Quotient (ceiling-setoid)`, transport `join`/`meet` through
the quotient using the absorption and distributivity lemmas already proved, and discharge the
Mathlib `DistribLattice` field obligations. Then build `BarrierClass →o ℕ` and upgrade it to a
`LatticeHom`.

**Why now?** All ten lattice laws on ceilings are already proved in this cycle; the only
remaining work is the quotient bookkeeping and matching Mathlib's bundled-structure API.

The key insight is that ceiling-equality is exactly the congruence that collapses the
incidental `Technique`/`Strength` data, leaving precisely the `(ℕ, max, min)` lattice — so the
instance is forced, not invented.

**If false:** would reveal that `Barrier.le` is only a preorder (antisymmetry failing on the
non-quotiented type), pinpointing exactly which lattice axiom resists bundling.

### Direction 2: A residual / Heyting structure for "barrier subtraction"

**Hypothesis.** The barrier lattice admits a relative pseudo-complement `B₁ ⇨ B₂` (the
weakest barrier whose join with `B₁` still blocks everything `B₂` blocks), making the ceiling
algebra a **Heyting algebra**, with `(B₁ ⇨ B₂).ceiling` computable from `B₁.ceiling` and
`B₂.ceiling`.

**Test.** Define `Barrier.imp` with ceiling `if c₁ ≤ c₂ then maxⁿ else c₂` (the order-theoretic
residual of max on a bounded interval), and prove the adjunction
`(B₁.join X).le B₂ ↔ X.le (B₁.imp B₂)` at the ceiling level.

**Why now?** Distributivity is established, which is the precondition for residuation to be
well-defined; the adjunction is then a finite ℕ inequality discharged by `omega`.

The key insight is that "which extra technique class would suffice to overcome `B₂` once `B₁`
is given" is precisely a residuation question, turning informal barrier-combination reasoning
into algebraic implication.

**If false:** would show max on ℕ lacks the needed residual within the relevant bounded range,
indicating barriers form a distributive lattice but not a Heyting algebra.

### Direction 3: Instantiate the lattice with the three canonical barriers

**Hypothesis.** Concrete `Barrier` values `relativization`, `naturalProofs`, and
`algebrization` can be built from the catalog's oracle, Shannon-counting, and circuit data so
that their pairwise joins/meets reproduce the known qualitative facts (e.g. relativization ∧
naturalization is strictly harder to bypass than either alone).

**Test.** Use `OracleProperty` (catalog `PvsNPFoundations`) to define the relativization
barrier's technique space, the largeness/usefulness predicates (catalog `isLarge`,`isUseful`)
for natural proofs, and circuit-size data for algebrization; compute the joins and verify the
blocking statements via `join_blocks_iff`/`meet_blocks_iff`.

**Why now?** The abstract lattice and the concrete catalog ingredients both exist; the gap is
purely the wiring of one onto the other.

The key insight is that the abstract `blocks` predicate is already the right interface — each
concrete barrier only needs to expose its ceiling, after which all combination reasoning is
inherited from the lattice for free.

**If false:** would identify which canonical barrier resists the `ceiling : ℕ` abstraction
(likely algebrization, whose strength is naturally a degree, not a size).

### Direction 4: Quantitative targets from circuit counting feed the lattice

**Hypothesis.** Bounding the number of circuits of size `≤ s` on `n` inputs by an explicit
`(c·(n+s))^s` and combining with `shannon_barrier_incomplete` yields a concrete target
`t(n) = 2^n /(2n)` such that the "size-`s` circuits" barrier provably `blocks t(n)` for
`s < t(n)`.

**Test.** Formalize `circuitCount_le : (circuits of size ≤ s).card ≤ (c*(n+s))^s`, instantiate
`shannon_barrier_incomplete` with the image inventory, and read off a `Barrier` whose ceiling
is `s` and which `blocks` the counting target.

**Why now?** The pigeonhole half is already proved (`shannon_barrier_incomplete`); only the
combinatorial DAG-counting bound remains, and it is independent of the lattice machinery.

The key insight is that counting and algebra are cleanly separable: the lattice consumes a
numeric target, and Shannon counting is exactly the engine that manufactures one.

**If false:** would expose an over/under-counting flaw in the inductive `BoolCircuit` model
(e.g. structurally distinct circuits computing identical functions inflating the inventory).

### Direction 5: Order-dual collapse — meets and the polynomial hierarchy

**Hypothesis.** The meet (min-ceiling) operation models hierarchy *collapse*: if two adjacent
hierarchy levels coincide, the associated barriers' meet has the lower ceiling, and iterating
the meet reproduces the upward propagation captured abstractly by the catalog's
`padding_collapse` / `hierarchy_collapse`.

**Test.** Map each hierarchy level to a `Barrier` whose ceiling encodes its separation
strength, show level-equality ⇒ ceiling-equality, and derive the collapse chain from
`meet_idem_ceiling` plus `blocks_of_le_of_blocks`.

**Why now?** Both the abstract collapse theorem (catalog) and the meet algebra (this cycle)
exist; connecting them needs only the level-to-ceiling encoding.

The key insight is that collapse is *idempotence in disguise*: once two levels share a
ceiling, every meet with that ceiling is fixed, which is exactly why collapse propagates.

**If false:** would indicate that hierarchy strength is not faithfully captured by a single ℕ
ceiling and needs the full strength *function*, not just its supremum.
