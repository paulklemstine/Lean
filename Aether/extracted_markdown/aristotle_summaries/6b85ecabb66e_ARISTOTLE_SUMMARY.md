# Summary of changes for run cce41584-715e-43e2-a20e-55744d17e56f
# Isomorphisms of Meaning: When Structures Collide

## Research Summary

This research cycle formalized the concept of **semantic opacity** — the phenomenon that isomorphic mathematical structures can carry genuinely different meanings — and established the **Iso-Torsor Framework** as a rigorous, quantitative theory of meaning in algebra and category theory.

## Lean 4 Proofs (Novelty/IsomorphismSemantics.lean)

All 15 theorems/definitions are **fully proved** with no `sorry` — clean build, standard axioms only. Key results:

1. **Iso-Torsor Theorem** (`isoTorsorEquiv`): The space of group isomorphisms G ≃* H is in natural bijection with Aut(G), via the torsor action σ ↦ σ.trans φ. This quantifies semantic freedom: there are exactly |Aut(G)|-many ways to identify isomorphic structures.

2. **Semantic Fiber Cardinality** (`semantic_fiber_card`): For finite groups, |{G ≃* H}| = |Aut(G)|.

3. **Semantic Opacity** (`semantic_opacity_Z4_Klein`): ℤ/4ℤ and ℤ/2ℤ × ℤ/2ℤ are non-isomorphic as groups despite having equivalent underlying sets — demonstrated via exponent separation.

4. **Rigid Uniqueness** (`rigid_iso_unique`): For groups with trivial automorphism group, any two isomorphisms must be equal — rigidity eliminates semantic ambiguity.

5. **Conjugation-Torsor Compatibility** (`conjugation_torsor_compat`): The conjugation isomorphism Aut(G) ≃* Aut(H) interacts naturally with the torsor structure.

6. **Faithful Iso-Reflection** (`faithful_reflects_iso_equality`): A faithful functor between categories preserves all semantic distinctions among isomorphisms.

7. **Aut-Factorial Divisibility** (`aut_order_divides_factorial`): |Aut(G)| divides |G|!, bounding semantic entropy.

8. **Invariant Separation** (`invariant_separation`): Any isomorphism invariant that separates two groups proves non-isomorphism — generalizing `different_euler_char_not_iso` from the catalog.

## Catalog Deepening

The work deepens two catalog results:
- **`different_euler_char_not_iso`**: Generalized from Euler characteristic to arbitrary isomorphism invariants via the Invariant Separation Theorem.
- **`oracle_preserves_truth`**: Complemented by showing that while isomorphisms preserve truth, they don't preserve meaning — there are |Aut(G)|-many equally valid truth-preserving identifications.

## Deliverables

- **ARTICLE.md**: 1500+ word Scientific American-style article on the ideas (no mention of formal verification)
- **RESEARCH_PAPER.md**: 3000+ word research paper with full PEGB analysis for top theorems
- **FUTURE_DIRECTIONS.md**: 5 research directions with synthesis, conjectures, tests, and proof strategies
- **demo.py**: Numerical demonstrations of all key theorems
- **algorithms.py**: Type-hinted implementations of iso-torsor action, semantic distance, automorphism computation
- **visualize_torsor.py**: Matplotlib visualizations of semantic entropy and automorphism spectra
- **PACKAGE.json**: Complete JSON bundle with 2 interactive HTML widgets (Semantic Opacity Explorer, Cayley Table Comparator)