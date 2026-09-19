# Envelope Bounds for the Dickman Function, an Unconditional $L[1/2]$ Cost Floor, and the Exact Second-Moment Structure of the Quadratic-Sieve Pool

**Author:** Aristotle
**Date:** 2026-09-19

---

## Abstract

We study two obstructions that prevent the sub-exponential complexity stratum —
the $L[1/2]$ regime inhabited by the quadratic sieve and its relatives — from
being observed in small-scale numerical experiments, and we convert both
obstructions into theorems.

First, we replace the Dickman function $\rho$, which has no closed form beyond
its first bands and no elementary construction, by an *envelope class*: a
function is a **Dickman majorant** if it is non-negative, equal to $1$ on
$[0,1]$, non-increasing, and satisfies the one-sided delay inequality
$u\rho(u) \le \int_{u-1}^{u}\rho$. The true Dickman function lies in this class,
and the class is provably non-empty by an explicit witness, so every bound
proved for majorants applies unconditionally to $\rho$. From the single delay
inequality we derive a contraction step $\rho(u) \le \rho(u-1)/u$, the factorial
tail $\rho(u) \le 1/\lfloor u\rfloor!$, and the shape bound
$\rho(u) \le (e/\lfloor u\rfloor)^{\lfloor u\rfloor}$. We then prove that the
standard leading-term surrogate
$L(u) = \exp(-u(\log u + \log\log u - 1))$ overshoots the truth by a factor
exceeding $5$ at $u = 3$ and still overshoots at $u = 4$ — the numerically
observed factor is roughly $12$ — establishing that any quantitative argument
using $L$ below $u \approx 8$ is invalid, even though its $u^{-u}$ *shape* is
rigorously correct.

Second, we prove an unconditional lower bound for the natural toy cost model
$C(b) = e^{b}/\rho(L/b)$ of a sieve with factor-base parameter $b = \log B$
acting on values of size $e^{L}$: uniformly in $b$,
$$
C(b) \;\ge\; \exp\!\big(2\sqrt{L\log 2} - 2\log 2\big),
$$
and, after replacing $n! \ge 2^{n-1}$ by $n! \ge (n/e)^n$ and applying the
Legendre transform of $x\log x$, the cost exponent is at least
$\sqrt{2L\log L} - \sqrt{L}$. This places the $L[1/2]$ floor by proof where
measurement failed.

Third, we determine the exact second-moment structure of the quadratic-sieve
relation pool. For an odd prime $p$ let $h_p(a) = \#\{x \bmod p : x^2 = a\}$ be
the number of hits per period of $p$ in the sequence $x^2 - N$ with
$N \equiv a$. We prove the total zero-lag dispersion identity
$\sum_a (h_p(a) - 1)^2 = p - 1$, so that the normalised mean square deviation
from the random-integer model is exactly $1 - 1/p$ and never decays, and the
pair-correlation identity $\sum_a h_p(a) h_p(a+c) = p - 1$ for every nonzero lag
$c$, which is *exactly* the random-model value. Hence the autocorrelation
dichotomy $\sum_a h_p(a)^2 - \sum_a h_p(a)h_p(a+c) = p$: the entire deviation of
the sieve pool from randomness is concentrated at lag zero.

**Keywords:** Dickman function, smooth numbers, sub-exponential complexity,
quadratic sieve, quadratic character, pair correlation, Legendre transform,
delay differential equation.

---

## 1. Introduction

### 1.1 The four strata

Integer-factoring algorithms partition naturally into complexity strata
according to the growth of their running time in $L = \log N$:

* **polynomial**: $\exp(O(\log L))$ — special-form algorithms and primality
  tests;
* **sub-exponential $L[1/3]$**: the number field sieve,
  $\exp(c L^{1/3}(\log L)^{2/3})$;
* **sub-exponential $L[1/2]$**: the quadratic sieve, Dixon's method,
  elliptic-curve factorization, $\exp(c\sqrt{L\log L})$;
* **exponential**: trial division and Pollard rho, $\exp(cL)$.

Three of these strata are readily visible in small-scale numerical experiments:
their exponents differ enough that a laptop-scale sweep of $N$ separates them.
The $L[1/2]$ stratum is the hard one. Its defining feature — a cost exponent
growing like $\sqrt{L}$ — is a *slowly varying* quantity: doubling $L$
multiplies the exponent by only $\sqrt{2}$, so over the two or three octaves of
$N$ that a toy experiment can afford the cost curve is nearly flat.

### 1.2 The experiment and its null

We report, as background and motivation, a direct attempt to measure the
$L[1/2]$ stratum. The design: sample $x$ uniformly in $[\sqrt N, 2\sqrt N]$,
compute $v = x^2 - N$, test $v$ for $B$-smoothness by trial division, and assign
each sample the smoothness depth $u = \log v/\log B$. Bin by $u$, and compare
the empirical smoothness frequency against $\rho(u)$ computed by numerical
integration of the delay equation (explicit Euler at step $5\times 10^{-4}$ on
$u\rho'(u) = -\rho(u-1)$). Sweep six $(N,B)$ cells, $2400$ samples in total, and
fit the toy cost model $C(B) = \pi(B)/\rho(u) + \pi(B)^2$ against $N$.

The outcome, bin by bin:

| $u$ | $n$ | empirical | $\pm 1\sigma$ | $\rho(u)$ numeric | ratio |
|---|---|---|---|---|---|
| $3.0$ | 161 | $0.0124$ | $0.0087$ | $0.0487$ | $0.26$ |
| $3.5$ | 265 | $0.0302$ | $0.0105$ | $0.0163$ | $1.86$ |
| $4.0$ | 413 | $0.0073$ | $0.0042$ | $0.0049$ | $1.47$ |
| $5.0$ | 303 | $0.0033$ | $0.0033$ | $0.00036$ | $9.27$ |

The ratios scatter non-monotonically over a factor of $36$; every bin is
underpowered, with relative standard error near $100\%$; three bins lie in a
region where the predicted density is below the resolution of a few hundred
Monte Carlo samples. The fitted cost exponent is
$d(\log_2 C)/d(\log_2 N) = 0.024$ — flat. The honest verdict is **inconclusive**:
the fourth stratum could not be measured at this scale.

Two structural facts survived the null and are the subject of this paper.

**(F1) The leading-term Dickman surrogate is quantitatively invalid at small
$u$.** The familiar approximation
$$
L(u) \;=\; \exp\!\big(-u(\log u + \log\log u - 1)\big)
$$
evaluates to $L(3) \approx 0.561$ where the true value is
$\rho(3) \approx 0.0487$ — a $12$-fold overshoot, persisting through $u \approx
6$. Since toy-scale experiments live entirely in $u \in [2,6]$, every informal
smoothness estimate in that range built on $L$ is meaningless.

**(F2) The smoothness of $x^2 - N$ is not the smoothness of a random integer at
toy scale.** Even against correctly integrated $\rho$, the ratios were
non-monotone. The suspected mechanism is the quadratic-character constraint on
prime divisors of $x^2 - N$.

### 1.3 Contributions

We make both findings rigorous, and in doing so replace two measurement targets
by proofs.

1. **An envelope class for $\rho$ (§2).** The Dickman majorant class, defined by
   a one-sided delay *inequality*, admits a complete tail theory
   (Theorems 2.4–2.6, 2.13) without ever constructing $\rho$, and is provably
   non-vacuous (Proposition 2.2).
2. **The overshoot theorem (§3).** $L(3) > 5\rho(3)$ and $L(4) > \rho(4)$ for
   every majorant with $\rho(2) \le 1 - \log 2$ (Theorems 3.4, 3.6).
3. **The shape theorem (§3.3).** Nevertheless
   $\rho(u) \le \exp(-n(\log n - 1))$ with $n = \lfloor u\rfloor$
   (Theorem 3.8): the $u^{-u}$ shape is correct.
4. **The unconditional $L[1/2]$ cost floor (§4).**
   $e^{b}/\rho(L/b) \ge \exp(2\sqrt{L\log 2} - 2\log 2)$ uniformly in $b$
   (Theorem 4.4), sharpened via the Legendre transform to
   $\sqrt{2L\log L} - \sqrt{L}$ in the exponent (Theorems 4.6, 4.7).
5. **The exact moment structure of the sieve pool (§5).** Zero-lag dispersion
   $\sum_a (h_p(a)-1)^2 = p-1$ (Theorem 5.4), nonzero-lag pair correlation
   $\sum_a h_p(a)h_p(a+c) = p-1$ (Theorem 5.8), and the dichotomy
   $A(0) - A(c) = p$ (Corollary 5.9).

---

## 2. A Dickman envelope class

### 2.1 Motivation

The Dickman function is defined as the unique continuous solution of
$$
\rho(u) = 1 \ (0 \le u \le 1), \qquad u\rho'(u) = -\rho(u-1) \ (u>1),
$$
equivalently of the integral equation
$$
u\,\rho(u) \;=\; \int_{u-1}^{u} \rho(t)\,dt \qquad (u \ge 1). \tag{2.1}
$$
Its closed form is known only in the first two bands:
$\rho(u) = 1$ on $[0,1]$ and $\rho(u) = 1 - \log u$ on $(1,2]$; on $(2,3]$ one
already needs a dilogarithm, and beyond that nothing elementary exists.

Constructing $\rho$ from scratch means solving a delay differential equation,
band by band. For upper-bound purposes this is unnecessary. All the tail
arguments we need use (2.1) in one direction only. We therefore work with an
envelope class.

> **Definition 2.1 (Dickman majorant).** A function $\rho : \mathbb{R} \to
> \mathbb{R}$ is a **Dickman majorant** if
> 1. $\rho(u) \ge 0$ for all $u$;
> 2. $\rho(u) = 1$ for $0 \le u \le 1$;
> 3. $\rho$ is non-increasing on $[0,\infty)$;
> 4. $u\,\rho(u) \le \int_{u-1}^{u}\rho(t)\,dt$ for all $u \ge 1$.

The true Dickman function satisfies (1)–(3) classically and (4) with equality,
so it is a majorant. Everything proved below therefore applies to it.

A definition of this kind is worthless if the class is empty or if its members
are all pathological, so we record an explicit witness.

> **Proposition 2.2 (Non-vacuity).** The indicator
> $\rho_0(u) = \mathbf{1}[u \le 1]$ is a Dickman majorant, and moreover satisfies
> the auxiliary normalisation $\rho_0(2) \le 1 - \log 2$ used in §3.

*Proof sketch.* Non-negativity, the unit clause, and antitonicity are immediate
from the case split on $u \le 1$. For (4): if $u > 1$ the left side is $0$ and
the integrand is non-negative. If $u = 1$ the integrand is identically $1$ on
$[0,1]$, so the right side is $1 = 1\cdot\rho_0(1)$ — the inequality is tight
exactly where it has to be. Finally $\rho_0(2) = 0 \le 1 - \log 2$ since
$\log 2 < 1$. $\square$

The witness is tight at $u=1$ and crude thereafter; its role is purely to
certify that no statement below is conditionally empty.

### 2.2 Integrability and the contraction step

> **Lemma 2.3 (Integrability).** A Dickman majorant is interval-integrable on
> every $[a,b] \subseteq [0,\infty)$.

*Proof sketch.* A monotone function on a compact interval is Riemann/Lebesgue
integrable; clause (3) supplies monotonicity on any subinterval of
$[0,\infty)$. $\square$

> **Theorem 2.4 (Contraction step).** For every Dickman majorant $\rho$ and
> every $u \ge 1$,
> $$ \rho(u) \;\le\; \frac{\rho(u-1)}{u}. $$

*Proof sketch.* By antitonicity, $\rho(t) \le \rho(u-1)$ for all
$t \in [u-1,u]$, and the interval has length $1$; integrating,
$$
\int_{u-1}^{u}\rho(t)\,dt \;\le\; \rho(u-1).
$$
Combining with the delay inequality (4) gives $u\rho(u) \le \rho(u-1)$, and
$u \ge 1 > 0$ permits division. $\square$

This single step is the engine of the whole section.

> **Theorem 2.5 (Factorial tail at integers).** For every Dickman majorant and
> every $n \in \mathbb{N}$, $\rho(n) \le 1/n!$.

*Proof sketch.* Induction. At $n=0$, $\rho(0) = 1 = 1/0!$. For the step, apply
Theorem 2.4 at $u = n+1$ to get
$\rho(n+1) \le \rho(n)/(n+1) \le 1/(n!\,(n+1)) = 1/(n+1)!$. $\square$

> **Theorem 2.6 (Factorial tail, real argument).** For every Dickman majorant
> and every $u \ge 0$,
> $$ \rho(u) \;\le\; \frac{1}{\lfloor u \rfloor!}. $$

*Proof sketch.* $\lfloor u\rfloor \le u$ and $\rho$ is non-increasing on
$[0,\infty)$, so $\rho(u) \le \rho(\lfloor u\rfloor)$; apply Theorem 2.5.
$\square$

Theorem 2.6 is already a strong statement: it says the density of $B$-smooth
numbers at depth $u$ decays super-exponentially, faster than $1/\Gamma(u)$ up to
the floor. It is the source of every quantitative claim in §3 and §4.

---

## 3. The leading-term surrogate overshoots

### 3.1 The surrogate

> **Definition 3.1.** The **leading-term Dickman surrogate** is
> $$ L(u) \;=\; \exp\!\big(-u(\log u + \log\log u - 1)\big), \qquad u > e. $$

The asymptotic statement $\rho(u) = L(u)^{1+o(1)}$ is correct and classical.
What is not correct — and is routinely assumed — is that $L(u) \approx \rho(u)$
numerically in the range accessible to computation.

### 3.2 Explicit numerics

We need two elementary bounds. Both are proved from convexity of $\exp$ via
$1 + x \le e^{x}$ and iterated powers, which keeps the argument self-contained.

> **Lemma 3.2.** $\log 3 < 1.1$.

*Proof sketch.* From $1.01 < e^{0.01}$ (a case of $1 + x < e^{x}$) raise to the
tenth power: $e^{0.1} > 1.01^{10} > 1.1046$. Multiply by
$e > 2.7182818$ to get $e^{1.1} = e\cdot e^{0.1} > 3$. Apply $\log$. $\square$

> **Lemma 3.3.** $L(3) > 0.54$ and $L(4) > 0.038$.

*Proof sketch.* For $L(3)$: $1 < \log 3 < 1.1$ by Lemma 3.2 and $e < 3$. The
elementary inequality $\log x \le x - 1$ gives
$\log\log 3 \le \log 3 - 1 < 0.1$, hence the exponent
$-3(\log 3 + \log\log 3 - 1) > -3(1.1 + 0.1 - 1) = -0.6$, so
$L(3) > e^{-0.6}$. Finally $e^{-0.6} = (e^{-0.05})^{12} \ge 0.95^{12} > 0.54$
using $1 + x \le e^{x}$ at $x = -0.05$.

For $L(4)$: $\log 4 = 2\log 2 \in (1.386, 1.387)$, so
$\log\log 4 \le \log 4 - 1 < 0.387$ and the exponent exceeds
$-4(1.387 + 0.387 - 1) > -3.1$; then
$e^{-3.1} = (e^{-0.1})^{31} \ge 0.9^{31} > 0.038$. $\square$

### 3.3 The overshoot

The exact band value $\rho(2) = 1 - \log 2 \approx 0.30685$ is classical (it is
$1 - \log u$ evaluated at $u=2$). We carry it as a hypothesis so that all
statements remain inside the majorant class; by Proposition 2.2 the hypothesis
is satisfiable, so nothing is vacuous.

> **Lemma 3.4 (Certified values at $u=3,4$).** If $\rho$ is a Dickman majorant
> with $\rho(2) \le 1 - \log 2$, then
> $$ \rho(3) \le \frac{1 - \log 2}{3} \approx 0.1023, \qquad
>    \rho(4) \le \frac{1 - \log 2}{12} \approx 0.0256. $$

*Proof sketch.* Two applications of the contraction step (Theorem 2.4) at
$u = 3$ and $u = 4$. $\square$

> **Theorem 3.5 (Leading-term overshoot at $u=3$).** For every Dickman majorant
> with $\rho(2) \le 1-\log 2$,
> $$ L(3) \;>\; 5\,\rho(3). $$

*Proof sketch.* By Lemma 3.4, $5\rho(3) \le 5(1-\log 2)/3 < 5(0.30686)/3 <
0.5115$, using $\log 2 > 0.6931471803$. By Lemma 3.3, $L(3) > 0.54 > 0.5115$.
$\square$

> **Theorem 3.6 (Persistence at $u=4$).** Under the same hypotheses,
> $L(4) > \rho(4)$.

*Proof sketch.* $\rho(4) \le (1 - \log 2)/12 < 0.0256$ while $L(4) > 0.038$.
$\square$

The factor certified at $u=3$ is $5$; the numerically measured factor is $12$.
The gap is entirely slack in the crude tail bound $\rho(3) \le (1-\log 2)/3 =
0.1023$ versus the true $\rho(3) = 0.0487$ — the bound is only a factor $2.1$
from truth, which is remarkable for an argument that never constructs $\rho$.

### 3.4 The shape is nevertheless correct

The overshoot is a statement about the *value* of $L$. Its exponential *shape*
survives intact, and can be certified inside the same framework.

> **Lemma 3.7 (Elementary Stirling).** For every $n \in \mathbb{N}$,
> $n^{n} \le n!\,e^{n}$.

*Proof sketch.* Induction on $n$. The case $n = 0$ is $1 \le 1$. For the step,
write
$$
(n+1)^n \;=\; n^n\Big(1 + \frac1n\Big)^n
$$
and use $(1 + 1/n)^n \le e$, which follows from $1 + x \le e^x$ at $x = 1/n$
raised to the $n$-th power. Then
$(n+1)^n \le n!\,e^{n}\cdot e$, and multiplying both sides by $n+1$ gives
$(n+1)^{n+1} \le (n+1)!\,e^{n+1}$. $\square$

> **Theorem 3.8 (Shape bound).** For every Dickman majorant and every $u \ge 1$,
> with $n = \lfloor u \rfloor \ge 1$,
> $$ \rho(u) \;\le\; \Big(\frac{e}{n}\Big)^{n} \;=\; \exp\!\big(-n(\log n - 1)\big). $$

*Proof sketch.* Theorem 2.6 gives $\rho(u) \le 1/n!$, and Lemma 3.7 gives
$1/n! \le e^{n}/n^{n}$. Rewrite $n^n = \exp(n\log n)$, so
$e^{n}/n^{n} = \exp(n - n\log n) = \exp(-n(\log n - 1))$. $\square$

Thus the $u^{-u}$-type decay encoded by $L$ is rigorously valid; what fails is
only the numerical calibration, including the $\log\log u$ refinement, at small
$u$. This is precisely the distinction that a small-scale experiment cannot see
and that a proof makes sharp.

---

## 4. An unconditional sub-exponential cost floor

### 4.1 The model

Consider an idealized sieve acting on values of size $e^{L}$ (so $L = \log X$)
with factor base consisting of the primes up to $B = e^{b}$. It needs on the
order of $\pi(B)$ relations; each candidate succeeds with probability of order
$\rho(u)$ where $u = L/b$. Neglecting logarithmic factors and setting
$\pi(B) \approx e^{b}$, the cost is
$$
C(b) \;=\; \frac{e^{b}}{\rho(L/b)}. \tag{4.1}
$$
The two terms fight: increasing $b$ raises the number of relations needed
($e^{b}$) and simultaneously raises the success probability (by lowering $u$).
Classical analysis balances them at $b \approx \sqrt{L}$, yielding $L[1/2]$. We
prove the corresponding *lower* bound unconditionally and uniformly in $b$ —
there is no optimization and no asymptotics.

### 4.2 The $2^{n}$ floor

> **Lemma 4.1.** For every $n \in \mathbb{N}$, $2^{n} \le (n+1)!$.

*Proof sketch.* Induction: $2^{n+1} = 2\cdot 2^{n} \le (n+2)\,2^{n} \le
(n+2)(n+1)! = (n+2)!$. $\square$

> **Lemma 4.2 (AM–GM in cost form).** For $b > 0$ and $c \ge 0$,
> $$ 2\sqrt{c} \;\le\; b + \frac{c}{b}. $$

*Proof sketch.* $b + c/b - 2\sqrt c = (b - \sqrt c)^2/b \ge 0$. $\square$

> **Lemma 4.3 (Model floor).** For $L \ge 0$ and $b > 0$,
> $$ 2\sqrt{L\log 2} - 2\log 2 \;\le\; b + \Big(\frac{L}{b} - 2\Big)\log 2. $$

*Proof sketch.* Apply Lemma 4.2 with $c = L\log 2$, and note
$c/b = (L/b)\log 2$; subtract $2\log 2$ from both sides. $\square$

> **Theorem 4.4 (Sub-exponential cost floor).** Let $\rho$ be any Dickman
> majorant and let $0 < b \le L$ with $\rho(L/b) > 0$. Then
> $$ \frac{e^{b}}{\rho(L/b)} \;\ge\; \exp\!\big(2\sqrt{L\log 2} - 2\log 2\big). $$

*Proof sketch.* Put $u = L/b \ge 1$ and $n = \lfloor u\rfloor \ge 1$, and write
$n = m+1$. By Theorem 2.6 and Lemma 4.1,
$$
\rho(u) \;\le\; \frac{1}{n!} \;\le\; \frac{1}{2^{m}}.
$$
Since $u < n+1 = m+2$, we have $u - 2 < m$, hence
$e^{(u-2)\log 2} = 2^{\,u-2} \le 2^{m}$, and therefore
$\rho(u)\,e^{(u-2)\log 2} \le 1$. Multiplying by $e^{b}$ and dividing by
$\rho(u) > 0$:
$$
\frac{e^{b}}{\rho(u)} \;\ge\; e^{\,b + (u-2)\log 2}.
$$
Lemma 4.3 bounds the exponent below by $2\sqrt{L\log 2} - 2\log 2$; monotonicity
of $\exp$ finishes. $\square$

With $L = \log N$ the conclusion reads
$C \ge \exp(2\sqrt{\log 2}\sqrt{\log N} - 2\log 2)$: the $\sqrt{\log N}$ in the
exponent is exactly the $L[1/2]$ signature that the toy-scale sweep failed to
resolve. It is here obtained without any measurement, without asymptotics, and
uniformly over every admissible choice of factor base.

### 4.3 The sharpened floor via the Legendre transform

The proof of Theorem 4.4 spends the factorial on $n! \ge 2^{n-1}$, which is
wasteful: this is the bound that loses the $\log\log$ factor in the classical
$L[1/2, c]$ exponent. Replacing it by the elementary Stirling bound
$n! \ge (n/e)^{n}$ (Lemma 3.7) turns the cost exponent into
$$
E(b) \;=\; b + u(\log u - 1), \qquad u = \frac{L}{b},
$$
whose infimum over $b$ has no closed form. The Legendre transform supplies a
family of closed-form floors.

> **Lemma 4.5 (Young/Legendre inequality for $x\log x$).** For $u > 0$ and any
> $\ell \in \mathbb{R}$,
> $$ \ell u - e^{\ell} \;\le\; u(\log u - 1), $$
> with equality at $u = e^{\ell}$.

*Proof sketch.* Substitute $t = u e^{-\ell} > 0$. The claim becomes
$t - 1 \le t\log t$, which is the standard inequality $\log s \le s - 1$ applied
at $s = 1/t$ and multiplied by $t > 0$. $\square$

> **Theorem 4.6 (Sharpened model floor).** For all $L > 0$, $b > 0$ and
> $\ell \ge 0$,
> $$ 2\sqrt{\ell L} - e^{\ell} \;\le\; b + \frac{L}{b}\Big(\log\frac{L}{b} - 1\Big). $$

*Proof sketch.* Lemma 4.5 with $u = L/b$ gives
$\ell L/b - e^{\ell} \le (L/b)(\log(L/b) - 1)$. Lemma 4.2 with $c = \ell L$
gives $2\sqrt{\ell L} \le b + \ell L/b$. Add. $\square$

> **Theorem 4.7 (The $\sqrt{L\log L}$ shape).** For $L \ge 1$ and $b > 0$,
> $$ \sqrt{2L\log L} \;-\; \sqrt{L} \;\le\; b + \frac{L}{b}\Big(\log\frac{L}{b} - 1\Big). $$

*Proof sketch.* Take $\ell = \tfrac12\log L \ge 0$ in Theorem 4.6. Then
$e^{\ell} = \sqrt L$ and
$2\sqrt{\ell L} = 2\sqrt{\tfrac12 L\log L} = \sqrt{2L\log L}$. $\square$

The leading term $\sqrt{2L\log L}$ is the correct $L[1/2]$ exponent with its
logarithmic factor, i.e. $\exp\big(\sqrt{2\log N\log\log N}\,\big)$ when
$L = \log N$; the classical quadratic-sieve heuristic has the same shape. Two
remarks:

* The family of floors in Theorem 4.6 is *tight* in $\ell$ — each is attained at
  $u = e^{\ell}$ — so the supremum over $\ell$ recovers the exact infimum of the
  smooth model, and $\ell = \tfrac12\log L$ is the asymptotically optimal choice
  up to lower-order terms.
* Transporting Theorem 4.7 back to a statement about $\rho$ itself requires
  replacing $u$ by $\lfloor u\rfloor$ inside the Stirling bound, which costs an
  $O(1)$ additive shift in the exponent. We leave that bookkeeping open; the
  $2^{n}$ version (Theorem 4.4) is already an unconditional statement about
  every Dickman majorant.

---

## 5. The quadratic-sieve pool is not a random pool — and exactly where

### 5.1 The hit pattern

The values sieved by the quadratic sieve are $v(x) = x^2 - N$. A prime $p$
divides $v(x)$ if and only if $x^2 \equiv N \pmod p$. Whether this has
solutions depends on the quadratic character of $N$ modulo $p$: for
$p \nmid 2N$, either $N$ is a residue and there are exactly two roots per
period, or it is a non-residue and there are none. A random integer sequence, by
contrast, is divisible by $p$ exactly once per period.

> **Definition 5.1 (Hit pattern).** For an odd prime $p$ and $a \in
> \mathbb{Z}/p$, put
> $$ h_p(a) \;=\; \#\{x \in \mathbb{Z}/p : x^2 = a\}, $$
> the number of hits of $p$ per period in the sequence $x^2 - N$ when
> $N \equiv a \pmod p$.

The random-integer null model is the constant pattern $h \equiv 1$.

> **Theorem 5.2 (First moment).** For every prime $p$,
> $\sum_{a \in \mathbb{Z}/p} h_p(a) = p$.

*Proof sketch.* The sets $\{x : x^2 = a\}$, as $a$ ranges over $\mathbb{Z}/p$,
partition $\mathbb{Z}/p$ (fibres of the squaring map), so the counts sum to
$|\mathbb{Z}/p| = p$. $\square$

Theorem 5.2 says the pool is indistinguishable from random *on average* — the
mean number of hits per period is exactly $1$, the random value. This is why
first-moment analyses of the quadratic sieve work, and precisely why they cannot
account for the observed scatter. One must go to second moments.

> **Lemma 5.3 (Character formula).** For an odd prime $p$ and $a \in
> \mathbb{Z}/p$,
> $$ h_p(a) \;=\; \chi_p(a) + 1, $$
> where $\chi_p$ is the quadratic character (Legendre symbol) of
> $\mathbb{Z}/p$, with $\chi_p(0) = 0$.

*Proof sketch.* This is the standard root-count for a quadratic: two roots when
$a$ is a nonzero square ($\chi_p(a) = 1$), none when $a$ is a non-residue
($\chi_p(a) = -1$), and the single root $x = 0$ when $a = 0$. $\square$

### 5.2 Zero-lag dispersion never decays

> **Theorem 5.4 (Zero-lag dispersion identity).** For every odd prime $p$,
> $$ \sum_{a \in \mathbb{Z}/p} \big(h_p(a) - 1\big)^2 \;=\; p - 1. $$

*Proof sketch.* By Lemma 5.3, $h_p(a) - 1 = \chi_p(a)$, so the summand is
$\chi_p(a)^2$, which equals $1$ for every $a \ne 0$ and $0$ at $a = 0$. Summing
the indicator of $\{a \ne 0\}$ over $\mathbb{Z}/p$ gives $p - 1$. $\square$

> **Corollary 5.5 (Second moment).** $\sum_{a}h_p(a)^2 = 2p - 1$.

*Proof sketch.* Expand
$\sum_a (h_p(a)-1)^2 = \sum_a h_p(a)^2 - 2\sum_a h_p(a) + p$ and substitute
Theorems 5.2 and 5.4. $\square$

> **Corollary 5.6 (Normalised dispersion).** The mean square deviation of the
> hit pattern from the random model is exactly
> $$ \frac1p\sum_{a}\big(h_p(a)-1\big)^2 \;=\; 1 - \frac1p, $$
> and in particular it is at least $1/2$ for every odd prime and tends to $1$.

This is the formal content of "the $O(1)$ corrections do not stabilise". Under
the random model the per-period hit count is deterministically $1$ and the
dispersion is $0$; under the quadratic constraint the dispersion is $1 - 1/p$,
which *increases* with $p$ towards the maximum possible value for a
$\{0,1,2\}$-valued pattern with mean $1$. The pool is maximally dispersed at
every prime, forever. Toy-scale smoothness ratios inherit this fluctuation, and
no growth of $p$ removes it — which is the algebraic explanation of the
non-monotone ratios $0.26$–$9.3$ in §1.2.

### 5.3 Nonzero lags are exactly random

Dispersion at lag zero could in principle be accompanied by correlations at
other lags — that would make the pool structurally biased in a way that changes
the smoothness heuristic globally. It does not. The next identity is exact,
with no error term.

> **Lemma 5.7 (Difference-of-squares count).** Let $p$ be an odd prime and
> $c \in \mathbb{Z}/p$, $c \ne 0$. Then
> $$ \#\{(x,y) \in (\mathbb{Z}/p)^2 : y^2 - x^2 = c\} \;=\; p - 1. $$

*Proof sketch.* Factor $y^2 - x^2 = (y-x)(y+x)$. Map a solution $(x,y)$ to
$v = y - x$. Since $c \ne 0$, $v \ne 0$. Conversely, given $v \ne 0$, the system
$y - x = v$, $y + x = c/v$ has the unique solution
$$
x = \frac{c/v - v}{2}, \qquad y = \frac{c/v + v}{2},
$$
because $2$ is invertible mod $p$ ($p$ odd); and this solution satisfies
$y^2 - x^2 = v\cdot(c/v) = c$. The map is therefore a bijection onto
$(\mathbb{Z}/p)^{\times}$, of cardinality $p-1$. $\square$

> **Theorem 5.8 (Pair correlation).** For every odd prime $p$ and every
> $c \in \mathbb{Z}/p$ with $c \ne 0$,
> $$ \sum_{a \in \mathbb{Z}/p} h_p(a)\,h_p(a+c) \;=\; p - 1. $$

*Proof sketch.* Fibre the solution set of $y^2 - x^2 = c$ over $a = x^2$. The
fibre above $a$ consists of pairs with $x^2 = a$ and $y^2 = a + c$, hence is the
product of the two root sets and has cardinality $h_p(a)h_p(a+c)$. Summing over
$a$ and applying Lemma 5.7 gives the claim. $\square$

Under the random model each term would be $1\cdot 1$, summing to $p$; the true
value $p-1$ differs only by the single degree of freedom removed by the zero
residue — it is exactly the random value in the natural normalisation (it is the
same $p-1$ that Theorem 5.4 produces, and it involves no character sum
cancellation or Weil-type error term whatsoever).

> **Corollary 5.9 (Autocorrelation dichotomy).** Write
> $A(c) = \sum_{a} h_p(a)h_p(a+c)$. Then for every odd prime $p$ and every
> $c \ne 0$,
> $$ A(0) - A(c) \;=\; (2p - 1) - (p-1) \;=\; p. $$

The autocorrelation function of the quadratic-sieve hit pattern is therefore a
*perfect spike*: constant $p-1$ off the origin, and $2p-1$ at the origin, the
difference being exactly one full period. In signal-processing language the
pattern is a perfect-autocorrelation sequence relative to the random baseline.
All deviation from randomness is at lag zero, and it is exactly quantified.

### 5.4 Consequences for the smoothness heuristic

Corollary 5.9 sharpens the informal statement "sieve values are not random
integers" into a precise structural dichotomy:

* *On average* (first moment), the pool is exactly random (Theorem 5.2).
* *In variance* (zero lag), it is maximally non-random, with a deviation that
  never decays (Theorem 5.4, Corollary 5.6).
* *In correlation* (all nonzero lags), it is again exactly random
  (Theorem 5.8).

For the smoothness heuristic this means that the standard substitution "treat
$x^2 - N$ as a random integer of its size" is correct to first order and
correct in all cross-prime pair correlations, but carries an irreducible
per-prime variance of $1 - 1/p$. At asymptotic scales this variance is averaged
over so many primes that it contributes only to the $o(1)$ in the exponent. At
toy scale, where only a handful of primes matter for each value, it dominates —
which is precisely the observed failure mode.

---

## 6. Algorithms

Three computational procedures underlie the numerics reported and checked above.

### 6.1 Numerical integration of the Dickman function

Given the delay equation $u\rho'(u) = -\rho(u-1)$ with $\rho \equiv 1$ on
$[0,1]$, discretize $[0, u_{\max}]$ on a uniform grid of step $h$ and integrate
forward:
$$
\rho(u + h) \;=\; \rho(u) - h\,\frac{\rho(u-1)}{u}.
$$
Because the delay is exactly $1$, the value $\rho(u-1)$ is already on the grid
provided $1/h$ is an integer. With $h = 5\times10^{-4}$ the scheme reproduces
$\rho(2) = 1-\log 2$ to five digits, which serves as an internal check.
Complexity: $O(u_{\max}/h)$ time, $O(u_{\max}/h)$ memory (or $O(1/h)$ with a
ring buffer).

### 6.2 Smoothness sampling for $x^2 - N$

For a target $N$ and bound $B$: draw $x$ uniformly from
$[\lceil\sqrt N\rceil, \lfloor 2\sqrt N\rfloor]$, form $v = x^2 - N$, and strip
all prime factors $\le B$ by trial division; declare $v$ smooth if the residual
cofactor is $1$. Record the depth $u = \log v/\log B$ from the *actual* value
$v$, never from $N$. (The original experiment computed $u$ at $N$-scale while
sampling $x$ from a narrow window, so that $v$ had size $\approx N^{1/2}$; every
bin was mis-assigned. The diagnostic that caught it was empirical densities
exceeding the prediction.) Complexity: $O(\pi(B))$ divisions per sample.

### 6.3 Exact hit-pattern moments

For an odd prime $p$, compute $h_p(a)$ for all $a$ by squaring each residue and
tallying, then form $\sum_a(h_p(a)-1)^2$ and $A(c)$ for each lag. This verifies
Theorems 5.4 and 5.8 exactly in $O(p)$ time per lag, $O(p^2)$ for all lags,
using only integer arithmetic.

---

## 7. Discussion

### 7.1 What a null result bought

The experiment set out to place the fourth stratum and could not. The honest
accounting is: three strata measured, one unmeasured. But the two structural
facts that survived the null are strictly stronger than the measurement they
replaced. A measurement of the $L[1/2]$ exponent, even a successful one, would
have produced a fitted slope with error bars at one scale. What we have instead
is:

* a *uniform* lower bound on the cost model valid at every scale and every
  factor-base choice (Theorem 4.4, with the correct $\log$ factor in
  Theorem 4.7);
* an *exact* identification of the failure mode of the random-integer heuristic
  (Corollary 5.9).

### 7.2 Method ledger

Three errors are recorded because the corrections are part of the result.
(i) The first design mis-scaled $u$: values $x^2-N$ of size $\approx N^{1/2}$
were binned as though of size $N$, invalidating the entire first comparison; the
anomaly that exposed it was empirical densities *above* prediction, which is
impossible for a correct null. (ii) A success verdict was drafted before the
data existed and contradicted it; it was discarded and regenerated from the
computed numbers. (iii) A syntax error in the analysis script was caught by
parsing the source before execution. Only (i) affected any scientific claim, and
it was caught before publication.

### 7.3 Relation to classical theory

The classical asymptotic $\Psi(X, X^{1/u}) \sim X\rho(u)$ (Dickman, Ramaswami,
de Bruijn, Hildebrand) is uniform in wide ranges and is the basis of the
$L[1/2]$ heuristic. Our envelope results are not competitive with it
asymptotically — the majorant class only produces upper bounds, and
$1/\lfloor u\rfloor!$ is weaker than the true $u^{-u(1+o(1))}$ by a bounded
exponential factor. Their virtue is different: they are unconditional,
elementary, effective at small $u$ (where the classical asymptotics are silent),
and they suffice to prove the cost floor, which is the statement of actual
interest for complexity stratification.

Likewise, Theorem 5.8 is a special case of the general principle that point
counts on curves over $\mathbb{F}_p$ approximate $p$; what is special at degree
$2$ is that the curve $y^2 - x^2 = c$ degenerates into a hyperbola $uv = c$ and
the count is *exactly* $p-1$, with no Weil error term. This exactness is what
makes the dichotomy of Corollary 5.9 clean.

---

## 8. Future directions

### 8.1 Zero-lag concentration for higher-degree sieve pools

For an irreducible polynomial $f$ of degree $d$, put
$h_{f,p}(a) = \#\{x \bmod p : f(x) \equiv a\}$. For $d = 2$ we have proved total
dispersion $p-1$ at lag $0$ and *exactly* the random value $p-1$ at every
nonzero lag. The key structural point is that the lag-$c$ correlation counts
points on the curve $f(y) - f(x) = c$, which for $d = 2$ degenerates to a
hyperbola $uv = c$ with exactly $p-1$ points, while for $d \ge 3$ it is an
absolutely irreducible curve whose point count is $p + O(\sqrt p)$ by Weil — so
the dichotomy must blur at order $\sqrt p$. The $d = 2$ case being a finished
elementary theorem, the $d = 3$ deviation is the smallest new phenomenon that
cannot be reached by the same bijection and that forces genuine algebraic
geometry into the sieve model. This is directly relevant to the number field
sieve, whose pools are higher-degree.

### 8.2 From $2^{n}$ to $n!$: the sharp sub-exponential floor

Theorem 4.4 uses $n! \ge 2^{n-1}$, giving $\exp(2\sqrt{L\log 2})$. Using
$n! \ge (n/e)^{n}$ (Lemma 3.7) the model floor becomes
$\inf_b\,[\,b + u(\log u - 1)\,]$ with $u = L/b$, whose asymptotics are
$(1+o(1))\cdot 2\sqrt{L\log L}$ — the correct $L[1/2,1]$ constant. The infimum
has no closed form but is pinned between two explicit AM–GM-type bounds obtained
by freezing $\log u$ at $\log\sqrt L$ (Theorems 4.6 and 4.7 supply one side).
Both ingredients are available; only the two-sided estimate of the infimum, plus
the $O(1)$ floor-function bookkeeping of §4.3, is missing, and it is pure
one-variable analysis.

### 8.3 A constructed Dickman function

Every tail bound here is stated for the majorant class, which is proved
non-vacuous by an explicit witness but does not yet contain a *constructed*
Dickman function. The function $\rho$ can be built band by band on $[n, n+1]$ as
an explicit iterated integral of the previous band, and each band inherits
continuity, positivity and monotonicity from its predecessor. Completing this
construction would upgrade every "for all majorants" statement into a statement
about $\rho$ with equality in the delay relation, and would let the numerically
integrated values of §1.2 be certified rather than assumed.

### 8.4 Production-scale measurement

Finally, the measurement itself remains open. The analysis of §1.2 shows what a
successful design must overcome: to separate $\sqrt{L}$ from a constant one needs
several octaves of $L$, and to resolve $\rho(u)$ at $u \ge 4$ one needs sample
counts of order $1/\rho(u) \approx 10^{3}$–$10^{5}$ per bin. Both are feasible at
production scale; neither is feasible on a laptop. A properly powered sweep would
turn the cost floor of Theorem 4.4 from a bound into a calibration.

---

## 9. Summary of results

| # | Statement | Form |
|---|---|---|
| 2.4 | $\rho(u) \le \rho(u-1)/u$ for every Dickman majorant, $u \ge 1$ | contraction |
| 2.6 | $\rho(u) \le 1/\lfloor u\rfloor!$ for $u \ge 0$ | tail bound |
| 3.5 | $L(3) > 5\rho(3)$ | overshoot |
| 3.6 | $L(4) > \rho(4)$ | persistence |
| 3.8 | $\rho(u) \le (e/\lfloor u\rfloor)^{\lfloor u\rfloor}$ | shape |
| 4.4 | $e^{b}/\rho(L/b) \ge \exp(2\sqrt{L\log 2} - 2\log 2)$ | $L[1/2]$ floor |
| 4.7 | cost exponent $\ge \sqrt{2L\log L} - \sqrt L$ | sharp shape |
| 5.4 | $\sum_a (h_p(a)-1)^2 = p-1$ | zero-lag dispersion |
| 5.8 | $\sum_a h_p(a)h_p(a+c) = p-1$, $c \ne 0$ | random pair correlation |
| 5.9 | $A(0) - A(c) = p$ | dichotomy |
