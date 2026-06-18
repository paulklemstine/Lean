# Future Directions: Theory Morphisms and Compositional Mathematical Research

This document outlines five breakthrough-level research directions opened by the theory morphism framework. Each direction is specific enough for a research team to pursue with clear hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Lattice-Valued Invariants for Multi-Dimensional Transfer

### Hypothesis
Replacing the single ℕ-valued invariant with a lattice-valued invariant (e.g., `Carrier → ℕ × ℕ`, or `Carrier → Finset ℕ`, or `Carrier → L` for a general lattice `L`) enables *finer-grained* theorem transfer that distinguishes different dimensions of complexity simultaneously.

### Proof Strategy
1. Define `RichTheory (L : Type) [Lattice L]` with `Inv : Carrier → L`.
2. Define morphisms requiring `T.Inv x ≤ U.Inv (f x)` in the lattice order.
3. Prove category laws (identical proofs modulo lattice axioms).
4. Show that the product of two ℕ-valued theories embeds naturally into a single `ℕ × ℕ`-valued theory, recovering the product as a special case.
5. Instantiate with `L = ℕ × ℕ` to simultaneously track "arithmetic height" and "geometric dimension" — two fundamentally different measures that both appear in the catalog.

### Expected Breakthrough
Multi-dimensional transfer would allow a single morphism to certify that *both* height bounds and dimension bounds are preserved, enabling much stronger cross-domain conclusions. For instance, translating from arithmetic geometry to combinatorics would simultaneously preserve both the algebraic complexity and the geometric decomposition structure.

### Cross-Domain Connections
- **Algebraic geometry**: Pairs (height, Krull dimension)
- **Machine learning**: Pairs (VC dimension, Rademacher complexity)
- **Cryptography**: Pairs (key size, circuit depth)

---

## Direction 2: Adjunctions Between Research Theories

### Hypothesis
Some pairs of research theories are connected not just by one-way morphisms but by *adjunctions* — pairs of morphisms (F, G) where F is "left adjoint" to G, meaning there is a natural correspondence between morphisms out of F-images and morphisms into G-images. Adjunctions capture the idea that two theories are *equivalent in expressive power* despite having different internal structures.

### Proof Strategy
1. Define `TheoryAdjunction (T U : ResearchTheory)` consisting of `F : TheoryHom T U`, `G : TheoryHom U T`, and unit/counit natural transformations satisfying the triangle identities.
2. Prove that adjunctions induce isomorphisms on lower-bound sets: `SatisfiesLowerBound T n ↔ SatisfiesLowerBound U n` (stronger than one-way transfer).
3. Show that the Height ↔ Cell bridge is *not* an adjunction (the quadratic amplification is asymmetric), but the Stability ↔ Capacity bridge *is* (they're isomorphic).
4. Construct a non-trivial adjunction using the free/forgetful paradigm: "free theory on a set" left adjoint to "forget structure."

### Expected Breakthrough
Adjunctions would provide a principled answer to "when are two theories really saying the same thing?" — a question that currently requires deep mathematical insight. An automated adjunction finder could discover equivalences between apparently unrelated domains.

### Cross-Domain Connections
- **Category theory**: Galois connections, free/forgetful adjunctions
- **Logic**: Lawvere's hyperdoctrine adjunctions
- **Physics**: Duality transformations as adjunctions

---

## Direction 3: Predicate Transport Beyond Lower Bounds

### Hypothesis
The current framework transfers only existential lower bounds (`∃ x, n ≤ Inv x`). A richer system should transfer *arbitrary predicates* preserved by morphisms, including:
- Universal properties: `∀ x, P x → Q (f x)`
- Structural properties: "T has exactly k elements of depth n"
- Finiteness: "T has bounded depth" transfers contrapositively

### Proof Strategy
1. Define a predicate-transport morphism: `PredicateHom T U P Q := { f : TheoryHom T U, transport : ∀ x, P x → Q (f.toFun x) }`.
2. Show that `SatisfiesLowerBound` transfer is a special case with `P x := (n ≤ T.Inv x)` and `Q y := (n ≤ U.Inv y)`.
3. Define *spectrum* of a theory: `Spectrum T := { n | AchievesExactDepth T n }` and prove that morphisms induce order-preserving maps on spectra.
4. Prove a *Galois correspondence* between predicates on the source and predicates on the target, mediated by the morphism.

### Expected Breakthrough
This would upgrade the framework from transferring *numbers* to transferring *theorems*. A predicate like "every element of depth ≥ 10 is stable" could be transported across a morphism to yield "every element of depth ≥ 10 in the target is also stable" — a qualitative upgrade in the power of cross-domain synthesis.

### Cross-Domain Connections
- **Model theory**: Elementary embeddings, preservation theorems (Łoś-Tarski)
- **Formal verification**: Simulation relations, refinement
- **Information theory**: Sufficient statistics as predicate-preserving maps

---

## Direction 4: Automated Morphism Discovery Across the Catalog

### Hypothesis
Given the existing catalog of 100+ formally verified theorems across arithmetic geometry, tropical algebra, dynamical systems, and closure theory, an automated search can discover *new* theory morphisms that were not explicitly constructed, yielding genuinely new cross-domain theorems.

### Proof Strategy
1. Extract all definitions in the catalog that have the form `T → ℕ` (potential invariants) and `T → U` (potential morphism candidates).
2. For each pair (invariant₁ on T, invariant₂ on U), search for functions `f : T → U` such that `invariant₁(x) ≤ invariant₂(f(x))` for all x.
3. Use the theorem prover to verify candidate morphisms.
4. Build a *morphism graph* and find connected components — theories in the same component can transfer theorems to each other.
5. Identify the longest transfer chains and compute the maximum depth amplification achievable.

### Expected Breakthrough
Automated morphism discovery could reveal connections that human mathematicians have missed. For instance, a chain from tropical character theory through Berkovich decomposition to cryptographic key bounds would yield a theorem of the form "representation-theoretic invariants control cryptographic security" — a connection that spans three traditionally unrelated fields.

### Cross-Domain Connections
- **Program synthesis**: Morphism search as program search
- **Knowledge graphs**: Mathematical knowledge as a directed graph with certified edges
- **AI for mathematics**: Theory morphisms as a structured search space for mathematical discovery

---

## Direction 5: A Bicategory of Theories, Interpretations, and Proof Transformations

### Hypothesis
The category of theories is really a *bicategory* (or 2-category): between any two morphisms f, g : T → U, there may be *2-cells* — proof transformations that witness one morphism being "better" than another (e.g., achieving strictly higher depth amplification). The 2-categorical structure captures the idea that there are many ways to translate between theories, and some are provably superior.

### Proof Strategy
1. Define `TheoryHom2 (f g : TheoryHom T U) := ∀ x, U.Inv (f.toFun x) ≤ U.Inv (g.toFun x)` — g uniformly dominates f.
2. Prove that this defines a preorder on morphisms (reflexive, transitive).
3. Show that composition is *functorial* with respect to 2-cells: if f ≤ f' and g ≤ g', then comp f g ≤ comp f' g'.
4. Define *optimal morphisms* as maximal elements in the 2-cell ordering and prove existence under finiteness conditions.
5. Construct concrete 2-cells between the catalog morphisms: show that `heightToCapacityDirect` dominates the pipeline `heightToDimension ; dimensionToStability ; stabilityToCapacity` at every point.

### Expected Breakthrough
The bicategorical structure would provide a formal notion of "best available translation" between theories. This would enable:
- Automated selection of the *optimal* proof pipeline for a given transfer goal
- Formal comparison of competing proof strategies across domains
- A notion of "proof distance" between theories: how much depth is inevitably lost in the best possible translation

### Cross-Domain Connections
- **Higher category theory**: Bicategories, double categories, lax functors
- **Optimization**: Optimal transport as a 2-categorical problem
- **Proof theory**: Cut elimination as a 2-cell, proof normalization as a 2-functor
- **Machine learning**: Model selection as choosing the optimal 2-cell

---

## Implementation Roadmap

| Phase | Direction | Estimated Effort | Dependencies |
|-------|-----------|-----------------|--------------|
| 1 | Direction 3 (predicate transport) | 2-3 weeks | Current framework |
| 2 | Direction 1 (lattice invariants) | 2-3 weeks | Current framework |
| 3 | Direction 5 (2-cells) | 3-4 weeks | Direction 1 |
| 4 | Direction 2 (adjunctions) | 3-4 weeks | Direction 5 |
| 5 | Direction 4 (automation) | 4-6 weeks | All of the above |

## Team Directive

Create a team to conduct research iterating on these directions. For each direction:
1. **Formulate precise conjectures** as Lean theorem statements with `sorry`.
2. **Test computationally** using the Python algorithms module.
3. **Prove formally** using the theorem-proving infrastructure.
4. **Document** each new bridge theorem with its cross-domain interpretation.
5. **Update** this roadmap with new directions discovered during formalization.

The goal is a self-sustaining research cycle: prove theorems → discover connections → formulate new conjectures → prove them → repeat. The theory morphism framework provides the formal backbone for this cycle.
