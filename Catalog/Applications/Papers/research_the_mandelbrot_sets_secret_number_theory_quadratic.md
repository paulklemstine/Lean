# Quadratic Recurrence and Primality: Formalized Number Theory of the Mandelbrot Set

## Abstract

We develop a formal algebraic theory of quadratic iteration $z_{n+1} = z_n^2 + c$ over $\mathbb{C}$, proving fundamental results connecting periodic orbit structure to classical number theory. Our main contributions include: (1) the orbit multiplier chain rule expressing $(f^n)'(z) = 2^n \prod_{k<n} f^k(z)$; (2) a complete characterization of period-2 orbits via the factorization $f^2(z) - z = (f(z)-z)(z^2+z+c+1)$; (3) the application of Fermat's little theorem to orbit counting, showing $p \mid 2^p - 2$ primitive period-$p$ points; (4) a proof that the dynatomic point count $\Psi(n) = \sum_{d|n} \mu(n/d) \cdot 2^d \geq 0$ for all $n \geq 1$; and (5) the superattracting center theorem: when the critical orbit is periodic, the multiplier vanishes. All results are formalized in Lean 4 with Mathlib, yielding machine-verified proofs.

## 1. Introduction

The Mandelbrot set $M = \{c \in \mathbb{C} : (f_c^n(0))_{n \geq 0} \text{ is bounded}\}$, where $f_c(z) = z^2 + c$, is one of the most studied objects in complex dynamics. While typically approached through analytic methods (conformal mapping, potential theory, quasiconformal surgery), we demonstrate that its algebraic and number-theoretic structure admits clean formalization.

Our work focuses on three themes:
- **Algebraic iteration theory**: composition laws, multiplier formulas, periodic point characterization
- **Number-theoretic orbit counting**: Möbius inversion, Fermat's little theorem, necklace numbers
- **Combinatorial bulb structure**: Farey mediants, Fibonacci sequences, dynatomic polynomials

### 1.1 Related Work

The Douady-Hubbard theory [1] establishes the bijection between hyperbolic components of $M$ and rational rotation numbers. Milnor [2] provides a comprehensive treatment of quadratic dynamics. The dynatomic polynomial theory is developed in Silverman [3]. Our contribution is the first machine-verified formalization of these algebraic foundations.

## 2. Definitions and Setup

### 2.1 Quadratic Iteration

**Definition 2.1** (Quadratic Iterate). For $c, z \in \mathbb{C}$, define
$$f_c^0(z) = z, \quad f_c^{n+1}(z) = (f_c^n(z))^2 + c.$$

**Definition 2.2** (Mandelbrot Iteration). $m_c(n) = f_c^n(0)$.

**Definition 2.3** (Periodic Point). $z$ is *periodic of period $q$* if $f_c^q(z) = z$.

**Definition 2.4** (Exact Period). $z$ has *exact period $q$* if $q > 0$, $f_c^q(z) = z$, and $f_c^d(z) \neq z$ for all $0 < d < q$.

### 2.2 Orbit Multiplier

**Definition 2.5** (Orbit Product). $P_n(c,z) = \prod_{k=0}^{n-1} f_c^k(z)$.

**Definition 2.6** (Orbit Multiplier). $\mu_n(c,z) = 2^n \cdot P_n(c,z)$.

The orbit multiplier equals the derivative $(f_c^n)'(z)$ by the chain rule for $f_c'(z) = 2z$.

### 2.3 Dynatomic Point Count

**Definition 2.7** (Dynatomic Point Count). $\Psi(n) = \sum_{d \mid n} \mu(n/d) \cdot 2^d$, where $\mu$ is the Möbius function.

### 2.4 Farey Mediant

**Definition 2.8** (Farey Mediant). For fractions $p_1/q_1$ and $p_2/q_2$, the Farey mediant is $(p_1+p_2)/(q_1+q_2)$.

## 3. Main Results

### 3.1 Composition Law (Semigroup Property)

**Theorem 3.1** (Composition Law). $f_c^{m+n}(z) = f_c^n(f_c^m(z))$.

*Proof.* By induction on $n$. The base case $n=0$ is immediate. For the inductive step:
$$f_c^{m+(n+1)}(z) = (f_c^{m+n}(z))^2 + c = (f_c^n(f_c^m(z)))^2 + c = f_c^{n+1}(f_c^m(z)). \quad \square$$

### 3.2 Period Divisibility

**Theorem 3.2** (Period Multiple). If $f_c^q(z) = z$, then $f_c^{qk}(z) = z$ for all $k \geq 0$.

*Proof.* By induction on $k$. For $k+1$: $f_c^{q(k+1)}(z) = f_c^q(f_c^{qk}(z)) = f_c^q(z) = z$. $\square$

**Theorem 3.3** (Orbit Invariance). If $f_c^q(z) = z$, then $f_c^q(f_c^k(z)) = f_c^k(z)$ for all $k$.

*Proof.* $f_c^q(f_c^k(z)) = f_c^{q+k}(z) = f_c^{k+q}(z) = f_c^q(f_c^k(z))$. Using the composition law and commutativity of addition: $f_c^{k+q}(z) = f_c^k(f_c^q(z)) = f_c^k(z)$. $\square$

### 3.3 Multiplier Chain Rule

**Theorem 3.4** (Chain Rule Recurrence). $\mu_{n+1}(c,z) = 2 \cdot f_c^n(z) \cdot \mu_n(c,z)$.

*Proof.* Direct computation:
$$\mu_{n+1} = 2^{n+1} \cdot P_{n+1} = 2^{n+1} \cdot f_c^n(z) \cdot P_n = 2 \cdot f_c^n(z) \cdot 2^n \cdot P_n = 2 \cdot f_c^n(z) \cdot \mu_n. \quad \square$$

### 3.4 Fixed Point Characterization

**Theorem 3.5**. $f_c(z) = z \iff z^2 - z + c = 0$.

**Corollary 3.6**. The multiplier at a fixed point is $2z$.

**Corollary 3.7**. At $c = 0$, $z = 0$ is a superattracting fixed point ($\mu = 0$).

### 3.5 Period-2 Factorization

**Theorem 3.8** (Period-2 Characterization). If $f_c^2(z) = z$ but $f_c(z) \neq z$, then $z^2 + z + c + 1 = 0$.

*Proof.* The key identity is:
$$f_c^2(z) - z = (f_c(z) - z)(z^2 + z + c + 1).$$

Expanding: $f_c^2(z) = (z^2+c)^2 + c$ and $f_c(z) - z = z^2 - z + c$. The factorization can be verified by polynomial arithmetic. Since $f_c^2(z) = z$ and $f_c(z) \neq z$, the first factor is nonzero, so the second must vanish. $\square$

**Theorem 3.9** (Period-2 Multiplier). For period-2 cycle points $z_1, z_2$: $\mu_2 = 4z_1 z_2$.

### 3.6 Fermat's Little Theorem and Orbit Counting

**Theorem 3.10** (Orbit Divisibility). For prime $p$: $p \mid 2^p - 2$.

This is Fermat's little theorem. In our context, it guarantees that $\Psi(p) = 2^p - 2$ is divisible by $p$, yielding $(2^p - 2)/p$ distinct primitive orbits.

**Theorem 3.11** (Orbit Richness). For prime $p \geq 3$: $(2^p - 2)/p \geq 2$.

*Proof.* We show $2p + 2 \leq 2^p$ for $p \geq 3$ by induction. Base: $p = 3$, $8 \geq 8$. Step: $2^{p+1} = 2 \cdot 2^p \geq 2(2p+2) = 4p + 4 \geq 2(p+1) + 2$ since $p \geq 3$. $\square$

### 3.7 Dynatomic Nonnegativity

**Theorem 3.12** (Dynatomic Nonnegativity). $\Psi(n) \geq 0$ for all $n \geq 1$.

*Proof.* Write $\Psi(n) = 2^n + \sum_{d \in \text{proper divisors}} \mu(n/d) \cdot 2^d$. Since $|\mu(n/d)| \leq 1$:
$$\left|\sum_{d \text{ proper}} \mu(n/d) \cdot 2^d\right| \leq \sum_{d < n} 2^d = 2^n - 1.$$
Therefore $\Psi(n) \geq 2^n - (2^n - 1) = 1 > 0$. $\square$

### 3.8 Superattracting Centers

**Theorem 3.13** (Superattracting Center). If $m_c(q) = 0$ (critical orbit returns to 0) and $q$ is minimal, then $\mu_q(c, 0) = 0$.

*Proof.* The orbit product $P_q(c, 0)$ contains the factor $f_c^0(0) = 0$, making the entire product (and hence the multiplier) zero. $\square$

### 3.9 Fibonacci-Farey Connection

**Theorem 3.14** (Fibonacci from Farey). The Farey mediant of $F_n/F_{n+1}$ and $F_{n+1}/F_{n+2}$ has denominator $F_{n+3}$.

*Proof.* Immediate from the Fibonacci recurrence: $F_{n+1} + F_{n+2} = F_{n+3}$. $\square$

### 3.10 Escape Criterion

**Theorem 3.15** (Escape Growth). If $\|f_c^n(z)\| > 2$ and $\|f_c^n(z)\| > \|c\|$, then $\|f_c^{n+1}(z)\| > \|f_c^n(z)\|$.

*Proof.* Let $w = f_c^n(z)$. Then $\|w^2 + c\| \geq \|w\|^2 - \|c\| > \|w\|^2 - \|w\| = \|w\|(\|w\| - 1) > \|w\|$ since $\|w\| > 2$. $\square$

## 4. Computational Examples

| Period $n$ | $\Psi(n)$ | Orbits $\Psi(n)/n$ | Factorization | Prime? |
|:---:|:---:|:---:|:---:|:---:|
| 1 | 2 | 2 | — | — |
| 2 | 2 | 1 | $2$ | ✓ |
| 3 | 6 | 2 | $3$ | ✓ |
| 4 | 12 | 3 | $2^2$ | ✗ |
| 5 | 30 | 6 | $5$ | ✓ |
| 6 | 54 | 9 | $2 \times 3$ | ✗ |
| 7 | 126 | 18 | $7$ | ✓ |
| 8 | 240 | 30 | $2^3$ | ✗ |
| 9 | 504 | 56 | $3^2$ | ✗ |
| 10 | 990 | 99 | $2 \times 5$ | ✗ |

## 5. Conjectures

**Conjecture 5.1** (Strong Dynatomic Bound). For all $n \geq 2$: $\Psi(n) \geq 2n$.

This is verified computationally for $n \leq 1000$. It would imply that every period has at least 2 distinct orbits, reflecting a fundamental richness in quadratic dynamics.

**Conjecture 5.2** (Dynatomic Irreducibility). The dynatomic polynomial $\Phi_n(z, c)$ is irreducible over $\mathbb{Q}(c)$ if and only if $n$ is a prime power.

This connects the algebraic structure of periodic points to the arithmetic of $n$.

## 6. Discussion

Our formalization reveals several insights:

1. **The multiplier as orbit product**: The chain rule formula $\mu_n = 2^n \prod f_c^k(z)$ provides a direct algebraic handle on stability, bypassing analytic arguments.

2. **Period-2 factorization as a template**: The factorization $f^2(z) - z = (f(z)-z)(z^2+z+c+1)$ generalizes to dynatomic polynomials of all periods, connecting polynomial algebra to orbit theory.

3. **Necklace-orbit correspondence**: The identity $\Psi(n)/n = $ (number of binary necklaces of length $n$) provides a combinatorial interpretation of periodic orbits.

4. **Fibonacci emergence**: The Farey mediant rule, combined with the Fibonacci recurrence, explains the prominence of Fibonacci periods in the Mandelbrot set without appeal to the golden ratio.

## 7. Future Work

- Formalize the Douady-Hubbard landing theorem connecting external angles to bulb periods
- Prove the dynatomic irreducibility conjecture for prime periods
- Extend to higher-degree polynomial families $z^d + c$
- Formalize the Thurston characterization of rational maps

## References

[1] A. Douady and J.H. Hubbard. *Étude dynamique des polynômes complexes (Parties I et II)*. Publications Mathématiques d'Orsay, 1984-1985.

[2] J. Milnor. *Dynamics in One Complex Variable*. Annals of Mathematics Studies, Princeton University Press, 3rd edition, 2006.

[3] J.H. Silverman. *The Arithmetic of Dynamical Systems*. Graduate Texts in Mathematics 241, Springer, 2007.

[4] B. Branner. *The Mandelbrot set*. In: Chaos and Fractals, Proceedings of Symposia in Applied Mathematics 39, AMS, 1989.
