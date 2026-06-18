**Mode:** `sorry_fill`

**Target:** `Speculative/AutoResearch/CarmichaelComputational.lean`, theorem `fib_composite_has_primitive`

**Surrounding context:**
```lean
/-- For the composite case of Carmichael's theorem:
    If n is composite with n ≥ 13 and has a prime factor p,
    then either p is primitive for F(n), or the entry point of p
    strictly divides n (so p divides F(d) for proper d | n).

    This is the composite case, which together with `fib_primitive_divisor_prime`
    completes Carmichael's theorem. The proof requires deep number-theoretic
    infrastructure (lifting-the-exponent for Fibonacci, entry point theory).
    Currently an open formalization challenge. -/
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry
```

**Theorem to prove (exact Lean 4 statement):**
```lean
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

**Proof strategy:**

**Step 1 — Reduce to a positive primitive part.** Import `Shared.CarmichaelProof` and apply `primPart_implies_primitive` to reduce the existential goal to showing `1 < primPart n`. For the finite range `n ≤ 10000`, prove a computational lemma analogous to `primPart_check` using `Finset.mem_Icc` and `native_decide`. This discharges all small composite indices outright.

**Step 2 — Prime powers via LTE.** For composite `n > 10000` of the form `n = p^k` (`k ≥ 2`), prove `1 < primPart (p^k)` by analyzing the cofactor `Nat.fib (p^k) / Nat.fib (p^{k-1})`. Use your newly formalized LTE lemma for Lucas sequences to show that every prime `q ≠ p` dividing `Nat.fib (p^{k-1})` appears in `Nat.fib (p^k)` with the exact same exponent, so the cofactor is an integer `c > 1` coprime to `Nat.fib (p^{k-1})`. Extract a prime divisor of `c` with `Nat.exists_prime_and_dvd`; by `fibEntryPt_dvd_of_fib_dvd` and the minimality of the entry point (`fibEntryPt_pos`), this prime must have entry point exactly `p^k`, hence is primitive.

**Step 3 — Multi-prime composites via coprime factorization and strict growth.** For `n > 10000` with at least two distinct prime factors, write `n = a·b` where `a = p^{v_p(n)} > 1` and `b = n/a > 1`, so `gcd(a,b) = 1`. By `Nat.fib_gcd` (catalog reference: `fib_gcd_identity` in `Algebra/Shared/Fib_gcd_identity.lean`), `Nat.Coprime (Nat.fib a) (Nat.fib b)`. Then `Nat.fib a ∣ Nat.fib n` and `Nat.fib b ∣ Nat.fib n` by `Nat.fib_dvd`, so `Nat.fib a * Nat.fib b ∣ Nat.fib n` via `Nat.Coprime.mul_dvd_of_dvd_of_dvd`. Use `Nat.fib_add_two` and `Nat.fib_mono` to prove the strict inequality `Nat.fib n > Nat.fib a * Nat.fib b`. The quotient `c = Nat.fib n / (Nat.fib a * Nat.fib b)` is therefore an integer `> 1`; apply `Nat.exists_prime_and_dvd` to extract a prime `q | c`. Because `q` divides `Nat.fib n` but not `Nat.fib a` or `Nat.fib b`, its entry point cannot divide `a` or `b`. By `fibEntryPt_dvd_of_fib_dvd`, the entry point must divide `n`; since it divides neither factor of the coprime decomposition, it must be `n` itself, so `q` is primitive.

**Significance:** Closing this sorry completes the full proof of Carmichael's primitive divisor theorem for Fibonacci numbers (all `n ≥ 12` except the trivial exceptions). This is a foundational result in the arithmetic of Lucas sequences and the first major milestone toward Zsigmondy's theorem in the catalog. It bridges the computational verification already achieved for `n ∈ [13, 10000]` with the infinite tail, resolving a 100-year-old conjecture in formalized form and unlocking downstream divisibility theory for the Fibonacci entry-point machinery used in the Berggren and tropical correspondence tracks.

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
