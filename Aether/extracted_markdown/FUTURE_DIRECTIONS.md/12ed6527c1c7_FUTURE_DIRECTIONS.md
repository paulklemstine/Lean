# Future Directions

## 1. Closing the Remaining Sorry

### Priority: HIGH

The single remaining sorry is `fib_carmichael_large` — proving that every composite n > 100,000 has a primitive prime divisor. Three approaches are worth pursuing:

#### Approach A: Cyclotomic Fibonacci Factors
Define Φ_n = ∏_{d|n} F(d)^{μ(n/d)} and prove:
1. Φ_n is a positive integer for all n ≥ 1
2. F(n) = ∏_{d|n} Φ_d
3. |Φ_n| ≥ φ^{φ(n) - C·2^{ω(n)}} for an explicit constant C
4. For composite n > 100000, this exceeds n, giving Φ_n/gcd(Φ_n, n) > 1

**Prerequisites:** Formalization of the Möbius function, multiplicative arithmetic functions, and basic analytic bounds on the golden ratio.

#### Approach B: Extend Computational Verification
Push `native_decide` to n = 500,000 or beyond by:
- Using more efficient GCD algorithms
- Parallelizing the verification across multiple lemmas
- Optimizing `fibCoprimePart` using modular arithmetic

This reduces the threshold where the growth argument needs to kick in.

#### Approach C: Direct Lucas Number Argument
For composite n = 2m with m prime > 50,000:
- F(2m) = F(m) · L(m) where L(m) = F(m-1) + F(m+1)
- gcd(F(m), L(m)) | 2
- Any odd prime factor of L(m) coprime to F(m) has entry point 2m

This handles the semiprime case cleanly. Extending to general composite n requires handling divisors of 2m beyond just m.

## 2. Extensions of Carmichael's Theorem

### 2.1 Lucas Sequences
Generalize to Lucas sequences U_n(P, Q) defined by U_0 = 0, U_1 = 1, U_{n+2} = P·U_{n+1} - Q·U_n. Carmichael's theorem generalizes: for n sufficiently large, U_n(P,Q) has a primitive prime divisor. The formal statement and proof would build on our Fibonacci infrastructure.

### 2.2 Quantitative Bounds
Prove quantitative lower bounds on the number or size of primitive prime divisors. For example, the primitive part Φ_n satisfies Φ_n ≥ φ^{φ(n)}/C, giving a lower bound that grows exponentially.

### 2.3 Wall-Sun-Sun Primes
Investigate the connection to Wall-Sun-Sun primes (primes p with p² | F(p - (p/5))). No such primes are known, and their existence is related to the structure of Fibonacci entry points.

## 3. Cross-Domain Connections

### 3.1 Algebraic Number Theory
The entry point z(p) divides p - (5/p) where (5/p) is the Legendre symbol. This connects to the splitting behavior of p in ℤ[φ]. Formalizing this connection would bridge our work with Mathlib's algebraic number theory library.

### 3.2 Elliptic Curve Analogues
The Fibonacci sequence can be viewed as the "x-coordinate sequence" of multiples of a point on a degenerate elliptic curve. Primitive divisor theorems for elliptic divisibility sequences (proved by Silverman) generalize Carmichael's theorem. Formalizing these would be a significant contribution.

### 3.3 p-adic Analysis
The Lifting-the-Exponent Lemma (LTE) for Fibonacci, used implicitly in our growth bounds, connects to p-adic analysis of Lucas sequences. Formalizing LTE for Fibonacci would be independently valuable.

## 4. Computational Extensions

### 4.1 Efficient Primitive Divisor Finding
Implement a verified efficient algorithm for finding primitive divisors, using:
- The Pisano period π(p) to compute entry points
- Fast matrix exponentiation for Fibonacci mod p
- Number field sieve for factoring large Fibonacci numbers

### 4.2 Fibonacci Factorization Database
Build a verified database of Fibonacci factorizations, connected to existing computational results (the Fibonacci factorization tables go up to n ≈ 10000).

## 5. Open Problems Encountered

1. **Stack overflow in native_decide:** For very large ranges, `native_decide` causes stack overflow. A workaround is batching, but better infrastructure for large-scale decidable proofs would help.

2. **Missing Mathlib infrastructure:** The formal proof of the infinite case requires:
   - Multiplicative arithmetic functions (Möbius, totient) — partially available
   - Bounds on φ^n for the golden ratio — need formalization
   - Cyclotomic polynomial analogues for Fibonacci — not in Mathlib

3. **Efficient big-number GCD in Lean:** The `native_decide` performance for large Fibonacci numbers (20,000+ digits) depends on the efficiency of GMP-backed natural number arithmetic. Performance could potentially be improved.

## 6. Recommended Next Steps

1. **Immediate:** Close `fib_carmichael_large` using Approach A (cyclotomic factors), building the needed Mathlib infrastructure as helper lemmas
2. **Short-term:** Formalize the Lifting-the-Exponent Lemma for Fibonacci as a standalone contribution
3. **Medium-term:** Extend to general Lucas sequences U_n(P, Q)
4. **Long-term:** Connect to elliptic divisibility sequences and Silverman's primitive divisor theorem
