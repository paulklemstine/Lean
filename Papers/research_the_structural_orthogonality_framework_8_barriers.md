# The Structural Orthogonality Framework: Eight Barriers to Classical Integer Factoring

**Author:** Aristotle
**Date:** 2026-08-12

---

## Abstract

We present a unified framework of eight structural barriers that explains the
uniform failure of a large class of proposed classical approaches to integer
factoring. The framework was synthesized from a systematic experimental
programme in which $284$ candidate invariants drawn from more than sixty
paradigms were tested against a common protocol — the *near-equal-$N$ test* —
and every one of them measured as uninformative about the hidden factors.

Three of the barriers are rigidity theorems. The **polynomial barrier** states
that no rational function, and more generally no nonzero algebraic relation over
$\mathbb{Q}$, connects a semiprime $N = pq$ to its smaller prime factor $p$; a
quantitative refinement bounds the number of semiprimes below $X$ on which a
fixed degree-$d$ polynomial succeeds by $d\,\pi(\sqrt X) \le d(\sqrt X + 1)$. The
**symmetry barrier** states that every power-sum invariant of the factor pair is
a fixed polynomial in the elementary symmetric functions $s = p+q$ and $N = pq$,
so that factor pairs sharing $(N, s)$ are indistinguishable by the whole family
at once. The **holomorphic (indeed meromorphic) rigidity barrier** states that
no function meromorphic at the origin satisfies $f(1/N) = 1/p$ across the
semiprimes.

Five further barriers are structural patterns made precise. **Computational
circularity**: the pair $(N,s)$ determines the factorization in closed form, and
$\sigma(N)$ and $\varphi(N)$ both reveal $s$, so any invariant that breaks the
symmetry barrier is already a factoring algorithm. **Known-method-in-disguise**:
for odd $N$, a nontrivial difference-of-squares representation is equivalent to a
nontrivial factorization, so such methods are Fermat's. **The multiplicative
dichotomy**, proved here in arbitrary degree: for any $F \in \mathbb{Z}[X]$ the
invariant $F(p)F(q)$ equals a universal polynomial $\Psi_F(s,N)$ of $s$-degree at
most $2\deg F$, and after fixing $N$ this polynomial is either constant (the
invariant takes the same value on every factorization of $N$) or nonconstant (the
hidden sum is one of at most $2\deg F$ explicitly computable roots). **Free-witness
aggregation** and, at the centre, **structural orthogonality**: on any finite
population equipped with a band label $n$ and a target $Y$, every invariant
$g \circ n$ computable from the band label alone is exactly orthogonal to the
residual $Y - E[Y \mid n]$. From this single identity follow the covariance
identity, the near-equal-$N$ test, the optimality of the band mean among all
$N$-only predictors, the band-spread law
$|\operatorname{corr}(g\circ n, Y)| \le \sqrt{\operatorname{Var}(E[Y\mid n])/\operatorname{Var}(Y)}$,
and its extensions to adaptive decision trees, randomized mixtures, and
finite-palette (quantized) strategies, where a depth–advantage collapse holds.

We also delimit the framework: the smaller prime factor *is* a function of $N$
alone, so the barriers are structural rather than information-theoretic; the
near-equal-$N$ test is vacuous for bands fine enough to separate the population;
and a two-point counterexample shows that the constant-band-mean hypothesis
cannot be dropped.

**Keywords:** integer factoring, semiprimes, structural orthogonality,
conditional expectation, band-spread law, polynomial rigidity, meromorphic
rigidity, multiplicative dichotomy, adaptive lower bounds.

---

## 1. Introduction

### 1.1 The problem and the persistence of the search

Let $p < q$ be distinct primes and $N = pq$ their product, a *semiprime*.
Recovering $p$ from $N$ is the integer factoring problem in its cryptographically
relevant form. The best known classical algorithm, the general number field
sieve, runs in time
$$L_N\!\left[\tfrac13, \sqrt[3]{64/9}\right]
= \exp\!\Bigl((1.9229\ldots + o(1))\,(\log N)^{1/3}(\log\log N)^{2/3}\Bigr),$$
sub-exponential but super-polynomial; the only known algorithm running in time
polynomial in $\log N$ requires a quantum computer.

The gap between these two regimes is enormous, and it has attracted a
correspondingly enormous volume of proposals: closed-form expressions, continued
fractions, analytic continuations, spectral heuristics, statistical "witnesses",
and, more recently, machine-learned predictors trained on features of $N$. They
fail. The interesting question is not *that* they fail but *whether they fail for
a common reason*.

### 1.2 The experimental programme

The framework presented here was distilled from a systematic experimental
programme: $284$ candidate invariants, gathered from more than sixty distinct
paradigms, were each subjected to the same protocol.

> **The near-equal-$N$ test.** Group semiprimes into narrow size bands (in
> practice by the value of $\lfloor N/40 \rfloor$). Within a band the modulus is
> essentially constant while the hidden factor pair varies widely. Compute the
> candidate invariant across the band and measure its correlation with the
> smaller factor $p$. An invariant that varies across the band but correlates
> $\approx 0$ with $p$ once $N$ has been controlled for is declared **$N$-only**:
> it is a repackaging of the modulus and carries no factor information.

Every invariant computable from $N$ alone tested as $N$-only. This paper explains
why, by isolating eight barriers and proving each of them.

### 1.3 Overview of the eight barriers

| # | Barrier | Nature | Content |
|---|---------|--------|---------|
| 1 | Polynomial / algebraic | theorem | No nonzero algebraic relation over $\mathbb{Q}$ links $N$ and $p$ |
| 2 | Counting | theorem | A degree-$d$ formula succeeds on $O(d\sqrt X)$ semiprimes below $X$ |
| 3 | Meromorphic rigidity | theorem | No function meromorphic at $0$ realizes $f(1/N) = 1/p$ |
| 4 | Symmetry | theorem | Power-sum invariants are functions of $(s, N)$ only |
| 5 | Computational circularity | theorem | $(N,s)$ factors $N$ in closed form; $\sigma$, $\varphi$ reveal $s$ |
| 6 | Known-method-in-disguise | theorem | Difference-of-squares $\equiv$ Fermat factorization |
| 7 | Multiplicative dichotomy | theorem | Every polynomial multiplicative invariant is constant-on-fibres or sum-revealing |
| 8 | Structural orthogonality | theorem | Every $N$-only statistic is orthogonal to the residual $Y - E[Y\mid n]$ |

Barrier 8 subsumes free-witness aggregation, adaptivity, randomization and
quantization as corollaries; it is the analytical core of the framework.

### 1.4 What this paper does not claim

This is a research deliverable, not a claim of a factoring breakthrough, and not
a proof that factoring is hard. Two facts, both proved below in Section 8,
constrain every statement:

1. the smaller prime factor *is* a function of $N$ alone (trial division computes
   it), so no barrier here can be information-theoretic; and
2. an $N$-only invariant *can* correlate with $p$ across bands, so every
   zero-correlation statement must be conditional on the band structure.

---

## 2. Notation and standing conventions

Throughout, $p$ and $q$ denote distinct primes with $p < q$ and $N = pq$. We
write
$$s = p + q, \qquad N = pq$$
for the elementary symmetric functions of the factor pair. For polynomials we
work over $\mathbb{Q}$ or $\mathbb{Z}$ as indicated, and $\deg$ denotes the
degree. For the probabilistic part, $\Omega$ is a finite nonempty population,
$\kappa$ a set of band labels, $n : \Omega \to \kappa$ the band map, and
$Y : \Omega \to \mathbb{R}$ the target (in the application, $Y(i) = p_i$, the
smaller factor of the $i$-th semiprime). All expectations are with respect to the
uniform law on $\Omega$:
$$E[Z] = \frac{1}{|\Omega|}\sum_{i \in \Omega} Z(i), \qquad
\operatorname{cov}(X,Y) = E[XY] - E[X]E[Y], \qquad
\operatorname{Var}(X) = \operatorname{cov}(X,X).$$
The **band** of $i$ is $\mathrm{Band}(i) = \{ j \in \Omega : n(j) = n(i)\}$, and
the **band mean** (conditional expectation) is
$$E[Y \mid n](i) = \frac{1}{|\mathrm{Band}(i)|}\sum_{j \in \mathrm{Band}(i)} Y(j).$$
An **$N$-only invariant** is a random variable of the form $i \mapsto g(n(i))$
for some $g : \kappa \to \mathbb{R}$.

---

## 3. Rigidity barriers: algebra

### 3.1 The polynomial and rational barriers

**Theorem 3.1 (Polynomial barrier).** *There is no $P \in \mathbb{Q}[X]$ with
$P(pq) = p$ for all primes $p < q$.*

**Theorem 3.2 (Rational escape is illusory).** *There are no
$A, B \in \mathbb{Q}[X]$ such that, for all primes $p < q$, $B(pq) \ne 0$ and*
$$A(pq) = p \cdot B(pq).$$

*Proof sketch.* Theorem 3.1 is the case $B = 1$. For Theorem 3.2, set
$C = A - 3B$. For $p = 3$ and any prime $q > 3$ the hypothesis gives
$A(3q) = 3B(3q)$, i.e. $C(3q) = 0$. Since there are infinitely many primes
$q > 3$ and the map $q \mapsto 3q$ is injective, $C$ has infinitely many roots in
$\mathbb{Q}$, so $C = 0$ and $A = 3B$ identically. Evaluating at
$N = 35 = 5 \cdot 7$ gives $5 B(35) = A(35) = 3 B(35)$, whence $B(35) = 0$,
contradicting the non-vanishing hypothesis. $\square$

The mechanism is worth isolating, because all three algebraic barriers share it:
*fixing the small factor makes the sample points accumulate* (here, spread out to
infinity along an arithmetic progression), *and rigidity of the function class
then forces a constant, which two different choices of small factor contradict.*

### 3.2 The algebraic barrier

The strongest algebraic statement asks not for a formula but merely for a
relation.

**Theorem 3.3 (Algebraic barrier).** *Let $F$ be a polynomial in two variables
over $\mathbb{Q}$, written as $F \in (\mathbb{Q}[X])[Y]$. If*
$$F(N, p) = 0 \qquad \text{for every semiprime } N = pq,\ p<q \text{ prime},$$
*then $F = 0$.*

*Proof sketch.* Two applications of "a nonzero polynomial over an integral domain
has finitely many roots". First, fix a prime $p$ and consider the specialization
$H_p(X) = F(X, p) \in \mathbb{Q}[X]$. It vanishes at $pq$ for every prime
$q > p$; these are infinitely many distinct rationals, so $H_p = 0$. Second,
regard $F$ as a polynomial in $Y$ with coefficients in the integral domain
$\mathbb{Q}[X]$. The elements $p \in \mathbb{Q} \subseteq \mathbb{Q}[X]$, one for
each prime, are then infinitely many distinct roots of $F$, so $F = 0$. $\square$

Theorems 3.1 and 3.2 are corollaries: the relation $Y - P(X)$, respectively
$A(X) - Y B(X)$, would be a nonzero witness.

### 3.3 The counting barrier

Impossibility in the limit is compatible with overwhelming success in practice.
It is not.

**Theorem 3.4 (Per-factor counting bound).** *Let $P \in \mathbb{Q}[X]$ and let
$p$ be a prime with $P \ne p$ (as polynomials). Then*
$$\#\{ q \text{ prime}: q > p,\ P(pq) = p \} \le \deg P .$$

*Proof sketch.* Each such $q$ makes $pq$ a root of the nonzero polynomial
$P - p$, and $q \mapsto pq$ is injective; a nonzero polynomial of degree $d$ has
at most $d$ roots. $\square$

**Theorem 3.5 (Global counting barrier).** *Let $P \in \mathbb{Q}[X]$ with
$\deg P \ge 1$ and let $X \ge 1$. Then*
$$\#\{(p,q) : p<q \text{ prime},\ pq \le X,\ P(pq)=p\}
\;\le\; \deg P \cdot \pi(\sqrt X) \;\le\; \deg P \cdot (\sqrt X + 1).$$
*The analogous bound holds for rational functions $A/B$ with $\deg P$ replaced by
$\max(\deg A, \deg B)$.*

*Proof sketch.* Partition the success set by the small factor $p$. Since
$p < q$ and $pq \le X$ we have $p \le \sqrt X$, so only $\pi(\sqrt X)$ values of
$p$ occur; each fibre has at most $\deg P$ elements by Theorem 3.4. $\square$

**Corollary 3.6 (Success density).** The number of semiprimes below $X$ is
asymptotically $X\log\log X/\log X$. Hence the success *density* of any fixed
polynomial or rational formula is $O(X^{-1/2}\log X/\log\log X) \to 0$: as soon as
the number of semiprimes below $X$ exceeds $\deg P\,(\sqrt X + 1)$, an explicit
failure is guaranteed to exist below $X$.

---

## 4. Rigidity barriers: analysis

Algebraic rigidity rests on root counting; analytic rigidity rests on the
identity theorem, which is stronger — and hence gives a stronger barrier, since
the class of functions is larger.

Rather than asking for $f(N) = p$, which would require control at infinity, we
invert: sample at $1/N$ and ask for $1/p$. The reciprocals of semiprimes with a
fixed small factor accumulate at the origin, and rigidity bites there.

**Theorem 4.1 (Holomorphic rigidity barrier).** *There is no entire function
$f : \mathbb{C}\to\mathbb{C}$ with*
$$f\!\left(\frac{1}{pq}\right) = \frac{1}{p}
\qquad \text{for all primes } p<q .$$

*Proof sketch.* Fix $p=3$. The points $u_k = 1/(3q_k)$, with $q_k$ the increasing
primes above $3$, are nonzero and tend to $0$, and $f(u_k) = 1/3$ for all $k$. An
entire function taking the same value on a sequence of distinct points converging
inside its domain is constant, by the identity theorem applied to $f - 1/3$;
hence $f \equiv 1/3$. But $f(1/35) = 1/5$ by hypothesis, and $1/3 \ne 1/5$.
$\square$

**Theorem 4.2 (Meromorphic rigidity barrier).** *The same conclusion holds under
the far weaker assumption that $f$ is merely meromorphic at $0$ — that is, has an
isolated, non-essential singularity there. In particular, no entire function, no
finite-order entire function, no rational function and no function with a finite
pole at the origin satisfies $f(1/N) = 1/p$ across the semiprimes. Moreover only
the two families $p = 3$ and $p = 5$ are used, so the barrier applies to any
function asked to compute the factor only for these two small primes.*

*Proof sketch.* Replace the identity theorem by the local dichotomy for isolated
singularities: a function meromorphic at $0$ either vanishes on a punctured
neighbourhood of $0$ or is nonzero on one. Apply it to $g = f - 1/3$. The points
$1/(3q)$ accumulate at $0$ and $g$ vanishes at all of them, ruling out the second
alternative; hence $g$ vanishes identically near $0$. The points $1/(5q)$ also
accumulate at $0$, and there $g = 1/5 - 1/3 \ne 0$ — a contradiction. $\square$

This closes what was, in an earlier stage of the programme, a conjecture: the
entirety hypothesis in Theorem 4.1 is an artifact of the proof method, not of the
phenomenon.

---

## 5. Symmetry and circularity

### 5.1 The symmetry barrier

**Definition 5.1.** For $e_1, e_2 \in \mathbb{Z}$ define the *Newton sequence*
$$T_0(e_1,e_2)=2,\quad T_1(e_1,e_2)=e_1,\quad
T_{k+2}(e_1,e_2) = e_1 T_{k+1}(e_1,e_2) - e_2 T_k(e_1,e_2).$$

**Theorem 5.2 (Newton's identity; the symmetry barrier).** *For all integers
$p, q$ and all $k \ge 0$,*
$$T_k(p+q,\ pq) = p^k + q^k .$$
*Consequently, if $(p,q)$ and $(p',q')$ satisfy $pq = p'q'$ and $p+q = p'+q'$,
then $p^k+q^k = p'^k+q'^k$ for every $k$: the two factorizations are
indistinguishable by the entire family of power-sum invariants simultaneously.*

*Proof sketch.* Strong induction on $k$, using
$p^{k+2}+q^{k+2} = (p+q)(p^{k+1}+q^{k+1}) - pq(p^k+q^k)$. The point of the
statement is not the identity but its *shape*: the recursion refers only to the
symmetric data $(e_1,e_2)$ and never to $p$ and $q$ separately. $\square$

### 5.2 Computational circularity

**Theorem 5.3 (Closed-form recovery from the sum).** *Let $p \le q$ be integers,
$N = pq$ and $s = p+q$. Then $s^2 - 4N = (q-p)^2$ is a perfect square, and*
$$p = \frac{s - \sqrt{s^2-4N}}{2}, \qquad q = \frac{s + \sqrt{s^2-4N}}{2}.$$

**Theorem 5.4 (Circularity of $\sigma$ and $\varphi$).** *For distinct primes
$p, q$ and $N = pq$,*
$$\sigma(N) = (1+p)(1+q) = N + 1 + s, \qquad
\varphi(N) = (p-1)(q-1) = N + 1 - s .$$
*Hence $s = \sigma(N) - N - 1 = N + 1 - \varphi(N)$, and by Theorem 5.3 both
$\sigma(N)$ and $\varphi(N)$ determine the factorization of $N$ in closed form.
Computing either invariant for a semiprime is therefore at least as hard as
factoring it.*

Theorems 5.2–5.4 together are the **circularity trap**: an invariant that
respects the symmetry of the factor pair is blind, while an invariant that breaks
it is a factoring algorithm.

### 5.3 Known-method-in-disguise

**Theorem 5.5 (Fermat equivalence).** *Let $N$ be odd. Then*
$$\exists\, a,b \in \mathbb{Z},\ 0 \le b,\ b+1 < a,\ N = a^2 - b^2
\iff
\exists\, u,v \in \mathbb{Z},\ 1 < u \le v,\ N = uv .$$

*Proof sketch.* ($\Rightarrow$) Take $u = a-b$, $v = a+b$; the strict inequality
$b+1 < a$ makes $u > 1$. ($\Leftarrow$) $N$ odd forces $u$ and $v$ odd, say
$u = 2m+1$, $v = 2n+1$; then $a = m+n+1$ and $b = n-m$ satisfy
$a^2 - b^2 = uv = N$ with $b \ge 0$ and $a > b+1$. $\square$

The two notions coincide exactly. A method whose output is a nontrivial
difference of squares is not structurally new; whatever novelty it has must be
argued at the level of running time.

---

## 6. The multiplicative dichotomy in arbitrary degree

### 6.1 The classical invariants

**Theorem 6.1 (Constant side).** *For distinct primes $p,q$ and $N=pq$:*
$$\tau(N) = 4, \qquad \omega(N) = 2, \qquad \mu(N) = 1 .$$
*These invariants are literally constant on the set of semiprimes; they cannot
distinguish any two semiprimes, let alone their factors.*

Combined with Theorem 5.4, this establishes the empirical "$N$-only or circular"
pattern for the classical multiplicative invariants: no third behaviour occurs.

### 6.2 Symmetric reduction

Let $F \in \mathbb{Z}[X]$ and consider the multiplicative invariant
$T = F(p)F(q)$ — the value of a multiplicative arithmetic function at $N$ when
that function is given by $F$ at primes.

**Theorem 6.2 (Symmetric reduction identity).** *Let $F \in \mathbb{Z}[X]$ and
$p,q \in \mathbb{Z}$. Divide $F$ by the monic quadratic
$(X-p)(X-q) = X^2 - sX + N$ and write the remainder as $BX + A$. Then*
$$F(p) = Bp + A, \qquad F(q) = Bq + A, \qquad
F(p)F(q) = A^2 + ABs + B^2N .$$

*Proof sketch.* Evaluate the division identity $F = Q\cdot(X-p)(X-q) + BX + A$ at
$X = p$ and $X = q$; then multiply and use $p+q=s$, $pq=N$:
$(Bp+A)(Bq+A) = B^2pq + AB(p+q) + A^2$. $\square$

**Theorem 6.3 (Reduction slope).** *If $p \ne q$ then $B = 0$ if and only if
$F(p) = F(q)$. In that case $F(p)F(q) = A^2$ is a perfect square; otherwise
$s = (T - A^2 - B^2N)/(AB)$ whenever $AB \ne 0$, and the factorization follows
from Theorem 5.3.*

The catch is that $A$ and $B$ as computed above depend on $p$ and $q$, which an
algorithm does not know. The next theorem removes that objection by performing
the reduction *generically*.

### 6.3 The generic reduction and the universal invariant polynomial

Work in the ring $\mathbb{Z}[N][s]$, treating $N$ and $s$ as independent formal
symbols, and reduce powers of $X$ modulo $X^2 - sX + N$ via the recursion
$$X^{k+1} \equiv (B_k s + A_k)X - N B_k,
\qquad A_0 = 1,\ B_0 = 0 \ \ (\text{for } X^0 = 1),$$
so that $X^k \equiv B_k X + A_k$ with $A_k, B_k \in \mathbb{Z}[N][s]$ and
$\deg_s A_k \le k$, $\deg_s B_k < k$. Extending by linearity to $F$ gives
$A_F, B_F$, and we define the **universal invariant polynomial**
$$\boxed{\ \Psi_F(s, N) \;=\; A_F^2 + A_F B_F\, s + B_F^2 N\ }$$

**Theorem 6.4 (Genericity).** *For all integers $p,q$,*
$$\Psi_F(p+q,\ pq) = F(p)F(q),$$
*and $\deg_s \Psi_F \le 2 \deg F$.*

*Proof sketch.* Both statements are proved by the evaluation homomorphism
$\mathbb{Z}[N][s] \to \mathbb{Z}$ sending $s \mapsto p+q$, $N \mapsto pq$. Under
it the generic recursion specializes to the concrete reduction of Theorem 6.2,
because $r = p$ (or $r=q$) satisfies $r^2 = (p+q)r - pq$. The degree bound
follows from $\deg_s A_F \le \deg F$ and $\deg_s B_F \le \deg F$ (indeed
$\deg_s B_F < \deg F$), by induction along the recursion. $\square$

### 6.4 The dichotomy

Fix a modulus $N$ and set $\psi = \Psi_F(\cdot, N) \in \mathbb{Z}[s]$, a
polynomial computable from $N$ and $F$ alone.

**Theorem 6.5 (General-degree multiplicative dichotomy).** *Exactly one of the
following holds.*

1. **($N$-only side.)** $\psi$ *is constant. Then for every factorization
   $N = pq$ we have $F(p)F(q) = \psi(0)$: the invariant takes one and the same
   value on all factor pairs of $N$, carrying literally no information about the
   factors.*
2. **(Circular side.)** $\psi$ *is nonconstant of degree at most $2\deg F$. Then
   for every factorization $N = pq$, writing $T = F(p)F(q)$ for the observed
   value, the polynomial $\psi - T$ is nonzero, has $s = p+q$ among its roots, and
   has at most $2 \deg F$ roots. Hence the hidden sum is one of at most
   $2\deg F$ explicitly computable candidates, and each candidate yields a
   candidate factorization in closed form by Theorem 5.3.*

*Proof sketch.* If $\deg\psi = 0$, evaluate Theorem 6.4 at any factorization: the
value is the constant coefficient. If $\deg \psi \ge 1$, then subtracting the
constant $T$ cannot lower the degree, so $\psi - T \ne 0$; Theorem 6.4 says
$(\psi - T)(p+q) = 0$; and a nonzero polynomial has at most $\deg$ many roots.
$\square$

**Corollary 6.6 (Both branches occur).** For $F = X$ one computes
$\Psi_X(s,N) = N$, constant in $s$: the identity invariant is $N$-only, as it must
be, since $F(p)F(q) = pq = N$. For $F = X + c$ with $c \ne 0$ one gets
$\Psi_F(s,N) = N + cs + c^2$, of degree $1$, and the sum is recovered by a single
division: $s = (T - N - c^2)/c$. For $F = X^2+1$ and $N = 15$ the specialized
polynomial evaluates to $260$ at $s = 8$, matching
$F(3)F(5) = 10 \cdot 26 = 260$; the degree is $2$, so at most two candidate sums
arise.

So the empirical trichotomy ("useless / partially informative / equivalent to
factoring") is in fact a **dichotomy**: there is no partially informative
polynomial multiplicative invariant. Between the two branches lies only a search
over at most $2\deg F$ candidates.

---

## 7. Structural orthogonality: the statistical core

We now leave arithmetic entirely. The results of this section are theorems about
finite populations; their force in the application comes from the identification
of "invariant computable from $N$ alone" with "function of the band label".

### 7.1 The fundamental identity

**Theorem 7.1 (Structural orthogonality).** *Let $\Omega$ be a finite population,
$n : \Omega \to \kappa$ a band map, $Y : \Omega \to \mathbb{R}$ a target, and
$g : \kappa \to \mathbb{R}$ arbitrary. Then*
$$\sum_{i\in\Omega} g(n(i))\,\bigl(Y(i) - E[Y\mid n](i)\bigr) = 0 .$$

*Proof sketch.* Partition $\Omega$ into the fibres of $n$ and sum band by band.
On a fibre, $g(n(i))$ is a constant and factors out of the sum; what remains is
$\sum_{j \in \mathrm{Band}} (Y(j) - E[Y\mid n](j))$, and since the band mean is
constant on the band and equals the average of $Y$ there, this is
$\sum_j Y(j) - |\mathrm{Band}|\cdot \overline{Y} = 0$. $\square$

Taking $g \equiv 1$ gives the tower property $E\bigl[E[Y\mid n]\bigr] = E[Y]$.

### 7.2 Covariance and the near-equal-$N$ test

**Theorem 7.2 (All correlation is band correlation).** *For every $g$,*
$$\operatorname{cov}(g\circ n,\ Y) = \operatorname{cov}\bigl(g\circ n,\ E[Y\mid n]\bigr).$$

*Proof sketch.* Theorem 7.1 states exactly that
$E[(g\circ n) Y] = E[(g\circ n) E[Y\mid n]]$; combine with the tower property.
$\square$

**Theorem 7.3 (Near-equal-$N$ test).** *If the band means are constant on the
population, $E[Y\mid n](i) = c$ for all $i \in \Omega$, then for every $g$,*
$$\operatorname{cov}(g\circ n,\ Y) = 0
\quad\text{and}\quad
\operatorname{corr}(g\circ n,\ Y) = 0 .$$

*Proof sketch.* By Theorem 7.2 the covariance equals that of $g\circ n$ with a
constant, which is $0$; the correlation is the covariance divided by a product of
standard deviations. $\square$

This is the formal content of the experimental protocol. Grouping semiprimes into
narrow bands is precisely an attempt to make $E[p \mid N\text{-band}]$ constant;
to the extent it succeeds, *every* $N$-only invariant is forced to measure zero
correlation with $p$ — not as a statistical accident, but identically.

### 7.3 The band mean is the best $N$-only predictor

**Theorem 7.4 (Squared-error decomposition).** *For every $g$,*
$$\sum_{i\in\Omega}\bigl(g(n(i)) - Y(i)\bigr)^2
= \underbrace{\sum_{i\in\Omega}\bigl(g(n(i)) - E[Y\mid n](i)\bigr)^2}_{\text{excess}}
+ \underbrace{\sum_{i\in\Omega}\bigl(E[Y\mid n](i) - Y(i)\bigr)^2}_{\text{irreducible}} .$$

*Proof sketch.* Expand the square around $E[Y\mid n]$; the cross term is
$2\sum_i (g(n(i)) - E[Y\mid n](i))(E[Y\mid n](i)-Y(i))$, which vanishes by
Theorem 7.1 applied to the band-label function $k \mapsto g(k) - \bar Y_k$ (where
$\bar Y_k$ is the band mean as a function of the label). $\square$

**Corollary 7.5 (Best-predictor barrier).** *For every $g$,*
$$\sum_{i\in\Omega}\bigl(E[Y\mid n](i) - Y(i)\bigr)^2
\le \sum_{i\in\Omega}\bigl(g(n(i)) - Y(i)\bigr)^2 .$$
*No $N$-only invariant predicts the hidden factor better than the band mean, and
the excess error of any invariant is exactly its squared deviation from the band
mean.*

### 7.4 Free-witness aggregation

**Theorem 7.6 (Free-witness aggregation).** *Let $g_1,\dots,g_m : \kappa \to
\mathbb{R}$ be $N$-only witnesses and let
$\Phi : \mathbb{R}^m \to \mathbb{R}$ be an arbitrary — possibly highly nonlinear
— aggregation rule. Then $i \mapsto \Phi(g_1(n(i)),\dots,g_m(n(i)))$ is itself an
$N$-only invariant. Consequently, under the constant-band-mean hypothesis its
covariance with $Y$ is exactly zero, and in general it cannot beat the band mean
in squared error.*

*Proof sketch.* The composite is $g \circ n$ for
$g(k) = \Phi(g_1(k),\dots,g_m(k))$; apply Theorems 7.3 and Corollary 7.5.
$\square$

This is the barrier that covers learned predictors: any model whose inputs are
functions of $N$ is, whatever its architecture, a function of $N$.

### 7.5 The band-spread law

The hypothesis of Theorem 7.3 is idealized. The following results replace it by a
quantitative estimate, with no hypothesis at all.

**Theorem 7.7 (Cauchy–Schwarz form).** *For every $g$,*
$$\operatorname{cov}(g\circ n, Y)^2
\le \operatorname{Var}(g\circ n)\cdot \operatorname{Var}\bigl(E[Y\mid n]\bigr) .$$

*Proof sketch.* Combine Theorem 7.2 with the Cauchy–Schwarz inequality for the
empirical covariance. $\square$

**Theorem 7.8 (Law of total variance).** 
$$\operatorname{Var}(Y)
= \frac{1}{|\Omega|}\sum_{i\in\Omega}\bigl(Y(i) - E[Y\mid n](i)\bigr)^2
+ \operatorname{Var}\bigl(E[Y\mid n]\bigr).$$

**Theorem 7.9 (Band-spread law).** *Assume $\operatorname{Var}(Y) > 0$. For every
$g$,*
$$\bigl|\operatorname{corr}(g\circ n, Y)\bigr|
\le \sqrt{\frac{\operatorname{Var}(E[Y\mid n])}{\operatorname{Var}(Y)}}
= \sqrt{1 - \frac{\text{within-band error}}{\operatorname{Var}(Y)}} .$$
*In particular, if the band means have spread at most $\varepsilon$ times that of
the target, $\operatorname{Var}(E[Y\mid n]) \le \varepsilon \operatorname{Var}(Y)$,
then every $N$-only invariant satisfies
$|\operatorname{corr}(g\circ n, Y)| \le \sqrt{\varepsilon}$; and zero band spread
forces exactly zero correlation.*

The significance of Theorem 7.9 is methodological. The entire experimental
programme — hundreds of invariants, dozens of paradigms — reduces to a single
scalar quantity of the *population*, $\operatorname{Var}(E[p \mid N\text{-band}])$,
which involves no invariant at all. Bounding it is a question about the
distribution of the smaller prime factor in a size band; every measured
correlation is then bounded uniformly over all invariants, simultaneously.

---

## 8. Adaptivity, randomness, and quantization

Three escape routes remain open in principle. Each is closed.

### 8.1 Adaptive strategies

**Definition 8.1.** A *decision tree* over $\Omega$ is either a leaf carrying a
function $\Omega \to \mathbb{R}$, or an internal node carrying a predicate on
$\Omega$ together with two subtrees; its evaluation $t(i)$ follows the branch
selected by the predicate at $i$. A function $f$ on $\Omega$ is *band-measurable*
if $n(i)=n(j)$ implies $f(i)=f(j)$ for $i,j\in\Omega$. A tree is *$N$-only* if
every internal predicate and every leaf function is band-measurable.

**Lemma 8.2.** *A band-measurable function factors as $g\circ n$ for some $g$; and
the evaluation of an $N$-only decision tree is band-measurable.* (Structural
induction on the tree.)

**Theorem 8.3 (Adaptive barrier).** *For every $N$-only decision tree $t$,*
$$\sum_{i\in\Omega}\bigl(E[Y\mid n](i) - Y(i)\bigr)^2
\le \sum_{i\in\Omega}\bigl(t(i) - Y(i)\bigr)^2 ,$$
*with the excess equal to $\sum_i (t(i)-E[Y\mid n](i))^2$. The bound is uniform in
the depth, the size and the branching structure of $t$; moreover
$\operatorname{cov}(t, Y) = \operatorname{cov}(t, E[Y\mid n])$, so the
near-equal-$N$ test applies verbatim to adaptive strategies.*

*Proof sketch.* By Lemma 8.2 write $t = g\circ n$ and apply Theorem 7.4 and
Corollary 7.5. $\square$

**Theorem 8.4 (The band-measurability hypothesis is necessary).** *There exist a
two-point population and a depth-$0$ tree attaining squared error $0$ while the
band mean has error $1/2$. Hence Theorem 8.3 genuinely requires that tests and
outputs be computable from the band label.*

The hypothesis is nevertheless met by the strategies the framework is about: any
tree whose internal tests are threshold comparisons $w(n(i)) \ge \theta$ of free
witnesses and whose leaves are $N$-only invariants is $N$-only in the sense of
Definition 8.1.

### 8.2 Randomized strategies

**Definition 8.5.** Given strategies $t_1,\dots,t_m$ and weights $w_j \ge 0$ with
$\sum_j w_j = 1$, the *mixture risk* is
$R = \sum_j w_j \sum_{i\in\Omega} (t_j(i)-Y(i))^2$, and the *mean predictor* is
$m(i) = \sum_j w_j t_j(i)$.

**Theorem 8.6 (Bias–variance identity for mixtures).**
$$R \;=\; \sum_{i\in\Omega}\bigl(m(i)-Y(i)\bigr)^2
\;+\; \sum_{i\in\Omega}\sum_{j} w_j\bigl(t_j(i)-m(i)\bigr)^2 .$$

*Proof sketch.* Pointwise in $i$, expand
$\sum_j w_j (t_j(i)-Y(i))^2$ around $m(i)$; the cross term vanishes because
$\sum_j w_j (t_j(i)-m(i)) = 0$. $\square$

**Corollary 8.7 (Randomization never helps, and usually hurts).** $R$ is at least
the error of the mean predictor, with equality if and only if all strategies of
positive weight agree pointwise on $\Omega$.

**Theorem 8.8 (Randomized barrier, with equality clause).** *If every $t_j$ is an
$N$-only decision tree, then*
$$\sum_{i\in\Omega}\bigl(E[Y\mid n](i)-Y(i)\bigr)^2 \le R,$$
*uniformly in the number of strategies, their sizes and the weights. Equality
holds if and only if every strategy of positive weight reproduces the band mean
on the whole population.*

*Proof sketch.* The mean predictor of band-measurable strategies is
band-measurable, so Theorem 8.3 applies to it; alternatively average the
per-strategy bounds. For equality, a sum $\sum_j w_j(\text{error}_j - E)$ of
non-negative terms vanishes iff each term does, and Theorem 7.4 identifies the
vanishing of the excess with $t_j = E[Y\mid n]$ on $\Omega$. $\square$

### 8.3 Quantization and the depth–advantage collapse

The adaptive barrier is uniform but not quantitative: it does not say how far a
*small* strategy must be from optimal. The following sharpens it.

**Definition 8.9.** For a finite nonempty palette $V \subset \mathbb{R}$, the
*quantization error* of the band means against $V$ is
$$\mathrm{QE}(V) = \sum_{i\in\Omega}\ \min_{v\in V}\ \bigl(v - E[Y\mid n](i)\bigr)^2 .$$

**Theorem 8.10 (Quantized barrier).** *Every $N$-only predictor with values in
$V$ satisfies*
$$\mathrm{QE}(V) + \sum_{i\in\Omega}\bigl(E[Y\mid n](i)-Y(i)\bigr)^2
\;\le\; \sum_{i\in\Omega}\bigl(\text{predictor}(i)-Y(i)\bigr)^2 .$$

**Theorem 8.11 (Depth–advantage collapse).** *Fix a palette $V$. Every $N$-only
adaptive strategy whose outputs lie in $V$ — of any size, any depth, any
branching pattern — obeys the same lower bound of Theorem 8.10. Since a
constant-leaf tree of size $\sigma$ emits at most $\sigma + 1$ distinct values,
enlarging the tree beyond the point at which its palette is realized cannot
improve the prediction.*

**Theorem 8.12 (Strictness).** *If some band mean lies outside the palette of a
strategy, then $\mathrm{QE}(V) > 0$ and the strategy is strictly worse than the
band mean.*

*Proof sketches.* Theorem 8.10 follows from Theorem 7.4 by bounding the excess
term pointwise below by the per-point quantization error; Theorem 8.11 from
Lemma 8.2 plus the palette bound; Theorem 8.12 because a finite palette missing a
value $\beta$ has positive distance to $\beta$. $\square$

---

## 9. The boundary of the framework

A barrier framework that cannot say where it stops is not a barrier framework.
Three explicit limitations are part of the result.

**Theorem 9.1 (The barriers are not information-theoretic).** *There is a
function $g : \mathbb{N}\to\mathbb{N}$ of $N$ alone with $g(pq) = p$ for all
primes $p<q$ — namely the least-prime-factor function.*

*Proof sketch.* For $p<q$ primes, the least prime divisor of $pq$ is $p$: any
prime dividing $pq$ is $p$ or $q$, and $p<q$. $\square$

Consequently the slogan "any computable function of $N$ alone is $N$-only" must
be read *structurally*. What the barriers exclude are richly structured classes:
polynomial, rational, algebraic, meromorphic, symmetric-power-sum, multiplicative
polynomial, and band-measurable statistics. Trial division escapes all of them
not by cleverness but by cost.

**Theorem 9.2 (Fine bands make the test vacuous).** *If $n$ is injective on
$\Omega$, then $E[Y\mid n] = Y$ on $\Omega$, the residual vanishes identically,
and the irreducible error in Theorem 7.4 is $0$.*

In the extreme case where the band label is $N$ itself and no two population
points share a modulus, every statement of Section 7 degenerates to a tautology.
The protocol's power comes from the *coarseness* of the band, and the band-spread
law (Theorem 7.9) is the quantitative expression of that trade-off: coarser bands
mean smaller $\operatorname{Var}(E[Y\mid n])$ and hence a stronger barrier, but
also a weaker predictor.

**Theorem 9.3 (The constant-band-mean hypothesis is necessary).** *On the
population $\Omega = \{6, 15\}$ with the identity as both invariant and target,
the covariance is $9/4 > 0$.* Hence an $N$-only invariant *can* correlate with
the smaller factor across bands, and every zero-correlation statement in this
framework must be read as conditional on the band structure.

---

## 10. Algorithms

The framework yields several concrete procedures, each of independent
computational interest.

**Algorithm A: the near-equal-$N$ classifier.** *Input:* a population of
semiprimes with known factorizations, a band width $w$, a candidate invariant
$f$. *Output:* a verdict "$N$-only" or "informative", plus a certified bound.
*Method:* compute band labels $\lfloor N/w\rfloor$; compute band means of the
target; compute $\operatorname{Var}(E[Y\mid n])/\operatorname{Var}(Y)$; report the
band-spread bound $\sqrt{\varepsilon}$ from Theorem 7.9 and the measured
correlation. Since the bound is uniform over all invariants, a single computation
per population certifies *all* candidates. Complexity: $O(|\Omega|)$ after
sorting by band, i.e. $O(|\Omega|\log|\Omega|)$.

**Algorithm B: generic symmetric reduction.** *Input:* $F \in \mathbb{Z}[X]$ and
a modulus $N$. *Output:* the specialized invariant polynomial
$\psi = \Psi_F(\cdot, N) \in \mathbb{Z}[s]$. *Method:* run the recursion
$A_{k+1} = -N B_k$, $B_{k+1} = B_k\,s + A_k$ in $\mathbb{Z}[s]$ with
$A_0 = 1, B_0 = 0$, accumulate $A_F = \sum_k c_k A_k$, $B_F = \sum_k c_k B_k$
where $F = \sum_k c_k X^k$, and return $A_F^2 + A_F B_F s + B_F^2 N$. Complexity:
$O(d^2)$ coefficient operations for $d = \deg F$; the output has degree at most
$2d$.

**Algorithm C: dichotomy decision and factor recovery.** *Input:* $F$, $N$, and
the observed invariant value $T = F(p)F(q)$. *Output:* either the verdict
"$N$-only" or a list of at most $2\deg F$ candidate factorizations. *Method:*
compute $\psi$ by Algorithm B; if $\deg\psi = 0$, report "$N$-only"; else find the
integer roots $s$ of $\psi - T$, and for each test whether $s^2-4N$ is a perfect
square, returning $\bigl((s\mp\sqrt{s^2-4N})/2\bigr)$. This makes the circular
branch of Theorem 6.5 *effective*: an invariant on that branch is a factoring
algorithm up to a search of size $2\deg F$.

**Algorithm D: polynomial success counting.** *Input:* $P \in \mathbb{Q}[X]$ and
a bound $X$. *Output:* the exact success set $\{(p,q): pq \le X, P(pq)=p\}$ and
the certified bound $\deg P\cdot \pi(\sqrt X)$ of Theorem 3.5. *Method:* sieve
primes to $\sqrt X$; for each $p$, find the rational roots of $P - p$ and keep
those of the form $pq$ with $q$ prime.

---

## 11. Applications and interpretation

**Cryptanalytic triage.** The framework provides a cheap filter for proposals.
Given a claimed factoring method, ask: (i) is the computed object algebraic in
$N$? — Sections 3, 6; (ii) analytic in $1/N$? — Section 4; (iii) a symmetric
function of the factor pair? — Section 5.1; (iv) does it reveal $s$? — Section
5.2, in which case the method is a factoring algorithm and its novelty is a
complexity question; (v) does it output a difference of squares? — Section 5.3;
(vi) is it a statistic, learned or hand-built, of features of $N$? — Section 7,
in which case the band-spread law bounds it. In practice this taxonomy accounts
for the overwhelming majority of proposals.

**Machine learning on number-theoretic features.** Theorem 7.6 has a blunt
consequence for the popular idea of learning to factor from features of $N$: any
model whose inputs are computable from $N$ is a function of $N$, hence a function
of the band label at any resolution finer than the feature set. Its correlation
with the hidden factor is bounded by the band spread, uniformly over
architectures, training procedures, and dataset sizes. No amount of capacity
changes the bound; the obstruction is in the input, not the model.

**Experiment design.** Theorem 9.2 shows that the near-equal-$N$ protocol is only
meaningful for bands coarse enough to contain many semiprimes, and Theorem 7.9
quantifies the trade-off. Practically: choose the band width as large as possible
subject to $\operatorname{Var}(E[p\mid \text{band}])$ remaining small; then a
single measurement of that variance certifies all invariants at once.

**Complexity context.** Nothing here proves a lower bound on the complexity of
factoring in any standard model. What the framework does is explain, class by
class, why the natural function families do not contain a factoring formula, and
why the natural statistical strategies cannot extract factor information from
$N$-derived features. Consistent with that, the best known classical bound
remains $L_N[1/3, 1.923\ldots]$, and the only known polynomial-time algorithm is
quantum.

---

## 12. Discussion

Three features of the framework deserve emphasis.

*The recurring mechanism.* All three rigidity barriers share one proof pattern:
freeze the small factor, so that the sample set becomes an infinite family with
an accumulation point in the relevant topology (at infinity for polynomials, at
the origin for the reciprocal sampling); invoke rigidity of the function class to
collapse the function to a constant; then use a second value of the small factor
to contradict the constant. The pattern is robust precisely because it uses
almost nothing about primes — only that there are infinitely many of them above
any bound.

*Symmetry as the true obstruction.* The symmetry barrier and the dichotomy
suggest that the real difficulty is not size but *symmetry*: the modulus $N$
determines the unordered pair $\{p,q\}$ only through the symmetric functions, and
every natural invariant one can write down is symmetric. Breaking symmetry
requires the discriminant $s^2-4N$, i.e. $(q-p)^2$, whose extraction is the whole
problem. Fermat's method is the honest acknowledgement of this: it searches for
the discriminant directly.

*Orthogonality as a statistical no-go.* Theorem 7.1 is elementary — one
regrouping of a finite sum — but its scope is unusually wide. It applies to any
predictor whatsoever built from band-computable inputs, including adaptive,
randomized, and quantized ones, and its quantitative form reduces an unbounded
experimental programme to a single population statistic. Elementary theorems with
large scope are typically the ones that survive.

---

## 13. Future directions

*Status of the earlier conjectures.* An earlier stage of this programme stated
five conjectures; four have since been closed fully or in reduction form, along
with the arbitrary-degree multiplicative dichotomy, the finite-mixture half of
the randomization conjecture, and the depth–advantage collapse. What remains
open, and how, is recorded below.

1. **Beyond algebraic relations.** Extend Theorem 3.3 from polynomial relations
   to *exponential polynomials* in $N$ and $p$. The freeze-and-count mechanism
   must be replaced, since exponential polynomials can have infinitely many
   zeros; the natural tool is a Skolem–Mahler–Lech style argument.
2. **The analytic band-spread estimate.** The reduction is complete: everything
   turns on $\operatorname{Var}(E[p \mid N\text{-band}])$ for semiprimes in a size
   band. Estimating this quantity is a pure question about the distribution of
   the smaller prime factor and involves no invariant at all. A sharp estimate
   would convert the framework's conditional statements into unconditional ones.
3. **Randomized strategies with oracle queries.** The finite-mixture case is
   settled, including the equality clause. The remaining half concerns strategies
   that may query an oracle adaptively during the run, where the mixture
   decomposition no longer applies directly.
4. **Sharpness of the two-way branch.** Is the bound $2\deg F$ on the number of
   candidate sums in Theorem 6.5 attained? A finite search for polynomials $F$
   and moduli $N$ realizing the maximum would settle it.
5. **Reduction-slope statistics.** The reduction slope $B_F$ vanishes exactly
   when $F(p)=F(q)$. How often does this happen for random $F$ of given degree
   and random semiprimes? A statistics of the slope would quantify how large the
   $N$-only side of the dichotomy is.
6. **A counting barrier for general algebraic relations.** Theorem 3.5 counts
   successes for formulas. The analogous count for relations $F(N,p)=0$ of given
   bidegree — how many semiprimes below $X$ can satisfy a fixed nonzero relation
   — is open, and would be the quantitative companion to Theorem 3.3.
7. **Depth versus palette.** The depth–advantage collapse says palette, not
   depth, is the resource. What is the minimal palette size needed to approximate
   the band means to a prescribed accuracy on a given population? This is a
   quantization problem whose answer would convert Theorem 8.11 into an explicit
   size–error trade-off.

---

## 14. Conclusion

Eight barriers stand between the natural function families and a classical
factoring formula. Three are rigidity theorems (polynomial/algebraic,
counting-quantitative, meromorphic); two are structural traps (symmetry,
circularity); one is a taxonomy result (known-method-in-disguise); one is a
dichotomy valid in every degree (multiplicative invariants are blind or
omniscient); and one — structural orthogonality — is a statistical no-go covering
free-witness aggregation, adaptivity, randomization and quantization at a stroke.

The framework is honest about its limits: it is structural, not
information-theoretic; it is conditional on genuinely coarse bands; and the
constant-band-mean hypothesis is necessary. Within those limits it explains, with
proofs, the uniform experimental failure of $284$ candidate invariants across
more than sixty paradigms, and it tells a would-be factorer exactly which
directions are closed.
