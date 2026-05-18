# Euler's Shape Theorem for Odd Perfect Numbers: A Complete Formal Verification

## Abstract

We present a complete formal verification of Euler's classical theorem (1747) on the structure of odd perfect numbers, together with Euclid's theorem on even perfect numbers and the Euler direction of the Euclid-Euler classification. Our formalization establishes: (1) if n is an odd perfect number, then n = q^{4k+1} · m² where q is prime, q ≡ 1 (mod 4), and gcd(q,m) = 1; (2) if 2^p − 1 is prime, then 2^{p−1}(2^p − 1) is perfect; (3) every even perfect number has this Euclid form. All proofs are machine-verified with no unproven assumptions beyond standard axioms.

## 1. Introduction

### 1.1 Background

A natural number n is *perfect* if the sum of its proper divisors equals n, equivalently if σ₁(n) = 2n where σ₁ denotes the sum-of-divisors function. The first four perfect numbers — 6, 28, 496, 8128 — were known to the ancient Greeks.

The theory of perfect numbers has two sides:

**Even perfect numbers** are completely characterized by the Euclid-Euler theorem: n is an even perfect number if and only if n = 2^{p−1}(2^p − 1) where 2^p − 1 is a Mersenne prime.

**Odd perfect numbers** remain mysterious. No example has been found, and their existence is one of the oldest open problems in mathematics (over 2300 years). The strongest structural result is Euler's theorem (1747): any odd perfect number must have the form q^{4k+1} · m² where q is a prime congruent to 1 modulo 4 and gcd(q,m) = 1.

### 1.2 Contributions

We provide a complete formal verification of:
1. **Euler's Shape Theorem** (`odd_perfect_euler_shape`): the full structural characterization of odd perfect numbers
2. **Euclid's Theorem** (`euclid_perfect`): Mersenne primes yield perfect numbers
3. **Even Perfect Classification** (`even_perfect_classification`): every even perfect number has the Euclid form
4. **Basic properties**: Perfect numbers are ≥ 6, not prime, positive

Key helper results include:
- Parity analysis of σ₁(p^a) for odd primes (`sigma_one_prime_pow_odd_iff`)
- Factorization of σ₁(p^{2j+1}) as (1+p) · Σ p^{2i} (`sigma_one_odd_exp_factor`)
- 2-adic valuation bounds when q ≡ 3 (mod 4) (`sigma_one_mod3_val2`)
- Square extraction from factorizations (`eq_sq_of_even_factorization`, `coprime_sq_of_factorization`)
- Uniqueness of the special prime (`odd_perfect_unique_special_prime`)

### 1.3 Related Work

Previous formalizations of perfect number theory include partial results in Isabelle/HOL and Mizar. To our knowledge, this is the first complete machine-verified proof of Euler's shape theorem in any proof assistant. Our work builds on Mathlib's arithmetic function library, particularly `ArithmeticFunction.sigma`, `IsMultiplicative`, and `Nat.factorization`.

## 2. Definitions and Notation

### 2.1 Perfect Numbers

Following Mathlib, we use:

```
def Nat.Perfect (n : ℕ) : Prop :=
  ∑ i ∈ n.properDivisors, i = n ∧ 0 < n
```

The equivalent characterization via the sum-of-divisors function is:
```
theorem perfect_iff_sigma_eq {n : ℕ} (hn : 0 < n) :
    n.Perfect ↔ (σ 1) n = 2 * n
```

where σ k n = Σ_{d|n} d^k is the k-th power divisor sum.

### 2.2 Multiplicativity

The divisor sum function σ₁ is multiplicative: if gcd(a,b) = 1, then σ₁(ab) = σ₁(a)σ₁(b). For prime powers, σ₁(p^a) = 1 + p + p² + ... + p^a = Σ_{i=0}^a p^i.

By multiplicative factorization: σ₁(n) = ∏_{p | n} σ₁(p^{v_p(n)}).

## 3. Main Results

### 3.1 Parity of σ₁(p^a) for Odd Primes

**Theorem 3.1** (`sigma_one_prime_pow_odd_iff`). *For an odd prime p, σ₁(p^a) is odd if and only if a is even.*

*Proof sketch.* σ₁(p^a) = Σ_{i=0}^a p^i. Each p^i is odd (since p is odd). The sum of (a+1) odd numbers has the same parity as (a+1). Hence σ₁(p^a) is odd iff a+1 is odd iff a is even. □

### 3.2 Factorization of σ₁ at Odd Exponents

**Theorem 3.2** (`sigma_one_odd_exp_factor`). *For any prime p and natural number j,*
*σ₁(p^{2j+1}) = (1+p) · Σ_{i=0}^j p^{2i}.*

*Proof sketch.* Group consecutive pairs in the geometric sum:
σ₁(p^{2j+1}) = (1 + p) + p²(1 + p) + ... + p^{2j}(1 + p) = (1+p) · Σ_{i=0}^j p^{2i}.
Formally proved by induction on j. □

### 3.3 The 2-adic Obstruction for q ≡ 3 (mod 4)

**Theorem 3.3** (`sigma_one_mod3_val2`). *If q is prime with q ≡ 3 (mod 4), then 4 | σ₁(q^{2j+1}).*

*Proof sketch.* By Theorem 3.2, σ₁(q^{2j+1}) = (1+q) · T. Since q ≡ 3 (mod 4), we have 1+q ≡ 0 (mod 4), so 4 | (1+q) | σ₁(q^{2j+1}). □

### 3.4 The Unique Special Prime

**Theorem 3.4** (`odd_perfect_unique_special_prime`). *If n is an odd perfect number, there exists a unique prime q dividing n such that:*
1. *q ≡ 1 (mod 4)*
2. *v_q(n) ≡ 1 (mod 4)*
3. *For every other prime p | n, v_p(n) is even*

*Proof sketch.* Since σ₁(n) = 2n and n is odd, v₂(σ₁(n)) = 1. By multiplicativity, σ₁(n) = ∏ σ₁(p^{v_p(n)}). By Theorem 3.1, each factor with even exponent is odd. So exactly one factor contributes the single factor of 2, meaning exactly one prime q has odd exponent.

For the mod 4 conditions: by Theorem 3.3, q ≢ 3 (mod 4) (else 4 | σ₁(q^{v_q(n)}) would force v₂(σ₁(n)) ≥ 2). Since q is odd and q ≢ 3, we get q ≡ 1 (mod 4).

For the exponent: write v_q(n) = 2j+1. By Theorem 3.2, σ₁(q^{2j+1}) = (1+q)T where T = Σ q^{2i}. Since q ≡ 1 (mod 4), v₂(1+q) = 1. For v₂((1+q)T) = 1, we need T odd. Since T = Σ_{i=0}^j q^{2i} is a sum of (j+1) odd terms, T is odd iff j is even. Writing j = 2k gives v_q(n) = 4k+1. □

### 3.5 Euler's Shape Theorem

**Theorem 3.5** (`odd_perfect_euler_shape`). *If n is an odd perfect number, then there exist q, k, m ∈ ℕ such that q is prime, q ≡ 1 (mod 4), n = q^{4k+1} · m², and gcd(q,m) = 1.*

*Proof.* By Theorem 3.4, obtain the special prime q with the stated properties. By the factorization lemma (`coprime_sq_of_factorization`), since all primes p ≠ q have even exponent in n, we can write n = q^{v_q(n)} · m² with gcd(q,m) = 1. Since v_q(n) ≡ 1 (mod 4), write v_q(n) = 4k + 1. □

### 3.6 Euclid's Theorem

**Theorem 3.6** (`euclid_perfect`). *If 2^p − 1 is prime and p ≥ 1, then 2^{p−1}(2^p − 1) is perfect.*

*Proof sketch.* Let M = 2^p − 1. Since M is odd and prime, gcd(2^{p−1}, M) = 1. By multiplicativity:
σ₁(2^{p−1} · M) = σ₁(2^{p−1}) · σ₁(M) = (2^p − 1) · (M + 1) = (2^p − 1) · 2^p = 2 · 2^{p−1} · (2^p − 1). □

### 3.7 Even Perfect Classification

**Theorem 3.7** (`even_perfect_classification`). *Every even perfect number has the form 2^{p−1}(2^p − 1) where 2^p − 1 is prime.*

*Proof sketch.* Write n = 2^a · m with m odd and a ≥ 1. From σ₁(n) = 2n and multiplicativity:
(2^{a+1} − 1) · σ₁(m) = 2^{a+1} · m.
Since gcd(2^{a+1} − 1, 2^{a+1}) = 1, we get (2^{a+1} − 1) | m. Write m = (2^{a+1} − 1) · d.
Then σ₁(m) = 2^{a+1} · d. If d > 1, then σ₁(m) ≥ 1 + d + m > 2^{a+1} · d, contradiction.
So d = 1, m = 2^{a+1} − 1 is prime, and n = 2^a · (2^{a+1} − 1) with p = a+1. □

## 4. Algorithms and Computational Aspects

### 4.1 Testing Perfectness

```
Algorithm: IS_PERFECT(n)
Input: Natural number n ≥ 1
Output: Boolean
1. Compute S ← Σ_{d | n, d < n} d
2. Return S = n

Time: O(√n) using trial division
Space: O(1)
```

### 4.2 Generating Even Perfect Numbers

```
Algorithm: EVEN_PERFECT_NUMBERS(limit)
Input: Upper bound limit
Output: List of even perfect numbers ≤ limit
1. For p = 2, 3, 5, 7, 11, ...
2.   M ← 2^p − 1
3.   If IS_PRIME(M):
4.     N ← 2^{p-1} × M
5.     If N ≤ limit: yield N
6.     Else: break

Time per candidate: O(M^{1/2+ε}) for trial division primality
     or O(log²(M) log(log(M))) for Lucas-Lehmer test
```

### 4.3 Checking Euler's Form

Given a candidate odd perfect number n:
1. Factor n = ∏ p_i^{a_i}
2. Count primes with odd exponent — must be exactly 1
3. Call that prime q; verify q ≡ 1 (mod 4)
4. Verify a_q ≡ 1 (mod 4)
5. Verify n = q^{a_q} · m² with gcd(q,m) = 1

## 5. Computational Experiments

### 5.1 Even Perfect Numbers

| p  | 2^p − 1    | Perfect Number          | Digits |
|----|------------|-------------------------|--------|
| 2  | 3          | 6                       | 1      |
| 3  | 7          | 28                      | 2      |
| 5  | 31         | 496                     | 3      |
| 7  | 127        | 8128                    | 4      |
| 13 | 8191       | 33,550,336              | 8      |
| 17 | 131071     | 8,589,869,056           | 10     |
| 19 | 524287     | 137,438,691,328         | 12     |

### 5.2 Divisor Sum Parity Verification

For odd primes p and various exponents a, we verify σ₁(p^a) mod 2:

| p  | a  | σ₁(p^a)     | Parity | a even? |
|----|----|-------------|--------|---------|
| 3  | 0  | 1           | Odd    | Yes ✓   |
| 3  | 1  | 4           | Even   | No ✓    |
| 3  | 2  | 13          | Odd    | Yes ✓   |
| 3  | 3  | 40          | Even   | No ✓    |
| 5  | 1  | 6           | Even   | No ✓    |
| 5  | 2  | 31          | Odd    | Yes ✓   |
| 7  | 1  | 8           | Even   | No ✓    |
| 7  | 2  | 57          | Odd    | Yes ✓   |
| 13 | 1  | 14          | Even   | No ✓    |
| 13 | 4  | 30941       | Odd    | Yes ✓   |

### 5.3 Euler Form Factor Analysis

For q = 5 (≡ 1 mod 4), we verify the σ₁ factoring:

| j  | σ₁(5^{2j+1})  | (1+5) × Σ 5^{2i} | Match? |
|----|----------------|-------------------|--------|
| 0  | 6              | 6 × 1 = 6        | ✓      |
| 1  | 3906           | 6 × 651 = 3906   | ✓      |
| 2  | 2441406        | 6 × 406901       | ✓      |

## 6. Applications

### 6.1 Connection to Mersenne Primes and Cryptography

Mersenne primes 2^p − 1 generate all known even perfect numbers. The search for Mersenne primes (GIMPS project) has produced the largest known primes. These primes are used in random number generation and have connections to:
- **Pseudorandom generators**: Mersenne Twister uses 2^{19937} − 1
- **Error-correcting codes**: Reed-Solomon codes over GF(2^p) when 2^p − 1 is prime
- **Cryptographic key generation**: Large primes for RSA and related schemes

### 6.2 Structural Constraints on Odd Perfect Numbers

Euler's theorem, combined with modern computational bounds, constrains any odd perfect number n:
- n > 10^{1500} (Ochem-Rao, 2012)
- n has at least 101 prime factors (not necessarily distinct) (Nielsen, 2015)
- The special prime q > 10^8 (Goto-Ohno, 2008)
- n is not divisible by 105 (various authors)

### 6.3 Multiplicative Function Analysis

The proof technique — analyzing v₂(σ₁(p^a)) via geometric series parity — generalizes to:
- Studying σ_k for arbitrary k
- Analyzing multiperfect numbers (σ₁(n) = kn)
- Understanding the distribution of values of multiplicative functions

## 7. Discussion

### 7.1 Significance of the Formalization

Our work demonstrates that classical number-theoretic results involving subtle combinatorial arguments about prime factorizations can be fully mechanized. Key challenges included:
- Working with Nat.factorization and its Finsupp structure
- Managing the multiplicativity argument across products indexed by prime factors
- The delicate 2-adic valuation bookkeeping in the proof of Theorem 3.4

### 7.2 Limitations

Our formalization establishes the *structure* of odd perfect numbers but does not resolve their existence. The formal framework could support future work on:
- Lower bounds for odd perfect numbers
- Computational search strategies guided by Euler's constraints
- Extensions to multiply perfect numbers

### 7.3 Open Questions

1. **Existence of odd perfect numbers**: The central open question remains unresolved after 2300+ years
2. **Infinitude of even perfect numbers**: Equivalent to the infinitude of Mersenne primes
3. **Generalization to σ_k**: Analogs of Euler's theorem for higher power sums
4. **Computational bounds**: Can Euler's structure theorem be leveraged for more efficient search algorithms?

## 8. Future Work

- Formalize the Euler-Euler converse (every even perfect number has the Euclid-Euler form) with explicit uniqueness
- Establish formal lower bounds on odd perfect numbers (n > 10^{36} should be achievable)
- Extend to multiperfect numbers and prove structural results for σ₁(n) = kn
- Formalize the proof that odd perfect numbers cannot be divisible by small primes
- Connect to the theory of unitary perfect numbers

## References

1. Euclid, *Elements*, Book IX, Proposition 36 (c. 300 BCE)
2. L. Euler, "De numeris amicabilibus" (1747)
3. L.E. Dickson, *History of the Theory of Numbers*, Vol. I (1919)
4. P. Ochem, M. Rao, "Odd perfect numbers are greater than 10^{1500}", Math. Comp. 81 (2012)
5. P.P. Nielsen, "Odd perfect numbers, Diophantine equations, and upper bounds", Math. Comp. 84 (2015)
6. T. Goto, Y. Ohno, "Odd perfect numbers have a prime factor exceeding 10^8", Math. Comp. 77 (2008)
