# Future Directions: Hyperbolic Number Theory

## Synthesis

This cycle established the foundational framework for arithmetic on the Poincaré disk: definitions of hyperbolic integers (as orbit points of PSL(2,ℤ)), Möbius addition (the natural arithmetic operation), and hyperbolic primes (indecomposable lattice points). We verified the group structure of SL(2,ℝ), the gyrogroup properties of Möbius addition (identity, inverse, unit-norm gyration), and lattice-point counting monotonicity. Most significantly, the cross-domain bridge theorem connecting the Riemann Hypothesis critical line to the Poincaré disk boundary reveals that the distribution of zeta zeros is fundamentally a hyperbolic-geometric phenomenon.

The most promising cross-domain connection is the **RH ↔ Poincaré disk** bridge. The Cayley transform maps the critical line Re(s) = 1/2 to a curve inside the unit disk, and the Riemann Hypothesis becomes a containment statement in the Poincaré disk. This geometrization potentially connects the analytic machinery of the Selberg trace formula (which relates the Laplacian spectrum on hyperbolic surfaces to closed geodesic lengths) to the distribution of zeta zeros. The Catalog already contains infrastructure for critical-line analysis (`Algebra/Foundations.lean: critical_line_implies_unit_disk`) and fixed-point dynamics (`Pythagorean/DynamicalSquaring.lean: prime_has_two_fixed_points`), both of which could integrate with the hyperbolic framework.

The highest breakthrough potential lies in Direction 1 (Selberg Trace Formula Bridge), because it would connect the formally verified SL(2,ℝ) group structure to the spectral theory of automorphic forms — a domain where deep analytic results (Selberg's eigenvalue conjecture, Ramanujan-Petersson) could become accessible to formal verification.

---

### Direction 1: Selberg Trace Formula for Hyperbolic Lattices

**Conjecture**: For the PSL(2,ℤ) lattice Λ on the Poincaré disk, the counting function N(R) = #{n : ‖Λ(n)‖_H ≤ R} satisfies the asymptotic N(R) = (area of hyperbolic disk of radius R) / (area of fundamental domain) + O(R·e^{R/2}), i.e., N(R) = (3/π)·(cosh R - 1) + O(R·e^{R/2}).

**Test**: Compute N(R) for R ∈ {1, 2, 3, 5, 8, 10} using the BFS orbit generator and compare with the predicted main term. The error term should grow slower than the main term (which is ~e^R). If the ratio |N(R) - (3/π)(cosh R - 1)| / (R·e^{R/2}) diverges for large R, the error bound is wrong.

**Impact**: If true, this gives a provable asymptotic formula for hyperbolic lattice point counting — the curved-space analogue of the Gauss circle problem. It would also provide a formal bridge between the algebraic (SL(2,ℝ) group structure) and analytic (spectral theory) aspects of hyperbolic geometry.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean: HyperbolicLattice`, `Speculative/HyperbolicNumberTheory/Theorems.lean: hypCountingN_mono`, `Algebra/Foundations.lean: critical_line_implies_unit_disk`

**Proof Strategy**: 
1. Formalize the hyperbolic area formula: area of a disk of radius R = 4π·sinh²(R/2).
2. Formalize the fundamental domain of PSL(2,ℤ) and compute its area = π/3.
3. State the lattice point counting theorem as an inequality for finite N.
4. The main tool is the Selberg trace formula, which requires formalizing the heat kernel on the hyperbolic plane.

**Domain Bridges**: NumberTheory <-> HyperbolicGeometry, Algebra <-> SpectralTheory

**Lineage**: Builds on the SL(2,ℝ) group structure (SL2R.mul_assoc', SL2R.mul_inv_eq) and counting monotonicity (hypCountingN_mono) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Gyrogroup Axioms and Hyperbolic Vector Spaces

**Conjecture**: Möbius addition on the Poincaré disk satisfies the full gyrogroup axioms: (1) left gyroassociativity: a ⊕ (b ⊕ c) = (a ⊕ b) ⊕ gyr[a,b](c), (2) left loop property: gyr[a,b] = gyr[a ⊕ b, b], and these can be formally verified in Lean 4.

**Test**: Verify each axiom algebraically by expanding Möbius addition and gyration in terms of complex arithmetic. Each should reduce to a polynomial identity after clearing denominators. Test numerically on 1000 random triples (a, b, c) with |a|, |b|, |c| < 0.99.

**Impact**: A formally verified gyrogroup structure would be the first complete machine-checked verification of Ungar's theory, establishing that hyperbolic geometry has a rigorous algebraic backbone analogous to vector space theory.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean: moebiusAdd`, `Speculative/HyperbolicNumberTheory/Theorems.lean: moebiusAdd_zero_left, moebiusAdd_neg_self, gyrationFactor_norm`

**Proof Strategy**:
1. Define gyr[a,b](c) = gyrationFactor(a,b) * c.
2. For gyroassociativity: expand both sides as rational functions of a, ā, b, b̄, c, c̄ and show equality by field_simp + ring.
3. For the left loop property: similarly expand and verify.
4. Key helper: prove that Möbius addition preserves the disk (|z ⊕ w| < 1 when |z|, |w| < 1).

**Domain Bridges**: Algebra <-> HyperbolicGeometry, Algebra <-> Physics (special relativity)

**Lineage**: Directly extends the Möbius addition properties (moebiusAdd_zero_left, moebiusAdd_zero_right, moebiusAdd_neg_self) and gyration norm theorem (gyrationFactor_norm) from this cycle.

**Ambition**: extension

---

### Direction 3: Hyperbolic Zeta Function and Functional Equation

**Conjecture**: The hyperbolic zeta function ζ_H(s) = Σ_{γ ∈ PSL(2,ℤ), γ ≠ id} e^{-s·d(γ·i, i)}, where d is hyperbolic distance, converges for Re(s) > 1 and satisfies a functional equation relating ζ_H(s) to ζ_H(1-s) via a gamma factor.

**Test**: Compute partial sums of ζ_H(s) for the first 500 orbit points at s = 2, 3, 5 and verify convergence. Then compute at s = 1/2 + it for several values of t and check whether the values match the predicted functional equation. If the partial sums diverge at Re(s) = 1.5 (where they should converge), the conjecture is false.

**Impact**: A hyperbolic zeta function with a functional equation would be a genuinely new object in analytic number theory, potentially amenable to the spectral methods that are unavailable for the classical Riemann zeta function.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean: hypNorm, HyperbolicLattice`, `Speculative/HyperbolicNumberTheory/Theorems.lean: hypNorm_lt_one`, `Algebra/Foundations.lean: critical_line_implies_unit_disk`

**Proof Strategy**:
1. Formalize the hyperbolic distance d(γ·i, i) = 2·arctanh(|cayley(γ·i)|).
2. Prove convergence for Re(s) > 1 using the Huber counting theorem (orbit points grow as e^R).
3. For the functional equation: use the Selberg/Gangolli approach relating ζ_H to the resolvent of the Laplacian on Γ\H.
4. Helper lemmas: summability of e^{-s·R} against the counting measure, analytic continuation.

**Domain Bridges**: NumberTheory <-> HyperbolicGeometry, AnalyticNumberTheory <-> SpectralGeometry

**Lineage**: Builds on the lattice definition and counting theory from this cycle, and connects to the critical line bridge theorem.

**Ambition**: grand_challenge

---

### Direction 4: Unique Factorization in Hyperbolic Integers

**Conjecture**: The hyperbolic integers Z_H (orbit of PSL(2,ℤ) on the Poincaré disk) do NOT have unique factorization under Möbius addition. Specifically, there exist lattice points that can be expressed as z₁ ⊕ z₂ and also as z₃ ⊕ z₄ where {z₁, z₂} ≠ {z₃, z₄} and all four are hyperbolic primes.

**Test**: For the first 100 orbit points, find all decompositions as Möbius sums of two hyperbolic primes. If any point has more than one such decomposition (up to order and gyration), unique factorization fails. Expected: failure should occur by index 30-50 due to the non-commutativity of Möbius addition.

**Impact**: If unique factorization fails, it reveals a fundamental difference between flat and curved arithmetic. The classification of how it fails (e.g., class number, factorization into ideals) would create a rich algebraic theory mirroring classical algebraic number theory.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean: IsHypPrime, moebiusAdd`, `Speculative/HyperbolicNumberTheory/Theorems.lean: moebiusAdd_neg_self`

**Proof Strategy**:
1. Computationally enumerate decompositions for the first 100 lattice points.
2. If non-uniqueness is found, formalize it as a constructive existence proof in Lean.
3. If it appears unique, investigate whether gyration equivalence classes restore uniqueness.
4. Define a "hyperbolic class group" measuring the failure of unique factorization.

**Domain Bridges**: NumberTheory <-> Algebra, HyperbolicGeometry <-> AlgebraicNumberTheory

**Lineage**: Builds on the hyperbolic prime definition (IsHypPrime) and Möbius addition properties from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical-Hyperbolic Bridge via Logarithmic Limit

**Conjecture**: The Möbius addition z ⊕ w = (z+w)/(1+z̄w) degenerates to tropical addition max(z,w) in the logarithmic limit. Specifically, for points on the positive real axis, if we set z = tanh(a/2) and w = tanh(b/2), then z ⊕ w = tanh((a+b)/2), and as a, b → ∞, the addition becomes max-plus arithmetic (tropical).

**Test**: Verify that tanh(a/2) ⊕ tanh(b/2) = tanh((a+b)/2) algebraically for real a, b > 0. Then verify that lim_{λ→∞} (1/λ)·log(exp(λa) + exp(λb)) = max(a,b) is the tropical limit. The bridge would show that tropical geometry is the "boundary" of hyperbolic arithmetic.

**Impact**: This would establish a formal connection between the Catalog's tropical geometry (`Tropical/` directory) and hyperbolic number theory, showing that tropical arithmetic arises as a degeneration of hyperbolic arithmetic at the boundary of the Poincaré disk.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean: moebiusAdd`, Tropical geometry files in the Catalog

**Proof Strategy**:
1. Prove the identity tanh(a/2) ⊕ tanh(b/2) = tanh((a+b)/2) using the addition formula for tanh.
2. Show that in the limit |z|, |w| → 1 along the real axis, Möbius addition behaves like max.
3. Formalize the tropical semiring and show it is a quotient of the hyperbolic gyrogroup in an appropriate sense.

**Domain Bridges**: HyperbolicGeometry <-> TropicalGeometry, NumberTheory <-> Tropical

**Lineage**: Builds on Möbius addition (moebiusAdd_zero_left, moebiusAdd_zero_right) and extends to the Tropical section of the Catalog.

**Ambition**: extension
