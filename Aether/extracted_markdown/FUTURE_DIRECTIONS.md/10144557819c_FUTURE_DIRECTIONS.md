# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundational algebraic layer for hyperbolic number theory: the Einstein addition group on (−1, 1), SL₂(ℤ) trace arithmetic with the Chebyshev recurrence, and cross-domain bridges to both tropical geometry and the Riemann Hypothesis via the Cayley transform. The most surprising discovery was that the simultaneous induction technique — proving monotonicity and lower bounds together — was essential for the Chebyshev trace growth theorems, suggesting that hyperbolic arithmetic inherently couples growth and ordering in ways that Euclidean arithmetic does not.

The most promising cross-domain connection is the **Hilbert-tropical bridge**: the fact that the Hilbert metric on a simplex equals the tropical metric in logarithmic coordinates. This bridge is currently formalized only for the one-dimensional case (positive reals); extending it to higher-dimensional simplices would connect the full Poincaré disk geometry to tropical algebraic geometry, potentially yielding new tools for studying the Selberg zeta function via tropical methods. The tropical Riemann-Roch theorem (Baker-Norine) could then be pulled back to hyperbolic geometry, giving a "spectral" Riemann-Roch for modular curves.

The second major opportunity is the **prime geodesic theorem**: formalizing the asymptotic count of primitive hyperbolic conjugacy classes. Our Chebyshev-trace machinery provides the combinatorial backbone, and the trace surjectivity theorem guarantees a rich supply of elements. The missing ingredient is the analytic number theory (Tauberian theorems, Perron's formula) needed to convert the algebraic counting into asymptotic estimates.

---

### Direction 1: Tropical Selberg Trace Formula

**Conjecture**: The Selberg trace formula for SL₂(ℤ)\H can be reformulated as an identity in tropical algebra, where the spectral side becomes a tropical polynomial and the geometric side becomes a sum over tropical geodesics. Specifically, the Selberg zeta function Z(s) can be expressed as a tropical determinant of the Laplacian on the Cayley graph of SL₂(ℤ).

**Test**: For the modular surface SL₂(ℤ)\H, compute the tropical Selberg zeta function Z_trop(s) for s ∈ {2, 3, 4, 5} by summing over primitive conjugacy classes with trace ≤ 100. Compare with the classical values Z(s). If the tropical and classical values disagree by more than 1%, the conjecture is falsified.

**Impact**: If true, this would provide a completely new approach to the Riemann Hypothesis for automorphic L-functions, using tropical methods that are inherently combinatorial and potentially algorithmically tractable. If false, the failure would reveal which aspects of the spectral geometry resist tropicalization.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (chebyshevTrace, SL2Z.trace_conjugate), `Tropical/` directory for tropical algebra foundations.

**Proof Strategy**: 
1. Formalize the tropical determinant of a weighted graph Laplacian
2. Define the Cayley graph of SL₂(ℤ) with edge weights from translation lengths
3. Prove that the tropical determinant specializes to the Ihara-Bass formula
4. Connect Ihara-Bass to the Selberg zeta function via the Hashimoto edge operator
5. Key lemma: the tropical log of the Selberg zeta function equals the Ihara zeta function

**Domain Bridges**: Hyperbolic Geometry <-> Tropical Algebra, Number Theory <-> Graph Theory

**Lineage**: Builds on the Hilbert-tropical bridge (hilbert_eq_tropical_log) and trace arithmetic from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Prime Geodesic Theorem via Chebyshev Methods

**Conjecture**: The number of primitive hyperbolic conjugacy classes in SL₂(ℤ) with trace ≤ T satisfies:
$$\pi_{\text{hyp}}(T) = \text{Li}(T^2) + O(T^{3/2} \log T)$$
where Li is the logarithmic integral. The error term O(T^{3/2} log T) is equivalent to the Selberg eigenvalue conjecture λ₁ ≥ 1/4.

**Test**: Enumerate all primitive traces ≤ 1000 (using the Chebyshev sieve: a trace t is primitive iff t ≠ chebyshevTrace(t₀, n) for any |t₀| < |t| and n ≥ 2). Compare π_hyp(T) with Li(T²) for T ∈ {100, 200, 500, 1000}. The relative error should be ≤ 10/√T.

**Impact**: This would be the first machine-verified formalization of a prime geodesic theorem, establishing the asymptotic count of primitive geodesics on the modular surface with an explicit error term.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (chebyshevTrace_strict_mono, isPrimeTrace, SL2Z.trace_surjective)

**Proof Strategy**:
1. Formalize the Chebyshev sieve: characterize which integers are in the range of chebyshevTrace(t₀, n) for n ≥ 2
2. Prove that the set of non-primitive traces has density 0 (most integers are primitive)
3. Connect trace counting to the Dirichlet series ∑ 1/|t|^s via partial summation
4. Apply Tauberian theorems (Wiener-Ikehara) to extract the asymptotic
5. Key lemma: the Chebyshev-trace values for n ≥ 2 grow at least as fast as φ^(2n) where φ = (1+√5)/2

**Domain Bridges**: Number Theory <-> Spectral Geometry, Combinatorics <-> Analysis

**Lineage**: Builds on chebyshevTrace_ge_two, chebyshevTrace_strict_mono, and the trace classification from this cycle.

**Ambition**: extension

---

### Direction 3: Einstein Addition in Higher Dimensions — Gyrogroups

**Conjecture**: The Möbius addition on the Poincaré disk model in dimension n satisfies the gyrogroup axioms, and the gyration operator gyr[a,b] can be expressed as a rotation matrix in SO(n) whose angle depends only on |a|, |b|, and the angle between a and b.

**Test**: Implement Möbius addition in ℝ³ and verify the gyroassociative law a ⊕ (b ⊕ c) = (a ⊕ b) ⊕ gyr[a,b](c) for 10000 random triples of points in the unit ball. The law should hold to machine precision (< 10⁻¹²).

**Impact**: This would establish the gyrogroup structure of the full Poincaré ball model, enabling hyperbolic neural networks to be formulated as gyrogroup modules with rigorous algebraic foundations.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (einsteinAdd_assoc, einsteinAdd_in_interval), `MachineLearning/` directory for ML foundations.

**Proof Strategy**:
1. Define Möbius addition in ℝⁿ: a ⊕ b = ((1+2⟨a,b⟩+|b|²)a + (1-|a|²)b) / (1+2⟨a,b⟩+|a|²|b|²)
2. Define the gyration operator: gyr[a,b](c) = ⊖(a ⊕ b) ⊕ (a ⊕ (b ⊕ c))
3. Prove gyr[a,b] ∈ SO(n) by showing it preserves inner products
4. Prove the gyroassociative law using the explicit formula
5. Key lemma: the denominator 1+2⟨a,b⟩+|a|²|b|² > 0 for |a|,|b| < 1

**Domain Bridges**: Algebra <-> MachineLearning, Geometry <-> Physics

**Lineage**: Directly extends the Einstein addition group from this cycle to higher dimensions.

**Ambition**: extension

---

### Direction 4: Hyperbolic Dirichlet Convolution and L-functions

**Conjecture**: There exists a "hyperbolic Dirichlet convolution" ★ on arithmetic functions f: ℤ → ℂ such that:
1. (f ★ g)(t) = ∑_{t₁·t₂ = t via Chebyshev} f(t₁)·g(t₂) where the sum is over pairs (t₁, n) with chebyshevTrace(t₁, n) = t
2. The convolution is associative
3. The delta function at trace 2 is the identity
4. The resulting "hyperbolic L-functions" L(s, χ) = ∑_t χ(t)/|t|^s satisfy a functional equation

**Test**: Compute the hyperbolic L-function for the trivial character up to trace 100. The function should have a meromorphic continuation with a pole at s = 1 (like the Riemann zeta function). Numerically verify the functional equation L(s) = ε(s) · L(1−s) for s ∈ {0.3, 0.5, 0.7} to 6 digits.

**Impact**: This would create a full "analytic number theory" for the hyperbolic setting, potentially providing a testing ground for the Riemann Hypothesis in a more tractable context.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (HypArithFn, chebyshevTrace, SL2Z.trace_surjective), `Algebra/Foundations.lean` (critical_line_implies_unit_disk)

**Proof Strategy**:
1. Define the "Chebyshev factorization": t has a (t₀, n)-factorization if chebyshevTrace(t₀, n) = t
2. Prove that the number of factorizations is finite for each t
3. Define the convolution using the Chebyshev factorization
4. Prove associativity by relating to composition of SL₂(ℤ) elements
5. Prove the functional equation using the Selberg trace formula

**Domain Bridges**: Number Theory <-> Algebra, Spectral Theory <-> Analysis

**Lineage**: Builds on HypArithFn and the Chebyshev-trace infrastructure from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Cayley Transform and Spectral Gap Bounds

**Conjecture**: The Cayley transform mapping from the critical strip to the unit disk can be extended to a rigorous equivalence: the Riemann Hypothesis for a Dirichlet L-function L(s, χ) is equivalent to a spectral gap condition ‖T_χ‖ < 1 for an explicit operator T_χ on the Poincaré disk, where T_χ is constructed from the Cayley transform of the L-function's Euler product.

**Test**: For the Riemann zeta function (χ = 1), compute the operator norm ‖T₁‖ numerically using a finite-dimensional truncation with N = 100 terms. If ‖T₁‖ < 1, this provides numerical evidence for RH. If ‖T₁‖ ≥ 1, identify which eigenvalue causes the failure and determine if it corresponds to a known zeta zero off the critical line.

**Impact**: If the equivalence holds, it would reformulate the Riemann Hypothesis as a concrete operator theory problem on the Poincaré disk — potentially making it amenable to techniques from functional analysis and operator algebras that are not available for the classical formulation.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (critical_line_to_disk'), `FINAL/Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Speculative/IdempotentCollapse/TheoreticalExtensions.lean` (RH_via_fixed_points)

**Proof Strategy**:
1. Formalize the Cayley transform as a unitary equivalence between L²(critical strip) and L²(disk)
2. Express the Euler product as a product of disk automorphisms
3. Define T_χ as the composition of these automorphisms
4. Prove that RH ⟺ spectral radius of T_χ < 1
5. Key lemma: the critical_line_to_disk theorem shows each factor maps into the disk

**Domain Bridges**: Number Theory <-> Functional Analysis, Algebra <-> Physics

**Lineage**: Directly extends critical_line_to_disk' and connects to RH_via_fixed_points from the catalog.

**Ambition**: grand_challenge
