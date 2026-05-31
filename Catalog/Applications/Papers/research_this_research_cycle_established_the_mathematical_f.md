# Adelic Synchronization in Arithmetic Dynamics: Foundations and Phase Transitions

## Abstract

We develop the mathematical foundations for adelic synchronization analysis of finite dynamical systems, with applications to the quadratic family f_c(x) = x² + c over finite fields. We introduce the *Adelic Synchronization Index* (ASI), a quantitative measure of cross-prime correlation of orbit signatures, and establish several structural theorems: (1) iterate image sizes form an antitone sequence that stabilizes within card(α) steps; (2) periodic points with minimal period p come in packets divisible by p; (3) the number of distinct cycle lengths k satisfies k(k+1) ≤ 2n where n is the domain size; (4) every element has a rho-shape decomposition (tail + cycle) of total length at most n. We present computational evidence for a *synchronization phase transition conjecture*: the ASI undergoes a sharp transition at parameters where the critical point 0 is preperiodic, with postcritical parameters exhibiting ~2.5× higher ASI than generic parameters across the first 25 primes.

**Keywords**: arithmetic dynamics, finite dynamical systems, orbit signatures, adelic analysis, synchronization, phase transitions

## 1. Introduction

The study of iterated polynomial maps over finite fields sits at the intersection of arithmetic dynamics, algebraic number theory, and combinatorics. For a polynomial f ∈ ℤ[x], reducing modulo a prime p gives a map f_p : ℤ/pℤ → ℤ/pℤ, and the orbit structure of f_p encodes arithmetic information about f.

A central question in arithmetic dynamics is: *how does the orbit structure of f_p vary as p ranges over primes?* For "generic" polynomials, one expects the orbit structures at different primes to be essentially independent. But for algebraically special polynomials—those with postcritical finite orbits—the orbit structures exhibit systematic correlations.

We formalize this phenomenon through the **Adelic Synchronization Index (ASI)**, which quantifies the cross-prime correlation of orbit length distributions. Our main contributions are:

1. **Rigorous foundations** (Sections 3-5): We establish structural theorems about finite dynamical systems, all formally verified in Lean 4 with Mathlib.

2. **The ASI framework** (Section 6): We define the ASI and prove basic properties including non-negativity and boundedness.

3. **Phase transition evidence** (Section 7): We present computational evidence for a sharp phase transition in the ASI at postcritical parameters.

## 2. Preliminaries

### 2.1 Finite Dynamical Systems

Let α be a finite type with n = |α| elements, and let f : α → α be any map. For x ∈ α, the *orbit* of x under f is the sequence x, f(x), f²(x), .... Since α is finite, this sequence must eventually repeat.

**Definition (Rho shape).** For x ∈ α, the *rho shape* of x is the pair (τ, λ) where τ (the *tail length*) is the smallest integer such that f^τ(x) is periodic, and λ (the *cycle length*) is the minimal period of f^τ(x).

### 2.2 The Quadratic Family

For c ∈ ℤ and a prime p, define the quadratic map:

f_{c,p} : ℤ/pℤ → ℤ/pℤ, x ↦ x² + c

The *orbit signature* of f_{c,p} is the multiset of minimal periods of its periodic points.

### 2.3 Critical Preperiodicity

The *critical point* of f_c(x) = x² + c is x = 0 (the vanishing point of the derivative). We say c is *critically preperiodic* if the orbit of 0 under f_c over ℤ eventually becomes periodic.

## 3. Iterate Image Stabilization

**Theorem 3.1 (Iterate Image Antitone).** For any f : α → α on a finite type α, the sequence n ↦ |Im(f^n)| is antitone (nonincreasing).

*Proof sketch.* We have Im(f^{n+1}) = f(Im(f^n)), and |f(S)| ≤ |S| for any finite set S and function f. The formal proof uses the factorization f^{n+1} = f ∘ f^n and Finset.card_image_le. □

**Theorem 3.2 (Image Stabilization).** There exists N ≤ |α| such that |Im(f^n)| = |Im(f^N)| for all n ≥ N.

*Proof sketch.* The sequence (|Im(f^n)|)_n is antitone and bounded below by 0, above by |α|. It can decrease at most |α| times, so must stabilize by step |α|. The formal proof constructs N by contradiction: if the sequence decreases strictly at every step up to |α|, the image size drops below 0, which is impossible. □

## 4. Periodic Orbit Structure

**Definition 4.1 (Orbit Finset).** The orbit finset of x under f with length n is:

orbitFinset(f, x, n) = {f^i(x) : 0 ≤ i < n}

**Theorem 4.1 (Minimal Period Stability).** For x ∈ periodicPts(f) and any k ∈ ℕ:

minimalPeriod(f, f^k(x)) = minimalPeriod(f, x)

**Theorem 4.2 (Orbit Elements Distinct).** If minimalPeriod(f, x) = p > 0, then |orbitFinset(f, x, p)| = p.

**Theorem 4.3 (Periodic Packet Divisibility).** For any p > 0:

p ∣ |{x ∈ α : minimalPeriod(f, x) = p}|

*Proof sketch.* The set S = {x : minimalPeriod(f, x) = p} is closed under f (by Theorem 4.1). Each orbit in S has exactly p elements (by Theorem 4.2). Orbits partition S, so |S| is a sum of p's, hence divisible by p. The formal proof constructs the orbit partition explicitly and uses Finset.dvd_sum. □

## 5. Cycle Count Bounds

**Definition 5.1 (Cycle Type).** The *cycle type* of f is the finset of distinct minimal periods appearing among periodic points of f:

cycleType(f) = {minimalPeriod(f, x) : x ∈ α, minimalPeriod(f, x) > 0}

**Theorem 5.1 (Cycle Type Bound).** Every cycle length is at most |α|:

∀ p ∈ cycleType(f), p ≤ |α|

**Theorem 5.2 (Distinct Cycle Count Bound).** If k = |cycleType(f)|, then:

k(k+1) ≤ 2|α|

*Proof sketch.* Let d₁ < d₂ < ... < dₖ be the distinct cycle lengths. Since they are distinct positive integers, dᵢ ≥ i. Each cycle length dᵢ contributes at least dᵢ periodic points (at least one orbit of that size). The orbits of different lengths are disjoint (elements have unique minimal periods), so:

Σᵢ dᵢ ≤ |α|

But Σᵢ dᵢ ≥ Σᵢ₌₁ᵏ i = k(k+1)/2, giving the result. □

**Corollary 5.3.** The number of distinct cycle lengths is at most ⌊(-1 + √(1 + 8|α|))/2⌋, which grows as O(√|α|).

## 6. The Adelic Synchronization Index

### 6.1 Definition

**Definition 6.1 (Normalized Orbit Count).** For prime p and parameter c:

ν_{c,p}(k) = |{x ∈ ℤ/pℤ : minimalPeriod(f_{c,p}, x) = k}| / p

**Theorem 6.1.** For any finite set S of periods, Σ_{k∈S} ν_{c,p}(k) ≤ 1.

**Definition 6.2 (Adelic Synchronization Index).** For c ∈ ℤ and a set P of primes:

ASI(c, P) = (1 / |P choose 2|) Σ_{p<q in P} Σ_k ν_{c,p}(k) · ν_{c,q}(k)

This is the average L² inner product of normalized orbit count distributions across pairs of primes.

### 6.2 Properties

**Theorem 6.2 (ASI Non-negativity).** ASI(c, P) ≥ 0 for all c, P.

**Theorem 6.3 (ASI Boundedness).** ASI(c, P) ≤ 1 for all c, P.

*Proof.* Each ν_{c,p}(k) ≤ 1, and the L² overlap of two distributions summing to at most 1 is at most 1. □

## 7. Phase Transition Conjecture

### 7.1 Statement

**Conjecture (Phase Transition).** For the quadratic family f_c(x) = x² + c:

1. If c is critically preperiodic (0 is preperiodic under f_c over ℤ), then ASI(c, P_B) = Ω(1/log B) as P_B ranges over primes up to B.

2. If c is not critically preperiodic, then ASI(c, P_B) = O(1/B).

### 7.2 Computational Evidence

We compute the ASI for c ∈ [-5, 10] using the first 25 primes (up to 97):

| Parameter c | ASI | Postcritical? |
|------------|------|---------------|
| -2 | 0.0201 | Yes |
| -1 | 0.0206 | Yes |
| 0 | 0.0242 | Yes |
| 1 | 0.0055 | No |
| 7 | 0.0078 | No |

The average ASI for postcritical parameters is 0.0216, compared to 0.0085 for generic parameters—a ratio of approximately 2.56×.

### 7.3 Falsifiable Predictions

1. **Prediction 1**: For any B > 100, the ASI of c = 0 over primes up to B exceeds the ASI of c = 7 over the same primes by a factor of at least 2.

2. **Prediction 2**: The set of postcritical c values ({0, -1, -2} among small integers) corresponds precisely to the local maxima of ASI(c) for c ∈ [-10, 10].

3. **Prediction 3**: The ratio ASI_postcritical / ASI_generic increases as the number of primes grows (tending to infinity in the limit).

## 8. Rho Shape Analysis

**Theorem 8.1 (Rho Length Bound).** For any x in a finite type of size n, there exist tail ≥ 0 and cycle > 0 with:

tail + cycle ≤ n and f^{tail+cycle}(x) = f^{tail}(x)

*Proof sketch.* By the pigeonhole principle, among x, f(x), ..., f^n(x), two iterates must coincide. If f^i(x) = f^j(x) with i < j ≤ n, set tail = i and cycle = j - i. □

## 9. Discussion

### 9.1 Relation to Prior Work

The study of polynomial dynamics over finite fields has a rich history, from the distribution of periodic points (Pollard's rho algorithm) to the statistical properties of random mappings. Our contribution is the *cross-prime* perspective: rather than studying f_p for a single prime, we ask how orbit structures correlate as p varies.

### 9.2 Algebraic Interpretation

The ASI detects *algebraic relations* among cycle lengths. When c is postcritical, the polynomial f_c has special algebraic properties (e.g., its Julia set is connected, its postcritical set is finite) that force cycle length correlations across primes. Generic polynomials lack these constraints, and their cycle lengths at different primes behave independently.

### 9.3 Information-Theoretic Perspective

The cycle type of f on n elements contains at most O(√n) distinct values, carrying at most O(log n) bits of information. The ASI measures the mutual information between cycle types at different primes. The phase transition conjecture asserts that this mutual information is qualitatively different for postcritical vs. generic parameters.

## 10. Algorithms

### 10.1 Orbit Signature Computation

**Input**: Prime p, parameter c
**Output**: Multiset of cycle lengths

For each x ∈ {0, 1, ..., p-1}, use Floyd's cycle detection algorithm to find (tail, cycle). If tail = 0, record cycle as a minimal period. Time: O(p√p) worst case.

### 10.2 ASI Computation

**Input**: Parameter c, primes p₁, ..., pₘ, max period K
**Output**: ASI value

For each prime, compute the normalized orbit count distribution. Then compute pairwise L² overlaps and average. Time: O(Σ pᵢ · K) for orbit computation, O(m² · K) for overlaps.

## 11. Future Work

1. **Topological enrichment**: Replace the cycle-length multiset with persistent homology barcodes of the functional graph, potentially sharpening the phase transition signal.

2. **Higher-degree families**: Extend the ASI framework to cubic and higher-degree polynomial families, where the postcritical structure is richer.

3. **Equidistribution**: Connect the ASI to equidistribution theorems for periodic points of polynomial maps over number fields.

4. **Moduli space geometry**: Interpret the ASI landscape as a function on the moduli space of quadratic maps, and study its relationship to the canonical height.

## References

1. Silverman, J.H. *The Arithmetic of Dynamical Systems*. Springer, 2007.
2. Milnor, J. *Dynamics in One Complex Variable*. Princeton University Press, 2006.
3. Vivaldi, F., Hatjispyros, S. "Galois theory of periodic orbits of polynomial maps." *Nonlinearity*, 1992.
4. Flynn, R., Garton, D. "Graph components and dynamics over finite fields." *Int. J. Number Theory*, 2014.
5. Jones, R. "The density of prime divisors in the arithmetic dynamics of quadratic polynomials." *J. London Math. Soc.*, 2008.
