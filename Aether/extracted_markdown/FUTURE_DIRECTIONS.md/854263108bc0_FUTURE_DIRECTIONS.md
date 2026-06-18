# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundations of hyperbolic number theory by formalizing the Poincaré disk model, the Lorentzian norm and its Brahmagupta multiplicativity, hyperbolic primes, and a novel algebraic structure—the hyperbolic arithmetic monoid. The most striking discovery is the **consecutive prime theorem**: every positive hyperbolic prime (a, b) with both entries positive satisfies a = b + 1, creating a perfect bijection with odd rational primes via (n+1, n) ↔ 2n+1. This bridges hyperbolic geometry and classical number theory at the level of individual primes.

The most promising cross-domain connection is between the **Lorentzian norm's multiplicativity** (the Brahmagupta identity) and the **Selberg zeta function** for hyperbolic surfaces. The Brahmagupta identity shows that Lorentzian norms form a multiplicative monoid, while the Selberg zeta function encodes the lengths of closed geodesics on a hyperbolic surface—which are precisely the norms of hyperbolic group elements. Connecting these two perspectives could yield a new proof technique for spectral results on hyperbolic surfaces. The direction with highest breakthrough potential is Direction 1 (Selberg–Brahmagupta bridge), because it could give algebraic access to analytic objects.

The cycle also produced exponential growth bounds for hyperbolic groups, conformal factor analysis of the Poincaré metric, and modular group structure theorems. These connect to the Catalog's existing work on modular forms (`EML/ModularForms.lean`), algebraic spacetime (`Algebra/AlgebraicSpacetime.lean`), and Lorentzian geometry (`Cryptography/BerggrenDiophantineLattice.lean`).

---

### Direction 1: The Selberg–Brahmagupta Bridge

**Conjecture**: The Selberg zeta function Z_Γ(s) for a cofinite Fuchsian group Γ can be expressed as an Euler product over hyperbolic primes in the Lorentzian lattice. Specifically, if {(a_n, b_n)} are the primitive hyperbolic elements of Γ ordered by Lorentzian norm, then Z_Γ(s) = ∏_n ∏_{k=0}^∞ (1 − e^{−(s+k)ℓ_n}) where ℓ_n = 2 arccosh(a_n) is the geodesic length corresponding to the Lorentzian norm a_n² − b_n².

**Test**: For Γ = PSL(2, ℤ), compute the first 50 terms of both the Selberg Euler product and the Brahmagupta-indexed product, and verify they agree to 10 decimal places. The primitive hyperbolic elements of PSL(2, ℤ) are classified, so this is computationally feasible.

**Impact**: If true, this would give an algebraic (Brahmagupta) encoding of the analytic (Selberg) zeta function, potentially enabling new techniques for the spectral theory of hyperbolic surfaces. It would also connect the Catalog's modular forms work to number-theoretic prime counting.

**Catalog References**: `EML/ModularForms.lean` (modular group generators), `Algebra/AlgebraicSpacetime.lean` (Lorentzian geometry), `Computation/HyperbolicNumberTheory.lean` (Brahmagupta identity, modular group)

**Proof Strategy**: (1) Classify primitive hyperbolic elements of PSL(2, ℤ) using the trace formula: an element [[a,b],[c,d]] is hyperbolic iff |a+d| > 2, and primitive iff it's not a proper power. (2) Show that the trace a+d determines the Lorentzian norm via (a+d)² = 4 + (a²−b²) for det=1 matrices. (3) Rewrite the Selberg Euler product in terms of Lorentzian norms using this correspondence. (4) Verify the resulting product matches the Brahmagupta-indexed version.

**Domain Bridges**: NumberTheory <-> Geometry, Algebra <-> SpectralTheory

**Lineage**: Builds on `consecutive_hyp_prime_iff`, `lorentz_brahmagupta`, and `modularST_cubed` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Unique Factorization in the Hyperbolic Arithmetic Monoid

**Conjecture**: The hyperbolic arithmetic monoid H (pairs (a, b) with a > |b|, Brahmagupta multiplication) does NOT have unique factorization into irreducible elements. Specifically, the element (a, b) = (5, 4) with Lorentzian norm 9 = 3² has two distinct factorizations: (5, 4) = (2, 1) · (2, 1)' for some (2, 1)' where the Brahmagupta product gives norm 9, but there exists another factorization path.

**Test**: Enumerate all elements of H with Lorentzian norm ≤ 100. For each composite norm n, find all factorization trees. If any norm has more than one essentially different factorization tree (up to ordering), unique factorization fails. If all norms up to 100 have unique factorization, the conjecture is likely false (and UF may hold).

**Impact**: If UF fails, the hyperbolic arithmetic monoid requires a class group analog—potentially connecting to the class number of real quadratic fields (since x² − y² relates to the norm form of ℤ[√1] = ℤ × ℤ). If UF holds, it would be a rare example of a non-trivial monoid with UF.

**Catalog References**: `Computation/HyperbolicNumberTheory.lean` (HypArithElt, mul_norm), `Algebra/Basic.lean`

**Proof Strategy**: (1) Define a "class monoid" for H as the set of equivalence classes of ideals. (2) Show that the factorization of norms in H reduces to the factorization of a² − b² = (a+b)(a−b) in ℤ. (3) Use the fact that ℤ is a UFD to analyze when the Brahmagupta product provides unique factorizations vs. when the two-factor structure of (a+b)(a−b) creates ambiguity.

**Domain Bridges**: Algebra <-> NumberTheory

**Lineage**: Builds on `HypArithElt.mul_norm`, `lorentz_factor`, `hyp_prime_consecutive` from this cycle.

**Ambition**: extension

---

### Direction 3: Hyperbolic Prime Number Theorem with Effective Error Bounds

**Conjecture**: The number of consecutive hyperbolic primes (n+1, n) with 2n+1 ≤ X satisfies π_H(X) = li(X)/2 + O(X^{1/2} log X), where li is the logarithmic integral. In particular, the error term has the same order as in the classical PNT.

**Test**: Compute π_H(X) for X = 10^k, k = 1, ..., 8, and compare with li(X)/2. The ratio should converge to 1, and the difference should grow slower than X^{0.6}.

**Impact**: This would be a rigorous version of the hyperbolic prime density conjecture. Since consecutive hyperbolic primes biject to odd primes, this reduces to PNT for odd numbers, which is classical. But formalizing it in Lean with effective error bounds would be significant—no effective PNT exists in Mathlib currently.

**Catalog References**: `Computation/HyperbolicNumberTheory.lean` (consHypPrimeCount, consecutive_hyp_prime_iff), `Algebra/Foundations.lean` (critical_line_implies_unit_disk)

**Proof Strategy**: (1) Formalize the Chebyshev bounds for primes in arithmetic progressions: π(X; 2, 1) ≥ cX/log(X) for an explicit constant c. (2) Use the bijection from `consecutive_hyp_prime_iff` to transfer bounds to hyperbolic primes. (3) For the upper bound, use Brun's sieve or the Selberg sieve formalized for the progression 2n+1.

**Domain Bridges**: NumberTheory <-> Computation

**Lineage**: Builds on `consecutive_hyp_prime_iff` and `hyperbolic_prime_density_conjecture` from this cycle.

**Ambition**: extension

---

### Direction 4: Hyperbolic Integers in Higher Dimensions via Clifford Algebras

**Conjecture**: The Brahmagupta identity generalizes to dimension d via Clifford algebra norms: for the Clifford algebra Cl(d-1, 1) over ℤ, the reduced norm N(xy) = N(x)N(y) provides a multiplicative Lorentzian norm in d dimensions, and the "hyperbolic primes" in d = 3 correspond to prime norms in the Hurwitz quaternion order.

**Test**: For d = 3, enumerate Clifford algebra elements with integer entries and Lorentzian norm ≤ 50. Check that the prime norms correspond to rational primes (or squares of primes, as in the quaternionic case). Verify multiplicativity computationally for 1000 random pairs.

**Impact**: This would extend hyperbolic number theory to hyperbolic 3-manifolds, connecting to the Thurston geometrization program and 3-manifold topology. The arithmetic of hyperbolic 3-manifolds is vastly richer than the 2D case.

**Catalog References**: `Cryptography/BerggrenDiophantineLattice.lean` (Lorentzian forms), `Algebra/BerggrenLorentz/Core.lean` (Lorentz group), `Computation/HyperbolicNumberTheory.lean` (Brahmagupta identity)

**Proof Strategy**: (1) Define the Clifford algebra Cl(2, 1) with generators e₁, e₂, e₃ satisfying e₁² = e₂² = 1, e₃² = −1. (2) Define the reduced norm as N(a + be₁ + ce₂ + de₃ + ...) = (generalized Lorentzian form). (3) Prove the norm is multiplicative using Clifford algebra identities. (4) Classify prime elements and test for unique factorization.

**Domain Bridges**: Algebra <-> Geometry <-> Topology

**Lineage**: Builds on `lorentz_brahmagupta`, `HypArithElt` from this cycle; extends to `BerggrenLorentz/Core.lean` from the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Computational Verification of Hyperbolic Zeta Zeros

**Conjecture**: The hyperbolic zeta function ζ_H(s) = Σ_{n≥1} 1/(2n+1)^{2s} (summing over consecutive hyperbolic prime norms) has all non-trivial zeros on the critical line Re(s) = 1/2.

**Test**: Numerically compute ζ_H(s) for s along vertical lines Re(s) = σ for σ ∈ {0.3, 0.4, 0.5, 0.6, 0.7} and Im(s) ∈ [0, 100]. Locate zeros by sign changes of Re(ζ_H) and Im(ζ_H). Check that all zeros found satisfy |Re(s) − 1/2| < 10^{−10}.

**Impact**: Since ζ_H(s) is essentially the Dirichlet series for odd numbers, its zeros are closely related to those of the Riemann zeta function and the Dirichlet L-function L(s, χ₀). Verifying GRH for this specific series would support the broader Riemann Hypothesis.

**Catalog References**: `Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Computation/HyperbolicNumberTheory.lean` (hypZetaPartial)

**Proof Strategy**: (1) Express ζ_H(s) in terms of ζ(2s) and L(2s, χ₂) where χ₂ is the non-principal character mod 2. (2) Use the known zero-free regions for ζ and L-functions to establish zero-free regions for ζ_H. (3) For zeros on the critical line, use the functional equation of the constituent L-functions.

**Domain Bridges**: NumberTheory <-> Computation <-> Analysis

**Lineage**: Builds on `hyp_zeta_partial_nonneg`, `hyp_zeta_partial_mono` from this cycle; connects to `critical_line_implies_unit_disk` from the Catalog.

**Ambition**: extension
