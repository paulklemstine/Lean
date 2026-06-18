**prove** `carmichael_composite_primitive_prime_divisor` in a new file extending `CarmichaelComposite.lean`, building on the divisibility theory, `pisano_period_divides_prime_bound` (`FibonacciPseudoprimes.lean`), `lattice_point_count_bound` (`LatticeFactoring.lean`), and `prime_encoding_bound` (`CompressionExtensions.lean`).

**Target theorem**
```lean
theorem carmichael_composite_primitive_prime_divisor {n : ℕ}
    (hn : n > 12) (hcomp : ¬Nat.Prime n) :
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k := by
```

**Why this matters.**  
This resolves the last open case of Carmichael's 1913 theorem on primitive prime divisors of Fibonacci numbers. All prime-index cases are already provable from classical Zsigmondy theory; the composite-index obstruction is the only remaining barrier in our catalog. Once this theorem is formalized, the full Carmichael theorem (every Fibonacci number $F_n$ with $n>12$ admits a primitive prime divisor) becomes unconditional. This immediately strengthens the pseudoprime density results in `FibonacciPseudoprimes.lean` and completes the number-theoretic foundation for the lattice-factoring security reduction.

**Proof strategy: three steps.**

**Step 1 — Lucas-sequence LTE lemma.** Formalize the valuation-lifting law for Fibonacci numbers:
```lean
lemma lucas_lte {p r t : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2) (hr : r > 0)
    (hrank : ∀ k < r, ¬ p ∣ Nat.fib k) :
    padicValNat p (Nat.fib (r * p ^ t)) = padicValNat p (Nat.fib r) + t := by
```
*Proof path.* Let $L_n$ denote the Lucas companion numbers. Use the identity $F_{rp^t} = F_{rp^{t-1}} L_{rp^{t-1}}$ and the fact that the rank of apparition of $p$ is exactly $r$ (so $p \nmid F_{rp^{t-1}}$). Show that $p \mid L_{rp^{t-1}}$ exactly once; conclude by `padicValNat.mul` and `padicValNat.pow_succ` (Mathlib) that the valuation increments by $1$ at each lifting. The base-case divisibility theory in `CarmichaelComposite.lean` gives the minimality of $r$, and `pisano_period_divides_prime_bound` controls the exceptional residue classes where the rank differs from the Pisano period.

**Step 2 — Exponential bound on the non-primitive factor product.** Define $N_{\text{np}}(n)$ as the product of all non-primitive prime powers dividing $\text{Nat.fib } n$. Prove:
```lean
lemma non_primitive_product_bound {n : ℕ} (hn : n > 100) (hcomp : ¬Nat.Prime n) :
    Nnp n < (φ : ℝ) ^ (n - 2) / Real.sqrt 5 := by
```
*Proof path.* By Step 1, every non-primitive prime $q$ with rank $r \mid n$, $r < n$, contributes at most $\text{padicValNat } q (\text{Nat.fib } r) + \text{padicValNat } q \,n$ to $N_{\text{np}}(n)$. Hence
$$N_{\text{np}}(n) \;\le\; \prod_{d \in n.\text{properDivisors}} (\text{Nat.fib } d)^{\,1 + \text{padicValNat } 2 \,n}.$$
Apply `lattice_point_count_bound` with $k=2$ and $R=n$ to bound the cardinality of `n.properDivisors` by $O(\sqrt{n})$. Apply `prime_encoding_bound` to bound the bit-size of the product in terms of the divisor sum, yielding an upper bound whose base-$\phi$ logarithm is $O(\sqrt{n}\,\log n)$. Use `Real.rpow_le_rpow` and `Finset.prod_le_pow_card` to show this is strictly less than $(n-2)\log\phi - \tfrac12\log 5$ for all composite $n > 100$.

**Step 3 — Analytic dominance and finite discharge.** Prove the Binet-style lower bound
```lean
lemma fib_lower_binet {n : ℕ} (hn : n ≥ 13) :
    (φ ^ n : ℝ) / Real.sqrt 5 - 1 / 2 < (Nat.fib n : ℝ) := by
```
*Proof path.* Induct on $n$ using `Nat.fib_add_two`, the characteristic identity `φ^2 = φ + 1` (derived via `Real.sq_sqrt` and `field_simp`), and `Real.sqrt_pos.mpr` to telescope the rounding error. This gives $\text{Nat.fib } n > \phi^{n-2}$ for all $n \ge 13$. Combine with Step 2: for all composite $n > 10000$,
$$N_{\text{np}}(n) \;<\; \phi^{n-2}/\sqrt{5} \;<\; \text{Nat.fib } n.$$
Since $N_{\text{np}}(n)$ is precisely the product of all non-primitive prime-power factors, strict inequality forces at least one prime divisor of $\text{Nat.fib } n$ to be primitive. For the finite interval $n \in [13, 10000]$, invoke the existing `native_decide` verified corpus (or discharge via a short `native_decide` loop over `Finset.Ioc 12 10000`). Conclude the existence of the primitive prime divisor with `Nat.exists_prime_and_dvd` and the definition of primitivity.

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
