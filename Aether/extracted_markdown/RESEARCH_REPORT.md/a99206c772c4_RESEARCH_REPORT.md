# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## 1. Mathematical Background

Carmichael's theorem (1913) states that for every $n \geq 13$, the Fibonacci number $F(n)$ possesses at least one **primitive prime divisor** — a prime $p$ dividing $F(n)$ that does not divide $F(k)$ for any $0 < k < n$. The exceptional indices where this fails are precisely $n \in \{1, 2, 6, 12\}$.

The theorem rests on the **entry point** (or *rank of apparition*) of a prime $p$, defined as the smallest positive integer $\alpha(p)$ such that $p \mid F(\alpha(p))$. The fundamental GCD identity $\gcd(F(m), F(n)) = F(\gcd(m,n))$ implies that $p \mid F(n)$ if and only if $\alpha(p) \mid n$. Consequently, $p$ is a primitive divisor of $F(n)$ if and only if $\alpha(p) = n$.

For **prime** $n$, the theorem is straightforward: if $p \mid F(n)$, then $\alpha(p) \mid n$, forcing $\alpha(p) \in \{1, n\}$. Since $F(1) = 1$, no prime has entry point 1, so $\alpha(p) = n$.

For **composite** $n$, the argument is substantially more delicate and constitutes the main challenge in this formalization.

## 2. Critical Observation: The Growth Bound Approach is Flawed

The proof sketch initially proposed suggests proving $F(n) > \prod_{d \mid n,\, 0 < d < n} F(d)$ for composite $n \geq 13$. **This inequality is false.** Computational verification shows:

| $n$ | $F(n)$ | $\prod F(d)$ | Holds? |
|-----|---------|--------------|--------|
| 14  | 377     | 13           | ✓      |
| 16  | 987     | 63           | ✓      |
| 24  | 46,368  | 145,152      | **✗**  |
| 30  | 832,040 | 2,684,000    | **✗**  |
| 36  | 14.9M   | ~607M        | **✗**  |

The inequality fails for highly composite numbers starting at $n = 24$. This means the proposed approach of deriving a contradiction from $F(n) \mid \prod F(d)$ via this growth bound **does not work**.

## 3. Correct Approach: Cyclotomic Fibonacci Polynomials

The standard proof of Carmichael's theorem uses the **cyclotomic Fibonacci factorization**. Define:

$$\Phi_n(\alpha, \beta) = \prod_{\substack{\zeta^n = 1 \\ \zeta \text{ primitive}}} (\alpha - \zeta \beta)$$

where $\alpha = (1+\sqrt{5})/2$ and $\beta = (1-\sqrt{5})/2$ are the roots of $x^2 - x - 1 = 0$. Then:

$$F(n) = \prod_{d \mid n} \Phi_d(\alpha, \beta)$$

Key properties:
1. $\Phi_n$ is a positive integer for $n \geq 1$.
2. $|\Phi_n| > 1$ for $n \geq 13$ (and also for $n \in \{7,8,9,10,11\}$).
3. Any prime factor of $\Phi_n$ that does not divide $n$ has entry point exactly $n$.
4. The only prime that can divide both $\Phi_n$ and $n$ is a prime $p$ with $p^2 \mid \Phi_n$, but for $n \geq 13$, $\Phi_n$ has at least one prime factor not dividing $n$.

Property (2) combined with (3)-(4) immediately yields Carmichael's theorem.

## 4. Alternative Approach: LTE + Primitive Part Analysis

An alternative route uses the **Lifting the Exponent Lemma** (LTE) for Fibonacci numbers:

For prime $p \neq 5$ with entry point $\alpha(p) = a$ and $a \mid n$:
$$v_p(F(n)) = v_p(F(a)) + v_p(n/a)$$

This allows computing the "primitive part" $F^*(n) = F(n) / \gcd(F(n), \text{lcm}_{d \mid n,\, d < n} F(d))$.

Analysis shows: $v_p$ contributes to the primitive part exactly when $n/\alpha(p)$ is a power of $p$. The primitive part equals $\prod_p p$ over primes $p$ with this property.

Showing $F^*(n) > 1$ for $n \geq 13$ still requires bounding $\Phi_n$ from below, so this approach ultimately reduces to the cyclotomic one.

## 5. Formalization Status

### Proved
- Entry point theory: $\alpha(p) \mid n$ whenever $p \mid F(n)$ (`fibEntryPt_dvd_of_fib_dvd`)
- Prime case: For prime $n \geq 13$, $F(n)$ has a primitive divisor (`fib_primitive_divisor_prime`)
- GCD identity: $\gcd(F(m), F(n)) = F(\gcd(m,n))$ (`Nat.fib_gcd` in Mathlib)
- Fibonacci divisibility: $m \mid n \Rightarrow F(m) \mid F(n)$ (`Nat.fib_dvd` in Mathlib)
- Basic bounds: $F(n) \geq n$ for $n \geq 6$, $F(n) \leq 2^n$

### Missing (Composite Case)
The composite case requires either:
1. Formalizing cyclotomic Fibonacci polynomials and proving $\Phi_n > 1$ for $n \geq 13$
2. Formalizing LTE for Fibonacci and the primitive part analysis
3. A computational verification approach (decidability + `native_decide`)

### Recommended Strategy
The most feasible formalization path is a **hybrid approach**:
- Verify the theorem computationally for composite $n$ from 4 to some bound $N$ using `native_decide`
- For composite $n > N$, prove $\Phi_n > 1$ using elementary bounds on products over primitive roots of unity

## 6. Theorem Statements

```lean
-- Main theorem (already stated, needs composite case)
theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)

-- Composite case (the key sorry)
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

## 7. Key Helper Lemmas Needed

```lean
-- 1. Lifting the Exponent for Fibonacci
lemma fib_lte (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5)
    (a n : ℕ) (ha : 0 < a) (han : a ∣ n) (hpa : p ∣ Nat.fib a)
    (hmin : ∀ m, 0 < m → m < a → ¬(p ∣ Nat.fib m)) :
    p.factorization (Nat.fib n) = p.factorization (Nat.fib a) + p.factorization (n / a)

-- 2. Cyclotomic Fibonacci bound
lemma cyclotomic_fib_gt_one (n : ℕ) (hn : 13 ≤ n) :
    1 < F(n) / ∏_{d | n, d < n} gcd(F(n), F(d))

-- 3. Primitive part has primitive divisors
lemma primitive_part_entry_point (p n : ℕ) (hp : Nat.Prime p)
    (h : p ∣ Φ_n) (hpn : ¬(p ∣ n)) :
    fibEntryPt p = n
```

## 8. Significance

Carmichael's theorem is foundational in the arithmetic theory of linear recurrence sequences. It generalizes to all Lucas sequences and is a precursor to:
- Zsygmondy's theorem (for $a^n - b^n$)
- Bang's theorem (for $a^n - 1$)
- The Primitive Divisor Theorem for elliptic divisibility sequences

A complete formalization would be a significant contribution to the Mathlib library and to the formal verification of number theory.
