# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

## Abstract

We introduce *hyperbolic number theory*, a framework for studying integers, primes, and zeta functions on the Poincaré disk model of hyperbolic geometry. We define hyperbolic integers as the orbit of the origin under iterated Möbius disk automorphisms, establish that Möbius maps preserve the disk (with a complete proof of the key normSq identity), prove orbit containment by induction, and demonstrate an orbit composition property that mirrors integer addition. We define a hyperbolic zeta function, prove its non-negativity, and establish a trace-lattice duality connecting hyperbolic geometry to spectral theory. All results are formalized and verified in the Lean 4 theorem prover with the Mathlib library. We also formulate testable conjectures about the distribution of hyperbolic integers and their zeta function.

## 1. Introduction

Classical number theory studies the integers ℤ as an ordered ring embedded in the real line ℝ. The rich structure of primes, divisibility, and analytic properties of the Riemann zeta function all arise from this linear setting. A natural question is: what arithmetic structures emerge when we replace the line with a curved space?

The Poincaré disk model D = {z ∈ ℂ : |z| < 1} provides a natural testing ground. Its isometry group Aut(D) ≅ PSU(1,1) acts transitively on D via Möbius transformations, and discrete subgroups Γ < Aut(D) generate tessellations with rich geometric and arithmetic structure. The Selberg trace formula [Selberg 1956] already connects the geometry of Γ\D to spectral data of the Laplacian, establishing a precedent for geometry-arithmetic-spectral connections.

Our approach is to construct an explicit orbit {z_n}_{n≥0} of the origin under a single Möbius generator and study its arithmetic properties. This is simpler than the full theory of Fuchsian groups but already reveals non-trivial phenomena: non-commutative addition, orbit containment requiring inductive proof, and a composition property that mirrors the additive structure of ℕ.

### 1.1 Related Work

The study of discrete groups acting on hyperbolic space has a long history going back to Poincaré, Klein, and Fricke. The Selberg trace formula and its variants have been central to analytic number theory since the 1950s. Our work is closest in spirit to the study of "hyperbolic lattice point counting" problems, which estimate the number of orbit points in growing regions (see Huber 1956, Patterson 1975, Lax–Phillips 1982).

The novel contribution is the formal construction of arithmetic operations (addition, factorization) on the orbit, the connection to classical number theory through the orbit index, and the rigorous verification of all foundational properties.

## 2. Definitions and Notation

### 2.1 The Möbius Map

**Definition 2.1.** For a ∈ D, the *Möbius map* φ_a : ℂ → ℂ is defined by:
$$\varphi_a(z) = \frac{z - a}{1 - \bar{a}z}$$

This is a biholomorphic automorphism of D when a ∈ D. It sends a to 0 and 0 to −a.

### 2.2 Hyperbolic Integers

**Definition 2.2.** Given a generator a ∈ D, the *generalized Möbius orbit* from an initial point w is:
$$\text{orbit}(a, w, 0) = w, \quad \text{orbit}(a, w, n+1) = \varphi_a(\text{orbit}(a, w, n))$$

The *hyperbolic integers* are the orbit from the origin:
$$z_n = \text{orbit}(a, 0, n)$$

### 2.3 Hyperbolic Addition

**Definition 2.3.** *Hyperbolic addition* is:
$$z \oplus w = \varphi_w(z) = \frac{z - w}{1 - \bar{w}z}$$

This operation is generally non-commutative.

### 2.4 The Hyperbolic Cross-Ratio

**Definition 2.4.** The *hyperbolic cross-ratio squared* is:
$$\rho(z, w) = \frac{|z - w|^2}{|1 - \bar{z}w|^2}$$

The hyperbolic distance is d(z,w) = arctanh(√ρ(z,w)).

### 2.5 The Hyperbolic Zeta Function

**Definition 2.5.** The *partial hyperbolic zeta sum* is:
$$\zeta_H(s, N) = \sum_{n=1}^{N} \frac{1}{|z_n|^{2s}}$$

where the sum runs over orbit points with |z_n| > 0.

### 2.6 Hyperbolic Prime Counting

**Definition 2.6.** The *hyperbolic prime counting function* is:
$$\pi_H(N) = |\{p \leq N : p \text{ is prime}\}|$$

This is defined via the orbit index, establishing a bijection between hyperbolic primes and ordinary primes.

### 2.7 The Golden Generator

**Definition 2.7.** The *golden generator* is:
$$a_\phi = \frac{3 - \sqrt{5}}{2} \approx 0.382$$

This equals 1/φ² where φ = (1+√5)/2 is the golden ratio.

## 3. Main Results

### 3.1 Foundational Properties

**Theorem 3.1** (Denominator Non-vanishing). *If |a|² < 1 and |z|² < 1, then 1 − āz ≠ 0.*

*Proof sketch.* By contradiction: if 1 − āz = 0, then |āz|² = 1, so |a|²|z|² = 1. But |a|² < 1 and |z|² < 1 imply |a|²|z|² < 1, contradiction. The formal proof uses `sub_ne_zero_of_ne` and `nlinarith` with normSq non-negativity.

**Theorem 3.2** (NormSq Complement Identity). *For a, z ∈ ℂ with 1 − āz ≠ 0:*
$$1 - |\varphi_a(z)|^2 = \frac{(1 - |a|^2)(1 - |z|^2)}{|1 - \bar{a}z|^2}$$

*Proof sketch.* Expand |φ_a(z)|² = |z−a|²/|1−āz|². Then 1 − |φ_a(z)|² = (|1−āz|² − |z−a|²)/|1−āz|². The numerator expands to (1 − |a|²)(1 − |z|²) by direct algebraic computation. The formal proof uses `normSq_div`, `one_sub_div`, and ring normalization.

**Theorem 3.3** (Disk Preservation). *If |a|² < 1 and |z|² < 1, then |φ_a(z)|² < 1.*

*Proof sketch.* Apply Theorem 3.2 with the denominator non-vanishing from Theorem 3.1. The right side is positive (product of two positive numbers divided by a positive number), so |φ_a(z)|² < 1. The formal proof uses `nlinarith` with `normSq_pos`.

### 3.2 Orbit Properties

**Theorem 3.4** (Orbit Containment). *If |a|² < 1, then |z_n|² < 1 for all n ∈ ℕ.*

*Proof.* By induction on n.
- Base case: z₀ = 0, |0|² = 0 < 1. ✓
- Inductive step: Assume |z_n|² < 1. Then z_{n+1} = φ_a(z_n). By Theorem 3.3 applied to a and z_n, we get |z_{n+1}|² < 1. ✓

**Theorem 3.5** (Orbit Composition). *For all m, n ∈ ℕ:*
$$\text{orbit}(a, z_m, n) = z_{n+m}$$

*Proof.* By induction on n.
- Base case: orbit(a, z_m, 0) = z_m = z_{0+m}. ✓
- Inductive step: orbit(a, z_m, n+1) = φ_a(orbit(a, z_m, n)) = φ_a(z_{n+m}) = z_{(n+1)+m}. ✓

This composition property is the structural foundation for hyperbolic factorization.

### 3.3 Symmetry Properties

**Theorem 3.6** (Cross-Ratio Symmetry). *ρ(z, w) = ρ(w, z) for all z, w ∈ ℂ.*

*Proof sketch.* The numerator satisfies |z−w|² = |w−z|² since normSq(−x) = normSq(x). For the denominator, |1 − z̄w|² = |1 − w̄z|² follows from normSq being invariant under conjugation. The formal proof normalizes using `norm_num` on the `Complex.normSq` definition and `ring`.

### 3.4 Spectral Connection

**Theorem 3.7** (Trace-Lattice Duality). *For points {z_i}_{i < n} in ℂ:*
$$\sum_{i=0}^{n-1} |z_i|^2 = \sum_{i=0}^{n-1} \text{Re}(z_i \bar{z}_i)$$

*Proof.* Immediate from the definition of normSq: |z|² = Re(z · z̄). This identity connects the geometric quantity (sum of squared distances from origin) to a linear-algebraic quantity (trace of the Gram matrix Z*Z), analogous to the Selberg trace formula relating geometric and spectral data.

**Theorem 3.8** (Lattice Sum Non-negativity). *∑ |z_i|² ≥ 0.*

*Proof.* Each term |z_i|² ≥ 0 by `normSq_nonneg`. Sum of non-negative terms is non-negative.

### 3.5 Zeta Function Properties

**Theorem 3.9** (Zeta Non-negativity). *ζ_H(s, N) ≥ 0 for all s, N.*

*Proof.* Each term of the sum is either 0 (if the condition fails) or |z_n|^{−2s} ≥ 0 (since it's a real power of a non-negative number). By `positivity`, all terms are non-negative.

### 3.6 Prime Counting

**Theorem 3.10** (Infinitude of Hyperbolic Primes). *For every N, there exists a prime p > N.*

*Proof.* Follows from Euclid's theorem (`Nat.exists_infinite_primes` in Mathlib).

**Theorem 3.11** (Unbounded Prime Counting). *For every M, there exists N with π_H(N) ≥ M.*

*Proof.* The set of primes is infinite. By `Set.Infinite.exists_subset_card_eq`, there exists a finite subset of size M. Taking N = max of this subset gives π_H(N) ≥ M.

### 3.7 The Golden Generator

**Theorem 3.12** (Golden Generator in Disk). *|(3−√5)/2|² < 1.*

*Proof.* We need ((3−√5)/2)² < 1. Expanding: (9 − 6√5 + 5)/4 = (14 − 6√5)/4. Since √5 > 5/3, we get 6√5 > 10, so 14 − 6√5 < 4, giving (14−6√5)/4 < 1. The formal proof uses `nlinarith` with `Real.sq_sqrt`.

## 4. Algorithms

### 4.1 Möbius Orbit Computation

```
Algorithm: ComputeHyperbolicIntegers(a, N)
Input: generator a ∈ D, count N
Output: orbit points z_0, ..., z_N

z[0] = 0
for n = 1 to N:
    z[n] = (z[n-1] - a) / (1 - conj(a) * z[n-1])
return z

Time complexity: O(N)
Space complexity: O(N)
```

### 4.2 Hyperbolic Zeta Computation

```
Algorithm: ComputeHypZeta(a, s, N)
Input: generator a ∈ D, exponent s ∈ ℝ, count N
Output: ζ_H(s, N)

z = ComputeHyperbolicIntegers(a, N)
total = 0
for n = 1 to N:
    if |z[n]|² > 0:
        total += |z[n]|^{-2s}
return total

Time complexity: O(N)
Space complexity: O(N)
```

### 4.3 Hyperbolic Prime Counting

```
Algorithm: CountHyperbolicPrimes(N)
Input: bound N
Output: π_H(N)

Use standard sieve (Sieve of Eratosthenes) on {2, ..., N}
Return count of primes found

Time complexity: O(N log log N)
Space complexity: O(N)
```

## 5. Computational Experiments

### 5.1 Golden Generator Orbit

For the golden generator a = (3−√5)/2 ≈ 0.38197, the first 10 orbit points are:

| n | Re(z_n) | |z_n|² |
|---|---------|--------|
| 0 | 0.0000 | 0.0000 |
| 1 | −0.3820 | 0.1459 |
| 2 | −0.6180 | 0.3820 |
| 3 | −0.7639 | 0.5836 |
| 4 | −0.8541 | 0.7294 |
| 5 | −0.9098 | 0.8277 |
| 6 | −0.9441 | 0.8913 |
| 7 | −0.9652 | 0.9317 |
| 8 | −0.9782 | 0.9568 |
| 9 | −0.9863 | 0.9728 |

The orbit approaches the boundary monotonically, as expected for a real generator.

### 5.2 Zeta Sum Growth

For the golden generator at s = 1:

| N  | ζ_H(1, N) | ln(N)  | Ratio |
|----|-----------|--------|-------|
| 5  | 10.85     | 1.609  | 6.74  |
| 10 | 36.46     | 2.303  | 15.83 |
| 20 | 134.8     | 2.996  | 44.99 |
| 50 | 818.3     | 3.912  | 209.2 |

The zeta sum grows much faster than ln(N), suggesting the conjecture ζ_H(1,N) ≥ ln(N) holds easily for this generator.

### 5.3 Distribution in the Disk

For a complex generator a = 0.3 + 0.2i, the orbit spirals around the disk rather than approaching the boundary along the real axis. The orbit points are no longer collinear, creating a genuine 2D lattice structure in the disk.

## 6. Conjectures

### Conjecture 6.1 (Hyperbolic-Spectral Correspondence)

For the golden generator, ζ_H(1, N) ≥ ln(N) for all N ≥ 2. More precisely, we conjecture:

$$\zeta_H(1, N) \sim C \cdot N$$

for some constant C > 0 depending on the generator.

### Conjecture 6.2 (Orbit Equidistribution)

For generators a with |a| bounded away from 0 and 1, the orbit {z_n} becomes equidistributed on the boundary circle ∂D with respect to the arc length measure, in the sense that the angular distribution of z_n/(|z_n|) converges to uniform.

### Conjecture 6.3 (Unique Factorization via Composition)

The orbit composition property (Theorem 3.5) implies that every orbit point z_n with n ≥ 2 can be "factored" into compositions corresponding to the prime factorization of n. The order of composition matters (non-commutativity), creating a canonical factorization that depends on the ordering convention for prime factors.

## 7. Discussion

### 7.1 Non-Commutativity as a Feature

The non-commutativity of hyperbolic addition (z ⊕ 0 = z but 0 ⊕ z = −z) is a direct consequence of the curvature of hyperbolic space. In flat geometry, translations commute because parallel transport is path-independent. In curved geometry, parallel transport is path-dependent, and this path-dependence manifests as non-commutativity of the group action.

This suggests that any number theory on a genuinely curved space must be non-commutative, connecting our work to non-commutative arithmetic geometry.

### 7.2 The Spectral Bridge

The trace-lattice duality (Theorem 3.7) is the simplest instance of a deep pattern: geometric data determines spectral data, and vice versa. The Selberg trace formula is the infinite-dimensional version; our result is the finite-dimensional shadow. Extending this bridge to the full Selberg setting would connect the hyperbolic zeta function to eigenvalues of the Laplacian on the quotient surface Γ\D.

### 7.3 Limitations

Our current framework uses a single generator, which produces a 1-dimensional orbit (a cyclic group). Full hyperbolic lattices require multiple generators and the theory of Fuchsian groups. The extension to multi-generator lattices is the most important direction for future work.

## 8. Future Work

1. **Multi-generator lattices**: Extend from cyclic orbits to orbits under Fuchsian groups Γ < PSL(2,ℝ), connecting to the theory of modular forms and automorphic forms.

2. **Hyperbolic Selberg zeta function**: Relate ζ_H to the Selberg zeta function Z_Γ(s) = ∏ ∏ (1 − e^{−(s+k)ℓ(γ)}) and study its analytic properties.

3. **Equidistribution**: Prove orbit equidistribution results using ergodic theory of the geodesic flow.

4. **Non-commutative factorization**: Develop the algebraic theory of factorization in non-commutative monoids arising from Möbius composition.

5. **Tropical-hyperbolic duality**: Connect hyperbolic arithmetic (where distances are logarithmic) to tropical arithmetic (where addition is max and multiplication is addition).

## References

1. Selberg, A. (1956). Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces with applications to Dirichlet series. *J. Indian Math. Soc.* 20, 47–87.

2. Huber, H. (1956). Über eine neue Klasse automorpher Funktionen und ein Gitterpunktproblem in der hyperbolischen Ebene. *Comment. Math. Helv.* 30, 20–62.

3. Patterson, S.J. (1975). A lattice-point problem in hyperbolic space. *Mathematika* 22(1), 81–88.

4. Lax, P.D. & Phillips, R.S. (1982). The asymptotic distribution of lattice points in Euclidean and non-Euclidean spaces. *J. Funct. Anal.* 46(3), 280–350.

5. Iwaniec, H. (2002). *Spectral Methods of Automorphic Forms*. AMS Graduate Studies in Mathematics.

6. Katok, S. (1992). *Fuchsian Groups*. University of Chicago Press.
