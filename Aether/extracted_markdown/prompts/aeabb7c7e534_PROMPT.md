## Research Task: Fibonacci GCD Identity and Carmichael's Theorem for Composite Indices

Research Mode: PROVE

### Precise Mathematical Framing

**Theorem 1 (Fibonacci GCD Identity).** For all natural numbers $m, n \geq 1$:
$$\gcd(F(m), F(n)) = F(\gcd(m, n))$$

In Lean 4:
```lean
theorem fib_gcd_identity (m n : ℕ) (hm : m > 0) (hn : n > 0) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) := by
  sorry
```

**Theorem 2 (Carmichael Primitive Divisor for Composite Indices).** For all composite $n \geq 6$, there exists a prime $p$ such that $p \mid F(n)$ and $p \nmid F(k)$ for all $1 \leq k < n$:

```lean
theorem carmichael_composite (n : ℕ) (hn : 6 ≤ n) (hcomp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 1 ≤ k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry
```

### Proof Strategy

**For Theorem 1 (fib_gcd_identity):** The proof proceeds by strong induction on $\max(m, n)$, mirroring the Euclidean algorithm:

*Step 1.* Prove the key divisibility lemma: if $d \mid n$ then $F(d) \mid F(n)$. This follows from the identity $F(n) = F(d) \cdot L(n - d) + (-1)^d \cdot F(n - 2d)$ where $L$ is the Lucas sequence, or more directly from $F(a+b) = F(a+1) \cdot F(b) + F(a) \cdot F(b-1)$ by induction on $b$.

*Step 2.* Prove the reduction step: $\gcd(F(m), F(n)) = \gcd(F(m), F(n \mod m))$ when $m \leq n$. This uses the identity $\gcd(F(m), F(n)) = \gcd(F(m), F(n \mod m))$ which follows from $F(n) = q \cdot F(m) + F(n \mod m)$ where $q$ is a suitable integer (derived from Step 1's divisibility and the Fibonacci recurrence).

*Step 3.* Apply strong induction: by the reduction step, $\gcd(F(m), F(n)) = \gcd(F(m), F(n \mod m)) = F(\gcd(m, n \mod m)) = F(\gcd(m, n))$ where the second equality uses the inductive hypothesis (since $n \mod m < n$) and the third is the standard Euclidean algorithm property `Nat.gcd_rec`.

*Step 4.* Handle base cases: when $m = n$, trivially $\gcd(F(n), F(n)) = F(n) = F(\gcd(n, n))$; when $\gcd(m, n) = 1$, prove $\gcd(F(m), F(n)) = 1$ using Step 2 and the fact that consecutive Fibonacci numbers are coprime.

**For Theorem 2 (carmichael_composite):** Building on the GCD identity and the existing LTE/Wall results:

*Step 1.* Factor $n = p_1^{a_1} \cdots p_r^{a_r}$ where $r \geq 2$ or some $a_i \geq 2$ (since $n$ is composite). Let $q$ be the smallest prime factor of $n$.

*Step 2.* By the GCD identity (Theorem 1), any prime dividing both $F(n)$ and $F(k)$ for $k < n$ must divide $F(\gcd(n, k))$. Since $\gcd(n, k) \mid n$ and $k < n$, we have $\gcd(n, k)$ is a proper divisor of $n$.

*Step 3.* Show $F(n) > \prod_{d \mid n, d < n} F(d)$ for $n \geq 6$ composite. Key inequality: $F(n) \geq F(n/q) \cdot F(q) \cdot (F(q) - 1)^{n/q - 1}$ using the divisibility structure and growth rate $F(n) \geq \varphi^{n-2}$ where $\varphi = (1+\sqrt{5})/2$.

*Step 4.* By Zsigmondy-type argument: the product of all $F(d)$ for proper divisors $d$ of $n$ is strictly less than $F(n)$, so $F(n)$ must have a prime factor not dividing any $F(d)$ with $d < n$—this is the primitive prime divisor.

*Step 5.* Handle the exceptional cases ($n = 6$ where $F(6) = 8 = 2^3$ and $2 \mid F(3)$, but $n = 6$ needs separate verification; actually $n = 6$ is not exceptional since $F(6) = 8$ and the primitive divisor is... verify: $F(1)=1, F(2)=1, F(3)=2, F(4)=3, F(5)=5, F(6)=8$. Here $2 \mid F(3)$, so $2$ is not primitive for $F(6)$, and $8 = 2^3$ has no other prime factor. Thus $n = 6$ IS the exception—adjust bound to $n \geq 12$ or handle $n = 6$ separately noting it's the unique exception, consistent with Carmichael's original theorem where $n \in \{1, 2, 6, 12\}$ are exceptional for primitive divisors in the classical sense.)

### Significance

Theorem 1 (Fibonacci GCD identity) is the **linchpin** connecting the divisibility structure of Fibonacci numbers to the Euclidean algorithm—every proof of Carmichael's theorem flows through it. Without this identity formalized in Mathlib, the entire Carmichael primitive divisor program remains blocked.

Theorem 2 resolves the **priority open problem** of Carmichael's theorem for composite indices. The classical Carmichael theorem (1913) states that for $n \notin \{1, 2, 6, 12\}$, $F(n)$ has a primitive prime divisor. The prime case was handled by Zsigmondy; the composite case requires the GCD identity plus careful size estimates. This completes a 100-year-old theorem in Lean 4 and directly enables progress on Wall's conjecture (whether $F(n) \mid F(m)$ implies the entry point of $n$ divides that of $m$).

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

Research domain: gravitational_factoring
Research mode: prove
