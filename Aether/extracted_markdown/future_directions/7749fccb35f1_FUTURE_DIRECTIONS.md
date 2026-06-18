# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the algebraic foundations of arithmetic on the Poincaré disk: the Einstein velocity group, the rapidity isomorphism, the SL₂(ℤ) trace trichotomy, and the cross-ratio positivity for the Poincaré metric. These results bridge three traditionally separate domains — special relativity (the Einstein addition formula), hyperbolic geometry (the Poincaré disk model), and number theory (prime counting via the modular group).

The most promising cross-domain connection discovered is the **rapidity isomorphism** (Theorem `rapidity_additive`), which converts the nonlinear Einstein addition to ordinary addition via the logarithmic map artanh. This bridge has unexploited consequences: it means every result about (ℝ, +) translates to a result about the Einstein group, but the *geometric* interpretation changes fundamentally. In particular, the uniform distribution of ℤ in ℝ becomes a *hyperbolic* distribution in the disk, with exponentially increasing density near the boundary — exactly the regime where the prime geodesic theorem operates. The connection between the rapidity isomorphism, the trace classification (`classifyByTrace`), and the cross-ratio metric (`cross_ratio_denom_pos`) provides a complete algebraic toolkit for studying discrete group actions on hyperbolic space.

The falsifiable conjecture (that π_H(N) ~ N²/(2 log N)) was computationally refuted, which itself is informative: it demonstrates that trace-based prime counting follows the classical PNT asymptotic, not the geometric lattice-point asymptotic. This distinction — between algebraic and geometric counting in hyperbolic number theory — is a key insight that should guide future work toward the Selberg trace formula, where both types of counting appear on opposite sides of the equation.

---

### Direction 1: Selberg Trace Formula for PSL(2, ℤ)

**Conjecture**: The Selberg trace formula for PSL(2, ℤ) can be formally stated and partially verified by decomposing it into three independently provable contributions: the identity term (area of the fundamental domain = π/3), the elliptic term (finite sum over elliptic conjugacy classes), and the hyperbolic term (sum over primitive hyperbolic conjugacy classes weighted by log of the norm).

**Test**: Formalize the statement of the trace formula for a specific test function (e.g., the heat kernel h(r) = e^{-t(r²+1/4)}). Verify the identity and elliptic contributions numerically against known values. The identity contribution should be Area(Γ\ℍ)/4π · ∫ h(r) r·tanh(πr) dr, and for the modular group Area(Γ\ℍ) = π/3. Check that the numerical trace formula matches the known spectrum (eigenvalues of the Laplacian on the modular surface).

**Impact**: A formal Selberg trace formula would be a landmark achievement, connecting spectral theory to geometry in a machine-verified way. It would enable formal proofs of the prime geodesic theorem and provide a foundation for attacking the Selberg eigenvalue conjecture (λ₁ ≥ 1/4 for congruence subgroups).

**Catalog References**: `Logic/HyperbolicArithmetic/Defs.lean` (SL2Class, classifyByTrace), `Logic/HyperbolicArithmetic/Theorems.lean` (trace classification theorems), `Catalog/MachineLearning/HyperbolicNumberTheory/Defs.lean` (SL2Z structure)

**Proof Strategy**: 
1. Formalize the fundamental domain of PSL(2, ℤ) as a region in the upper half-plane.
2. Prove Area(Γ\ℍ) = π/3 using the standard calculation (integration over the standard fundamental domain).
3. Classify all elliptic conjugacy classes in PSL(2, ℤ): there are exactly two, represented by S (order 2, trace 0) and ST (order 3, trace 1).
4. Define the test function space and the spectral side (sum over eigenvalues).
5. State the trace formula as an equality between spectral and geometric sides.
6. Verify for the constant function h = 1 (which gives Weyl's law).

**Domain Bridges**: NumberTheory <-> SpectralTheory, Geometry <-> Analysis

**Lineage**: Builds on the trace classification (elliptic_trace_bounded, parabolic_iff_trace_pm2, hyperbolic_iff_trace_large) and the SL2Z structure from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Gyrogroup Structure for the Full Poincaré Disk

**Conjecture**: The Möbius addition on the open unit disk 𝔻 ⊂ ℂ, defined by
  a ⊕_M b = (a + b) / (1 + ā·b)
forms a *gyrocommutative gyrogroup*: it satisfies the left gyroassociative law
  a ⊕_M (b ⊕_M c) = (a ⊕_M b) ⊕_M gyr[a,b](c)
where gyr[a,b] is a rotation (the gyration) given by
  gyr[a,b](c) = ((1 + a·b̄) / (1 + ā·b)) · c

**Test**: Verify the gyroassociative law computationally for 1000 random triples (a, b, c) in the disk. Formalize the gyration operator in Lean and prove it is a rotation (|gyr[a,b](c)| = |c|). Prove the real case is trivially gyroassociative (the gyration is the identity, reducing to ordinary associativity — our einstein_add_assoc theorem).

**Impact**: The gyrogroup structure is the correct algebraic framework for non-Euclidean geometry. Formalizing it would provide the first machine-verified foundation for Ungar's gyrovector space theory, bridging abstract algebra and differential geometry. It would also enable formal proofs about the Thomas precession in special relativity.

**Catalog References**: `Logic/HyperbolicArithmetic/Defs.lean` (einsteinAdd', IsSubluminal, realGyration), `Logic/HyperbolicArithmetic/Theorems.lean` (einstein_add_assoc, einstein_add_subluminal)

**Proof Strategy**:
1. Define Möbius addition on ℂ (as a function on the disk subtype, not just ℝ).
2. Prove closure: |a ⊕_M b| < 1 when |a|, |b| < 1. Use the identity |1 + ā·b|² - |a + b|² = (1 - |a|²)(1 - |b|²).
3. Define the gyration operator gyr[a,b] and prove it maps the disk to itself.
4. Prove the left gyroassociative law by expanding definitions and using field_simp + ring after appropriate normSq manipulations.
5. Show that when restricted to ℝ, gyr[a,b] = id and gyroassociativity reduces to associativity.

**Domain Bridges**: Algebra <-> Geometry, Physics <-> NumberTheory

**Lineage**: Direct extension of the Einstein addition results (einstein_add_subluminal, einstein_add_assoc, rapidity_additive) from 1D to 2D.

**Ambition**: extension

---

### Direction 3: Prime Geodesic Theorem via Trace Asymptotics

**Conjecture**: The number of primitive hyperbolic conjugacy classes in PSL(2, ℤ) with trace norm at most T satisfies
  π_hyp(T) = li(T²) + O(T^{3/2})
where li(x) = ∫₂ˣ dt/ln(t) is the logarithmic integral. Equivalently, the number of prime geodesics on the modular surface with length at most L satisfies π_geod(L) ~ e^L / L.

**Test**: 
1. Enumerate all primitive hyperbolic conjugacy classes in PSL(2, ℤ) with |trace| ≤ 100. (A conjugacy class is determined by its trace for hyperbolic elements.)
2. Compute π_hyp(T) for T = 10, 20, 50, 100 and compare with li(T²).
3. Plot the error π_hyp(T) - li(T²) and verify it is O(T^{3/2}).

**Impact**: This would be the first formal verification of any case of the prime geodesic theorem, connecting the algebraic trace classification to the geometric counting of closed geodesics.

**Catalog References**: `Logic/HyperbolicArithmetic/Theorems.lean` (hypPrimeCount_lower_bound, hypPrimeCount_mono, hyperbolic_iff_trace_large), `FINAL/Algebra/Foundations.lean` (critical_line_implies_unit_disk)

**Proof Strategy**:
1. Define "primitive" hyperbolic elements: γ is primitive if γ ≠ δⁿ for any n > 1 and any δ.
2. Use the Markov theory of binary quadratic forms to enumerate primitive traces.
3. Establish the bijection between primitive hyperbolic conjugacy classes and classes of indefinite binary quadratic forms of discriminant t² - 4.
4. Apply the class number formula to count these classes.
5. Sum the class numbers and use analytic number theory (Dirichlet series) to extract asymptotics.

**Domain Bridges**: NumberTheory <-> Geometry, Algebra <-> Analysis

**Lineage**: Builds on the trace classification and hyperbolic prime counting from this cycle. Connects to `FINAL/Algebra/Foundations.lean` via the critical line ↔ unit disk bridge.

**Ambition**: grand_challenge

---

### Direction 4: Hyperbolic Zeta Function and Functional Equation

**Conjecture**: The Selberg zeta function for PSL(2, ℤ),
  Z(s) = ∏_{γ primitive} ∏_{k=0}^∞ (1 - N(γ)^{-(s+k)})
where N(γ) = ((tr(γ) + √(tr(γ)²-4))/2)², has a meromorphic continuation to ℂ and satisfies a functional equation relating Z(s) and Z(1-s).

**Test**: Compute Z(s) numerically for s on the critical line Re(s) = 1/2 using the first 50 primitive hyperbolic conjugacy classes. Verify that the zeros match the known eigenvalues of the Laplacian on the modular surface: λ_n = s_n(1 - s_n) where s_n = 1/2 + ir_n.

**Impact**: A formal functional equation for the Selberg zeta function would establish the "hyperbolic Riemann Hypothesis" on rigorous foundations. Unlike the classical Riemann Hypothesis, this version is *provable* — the zeros of Z(s) on the critical line correspond to eigenvalues of a self-adjoint operator (the Laplacian), which are real by the spectral theorem.

**Catalog References**: `Logic/HyperbolicArithmetic/Theorems.lean` (cross_ratio_denom_pos, hyperbolic_iff_trace_large), `FINAL/Algebra/Foundations.lean` (critical_line_implies_unit_disk)

**Proof Strategy**:
1. Define the Selberg zeta function as a formal product.
2. Prove absolute convergence for Re(s) > 1 using the prime geodesic theorem asymptotic.
3. Use the Selberg trace formula to establish the meromorphic continuation.
4. Derive the functional equation from the trace formula's symmetry.
5. Identify zeros with eigenvalues of the Laplacian and use self-adjointness to place them on the critical line.

**Domain Bridges**: NumberTheory <-> SpectralTheory, Analysis <-> Geometry

**Lineage**: Combines the trace classification with cross-ratio positivity. The critical_line_implies_unit_disk theorem from the catalog provides the bridge between s = 1/2 + it (critical line) and the disk model.

**Ambition**: grand_challenge

---

### Direction 5: Tropical Geometry of Hyperbolic Lattice Points

**Conjecture**: The tropical semiring (ℝ ∪ {∞}, min, +) provides a natural valuation-theoretic framework for the lattice point counting problem in hyperbolic space. Specifically, the "tropical norm" of a lattice point γ·o (defined as the hyperbolic distance d(o, γ·o)) satisfies a tropical Minkowski inequality, and the tropical zeta function ∑_{γ} e^{-s·d(o,γ·o)} converges for Re(s) > 1 (for cofinite groups).

**Test**: Compute the tropical zeta function for PSL(2, ℤ) using orbit points up to distance R = 10. Verify convergence behavior and compare with the Eisenstein series E(z, s) at the basepoint.

**Impact**: This would establish a new bridge between tropical geometry and automorphic forms, potentially providing combinatorial methods for studying lattice point asymptotics.

**Catalog References**: `Catalog/Tropical/Hyperbolicity.lean`, `Logic/HyperbolicArithmetic/Defs.lean` (crossRatioModSq, hypLatCount)

**Proof Strategy**:
1. Define the tropical norm on lattice points via the Poincaré metric.
2. Prove the tropical Minkowski inequality using the triangle inequality for hyperbolic distance.
3. Establish convergence of the tropical zeta function for Re(s) > 1 using lattice point counting bounds (N(R) ~ Ce^R).
4. Connect to Eisenstein series via the unfolding method.

**Domain Bridges**: Tropical <-> NumberTheory, Geometry <-> Algebra

**Lineage**: Bridges the cross-ratio metric results (cross_ratio_denom_pos) with existing tropical geometry infrastructure in the Catalog.

**Ambition**: extension
