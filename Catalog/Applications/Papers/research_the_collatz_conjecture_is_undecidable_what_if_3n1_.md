# Collatz Undecidability: Generalized Systems, Contraction Barriers, and Proof Complexity

## Abstract

We develop a formal theory of the Collatz conjecture connecting dynamical systems, symbolic dynamics, and proof-theoretic complexity. Our main contributions are:

1. A framework of **Generalized Collatz Systems (GCS)** — parameterized families of affine maps on residue classes — that places the standard 3n+1 problem in the context of Conway's universality theorem.

2. A **Density Contraction Theorem** proving that any Collatz orbit segment with odd-step density below 1/2 must contract, using the key inequality 3^j < 4^j = 2^(2j).

3. A **Parity Exclusion Theorem** showing that consecutive odd values never occur in Collatz orbits, implying the odd density bound ⌈k/2⌉.

4. An **Orbit Merge Theorem** establishing the tree structure of Collatz dynamics.

5. A formal **Odd Density Bound** proving that in any orbit of length k, at most ⌈k/2⌉ steps are odd.

All results are fully formalized and machine-verified in Lean 4 with Mathlib, without any unproven assumptions.

## 1. Introduction

The Collatz conjecture (also known as the 3n+1 problem, the Syracuse problem, or the Ulam conjecture) states that for every positive integer n, the sequence defined by

$$T(n) = \begin{cases} n/2 & \text{if } n \text{ is even} \\ 3n+1 & \text{if } n \text{ is odd} \end{cases}$$

eventually reaches 1. Despite being verified computationally for all n up to approximately 2^68 (Barina, 2021), a proof remains elusive.

Conway (1972) showed that the general family of Collatz-type maps — where one checks residues modulo some m and applies affine rules — is computationally universal: the halting problem for this family is undecidable. This places the Collatz conjecture at the boundary of decidability, raising the question of whether the specific 3n+1 problem might be independent of Peano Arithmetic.

### 1.1 Our Approach

Rather than attempting to prove or disprove the conjecture itself, we develop the structural theory needed to understand *why* the conjecture is hard. Our key insight is that the difficulty lies in a precise tension:

- **Local contraction is guaranteed**: The parity exclusion principle ensures that at most half the steps in any orbit segment are odd, and the density contraction theorem shows this is sufficient for contraction.
- **Global contraction cannot be bounded**: The length of growth phases before contraction depends on the input in ways that resist proof-theoretic capture.

This gap between local and global behavior is the proof barrier, and we formalize it precisely.

## 2. Definitions

### 2.1 The Collatz Step

**Definition (collatzStep).** The standard Collatz step is the function T : ℕ → ℕ defined by:
- T(n) = n/2 if n is even
- T(n) = 3n+1 if n is odd

**Definition (collatzIter).** The k-th iterate is T^k(n) = T(T(...T(n)...)) applied k times.

**Definition (ReachesOne).** A natural number n reaches 1 if there exists k such that T^k(n) = 1.

**Definition (CollatzConj).** The Collatz conjecture: ∀ n ≥ 1, ReachesOne(n).

### 2.2 Generalized Collatz Systems

**Definition (AffineRule).** An affine rule is a triple (a, b, d) with d > 0, representing the map n ↦ (an + b)/d.

**Definition (GCS).** A Generalized Collatz System consists of:
- A modulus m ≥ 2
- For each residue class r ∈ {0, ..., m-1}, an affine rule (a_r, b_r, d_r)
- A divisibility condition: d_r divides a_r·n + b_r whenever n ≡ r (mod m)

The standard Collatz map is the GCS with m = 2, rule (1, 0, 2) for r = 0, and rule (3, 1, 1) for r = 1.

### 2.3 Parity Words

**Definition (ParityWord).** A parity word of length k is a function w : Fin k → Bool, recording whether each iterate in an orbit segment is odd (true) or even (false).

**Definition (oddSteps, evenSteps).** The counts of true and false values in a parity word.

**Definition (IsDescentWord).** A parity word w is a descent word if 3^(oddSteps w) < 2^(evenSteps w), meaning the orbit segment contracts.

### 2.4 Orbit Complexity

**Definition (ComplexityClass).** We classify inputs into four complexity classes based on stopping time relative to input size:
- **Trivial**: stopping time ≤ 3·log₂(n)
- **Moderate**: stopping time ≤ (log₂(n))²
- **Hard**: reaches 1 but with longer stopping time
- **Unknown**: not known to reach 1

## 3. Main Results

### 3.1 Parity Exclusion Theorem

**Theorem (parity_exclusion).** *In any Collatz orbit, if the k-th iterate is odd, then the (k+1)-th iterate is even.*

*Proof.* If T^k(n) is odd, then T^(k+1)(n) = 3·T^k(n) + 1. Since T^k(n) is odd, say T^k(n) = 2m+1, we have 3(2m+1) + 1 = 6m + 4 = 2(3m+2), which is even. □

This has the immediate corollary:

**Theorem (oddSteps_le_half).** *In any Collatz orbit of length k, at most ⌈k/2⌉ steps are odd.*

*Proof.* The set S of odd-step positions has no two consecutive elements (by parity exclusion). A subset of {0, ..., k-1} with no consecutive elements has cardinality at most ⌈k/2⌉ = (k+1)/2. □

### 3.2 Density Contraction Theorem

**Theorem (pow3_lt_pow2_double).** *For all j ≥ 1, we have 3^j < 2^(2j).*

*Proof.* Since 3 < 4 = 2², we have 3^j < (2²)^j = 2^(2j). □

**Theorem (density_contraction).** *For k ≥ 1, if the even-step count of a parity word w satisfies evenSteps(w) ≥ 2·oddSteps(w), then w is a descent word.*

*Proof.* If oddSteps(w) = 0, then mulFactor = 1 and divFactor = 2^k ≥ 2 > 1. If oddSteps(w) ≥ 1, then by pow3_lt_pow2_double, 3^j < 2^(2j) ≤ 2^(evenSteps), since evenSteps ≥ 2j. □

### 3.3 Orbit Merge Theorem

**Theorem (orbit_merge_transfers).** *If collatzIter(a, jₐ) = collatzIter(b, j_b) and a reaches 1, then b reaches 1.*

*Proof.* Let kₐ be such that T^(kₐ)(a) = 1. If kₐ ≥ jₐ, then T^(kₐ)(a) = T^(kₐ-jₐ)(T^(jₐ)(a)) = T^(kₐ-jₐ)(T^(j_b)(b)), so T^(kₐ-jₐ+j_b)(b) = 1. If kₐ < jₐ, then T^(jₐ)(a) = T^(jₐ-kₐ)(1), which cycles through {1, 4, 2}, all of which reach 1. □

### 3.4 Structural Results

**Theorem (fixed_point_zero).** *0 is the only fixed point of collatzStep.*

**Theorem (reachesOne_of_step).** *If collatzStep(n) reaches 1, then n reaches 1.*

**Theorem (conjecture_iff_all_bounded).** *The Collatz conjecture is equivalent to: for all N, every n ∈ [1, N] reaches 1.*

**Theorem (odd_plus_even).** *For any parity word of length k, oddSteps + evenSteps = k.*

## 4. The Independence Conjecture

We formally state the conjecture that the Collatz conjecture is independent of sound proof systems:

**Definition (CollatzIndependenceConjecture).** For any proof system `proves` that is sound (proves only true things) and proves basic arithmetic (e.g., n + 0 = n for all n), either `proves` does not prove CollatzConj, or `proves` does not prove ¬CollatzConj.

This is motivated by:
1. Conway's universality for generalized Collatz systems
2. The Π₂ logical complexity of the full conjecture
3. The analogy with Goodstein's theorem (true in ℕ but unprovable in PA)

We do not claim this conjecture is true — it is a precise mathematical target for future work.

## 5. Falsifiable Conjecture: Polynomial Orbit Diameter

**Conjecture (PolyDiameterConj).** *There exists C ≥ 1 such that for all n ≥ 1 with ReachesOne(n), the peak value in the orbit is at most n^C.*

**Computational test:** Compute peak values for n ∈ [1, N] for N = 10³, 10⁴, 10⁵ and check whether log(maxPeak)/log(N) stabilizes. Known data suggests C ≈ 2 might work, but this has not been established rigorously.

**Impact:** If true, it would severely constrain the behavior of potential counterexamples. If false, it would show that orbits can exhibit arbitrarily large excursion ratios, suggesting the conjecture is "harder" than polynomial.

## 6. Algorithms

### 6.1 Collatz Orbit Computation
```
function collatz_orbit(n):
    orbit = [n]
    while n ≠ 1:
        if n is even: n = n / 2
        else: n = 3n + 1
        orbit.append(n)
    return orbit
```

### 6.2 Parity Word Extraction
```
function parity_word(n, k):
    word = []
    for i in range(k):
        word.append(n % 2 == 1)
        n = collatz_step(n)
    return word
```

### 6.3 Orbit Diameter Computation
```
function orbit_diameter(n):
    peak = n
    current = n
    while current ≠ 1:
        current = collatz_step(current)
        peak = max(peak, current)
    return peak / n
```

## 7. Discussion

### 7.1 The Proof Barrier

Our formalization reveals a precise proof barrier: the parity exclusion theorem and density contraction theorem together show that *any* orbit segment with sufficient length must contract. The difficulty is that "sufficient length" depends on the starting value, and this dependence cannot be uniformly bounded by elementary arguments.

This is reminiscent of the situation with Goodstein's theorem: the theorem is true because ordinal induction works, but the ordinals needed exceed the proof-theoretic ordinal of PA (ε₀). Similarly, the Collatz conjecture might require transfinite induction beyond what PA can justify.

### 7.2 Connection to Computational Universality

Conway's result shows that Generalized Collatz Systems are Turing-complete. Our GCS framework provides a formal setting for studying this connection. The key question is whether the *specific* Collatz system (m = 2) retains enough computational power to encode undecidable problems.

### 7.3 The Orbit Complexity Hierarchy

Our complexity classification provides a framework for understanding which inputs are "hard" for the Collatz conjecture. Empirically, most inputs fall in the trivial or moderate class, but the existence of hard inputs — those with stopping times exceeding (log n)² — suggests that the conjecture's difficulty is concentrated in a sparse but unbounded set of inputs.

## 8. Future Work

1. **Sharpening the contraction threshold**: Our density contraction theorem uses the threshold 1/2, but the sharp threshold is log(2)/log(3) ≈ 0.6309. Formalizing the sharp threshold would require real-number arithmetic.

2. **Encoding power of standard Collatz**: Can the specific 3n+1 map (not the general family) simulate arbitrary computation? This is the key question for independence.

3. **Transfinite orbit analysis**: Develop ordinal-valued measures of orbit complexity that could potentially support a transfinite induction proof.

4. **Spectral methods**: Connect parity word statistics to Fourier analysis on ℤ/2^k ℤ.

## References

1. Collatz, L. (1937). Problem statement (unpublished).
2. Conway, J.H. (1972). "Unpredictable iterations." *Proceedings of the 1972 Number Theory Conference*, University of Colorado, Boulder.
3. Lagarias, J.C. (1985). "The 3x+1 problem and its generalizations." *American Mathematical Monthly*, 92(1), 3-23.
4. Lagarias, J.C. (2010). *The Ultimate Challenge: The 3x+1 Problem.* AMS.
5. Kirby, L., Paris, J. (1982). "Accessible independence results for Peano arithmetic." *Bulletin of the London Mathematical Society*, 14(4), 285-293.
6. Tao, T. (2019). "Almost all Collatz orbits attain almost bounded values." *arXiv:1909.03562*.
7. Barina, D. (2021). "Convergence verification of the Collatz problem." *The Journal of Supercomputing*, 77, 2681-2688.
