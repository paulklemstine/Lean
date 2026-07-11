# The Mega-Sphere: Encoding All Dimensions in a Single Object

**Author:** Aristotle
**Date:** 2026-07-11
**Domain:** Novelty

## Abstract

We develop, from three complementary directions, the principle that an infinite family of mathematical structures — one per dimension or stage — can be captured by a single algebraic object, and we sharpen the sometimes-counterintuitive behavior of these "all-at-once" objects. First, working with inverse limits of towers of additive groups, we prove a general collapse theorem: for every integer $d$ with $|d| \ge 2$, the multiplication tower $\mathbb{Z} \xleftarrow{\times d} \mathbb{Z} \xleftarrow{\times d} \cdots$ has trivial inverse limit. We disprove the tempting conjecture that a tower of nontrivial groups must have nontrivial inverse limit, and we prove a positive Mittag-Leffler-type result: towers with surjective connecting maps surject onto their bottom stage. Second, in the arithmetic of Bernoulli numbers, we record the single exponential generating identity $\big(\sum_n B_n x^n/n!\big)(e^x-1) = x$ that encodes all Bernoulli numbers at once, disprove the conjecture that all odd-indexed Bernoulli numbers vanish (since $B_1 = -\tfrac12$), and establish that for every exponent $p$ the running power sum $n \mapsto \sum_{k<n} k^p$ is a single polynomial in $n$. Third, modeling $H^*(\mathbb{R}P^\infty;\mathbb{F}_2)\cong\mathbb{F}_2[w]$, we prove the finite/infinite dichotomy that $w$ is not nilpotent in the infinite ring but nilpotent in every truncation, compute the Poincaré count, and establish the Whitney–Frobenius identity $(1+w)^{2^k}=1+w^{2^k}$ together with the fact that all dual Stiefel–Whitney classes equal $1$. Throughout, the unifying theme is that the all-at-once object carries genuine structure — and genuine exceptions — that no finite stage reveals.

## 1. Introduction

Much of mathematics is organized by dimension or by stage: the spheres $S^0, S^1, S^2, \dots$; the projective spaces $\mathbb{R}P^0 \subset \mathbb{R}P^1 \subset \cdots$; the partial power sums $\sum_{k<n} k^p$ for $n = 0, 1, 2, \dots$; the Bernoulli numbers $B_0, B_1, B_2, \dots$. A powerful and recurring idea is to replace such an infinite family by a **single object** that encodes the whole family and from which each member is recovered as a "projection" or "coefficient." We call this the *mega-object* principle, and, following the guiding metaphor of a limit of spheres across all dimensions, the *mega-sphere* program.

Two general mechanisms realize the principle:

- **Inverse limits.** Given a tower $X_0 \xleftarrow{\pi_0} X_1 \xleftarrow{\pi_1} X_2 \xleftarrow{\pi_2}\cdots$, the inverse limit collects all coherent threads $(x_n)_n$ with $\pi_n(x_{n+1}) = x_n$. This is the standard way to assemble $\mathbb{R}P^\infty$, the $p$-adic integers, and countless other "limit of finite stages" objects.
- **Generating objects.** A single power series or polynomial can encode an infinite sequence: the exponential generating function of the Bernoulli numbers, or the single Faulhaber polynomial that computes a power sum at every stage.

The purpose of this paper is not merely to celebrate the principle but to test it. All-at-once objects are prone to two kinds of surprise: they may collapse (be far smaller than the individual stages suggest), and they may satisfy a clean law *almost* everywhere while breaking it at one exceptional point. We make both phenomena precise, prove the sharp positive counterparts, and organize everything around the three concrete arenas of inverse limits, Bernoulli numbers, and Stiefel–Whitney classes.

### Summary of contributions

1. **General collapse of multiplication towers** (Theorem 3.4) and its arithmetic engine (Theorem 3.3).
2. **Disproof** that nontrivial stages force a nontrivial inverse limit (Theorem 3.6).
3. **Mittag-Leffler for $\mathbb{N}$-towers**: surjective connecting maps give surjection onto the bottom stage (Theorem 3.7).
4. The **mega generating identity** for Bernoulli numbers (Theorem 4.2) and the **disproof** that all odd Bernoulli numbers vanish (Theorem 4.4).
5. **Faulhaber polynomiality**: for every $p$, one polynomial computes $\sum_{k<n}k^p$ at all stages (Theorem 4.7), with the explicit degree-4 formula (Theorem 4.6).
6. The **finite/infinite dichotomy** for the twisting class $w$ (Theorems 5.2, 5.3), the **Poincaré count** (Theorem 5.4), the **Whitney–Frobenius identity** (Theorem 5.5), and the fact that **all dual classes equal $1$** (Theorem 5.6).

## 2. Preliminaries and notation

We write $\mathbb{Z}$, $\mathbb{Q}$ for the integers and rationals, $\mathbb{F}_2 = \mathbb{Z}/2$ for the two-element field, and $|d|$ for the absolute value of an integer $d$. For a ring $R$, $R[x]$ denotes polynomials and $R\llbracket x\rrbracket$ formal power series; the coefficient extraction operator is $[x^k]$.

A **tower of additive groups** indexed by $\mathbb{N}$ is a family $(X_n)_{n\in\mathbb{N}}$ of additive groups together with group homomorphisms $\pi_n \colon X_{n+1} \to X_n$, the *connecting maps*.

**Definition 2.1 (Inverse limit).** The *inverse limit* of a tower $(X_n, \pi_n)$ is the additive subgroup of the product $\prod_n X_n$ given by
$$\varprojlim X_n \;=\; \{\, x = (x_n)_n \;:\; \pi_n(x_{n+1}) = x_n \text{ for all } n \,\}.$$
Its elements are the *coherent threads*. For each $n$ there is a **projection homomorphism** $p_n \colon \varprojlim X_n \to X_n$, $p_n(x) = x_n$.

That $\varprojlim X_n$ is a subgroup is immediate: the zero thread is coherent; if $x, y$ are coherent then, since each $\pi_n$ is additive, $\pi_n(x_{n+1}+y_{n+1}) = x_n + y_n$ and $\pi_n(-x_{n+1}) = -x_n$, so sums and negatives are coherent.

## 3. Inverse limits: collapse, disproof, and Mittag-Leffler

### 3.1 An arithmetic collapse lemma

**Lemma 3.1.** *Let $d$ be an integer with $|d| \ge 2$. If an integer $a$ is divisible by $d^n$ for every $n \in \mathbb{N}$, then $a = 0$.*

*Proof.* Suppose $a \neq 0$. Since $|d| \ge 2$, the powers $|d|^n$ are unbounded, so choose $n$ with $|d|^n > |a|$. From $d^n \mid a$ and $a \neq 0$ we get $|d^n| \le |a|$ (a nonzero multiple has absolute value at least that of its divisor), i.e. $|d|^n \le |a|$, contradicting the choice of $n$. Hence $a = 0$. $\qquad\blacksquare$

This elementary fact is the entire engine behind the collapse of multiplication towers.

### 3.2 The multiplication tower

**Definition 3.2 (Multiplication tower).** For an integer $d$, the *multiplication tower* is the tower with $X_n = \mathbb{Z}$ for all $n$ and every connecting map equal to $\pi_n = (\,\cdot\, \mapsto d\cdot\,)$, i.e. multiplication by $d$:
$$\mathbb{Z} \xleftarrow{\ \times d\ } \mathbb{Z} \xleftarrow{\ \times d\ } \mathbb{Z} \xleftarrow{\ \times d\ } \cdots.$$

**Lemma 3.3 (Threads are highly divisible).** *For a coherent thread $x = (x_m)_m$ of the multiplication tower and all $m, k \in \mathbb{N}$, one has $x_m = d^k\, x_{m+k}$.*

*Proof.* Induction on $k$. For $k=0$ the claim is $x_m = x_m$. For the step, coherence gives $x_{m+k} = d\, x_{m+k+1}$, so $x_m = d^k x_{m+k} = d^{k+1} x_{m+k+1}$. $\qquad\blacksquare$

**Theorem 3.4 (Collapse of the general multiplication tower).** *For every integer $d$ with $|d| \ge 2$, the multiplication tower has trivial inverse limit: $\varprojlim \mathbb{Z} = \{0\}$.*

*Proof.* Let $x = (x_m)_m$ be a coherent thread. Fix $m$. By Lemma 3.3, $x_m = d^k x_{m+k}$ for all $k$, so $d^k \mid x_m$ for every $k$. By Lemma 3.1, $x_m = 0$. As $m$ was arbitrary, $x = 0$. $\qquad\blacksquare$

This strictly generalizes the classical doubling collapse ($d = 2$): infinitely many nontrivial-looking stages assemble into a single point.

### 3.3 Disproof: nontrivial stages, trivial limit

The collapse above already suggests caution, but one might hope the phenomenon is special to $\mathbb{Z}$ and its "infinitely divisible" behavior. It is not.

**Definition 3.5 (Zero tower).** The *zero tower* has $X_n = \mathbb{F}_2$ for all $n$ and every connecting map equal to the zero homomorphism $\pi_n = 0$.

**Theorem 3.6 (A tower of nontrivial groups with trivial limit).** *There is a tower $(Y_n, \pi_n)$ of additive groups in which every stage $Y_n$ is nontrivial, yet $\varprojlim Y_n = \{0\}$. Consequently, the conjecture "the inverse limit of a tower of nontrivial groups is nontrivial" is false.*

*Proof.* Take the zero tower: each $Y_n = \mathbb{F}_2$ is nontrivial. If $x = (x_n)_n$ is coherent, then for each $n$, $x_n = \pi_n(x_{n+1}) = 0(x_{n+1}) = 0$. Hence the only coherent thread is $0$, so $\varprojlim Y_n = \{0\}$. $\qquad\blacksquare$

The moral: the size of the mega-object is controlled by the *connecting maps*, not by the stages. When the maps forget everything, the limit remembers nothing.

### 3.4 Mittag-Leffler: surjective towers do not collapse

The positive counterpart isolates a condition guaranteeing that the mega-object is large.

**Theorem 3.7 (Mittag-Leffler for $\mathbb{N}$-towers).** *Let $(X_n, \pi_n)$ be a tower of additive groups in which every connecting map $\pi_n$ is surjective. Then the bottom projection $p_0 \colon \varprojlim X_n \to X_0$ is surjective.*

*Proof.* Let $a \in X_0$. We construct a coherent thread $x$ with $x_0 = a$ by recursion. Set $x_0 = a$. Given $x_n$, surjectivity of $\pi_n$ provides some $x_{n+1}$ with $\pi_n(x_{n+1}) = x_n$ (a choice of preimage). The resulting sequence $x = (x_n)_n$ satisfies $\pi_n(x_{n+1}) = x_n$ for all $n$, hence is coherent, and $p_0(x) = x_0 = a$. $\qquad\blacksquare$

Thus a tower whose maps never lose information cannot collapse below its ground floor. Theorems 3.4, 3.6, and 3.7 together give a clean dichotomy: whether the all-at-once object is everything or nothing is a property of the arrows, not of the objects.

## 4. Bernoulli numbers: one function for the whole sequence

### 4.1 The generating object

The Bernoulli numbers $B_0, B_1, B_2, \dots \in \mathbb{Q}$ are most cleanly defined *all at once* through their exponential generating function.

**Definition 4.1 (Bernoulli generating series).** The Bernoulli numbers are the coefficients determined by the formal power series identity
$$\sum_{n=0}^{\infty} B_n \frac{x^n}{n!} \;=\; \frac{x}{e^x - 1},$$
equivalently by the recursion obtained from clearing the denominator.

**Theorem 4.2 (The mega generating identity).** *As formal power series over $\mathbb{Q}$,*
$$\left(\sum_{n=0}^{\infty} B_n \frac{x^n}{n!}\right)\cdot\left(e^x - 1\right) \;=\; x.$$

*Proof sketch.* Write $B(x) = \sum_n B_n x^n/n!$ and $E(x) = e^x - 1 = \sum_{m\ge 1} x^m/m!$. The coefficient of $x^N$ in $B(x)E(x)$ is, after multiplying through by $N!$, the binomial convolution $\sum_{i=0}^{N-1}\binom{N}{i} B_i$. The defining recursion of the Bernoulli numbers states precisely that this convolution equals $0$ for $N \ge 2$ and $1$ for $N = 1$, which is the coefficientwise content of the right-hand side $x$. $\qquad\blacksquare$

This one identity *is* the sequence: every $B_n$ is recovered as $n!$ times the coefficient of $x^n$ on the left.

### 4.2 Small values and a disproof

**Theorem 4.3.** $B_1 = -\tfrac{1}{2}$ and $B_4 = -\tfrac{1}{30}$.

*Proof sketch.* Extracting the coefficient of $x^1$ in the generating identity gives $B_0 + \binom{2}{1}B_1/2! \cdot(\dots)$; concretely the $N=2$ instance of $\sum_{i<N}\binom{N}{i}B_i = 0$ reads $B_0 + 2B_1 = 0$, so $B_1 = -\tfrac12$. For $B_4$, use that $B_3 = 0$ (odd index $\ge 3$; see below) and the $N=5$ instance $\sum_{i<5}\binom{5}{i}B_i = 0$, namely $B_0 + 5B_1 + 10 B_2 + 10 B_3 + 5 B_4 = 0$. Substituting $B_0=1$, $B_1=-\tfrac12$, $B_2=\tfrac16$, $B_3=0$ yields $5B_4 = -\tfrac16$, i.e. $B_4 = -\tfrac{1}{30}$. $\qquad\blacksquare$

**Theorem 4.4 (Disproof: not all odd Bernoulli numbers vanish).** *The statement "for every odd $n$, $B_n = 0$" is false.*

*Proof.* If it held, then in particular $B_1 = 0$. But $B_1 = -\tfrac12 \neq 0$. $\qquad\blacksquare$

The precise truth is that $B_n = 0$ for *odd* $n \ge 3$ (a consequence of the near-evenness of $x/(e^x-1) + x/2$), with $B_1$ the unique exception. This is a textbook example of the mega-object principle's characteristic twist: a clean law that holds everywhere except at a single distinguished index.

### 4.3 Faulhaber: one polynomial per exponent

Bernoulli numbers earn their central place through power sums.

**Theorem 4.5 (Faulhaber's formula).** *For all $n, p \in \mathbb{N}$,*
$$\sum_{k=0}^{n-1} k^p \;=\; \frac{1}{p+1}\sum_{i=0}^{p}\binom{p+1}{i} B_i\, n^{\,p+1-i}.$$

**Theorem 4.6 (Degree four).** *For all $n \in \mathbb{N}$,*
$$\sum_{k=0}^{n-1} k^4 \;=\; \frac{(n-1)\,n\,(2n-1)\,(3n^2 - 3n - 1)}{30}.$$

*Proof sketch.* Both sides agree at $n = 0$, and the difference of consecutive values on each side equals $(n)^4$ (an algebraic identity verified by expansion), so the two sides agree for all $n$ by induction. The denominator $30$ is exactly the denominator of $B_4$, reflecting the appearance of $B_4$ in the leading Bernoulli contributions. $\qquad\blacksquare$

The genuine "all stages at once" statement is the following.

**Theorem 4.7 (Faulhaber polynomiality).** *For every exponent $p \in \mathbb{N}$ there exists a single polynomial $P \in \mathbb{Q}[x]$ such that*
$$\sum_{k=0}^{n-1} k^p \;=\; P(n) \qquad \text{for all } n \in \mathbb{N}.$$

*Proof.* By Theorem 4.5, the left side equals $\frac{1}{p+1}\sum_{i=0}^{p}\binom{p+1}{i}B_i\, n^{p+1-i}$, which is the evaluation at $n$ of the fixed polynomial
$$P \;=\; \sum_{i=0}^{p} \frac{\binom{p+1}{i} B_i}{p+1}\, x^{\,p+1-i} \;\in\; \mathbb{Q}[x].$$
This polynomial does not depend on $n$, so a single algebraic object computes the running power sum at every stage simultaneously. $\qquad\blacksquare$

This is the mega-sphere principle in arithmetic form: rather than an infinite table of values indexed by $n$, one polynomial (with Bernoulli coefficients) governs the entire tower of partial sums.

## 5. Stiefel–Whitney classes: the cohomology of the infinite projective space

The topological mega-sphere par excellence is the infinite real projective space $\mathbb{R}P^\infty = \varinjlim \mathbb{R}P^n$. Its mod-$2$ cohomology is a polynomial ring on a single degree-one generator $w$, the first Stiefel–Whitney class:
$$H^*(\mathbb{R}P^\infty; \mathbb{F}_2) \;\cong\; \mathbb{F}_2[w].$$
We model this ring by $\mathbb{F}_2[w]$ (polynomials over $\mathbb{F}_2$, with $w$ the indeterminate) and its truncations and completions, and extract the structural comparison between the finite spaces $\mathbb{R}P^n$ and the infinite one.

### 5.1 The finite/infinite dichotomy

**Theorem 5.2 ($w$ is not nilpotent).** *In $\mathbb{F}_2[w] \cong H^*(\mathbb{R}P^\infty;\mathbb{F}_2)$, the class $w$ is not nilpotent: $w^n \neq 0$ for all $n$.*

*Proof.* If $w^n = 0$ for some $n$, then evaluating the polynomial identity $w^n = 0$ at $w = 1 \in \mathbb{F}_2$ gives $1 = 0$ in $\mathbb{F}_2$, a contradiction. Hence every power $w^n$ is nonzero. $\qquad\blacksquare$

This is exactly what makes the mega-object infinite-dimensional: there is a nonzero class in every degree.

**Theorem 5.3 ($w$ is nilpotent in every truncation).** *For each $n$, in the truncated ring $\mathbb{F}_2[w]/(w^{n+1}) \cong H^*(\mathbb{R}P^n; \mathbb{F}_2)$, the image of $w$ is nilpotent; indeed $w^{n+1} = 0$.*

*Proof.* In the quotient by the ideal generated by $w^{n+1}$, the element $w^{n+1}$ is by construction zero, since $w^{n+1}$ lies in that ideal. $\qquad\blacksquare$

Theorems 5.2 and 5.3 together are the *finite/infinite dichotomy*: the twisting class is nilpotent in every finite stage but not in the all-at-once limit. This single algebraic contrast distinguishes "all dimensions at once" from every finite dimension.

### 5.2 The Poincaré count

**Theorem 5.4 (Poincaré count).** *The subspace of $\mathbb{F}_2[w]$ spanned by classes of degree $< n$ has dimension exactly $n$ over $\mathbb{F}_2$. Consequently the Poincaré series of $H^*(\mathbb{R}P^\infty;\mathbb{F}_2)$ is $1 + t + t^2 + \cdots = \tfrac{1}{1-t}$.*

*Proof.* The monomials $1, w, w^2, \dots, w^{n-1}$ form a basis of the degree-$< n$ part, so its dimension equals the number of such monomials, namely $n$. Summing the one-dimensional contributions across all degrees gives the stated Poincaré series. $\qquad\blacksquare$

There is exactly one Stiefel–Whitney class in each degree — the cleanest possible cohomology.

### 5.3 Frobenius and dual classes in characteristic two

Working in the completed ring $\mathbb{F}_2\llbracket w\rrbracket$ exposes the peculiar arithmetic of characteristic $2$.

**Theorem 5.5 (Whitney–Frobenius identity).** *In $\mathbb{F}_2\llbracket w\rrbracket$, for every $k \in \mathbb{N}$,*
$$(1 + w)^{2^k} \;=\; 1 + w^{2^k}.$$

*Proof.* The ring $\mathbb{F}_2\llbracket w\rrbracket$ has characteristic $2$, so the Frobenius endomorphism $x \mapsto x^2$ is a ring homomorphism (all binomial coefficients $\binom{2}{1}$ vanish). Iterating, $x \mapsto x^{2^k}$ is a ring homomorphism, whence $(1+w)^{2^k} = 1^{2^k} + w^{2^k} = 1 + w^{2^k}$. $\qquad\blacksquare$

Interpreted topologically, the total Stiefel–Whitney class of a $2^k$-fold Whitney sum of the tautological line bundle collapses to just two terms.

**Theorem 5.6 (All dual classes equal $1$).** *Let $y \in \mathbb{F}_2\llbracket w\rrbracket$ be the inverse of the total class $1 + w$, i.e. $(1+w)\,y = 1$. Then every coefficient of $y$ equals $1$:*
$$[w^k]\,y = 1 \quad \text{for all } k, \qquad \text{equivalently}\qquad (1+w)^{-1} = 1 + w + w^2 + w^3 + \cdots.$$

*Proof.* Compare coefficients in $(1+w)y = 1$. The constant coefficient gives $[w^0]y = 1$. For $k \ge 1$, expanding $(1+w)y = y + wy$ and reading off the coefficient of $w^k$ gives $[w^k]y + [w^{k-1}]y = 0$, i.e. $[w^k]y = [w^{k-1}]y$ in $\mathbb{F}_2$. By induction from $[w^0]y = 1$, every coefficient equals $1$. $\qquad\blacksquare$

Thus the dual Stiefel–Whitney classes of the universal line bundle are uniformly trivial in each degree — a striking simplification enforced by working modulo $2$.

## 6. Algorithms

The results above are constructive and lend themselves to direct computation. We highlight three.

**Algorithm A (Detecting collapse of a multiplication tower).** Given a base $d$ and a candidate coherent thread specified by its top entry $x_N$ at level $N$, propagate downward via $x_{m} = d\,x_{m+1}$ and verify divisibility; by Lemma 3.3 the bottom entry must be divisible by $d^N$, and by Lemma 3.1 the only globally consistent value is $0$. Complexity: $O(N)$ big-integer multiplications.

**Algorithm B (Bernoulli numbers and Faulhaber polynomials).** Compute $B_0, \dots, B_p$ from the recursion $\sum_{i=0}^{N}\binom{N+1}{i}B_i = [N=0]$ (equivalently, coefficient extraction from the generating identity of Theorem 4.2), then assemble the Faulhaber polynomial $P(x) = \frac{1}{p+1}\sum_{i=0}^{p}\binom{p+1}{i}B_i\, x^{p+1-i}$ of Theorem 4.7. Complexity: $O(p^2)$ rational operations.

**Algorithm C (Cohomology of $\mathbb{R}P^n$ and $\mathbb{R}P^\infty$).** Represent classes as $\mathbb{F}_2$-coefficient (truncated) power series in $w$; verify non-nilpotence in the infinite model, nilpotence in the truncation, the Poincaré count, the Frobenius identity $(1+w)^{2^k} = 1 + w^{2^k}$, and the all-ones inverse $(1+w)^{-1}$. Complexity: $O(D)$ or $O(D^2)$ in the truncation degree $D$.

## 7. Applications and discussion

**Number theory and the zeta function.** The generating identity of Theorem 4.2 is the gateway to the special values $\zeta(2k) = (-1)^{k+1}\frac{B_{2k}(2\pi)^{2k}}{2\,(2k)!}$ and to congruences such as the von Staudt–Clausen theorem controlling the denominators of $B_{2k}$. The single exceptional odd value $B_1 = -\tfrac12$ (Theorem 4.4) is not a defect but a feature: it is the term that separates the "naive" symmetric part of $x/(e^x-1)$ from the linear correction.

**Topology and characteristic classes.** The finite/infinite dichotomy (Theorems 5.2–5.3) is the algebraic shadow of the fact that $\mathbb{R}P^\infty$ is a classifying space $B(\mathbb{Z}/2)$ while each $\mathbb{R}P^n$ is a finite approximation. The all-ones dual classes (Theorem 5.6) and the Frobenius identity (Theorem 5.5) encode the mod-$2$ Wu-formula-type relations that make Stiefel–Whitney arithmetic so rigid.

**Inverse limits across mathematics.** The collapse and Mittag-Leffler results (Theorems 3.4, 3.6, 3.7) are prototypes of behaviors seen throughout homological algebra: the vanishing or non-vanishing of $\varprojlim$ and $\varprojlim^1$ terms, the role of surjectivity (the Mittag-Leffler condition) in guaranteeing exactness, and the $p$-adic integers as the non-collapsing companion to the collapsing multiplication tower (the difference being that the $p$-adic tower uses quotient maps $\mathbb{Z}/p^{n+1} \to \mathbb{Z}/p^n$, which are surjective).

## 8. Future directions

- **Inverse limits.** Formalize the exactness ($\varprojlim^1 = 0$) for towers of surjective maps of abelian groups; identify the limit of the $p$-adic tower with $\mathbb{Z}_p$ as a topological ring.
- **Bernoulli / zeta.** Connect the Bernoulli numbers to the special values $\zeta(2k) = (-1)^{k+1} B_{2k}(2\pi)^{2k}/(2\,(2k)!)$, and formalize the von Staudt–Clausen theorem for denominators.
- **Cohomology.** Extend the single-generator model to the full ring of universal Stiefel–Whitney classes and the Steenrod-algebra action, and to the analogous Chern-class story over $\mathbb{Z}$.

## 9. Conclusion

Across three arenas — inverse limits, Bernoulli numbers, and Stiefel–Whitney classes — a single principle recurs: an infinite family indexed by dimension or stage can be packaged into one algebraic object, and that object has a life of its own. It may collapse where the stages are rich; it may obey a clean law with exactly one exception; it may be infinite-dimensional yet governed by the simplest possible series. The value of the mega-object is precisely that it makes the genuine structure, and the genuine exceptions, visible all at once.
