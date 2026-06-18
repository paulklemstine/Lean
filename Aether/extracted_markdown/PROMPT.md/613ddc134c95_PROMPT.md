Develop a fully formal Lean 4 theory of behavioral equivalence and internal-state non-identifiability for finite-state systems, avoiding unverifiable philosophical claims about subjective experience.

Create a new file in Catalog/MachineLearning/ (or a closely relevant domain if better justified) that defines a structure representing a system with:
- a type of hidden states S,
- a type of observable behaviors B,
- optionally a type of internal representations R,
- a behavior map behavior : S -> B,
- a representation map repr : S -> R.

The target is a complete, sorry-free formalization with concrete theorems and proofs. Focus on the following mathematically precise program:

1. Core definitions
- Define behavioral equivalence on states: s ~ t iff behavior s = behavior t.
- Define representation supervenience on behavior: whenever behavior s = behavior t, we have repr s = repr t.
- Define factorization of repr through behavior: there exists f : B -> R such that repr = f ∘ behavior.
- Define a behavior-preserving twin of a system as another representation map repr' with the same behavior map.
- Define a non-identifiability witness (formerly 'zombie pair' if you want a comment only, not a theorem name): states s,t with equal behavior but unequal repr.

2. Main theorems to prove
- supervenes_iff_factors: representation supervenes on behavior iff repr factors through behavior.
- not_supervenes_iff_exists_witness: failure of supervenience iff there exist s,t with same behavior and different repr.
- supervenes_of_injective_behavior: if behavior is injective then every representation supervenes.
- canonical_factor_through_quotient: define the quotient by behavioral equivalence and show any supervening representation descends to a well-defined map on the quotient.
- twin_construction: for any system and any constant r0 : R, construct a behavior-preserving twin with constant representation; prove it has the same behavior map.
- underdetermination: if R has at least two distinct elements and behavior is not injective or S is nonempty, construct two distinct representation maps with identical behavior.

3. Finite/combinatorial component
Include at least one theorem on finite state spaces. Good options:
- For finite S and finite B, count the number of supervening representation maps in terms of the image/range of behavior.
- Or count constant/behavior-preserving twins under suitable assumptions.
- Or give an explicit algorithm/function that, from a table for behavior and a choice of values on image(behavior), constructs all supervening repr maps.
This part should be concrete and fully proved, using Fintype/Finite tools where appropriate.

4. Examples and counterexamples
- Provide a small finite example where supervenience holds.
- Provide a small finite example where it fails via an explicit witness pair.
- If possible, include a theorem showing that two non-equal repr maps can induce the same observable behavior, formalizing representational non-identifiability.

5. Style and scope constraints
- Do not claim or formalize that this resolves the hard problem of consciousness.
- Do not assert any isomorphism with Gödel incompleteness unless you can give a fully precise, modest theorem already available in Lean; otherwise omit it.
- Keep theorem names mathematically neutral and machine-learning friendly: use terms like supervenience, factorization, behavioral equivalence, identifiability, quotient model, representation map.
- Ensure all structures, defs, and theorem statements are complete and all proofs compile without sorry.

6. Deliverables
Produce:
- a standalone Lean file with module docs explaining the mathematical setup,
- a RESEARCH_PAPER.md explaining the problem as representation non-identifiability rather than metaphysics,
- FUTURE_DIRECTIONS.md with 3-5 next directions grounded in this formal theory.

Prefer simple, robust proofs over grand philosophical claims. The goal is a substantial, complete formal artifact that captures a genuine mathematical distinction between external behavior and internal representation.