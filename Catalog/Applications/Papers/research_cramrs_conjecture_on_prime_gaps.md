# Formalized Bounds on Prime Gaps and the Cramér Random Model

## Abstract

We present a formalization of key results in the theory of prime gaps, including a complete proof framework connecting Bertrand's postulate to unconditional gap bounds, a formal definition of the Cramér random model, and the first machine-verified proof that Cramér's conjecture implies sublinear prime gaps via an analytic argument involving the convergence of (log p)²/p to zero. We establish the formal statement of Cramér's conjecture, prove that prime gaps are unbounded using the factorial construction, and demonstrate the cryptographic significance by proving that Cramér's conjecture implies O(k²) worst-case bounds on RSA prime search for k-bit primes. All results are verified in Lean 4 with Mathlib.

## 1. Introduction

The distribution of prime numbers has been a central topic in number theory since antiquity. While the prime number theorem describes their average density, the behavior of *gaps* between consecutive primes remains far less understood.

**Definition 1.1.** For a natural number n, define the *next prime function* nextPrime(n) as the smallest prime strictly greater than n. The *prime gap* at n is primeGap(n) = nextPrime(n) − n.

The study of prime gaps connects classical analytic number theory to modern cryptographic applications, where the efficiency of prime generation algorithms depends critically on gap bounds.

### 1.1 Historical Context

- **Bertrand's Postulate** (1845, proved by Chebyshev 1852): For n ≥ 1, there exists a prime in (n, 2n].
- **Cramér's Conjecture** (1936): There exists C > 0 such that primeGap(p) ≤ C · (log p)² for all primes p.
- **Baker-Harman-Pintz** (2001): primeGap(p) = O(p^{0.525}), the best unconditional bound.
- **Maynard-Tao** (2013): Bounded gaps between primes; infinitely many pairs with gap ≤ 246.

## 2. Definitions

### 2.1 Next Prime Function

```
nextPrime(n) = min { p : ℕ | p > n ∧ p is prime }
```

This is well-defined by the infinitude of primes (Euclid's theorem).

**Properties:**
- nextPrime(n) > n (strict)
- nextPrime(n) is prime
- nextPrime(n) is minimal: if q > n is prime, then nextPrime(n) ≤ q

### 2.2 Cramér Random Model

**Definition 2.1.** A *Cramér random model* is a probability assignment that associates to each integer n ≥ 2 a density function:

```
density(n) = 1 / log(n)    for n ≥ 2
```

This models each integer n as being "prime" independently with probability 1/log(n), matching the prime number theorem's prediction for prime density.

**Key properties:**
- density(n) ≥ 0 for all n
- density(n) → 0 as n → ∞
- density(n) = 1/log(n) for n ≥ 2

### 2.3 Cramér's Conjecture

**Conjecture (Cramér, 1936).** There exists C > 0 such that for all primes p ≥ 2:

```
primeGap(p) ≤ C · (log p)²
```

The *strong form* asserts C = 1 suffices for p ≥ 11.

**Testable Prediction.** For all primes p with 11 ≤ p ≤ B, primeGap(p) ≤ (log p)². This has been verified computationally up to B = 4 × 10¹⁸.

## 3. Main Results

### 3.1 Bertrand-Based Gap Bound

**Theorem 3.1** (nextPrime_le_two_mul). For n ≥ 1, nextPrime(n) ≤ 2n.

*Proof sketch.* By Bertrand's postulate (Nat.bertrand in Mathlib), for n ≥ 1, there exists a prime p with n < p ≤ 2n. Since nextPrime(n) is the minimum such prime, nextPrime(n) ≤ p ≤ 2n. □

**Theorem 3.2** (bertrand_prime_gap_lt). For n ≥ 2, primeGap(n) < n.

*Proof sketch.* From Theorem 3.1, primeGap(n) = nextPrime(n) − n ≤ 2n − n = n. For strict inequality: if primeGap(n) = n, then nextPrime(n) = 2n. Since n ≥ 2, 2n ≥ 4 is even, hence composite—contradicting nextPrime(n) being prime. □

**Corollary 3.3** (prime_gap_lt_self). For any prime p, primeGap(p) < p.

### 3.2 Logarithmic Bounds

**Theorem 3.4** (log_gt_one_of_ge_three). For n ≥ 3, log(n) > 1.

*Proof.* Since n ≥ 3 > e¹ ≈ 2.718..., we have log(n) > log(e) = 1. □

**Theorem 3.5** (log_sq_lt_self). For n ≥ 1, (log n)² < n.

*Proof sketch.* We show log(n) < √n, from which (log n)² < n follows. The key step uses the inequality log(√n/2) ≤ √n/2 − 1 (a consequence of log(x) ≤ x − 1 for x > 0) and numerical bounds on log 2. □

This theorem demonstrates that Cramér's conjecture is strictly stronger than Bertrand's postulate: if gaps are bounded by (log p)², they are a fortiori bounded by p.

### 3.3 Cramér Implies Sublinear Gaps

**Theorem 3.6** (cramer_bound_sublinear). If Cramér's conjecture holds, then for any ε > 0, there exists N such that primeGap(p) ≤ ε · p for all primes p ≥ N.

*Proof sketch.* Under Cramér's conjecture with constant C, we need C · (log p)² ≤ ε · p, equivalently (log p)²/p ≤ ε/C. The key analytic step is showing:

```
lim_{p→∞} (log p)² / p = 0
```

This is established by the substitution y = log(x), reducing to lim_{y→∞} y²/e^y = 0, which follows from the classical result that exponentials dominate polynomials (Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero in Mathlib). □

This is the deepest proof in the formalization, requiring filter-based limit theory and the connection between logarithmic and exponential asymptotics.

### 3.4 Unboundedness of Prime Gaps

**Theorem 3.7** (arbitrarily_large_prime_gaps). For every k, there exists a prime n with primeGap(n) ≥ k.

*Proof sketch.* Consider the (k+1) consecutive integers (k+1)! + 2, (k+1)! + 3, ..., (k+1)! + (k+1). For 2 ≤ j ≤ k+1, j divides (k+1)!, hence j divides (k+1)! + j, making it composite. The largest prime p ≤ (k+1)! + 1 must have nextPrime(p) > (k+1)! + (k+1), giving primeGap(p) ≥ k. □

### 3.5 Cramér-RSA Bridge

**Theorem 3.8** (cramer_rsa_bridge). If Cramér's conjecture holds, then there exists C' > 0 such that for k ≥ 10 and any k-bit prime p (i.e., 2^k ≤ p < 2^{k+1}), primeGap(p) ≤ C' · k².

*Proof sketch.* For a k-bit number p < 2^{k+1}, log(p) ≤ (k+1) · log(2). For k ≥ 10, (k+1) ≤ 2k, so log(p) ≤ 2k · log(2). Under Cramér with constant C, primeGap(p) ≤ C · (log p)² ≤ C · (2k · log 2)² = 4C · (log 2)² · k². Take C' = 4C · (log 2)². □

## 4. Algorithms

### 4.1 Next Prime Search

```python
def next_prime(n):
    """Find the smallest prime > n."""
    candidate = n + 1
    while not is_prime(candidate):
        candidate += 1
    return candidate
```

Under Cramér's conjecture, this terminates within O((log n)²) iterations.

### 4.2 RSA Key Generation

```python
def generate_rsa_prime(k):
    """Generate a random k-bit prime."""
    while True:
        n = random_odd_k_bit_number(k)
        if is_prime(n):
            return n
```

Expected iterations: O(k) by PNT. Worst case under Cramér: O(k²).

## 5. Cryptographic Applications

The connection between prime gaps and cryptography operates through several channels:

1. **Key generation efficiency**: Bounded prime gaps ensure that prime search algorithms terminate efficiently.

2. **Timing side-channels**: If prime gaps were unpredictably large, RSA key generation could leak timing information.

3. **Provable security**: Several cryptographic proofs assume efficient prime generation; Cramér's conjecture provides the strongest such guarantee.

4. **Post-quantum considerations**: Lattice-based cryptography uses prime moduli; gap bounds inform modulus selection.

## 6. The Cramér Model as Heuristic

The Cramér model's success lies in its simplicity: model primes as independent events with the correct marginal density. While real primes exhibit significant local dependencies (e.g., no two consecutive primes past 2-3, divisibility patterns modulo small primes), these dependencies appear to cancel out at the scale of maximum gaps.

However, Granville (1995) observed that the Cramér model's predictions may need refinement. He proposed that the correct asymptotic should be:

```
max gap ~ 2e^{-γ} (log p)² ≈ 1.1229... (log p)²
```

where γ is the Euler-Mascheroni constant. This correction accounts for the Hardy-Littlewood prime tuple conjecture, which creates a subtle bias in prime distribution that the simple Cramér model misses.

## 7. Future Work

1. **Conditional bounds**: Formalize the implication from the Riemann hypothesis to O(√p · log p) gap bounds (Cramér, 1936).

2. **Granville's refinement**: Formalize the Granville correction factor 2e^{−γ}.

3. **Maier's theorem**: Formalize the result that primes are *not* uniformly distributed in short intervals, providing a counterpoint to Cramér's model.

4. **Baker-Harman-Pintz**: Formalize the unconditional O(p^{0.525}) bound, the strongest known result.

5. **Large gap constructions**: Formalize the Ford-Green-Konyagin-Maynard-Tao result on large prime gaps.

## 8. Summary of Formalized Results

| Theorem | Statement | Status |
|---------|-----------|--------|
| nextPrime_gt | nextPrime(n) > n | ✓ Proved |
| nextPrime_prime | nextPrime(n) is prime | ✓ Proved |
| nextPrime_least | nextPrime is minimal | ✓ Proved |
| primeGap_pos | primeGap(n) ≥ 1 | ✓ Proved |
| nextPrime_le_two_mul | nextPrime(n) ≤ 2n for n ≥ 1 | ✓ Proved |
| bertrand_prime_gap_lt | primeGap(n) < n for n ≥ 2 | ✓ Proved |
| prime_gap_lt_self | primeGap(p) < p for prime p | ✓ Proved |
| cramerModel | Standard model construction | ✓ Proved |
| log_gt_one_of_ge_three | log(n) > 1 for n ≥ 3 | ✓ Proved |
| log_sq_lt_self | (log n)² < n for n ≥ 1 | ✓ Proved |
| cramer_bound_sublinear | Cramér ⟹ sublinear gaps | ✓ Proved |
| arbitrarily_large_prime_gaps | Gaps are unbounded | ✓ Proved |
| log2_pow_eq | log₂(2^k) = k | ✓ Proved |
| cramer_rsa_bridge | Cramér ⟹ O(k²) RSA search | ✓ Proved |

All 14 theorems verified with no `sorry` and no non-standard axioms.

## References

1. Cramér, H. (1936). "On the order of magnitude of the difference between consecutive prime numbers." *Acta Arithmetica*, 2(1), 23–46.

2. Baker, R. C., Harman, G., & Pintz, J. (2001). "The difference between consecutive primes, II." *Proceedings of the London Mathematical Society*, 83(3), 532–562.

3. Granville, A. (1995). "Harald Cramér and the distribution of prime numbers." *Scandinavian Actuarial Journal*, 1995(1), 12–28.

4. Ford, K., Green, B., Konyagin, S., Maynard, J., & Tao, T. (2018). "Long gaps between primes." *Journal of the American Mathematical Society*, 31(1), 65–105.

5. Oliveira e Silva, T., Herzog, S., & Pardi, S. (2014). "Empirical verification of the even Goldbach conjecture and computation of prime gaps up to 4·10^18." *Mathematics of Computation*, 83(288), 2033–2060.

6. Maynard, J. (2015). "Small gaps between primes." *Annals of Mathematics*, 181(1), 383–413.
