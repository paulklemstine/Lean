Close the two remaining sorries `wall_base` and `wall_theorem` in `Catalog/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean` by proving Wall's Lifting-the-Exponent Lemma for Fibonacci numbers.

**Exact targets:**

```lean
-- File: Catalog/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean

lemma wall_base (n p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (hpn : p ∣ Nat.fib n) (hn : 2 ≤ n) :
    padicValNat p (Nat.fib (n * p) / Nat.fib n) = 1 := by
  sorry

lemma wall_theorem (n k p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n) (hk : 0 < k) :
    padicValNat p (Nat.fib (n * k)) = padicValNat p (Nat.fib n) + padicValNat p k := by
  sorry
```

**Proof strategy — three steps:**

1. **Lift `fib_div_mod` to modulus `p²` to prove `wall_base`.**
   From the existing `fib_div_mod n k p hp hpn hn hk`, you already know
   `F(nk)/F(n) ≡ k·F(n+1)^{k-1} (mod p)`.
   Prove by induction on `k` the refined congruence
   `F(nk)/F(n) ≡ k·F(n+1)^{k-1} + (k·(k-1)/2)·F(n+1)^{k-2}·F(n) (mod p²)`,
   using the recurrence `F(n(k+1)) = F(n-1)·F(nk) + F(n)·F(nk+1)` (via `Nat.fib_add`), the existing `fib_succ_mul_mod`, and the binomial identity on `F(nk+1)` modulo `p²` (via `Nat.choose` and `Finset.sum_range_succ`). Setting `k = p` gives `F(np)/F(n) ≡ p·F(n+1)^{p-1} (mod p²)` because `p² ∣ C(p,2)·F(n)`. Since `p ∤ F(n+1)` (from `Nat.fib_coprime_fib_succ` and `p | F(n)`), `p²` does not divide `F(np)/F(n)`. Combined with `p | F(np)/F(n)` (from the mod-p case), conclude `padicValNat p (F(np)/F(n)) = 1` using the characterization `padicValNat_eq_iff` through `hp.dvd_of_dvd_pow` and `Nat.not_dvd_ordCompl`.

2. **Iterate `wall_base` to obtain the prime-power case.**
   Prove by induction on `t` that `padicValNat p (Nat.fib (n * p^t)) = padicValNat p (Nat.fib n) + t`.
   The base `t = 0` is trivial. For the inductive step, apply `wall_base` to `n·p^t` instead of `n` (justified because `p | F(n·p^t)` follows from `fib_div_fib_dvd` and `hpn`). Split `F(n·p^{t+1}) = F(n·p^t) · (F(n·p^{t+1})/F(n·p^t))` using `Nat.div_mul_cancel` with `fib_div_fib_dvd`, then apply `padicValNat.mul` to add valuations.

3. **Assemble the general case `wall_theorem` via coprime reduction.**
   Decompose `k = p^t · v` with `p ∤ v` using `Nat.factorization k p`, `Nat.ordProj_dvd`, and `Nat.not_dvd_ordCompl`. From Step 2 you get `padicValNat p (F(n·p^t)) = padicValNat p (F(n)) + t`. From the existing `weak_wall` applied to `n·p^t` and `v` (using `hpn` transited through `fib_div_fib_dvd` to verify `p | F(n·p^t)`), deduce `p ∤ F(n·p^t·v)/F(n·p^t)`, hence `padicValNat p (F(nk)) = padicValNat p (F(n·p^t))`. Assemble with `padicValNat.mul` and `padicValNat.div` using the exact divisibility given by `fib_div_fib_dvd` to reach the final equality `padicValNat p (F(nk)) = padicValNat p (F(n)) + padicValNat p k`.

**Why this is critical:** This closes the algebraic gap in the Carmichael's theorem proof pipeline. `wall_theorem` is the exact Lifting-the-Exponent congruence needed to control p-adic valuations of Fibonacci numbers at composite indices, which in turn lets you prove that primitive prime divisors persist through prime-power and multiplicative extensions of the index. Without it, the entry-point argument in `Carmichael_Primitive_Divisors_for_Composite_Indices_via_Fibonacci_Entry_Points_and_LTE.lean` cannot bridge from the finite computational verification to the infinite mathematical case.

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
