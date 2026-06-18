# FUTURE_DIRECTIONS.md — The Complexity Barrier Lattice

## Synthesis

This cycle formalized, with **zero `sorry`** and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`), the lattice-theoretic structure of
complexity barriers and the robustness of the relativization barrier under logical
reformulation. The work lives in `Logic/ComplexityBarrierLattice.lean` and extends
the catalog files `Logic/CircuitComplexityBarriers.lean` (the `ComplexityBarrier`
structure and its `compose`/join) and `Logic/PvsNPFoundations.lean` (the
`OracleProperty` relativization framework and `oracle_barrier`).

The central new object is `ComplexityBarrier.meet`, the order-theoretic dual of the
catalog's `compose`. Where `compose` keeps techniques strong against *either*
component (a `max` of ceilings), `meet` keeps only what is strong against *both*
(a `min`). The two operations make the ceilings of barriers a **distributive
lattice**: we prove associativity and commutativity of meet, both absorption laws,
and distributivity of join over meet. The most conceptually clean result is the
**blocking duality**: a join blocks a target iff *both* components block it
(`compose_blocks_iff`, an iff-strengthening of the catalog's one-directional
`compose_blocks_of_both_block`), while a meet blocks iff *either* does
(`meet_blocks_iff`). On the relativization side we prove the oracle-dependent
class is closed under negation (an involution) and conjunction, and conclude
`relativization_barrier_robust`: reformulating an oracle-dependent question by
negation keeps it non-absolute, so the Baker–Gill–Solovay barrier cannot be
escaped by logical sleight of hand.

The main limitation is the same as the catalog's: these are *structural* results
about the algebra of barriers and oracle properties, not concrete circuit lower
bounds for explicit functions. The directions below push toward closing that gap
and toward upgrading the ceiling-level lattice to a genuine order-theoretic
instance in Mathlib's hierarchy.

## Results delivered this cycle

| Theorem | Status | Significance |
|---------|--------|-------------|
| `ComplexityBarrier.meet` | def | Dual of `compose`; the missing lattice operation |
| `compose_blocks_iff` | proved | Join blocks ⇔ both block (iff-upgrade of catalog) |
| `meet_blocks_iff` | proved | Meet blocks ⇔ either blocks (the dual) |
| `compose_ceiling_assoc` | proved | Join semilattice associativity |
| `meet_ceiling_assoc` | proved | Meet semilattice associativity |
| `meet_ceiling_comm` | proved | Meet commutativity (dual of `compose_ceiling_comm`) |
| `absorption_compose_meet` | proved | Absorption law I |
| `absorption_meet_compose` | proved | Absorption law II |
| `compose_meet_ceiling_distrib` | proved | Distributivity (the lattice is distributive) |
| `meet_le_compose_ceiling` | proved | Induced order `meet ≤ join` |
| `oracle_dependent_closed_negation` | proved | Relativization symmetric under negation |
| `oracle_dependent_negation_involution` | proved | Negation is an involution on dependence |
| `oracle_dependent_closed_conjunction` | proved | Dependence closed under conjunction |
| `oracle_dependent_not_absolute` | proved | Self-contained re-proof of the barrier |
| `relativization_barrier_robust` | proved | Barrier immune to logical reformulation |

## Research Directions

### Direction 1: Promote the ceiling lattice to a Mathlib `DistribLattice` instance

**Hypothesis.** Define the quotient of `ComplexityBarrier` by ceiling-equality
(`B₁ ≈ B₂ ↔ B₁.ceiling = B₂.ceiling`) and equip the quotient with
`⊔ := compose`, `⊓ := meet`. All lattice axioms have already been proved on
representatives this cycle, so the quotient should support a bona fide
`DistribLattice` instance, after which Mathlib's lattice automation
(`le_sup_left`, `inf_le_sup`, lattice `omega`-style reasoning) becomes available
for free.

**Test.** Construct `BarrierClass := Quotient barrierSetoid`, lift `compose` and
`meet` with `Quotient.lift₂`, and discharge `Lattice.le_antisymm`,
`sup_le`, `le_inf`, and the absorption fields using `absorption_compose_meet`,
`absorption_meet_compose`, and `compose_meet_ceiling_distrib`. Verify
`OrderBot` holds with the zero-ceiling barrier as `⊥`.

**Why now.** Every algebraic law required for the instance (`assoc`, `comm`,
absorption, distributivity, the order `meet_le_compose_ceiling`) is now a proved
theorem in `ComplexityBarrierLattice.lean`. The only remaining work is the
quotient plumbing — no new mathematics.

**If true:** the barrier algebra plugs into Mathlib's order hierarchy, enabling
automated reasoning about which *combinations* of barriers suffice to block a
target. **If false:** ceiling-equality fails to respect one operation, revealing
that barriers carry strictly finer structure than their ceilings (a semilattice
with side conditions rather than a quotient lattice).

The key insight is that `(ℕ, max, min)` is already a distributive lattice in
Mathlib, and `compose`/`meet` are *exactly* `max`/`min` transported along the
`ceiling` projection — so the lattice structure descends through the quotient by
construction.

### Direction 2: A quantitative blocking calculus for finite barrier families

**Hypothesis.** For a finite indexed family `B : Fin k → ComplexityBarrier`, the
iterated join blocks a target `t` iff *every* member blocks `t`, and the iterated
meet blocks `t` iff *some* member does — i.e. `compose_blocks_iff` and
`meet_blocks_iff` lift verbatim to `Finset.sup`/`Finset.inf` over the family, with
ceiling `Finset.sup i (B i).ceiling` and `Finset.inf i (B i).ceiling`.

**Test.** Define `bigCompose` and `bigMeet` by `Finset.fold` over the family,
prove `(bigCompose B).blocks t ↔ ∀ i, (B i).blocks t` and the dual, and derive a
decision procedure: a target is blocked by the family's join iff it exceeds
`Finset.sup` of the ceilings.

**Why now.** The two binary blocking laws are proved and are pure `max`/`min`
facts; `Finset.sup`/`Finset.inf` over `ℕ` already satisfy the matching
`Finset.sup_lt_iff` / `Finset.lt_inf_iff` lemmas in Mathlib, so the induction is
mechanical.

**If true:** gives a literal algorithm answering "does this collection of known
barriers rule out a proof of strength `t`?" **If false:** the empty-family base
case (`⊥`/`⊤` conventions) forces a `Nonempty` hypothesis, sharpening exactly when
the calculus applies.

The key insight is that blocking is a threshold predicate on a single number (the
ceiling), so finite blocking reduces to `Finset.sup`/`Finset.inf` comparisons that
Mathlib already automates.

### Direction 3: Instantiate the lattice with the three classical barriers

**Hypothesis.** The relativization, natural-proofs, and algebrization barriers can
each be realized as a concrete `ComplexityBarrier` whose `ceiling` is the largest
circuit-size lower bound that family of techniques can certify, and their pairwise
`meet`/`compose` ceilings then encode known facts such as "algebrization subsumes
relativization" as `meet`/order relations between the instances.

**Test.** Build `relativizationBarrier`, `naturalProofsBarrier`,
`algebrizationBarrier : ComplexityBarrier` with `Technique` types modeling oracle
constructions, large-and-constructive properties (reusing `CircuitComplexity.isLarge`
and `isUseful`), and algebraic oracle extensions; then prove
`meet_le_compose_ceiling` specializes to the containment hierarchy among them.

**Why now.** The abstract `ComplexityBarrier` interface plus `meet`/`compose` is
complete, and `CircuitComplexity` already supplies `isLarge`/`isUseful` for the
natural-proofs technique space — the instances only need a `Strength` function and
a `ceiling` witness.

**If true:** first formal statement, inside one lattice, of how the three P-vs-NP
barriers relate. **If false:** would expose that one barrier's "strength" is not
faithfully a single natural number (e.g. natural proofs needs a *pair*: largeness
fraction and size bound), motivating a multi-graded barrier.

The key insight is that the order `meet_le_compose_ceiling` is exactly the
"barrier A is weaker than barrier B" relation, so the textbook subsumption
statements become provable inequalities once the ceilings are pinned down.

### Direction 4: Boolean-algebra closure of oracle-dependence

**Hypothesis.** The oracle-dependent properties do *not* form a Boolean
subalgebra of `OracleProperty`: closed under negation (proved) but **not** under
unconditional conjunction. There exist `P`, `Q` each oracle-dependent whose
conjunction is absolute (constantly false), witnessing the failure.

**Test.** Take `P O := O 0 = true` and `Q O := O 0 = false`; both are
oracle-dependent, yet `fun O => P O ∧ Q O` is constantly false, hence absolute.
Formalize this as `oracle_dependent_not_closed_under_conjunction`, the sharp
counterexample to dropping the shared-witness hypotheses of
`oracle_dependent_closed_conjunction`.

**Why now.** `oracle_dependent_closed_negation` and the *conditional*
`oracle_dependent_closed_conjunction` are proved; the natural next question — is
the hypothesis necessary? — has a one-line concrete witness using oracles as plain
`ℕ → Bool` functions.

**If true:** delineates exactly how much Boolean structure the relativization
barrier respects (a "negation-closed but not ∧-closed" system). **If false (it is
true):** the search for a counterexample would instead force a proof of closure,
contradicting the explicit witness — a useful disproof sanity check.

The key insight is that negation merely swaps the two witnesses an
oracle-dependent property already carries, whereas conjunction can annihilate them
— so closure under `¬` is robust but closure under `∧` is genuinely conditional.

### Direction 5: From the abstract lattice to a Shannon-counting barrier instance

**Hypothesis.** The Shannon counting argument already in the catalog
(`CircuitComplexity.card_boolFn`, `shannon_lower_bound_abstract`,
`hard_function_exists`) yields a *concrete* `ComplexityBarrier` instance whose
ceiling is the size threshold `s(n)` below which a finite circuit set cannot cover
all `2^(2^n)` Boolean functions, and whose `compose` with any other barrier obeys
the proved blocking laws.

**Test.** Define `shannonBarrier n : ComplexityBarrier` with `Technique` the
circuits of size `≤ s(n)`, `Strength` the size, and `ceiling := s(n)`; prove its
`blocks` predicate matches `hard_function_exists` via `compose_blocks_iff`, giving
a barrier whose ceiling is *certified* by counting rather than postulated.

**Why now.** Both halves exist and are proved: the counting infrastructure in
`CircuitComplexityBarriers.lean` and the blocking calculus in
`ComplexityBarrierLattice.lean`. The bridge is a single instance plus one rewrite.

**If true:** the first barrier in the lattice whose ceiling is a *theorem*, not a
parameter, turning the algebra into a tool with concrete content. **If false:**
the counting bound's dependence on `n` does not fit a fixed `ceiling : ℕ`,
indicating the lattice should be indexed/graded by input length `n`.

The key insight is that Shannon's bound is precisely a statement "no technique of
size below `s(n)` reaches the target," which is the defining shape of a
`ComplexityBarrier.blocks` fact — so counting *is* a barrier, already in the
lattice.
