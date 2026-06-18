# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundational infrastructure for arithmetic on the Poincaré disk: verified group structure for SL₂(ℝ), hyperbolic distance properties, and bridges to classical number theory via Euler's totient and Farey sequences. The most promising cross-domain connection discovered is the **Chebyshev-trace identity** (tr(g²) = tr(g)² − 2), which links hyperbolic dynamics to polynomial algebra and approximation theory. This identity, combined with the power addition law g^(m+n) = g^m · g^n, suggests that trace sequences form a rich algebraic structure that could yield new results in both directions.

The totient sum growth bound (Σφ(k) ≥ n) and the congruence subgroup index divisibility (6 | p(p²−1)) provide concrete numerical handles connecting the geometry of lattice tessellations to classical divisibility. The Farey-SL₂(ℤ) correspondence discovered here—adjacent Farey fractions give SL₂(ℤ) matrices—opens a pathway from rational approximation theory into hyperbolic geometry that has not been fully exploited computationally.

The highest breakthrough potential lies in Direction 1 (Chebyshev trace recurrence proof), which if completed would unlock a systematic theory of trace polynomials with applications to spectral theory and quantum chaos. Direction 2 (unique factorization) addresses the most fundamental question about hyperbolic arithmetic and could either yield a new algebraic structure or reveal why flatness is essential for unique factorization.

---

### Direction 1: Chebyshev Trace Recurrence — Full Proof

**Conjecture**: For any g ∈ SL₂(ℝ) and all n ∈ ℕ,
tr(g^{n+2}) = tr(g) · tr(g^{n+1}) − tr(g^n).

**Test**: Prove this by induction on n in Lean 4 using the definitions from `Speculative/HyperbolicNumberTheory/Theorems.lean`. The base case n=0 reduces to tr(g²) = tr(g)·tr(g) − tr(I) = tr(g)² − 2, which is already proved as `hypsl2_trace_sq`. The inductive step requires expanding SL2.mul and computing traces.

**Impact**: If true, this gives a complete characterization of trace sequences as Chebyshev polynomials, connecting: (1) hyperbolic geometry (geodesic lengths), (2) spectral theory (eigenvalues of Laplacians on modular surfaces), and (3) number theory (algebraic integers). It would also yield efficient O(log n) computation of tr(gⁿ) via matrix exponentiation.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Theorems.lean` (hypsl2_trace_sq, hypsl2_pow_add), `Algebra/Berggren.lean` (matrix power identities)

**Proof Strategy**: Unfold SL2.pow for n+2 to get mul g (mul g (pow g n)). Express the trace as a sum of products of entries. Use the determinant condition ad − bc = 1 and the inductive hypothesis. The key step is showing that the cross-terms cancel due to the determinant identity.

**Domain Bridges**: Algebra <-> Geometry, NumberTheory <-> SpectralTheory

**Lineage**: Builds on hypsl2_trace_sq and sl2r_trace_discriminant from this cycle.

**Ambition**: extension

---

### Direction 2: Unique Factorization in Hyperbolic Lattices

**Conjecture**: The hyperbolic integers ℤ_H (orbit of origin under PSL(2,ℤ)) equipped with coordinate-wise addition do NOT have unique factorization into hyperbolic primes. Specifically, there exist orbit points with two distinct decompositions into indecomposable elements.

**Test**: Enumerate all orbit points up to Euclidean radius 0.8, identify hyperbolic primes (indecomposable points), and search for points with multiple decompositions. If found, construct a concrete counterexample in Lean.

**Impact**: A negative answer reveals that unique factorization is an artifact of one-dimensional flat geometry, fundamentally changing our understanding of what makes ℤ special. A positive answer would establish a new algebraic structure with deep implications for automorphic forms.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (HyperbolicPrime, HyperbolicLattice), `Cryptography/BerggrenDiophantineLattice.lean` (lattice structures)

**Proof Strategy**: Define a computable decomposition function on orbit points. For the negative direction, find a point p with two distinct pairs (q₁, r₁) and (q₂, r₂) where q_i + r_i = p and all are non-identity lattice points. Use the PSL(2,ℤ) orbit computation to search exhaustively.

**Domain Bridges**: NumberTheory <-> Geometry, Algebra <-> Cryptography

**Lineage**: Builds on HyperbolicPrime definition from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Hyperbolic Zeta Function and Spectral Theory

**Conjecture**: The partial hyperbolic zeta function ζ_H(s) = Σ_{p ∈ orbit, |p|>0} 1/|p|^{2s} converges absolutely for Re(s) > 1 and has meromorphic continuation to ℂ with a simple pole at s = 1 with residue related to the volume of the fundamental domain.

**Test**: Compute ζ_H(s) numerically for the PSL(2,ℤ) orbit at depth 10 for s = 1.5, 2.0, 2.5, ..., 5.0. Verify convergence by comparing values at successive depths. Check that ζ_H(s) ≈ C/(s−1) near s = 1.

**Impact**: This would provide a Poincaré-disk analog of the Riemann zeta function, potentially with a functional equation and spectral interpretation via the Selberg trace formula. The zeros would encode geometric information about the lattice.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Defs.lean` (hypZetaPartial, hypZetaPartial_nonneg), `Speculative/HolographicPrimes/` (zeta function constructions)

**Proof Strategy**: First establish absolute convergence using the counting function bound N(r) ~ C/(1−r²). Then use Mellin transform techniques to relate ζ_H to the Selberg zeta function. For the functional equation, exploit the self-adjointness of the hyperbolic Laplacian.

**Domain Bridges**: NumberTheory <-> SpectralTheory, Analysis <-> Geometry

**Lineage**: Builds on hypZetaPartial_nonneg and denom_pos from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Farey Sequence Enumeration via SL₂(ℤ)

**Conjecture**: The precise formula |F_n| = 1 + Σ_{k=1}^n φ(k) can be proved in Lean by establishing a bijection between Farey fractions of order n and certain elements of PSL(2,ℤ) with bounded entries.

**Test**: Define FareySequence(n) as a Finset of pairs (p,q) with 0 ≤ p ≤ q ≤ n and gcd(p,q) = 1. Prove card(FareySequence n) = 1 + totientSum n.

**Impact**: This would complete the bridge between rational approximation and hyperbolic geometry, giving a purely algebraic proof of the Farey enumeration theorem.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Theorems.lean` (totientSumH_ge, FareyFraction), `Algebra/Foundations.lean` (number theory foundations)

**Proof Strategy**: Define the Farey set as a Finset using Finset.filter on Finset.range. Partition by denominator q: fractions with denominator q biject with {p : 0 ≤ p ≤ q, gcd(p,q) = 1}, which has cardinality φ(q). Sum over q = 1 to n.

**Domain Bridges**: NumberTheory <-> Combinatorics, Algebra <-> Geometry

**Lineage**: Builds on totientSumH_ge and FareyFraction from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Geometry of Hyperbolic Lattices

**Conjecture**: The tropicalization of the orbit counting function N(r) — defined by replacing (×, +) with (+, min) — satisfies a min-plus recurrence analogous to the Chebyshev trace recurrence in tropical algebra.

**Test**: Compute the tropical analog of the trace sequence: define T_n^{trop} by T₀ = 0, T₁ = t, T_{n+2} = t + T_{n+1} ∧ T_n (where ∧ = min). Verify that this sequence describes geodesic distances in a tropical graph approximation of the hyperbolic lattice.

**Impact**: This would create a new bridge between tropical geometry and hyperbolic number theory, potentially yielding combinatorial tools for studying lattice point distributions. The connection could also illuminate the relationship between tropical curves and modular curves.

**Catalog References**: `Tropical/` (tropical algebra foundations), `Speculative/HyperbolicNumberTheory/Theorems.lean` (trace sequences), `Algebra <-> Tropical` structural opportunity noted in Catalog analysis

**Proof Strategy**: Define tropical SL₂ matrices over the tropical semiring (ℝ ∪ {∞}, min, +). Verify that the tropical determinant condition holds. Compute tropical traces and verify the recurrence.

**Domain Bridges**: Tropical <-> Geometry, Algebra <-> NumberTheory

**Lineage**: Builds on trace theory from this cycle; addresses the Algebra <-> Tropical structural gap identified in Catalog analysis.

**Ambition**: extension
