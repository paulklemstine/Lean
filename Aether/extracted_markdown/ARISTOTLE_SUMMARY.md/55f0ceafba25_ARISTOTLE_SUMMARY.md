# Summary of changes for run 2ca3c6e8-9726-46fb-ae62-8ad9696e1452
## Carmichael's Primitive Divisor Theorem — Partial Formalization

I worked on proving the theorem `fib_composite_has_primitive` in `RequestProject/CarmichaelComputational.lean`, which states that for every composite `n ≥ 13`, the Fibonacci number `fib(n)` has a prime divisor that does not divide any earlier Fibonacci number.

### What was accomplished

The proof is **complete modulo one sorry** (`primPart_gt_one_large`). Here is the full structure:

1. **Bridge lemma** (`fib_primitive_of_proper_divisors`) — ✅ Proved  
   Uses `Nat.fib_gcd` to reduce from "∀ k < n" to "∀ proper divisors d of n"

2. **Factor-stripping infrastructure** — ✅ Proved  
   - `stripFactors_dvd`: the stripped result divides the original  
   - `stripFactors_coprime`: the stripped result is coprime to the stripping factor  
   - `prime_dvd_stripFactors`: primes not dividing the stripping factor survive  

3. **Primitive part properties** — ✅ Proved  
   - `primPart_dvd`: `primPart n ∣ fib(n)`  
   - `prime_dvd_primPart`: primitive primes divide `primPart`  
   - `exists_primitive_of_primPart_gt_one`: if `primPart n > 1`, a primitive prime exists  

4. **Computational verification** (`primPart_gt_one_small`) — ✅ Proved  
   Verifies `primPart n > 1` for all composite n in [13, 100000] via `native_decide`

5. **Analytical tail** (`primPart_gt_one_large`) — ❌ Sorry  
   For composite n > 100000, showing `primPart n > 1` requires the **Lifting the Exponent Lemma for Fibonacci numbers**, which is not available in Mathlib. This is a well-known result in the theory of Lucas sequences but requires substantial formalization effort (modular congruences for Fibonacci matrix powers, entry point theory, etc.)

6. **Main theorem** (`fib_composite_has_primitive`) — ✅ Proved (modulo the sorry above)  
   Combines all pieces into the final result

### The remaining gap

The single sorry is `primPart_gt_one_large`: for composite `n > 100000`, the primitive part of `fib(n)` is greater than 1. Closing this requires formalizing the Lifting the Exponent Lemma for Fibonacci numbers (the identity `v_p(fib(kd)) = v_p(fib(d)) + v_p(k)` for odd primes `p` with entry point `d`), which would be a substantial Mathlib contribution in its own right.