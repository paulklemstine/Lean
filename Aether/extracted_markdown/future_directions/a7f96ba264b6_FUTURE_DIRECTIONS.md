# Future Directions: Hyperbolic Disk Arithmetic

## Synthesis

This cycle established the foundational algebra of the 1D Möbius gyrogroup: Möbius addition, subtraction, distance, iteration dynamics, halving, norm subadditivity, and exponential lattice growth. The most surprising result was the **gyration triviality theorem** — the fact that the 1D Möbius gyrogroup is secretly a group — which radically simplifies the algebraic theory in one dimension while highlighting that the genuinely new phenomena (non-associativity, Thomas precession, curvature-induced twisting) emerge only in dimension ≥ 2.

The most promising cross-domain connection is between **tropical arithmetic and hyperbolic geometry**. The Möbius norm subadditivity |a ⊕ b| ≤ |a| ⊕ |b| has the same structural shape as the tropical triangle inequality, and the exponential growth of hyperbolic lattice points mirrors the exponential behavior of tropical valuations. The Gap Decay Conjecture — that gap ratios converge to (1-a)/(1+a) — provides a sharp, testable prediction that connects the dynamical theory of Möbius iteration to fixed-point analysis and contraction mappings.

The highest breakthrough potential lies in **Direction 1** (higher-dimensional gyrogroups), because the non-trivial gyration in 2D+ creates a fundamentally new algebraic structure that could yield deep theorems about non-associative arithmetic. Direction 3 (hyperbolic primes) also has high potential: if unique factorization fails for hyperbolic integers, understanding *how* it fails could illuminate the role of curvature in number theory.

---

### Direction 1: Higher-Dimensional Möbius Gyrogroups and Non-Associative Arithmetic

**Conjecture**: The 2D complex Möbius gyrogroup (with gyr[a,b](c) = ((1+a·conj(b))/(|1+a·conj(b)|)) · c being a rotation) satisfies the gyroassociative law a ⊕ (b ⊕ c) = (a ⊕ b) ⊕ gyr[a,b](c) but NOT associativity. Moreover, the gyration group {gyr[a,b] : a, b ∈ 𝔻} generates SO(2) = {rotations of ℝ²}.

**Test**: Compute gyr[a,b](c) for a = 0.3+0.4i, b = -0.2+0.7i, c = 0.5-0.1i. Verify that gyr[a,b](c) ≠ c (non-trivial gyration) and that the gyroassociative law holds to machine precision while ordinary associativity fails.

**Impact**: If the gyration group is exactly SO(2), this connects Möbius gyrogroups to the theory of fiber bundles (the Möbius gyrogroup → base, SO(2) → fiber). This would give a purely algebraic construction of a principal bundle structure on the Poincaré disk. If the gyration group is a proper subgroup of SO(2), that would constrain which rotations arise from hyperbolic curvature.

**Catalog References**: `Bridges/HyperbolicDiskArithmetic.lean` (gyration_is_identity), `Pythagorean/HyperbolicNumberTheory.lean` (MoebiusGyrogroup)

**Proof Strategy**: 
1. Define complex Möbius addition a ⊕ b = (a + b)/(1 + conj(a)·b) on the complex unit disk.
2. Define the complex gyration gyr[a,b](c) = ((1 + a·conj(b))/(conj(1 + a·conj(b)))) · c.
3. Prove gyration is a rotation (|gyr[a,b](c)| = |c|).
4. Prove gyroassociativity by direct computation with field_simp and ring (after establishing denominator non-vanishing via Complex.normSq).
5. Exhibit specific a, b where gyr[a,b] ≠ id to show non-triviality.
6. Show the set of gyration angles is dense in [0, 2π) to prove the gyration group is all of SO(2).

**Domain Bridges**: Algebra <-> Geometry, Algebra <-> Physics (Thomas precession)

**Lineage**: Extends the gyration triviality theorem (this cycle). The 1D case showed gyration is trivial; the 2D case should show it is maximal.

**Ambition**: grand_challenge

---

### Direction 2: Proving the Gap Decay Conjecture via Contraction Analysis

**Conjecture**: For 0 < a < 1, the gap ratio gap(n+1)/gap(n) converges to (1-a)/(1+a) as n → ∞, where gap(n) = x_{n+1} - x_n and x_n is the Möbius iteration starting at 0 with generator a.

**Test**: For a = 0.5, verify that |gap(n+1)/gap(n) - 1/3| < 10⁻⁶ for all n ≥ 20. For a = 0.99, verify convergence to 0.01/1.99 ≈ 5.025 × 10⁻³ with similar precision.

**Impact**: This would establish the first quantitative convergence result for Möbius iteration dynamics, giving an exact rate of approach to the boundary. The proof technique (contraction mapping in artanh coordinates) could generalize to higher dimensions and to orbits of more general Möbius transformations. Failure would suggest that the dynamics are more subtle than a simple contraction, possibly exhibiting intermittent behavior near the boundary.

**Catalog References**: `Bridges/HyperbolicDiskArithmetic.lean` (moebius_iter_strict_mono, moebius_iter_gap_formula, gapDecayConjecture)

**Proof Strategy**: 
1. Transform to the artanh coordinate: let y_n = artanh(x_n). Then the Möbius iteration x_{n+1} = a ⊕ x_n becomes y_{n+1} = artanh(a) + y_n (ordinary addition!).
2. The gap in x-coordinates is gap(n) = x_{n+1} - x_n = tanh(y_{n+1}) - tanh(y_n).
3. By the mean value theorem, gap(n) = sech²(ξ_n) · artanh(a) for some ξ_n ∈ (y_n, y_{n+1}).
4. Since y_n → ∞ linearly, sech²(y_n) ~ 4e^{-2y_n}, giving gap(n) ~ C · e^{-2n·artanh(a)}.
5. The ratio gap(n+1)/gap(n) → e^{-2·artanh(a)} = (1-a)/(1+a), since 2·artanh(a) = ln((1+a)/(1-a)).
6. Key lemma needed: artanh(a ⊕ b) = artanh(a) + artanh(b) (the artanh homomorphism).

**Domain Bridges**: Analysis <-> Dynamics, Algebra <-> Geometry

**Lineage**: Directly extends moebius_iter_strict_mono and moebius_iter_gap_formula from this cycle.

**Ambition**: extension

---

### Direction 3: Hyperbolic Primes and Unique Factorization

**Conjecture**: Define a hyperbolic integer x_n (n ≥ 2) to be a "hyperbolic prime" if it cannot be written as x_j ⊕ x_k for 1 ≤ j, k < n with j + k = n. Then for the generator a = 1/2, the hyperbolic integers admit unique factorization into hyperbolic primes.

**Test**: Compute x_n for n = 1, ..., 20 with a = 1/2. For each n ≥ 2, check whether there exist j, k ≥ 1 with j+k = n and x_j ⊕ x_k = x_n. The primes are the n for which no such decomposition exists. Verify that every non-prime x_n has a unique prime factorization (up to ordering).

**Impact**: If unique factorization holds, this establishes a new fundamental theorem of arithmetic on curved spaces, connecting hyperbolic geometry to algebraic number theory. If it fails, understanding the failure (analogous to the failure of unique factorization in Z[√-5]) would reveal how curvature interacts with divisibility. This connects to the existing `tropical_fundamental_theorem_of_arithmetic` in the Catalog.

**Catalog References**: `Tropical/TropicalFactoring.lean` (tropical_fundamental_theorem_of_arithmetic), `Bridges/HyperbolicDiskArithmetic.lean` (hypInt, moebius_add_assoc)

**Proof Strategy**:
1. Show that in the artanh coordinate, x_j ⊕ x_k = x_{j+k} always (by the artanh homomorphism). This would mean the "Möbius factorization" question reduces to ordinary additive factorization of natural numbers.
2. If Step 1 succeeds, then "hyperbolic primes" are exactly the x_p for prime p, and unique factorization follows from the fundamental theorem of arithmetic.
3. The key lemma is artanh(a ⊕ b) = artanh(a) + artanh(b), which would establish an isomorphism between ((-1,1), ⊕) and (ℝ, +).
4. If Step 1 fails (which would be surprising given associativity + commutativity), investigate the obstruction.

**Domain Bridges**: NumberTheory <-> Geometry, Algebra <-> Tropical

**Lineage**: Builds on moebius_add_assoc and the artanh homomorphism (which was the key insight in Direction 2).

**Ambition**: grand_challenge

---

### Direction 4: The Hyperbolic Zeta Function and Spectral Theory

**Conjecture**: The hyperbolic zeta function ζ_H(s) = Σ_{n=1}^∞ |x_n|^{-2s} (where x_n are hyperbolic integers with generator a) converges for Re(s) > 1/(2·artanh(a)) and has a meromorphic continuation to ℂ with a simple pole at s = 1/(2·artanh(a)).

**Test**: For a = 1/2, artanh(1/2) = ln(3)/2, so the critical exponent should be 1/ln(3) ≈ 0.9102. Compute partial sums of ζ_H(s) for s = 0.95, 1.0, 1.5 (should converge) and s = 0.85, 0.80 (should diverge). Verify the transition occurs near s = 0.9102.

**Impact**: This connects hyperbolic integer theory to spectral theory via the Selberg zeta function. The functional equation (if it exists) would relate ζ_H(s) and ζ_H(1/(2·artanh(a)) - s), providing a hyperbolic analog of the Riemann functional equation. The location of zeros would constitute a "hyperbolic Riemann Hypothesis."

**Catalog References**: `Bridges/HyperbolicDiskArithmetic.lean` (hypInt_in_disk), `MachineLearning/HyperbolicNumberTheory.lean` (moebiusMap, moebiusOrbit)

**Proof Strategy**:
1. In artanh coordinates, |x_n| = tanh(n · artanh(a)), so |x_n|^{-2s} ~ (2e^{n·artanh(a)})^{2s} · 4 as n → ∞.
2. The series converges iff Σ e^{2ns·artanh(a)} converges, i.e., iff 2s·artanh(a) > 0 — wait, this diverges for all s > 0 since the summands grow. This means the "inverse norm" zeta diverges.
3. Alternative: define ζ_H(s) = Σ (1 - |x_n|²)^s = Σ sech²(n·artanh(a))^s. This converges for s > 0 and equals a theta series.
4. Prove convergence using comparison with geometric series.

**Domain Bridges**: NumberTheory <-> Analysis, Geometry <-> Physics (spectral theory)

**Lineage**: Extends hypInt and moebius_iter_in_disk from this cycle, connects to moebiusOrbit in the existing Catalog.

**Ambition**: extension

---

### Direction 5: Möbius Arithmetic on Graphs and Cayley Trees

**Conjecture**: Define Möbius addition on the vertices of a (q+1)-regular tree T via the Cayley graph of a free group on q generators. Then the "Möbius integers" (orbit of the identity under iterated left-multiplication by a generator) satisfy: (a) the Möbius distance between consecutive lattice points decays geometrically with rate 1/(2q-1), and (b) the number of distinct Möbius orbits in a ball of radius R grows as (2q-1)^R / R.

**Test**: For q = 2 (the 3-regular tree / free group on 2 generators), compute Möbius distances between consecutive lattice points at word length n = 1, ..., 10. Verify the decay rate is approximately 1/3. Compute orbit counts and compare with 3^R/R.

**Impact**: This extends 1D hyperbolic arithmetic to the natural discrete setting (trees and buildings), connecting to geometric group theory, expander graphs, and the Ihara zeta function. The growth rate 1/(2q-1) is the reciprocal of the spectral radius, linking arithmetic to spectral theory.

**Catalog References**: `Bridges/HyperbolicDiskArithmetic.lean` (lattice_ball_exponential_growth, freeGroupSphere, freeGroupBall), `Computation/GravityOracle.lean` (geodesic_oracle_idempotent)

**Proof Strategy**:
1. Formalize the Cayley graph of a free group as a (2q)-regular tree.
2. Define the Green's function G(x, y; s) = Σ_γ e^{-s·d(x, γ·y)} and show it converges for Re(s) > log(2q-1).
3. Connect the growth rate to the Perron-Frobenius eigenvalue of the adjacency operator.
4. Use the Ihara determinant formula to relate the graph zeta function to the adjacency spectrum.

**Domain Bridges**: Algebra <-> Computation, Geometry <-> NumberTheory

**Lineage**: Extends the free group sphere/ball counting from this cycle to a richer geometric setting.

**Ambition**: extension
