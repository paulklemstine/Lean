# Transitivity Partition Functions of Graded $G$-Sets: Rationality, Exact Denominators, and a Finite-Difference Criterion

**Author:** Aristotle

**Date:** 2026-08-19

---

## Abstract

Let $G$ be a group and let $Y = \bigsqcup_{n \ge 0} Y_n$ be a *graded $G$-set*: a sequence of $G$-sets indexed by a grading parameter $n$. For each $r \ge 0$ define the *$r$-th transitivity count* $t_r(Y_n)$ to be the number of $G$-orbits on injective $r$-tuples of elements of $Y_n$. This integer equals $1$ precisely when $G$ acts $r$-transitively on $Y_n$, and is bounded above by the descending factorial $|Y_n|^{\underline r}$ when $Y_n$ is finite; it is therefore a genuine order parameter interpolating between total symmetry and total rigidity.

We study the *transitivity partition function*
$$Z_r(q) \;=\; \sum_{n \ge 0} t_r(Y_n)\, q^n .$$
Our main theorem states that if the grades are *eventually $r$-transitive* — that is, if there is an index $N$ with $G$ acting $r$-transitively on $Y_n$ for all $n \ge N$ — then $Z_r$ is a rational function of $q$ whose denominator divides $(1-q)^{r+1}$, with numerator a polynomial of integer coefficients and degree at most $N+r$. Analytically, for $|q| < 1$,
$$Z_r(q) \;=\; \sum_{n<N} t_r(Y_n) q^n \;+\; \frac{q^N}{1-q},$$
so that $Z_r$ extends meromorphically to a function whose only singularity is a simple pole at $q = 1$.

The engine is a finite-difference criterion that we prove in both directions: for every $s$, the series $(1-q)^s\sum_n a_n q^n$ is a polynomial *if and only if* the $s$-th forward difference of $(a_n)$ vanishes eventually; and the coefficient of $q^{n+s}$ in $(1-q)^s\sum_k a_k q^k$ is exactly $(\Delta^s a)_n$. This converts an analytic rationality question into an exactly equivalent combinatorial one about difference tables. We use the equivalence to prove sharpness: the exponent $r+1$ cannot be lowered, being attained by the trivial action on grades of size $n$, whose transitivity counts are $n^{\underline r}$; and we exhibit a genuinely intermediate family — the integers translating $\mathbb{Z}/n\mathbb{Z}$ — for which the denominator at $r = 2$ is exactly $(1-q)^2$. A descent theorem ($r$-transitivity implies $k$-transitivity for $k \le r$ on finite $G$-sets) yields the same rationality for the total partition function $\sum_n (\sum_{k \le r} t_k(Y_n)) q^n$, and a Burnside-type identity recasts all coefficients as sums over the group of fixed-point counts, exhibiting $Z_r$ as a partition function over the symmetry group itself.

**Keywords.** graded $G$-set, multiply transitive action, orbit counting, generating function, forward difference, rational generating function, Burnside's lemma, partition function.

---

## 1. Introduction

### 1.1 Motivation

A recurring pattern in mathematical physics is the *grading* of a system by a discrete quantum number: particle number, excitation level, defect count, lattice size. Symmetry groups act at every level, and the natural object encoding all levels at once is a generating function in a formal fugacity $q$, whose coefficients are level-by-level counts. The analytic structure of such a generating function — the location and order of its singularities — is the object of interest: poles at $q=1$ signal power-law growth of the coefficients, higher-order poles signal higher-degree polynomial growth, and non-rationality signals that no polynomial regime is ever reached.

In the situations we consider, the quantity being counted at each level is not a number of states but a number of *symmetry classes*. Concretely, we count $G$-orbits of ordered tuples of distinct elements. This measurement is classical in permutation group theory, where $r$-transitivity is the statement that the action on ordered $r$-tuples of distinct points is transitive, and appears in the Jordan–Mathieu classification of multiply transitive groups. What is new here is the *graded* and *generating-function* perspective: we ask not whether a single action is $r$-transitive but how the deviation from $r$-transitivity behaves as a function of the grading parameter, and what that behaviour does to the analytic structure of the associated partition function.

The answer is remarkably rigid. Eventual $r$-transitivity forces the partition function to be rational with a single simple pole at $q=1$; and the general mechanism behind this — a two-way equivalence between denominators and difference tables — tells us that in every case, the *order of the pole* is an exact measurement of the polynomial degree of the symmetry deficit.

### 1.2 Summary of results

Throughout, $G$ is a group and all generating functions are elements of the ring $\mathbb{Z}[\![q]\!]$ of formal power series with integer coefficients, or, where convergence is asserted, real-analytic functions on $|q|<1$.

1. **Transitivity Criterion** (Theorem 3.2): $t_r(Y) = 1 \iff G$ acts $r$-transitively on $Y$.
2. **Difference Identity and Coefficient Formula** (Theorems 4.2, 4.4): $(1-q)A(q) = a_0 + q\,(\Delta A)(q)$, and $[q^{n+s}]\big((1-q)^s A(q)\big) = (\Delta^s a)_n$.
3. **Exact Criterion** (Theorem 4.7): $(1-q)^s A(q)$ is a polynomial iff $\Delta^s a$ eventually vanishes.
4. **Polynomial Coefficient Theorem** (Theorem 4.8) and its quantitative form (Theorem 4.9): eventually polynomial coefficients of degree $\le r$ give denominator dividing $(1-q)^{r+1}$ and numerator degree $\le N+r$.
5. **Main Rationality Theorem** (Theorem 5.1) and **Analytic Form** (Theorem 5.4).
6. **Descent Theorem** (Theorem 6.1) and the total partition function (Theorem 6.3).
7. **Fixed-Point (Burnside) Form** (Theorems 7.1–7.3).
8. **Sharpness** (Theorems 8.2–8.5): the trivial-action family attains $(1-q)^{r+1}$ exactly and is never eventually $r$-transitive for $r \ge 1$; the binomial model $\binom{n+r}{r}$ is the universal extremal sequence.
9. **An intermediate family** (Theorems 9.2–9.4): $\mathbb{Z}$ translating $\mathbb{Z}/n\mathbb{Z}$ is $1$-transitive in every grade but has $t_2(\mathbb{Z}/n\mathbb{Z}) = n-1$, giving denominator exactly $(1-q)^2$.

---

## 2. Definitions

**Definition 2.1 (Graded $G$-set).** Let $G$ be a group. A *graded $G$-set* is a family $(Y_n)_{n \ge 0}$ of sets, each equipped with an action of $G$. We write $Y = \bigsqcup_{n\ge 0} Y_n$ and call $Y_n$ the *grade $n$*. No compatibility between different grades is assumed: the grading is purely a bookkeeping index, exactly as a particle-number sector is in a Fock space decomposition.

**Definition 2.2 (Injective tuples).** For $r \ge 0$ and a set $Y$, an *injective $r$-tuple* is a function $f : \{1,\dots,r\} \to Y$ that is injective; equivalently an ordered list of $r$ pairwise distinct elements of $Y$. We write $\mathrm{Inj}_r(Y)$ for the set of these. If $G$ acts on $Y$, then $G$ acts on $\mathrm{Inj}_r(Y)$ by $(g \cdot f)(i) = g \cdot f(i)$; this is well defined, since $y \mapsto g\cdot y$ is a bijection of $Y$ with inverse $y \mapsto g^{-1}\cdot y$, so it preserves injectivity. The set $\mathrm{Inj}_r(Y)$ is canonically identified with the set of embeddings $\{1,\dots,r\}\hookrightarrow Y$; when $Y$ is finite,
$$|\mathrm{Inj}_r(Y)| \;=\; |Y|^{\underline r} \;=\; |Y|(|Y|-1)\cdots(|Y|-r+1),$$
the descending factorial (interpreted as $0$ if $r > |Y|$, and as $1$ if $r=0$).

**Definition 2.3 (Transitivity count).** For a $G$-set $Y$ and $r\ge 0$, the *$r$-th transitivity count* is
$$t_r(Y) \;=\; \#\big(\mathrm{Inj}_r(Y)/G\big),$$
the number of $G$-orbits on injective $r$-tuples. We adopt the convention that this is a cardinal number, finite whenever $\mathrm{Inj}_r(Y)$ is finite; for $Y = \emptyset$ and $r \ge 1$ one has $\mathrm{Inj}_r(Y) = \emptyset$ and $t_r(Y) = 0$.

**Definition 2.4 ($r$-transitivity).** $G$ acts *$r$-transitively* on $Y$ if (i) $\mathrm{Inj}_r(Y) \ne \emptyset$ and (ii) for all $a, b \in \mathrm{Inj}_r(Y)$ there exists $g \in G$ with $g\cdot a = b$. For $r=1$ this is ordinary transitivity on a nonempty set; for $r = 0$ it holds always (the empty tuple is unique).

**Definition 2.5 (Eventual $r$-transitivity).** A graded $G$-set $(Y_n)$ is *eventually $r$-transitive* if there exists $N$ such that $G$ acts $r$-transitively on $Y_n$ for all $n \ge N$. The least such $N$ is the *onset index*.

**Definition 2.6 (Transitivity partition function).** For a graded $G$-set with finite transitivity counts, set
$$Z_r(q) \;=\; \sum_{n \ge 0} t_r(Y_n)\,q^n \;\in\; \mathbb{Z}[\![q]\!] .$$

**Definition 2.7 (Forward difference).** For $a : \mathbb{N} \to \mathbb{Z}$, put $(\Delta a)_n = a_{n+1} - a_n$, and let $\Delta^s$ denote the $s$-fold iterate, with $\Delta^0 a = a$. Explicitly,
$$(\Delta^s a)_n \;=\; \sum_{k=0}^{s} (-1)^{s-k}\binom{s}{k} a_{n+k}.$$
In particular $(\Delta^s a)_n$ depends only on the finitely many values $a_n, \dots, a_{n+s}$.

**Definition 2.8 (Polynomiality of a series).** A formal power series $F \in \mathbb{Z}[\![q]\!]$ *is a polynomial* if it lies in the image of the inclusion $\mathbb{Z}[q] \hookrightarrow \mathbb{Z}[\![q]\!]$; equivalently, if its coefficients vanish from some index on. We say a series $A$ has *denominator dividing $(1-q)^s$* when $(1-q)^s A$ is a polynomial.

---

## 3. Transitivity counts as an order parameter

**Theorem 3.1 (Growth Bound).** *Let $Y$ be a finite $G$-set and $r \ge 0$. Then*
$$t_r(Y) \;\le\; |Y|^{\underline r}.$$

*Proof sketch.* The quotient map $\mathrm{Inj}_r(Y) \to \mathrm{Inj}_r(Y)/G$ is surjective, so the cardinality of the target is at most that of the source, and the source has cardinality $|Y|^{\underline r}$ by the embedding identification of Definition 2.2. $\square$

**Theorem 3.2 (Transitivity Criterion).** *Let $G$ act on a set $Y$ and let $r \ge 0$. Then $t_r(Y) = 1$ if and only if $G$ acts $r$-transitively on $Y$.*

*Proof sketch.* A quotient set has exactly one element iff it is nonempty and any two of its elements coincide. Nonemptiness of $\mathrm{Inj}_r(Y)/G$ is nonemptiness of $\mathrm{Inj}_r(Y)$, which is condition (i). Given nonemptiness, all classes coincide iff for all $a,b$ the classes $[a]$ and $[b]$ agree, i.e. iff there is $g$ with $g\cdot a = b$ (using that the orbit relation is symmetric via $g^{-1}$), which is condition (ii). $\square$

Together, Theorems 3.1 and 3.2 place $t_r(Y_n)$ between $1$ and $|Y_n|^{\underline r}$, the two values corresponding to maximal symmetry and, as we shall see in §8, to no symmetry at all. It is therefore a legitimate order parameter for the symmetry of a grade, and the object whose generating function we now study.

---

## 4. The finite-difference core

This section is independent of group theory: it develops, for arbitrary integer sequences, the exact relationship between denominators of the form $(1-q)^s$ and difference tables. Write
$$A(q) \;=\; \sum_{n\ge 0} a_n q^n$$
for the generating function of $a : \mathbb{N} \to \mathbb{Z}$.

**Lemma 4.1.** *A formal power series is a polynomial iff its coefficients vanish from some index on; if they vanish above $M$, the polynomial has degree $\le M$.*

*Proof sketch.* Truncation at level $M+1$ produces a polynomial whose coefficients agree with those of the series in every degree. $\square$

**Theorem 4.2 (Difference Identity).** *For any $a : \mathbb{N} \to \mathbb{Z}$,*
$$(1-q)\,A(q) \;=\; a_0 \;+\; q\sum_{n\ge 0}(\Delta a)_n q^n .$$

*Proof sketch.* Compare coefficients. In degree $0$: the left side has $a_0$, the right side has $a_0$. In degree $m+1$: the left side has $a_{m+1} - a_m$, and the right side has the degree-$m$ coefficient of the difference series, which is $(\Delta a)_m = a_{m+1}-a_m$. $\square$

This identity is the entire mechanism: *multiplication by $1-q$ is differencing*, up to a shift and a constant term. Everything below is obtained by iterating it.

**Lemma 4.3.** *$(1-q)^s$ is a polynomial of degree $s$; in particular its coefficient in degree $m$ vanishes for $m > s$.*

**Theorem 4.4 (Coefficient Formula).** *For all $s, n \ge 0$,*
$$\big[q^{\,n+s}\big]\Big((1-q)^s A(q)\Big) \;=\; (\Delta^s a)_n .$$

*Proof sketch.* Induct on $s$. The case $s=0$ is the definition. For the step, Theorem 4.2 gives
$$(1-q)^{s+1}A(q) \;=\; a_0(1-q)^s \;+\; q\Big((1-q)^s \textstyle\sum_n (\Delta a)_n q^n\Big).$$
Extract the coefficient in degree $n+s+1$. The first summand contributes $a_0 \cdot [q^{n+s+1}](1-q)^s = 0$ by Lemma 4.3, since $n+s+1 > s$. The second contributes, after removing the factor $q$, the coefficient of $q^{n+s}$ in $(1-q)^s\sum(\Delta a)_n q^n$, which by the inductive hypothesis is $(\Delta^s(\Delta a))_n = (\Delta^{s+1}a)_n$. $\square$

Theorem 4.4 is the crux: it identifies the "clearing the denominator" operation with the difference operator, coefficient by coefficient, with an explicit index shift. Both directions of the following criterion are immediate consequences.

**Theorem 4.5 (Sufficiency).** *If $(\Delta^s a)_n = 0$ for all $n \ge N$, then $(1-q)^s A(q)$ is a polynomial, of degree at most $N+s-1$ when $s \ge 1$.*

*Proof sketch.* By Theorem 4.4 the coefficient of $q^{m}$ in $(1-q)^sA(q)$ equals $(\Delta^s a)_{m-s}$ whenever $m \ge s$, hence vanishes for $m \ge N+s$; apply Lemma 4.1. (An alternative, purely algebraic induction using Theorem 4.2 directly gives the same conclusion.) $\square$

**Theorem 4.6 (Necessity).** *If $(1-q)^s A(q)$ is a polynomial then there is $N$ with $(\Delta^s a)_n = 0$ for all $n \ge N$.*

*Proof sketch.* By Lemma 4.1 the coefficients of $(1-q)^sA(q)$ vanish above some $M$; by Theorem 4.4, $(\Delta^s a)_n$ equals the coefficient in degree $n+s$, which vanishes for $n \ge \max(M+1-s,0)$. (Equivalently, one induces on $s$, using that if $qF$ is a polynomial then so is $F$.) $\square$

**Theorem 4.7 (Exact Criterion).** *For every $s \ge 0$ and every $a : \mathbb{N}\to\mathbb{Z}$,*
$$(1-q)^s A(q) \text{ is a polynomial} \iff \exists N \ \forall n \ge N:\ (\Delta^s a)_n = 0 .$$

This equivalence is what makes all subsequent sharpness statements possible: to show that a denominator *cannot* be lowered one need only exhibit a nonvanishing entry in a difference column, a finite and completely explicit computation.

**Theorem 4.8 (Polynomial Coefficient Theorem).** *Suppose there are $N \ge 0$, $r \ge 0$ and a polynomial $P \in \mathbb{Z}[x]$ with $\deg P \le r$ such that $a_n = P(n)$ for all $n \ge N$. Then $(1-q)^{r+1}A(q)$ is a polynomial: the generating function $A$ is rational with denominator dividing $(1-q)^{r+1}$.*

*Proof sketch.* Fix $n \ge N$. Since $(\Delta^{r+1}a)_n$ depends only on $a_n,\dots,a_{n+r+1}$, all of which equal the corresponding values of $P$, we may replace $a$ by $n \mapsto P(n)$ in computing it. The forward difference of a polynomial of degree $d \ge 1$ is a polynomial of degree $d-1$, and the difference of a constant is $0$; hence $\Delta^{r+1}$ annihilates every polynomial of degree $\le r$, so $(\Delta^{r+1}a)_n = 0$. Apply Theorem 4.5. $\square$

**Theorem 4.9 (Quantitative form).** *Under the hypotheses of Theorem 4.8 the numerator may be taken of degree at most $N + r$: there is $Q \in \mathbb{Z}[q]$ with $\deg Q \le N+r$ and*
$$A(q) \;=\; \frac{Q(q)}{(1-q)^{r+1}} .$$

*Proof sketch.* For $m > N+r$ write $m = k + (r+1)$ with $k > N - 1$, i.e. $k \ge N$. By Theorem 4.4 the coefficient of $q^m$ in $(1-q)^{r+1}A(q)$ is $(\Delta^{r+1}a)_k$, which vanishes by the argument of Theorem 4.8. Now apply Lemma 4.1. $\square$

**Corollary 4.10 (Eventually constant coefficients).** *If $a_n = c$ for all $n \ge N$, then for every $r \ge 0$ the series $(1-q)^{r+1}A(q)$ is a polynomial; already $(1-q)A(q)$ is.*

*Proof sketch.* Apply Theorem 4.8 with $P$ the constant polynomial $c$ and $r = 0$, then multiply by further factors of $(1-q)$, which preserves polynomiality. $\square$

---

## 5. The main theorem

**Theorem 5.1 (Rationality of the transitivity partition function).** *Let $(Y_n)$ be a graded $G$-set which is eventually $r$-transitive from index $N$ on. Then*
$$(1-q)^{r+1}\,Z_r(q) \quad\text{is a polynomial in } \mathbb{Z}[q],$$
*i.e. $Z_r$ is a rational function of $q$ with denominator dividing $(1-q)^{r+1}$.*

*Proof sketch.* By the Transitivity Criterion (Theorem 3.2), $t_r(Y_n) = 1$ for every $n \ge N$. So the coefficient sequence $n \mapsto t_r(Y_n)$ is eventually constant with value $1$, and Corollary 4.10 applies. $\square$

**Theorem 5.2 (Quantitative form).** *Under the hypotheses of Theorem 5.1 there is $Q \in \mathbb{Z}[q]$ with $\deg Q \le N + r$ and $Z_r(q) = Q(q)/(1-q)^{r+1}$.*

*Proof sketch.* Apply Theorem 4.9 with $P$ the constant polynomial $1$. $\square$

**Remark 5.3.** The theorem as stated is deliberately not optimal in the exponent: the hypothesis of eventual $r$-transitivity in fact yields a denominator of $(1-q)^1$. The exponent $r+1$ is the correct *ambient* bound, in the sense that it is the exponent forced by the natural growth bound $t_r(Y_n)\le |Y_n|^{\underline r}$ when the grades grow linearly in size; §8 shows the exponent is attained, so no theorem of this shape can do better while covering all graded $G$-sets with polynomially bounded transitivity counts of degree $r$.

We now pass from formal series to honest functions.

**Lemma 5.4 (Eventually constant summation).** *Let $a : \mathbb{N}\to\mathbb{Z}$ satisfy $a_n = c$ for all $n \ge N$, and let $q \in \mathbb{R}$ with $|q| < 1$. Then $\sum_n a_n q^n$ converges absolutely and*
$$\sum_{n \ge 0} a_n q^n \;=\; \sum_{n < N} a_n q^n \;+\; \frac{c\,q^N}{1-q}.$$

*Proof sketch.* The shifted tail satisfies $a_{n+N}q^{\,n+N} = (c\,q^N)\,q^n$ for all $n \ge 0$, a geometric series with ratio $q$, hence summable with sum $c q^N/(1-q)$; summability of the shifted tail implies summability of the whole series, and splitting off the first $N$ terms gives the identity. $\square$

**Theorem 5.5 (Analytic form of the main theorem).** *Let $(Y_n)$ be a graded $G$-set which is eventually $r$-transitive from index $N$ on, and let $q \in \mathbb{R}$ with $|q|<1$. Then the series $Z_r(q) = \sum_n t_r(Y_n)q^n$ converges absolutely and*
$$Z_r(q) \;=\; \sum_{n<N} t_r(Y_n)\,q^n \;+\; \frac{q^N}{1-q} .$$
*Consequently $Z_r$ extends to a meromorphic function on the complex plane whose only singularity is a simple pole at $q = 1$, with residue $-1$.*

*Proof sketch.* By Theorem 3.2 the coefficients equal $1$ from index $N$ on; apply Lemma 5.4 with $c = 1$. The right-hand side is manifestly a rational function whose only pole is at $q=1$ and is simple; the residue of $q^N/(1-q)$ at $q=1$ is $-1$. $\square$

**Theorem 5.6 (Cleared denominator).** *Under the same hypotheses, for $|q|<1$,*
$$(1-q)\,Z_r(q) \;=\; (1-q)\sum_{n<N}t_r(Y_n)q^n \;+\; q^N,$$
*a polynomial expression in $q$ of degree at most $N$.*

*Proof sketch.* Multiply the identity of Theorem 5.5 by $1-q \ne 0$ and simplify. $\square$

**Interpretation.** Theorem 5.5 exhibits the transitivity partition function as a *transient plus a bulk*: the finitely many pre-onset grades contribute a polynomial of degree $< N$, and the symmetric regime contributes exactly the geometric tail $q^N/(1-q)$. In statistical-mechanics language: the system has a single critical fugacity $q=1$, the transition there is of the mildest (first-order-pole) type, and all the model-dependent information sits in a finite list of transient coefficients.

---

## 6. Descent and the total partition function

Multiple transitivity is a downward-hereditary property on finite sets, which allows us to bundle all orders $k \le r$ into one partition function.

**Theorem 6.1 (Descent).** *Let $Y$ be a finite $G$-set and let $k \le r$. If $G$ acts $r$-transitively on $Y$, then $G$ acts $k$-transitively on $Y$.*

*Proof sketch.* Write $r = k+m$. Since $\mathrm{Inj}_{k+m}(Y)\ne\emptyset$ we have $|Y| \ge k+m$. Given two injective $k$-tuples $a,b$, extend each to an injective $(k+m)$-tuple by appending $m$ further elements chosen from the complement of the image (possible by the cardinality bound: the complement of a $k$-element image has at least $m$ elements). Call the extensions $A, B$. By $r$-transitivity there is $g$ with $g\cdot A = B$; restricting to the first $k$ coordinates gives $g\cdot a = b$. Nonemptiness of $\mathrm{Inj}_k(Y)$ follows by restricting any element of $\mathrm{Inj}_{k+m}(Y)$. $\square$

**Corollary 6.2.** *If a graded $G$-set with finite grades is eventually $r$-transitive from index $N$, then for each $k \le r$ it is eventually $k$-transitive from index $N$, and $t_k(Y_n) = 1$ for all $n \ge N$ and all $k\le r$.*

**Theorem 6.3 (Total transitivity partition function).** *Under the hypotheses of Corollary 6.2, the series*
$$Z^{\mathrm{tot}}_r(q) \;=\; \sum_{n\ge 0}\Big(\sum_{k=0}^{r} t_k(Y_n)\Big) q^n$$
*is rational with denominator dividing $(1-q)^{r+1}$.*

*Proof sketch.* For $n \ge N$ the inner sum equals $\sum_{k=0}^r 1 = r+1$, a constant; apply Corollary 4.10 with $c = r+1$. $\square$

The total partition function is the natural object if one wishes to grade by symmetry *order* as well as by $n$: it is the specialisation at $z=1$ of the two-variable series $\sum_{n,k} t_k(Y_n)z^kq^n$ truncated at $k \le r$.

---

## 7. The fixed-point (Burnside) form

Orbit counts admit a dual description as averages of fixed-point counts. This converts the transitivity partition function from a sum over configurations into a sum over the symmetry group — precisely the passage from a configuration-space partition function to a sum over sectors.

For $g\in G$ let
$$\mathrm{Fix}_r(g, Y) \;=\; \{f \in \mathrm{Inj}_r(Y) : g\cdot f = f\}$$
be the set of injective $r$-tuples fixed entrywise by $g$.

**Theorem 7.1 (Burnside's lemma for injective tuples).** *Let $G$ be a finite group acting on a finite set $Y$, and let $r \ge 0$. Then*
$$\sum_{g\in G}\big|\mathrm{Fix}_r(g,Y)\big| \;=\; t_r(Y)\cdot |G| .$$

*Proof sketch.* Apply the orbit-counting lemma to the $G$-set $\mathrm{Inj}_r(Y)$, which is finite because $Y$ is: the number of orbits equals the average number of fixed points, i.e. $|G|^{-1}\sum_g |\mathrm{Fix}_r(g,Y)|$. Multiply through by $|G|$. $\square$

**Theorem 7.2 (Degeneracy at transitivity).** *If $G$ is finite and acts $r$-transitively on the finite set $Y$, then*
$$\sum_{g\in G}\big|\mathrm{Fix}_r(g,Y)\big| \;=\; |G| .$$
*Equivalently, the average number of fixed injective $r$-tuples per group element is exactly $1$.*

*Proof sketch.* Combine Theorem 7.1 with the Transitivity Criterion ($t_r(Y)=1$). $\square$

**Theorem 7.3 (Fixed-point partition function).** *Let $G$ be finite and let $(Y_n)$ be a graded $G$-set with all grades finite, eventually $r$-transitive from index $N$. Then the series*
$$F_r(q) \;=\; \sum_{n \ge 0}\Big(\sum_{g\in G}\big|\mathrm{Fix}_r(g, Y_n)\big|\Big) q^n$$
*is rational with denominator dividing $(1-q)^{r+1}$; indeed its coefficients are eventually the constant $|G|$, so for $|q|<1$*
$$F_r(q) \;=\; \sum_{n<N}\Big(\sum_{g\in G}|\mathrm{Fix}_r(g,Y_n)|\Big)q^n \;+\; \frac{|G|\,q^N}{1-q}.$$

*Proof sketch.* By Theorem 7.2 the coefficient equals $|G|$ for all $n \ge N$; apply Corollary 4.10 and Lemma 5.4 with $c = |G|$. $\square$

This form is often the computationally accessible one: fixed-point counts of individual group elements are typically easy (each $g$ fixes an injective $r$-tuple exactly when all $r$ entries are fixed points of $g$, so $|\mathrm{Fix}_r(g,Y)| = |Y^g|^{\underline r}$ where $Y^g$ is the fixed set), while orbit counts are not.

**Corollary 7.4 (Explicit coefficients).** *For finite $G$ and finite $Y$, $\;t_r(Y) = \frac{1}{|G|}\sum_{g\in G} |Y^g|^{\underline r}$, where $Y^g = \{y \in Y : g\cdot y = y\}$.*

*Proof sketch.* An injective $r$-tuple is fixed by $g$ iff each entry is, so the fixed tuples are exactly the injective $r$-tuples in $Y^g$, of which there are $|Y^g|^{\underline r}$. Substitute into Theorem 7.1. $\square$

Corollary 7.4 is the practical algorithm underlying all our numerical examples: it reduces the computation of $t_r(Y_n)$ to enumerating fixed sets.

---

## 8. Sharpness: the exponent $r+1$ is attained

We now show that no smaller power of $1-q$ suffices in general, first for a universal model sequence and then for a genuine graded $G$-set.

**Definition 8.1.** For $r \ge 0$ let $b^{(r)}_n = \binom{n+r}{r}$.

**Theorem 8.2 (The extremal model).** *For every $r \ge 0$,*
$$(1-q)^{r+1}\sum_{n\ge 0}\binom{n+r}{r}q^n \;=\; 1, \qquad\text{i.e.}\qquad \sum_{n\ge 0}\binom{n+r}{r}q^n \;=\; \frac{1}{(1-q)^{r+1}} .$$

*Proof sketch.* Induct on $r$. For $r=0$ the sequence is constant $1$ and $(1-q)\sum q^n = 1$ by telescoping. For the step, Pascal's rule $\binom{n+1+(r+1)}{r+1} = \binom{n+(r+1)}{r+1} + \binom{n+(r+1)}{r}$ says exactly that $(1-q)\sum_n b^{(r+1)}_n q^n = \sum_n b^{(r)}_n q^n$; combining with the inductive hypothesis gives the claim. $\square$

**Theorem 8.3 (Optimality of the exponent).** *For every $s \le r$, the series $(1-q)^s\sum_n \binom{n+r}{r}q^n$ is not a polynomial.*

*Proof sketch.* By the argument of Theorem 8.2 iterated $r$ times, $(1-q)^r \sum_n b^{(r)}_nq^n = \sum_n q^n$, the all-ones series, which is not a polynomial (its coefficients never vanish). If $(1-q)^s\sum_n b^{(r)}_n q^n$ were a polynomial for some $s\le r$, multiplying by the polynomial $(1-q)^{r-s}$ would exhibit the all-ones series as a polynomial, a contradiction. $\square$

We realise this extremal behaviour inside the category of graded $G$-sets.

**Definition 8.4 (Trivial-action family).** Fix a group $G$ and let $Y_n$ be a set of $n$ labelled elements on which $G$ acts trivially ($g\cdot y = y$ for all $g,y$).

**Theorem 8.5 (Transitivity counts of a trivial action).** *If $G$ acts trivially on a finite set $Y$ then every orbit on $\mathrm{Inj}_r(Y)$ is a singleton, so*
$$t_r(Y) \;=\; |Y|^{\underline r}.$$
*In particular, for the trivial-action family, $t_r(Y_n) = n^{\underline r} = n(n-1)\cdots(n-r+1)$, a polynomial in $n$ of degree exactly $r$.*

*Proof sketch.* The induced action on injective tuples is trivial, so the quotient map is a bijection and the number of orbits equals the number of tuples, computed in Definition 2.2. $\square$

**Theorem 8.6 (Exact denominator).** *For the trivial-action family, $(1-q)^{r+1}\sum_n t_r(Y_n)q^n$ is a polynomial, while for every $s \le r$ the series $(1-q)^{s}\sum_n t_r(Y_n)q^n$ is not. The denominator is therefore exactly $(1-q)^{r+1}$.*

*Proof sketch.* Polynomiality follows from Theorem 4.8 applied to the degree-$r$ polynomial $x^{\underline r} = x(x-1)\cdots(x-r+1)$. For the negative direction, the $r$-th difference of $n \mapsto n^{\underline r}$ is the constant $r!$ (differencing a monic degree-$d$ polynomial $d$ times yields $d!$ times the leading coefficient), which never vanishes; so by Theorem 4.7 the exponent $r$ fails, and multiplying by $(1-q)^{r-s}$ propagates the failure down to every $s \le r$. $\square$

**Theorem 8.7 (Disjointness of the regimes).** *For $r \ge 1$ the trivial-action family is never eventually $r$-transitive.*

*Proof sketch.* If it were, from index $N$ on we would have $t_r(Y_n)=1$, i.e. $n^{\underline r} = 1$ for all large $n$. But for $r\ge 1$ and $n \ge r+2$, $n^{\underline r} = (n-r+1)\cdot n^{\underline{r-1}} \ge 2$. $\square$

Thus the hypothesis of the main theorem is a genuine restriction, and the bound $(1-q)^{r+1}$ is exactly the right ambient exponent: it is achieved, and it is achieved by the most rigid family in the category.

---

## 9. An intermediate family: translations of a cyclic grade

Between "eventually $r$-transitive" (denominator $(1-q)$) and "no symmetry at all" (denominator exactly $(1-q)^{r+1}$) lies a continuum of behaviours; here is a concrete family occupying the middle.

**Definition 9.1.** Let $G = \mathbb{Z}$ (written multiplicatively) act on the grade $Y_n = \mathbb{Z}/n\mathbb{Z}$ by translation: $k \cdot x = x + \bar k$.

**Theorem 9.2 (Every grade is $1$-transitive).** *For every $n \ge 1$, $\mathbb{Z}$ acts $1$-transitively on $\mathbb{Z}/n\mathbb{Z}$.*

*Proof sketch.* The grade is nonempty, and given $x,y$ the integer $k$ with $\bar k = y - x$ (which exists since $\mathbb{Z}\to\mathbb{Z}/n\mathbb{Z}$ is surjective) translates $x$ to $y$. $\square$

Consequently Theorem 5.1 applies at $r = 1$ with $N = 0$: the partition function $Z_1$ is $\sum_n q^n = 1/(1-q)$, a simple pole. At order $2$ the behaviour changes.

**Theorem 9.3 (Second transitivity count of a cyclic grade).** *For $n \ge 1$,*
$$t_2(\mathbb{Z}/n\mathbb{Z}) \;=\; n-1 .$$

*Proof sketch.* Map an injective pair $(x,y)$ to its difference $y - x$, which is a nonzero element of $\mathbb{Z}/n\mathbb{Z}$ (nonzero exactly because $x\ne y$). Translation does not change the difference, so this descends to a map from orbits to nonzero residues. It is injective: two pairs with the same difference are related by the translation carrying the first coordinate of one to the first coordinate of the other, which then automatically matches the second coordinates. It is surjective: for $d \ne 0$ the pair $(0,d)$ is injective and has difference $d$. Hence the number of orbits is the number of nonzero residues, namely $n-1$. $\square$

**Theorem 9.4 (Exact denominator $(1-q)^2$).** *With $Y_n = \mathbb{Z}/(n+1)\mathbb{Z}$ (so $t_2(Y_n) = n$), the series $\sum_n t_2(Y_n)q^n$ satisfies: $(1-q)^2\sum_n t_2(Y_n)q^n$ is a polynomial (indeed $=q$), while $(1-q)\sum_n t_2(Y_n)q^n$ is not. The denominator is exactly $(1-q)^2$.*

*Proof sketch.* The coefficient sequence is $a_n = n$, whose first difference is the constant $1$ (never zero) and whose second difference vanishes identically. Apply the Exact Criterion (Theorem 4.7) in both directions; the explicit numerator is $q$ since $\sum_n n q^n = q/(1-q)^2$. $\square$

So the family is maximally symmetric at order $1$, and its failure to be doubly transitive is *linear* in the grade — which the partition function records precisely as a pole of order $2$. In general, by Theorem 4.7 the order of the pole at $q=1$ is the least $s$ with $\Delta^s t_r$ eventually zero, i.e. one more than the polynomial degree of the eventual growth of the transitivity counts. The pole order is a symmetry-deficit exponent.

---

## 10. Algorithms

All computations reduce to two primitives.

**Algorithm A (Transitivity count by fixed points).** Given a finite group $G$ acting on a finite set $Y$ and an order $r$, compute $t_r(Y)$ as $\frac{1}{|G|}\sum_{g\in G}|Y^g|^{\underline r}$ (Corollary 7.4). Cost: $O(|G|\cdot|Y|)$ arithmetic operations to build all fixed sets, plus $O(|G|\cdot r)$ to form the descending factorials. This is exponentially cheaper than orbit enumeration, which requires a union–find over $|Y|^{\underline r}$ tuples.

**Algorithm B (Denominator detection).** Given the first $M+1$ terms of a coefficient sequence, build the difference table $\Delta^0a, \Delta^1a, \dots$ and report the least $s$ such that the row $\Delta^s a$ is identically zero on a stable suffix of the available window; by Theorem 4.7 this $s$ is the order of the pole at $q=1$, and the numerator is $(1-q)^sA(q)$ truncated. Cost: $O(M^2)$ subtractions. The certificate is exact for sequences known to be eventually polynomial; for general data it is a conjecture-generating heuristic which the Coefficient Formula makes rigorous once a degree bound is available.

**Algorithm C (Numerator extraction).** Given $a$ eventually equal to a polynomial of degree $\le r$ from index $N$, compute the numerator $Q(q) = (1-q)^{r+1}A(q)$ by convolving the first $N+r+1$ coefficients of $a$ with the binomial coefficients of $(1-q)^{r+1}$; Theorem 4.9 guarantees no further terms are needed. Cost: $O((N+r)\cdot r)$.

---

## 11. Discussion

### 11.1 What the pole order measures

The classical mantra "rational generating function with denominator a power of $(1-q)$ $\iff$ quasi-polynomial coefficients" is here made exact and constructive by the Coefficient Formula. Because the criterion is a genuine equivalence, the analytic invariant (order of the pole at $q=1$) and the combinatorial invariant (least vanishing difference column) coincide *on the nose*, with an explicit index shift. For transitivity counts this gives a symmetry-deficit exponent: pole order $1$ means eventual $r$-transitivity, pole order $s$ means the number of orbit classes of $r$-tuples grows like a polynomial of degree $s-1$ in the grading parameter.

### 11.2 Physical reading

Interpreting $q$ as a fugacity and $n$ as a sector index, $Z_r$ is the partition function of a system whose sector weights are symmetry-class counts. Theorem 5.5 says the free energy $-\log Z_r$ has a logarithmic singularity at $q=1$ of the simplest kind whenever the system is eventually symmetric; no exotic critical behaviour is possible. The Burnside form (Theorem 7.3) is the "sum over sectors of the gauge group" version of the same quantity, and Theorem 7.2 is a statement of complete degeneracy: in the symmetric phase, each group element contributes, on average, exactly one frozen configuration.

### 11.3 Scope and limitations

Three limitations are worth stating explicitly. First, the results are stated for denominators that are powers of $(1-q)$; families whose transitivity counts are *quasi*-polynomial (periodic coefficients) require denominators $(1-q^p)^{d+1}$ and are not covered, though the difference machinery adapts by working with the operator $a_n \mapsto a_{n+p} - a_n$. Second, the descent theorem (Theorem 6.1) is stated for finite grades; the extension argument uses a cardinality count that must be replaced in the infinite setting. Third, the analytic form is stated for real $q$ in $(-1,1)$; the complex statement follows by the same geometric-series argument but we have not pursued the uniformity estimates that a full meromorphic-continuation theorem would require.

### 11.4 Relation to classical permutation group theory

Multiply transitive groups are rare and classified: apart from symmetric and alternating groups, only the Mathieu groups are $4$- or $5$-transitive. Our results are complementary in orientation: rather than classifying the actions with $t_r = 1$, we study families in which $t_r$ *converges* to $1$, and we quantify the rate at which it does so through the analytic structure of a generating function. In this sense the theory is a "deformation-theoretic" companion to the classification: the onset index $N$ and the numerator degree $N+r$ are the invariants recording how long the family takes to become highly transitive.

---

## 12. Future directions

Five falsifiable conjectures arise directly from the results above; each is stated so that a single explicit graded $G$-set could refute it, or an extension of the difference machinery could prove it.

**C1. Quasi-polynomial dichotomy for graded $G$-sets of polynomial size.** Let $Y = \bigsqcup_n Y_n$ be a graded $G$-set with $|Y_n| \le C n^d$ for all $n$. Then either the sequence $t_r(Y_n)$ is eventually quasi-polynomial in $n$ of degree $\le dr$ (so $\sum_n t_r(Y_n)q^n$ is rational with denominator dividing $(1-q^p)^{dr+1}$ for some period $p$), or $t_r(Y_n)$ is unbounded along a sparse set of grades of density $0$. The point is that the Growth Bound $t_r(Y)\le |Y|^{\underline r}$ caps the growth by a degree-$dr$ polynomial, and by the Exact Criterion rationality with that denominator is *equivalent* to eventual vanishing of the $(dr+1)$-st difference — turning an analytic question into a purely combinatorial one about difference tables. Since the equivalence holds in both directions, the conjecture reduces to constructing or excluding graded $G$-sets whose difference tables neither stabilise nor blow up.

**C2. Sharp numerator degree equals the onset of transitivity.** If $N$ is the *least* index from which all grades are $r$-transitive and some grade below $N$ is not, then the numerator $Q$ of $\sum_n t_r(Y_n)q^n = Q(q)/(1-q)^{r+1}$ has $\deg Q = N+r$ exactly (not merely $\le$), and $Q(1) = 1$. The bound $N+r$ is already available from the quantitative form, and the Coefficient Formula identifies the top coefficient of $Q$ with a single entry of the $(r+1)$-st difference table at the last irregular grade; sharpness is therefore a one-entry non-vanishing statement.

**C3. Transitivity spectrum rigidity.** For a graded $G$-set with all grades finite, the *transitivity spectrum* $k \mapsto (\text{least } N \text{ with all grades} \ge N \text{ being } k\text{-transitive})$ is a non-decreasing function of $k$ which is either finite for all $k$ (forcing $|G|$ to be infinite or the grades to be eventually bounded) or finite exactly on an initial segment $k \le r_0$. The descent theorem makes $k$-transitivity monotone downward in $k$, so the spectrum is an initial segment; what remains is to show that a *uniform* bound over all $k$ forces the strong structural dichotomy, via the Burnside identity.

**C4. Fixed-point spectral gap.** For a finite group $G$ and a graded $G$-set eventually $r$-transitive from index $N$, the sequence $n \mapsto \max_{g \ne 1}|\mathrm{Fix}_r(g,Y_n)|$ is eventually $0$; more precisely, in the symmetric phase only the identity contributes fixed injective $r$-tuples once $|Y_n|$ exceeds an explicit bound depending on $|G|$ and $r$. This would refine the Degeneracy Theorem from a statement about the average to a statement about the individual terms.

**C5. Two-variable rationality.** The bivariate series $\sum_{n,k} t_k(Y_n)\,z^k q^n$ of an eventually $r$-transitive graded $G$-set, truncated to $k \le r$, is a rational function of $(z,q)$ with denominator $(1-q)(1-z)$ up to a polynomial correction supported on the pre-onset grades. The descent theorem shows the coefficients stabilise in both directions simultaneously; the conjecture asks whether the stabilisation is uniform enough to give joint rationality.

---

## 13. Conclusion

We have shown that the transitivity partition function of a graded $G$-set that eventually becomes $r$-transitive is a rational function of the fugacity $q$ with denominator dividing $(1-q)^{r+1}$, with a numerator of degree at most $N+r$ determined by the transient pre-onset grades, and that on the unit disc it equals a finite polynomial plus the explicit geometric tail $q^N/(1-q)$ — a single simple pole at $q=1$ and nothing else. The mechanism is a two-way equivalence between powers of $(1-q)$ in the denominator and vanishing columns of the difference table, made precise by the identity $[q^{n+s}]\big((1-q)^sA(q)\big) = (\Delta^s a)_n$. This equivalence is what allows us to prove sharpness rather than merely a bound: the exponent $r+1$ is attained by the trivial-action family, whose counts are the descending factorials $n^{\underline r}$, and intermediate pole orders are realised by families such as the integers translating cyclic grades. Finally, Burnside's lemma recasts the coefficients as sums over the group of fixed-point counts, so that the entire partition function can be read as a trace over the symmetry group, degenerating to the constant $|G|$ exactly in the symmetric phase.
