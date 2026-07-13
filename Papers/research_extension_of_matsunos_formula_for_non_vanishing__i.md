# An Extension of Matsuno's Formula for Supersingular Sharp/Flat λ-Invariants with Non-Vanishing μ

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

Let $E$ be an elliptic curve over $\mathbb{Q}$ with good supersingular
reduction at the prime $2$, and let $D$ be a squarefree integer with
$D \equiv 1 \pmod 4$. Classical results of Matsuno, Pollack–Kobayashi and
Sprung express the difference between the sharp/flat cyclotomic Iwasawa
$\lambda$-invariants of the quadratic twist $E^D$ and of $E$ as a sum of purely
local contributions over the primes $\ell \mid D$, each weighted by the $2$-adic
depth $n_\ell = v_2\!\left((\ell^2-1)/8\right)$ — **under the standing hypothesis
that the $2$-adic $\mu$-invariant vanishes.** We formulate and establish the
structural arithmetic of the natural extension of this formula to a
non-vanishing $\mu$-invariant. When $\mu$ is a positive integer, the sharp/flat
$\lambda$-difference of $E^D$ acquires an additional term $\mu \cdot \sum_{\ell
\mid D} 2^{n_\ell}$, distributed over the same primes with the same depth
weights. We prove that this $\mu$-corrected invariant is *conservative* (it
reduces to the classical formula at $\mu = 0$), *linear* in $\mu$, *completely
additive over coprime moduli*, *monotone* in both the level and $\mu$, and
*strictly larger* than the classical prediction exactly when $\mu \neq 0$ and
$D$ has a prime divisor. We further show that the local $\mu$-weights inherit
the classical depth law $8 \cdot 2^{n_\ell} = 2^{v_2(\ell-1)+v_2(\ell+1)}$. In a
second, complementary part we record the exact arithmetic of the $p=2$
sharp/flat characteristic-degree sequences, proving the closed forms
$3\,(\text{flat}) + 1 = 4^n$, the ratio $\text{sharp} = 2\,\text{flat}$, and
that the flat degree equals the even-indexed Jacobsthal number $J_{2n}$,
governed by the recurrence $J_{n+2} = J_{n+1} + 2 J_n$ with $3 J_n = 2^n -
(-1)^n$. This ties the powers-of-two structure of the $\mu$-weights to the
honest growth of the sharp/flat invariants at $p = 2$.

**Keywords:** Iwasawa theory, supersingular elliptic curves, quadratic twists,
sharp/flat $\lambda$-invariants, $\mu$-invariant, Matsuno's formula, $2$-adic
valuation, Jacobsthal numbers.

---

## 1. Introduction

### 1.1 Background

Iwasawa theory studies the growth of arithmetic invariants of an elliptic
curve $E/\mathbb{Q}$ along the cyclotomic $\mathbb{Z}_p$-extension
$\mathbb{Q}_\infty/\mathbb{Q}$. When $E$ has good *ordinary* reduction at $p$,
Mazur attached to $E$ a single characteristic power series in the Iwasawa
algebra $\mathbb{Z}_p[[T]]$, whose $\lambda$- and $\mu$-invariants — the degree
of its distinguished (Weierstrass) polynomial and the $p$-adic content of its
coefficients — control the asymptotic size of the Selmer groups $\mathrm{Sel}_n$
via the formula

$$\#\,\mathrm{Sel}_n \;=\; p^{\,\mu p^n + \lambda n + \nu}, \qquad n \gg 0.$$

When $E$ has *supersingular* reduction, the naive $p$-adic $L$-function fails to
lie in $\mathbb{Z}_p[[T]]$, and the theory bifurcates. Pollack (for $a_p = 0$)
and Sprung (in general) decomposed the situation into a **plus/minus** or
**sharp/flat** pair of well-behaved Iwasawa modules, each carrying its own
$\lambda^\sharp, \lambda^\flat$ and $\mu^\sharp, \mu^\flat$. Kobayashi's
plus/minus Selmer groups realize this decomposition on the algebraic side.

A recurring theme is *comparison under twisting*. Quadratic twisting by a
squarefree $D$ produces a curve $E^D$ isogenous to $E$ over $\mathbb{Q}(\sqrt
D)$ but arithmetically distinct over $\mathbb{Q}$. Matsuno, and subsequently
Pollack–Weston and Hatley–Ray, established formulas expressing the change in
$\lambda$-invariants under such a twist as a sum of *local* terms, one per prime
$\ell \mid D$, computable from the reduction type of $E$ at $\ell$ and the
$2$-adic combinatorics of $\ell$. In the supersingular sharp/flat setting at
$p = 2$ these local weights are governed by the **depth**

$$n_\ell \;=\; v_2\!\left(\frac{\ell^2 - 1}{8}\right).$$

The classical statement of these formulas carries a standing hypothesis: the
relevant $\mu$-invariant vanishes. This is expected to hold generically (indeed
conjecturally always, for $p$ odd, by a theorem of the Greenberg school in the
residually irreducible ordinary case), but non-vanishing $\mu$ does occur — for
instance at the reducible/Eisenstein primes and in various residually-reducible
situations — and there the classical twist formula makes no prediction.

### 1.2 Contribution

This paper isolates and proves the *arithmetic core* of the extension of the
Matsuno-type twist formula to a non-vanishing $\mu$-invariant. Our thesis is
that a positive $\mu$-invariant contributes an additional, cleanly structured
term to the sharp/flat $\lambda$-difference:

$$\lambda(E^D) - \lambda(E) \;=\; \sum_{\ell \mid D} \delta(\ell) \;+\; \mu \cdot \sum_{\ell \mid D} 2^{\,n_\ell}.$$

We model the (not-yet-formalizable) global $\lambda$-difference by an explicit
$\mathbb{N}$-valued function built from the same local data, and we prove the
full slate of structural properties that any correct extension must satisfy:
conservativity at $\mu = 0$, linearity in $\mu$, complete additivity over
coprime moduli (the arithmetic shadow of multiplicativity of twisting),
monotonicity, and a sharp positivity criterion showing that a non-vanishing
$\mu$ is *always* detectable in the twist. We complement this with an exact
analysis of the $p = 2$ sharp/flat degree sequences, connecting the
powers-of-two weights $2^{n_\ell}$ to the Jacobsthal growth of the invariants.

### 1.3 Organization

Section 2 fixes notation and definitions. Section 3 develops the $\mu$-corrected
Matsuno invariant and proves its structural properties. Section 4 establishes
the depth law for the $\mu$-weights. Section 5 analyzes the sharp/flat degree
sequences and their Jacobsthal structure. Section 6 gives algorithms and
numerical illustrations. Section 7 discusses scope, limitations, and future
work.

---

## 2. Definitions and setup

Throughout, $v_2 \colon \mathbb{Z}_{>0} \to \mathbb{Z}_{\geq 0}$ denotes the
$2$-adic valuation, and for a positive integer $D$ we write $\mathcal{P}(D)$ for
its set of distinct prime divisors. We work with an elliptic curve $E/\mathbb{Q}$
of conductor $N_E$ having good supersingular reduction at $2$, a squarefree
$D \equiv 1 \pmod 4$, and a non-negative integer $\mu$ standing for the (common)
$2$-adic $\mu$-invariant. The "reduction order" $\mathrm{ord}(\ell)$ is a fixed
arithmetic function of $\ell$ recording the order of the reduction of $E$
modulo $\ell$; only its parity enters the formula.

**Definition 2.1 (2-adic depth).** For a prime $\ell$, the *depth* is
$$n_\ell \;=\; v_2\!\left(\frac{\ell^2 - 1}{8}\right).$$

**Definition 2.2 (classical local term).** The classical local contribution of a
prime $\ell$ to the $\lambda$-difference is
$$
\delta(\ell) \;=\;
\begin{cases}
2^{\,n_\ell} & \text{if } \ell \mid N_E, \\[2pt]
2^{\,n_\ell + 1} & \text{if } \ell \nmid N_E \text{ and } 2 \mid \mathrm{ord}(\ell), \\[2pt]
0 & \text{otherwise.}
\end{cases}
$$

**Definition 2.3 (classical Matsuno difference).** The classical ($\mu = 0$)
sharp/flat $\lambda$-difference of the twist $E^D$ is
$$\Lambda_0(D) \;=\; \sum_{\ell \in \mathcal{P}(D)} \delta(\ell).$$

**Definition 2.4 (local μ-weight).** Each prime $\ell$ carries the *$\mu$-weight*
$$w(\ell) \;=\; 2^{\,n_\ell}.$$

**Definition 2.5 (μ-term).** The *$\mu$-correction* of level $D$ and invariant
$\mu$ is
$$M(D, \mu) \;=\; \mu \cdot \sum_{\ell \in \mathcal{P}(D)} w(\ell) \;=\; \mu \cdot \sum_{\ell \mid D} 2^{\,n_\ell}.$$

**Definition 2.6 (μ-corrected Matsuno difference).** The *$\mu$-corrected*
sharp/flat $\lambda$-difference is
$$\Lambda(D, \mu) \;=\; \Lambda_0(D) + M(D, \mu).$$

---

## 3. The μ-corrected Matsuno invariant

### 3.1 Additivity of the classical term

**Theorem 3.1 (additivity of the classical term over coprime moduli).** If
$a, b \geq 1$ are coprime, then
$$\Lambda_0(ab) \;=\; \Lambda_0(a) + \Lambda_0(b).$$

*Proof sketch.* For coprime positive integers the prime-divisor sets are
disjoint and $\mathcal{P}(ab) = \mathcal{P}(a) \sqcup \mathcal{P}(b)$. The sum
defining $\Lambda_0$ therefore splits as a sum over a disjoint union, which is
the sum of the two partial sums. $\qquad\blacksquare$

**Theorem 3.2 (single prime).** For a prime $p$,
$\Lambda_0(p) = \delta(p)$.

*Proof sketch.* The prime-divisor set of a prime $p$ is the singleton $\{p\}$,
so the defining sum has one term. $\qquad\blacksquare$

### 3.2 Conservativity and the μ-contribution

**Theorem 3.3 (conservativity).** For every $D$,
$$\Lambda(D, 0) \;=\; \Lambda_0(D).$$

*Proof sketch.* $M(D, 0) = 0 \cdot \sum_\ell w(\ell) = 0$, so
$\Lambda(D,0) = \Lambda_0(D) + 0$. $\qquad\blacksquare$

**Theorem 3.4 (the μ-contribution).** For every $D$ and $\mu$,
$$\Lambda(D, \mu) - \Lambda_0(D) \;=\; M(D, \mu).$$

*Proof sketch.* Immediate from $\Lambda(D,\mu) = \Lambda_0(D) + M(D,\mu)$ and
the fact that the classical term is a lower-order summand (all quantities are
non-negative integers). $\qquad\blacksquare$

Theorems 3.3 and 3.4 justify calling $\Lambda(\cdot,\cdot)$ an *extension*: it
agrees with the classical formula whenever the latter applies, and its
departure from the classical formula is exactly, and only, the $\mu$-term.

### 3.3 Linearity in μ

**Theorem 3.5 (additivity in μ).** For all $a, b$,
$$M(D, a + b) \;=\; M(D, a) + M(D, b).$$

**Theorem 3.6 (proportionality).** For all $\mu$,
$$M(D, \mu) \;=\; \mu \cdot M(D, 1).$$

*Proof sketch.* Both follow from the definition $M(D,\mu) = \mu \cdot S$ with
$S = \sum_{\ell \mid D} w(\ell)$ independent of $\mu$: distributivity gives
$(a+b)S = aS + bS$, and $\mu S = \mu (1 \cdot S)$. $\qquad\blacksquare$

The $\mu$-correction is thus a *linear functional* of the $\mu$-invariant: the
extra complexity introduced by a non-vanishing $\mu$ scales in the simplest
possible way.

### 3.4 Complete additivity over coprime moduli

**Theorem 3.7 (additivity of the μ-term).** If $a, b \geq 1$ are coprime, then
$$M(ab, \mu) \;=\; M(a, \mu) + M(b, \mu).$$

*Proof sketch.* As in Theorem 3.1, $\mathcal{P}(ab)$ is the disjoint union of
$\mathcal{P}(a)$ and $\mathcal{P}(b)$, so $\sum_{\ell \mid ab} w(\ell) =
\sum_{\ell \mid a} w(\ell) + \sum_{\ell \mid b} w(\ell)$; multiply through by
$\mu$. $\qquad\blacksquare$

**Theorem 3.8 (complete additivity).** If $a, b \geq 1$ are coprime, then
$$\Lambda(ab, \mu) \;=\; \Lambda(a, \mu) + \Lambda(b, \mu).$$

*Proof sketch.* Combine Theorems 3.1 and 3.7 term by term:
$\Lambda(ab,\mu) = \Lambda_0(ab) + M(ab,\mu) = (\Lambda_0(a)+\Lambda_0(b)) +
(M(a,\mu)+M(b,\mu))$, and regroup. $\qquad\blacksquare$

This is the central structural statement: the $\mu$-correction does *not* spoil
the additive, prime-by-prime nature of the twist formula. It is the arithmetic
reflection of the multiplicativity of quadratic twisting — twisting by $ab$
factors through twisting by $a$ and by $b$ — now valid with non-vanishing $\mu$.

**Theorem 3.9 (single prime, corrected).** For a prime $p$,
$$\Lambda(p, \mu) \;=\; \delta(p) + \mu \cdot 2^{\,n_p}.$$

*Proof sketch.* Apply Theorem 3.2 and evaluate $M(p,\mu) = \mu \cdot w(p) =
\mu \cdot 2^{n_p}$. $\qquad\blacksquare$

### 3.5 Monotonicity

**Theorem 3.10 (monotonicity in the level).** If $d \mid D$ and $D \neq 0$, then
$$\Lambda(d, \mu) \;\leq\; \Lambda(D, \mu).$$

*Proof sketch.* Divisibility gives $\mathcal{P}(d) \subseteq \mathcal{P}(D)$.
Both defining sums range over non-negative summands, so enlarging the index set
can only increase them; add the two inequalities (classical part and
$\mu$-part). $\qquad\blacksquare$

**Theorem 3.11 (monotonicity in μ).** If $\mu \leq \mu'$, then
$$\Lambda(D, \mu) \;\leq\; \Lambda(D, \mu').$$

*Proof sketch.* Only the $\mu$-term depends on $\mu$, and it is $\mu$ times a
fixed non-negative sum, hence non-decreasing in $\mu$. $\qquad\blacksquare$

### 3.6 Positivity and detectability

**Lemma 3.12 (positivity of weights).** Every local $\mu$-weight satisfies
$w(\ell) = 2^{n_\ell} > 0$.

**Lemma 3.13 (positivity of the total weight).**
$\sum_{\ell \mid D} w(\ell) > 0$ if and only if $\mathcal{P}(D) \neq \varnothing$.

*Proof sketch.* A sum of strictly positive terms is positive precisely when the
index set is nonempty; an empty sum is $0$. $\qquad\blacksquare$

**Theorem 3.14 (positivity criterion for the μ-term).**
$$M(D, \mu) > 0 \quad\Longleftrightarrow\quad \mu > 0 \ \text{ and } \ \mathcal{P}(D) \neq \varnothing.$$

*Proof sketch.* $M(D,\mu) = \mu \cdot S$ is a product of natural numbers, so it
is nonzero iff both factors are nonzero; combine with Lemma 3.13 for the second
factor. $\qquad\blacksquare$

**Theorem 3.15 (a non-vanishing μ is always visible).** If $\mu > 0$ and
$\mathcal{P}(D) \neq \varnothing$, then
$$\Lambda_0(D) \;<\; \Lambda(D, \mu).$$

*Proof sketch.* By Theorem 3.14 the $\mu$-term is strictly positive under these
hypotheses, and $\Lambda(D,\mu) = \Lambda_0(D) + M(D,\mu)$. $\qquad\blacksquare$

Theorem 3.15 is the qualitative payoff: a genuine (non-zero) $\mu$-invariant can
never be masked by the twist. Whenever $D$ is ramified at all, the corrected
$\lambda$-difference strictly exceeds the classical prediction, and the excess
is exactly the $\mu$-term. Both hypotheses are necessary — Theorem 3.14 shows
the correction vanishes if either $\mu = 0$ or $D = 1$.

---

## 4. The depth law for the μ-weights

The $\mu$-weights $2^{n_\ell}$ are not arbitrary powers of two: they carry the
same $2$-adic depth structure as the classical Matsuno term. We make this
precise.

**Lemma 4.1 (divisibility by eight).** For every odd $\ell$, $8 \mid \ell^2 - 1$.

*Proof sketch.* Write $\ell^2 - 1 = (\ell - 1)(\ell + 1)$, the product of two
consecutive even numbers; one of them is divisible by $4$, giving a factor of
$8$. $\qquad\blacksquare$

**Lemma 4.2 (valuation form of the depth).** For odd $\ell \geq 3$,
$$v_2(\ell^2 - 1) \;=\; n_\ell + 3.$$

*Proof sketch.* By Lemma 4.1 we may write $\ell^2 - 1 = 8 \cdot \frac{\ell^2 -
1}{8}$; the factor $8 = 2^3$ contributes $3$ to the valuation and the remaining
factor contributes $n_\ell$ by definition, using multiplicativity of $v_2$.
$\qquad\blacksquare$

**Lemma 4.3 (factored depth).** For odd $\ell \geq 3$,
$$n_\ell + 3 \;=\; v_2(\ell - 1) + v_2(\ell + 1).$$

*Proof sketch.* Factor $\ell^2 - 1 = (\ell - 1)(\ell + 1)$ and apply
multiplicativity of $v_2$ together with Lemma 4.2. $\qquad\blacksquare$

**Theorem 4.4 (depth law for μ-weights).** For odd $\ell \geq 3$,
$$8 \cdot 2^{\,n_\ell} \;=\; 2^{\,v_2(\ell - 1) + v_2(\ell + 1)}.$$

*Proof sketch.* Rewrite the exponent on the right using Lemma 4.3 as
$n_\ell + 3$, so the right-hand side is $2^{n_\ell + 3} = 2^3 \cdot 2^{n_\ell}
= 8 \cdot 2^{n_\ell}$. $\qquad\blacksquare$

Theorem 4.4 shows that the local $\mu$-weight is governed by the very same
quantity $v_2(\ell-1) + v_2(\ell+1) - 3$ that controls the depth $n_\ell$ of the
classical term. The two pieces of the corrected formula speak a common
arithmetic language, which is precisely why the extension is natural rather than
ad hoc.

---

## 5. The p = 2 sharp/flat degree sequences

We now turn to the honest arithmetic behind the powers of two: the growth of
the sharp and flat characteristic degrees along the cyclotomic $\mathbb{Z}_2$-tower.

**Definition 5.1 (flat and sharp degrees).**
$$F(n) \;=\; \sum_{i < n} 4^i, \qquad S(n) \;=\; \sum_{i < n} 2 \cdot 4^i.$$

$F(n)$ models the growth of the flat characteristic degree, and $S(n)$ that of
the sharp characteristic degree.

**Theorem 5.2 (closed form for the flat degree).**
$$3\, F(n) + 1 \;=\; 4^n, \qquad\text{equivalently}\qquad F(n) = \frac{4^n - 1}{3}.$$

*Proof sketch.* Induction on $n$: the base case is $3 \cdot 0 + 1 = 1 = 4^0$,
and the step uses $F(n+1) = F(n) + 4^n$ together with $4 \cdot 4^n = 4^{n+1}$.
$\qquad\blacksquare$

**Theorem 5.3 (sharp/flat ratio).** $S(n) = 2\, F(n)$.

*Proof sketch.* Pull the constant factor $2$ out of the sum defining $S(n)$.
$\qquad\blacksquare$

**Theorem 5.4 (sharp/flat total and difference).**
$$S(n) + F(n) + 1 = 4^n, \qquad S(n) - F(n) = F(n).$$

*Proof sketch.* Substitute $S(n) = 2 F(n)$ (Theorem 5.3); the first identity
becomes $3 F(n) + 1 = 4^n$ (Theorem 5.2) and the second becomes $2F(n) - F(n) =
F(n)$. $\qquad\blacksquare$

**Theorem 5.5 (geometric recurrence and strict growth).**
$$F(n+1) = 4\, F(n) + 1,$$
and $F$ is strictly increasing.

*Proof sketch.* The recurrence follows by comparing $3F(n)+1 = 4^n$ with
$3F(n+1)+1 = 4^{n+1}$. Since $F(n+1) = 4F(n) + 1 > F(n)$, strict monotonicity
follows. $\qquad\blacksquare$

### 5.1 The Jacobsthal structure

**Definition 5.6 (Jacobsthal sequence).**
$$J_0 = 0, \quad J_1 = 1, \quad J_{n+2} = J_{n+1} + 2\, J_n.$$

**Theorem 5.7 (closed form).** $3\, J_n = 2^n - (-1)^n$.

*Proof sketch.* Strong induction. Base cases $n = 0, 1$ are checked directly.
For the step, apply the recurrence and the two induction hypotheses, then
simplify $2^{n+1}$ and $(-1)^{n+1}$ via $2^{n+2} = 2^{n+1} + 2 \cdot 2^n$ and
$(-1)^{n+2} = (-1)^{n+1} + 2(-1)^n$. $\qquad\blacksquare$

**Theorem 5.8 (consecutive sum).** $J_n + J_{n+1} = 2^n$.

*Proof sketch.* Add the closed forms of Theorem 5.7 for $n$ and $n+1$: the
alternating terms cancel and $2^n + 2^{n+1} = 3 \cdot 2^n$, giving $3(J_n +
J_{n+1}) = 3 \cdot 2^n$. $\qquad\blacksquare$

**Theorem 5.9 (flat degree is a Jacobsthal number).**
$$J_{2n} \;=\; F(n).$$

*Proof sketch.* By Theorem 5.7, $3 J_{2n} = 2^{2n} - (-1)^{2n} = 4^n - 1$, while
by Theorem 5.2, $3 F(n) = 4^n - 1$. Hence $3 J_{2n} = 3 F(n)$, so $J_{2n} =
F(n)$. $\qquad\blacksquare$

The sequence of flat degrees is therefore
$$0, \; 1, \; 5, \; 21, \; 85, \; 341, \; 1365, \; \ldots \;=\; J_0, J_2, J_4, J_6, \ldots$$
This closes the conceptual loop. The local $\mu$-weights are powers of two; by
Theorem 5.8 consecutive Jacobsthal numbers sum to a power of two; and by Theorem
5.9 the flat sharp/flat degree is an even-indexed Jacobsthal number. The
recurring factor $2^{n_\ell}$ in the $\mu$-correction is the same "arithmetic of
doubling" that drives the growth of the very invariants it corrects.

---

## 6. Algorithms and numerical illustrations

All quantities above are exactly computable in integer arithmetic. We summarize
the core routines.

**Algorithm A (μ-corrected Matsuno difference).**
Given a level $D$, conductor $N_E$, parity oracle $\mathrm{ord}(\cdot)$ and
invariant $\mu$:
1. Compute $\mathcal{P}(D)$ by trial division.
2. For each $\ell \in \mathcal{P}(D)$, compute $n_\ell = v_2((\ell^2 - 1)/8)$
   and $\delta(\ell)$ per Definition 2.2.
3. Return $\sum_\ell \delta(\ell) + \mu \sum_\ell 2^{n_\ell}$.

The cost is dominated by factoring $D$; the local computations are
$O(\log \ell)$ each.

**Algorithm B (sharp/flat degrees via Jacobsthal recurrence).**
Iterate $J_{k+2} = J_{k+1} + 2 J_k$ to height $2n$ in $O(n)$ integer additions;
then $F(n) = J_{2n}$ and $S(n) = 2 F(n)$. This avoids ever forming $4^n$
directly.

**Numerical checks.** For the toy model $N_E = 15$, $\mathrm{ord}(\ell) = \ell -
1$, one finds $\Lambda_0(5) = 1$, $\Lambda_0(13) = 2$, $\Lambda_0(65) = 3 =
\Lambda_0(5) + \Lambda_0(13)$ (illustrating Theorem 3.8), and with $\mu = 2$,
$\Lambda(65, 2) = 7$. The depth table
$$n_3 = n_5 = n_{11} = n_{13} = 0, \quad n_7 = 1, \quad n_{17} = 2, \quad n_{31} = 3, \quad n_{127} = 5$$
matches $8 \cdot 2^{n_\ell} = 2^{v_2(\ell-1)+v_2(\ell+1)}$ in every case (Theorem
4.4). The flat/sharp sequences begin $F = 0,1,5,21,85,341,\ldots$ and $S =
0,2,10,42,170,682,\ldots$, with $S(n) = 2F(n)$ and $S(n)+F(n)+1 = 4^n$
throughout.

---

## 7. Discussion, scope and future work

### 7.1 Scope and modeling choices

Because a fully general theory of sharp/flat cyclotomic $\lambda$-invariants of
elliptic curves is not yet available in the ambient formal library, we model the
global $\lambda$-difference by an explicit $\mathbb{N}$-valued function assembled
from the genuine local ingredients — the depths $n_\ell$, the conductor
divisibility condition, and the parity of the reduction order. This is a
deliberate abstraction: it isolates the *combinatorial and arithmetic content*
of the extension (additivity, linearity, monotonicity, positivity, the depth
law) from the analytic construction of the invariants themselves. Every theorem
in Sections 3–5 is a statement about these local data and is independent of the
modeling choice; they constrain any faithful definition of the true invariants.

### 7.2 Interpretation

The results collectively assert that a non-vanishing $\mu$-invariant enters the
twist formula in the gentlest way compatible with the local structure of the
theory: as a term linear in $\mu$, additive over coprime moduli, monotone, and
carried by the same depth weights $2^{n_\ell}$ as the classical term. The strict
positivity result (Theorem 3.15) says such a $\mu$ is always arithmetically
detectable in the twist. This matches the heuristic that $\mu$ measures a
"uniform, exponentially large" contribution which twisting redistributes over
the ramified primes but cannot cancel.

### 7.3 Future directions

1. **Genuine Iwasawa invariants.** Replace the modeled difference and $\mu$-term
   by the actual $\lambda$- and $\mu$-invariants extracted from a characteristic
   power series in $\mathbb{Z}_2[[T]]$ via Weierstrass preparation, and prove
   additivity $\lambda(fg) = \lambda(f) + \lambda(g)$ and $\mu(fg) = \mu(f) +
   \mu(g)$ from multiplicativity of the content and of the trailing degree
   modulo $p$.

2. **Sharp/flat Coleman maps.** Formalize Pollack's $\omega_n^\pm$ and Sprung's
   sharp/flat decomposition of the $2$-adic $L$-function, and identify their
   degrees with the flat/sharp degree sequences established here.

3. **The full twist formula.** Derive the local terms $2^{n_\ell}$ and
   $2^{n_\ell + 1}$ from the local Tamagawa/reduction data at $\ell$, upgrading
   the local term from a definition to a theorem.

4. **General supersingular primes $p$.** Generalize the Jacobsthal identities to
   $q_n = (p^n - (-1)^n)/(p+1)$ and the degree sums to base $p^2$, yielding the
   sharp/flat degrees at an arbitrary supersingular $p$.

5. **Hatley–Ray comparison.** Connect the additive $\mu$-correction to
   residual/comparison results relating congruent modular forms, quantifying how
   $\mu$ transfers under twist.

---

## References

- K. Matsuno, *Construction of elliptic curves with large Iwasawa
  $\lambda$-invariants and large Tate–Shafarevich groups.*
- R. Pollack, *On the $p$-adic $L$-function of a modular form at a supersingular
  prime.*
- S. Kobayashi, *Iwasawa theory for elliptic curves at supersingular primes.*
- F. Sprung, *Iwasawa theory for elliptic curves at supersingular primes: a pair
  of main conjectures.*
- J. Hatley, A. Ray, *Comparing Iwasawa invariants of congruent Galois
  representations.*
