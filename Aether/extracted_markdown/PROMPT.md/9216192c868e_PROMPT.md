Mode: sorry_fill

**Target 1:** `Speculative/AutoResearch/CarmichaelComposite.lean`, theorem `fib_carmichael_large` (line 164)

```lean
/-- For composite n > 10000, F(n) has a primitive prime divisor.
    This follows from growth bounds on Fibonacci numbers. -/
lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry
```

**Target 2:** `Shared/CarmichaelProof.lean`, theorem `fib_carmichael_composite` infinite-tail branch (line 129)

```lean
theorem fib_carmichael_composite (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases h : n ≤ 10000
  · -- Finite case: extract from computational verification
    have := primPart_check n (Finset.mem_Icc.mpr ⟨hn, h⟩)
    exact primPart_implies_primitive n (by omega) (this.resolve_left hnp)
  · -- Infinite tail: composite n > 10000
    sorry
```

You are filling the last two `sorry` placeholders needed to complete the first fully formal, unconditional proof of Carmichael's primitive divisor theorem for composite indices. The surrounding files already contain:
- `primitive_of_fibCoprimePart_pos` and `primPart_implies_primitive`, which reduce the problem to proving the "coprime part" of F(n) exceeds 1.
- `fibEntryPt_dvd_of_fib_dvd` and `primitive_of_entryPt_eq`, which characterize primitive divisors via entry-point theory.
- `Nat.fib_gcd` and `Nat.fib_dvd` (from Mathlib), giving the fundamental divisibility structure.
- `fib_entry_point` (Algebra/Algebra/OpenDirections.lean, catalog theorem #2) for the entry-point properties of primes.
- `nontrivial_divisor_composite` (Algebra/DivisionAlgebras/NormHierarchy.lean, catalog theorem #3) for extracting proper factorizations.

**Proof strategy — three concrete steps with Mathlib lemmas:**

1. **Prime powers:** If n = p^k with k ≥ 2, use `Nat.fib_dvd` to obtain F(p^{k−1}) | F(p^k). By `Nat.fib_lt_fib` (strict monotonicity for indices ≥ 2), the integer quotient Q = F(p^k)/F(p^{k−1}) exceeds 1. Apply `Nat.exists_prime_and_dvd` to extract a prime q | Q. Because q divides F(p^k) but not F(p^{k−1}), the entry-point minimality lemma `fibEntryPt_dvd_of_fib_dvd` forces the entry point of q to equal p^k exactly. Then `primitive_of_entryPt_eq` yields that q is a primitive prime divisor of F(p^k).

2. **Coprime composites:** If n = ab with gcd(a,b) = 1 and a,b > 1, invoke `Nat.fib_gcd` to show Nat.Coprime (Nat.fib a) (Nat.fib b) = F(gcd(a,b)) = F(1) = 1. By `Nat.fib_dvd`, both F(a) | F(n) and F(b) | F(n); since they are coprime, `Nat.Coprime.mul_dvd_of_dvd_of_dvd` gives F(a)·F(b) | F(n). Prove F(n) > F(a)·F(b) for all such n > 10000 using the explicit lower bound `le_fib_self` and the fact that n > a + b whenever n = ab > 10000 with a,b > 1 (this growth gap is guaranteed because the minimal such product with n > 10000 forces a ≥ 2 and b = n/a ≥ 5000). Let Q = F(n)/(F(a)·F(b)) > 1. Extract a prime q | Q via `Nat.exists_prime_and_dvd`. If q divided F(d) for some proper divisor d | n, then by `fib_dvd_gcd_of_dvd` (in the file) the entry point z(q) would divide d | n and also divide both a and b (contradicting q ∤ F(a),F(b)) unless z(q) = n; hence q is primitive.

3. **General reduction:** For arbitrary composite n > 10000, perform case analysis with `by_cases` on whether n is a perfect prime power. Obtain a nontrivial factorization using `nontrivial_divisor_composite` and `prime_has_divisor_one`. If n = p^k, apply Step 1. Otherwise n = p^e·m with gcd(p^e, m) = 1 and m > 1; apply Step 2 with a = p^e, b = m, using `Nat.Coprime.pow_left`/`Nat.Coprime.pow_right` to lift coprimality of the base prime factors to their powers. In Target 1, conclude with `primitive_of_fibCoprimePart_pos` once you show `1 < fibCoprimePart n`. In Target 2, conclude with `primPart_implies_primitive` once you show `1 < primPart n`.

**Why this matters:** This closes the composite-index gap in Carmichael's theorem, completing the first formal proof that every Fibonacci number F_n with composite n > 1 possesses a primitive prime divisor. Together with the existing `fib_primitive_divisor_prime` (prime case) and the `native_decide` finite verification up to 10 000, these two sorries yield an unconditional, constructively valid result for all composite indices. The proof pioneers the formalization of entry-point divisibility theory and lifting-the-exponent arguments for Fibonacci sequences, directly supporting the broader research program on classical-quantum-tropical correspondence by establishing number-theoretic primitives (Carmichael's theorem) that underpin later cryptographic and algebraic bridges.

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
