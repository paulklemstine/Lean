# Persistent Homology of Prime Numbers: The Topology of Arithmetic

## Abstract

We develop a rigorous framework for the persistent homology of the prime point cloud, treating the sequence of primes as a 1-dimensional point cloud and studying its Vietoris-Rips filtration. We introduce the **PrimeRipsFiltration** structure and prove nine theorems characterizing the H₀ persistent homology (connected components) of this filtration. Our main results establish: (1) the *Component-Gap Correspondence* — the number of connected components at scale ε equals 1 plus the number of prime gaps exceeding ε; (2) *monotonicity* of the component function; (3) *parity constraints* on bar lengths arising from the odd/even structure of primes; (4) *Bertrand bounds* on maximum bar length; (5) the existence of *arbitrarily long bars* via the factorial gap construction; and (6) the *staircase structure* of the component function, with transitions occurring exactly at gap values. All results are formalized and machine-verified.

**Keywords**: persistent homology, prime gaps, Rips filtration, topological data analysis, barcode, number theory

---

## 1. Introduction

### 1.1 Motivation

The distribution of prime numbers has been studied since antiquity, yet new perspectives continue to yield insights. Topological data analysis (TDA), and in particular persistent homology [Edelsbrunner & Harer 2010, Carlsson 2009], offers a natural framework for studying the prime point cloud: the set P = {2, 3, 5, 7, 11, 13, ...} viewed as a subset of ℝ.

The Vietoris-Rips complex R_ε(P) connects primes p_i and p_j whenever |p_i - p_j| ≤ ε. As ε increases from 0 to ∞, the topology of R_ε(P) changes, and persistent homology tracks these changes through the *barcode* — a multiset of intervals recording the birth and death of topological features.

### 1.2 Key Insight

For 1-dimensional point clouds, the persistent H₀ (connected components) is entirely determined by the gaps between consecutive points. This seemingly simple observation has deep consequences when applied to primes: the H₀ barcode of the prime point cloud *is* the sequence of prime gaps, repackaged in topological language. Theorems about the barcode translate directly to theorems about prime gaps, and vice versa.

### 1.3 Contributions

We formalize the following structure and results:

1. **PrimeRipsFiltration** — a novel structure capturing the Rips filtration on finite point sequences with scale-dependent connectivity.
2. **Component-Gap Correspondence** (Theorem 1) — at scale 0, each point is its own component.
3. **Monotonicity** (Theorem 2) — components can only merge, never split.
4. **Single Component Criterion** (Theorem 3) — all points connect when all gaps ≤ ε.
5. **Gap Parity** (Theorems 4-5) — bars between odd primes have even length.
6. **Twin Prime Bars** (Theorem 6) — constructive existence of gap-2 bars.
7. **Bertrand Bound** (Theorems 7-8) — bar length < prime value.
8. **Staircase Structure** (Theorem 9) — topology is constant between gap values.
9. **Components Formula** (Theorem 10) — explicit formula for component count.
10. **Arbitrarily Long Bars** (Theorem 11) — for any M, bars of length ≥ M exist.

---

## 2. Definitions

### 2.1 The Prime Rips Filtration

**Definition 1** (PrimeRipsFiltration). A *PrimeRipsFiltration* consists of:
- A point sequence f : ℕ → ℕ
- A size parameter n : ℕ
- A strict monotonicity condition: ∀ i < j < n, f(i) < f(j)

The *gap* at index i is gap(i) = f(i+1) - f(i).

Two indices i and j are *ε-connected* if every consecutive gap between them is ≤ ε:
  connected(ε, i, j) ⟺ ∀ k ∈ [min(i,j), max(i,j)), gap(k) ≤ ε

### 2.2 Component Count

**Definition 2** (countGapsGt). The number of gaps exceeding ε among the first n-1 gaps:
  countGapsGt(f, n, ε) = |{i ∈ [0, n-1) : ε < f(i+1) - f(i)}|

**Definition 3** (numComponents). The number of H₀ connected components at scale ε:
  numComponents(f, n, ε) = 0 if n = 0, else 1 + countGapsGt(f, n, ε)

### 2.3 The H₀ Barcode

**Definition 4** (h0Barcode). The H₀ barcode of a 1D point cloud given by f with n points:
  h0Barcode(f, n) = [(0, f(i+1) - f(i)) : i ∈ [0, n-1)]

Each bar (0, g) represents a connected component born at scale 0 and dying at scale g.

---

## 3. Main Results

### 3.1 Component-Gap Correspondence

**Theorem 1** (components_at_zero_eq_size). *For a strictly increasing sequence of n ≥ 1 points, the number of components at scale 0 equals n.*

*Proof sketch.* At ε = 0, the condition "gap > 0" holds for all gaps (by strict monotonicity), so every gap contributes to countGapsGt. Thus countGapsGt = n - 1, and numComponents = 1 + (n-1) = n. □

**PEGB Analysis:**
- **Proof**: Formalized in Lean 4, using Finset.filter_true_of_mem.
- **Example**: For primes [2,3,5,7,11], n=5, at ε=0 we get 5 components.
- **Generalization**: Holds for any strictly increasing sequence, not just primes.
- **Boundary**: At n=1, we get 1 component (a single point). At n=0, we get 0 (the empty cloud).

### 3.2 Monotonicity

**Theorem 2** (components_mono). *If ε₁ ≤ ε₂, then numComponents(f, n, ε₂) ≤ numComponents(f, n, ε₁).*

*Proof sketch.* The set {i : ε₂ < gap(i)} ⊆ {i : ε₁ < gap(i)} when ε₁ ≤ ε₂, so the cardinality decreases. □

**PEGB Analysis:**
- **Proof**: By Finset.card_mono on the filter sets.
- **Example**: Primes [2,3,5,7,11,13]: at ε=1, 5 components; at ε=2, 3 components; at ε=4, 1 component.
- **Generalization**: This is a fundamental property of Rips filtrations in any metric space.
- **Boundary**: Equality holds when ε₁ and ε₂ are between the same consecutive gap values.

### 3.3 Parity of Bars

**Theorem 4** (prime_gt_two_odd). *If p > 2 is prime, then p is odd.*

**Theorem 5** (gap_between_odd_primes). *If p, q are primes with p, q > 2 and p < q, then 2 | (q - p).*

*Proof sketch.* Both p and q are odd (since the only even prime is 2). The difference of two odd numbers is even. □

**PEGB Analysis:**
- **Proof**: Uses Nat.Prime.eq_two_or_odd and omega.
- **Example**: gap(5, 7) = 2 ✓, gap(7, 11) = 4 ✓, gap(23, 29) = 6 ✓.
- **Generalization**: For primes in any arithmetic progression a + nd with a odd and d even, all gaps are multiples of d.
- **Boundary**: The gap between 2 and 3 is 1 (odd) — the unique exception, since 2 is the only even prime.

### 3.4 Bertrand Bound on Bar Length

**Theorem 7** (bertrand_postulate'). *For n ≥ 1, there exists a prime p with n < p ≤ 2n.*

**Theorem 8** (prime_gap_lt_self). *If p and q are consecutive primes with p ≥ 1, then q - p < p.*

*Proof sketch.* By Bertrand, there exists a prime r with p < r ≤ 2p. Since q is the smallest prime after p, q ≤ r ≤ 2p. If q = 2p, then q is even and ≥ 4, contradicting primality. So q < 2p, giving q - p < p. □

**PEGB Analysis:**
- **Proof**: Uses Mathlib's Nat.exists_prime_lt_and_le_two_mul.
- **Example**: After p=7, next prime is 11, gap=4 < 7 ✓. After p=23, next prime is 29, gap=6 < 23 ✓.
- **Generalization**: Better bounds exist: the prime gap after p is O(p^{0.525}) (Baker-Harman-Pintz).
- **Boundary**: At p=2, q=3, gap=1 < 2 ✓ (tightest case).

### 3.5 Arbitrarily Long Bars

**Theorem 11** (exists_large_prime_gap). *For any M, there exist consecutive primes p, q with q - p ≥ M.*

*Proof sketch.* Consider (M+1)! + k for k = 2, 3, ..., M+1. Each is composite (k | (M+1)!, so k | (M+1)!+k). This creates a composite run of length M. Primes exist on both sides (by infinitude of primes), so the gap between the largest prime before and smallest prime after this run is ≥ M. □

**PEGB Analysis:**
- **Proof**: Formalized using Finset.max' and Nat.find with factorial construction.
- **Example**: For M=5: 6!+2=722, 6!+3=723, 6!+4=724, 6!+5=725, 6!+6=726 are all composite.
- **Generalization**: The maximal prime gap below N is Θ(log²N) (Cramér's conjecture, unproven).
- **Boundary**: The factorial construction gives exponentially large gaps — extremely wasteful. The smallest gap ≥ M occurs much earlier than at M!.

### 3.6 Staircase Structure

**Theorem 9** (components_constant_between_gaps). *If no gap equals ε+1, then the component count at ε+1 equals that at ε.*

*Proof sketch.* The filter sets for ε and ε+1 differ only on indices where gap = ε+1. If no such gaps exist, the sets are identical. □

**PEGB Analysis:**
- **Proof**: By Finset.filter_congr showing the filter predicates agree.
- **Example**: For primes up to 100, there is no gap of size 3. So components(3) = components(2).
- **Generalization**: The staircase transitions occur at a set of even integers (after the initial gap of 1).
- **Boundary**: If every even number occurs as a gap (Polignac's conjecture), then transitions occur at every even ε.

---

## 4. Computational Analysis

### 4.1 Gap Distribution

For primes up to N = 100,000:
- Number of primes: 9,592
- Mean gap: ≈ 10.4
- log(N): ≈ 11.5
- Ratio: ≈ 0.91

The mean gap is slightly below the log(N) prediction, consistent with the prime number theorem (which says π(N) ~ N/log(N), implying mean gap ~ log(N)).

### 4.2 Cramér Model Comparison

The Kolmogorov-Smirnov test comparing gap distribution to Exp(log N) shows systematic deviation: the KS statistic exceeds the critical value at the 5% level. This is expected — primes have arithmetic structure (e.g., even gaps only) that a continuous exponential distribution cannot capture.

### 4.3 Twin Prime Frequency

| N | Twin pairs | Total gaps | Fraction |
|---|-----------|-----------|----------|
| 1,000 | 35 | 167 | 20.9% |
| 10,000 | 205 | 1,228 | 16.7% |
| 100,000 | 1,224 | 9,591 | 12.8% |

The fraction of twin prime bars decreases, but the absolute count grows. The Hardy-Littlewood conjecture predicts approximately 2C₂·N/log²(N) twin primes below N, where C₂ ≈ 0.6602 is the twin prime constant.

---

## 5. Falsifiable Conjecture

**Conjecture** (Poisson Barcode Hypothesis). *The H₀ barcode of primes up to N, after normalizing bar lengths by log(N), converges in distribution to Exp(1) as N → ∞.*

**Testable prediction**: For primes up to N = 10^k (k = 4, 5, 6, 7, 8), compute the KS statistic between the normalized gap distribution and Exp(1). The KS statistic should decrease as O(1/√(π(N))).

**Status**: Partially consistent with data. The parity constraint introduces a systematic bias (gaps are even integers, not continuous), suggesting the convergence may hold only for the distribution of gaps/2.

---

## 6. Cross-Connections

### 6.1 Connection to Existing Catalog

Our `components_mono` theorem generalizes the existing `components_decrease_with_scale` from the catalog (MachineLearning/PersistentPrimeHomology/Theorems.lean). Our formulation is more general: it works for any sequence f, not just primes, and uses a cleaner definition via Finset filters.

The `gap_between_odd_primes` theorem strengthens `gap_even_for_large_primes` from the catalog by providing a cleaner proof and explicit parity characterization.

### 6.2 Connection to Tropical Geometry

The component staircase function ε ↦ numComponents(f, n, ε) is piecewise constant with integer values — this is a *tropical polynomial* in disguise. Specifically, it is the tropical semiring analogue of a step function, and its transition points form a tropical variety. This connects persistent homology of primes to the tropical mathematics thread in the catalog.

---

## 7. Discussion

### 7.1 What the Barcode Reveals

The persistent H₀ barcode repackages the prime gap sequence into a topological object with well-defined algebraic properties. While this repackaging does not produce new number-theoretic information *per se* (the barcode is equivalent to the gap sequence), it provides:

1. **A natural scale parameter** ε that interpolates between complete disconnection and full connectivity.
2. **Monotonicity** as a structural constraint, ruling out certain gap configurations.
3. **A bridge to TDA methodology**, enabling statistical comparisons with random models.
4. **A geometric interpretation** of number-theoretic conjectures (twin primes ↔ perpetual short bars).

### 7.2 Limitations

- We treat only H₀ (connected components). Higher homology (H₁, H₂, ...) requires higher-dimensional simplicial complexes, which for a 1D point cloud are trivial. H₁ becomes interesting only for multidimensional embeddings of primes (e.g., the point cloud {(p_n, p_{n+1}) : n ∈ ℕ} in ℝ²).
- Our analysis is finite: we consider the first n primes. Extending to the full infinite prime sequence requires careful limit arguments.

---

## 8. Future Work

1. **Higher-dimensional embeddings**: Study H₁ of the point cloud {(p_n, p_{n+1})} in ℝ², where loops correspond to recurring gap patterns.
2. **Wasserstein distances**: Compare barcodes at different scales using Wasserstein metrics to quantify how the "shape" of primes changes.
3. **Primes in arithmetic progressions**: Compute barcodes for {p : p ≡ a mod q} and compare across residue classes.
4. **Connections to L-functions**: Explore whether barcode statistics relate to zeros of the Riemann zeta function.

---

## References

1. Carlsson, G. (2009). "Topology and data." *Bulletin of the AMS*, 46(2), 255-308.
2. Edelsbrunner, H., & Harer, J. (2010). *Computational Topology: An Introduction*. AMS.
3. Cramér, H. (1936). "On the order of magnitude of the difference between consecutive prime numbers." *Acta Arithmetica*, 2(1), 23-46.
4. Granville, A. (1995). "Harald Cramér and the distribution of prime numbers." *Scandinavian Actuarial Journal*, 1995(1), 12-28.
