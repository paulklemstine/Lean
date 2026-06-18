# Future Directions

## Synthesis

The tight depth hierarchy theorem for inverse-free EML expressions opens a systematic program for understanding the fine structure of compositional real-expression complexity. The three main axes of extension are: (1) removing syntactic restrictions (inverse-free → general), (2) strengthening the complexity measure (depth → size), and (3) broadening the function families (iterExp → general growth hierarchies). Each direction connects to established open problems in circuit complexity, analytic number theory, and machine learning theory, making this work a potential hub for cross-domain transfer.

---

## Direction 1: General EML Depth Hierarchy (with Division)

**Conjecture.** For all D < n, no EML expression (with or without `inv`) of eml-depth at most D can represent iterExp(n) on positive reals.

**Test.** Enumerate EML expressions with `inv` nodes up to size 20 and depth D. For each candidate, numerically evaluate at x = 1, 2, ..., 100 and compare with iterExp(n)(x). If any expression of depth < n matches iterExp(n) to within 10^{-10} on all test points, the conjecture is refuted.

**Impact.** Would establish the full (unrestricted) depth hierarchy, removing the main caveat of our current result. This would be a definitive circuit-depth lower bound for real-expression languages.

**Catalog References.** `Catalog/Speculative/TightDepthHierarchy/Main.lean` (no_invFree_repr_iterExp_of_depth_lt), `Catalog/EML/Complexity/Growth.lean` (polynomial bounds).

**Proof Strategy.** The main new challenge is bounding the growth of expressions containing `inv`. Near poles (zeros of the denominator), the function can be arbitrarily large. One approach: show that inv-containing expressions representing iterExp(n) must have removable singularities (since iterExp(n) is entire), and then argue that after clearing denominators, the resulting expression is effectively inverse-free. Alternative: use the fact that iterExp(n) is strictly positive on (0,∞) to derive that the denominator never vanishes, constraining its form.

**Domain Bridges.** Circuit complexity (unbounded fanin with division gates), algebraic complexity theory (polynomial identity testing with inverses).

**Lineage.** Direct extension of the main theorem.

**Ambition.** Grand challenge — would be the first unconditional depth hierarchy for a complete real-expression language.

---

## Direction 2: Size Lower Bounds for Iterated Exponentials

**Conjecture.** For fixed depth D = n, the minimum size of an inverse-free EML expression of depth n representing iterExp(n) is exactly 2n + 1 (the size of the canonical construction eml(1, eml(1, ..., var))).

**Test.** For n = 1, 2, 3, 4: enumerate all inverse-free EML expressions of depth exactly n and size < 2n + 1. Check if any represents iterExp(n) on a grid of positive reals. If none does, the conjecture is supported.

**Impact.** Would show that the canonical construction is not only depth-optimal but also size-optimal, establishing a Kolmogorov-style incompressibility result for iterated exponentials.

**Catalog References.** `Catalog/Speculative/TightDepthHierarchy/Main.lean` (emlExprIterExp_eval, emlExprIterExp_emlDepth).

**Proof Strategy.** Case analysis on the possible expression trees of the given size and depth. Each eml node contributes at least 3 nodes (the eml itself plus two children). At depth n, we need n eml nodes, giving a minimum of 3n nodes. But the constant child can share structure, so the true minimum may be 2n + 1.

**Domain Bridges.** Kolmogorov complexity, circuit size lower bounds, symbolic regression.

**Lineage.** Extension of the depth hierarchy to size.

**Ambition.** Solid extension — approachable but nontrivial.

---

## Direction 3: Approximate Depth Separation

**Conjecture.** For all D < n and ε > 0, there exists X > 0 such that no inverse-free depth-D expression approximates iterExp(n) within ε on [X, ∞).

**Test.** For D = 1, n = 2, ε = 0.01: numerically search for depth-1 expressions (of the form p(x)·exp(q(x)) with polynomials p, q of degree ≤ 5) that approximate exp(exp(x)) within ε on [1, R] for increasing R. If the best approximation error diverges with R, the conjecture is supported.

**Impact.** Would extend the exact depth hierarchy to an approximation hierarchy, connecting to the theory of uniform approximation and neural network expressivity.

**Catalog References.** `Catalog/MachineLearning/DepthHierarchy/Separation.lean` (ApproxOn, derivative-based separation).

**Proof Strategy.** Use the growth bound to show that depth-D expressions grow at most like iterExp(D), while iterExp(n) grows like iterExp(n). Since iterExp(n)(x) - iterExp(D)(C·x^k) → ∞ as x → ∞ when n > D, no bounded approximation error is achievable on unbounded intervals.

**Domain Bridges.** Approximation theory, neural network depth-width tradeoffs, function spaces.

**Lineage.** Strengthening of the exact separation to uniform approximation.

**Ambition.** Solid extension — the proof strategy follows naturally from the growth bound.

---

## Direction 4: Exponential Rank as a Hardy Hierarchy Measure

**Conjecture.** The exponential rank of a function (the minimum D such that ExpRankBound f D holds) defines a well-ordered hierarchy on the set of computable real functions, isomorphic to the initial segment ω of the Hardy hierarchy.

**Test.** For each k = 0, 1, 2, 3, 4: find explicit functions f_k of rank exactly k (rank k but not rank k-1). Verify numerically that f_k is dominated by iterExp(k) but dominates iterExp(k-1) with polynomial scaling.

**Impact.** Would establish a formal connection between EML expression complexity and classical growth-rate hierarchies from proof theory and set theory, opening a bridge between formal verification and ordinal analysis.

**Catalog References.** `Catalog/Speculative/TightDepthHierarchy/Main.lean` (ExpRankBound definition, iterExp_not_expRankBound).

**Proof Strategy.** Show that ExpRankBound defines a pre-order on functions that is well-ordered at level ω. The iterated exponentials provide canonical witnesses at each level. The key challenge is showing totality: every elementary function has a finite exponential rank.

**Domain Bridges.** Proof theory (Hardy hierarchy, Wainer hierarchy), ordinal analysis, reverse mathematics.

**Lineage.** Conceptual extension of the ExpRankBound invariant.

**Ambition.** Grand challenge — connects EML complexity to deep foundations of mathematics.

---

## Direction 5: Neural Network Depth Separation via EML Embedding

**Conjecture.** For every feedforward neural network with ReLU+exp activations and L layers, there exists an inverse-free EML expression of eml-depth at most L that computes the same function on positive reals. Therefore, the EML depth hierarchy implies a depth hierarchy for such networks.

**Test.** Implement a compiler from small neural networks (≤ 5 layers, ≤ 10 neurons per layer, ReLU+exp activations) to EML expressions. Verify that the eml-depth of the output equals the network depth. Test on 100 random networks.

**Impact.** Would provide the first provable depth separation for neural networks with exponential activations, grounded in the EML hierarchy theorem.

**Catalog References.** `Catalog/Speculative/TightDepthHierarchy/Main.lean` (depth_hierarchy_strict), `Catalog/EML/AIResearch/NeuralArchitectureTheory.lean`.

**Proof Strategy.** Each ReLU+exp layer can be encoded as a combination of eml operations and max operations. If we restrict to the positive orthant (where ReLU is the identity), the encoding is exact. The depth of the EML expression equals the number of layers.

**Domain Bridges.** Deep learning theory, neural network expressivity, computational learning theory.

**Lineage.** Application of the depth hierarchy to machine learning.

**Ambition.** Solid extension — the compiler construction is concrete and testable.
