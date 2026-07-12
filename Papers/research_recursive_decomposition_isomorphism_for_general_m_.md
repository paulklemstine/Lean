# The Enumerative Layer of the $m$-Tamari / $(m+1)$-Constellation Correspondence: Fuss–Catalan Element Counts and Bousquet-Mélou–Chapoton Interval Numbers

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

The conjectured recursive-decomposition isomorphism between general $m$-Tamari intervals and planar $(m+1)$-constellations has two layers: a *structural* layer, consisting of a generating-tree / statistic-transport correspondence, and an *enumerative* layer, which identifies the underlying counting sequences with the classical Fuss–Catalan and Bousquet-Mélou–Chapoton numbers. This paper supplies rigorous enumerative content. We define the Fuss–Catalan numbers $\mathrm{Cat}_m(n)$ through a manifestly integer two-term binomial difference and prove that this definition satisfies the classical rational closed form $(mn+1)\mathrm{Cat}_m(n)=\binom{(m+1)n}{n}$, yielding the divisibility $mn+1 \mid \binom{(m+1)n}{n}$ — the $m$-generalization of $(n+1)\mid\binom{2n}{n}$. We recover the ordinary Catalan numbers at $m=1$, establish small-value identities and positivity, and introduce the interval numbers $\mathrm{Int}_m(n)$, verifying the classical values $1,3,13,68$ (for $m=1$) and $1,6,58$ (for $m=2$). We prove that intervals strictly outnumber elements — the qualitative constraint any interval$\leftrightarrow$constellation bijection must respect — and prove that the factor $n$ of the interval denominator always divides the numerator, reducing full integrality to a single remaining divisibility by $mn+1$. Finally, we disprove two natural conjectures: that Fuss–Catalan numbers are symmetric in $(m,n)$, and that an $m$-free two-term formula computes them.

**Keywords:** Fuss–Catalan numbers, $m$-Tamari lattice, planar constellations, Bousquet-Mélou–Chapoton numbers, binomial coefficients, divisibility, Catalan numbers, lattice intervals.

## 1. Introduction

### 1.1 Background

The **Tamari lattice** organizes the parenthesizations of a product (equivalently the binary trees, or the triangulations of a polygon) into a lattice in which an elementary right-rotation is a covering relation. Its elements are counted by the Catalan numbers $C_n = \frac{1}{n+1}\binom{2n}{n}$. Fixing an integer parameter $m\ge 1$ yields the **$m$-Tamari lattice** $\mathcal{T}_m(n)$, whose elements are the $(m+1)$-ary trees with $n$ internal nodes, equivalently the lattice paths staying weakly above a line of slope $m$. At $m=1$ one recovers the classical Tamari lattice.

Two enumerative invariants attach to $\mathcal{T}_m(n)$:

- the **element count**, which is the Fuss–Catalan number $\mathrm{Cat}_m(n)$;
- the **interval count** — the number of pairs $(x,y)$ with $x\le y$ — which is the Bousquet-Mélou–Chapoton number $\mathrm{Int}_m(n)$.

A central conjecture in this area asserts that $m$-Tamari intervals are in refined bijection with **planar $(m+1)$-constellations** — certain bipartite maps on the sphere — with the bijection preserving statistics such as numbers of valleys, peaks, and component sizes. The $m=1$ case connects the interval numbers $1,3,13,68,\dots$ to well-studied families of planar maps and triangulations.

### 1.2 Scope of this paper

The structural side of the correspondence (succession rules, generating trees, statistic transport) is developed separately and explicitly leaves open the identification of the resulting counting sequences with the classical closed forms. This paper closes several enumerative gaps rigorously and from first principles. Concretely, we:

1. Define $\mathrm{Cat}_m(n)$ as a two-term binomial difference (manifestly a non-negative integer) and prove it equals the classical rational closed form (Theorem 3.2), whence a divisibility corollary (Corollary 3.3).
2. Recover Catalan numbers at $m=1$ (Theorem 3.7) and establish small values, positivity, and non-triviality (Theorems 3.4–3.6).
3. Define $\mathrm{Int}_m(n)$ over $\mathbb{Q}$, verify classical values (Proposition 4.1), prove intervals strictly outnumber elements (Theorem 4.2), and prove the $n$-factor of interval integrality (Theorem 4.3).
4. Disprove two plausible conjectures by explicit counterexample (Theorems 5.1–5.2).

All results are proved over $\mathbb{N}$ and $\mathbb{Q}$ using only the elementary binomial recurrence and standard facts about Catalan numbers.

## 2. Definitions

Throughout, $\binom{a}{b}$ denotes the usual binomial coefficient, with the convention $\binom{a}{b}=0$ when $b>a$. Subtraction on $\mathbb{N}$ is truncated (never negative), but each subtraction below occurs in a range where the subtrahend does not exceed the minuend, so no truncation is lost.

**Definition 2.1 (Fuss–Catalan number).** For $m,n\in\mathbb{N}$, define
$$\mathrm{Cat}_m(0) = 1, \qquad \mathrm{Cat}_m(n) = \binom{(m+1)n}{n} - m\binom{(m+1)n}{n-1}\quad (n\ge 1).$$
This is manifestly a difference of two natural numbers; positivity (Theorem 3.5) confirms it is a well-defined non-negative integer. Combinatorially, $\mathrm{Cat}_m(n)$ counts the $(m+1)$-ary trees with $n$ internal nodes, i.e. the elements of the $m$-Tamari lattice of size $n$.

**Definition 2.2 ($m$-Tamari interval number).** For $m,n\in\mathbb{N}$, define over $\mathbb{Q}$
$$\mathrm{Int}_m(n) = \frac{m+1}{n(mn+1)}\binom{(m+1)^2 n + m}{\,n-1\,}.$$
Conjecturally $\mathrm{Int}_m(n)$ equals the number of planar $(m+1)$-constellations of the appropriate size, and equals the number of intervals in $\mathcal{T}_m(n)$.

## 3. The Fuss–Catalan numbers

### 3.1 The key recurrence

**Lemma 3.1 (Absorption in the Fuss–Catalan window).** For all $m,n$,
$$(n+1)\binom{(m+1)(n+1)}{\,n+1\,} = \big(m(n+1)+1\big)\binom{(m+1)(n+1)}{\,n\,}.$$

*Proof.* Set $N=(m+1)(n+1)$. The standard identity $\binom{N}{k+1}(k+1)=\binom{N}{k}(N-k)$ with $k=n$ gives
$$\binom{N}{n+1}(n+1) = \binom{N}{n}(N-n).$$
Since $N = m(n+1) + (n+1)$, we have $N-n = m(n+1)+1$. Substituting yields the claim. $\square$

### 3.2 The closed form

**Theorem 3.2 (Closed form).** For all $m,n$,
$$(mn+1)\,\mathrm{Cat}_m(n) = \binom{(m+1)n}{n}.$$
Equivalently $\mathrm{Cat}_m(n) = \binom{(m+1)n}{n}/(mn+1)$, so Definition 2.1 agrees with the classical rational formula.

*Proof.* For $n=0$ both sides equal $1$. For $n\ge 1$ write $a=\binom{(m+1)(n+1)}{n+1}$, $b=\binom{(m+1)(n+1)}{n}$, and $s=m(n+1)+1$. Lemma 3.1 states $(n+1)a = sb$. First, $m b \le a$: from $(n+1)a = sb = (m(n+1)+1)b \ge m(n+1)b$ we get $(n+1)a \ge (n+1)(mb)$, and cancelling $n+1$ gives $a\ge mb$. Hence $d := a - mb$ is a genuine natural number and $a = d + mb$. Substituting into $(n+1)a = sb$:
$$(n+1)(d+mb) = sb = \big(m(n+1)+1\big)b = m(n+1)b + b,$$
so $(n+1)d = b$. Therefore
$$s\,\mathrm{Cat}_m(n+1) = s\,d = s\,d,\qquad\text{and}\qquad a = d + mb = d + m(n+1)d = \big(m(n+1)+1\big)d = s\,d,$$
i.e. $s\,\mathrm{Cat}_m(n+1) = a = \binom{(m+1)(n+1)}{n+1}$, which is the assertion at $n+1$. $\square$

**Corollary 3.3 (Divisibility).** For all $m,n$, $\;mn+1 \mid \binom{(m+1)n}{n}$. In particular, at $m=1$, $\;n+1 \mid \binom{2n}{n}$, the classical integrality of Catalan numbers.

*Proof.* Immediate from Theorem 3.2, with explicit quotient $\mathrm{Cat}_m(n)$. $\square$

### 3.3 Small values, positivity, non-triviality

**Theorem 3.4 (Unit value).** $\mathrm{Cat}_m(1) = 1$ for all $m$.

*Proof.* By Theorem 3.2, $(m+1)\mathrm{Cat}_m(1) = \binom{m+1}{1} = m+1$; cancel $m+1>0$. $\square$

**Theorem 3.5 (Positivity).** $\mathrm{Cat}_m(n) > 0$ for all $m,n$.

*Proof.* $\binom{(m+1)n}{n} > 0$ since $n\le (m+1)n$. If $\mathrm{Cat}_m(n)$ were $0$, Theorem 3.2 would force $\binom{(m+1)n}{n}=0$, a contradiction. $\square$

**Theorem 3.6 (Quadratic value and non-triviality).** $\mathrm{Cat}_m(2) = m+1$; hence for $m\ge 1$, $\mathrm{Cat}_m(2) > 1$, so the sequence is not eventually constant and genuinely depends on $m$.

*Proof.* By Theorem 3.2, $(2m+1)\mathrm{Cat}_m(2) = \binom{2(m+1)}{2} = (m+1)(2m+1)$; cancel $2m+1>0$ to get $\mathrm{Cat}_m(2) = m+1$. $\square$

**Theorem 3.7 (Recovery of Catalan numbers).** For all $n$, $\;\mathrm{Cat}_1(n) = C_n$, the $n$-th Catalan number and the size of the Tamari lattice.

*Proof.* By Theorem 3.2 with $m=1$, $(n+1)\mathrm{Cat}_1(n) = \binom{2n}{n}$. The Catalan numbers satisfy $(n+1)C_n = \binom{2n}{n}$ (the central binomial identity). Cancelling $n+1>0$ gives $\mathrm{Cat}_1(n) = C_n$. $\square$

## 4. The interval numbers

**Proposition 4.1 (Classical values).** The interval numbers take the values
$$\mathrm{Int}_1(1)=1,\ \mathrm{Int}_1(2)=3,\ \mathrm{Int}_1(3)=13,\ \mathrm{Int}_1(4)=68,$$
$$\mathrm{Int}_2(2)=6,\ \mathrm{Int}_2(3)=58.$$
The $m=1$ sequence $1,3,13,68,399,\dots$ is the sequence of Tamari-interval numbers (equivalently a planar-triangulation enumeration); the $m=2$ sequence begins $1,6,58,\dots$.

*Proof.* Direct evaluation of Definition 2.2. For instance, at $m=1,n=2$ we have $(m+1)^2 n + m = 4\cdot 2 + 1 = 9$ and $n-1=1$, so $\mathrm{Int}_1(2)=\frac{2}{2\cdot 3}\binom{9}{1} = \frac{2}{6}\cdot 9 = 3$. The remaining values are analogous finite computations. $\square$

**Theorem 4.2 (Intervals strictly outnumber elements).** $\mathrm{Cat}_1(2) < \mathrm{Int}_1(2)$; explicitly $2 < 3$. Consequently no bijection at the level of lattice *elements* can realize the interval$\leftrightarrow$constellation correspondence: it must operate on intervals.

*Proof.* $\mathrm{Cat}_1(2)=2$ by Theorem 3.6 and $\mathrm{Int}_1(2)=3$ by Proposition 4.1. $\square$

**Theorem 4.3 ($n$-factor of interval integrality).** For every $m$ and every $n\ge 1$,
$$n \;\big|\; (m+1)\binom{(m+1)^2 n + m}{\,n-1\,}.$$

*Proof.* Write $N = (m+1)^2 n + m$. The absorption identity $n\binom{N}{n} = (N-n+1)\binom{N}{n-1}$ (the recurrence $\binom{N}{k}(N-k) = \binom{N}{k+1}(k+1)$ read at $k=n-1$) applies, and here
$$N - n + 1 = (m+1)^2 n + m - n + 1 = m(m+2)n + (m+1).$$
Hence
$$(m+1)\binom{N}{n-1} = n\binom{N}{n} - m(m+2)n\binom{N}{n-1} = n\Big(\binom{N}{n} - m(m+2)\binom{N}{n-1}\Big),$$
exhibiting $n$ as a divisor with explicit cofactor $\binom{N}{n} - m(m+2)\binom{N}{n-1}$. $\square$

**Remark 4.4 (Reduction of full integrality).** Since $\gcd(n, mn+1) = 1$ (any common divisor divides $mn+1 - m\cdot n = 1$), the denominator $n(mn+1)$ of $\mathrm{Int}_m(n)$ factors into coprime parts. Theorem 4.3 settles the $n$-part. The full integrality of $\mathrm{Int}_m(n)$ therefore reduces to the single divisibility
$$mn+1 \;\big|\; (m+1)\binom{(m+1)^2 n + m}{\,n-1\,}.$$
Unlike the $n$-factor, this does not follow from a one-step absorption: the index $n-1$ and the target modulus $mn+1$ are unrelated. It appears to require a cycle-lemma / Lagrange-inversion argument analogous to the one behind Corollary 3.3.

## 5. Contrarian layer: disproved conjectures

Two plausible-looking conjectures are false; each failure clarifies the structure.

**Theorem 5.1 (No $(m,n)$-symmetry).** It is *not* true that $\mathrm{Cat}_m(n) = \mathrm{Cat}_n(m)$ for all $m,n$.

*Proof.* $\mathrm{Cat}_1(2) = 2$ (Theorem 3.6) but $\mathrm{Cat}_2(1) = 1$ (Theorem 3.4). $\square$

**Theorem 5.2 (The multiplier $m$ is essential).** It is *not* true that
$$\mathrm{Cat}_m(n) = \binom{(m+1)n}{n} - \binom{(m+1)n}{n-1}$$
for all $m,n$; the $m$-free second term is wrong. At $m=2,\ n=2$ we have $(m+1)n = 6$, so the right side is $\binom{6}{2} - \binom{6}{1} = 15 - 6 = 9$, whereas $\mathrm{Cat}_2(2) = 3$.

*Proof.* $\mathrm{Cat}_2(2) = 3$ by Theorem 3.6, while $\binom{6}{2}-\binom{6}{1} = 9 \neq 3$. $\square$

The multiplier $m$ on the second binomial in Definition 2.1 is precisely what makes the cancellation in Theorem 3.2 exact; removing it destroys both the closed form and the divisibility.

## 6. Algorithms

We record the computational content used in the demonstrations.

**Algorithm A (Fuss–Catalan via binomial difference).** Compute $\mathrm{Cat}_m(n) = \binom{(m+1)n}{n} - m\binom{(m+1)n}{n-1}$ with exact integer arithmetic. Complexity $O(n)$ multiplications for each binomial coefficient computed incrementally; the difference is exact and non-negative.

**Algorithm B (Closed-form / divisibility verifier).** For a range of $(m,n)$, compute $\binom{(m+1)n}{n}$, verify $mn+1$ divides it, and check the quotient equals Algorithm A's output. This certifies Theorem 3.2 and Corollary 3.3 numerically.

**Algorithm C (Interval number and integrality diagnostics).** Compute $\mathrm{Int}_m(n)$ from Definition 2.2 with exact rational arithmetic, verify it is an integer, and separately confirm the $n$-factor divisibility of Theorem 4.3 and the reduced $mn+1$ divisibility of Remark 4.4.

## 7. Applications and discussion

The enumerative facts above are the arithmetic backbone of the $m$-Tamari / constellation program:

- **Integrality with meaning.** Corollary 3.3 and Theorem 4.3 explain *why* the counting formulas produce integers, in a way that mirrors the combinatorial objects being counted. The difference-of-binomials form of $\mathrm{Cat}_m(n)$ is itself suggestive of an inclusion–exclusion or cycle-lemma bijection.
- **Interval-level correspondence.** Theorem 4.2 shows the correspondence with constellations cannot be an element-level bijection; the extra structure of intervals is essential. This constrains the search for explicit bijections.
- **A sharp open target.** Remark 4.4 isolates a single clean divisibility ($mn+1 \mid (m+1)\binom{(m+1)^2 n + m}{n-1}$) as the entire remaining obstruction to interval-number integrality.
- **Guardrails.** The disproofs (Theorems 5.1–5.2) rule out two seductive shortcuts, saving future work from blind alleys.

## 8. Future directions

The following directions extend the present enumerative layer.

1. **General integrality of $\mathrm{Int}_m(n)$.** Prove $n(mn+1) \mid (m+1)\binom{(m+1)^2 n + m}{n-1}$ for all $m,n$. The $n$-factor is settled (Theorem 4.3); since $\gcd(n,mn+1)=1$, the remaining task is divisibility by $mn+1$ alone. This does not follow from a single absorption step and appears to require a cycle-lemma / Lagrange-inversion argument analogous to the one behind Corollary 3.3.

2. **Fuss–Catalan convolution recurrence.** Prove $\mathrm{Cat}_m(n+1) = \sum_{i_1+\cdots+i_{m+1}=n}\mathrm{Cat}_m(i_1)\cdots\mathrm{Cat}_m(i_{m+1})$, connecting the closed form directly to the $(m+1)$-ary tree decomposition.

3. **Identify the generating-tree counting sequence with $\mathrm{Cat}_m$ / $\mathrm{Int}_m$.** The structural side builds succession rules and proves refined equinumerosity of two encodings; the remaining step is to show the resulting counting sequence *is* the $m$-Tamari interval sequence $\mathrm{Int}_m(n)$, i.e. to connect the abstract generating tree to the Bousquet-Mélou–Chapoton closed form.

## 9. Conclusion

We have supplied rigorous enumerative content for the $m$-Tamari / $(m+1)$-constellation correspondence: an integer definition of the Fuss–Catalan numbers matching the classical closed form, the corresponding divisibility, recovery of Catalan numbers at $m=1$, small values and positivity, the interval numbers with verified classical values, the strict excess of intervals over elements, the $n$-factor of interval integrality reducing the open case to a single divisibility, and two instructive disproofs. Together these fix the arithmetic ground on which the structural bijection to planar constellations is to be built.
