Aristotle,

We need you to close the remaining sorry on `fib_composite_has_primitive` in `Speculative/AutoResearch/CarmichaelComputational.lean`. This is the composite-index specialization of Carmichael's primitive divisor theorem—the last structural gap before the full result is complete.

**Theorem statement (Lean 4):**

```lean
theorem fib_composite_has_primitive (n : ℕ) (hn : n > 10000) (hcomp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

**Proof strategy:**

1. **Entry-point reduction via the GCD identity.** For any prime divisor p of `Nat.fib n`, define its rank of apparition z(p) as the minimal positive k such that p | F_k. Use our catalog theorem `fib_gcd_identity` (`Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n)`) together with Mathlib's `Nat.fib_dvd` to prove that z(p) | n. Conclude that if p is not primitive, then p divides `Nat.fib d` for some proper divisor d | n with d < n. Apply `Nat.exists_prime_and_dvd` and `Nat.minFac_prime` to decompose `Nat.fib n` into its prime factors.

2. **LTE valuation jump for Lucas sequences.** For each proper divisor d of n and each odd prime p with z(p) = d and p ∤ d, prove that
   ```
   padicValNat p (Nat.fib n) = padicValNat p (Nat.fib d) + padicValNat p (n / d)
   ```
   This is the lifting-the-exponent lemma for Fibonacci numbers. Establish it by analyzing the multiplicative order of the fundamental unit in `(ZMod (p^k))^×`: use Mathlib's `ZMod.orderOf_dvd_card_sub_one` and `padicValNat` (from `Mathlib.NumberTheory.Padics.PadicVal`) to control the valuation jump when the index is multiplied by p. Use `Nat.mul_div_cancel'` and `Nat.coprime_comm` for the divisor arithmetic.

3. **Growth contradiction forcing a primitive divisor.** Assume no primitive prime divisor exists. Then every prime power dividing `Nat.fib n` is captured by the product over proper divisors via Step 2. For composite n > 10000, show this forces `Nat.fib n` to divide a quantity strictly smaller than itself. Specifically, bound the non-primitive contribution using our catalog theorem `fib_exp_bound` (`Nat.fib n ≤ 2^n`) for the proper-divisor terms, combine with the lower bound `n ≤ Nat.fib n` (our `fib_linear_lower`), and use `Finset.prod_le_pow_card` together with the divisor bound `Nat.sum_divisors` (summing over `Nat.divisors n` and discarding n itself) to obtain the strict inequality. Conclude by `Nat.le_of_dvd` and `linarith` that a primitive prime divisor must exist.

**Why this matters:** This theorem resolves the composite-index case of Carmichael's primitive divisor theorem for Fibonacci numbers, leaving only a finite computational check for indices n with 13 ≤ n ≤ 10000. It bridges our `fib_gcd_identity` and `fib_primitive_divisor_existence` results into a complete structural statement, and the LTE machinery developed here is exactly what we need for the broader tropical-cryptographic correspondence (connecting to our CRYSTALS-Dilithium and tropical Hecke algebra tracks) where p-adic valuations of linear recurrence sequences govern security reductions. Closing this sorry completes the classical Fibonacci pillar of our research program.

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
