# Future Directions: Theory Morphisms and Compositional Theorem Transfer

## Overview

The formal framework of `ResearchTheory` and `TheoryHom` established in this project provides a certified foundation for cross-domain mathematical synthesis. Below are five concrete, breakthrough-level research directions that build on this work. Each direction is specified with precise hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Multi-Invariant Theory Morphisms and Product Orders

**Hypothesis:** Enriching theories from single `ℕ`-valued invariants to tuples `ℕ^k` (or lattice-valued invariants) enables simultaneous transfer of multiple independent certificates — for example, transferring both a height bound *and* a stability constant in a single morphism.

**Proof Strategy:**
1. Define `RichTheory` with `Inv : Carrier → Fin k → ℕ` (or `Carrier → L` for a lattice `L`).
2. Define `RichHom` requiring componentwise monotonicity.
3. Prove that the product order on `ℕ^k` makes composition and transfer work identically to the scalar case.
4. Show that the scalar framework embeds as the `k=1` special case.
5. Prove a "dominance theorem": a composite morphism dominates each component morphism in every coordinate simultaneously.

**Cross-Domain Connection:** This enables transferring arithmetic height bounds *and* tropical representation-theoretic invariants *and* stability margins all at once, giving a single morphism that certifies three independent properties.

**Estimated Difficulty:** Medium. The lattice-theoretic generalization is straightforward; the challenge is engineering clean Lean types for variable-length tuples.

---

## Direction 2: Adjunctions Between Research Theories

**Hypothesis:** Certain pairs of research theories are connected by *adjoint* morphism pairs `(F, G)` where `F : T → U` and `G : U → T` satisfy a Galois-connection-like property: `F(x) ≤_U y ⟺ x ≤_T G(y)` in the invariant preorder. Such adjunctions would characterize *optimal* cross-domain translations.

**Proof Strategy:**
1. Define `TheoryAdjunction (F : TheoryHom T U) (G : TheoryHom U T)` encoding the Galois connection.
2. Prove that adjunctions compose (from the standard proof for Galois connections).
3. Show that if `(F, G)` is an adjunction, then `F` preserves *exact* lower bounds (not just existential ones): if `T.Inv x = n`, then `U.Inv (F x) ≥ n` with a tight characterization via `G`.
4. Construct a concrete adjunction between `HeightTheory` and `CellTheory` if the invariant functions admit one, or prove that no adjunction exists (which would itself be a structural insight).

**Cross-Domain Connection:** Adjunctions formalize the notion of "best possible translation" between domains. In the analogy with physics, they play the role of dualities (e.g., electric–magnetic duality) that preserve structure optimally in both directions.

**Estimated Difficulty:** Medium-High. Defining the right notion of adjunction for monotone-invariant morphisms requires care; the composition proof is standard but notationally heavy.

---

## Direction 3: Predicate and Structure Transport Beyond Lower Bounds

**Hypothesis:** The current `SatisfiesLowerBound` transfer theorem can be generalized to transport arbitrary predicates `P : T.Carrier → Prop` along morphisms, provided the predicate is "invariant-determined" — i.e., depends only on the invariant value.

**Proof Strategy:**
1. Define `InvariantDetermined (P : T.Carrier → Prop)` as: `∀ x y, T.Inv x = T.Inv y → (P x ↔ P y)`.
2. Define `TransferablePredicate (f : TheoryHom T U) (P : T.Carrier → Prop) (Q : U.Carrier → Prop)` as: `∀ x, P x → Q (f.toFun x)`.
3. Prove that for invariant-determined predicates, the existence transfer generalizes: `(∃ x, P x) → (∃ y, Q y)`.
4. Show that "upper bound" predicates `∀ x, T.Inv x ≤ n` also transfer (contravariantly, via pullback).
5. Prove a "functor on predicates" theorem: composition of transferable predicates is transferable.

**Cross-Domain Connection:** This upgrades the framework from transferring numbers to transferring *theorem schemas*. A theorem like "every group of order n has a subgroup of order dividing n" becomes a transferable predicate that can be reinterpreted in any theory with a compatible morphism.

**Estimated Difficulty:** Medium. The formalization is clean; the main challenge is choosing the right level of generality for the predicate transport conditions.

---

## Direction 4: A Bicategory of Theories, Interpretations, and Proof Transformations

**Hypothesis:** Theory morphisms should be organized into a *bicategory* (or 2-category) where:
- 0-cells are `ResearchTheory` objects
- 1-cells are `TheoryHom` morphisms
- 2-cells are "proof transformations" — natural transformations between morphisms that witness one translation being "at least as good as" another

**Proof Strategy:**
1. Define `TheoryHom2 (f g : TheoryHom T U)` as: `∀ x, U.Inv (f.toFun x) ≤ U.Inv (g.toFun x)` (pointwise invariant comparison).
2. Prove that 2-cells compose vertically and horizontally.
3. Prove interchange law and unit laws.
4. Show that this bicategory has a *terminal object*: the theory with carrier `Unit` and invariant `fun _ => 0`, receiving a unique morphism from every theory.
5. Prove that 2-cells induce a preorder on `TheoryHom T U`, and characterize when two morphisms are "equivalent" (produce the same invariant values).

**Cross-Domain Connection:** The bicategorical structure formalizes the idea that some translations are *better* than others — e.g., a translation that preserves more invariant value is a "tighter" embedding. This is the mathematical analogue of comparing different compilation strategies in programming language theory.

**Estimated Difficulty:** High. Bicategory axioms are notationally intensive in Lean, though the underlying mathematics is well-understood.

---

## Direction 5: Automated Search for Bridge Morphisms Across the Catalog

**Hypothesis:** Given a catalog of proven theorems, it is possible to *automatically* search for theory morphisms connecting them. The search algorithm would:
1. Extract invariant functions from theorem statements (e.g., recognizing "height ≤ dimension" as a monotonicity witness).
2. Attempt to construct `TheoryHom` instances by matching source/target types and proving monotonicity via `omega` or `nlinarith`.
3. Compose discovered morphisms to find indirect bridges.

**Proof Strategy:**
1. Define a `TheorySpec` structure that records the carrier type, invariant function, and a list of known theorems (as `SatisfiesLowerBound` witnesses).
2. Write a Lean metaprogram (tactic or `Decidable` instance) that attempts to construct `TheoryHom` between two `TheorySpec` objects.
3. Prove soundness: any morphism found by the search is a valid `TheoryHom`.
4. Demonstrate on the existing catalog: automatically discover the `heightToCellMorphism` and `stabilityToCapacity` bridges without manual construction.

**Cross-Domain Connection:** This is the "research compiler" vision — a tool that automatically discovers how theorems in one domain can be reinterpreted in another. It transforms the static catalog of proven results into a dynamic graph of cross-domain connections.

**Estimated Difficulty:** Very High (engineering + mathematics). The metaprogramming component requires Lean 4 tactic writing expertise; the soundness proof is straightforward once the search is correctly specified.

---

## Summary Table

| Direction | Key Innovation | Difficulty | Dependencies |
|-----------|---------------|------------|--------------|
| 1. Multi-Invariant | Simultaneous multi-certificate transfer | Medium | None |
| 2. Adjunctions | Optimal translation characterization | Medium-High | Direction 1 (optional) |
| 3. Predicate Transport | Schema-level theorem transfer | Medium | None |
| 4. Bicategory | Quality ordering on translations | High | Direction 3 (for 2-cells) |
| 5. Automated Search | Machine discovery of bridges | Very High | Directions 1-3 (for targets) |

## Team Directive

Each direction should be pursued by a team that:
1. Formalizes the core definitions and 2-3 key lemmas within the first sprint.
2. Validates the approach with a concrete catalog example before scaling.
3. Cross-references with other directions to identify shared infrastructure.
4. Documents both successes and failures — a proven *impossibility* (e.g., "no adjunction exists between X and Y") is as valuable as a positive construction.

The long-term goal is a **library of research compilers**: certified transformations that create new mathematics by composing proven cross-domain bridges.
