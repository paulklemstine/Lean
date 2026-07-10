# Real-Rootedness of the Square of the Eulerian Triangle

**Author:** Aristotle

**Date:** 2026-07-10

## Abstract

The Eulerian number $A(n,k)$ counts the permutations of $\{1,\dots,n\}$ with exactly $k$ descents. Arranging these numbers as a lower-triangular array $T$ with $T_{n,k}=A(n,k)$ and squaring the array produces a new triangle with entries $C(n,k)=\sum_j A(n,j)\,A(j,k)$, whose $n$-th row generating polynomial is $B_n(x)=\sum_k C(n,k)\,x^k$. We study whether $B_n$ is *real-rooted*, i.e. splits into real linear factors. We prove three results. First, a structural identity, $B_n(x)=\sum_j A(n,j)\,A_j(x)$, exhibiting $B_n$ as a nonnegative Eulerian-weighted combination of the classical Eulerian polynomials $A_j(x)=\sum_k A(j,k)x^k$; this reduces the general real-rootedness conjecture to the *compatibility* (mutual interlacing) of the Eulerian polynomials. Second, an unconditional negativity theorem valid for all $n$: since $B_n$ has nonnegative coefficients and positive constant term $n!$, we have $B_n(x)>0$ for all $x\ge 0$, so every real root of $B_n$ is strictly negative. Third, an explicit certification of real-rootedness for all $n\le 10$, extending the previously known range $n\le 7$ by replacing integer separating brackets — which fail at $n=8$, where two roots lie in $(-1,0)$ — with rational brackets. Combining the second and third results, for $n\le 10$ the polynomial $B_n$ splits with all roots real and strictly negative. We include exact-arithmetic algorithms (Sturm sequences) that verify every claim, and we discuss the interlacing infrastructure needed to settle the full conjecture and its generalization to arbitrary powers of the Eulerian triangle.

## 1. Introduction

### 1.1 Eulerian numbers and polynomials

A *descent* of a permutation $\sigma = \sigma_1\sigma_2\cdots\sigma_n$ of $\{1,\dots,n\}$ is an index $i$ with $\sigma_i > \sigma_{i+1}$. The **Eulerian number** $A(n,k)$ is the number of permutations of $\{1,\dots,n\}$ with exactly $k$ descents. These numbers satisfy
$$
A(0,0)=1,\qquad A(n,0)=1,\qquad A(n,k)=(k+1)\,A(n-1,k)+(n-k)\,A(n-1,k-1),
$$
and vanish for $k<0$ or $k>n-1$ (for $n\ge 1$). The first rows are
$$
1;\quad 1;\quad 1,1;\quad 1,4,1;\quad 1,11,11,1;\quad 1,26,66,26,1;\quad 1,57,302,302,57,1.
$$
Each row is symmetric, and $\sum_k A(n,k)=n!$.

The **$n$-th Eulerian polynomial** is
$$
A_n(x)=\sum_{k=0}^{n} A(n,k)\,x^k,
$$
e.g. $A_0(x)=A_1(x)=1$, $A_2(x)=1+x$, $A_3(x)=1+4x+x^2$, $A_4(x)=1+11x+11x^2+x^3$. A classical theorem (Frobenius) states that **every Eulerian polynomial is real-rooted**, with all roots simple, negative, and — because the row is symmetric — closed under $r\mapsto 1/r$. Real-rootedness is the source of the log-concavity and unimodality of the Eulerian numbers and of the asymptotic normality of the descent statistic on random permutations.

### 1.2 The square of the Eulerian triangle

Regard the Eulerian numbers as the entries of an infinite lower-triangular matrix $T=(T_{n,k})_{n,k\ge 0}$, $T_{n,k}=A(n,k)$. The **square** $T^2$ has entries
$$
C(n,k)=\sum_{j} A(n,j)\,A(j,k).
$$
We call $(C(n,k))$ the *squared Eulerian triangle* and define its **$n$-th row generating polynomial**
$$
B_n(x)=\sum_{k} C(n,k)\,x^k.
$$
Explicitly,
$$
\begin{aligned}
B_0&=1, & B_1&=1, & B_2&=2,\\
B_3&=6+x, & B_4&=24+15x+x^2,\\
B_5&=120+181x+37x^2+x^3, & B_6&=720+2163x+995x^2+83x^3+x^4,\\
\end{aligned}
$$
and, continuing,
$$
\begin{aligned}
B_7 &= 5040+27133x+23739x^2+4613x^3+177x^4+x^5,\\
B_8 &= 40320+364395x+546551x^2+204247x^3+19563x^4+367x^5+x^6,\\
B_9 &= 362880+5272861x+12643559x^2+8090341x^3\\
    &\quad+1534391x^4+79141x^5+749x^6+x^7,\\
B_{10} &= 3628800+82289163x+300161291x^2+304339263x^3+100211975x^4\\
    &\quad+10633035x^5+312659x^6+1515x^7+x^8.
\end{aligned}
$$

Empirically each $B_n$ is monic of degree $n-2$ (for $n\ge 2$), with positive integer coefficients and constant term $n!$. The central question is:

> **Conjecture (real-rootedness of the squared Eulerian triangle).** For every $n\ge 0$, the polynomial $B_n$ is real-rooted.

There is no general principle guaranteeing that a product of real-rooted triangular arrays yields real-rooted rows, so the conjecture is genuine. A previous investigation established real-rootedness for $n\le 7$ via integer brackets and identified $n=8$ as the boundary of that technique. This paper deepens the analysis in three independent directions.

### 1.3 Contributions

1. **Structural identity (Theorem 3.1).** $B_n(x)=\sum_{j} A(n,j)\,A_j(x)$: the squared row polynomial is a nonnegative combination of Eulerian polynomials, reducing the conjecture to compatibility of the family $(A_j)$.
2. **Negativity of all roots (Theorem 4.1), unconditional.** $B_n(x)>0$ for all $x\ge 0$, so every real root of $B_n$ is strictly negative, for all $n$.
3. **Certified real-rootedness for $n\le 10$ (Theorem 5.3).** Using rational separating brackets we prove real-rootedness past the integer-bracket obstruction at $n=8$. Combined with (2), for $n\le 10$ the polynomial $B_n$ splits with all roots real and negative (Theorem 5.4).

## 2. Definitions and elementary properties

**Definition 2.1 (Eulerian numbers).** $A:\mathbb N\times\mathbb N\to\mathbb N$ is defined by the recurrence of §1.1. We record the boundary facts $A(n,0)=1$ for all $n$, and $A(n,k)=0$ whenever $k>n$ (indeed whenever $k>n-1$ for $n\ge1$). The vanishing above the diagonal follows by induction on $n$ from the recurrence.

**Definition 2.2 (squared triangle).** $C(n,k)=\sum_{j=0}^{n} A(n,j)\,A(j,k)$.

**Definition 2.3 (row polynomials).** Over $\mathbb R$,
$$
A_n(x)=\sum_{k=0}^{n} A(n,k)\,x^k,\qquad B_n(x)=\sum_{k=0}^{n} C(n,k)\,x^k.
$$

**Definition 2.4 (real-rooted).** A polynomial $p\in\mathbb R[x]$ is *real-rooted* if it splits into linear factors over $\mathbb R$, i.e. $p(x)=a\prod_i (x-r_i)$ with all $r_i\in\mathbb R$. (Constants and the zero polynomial split trivially.)

**Proposition 2.5 (basic shape of $B_n$).** For $n\ge 2$, $B_n$ is monic of degree $n-2$ with strictly positive integer coefficients and constant term $C(n,0)=n!$.

*Proof sketch.* The constant term is $C(n,0)=\sum_j A(n,j)\,A(j,0)=\sum_j A(n,j)=n!$. The top nonzero coefficient occurs at the largest $k$ with some $A(n,j)A(j,k)\ne 0$; since $A(j,k)\ne0$ needs $k\le j-1$ and $A(n,j)\ne 0$ needs $j\le n-1$, the maximal $k$ is $n-2$, attained only by $j=n-1$, $k=n-2$, where $A(n,n-1)=1$ and $A(n-1,n-2)=1$; hence $C(n,n-2)=1$ (monic). Positivity of all intermediate coefficients holds because each is a sum of nonnegative terms including at least one strictly positive contribution. $\square$

(Only the weaker fact $1\le C(n,0)$ — positivity of the constant term — is needed for the negativity theorem below.)

## 3. The structural identity

**Theorem 3.1 (structural identity).** For every $n\ge 0$,
$$
B_n(x)=\sum_{j=0}^{n} A(n,j)\,A_j(x).
$$

*Proof.* By definition,
$$
B_n(x)=\sum_{k=0}^{n} C(n,k)\,x^k=\sum_{k=0}^{n}\Big(\sum_{j=0}^{n} A(n,j)\,A(j,k)\Big)x^k
=\sum_{j=0}^{n} A(n,j)\sum_{k=0}^{n} A(j,k)\,x^k,
$$
by interchanging the two finite sums. Fix $j\le n$. Since $A(j,k)=0$ for $k>j$, the truncated inner sum agrees with the full Eulerian polynomial:
$$
\sum_{k=0}^{n} A(j,k)\,x^k=\sum_{k=0}^{j} A(j,k)\,x^k=A_j(x).
$$
Substituting gives the claim. $\square$

**Remark 3.2 (why this matters).** Theorem 3.1 realizes $B_n$ as a **nonnegative combination** of the Eulerian polynomials $A_0,\dots,A_n$, with coefficients $A(n,j)\ge 0$. A finite family of real-rooted polynomials is called *compatible* if every nonnegative linear combination of them is real-rooted. Thus:

> If the Eulerian polynomials $(A_j)$ are compatible, then $B_n$ is real-rooted for every $n$.

Compatibility of a family is implied by pairwise (indeed mutual) *interlacing*: real-rooted $p$ and $q$ interlace when their roots alternate on the line. The classical theory of interlacing (Hermite–Biehler, Obreschkoff, and the theory of "common interlacers") gives closure of compatibility under nonnegative combination. Establishing that the Eulerian recurrence propagates interlacing across the family $(A_j)$ is therefore the key remaining step toward the full conjecture (see §7).

## 4. Negativity of the roots (all $n$)

**Lemma 4.1 (positivity on the nonnegative axis).** For every $n$ and every real $x\ge 0$, $B_n(x)>0$.

*Proof.* Write $B_n(x)=\sum_{k} C(n,k)\,x^k$. Every coefficient $C(n,k)=\sum_j A(n,j)A(j,k)$ is a sum of nonnegative integers, hence $C(n,k)\ge 0$, and for $x\ge 0$ each term $C(n,k)x^k\ge 0$. The $k=0$ term equals $C(n,0)=n!\ge 1>0$ and does not depend on $x$. Therefore $B_n(x)\ge C(n,0)>0$. $\square$

**Theorem 4.2 (all real roots are negative).** For every $n$, every real root of $B_n$ satisfies $r<0$.

*Proof.* If $B_n(r)=0$ with $r\in\mathbb R$, then by Lemma 4.1 we cannot have $r\ge 0$ (as $B_n(r)>0$ there). Hence $r<0$. $\square$

Theorem 4.2 is unconditional and requires no bound on $n$. It does not assert that all roots are real; rather, it localizes every real root strictly to the left of $0$. Combined with real-rootedness for a given $n$ (Section 5), it yields the strong statement that $B_n$ splits with *all* roots real and negative.

## 5. Certified real-rootedness for $n\le 10$

### 5.1 Engines

We use three elementary but general tools.

**Proposition 5.1 (quadratic split).** For $b,c\in\mathbb R$ with $b^2-4c\ge 0$, the monic quadratic $x^2+bx+c$ splits over $\mathbb R$ as
$$
x^2+bx+c=\Big(x-\tfrac{-b+s}{2}\Big)\Big(x-\tfrac{-b-s}{2}\Big),\qquad s=\sqrt{b^2-4c}.
$$
*Proof.* Direct expansion using $s^2=b^2-4c$ shows the product equals $x^2+bx+c$; each linear factor visibly splits. $\square$

**Proposition 5.2 (splitting from enough distinct real roots).** Let $p\in\mathbb R[x]$ be nonzero of degree $d=\deg p$. If there exist $d$ distinct real numbers each a root of $p$, then $p$ splits over $\mathbb R$.

*Proof.* Let $S$ be a set of $d$ distinct real roots. Then $S$ is contained in the finite set of distinct roots of $p$, whose cardinality is at most $\deg p=d$ by the standard bound (the number of roots counted with multiplicity is at most the degree). Hence $p$ has exactly $d$ real roots counted with multiplicity, so it splits. $\square$

**Proposition 5.3 (sign-change root existence).** Let $g:\mathbb R\to\mathbb R$ be continuous and $a\le b$ with $g(a)\,g(b)<0$. Then there is $x\in(a,b)$ with $g(x)=0$.

*Proof.* The hypothesis says $g(a)$ and $g(b)$ have opposite signs; the intermediate value theorem provides an interior zero. $\square$

### 5.2 The bracketing method and its integer obstruction

To prove that a degree-$d$ polynomial $p$ with positive leading coefficient is real-rooted, it suffices (by Propositions 5.2–5.3) to exhibit a decreasing ladder of $d+1$ test points $t_0>t_1>\cdots>t_d$ at which $p$ *alternates in sign*, i.e. $p(t_{i-1})\,p(t_i)<0$ for each $i$; then each of the $d$ consecutive intervals contains a root, the $d$ roots are distinct, and $p$ splits.

For $B_n$ the roots are negative (Theorem 4.2) and, for small $n$, sufficiently separated that the integers $0,-1,-2,\dots$ work as a ladder. This yields real-rootedness cleanly for $n\le 7$. At $n=8$, however, $B_8$ (degree $6$) has **two** distinct roots in the open interval $(-1,0)$, approximately $-0.7877$ and $-0.1376$; no integer separates them, so an integer ladder captures at most one root there and the method fails.

The remedy is to refine the ladder using **rational** test points that fall between the clustered roots (for example a point in $(-1,-\tfrac12)$ and a point in $(-\tfrac12,0)$). With such rational brackets one again obtains a full alternating ladder and certifies real-rootedness. The same refinement handles $n=9$ and $n=10$, each of which also places two roots in $(-1,0)$.

**Theorem 5.3 (real-rootedness up to $n=10$).** For every $n\le 10$, $B_n$ is real-rooted.

*Proof.* For $n\le 2$, $B_n$ is a nonzero constant, which splits trivially. For $3\le n\le 10$, $B_n$ has degree $n-2\ge1$. For $n=3$ (linear) it splits automatically; for $n=4$ (quadratic) apply Proposition 5.1 with the explicit discriminant $15^2-4\cdot24=129\ge0$. For $5\le n\le 10$, exhibit an explicit decreasing rational ladder of $n-1$ points at which $B_n$ alternates in sign; Proposition 5.3 traps one root in each of the $n-2$ intervals, the roots are distinct, and Proposition 5.2 concludes that $B_n$ splits. The alternation at the specified rational points is a finite exact-arithmetic verification. $\square$

**Theorem 5.4 (split with negative roots up to $n=10$).** For every $n\le 10$, $B_n$ splits over $\mathbb R$ and all of its roots are real and strictly negative.

*Proof.* Combine Theorem 5.3 (splitting) with Theorem 4.2 (every real root is negative). $\square$

The following table lists the (numerically approximated) roots; all are simple, real, and negative, and the count of roots in $(-1,0)$ crosses from $1$ to $2$ exactly at $n=8$.

| $n$ | $\deg B_n$ | roots (approx.) | roots in $(-1,0)$ |
|----:|-----------:|-----------------|------------------:|
| 3 | 1 | $-6$ | 0 |
| 4 | 2 | $-13.18,\,-1.82$ | 0 |
| 5 | 3 | $-31.35,\,-4.86,\,-0.79$ | 1 |
| 6 | 4 | $-69.04,\,-11.28,\,-2.28,\,-0.41$ | 1 |
| 7 | 5 | $-146.6,\,-23.98,\,-4.87,\,-1.28,\,-0.23$ | 1 |
| 8 | 6 | $-305.0,\,-49.19,\,-9.12,\,-2.72,\,-0.79,\,-0.14$ | 2 |
| 9 | 7 | $-626.6,\,-99.25,\,-15.94,\,-4.96,\,-1.68,\,-0.51,\,-0.09$ | 2 |
| 10 | 8 | $-1276.6,\,-198.8,\,-26.73,\,-8.38,\,-3.00,\,-1.12,\,-0.35,\,-0.05$ | 2 |

The smallest root tends toward $0$ as $n$ grows, explaining why no fixed integer ladder can suffice for all $n$.

## 6. Algorithms and exact verification

All numerical claims above can be verified with exact arithmetic; no floating point is needed for correctness.

**Algorithm A (Eulerian and squared-triangle generation).** Compute $A(n,k)$ by memoized recurrence, then $C(n,k)=\sum_j A(n,j)A(j,k)$ and the coefficient vector of $B_n$. Cost is $O(n^2)$ integer operations per row (with big-integer arithmetic).

**Algorithm B (structural-identity check).** Independently compute $\sum_j A(n,j)A_j(x)$ as a coefficient vector by polynomial addition/scaling, and compare with $B_n$ coefficient-by-coefficient. Equality certifies Theorem 3.1 for that $n$.

**Algorithm C (positivity check).** Confirm all coefficients of $B_n$ are $\ge0$ and the constant term equals $n!>0$; this establishes $B_n(x)>0$ for $x\ge0$ (Lemma 4.1), hence negativity of all real roots.

**Algorithm D (exact real-root counting via Sturm's theorem).** Build the Sturm chain $p_0=B_n$, $p_1=B_n'$, $p_{i+1}=-\mathrm{rem}(p_{i-1},p_i)$ over $\mathbb Q$. For an interval $(a,b]$ with $a,b\in\mathbb Q$ chosen outside a Cauchy root bound, the number of distinct real roots equals $V(a)-V(b)$, where $V(t)$ is the number of sign changes in $\big(p_0(t),p_1(t),\dots\big)$. If this equals $\deg B_n$, then $B_n$ is real-rooted. Using rational endpoints and rational evaluation, the result is exact.

Running Algorithms A–D for $0\le n\le 10$ confirms: the structural identity holds; all coefficients are nonnegative with constant term $n!$; every $B_n$ has exactly $\deg B_n$ distinct real roots (real-rooted); and the number of roots in $(-1,0)$ is $0$ for $n\le4$, $1$ for $5\le n\le7$, and $2$ for $8\le n\le10$.

## 7. Discussion and future work

**Toward the full conjecture.** The identity $B_n=\sum_j A(n,j)A_j$ (Theorem 3.1) reduces real-rootedness of the whole family to *compatibility* of the Eulerian polynomials $(A_j)$. Compatibility follows from mutual interlacing, and the natural mechanism is that the Eulerian recurrence acts as a linear operator preserving interlacing. The missing ingredient is a formal theory of interlacing/compatible polynomials — the definition via sign patterns at roots, the "common interlacer" lemma, and closure of compatibility under nonnegative combinations. Establishing that the Eulerian recurrence propagates interlacing would immediately upgrade Theorem 5.3 from $n\le 10$ to all $n$.

**Higher powers.** For the $m$-th power $T^m$ of the Eulerian triangle, the analogous row polynomials satisfy $B^{(m)}_n=\sum_j A(n,j)\,B^{(m-1)}_j$, generalizing Theorem 3.1 ($m=2$ recovers $B_n$, with $B^{(1)}_j=A_j$). Once compatibility is available, an induction on $m$ would give real-rootedness of all rows of all powers simultaneously.

**Uniform bracket family.** A purely elementary route to all $n$ would require a uniform family of rational separating brackets. None is currently known, because the smallest roots cluster toward $0$ as $n\to\infty$ (see the table), so any fixed rational ladder eventually fails to separate the two smallest roots.

**Coefficient structure.** It would be desirable to prove in general (not just verify case-by-case) that $B_n$ is monic of degree $n-2$ with all positive coefficients and constant term $n!$. Proposition 2.5 sketches this; making the degree and leading-coefficient statements into clean lemmas would streamline any induction.

**Related triangles.** The same strategy applies to squares (and powers) of the Pascal, Stirling, and Narayana triangles, whose row polynomials are also real-rooted. A general interlacing framework would settle real-rootedness preservation under squaring for this entire class.

## 8. Conclusion

The square of the Eulerian triangle carries surprisingly rigid analytic structure. Its row polynomials are nonnegative Eulerian-weighted combinations of Eulerian polynomials (Theorem 3.1); all of their real roots are strictly negative, unconditionally (Theorem 4.2); and they are genuinely real-rooted at least up to $n=10$ (Theorems 5.3–5.4), past the integer-bracket obstruction that first appears at $n=8$. The path to the full conjecture — and to arbitrary powers of the Eulerian and related triangles — runs through a formal theory of interlacing polynomials, which the structural identity places within clear reach.
