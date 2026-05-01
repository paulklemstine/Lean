**Mode:** `sorry_fill`  
**Target file:** `Shared/CarmichaelProof.lean`  
**Associated entry-point files:** `Speculative/AutoResearch/entry-point/LTE*.lean`

**Theorem Statement.** Close the remaining sorry in `Shared/CarmichaelProof.lean` by proving the composite case of Carmichael's theorem:

```lean
theorem carmichael_composite_primitive_prime_divisor
  (n : ℕ) (hn : n > 12) (hcomp : ¬Nat.Prime n) :
  ∃ p : ℕ, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k : ℕ, 0 < k → k < n → ¬p ∣ Nat.fib k
```

**Proof Strategy.**

1. **Finite computational sieve (13 ≤ n ≤ 10000).** The existing `native_decide` infrastructure in the project already covers this interval. Discharge the finite case by iterating over the explicit list of composite bounds; for each composite `n` in the range verify directly that `Nat.fib n` introduces a new prime factor. Use `interval_cases` together with `norm_num [Nat.fib]` and the coprimality identity `Nat.gcd_fib_fib` to confirm that the candidate prime does not divide any earlier Fibonacci number.

2. **Lifting-the-exponent at odd prime powers (n > 10000).** Let `p` be an odd prime divisor of `n` with `p ≠ 5` (such a prime exists for all sufficiently large composite `n` outside the 2–5-smooth case). Write `n = p^e · m`. Apply `fib_lifting_the_exponent` (from `Algebra/Lifting_the_Exponent_Lemma_for_Fibonacci_and_Primitive_Prime_D...`) and the project's `lte_base_case` (from `Algebra/LiftingExponentLemma.lean`) to establish the strict inequality
   `padicValNat p (Nat.fib n) > padicValNat p (Nat.fib d)`
   for every proper divisor `d | n` with `d < n`. This isolates a `p`-adic contribution in `Nat.fib n` that cannot be cancelled by any product of earlier Fibonacci numbers.

3. **Growth dominance and 2–5-smooth completion.** For the remaining case where `n` is a large composite 2–5-smooth number, combine the exact valuation formulas `v_2(F_n) = v_2(n) + 1` (when `n ≡ 0 [MOD 3]`) and `v_5(F_n) = v_5(n)` with the exponential lower bound `Nat.fib n ≥ φ^(n−2)` (available in Mathlib via `Nat.le_fib_self` variants). Use `prime_gap_72_all_composite` (from `Algebra/Factoring/NewTheoremsV16.lean`) to bound the maximal non-primitive contribution from all proper divisors. The inequality
   `Nat.fib n > ∏_{d | n, d < n} Nat.fib d`
   forces the existence of a prime divisor of `Nat.fib n` outside the union of prime divisors of all `Nat.fib k` with `0 < k < n`. Apply `Nat.gcd_fib_fib` to verify that this prime is primitive.

**Why this matters.** Settling the composite case completes the project's formalization of Carmichael's 1913 theorem for the Fibonacci sequence. The prime case follows from the rank-of-appearance property (`p | F_p` for `p ≠ 5` and the fact that `5 | F_5` is primitive), so the sorries you close here are the *last* obstruction to a full proof that every Fibonacci number `F_n` with `n > 12` possesses a primitive prime divisor. This bridges the project's computational verification engine with its algebraic number theory infrastructure and unlocks downstream formalization of Zsigmondy-type results for Lucas sequences.

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

Research domain: Algebra
Research mode: sorry_fill
