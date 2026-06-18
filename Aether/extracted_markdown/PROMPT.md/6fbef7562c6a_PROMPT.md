Formalize the strong divisibility property of Fibonacci numbers in a single self-contained Lean 4 file.

## Target Theorem

The main theorem is:

`theorem fib_gcd (m n : ℕ) : Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n)`

## Required Intermediate Results

1. **Divisibility lemma**: If m | n, then F_m | F_n. Prove this first as:
   `theorem fib_dvd_of_dvd {m n : ℕ} (h : m ∣ n) : (Nat.fib m) ∣ (Nat.fib n)`
   Strategy: Use induction on n/m, leveraging the identity F_{m*(k+1)} can be expressed in terms of F_{m*k} and F_m via Lucas sequences or matrix exponentiation.

2. **Strong divisibility**: The gcd property follows from (1) plus the observation that any common divisor of F_m and F_n also divides F(gcd(m,n)).

## Proof Strategy

- For fib_dvd_of_dvd: Use the fact that the matrix [[1,1],[1,0]]^n = [[F_{n+1}, F_n],[F_n, F_{n-1}]]. Then F_m | F_{m*k} follows by matrix multiplication properties. Alternatively, use the identity F_{a+b} = F_a * F_{b+1} + F_{a-1} * F_b and induction.
- For the gcd theorem: Use the fact that {F_n} is a strong divisibility sequence. Since gcd(F_m, F_n) divides both F_m and F_n, and F_m | F_{gcd(m,n)} * k for appropriate k, the result follows.

## Constraints

- Import only from Mathlib (no custom catalog files)
- No `sorry` in final theorem statements
- No unrelated commented-out stubs from other domains
- All auxiliary lemmas must have complete proofs
- Use Nat.fib from Mathlib
- The file must compile without errors

## File Location

Catalog/NumberTheory/FibonacciStrongDivisibility.lean