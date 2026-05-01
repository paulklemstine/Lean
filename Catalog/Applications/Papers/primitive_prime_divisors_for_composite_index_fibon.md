# Toward a Machine-Verified Proof of Carmichael's Primitive Divisor Theorem

## Abstract

We present a partial formalization of Carmichael's 1913 theorem on primitive prime divisors of Fibonacci numbers in Lean 4 with Mathlib. The theorem states that for every $n > 12$, the Fibonacci number $F_n$ possesses at least one prime factor that does not divide any earlier Fibonacci number. Our formalization handles the finite case ($n \leq 10000$) via verified computation and reduces the infinite case to Wall's theorem on $p$-adic valuations of Fibonacci numbers (1960). Along the way, we establish several foundational results including the Fibonacci multiplication inequality, the modular congruence for Fibonacci quotients, and a weak form of Wall's theorem.

## 1. Introduction

The Fibonacci sequence $F_0 = 0, F_1 = 1, F_{n+2} = F_n + F_{n+1}$ is one of the most studied objects in number theory. A prime $p$ is called a **primitive prime divisor** of $F_n$ if $p \mid F_n$ but $p \nmid F_k$ for all $0 < k < n$. Equivalently, the **entry point** (or rank of apparition) $\alpha(p) = n$.

**Carmichael's Theorem (1913):** *For every $n \notin \{1, 2, 6, 12\}$, the Fibonacci number $F_n$ has at least one primitive prime divisor.*

The four exceptions are:
- $F_1 = 1$ and $F_2 = 1$ (no prime factors at all)
- $F_6 = 8 = 2^3$ (only prime factor $2$ has $\alpha(2) = 3$)
- $F_{12} = 144 = 2^4 \cdot 3^2$ (prime factors $2, 3$ have $\alpha(2) = 3, \alpha(3) = 4$)

## 2. Key Mathematical Results

### 2.1 Entry Point Theory

For any prime $p$, the **entry point** $\alpha(p)$ is the smallest positive integer $m$ such that $p \mid F_m$. The fundamental property connecting entry points to Fibonacci divisibility is:

$$\gcd(F_m, F_n) = F_{\gcd(m,n)}$$

This identity (available as `Nat.fib_gcd` in Mathlib) immediately implies: $p \mid F_n$ if and only if $\alpha(p) \mid n$.

### 2.2 The Fibonacci Multiplication Inequality

**Theorem (Formalized):** *For $a, b \geq 2$, $F_a \cdot F_b < F_{a \cdot b}$.*

This follows from the Fibonacci addition identity $F_{m+n+1} = F_m F_n + F_{m+1} F_{n+1}$ and the monotonicity of the Fibonacci sequence. We also prove the power bound: $F_a^b \leq F_{a \cdot b}$ for $a \geq 2, b \geq 1$.

### 2.3 Wall's Theorem (Lifting the Exponent for Fibonacci)

**Theorem (Wall, 1960):** *For an odd prime $p$ with $\alpha(p) = m$ and $k \geq 1$:*

$$v_p(F_{mk}) = v_p(F_m) + v_p(k)$$

*where $v_p$ denotes the $p$-adic valuation.*

This deep result is the key technical tool for the infinite case. We establish two intermediate results toward its proof:

1. **Modular congruence:** $F_{nk+1} \equiv F_{n+1}^k \pmod{p}$ when $p \mid F_n$ (formalized using `ZMod`).

2. **Quotient congruence:** $F_{nk}/F_n \equiv k \cdot F_{n+1}^{k-1} \pmod{p}$ (formalized).

3. **Weak Wall's theorem:** If $p \mid F_n$ and $p \nmid k$, then $p \nmid (F_{nk}/F_n)$ (formalized).

The full Wall's theorem requires additionally showing $v_p(F_{np}/F_n) = 1$, which can be approached via the Lifting the Exponent lemma (available in Mathlib as `padicValNat.pow_sub_pow`).

### 2.4 The Primitive Part

For each $n$, we define the **primitive part** $\text{primPart}(n)$ as $F_n$ with all prime factors shared with $F_d$ (for proper divisors $d \mid n$) removed. This is computed by iteratively stripping GCD factors:

```
primPart(n) = foldl(stripAll, F_n, [F_d : d ∈ propDivs(n)])
```

We prove:
- `primPart(n) | F_n` (the primitive part divides the Fibonacci number)
- If `primPart(n) > 1`, then `minFac(primPart(n))` is a primitive prime divisor

### 2.5 Computational Verification

Using Lean's `native_decide`, we verify:

**Theorem:** *For all $n \in [13, 10000]$, either $n$ is prime or $\text{primPart}(n) > 1$.*

Since the theorem for prime $n$ follows from the fact that all prime factors of $F_p$ (for prime $p$) have entry point exactly $p$, this handles Carmichael's theorem for all $n \leq 10000$.

## 3. Proof Architecture

The overall proof structure:

```
fib_carmichael_composite(n, hn: 13 ≤ n, hnp: ¬Prime n)
├── Case n ≤ 10000: primPart_check (native_decide) → primPart_implies_primitive
└── Case n > 10000: primPart_gt_one_large (Wall's theorem) → primPart_implies_primitive
    ├── Subcase: n is a prime power p^k
    │   └── F(p^k)/F(p^{k-1}) > 1, coprime to F(p^{k-1}) by Wall's
    └── Subcase: n has ≥ 2 distinct prime factors
        └── F(n)/(F(a)·F(b)) has primitive prime by Wall's + multiplication ineq.
```

## 4. Discussion

### What We Proved

Our formalization establishes 10 key lemmas:
- `fib_mul_le`, `fib_mul_lt`: Fibonacci addition growth bounds
- `fib_mul_lt'`: The strict multiplication inequality $F_{ab} > F_a F_b$
- `fib_ge_id`: $F_n \geq n$ for $n \geq 5$
- `fib_pow_le`: The power bound $F_a^b \leq F_{ab}$
- `fib_coprime_of_coprime`: Fibonacci coprimality from index coprimality
- `fib_succ_mul_mod`, `fib_div_mod`: Modular congruences for Fibonacci quotients
- `weak_wall`: The $p \nmid k$ case of Wall's theorem
- `primPart_implies_primitive`: Primitive part extraction

### What Remains

Two `sorry` statements remain:

1. **`wall_base`**: $v_p(F_{np}/F_n) = 1$ for odd prime $p \mid F_n$. This is the base case of Wall's theorem and can be proved using the Lifting the Exponent lemma (`padicValNat.pow_sub_pow` in Mathlib).

2. **`primPart_gt_one_large`**: For composite $n > 10000$, $\text{primPart}(n) > 1$. This follows from Wall's theorem combined with the multiplication inequality.

### Connections to Broader Mathematics

Carmichael's theorem is the Fibonacci-specific case of **Zsygmondy's theorem** (1892), which establishes primitive divisors for sequences $a^n - b^n$. The theorem has applications in:

- **Algebraic number theory**: Understanding the factorization of cyclotomic-like expressions
- **Cryptography**: The hardness of discrete logarithm problems in Fibonacci-based groups
- **Combinatorics**: Counting problems involving Lucas sequences

## 5. Conclusion

We have reduced the formalization of Carmichael's theorem to two focused mathematical claims: the base case of Wall's theorem and its application to the primitive part bound. The proof architecture is complete and verified by the Lean type checker, with the remaining work being purely number-theoretic (establishing $p$-adic valuation identities for Fibonacci numbers). This represents significant progress toward a fully machine-verified proof of a century-old theorem in number theory.

## References

1. R.D. Carmichael, "On the numerical factors of the arithmetic forms $\alpha^n \pm \beta^n$," *Annals of Mathematics*, 1913.
2. D.D. Wall, "Fibonacci Series Modulo $m$," *American Mathematical Monthly*, 1960.
3. Yu. Bilu, G. Hanrot, P.M. Voutier, "Existence of primitive divisors of Lucas and Lehmer numbers," *J. Reine Angew. Math.*, 2001.
