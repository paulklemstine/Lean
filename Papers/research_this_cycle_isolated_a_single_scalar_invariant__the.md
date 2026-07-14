# The Möbius Discriminant: An Exact Sign-and-Size Law for the Log-Behaviour of First-Order Multiplicative Recurrences

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We study positive real sequences $a:\mathbb{N}\to\mathbb{R}$ governed by a
first-order multiplicative recurrence
$$(\alpha n + \beta)\,a(n+1) = (\gamma n + \delta)\,a(n),$$
and attach to each such recurrence a single scalar invariant, the **Möbius
discriminant** $\Delta = \gamma\beta - \alpha\delta$. We prove that the sign of
$\Delta$ completely governs the log-behaviour of the sequence: strict
log-convexity when $\Delta > 0$, exact log-linearity when $\Delta = 0$, and
strict log-concavity when $\Delta < 0$. This refines the classical
first-difference / second-difference dichotomy into a sign-indexed trichotomy.
We then upgrade this *sign* law to an *exact quantitative* law. The pointwise
discriminant $D(n) = a(n)a(n+2) - a(n+1)^2$ satisfies the closed identity
$$(\alpha n + \beta)(\alpha(n+1)+\beta)\,D(n) = \Delta\cdot a(n)\,a(n+1),$$
a pure algebraic consequence of the recurrence requiring no positivity. The
consecutive ratio is a Möbius transform of $n$ whose forward difference has the
constant numerator $\Delta$, and the log-curvature (second difference of the
logarithm) admits the exact form
$\log\!\big(1 + \Delta/((\gamma n+\delta)(\alpha(n+1)+\beta))\big)$, which tends
to $0$ when $\alpha,\gamma>0$ — the valuation $-\log a$ is asymptotically affine.
The classical totals $2^n$ ($\Delta=0$), reciprocal factorials ($\Delta=-1$),
factorials ($\Delta=1$), central binomials ($\Delta=2$), and Catalan numbers
($\Delta=6$) instantiate all three regimes. Finally, in a contrarian spirit, we
prove that the naive second-order generalization is **false**: no discriminant
built solely from the coefficients of a second-order recurrence
$p\,a(n+2)=q\,a(n+1)+r\,a(n)$ can govern log-convexity, the obstruction being the
Fibonacci numbers, whose constant-coefficient recurrence carries the
sign-alternating Cassini discriminant $(-1)^{n+1}$.

**Keywords:** Möbius discriminant, first-order multiplicative recurrence,
log-convexity, log-concavity, Catalan numbers, central binomial coefficients,
Cassini identity, P-recursive sequences.

---

## 1. Introduction

A remarkable number of the sequences that combinatorics cares about are
*holonomic of the simplest kind*: each term is obtained from its predecessor by
multiplication by a ratio of two affine functions of the index. Powers of two,
factorials, reciprocal factorials, central binomial coefficients, and Catalan
numbers all fall into this class. Writing the multiplier as a fraction, the
defining relation is
$$\frac{a(n+1)}{a(n)} = \frac{\gamma n + \delta}{\alpha n + \beta},$$
or, cleared of denominators,
$$(\alpha n + \beta)\,a(n+1) = (\gamma n + \delta)\,a(n). \tag{$\ast$}$$

The four real coefficients $\alpha,\beta,\gamma,\delta$ encode the entire growth
law. The purpose of this paper is to show that a single scalar built from these
four coefficients — the **Möbius discriminant**
$$\boxed{\;\Delta = \gamma\beta - \alpha\delta\;}$$
governs, exactly and pointwise, the second-order (logarithmic) behaviour of the
sequence, and to delimit precisely how far this phenomenon extends.

The name is deliberate: $x \mapsto \tfrac{\gamma x + \delta}{\alpha x + \beta}$
is a Möbius transformation, and $\gamma\beta - \alpha\delta$ is (up to sign
conventions) its determinant. That the log-convexity of a combinatorial total
should be read off from the determinant of the Möbius transformation encoding its
growth is the conceptual heart of this work.

### 1.1 Log-behaviour and the pointwise discriminant

A positive sequence $a$ is **log-convex** if $\log a$ is convex, equivalently
$a(n)a(n+2) \ge a(n+1)^2$ for all $n$; **log-concave** if $\log a$ is concave,
equivalently $a(n)a(n+2)\le a(n+1)^2$; and **log-linear** (geometric) if equality
holds. The single quantity detecting the regime is the **pointwise
discriminant**
$$D(n) := a(n)\,a(n+2) - a(n+1)^2.$$
Its sign at each $n$ is the local curvature of $\log a$. Our results describe
$D(n)$ exactly.

### 1.2 Contributions

1. **An exact sign-and-size identity** (Theorem 3.1) expressing
   $(\alpha n+\beta)(\alpha(n+1)+\beta)\,D(n)$ as $\Delta\cdot a(n)a(n+1)$,
   valid with no positivity hypotheses.
2. **The sign trichotomy** (Theorem 3.2) as a pointwise corollary: the sign of
   $D(n)$ equals the sign of $\Delta$ for every $n$.
3. **The Möbius ratio law** (Theorems 4.1–4.2): the consecutive ratio equals the
   Möbius transform $(\gamma n + \delta)/(\alpha n + \beta)$, and its forward
   difference has the index-independent numerator $\Delta$.
4. **The exact curvature law** (Theorems 5.1–5.3): a closed form for the
   log-curvature and a proof that it tends to $0$ when $\alpha,\gamma>0$, so the
   valuation $-\log a$ is asymptotically affine.
5. **A classification table** (Section 6) placing $2^n$, $1/n!$, $n!$,
   $\binom{2n}{n}$, and $C_n$ into the three regimes, with the exact Catalan
   identity as a worked instance.
6. **A negative result** (Theorem 7.2): no coefficient-only discriminant governs
   log-convexity for second-order recurrences, obstructed by Cassini's identity
   for the Fibonacci numbers.

---

## 2. Setup and definitions

Throughout, $a:\mathbb{N}\to\mathbb{R}$ and $\alpha,\beta,\gamma,\delta\in\mathbb{R}$.

**Definition 2.1 (Recurrence class).** We say $a$ obeys the *first-order
multiplicative recurrence* with data $(\alpha,\beta,\gamma,\delta)$ if
$$(\alpha n + \beta)\,a(n+1) = (\gamma n + \delta)\,a(n) \qquad \text{for all } n\in\mathbb{N}. \tag{$\ast$}$$

**Definition 2.2 (Möbius discriminant).** The *Möbius discriminant* of the data
is the scalar $\Delta = \gamma\beta - \alpha\delta$.

**Definition 2.3 (Pointwise discriminant).** The *pointwise discriminant* of $a$
is $D(n) = a(n)\,a(n+2) - a(n+1)^2$.

We will frequently assume:
- **(P)** positivity of the sequence, $a(n) > 0$ for all $n$;
- **(D)** positivity of the affine denominator, $\alpha n + \beta > 0$ for all $n$;
- **(N)** positivity of the affine numerator, $\gamma n + \delta > 0$ for all $n$.

Under (P) and (D), the recurrence $(\ast)$ forces the sequence to remain
positive and the growth ratio to be well defined and positive.

---

## 3. The exact discriminant identity and the sign trichotomy

### 3.1 The identity

**Theorem 3.1 (Exact discriminant identity).** If $a$ obeys $(\ast)$ then for
every $n$,
$$(\alpha n + \beta)\,(\alpha(n+1)+\beta)\,\big(a(n)\,a(n+2) - a(n+1)^2\big)
= (\gamma\beta - \alpha\delta)\, a(n)\, a(n+1).$$

*Proof sketch.* Write $(\ast)$ at index $n$ and at index $n+1$:
$$(\alpha n + \beta)\,a(n+1) = (\gamma n + \delta)\,a(n), \qquad
(\alpha(n+1)+\beta)\,a(n+2) = (\gamma(n+1)+\delta)\,a(n+1).$$
Multiply the second by $a(n)(\alpha n + \beta)$ and the first by
$(\alpha(n+1)+\beta)\,a(n+1)$, then subtract. On the left the terms combine into
$(\alpha n+\beta)(\alpha(n+1)+\beta)\big(a(n)a(n+2)-a(n+1)^2\big)$. On the right,
after substituting $(\alpha n+\beta)a(n+1)=(\gamma n+\delta)a(n)$ once more to
eliminate the surviving $a(n+1)$ factor, the coefficient collapses to
$(\gamma(n+1)+\delta)(\alpha n+\beta) - (\gamma n+\delta)(\alpha(n+1)+\beta)$,
which expands to $\gamma\beta - \alpha\delta = \Delta$, multiplied by
$a(n)a(n+1)$. This is a pure polynomial identity in the six quantities
$\alpha,\beta,\gamma,\delta$ and the three consecutive terms, so no positivity is
used. $\square$

**Remark.** The identity is genuinely two-sided in the coefficients: it shows the
left-hand product is a *fixed multiple* of $\Delta$, so $D(n)$ never merely
*shares* the sign of $\Delta$ — it is rigidly proportional to it.

### 3.2 The sign trichotomy

**Theorem 3.2 (Sign trichotomy).** Assume (P) and (D). Then for every $n$:
- if $\Delta > 0$, then $D(n) > 0$ (strict log-convexity);
- if $\Delta = 0$, then $D(n) = 0$ (log-linearity);
- if $\Delta < 0$, then $D(n) < 0$ (strict log-concavity).

*Proof sketch.* By (D), both $\alpha n+\beta$ and $\alpha(n+1)+\beta$ are
positive, so their product $P_n := (\alpha n+\beta)(\alpha(n+1)+\beta)$ is
positive. By (P), $a(n)a(n+1)>0$. Theorem 3.1 reads $P_n\,D(n) = \Delta\cdot
a(n)a(n+1)$. Dividing by the positive $P_n$ shows $D(n)$ has the same sign as
$\Delta\cdot a(n)a(n+1)$, i.e. the same sign as $\Delta$. The three cases follow
by taking $\Delta>0$, $=0$, $<0$ respectively. $\square$

This is the sharp refinement of the earlier degree-based dichotomy: rather than
distinguishing merely whether the growth ratio is affine of degree one or two, we
read the *direction* of curvature from the sign of a single determinant.

---

## 4. The Möbius ratio and its constant-numerator forward difference

### 4.1 The ratio is a Möbius transform

**Theorem 4.1 (Ratio as Möbius transform).** Assume (P) and (D). Then for every
$m$,
$$\frac{a(m+1)}{a(m)} = \frac{\gamma m + \delta}{\alpha m + \beta}.$$

*Proof sketch.* Cross-multiplying, the claim is
$(\alpha m+\beta)\,a(m+1) = (\gamma m+\delta)\,a(m)$, which is exactly $(\ast)$;
positivity of $a(m)$ and $\alpha m+\beta$ makes both denominators nonzero. $\square$

### 4.2 Constant numerator of the forward difference

**Theorem 4.2 (Forward difference with constant numerator).** Assume (P) and (D).
Then for every $n$,
$$\frac{a(n+2)}{a(n+1)} - \frac{a(n+1)}{a(n)}
= \frac{\gamma\beta - \alpha\delta}{(\alpha n + \beta)(\alpha(n+1)+\beta)}.$$

*Proof sketch.* Substitute Theorem 4.1 at $n$ and $n+1$ to rewrite both ratios
as $\tfrac{\gamma(n+1)+\delta}{\alpha(n+1)+\beta}$ and
$\tfrac{\gamma n+\delta}{\alpha n+\beta}$. Combining over the common denominator
$(\alpha n+\beta)(\alpha(n+1)+\beta)$, the numerator is
$(\gamma(n+1)+\delta)(\alpha n+\beta) - (\gamma n+\delta)(\alpha(n+1)+\beta)$,
which expands to the index-independent $\gamma\beta - \alpha\delta$. $\square$

This is the defining rigidity of Möbius transformations: consecutive differences
carry the transformation's determinant as a constant numerator. It is the exact
form of the informal "ratio-as-Möbius, constant-numerator" heuristic and it is
what powers the pointwise identity of Section 3.

---

## 5. The exact curvature law (valuation dequantization)

### 5.1 The curvature ratio

**Theorem 5.1 (Exact curvature ratio).** Assume (P), (D), (N). Then for every
$n$,
$$\frac{a(n)\,a(n+2)}{a(n+1)^2}
= 1 + \frac{\gamma\beta - \alpha\delta}{(\gamma n + \delta)(\alpha(n+1)+\beta)}.$$

*Proof sketch.* From Theorem 3.1, $a(n)a(n+2) = a(n+1)^2 + \Delta\,a(n)a(n+1)/P_n$
with $P_n = (\alpha n+\beta)(\alpha(n+1)+\beta)$. Dividing by $a(n+1)^2$ gives
$1 + \Delta\,\tfrac{a(n)}{a(n+1)}\cdot\tfrac{1}{P_n}$. By Theorem 4.1,
$a(n)/a(n+1) = (\alpha n+\beta)/(\gamma n+\delta)$, so the correction becomes
$\Delta\cdot\tfrac{\alpha n+\beta}{(\gamma n+\delta)\,P_n}
= \tfrac{\Delta}{(\gamma n+\delta)(\alpha(n+1)+\beta)}$. $\square$

### 5.2 The log-curvature identity

**Theorem 5.2 (Log-curvature identity).** Assume (P), (D), (N). Then for every
$n$,
$$\log a(n) - 2\log a(n+1) + \log a(n+2)
= \log\!\left(1 + \frac{\gamma\beta - \alpha\delta}{(\gamma n + \delta)(\alpha(n+1)+\beta)}\right).$$

*Proof sketch.* The left side is $\log\big(a(n)a(n+2)/a(n+1)^2\big)$ by the
multiplicativity of $\log$ over positive reals; apply Theorem 5.1 to the
argument. $\square$

The left side is exactly the discrete second difference $\Delta^2 (\log a)(n)$ of
the valuation-negative $\log a$. Thus the sign of the log-curvature equals the
sign of $\Delta$ (since $1+x$ exceeds, equals, or is below $1$ according as $x$
is positive, zero, or negative), recovering Theorem 3.2 in valuation form.

### 5.3 Asymptotic flatness

**Theorem 5.3 (Asymptotic affinity of the valuation).** Assume (P), (D), (N) and
in addition $\alpha > 0$, $\gamma > 0$. Then
$$\lim_{n\to\infty}\Big(\log a(n) - 2\log a(n+1) + \log a(n+2)\Big) = 0.$$

*Proof sketch.* With $\alpha,\gamma>0$ the factors $\gamma n+\delta$ and
$\alpha(n+1)+\beta$ both tend to $+\infty$, so their product does too, and the
correction term $\Delta/((\gamma n+\delta)(\alpha(n+1)+\beta))$ tends to $0$.
Hence the argument of the logarithm in Theorem 5.2 tends to $1$, and by
continuity of $\log$ at $1$ the log-curvature tends to $\log 1 = 0$. $\square$

Consequently the valuation $v(n) = -\log a(n)$ is *asymptotically affine*: its
second difference vanishes in the limit, so $\log a$ becomes indistinguishable
from a straight line at large $n$, with a persistent but decaying curvature
defect whose entire strength is carried by $\Delta$. This is the tropical /
valuation "dequantization" of the trichotomy: log-convexity is convexity of the
valuation, and $\Delta$ is the leading coefficient of the piecewise-linear
profile.

---

## 6. The classical totals, classified

Each classical total obeys $(\ast)$ for a specific data vector, and the Möbius
discriminant sorts them exactly.

| Sequence | $a(n+1)/a(n)$ | $(\alpha,\beta,\gamma,\delta)$ | $\Delta$ | Regime |
|---|---|---|---|---|
| $2^n$ | $2$ | $(0,1,0,2)$ | $0$ | log-linear |
| $1/n!$ | $\dfrac{1}{n+1}$ | $(1,1,0,1)$ | $-1$ | log-concave |
| $n!$ | $n+1$ | $(0,1,1,1)$ | $+1$ | log-convex |
| $\binom{2n}{n}$ | $\dfrac{2(2n+1)}{n+1}$ | $(1,1,4,2)$ | $+2$ | log-convex |
| $C_n$ | $\dfrac{2(2n+1)}{n+2}$ | $(1,2,4,2)$ | $+6$ | log-convex |

The three regimes are all realized, refining the earlier "$d=1$ vs $d=2$"
dichotomy into a genuine sign-indexed trichotomy.

**Theorem 6.1 (Exact Catalan discriminant identity).** For all $n$,
$$(n+2)(n+3)\,\big(C_n\,C_{n+2} - C_{n+1}^2\big) = 6\, C_n\, C_{n+1}.$$

*Proof sketch.* The Catalan numbers satisfy the multiplicative recurrence
$(n+2)\,C_{n+1} = 2(2n+1)\,C_n$, i.e. $(\ast)$ with
$(\alpha,\beta,\gamma,\delta)=(1,2,4,2)$ and hence
$\Delta = \gamma\beta-\alpha\delta = 4\cdot 2 - 1\cdot 2 = 6$. Positivity of the
Catalan numbers (they equal $\binom{2n}{n}/(n+1)$, a positive integer) supplies
(P), and $\alpha n + \beta = n+2 > 0$ supplies (D). Instantiating Theorem 3.1
gives $(n+2)(n+3)D(n) = 6\,C_n C_{n+1}$. $\square$

The number $6$ on the right of the Catalan identity is literally the Catalan
discriminant. Analogous exact identities hold for every entry of the table with
$6$ replaced by the corresponding $\Delta$.

---

## 7. The boundary: no coefficient-only second-order discriminant

Second-order recurrences $p(n)\,a(n+2) = q(n)\,a(n+1) + r(n)\,a(n)$ include the
Motzkin, Baxter, and Fibonacci numbers. It is natural to conjecture a
"discriminant polynomial" $\Delta_2$, built from $p, q, r$, whose eventual sign
governs log-convexity, reducing to $\gamma\beta - \alpha\delta$ when $r \equiv 0$.
We show this cannot be.

**Theorem 7.1 (Cassini-type discriminant identity).** For the Fibonacci numbers
$F_n$ ($F_0=0, F_1=1, F_{n+2}=F_{n+1}+F_n$),
$$F_n\,F_{n+2} - F_{n+1}^2 = (-1)^{n+1}.$$

*Proof sketch.* Induction using $F_{n+2}=F_{n+1}+F_n$; the base case is direct,
and the inductive step is the standard telescoping of Cassini's identity
$F_{n+1}^2 - F_n F_{n+2} = (-1)^n$. $\square$

**Theorem 7.2 (No coefficient-only $\Delta_2$).** There is no function of the
coefficients $p, q, r$ of a second-order recurrence whose sign governs the sign
of the pointwise discriminant $D(n) = a(n)a(n+2) - a(n+1)^2$.

*Proof sketch.* The Fibonacci numbers obey the second-order recurrence with
*constant* coefficients $p = q = r = 1$. Any quantity built solely from these
coefficients is a single constant with one fixed sign. But by Theorem 7.1 the
Fibonacci pointwise discriminant is $(-1)^{n+1}$, which is $+1$ for every odd $n$
and $-1$ for every even $n$; hence it is positive infinitely often and negative
infinitely often. No constant can match both signs, so no coefficient-only
discriminant can govern the sign of $D(n)$. $\square$

Thus the first-order case is *genuinely special*: the collapse of all
higher-order data into one scalar $\Delta$ is a feature of first-order
multiplicative recurrences and does not survive to the second order in
coefficient-only form.

---

## 8. Algorithms

We record the elementary algorithms underlying the numerical demonstrations.

**Algorithm A (Discriminant classification).** Given data
$(\alpha,\beta,\gamma,\delta)$, compute $\Delta = \gamma\beta - \alpha\delta$ and
return `log-convex`, `log-linear`, or `log-concave` according to the sign. Cost
$O(1)$.

**Algorithm B (Identity verifier).** Given the data and a positive seed $a(0)$,
generate $a(0),\dots,a(N)$ via $a(n+1) = \tfrac{\gamma n+\delta}{\alpha n+\beta}
a(n)$, and check the exact identity of Theorem 3.1 and the curvature identity of
Theorem 5.1 to machine tolerance at each index. Cost $O(N)$.

**Algorithm C (Cassini obstruction sampler).** Generate Fibonacci numbers and
tabulate $F_n F_{n+2} - F_{n+1}^2$, exhibiting the $\pm 1$ alternation that
obstructs any constant-coefficient discriminant. Cost $O(N)$ with exact integer
arithmetic.

---

## 9. Applications and discussion

**Unimodality and inequalities.** Log-convexity and log-concavity are the engines
behind unimodality of coefficient sequences, Newton-type inequalities, and the
good analytic behaviour of generating functions. The Möbius discriminant turns
these checks into a one-line computation for the entire first-order class.

**Growth asymptotics.** Theorem 5.3 quantifies the sense in which every such
total is "eventually geometric": the logarithm is asymptotically affine with a
curvature defect of order $1/n^2$ scaled by $\Delta$. This gives uniform control
of second-order growth across the whole class simultaneously.

**A dictionary, not a case analysis.** Traditionally the log-convexity of each
combinatorial total is proved by a bespoke argument. Theorem 3.1 replaces the
case analysis by a single determinant read off from the recurrence coefficients.

**The sharp boundary.** Theorem 7.2 is a cautionary tale about generalization:
the elegance of the first-order law does not lift to the second order in
coefficient-only form. The Fibonacci wall marks exactly where the phenomenon
stops.

---

## 10. Future directions

Several natural questions remain, aligned with the conjectures that framed this
investigation.

- **Quantitative discriminant law (settled).** The exact identity of Theorem 3.1
  and the constant-numerator forward difference of Theorem 4.2 upgrade the
  original sign law into an exact proportionality, giving closed-form control of
  the second-order growth of every classical total simultaneously.

- **Second-order (Turán) recurrences.** While Theorem 7.2 rules out a
  *coefficient-only* discriminant, an *index-dependent* discriminant polynomial
  $\Delta_2(n)$ built from $p(n), q(n), r(n)$ and reducing to $\gamma\beta -
  \alpha\delta$ when $r\equiv 0$ remains a viable target; the Motzkin and Baxter
  numbers, with their known log-convexity, are concrete test cases.

- **Renormalized totals and infinite log-concavity.** Dividing a strictly
  log-convex total by its exact growth ratio $(\gamma n+\delta)/(\alpha n+\beta)$
  produces a log-linear residual; iterating a suitable renormalization may
  expose higher-order convexity data in a controlled tower and connect to
  infinite log-concavity.

- **Tropical / valuation dequantization (settled).** Theorem 5.3 casts the
  trichotomy as a statement about the second difference of the valuation
  $-\log a$, which is asymptotically affine with curvature defect controlled by
  $\Delta$; summation-by-parts refinements of the decay rate are a natural next
  step.

---

## 11. Conclusion

The Möbius discriminant $\Delta = \gamma\beta - \alpha\delta$ is a single scalar
that decides, exactly and pointwise, the log-behaviour of every sequence obeying
a first-order multiplicative recurrence. Its sign fixes the trichotomy of
log-convex / log-linear / log-concave; its value fixes the exact pointwise
discriminant, the constant numerator of the ratio's forward difference, and the
closed-form log-curvature that decays to zero. Powers of two, factorials,
reciprocal factorials, central binomials, and Catalan numbers realize all three
regimes. And the phenomenon stops sharply at the second order: Cassini's identity
for the Fibonacci numbers shows no coefficient-only discriminant can exist.
