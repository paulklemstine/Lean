Close the sorry `fib_composite_has_primitive` in `Speculative/AutoResearch/CarmichaelComposite.lean` (also tracked as the infinite-tail case in `Shared/CarmichaelProof.lean`). State and prove:

```lean
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

Note that n = 12 must be excluded because F(12) = 144 = 2⁴·3² and both 2 | F(3) and 3 | F(4), so no primitive divisor exists; the bound n ≥ 13 is sharp.

**Proof strategy — three concrete steps with Mathlib lemmas:**

1. **Fibonacci-specific LTE (Lifting-The-Exponent).** Prove the lemma
   ```
   lemma fib_padic_val_lte (p m r : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5)
     (hp_odd : p ≠ 2) (hm : 0 < m) (hpm : p ∣ Nat.fib m)
     (hpm' : ¬(p ∣ m)) :
     padicValNat p (Nat.fib (m * p ^ r)) = padicValNat p (Nat.fib m) + r
   ```
   The key insight is the Binet-type factorization. Write `Nat.fib (m * p^r)` in terms of the p^r-th power of a unit in the ring ℤ[φ] (or work directly with the closed form). Overkill for Lean: instead use the general `padicValNat.pow_sub_pow_eq_add` from Mathlib's `NumberTheory.PadicValuation`, applied to the identity
   ```
   F(m p^r) = F(m) · L
   ```
   where L ≡ p^r · (F(m))^{-1}·F'(m) (mod p^{r+1}) can be extracted from the recurrence. More directly, prove by induction on r using `Nat.fib_add_two` together with the matrix-formula power `![[1,1],[1,0]]^(m*p^r)`; the p-adic valuation step follows from the fact that the reduction mod p of the companion matrix has order dividing p−1 or 2(p+1) (by `fib_entry_point` in `Algebra/Algebra/OpenDirections.lean`), so the LTE hypothesis on `a^{p^r} − b^{p^r}` is satisfied. Handle p = 2 separately via `Nat.fib_even` (prove that `padicValNat 2 (Nat.fib (6·2^r)) = 3 + r`, which covers the only relevant even entry points). Handle p = 5 via the explicit divisibility `5 | Nat.fib (5·k)` for all k ≥ 1, provable by induction on k with `Nat.fib_add_two`.

2. **Primitive-part growth domination.** Prove that for all composite n ≥ 13,
   ```
   Nat.fib n > ∏_{d | n, d < n} Nat.fib d
   ```
   First establish the sharp lower bound `Nat.fib n ≥ 2 ^ ((n - 1) / 2)` by strong induction using `Nat.fib_add_two` and the monotonicity of `Nat.pow`. For the product bound, let `τ(n)` denote the number of divisors of n. By `Nat.divisorsAntidiagonal` or an elementary counting argument with `Nat.sqrt`, show `τ(n) ≤ 2 * Nat.sqrt n`. Every proper divisor d of n satisfies `d ≤ n / 2`, so each factor `Nat.fib d` is at most `Nat.fib (n / 2)`. By the easy upper bound `Nat.fib k ≤ 2 ^ k` (induction via `Nat.fib_add_two`), obtain
   ```
   ∏_{d | n, d < n} Nat.fib d ≤ (2 ^ (n / 2)) ^ (2 * Nat.sqrt n).
   ```
   Taking base-2 logarithms, the right-hand side is `n * Nat.sqrt n`, while the left-hand side from the lower bound is at least `(n - 1) / 2`. The inequality `(n - 1) / 2 > n * Nat.sqrt n` holds for all n > 10000 by `nlinarith` with `Nat.sqrt_le_sqrt`. For the finitely many composite n in [13, 10000], the inequality is discharged by `native_decide`. The gap between the asymptotic bound and the finite interval is bridged exactly at n = 10000 to match the existing computational verification `fib_coprime_part_pos_small`.

3. **Entry-point sieve contradiction.** Assume F(n) has no primitive prime divisor. By your already-established lemma `fibEntryPt_dvd_of_fib_dvd` (in `CarmichaelComposite.lean`), for every prime p | F(n) the entry point `z(p) = fibEntryPt p` divides n and is < n, hence z(p) is a proper divisor of n. By step 1, for each such p the full p-adic valuation of F(n) is carried by the factor F(z(p)) and its p-power multiples, all of which divide the product `∏_{d | n, d < n} F(d)`. Therefore
   ```
   padicValNat p (Nat.fib n) ≤ padicValNat p (∏_{d | n, d < n} Nat.fib d)
   ```
   for every prime p. Multiplying over all p implies `Nat.fib n ≤ ∏_{d | n, d < n} Nat.fib d`, contradicting step 2. Consequently some prime p | F(n) satisfies `fibEntryPt p = n`. Your lemma `primitive_of_entryPt_eq` (already proven in the same file) then immediately yields that p is a primitive prime divisor of F(n).

**Why this matters.** Closing this sorry completes the composite-index case of Carmichael's theorem, a century-old cornerstone of Diophantine arithmetic for Lucas sequences. In our broader research program, this is not merely a classical curiosity: the primitive-divisor structure governs the rank-of-appearance of primes in Berggren factoring (used to generate new Pythagorean triples via Lorentz matrices), and the same entry-point / growth-bound machinery is the algebraic backbone of the tropical-certified-robustness pipeline and the EML universal-approximation program. A fully formalized Carmichael theorem demonstrates that our `native_decide` + asymptotic-proof hybrid methodology scales to deep number theory, which is exactly the paradigm needed for the remaining open goals: Niven integrality, tropical Hecke algebras, and the CRYSTALS-Dilithium security reduction.

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
