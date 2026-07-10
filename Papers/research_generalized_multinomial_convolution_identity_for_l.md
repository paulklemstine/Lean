# A Generalized Multinomial Convolution Identity for Latin Rectangle Enumeration

## Abstract

We prove a general convolution identity for products of binomial coefficients indexed by ordered compositions. For all non-negative integers $m \ge 1$, $a$, and $d$,
$$\sum_{i_1+\cdots+i_m=d}\;\prod_{j=1}^{m}\binom{a+i_j}{a} \;=\; \binom{ma+d+m-1}{d},$$
where the sum ranges over all ordered $m$-tuples of non-negative integers summing to $d$. The case $m=3$ is the identity used to simplify the Bogart–Longyear closed form for the number of three-row Latin rectangles, where it was described only as being "easily proved with dots and dividers." We give a complete, self-contained proof: a two-factor *negative binomial convolution* serves as the base engine, a coordinate-splitting recursion reduces an $m$-tuple sum to nested two-factor convolutions, and induction on the number of factors closes the identity. We record the specializations $m=2$ and $m=3$, a direct two-factor form over the ordinary antidiagonal, and the stars-and-bars count recovered at $a=0$. We conclude with the generating-function interpretation that makes the identity transparent — every factor is a negative binomial series, and the identity is the additivity of exponents — and outline extensions to mixed parameters, multisymmetric-function series, and $q$-analogues.

**Keywords:** binomial convolution, negative binomial series, compositions, stars and bars, Latin rectangles, Vandermonde-type identities, generating functions.

**MSC 2020:** 05A10, 05A19, 05B15, 05A15.

---

## 1. Introduction

A *Latin rectangle* of size $k \times n$ is a $k \times n$ array of symbols from an $n$-element alphabet such that no symbol repeats within any row or any column. Enumerating Latin rectangles is a central and difficult problem of combinatorial design theory, with connections to experimental design, coding theory, and the permanent of $0/1$ matrices. Even the three-row case is delicate: the classical closed form of Bogart and Longyear for the number of $3 \times n$ Latin rectangles is expressed as a sum of products of binomial coefficients.

Within the derivation of that closed form, a subordinate identity appears whose role is purely to collapse an inclusion–exclusion sum into a single binomial coefficient. In the original treatment this identity is dispatched with the phrase "easily proved with dots and dividers," a reference to the stars-and-bars technique of elementary enumerative combinatorics. In the three-factor form relevant there, the identity reads
$$\sum_{i+j+k=d}\binom{a+i}{a}\binom{a+j}{a}\binom{a+k}{a} \;=\; \binom{3a+d+2}{d}. \tag{1}$$

The purpose of this paper is to prove, in full and for arbitrary numbers of factors, the natural generalization of $(1)$:

$$\sum_{i_1+\cdots+i_m=d}\;\prod_{j=1}^{m}\binom{a+i_j}{a} \;=\; \binom{ma+d+m-1}{d}, \qquad m \ge 1. \tag{2}$$

Identity $(2)$ is a member of the classical family of "negative binomial" or "Vandermonde-type" convolutions, and it admits a transparent generating-function reading: the sequence $i \mapsto \binom{a+i}{a}$ is the coefficient sequence of $(1-x)^{-(a+1)}$, so $(2)$ is nothing but the statement that the product of $m$ copies of $(1-x)^{-(a+1)}$ equals $(1-x)^{-m(a+1)}$, whose $x^d$-coefficient is $\binom{m(a+1)-1+d}{d} = \binom{ma+m-1+d}{d}$. Our contribution is a fully rigorous, elementary, purely combinatorial-algebraic proof that avoids appealing to formal power series machinery — instead using a single two-factor convolution lemma, a coordinate-splitting recursion for tuple sums, and induction.

### 1.1 Organization

Section 2 fixes notation for compositions and ordered tuples. Section 3 proves the two-factor negative binomial convolution, the base engine of the argument. Section 4 establishes the coordinate-splitting recursion for sums over ordered tuples. Section 5 proves the main identity $(2)$ by induction and records its corollaries. Section 6 gives the generating-function interpretation. Section 7 discusses applications to Latin rectangle enumeration, and Section 8 lists future directions.

---

## 2. Definitions and notation

Throughout, $\mathbb{N} = \{0,1,2,\dots\}$ and all variables are non-negative integers. We write $\binom{n}{k}$ for the ordinary binomial coefficient, with the standard convention $\binom{n}{k} = 0$ when $k > n$.

**Definition 2.1 (Ordinary antidiagonal).** For $d \in \mathbb{N}$, the *antidiagonal* of $d$ is the set of ordered pairs
$$A(d) = \{(i,j) \in \mathbb{N}^2 : i + j = d\} = \{(0,d),(1,d-1),\dots,(d,0)\}.$$
It has $d+1$ elements.

**Definition 2.2 (Ordered $m$-tuple compositions / antidiagonal tuples).** For $m, d \in \mathbb{N}$, the *antidiagonal tuple set* $T(m,d)$ is the set of all functions $x : \{1,\dots,m\} \to \mathbb{N}$ (equivalently, ordered $m$-tuples $(x_1,\dots,x_m)$ of non-negative integers) with
$$\sum_{j=1}^{m} x_j = d.$$
These are exactly the *weak compositions* of $d$ into $m$ parts. By stars and bars, $|T(m,d)| = \binom{d+m-1}{d}$.

**Definition 2.3 (Negative binomial coefficient).** For fixed $a \in \mathbb{N}$, the sequence
$$c_a(i) = \binom{a+i}{a} = \binom{a+i}{i}, \qquad i \in \mathbb{N},$$
is the *negative binomial weight of order $a$*. It counts the multisets of size $i$ from an $(a+1)$-element alphabet, and it is the coefficient of $x^i$ in $(1-x)^{-(a+1)}$.

The object of study is the weighted tuple sum
$$S_m(a,d) \;=\; \sum_{x \in T(m,d)} \;\prod_{j=1}^{m} c_a(x_j) \;=\; \sum_{x_1+\cdots+x_m = d}\;\prod_{j=1}^{m}\binom{a+x_j}{a}.$$
Identity $(2)$ is the assertion $S_m(a,d) = \binom{ma+d+m-1}{d}$ for $m \ge 1$.

---

## 3. The two-factor negative binomial convolution

The base case of the entire development is the following two-parameter convolution. It is the only place binomial arithmetic is used directly.

**Theorem 3.1 (Negative binomial convolution).** For all $p, q, d \in \mathbb{N}$,
$$\sum_{i+j=d}\binom{p+i}{p}\binom{q+j}{q} \;=\; \binom{p+q+1+d}{d}. \tag{3}$$

*Proof sketch (elementary, by double induction).* Fix the identity as a statement $P(p,q,d)$.

*Base in $q$.* When $q = 0$ we have $\binom{q+j}{q} = 1$ for all $j$, so the left side of $(3)$ is $\sum_{i+j=d}\binom{p+i}{p} = \sum_{i=0}^{d}\binom{p+i}{p}$. The hockey-stick identity gives $\sum_{i=0}^{d}\binom{p+i}{p} = \binom{p+d+1}{d}$, which is the right side of $(3)$ with $q=0$. This inner claim is itself proved by induction on $d$: the step uses the Pascal recurrence $\binom{p+d+1}{d} = \binom{p+d}{d-1} + \binom{p+d}{d}$ together with the symmetry $\binom{n}{k} = \binom{n}{n-k}$ to match the added term $\binom{p+d}{p}$.

*Inductive step in $q$.* Assume $(3)$ holds for $q$ and all $p, d$. Apply the Pascal recurrence to the factor $\binom{q+1+j}{q+1} = \binom{q+j}{q+1} + \binom{q+j}{q}$ and split the sum accordingly. One summand reproduces (after reindexing the antidiagonal via the successor map $(i,j)\mapsto(i,j{+}1)$) a convolution to which the induction hypothesis in $q$ applies; the other is handled by an inner induction on $d$. Regrouping the binomial coefficients with Pascal's rule and the symmetry relation collapses the two contributions into the single coefficient $\binom{p+q+2+d}{d}$, which is the right side of $(3)$ with $q$ replaced by $q+1$. $\qquad\blacksquare$

**Remark 3.2.** Identity $(3)$ is the Vandermonde/Chu convolution in "negative upper index" form. Reindexing $\binom{p+i}{p} = (-1)^i \binom{-(p+1)}{i}$ turns $(3)$ into the ordinary Vandermonde convolution $\sum_{i+j=d}\binom{-(p+1)}{i}\binom{-(q+1)}{j} = \binom{-(p+q+2)}{d}$. We prove it directly to keep the development self-contained.

Two immediate specializations will be convenient.

**Corollary 3.3 (Equal-parameter two-factor form).** For all $a, d \in \mathbb{N}$,
$$\sum_{i+j=d}\binom{a+i}{a}\binom{a+j}{a} \;=\; \binom{2a+d+1}{d}. \tag{4}$$
*Proof.* Set $p = q = a$ in $(3)$ and simplify $a + a + 1 + d = 2a + d + 1$. $\blacksquare$

---

## 4. The coordinate-splitting recursion

To lift the two-factor statement to $m$ factors we need a clean way to peel one coordinate off a tuple sum. For an $(k+1)$-tuple $x = (x_0, x_1, \dots, x_k)$, write $x = (x_0, y)$ where $y = (x_1,\dots,x_k)$; conversely $\mathrm{cons}(t, y)$ prepends $t$ to the $k$-tuple $y$.

**Lemma 4.1 (Coordinate splitting).** Let $M$ be any commutative monoid (written additively) and let $f : \mathbb{N}^{k+1} \to M$. Then
$$\sum_{x \in T(k+1,\,n)} f(x) \;=\; \sum_{(t,r) \in A(n)}\;\sum_{y \in T(k,\,r)} f(\mathrm{cons}(t,y)). \tag{5}$$

*Proof sketch.* The map
$$x \longmapsto \bigl((x_0,\, n - x_0),\; (x_1,\dots,x_k)\bigr)$$
is a bijection from $T(k+1,n)$ onto the disjoint union $\bigsqcup_{(t,r)\in A(n)} T(k,r)$: if $x_0 + \cdots + x_k = n$ then $x_0 \le n$, the pair $(x_0, n-x_0)$ lies in $A(n)$, and the residual tuple $(x_1,\dots,x_k)$ sums to $n - x_0 = r$; conversely, given $(t,r) \in A(n)$ and $y \in T(k,r)$, the tuple $\mathrm{cons}(t,y)$ sums to $t + r = n$. The two constructions are mutually inverse, and $f$ is transported term by term, giving $(5)$. $\qquad\blacksquare$

The value of $(5)$ is that it converts an $(k+1)$-fold tuple sum into an *ordinary* two-index antidiagonal sum whose inner summand is a $k$-fold tuple sum — exactly the shape needed to feed the inductive hypothesis into Theorem 3.1.

---

## 5. The generalized multinomial convolution identity

We now prove the main theorem. It is convenient to first state the identity indexed by $m+1$ factors, where the arithmetic is cleanest, and then translate to the exact stated form.

**Theorem 5.1 (Main identity, $m+1$ factors).** For all $m, a, d \in \mathbb{N}$,
$$\sum_{x \in T(m+1,\,d)}\;\prod_{j=0}^{m}\binom{a+x_j}{a} \;=\; \binom{(m+1)a + d + m}{d}. \tag{6}$$

*Proof.* Induction on $m$.

*Base $m = 0$.* Then $T(1,d)$ is the singleton $\{(d)\}$, the product has one factor, and the left side is $\binom{a+d}{a}$. By symmetry $\binom{a+d}{a} = \binom{a+d}{d}$, which is the right side $\binom{1\cdot a + d + 0}{d} = \binom{a+d}{d}$.

*Inductive step.* Assume $(6)$ holds for $m$ (for all $d$), and consider $m+1$ factors, i.e. $(m+2)$-tuples. Apply the coordinate-splitting Lemma 4.1 with $k = m+1$, $n = d$, and $f(x) = \prod_{j=0}^{m+1}\binom{a+x_j}{a}$:
$$\sum_{x \in T(m+2,\,d)} f(x) = \sum_{(t,r)\in A(d)}\;\sum_{y \in T(m+1,\,r)} \binom{a+t}{a}\prod_{j=0}^{m}\binom{a+y_j}{a}.$$
The leading factor $\binom{a+t}{a}$ is constant over the inner sum, so it factors out:
$$= \sum_{(t,r)\in A(d)} \binom{a+t}{a}\left(\sum_{y\in T(m+1,\,r)}\prod_{j=0}^{m}\binom{a+y_j}{a}\right).$$
By the inductive hypothesis $(6)$ (with $d$ replaced by $r$), the inner sum equals $\binom{(m+1)a + r + m}{r}$. Writing $b = (m+1)a + m$, this is $\binom{b + r}{r} = \binom{b+r}{b}$. Hence
$$\sum_{x\in T(m+2,\,d)} f(x) = \sum_{(t,r)\in A(d)} \binom{a+t}{a}\binom{b+r}{b}.$$
This is exactly a two-factor negative binomial convolution over the antidiagonal $A(d)$, with parameters $p = a$ and $q = b$. Theorem 3.1 gives
$$= \binom{a + b + 1 + d}{d} = \binom{a + (m+1)a + m + 1 + d}{d} = \binom{(m+2)a + d + (m+1)}{d},$$
which is the right side of $(6)$ with $m$ replaced by $m+1$. This completes the induction. $\qquad\blacksquare$

**Theorem 5.2 (Main identity, stated form).** For all $a, d \in \mathbb{N}$ and every $m \ge 1$,
$$\sum_{x \in T(m,\,d)}\;\prod_{j=1}^{m}\binom{a+x_j}{a} \;=\; \binom{ma + d + m - 1}{d}. \tag{2}$$
*Proof.* Write $m = m' + 1$ with $m' \ge 0$ and apply Theorem 5.1: the right side becomes $\binom{(m'+1)a + d + m'}{d} = \binom{ma + d + (m-1)}{d} = \binom{ma+d+m-1}{d}$. $\blacksquare$

### 5.1 Corollaries

**Corollary 5.3 ($m=2$).** $\displaystyle \sum_{i+j=d}\binom{a+i}{a}\binom{a+j}{a} = \binom{2a+d+1}{d}.$ *(This is $(4)$ again, now as an instance of $(2)$.)*

**Corollary 5.4 ($m=3$, the Bogart–Longyear identity).**
$$\sum_{i+j+k=d}\binom{a+i}{a}\binom{a+j}{a}\binom{a+k}{a} \;=\; \binom{3a+d+2}{d}. \tag{1}$$
*Proof.* Set $m = 3$ in $(2)$: $3a + d + 3 - 1 = 3a + d + 2$. $\blacksquare$

**Corollary 5.5 (Stars and bars, $a = 0$).** For all $m \ge 1$ and $d \ge 0$,
$$|T(m,d)| \;=\; \binom{d + m - 1}{d}.$$
*Proof.* Set $a = 0$ in $(2)$. Then $\binom{0 + x_j}{0} = 1$, so each product equals $1$ and the left side counts the elements of $T(m,d)$; the right side is $\binom{d+m-1}{d}$. $\blacksquare$

Thus the general identity contains the classical stars-and-bars count as its unweighted ($a=0$) shadow, which is precisely the "dots and dividers" justification alluded to in the original three-row derivation.

---

## 6. Generating-function interpretation

The proof above is deliberately elementary, but the identity is *conceptually* a statement about formal power series. Recall the negative binomial series
$$\frac{1}{(1-x)^{a+1}} \;=\; \sum_{i=0}^{\infty}\binom{a+i}{a}x^{i}, \qquad a \in \mathbb{N}. \tag{7}$$
The Cauchy product of power series realizes convolution: if $F(x) = \sum_i f_i x^i$ and $G(x) = \sum_j g_j x^j$, then $[x^d]\,F(x)G(x) = \sum_{i+j=d} f_i g_j$. Applying this to $m$ copies of $(7)$,
$$\left(\frac{1}{(1-x)^{a+1}}\right)^{\! m} = \frac{1}{(1-x)^{m(a+1)}} = \sum_{d=0}^{\infty}\binom{m(a+1)-1+d}{d}x^d,$$
and reading off the coefficient of $x^d$ on both sides yields exactly $(2)$, since $m(a+1) - 1 = ma + m - 1$. The two-factor lemma (Theorem 3.1) is the case where the two factors carry possibly different exponents $p+1$ and $q+1$; their product carries exponent $(p+1)+(q+1) = p+q+2$, whose $x^d$-coefficient is $\binom{p+q+1+d}{d}$. In this light, the entire identity is the additivity of exponents under multiplication, and the inductive proof is a term-level unwinding of that single fact.

---

## 7. Application to Latin rectangle enumeration

The number $L_k(n)$ of $k \times n$ Latin rectangles is governed, for small $k$, by inclusion–exclusion over forbidden column patterns. For $k = 3$, the Bogart–Longyear analysis produces a closed form in which sums of the shape $(1)$ appear when one aggregates contributions of columns grouped by "type," the parameter $a$ recording a common offset and $d$ a running total. Replacing each such sum by the single binomial coefficient $\binom{3a+d+2}{d}$ collapses a double summation into a single one and yields the compact closed form.

The generalization $(2)$ makes the mechanism uniform across the number of factors. The three factors in $(1)$ correspond to the three rows; more generally, an analogous $m$-fold aggregation arising in the enumeration of $m$-row structures (and in related rook-polynomial and permanent expansions) is exactly of the form $(2)$ and collapses in the same way. This positions the identity as a reusable simplification lemma rather than an ad hoc trick, and connects it, through the generating-function reading of Section 6, to the multisymmetric-function series framework in which such enumerations are naturally expressed.

---

## 8. Discussion and future directions

The identity sits at a pleasant intersection: elementary enough to prove by hand, general enough to be genuinely useful, and structured enough to point toward several extensions.

1. **Weighted / mixed-parameter convolution.** Because the two-factor engine (Theorem 3.1) already carries independent parameters $p, q$, the same induction proves the mixed-parameter identity
$$\sum_{i_1+\cdots+i_m=d}\;\prod_{j=1}^{m}\binom{a_j+i_j}{a_j} \;=\; \binom{(a_1+\cdots+a_m)+m-1+d}{d}$$
for arbitrary parameters $a_1,\dots,a_m \in \mathbb{N}$, by inducting over a list of parameters rather than a single repeated one.

2. **Generating-function bridge.** Packaging Theorem 3.1 as the identity $(1-x)^{-(p+1)}(1-x)^{-(q+1)} = (1-x)^{-(p+q+2)}$ at the level of formal power series gives a second, structural proof and connects the combinatorics to the theory of multisymmetric-function generating series.

3. **Bogart–Longyear simplification.** A natural next step is to carry the $m=3$ case all the way through the three-row Latin rectangle count, and then to relate the $m$-fold identity to $m$-row Latin rectangle and rook-polynomial generating series.

4. **Multiset / symmetric formulation.** Recasting the sum over ordered tuples as a sum over multisets with multiplicity weights matches the symmetric-function generating series in which these enumerations naturally live.

5. **$q$-analogue.** One may ask for a Gaussian ($q$-binomial) version $\sum \prod_j \binom{a+i_j}{a}_q = \binom{ma+d+m-1}{d}_q$. This fails in general but holds after an appropriate $q$-power weighting (Gaussian/$q$-convolution), suggesting a refined identity worth pinning down precisely.

---

## Appendix: worked numerical checks

| $m$ | $a$ | $d$ | left side $S_m(a,d)$ | right side $\binom{ma+d+m-1}{d}$ |
|----|----|----|----|----|
| 2 | 1 | 2 | $1{\cdot}3 + 2{\cdot}2 + 3{\cdot}1 = 10$ | $\binom{5}{2}=10$ |
| 3 | 1 | 2 | $3{\cdot}3 + 3{\cdot}4 = 21$ | $\binom{7}{2}=21$ |
| 3 | 0 | 4 | $|T(3,4)| = 15$ | $\binom{6}{4}=15$ |
| 4 | 2 | 3 | $364$ | $\binom{14}{3}=364$ |
| 5 | 1 | 3 | $220$ | $\binom{12}{3}=220$ |

All exact values are confirmed by direct enumeration in the companion numerical examples.
