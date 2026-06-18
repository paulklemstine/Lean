# Summary of changes for run e208b7f8-f53f-4cf2-82dc-8841231d0f29
# Carmichael's Primitive Divisor Theorem — Partial Formalization

## What Was Accomplished

### Lean 4 Formalization (Shared/CarmichaelHelper.lean, Shared/CarmichaelProof.lean)

I restructured the proof of `fib_carmichael_composite` to reduce the original sorry to a cleaner, more focused mathematical claim. The proof now has this structure:

**Main theorem** (`fib_carmichael_composite`): For composite n ≥ 13, F(n) has a primitive prime divisor.
- **n ≤ 10000**: Handled by `native_decide` computational verification (unchanged, working).
- **n > 10000**: Reduced to `primPart_gt_one_large`, which depends on Wall's theorem.

**10 helper lemmas fully proved** in `Shared/CarmichaelHelper.lean`:
1. `fib_mul_le` — F(a)·F(b) ≤ F(a+b) for a,b ≥ 1
2. `fib_mul_lt` — F(a)·F(b) < F(a+b) for a,b ≥ 2
3. `fib_mul_lt'` — **Key multiplication inequality**: F(a·b) > F(a)·F(b) for a,b ≥ 2
4. `fib_ge_id` — F(n) ≥ n for n ≥ 5
5. `fib_pow_le` — F(a)^b ≤ F(a·b) for a ≥ 2, b ≥ 1
6. `fib_coprime_of_coprime` — gcd(F(a),F(b)) = 1 when gcd(a,b) = 1
7. `fib_div_fib_dvd` — F(n) | F(n·k)
8. `fib_succ_mul_mod` — F(nk+1) ≡ F(n+1)^k mod p (key modular recurrence)
9. `fib_div_mod` — F(nk)/F(n) ≡ k·F(n+1)^{k-1} mod p (quotient congruence)
10. `weak_wall` — **Weak Wall's theorem**: p ∤ F(nk)/F(n) when p | F(n) and p ∤ k

**3 remaining sorries** (all in Shared/):
- `wall_base` — v_p(F(np)/F(n)) = 1 (Wall's theorem base case)
- `wall_theorem` — Full Wall's theorem: v_p(F(nk)) = v_p(F(n)) + v_p(k)
- `primPart_gt_one_large` — primPart(n) > 1 for composite n > 10000

All three reduce to **Wall's theorem** (D.D. Wall, 1960), a deep result on p-adic valuations of Fibonacci numbers. The necessary Mathlib infrastructure exists (`padicValNat.pow_sub_pow` — the Lifting the Exponent lemma), but connecting it to the Fibonacci-specific formulation requires substantial additional formalization.

### Python Demos (demos/)

- `carmichael_demo.py` — Interactive demonstration verifying Carmichael's theorem for F(13)..F(100), showing entry points, Wall's theorem, and the multiplication inequality
- `applications.py` — Four practical applications: Fibonacci primality certificates, large prime generation, GCD algorithms, and cryptographic implications (Pisano periods)

### Research Paper (RESEARCH_PAPER.md)

A complete research paper documenting the formalization effort, including the proof architecture, what was proved vs. what remains, and connections to broader mathematics (Zsygmondy's theorem, algebraic number theory, cryptography).

## What Remains

The core mathematical obstruction is **Wall's theorem** — proving that for an odd prime p with p | F(n), the p-adic valuation satisfies v_p(F(nk)) = v_p(F(n)) + v_p(k). This 1960 result requires careful modular arithmetic analysis at the p² level, connecting the Fibonacci quotient formula to the Lifting the Exponent lemma. The proof infrastructure (modular congruences, weak Wall's) is in place; the gap is the base case v_p(F(np)/F(n)) = 1.