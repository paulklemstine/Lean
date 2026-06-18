# Future Directions: Proof System Collapse Theory

The module `Logic/ProofSystemCollapse.lean` formalizes the abstract simulation
preorder on Cook–Reckhow propositional proof systems, establishes the duality
between proof systems (modulo simulation) and subsets of the formula type, proves
maximality of complete systems (`complete_simulates_all_sound`), and — the
quantitative flagship — shows that polynomial boundedness is closed under finite
indexed joins (`iUnion_pBounded`). The directions below extend that foundation.

## 1. Meet preserves additive proof-size bounds

The lattice join already lifts to the polynomial setting (`union_pBounded`,
`iUnion_pBounded`). The dual question concerns the meet `meet P Q`, whose proofs
are *pairs* of component proofs of the same formula, so size adds. The key
insight is that `(meet P Q).size = P.size ∘ fst + Q.size ∘ snd`, hence the
optimal proof size in the meet is bounded by the *sum* of optimal sizes in the
components; combined with `prov_meet` this gives a quantitative meet law dual to
`union_pBounded`. Why now? The `size` field and the explicit fibred-product
construction are already in place, so the statement
`PBounded cx P → PBounded cx Q → PBounded cx (meet P Q)` is one provable lemma
away (take `c = c₁ + c₂`, exponent `max k₁ k₂`). Testable, falsifiable: the meet
of two p-bounded systems is p-bounded.

## 2. The simulation order is a bounded distributive lattice on `Set F`

`prov_union`, `prov_meet`, `prov_iUnion`, and `prov_setSys` together say the map
`Prov : ProofSys F → Set F` is a surjective lattice homomorphism onto the
powerset. The key insight is that simulation-equivalence classes of proof systems
form a complete, *distributive* lattice isomorphic to `Set F` ordered by
inclusion, with `setSys` providing a canonical section. Why now? With
`simEquiv_iff_prov_eq` already proven, one can build a `Quotient` of `ProofSys F`
by `SimEquiv` and transport Mathlib's `CompleteDistribLattice (Set F)` instance
across the resulting `Equiv`. Testable conjecture: the quotient
`ProofSys F / SimEquiv` carries a `CompleteDistribLattice` instance whose order is
`Simulates` and which is order-isomorphic to `Set F`.

## 3. Optimal (p-optimal) systems exist iff the join is attained

A system is *p-optimal* when it simulates every p-bounded system with only
polynomial blow-up. The key insight is that `iUnion_pBounded` already constructs,
from any *finite* family of p-bounded systems, a single p-bounded system that
simulates them all — so the obstruction to a universal p-optimal system is purely
the jump from finite to countable joins. Why now? The finite case is closed
(`iUnion_pBounded`), isolating exactly the infinitary gap that the Cook–Reckhow
conjecture (no p-optimal proof system) lives in. Testable, falsifiable: for a
*countable* family `P : ℕ → ProofSys F` of uniformly p-bounded systems with a
shared `(c, k)`, the union `iUnion P` is p-bounded; without a *shared* bound it
need not be (the intended counterexample uses `cf n = n`).

## 4. Concrete instantiation: resolution vs. a tautology-table system

The abstract `setSys` (the "table" system, p-bounded by `setSys_pBounded`) is the
trivial complete system; resolution is a genuine, syntactically restricted
system. The key insight is that instantiating `ProofSys (Finset (Fin n × Bool))`
with a resolution-derivation `Proof` type and clause-count `size` turns the
abstract maximality theorem `complete_simulates_all_sound` into the concrete
statement that the table system simulates resolution, while the *converse* fails
quantitatively. Why now? `complete_simulates_all_sound` and `PBounded` are
parametric in the formula type, so only the syntactic resolution datatype must be
added. Testable, falsifiable separation: the resolution system is *not*
`PBounded` for the pigeonhole complexity measure, even though the table system is
— the first formalized proof-complexity separation built on this lattice.

## 5. Decidable collapse and the Dedekind-number bridge for `F = Fin n`

When `F = Fin n`, every provable set is a `Finset`, the simulation preorder is a
finite partial order, and `complete_simulates_all_sound` becomes decidable by
enumeration. The key insight is that simulation-equivalence classes of systems
biject with subsets of the valid formulas (via `prov_setSys` and
`simEquiv_iff_prov_eq`), so counting *sound* equivalence classes counts subsets
of `{f | Valid f}` — and counting the *antichains* of that subset lattice is the
Dedekind number. Why now? Mathlib's `Fintype`/`DecidableEq` machinery makes the
finite simulation order computable and `#eval`-checkable. Testable conjecture:
for `F = Fin n` the number of simulation-equivalence classes of sound proof
systems equals `2 ^ (card {f | Valid f})`, and the number of *closure-distinct*
families under meet/join equals the Dedekind number `M(card {f | Valid f})` — a
bridge from proof-system collapse to enumerative combinatorics.
