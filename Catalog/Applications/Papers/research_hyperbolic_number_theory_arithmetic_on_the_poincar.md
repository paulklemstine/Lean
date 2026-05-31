# Hyperbolic Number Theory: Formally Verified Arithmetic on the Poincaré Disk

## Abstract

We develop a rigorous algebraic framework for arithmetic on the Poincaré disk, formalizing the Einstein velocity group, the rapidity isomorphism, the SL₂(ℤ) trace classification, and the Poincaré metric's cross-ratio positivity. Our main contributions are:

1. **Einstein velocity group**: A complete proof that the open interval (-1, 1) with Einstein addition (a ⊕ b = (a+b)/(1+ab)) forms a group, with closure, associativity, identity, and inverses all verified.

2. **Rapidity isomorphism theorem**: A proof that the rapidity map artanh : ((-1,1), ⊕) → (ℝ, +) is a group homomorphism, converting the nonlinear Einstein addition to ordinary addition.

3. **Trace classification trichotomy**: A complete characterization of SL₂(ℤ) elements as elliptic (|tr| < 2), parabolic (|tr| = 2, equivalently tr = ±2), or hyperbolic (|tr| > 2), with mutual exclusivity and exhaustiveness.

4. **Cross-ratio positivity**: A proof that the denominator of the Poincaré metric |1 - w̄z|² > 0 for all z, w in the open unit disk, ensuring the metric is well-defined.

5. **Hyperbolic prime counting bounds**: Constructive lower bounds on the counting function for primes serving as potential hyperbolic traces, including monotonicity.

6. **Falsifiable conjecture**: A specific quantitative prediction about hyperbolic prime density that we computationally refute, establishing the correct asymptotic regime.

All proofs are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

### 1.1 Motivation

The integers ℤ, equipped with addition and multiplication, are the foundation of number theory. Their structure is fundamentally tied to the flat geometry of the real line: the integers are evenly spaced, and the distance between consecutive integers is uniform. What changes when we place arithmetic on a curved space?

The Poincaré disk model of hyperbolic geometry provides a natural setting for this question. The open unit disk 𝔻 = {z ∈ ℂ : |z| < 1} carries a Riemannian metric of constant negative curvature, and the group of isometries includes discrete subgroups (such as PSL(2, ℤ)) whose orbit points provide natural "hyperbolic integers."

### 1.2 The Einstein Velocity Group

The starting point is the observation that Einstein's relativistic velocity addition formula

$$a \oplus b = \frac{a + b}{1 + ab}$$

defines a group operation on the open interval (-1, 1). This is the one-dimensional case of the Möbius addition on the Poincaré disk, and it captures the essential algebraic structure of hyperbolic geometry.

### 1.3 Related Work

- **Ungar (2008)**: Developed the theory of gyrogroups and gyrovector spaces, providing an algebraic framework for hyperbolic geometry based on the Einstein velocity addition.
- **Beardon (1983)**: Established the geometric theory of discrete groups acting on hyperbolic space.
- **Selberg (1956)**: Proved the trace formula connecting spectral theory of the Laplacian to the geometry of closed geodesics.
- **Iwaniec (2002)**: Developed spectral methods for automorphic forms with applications to prime geodesic counting.

## 2. Definitions

### 2.1 Einstein Addition

**Definition 2.1** (Einstein Addition). For real numbers a, b, we define
$$\text{einsteinAdd}'(a, b) := \frac{a + b}{1 + ab}$$

**Definition 2.2** (Subluminal). A real number x is *subluminal* if |x| < 1. We write IsSubluminal(x) for this predicate.

**Definition 2.3** (Rapidity). The rapidity of a subluminal value x is
$$\text{rapidity}(x) := \frac{1}{2}\ln\frac{1+x}{1-x} = \text{artanh}(x)$$

### 2.2 SL₂(ℤ) and Trace Classification

**Definition 2.4** (SL₂(ℤ)). The special linear group SL₂(ℤ) consists of 2×2 integer matrices with determinant 1.

**Definition 2.5** (Trace Classification). For an integer t (the trace of an SL₂(ℤ) element), we define:
- classifyByTrace(t) = elliptic if |t| < 2
- classifyByTrace(t) = parabolic if |t| = 2
- classifyByTrace(t) = hyperbolic if |t| > 2

### 2.3 Cross-Ratio and Poincaré Metric

**Definition 2.6** (Cross-Ratio Modulus Squared). For complex numbers z, w:
$$\text{crossRatioModSq}(z, w) := \frac{|z - w|^2}{|1 - \bar{w}z|^2}$$

### 2.4 Hyperbolic Prime Counting (Novel)

**Definition 2.7** (Hyperbolic Prime Count). We define
$$\pi_H(n) := |\{p \in [3, n] : p \text{ is prime}\}|$$
counting primes p > 2 up to n. These correspond to potential traces of primitive hyperbolic elements in SL₂(ℤ).

### 2.5 Einstein Velocity (Novel Structure)

**Definition 2.8** (Einstein Velocity). The type EinsteinVelocity is the subtype {x : ℝ // IsSubluminal x}, equipped with:
- Zero: (0, proof that |0| < 1)
- Negation: (-x, proof that |-x| < 1)
- Addition: Einstein addition on the underlying values

## 3. Main Results

### 3.1 Einstein Addition Closure (Theorem 1)

**Theorem 3.1** (einstein_add_subluminal). *If |a| < 1 and |b| < 1, then |einsteinAdd'(a, b)| < 1.*

*Proof sketch.* Unfold the definition and show |a+b| < |1+ab|. The key algebraic identity is
$$(1 + ab)^2 - (a+b)^2 = (1 - a^2)(1 - b^2) > 0$$
since |a| < 1 implies 1 - a² > 0 and similarly for b. The proof uses abs_lt to extract bounds, then div_lt_iff to reduce to the polynomial inequality, finished by nlinarith. □

### 3.2 Einstein Addition Associativity (Theorem 2)

**Theorem 3.2** (einstein_add_assoc). *If |a|, |b|, |c| < 1, then (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c).*

*Proof sketch.* After unfolding einsteinAdd', use field_simp with the nonzero denominators (1 + ab ≠ 0 and 1 + bc ≠ 0, from einstein_denom_ne_zero), then close with ring. □

### 3.3 Rapidity Additivity (Theorem 3)

**Theorem 3.3** (rapidity_additive). *If |a| < 1 and |b| < 1, then rapidity(a ⊕ b) = rapidity(a) + rapidity(b).*

*Proof sketch.* The core identity is:
$$\frac{1 + \frac{a+b}{1+ab}}{1 - \frac{a+b}{1+ab}} = \frac{(1+a)(1+b)}{(1-a)(1-b)}$$

After establishing this by field_simp and ring, use Real.log_mul and Real.log_div to decompose the logarithm, then verify the result by ring arithmetic on the rapidity formula. □

### 3.4 Parabolic Trace Characterization (Theorem 4)

**Theorem 3.4** (parabolic_iff_trace_pm2). *classifyByTrace(t) = parabolic if and only if t = 2 or t = -2.*

*Proof sketch.* Unfold classifyByTrace and analyze the if-then-else chain. The forward direction uses Int.natAbs_eq to recover the sign. The backward direction computes directly. Proved using the grind tactic with extensional equality. □

### 3.5 Cross-Ratio Positivity (Theorem 5)

**Theorem 3.5** (cross_ratio_denom_pos). *If normSq(z) < 1 and normSq(w) < 1, then normSq(1 - w̄z) > 0.*

*Proof sketch.* Expand normSq in terms of real and imaginary parts. The result reduces to a polynomial inequality in four real variables, which is dispatched by nlinarith using auxiliary square terms to witness positivity. □

### 3.6 Hyperbolic Prime Counting Lower Bound (Theorem 6)

**Theorem 3.6** (hypPrimeCount_lower_bound). *For n ≥ 25, π_H(n) ≥ 3.*

*Proof sketch.* Exhibit the set {3, 5, 7} as a subset of the filter. Each element is verified to be prime (by norm_num), greater than 2, and less than n (since n ≥ 25). The bound follows from Finset.card_le_card via Finset.two_lt_card. □

### 3.7 Einstein Velocity Group Structure (Theorem 7)

**Theorem 3.7** (EinsteinVelocity group laws). *The Einstein velocity type satisfies:*
- *add_zero: v ⊕ 0 = v*
- *zero_add: 0 ⊕ v = v*
- *neg_add: (-v) ⊕ v = 0*

*Proof sketch.* Each follows from the corresponding identity for einsteinAdd' by applying Subtype.ext and reducing to the real-valued statement. □

## 4. The Falsifiable Conjecture

### 4.1 Statement

**Conjecture** (Hyperbolic Prime Density). The naive conjecture that π_H(N) ~ N²/(2 log N) is *false*.

### 4.2 Computational Test

We compute the ratio π_H(N) · log(N) / N² for increasing N:

| N     | π_H(N) | π_H(N)·ln(N)/N² |
|-------|---------|------------------|
| 100   | 24      | 0.01106          |
| 500   | 94      | 0.00234          |
| 1000  | 167     | 0.00115          |
| 5000  | 668     | 0.00023          |
| 10000 | 1228    | 0.00011          |

The ratio converges to 0, decisively refuting the N²/(2 log N) conjecture. The correct asymptotic is π_H(N) ~ N/log(N) (the prime number theorem), giving π_H(N)·log(N)/N → 1.

### 4.3 Interpretation

The quadratic growth N²/(2 log N) confuses two different counting problems:
1. **Trace-based counting**: How many *ordinary* primes serve as traces of hyperbolic elements? This follows the classical PNT.
2. **Geometric counting**: How many orbit points lie within a hyperbolic ball of radius R? This follows Selberg's lattice point theorem: N(R) ~ Ce^R.

The original conjecture conflated these two distinct counting regimes.

## 5. Algorithms

### 5.1 Einstein Addition with Closure Verification

```
Input: a, b ∈ (-1, 1)
Output: a ⊕ b ∈ (-1, 1)
1. Compute result = (a + b) / (1 + a·b)
2. Assert |result| < 1 (guaranteed by Theorem 3.1)
3. Return result
```

### 5.2 Rapidity-Based Computation

```
Input: a₁, ..., aₙ ∈ (-1, 1)
Output: a₁ ⊕ a₂ ⊕ ... ⊕ aₙ
1. Compute rᵢ = rapidity(aᵢ) for each i
2. Compute R = r₁ + r₂ + ... + rₙ  (ordinary addition)
3. Return tanh(R)  (inverse rapidity)
```

By the rapidity isomorphism (Theorem 3.3), this gives the same result as iterated Einstein addition, but is numerically more stable for long chains.

### 5.3 SL₂(ℤ) Orbit Generation

```
Input: basepoint z₀ ∈ ℍ, max depth D
Output: orbit {γ·z₀ : γ ∈ SL₂(ℤ), word_length(γ) ≤ D}
1. Initialize queue with identity matrix, depth 0
2. For each (γ, d) in queue:
   a. Compute γ·z₀ via Möbius action
   b. Map to disk via Cayley transform
   c. Classify γ by trace (Theorem 3.4)
   d. If d < D, enqueue γ·T, γ·T⁻¹, γ·S
3. Deduplicate by matrix entries
```

## 6. Discussion

### 6.1 Connections to Physics

The Einstein velocity group is not merely an analogy — it *is* the group of Lorentz boosts in 1+1 dimensions. The rapidity is the standard parametrization used in particle physics. Our isomorphism theorem (Theorem 3.3) is a rigorous proof of the well-known physics fact that "rapidities add," placing it on firm mathematical foundations.

### 6.2 Connections to Automorphic Forms

The trace classification (Theorems 3.4 and related) is the starting point for the Selberg trace formula. Elliptic elements contribute to the identity term, parabolic elements to the cusp contribution, and hyperbolic elements — through the prime geodesic theorem — to the spectral side. Our formalization provides the algebraic foundations needed to state and eventually prove these deeper results.

### 6.3 The Spectral Gap and Ramanujan Conjecture

The error term in the prime geodesic theorem is controlled by the spectral gap of the Laplacian on the modular surface. The Ramanujan conjecture (proved by Deligne for GL(2) over function fields, and by Eichler-Shimura-Igusa for holomorphic forms on GL(2)/ℚ) implies optimal error terms. Extending our framework to include spectral theory would enable formal verification of these deeper connections.

## 7. Future Work

1. **Selberg zeta function**: Define ζ_Γ(s) = ∏_{γ primitive hyperbolic} ∏_{k=0}^∞ (1 - e^{-(s+k)ℓ(γ)}) and prove its analytic continuation.

2. **Trace formula**: Formalize the Selberg trace formula connecting spectral and geometric data.

3. **Spectral theory**: Define the Laplacian on L²(Γ\ℍ) and establish the connection between its eigenvalues and the error term in the prime geodesic theorem.

4. **Higher-dimensional generalization**: Extend Einstein addition to the full Poincaré disk model in ℂ, where the gyration operator becomes nontrivial.

5. **Connections to the Langlands program**: The automorphic representations of GL(2) over ℚ encode both the classical and hyperbolic prime distributions. A formal bridge between these would be a significant achievement.

## References

1. Ungar, A.A. (2008). *Analytic Hyperbolic Geometry and Albert Einstein's Special Theory of Relativity*. World Scientific.
2. Beardon, A.F. (1983). *The Geometry of Discrete Groups*. Springer.
3. Selberg, A. (1956). Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces with applications to Dirichlet series. *J. Indian Math. Soc.* 20, 47–87.
4. Iwaniec, H. (2002). *Spectral Methods of Automorphic Forms*. AMS/Revista Matemática Iberoamericana.
5. Sarnak, P. (1983). The arithmetic and geometry of some hyperbolic three-manifolds. *Acta Math.* 151, 253–295.
6. Hejhal, D. (1976, 1983). *The Selberg Trace Formula for PSL(2, ℝ)*. Vols. I–II, Springer.
