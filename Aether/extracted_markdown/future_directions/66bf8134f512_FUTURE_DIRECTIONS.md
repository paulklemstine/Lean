# Future Directions: Certified Tropical Hodge Theory

## Overview

The Tropical Hodge Correspondence establishes the first formally verified bridge between tropical cycle theory and Hodge-type cohomological phenomena. This document outlines five concrete next steps, each opening a distinct research frontier.

---

## Direction 1: Tropical Intersection Products and Higher Codimension

### Goal
Extend the cycle class map to a ring homomorphism by defining a formal intersection product on tropical subvarieties and proving compatibility with the cup product on tropical cohomology.

### Hypothesis
On a Kähler-like tropical complex X with a well-defined stable intersection, the intersection product of two balanced subvarieties is balanced, and the cycle class map is multiplicative:

```
cl(Z₁ · Z₂) = cl(Z₁) ∪ cl(Z₂)
```

### Proof Strategy
1. Define the stable intersection of tropical subvarieties using the transversal displacement rule (perturb, intersect, take limit).
2. In the finite setting, reduce to a combinatorial formula: the intersection weight at a cell σ equals a signed sum over higher-dimensional cells incident to σ.
3. Prove the balancing condition is preserved under intersection using the associativity of the sum formula.
4. Verify multiplicativity of the cycle class map by direct computation.

### Cross-Domain Connections
- **Combinatorial commutative algebra**: The intersection ring is a quotient of a polynomial ring modulo Stanley-Reisner relations.
- **Matroid theory**: For matroid-based tropical linear spaces, intersection products connect to matroid intersection theory (Adiprasito-Huh-Katz).

### Deliverables
- Lean formalization of tropical intersection products
- Proof of `cycleClass_mul : cl(Z₁ · Z₂) = cl(Z₁) ∪ cl(Z₂)`
- Computational implementation with complexity analysis

---

## Direction 2: Tropical Hard Lefschetz and Primitive Decomposition

### Goal
Formalize a tropical Lefschetz operator L (multiplication by a Kähler class) and prove the Hard Lefschetz theorem: L^k : Hdg^{n-k}(X) → Hdg^{n+k}(X) is an isomorphism.

### Hypothesis
For a tropical complex X with a "Kähler element" ω ∈ Hdg¹(X), the Lefschetz map L^k is an isomorphism of abelian groups for all k ≤ n.

### Proof Strategy
1. Define the Lefschetz operator as cup product with ω (using Direction 1's intersection product).
2. In the finite combinatorial setting, the Hard Lefschetz theorem becomes a linear algebra statement: a certain matrix has full rank.
3. For specific classes (simplicial complexes, matroid complexes), prove this using the Kähler package of Adiprasito-Huh-Katz.
4. Derive the primitive decomposition as a formal consequence.

### Cross-Domain Connections
- **Discrete Hodge theory**: The Lefschetz operator connects to the combinatorial Laplacian.
- **Representation theory**: The Lefschetz sl₂ action has analogues in the representation theory of the symmetric group.

### Deliverables
- Lean definition of the Lefschetz operator
- Proof of Hard Lefschetz for pure simplicial complexes
- Primitive decomposition theorem

---

## Direction 3: Finite Generation of the Tropical Effective Cycle Cone

### Goal
Prove that the cone of effective balanced codimension-p cycles in a finite tropical complex is finitely generated (as a monoid under addition), and compute explicit generators using idempotent Hilbert basis methods.

### Hypothesis
For every finite tropical complex X and codimension p, the monoid

```
Eff^p(X) = { Z : TropSubvar(X, p) | Z.weight(c) ≥ 0 for all c }
```

is finitely generated. Moreover, the generators can be computed in time polynomial in |Cell| using integer programming.

### Proof Strategy
1. Formulate the effective cycle cone as the non-negative part of the kernel of the balancing constraint matrix.
2. Apply Gordan's lemma (the Hilbert basis theorem for rational polyhedral cones) to conclude finite generation.
3. Implement the computation using the existing `idempotent_hilbert_basis_theorem` infrastructure.
4. For the tropical semiring interpretation: effective cycles form an idempotent semimodule over the tropical semiring, and finite generation follows from the tropical Hilbert basis theorem.

### Cross-Domain Connections
- **Integer programming**: Computing Hilbert bases is a well-studied problem in combinatorial optimization.
- **Idempotent algebra**: The tropical semiring structure on effective cycles connects to the catalog's existing idempotent infrastructure.

### Deliverables
- Lean proof of finite generation
- Algorithm computing Hilbert basis of the effective cycle cone
- Connection to existing `idempotent_hilbert_basis_theorem`

---

## Direction 4: Comparison Theorems via Berkovich Analytification

### Goal
Construct explicit comparison maps from the tropical cohomology of a polyhedral complex to the cohomology of an associated algebraic variety, and verify the hypotheses of the Transfer Principle.

### Hypothesis
For a smooth projective toric variety X_Σ with fan Σ, there exists a comparison map

```
comp : H^n_trop(Trop(X_Σ), ℤ) → H^n(X_Σ(ℂ), ℤ)
```

that sends tropical Hodge classes to classical Hodge classes and cycle classes to algebraic classes.

### Proof Strategy
1. For toric varieties, the tropical complex is the dual of the fan Σ.
2. The comparison map sends tropical cochains to torus-equivariant cohomology classes via the moment map.
3. The key lemma: balanced tropical subvarieties of the fan correspond to torus-invariant subvarieties of X_Σ.
4. Verify the Transfer Principle hypotheses using the equivariant Hodge theory of toric varieties.

### Cross-Domain Connections
- **Non-Archimedean geometry**: Berkovich analytifications provide a functorial bridge between algebraic and tropical worlds.
- **Mirror symmetry**: Tropical-to-classical comparison is a central ingredient in the Gross-Siebert program.
- **Mathematical physics**: Period integrals and mirror maps can be tropicalized using this comparison.

### Deliverables
- Lean formalization of toric fans and their tropical complexes
- Comparison map for toric surfaces
- Verification of Transfer Principle hypotheses for P² and P¹ × P¹

---

## Direction 5: Algorithmic Tropical Hodge Detection

### Goal
Develop and implement a certified algorithm that, given an integral cohomology class on a concrete variety (specified by equations), determines whether it is representable by a tropical cycle, and if so, produces an explicit balanced representative.

### Hypothesis
For varieties admitting a tropicalization with a certified comparison map, the tropical Hodge detection problem is decidable in polynomial time (in the size of the tropical complex).

### Proof Strategy
1. Given a variety X and a class α ∈ H^{2p}(X, ℤ), compute the tropicalization Trop(X).
2. Pull back α to a tropical cochain via the comparison map.
3. Test the tropical Hodge condition (Algorithm 1, O(n²) time).
4. If Hodge, construct the balanced representative (Algorithm 2, O(n²) time).
5. Push the representative forward to obtain an algebraic cycle on X.

### Cross-Domain Connections
- **Computational algebraic geometry**: Integration with Gröbner basis methods for tropicalization.
- **Formal methods**: The algorithm produces a machine-checkable certificate of representability.
- **Machine learning**: Tropical methods have been used in neural network verification; Hodge detection could provide new invariants for network architecture analysis.

### Deliverables
- Certified decision procedure for tropical Hodge detection
- Implementation with benchmarks on toric varieties
- Integration with existing computational algebra systems

---

## Summary Table

| Direction | Key Result | Difficulty | Impact |
|:---------:|:----------:|:----------:|:------:|
| 1. Intersection products | Multiplicative cycle class map | Medium | High |
| 2. Hard Lefschetz | Tropical primitive decomposition | Hard | Very High |
| 3. Finite generation | Hilbert basis of effective cycles | Medium | High |
| 4. Comparison theorems | Toric variety comparison map | Hard | Very High |
| 5. Algorithmic detection | Certified Hodge detection | Medium | High |

## Cross-Domain Synthesis

The five directions form a coherent research program:

```
Direction 3 (Finite Generation)
       ↓
Direction 1 (Intersection Products) → Direction 2 (Hard Lefschetz)
       ↓                                       ↓
Direction 4 (Comparison Theorems) ← Direction 5 (Algorithms)
```

Direction 1 provides the multiplicative structure needed for Directions 2 and 4. Direction 3 gives the computational foundation for Direction 5. Direction 4 connects everything back to classical algebraic geometry through the Transfer Principle.

Together, these directions would establish **certified tropical Hodge theory** as a new computational framework for algebraic geometry, with applications ranging from enumerative geometry to mathematical physics to formal verification of geometric computations.
