# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the mathematical foundations of arithmetic on the Poincaré disk: we proved that Möbius automorphisms preserve the disk, that hyperbolic distance is symmetric and non-negative, and that lattice orbits grow at most exponentially. We introduced novel concepts of hyperbolic divisibility and hyperbolic valuation that create genuine arithmetic structure on geometric lattice points.

The most promising cross-domain connection emerged between the critical line of the Riemann zeta function and the geometry of the Poincaré disk. The theorem `critical_line_implies_unit_disk` — which shows that zeros on Re(s) = 1/2 map into the closed unit disk — bridges analytic number theory and hyperbolic geometry. Combined with our lattice framework, this suggests that the distribution of classical primes may have a geometric explanation rooted in hyperbolic curvature. The exponential growth bounds we proved for lattice orbits (Theorem `orbit_card_upper_bound`) connect to the Patterson-Sullivan theory of critical exponents for Fuchsian groups, and matching lower bounds would establish a precise growth rate that could be compared against the classical prime number theorem.

The highest breakthrough potential lies in Direction 1 (Spectral Gaps and Prime Gaps), because it connects the well-developed spectral theory of hyperbolic surfaces to concrete prime-counting questions via the Selberg trace formula. If the hyperbolic zeta function's analytic continuation can be controlled by spectral data, this would give a new proof technique for prime counting that is fundamentally geometric rather than analytic.

---

### Direction 1: Spectral Gaps and Hyperbolic Prime Gaps

**Conjecture**: For the modular group Γ = PSL(2,ℤ) acting on the Poincaré disk, the difference between consecutive hyperbolic primes (ordered by hyperbolic norm) is bounded above by C · √(‖z‖_H) for some absolute constant C > 0. Moreover, the gap distribution is governed by the spectral gap λ₁ of the Laplacian on the modular surface Γ\𝔻.

**Test**: Compute the orbit of PSL(2,ℤ) to depth 20 (approximately 3^20 ≈ 3.5 billion candidate points, but with deduplication this reduces dramatically). Sort the first-generation points by hyperbolic norm. Compute consecutive differences and test whether max_gap(R) / √R remains bounded as R → ∞ for hyperbolic radius R. Compare the empirical gap distribution against the Random Matrix Theory prediction (GUE statistics) used for Riemann zeros.

**Impact**: If true, this provides a geometric explanation for prime gaps that avoids the analytic machinery of zero-free regions. The spectral gap λ₁ = 1/4 for the modular surface is known (Selberg's eigenvalue conjecture, proved in this case), giving an explicit constant. If false, the failure would indicate that hyperbolic primes have fundamentally different gap statistics from classical primes, revealing where the analogy breaks down.

**Catalog References**: `Catalog/Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Catalog/Algebra/HyperbolicNumberTheory.lean` (orbit_card_upper_bound, hyp_norm_nonneg)

**Proof Strategy**: (1) Prove that the Selberg trace formula relates orbit-counting to spectral data. This requires formalizing the trace formula for the modular surface. (2) Use the known spectral gap λ₁ = 1/4 to bound the error term in the lattice point counting problem. (3) Convert the counting bound into a gap bound using standard sieve methods. Key lemmas needed: a formalized version of the Selberg trace formula, Weyl's law for eigenvalue asymptotics on hyperbolic surfaces, and an effective bound for the remainder term in lattice point counting.

**Domain Bridges**: NumberTheory <-> HyperbolicGeometry <-> SpectralTheory

**Lineage**: Builds on `orbit_card_upper_bound` and `hyp_norm_nonneg` from this cycle, and `critical_line_implies_unit_disk` from the Catalog.

**Ambition**: grand_challenge

---

### Direction 2: Unique Factorization in Hyperbolic Lattices

**Conjecture**: For the standard presentation PSL(2,ℤ) ≅ ⟨S, T | S² = (ST)³ = 1⟩ acting on the Poincaré disk via S(z) = -1/z and T(z) = z+1 (conjugated to disk automorphisms), every lattice point has a unique representation as a reduced word in the Cayley graph. The number of lattice points with word length exactly n (hyperbolic valuation = n) equals 2·3^{n-1} for n ≥ 1.

**Test**: Implement the Cayley graph of PSL(2,ℤ) with generators S, T. Enumerate all reduced words of length ≤ 10 and evaluate them as Möbius transformations applied to the origin in the disk model. Check: (a) distinct words give distinct disk points (up to numerical precision 10^{-12}), (b) the count at depth n matches 2·3^{n-1}. This is feasible on a laptop in minutes.

**Impact**: If true, this gives ℤ_H a genuine unique factorization theorem — the holy grail of arithmetic structure. The explicit growth formula 2·3^{n-1} would pin down the "prime counting function" exactly. If false (e.g., distinct words collide in the disk), it reveals that the geometric embedding loses algebraic structure, which would be equally informative.

**Catalog References**: `Catalog/Algebra/HyperbolicNumberTheory.lean` (HypDivides, hypValuation, IsHypPrime), `Catalog/Algebra/ChimeraFactoring.lean` (semiprime_unique_factorization)

**Proof Strategy**: (1) Prove that PSL(2,ℤ) is a free product ℤ/2 * ℤ/3 (this is classical). (2) Show that the normal form theorem for free products gives unique reduced words. (3) Prove that the action on 𝔻 is faithful (the kernel is trivial), so distinct group elements give distinct lattice points. (4) Count words using the transfer matrix method: at each step, from a vertex of type S, you can go to 2 vertices; from type T, to 2 vertices; giving geometric growth. Key prerequisite: formalize free products and normal forms in Lean 4.

**Domain Bridges**: Algebra <-> HyperbolicGeometry <-> Combinatorics

**Lineage**: Builds on `hyp_divides_refl`, `hyp_prime_ne_zero`, and `hypValuation` from this cycle.

**Ambition**: extension

---

### Direction 3: Hyperbolic Zeta Function and Functional Equation

**Conjecture**: The hyperbolic zeta function ζ_H(s) = Σ_{z ∈ ℤ_H, z ≠ 0} 1/‖z‖_H^{2s} for the modular group converges for Re(s) > 1 and admits a meromorphic continuation to ℂ with a functional equation relating ζ_H(s) and ζ_H(1−s). The critical exponent (abscissa of convergence) equals δ = 1, the Hausdorff dimension of the limit set of PSL(2,ℤ).

**Test**: Numerically compute ζ_H(s) for s = 1.5, 2, 3 using orbit truncation to depth N = 15. Plot |ζ_H(s)| for s ∈ [0.5, 3] along the real axis. Check whether ζ_H(s) diverges as s → 1+ (if critical exponent is 1) or converges (if critical exponent < 1). Compare with the Selberg zeta function Z(s) for the modular surface and check if ζ_H(s) = Z'(s)/Z(s) or a similar relation holds.

**Impact**: If a functional equation exists, it would be the first instance of a "Riemann Hypothesis for curved space" that is potentially provable using geometric methods (Selberg trace formula). The analytic continuation would connect hyperbolic lattice counting to the spectral theory of automorphic forms. If no functional equation exists, this would distinguish hyperbolic zeta functions from classical ones in a fundamental way.

**Catalog References**: `Catalog/Algebra/HyperbolicNumberTheory.lean` (hypZetaPartial, hypNorm), `Catalog/Algebra/Foundations.lean` (critical_line_implies_unit_disk, li_positivity_from_critical_line)

**Proof Strategy**: (1) Prove convergence for Re(s) > δ using the orbit growth bound (k+1)^n and comparison with geometric series. (2) Relate ζ_H to the Eisenstein series E(z,s) evaluated at the origin. (3) Use the Fourier expansion of Eisenstein series and their known functional equation E(z,s) = E(z,1-s) times a gamma factor. (4) Extract the functional equation for ζ_H. Key tools: Fourier analysis on the modular surface, theory of Eisenstein series, Langlands-Shahidi method.

**Domain Bridges**: NumberTheory <-> ComplexAnalysis <-> SpectralTheory <-> HyperbolicGeometry

**Lineage**: Builds on `hypZetaPartial`, `hyp_norm_formula`, and the critical line bridge from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Higher-Dimensional Hyperbolic Lattices

**Conjecture**: The framework extends to hyperbolic 3-space ℍ³ via the Bianchi groups PSL(2, 𝒪_K) where 𝒪_K is the ring of integers of an imaginary quadratic field K = ℚ(√(-d)). The orbit growth in ℍ³ is cubic (R³ rather than R² in ℍ²), and the critical exponent equals 2 (the dimension of the boundary sphere). The hyperbolic zeta function in 3D converges for Re(s) > 1 and has nontrivial zeros that correspond to Maass forms on the Bianchi manifold.

**Test**: For d = 1 (Gaussian integers), compute the orbit of PSL(2, ℤ[i]) acting on the unit ball model of ℍ³ to depth 8. Count orbit points vs. hyperbolic radius and fit to R^α to estimate the growth exponent α. Predicted: α ≈ 3.

**Impact**: Extends hyperbolic number theory from 2D to 3D, connecting to the arithmetic of imaginary quadratic fields. The Bianchi groups are arithmetic groups with deep connections to elliptic curves (via modularity). If the 3D framework works, it provides a geometric perspective on the Langlands program for GL(2) over imaginary quadratic fields.

**Catalog References**: `Catalog/Algebra/HyperbolicNumberTheory.lean` (full framework), `Catalog/Cryptography/BerggrenDiophantineLattice.lean` (lorentzForm, euclidNormSq)

**Proof Strategy**: (1) Define the ball model of ℍ³ as {x ∈ ℝ³ : |x| < 1}. (2) Define Möbius transformations in 3D using quaternionic representation. (3) Prove disk (ball) preservation analogously to the 2D case. (4) Prove orbit growth bounds using the known volume growth of hyperbolic balls: Vol(B_R) ~ e^{2R} in ℍ³. (5) Connect to spectral theory via the 3D Selberg trace formula.

**Domain Bridges**: NumberTheory <-> HyperbolicGeometry <-> AlgebraicNumberTheory

**Lineage**: Direct extension of the 2D framework from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Hyperbolic Arithmetic

**Conjecture**: The tropicalization of hyperbolic distance — replacing (a + b, a · b) with (min(a,b), a + b) — yields a "tropical Poincaré disk" where the hyperbolic metric becomes a piecewise-linear function. Tropical Möbius transformations are piecewise-linear maps that preserve this tropical disk. The tropical hyperbolic lattice has a unique factorization theorem that is provable by combinatorial methods (unlike the complex case, which requires analysis).

**Test**: Define the tropical cross-ratio as min(|z-w|_T, |1-w*z|_T) where operations are tropical. Compute the tropical orbit of the tropical modular group to depth 10. Check: (a) the orbit is a polyhedral complex, (b) every point has a unique reduced word representation, (c) orbit growth matches the expected tropical analogue of (k+1)^n.

**Impact**: Tropical geometry often "linearizes" hard problems from algebraic geometry. If hyperbolic unique factorization is provable in the tropical setting, the tropical proof might lift to the complex setting via Viro's patchworking or Mikhalkin's correspondence. This would give a fundamentally new approach to proving arithmetic properties of lattices.

**Catalog References**: `Catalog/Tropical/` (tropical foundations), `Catalog/Algebra/HyperbolicNumberTheory.lean` (HypDivides, IsHypPrime), `Catalog/Computation/PadicValuationDepth.lean` (ValuationDepthMeasure)

**Proof Strategy**: (1) Define the tropical semifield (ℝ ∪ {∞}, min, +). (2) Define the tropical Poincaré disk as {x ∈ ℝ : x > 0} (the positive reals under tropical arithmetic). (3) Define tropical Möbius transformations as piecewise-linear maps. (4) Prove the tropical unique factorization theorem using the combinatorics of the tropical Cayley graph (which is a tree). (5) Attempt to lift via deformation/specialization.

**Domain Bridges**: TropicalGeometry <-> HyperbolicGeometry <-> Combinatorics <-> NumberTheory

**Lineage**: Bridges the Tropical catalog with the new Hyperbolic Number Theory framework.

**Ambition**: extension
