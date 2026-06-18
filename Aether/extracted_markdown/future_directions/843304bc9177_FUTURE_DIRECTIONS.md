# Future Directions: Tropical Reflection Tactic

## Overview

The tropical reflection tactic establishes a certified decision procedure for the additive-commutative-idempotent (ACI) fragment of min-plus algebra. This document outlines five breakthrough-level research directions that this foundation enables.

---

## Direction 1: Distributive Extension — Tropical Polynomial Normal Forms

**Hypothesis:** The ACI normalizer can be extended to handle the distributive law `a + min(b, c) = min(a + b, a + c)`, yielding a complete decision procedure for the full tropical semiring fragment (without subtraction).

**Proof Strategy:**
1. Define a *tropical polynomial normal form* as `min` of sums of variables and constants — i.e., a formal tropical polynomial in "expanded" form.
2. Implement a `distribute` pass that pushes `+` through `min` until every `min`-child is a pure sum.
3. After distribution, apply the existing ACI normalizer to the resulting `min`-of-sums expression.
4. Prove soundness of the distribution step: `eval(distribute(e)) = eval(e)` by structural induction, using `tropical_plus_distributes_over_min` as the key rewrite.
5. Compose: `normalize_full = normalize_ca ∘ distribute` is sound, and equal normal forms imply semantic equality.

**Impact:** This would give a complete decision procedure for all identities in the free tropical semiring, analogous to what `ring` does for commutative rings. It would handle goals like `a + min(b, c) = min(a + b, a + c)` automatically.

**Cross-Domain Connections:**
- Tropical polynomials define piecewise-linear functions; this enables automated reasoning about tropical hypersurfaces.
- In optimization, expanded tropical polynomials correspond to sets of feasible cost expressions in dynamic programming.

---

## Direction 2: Max-Plus Dualization

**Hypothesis:** The entire tactic infrastructure can be systematically dualized from min-plus to max-plus algebra by a functorial transformation, yielding a parallel `tropical_max` tactic with zero additional proof effort.

**Proof Strategy:**
1. Define a `dual : CTropExpr → CTropExpr` map that swaps `tmin` for `tmax` (a new constructor).
2. Prove `eval_max σ (dual e) = -eval_min (fun i => -σ i) e`, exploiting `max a b = -min(-a)(-b)`.
3. Transfer all soundness theorems through this duality: `normalize_ca_sound` for max follows from the min version by negation.
4. Alternatively, parameterize the entire development over a `TropicalSemiring` typeclass that abstracts over the choice of `min` vs `max`.

**Impact:** Max-plus algebra is the native language of scheduling theory, discrete event systems, and max-flow problems. A dual tactic doubles the applicability with minimal effort.

**Cross-Domain Connections:**
- Weighted automata over max-plus compute longest paths and maximum-weight matchings.
- In machine learning, max-plus corresponds to ReLU network computations and tropical rational functions.

---

## Direction 3: Certified Tropical Matrix Algebra

**Hypothesis:** The scalar-level reflection tactic can be lifted to matrix expressions over the tropical semiring, enabling automated proofs of tropical matrix identities and spectral properties.

**Proof Strategy:**
1. Define `TropMatExpr` as matrices of `CTropExpr` entries.
2. Implement tropical matrix multiplication: `(A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})`.
3. Lift `normalize_ca` entry-wise and prove that normalized matrix equality implies semantic equality.
4. For spectral properties: formalize the tropical eigenvalue as the minimum cycle mean in the associated weighted digraph. Prove that `tr(A^n)/n → λ(A)` tropically.
5. Connect to the existing `MinPlusSpectral.lean` infrastructure.

**Impact:** Tropical matrix algebra is the computational engine behind:
- Shortest-path algorithms (Floyd-Warshall is tropical matrix powering)
- Discrete event system simulation
- Train scheduling and manufacturing optimization

A certified tactic here would enable verified implementations of these algorithms.

**Cross-Domain Connections:**
- Bellman-Ford and Dijkstra can be expressed as tropical matrix-vector products.
- Tropical spectral theory connects to Perron-Frobenius theory via the max-plus eigenvalue problem.

---

## Direction 4: Tropical Convexity and Optimization Certificates

**Hypothesis:** The reflection tactic can serve as the algebraic kernel for a certified tropical convexity checker, verifying that a point lies in a tropical polytope or that a tropical linear program has a given optimal value.

**Proof Strategy:**
1. Define tropical convex combinations: `tconv(x, y, λ) = min(λ + x, μ + y)` where `λ + μ = 0` tropically.
2. A tropical polytope is the tropical convex hull of finitely many points. Membership reduces to solving a system of tropical linear equations.
3. Use the reflection tactic to verify algebraic identities arising in membership certificates.
4. For tropical linear programming: the optimal value of `min_x max_i (a_i + x)` can be computed by the reflection tactic when the problem is finite and concrete.
5. Prove a tropical Farkas lemma: either a tropical system has a solution, or there exists a separating tropical hyperplane. Use the tactic to verify the certificate in each case.

**Impact:** This creates a bridge between formal verification and tropical optimization, enabling:
- Certified solutions to assignment problems
- Verified scheduling algorithms
- Formal proofs of optimality in combinatorial optimization

**Cross-Domain Connections:**
- Tropical convexity appears in phylogenetics (tree space is a tropical Grassmannian).
- Auction theory uses tropical geometry to analyze competitive equilibria.

---

## Direction 5: Piecewise-Linear Neural Network Verification

**Hypothesis:** Since tropical polynomials compute piecewise-linear functions (specifically, pointwise minima of affine functions), the tropical reflection tactic can serve as a backend for verifying properties of ReLU neural networks.

**Proof Strategy:**
1. A ReLU network with one hidden layer computes `f(x) = max(0, Wx + b)`, which is a tropical rational function.
2. Formalize the correspondence: every piecewise-linear function on ℝⁿ with integer slopes is a tropical rational function (Theorem of [Tropical Geometry literature]).
3. Verification queries like "does `f(x) = g(x)` for all x in a tropical polytope?" reduce to tropical polynomial identity checking in the restricted fragment.
4. Use the reflection tactic to discharge these identities automatically.
5. Extend to compositional reasoning: if networks N₁ and N₂ are tropically equivalent on a region, and N₂ ∘ N₃ has a known bound, transfer the bound to N₁ ∘ N₃.

**Impact:** Neural network verification is one of the most active areas in formal methods. A tropical approach offers a fundamentally different angle from interval arithmetic and SMT-based methods, potentially handling cases where those techniques struggle.

**Cross-Domain Connections:**
- The tropical geometry of neural networks has been studied by [Zhang et al., 2018] and connects network expressivity to Newton polytope complexity.
- Certified robustness bounds for adversarial examples could be derived tropically.
- This connects tropical algebra to AI safety and trustworthy machine learning.

---

## Implementation Priority

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Distributive Extension | Medium | Very High | Current tactic |
| 2. Max-Plus Dual | Low | High | Current tactic |
| 3. Matrix Algebra | High | Very High | Direction 1 |
| 4. Convexity Certificates | High | High | Directions 1, 3 |
| 5. Neural Network Verification | Very High | Transformative | Directions 1, 2 |

**Recommended sequence:** 2 → 1 → 3 → 4 → 5

Direction 2 (dualization) is low-hanging fruit that doubles the tactic's applicability. Direction 1 (distributive extension) is the critical mathematical step. Directions 3–5 build on these foundations for increasingly ambitious applications.
