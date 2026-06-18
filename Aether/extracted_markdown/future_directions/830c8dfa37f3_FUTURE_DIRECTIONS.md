# Future Directions: Tropical Polynomial Normal Forms

## Overview

The verified tropical normalization procedure opens several concrete research frontiers. Each direction below includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Extensional Completeness via Convex Separation

### Goal
Prove the reverse direction of the decision procedure:
```
(∀ x, eval e₁ x = eval e₂ x) → normalize e₁ = normalize e₂
```

### Hypothesis
Two distinct normalized monomial supports yield different evaluation functions. Specifically, if monomial m ∈ S \ T, there exists a valuation x where evalMonomial(m, x) > evalNF(T, x).

### Proof Strategy
1. **Separation lemma for affine forms**: Given finitely many affine forms f₁, ..., fₖ on ℝⁿ with fᵢ ≠ f₁ for all i > 1, there exists x such that f₁(x) > max(f₂(x), ..., fₖ(x)). Prove this by induction on n, using the fact that distinct affine forms agree on at most a hyperplane.

2. **Domination pruning**: Define a pruning operation that removes geometrically dominated monomials (those whose affine form is everywhere ≤ the max of the remaining). Prove that pruning is idempotent and that the pruned support is unique.

3. **Canonical form**: Show that pruned normal forms are canonical: equal functions ↔ equal pruned supports.

### Required Mathlib Infrastructure
- Convex hull computation for finite sets in ℝⁿ
- Support function theory (partially available)
- Hyperplane separation theorem (available for convex sets)

### Cross-Domain Connections
- **Convex geometry**: pruned supports correspond to vertices of upper envelopes
- **Tropical geometry**: pruned supports are dual to regular subdivisions of Newton polytopes
- **Optimization**: minimal support = minimal certificate family

### Estimated Difficulty
High. The separation lemma requires careful handling of ℝⁿ geometry. Possible intermediate target: prove completeness for n=1 (one variable) first, where separation reduces to comparing slopes and intercepts.

---

## Direction 2: Computable Normalization and Proof-by-Reflection Tactic

### Goal
Implement a `tropical_nf` tactic that decides tropical polynomial identities by computation inside Lean's kernel.

### Strategy
1. **Integer coefficient version**: Define `TropExprZ n` with ℤ coefficients. This admits `DecidableEq` computationally (no Classical.choice needed).

2. **Reification**: Write a tactic that takes a goal of the form `∀ x, max(f₁(x), f₂(x)) = max(g₁(x), g₂(x))` (where fᵢ, gᵢ are affine in x) and reifies it into `TropExprZ` terms.

3. **Boolean decision**: Implement `beqNorm : TropExprZ n → TropExprZ n → Bool` and prove `beqNorm e₁ e₂ = true → eval e₁ = eval e₂`.

4. **Kernel evaluation**: Use `native_decide` or `decide` to evaluate `beqNorm` at compile time.

### Concrete Syntax Target
```lean
example (x y z : ℤ) :
    x + max y z = max (x + y) (x + z) := by
  tropical_nf
```

### Cross-Domain Connections
- **Metaprogramming**: extends Lean's tactic framework for non-ring-like algebraic structures
- **SMT integration**: could serve as a theory solver for tropical constraints
- **Certified computation**: proof by reflection = computation as proof

### Estimated Difficulty
Medium. The mathematical content is already established; the main challenge is tactic engineering in Lean 4's metaprogramming framework.

---

## Direction 3: Newton Polytope Formalization and Tropical Geometry

### Goal
Connect normalized tropical polynomial supports to Mathlib's convex geometry library, formalizing Newton polytopes and their duality with tropical hypersurfaces.

### Key Theorems to Formalize
1. **Newton polytope of a product**: `NewtonPolytope(p ⊙ q) = MinkowskiSum(NewtonPolytope(p), NewtonPolytope(q))`
2. **Tropical hypersurface structure**: The non-smoothness locus of a tropical polynomial (where the max is achieved by ≥ 2 monomials) is the (n-1)-skeleton of the normal fan of the Newton polytope.
3. **Kapranov's theorem** (restricted form): The tropical variety of a polynomial captures the valuations of its algebraic roots.

### Proof Strategy
- Use the normal form representation to define Newton polytopes as `Finset.convexHull` of exponent vectors
- Prove that `mulNF` corresponds to Minkowski sum via the existing `eval_mulNF` theorem
- Connect to `Mathlib.Analysis.Convex.Hull` and `Mathlib.Geometry.Combinatorics`

### Cross-Domain Connections
- **Algebraic geometry**: tropical geometry as a combinatorial shadow of algebraic geometry
- **Optimization**: Newton polytopes govern the complexity of polynomial optimization
- **Combinatorics**: face lattices of polytopes from tropical polynomial structure

### Estimated Difficulty
High. Requires substantial interface work between tropical algebra and Mathlib's convex geometry.

---

## Direction 4: Tropical Neural Network Verification

### Goal
Formalize the correspondence between deep ReLU neural networks and tropical polynomials, then use normalization for exact robustness certification.

### Key Results to Formalize
1. **ReLU layer as tropical polynomial**: A layer `x ↦ max(0, Wx + b)` with max-pooling output is a tropical polynomial of degree 1.
2. **Depth-degree correspondence**: A depth-d ReLU network computes a tropical polynomial of degree ≤ d (where degree = maximum total exponent in any monomial).
3. **Exact robustness**: The minimum margin over an ε-perturbation ball equals a linear program over the Newton polytope data.

### Strategy
1. Define `ReLUNetwork` as a sequence of weight matrices and bias vectors.
2. Define `networkToTropExpr` converting a network to a tropical expression.
3. Prove `eval(networkToTropExpr(N), x) = networkEval(N, x)`.
4. Apply `normalize` to extract the monomial support.
5. Prove that robustness = margin = gap between class polynomials.

### Cross-Domain Connections
- **Machine learning**: exact analysis of neural network decision boundaries
- **Safety-critical systems**: certified robustness for autonomous driving, medical AI
- **Complexity theory**: tropical degree as a measure of network expressiveness

### Estimated Difficulty
Medium-High. The basic correspondence is straightforward; the robustness certification requires optimization over polytopes.

---

## Direction 5: Tropical Gröbner Bases and Ideal Membership

### Goal
Extend the normalizer from single polynomial identity to systems: given tropical polynomials p₁, ..., pₖ and q, decide whether q is in the tropical ideal generated by p₁, ..., pₖ.

### Background
In classical algebra, Gröbner bases provide a decision procedure for polynomial ideal membership. The tropical analogue replaces polynomial division with tropical division (subtraction and comparison of monomial supports).

### Key Definitions
1. **Tropical ideal**: the set of tropical polynomials that vanish on the tropical variety V(p₁, ..., pₖ).
2. **Tropical division**: given p and a set G, reduce p by subtracting (tropically) the dominant terms of elements of G.
3. **Tropical Gröbner basis**: a generating set G such that tropical division by G terminates with remainder 0 iff p ∈ ideal(G).

### Proof Strategy
- Formalize tropical division using the normal form representation
- Prove termination via a well-founded order on monomial supports
- Prove the Buchberger criterion: S-polynomials reduce to 0

### Cross-Domain Connections
- **Computational algebra**: extends classical Gröbner basis theory to tropical setting
- **Algebraic geometry**: tropical varieties as computational objects
- **Combinatorial optimization**: tropical ideal membership has applications in linear programming duality

### Estimated Difficulty
Very High. This is a substantial research project. An intermediate target: formalize tropical division for univariate polynomials.

---

## Priority Ordering

1. **Direction 2** (Tactic) — Highest immediate impact, builds directly on existing work
2. **Direction 1** (Completeness) — Highest mathematical value, upgrades sound procedure to decision procedure
3. **Direction 4** (Neural Networks) — Highest application value, connects to active ML research
4. **Direction 3** (Newton Polytopes) — Deepest mathematical content, requires most Mathlib infrastructure
5. **Direction 5** (Gröbner Bases) — Most ambitious, suitable for a research program

---

## Team Directive

Each direction should be pursued by a team with expertise in:
- **Formal verification** (Lean 4, Mathlib)
- **Tropical algebra** (max-plus semiring theory)
- **Convex geometry** (polytopes, separation theorems)
- **Domain expertise** (ML for Direction 4, algebraic geometry for Direction 3/5)

Hypotheses should be validated computationally (Python prototypes) before formalization. Each milestone should produce both a machine-verified theorem and a demonstration of its practical utility.
