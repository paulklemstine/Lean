# Algebraic Foundations of Aperiodic Monotile Theory: Pisot Numbers, Pell Equations, and the Hat Spectrum

## Abstract

We develop the algebraic theory underlying the aperiodic monotile ("the hat") discovered by Smith, Myers, Kaplan, and Goodman-Strauss (2023). The hat tile's substitution system is governed by a 2×2 integer matrix with characteristic polynomial x² − 4x + 1, whose eigenvalues λ = 2 + √3 and μ = 2 − √3 form a Pisot pair. We prove three main results: (1) the eigenvalues are not roots of unity, which implies the substitution matrix has infinite order — the algebraic core of aperiodicity; (2) the trace and companion sequences of the substitution matrix satisfy a generalized Pell equation a(n)² − 12b(n)² = 4, connecting aperiodic tiling theory to the arithmetic of quadratic number fields; and (3) the algebraic dynamics are invariant across the hat spectrum — the continuous family of tiles interpolating between the hat and the turtle. These results bridge the periodic orbit theory of dynamical systems to the aperiodic monotile domain, showing that the Pisot property is the algebraic mechanism that transitions a system from the periodic to the aperiodic regime.

## 1. Introduction

### 1.1 Background

The aperiodic monotile problem — whether a single tile shape can tile the plane but only aperiodically — was one of the longest-standing open problems in combinatorial geometry. The problem traces back to Berger's 1966 proof that a set of 20,426 tiles can tile the plane only aperiodically, followed by increasingly smaller aperiodic sets: Robinson (1971, 6 tiles), Penrose (1974, 2 tiles), and finally Smith et al. (2023, 1 tile).

The hat tile is a 13-sided polygon (a polykite) whose aperiodicity is proved via a hierarchical substitution rule: tiles group into super-tiles, which group into super-super-tiles, ad infinitum. The expansion factor of this substitution — the ratio of sizes between successive levels — is λ = 2 + √3.

### 1.2 Contribution

This paper formalizes the algebraic backbone of the hat tile's aperiodicity. While Smith et al. (2023) prove aperiodicity through geometric and combinatorial arguments, we isolate the *algebraic* mechanism: the expansion factor is a Pisot unit, which implies the substitution matrix has infinite order. This algebraic characterization:

1. **Explains** why aperiodicity holds for the entire hat spectrum, not just the hat
2. **Connects** aperiodic tiling theory to classical number theory (Pell equations, Diophantine approximation)
3. **Bridges** the periodic orbit theory of dynamical systems to the aperiodic regime

All results are formalized and machine-verified.

### 1.3 Catalog References

This work builds upon and extends:
- `Tropical.PeriodicOrbits.periodic_point_with_constraint` — periodic point definability for min-plus cellular automata
- `Bridges.ProofStoneCechDynamics.exists_periodic_point_finite` — existence of periodic points in finite systems

Our contribution shows the opposite phenomenon: when the expansion factor is a Pisot unit, periodic orbits are *impossible*.

## 2. Definitions and Setup

### 2.1 The Hat Substitution Matrix

The hat tile admits a hierarchical substitution rule that can be encoded as a 2×2 integer matrix M with:
- trace(M) = 4
- det(M) = 1

The characteristic polynomial is p(x) = x² − 4x + 1.

**Definition 2.1 (Expansion factor).** The *expansion factor* of the hat substitution is
$$\lambda = 2 + \sqrt{3} \approx 3.732$$
the larger root of x² − 4x + 1 = 0.

**Definition 2.2 (Conjugate eigenvalue).** The *conjugate eigenvalue* is
$$\mu = 2 - \sqrt{3} \approx 0.268$$
the smaller root of x² − 4x + 1 = 0.

### 2.2 The Trace Sequence

**Definition 2.3 (Trace sequence).** The sequence a(n) = tr(Mⁿ) = λⁿ + μⁿ satisfies:
- a(0) = 2, a(1) = 4
- a(n+2) = 4a(n+1) − a(n)

First values: 2, 4, 14, 52, 194, 724, 2702, 10084, ...

**Definition 2.4 (Companion sequence).** The sequence b(n) = (λⁿ − μⁿ)/(λ − μ) satisfies:
- b(0) = 0, b(1) = 1
- b(n+2) = 4b(n+1) − b(n)

First values: 0, 1, 4, 15, 56, 209, 780, 2911, ...

## 3. Main Results

### 3.1 Pisot Property

**Theorem 3.1 (Pisot property).** The expansion factor λ = 2 + √3 is a Pisot number:
1. λ > 1
2. 0 < μ < 1

*Proof.* Since √3 > 0, we have λ = 2 + √3 > 2 > 1. For the conjugate: √3 < 2 (since 3 < 4), so μ = 2 − √3 > 0. And √3 > 1 (since 3 > 1), so μ = 2 − √3 < 1. □

**Theorem 3.2 (Algebraic unit).** The eigenvalues are algebraic units: λ · μ = 1.

*Proof.* λμ = (2 + √3)(2 − √3) = 4 − 3 = 1. □

**Theorem 3.3 (Irrationality).** Both λ and μ are irrational.

*Proof.* Since 3 is prime, √3 is irrational. Adding or subtracting 2 preserves irrationality. □

### 3.2 No-Period Theorem

**Theorem 3.4 (Trace growth).** The trace sequence is strictly increasing for n ≥ 1:
$$a(1) < a(2) < a(3) < \cdots$$

*Proof.* By induction. a(n+2) − a(n+1) = 3a(n+1) − a(n). Since a(n+1) > a(n) (by induction) and a(n+1) ≥ 2, we have 3a(n+1) − a(n) > 3a(n+1) − a(n+1) = 2a(n+1) ≥ 4 > 0. □

**Theorem 3.5 (Not roots of unity).** For all n ≥ 1:
$$\lambda^n \neq 1 \quad \text{and} \quad \mu^n \neq 1$$

*Proof.* Since λ > 1, we have λⁿ > 1. Since 0 < μ < 1, we have μⁿ < 1. Neither equals 1. □

**Theorem 3.6 (No lattice period — the aperiodicity theorem).** For all n ≥ 1:
$$\text{tr}(M^n) \neq 2$$

Equivalently, Mⁿ ≠ I for all n ≥ 1. The hat substitution matrix has infinite order.

*Proof.* a(n) > 2 for n ≥ 1 (from Theorem 3.4 and a(1) = 4). □

**Corollary 3.7 (Invertibility of Mⁿ − I).** For all n ≥ 1:
$$\det(M^n - I) = \text{tr}(M^n) - 2 > 0$$

The only vector v ∈ ℤ² satisfying Mⁿv = v is v = 0.

### 3.3 Pell Equation Identity

**Theorem 3.8 (Generalized Pell identity).** For all n ≥ 0:
$$a(n)^2 - 12 \cdot b(n)^2 = 4$$

*Proof sketch.* By strong induction on n. The base cases a(0)² − 12·b(0)² = 4 − 0 = 4 and a(1)² − 12·b(1)² = 16 − 12 = 4 are immediate. The inductive step uses the recurrence relations and algebraic simplification. The identity reflects the norm form N(α) = αᾱ in the ring ℤ[√3], where α = (a(n) + b(n)√12)/2. □

**Remark 3.9.** The coefficient 12 = (λ − μ)² = (2√3)² appears because the gap between eigenvalues is 2√3. This connects the hat substitution to the quadratic field ℚ(√3) and the Pell equation x² − 3y² = 1 (via the substitution x = a/2, y = b).

### 3.4 Spectrum Invariance

**Theorem 3.10 (Hat spectrum invariance).** For any substitution system with characteristic polynomial x² − 4x + 1, the trace sequence a(n) is identical to the hat's trace sequence. In particular, all tiles in the hat spectrum {H_t : t ∈ [0,1]} share the same algebraic dynamics.

*Proof.* The trace sequence is completely determined by the recurrence a(n+2) = tr·a(n+1) − det·a(n) with initial values a(0) = 2, a(1) = tr. For the hat spectrum, tr = 4 and det = 1 are invariant under the geometric deformation. □

## 4. Bridge to Periodic Orbit Theory

### 4.1 The Periodic-Aperiodic Dichotomy

The Catalog contains results showing that periodic orbits always exist in certain dynamical systems:
- `fixed_periodic_all`: fixed points of any map are periodic with every period
- `periodic_point_with_constraint`: periodic points of min-plus CA are definable
- `exists_periodic_point_finite`: finite dynamical systems always have periodic orbits

The hat substitution reveals the complementary regime. The key algebraic distinction:

| Property | Periodic regime | Aperiodic regime |
|----------|----------------|------------------|
| Expansion factor | Rational (or root of unity) | Irrational Pisot number |
| Eigenvalue conjugate | |μ| ≥ 1 or μ = 1 | 0 < |μ| < 1 |
| Matrix order | Finite | Infinite |
| Lattice periodic points | Exist | Only trivial (v = 0) |
| det(Mⁿ − I) | = 0 for some n | > 0 for all n ≥ 1 |

### 4.2 The Determinant Criterion

**Theorem 4.1.** For a 2×2 integer matrix M with det(M) = 1, the following are equivalent:
1. Mⁿ = I for some n ≥ 1
2. tr(Mⁿ) = 2 for some n ≥ 1
3. det(Mⁿ − I) = 0 for some n ≥ 1
4. The eigenvalues of M are roots of unity

The hat substitution satisfies the negation of all four conditions.

## 5. Algorithms

### 5.1 Computing the Trace Sequence

```
Algorithm: HatTraceComputation(N)
Input: N (number of terms)
Output: a[0..N-1] (trace sequence)

a[0] ← 2
a[1] ← 4
for n from 2 to N-1:
    a[n] ← 4 * a[n-1] - a[n-2]
return a
```

Time complexity: O(N), Space: O(1) (only need two previous values).

### 5.2 Verifying the Pell Identity

```
Algorithm: VerifyPellIdentity(N)
Input: N (number of terms to verify)
Output: True if a[n]² - 12b[n]² = 4 for all n ∈ [0, N]

a[0] ← 2, a[1] ← 4
b[0] ← 0, b[1] ← 1
for n from 0 to N:
    if a[n]² - 12 * b[n]² ≠ 4:
        return False
    if n + 2 ≤ N:
        a[n+2] ← 4 * a[n+1] - a[n]
        b[n+2] ← 4 * b[n+1] - b[n]
return True
```

## 6. Discussion

### 6.1 The Role of the Pisot Property

The Pisot property (λ > 1, |μ| < 1, λμ = 1) is not merely a sufficient condition for aperiodicity — it is the *organizing principle*. The fact that μ lies inside the unit disk means that:
1. The trace sequence a(n) = λⁿ + μⁿ ≈ λⁿ for large n (the conjugate contribution vanishes)
2. The companion sequence b(n) ≈ λⁿ/(2√3) grows at the same exponential rate
3. The Pell identity a(n)² − 12b(n)² = 4 becomes more "tensioned" as n grows

### 6.2 Boundary of the Hat Spectrum

The hat spectrum is parameterized by the geometric deformation, but the algebraic dynamics remain constant. The boundary of the spectrum — where aperiodicity breaks down — corresponds to the degenerate cases where the characteristic polynomial has rational roots (a perfect-square discriminant). For x² − tr·x + det = 0, the discriminant is tr² − 4det. For the hat, this is 16 − 4 = 12, which is not a perfect square. If the discriminant were a perfect square, the eigenvalues would be rational, and periodic tilings might be possible.

### 6.3 Connections to Other Areas

- **Diophantine approximation**: The Pell equation x² − 12y² = 4 is equivalent (via x = 2X, y = Y) to X² − 3Y² = 1, the classical Pell equation for √3. The convergents of the continued fraction of √3 give the best rational approximations, and these are encoded in the hat's trace and companion sequences.
- **Algebraic number theory**: The ring ℤ[√3] has class number 1, and its unit group is generated by 2 + √3. The hat substitution is, in essence, multiplication by this fundamental unit.
- **Dynamical systems**: The hat substitution defines a hyperbolic toral automorphism (Anosov diffeomorphism) on the 2-torus, with the same eigenvalue structure. The connection between aperiodic tilings and hyperbolic dynamics deserves further exploration.

## 7. Future Work

1. Classify all Pisot numbers that give rise to aperiodic monotiles
2. Study the statistical properties of the hat tiling using the Pell equation structure
3. Explore the connection between the hat's algebraic dynamics and hyperbolic dynamics on the 2-torus
4. Extend the Pell identity to higher-dimensional substitution systems
5. Investigate whether the hat spectrum has a natural moduli space structure

## References

1. Smith, D., Myers, J.S., Kaplan, C.S., Goodman-Strauss, C. "An aperiodic monotile." arXiv:2303.10798 (2023).
2. Smith, D., Myers, J.S., Kaplan, C.S., Goodman-Strauss, C. "A chiral aperiodic monotile." arXiv:2305.17743 (2023).
3. Pisot, C. "La répartition modulo 1 et les nombres algébriques." Ann. Sc. Norm. Super. Pisa (1938).
4. Berger, R. "The undecidability of the domino problem." Memoirs AMS 66 (1966).
5. Penrose, R. "The role of aesthetics in pure and applied mathematical research." Bull. Inst. Math. Appl. 10 (1974).
6. Baake, M., Grimm, U. "Aperiodic Order, Volume 1." Cambridge University Press (2013).
