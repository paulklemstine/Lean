**Mode:** `sorry_fill`

**Targets.** Close the two remaining `sorry` placeholders:

1. `fib_carmichael_large` in `Speculative/AutoResearch/CarmichaelComposite.lean` (line ~162):
```lean
lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry
```

2. `fib_composite_has_primitive` in `Speculative/AutoResearch/CarmichaelComputational.lean` (line ~68):
```lean
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry
```

**Verified infrastructure you are building on.**  
- `Shared/CarmichaelHelper.lean` contains `fib_primitive_divisor_prime`, giving the prime-index case.  
- `CarmichaelComposite.lean` contains `primitive_of_fibCoprimePart_pos`: if `1 < fibCoprimePart n`, then a primitive prime divisor exists. It also contains `fib_coprime_part_pos_small`, which verifies `1 < fibCoprimePart n` for all composite `14 ≤ n ≤ 10000` via `native_decide`.  
- `CarmichaelComputational.lean` contains `entry_point_divides`: for a prime `p | F(n)`, the entry point `α(p)` divides `n`.  
- `CarmichaelPrimitiveDivisor.lean` contains `non_primitive_to_proper_divisor`: any non-primitive prime factor of `F(n)` already divides `F(d)` for some proper divisor `d | n`.

**Concrete proof strategy — three steps.**

**Step 1: LTE for Fibonacci prime powers.**  
For `n = p^k` with `p` prime, `k ≥ 2`, and `p^k > 10000`, formalize the lifting-the-exponent lemma for the Lucas sequence `U_n(1,−1)`. Let `q` be a primitive prime divisor of `F(p)` (exists by `fib_primitive_divisor_prime`). Because `q` is primitive, `q ∤ 5` and `q ∤ F(j)` for all `1 ≤ j < p`. Apply `Nat.emultiplicity_pow_sub_pow` from Mathlib in the quadratic integer ring `ℤ[√5]`, or equivalently argue via `padicValNat` together with the closed form `F(p^r) = (α^{p^r} − β^{p^r})/(α−β)`. The LTE calculation yields
```
v_q(F(p^r)) = v_q(F(p)) + (r − 1)    for all r ≥ 1.
```
Since the right-hand side is at least `1`, we have `q | F(p^r)`; and because the valuation jumps with `r`, any proper divisor `d | p^r` has `v_q(F(d)) < v_q(F(p^r))`, so `q` is a primitive prime divisor of `F(p^r)`.

**Step 2: Coprime-factor primitive divisors.**  
For composite `n` with at least two distinct prime factors, write `n = ab` with `gcd(a,b) = 1` and `a,b > 1`. By Step 1 (or the prime case when `a` or `b` is prime), choose primitive prime divisors `q_a | F(a)` and `q_b | F(b)`. By `Nat.fib_gcd` we have `gcd(F(a), F(b)) = F(gcd(a,b)) = F(1) = 1`. Hence `q_a ≠ q_b`; moreover `q_a ∤ F(b)` and `q_b ∤ F(a)`. Since `a | n` and `b | n`, `Nat.fib_dvd` gives `F(a) | F(n)` and `F(b) | F(n)`, so both `q_a` and `q_b` divide `F(n)`. Use `entry_point_divides` to show that a common prime divisor of `F(a)` and `F(b)` would have entry point dividing both `a` and `b`, forcing entry point `1` and thus dividing `F(1) = 1` — impossible. Therefore `F(n)` inherits at least one primitive prime divisor from each coprime factor.

**Step 3: Assemble the infinite tail.**  
Combine Steps 1 and 2 to prove `fib_carmichael_large`: every composite `n > 10000` is either a prime power (covered by Step 1) or a product of coprime factors > 1 (covered by Step 2). In either case `F(n)` possesses a primitive prime divisor, which is exactly the existential goal. Then discharge `fib_composite_has_primitive` in `CarmichaelComputational.lean` by the dichotomy `n ≤ 10000` — apply `primitive_of_fibCoprimePart_pos` together with the computational lemma `fib_coprime_part_pos_small` — and `n > 10000`, where you invoke `fib_carmichael_large`.

**Why this matters.**  
This closes the final gap in the formal proof of Carmichael’s 1913 theorem: every Fibonacci number `F_n` with `n ≥ 13` has a primitive prime divisor. The result is a cornerstone of Lucas-sequence arithmetic, directly analogous to Zsigmondy’s theorem and essential for the Berggren/SPB Pythagorean-triple correspondence already verified in the catalog. The entry-point theory (`entry_point_divides`) and LTE machinery formalized here are precisely the algebraic prerequisites needed for the remaining open priorities: the Tropical Hecke algebra for `GL₂`, CRYSTALS-Dilithium primitive-divisor security reductions, and the EML universal approximation theorem via cyclotomic factor bounds.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Speculative
Research mode: sorry_fill
