# Future Directions: Bilattices, Paraconsistency, and Their Topological Duals

## Synthesis

This cycle formalized Belnap's four-valued logic `FOUR` from the ground up as an
*interlaced distributive bilattice with negation and conflation*, and proved the two
theorems that justify its slogan — *the smallest non-trivial paraconsistent bilattice*:

1. **Two lattices on one carrier.** The truth order (`tand`/`tor`) and the knowledge order
   (`kand`/`kor`) are each genuine lattices (`truth_lattice_axioms`,
   `knowledge_lattice_axioms`), they compute the glb/lub of the declared orders
   (`orders_match_operations`), all twelve interlacing distributive laws hold
   (`distributive_bilattice`), and negation/conflation are the expected dual involutions
   (`negation_laws`, `conflation_laws`).
2. **Paraconsistency = the gap between satisfiable contradiction and valid explosion.**
   In `FOUR` the premise `designated a ∧ designated (¬a)` is *satisfiable* (`B` witnesses
   `explosion_premise_satisfiable`) yet does not entail an arbitrary conclusion
   (`no_explosion`); classically the same premise is *unsatisfiable*
   (`bool_explosion_premise_unsatisfiable`), which is exactly why classical logic explodes
   (`bool_validates_explosion`).
3. **Minimality via the product representation.** `belnap_iso_prod` /
   `operations_transport` realize `FOUR ≅ 2 ⊙ 2 = Bool × Bool` with the standard "twist",
   and `card_four` + `orders_two_dimensional` show the four elements are forced and the two
   orders are genuinely independent.

Everything is decidable over the four-element carrier, so the proofs are kernel-checked
`decide` calls; the mathematical work is in the *correct tables* and the *structural
statements*, which now form a reusable, axiom-clean nucleus (`propext`,
`Classical.choice`, `Quot.sound` only).

## Results Summary

- `Core.lean`: 8 structural theorems (two lattice-axiom bundles, order/operation match,
  partial-order laws, 12-law distributivity, negation laws, conflation laws).
- `Paraconsistency.lean`: paraconsistency (4 theorems), product representation
  `FOUR ≅ 2⊙2` (bijection + order transport + operation transport), and minimality
  (card, two-dimensionality, distinctness witness).

## Bold, Falsifiable Research Directions

### 1. The generic interlaced bilattice `L ⊙ L` and a Lean representation theorem

Conjecture: every *bounded interlaced distributive bilattice with negation* is isomorphic
to the product bilattice `L ⊙ L` of a single bounded distributive lattice `L`, with the
twist `(x₁,y₁) ≤_t (x₂,y₂) ⇔ x₁ ≤ x₂ ∧ y₂ ≤ y₁`, `(x₁,y₁) ≤_k (x₂,y₂) ⇔ x₁ ≤ x₂ ∧ y₁ ≤ y₂`,
and `¬(x,y) = (y,x)`. This generalizes `belnap_iso_prod` from `L = Bool` to arbitrary `L`.
The key insight is that negation forces a coordinate swap, so the diagonal `{(x,x)}` is the
fixed-point sublattice and the off-diagonal encodes a *single* lattice `L` twice — the
bilattice is "two copies of `L` glued by `¬`". Why now? We already have the `L = Bool`
instance fully transported coordinatewise in `operations_transport`; lifting each `decide`
to a coordinate computation in a general `DistribLattice L` is a direct generalization that
Mathlib's lattice API supports, and it would give Lean its first bilattice representation
theorem. Falsifiable: exhibit a finite interlaced distributive bilattice with negation that
is *not* of the form `L ⊙ L` (the conjecture predicts none exists).

### 2. Strict minimality: no non-trivial paraconsistent bilattice has fewer than 4 elements

Conjecture: any structure with two bounded lattice orders sharing a carrier, a De Morgan
negation swapping the truth bounds while fixing the knowledge bounds, and at least one
value that is both designated and has a designated negation, must have `card ≥ 4`, with
equality iff it is `FOUR`. We proved `card_four` and the *existence* of four forced
distinct values (`four_distinct_values`); the open part is the *lower bound for all such
structures*. The key insight is that a paraconsistent value `B` (designated, `¬B`
designated) and a classical value `T` (designated, `¬T` not) are distinct, their negations
`B, F` give a non-designated value, and the knowledge bottom `N = ¬-fixed`, `≤_k`-below `B`,
must differ from all three — a four-element pigeonhole. Why now? The witnesses already live
in `four_distinct_values`; turning them into a `Fintype.card`-lower-bound is a finite
combinatorial argument over a `DecidableEq` carrier, exactly the regime where `decide`/
`Finset` reasoning is strongest. Falsifiable: find a 3-element model satisfying all the
axioms (the conjecture says it cannot exist).

### 3. Topological / Priestley duals of finite bilattices

Conjecture: the Priestley/Esakia-style dual of a finite interlaced distributive bilattice
is a *bi-ordered* finite space — a finite set carrying two partial orders linked by an
order-reversing involution — and bilattice homomorphisms correspond contravariantly to
bi-order-preserving maps. For `FOUR ≅ 2⊙2` the dual should be the two-point twisted square.
The key insight is that the product representation (Direction 1) reduces bilattice duality
to *two simultaneous copies of ordinary Priestley duality* glued by the negation swap, so no
new topology is needed beyond Mathlib's order-theoretic infrastructure. Why now? Direction 1
delivers the algebraic side as a clean product, and finite Priestley duality is purely
order-combinatorial (Stone topology is discrete in the finite case), making a finite-case
formalization tractable immediately. Falsifiable: produce two non-isomorphic finite
bilattices with isomorphic bi-ordered duals (the duality predicts this is impossible).

### 4. `FDE`/`LP`/`K3` entailment as the truth order, fully internalized

Conjecture: the consequence relation of First-Degree Entailment is *exactly* the truth
preorder lifted pointwise to valuations: `Γ ⊨_FDE φ` iff under every `Belnap`-valuation the
meet of `Γ`'s values is `≤_t` the value of `φ`, and the Logic of Paradox (`LP`) and
Strong Kleene (`K3`) arise by changing only the designated set to `{T,B}` resp. `{T}`. We
proved the single-step kernel `tle_preserves_designated`; the open part is a full
soundness-and-completeness theorem for a formula language. The key insight is that all three
logics share one algebra and differ *only* in the designated set, so completeness factors
through the same `decide`-checked truth tables plus a Lindenbaum-style canonical valuation.
Why now? The algebra, designation predicate, and order-vs-designation bridge already exist
and are axiom-clean, so adding an inductive `Formula` type and an evaluation homomorphism is
the only missing scaffolding. Falsifiable: find an `FDE`-valid entailment that fails the
proposed truth-order semantics, or vice versa.

### 5. Fixpoint semantics: Fitting's bilattice approach to the paradoxes

Conjecture: for any monotone (in the knowledge order `≤_k`) "revision" operator on
`Belnap`-valued models, the Knaster–Tarski least fixpoint in `(Belnap, ⊗ₖ, ⊕ₖ)` exists and
assigns the liar sentence the value `B`, giving a paraconsistent fixed-point semantics where
self-reference is *tolerated* rather than explosive. The key insight is that the knowledge
order — not the truth order — is the *information* CPO along which monotone revision
converges, and `B` is its top, so contradictory self-reference lands at the knowledge
maximum without trivializing truth. Why now? `knowledge_lattice_axioms` and
`orders_match_operations` already give the complete-lattice structure that Knaster–Tarski
needs, and Mathlib's `OrderHom`/`lfp` API plugs directly into the `≤_k` order, so the liar
fixpoint is a short construction on top of this cycle's results. Falsifiable: exhibit a
`≤_k`-monotone operator whose least fixpoint assigns the liar a *classical* value `T`/`F`
(the conjecture predicts the value is `B`).
