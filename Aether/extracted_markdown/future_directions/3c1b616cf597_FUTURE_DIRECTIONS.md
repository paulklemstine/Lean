# Future Directions: Tropical Type Theory

## Overview

This document outlines five breakthrough-level research directions opened by the formalization of tropical dependent type theory. Each direction is concrete enough for a research team to pursue immediately, with clear hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Π-Types as Min-Plus Right Kan Extensions

### Hypothesis
The dependent product (Π-type) in tropical type theory can be defined as a min-plus integral (right Kan extension along a tropical fibration), yielding a tropical function space with decidable type-checking on finite domains.

### Concrete Formulation
Given a tropical family B : (x : α) → β(x) → ℕ over a base A : α → ℕ, define:

```
TropPi(A, B)(f) = sup_{x : α} (B(x)(f(x)) - A(x))
```

(or the min-plus variant using inf and tropical addition). The Π-type is the tropical set of all sections f, with cost given by the worst-case excess over the base cost.

### Key Theorems to Prove
1. **Adjunction**: TropPi is right adjoint to a tropical context extension functor.
2. **Decidability**: On finite base types, TropPi membership is decidable.
3. **β-reduction**: Application of a tropical function to an argument preserves cost bounds.
4. **η-expansion**: Every well-typed section arises from a tropical function.

### Proof Strategy
- Start with the non-dependent case (simple function types) where the Kan extension reduces to a matrix tropical product.
- Use the existing TropPi definition as a stepping stone.
- Verify on finite examples using #eval before attempting full proofs.

### Cross-Domain Connections
- **Optimization**: The Kan extension is the tropical analogue of the value function in dynamic programming.
- **Linear algebra**: For finite types, this is tropical matrix multiplication.
- **Category theory**: Connects to enriched presheaf categories over the (ℕ, min, +) quantale.

### Expected Impact
A working tropical Π-type would complete the basic type formers, making tropical type theory a candidate for a resource-aware proof assistant.

---

## Direction 2: Tropical W-Types via Least Fixed Points of Polynomial Functors

### Hypothesis
Well-founded trees (W-types) in tropical type theory correspond to least fixed points of tropical polynomial endofunctors, with the recursion principle yielding a tropical Bellman equation.

### Concrete Formulation
A tropical polynomial functor P : TropSet → TropSet is given by:
```
P(X)(t) = min_{(a, b₁, ..., bₙ) constructing t} (c(a) + X(b₁) + ... + X(bₙ))
```
where c(a) is the constructor cost. The W-type is the least fixed point X* with P(X*) ≅ X*.

### Key Theorems to Prove
1. **Existence**: For well-behaved P, the least fixed point exists and equals the initial P-algebra.
2. **Recursion**: The unique homomorphism from X* to any P-algebra computes the optimal cost bottom-up (generalized Bellman equation).
3. **Induction**: If a tropical predicate holds at zero cost for all constructors, it holds everywhere.
4. **Finite trees**: On bounded-depth trees, type checking remains decidable.

### Proof Strategy
- Generalize the existing NatTropAlg initiality proof from Option (= 1 ⊕ X) to arbitrary polynomial functors.
- Start with binary trees: F(X) = 1 ⊕ X × X.
- Use Lean's native inductive types to represent the syntax, then define tropical cost by recursion.

### Cross-Domain Connections
- **Dynamic programming**: Every polynomial functor recursion scheme corresponds to a DP recurrence.
- **Compiler optimization**: Cost-annotated syntax trees are tropical W-types.
- **Homotopy type theory**: W-types are the foundation of higher inductive types; tropical W-types could seed tropical HIT theory.

### Expected Impact
This would establish tropical type theory as a framework for certified optimization over recursive structures — a fundamentally new application of type-theoretic methods.

---

## Direction 3: Tropical Normalization-by-Evaluation and Decidable Conversion

### Hypothesis
Normalization-by-evaluation (NbE) can be adapted to the tropical setting, where evaluation computes minimum costs and readback produces normal forms. The resulting conversion check is decidable and corresponds to checking equality of shortest-path distances.

### Concrete Formulation
- **Syntax**: Define a small lambda calculus with tropical type annotations.
- **Semantics**: Evaluate terms into tropical sets (cost functions).
- **Readback**: Extract normal forms by selecting minimum-cost representatives.
- **Conversion**: Two terms are convertible iff they evaluate to tropically equal cost functions.

### Key Theorems to Prove
1. **Soundness**: If two terms are syntactically convertible, their tropical evaluations are equal.
2. **Completeness**: If two terms evaluate to tropically equal functions, they are convertible.
3. **Decidability**: Conversion checking terminates and is decidable on finite types.
4. **Canonicity**: Every closed term of base type evaluates to a canonical value.

### Proof Strategy
- Start with a simply-typed tropical lambda calculus (no dependent types).
- Use the existing TropEq and tropical_identity_eq_minplus_equality as the semantic equality.
- Implement the evaluator in Lean and prove termination using the well-founded universe hierarchy.

### Cross-Domain Connections
- **Denotational semantics**: NbE bridges syntax and semantics; tropical NbE would bridge syntax and optimization.
- **Shortest paths**: Conversion checking = checking equality of shortest-path distances.
- **Proof search**: In the tropical setting, proof search becomes optimization search.

### Expected Impact
A tropical NbE would be the first type-theoretic normalization procedure with a direct optimization interpretation, potentially enabling new verified optimization techniques.

---

## Direction 4: Quantale-Valued Identity and Tropical Path Structures

### Hypothesis
Tropical identity types carry the structure of a (ℕ, min, +)-enriched category, where higher identity types correspond to iterated tropical discrepancy measures. This yields a truncated tropical analogue of the identity types in homotopy type theory.

### Concrete Formulation
Define a tropical distance between terms:
```
d_B(f, g) = sup_x |B(f(x)) - B(g(x))|
```
This is a pseudometric. The identity type Id_B(f, g) is inhabited iff d_B(f, g) = 0.

For higher identity, define:
```
d²(p, q) = sup_x |p(x) - q(x)|
```
where p, q are "paths" (proofs of tropical identity).

### Key Theorems to Prove
1. **Metric structure**: d_B satisfies the triangle inequality (transitivity of TropId).
2. **Truncation**: All higher identity types are trivial (tropical identity is a proposition, not a set).
3. **Univalence fragment**: For finite types, tropically equivalent tropical sets are isomorphic.
4. **Path algebra**: The space of paths forms a tropical semiring.

### Proof Strategy
- Use the existing TropId equivalence relation as the base case.
- Prove truncation using the fact that TropId is a Prop (all proofs of pointwise equality are equal).
- For univalence, construct explicit isomorphisms between tropically equivalent finite sets.

### Cross-Domain Connections
- **Lawvere metric spaces**: Tropical identity corresponds to zero-distance in an enriched category.
- **HoTT**: The truncation result shows that tropical type theory naturally lives at the "set" level (h-level 2), without higher homotopical structure.
- **Information theory**: Tropical distance measures information discrepancy under a cost model.

### Expected Impact
This would establish the precise relationship between tropical type theory and homotopy type theory, showing that tropical semantics provides a natural model for truncated (set-level) type theory.

---

## Direction 5: Certified Resource-Aware Programming via Tropical Type Checking

### Hypothesis
A practical programming language can be designed where tropical types simultaneously serve as resource bounds and correctness specifications, with the type checker automatically verifying both properties.

### Concrete Formulation
Design a language TropLang where:
- Every function has a tropical type annotation specifying its resource budget.
- The type checker verifies ∀ x, B(f(x)) ≤ A(x) + c for declared cost bound c.
- Composition of functions automatically tracks cumulative cost via the composition theorem.
- Pattern matching on inductive types uses the initial algebra recursion principle.

### Key Milestones
1. **Core language**: Simply-typed lambda calculus with tropical cost annotations.
2. **Type inference**: Infer minimal cost bounds using the principal type algorithm (TropHomC with minimal c).
3. **Dependent types**: Extend to dependent tropical types for expressive specifications.
4. **Compiler**: Compile to efficient code with guaranteed resource bounds.
5. **Case studies**: Verify resource bounds for sorting algorithms, graph algorithms, and ML inference.

### Proof Strategy
- Implement a prototype in Python first, using the algorithms.py codebase.
- Formalize the type system in Lean, proving soundness (well-typed programs respect resource bounds).
- Use the existing decidability results to justify termination of type checking.

### Cross-Domain Connections
- **Rust's borrow checker**: Type-level resource tracking, but for computational resources rather than memory ownership.
- **Amortized complexity**: Tropical types can encode amortized cost analysis via potential functions.
- **Embedded systems**: Hard real-time constraints as tropical type specifications.
- **Machine learning**: Training budget certification — proving that an optimization loop terminates within a resource bound.

### Expected Impact
A working resource-aware type checker would be immediately applicable to safety-critical software, embedded systems, and any domain where both correctness and resource consumption must be certified. This is the most practically impactful direction.

---

## Research Roadmap

```
Phase 1 (Months 1-3): Tropical Π-types and simple function spaces
Phase 2 (Months 3-6): W-types for binary trees and lists
Phase 3 (Months 6-9): Normalization-by-evaluation prototype
Phase 4 (Months 9-12): TropLang prototype with type inference
Phase 5 (Months 12-18): Path structures and higher identity
```

Each phase builds on the previous, with the formal verification (Lean proofs) proceeding in parallel with the implementation work (Python prototypes). The semantic foundations established in this work — decidability, identity, initiality, well-foundedness — serve as the verified core on which all subsequent development rests.
