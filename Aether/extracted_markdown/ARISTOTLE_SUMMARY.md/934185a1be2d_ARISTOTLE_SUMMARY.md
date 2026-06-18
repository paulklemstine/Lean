# Summary of changes for run 56877ab7-984f-498d-92db-fcfd2a1829c7
## Carmichael's Primitive Divisor Theorem — Formalization Progress

### What was accomplished

I substantially advanced the formalization of Carmichael's Primitive Divisor Theorem in `Speculative/CarmichaelPrimitiveDivisor.lean`. The theorem states: for n ≥ 13, F(n) has a **primitive prime divisor** — a prime p dividing F(n) that does not divide F(k) for any 0 < k < n.

### Fully proved theorems (9 lemmas/theorems)

1. **`fib_prime_dvd_gcd'`** — If p | F(n) and p | F(k), then p | F(gcd(n,k))
2. **`fib_gt_one`** — F(n) > 1 for n ≥ 3
3. **`fib_has_prime_factor'`** — F(n) has a prime factor for n ≥ 3
4. **`non_primitive_to_proper_divisor`** — Non-primitive primes reduce to proper divisors
5. **`bridge_lemma`** — Reduces checking all k to checking only divisors of n
6. **`fib_primitive_divisor_prime`** — For prime n ≥ 13, any prime factor of F(n) is primitive
7. **`stripAllAux_dvd`**, **`stripAllAux_coprime`**, **`primPart_dvd`** — Correctness of the primitive part computation
8. **`primPart_implies_primitive`** — If primPart(n) > 1, then F(n) has a primitive divisor
9. **`primPart_check`** — Computational verification via `native_decide` for n ∈ [13, 10000]

### Main theorem status

`fib_primitive_divisor` is proved for two of three cases:
- ✅ **Prime n ≥ 13**: Clean proof using GCD identity and primality
- ✅ **Composite n ∈ [13, 10000]**: Computationally verified via `native_decide`
- ⬜ **Composite n > 10000**: One `sorry` remains — requires the Lifting-the-Exponent Lemma for Fibonacci numbers (not in Mathlib)

The mathematical argument for the tail case is well-understood (Φ(n) ≈ φ^{φ(n)} > 1 for φ(n) ≥ 6), and computational verification confirms it up to n = 100,000. A complete formalization would require building the LTE for Fibonacci sequences from scratch.

### Deliverables created
- `Speculative/CarmichaelPrimitiveDivisor.lean` — Main Lean file with proofs
- `RESEARCH_REPORT.md` — Technical report on the formalization
- `DISCUSSION.md` — Scientific American-style explanation
- `demo.py` — Python demonstration with numerical examples
- `diagram.svg` — Visual diagram of the proof structure