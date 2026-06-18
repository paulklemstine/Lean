**SORRY FILL: Exact theorem statement**

In `Speculative/AutoResearch/CarmichaelComposite.lean`, fill:

```lean
lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry -- YOUR TARGET
```

As the surrounding context shows, the finite case `n ≤ 10000` is already closed by `primitive_of_fibCoprimePart_pos` plus `fib_coprime_part_pos_small` (verified by `native_decide`). The infinite tail is the only obstruction to the composite case.

**Proof Strategy**

1. **Prove that `1 < fibCoprimePart n` for all composite `n > 10000` by a growth bound on the primitive part.**  
   The primitive part `fibCoprimePart n` equals `∏_{d|n} (Nat.fib d)^(μ(n/d))` by Möbius inversion over the divisibility lattice. Taking logarithms and using the elementary recurrence bound `Nat.fib (k+2) = Nat.fib (k+1) + Nat.fib k` (from `Nat.fib_add_two`), establish by induction that `Nat.fib m ≥ 2^((m-1)/2)` for all `m ≥ 1`. Deduce that `log₂(fibCoprimePart n) ≥ φ(n)/2 - ∑_{d|n, d<n} (d/2) ≥ 1` for composite `n > 10000`, because `φ(n) ≥ 2` and the divisor sum of the largest proper divisors is asymptotically separated from `φ(n)` at this scale. Use `Nat.totient_pos`, `Nat.sum_divisors`, and `Nat.fib_pos`.

2. **Apply LTE to control the p-adic valuation of non-primitive prime powers and prevent them from absorbing the entire Fibonacci number.**  
   For any prime `p` dividing `Nat.fib n` with entry point `z := fibEntryPt p` strictly dividing `n` (so `z | n` and `z < n`), establish the Fibonacci LTE identity `padicValNat p (Nat.fib n) = padicValNat p (Nat.fib z) + padicValNat p (n / z)`. This follows from the general LTE for Lucas sequences using the existing `Nat.fib_add_two` recurrence and the divisibility infrastructure in `Nat.fib_gcd`. Since `z ≤ n/2` for composite `n`, summing over all non-primitive prime powers shows that the product of all `p^(padicValNat p (Nat.fib n))` for non-primitive `p` divides `lcm_{d|n, d<n} (Nat.fib d)`, which is exponentially smaller than `Nat.fib n` by Step 1. Use `padicValNat.eq_emultiplicity`, `Nat.factorization`, and `Nat.lcm` properties from Mathlib.

3. **Extract the primitive prime divisor and close the bridge to `Shared/CarmichaelProof.lean`.**  
   From Step 1 we have `1 < fibCoprimePart n`. Apply the existing catalog lemma `primitive_of_fibCoprimePart_pos` (already proven in `Speculative/AutoResearch/CarmichaelComposite.lean`) to obtain the witness prime `p`. This immediately fills the sorry in `fib_carmichael_large`. Then in `Shared/CarmichaelProof.lean`, in the infinite tail of `fib_carmichael_composite`, invoke `fib_carmichael_large` via `by_cases` on `n ≤ 10000` (already handled by `primPart_check` and `primPart_implies_primitive`) to complete the composite-index case.

**Why this matters**

This closes the last open sorry in the Carmichael pipeline and completes the composite-index case of Carmichael's theorem (1913) in Lean 4. Once this sorry is filled, the full theorem — that every Fibonacci number `F_n` with `n ≥ 13` admits a primitive prime divisor — becomes an unbroken formal proof, combining finite computational verification (`native_decide` to 10000) with asymptotic number theory (growth bounds and LTE). This establishes a reusable pattern in the Aether catalog for lifting exhaustive small-case checks to infinite results via entry-point theory and p-adic valuation control, directly supporting the priority open problem "Carmichael's theorem composite case."

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
