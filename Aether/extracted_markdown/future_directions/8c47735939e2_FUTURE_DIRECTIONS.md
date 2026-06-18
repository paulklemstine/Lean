# Future Directions: Lorentzian Polynomials and M-Convex Geometry

## Synthesis

The formalization of the Brändén-Huh support theorem opens a corridor between continuous algebraic geometry and discrete combinatorial optimization. Our work establishes the algebraic infrastructure — PSD Cauchy-Schwarz, the 3×3 determinant lemma, the spectral exchange argument — needed to prove that Lorentzian curvature forces M-convex exchange geometry. The five directions below extend this foundation: from completing the quadratic case to tropical valuated extensions, from algorithmic applications to connections with negative dependence and complexity theory. Together, they constitute a research program in *verified discrete convex analysis from algebraic structure*.

---

## Direction 1: Valuated M-Convex Strengthening

**Conjecture**: If f is a Lorentzian polynomial of degree d, then the function ν(α) = -log(coeff(α, f)) on NewtonSupport(f) is an M-convex valuation: for any α, β ∈ supp(f) and i with α(i) > β(i), there exists j with α(j) < β(j) such that:
```
ν(α) + ν(β) ≥ ν(α - eᵢ + eⱼ) + ν(β + eᵢ - eⱼ)
```

**Test**: Compute ν for all Lorentzian polynomials with n=3, d≤4, coefficients in {1,...,5}. Check the valuated exchange inequality for all pairs. Expected: no counterexamples.

**Impact**: Would establish that Lorentzian polynomials carry not just a combinatorial M-convex support, but a *valued* M-convex structure — connecting to tropical geometry and valuated matroids.

**Catalog References**: `Pythagorean/LorentzianMConvex.lean` (exchange_from_decomp), `Catalog/FINAL/Pythagorean/MConvexBridge.lean`

**Proof Strategy**: Extend the spectral decomposition argument. The log-coefficient function satisfies ν(eᵢ+eⱼ) = -log(v(i)v(j) - B(i,j)). The valuated exchange should follow from the concavity of log and the PSD structure of B.

**Domain Bridges**: Tropical geometry ↔ discrete convex analysis ↔ algebraic geometry

**Lineage**: Extends the support theorem from set-valued to function-valued M-convexity.

**Ambition**: grand_challenge — would unify the Lorentzian and tropical matroid theories.

---

## Direction 2: Derivative Closure and Inductive Completion

**Conjecture**: If f is Lorentzian of degree d+1, then ∂f/∂xᵢ is Lorentzian of degree d for all i.

**Test**: For n=3, d≤5, verify computationally that all partial derivatives of Lorentzian polynomials remain Lorentzian. Check eigenvalue conditions on Hessians of derivatives.

**Impact**: Completes the inductive framework for the full Brändén-Huh theorem. Combined with the quadratic base case and the support lifting theorem, this would give a complete formal proof for all degrees.

**Catalog References**: `Pythagorean/LorentzianMConvex.lean` (newtonSupport_pderiv_eq, coeff_pderiv_eq)

**Proof Strategy**: Show that the Hessian of ∂f/∂xᵢ is a principal submatrix of a related Hessian of f, inheriting the one-positive-eigenvalue property.

**Domain Bridges**: Algebraic geometry ↔ analysis ↔ combinatorics

**Lineage**: Builds on the derivative-support infrastructure already formalized.

**Ambition**: solid_extension — the mathematical argument is well-understood, formalization is the challenge.

---

## Direction 3: Negative Dependence and Strongly Rayleigh Measures

**Conjecture**: The support of the generating polynomial of a strongly Rayleigh probability measure is M-convex. Moreover, the measure satisfies the *stochastic exchange property*: for events A, B with P(A)P(B) > 0 and A "dominating" B in some coordinate, there exists an exchange that preserves positive probability.

**Test**: Generate random determinantal point processes (which are strongly Rayleigh) on n=6 points. Compute the generating polynomial, verify Lorentzianity, check M-convexity of support.

**Impact**: Would provide a formal certificate that sampling algorithms for strongly Rayleigh measures are efficient, by reducing to M-convex optimization.

**Catalog References**: `Pythagorean/LorentzianMConvex.lean`, `Catalog/FINAL/Pythagorean/TropicalMConvexity.lean`

**Proof Strategy**: Show that the generating polynomial of a strongly Rayleigh measure is Lorentzian (this is known), then apply the support theorem.

**Domain Bridges**: Probability ↔ algebraic combinatorics ↔ optimization

**Lineage**: Applies the M-convex exchange theory to probabilistic settings.

**Ambition**: solid_extension — connects existing theories in a new formal framework.

---

## Direction 4: Tropical Hodge Theory via Support Geometry

**Conjecture**: The tropicalization of a Lorentzian polynomial defines a tropical hypersurface whose dual subdivision is a matroid subdivision — i.e., each cell corresponds to an M-convex set.

**Test**: Compute tropical hypersurfaces for Lorentzian polynomials with n=3, d≤4. Verify that the dual subdivisions are matroidal by checking the exchange property on each cell.

**Impact**: Would establish a concrete link between tropical Hodge theory and the Lorentzian polynomial framework, advancing the program of tropical analogues of classical algebraic geometry.

**Catalog References**: `Pythagorean/LorentzianMConvex.lean`, `Catalog/FINAL/Pythagorean/TropicalMarkov.lean`

**Proof Strategy**: Use the valuated M-convex structure (Direction 1) to control the combinatorics of the tropical hypersurface.

**Domain Bridges**: Tropical geometry ↔ Hodge theory ↔ polyhedral combinatorics

**Lineage**: Extends both the M-convex bridge and tropical Markov formalizations.

**Ambition**: grand_challenge — would open tropical Hodge theory to formal verification.

---

## Direction 5: Complexity of Lorentzian Recognition

**Conjecture**: Given a homogeneous polynomial f with nonneg integer coefficients (represented as a list of monomials), deciding whether f is Lorentzian is coNP-hard in general, but polynomial-time for fixed degree d.

**Test**: Implement the Lorentzian test for d=2 (eigenvalue computation, O(n³)). For d=3, benchmark the derivative-then-eigenvalue approach. For general d, estimate the complexity of the recursive eigenvalue test.

**Impact**: Would clarify the computational complexity landscape of Lorentzian recognition, guiding the design of certified algorithms.

**Catalog References**: `Pythagorean/LorentzianMConvex.lean` (IsLorentzianQuadratic definition)

**Proof Strategy**: For fixed d, the recursive derivative approach gives polynomial time (O(n^d · n³) for n variables). For general d, reduction from matrix permanent or related #P-hard problems.

**Domain Bridges**: Complexity theory ↔ algebraic combinatorics ↔ optimization

**Lineage**: Connects the algebraic formalization to algorithmic questions.

**Ambition**: solid_extension — the fixed-degree result is likely provable; the hardness result is more speculative.
