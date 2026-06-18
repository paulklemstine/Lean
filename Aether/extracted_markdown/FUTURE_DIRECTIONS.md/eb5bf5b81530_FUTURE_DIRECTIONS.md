# Future Directions: Proof System Collapse Theory

## Synthesis

This cycle built, from a cold start, the abstract simulation preorder at the core
of the Cook–Reckhow program in proof complexity, in the new file
`Catalog/Logic/ProofSystemCollapse.lean`. We model an abstract `ProofSystem` over
a fixed theorem type `T`, a parametric `BoundClass` of admissible proof-size
blowup functions, and the p-simulation relation `Simulates B P Q` ("`P` is at
least as powerful as `Q`"). The central finding is that the *entire* preorder
structure rests on exactly two closure properties of the bound class —
`contains_id` (reflexivity) and `comp_closed` together with `mono` (transitivity).
No arithmetic, no polynomials, and no model of computation are needed for the
order-theoretic skeleton; concrete classes such as "all monotone functions"
(`allMonotone`) are merely instances.

The structural payoff is the collapse theorem: mutual simulation is an
equivalence relation (`equiv_equivalence`), and the quotient `Degree B T` carries
a genuine `PartialOrder` (`Degree.partialOrder`). The word "collapse" is literal —
it is the quotient construction. Critically, antisymmetry *fails* on the raw
systems (`le_not_antisymm`): two systems over `Unit` differing only by a size
relabelling (`0` vs `1`) simulate each other yet are unequal. That failure is
exactly what forces the quotient and identifies the *degree* — not the system —
as the correct invariant object. The bounded structure (`le_top_system`,
`bot_system_le`) shows there is a greatest "trivial" system that proves everything
in one step and a least empty system, so degrees form a bounded poset.

What did not fit this cycle: the existence of a maximal degree (an optimal proof
system) is the famous open Krajíček–Pudlák question, left as a conjecture below.
The abstraction makes precise what such an element would be — a top of
`Degree.partialOrder` — and isolates exactly which concrete ingredient (an
effective universal bound) is missing from the order-theoretic core.

## Results Summary

- `sim_refl` — simulation is reflexive; reflexivity *is* the `contains_id` axiom.
- `sim_trans` — simulation composes via composition of bounds, using `comp_closed` and `mono`.
- `preorder` — packages `Simulates` into a `Preorder` for any bound class.
- `equiv_equivalence` — mutual simulation is an equivalence relation.
- `le_respects` — simulation is invariant under mutual simulation, descending to the quotient.
- `Degree.partialOrder` — degrees of proof systems form a genuine partial order (the "collapse").
- `Degree.le_antisymm` — antisymmetry holds on degrees by `Quotient.sound`.
- `le_top_system` — the trivial system is a greatest element (top degree candidate).
- `bot_system_le` — the empty system is a least element (bottom degree).
- `le_not_antisymm` — distinct raw systems can mutually simulate; the quotient is essential.

All main results compile with `sorry = 0` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound` (and `le_top_system` on none at all).

## Research Directions

### Direction 1: Optimality is a top element of the degree poset

For the polynomial bound class over a suitable theorem type equipped with an
effective universal simulator, `Degree.partialOrder` should have an `OrderTop`;
equivalently, there is a degree `d` with `Degree.le B e d` for every `e`. The test
is twofold: attempt to construct such a top in Lean for a concrete computable
`BoundClass` and theorem encoding, and conversely prove that no top exists for a
deliberately "non-effective" bound class — separating the order question from the
effectiveness question. **Why now?** This cycle reduced optimality to a single
order-theoretic statement (`OrderTop (Degree B T)`) and already provides
`le_top_system` as a candidate top in the *unbounded* setting, so the obstruction
is provably the effectiveness of the bound, not the order structure. The key
insight is that p-optimality is literally "the degree poset has a greatest
element," cleanly separable from computability. If true, this gives a
Lean-checkable interface for optimal proof systems and a target for conditional
results (e.g. under `NE = coNE`); if false for a class, it pinpoints which closure
property an optimal system would have to violate.

### Direction 2: The degree poset is a join-semilattice

Degrees should admit joins: for any systems `P`, `Q` there is a system `P ⊔ Q`
(the disjoint union of their proofs) whose degree is the least upper bound under
`Degree.le`. Meets, by contrast, are conjectured to fail in general. The test is
to define the disjoint-union system, prove its degree is a join, and search for a
counterexample to the existence of meets. **Why now?** With `Degree.partialOrder`
in hand, lattice structure is the immediate next order-theoretic question, and the
disjoint-union construction needs only the existing `BoundClass` axioms. The key
insight is that "running two proof systems in parallel" is exactly a categorical
coproduct, which should realize the join. If true, this upgrades degrees to a
join-semilattice; if meets fail, it shows the degree structure is fundamentally
asymmetric, mirroring the asymmetry between completeness and soundness blowups.

### Direction 3: Bound-class refinement induces poset morphisms

If `B₁.mem ⊆ B₂.mem` (i.e. `B₂` allows more blowup), then `Simulates B₁ P Q →
Simulates B₂ P Q`, and this should induce a monotone surjection
`Degree B₁ T → Degree B₂ T` that collapses degrees as the bound class grows. The
test: prove the implication on `Simulates`, construct the induced map on
quotients, and exhibit two systems distinct in a polynomial degree poset but
identified in an exponential one. **Why now?** `BoundClass` was deliberately
abstracted this cycle, so comparing two classes is now a first-class question, and
`le_respects` already shows how `Simulates` descends to quotients. The key insight
is that "how much you may pad a proof" is a tunable parameter, and coarsening it
functorially collapses the degree poset. If true, this yields a filtration of
degree posets indexed by bound classes — a new structural invariant; if false, it
reveals that simulation strength is not monotone in the bound budget, an
instructive anomaly.

### Direction 4: Effective (functional) simulation strengthens the preorder

Replacing the existential translation in `Simulates` by an explicit function
`tr : Q.Proof → P.Proof` (constructive p-simulation) should yield a preorder that
is *strictly finer*: there exist systems with `Simulates B P Q` but no bounded
constructive translation. The test: define `SimulatesFun B P Q` with a witnessing
function, prove it implies `Simulates`, prove it is a preorder, and construct a
separating example using a non-constructive existence of short proofs. **Why now?**
The current `Simulates` uses a bare `∃`, and the proofs of `sim_refl`/`sim_trans`
make explicit that the witnesses are functions, so promoting them to data is a
small, well-scoped change. The key insight is that classical p-simulation
distinguishes "short proofs exist" from "short proofs are computable," and only the
latter is algorithmically meaningful. If true, this formalizes the
constructive/non-constructive gap inside one comparable framework; if false, it
shows existential and functional simulation coincide abstractly, isolating where
the distinction must come from computability assumptions.

### Direction 5: Hard tautologies as antichains in the degree poset

A family of theorems "hard" for system `Q` but "easy" for `P` should witness
`¬ Simulates B Q P`, and mutually hard families should produce antichains of
incomparable degrees of arbitrary finite width. The test: add a
`complexity : T → ℕ` lower-bound interface, prove a lemma deriving
`¬ Simulates B Q P` from a size lower bound, build a 2-element antichain, then
generalize to width `n`. **Why now?** `le_not_antisymm` already manipulates
explicit size functions to separate systems; the same technique, applied to
*lower* bounds instead of relabellings, should yield incomparability. The key
insight is that proof-size lower bounds are precisely non-simulation certificates,
turning hardness results into order-theoretic structure. If true, this connects
concrete lower-bound theorems (resolution, cutting planes) to the abstract degree
poset; if false, it indicates the abstract bound class is too permissive to see
known separations, prompting a more refined (e.g. uniform) `BoundClass`.
