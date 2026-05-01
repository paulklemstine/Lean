**Close the Carmichael Composite-Index Gap via Fibonacci LTE and the Primitive-Part Bridge**

We are blocked on the final sorry in `Speculative/CarmichaelPrimitiveDivisor.lean` (and its mirror in `Speculative/AutoResearch/CarmichaelPrimitiveDivisor.lean`) that would upgrade the `native_decide` certification for $n \in [13,10000]$ into a full arithmetic proof for all composite $n > 12$. The surrounding context already contains `non_primitive_to_proper_divisor`, which shows that any non-primitive prime divisor of $F_n$ must already divide $F_d$ for some proper divisor $d \mid n$. What is missing is the exact theorem below, which forces at least one primitive prime divisor to exist for every composite index $n > 12$.

**Target sorry (insert in `Speculative/CarmichaelPrimitiveDivisor.lean`):**

```lean4
theorem exists_primitive_prime_divisor_of_composite {n : ℕ}
    (hn : n > 12) (hcomp : ¬ n.Prime) :
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k := by
  sorry
```

If your local development environment has already defined a bespoke predicate `IsPrimitivePrimeDivisor p n`, the equivalent statement is:

```lean4
theorem Carmichael_composite_case {n : ℕ}
    (hn : n > 12) (hcomp : ¬ n.Prime) :
    ∃ p, IsPrimitivePrimeDivisor p n := by
  sorry
```

**Proof strategy — three non-trivial steps:**

1. **Prove the Fibonacci Lifting-the-Exponent (LTE) lemma.**  
   First establish that if $p$ is an odd prime with entry point $z(p) = m$ — i.e. $p \mid \mathtt{Nat.fib}\;m$ and $p \nmid \mathtt{Nat.fib}\;k$ for all $0 < k < m$ — then for every $e \geq 0$:
   $$v_p(\mathtt{Nat.fib}\;(m \cdot p^e)) = v_p(\mathtt{Nat.fib}\;m) + e.$$
   The induction on $e$ uses `Nat.fib_add` (or `Nat.fib_add_two`) to expand $\mathtt{Nat.fib}\;(m \cdot p^{e+1})$ as a linear combination of $\mathtt{Nat.fib}\;(m \cdot p^e)$ and neighbouring terms. Coprimality of the cofactor to $p$ follows from `Nat.gcd_fib_fib` (yielding $\gcd(F_m, F_{m+1}) = 1$) together with the hypothesis that $p$ is primitive for $m$. Apply `padicValNat` and `padicValNat.mul` to match the valuations on both sides of the addition formula.

2. **Construct the primitive-part bridge via Möbius inversion and the Binet bound.**  
   Define the primitive part
   $$Q(n) \;=\; \prod_{d \mid n} (\mathtt{Nat.fib}\;d)^{\mu(n/d)}.$$
   Prove $Q(n)$ is a positive integer using the strong divisibility property $m \mid n \Rightarrow \mathtt{Nat.fib}\;m \mid \mathtt{Nat.fib}\;n$ (available as `Nat.fib_dvd` or derivable from `Nat.gcd_fib_fib`) and the Möbius inversion machinery in Mathlib (`ArithmeticFunction.moebius`, `Nat.sum_divisors`, `Finset.prod_divisors_filter`). Next derive the analytic lower bound
   $$\log Q(n) \;>\; \varphi(n)\,\log\varphi \;-\; \sum_{d \mid n,\; d < n} \varphi(d)\,\log\varphi \;>\;
   0 \qquad (n > 12\text{ composite})$$
   via the Binet formula. This step requires `Real.log_le_iff_le_exp`, `Nat.totient_eq_card_coprime`, and the divergence of the cyclotomic norm in $\mathbb{Q}(\sqrt{5})$.

3. **Extract the primitive prime divisor by combining the two lemmata above.**  
   By the identity $F_n = \prod_{d \mid n} Q(d)$, any prime dividing $F_n$ but not primitive for $n$ must divide $Q(d)$ for some proper divisor $d \mid n$ (this is exactly where `non_primitive_to_proper_divisor` applies). The LTE lemma from Step 1 controls the exponent with which such a prime can appear in $F_n$: it cannot “use up” the full size of $Q(n)$. Because Step 2 guarantees $Q(n) > 1$, the remaining factor of $Q(n)$ must be divisible by at least one prime $p$ whose entry point is exactly $n$. Use `Nat.exists_prime_and_dvd` on $Q(n)$, then appeal to `Nat.Prime.dvd_mul` and the contrapositive of `non_primitive_to_proper_divisor` to verify that this $p$ does not divide any earlier Fibonacci number.

**Why this matters:**  
Discharging this sorry finishes the first fully formalized, non-computational proof of Carmichael’s 1913 theorem that every $F_n$ with $n > 12$ contains a primitive prime divisor. It removes the last reliance on `native_decide` in the Carmichael files, yielding an eternal arithmetic certificate. More broadly, the Fibonacci-specific LTE bound and the Möbius bridge for Lucas sequences are reusable across the research program — in particular for the open `Niven integration-by-parts integrality lemma` and for future formalization of Bilu-Hanrot-Voutier primitive divisor bounds.

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
