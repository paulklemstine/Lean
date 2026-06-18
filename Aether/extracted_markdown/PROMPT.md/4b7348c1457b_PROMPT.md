Mode: `sorry_fill`

Target: Complete the final `sorry` in `Shared/CarmichaelProof.lean` (line ~129), which is the infinite tail of `fib_carmichael_composite`. The theorem states:

```lean
theorem fib_carmichael_composite (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

The surrounding context already proves:
- `bridge_lemma`: if `p ∣ Nat.fib n` and `p` divides no `Nat.fib d` for proper divisors `d ∣ n`, then `p` divides no `Nat.fib k` for any `0 < k < n`.
- `primPart_implies_primitive`: if `1 < primPart n`, then such a primitive prime `p` exists.
- `primPart_check`: computationally verifies `1 < primPart n` for all composite `n ∈ [13, 10000]`.

Therefore, the missing `sorry` reduces to proving `1 < primPart n` for **composite `n > 10000`**. Here `primPart n` is the result of recursively removing, via `stripAllAux`, all prime factors shared with `Nat.fib d` for every proper divisor `d ∣ n`.

**Proof Strategy — Three Steps:**

1. **Entry point characterization of primitive primes.**  
   Use `primitive_of_entryPt_eq` from `CarmichaelComposite.lean`, which proves that if `p ∣ Nat.fib n` and the Fibonacci entry point `fibEntryPt p = n`, then `p` is primitive. Combine this with `fibEntryPt_dvd_of_fib_dvd`: the entry point of any prime divisor of `Nat.fib n` divides `n`. Consequently, a prime factor of `Nat.fib n` is non-primitive *iff* its entry point is a proper divisor of `n`. This means `primPart n` is precisely the product of prime powers of `Nat.fib n` whose entry point equals `n`.

2. **Even composite case via the Lucas companion.**  
   For `n = 2m`, apply `Nat.fib_two_mul` to decompose `Nat.fib (2*m) = Nat.fib m * L m` where `L m = 2*Nat.fib (m+1) - Nat.fib m`. Use `Nat.gcd (L m) (Nat.fib m) ∣ 2` (provable via `Nat.fib_coprime_fib_succ` and `Nat.dvd_gcd`) to show that any odd prime factor of `L m` does not divide `Nat.fib m`. Since `Nat.fib_two_mul` gives a genuine multiplicative split, and `lucas_ge_three` guarantees `L m ≥ 3` for `m ≥ 2`, the odd part of `L m` contributes a factor to `Nat.fib n` that survives removal by `stripAllAux` relative to all proper divisors `d ∣ n`.

3. **General odd composite case via multiplicative quotient bounds.**  
   For odd composite `n = a*b` with `3 ≤ a ≤ b`, use `fib_mul_eq` from the LTE development (`Lifting_the_Exponent_Lemma_for_Fibonacci...`) to write `Nat.fib n = Nat.fib a * fibQuot a b`. Then apply `fib_quotient_gcd_dvd`, which proves `Nat.gcd (fibQuot a b) (Nat.fib a) ∣ b`. Because `b < n` and the gcd is bounded, at least one prime factor of `fibQuot a b` is not canceled by `stripAllAux` when processing the proper divisor `a`. Since `Nat.fib n > Nat.fib a` for `b ≥ 2` (by `Nat.fib_lt_fib_succ` and monotonicity), the quotient contributes positive remaining mass, ensuring `primPart n > 1`.

**Why this matters:**  
This `sorry` is the last obstruction to a complete formal proof of Carmichael's 1913 theorem on primitive prime divisors of Fibonacci numbers. The prime case (`fib_primitive_divisor_prime`) is already in the catalog. Closing this composite gap will yield the first fully machine-checked proof that every `F_n` with `n ≥ 13` admits a primitive prime divisor, resolving the century-old conjecture in Lean 4 and unlocking downstream formalizations of Lucas sequence cryptography (relevant to the CRYSTALS-Dilithium security reduction program).

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

Research domain: Shared
Research mode: sorry_fill
