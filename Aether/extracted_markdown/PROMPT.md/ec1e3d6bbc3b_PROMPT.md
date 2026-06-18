Close the sorry in `Speculative/AutoResearch/CarmichaelComputational.lean` at `theorem fib_composite_has_primitive`.

**Target statement (exact):**
```lean
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry
```

**Proof strategy — three concrete steps with Mathlib lemma names:**

1. **Reduce the existential goal to the non-triviality of the primitive part.**  
   The file `Shared/CarmichaelProof.lean` already defines `primPart n` by folding `stripAllAux` over `propDivs n`; this is precisely the divisor-stripping algorithm referenced in the concept description. Invoke the structural facts established there:
   - `primPart_dvd n` (using `stripAllAux_dvd` and `dvd_trans` to show `primPart n ∣ Nat.fib n`);
   - `primPart_coprime_proper_divs n` (using `stripAllAux_coprime` and `Nat.gcd_comm` to show `Nat.gcd (primPart n) (Nat.fib d) = 1` for every proper divisor `d` of `n`).
   Then apply `primPart_implies_primitive` : it states that if `1 < primPart n`, then `Nat.minFac (primPart n)` is a prime that divides `Nat.fib n` and does not divide any earlier Fibonacci term. This collapses the existential statement to the single inequality `1 < primPart n`.

2. **Close the finite range computationally and the infinite tail analytically.**  
   - For `n ≤ 10000`, use `primPart_check` from `Shared/CarmichaelProof.lean`. This theorem was already verified by `native_decide`; because `n` is composite, the disjunction `Nat.Prime n ∨ 1 < primPart n` immediately gives `1 < primPart n`. Use `Finset.mem_Icc.mpr` and `Or.resolve_left` with the hypothesis `hn_comp`.
   - For `n > 10000`, prove `1 < primPart n` by a size argument on the cyclotomic-like factor. Observe that `primPart n` coincides with `∏_{d|n} (Nat.fib d) ^ μ(n/d)` (negative exponents are realised by the iterative `Nat.div` inside `stripAllAux`). Establish the Binet-style lower bound `Nat.fib d ≥ φ^d / 5` for all `d ≥ 5` by induction on `d` using `Nat.fib_add_two` and `Real.rpow_le_rpow`. Summing over divisors with `Finset.sum_mul` and `ArithmeticFunction.moebius` yields
     `log (primPart n) = ∑_{d|n} μ(n/d) · log(F(d)) ≥ φ(n)·log φ − τ(n)·log(5)/2`.
     Apply `Nat.totient_even` (valid since `n > 2`) to get `φ(n) ≥ 2`, bound the divisor count `τ(n)` by `2·n.sqrt` via `Nat.divisors_card_le_self` (or the standard `τ(n) ≤ 2√n` proved with `Nat.le_sqrt`), and verify that the right-hand side exceeds `0` for every composite `n > 10000`. Conclude with `Nat.floor_pos` and `Nat.zero_lt_one.trans`.

3. **Discharge the non-divisibility side conditions via entry-point theory.**  
   Once `p := Nat.minFac (primPart n)` is extracted using `Nat.minFac_prime` and `Nat.minFac_dvd`, you must show `∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)`. Apply the `bridge_lemma` from `Shared/CarmichaelProof.lean` (or replicate its argument directly): if `p ∣ Nat.fib k` for some `0 < k < n`, then `p ∣ Nat.fib (Nat.gcd n k)` by `fib_dvd_gcd` and `Nat.fib_gcd`. But `Nat.gcd n k` is a proper divisor of `n`; by `Nat.gcd_dvd_left`, `Nat.gcd_pos_of_pos_left`, and `Nat.gcd_le_right`, it lies in `propDivs n`. This contradicts `primPart_coprime_proper_divs`, which gives `Nat.gcd (primPart n) (Nat.fib (Nat.gcd n k)) = 1`. Use `Nat.Prime.not_dvd_one` (specialised to `Nat.minFac_prime`) to turn the common-divisor hypothesis into the final contradiction via `absurd`.

**Why this matters:**  
Closing this sorry completes the composite case of Carmichael's primitive divisor theorem: for every `n > 12`, the Fibonacci number `F(n)` admits a prime divisor that does not divide any earlier Fibonacci term. This finalises the classical number-theoretic pillar that underpins the Korselt-style factorisation work in `Algebra/IntegerEnergy/KorseltCriterionFull.lean` (where `carmichael_not_prime_power` was established) and supplies the exact divisibility structure needed for the tropical certified-robustness programme.

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
