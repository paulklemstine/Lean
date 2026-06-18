# Summary of changes for run 3dc7ed22-840a-407f-85d9-e76888f6f855
# Research Brief & Formalization: Carmichael's Primitive Divisor Theorem

## Deliverables Created

### 1. Research Report (`RESEARCH_REPORT.md`)
A detailed mathematical report covering:
- Background on Carmichael's theorem and entry point theory
- **Critical finding**: The proposed growth bound F(n) > ∏ F(d) over proper divisors is **FALSE** for n = 24, 30, 36, 40, 42, 48, 54, ... (computationally verified). This means the proof strategy outlined in the original brief is fundamentally flawed.
- The correct approach via cyclotomic Fibonacci polynomials and the Lifting the Exponent Lemma
- Current formalization status and recommended strategy

### 2. Discussion (`DISCUSSION.md`)
A Scientific American-style article explaining Carmichael's theorem, entry points, and the formalization challenge.

### 3. Demo (`demo.py`)
Python script demonstrating:
- Computational verification of Carmichael's theorem for n up to 60
- Entry point structure of small primes
- The GCD identity gcd(F(m), F(n)) = F(gcd(m,n))
- Concrete proof that the growth bound fails for highly composite numbers
- The correct primitive part formulation F*(n) = F(n)/gcd(F(n), lcm{F(d)}) > 1

### 4. Diagram (`diagram.svg`)
Architectural diagram showing the proof structure, the prime vs composite case split, and the two main approaches (cyclotomic and LTE).

### 5. Formal Lean 4 Proofs (`Shared/CarmichaelEvenPrimeCase.lean`)
A **sorry-free** Lean 4 file with 5 fully verified theorems:

- **`gcd_fib_lucas_dvd_two`**: gcd(F(m), L(m)) divides 2, where L(m) = 2·F(m+1) − F(m) is the Lucas number
- **`lucas_gt_two`**: L(m) > 2 for m ≥ 4
- **`fib_primitive_divisor_twice_prime`**: For p odd prime ≥ 7, F(2p) has a primitive prime divisor (a key special case of Carmichael's composite case)
- **`fib_super_mult`**: F(a+b) ≥ F(a)·F(b) for a, b ≥ 1 (Fibonacci super-multiplicativity)
- **`fib_strict_super_mult`**: F(a·b) > F(a)·F(b) for a, b ≥ 2 (strict super-multiplicativity)

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

## Key Mathematical Insight

The proof of `fib_primitive_divisor_twice_prime` uses an elegant argument:
1. F(2p) = F(p) · L(p) where L(p) = 2·F(p+1) − F(p)
2. Since p ≥ 7 is prime with p ≠ 3, we show F(2p) is odd (via gcd/entry-point theory)
3. Therefore L(p) is odd, and since L(p) > 2, it has an odd prime factor q
4. By gcd(F(p), L(p)) | 2 and q odd, we get q ∤ F(p)
5. Since the only proper divisors of 2p are {1, 2, p}, and q cannot divide F(1)=F(2)=1 or F(p), any occurrence of q in F(k) for 0 < k < 2p would force q | F(gcd(2p,k)) with gcd(2p,k) ∈ {1, 2, p} — all contradictions.

## Status of Original Sorries

The 8 sorry placeholders in the existing Carmichael files all require the **full composite case** of Carmichael's theorem, which remains an open formalization challenge. The composite case requires either:
- Cyclotomic Fibonacci polynomial theory (showing Φ_n > 1 for n ≥ 13)
- The Lifting the Exponent Lemma for Fibonacci sequences
- Both are substantial formalizations not currently in Mathlib

The new file provides foundational infrastructure (the n = 2p special case and helper lemmas) that would be building blocks for any eventual complete proof.