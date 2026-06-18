# Summary of changes for run d377bfb6-2463-4077-93fe-3107daf4cefc
## Carmichael's Primitive Divisor Theorem — Partial Formalization

### Lean File (`Speculative/CarmichaelPrimitiveDivisor.lean`)

The file contains 5 fully proved lemmas and the main theorem statement with partial progress:

**Fully proved:**
1. `fib_prime_dvd_gcd'` — If p | F(n) and p | F(k), then p | F(gcd(n,k))
2. `fib_gt_one` — F(n) > 1 for n ≥ 3
3. `fib_has_prime_factor'` — F(n) has a prime factor for n ≥ 3
4. `non_primitive_to_proper_divisor` — Non-primitive primes relate to proper divisors
5. `fib_primitive_divisor_prime_index` (**new**) — For prime n ≥ 3, every prime factor of F(n) is primitive

**Main theorem (`fib_primitive_divisor`):**
- **Prime case: PROVED** — Uses the GCD identity: for prime n, gcd(n,k) = 1 for 0 < k < n, so any prime factor of fib(n) must be primitive since p | fib(gcd(n,k)) = fib(1) = 1 is impossible.
- **Composite case: remains as `sorry`** — This requires the full Carmichael theory (Fibonacci entry points, lifting-the-exponent lemma, primitive part bounds), none of which currently exist in Mathlib. This is a substantial formalization project in its own right.

### Sorry Count
1 sorry remains (same as original), but the proof now handles all prime indices — covering infinitely many values of n ≥ 13.

### Additional Deliverables
- `RESEARCH_REPORT.md` — Technical report on the formalization status and mathematical background
- `demo.py` — Python script demonstrating the theorem with concrete examples (verified for n = 13 to 50)
- `diagram.svg` — Visual summary of the theorem, exceptions, and proof structure
- `DISCUSSION.md` — Accessible explanation of the theorem's significance

### Why the Composite Case Is Hard
Carmichael's theorem for composite n requires showing that the "primitive part" Ψ_n (the product of primes whose entry point is exactly n) is > 1 for n ≥ 13. This needs:
- A theory of Fibonacci entry points (smallest m > 0 with p | F(m))
- The lifting-the-exponent lemma relating v_p(F(kd)) to v_p(F(d)) + v_p(k)
- Growth bounds on the primitive part using cyclotomic-like factorizations of Fibonacci numbers

None of this infrastructure exists in Mathlib, and building it would be a significant project equivalent to several hundred lines of new mathematical library code.