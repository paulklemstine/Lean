# Future Directions: Tropical Normal Forms

This breakthrough establishes the foundation for a broad research program bridging formal methods, tropical geometry, and machine learning. We propose three major tracks for future research.

## 1. Certified Canonical Equivalence for ReLU Networks
**Goal:** Extend the univariate canonical form to tropical rational functions (differences of tropical polynomials) to provide a complete equivalence checker for piecewise-linear neural networks.
- **Hypothesis:** Any continuous piecewise-linear function representable by a ReLU network has a unique minimal representation as a quotient of canonical tropical polynomials.
- **Next Steps:** Formalize the algebra of tropical rational functions. Implement a simplification engine that reduces fraction equivalence $P/Q = R/S$ to tropical polynomial cross-multiplication $P \otimes S = R \otimes Q$, and verify it using the `canonicalize` algorithm. 

## 2. Multivariate Polyhedral Canonicalization
**Goal:** Generalize the 1D Graham scan canonicalization to multivariate tropical polynomials using formal Newton polytopes.
- **Hypothesis:** The redundant multivariate monomials correspond exactly to interior points of the upper facets of the lifted Newton polytope in $\mathbb{R}^{d+1}$.
- **Next Steps:** Interface the tropical evaluation semantics with Lean's existing convex geometry library. Implement a verified QuickHull or Beneath-Beyond algorithm to compute the lower convex hull of multivariate exponent vectors.

## 3. Weighted Automata Minimization (Myhill-Nerode Bridge)
**Goal:** Unify tropical polynomial canonicalization with finite state minimization for weighted automata.
- **Hypothesis:** The removal of dominated monomials in a tropical polynomial is categorically equivalent to the elimination of redundant states in a tropical Myhill-Nerode equivalence class.
- **Next Steps:** Build a formal functor between `TropPolynomial` semantics and the residual languages defined in `TropicalMyhillNerode.lean`. Prove that canonicalization computes the exact state-minimal automaton for single-variable weighted languages.