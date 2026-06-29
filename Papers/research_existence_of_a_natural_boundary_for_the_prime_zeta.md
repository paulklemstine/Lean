# A Two-Sided Abscissa Bracket for the Prime-Ideal Zeta Function of an Imaginary Quadratic Field, with a Conjectural Natural Boundary

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Number Theory (Novelty)

## Abstract

We study the prime-ideal zeta function $P_K(s) = \sum_{\mathfrak{p}} N(\mathfrak{p})^{-s}$
of an imaginary quadratic field $K$ of class number one, taking the Gaussian
field $K = \mathbb{Q}(i)$ as the running model. Using the splitting law of
rational primes in $\mathbb{Z}[i]$ (governed by $p \bmod 4$), we organize $P_K$
as an explicit Dirichlet series over the rational primes and prove an
*unconditional two-sided bracket* on its abscissa of convergence: the series
converges absolutely for every $s > 1$ and diverges for every $s \le \tfrac{1}{2}$.
The upper bound (ceiling) follows from a pointwise comparison $\mathrm{term}(s,p)
\le 2\,p^{-s}$ against twice the rational prime zeta function; the lower bound
(floor) follows from a pointwise comparison $\mathrm{term}(s,p) \ge p^{-2s}$ using
the inert primes of norm $p^2$. We further establish strict positivity in the
region of convergence and a quantitative bridge $P_{\mathbb{Q}(i)}(s) \le
2\,P(s)$. We then formulate, and motivate, three conjectures that lie beyond the
elementary estimates: that the sharp abscissa is exactly $1$ (closing the
bracket, conditional on positive Dirichlet density of split primes), that the
analytic continuation of $P_K$ admits the imaginary axis $\mathrm{Re}(s) = 0$ as a
natural boundary, and that consequently no zeta-style regularization of the
"product of all prime ideals" can exist. The bracket cleanly isolates the inert
contribution (the unconditional floor) from the split contribution (the
conjectural ceiling and natural-boundary phenomenon).

---

## 1. Introduction

### 1.1 Regularizing divergent sums over primes

The Riemann zeta function $\zeta(s) = \sum_{n \ge 1} n^{-s}$ converges only for
$\mathrm{Re}(s) > 1$, yet its analytic continuation famously assigns finite
values such as $\zeta(-1) = -\tfrac{1}{12}$ at points where the series diverges.
This *regularization* underlies many computations in mathematical physics, from
the Casimir effect to string-theoretic mode sums. A recurring question is which
divergent sums can be regularized in this way, and which cannot.

The **prime zeta function**
$$P(s) = \sum_{p \text{ prime}} p^{-s}$$
is the prime-supported analogue of $\zeta$. Its convergence behavior is sharply
understood: it has abscissa of convergence exactly $1$. In particular, the value
"$\sum_p p$" at $s = -1$ never arises from the series itself, only (if at all)
from an analytic continuation. Moreover $P(s)$ is known to possess the line
$\mathrm{Re}(s) = 0$ as a *natural boundary* (Landau–Walfisz), so its
continuation cannot reach the imaginary axis.

### 1.2 The number-field generalization

For a number field $K$ with ring of integers $\mathcal{O}_K$, the prime-ideal
zeta function is
$$P_K(s) = \sum_{\mathfrak{p}} N(\mathfrak{p})^{-s},$$
the sum running over nonzero prime ideals $\mathfrak{p}$ of $\mathcal{O}_K$, with
$N(\mathfrak{p}) = |\mathcal{O}_K / \mathfrak{p}|$ the absolute norm. This is the
prime-supported logarithm of the Dedekind zeta function $\zeta_K$. We focus on
**imaginary quadratic fields of class number one**, whose arithmetic is fully
governed by an elementary splitting law, and we take $K = \mathbb{Q}(i)$
(discriminant $-4$, class number $1$) as the concrete model.

### 1.3 Contributions

The contributions of this paper are:

1. An explicit Dirichlet-series model of $P_{\mathbb{Q}(i)}(s)$, organized over
   rational primes via the $p \bmod 4$ splitting law (Section 2).
2. Two sharp pointwise bounds on each term — an upper bound $2\,p^{-s}$ and a
   lower bound $p^{-2s}$ — valid for $s \ge 0$ (Section 3).
3. An **unconditional abscissa bracket** $[\tfrac{1}{2}, 1]$: convergence for
   $s > 1$ and divergence for $s \le \tfrac{1}{2}$ (Section 4).
4. Strict positivity in the region of convergence, and a quantitative bridge
   $P_{\mathbb{Q}(i)}(s) \le 2\,P(s)$ (Section 5).
5. A general abstract model $P_K(s) = \sum_p \big((\deg_1 p)\,p^{-s} +
   (\mathrm{inert}\,p)\,p^{-2s}\big)$ with the same bracket (Section 6).
6. Three conjectures — sharp abscissa, natural boundary, regularization
   obstruction — with motivation (Section 7).

---

## 2. The Gaussian splitting law and the series model

### 2.1 Splitting of rational primes in $\mathbb{Z}[i]$

The factorization of a rational prime $p$ in the Gaussian integers $\mathbb{Z}[i]$
is determined entirely by $p \bmod 4$:

- **$p = 2$ (ramified):** $2 = -i\,(1+i)^2$, so a single prime ideal
  $\mathfrak{p} = (1+i)$ of norm $N(\mathfrak{p}) = 2$ lies above $2$.
- **$p \equiv 1 \pmod 4$ (split):** $p = \mathfrak{p}\,\overline{\mathfrak{p}}$
  with two distinct conjugate prime ideals, each of norm $p$. (E.g. $5 =
  (2+i)(2-i)$.)
- **$p \equiv 3 \pmod 4$ (inert):** $p$ remains prime in $\mathbb{Z}[i]$ and is a
  single prime ideal of norm $p^2$. (E.g. $3, 7, 11$.)

### 2.2 Definition of the per-prime term

**Definition 2.1 (Gaussian term).** For $s \in \mathbb{R}$ and a rational prime
$p$, define
$$
\mathrm{gaussTerm}(s, p) =
\begin{cases}
2^{-s}, & p = 2,\\
2\,p^{-s}, & p \equiv 1 \pmod 4,\\
p^{-2s}, & p \equiv 3 \pmod 4.
\end{cases}
$$

This is precisely the total contribution to $\sum_{\mathfrak{p} \mid p}
N(\mathfrak{p})^{-s}$ of all prime ideals above $p$: the ramified prime gives one
ideal of norm $2$; the split prime gives two ideals of norm $p$ (hence the factor
$2$); the inert prime gives one ideal of norm $p^2$ (hence the exponent $-2s$).

**Definition 2.2 (Gaussian prime-ideal zeta).** The **Gaussian prime-ideal zeta
function** is the sum over rational primes
$$P_{\mathbb{Q}(i)}(s) = \sum_{p \text{ prime}} \mathrm{gaussTerm}(s, p).$$

Because every prime ideal of $\mathbb{Z}[i]$ lies above a unique rational prime,
this reorganization is exactly $\sum_{\mathfrak{p}} N(\mathfrak{p})^{-s}$ with no
double counting and no omissions.

### 2.3 The rational prime zeta function

For comparison we also use the **rational prime zeta function**
$$P(s) = \sum_{p \text{ prime}} p^{-s}.$$

**Proposition 2.3 (abscissa of $P$).** $P(s)$ converges absolutely if and only
if $s > 1$.

*Proof sketch.* The summability of $p \mapsto p^{-s} = p^{r}$ over primes with
$r = -s$ holds iff $r < -1$, i.e. $s > 1$. Equivalently, $P$ shares the abscissa
$1$ of the full zeta series $\sum_n n^{-s}$. $\square$

In particular $P$ diverges for all $s \le 1$, recovering Euler's divergence of
$\sum_p 1/p$ at $s = 1$, and diverging a fortiori at $s = -1$ (the "sum of all
primes" point).

---

## 3. Pointwise bounds on the Gaussian term

All three estimates below are elementary and hold termwise; they are the entire
engine behind the abscissa bracket.

**Lemma 3.1 (nonnegativity).** For all $s \in \mathbb{R}$ and all primes $p$,
$$0 \le \mathrm{gaussTerm}(s, p).$$

*Proof sketch.* Each branch is a positive real power of a positive base (times a
nonnegative constant), hence nonnegative. $\square$

**Lemma 3.2 (upper bound).** For all $s \ge 0$ and all primes $p$,
$$\mathrm{gaussTerm}(s, p) \le 2\,p^{-s}.$$

*Proof sketch.* Branch by branch:
- $p = 2$: $2^{-s} \le 2 \cdot 2^{-s}$ since $1 \le 2$.
- $p \equiv 1 \pmod 4$: equality, $2\,p^{-s} = 2\,p^{-s}$.
- $p \equiv 3 \pmod 4$: since $p \ge 2 > 1$ and $-2s \le -s$ for $s \ge 0$, we have
  $p^{-2s} \le p^{-s} \le 2\,p^{-s}$ by monotonicity of $x \mapsto p^{x}$. $\square$

**Lemma 3.3 (lower bound).** For all $s \ge 0$ and all primes $p$,
$$p^{-2s} \le \mathrm{gaussTerm}(s, p).$$

*Proof sketch.* Branch by branch:
- $p = 2$: $2^{-2s} \le 2^{-s} = \mathrm{gaussTerm}(s,2)$ since $-2s \le -s$.
- $p \equiv 1 \pmod 4$: $p^{-2s} \le p^{-s} \le 2\,p^{-s}$, as above.
- $p \equiv 3 \pmod 4$: equality, $p^{-2s} = p^{-2s}$. $\square$

These two bounds bracket every term between an "inert-like" floor $p^{-2s}$ and a
"split-like" ceiling $2\,p^{-s}$.

---

## 4. The unconditional abscissa bracket

### 4.1 Convergence ceiling

**Theorem 4.1 (convergence for $s > 1$).** For every $s > 1$, the series
$\sum_p \mathrm{gaussTerm}(s, p)$ converges absolutely; equivalently
$P_{\mathbb{Q}(i)}(s)$ is a well-defined finite real number.

*Proof sketch.* By Lemma 3.1 the terms are nonnegative, and by Lemma 3.2 they
are dominated by $2\,p^{-s}$. The dominating series $\sum_p 2\,p^{-s} = 2P(s)$
converges for $s > 1$ by Proposition 2.3. Comparison
(`Summable.of_nonneg_of_le`) gives the result. $\square$

Thus the abscissa of convergence is $\le 1$.

### 4.2 Divergence floor

**Theorem 4.2 (divergence for $s \le \tfrac{1}{2}$).** For every $s$ with
$0 \le s \le \tfrac{1}{2}$, the series $\sum_p \mathrm{gaussTerm}(s, p)$
diverges.

*Proof sketch.* By Lemma 3.3 the terms dominate $p^{-2s}$. The minorant series
$\sum_p p^{-2s}$ is the rational prime zeta at the point $2s$, and since $2s \le 1$
it diverges by Proposition 2.3 (divergence on $\{ \cdot \le 1\}$). If the
Gaussian series converged, comparison would force the minorant to converge — a
contradiction. Hence divergence. $\square$

Thus the abscissa of convergence is $\ge \tfrac{1}{2}$. Note the divergence is
driven by the *inert* primes alone (norm $p^2$): it is an honest lower bound from
a genuinely infinite subfamily, not an artifact of an empty or degenerate sum.

### 4.3 The bracket

Combining Theorems 4.1 and 4.2:

**Corollary 4.3 (abscissa bracket).** The abscissa of convergence
$\sigma_c$ of $P_{\mathbb{Q}(i)}$ satisfies
$$\tfrac{1}{2} \le \sigma_c \le 1.$$
The floor at $\tfrac{1}{2}$ is forced by the inert primes; the ceiling at $1$ by
the split (and ramified) primes.

---

## 5. Positivity and the bridge to the rational primes

**Theorem 5.1 (strict positivity).** For every $s > 1$,
$$P_{\mathbb{Q}(i)}(s) > 0.$$

*Proof sketch.* The series converges (Theorem 4.1) and all terms are nonnegative
(Lemma 3.1). The ramified prime $p = 2$ contributes the strictly positive term
$2^{-s} > 0$. A convergent nonnegative series with one strictly positive term has
strictly positive sum (`Summable.tsum_pos` / `Summable.le_tsum` applied at the
witness $p = 2$). $\square$

**Theorem 5.2 (bridge inequality).** For every $s > 1$,
$$P_{\mathbb{Q}(i)}(s) \le 2\,P(s).$$

*Proof sketch.* Both sides converge for $s > 1$ (Theorem 4.1 and Proposition
2.3). Termwise, Lemma 3.2 gives $\mathrm{gaussTerm}(s, p) \le 2\,p^{-s}$. Summing
the inequality (`Summable.tsum_le_tsum`, with $\sum_p 2\,p^{-s} = 2P(s)$ via
`tsum_mul_left`) yields the claim. $\square$

The constant $2$ is structural: it is the field degree $[\mathbb{Q}(i):\mathbb{Q}]
= 2$, equivalently the maximal number of prime ideals above any rational prime.
It cannot be improved to a constant smaller than $2$, since for split primes the
ratio $\mathrm{gaussTerm}(s,p)/p^{-s}$ equals exactly $2$.

---

## 6. The general imaginary quadratic model

The Gaussian computation abstracts to an arbitrary imaginary quadratic field $K$
of class number one. The arithmetic is encoded by *splitting data* at each
rational prime $p$:

- $\deg_1(p) \in \{0, 1, 2\}$: the number of degree-one prime ideals above $p$
  (each of norm $p$). Split primes give $\deg_1 = 2$, ramified primes $\deg_1 = 1$.
- $\mathrm{inert}(p) \in \{0, 1\}$: the number of degree-two (inert) prime ideals
  above $p$ (each of norm $p^2$). Inert primes give $\mathrm{inert} = 1$.

**Definition 6.1 (general model).** With this data,
$$P_K(s) = \sum_{p \text{ prime}} \Big( \deg_1(p)\, p^{-s} + \mathrm{inert}(p)\, p^{-2s} \Big).$$

Specializing to $\mathbb{Q}(i)$: $\deg_1(2) = 1$ and $\mathrm{inert}(2) = 0$;
$\deg_1(p) = 2$, $\mathrm{inert}(p) = 0$ for $p \equiv 1 \pmod 4$; $\deg_1(p) = 0$,
$\mathrm{inert}(p) = 1$ for $p \equiv 3 \pmod 4$. This recovers Definition 2.1.

Because $\deg_1(p) \le 2$ and $\mathrm{inert}(p) \le 1$, the same two pointwise
bounds hold ($\mathrm{term} \le 2\,p^{-s}$ and $\mathrm{term} \ge p^{-2s}$ on the
inert primes), so the abscissa bracket $[\tfrac{1}{2}, 1]$ holds for every such
$K$. The model also exhibits the regularization obstruction for $s \le 0$: there
the inert terms $p^{-2s} = p^{|2s|}$ grow without bound, so the series cannot
converge anywhere on the closed half-plane to the left of the floor.

---

## 7. Conjectures beyond the elementary bracket

The bracket $[\tfrac{1}{2}, 1]$ is unconditional. The remaining field-dependent
ingredient — the *density of split primes* — is the gateway to the sharp results.

### 7.1 Sharp abscissa

**Conjecture 7.1 (abscissa exactly $1$).** For every imaginary quadratic field
$K$ of class number one, $P_K$ converges for $s > 1$ and diverges at $s = 1$; the
abscissa of convergence is exactly $1$.

*Motivation.* The gap $(\tfrac{1}{2}, 1]$ is controlled by the split primes
(those with quadratic character $\chi_d(p) = +1$). Their reciprocal sum
$\sum_{\chi_d(p) = +1} 1/p$ diverges, because Dirichlet's theorem on primes in
arithmetic progressions assigns density $\tfrac{1}{2}$ to the split class. The
inert primes only contribute the convergent tail $\sum_p p^{-2s}$ for $s$ near
$1$. An Abel partial-summation bridge from $\Lambda(p)/p$ to $1/p$ over a residue
class upgrades the $s \le \tfrac{1}{2}$ divergence to the sharp $s = 1$.

### 7.2 Natural boundary on the imaginary axis

**Conjecture 7.2 (natural boundary).** The analytic continuation of $P_K(s)$
(via $\log \zeta_K$) admits the line $\mathrm{Re}(s) = 0$ as a natural boundary:
it cannot be continued to any open set meeting the imaginary axis.

*Motivation.* The Möbius–log expansion
$$P_K(s) = \sum_{k \ge 1} \frac{\mu(k)}{k}\,\log \zeta_K(ks)$$
turns each nontrivial zero $\rho$ of $\zeta_K$ into a logarithmic singularity of
$P_K$ at every point $\rho/k$. These accumulate densely on $\mathrm{Re}(s) = 0$,
exactly as in Landau–Walfisz for the rational prime zeta. Class number one forces
the factorization $\zeta_K(s) = \zeta(s)\,L(s, \chi_d)$, so the zeros of both
$\zeta$ and $L(\cdot, \chi_d)$ contribute to the pile-up, reinforcing the wall.

### 7.3 Regularization obstruction

**Conjecture 7.3 (no regularized product of all prime ideals).** There is no
zeta-style regularized value for the "product of all prime ideals" of $K$,
because the relevant evaluation point $s = 0$ lies on the natural boundary
$\mathrm{Re}(s) = 0$ and is therefore unreachable by analytic continuation.

*Motivation.* A zeta-regularized product $\prod_{\mathfrak{p}} N(\mathfrak{p})$
would be computed from $-\frac{d}{ds} P_K(s)\big|_{s=0}$ (or an equivalent
continuation to $s = 0$). If $\mathrm{Re}(s) = 0$ is a natural boundary, no such
continuation to $s = 0$ exists, so the regularized product is not merely hard to
compute but genuinely undefined.

---

## 8. Algorithms

We summarize the computational procedures used to instantiate and verify the
results numerically (full code accompanies this work).

### 8.1 Splitting classification

Given a rational prime $p$, return its splitting type in $\mathbb{Z}[i]$:
ramified if $p = 2$; split if $p \equiv 1 \pmod 4$; inert if $p \equiv 3
\pmod 4$. Complexity $O(1)$ per prime.

### 8.2 Truncated Gaussian prime zeta

Sum $\mathrm{gaussTerm}(s, p)$ over all primes $p \le N$. Generate primes by a
sieve of Eratosthenes in $O(N \log\log N)$; evaluate each term in $O(1)$.

### 8.3 Bracket verification

For a grid of $s$-values, compare partial sums against the dominating bound
$2\,P_N(s)$ and the minorizing inert sum $\sum_{p \le N} p^{-2s}$, exhibiting
convergence for $s > 1$ and divergence (growth of partial sums with $N$) for
$s \le \tfrac{1}{2}$.

---

## 9. Applications and discussion

- **Spectral / physical regularization.** The natural-boundary obstruction
  formalizes *why* the "product of all prime ideals" resists zeta-regularization,
  in contrast to the regularized product of all integers ($\sqrt{2\pi}$).
- **Comparative arithmetic.** The bracket separates two universal contributions —
  inert (floor) and split (ceiling) — clarifying which features of $P_K$ are
  elementary and which require analytic input (Dirichlet density, $L$-function
  zeros).
- **Template for other fields.** The general model of Section 6 applies verbatim
  to all imaginary quadratic fields of class number one; only the splitting data
  $(\deg_1, \mathrm{inert})$, equivalently the Kronecker symbol $\chi_d$, changes.

---

## 10. Future work

The immediate program is to (i) prove Conjecture 7.1 via an Abel summation bridge
from the non-summability of the von Mangoldt function over an invertible residue
class to the divergence of $\sum 1/p$ over that class; (ii) formalize the
Möbius–log expansion and the accumulation-of-singularities lemma toward
Conjecture 7.2; and (iii) deduce Conjecture 7.3 as a corollary. All three rest on
mature $L$-function infrastructure (the factorization $\zeta_K = \zeta \cdot
L(\cdot, \chi_d)$, functional equations, Dirichlet's theorem) and on the
half-line obstruction already framed by the abscissa bracket.

---

## 11. Conclusion

We have established an unconditional two-sided bracket $[\tfrac{1}{2}, 1]$ for the
abscissa of convergence of the prime-ideal zeta function of the Gaussian field,
together with strict positivity and a factor-of-two bridge to the rational prime
zeta function, and we have abstracted these to all imaginary quadratic fields of
class number one. The floor at $\tfrac{1}{2}$ is the unconditional contribution of
the inert primes; the ceiling at $1$ and the conjectural natural boundary on the
imaginary axis are the contribution of the split primes and the zeros of the
field's zeta function. The bracket thus isolates exactly the field-dependent
ingredient — positive density of split primes — whose resolution would yield the
sharp abscissa, the natural boundary, and the impossibility of regularizing the
product of all prime ideals.
