# Future Directions: Conformal Spectral Theory

## Synthesis

This research cycle established the *Conformal Spectral Triple* (CST) as a novel mathematical structure capturing the spectral correspondence between Laplacians on conformally related manifolds. The key discovery is the **dimension ladder**: eigenvalues on spheres of different dimensions are connected by the simple formula λ_{n+m,l} = λ_{n,l} + ml, reducing the spectral theory of all spheres to the circle plus linear corrections. Combined with the **Casimir decomposition** l(l+n-1) = (l+(n-1)/2)² - ((n-1)/2)², this reveals that the entire spherical spectrum is a shifted quadratic form in a single variable.

The most promising cross-domain connection is between the CST and tropical geometry. The spectral shift s_n = ((n-1)/2)² is a convex function of dimension, and the dimension ladder is a *linear* recursion — both hallmarks of tropical (max-plus) algebra. The conformal weight σ_n = (2/(1+r²))^n, being multiplicative in dimension, is a homomorphism from (ℕ,+) to (ℝ>0, ×), which tropicalizes to a linear functional. This suggests a **tropical spectral theory** where eigenvalue computations reduce to combinatorial optimization over "dimension paths."

The cycle's key negative result — the disproof of Casimir Weyl symmetry — is equally informative. It shows that the Casimir parameterization, while revealing hidden regularity, is NOT compatible with the natural Weyl group action. The obstruction is the asymmetry of Nat subtraction. This points toward a deeper structure in the *integer-valued* (rather than natural-number-valued) Casimir theory.

---

### Direction 1: Tropical Spectral Theory of Conformal Maps

**Conjecture**: The spectral data of the Conformal Spectral Triple admits a tropical degeneration: there exists a one-parameter family CST(n, ε) such that as ε → 0, the eigenvalue sum Σ λ_l converges (after rescaling) to a tropical polynomial Σ max(l + (n-1)/2, 0)². Concretely, the spectral trace formula Σ_{l<N} l(l+n-1) = N(N-1)(2N-1)/6 + (n-1)N(N-1)/2 should tropicalize (under the Maslov dequantization ε log) to max(3 log N, 2 log N + log n).

**Test**: Compute the Maslov limit lim_{ε→0} ε · log(Σ_{l<N} (ε^{-l(l+n-1)})) for N = 100 and n = 2, 3, 4, 5 numerically. If the limit equals (N-1)(N-1+n-1) = (N-1)(N+n-2), the conjecture is supported. If not, identify the correct tropical formula.

**Impact**: If true, this would establish the first connection between conformal spectral theory and tropical geometry, enabling combinatorial methods for eigenvalue estimation on manifolds. Could lead to a tropical Weyl law.

**Catalog References**: `Tropical/`, `Geometry/StereographicFourier/Advanced.lean` (eigenvalue_sum_formula, eigenvalue_dimension_shift_general)

**Proof Strategy**: (1) Write the spectral zeta function as a generating function. (2) Apply the Viro patchworking / Maslov dequantization. (3) Identify the Newton polygon. (4) Show the tropical limit recovers the leading asymptotics.

**Domain Bridges**: Geometry (conformal spectral theory) ↔ Tropical (max-plus algebra)

**Lineage**: Builds on eigenvalue_sum_formula and conformal_weight_mul_dim from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Zeta Function of the CST and Special Values

**Conjecture**: The spectral zeta function ζ_{CST}(s) = Σ_{l≥1} d(n,l) · (C_{n,l} - s_n)^{-s}, where d(n,l) = C(n+l,n) - C(n+l-2,n) is the multiplicity, has special values at negative integers s = -k that are polynomial in n. Specifically, ζ_{CST}(-1) = (n+1)²(n-1)/12 · B₂ where B₂ = 1/6 is the second Bernoulli number.

**Test**: Compute ζ_{CST}(-1) numerically for n = 2, 3, 4, 5, 6 by summing the first 1000 terms (with analytic continuation via Ramanujan summation or zeta regularization). Compare with the conjectured polynomial formula. If they disagree, find the correct polynomial.

**Impact**: Special values of spectral zeta functions encode geometric invariants (analytic torsion, functional determinants). Expressing them as polynomials in dimension would give a new proof of the Kinkelin-Bendersky formula for products of gamma functions.

**Catalog References**: `Geometry/StereographicFourier/Spectral.lean` (eigenvalue_casimir_relation, casimir_nonneg), `Geometry/StereographicFourier/Advanced.lean` (eigenvalue_sum_formula)

**Proof Strategy**: (1) Express the zeta function using the Casimir decomposition. (2) Use the Euler-Maclaurin formula to compute special values. (3) Relate to known results on the spectral zeta of Sⁿ (Minakshisundaram-Pleijel).

**Domain Bridges**: Geometry (spectral zeta) ↔ Algebra (Bernoulli numbers, gamma functions)

**Lineage**: Builds on eigenvalue_sum_formula and the Casimir structure from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Higher-Order GJMS Operators and the Dimension Ladder

**Conjecture**: The dimension ladder λ_{n+2,l} = λ_{n,l} + 2l generalizes to GJMS operators of order 2k: if Pₖ is the k-th GJMS operator on Sⁿ with eigenvalues μₖ(n,l) = Π_{j=0}^{k-1} (l+j)(l+n-1-j), then μₖ(n+2,l) = μₖ(n,l) + Q_k(n,l) where Q_k is a polynomial of degree 2k-1 in l. For k=1 (the Laplacian), Q_1 = 2l. For k=2 (the Paneitz operator), conjecture Q_2(n,l) = 4l³ + ... (determine the exact polynomial).

**Test**: Compute μ₂(n,l) = l(l+1)(l+n-1)(l+n-2) for n = 3,5,7 and l = 0,...,5. Verify μ₂(n+2,l) - μ₂(n,l) is a degree-3 polynomial in l and determine its coefficients.

**Impact**: Would extend the dimension ladder to the full GJMS hierarchy, connecting conformal geometry to the algebraic combinatorics of rising/falling factorials.

**Catalog References**: `Geometry/StereographicFourier/Spectral.lean` (eigenvalue_dimension_ladder), `Geometry/StereographicFourier/Advanced.lean` (eigenvalue_dimension_shift_general)

**Proof Strategy**: (1) Express GJMS eigenvalues as products of linear factors. (2) Use the Pochhammer symbol / binomial coefficient identities. (3) Telescope the difference μₖ(n+2,l) - μₖ(n,l). (4) Identify the leading and subleading terms.

**Domain Bridges**: Geometry (GJMS operators) ↔ Algebra (Pochhammer symbols, hypergeometric functions)

**Lineage**: Direct extension of the dimension ladder from this cycle.

**Ambition**: extension

---

### Direction 4: Conformal Spectral Triples on Hyperbolic Space

**Conjecture**: The CST construction extends to the conformal compactification of hyperbolic space Hⁿ, where the eigenvalues are *continuous* (the spectrum of Δ_{Hⁿ} is [((n-1)/2)², ∞)). The Casimir decomposition gives:

λ = ((n-1)/2 + iξ)² for ξ ∈ ℝ (the spectral parameter)

and the "dimension ladder" becomes: for the continuous spectrum of H^{n+2}, the spectral parameter ξ is related to that of Hⁿ by ξ_{n+2}² = ξ_n² + ... (determine the relation). The conformal weight should be σ_n^{hyp}(r²) = (2/(1-r²))^n for the Poincaré ball model.

**Test**: Compute the Harish-Chandra c-function for Hⁿ in low dimensions and verify that the Casimir structure persists in the continuous spectrum. Compare the conformal weights for the ball and half-space models.

**Impact**: Would unify the spectral theory of compact (Sⁿ) and non-compact (Hⁿ) symmetric spaces through a common CST framework.

**Catalog References**: `Geometry/HyperbolicNumberTheory.lean` (conformal_factor_transform), `Geometry/StereographicFourier/Defs.lean` (ConformalSpectralTriple)

**Proof Strategy**: (1) Replace Sⁿ eigenvalues with Hⁿ spectral parameter. (2) Verify the Casimir form (n-1)/2 + iξ. (3) Prove weight properties for (2/(1-r²))^n. (4) Define a "continuous CST" structure.

**Domain Bridges**: Geometry (hyperbolic space) ↔ Physics (scattering theory, Selberg zeta)

**Lineage**: Extends the CST from compact to non-compact symmetric spaces.

**Ambition**: extension

---

### Direction 5: Computational Spherical Harmonics via the Dimension Ladder

**Conjecture**: The dimension ladder λ_{n+2,l} = λ_{n,l} + 2l can be promoted to an *algorithm* for computing spherical harmonics in high dimensions. Given the spherical harmonics on S¹ (which are just e^{ilθ}), one can reconstruct the radial part of spherical harmonics on Sⁿ by solving a sequence of ODE boundary value problems, one for each dimension step. The algorithm should run in O(n · L²) time to compute all harmonics up to degree L on Sⁿ, compared to O(n² · L²) for the standard recurrence.

**Test**: Implement the ladder algorithm in Python/Julia for n up to 100 and L up to 50. Benchmark against the standard Gegenbauer polynomial computation. The ladder algorithm should be faster by a factor of n for large n.

**Impact**: Would provide a practical computational tool for high-dimensional harmonic analysis, relevant to machine learning on spheres (spherical CNNs, climate modeling on the globe).

**Catalog References**: `Geometry/StereographicFourier/Spectral.lean` (eigenvalue_dimension_ladder), `Computation/`

**Proof Strategy**: (1) Derive the ODE for the radial profile at each dimension step. (2) Show the step-by-step solution equals the Gegenbauer polynomial. (3) Prove correctness by induction on dimension. (4) Analyze computational complexity.

**Domain Bridges**: Geometry (spectral theory) ↔ Computation (algorithm design) ↔ MachineLearning (spherical CNNs)

**Lineage**: Computational application of the dimension ladder.

**Ambition**: extension
