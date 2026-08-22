# Singularities of Transitivity Partition Functions: Zeta-Regularised Residues, Laurent Moments, and Reciprocity

**Author:** Aristotle

**Date:** 2026-08-22

---

## Abstract

Let a group $G$ act on a sequence of finite sets $Y_0, Y_1, Y_2, \dots$, and for
a fixed arity $r$ let $t_r(Y_n)$ denote the number of $G$-orbits on the injective
$r$-tuples of $Y_n$; thus $t_r(Y_n) = 1$ precisely when $G$ acts $r$-transitively
on $Y_n$. We study the *transitivity partition function*
$Z_r(q) = \sum_{n\ge0} t_r(Y_n)q^n$ as a function of a complex variable $q$, and
we determine its analytic continuation and its complete singularity data under
the successively weaker hypotheses that the grade counts are eventually
constant, eventually polynomial, eventually periodic, and eventually
quasi-polynomial.

The results are the following. (i) If the action is eventually $r$-transitive,
$Z_r$ continues uniquely to an analytic function on $\mathbb{C}\setminus\{1\}$
with a pole of order exactly $1$ at $q=1$ and residue $-1$; the residue is a
universal constant, independent of the group, of the sets, of $r$, and of
finitely many exceptional grades. (ii) If the grade counts are eventually the
values of a polynomial $P$, the pole at $q=1$ has order exactly $\deg P + 1$ and
residue $-P(-1)$: the residue is the zeta-regularised evaluation of the
grade-counting polynomial at a *negative* grade. (iii) For the trivial action on
sets of size $n$, this specialises to residue $(-1)^{r+1}r!$ and pole order
$r+1$. (iv) The pair (pole order, residue) $=(1,-1)$ characterises eventual
$r$-transitivity, and the boundary is sharp: eventually $c$ orbits gives a simple
pole with residue $-c$. (v) For grade counts eventually periodic modulo $m$ there
is a simple pole at every $m$-th root of unity, with residue $-\hat A_k/\zeta^k$
at $\zeta^{-k}$, where $\hat A_k$ is the $k$-th discrete Fourier coefficient of
one period; the family of these residues is a complete invariant of the grade
germ. (vi) The whole principal part at $q=1$ of a polynomial grade count is given
by the explicit finite-difference *Laurent moments*
$m_j(P)=\sum_{k\le \deg P}(-1)^{k+1}\binom{k}{j}(\Delta^kP)(0)$, which reduce to
the residue at $j=0$, vanish for $j>\deg P$, and have nonvanishing top
coefficient. (vii) For quasi-polynomial grade counts $a_n = P_{n\bmod m}(n)$ the
residue at $\zeta^{-k}$ equals
$-\frac{1}{m\zeta^k}\sum_{j<m}\zeta^{-kj}P_j(-1)$. (viii) Finally, an
Ehrhart-style reciprocity law $Z(1/q) = -\sum_{n\ge1}P(-n)q^n$ explains the
appearance of the negative grade: the residue at $q=1$ *is* the first reflected
grade. All residues are tail-only invariants and the residue functional is
additive in the grade counts.

**Keywords:** multiply transitive action, graded $G$-set, partition function,
analytic continuation, residue, zeta-regularisation, finite differences,
quasi-polynomial, Ehrhart reciprocity, discrete Fourier transform.

---

## 1. Introduction

### 1.1 Motivation

Given a combinatorial family indexed by a size, energy, or volume parameter $n$,
the standard analytic instrument is the generating function, or, in the language
of statistical mechanics, the partition function
$Z(q) = \sum_{n\ge0} a_n q^n$ with $q = e^{-\beta}$ a Boltzmann weight. The
behaviour of $Z$ at its dominant singularity governs the asymptotics of the
coefficients; conversely, sharp information about the coefficients pins the
singularity down. This paper carries out the second direction in a situation
where the coefficients count *symmetry*.

Multiple transitivity is a classical measure of the strength of a group action.
An action of $G$ on a finite set $Y$ is $r$-transitive if $G$ acts transitively
on the set of injective $r$-tuples of elements of $Y$. Rather than a Boolean, we
work with the orbit count itself, which measures the failure of $r$-transitivity
quantitatively, and we let the underlying set vary in a graded family. The
resulting object,

$$Z_r(q) \;=\; \sum_{n\ge0} t_r(Y_n)\,q^n ,$$

we call the transitivity partition function. Its "infinite-temperature" point
$q=1$ is where the series diverges, and the question is what the divergence
knows about the symmetry.

### 1.2 Summary of results

The answer is a dictionary. The order of the pole at $q=1$ measures the
polynomial growth rate of the orbit counts; the residue measures their
zeta-regularised size, and equals $-P(-1)$ when the counts are eventually the
values of a polynomial $P$; further poles, one at each root of unity, appear
exactly when the counts have a periodic component, and their residues are the
discrete Fourier coefficients of the period. The residue at $q=1$ equals $-1$
exactly for eventually $r$-transitive families, so the analytic data recovers the
group-theoretic property it came from.

Section 2 fixes notation. Section 3 treats the eventually constant case and the
universal residue. Section 4 develops the polynomial case through the
Gregory–Newton/Laurent bridge. Section 5 computes the extreme case of the trivial
action. Section 6 states the detection theorem. Section 7 treats periodicity and
the residues at roots of unity. Section 8 gives the full principal part at $q=1$
by way of Laurent moments. Section 9 treats quasi-polynomial grade counts.
Section 10 proves the reciprocity law. Section 11 collects structural properties:
tail-invariance, additivity, and rigidity of the residue spectrum. Section 12
describes algorithms, Section 13 numerical illustrations, and Section 14
applications, limitations, and open directions.

---

## 2. Setting and notation

**Definition 2.1 (graded $G$-set).** A *graded $G$-set* is a sequence
$Y = (Y_n)_{n\ge0}$ of finite sets, each equipped with an action of a fixed group
$G$. We call $n$ the *grade*.

**Definition 2.2 (transitivity count).** For $r\in\mathbb{N}$ and a finite
$G$-set $Y$, let $\mathrm{Inj}_r(Y)$ denote the set of injective maps
$\{1,\dots,r\}\to Y$, with the diagonal $G$-action. The *transitivity count* is
$$t_r(Y) \;=\; \#\bigl(\mathrm{Inj}_r(Y)/G\bigr),$$
the number of $G$-orbits on injective $r$-tuples. The action is *$r$-transitive*
if $\mathrm{Inj}_r(Y)$ is a single orbit; equivalently, $t_r(Y) = 1$.

**Definition 2.3 (transitivity partition function).** For a graded $G$-set $Y$
and $r\in\mathbb{N}$, set
$$Z_r(q) \;=\; \sum_{n\ge0} t_r(Y_n)\,q^n .$$

Since $t_r(Y_n) \le |Y_n|^{\underline{r}}$ is finite, the series is a formal power
series with nonnegative integer coefficients; the convergence hypotheses below
always place $q$ in the open unit disc when the series itself is used.

**Definition 2.4 (grade germ).** Two coefficient sequences $a, b:\mathbb{N}\to\mathbb{C}$
have the same *grade germ* if $a_n = b_n$ for all sufficiently large $n$. A
quantity is a *tail-only invariant* if it depends on the sequence only through
its grade germ.

**Definition 2.5 (residue).** If $F$ is analytic on a punctured neighbourhood of
$c\in\mathbb{C}$, its residue is
$$\operatorname{Res}_{q=c}F \;=\; \frac{1}{2\pi i}\oint_{|q-c|=\rho}F(q)\,dq$$
for any sufficiently small $\rho>0$; more generally the *$j$-th Laurent moment*
$$\mu_j(F;c) \;=\; \frac{1}{2\pi i}\oint_{|q-c|=\rho}(q-c)^{j}F(q)\,dq$$
is the coefficient of $(q-c)^{-(j+1)}$ in the Laurent expansion of $F$ at $c$.
All contour integrals in this paper are over positively oriented circles, and in
every theorem the stated value is independent of the radius $\rho$ within the
allowed range.

**Notation.** $\Delta$ is the forward difference operator,
$(\Delta P)(x) = P(x+1)-P(x)$, and $\binom{x}{k}$ denotes the binomial polynomial
$x(x-1)\cdots(x-k+1)/k!$, of degree $k$. We write $x^{\underline{r}} =
x(x-1)\cdots(x-r+1)$ for the falling factorial.

---

## 3. Eventual transitivity: continuation and the universal residue

**Theorem 3.1 (closed form and continuation).** Let $a:\mathbb{N}\to\mathbb{Z}$
satisfy $a_n = c$ for all $n \ge N$. Then for every complex $q$ with $|q|<1$ the
series $\sum_n a_n q^n$ converges absolutely and
$$\sum_{n\ge0} a_n q^n \;=\; Z_{a,N,c}(q) \;:=\; \sum_{n<N} a_n q^n + \frac{c\,q^N}{1-q}.$$
The function $Z_{a,N,c}$ is analytic on $\mathbb{C}\setminus\{1\}$ and is the
unique such continuation: if $F$ is analytic on $\mathbb{C}\setminus\{1\}$ and
agrees with $\sum_n a_nq^n$ on a neighbourhood of $0$, then $F = Z_{a,N,c}$ on
$\mathbb{C}\setminus\{1\}$.

*Proof sketch.* Split the series at $N$; the tail is
$cq^N\sum_{k\ge0}q^k = cq^N/(1-q)$ by the geometric series, which converges for
$|q|<1$. The closed form is manifestly analytic away from $q=1$. Uniqueness is
the identity theorem on the connected open set $\mathbb{C}\setminus\{1\}$: two
analytic functions agreeing on a set with an accumulation point in the domain
agree throughout. $\square$

**Theorem 3.2 (exact partial fractions).** For $q\ne1$,
$$Z_{a,N,c}(q) \;=\; \underbrace{\left(\sum_{n<N}a_nq^n - c\sum_{k<N}q^k\right)}_{\text{entire}} \;-\; \frac{c}{q-1}.$$

*Proof sketch.* Substitute the finite geometric sum
$\sum_{k<N}q^k = (1-q^N)/(1-q)$ and clear denominators. $\square$

**Corollary 3.3 (pole order and residue).** If $c \ne 0$, then $Z_{a,N,c}$ has a
pole of order exactly $1$ at $q=1$, and for every $\rho>0$
$$\frac{1}{2\pi i}\oint_{|q-1|=\rho}Z_{a,N,c}(q)\,dq \;=\; -c .$$
Equivalently $(q-1)Z_{a,N,c}(q) \to -c$ as $q\to1$.

*Proof sketch.* By Theorem 3.2 the difference between $Z_{a,N,c}$ and $-c/(q-1)$
is entire, hence contributes nothing to the contour integral, while
$\oint (q-1)^{-1}dq = 2\pi i$. Order exactly $1$: multiplying by $(q-1)$ yields
a function extending analytically across $1$ with nonzero value $-c$, and the
identity $(q-1)^2Z(q) = (q-1)\bigl((q-1)\Pi(q)-c\bigr)$ (valid at *every* point,
including $q=1$) shows meromorphy at $1$. $\square$

**Theorem 3.4 (universal residue for eventually transitive graded $G$-sets).**
Let $Y$ be a graded $G$-set which is eventually $r$-transitive, i.e.
$t_r(Y_n) = 1$ for all $n\ge N$. Then $Z_r$ continues uniquely to
$\mathbb{C}\setminus\{1\}$, the point $q=1$ is a simple pole, and
$$\operatorname{Res}_{q=1} Z_r \;=\; -1 .$$

*Proof.* Apply Theorem 3.1 and Corollary 3.3 with $c=1$. $\square$

The residue is *universal*: it depends neither on $G$, nor on the sets $Y_n$, nor
on $r$, nor on the finitely many grades where transitivity fails. All of that
information sits in the entire part of the partial fraction decomposition.

---

## 4. Polynomial grade counts: the zeta-regularised residue

We now weaken the hypothesis from eventually constant to eventually polynomial.

**Definition 4.1 (the closed form).** For a polynomial $P\in\mathbb{C}[x]$ of
degree $d$ put
$$\zeta_P(q) \;=\; \sum_{k=0}^{d}(\Delta^kP)(0)\,\frac{q^k}{(1-q)^{k+1}} .$$

**Lemma 4.2 (Gregory–Newton).** Every $P\in\mathbb{C}[x]$ of degree $d$ satisfies
$P = \sum_{k=0}^{d}(\Delta^kP)(0)\binom{x}{k}$, and consequently
$$P(-1) \;=\; \sum_{k=0}^{d}(-1)^k(\Delta^kP)(0),$$
since $\binom{-1}{k} = (-1)^k$.

*Proof sketch.* The binomial polynomials form a basis of $\mathbb{C}[x]$ adapted
to $\Delta$, with $\Delta\binom{x}{k} = \binom{x}{k-1}$; comparing $\Delta^j$ at
$x=0$ identifies the coefficients. Both sides of the displayed identity are
polynomials agreeing on $\mathbb{N}$, hence equal. $\square$

**Lemma 4.3 (binomial summation).** For $|q|<1$ and $k\in\mathbb{N}$,
$$\sum_{n\ge0}\binom{n}{k}q^n \;=\; \frac{q^k}{(1-q)^{k+1}} .$$

*Proof sketch.* Differentiate the geometric series $k$ times, or induct on $k$
using $\binom{n}{k} = \binom{n-1}{k}+\binom{n-1}{k-1}$. $\square$

**Theorem 4.4 (summation).** For $|q|<1$,
$\sum_{n\ge0}P(n)q^n = \zeta_P(q)$, and $\zeta_P$ is analytic on
$\mathbb{C}\setminus\{1\}$.

*Proof sketch.* Expand $P$ in the binomial basis (Lemma 4.2), interchange the
finite sum with the convergent series, and apply Lemma 4.3 termwise. $\square$

**Lemma 4.5 (residue of a basis element).** For every $k$ and every $\rho>0$,
$$\frac{1}{2\pi i}\oint_{|q-1|=\rho}\frac{q^k}{(1-q)^{k+1}}\,dq \;=\; (-1)^{k+1}.$$

*Proof sketch.* Write $u=q-1$, so $q^k=(1+u)^k$ and $(1-q)^{k+1}=(-1)^{k+1}u^{k+1}$.
Hence the integrand is $(-1)^{k+1}(1+u)^k u^{-(k+1)}$, whose residue is
$(-1)^{k+1}$ times the coefficient of $u^{k}$ in $(1+u)^k$, namely
$(-1)^{k+1}\binom{k}{k} = (-1)^{k+1}$. $\square$

**Theorem 4.6 (zeta-regularised residue).** For every polynomial
$P\in\mathbb{C}[x]$ and every $\rho>0$,
$$\frac{1}{2\pi i}\oint_{|q-1|=\rho}\zeta_P(q)\,dq \;=\; -P(-1).$$

*Proof.* By Lemma 4.5 the $k$-th term of $\zeta_P$ contributes
$(\Delta^kP)(0)(-1)^{k+1}$; summing over $k$ and applying the second part of
Lemma 4.2 gives $-\sum_k(-1)^k(\Delta^kP)(0) = -P(-1)$. $\square$

**Theorem 4.7 (pole order).** For $P\ne0$ of degree $d$, the function $\zeta_P$
has a pole at $q=1$ of order exactly $d+1$.

*Proof sketch.* Multiplying by $(1-q)^{d+1}$ produces the polynomial
$\sum_{k\le d}(\Delta^kP)(0)q^k(1-q)^{d-k}$, whose value at $q=1$ is
$(\Delta^dP)(0)$, i.e. $d!$ times the leading coefficient of $P$, hence nonzero.
So the order is at most $d+1$ and not less. $\square$

**Theorem 4.8 (tail-only version).** Let $a:\mathbb{N}\to\mathbb{C}$ satisfy
$a_n = P(n)$ for all $n\ge N$, and let $F$ be any function analytic on
$\mathbb{C}\setminus\{1\}$ agreeing with $\sum_n a_nq^n$ near $q=0$. Then
$$\operatorname{Res}_{q=1}F \;=\; -P(-1),$$
and the pole order at $q=1$ equals $\deg P+1$ when $P \ne 0$.

*Proof sketch.* The difference $\sum_{n<N}(a_n-P(n))q^n$ is a polynomial, hence
entire and residue-free; $F$ equals $\zeta_P$ plus this polynomial by the identity
theorem, and Theorems 4.6 and 4.7 apply. $\square$

For $P=1$ we recover Theorem 3.4; the residue $-1$ of the eventually transitive
case is the value of the constant polynomial $1$ at $-1$, with a sign.

**Remark 4.9 (the nature of the surprise).** The residue is the value of the
grade-counting polynomial at a grade that does not exist. This is exactly the
mechanism of zeta-regularisation, but it appears here as the value of a
convergent contour integral, not as a formal device. The proof is a bridge
between two classical alternating-sign phenomena: the alternating signs
$\binom{-1}{k}=(-1)^k$ of finite-difference calculus, and the alternating signs
$(-1)^{k+1}$ produced by expanding $q^k/(1-q)^{k+1}$ at $q=1$. Section 10 shows
that this coincidence is a shadow of a reciprocity law.

---

## 5. The trivial action: an explicit extreme

**Lemma 5.1.** If $G$ acts trivially on $Y$ then every orbit is a singleton, so
$t_r(Y) = \#\mathrm{Inj}_r(Y) = |Y|^{\underline r}$.

**Lemma 5.2.** $x^{\underline r}\big|_{x=-1} = (-1)(-2)\cdots(-r) = (-1)^r r!$.

**Theorem 5.3 (residue and order for the trivial action).** Let $G$ act trivially
on a graded set with $|Y_n| = n$. Then $t_r(Y_n) = n^{\underline r}$ is a
polynomial of degree $r$ in $n$, the partition function $Z_r$ continues to
$\mathbb{C}\setminus\{1\}$ with a pole of order exactly $r+1$ at $q=1$, and
$$\operatorname{Res}_{q=1}Z_r \;=\; (-1)^{r+1}\,r! .$$

*Proof.* Combine Lemmas 5.1–5.2 with Theorems 4.6–4.8 applied to
$P(x)=x^{\underline r}$. $\square$

Thus the two extremes of symmetry give residues $-1$ (maximal symmetry) and
$(-1)^{r+1}r!$ (no symmetry): the residue is a genuine invariant of the decay of
symmetry, not a universal constant. The pole order $r+1$ matches the sharp
denominator $(1-q)^{r+1}$ predicted by formal rationality of such generating
functions.

---

## 6. The analytic detector

**Theorem 6.1 (transitivity in terms of the counting polynomial).** Suppose
$t_r(Y_n) = P(n)$ for all $n\ge N$. Then $Y$ is eventually $r$-transitive if and
only if $P = 1$.

*Proof sketch.* If the action is eventually $r$-transitive, then $P(n)=1$ for
infinitely many $n$, so $P-1$ has infinitely many roots and vanishes. Conversely
$P=1$ forces $t_r(Y_n)=1$ for $n\ge N$, which is $r$-transitivity. $\square$

**Theorem 6.2 (the detector).** Let $Y$ be a graded $G$-set with eventually
polynomial transitivity counts, and let $F$ be the analytic continuation of
$Z_r$. Then
$$Y \text{ is eventually } r\text{-transitive} \iff
\begin{cases} F \text{ has a pole of order exactly } 1 \text{ at } q=1, \\[2pt]
\operatorname{Res}_{q=1}F = -1. \end{cases}$$

*Proof.* ($\Rightarrow$) Theorem 3.4. ($\Leftarrow$) Order $1$ forces
$\deg P = 0$ by Theorem 4.7, so $P$ is a constant $c$; the residue $-c=-1$ gives
$c=1$, and Theorem 6.1 concludes. $\square$

**Theorem 6.3 (sharpness).** If $t_r(Y_n) = c$ for all $n\ge N$, then $q=1$ is a
simple pole with residue $-c$. In particular a family with eventually two orbits
on injective $r$-tuples has the same pole order as an eventually transitive one
and is distinguished from it only by the residue.

Thus neither condition of Theorem 6.2 can be dropped, and the pair
(order, residue) is a complete analytic detector for eventual $r$-transitivity.

---

## 7. Periodicity: a singularity at every root of unity

### 7.1 Two-periodic counts

**Theorem 7.1.** Suppose $a_n = c_0$ for even $n$ and $a_n = c_1$ for odd $n$.
Then for $|q|<1$
$$\sum_{n\ge0}a_nq^n \;=\; \frac{c_0+c_1q}{1-q^2},$$
a rational function with simple poles at $q=\pm1$, and
$$\operatorname{Res}_{q=1} = -\frac{c_0+c_1}{2}, \qquad
\operatorname{Res}_{q=-1} = \frac{c_0-c_1}{2}.$$

*Proof sketch.* Split the series into even and odd parts, each a geometric series
in $q^2$: $c_0/(1-q^2) + c_1q/(1-q^2)$. Since $1-q^2 = (1-q)(1+q)$, the residues
are computed by evaluating the numerator at $q=\pm1$ and dividing by the
derivative of the denominator, which is $\mp2$. $\square$

**Corollary 7.2 (dichotomy).** For an eventually two-periodic grade count the
singularity at $q=-1$ is invisible (residue $0$) if and only if $c_0=c_1$. In
particular an eventually $r$-transitive graded $G$-set has no residue at $q=-1$,
while its residue at $q=1$ is $-1$.

### 7.2 Exponential grade counts

**Theorem 7.3 (finite exponential sums).** Let $A_i\in\mathbb{C}$ and let $w_i$
be nonzero complex numbers with $|w_i|\le1$, $i$ ranging over a finite index set,
and suppose $a_n = \sum_i A_iw_i^n$. Then for $|q|<1$
$$\sum_{n\ge0}a_nq^n \;=\; \sum_i \frac{A_i}{1-w_iq},$$
which continues analytically to the complement of $\{w_i^{-1}\}$, has a simple
pole at each $w_j^{-1}$ not equal to any other $w_i^{-1}$, and
$$\operatorname{Res}_{q=w_j^{-1}} \;=\; -\frac{A_j}{w_j}.$$

*Proof sketch.* Each summand is a twisted geometric series
$\sum_n A_iw_i^nq^n = A_i/(1-w_iq)$, whose only singularity is a simple pole at
$q = w_i^{-1}$ with residue $-A_i/w_i$; the remaining summands are analytic
there, so they contribute nothing to a small contour around $w_j^{-1}$. $\square$

**Theorem 7.4 (tail-only version).** The conclusion of Theorem 7.3 holds for any
function analytic off $\{w_i^{-1}\}$ that agrees near $0$ with
$\sum_n a_nq^n$ for a sequence $a$ that equals $\sum_iA_iw_i^n$ for all large
$n$: the finitely many exceptional grades contribute an entire polynomial and no
residue.

### 7.3 Counts periodic modulo $m$

**Lemma 7.5 (character orthogonality).** If $\zeta$ is a primitive $m$-th root of
unity and $\zeta^k \ne 1$, then $\sum_{n<m}\zeta^{kn} = 0$.

**Theorem 7.6 (discrete Fourier inversion for grade counts).** Let $c$ be
periodic modulo $m$, i.e. $c_{n+m}=c_n$, and set
$$\hat A_k \;=\; \frac1m\sum_{j<m}\zeta^{-kj}c_j , \qquad \zeta = e^{2\pi i/m}.$$
Then $c_n = \sum_{k<m}\hat A_k(\zeta^k)^n$ for every $n$.

*Proof sketch.* Substituting the definition of $\hat A_k$ and interchanging the
finite sums leaves $\frac1m\sum_j c_j\sum_k \zeta^{k(n-j)}$, and by Lemma 7.5 the
inner sum is $m$ if $n\equiv j \pmod m$ and $0$ otherwise. $\square$

**Theorem 7.7 (residues at all $m$-th roots of unity).** If a grade count is
eventually periodic modulo $m$ with period values $c_0,\dots,c_{m-1}$, then the
partition function continues analytically off the $m$-th roots of unity, has a
simple pole at each $\zeta^{-k}$, and
$$\operatorname{Res}_{q=\zeta^{-k}} \;=\; -\frac{\hat A_k}{\zeta^{k}} .$$
In particular at $k=0$, i.e. $q=1$, the residue is $-\frac1m\sum_{j<m}c_j$: minus
the mean of one period.

*Proof.* Theorem 7.6 exhibits the count as a finite exponential sum with twists
$w_k = \zeta^{k}$ and amplitudes $\hat A_k$; apply Theorems 7.3 and 7.4. $\square$

For $m=2$ this returns the residues $-\frac{c_0+c_1}{2}$ and
$\frac{c_0-c_1}{2}$ of Theorem 7.1, an independent consistency check; for $m=1$
it returns the eventually constant case.

---

## 8. The full principal part at $q=1$: Laurent moments

The residue is the top coefficient of the principal part; for polynomial grade
counts of positive degree, more coefficients exist and are equally explicit.

**Definition 8.1 (Laurent moments of a polynomial).** For $P\in\mathbb{C}[x]$ of
degree $d$ and $j\in\mathbb{N}$ set
$$m_j(P) \;=\; \sum_{k=0}^{d}(-1)^{k+1}\binom{k}{j}(\Delta^kP)(0).$$

**Lemma 8.2 (moments of a basis element).** For all $j,k$ and $\rho>0$,
$$\frac{1}{2\pi i}\oint_{|q-1|=\rho}(q-1)^{j}\frac{q^{k}}{(1-q)^{k+1}}\,dq
\;=\; (-1)^{k+1}\binom{k}{j}.$$

*Proof sketch.* With $u=q-1$ the integrand is $(-1)^{k+1}(1+u)^ku^{j-k-1}$, whose
residue is $(-1)^{k+1}$ times the coefficient of $u^{k-j}$ in $(1+u)^k$, namely
$\binom{k}{k-j}=\binom{k}{j}$ (and $0$ when $j>k$). $\square$

**Theorem 8.3 (the moments of the partition function).** For every polynomial
$P$, every $j$, and every $\rho>0$,
$$\frac{1}{2\pi i}\oint_{|q-1|=\rho}(q-1)^{j}\,\zeta_P(q)\,dq \;=\; m_j(P),$$
i.e. the coefficient of $(q-1)^{-(j+1)}$ in the Laurent expansion of $\zeta_P$ at
$q=1$ is $m_j(P)$.

*Proof.* Expand $\zeta_P$ in the binomial basis and integrate termwise using
Lemma 8.2. $\square$

**Theorem 8.4 (structure of the principal part).**
1. $m_0(P) = -P(-1)$: the zeroth moment is the residue of Theorem 4.6.
2. $m_j(P) = 0$ for $j>\deg P$: the principal part terminates.
3. $m_{d}(P) = (-1)^{d+1}(\Delta^dP)(0)$ with $d=\deg P$, which is nonzero for
   $P\ne0$; hence the pole order is exactly $d+1$.

*Proof sketch.* (1) $\binom{k}{0}=1$ reduces $m_0$ to $-\sum_k(-1)^k(\Delta^kP)(0)$,
which is $-P(-1)$ by Lemma 4.2. (2) $\binom{k}{j}=0$ whenever $k<j$, and all
$k\le d<j$. (3) Only $k=d$ survives $\binom{k}{d}$, and $(\Delta^dP)(0)=d!\,\mathrm{lc}(P)$.
$\square$

**Theorem 8.5 (tail-only invariance of all moments).** If $a_n = P(n)$ for all
$n\ge N$ and $F$ is any analytic continuation off $q=1$ of $\sum_na_nq^n$, then
$\mu_j(F;1)=m_j(P)$ for every $j$: the whole principal part is a tail-only
invariant.

**Example 8.6.** For $P(x)=2x^2-3x+5$ one has $(\Delta^kP)(0) = 5,-1,4$ for
$k=0,1,2$, so $m_0=-10=-P(-1)$, $m_1=-9$, $m_2=-4$, $m_j=0$ for $j\ge3$, and the
principal part at $q=1$ is
$$\frac{-10}{q-1}+\frac{-9}{(q-1)^2}+\frac{-4}{(q-1)^3}.$$

---

## 9. Quasi-polynomial grade counts

Growth and periodicity combine in the quasi-polynomial regime, which is the
regime of Ehrhart theory and of most combinatorial families constrained modulo
$m$.

**Definition 9.1.** A sequence $a$ is *eventually quasi-polynomial of period $m$*
if there are polynomials $P_0,\dots,P_{m-1}$ and $N$ with
$a_n = P_{n\bmod m}(n)$ for all $n\ge N$.

**Lemma 9.2 (twisted summation).** For $P\in\mathbb{C}[x]$, $w \ne 0$, and
$|wq|<1$,
$$\sum_{n\ge0}P(n)w^nq^n \;=\; \zeta_P(wq),$$
which continues analytically to $\mathbb{C}\setminus\{w^{-1}\}$ and has, at
$q=w^{-1}$, a pole of order $\deg P+1$ with
$$\operatorname{Res}_{q=w^{-1}} \;=\; -\frac{P(-1)}{w}.$$

*Proof sketch.* The identity is Theorem 4.4 applied at the point $wq$. For the
residue, substitute $z=wq$ in the contour integral: $dq = dz/w$, and the circle
around $w^{-1}$ maps to a circle around $1$, giving $\frac1w$ times the residue
of $\zeta_P$ at $1$, which is $-P(-1)$ by Theorem 4.6. $\square$

**Definition 9.3 (section polynomials).** Given $P_0,\dots,P_{m-1}$ and
$\zeta = e^{2\pi i/m}$, the *$k$-th section polynomial* is
$$S_k \;=\; \frac1m\sum_{j<m}\zeta^{-kj}P_j \;\in\;\mathbb{C}[x].$$

**Theorem 9.4 (Fourier decomposition of a quasi-polynomial count).** For every
$n$,
$$P_{n\bmod m}(n) \;=\; \sum_{k<m} S_k(n)\,(\zeta^{k})^{n}.$$

*Proof.* Apply Theorem 7.6 pointwise in $n$ to the periodic sequence
$j\mapsto P_j(n)$; the amplitudes are the values $S_k(n)$ by Definition 9.3.
$\square$

**Theorem 9.5 (residues of a quasi-polynomial grade count).** Let $a$ be
eventually quasi-polynomial of period $m$ with polynomials $P_0,\dots,P_{m-1}$,
and let $F$ be any function analytic off the set of $m$-th roots of unity that
agrees with $\sum_na_nq^n$ near $q=0$. Then for each $k<m$,
$$\operatorname{Res}_{q=\zeta^{-k}}F \;=\; -\frac{S_k(-1)}{\zeta^{k}}
\;=\; -\frac{1}{m\,\zeta^{k}}\sum_{j<m}\zeta^{-kj}P_j(-1).$$

*Proof.* By Theorem 9.4 the tail of $a$ is a sum of $m$ twisted polynomial counts
with twists $\zeta^k$ and coefficient polynomials $S_k$. By Lemma 9.2 the $k$-th
summand has a pole at $\zeta^{-k}$ with residue $-S_k(-1)/\zeta^k$, and the other
summands are analytic at that point. The head of $a$ contributes an entire
polynomial. $\square$

This single formula contains all previous residue computations:

- $m=1$: residue $-P(-1)$ (Theorem 4.6);
- all $P_j$ constant, $P_j = c_j$: residue $-\hat A_k/\zeta^k$ (Theorem 7.7);
- $m=2$, constants: residues $-\frac{c_0+c_1}{2}$ and $\frac{c_0-c_1}{2}$
  (Theorem 7.1);
- $m=1$, $P=1$: the universal residue $-1$ (Theorem 3.4).

---

## 10. Reciprocity: why the negative grade appears

Theorem 4.6 produces the value of the counting polynomial at $-1$. The following
reciprocity law, an analogue of Ehrhart reciprocity for lattice-point counting
polynomials, explains it structurally.

**Lemma 10.1 (negative-argument binomials).** For $k,n\in\mathbb{N}$,
$$\binom{-n-1}{k} \;=\; (-1)^k\binom{n+k}{k}.$$

*Proof sketch.* Expand the falling factorial:
$(-n-1)(-n-2)\cdots(-n-k) = (-1)^k(n+1)(n+2)\cdots(n+k)$, then divide by $k!$.
$\square$

**Lemma 10.2 (reflected summation).** For $|q|<1$ and $k\in\mathbb{N}$,
$$\sum_{n\ge0}\binom{n+k}{k}q^n \;=\; \frac{1}{(1-q)^{k+1}} .$$

Lemmas 4.3 and 10.2 are mirror images: the two generating functions differ
exactly by the factor $q^k$, which is what inverting $q$ removes.

**Theorem 10.3 (reciprocity).** For every $P\in\mathbb{C}[x]$ and every $q$ with
$0<|q|<1$,
$$\zeta_P(1/q) \;=\; -\sum_{n\ge1}P(-n)\,q^{n}.$$
Equivalently, with $P^{\vee}(x) := P(-x-1)$,
$$\zeta_P(1/q) \;=\; -\,q\;\zeta_{P^{\vee}}(q),$$
and the reflection $P\mapsto P^{\vee}$ is an involution on $\mathbb{C}[x]$.

*Proof sketch.* Expand $P$ in the binomial basis. By Lemma 10.1,
$P(-n-1) = \sum_k(\Delta^kP)(0)(-1)^k\binom{n+k}{k}$, so by Lemma 10.2 the
reflected series $\sum_{n\ge0}P(-n-1)q^n$ converges to
$\sum_k(-1)^k(\Delta^kP)(0)(1-q)^{-(k+1)}$. On the other hand, substituting
$q\mapsto1/q$ in the definition of $\zeta_P$ and using
$1-q^{-1} = (q-1)/q$ gives, termwise,
$$\frac{q^{-k}}{(1-q^{-1})^{k+1}} \;=\; \frac{q}{(q-1)^{k+1}} \;=\; \frac{-q\,(-1)^{k}}{(1-q)^{k+1}},$$
so $\zeta_P(1/q) = -q\sum_k(-1)^k(\Delta^kP)(0)(1-q)^{-(k+1)} = -q\sum_{n\ge0}P(-n-1)q^n$,
which is the first display after reindexing $n\mapsto n-1$. Involutivity is immediate:
$(P^{\vee})^{\vee}(x) = P(-(-x-1)-1) = P(x)$. $\square$

**Corollary 10.4 (the residue is the first reflected grade).** The coefficient of
$q^1$ in $-\sum_{n\ge1}P(-n)q^n$ is $-P(-1)$, i.e. the residue of the partition
function at $q=1$. The residue is therefore not a coincidence of the Newton
expansion; it is the value the grade count would take at grade $-1$ if grades ran
backwards, read off from the inverted-temperature expansion.

---

## 11. Structural properties of the residue functional

**Theorem 11.1 (summability).** If $a_n = P(n)$ for all $n\ge N$, then
$\sum_n a_nq^n$ converges absolutely for $|q|<1$; consequently two such
generating functions may be added before continuation.

*Proof sketch.* Polynomial coefficients grow subexponentially, so the series is
dominated by $\sum_n C n^{d}|q|^n<\infty$. $\square$

**Theorem 11.2 (additivity).** If two graded objects have eventually polynomial
grade counts with polynomials $P$ and $Q$, then the grade-wise sum has eventually
polynomial grade count $P+Q$, and
$$\operatorname{Res}_{q=1} = -(P+Q)(-1) = \bigl(-P(-1)\bigr) + \bigl(-Q(-1)\bigr).$$
The zeta-regularised residue is thus an additive functional on the monoid of
grade germs; more generally $P \mapsto m_j(P)$ is linear for every $j$.

*Proof sketch.* Both series converge on the disc by Theorem 11.1, so the
continuation of the sum is the sum of the continuations, and the contour integral
is linear. $\square$

**Theorem 11.3 (rigidity of the periodic residue spectrum).** Let two graded
objects have grade counts that are eventually periodic modulo $m$. Then their
residues agree at *all* $m$-th roots of unity if and only if their grade counts
agree for all sufficiently large grades.

*Proof sketch.* By Theorem 7.7 the residue at $\zeta^{-k}$ determines $\hat A_k$,
so equality of all residues means equality of all discrete Fourier coefficients
of the two periods; Fourier inversion (Theorem 7.6) recovers the periods
themselves, hence the tails. The converse is Theorem 7.4 (tail-only
invariance). $\square$

**Corollary 11.4 (no invisible symmetry data).** A grade count that is eventually
periodic modulo $m$ and not eventually zero must have a nonzero residue at some
$m$-th root of unity. In particular its partition function cannot continue to an
entire function.

---

## 12. Algorithms

Every statement above is effective. Three procedures suffice.

**Algorithm A (residue and pole order from a grade count).**
*Input:* the values $a_N,\dots,a_{N+D}$ of an eventually polynomial grade count,
with a bound $D$ on the degree. *Output:* $\deg P$, the residue, all Laurent
moments.
1. Form the finite-difference table of $a_N,\dots,a_{N+D}$; let $d$ be the last
   index with nonzero leading difference. Then $\deg P = d$ and
   $(\Delta^kP)(0)$ is read off after shifting the base point to $0$.
2. Residue $= -P(-1) = -\sum_{k\le d}(-1)^k(\Delta^kP)(0)$.
3. Pole order $= d+1$; the moment $m_j = \sum_{k\le d}(-1)^{k+1}\binom kj(\Delta^kP)(0)$.

Cost: $O(D^2)$ arithmetic operations.

**Algorithm B (residues of a quasi-polynomial count).**
*Input:* the period $m$ and, for each residue class $j$, enough values to
interpolate $P_j$. *Output:* the residue at every $m$-th root of unity.
1. For each $j<m$, interpolate $P_j$ from the subsequence $a_{j}, a_{j+m},\dots$
   and evaluate $v_j := P_j(-1)$.
2. Compute the discrete Fourier transform $\hat v_k = \frac1m\sum_j\zeta^{-kj}v_j$.
3. Return $\operatorname{Res}_{q=\zeta^{-k}} = -\hat v_k/\zeta^k$.

Cost: $O(m D^2)$ for interpolation plus $O(m\log m)$ for the transform.

**Algorithm C (numerical certification by contour integration).**
*Input:* a closed-form evaluator for the continuation, a centre $c$, a radius
$\rho$ separating $c$ from the other singularities, an index $j$. *Output:* the
$j$-th Laurent moment at $c$.
1. Sample $z_t = c+\rho e^{2\pi i t/T}$ for $t=0,\dots,T-1$.
2. Return $\frac1T\sum_t (z_t-c)^{j+1}F(z_t)$ — the trapezoidal rule on the
   circle, which converges geometrically in $T$ for analytic integrands.

Algorithm C is what independently confirms the closed forms of Algorithms A
and B.

---

## 13. Numerical illustrations

The following values are produced by evaluating closed forms and, independently,
by numerical contour integration (Algorithm C), and agree to full double
precision.

| grade count | pole(s) | order | residue |
|---|---|---|---|
| eventually $1$ (any head) | $q=1$ | $1$ | $-1$ |
| eventually $c$ | $q=1$ | $1$ | $-c$ |
| $P(n)=n$ | $q=1$ | $2$ | $+1$ |
| $P(n)=2n^2-3n+5$ | $q=1$ | $3$ | $-10$ |
| $P(n)=n^{\underline r}$ | $q=1$ | $r+1$ | $(-1)^{r+1}r!$ |
| $(c_0,c_1)=(3,1)$ periodic | $q=1$; $q=-1$ | $1$; $1$ | $-2$; $+1$ |
| $(c_0,c_1)=(4,4)$ periodic | $q=1$ only | $1$ | $-4$ |
| $P_0=x+1,\ P_1=2,\ P_2=x^2$ | all cube roots of $1$ | $1$; $1$; $1$ | $-1$; $-0.5774i$; $+0.5774i$ |

For the quasi-polynomial row, the closed formula gives at $k=1$ the value
$-\frac{1}{3\zeta}\bigl(P_0(-1)+\zeta^{-1}P_1(-1)+\zeta^{-2}P_2(-1)\bigr)$ with
$P_0(-1)=0$, $P_1(-1)=2$, $P_2(-1)=1$ and $\zeta = e^{2\pi i/3}$, numerically
$-0.577350\,i$, matching the contour integral.

Reciprocity is likewise verified numerically: for $P(x)=x^3-2x+7$ and
$q=0.37-0.21i$, both $\zeta_P(1/q)$ and $-\sum_{n\ge1}P(-n)q^n$ equal
$-7.186373+0.126799i$, and the coefficient of $q^1$ in the reflected series is
$-P(-1)=-8$, the residue at $q=1$.

---

## 14. Discussion

### 14.1 What the dictionary says

The results assemble into a correspondence between the asymptotic shape of a
graded symmetry and the singularity data of its partition function:

| grade-count behaviour | singularity data at the relevant points |
|---|---|
| eventually $r$-transitive | simple pole at $1$, residue $-1$ |
| eventually $c$ orbits | simple pole at $1$, residue $-c$ |
| eventually polynomial of degree $d$ | pole of order $d+1$ at $1$, residue $-P(-1)$, principal part $\{m_j(P)\}$ |
| trivial action, $|Y_n|=n$ | pole of order $r+1$ at $1$, residue $(-1)^{r+1}r!$ |
| eventually periodic mod $m$ | simple pole at each $m$-th root of unity, residues $-\hat A_k/\zeta^k$ |
| eventually quasi-polynomial | pole at each $m$-th root of unity, residue $-\frac{1}{m\zeta^k}\sum_j\zeta^{-kj}P_j(-1)$ |
| any finite modification | no change whatsoever |

Three features deserve emphasis. First, *tail-only invariance*: the entire
principal part at every singularity is a function of the grade germ alone.
Second, *linearity*: all the invariants are linear functionals of the counting
polynomial, so the residue behaves additively under grade-wise sums of families.
Third, *completeness in the periodic regime*: the residue spectrum determines the
germ, so no eventually periodic information is lost by passing to the analytic
side.

### 14.2 Interpretation

Reading $q=e^{-\beta}$, the point $q=1$ is infinite temperature and $q\to0$ is
zero temperature. The theorems say that the hot limit of a symmetry-counting
partition function forgets the low grades entirely and retains exactly the
asymptotic law of orbit growth, packaged as a regularised value $-P(-1)$ and a
finite list of finite-difference moments. Additional singularities on the unit
circle are the analytic signature of periodic structure in the family — a
resonance at each root of unity whose strength is the corresponding Fourier
amplitude of the period.

The reciprocity law places the phenomenon in a familiar family. Ehrhart
reciprocity states that the lattice-point counting polynomial of a rational
polytope, evaluated at negative integers, counts interior points; here, the
partition function evaluated at the inverted temperature $1/q$ is the generating
function of the counting polynomial at negative grades, and its first coefficient
is the residue. In both settings the "impossible" negative evaluation is the
honest content of an inversion symmetry.

### 14.3 Limitations

The analysis assumes the grade counts are eventually quasi-polynomial (or a
finite exponential sum). Families with genuinely transcendental growth — for
example counts growing like $n!$ or $2^{n^2}$ — have partition functions with
zero radius of convergence or natural boundaries, and none of the residue
machinery applies. Also, the detector of Section 6 tests eventual
$r$-transitivity for a *fixed* $r$; a uniform statement across all $r$
simultaneously would require control of the joint behaviour of the family
$\{Z_r\}_r$, which is not addressed here. Finally, the pole-order statements
require the counting polynomial to be nonzero; a family whose orbit counts vanish
eventually (empty $r$-tuple sets) has an entire partition function and no
singularity data at all.

### 14.4 Future directions

Several directions extend the present work naturally.

- *Full principal parts at all roots of unity.* Section 8 computes the whole
  principal part at $q=1$ for polynomial counts. The twisted computation of
  Lemma 9.2 should give, for quasi-polynomial counts, the whole principal part at
  every $m$-th root of unity, with moments $m_j(S_k)$ modified by twist factors.
- *Rigidity in the quasi-polynomial regime.* Theorem 11.3 shows the residue
  spectrum is a complete invariant of an eventually periodic germ. The
  corresponding question for quasi-polynomial germs asks whether the *full*
  principal-part data at all $m$-th roots of unity determines the germ; Fourier
  inversion plus the injectivity of $P\mapsto (m_j(P))_j$ makes this plausible.
- *Two-variable refinements.* Grading by both $n$ and the arity $r$ gives a
  two-variable partition function $\sum_{n,r}t_r(Y_n)q^nu^r$ whose singularity
  structure in $u$ would encode how transitivity degrades with arity.
- *Group-theoretic input.* The classification of multiply transitive finite
  permutation groups strongly restricts which polynomials $P$ can occur as
  transitivity counts of natural families; identifying the achievable residue
  values would turn the residue into a genuine classification invariant.
- *Effective error terms.* Since the singularity data determines coefficient
  asymptotics, one may ask for explicit constants in
  $t_r(Y_n) = P(n)+O(\text{decay})$ once the continuation is known on a slightly
  larger disc.

---

## 15. Conclusion

For a group acting on a graded family of finite sets, the generating function of
the numbers of orbits on injective $r$-tuples is a rational function whose
singularities are located at roots of unity and whose singularity data is fully
computable from the asymptotic shape of the orbit counts. The point $q=1$ carries
a pole of order one more than the growth degree, and its residue is the
zeta-regularised value $-P(-1)$ of the counting polynomial at a negative grade —
which, by reciprocity, is literally the first coefficient of the
inverted-temperature expansion. The residue equals $-1$ with a simple pole
exactly for eventually multiply transitive families, and the full residue
spectrum at all $m$-th roots of unity is a complete invariant of an eventually
periodic family. Symmetry, in this setting, is entirely legible in the
singularities.
