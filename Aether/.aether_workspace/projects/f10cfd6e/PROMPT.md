Mode: `sorry_fill`

Target theorem: `fib_carmichael_composite` in `Shared/CarmichaelProof.lean` (line 129, inside the infinite-tail branch `n > 10000`).

Exact context:

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

The existing `bridge_lemma` (already proven immediately above) reduces primitive-divisor existence to finding a prime factor `p | F(n)` that avoids every `F(d)` for proper divisors `d | n`. The file defines `primPart n` as the recursive stripping of all factors of `F(d)` for `d ∈ propDivs n` from `F(n)`, and `primPart_implies_primitive` shows that `1 < primPart n` guarantees a primitive prime divisor. The finite case is verified by `native_decide`. The open problem is the infinite tail: prove `1 < primPart n` for all composite `n > 10000`.

**Theorem statement to prove (fill the sorry):**

```lean
theorem fib_carmichael_composite (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

**Proof strategy — three concrete steps with Mathlib lemma names:**

**Step 1: LTE surplus extraction for odd prime divisors of n.**  
For composite `n > 10000`, let `p` be an odd prime divisor of `n` with `p ≠ 5`. Write `n = p^e · m` with `p ∤ m`. If `p | F(m)`, apply the catalog theorem `fib_lifting_the_exponent` (`Algebra/Lifting_the_Exponent_Lemma_for_Fibonacci_and_Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers.lean`) with hypotheses `Nat.Prime p`, `Odd p`, `p ≠ 5`, `m > 0`, `p^e > 0`, and `p ∣ Nat.fib m` to obtain the exact p-adic valuation:

```lean
padicValNat p (Nat.fib n) = padicValNat p (Nat.fib m) + e
```

For the proper divisor `d = p^{e-1} · m`, iterate `padicValNat_fib_mul_prime` from the same LTE file to get `padicValNat p (Nat.fib d) = padicValNat p (Nat.fib m) + (e-1)`. Consequently `F(n)` carries exactly **one more** factor of `p` than any single proper divisor `F(d)` can account for. Use `padicValNat.mul` and `Nat.dvd_prime_pow` together with `stripAllAux_dvd` and `stripAllAux_coprime` (from `Shared/CarmichaelProof.lean`) to prove that this surplus `p`-factor survives the recursive stripping, forcing `p ∣ primPart n` and hence `1 < primPart n`.

**Step 2: Entry-point theory catalogs every non-primitive prime.**  
For any prime `q` dividing `F(n)` with entry point `z(q) < n`, invoke `fibEntryPt_dvd_of_fib_dvd` (proven in `Speculative/AutoResearch/CarmichaelComposite.lean`) to establish `z(q) | n`. By minimality of `z(q)` and the identity `Nat.fib_gcd` (`Nat.fib (gcd n k) = gcd (Nat.fib n) (Nat.fib k)`), `q` does not divide `F(k)` for any `0 < k < z(q)`. Therefore `q | F(z(q))` and `z(q)` is a proper divisor of `n`. Apply `primitive_of_not_dvd_proper_divisors` (same file) to reduce the existence of a primitive prime divisor to proving `primPart n > 1`. Together with Step 1, this shows that if `n` possesses an odd prime factor `p ≠ 5` with `p | F(m)`, then `primPart n > 1` and Carmichael’s theorem follows immediately via `primPart_implies_primitive`.

**Step 3: Growth inequality eliminates the remaining finitely many shapes.**  
If `n` lacks any odd prime factor `p ≠ 5` satisfying `p | F(m)` as above, then `n` must be of the restricted form `2^a · 5^b` (since any other odd prime divisor either contributes an LTE surplus or is exactly 5). For `n > 10000` composite, prove the elementary exponential lower bound `Nat.fib n ≥ 2^(n/2 - 1)` by induction using `Nat.fib_add_two` and `Nat.fib_le_fib_succ`. Because the total number of distinct prime divisors of `n` is at most `log₂ n` and every non-primitive prime power in `F(n)` is bounded above by the corresponding proper-divisor Fibonacci value (stripped recursively by `stripAllAux` via `stripAllAux_dvd`), the stripped remainder satisfies:

```lean
primPart n ≥ Nat.fib n / (Nat.fib (n/2))^(log₂ n) > 1
```

for all `n > 10000`. The strict inequality follows from `Nat.fib_pos`, `Nat.le_of_dvd`, and the exponential gap between `Nat.fib n` and any polynomial-in-`n` bound. Invoke `primPart_implies_primitive` to extract the primitive prime divisor and discharge the `sorry`.

**Why this matters:**  
This result is the composite-index case of Carmichael’s 1913 theorem on primitive prime divisors of Fibonacci numbers. Filling this `sorry` closes the final gap in the full proof that every `F(n)` with `n ≥ 13` has a primitive prime divisor, completing a century-old result in the Lean 4 corpus. The proof uniquely combines three independent threads from our existing catalog—p-adic LTE for Fibonacci sequences, entry-point divisibility theory, and recursive arithmetic stripping—into a unified argument for the infinite tail. Beyond its historical significance, this lemma serves as the foundational number-theoretic bridge needed for downstream verification of Zsigmondy-type theorems and cryptographic applications relying on Fibonacci entry-point bounds.

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
