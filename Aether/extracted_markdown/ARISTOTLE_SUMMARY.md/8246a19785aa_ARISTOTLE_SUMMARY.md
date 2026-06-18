# Summary of changes for run 118fde82-192c-4bcb-b416-ed4ea234e631
## Summary of Completed Work

### Critical Finding: The Growth Bound Theorem is FALSE

The proposed theorem `fib_growth_dominates_proper_divisor_product` — that for composite n ≥ 13, F(n) exceeds the product of F(d) over all proper divisors d of n — is **false**. Counterexample: n = 24, where F(24) = 46,368 but ∏ F(d) = 145,152. Additional counterexamples include n = 30, 36, 40, 42, 48 (any composite with sufficiently many divisors).

Despite this, Carmichael's theorem (that F(n) has a primitive prime divisor for n ≥ 13) remains true. The correct approach uses the Möbius primitive part Ψ(n) = ∏_{d|n} F(d)^{μ(n/d)}, not the raw product of Fibonacci values at divisors.

### New Files Created

1. **`Shared/FibGrowth.lean`** — Sorry-free file containing:
   - `growth_bound_counterexample`: Formal proof that F(24) < ∏ F(d) (disproving the conjecture)
   - `fib_add_ge_mul`: F(a+1)·F(b) ≤ F(a+b) for b ≥ 1
   - `fib_submultiplicative`: F(a)·F(b) ≤ F(a+b) for a,b ≥ 1
   - `fib_power_bound`: F(m)^k ≤ F(k·m) for m,k ≥ 1
   - `fib_gt_id`: n < F(n) for n ≥ 7
   - `fib_double_gt_sq`: F(m)² < F(2m) for m ≥ 2
   - The original false theorem is commented out with explanation

2. **`Shared/CarmichaelCompositeHelper.lean`** — Sorry-free file proving Carmichael's theorem for n = 2q (q prime ≥ 7):
   - Lucas number theory: `fib_double_eq_mul_lucas`, `gcd_lucas_fib_dvd_two`, `lucas_odd_of_not_three_dvd`, `lucas_ge_three`
   - `lucas_has_odd_prime_factor`: L(q) has an odd prime coprime to F(q)
   - Entry point theory: `fibEntry_dvd`, `fibEntry_pos_of_dvd`
   - `entry_eq_double_prime`: Entry point determination for primes dividing L(q)
   - **`carmichael_double_prime`**: Full proof that F(2q) has a primitive prime for q prime ≥ 7

3. **Supporting documents:**
   - `RESEARCH_REPORT.md`: Technical report on findings and formal results
   - `demo.py`: Python script demonstrating counterexamples, primitive divisors, and the Lucas number proof
   - `diagram.svg`: SVG visualization of entry point theory and the counterexample
   - `DISCUSSION.md`: Scientific American-style discussion of Carmichael's theorem

### Existing Sorries (Unchanged)

The 4 remaining sorries in catalog files — all for the **general composite case** of Carmichael's theorem — were not filled:
- `Shared/CarmichaelComposite.lean`: `fib_carmichael` (composite branch)
- `Shared/CarmichaelComputational.lean`: `fib_composite_has_primitive`
- `Speculative/CarmichaelPrimitiveDivisor.lean`: `fib_primitive_divisor`
- `Shared/Fib_gcd_identity.lean`: `fib_primitive_divisor_existence`

These all require proving that for **arbitrary** composite n ≥ 13, the primitive part Ψ(n) > 1. This is a deep result requiring lifting-the-exponent lemma for Fibonacci, cyclotomic polynomial bounds, and Möbius inversion machinery that goes beyond what's currently available in Mathlib. The n = 2q case (proved in CarmichaelCompositeHelper.lean) demonstrates the proof technique for the simplest composite structure.

### Verification

All new files compile without sorries, and all axioms used are standard (`propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler`).