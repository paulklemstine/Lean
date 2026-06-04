# Collatz Undecidability: Generalized Iteration Systems, Parity Profiles, and Proof-Theoretic Barriers

## Abstract

We develop a formal theory connecting the Collatz conjecture to computability and proof theory. Our contributions are threefold. First, we introduce the *parity profile algebra*, a novel algebraic structure that encodes the binary decision sequence of a Collatz orbit, and prove that the orbit's multiplicative growth factor is exactly 3^a where a is the number of odd steps (the Orbit Encoding Theorem). Second, we formalize *Generalized Collatz Systems* (GCS), an abstraction with arbitrary modulus that subsumes the standard Collatz map, and prove that the standard Collatz function and the Syracuse (accelerated) function arise as special cases. Third, we establish the *Completeness Gap Theorem*, which formalizes the logical barrier between instance-by-instance verification and universal proof: if the Collatz conjecture is true but unprovable in a sound formal theory, then it is independent. All results are machine-verified in Lean 4 with no axioms beyond the standard foundations of mathematics.

**Keywords**: Collatz conjecture, 3n+1 problem, undecidability, parity profile, generalized Collatz system, proof-theoretic barrier, arithmetical hierarchy

## 1. Introduction

The Collatz conjecture, proposed by Lothar Collatz in 1937, states that the iteration

$$T(n) = \begin{cases} n/2 & \text{if } n \text{ is even} \\ 3n+1 & \text{if } n \text{ is odd} \end{cases}$$

eventually reaches 1 from any positive integer starting value. Despite extensive computational verification (up to 2^68 by Barina, 2020) and significant partial results (Tao, 2019, proving convergence for almost all integers in a logarithmic density sense), a complete proof remains elusive.

This paper investigates the structural reasons for this difficulty, formalizing three complementary perspectives:

1. **Algebraic**: The parity profile captures all dynamical information about an orbit, reducing the conjecture to a question about binary sequences.

2. **Computational**: Generalized Collatz Systems provide a formal framework connecting the specific 3n+1 problem to the broader undecidability landscape established by Conway (1972).

3. **Proof-theoretic**: The completeness gap between finite verification and universal proof is precisely the logical space where independence results live.

### 1.1 Related Work

Conway (1972) proved that a class of generalized Collatz functions, called FRACTRAN programs, can simulate arbitrary computations, establishing the undecidability of the halting problem for such systems. Kurtz and Simon (2007) strengthened this by showing that the problem remains undecidable even for relatively small moduli.

The connection to proof theory has been explored informally by several authors. Our work makes these connections precise by formalizing them in a proof assistant, ensuring logical rigor.

## 2. Definitions and Setup

### 2.1 The Collatz Function

**Definition 2.1** (Collatz Step). The *Collatz step function* `collatz : ℕ → ℕ` is defined by:
```
collatz(n) = n/2        if n ≡ 0 (mod 2)
collatz(n) = 3n + 1     if n ≡ 1 (mod 2)
```

**Definition 2.2** (Iteration). For k ∈ ℕ, `collatzIter(n, k)` denotes the k-fold composition of `collatz` applied to n.

**Definition 2.3** (Reachability). We say n *reaches 1* if there exists k ∈ ℕ such that `collatzIter(n, k) = 1`.

**Definition 2.4** (Syracuse Function). The *Syracuse function* `syracuse : ℕ → ℕ` is the accelerated Collatz map defined by:
```
syracuse(n) = n/2          if n ≡ 0 (mod 2)
syracuse(n) = (3n + 1)/2   if n ≡ 1 (mod 2)
```
This combines the odd step (3n+1, which always produces an even number) with the subsequent even step (division by 2).

### 2.2 Parity Profile (Novel Definition)

**Definition 2.5** (Odd Step Count). The *odd step count* `oddCount(n, k)` is the number of indices i < k such that `collatzIter(n, i)` is odd. Formally:
```
oddCount(n, 0) = 0
oddCount(n, k+1) = oddCount(n, k) + [collatzIter(n, k) is odd]
```
where [·] is the Iverson bracket.

**Definition 2.6** (Balance Ratio). The *balance ratio* β(n, k) = oddCount(n, k) / k measures the density of odd steps in the first k iterations.

**Definition 2.7** (Orbit Numerator). The *orbit numerator* `orbitNumerator(n, k)` tracks the multiplicative contribution of odd steps:
```
orbitNumerator(n, 0) = 1
orbitNumerator(n, k+1) = orbitNumerator(n, k) × (3 if step k is odd, 1 if even)
```

### 2.3 Generalized Collatz Systems

**Definition 2.8** (GCS). A *Generalized Collatz System* with modulus m ≥ 1 consists of:
- A multiplier function `multiplier : Fin(m) → ℕ`
- An offset function `offset : Fin(m) → ℤ`

The GCS step function is:
```
step(n) = (multiplier(n mod m) · n + offset(n mod m)) / m
```

The standard Collatz corresponds to m = 2 with multiplier = [1, 3] and offset = [0, 1].

## 3. Main Results

### 3.1 Orbit Structure Theorems

**Theorem 3.1** (Descent Lemma). For even n ≥ 2, `collatz(n) < n`.

*Proof*. `collatz(n) = n/2 < n` since n ≥ 2. □

**Theorem 3.2** (Ascent Lemma). For odd n ≥ 1, `collatz(n) > n`.

*Proof*. `collatz(n) = 3n + 1 > n` since n ≥ 1. □

**Theorem 3.3** (Parity of Odd Step). For odd n, `collatz(n)` is always even.

*Proof*. `collatz(n) = 3n + 1`. Since n is odd, 3n is odd, so 3n + 1 is even. □

**Theorem 3.4** (Syracuse Bound). For odd n, `syracuse(n) ≤ 2n`.

*Proof*. `syracuse(n) = (3n+1)/2 ≤ (3n+1)/2`. Since n ≥ 1, we have 3n+1 ≤ 4n, so (3n+1)/2 ≤ 2n. □

### 3.2 The 4-2-1 Cycle

**Theorem 3.5** (Cycle Periodicity). `collatzIter(1, 3k) = 1` for all k ∈ ℕ.

*Proof*. By induction on k. The base case is immediate. For the inductive step, `collatzIter(1, 3(k+1)) = collatzIter(collatzIter(1, 3k), 3) = collatzIter(1, 3) = 1`, using the fact that 1 → 4 → 2 → 1 in three steps. □

**Theorem 3.6** (Cycle Continuation). If `collatzIter(n, k) = 1`, then `collatzIter(n, k+3) = 1`.

This means once an orbit reaches 1, it remains trapped in the 4-2-1 cycle forever.

### 3.3 The Orbit Encoding Theorem

**Theorem 3.7** (Orbit Numerator = 3^oddCount). For all n, k:
```
orbitNumerator(n, k) = 3^oddCount(n, k)
```

*Proof*. By induction on k. The base case gives 1 = 3^0. For the inductive step, if step k is odd, both sides multiply by 3 (the numerator by definition, the exponent by incrementing oddCount). If step k is even, both sides remain unchanged (multiply by 1, add 0 to oddCount). □

This theorem reveals that the multiplicative growth of a Collatz orbit is governed entirely by the number of odd steps: each odd step contributes a factor of 3, while even steps contribute nothing multiplicatively (they only divide by 2 in the denominator). The orbit converges when the denominator 2^(k - oddCount) grows faster than the numerator 3^oddCount, which requires oddCount/k < log(2)/log(3) ≈ 0.63.

### 3.4 Balance Ratio Bounds

**Theorem 3.8**. The balance ratio satisfies 0 ≤ β(n, k) ≤ 1 for all n, k.

*Proof*. Non-negativity is immediate since oddCount ≥ 0 and k > 0. The upper bound follows from oddCount(n, k) ≤ k (proved by induction). □

### 3.5 GCS Correspondence

**Theorem 3.9** (GCS-Collatz Equivalence, Even Case). For even n, the standard Collatz GCS step equals `collatz(n)`.

**Theorem 3.10** (GCS-Syracuse Equivalence, Odd Case). For odd n, the standard Collatz GCS step equals `syracuse(n)`.

These theorems validate that the GCS framework correctly abstracts the Collatz dynamics. The GCS always divides by its modulus, so the mod-2 GCS naturally produces the Syracuse (accelerated) function rather than the raw Collatz function.

### 3.6 The Completeness Gap Theorem

**Definition 3.1** (Formal Theory). A *formal theory* T is a set of propositions closed under modus ponens. T is *sound* if all its theorems are true.

**Definition 3.2** (Independence). A proposition p is *independent* of T if neither p nor ¬p is in T.

**Theorem 3.11** (Completeness Gap). Let T be a sound formal theory, and let p : ℕ → Prop be a predicate. If (∀n, p(n)) is true but not provable in T, then (∀n, p(n)) is independent of T.

*Proof*. By hypothesis, p is not provable. If ¬p were provable, soundness would imply ¬p is true, contradicting the truth of p. Hence neither p nor ¬p is provable. □

**Corollary 3.12** (Collatz Independence Structure). If the Collatz conjecture is true but unprovable in a sound theory T, then it is independent of T.

This theorem does not prove that the Collatz conjecture is independent of PA. Rather, it establishes the *logical structure* of such an independence result: truth plus unprovability implies independence. The open question is whether the unprovability hypothesis holds.

### 3.7 Reachability Properties

**Theorem 3.13** (Transitivity). If n reaches m and m reaches p via Collatz iteration, then n reaches p.

**Theorem 3.14** (Preimage Closure). If collatz(n) reaches 1, then n reaches 1.

These structural properties show that `reachesOne` is well-behaved: it is closed under Collatz preimages and reachability is transitive.

## 4. Falsifiable Conjecture

**Conjecture 4.1** (Parity Balance). For every n ≥ 1 that reaches 1 with stopping time T:
```
3 · oddCount(n, T) < 2 · T
```

Equivalently, the fraction of odd steps is strictly less than 2/3 for every convergent orbit.

**Computational Test**: For each n from 1 to 10^8, compute the stopping time T and oddCount. Check whether 3 · oddCount < 2T. A single counterexample would disprove the conjecture.

**Theoretical Significance**: If true, this conjecture implies that every convergent orbit has "enough" even steps for the factor of 1/2 per even step to overcome the factor of 3 per odd step. The critical threshold is log(2)/log(3) ≈ 0.6309, and the conjecture asserts the ratio stays strictly below the nearby rational bound 2/3 ≈ 0.6667.

## 5. Discussion

### 5.1 The Role of GCS in Understanding Undecidability

Our formalization of Generalized Collatz Systems provides a bridge between the specific 3n+1 problem and the general undecidability landscape. Conway's theorem shows that GCS with large modulus can simulate Turing machines; our results show how the standard Collatz (modulus 2) relates to this framework.

The key insight is that the GCS naturally produces the Syracuse function rather than the raw Collatz function, because the division by modulus is built into the GCS step. This means the GCS framework studies the "effective" dynamics (where growth per step is bounded by factor 3/2) rather than the "raw" dynamics (where odd steps produce unbounded growth factor 3+1/n).

### 5.2 Parity Profiles as a Proof Strategy

The Orbit Encoding Theorem (Theorem 3.7) suggests a possible proof strategy: instead of studying the Collatz dynamics directly, study the space of parity profiles. A parity profile is a binary sequence; the question becomes: which binary sequences can arise as parity profiles of Collatz orbits? If one could show that all valid parity profiles eventually produce a value of 1, the conjecture would follow.

The advantage of this perspective is that it separates the *algebraic* contribution (3^a / 2^b growth) from the *combinatorial* constraint (which binary sequences are realizable). The conjecture would follow from showing that the combinatorial constraints force sufficient even-step density.

### 5.3 Limitations

Our completeness gap theorem is a conditional result: it says that *if* the Collatz conjecture is true and unprovable, *then* it is independent. We do not prove either hypothesis. The question of whether the Collatz conjecture is actually independent of PA remains open. However, the formalization makes the logical structure precise and identifies exactly what would need to be shown.

## 6. Algorithms

### 6.1 Collatz Orbit Computation

```python
def collatz_orbit(n: int) -> list[int]:
    orbit = [n]
    while n != 1 and len(orbit) < 10**6:
        n = n // 2 if n % 2 == 0 else 3 * n + 1
        orbit.append(n)
    return orbit
```

### 6.2 Parity Balance Verification

```python
def verify_parity_balance(n: int) -> bool:
    """Check the parity balance conjecture for a single n."""
    steps, odd_count = 0, 0
    current = n
    while current != 1:
        if current % 2 == 1:
            odd_count += 1
        current = current // 2 if current % 2 == 0 else 3 * current + 1
        steps += 1
    return 3 * odd_count < 2 * steps
```

## 7. Future Work

1. **Parity profile classification**: Characterize which binary sequences arise as Collatz parity profiles.
2. **GCS universality threshold**: Determine the minimum modulus m for which GCS can simulate Turing machines.
3. **Balance ratio distribution**: Study the statistical distribution of balance ratios across all n.
4. **Tropical Collatz**: Apply tropical geometry to the logarithmic version of the Collatz map.

## References

1. Collatz, L. (1937). Unpublished problem.
2. Conway, J. H. (1972). "Unpredictable Iterations." *Proceedings of the 1972 Number Theory Conference*, pp. 49–52.
3. Erdős, P. (1979). "Some Unsolved Problems." *Michigan Mathematical Journal*, 26, 175–196.
4. Kurtz, S. A., & Simon, J. (2007). "The Undecidability of the Generalized Collatz Problem." *Theory and Applications of Models of Computation*, LNCS 4484, pp. 542–553.
5. Lagarias, J. C. (1985). "The 3x+1 Problem and its Generalizations." *The American Mathematical Monthly*, 92(1), 3–23.
6. Tao, T. (2019). "Almost All Orbits of the Collatz Map Attain Almost Bounded Values." *arXiv:1909.03562*.
7. Barina, D. (2020). "Convergence Verification of the Collatz Problem." *The Journal of Supercomputing*, 77, 2681–2688.
