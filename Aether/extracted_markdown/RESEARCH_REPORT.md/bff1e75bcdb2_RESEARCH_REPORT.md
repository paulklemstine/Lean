# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Statement

**Theorem (Carmichael, 1913):** For every integer $n \geq 13$, the Fibonacci number $F(n)$ has a *primitive prime divisor*: a prime $p$ such that $p \mid F(n)$ but $p \nmid F(k)$ for all $0 < k < n$.

The exceptions are $n \in \{1, 2, 6, 12\}$, where $F(1) = F(2) = 1$ (no prime factors), $F(6) = 8$ (only factor 2, which divides $F(3) = 2$), and $F(12) = 144 = 2^4 \cdot 3^2$ (2 divides $F(3)$, 3 divides $F(4)$).

## Significance

Carmichael's theorem is a foundational result in the arithmetic of linear recurrence sequences. It connects:

- **Number theory:** The divisibility structure of Fibonacci numbers
- **Algebraic number theory:** Entry points (ranks of apparition) of primes in Lucas sequences  
- **Cyclotomic theory:** The analogue of cyclotomic polynomials for Lucas sequences

The theorem has applications to:
- Primality testing using Lucas sequences
- Algebraic factorization methods
- The study of Zsygmondy-type phenomena in integer sequences

## Formalization Progress

### Fully Proved

1. **GCD Identity** (`fib_prime_dvd_gcd'`): If $p \mid F(n)$ and $p \mid F(k)$, then $p \mid F(\gcd(n,k))$. This is the cornerstone identity, derived from Mathlib's `Nat.fib_gcd`.

2. **Fibonacci Growth** (`fib_gt_one`): $F(n) > 1$ for $n \geq 3$.

3. **Prime Factor Existence** (`fib_has_prime_factor'`): $F(n)$ has a prime factor for $n \geq 3$.

4. **Non-Primitive Reduction** (`non_primitive_to_proper_divisor`): If a prime $p$ divides both $F(n)$ and $F(k)$ for some $0 < k < n$, then $p$ divides $F(d)$ for some proper divisor $d$ of $n$.

5. **Prime Index Case** (`fib_primitive_divisor_of_prime`): For prime $n \geq 3$, every prime factor of $F(n)$ is primitive. This uses the fact that $\gcd(n, k) = 1$ for $0 < k < n$ when $n$ is prime, combined with the GCD identity.

6. **Composite Small Cases** (`fib_primitive_divisor_composite_small`): For composite $n$ with $14 \leq n \leq 50$, verified computationally using explicit primitive prime witnesses and `native_decide`.

### Remaining Gap

The case of **composite $n > 50$** remains as `sorry`. This is the deep case requiring either:

- The **entry point theory** (defining $\alpha(m) = \min\{k > 0 : m \mid F(k)\}$ and proving $m \mid F(n) \iff \alpha(m) \mid n$)
- The **Fibonacci cyclotomic numbers** $\Psi_n = \prod_{d \mid n} F(d)^{\mu(n/d)}$ and the bound $\Psi_n > 1$ for $n \geq 13$
- Analytical bounds from the Binet formula $F(n) = (\varphi^n - \psi^n)/\sqrt{5}$

These require substantial mathematical infrastructure not currently available in Mathlib.

## Key Mathematical Ideas

### Entry Point Theory

For $m > 1$, the *entry point* $\alpha(m)$ is the smallest positive integer $k$ with $m \mid F(k)$. The GCD identity $\gcd(F(m), F(n)) = F(\gcd(m,n))$ implies:

$$m \mid F(n) \iff \alpha(m) \mid n$$

A prime $p$ is primitive for $F(n)$ iff $\alpha(p) = n$.

### Cyclotomic Fibonacci Numbers

Define $\Psi_n = \prod_{d \mid n} F(d)^{\mu(n/d)}$ (Möbius inversion). Then $F(n) = \prod_{d \mid n} \Psi_d$, and any prime dividing $\Psi_n$ (that doesn't divide $n$) has entry point exactly $n$.

Carmichael's theorem reduces to showing $\Psi_n > 1$ for $n \geq 13$, which follows from:

$$|\Psi_n| \geq \varphi^{\phi(n)} - 1 > 1 \text{ for } \phi(n) \geq 1$$

where $\varphi = (1+\sqrt{5})/2$ is the golden ratio and $\phi$ is Euler's totient function.

## Computational Evidence

The theorem was verified computationally for all $n$ from 13 to 60 (see `demo.py`). For each composite $n$, a specific primitive prime witness was found and verified.

## References

- Carmichael, R.D. (1913). "On the numerical factors of the arithmetic forms $\alpha^n \pm \beta^n$." *Annals of Mathematics*.
- Bilu, Y., Hanrot, G., and Voutier, P.M. (2001). "Existence of primitive divisors of Lucas and Lehmer numbers." *Journal für die reine und angewandte Mathematik*.
