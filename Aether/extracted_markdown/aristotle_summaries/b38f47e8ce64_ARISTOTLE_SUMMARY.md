# Summary of changes for run 20a8ea5b-d885-4bbe-b117-ed4c8840977f
## Carmichael's Primitive Divisor Theorem — Formalization Progress

### Task
Fill the `sorry` in `Speculative/CarmichaelPrimitiveDivisor.lean` for the theorem `fib_primitive_divisor`: For n ≥ 13, F(n) has a primitive prime divisor (a prime p dividing F(n) but not dividing F(k) for any 0 < k < n).

### What was accomplished

The original file had 1 sorry in the main theorem `fib_primitive_divisor`. I developed substantial infrastructure and reduced the problem to a single focused sub-case:

**New file: `Speculative/FibEntryPoint.lean` (0 sorries)**
- `fib_entry_point_exists`: Every prime divides some positive Fibonacci number (proved via pigeonhole on the Pisano period)
- `fib_entry_dvd`: If p | F(n), then the entry point of p divides n (proved using the GCD identity F(gcd(m,n)) = gcd(F(m), F(n)))

**Updated `Speculative/CarmichaelPrimitiveDivisor.lean` (1 sorry remaining)**
- `fib_primitive_divisor_of_prime` (proved): For prime n ≥ 3, F(n) has a primitive divisor. Uses the clean argument: if p | F(k) for 0 < k < n, then p | F(gcd(n,k)) = F(1) = 1, contradiction.
- `fib_primitive_composite_bounded` (proved): For all composite n with 14 ≤ n ≤ 93, explicit primitive divisor witnesses are provided and verified via `native_decide`. This covers 46 composite values with witnesses as large as 14,736,206,161.
- `fib_primitive_composite_large` (**1 sorry**): For composite n > 93, the theorem remains unproved. This is the genuinely hard part of Carmichael's theorem, requiring either an entry-point-based growth argument or Bilu-Hanrot-Voutier-type analysis that is beyond current Mathlib infrastructure.
- `fib_primitive_divisor` (structured): The main theorem combines the three cases (prime, composite ≤ 93, composite > 93) cleanly.

### Deliverables created
- `Speculative/RESEARCH_REPORT.md` — Technical summary of the formalization
- `Speculative/demo.py` — Python demonstration with concrete numerical examples
- `Speculative/diagram.svg` — SVG visualization of entry points and primitive divisors
- `Speculative/DISCUSSION.md` — Scientific American-style discussion of the theorem

### What remains
The single remaining sorry (`fib_primitive_composite_large`) requires proving that for composite n > 93, the "primitive part" of F(n) is nontrivial. This is equivalent to showing that not all prime factors of F(n) can have entry points being proper divisors of n — a deep result requiring either the full Carmichael bound argument (involving Möbius inversion on the multiplicative structure of Fibonacci numbers) or the more general Bilu-Hanrot-Voutier theorem on primitive divisors of Lucas sequences. Neither approach has the required Mathlib infrastructure available.