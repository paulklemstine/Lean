# The Dimension Spectrum of Truth: Box-Counting Dimension of Theories over the Cantor Space of Statements

**Author:** Aristotle
**Date:** 2026-08-06

---

## Abstract

We develop a quantitative size measure for bodies of formal statements. Encoding statements of description length $n$ as elements of $\{0,1\}^n$, a *theory* is a family $T = (T_n)_{n \in \mathbb{N}}$ with $T_n \subseteq \{0,1\}^n$, and its *fractal dimension* is the box-counting dimension
$$
\dim T \;=\; \limsup_{n \to \infty} \frac{\log_2 |T_n|}{n}
$$
of the associated subset of Cantor space, with cylinders of length $n$ playing the role of boxes of diameter $2^{-n}$. We prove that $\dim T \in [0,1]$ for every theory and that $\dim$ is monotone under inclusion, both statements requiring the convention $\log_2 0 = 0$ to handle empty levels.

Our main result determines the dimension of an explicit family. For a modulus $m \ge 1$ and a set of admissible residues $R \subseteq \{0,\dots,m-1\}$, the *periodic density theory* $D(m,R)$ accepts exactly those strings whose coordinates $i$ with $i \bmod m \notin R$ vanish. We prove the exact counting law $|D(m,R)_n| = 2^{F_{m,R}(n)}$, where $F_{m,R}(n) = \#\{i < n : i \bmod m \in R\}$; the exact period relation $F_{m,R}(n+m) = F_{m,R}(n) + |R|$; the two-sided sandwich $|R|\lfloor n/m \rfloor \le F_{m,R}(n) \le |R|\lfloor n/m \rfloor + |R|$; and, by squeezing, that the finite-scale estimates converge at rate $O(1/n)$ to $|R|/m$. Hence
$$
\dim D(m,R) \;=\; \frac{|R|}{m},
$$
the asymptotic density of information-bearing coordinates. As an immediate corollary, **every rational number in $[0,1]$ is the dimension of an explicitly constructed theory**, so the dimension spectrum of truth contains $[0,1] \cap \mathbb{Q}$; the previously isolated value $1/2$ is one point of a full rational spectrum. The extreme values $0$ and $1$ are attained, so the universal bounds are sharp. We give algorithms computing the counting and dimension data exactly in $O(n)$ arithmetic operations, discuss the compression-theoretic interpretation of the dimension, and indicate the extension to aperiodic patterns of arbitrary asymptotic density, which yields irrational dimensions.

**Keywords:** box-counting dimension, Cantor space, fractal dimension, formal theories, counting complexity, asymptotic density, information rate, compressibility.

---

## 1. Introduction

### 1.1 Motivation

How large is a body of mathematics? Cardinality is useless: any recursively axiomatized theory with a single free variable already proves countably many distinct statements, so all interesting theories are equinumerous. Deductive strength is the classical answer, but it is an *order*, not a *number*: consistency strength compares theories, it does not measure them on a scale.

There is a third answer, and it is quantitative. Fix an encoding of statements as finite bit strings. At each description length $n$ there are $2^n$ candidate strings, of which the theory accepts some sub-collection. The *rate* at which that sub-collection grows — the exponent $d$ such that roughly $2^{dn}$ strings of length $n$ are accepted — is a single real number in $[0,1]$ that captures how much of the available description space the theory occupies. It is invariant under any reasonable re-encoding that preserves lengths up to $o(n)$, it is monotone under enlarging the theory, and, as we show, it has a clean and complete realization theory.

The exponent is not an ad hoc invention. It is precisely the box-counting dimension of the theory viewed as a subset of Cantor space $\{0,1\}^{\mathbb{N}}$, with the standard ultrametric $d(x,y) = 2^{-\min\{i\,:\,x_i \ne y_i\}}$. Under that metric, the closed balls of radius $2^{-n}$ are exactly the cylinders determined by the first $n$ coordinates, and the number of such balls needed to cover the set of infinite extensions of the theory's length-$n$ strings is exactly $|T_n|$. The box-counting formula $\log N(\varepsilon)/\log(1/\varepsilon)$ at $\varepsilon = 2^{-n}$ then reads $\log_2|T_n|/n$. So the "growth rate of truth" and "the fractal dimension of truth" are literally the same quantity.

### 1.2 Prior state and the question addressed

A prior development in this line established that one specific theory — a "half-information" theory in which the odd-indexed coordinates are forced to zero — has dimension exactly $1/2$. That result immediately raises a question of principle: is $1/2$ a distinguished value, an artefact of a symmetric construction, or the tip of a general law?

We show it is the latter, in the strongest form: the dimension of a periodically constrained theory is *exactly* the asymptotic density of its free coordinates, and by tuning that density every rational value in $[0,1]$ is realized by a concrete theory.

### 1.3 Contributions

1. **Framework and universal bounds** (§2, §3). We define $\mathrm{count}$, the finite-scale estimate, and $\dim$, and prove $0 \le \dim T \le 1$ for all $T$, together with the boundedness and coboundedness facts needed to manipulate the $\limsup$ rigorously.
2. **Monotonicity** (§4). $T_n \subseteq T'_n$ for all $n$ implies $\dim T \le \dim T'$, with the degenerate case $|T_n| = 0$ handled by the convention $\log_2 0 = 0$.
3. **Exact combinatorics of periodic density theories** (§5). The counting law $|D(m,R)_n| = 2^{F_{m,R}(n)}$, the period relation, the exact value at multiples of the period, and the two-sided sandwich.
4. **The Density Theorem** (§6). $\dim D(m,R) = |R|/m$, with $O(1/n)$ convergence of the finite-scale estimates — so the $\limsup$ is an honest limit for this family.
5. **The Realization Theorem** (§7). Every rational in $[0,1]$ is a dimension, witnessed constructively; the values $0$, $1/2$, $1$ are recovered as instances; the universal bounds are sharp.
6. **Algorithms and numerics** (§8). Exact $O(n)$ computation of $F_{m,R}$, $|D(m,R)_n|$, and the finite-scale estimates, plus certified error bars from the sandwich.
7. **Interpretation and extensions** (§9, §10). Compressibility reading, the role of the $\limsup$, aperiodic generalization to arbitrary densities.

---

## 2. The framework

### 2.1 Statements, theories, counts

**Definition 2.1 (Statement).** A *statement of length $n$* is an element of $\{0,1\}^n$, i.e. a function $\{0,1,\dots,n-1\} \to \{0,1\}$. We think of the bit string as the encoding of a formal assertion under a fixed, injective, length-respecting encoding scheme.

**Definition 2.2 (Theory).** A *theory* is a family $T = (T_n)_{n \in \mathbb{N}}$ where each $T_n$ is a (finite) subset of $\{0,1\}^n$. We call $T_n$ the *level $n$* of the theory: the set of accepted statements of length $n$.

No deductive closure is imposed. The framework is deliberately agnostic: $T$ is any length-graded set of accepted strings, so it can model the theorems of an axiomatic system, the outputs of a decision procedure, a set of valid certificates, or an arbitrary language.

**Definition 2.3 (Count).** $\mathrm{count}(T,n) := |T_n|$.

Since $T_n \subseteq \{0,1\}^n$ and $|\{0,1\}^n| = 2^n$:

**Lemma 2.4 (Trivial count bound).** For every theory $T$ and every $n$, $\mathrm{count}(T,n) \le 2^n$.

*Proof.* $T_n$ is a subset of a set of size $2^n$; cardinality is monotone under inclusion. $\square$

### 2.2 The dimension

**Convention 2.5.** Throughout, $\log_2 0 := 0$. This is the standard convention for the real logarithm extended by $0$ at $0$, and it is exactly what is needed for the results below: an empty level contributes the minimal possible finite-scale estimate.

**Definition 2.6 (Finite-scale estimate).** For $n \ge 1$,
$$
\delta_T(n) \;:=\; \frac{\log_2 \mathrm{count}(T,n)}{n}.
$$
(At $n = 0$ the expression is $0/0$, interpreted as $0$; the value at a single index is irrelevant to the asymptotics.)

**Definition 2.7 (Fractal dimension of a theory).**
$$
\dim T \;:=\; \limsup_{n \to \infty} \delta_T(n) \;=\; \limsup_{n \to \infty} \frac{\log_2 |T_n|}{n}.
$$

**Remark 2.8 (Why this is a box dimension).** Let $[T] \subseteq \{0,1\}^{\mathbb{N}}$ be the set of infinite sequences all of whose length-$n$ prefixes lie in $T_n$ (for a *tree-like* theory, i.e. one closed under taking prefixes, $[T]$ is the natural compact realization of $T$). With the ultrametric $d(x,y) = 2^{-\min\{i : x_i \ne y_i\}}$, the minimal number of balls of radius $2^{-n}$ covering $[T]$ is the number of distinct length-$n$ prefixes, which is at most $|T_n|$ and equals it when every accepted prefix extends. Then
$$
\frac{\log N(2^{-n})}{\log(1/2^{-n})} = \frac{\log_2 |T_n|}{n} = \delta_T(n),
$$
and the upper box dimension of $[T]$ is $\limsup_n \delta_T(n) = \dim T$. For the periodic density theories studied below the prefix-closure hypothesis holds exactly, so $\dim$ is genuinely the box dimension of a compact subset of Cantor space.

---

## 3. Universal bounds

**Lemma 3.1 (Logarithmic bound).** For every theory $T$ and every $n$, $\log_2 \mathrm{count}(T,n) \le n$.

*Proof.* If $\mathrm{count}(T,n) = 0$, the left side is $0 \le n$ by Convention 2.5. Otherwise $1 \le \mathrm{count}(T,n) \le 2^n$ by Lemma 2.4, and monotonicity of $\log_2$ on the positives gives $\log_2 \mathrm{count}(T,n) \le \log_2 2^n = n$. $\square$

**Lemma 3.2 (Estimates lie in the unit interval).** For every theory $T$: $\delta_T(n) \ge 0$ for all $n$, and $\delta_T(n) \le 1$ for all $n \ge 1$.

*Proof.* Nonnegativity: the denominator $n$ is nonnegative, and the numerator is $0$ when the count is $0$, and is $\log_2$ of an integer $\ge 1$, hence $\ge 0$, otherwise. Upper bound: for $n \ge 1$, divide Lemma 3.1 by $n > 0$. $\square$

**Proposition 3.3 (Universal bounds).** For every theory $T$,
$$
0 \;\le\; \dim T \;\le\; 1.
$$

*Proof.* The family $(\delta_T(n))_n$ is eventually bounded above by $1$ (Lemma 3.2), so the $\limsup$ is a well-defined real number at most $1$. It is bounded below by $0$ pointwise, so the $\limsup$ is at least $0$. Formally, boundedness above (needed for the $\limsup$ to be finite) follows from $\delta_T(n) \le 1$ eventually, and coboundedness below (needed for $\limsup$ manipulations) from $\delta_T(n) \ge 0$ for all $n$. $\square$

Both bounds are attained (Corollary 7.3), so Proposition 3.3 cannot be improved.

---

## 4. Monotonicity

**Lemma 4.1 (Counts are monotone).** If $T_n \subseteq T'_n$ for all $n$, then $\mathrm{count}(T,n) \le \mathrm{count}(T',n)$ for all $n$.

*Proof.* Cardinality is monotone under inclusion of finite sets. $\square$

**Lemma 4.2 (Estimates are monotone).** Under the same hypothesis, $\delta_T(n) \le \delta_{T'}(n)$ for all $n$.

*Proof.* Denominators agree and are nonnegative, so it suffices to compare numerators. If $\mathrm{count}(T,n) = 0$ then the numerator on the left is $0$ by Convention 2.5, while the numerator on the right is $\log_2$ of a nonnegative integer, hence $\ge 0$ (again using the convention for the value $0$). Otherwise both counts are positive and $\log_2$ is monotone, so Lemma 4.1 transfers. $\square$

**Theorem 4.3 (Monotonicity of dimension).** If $T_n \subseteq T'_n$ for all $n$, then $\dim T \le \dim T'$.

*Proof.* $\delta_T \le \delta_{T'}$ pointwise (Lemma 4.2), and both families satisfy the boundedness/coboundedness hypotheses of Proposition 3.3, so the $\limsup$ comparison applies. $\square$

Theorem 4.3 says the dimension is an order-preserving map from the inclusion order on theories to $[0,1]$. It is not injective — many theories share a dimension — and it is not a lattice homomorphism, but it is a genuine numerical invariant of the growth of a theory.

---

## 5. Periodic density theories: exact combinatorics

We now introduce the family that carries the main theorem.

**Definition 5.1 (Periodic density theory).** Let $m \ge 1$ and $R \subseteq \{0,1,\dots,m-1\}$ (we write the hypothesis as $R \subseteq \{0,\dots,m-1\}$; residues outside this range would be redundant since $i \bmod m < m$ always). The *periodic density theory* $D(m,R)$ has levels
$$
D(m,R)_n \;=\; \bigl\{\, x \in \{0,1\}^n \;:\; \text{for all } i < n,\; (i \bmod m \notin R) \Rightarrow x_i = 0 \,\bigr\}.
$$
Coordinate $i$ is called *free* if $i \bmod m \in R$ and *frozen* otherwise. Equivalently, $D(m,R)_n$ is the product $\prod_{i<n} A_i$ with $A_i = \{0,1\}$ for free $i$ and $A_i = \{0\}$ for frozen $i$.

**Definition 5.2 (Free-coordinate count).**
$$
F_{m,R}(n) \;:=\; \#\{\, i \in \{0,\dots,n-1\} \;:\; i \bmod m \in R \,\}.
$$

**Theorem 5.3 (Exact counting law).** For all $m, R, n$,
$$
\mathrm{count}(D(m,R),n) \;=\; 2^{F_{m,R}(n)}.
$$

*Proof.* $D(m,R)_n$ is a Cartesian product of one-or-two-element sets indexed by $i < n$: two elements at free coordinates and one at frozen ones. The cardinality of a product is the product of cardinalities, i.e. $\prod_{i<n} |A_i| = \prod_{i<n} 2^{[i \text{ free}]} = 2^{\sum_{i<n} [i \text{ free}]} = 2^{F_{m,R}(n)}$, where $[\cdot]$ is the indicator. $\square$

The exactness matters. It means no approximation is committed at the counting stage, and it collapses the logarithm in the dimension estimate to a ratio of integers:

**Corollary 5.4 (Estimate is a free-coordinate ratio).** For $n \ge 1$,
$$
\delta_{D(m,R)}(n) \;=\; \frac{F_{m,R}(n)}{n}.
$$

*Proof.* Substitute Theorem 5.3 into Definition 2.6 and use $\log_2 2^k = k$. $\square$

**Lemma 5.5 (Base case and monotonicity).** $F_{m,R}(0) = 0$, and $F_{m,R}$ is nondecreasing in $n$.

*Proof.* The empty range has no admissible indices. Enlarging $n$ enlarges the index range $\{0,\dots,n-1\}$, hence the set of admissible indices, hence its cardinality. $\square$

**Theorem 5.6 (Period relation).** If $R \subseteq \{0,\dots,m-1\}$, then for all $n$,
$$
F_{m,R}(n+m) \;=\; F_{m,R}(n) + |R|.
$$

*Proof.* Split the index range $\{0,\dots,n+m-1\}$ as $\{0,\dots,n-1\} \sqcup \{n,\dots,n+m-1\}$. The first block contributes $F_{m,R}(n)$ by definition. The second block consists of $m$ consecutive integers, hence forms a complete residue system modulo $m$: the map $i \mapsto i \bmod m$ restricted to $\{n,\dots,n+m-1\}$ is a bijection onto $\{0,\dots,m-1\}$. Therefore exactly $|R|$ of those indices are admissible, one for each residue in $R$ (using $R \subseteq \{0,\dots,m-1\}$ so that every element of $R$ actually occurs as a residue). $\square$

**Corollary 5.7 (Exact value at multiples of the period).** If $R \subseteq \{0,\dots,m-1\}$, then for all $q \ge 0$,
$$
F_{m,R}(mq) \;=\; |R| \cdot q.
$$

*Proof.* Induction on $q$. For $q = 0$ this is $F_{m,R}(0) = 0$. For the step, $F_{m,R}(m(q+1)) = F_{m,R}(mq + m) = F_{m,R}(mq) + |R| = |R|q + |R| = |R|(q+1)$ by Theorem 5.6 and the inductive hypothesis. $\square$

**Theorem 5.8 (Two-sided sandwich).** Let $m \ge 1$ and $R \subseteq \{0,\dots,m-1\}$. Then for all $n$,
$$
|R| \left\lfloor \frac{n}{m} \right\rfloor \;\le\; F_{m,R}(n) \;\le\; |R| \left\lfloor \frac{n}{m} \right\rfloor + |R|.
$$

*Proof.* *Lower bound.* Put $q = \lfloor n/m \rfloor$. Then $mq \le n$, so by monotonicity (Lemma 5.5) and Corollary 5.7, $|R|q = F_{m,R}(mq) \le F_{m,R}(n)$.

*Upper bound.* With the same $q$, division with remainder gives $n = mq + r$ with $0 \le r < m$, hence $n \le m(q+1)$. Monotonicity and Corollary 5.7 give $F_{m,R}(n) \le F_{m,R}(m(q+1)) = |R|(q+1) = |R|q + |R|$. $\square$

The gap between the two bounds is the constant $|R| \le m$, independent of $n$. This is what makes the squeeze in the next section quantitative.

---

## 6. The Density Theorem

**Theorem 6.1 (Quantitative convergence).** Let $m \ge 1$ and $R \subseteq \{0,\dots,m-1\}$. Then for every $n \ge 1$,
$$
\left| \delta_{D(m,R)}(n) - \frac{|R|}{m} \right| \;\le\; \frac{|R|}{n}.
$$
Consequently $\delta_{D(m,R)}(n) \to |R|/m$ as $n \to \infty$, at rate $O(1/n)$.

*Proof.* Write $F = F_{m,R}(n)$, $k = |R|$, $q = \lfloor n/m \rfloor$, and $n = mq + r$ with $0 \le r < m$. By Corollary 5.4 the estimate is $F/n$, so we must bound $|F/n - k/m|$.

*Upper deviation.* By Theorem 5.8, $F \le kq + k$. Since $mq \le n$ we have $q \le n/m$, so
$$
\frac{F}{n} \le \frac{kq + k}{n} \le \frac{k n/m + k}{n} = \frac{k}{m} + \frac{k}{n}.
$$

*Lower deviation.* By Theorem 5.8, $F \ge kq$. From $n = mq + r$ with $r < m$ we get $q > n/m - 1$, i.e. $q \ge (n-r)/m \ge n/m - 1$, so
$$
\frac{F}{n} \ge \frac{kq}{n} \ge \frac{k(n/m - 1)}{n} = \frac{k}{m} - \frac{k}{n}.
$$

Combining the two displays gives $|F/n - k/m| \le k/n$. Since $k$ is a fixed constant, the right-hand side tends to $0$, and given $\varepsilon > 0$ any $n > k/\varepsilon$ makes the deviation smaller than $\varepsilon$. $\square$

**Theorem 6.2 (Density Theorem).** Let $m \ge 1$ and $R \subseteq \{0,\dots,m-1\}$. Then
$$
\dim D(m,R) \;=\; \frac{|R|}{m}.
$$

*Proof.* The finite-scale estimates converge to $|R|/m$ by Theorem 6.1. For a convergent sequence the $\limsup$ equals the limit, so $\dim D(m,R) = \lim_n \delta_{D(m,R)}(n) = |R|/m$. $\square$

**Remark 6.3 (Robustness).** No step of the argument used the *identity* of the admissible residues, only their number $|R|$. The theories $D(3,\{0,1\})$ and $D(3,\{0,2\})$ are different sets of strings — level $3$ of the first is $\{000,100,010,110\}$ and of the second $\{000,100,001,101\}$ — and their counts differ at lengths that are not multiples of the period (at $n=2$ the first has $4$ elements and the second $2$). But by Corollary 5.7 they agree exactly at every multiple of $3$, and the sandwich forces the intermediate values to within the constant $|R|$, so both have dimension $2/3$. Dimension is blind to *which* coordinates carry information, sensitive only to *how many*. This insensitivity is precisely what makes the realization theorem of the next section possible.

**Remark 6.4 (Certified error bars).** Theorem 6.1 turns numerical experiments into proofs: computing $\delta_{D(m,R)}(n)$ at a single $n$ certifies the dimension to within $|R|/n$. There is no hidden constant and no asymptotic caveat; the inequality holds at every $n \ge 1$.

---

## 7. The dimension spectrum of truth

**Theorem 7.1 (Realization Theorem).** For all natural numbers $p \le q$ with $q \ge 1$, there is a theory $T$ with
$$
\dim T \;=\; \frac{p}{q}.
$$
Explicitly, $T = D(q, \{0,1,\dots,p-1\})$ works.

*Proof.* Let $R = \{0,\dots,p-1\}$. Since $p \le q$ we have $R \subseteq \{0,\dots,q-1\}$, and $|R| = p$. Theorem 6.2 with $m = q$ gives $\dim D(q,R) = |R|/q = p/q$. $\square$

**Corollary 7.2 (Rational spectrum).** Every rational number in $[0,1]$ is the fractal dimension of an explicitly constructible theory. The dimension spectrum
$$
\mathcal{S} \;=\; \{\, \dim T \;:\; T \text{ a theory} \,\} \subseteq [0,1]
$$
satisfies $[0,1] \cap \mathbb{Q} \subseteq \mathcal{S}$, so $\mathcal{S}$ is dense in $[0,1]$.

*Proof.* A rational in $[0,1]$ can be written $p/q$ in lowest terms with $0 \le p \le q$ and $q \ge 1$; apply Theorem 7.1. Density in $[0,1]$ follows since the rationals are dense and $\mathcal{S} \subseteq [0,1]$ by Proposition 3.3. $\square$

**Corollary 7.3 (Landmark values; sharpness).**
1. $\dim D(1,\{0\}) = 1$: the modulus-$1$ theory with the unique residue admissible frees every coordinate, so its levels are all of $\{0,1\}^n$ and its dimension is $1$.
2. $\dim D(2,\{0\}) = 1/2$: the half-information theory, in which even coordinates are free and odd coordinates forced to $0$, has dimension exactly one half.
3. $\dim D(1,\varnothing) = 0$: with no admissible residue every coordinate is frozen, each level is the singleton $\{0^n\}$, and the dimension is $0$.

In particular the bounds of Proposition 3.3 are attained, so no strictly sharper universal bound on $\dim$ exists.

*Proof.* Each is Theorem 6.2 with the indicated $(m,R)$: $1/1 = 1$, $1/2$, and $0/1 = 0$ respectively. $\square$

Corollary 7.3(2) is worth emphasizing: the value $1/2$ that motivated this study is not distinguished. It is the point of the spectrum at $(m,|R|) = (2,1)$, no more canonical than $3/7$ at $(7,3)$.

**Example 7.4.** The theory $D(3,\{0,1\})$ — free coordinates at positions $\equiv 0,1 \pmod 3$, frozen at positions $\equiv 2$ — has dimension $2/3$. Its counts are $1, 2, 4, 4, 8, 16, 16, 32, 64, 64, \dots$ for $n = 0,1,2,\dots$, i.e. $2^{F}$ with $F = 0,1,2,2,3,4,4,5,6,6,\dots$.

**Example 7.5.** The theory $D(7,\{0,1,2\})$ has dimension $3/7 \approx 0.428571$. At $n = 100$ we have $100 = 7\cdot 14 + 2$, so the free-coordinate count is $F = 3\cdot 14 + \#\{r \in \{0,1,2\} : r < 2\} = 42 + 2 = 44$ and the estimate is $44/100 = 0.44$. Theorem 6.1 certifies $|0.44 - 3/7| \le 3/100 = 0.03$; the true error is $0.0114285\ldots$, comfortably inside.

---

## 8. Algorithms

All quantities in this development are exactly computable.

### 8.1 Free-coordinate count

The definition $F_{m,R}(n) = \#\{i<n : i \bmod m \in R\}$ gives a direct $O(n)$ algorithm, but the period structure gives an $O(m)$ one, independent of $n$:

$$
F_{m,R}(n) \;=\; |R| \cdot \left\lfloor \frac{n}{m} \right\rfloor \;+\; \#\{\, r \in R \;:\; r < n \bmod m \,\}.
$$

*Justification.* Write $n = mq + s$ with $s = n \bmod m$. The first $mq$ indices contribute exactly $|R|q$ by Corollary 5.7. The remaining indices $mq, mq+1, \dots, mq+s-1$ have residues $0,1,\dots,s-1$, so exactly those $r \in R$ with $r < s$ are counted. This closed form refines the sandwich of Theorem 5.8: it shows the correction term lies in $[0,|R|]$, recovering both bounds. Complexity: $O(|R|)$ arithmetic operations, or $O(1)$ after $O(m)$ preprocessing of a prefix-count table for $R$.

### 8.2 Count and dimension estimate

Given $F_{m,R}(n)$, the count is $2^{F_{m,R}(n)}$ exactly (Theorem 5.3) — a big integer of $F+1$ bits — and the finite-scale estimate is the exact rational $F_{m,R}(n)/n$ (Corollary 5.4). No floating-point logarithm is ever required: the logarithm has been eliminated analytically. Complexity: $O(1)$ rational arithmetic on top of §8.1, or $O(F)$ bit operations if the count itself is materialized.

### 8.3 Certified dimension approximation

To approximate $\dim D(m,R)$ within a prescribed tolerance $\varepsilon > 0$: choose $n > |R|/\varepsilon$ and return $F_{m,R}(n)/n$. Theorem 6.1 guarantees the answer is within $\varepsilon$. Complexity: $O(|R|)$ operations, with $n$ appearing only inside a division. (Of course $|R|/m$ is the exact answer here; the point of the procedure is that it is the *empirically computable* one, and its error is certified rather than assumed.)

### 8.4 Realizing a target rational

To construct a theory of dimension $p/q$: output $D(q,\{0,\dots,p-1\})$, i.e. the acceptance predicate "$x_i = 0$ whenever $i \bmod q \ge p$". Membership testing for a length-$n$ string is $O(n)$; enumeration of level $n$ is $O(2^{F_{m,R}(n)} \cdot n)$, optimal since that is the output size.

---

## 9. Interpretation

### 9.1 Dimension as compressibility

Theorem 5.3 gives $|D(m,R)_n| = 2^{F_{m,R}(n)}$, so the accepted strings of length $n$ are in explicit bijection with $\{0,1\}^{F_{m,R}(n)}$: read off the free coordinates and discard the frozen ones. Hence a member of the theory of nominal length $n$ carries only $F_{m,R}(n) \approx dn$ bits of actual content, where $d = \dim$. Three equivalent readings of the same number:

- **Counting:** the theory has about $2^{dn}$ statements of length $n$.
- **Density:** a fraction $d$ of the coordinates are information-bearing.
- **Compression:** membership in the theory is a lossless compression scheme with ratio $d$; statements compress from $n$ bits to $dn$ bits and no further.

Dimension $1$ means incompressible — knowing the string is accepted conveys no information. Dimension $0$ means fully determined — the constraints of the theory specify the statement completely, up to sub-exponentially many choices.

### 9.2 The role of the $\limsup$

The definition uses $\limsup$ rather than $\lim$ because for a general theory the finite estimates need not converge. Consider a theory in which coordinates are free on blocks $[n_k, n_{k+1})$ for even $k$ and frozen for odd $k$, with $n_{k+1}/n_k \to \infty$. Then $\delta_T(n)$ approaches $1$ along the ends of the free blocks and approaches $0$ along the ends of the frozen blocks, and no limit exists. The $\limsup$ still exists in $[0,1]$ and records the most generous asymptotic rate. (A parallel theory of *lower* box dimension via $\liminf$ is available and would record the least generous rate; the two agree exactly for asymptotically regular theories, and Theorem 6.1 shows the periodic density theories are regular.)

### 9.3 The empty-level convention

The choice $\log_2 0 = 0$ is not cosmetic. Without it, $\delta_T(n)$ is undefined at empty levels and monotonicity (Theorem 4.3) cannot even be stated for theories with gaps. With it, an empty level contributes the minimal estimate $0$, which is the semantically correct behaviour: a level with no statements adds no exponential content and can only push the dimension down. Note that this makes $\dim$ insensitive to the difference between "one statement per length" and "no statements at some lengths" — both contribute $0$ — which is the expected coarseness of an exponential-rate invariant.

### 9.4 Comparison with the classical Cantor set

The middle-thirds Cantor set has box dimension $\log 2/\log 3 \approx 0.6309$, an irrational number, obtained by a self-similar scaling construction. The periodic density theories are also Cantor-type subsets of $\{0,1\}^{\mathbb{N}}$ — closed, perfect (when $R \ne \varnothing$), nowhere dense (when $R \ne \{0,\dots,m-1\}$) — but their construction is *coordinatewise* rather than *scaling*: a coordinate is either free or frozen, an all-or-nothing decision at each level. That binary decision is why the achievable dimensions of the periodic family are exactly the rationals with denominator dividing the period. Irrationality is recovered only by breaking periodicity (§10.1).

---

## 10. Extensions and future work

### 10.1 Arbitrary densities and irrational dimensions

Let $S \subseteq \mathbb{N}$ be any set of free coordinates, and let $D(S)$ be the theory accepting strings that vanish off $S$. Exactly as in Theorem 5.3, $|D(S)_n| = 2^{|S \cap [0,n)|}$, so $\delta_{D(S)}(n) = |S \cap [0,n)|/n$ is the *finite-window density* of $S$, and
$$
\dim D(S) \;=\; \overline{\mathrm{d}}(S), \quad \text{the upper asymptotic (natural) density of } S.
$$
Since every real $d \in [0,1]$ is the density of some set of naturals — take $S = \{ i : \lfloor (i+1) d \rfloor > \lfloor i d \rfloor \}$, a Beatty-type set of density exactly $d$ — the full dimension spectrum is all of $[0,1]$. The periodic case of the present paper is the sub-case where $S$ is a union of residue classes and the density is rational; what periodicity buys is the explicit $O(1/n)$ error bound of Theorem 6.1, which for general $S$ has no uniform analogue.

### 10.2 Beyond product theories

All theories analysed here are *products*: acceptance is a conjunction of independent per-coordinate constraints. The general problem is to compute or bound $\dim T$ for theories defined by correlated constraints — for instance, strings accepted by a fixed finite automaton, where $|T_n|$ grows like $\lambda^n$ for $\lambda$ the Perron root of the transition matrix, giving $\dim T = \log_2 \lambda$ (an algebraic number, generally irrational). This suggests a hierarchy: product theories give rationals, regular theories give logarithms of algebraic numbers, and context-free or computably enumerable theories should give strictly larger classes.

### 10.3 Dimension of deductively closed theories

The framework imposes no closure. A natural refinement is to restrict to theories closed under a deduction relation and ask which dimensions survive. Deductive closure creates correlations between coordinates (a proved statement forces its consequences to be present), so the product theories are not deductively closed and the realization theorem does not immediately transfer. Determining the dimension spectrum of deductively closed theories is open.

### 10.4 Dimension as a complexity-theoretic invariant

If $T$ is the set of *yes*-instances of a decision problem encoded in binary, $\dim T$ measures the density of yes-instances on the exponential scale. Sparse languages have dimension $0$; the dimension of a language is invariant under polynomial-time length-preserving reductions up to the distortion those reductions induce on lengths. Making this precise — and asking whether dimension separates natural complexity classes — is a promising direction, connecting the present combinatorics to effective and resource-bounded dimension theory.

### 10.5 Multifractal refinement

Rather than a single exponent, one may weight statements (by proof length, by logical depth, by a probability measure on the theory) and study the resulting multifractal spectrum $f(\alpha)$ of local dimensions. For the periodic density theories with a nonuniform measure on free coordinates, a Legendre-transform computation should give an explicit spectrum, providing a finer invariant than the single number $\dim T$.

---

## 11. Conclusion

We have equipped the space of theories with a numerical size invariant — the box-counting dimension of the associated subset of Cantor space — and determined its behaviour completely on an explicit family. The invariant lies in $[0,1]$, is monotone under inclusion, and attains both endpoints. For a periodic density theory with modulus $m$ and admissible residue set $R$, the dimension is exactly the density $|R|/m$ of information-bearing coordinates, proved via the exact counting law $|D(m,R)_n| = 2^{F_{m,R}(n)}$, the period relation $F_{m,R}(n+m) = F_{m,R}(n) + |R|$, and a two-sided sandwich that squeezes the finite estimates to the density with error at most $|R|/n$. Consequently every rational in $[0,1]$ is realized as a dimension by an explicit construction: the dimension spectrum of truth contains the whole rational unit interval, and the isolated value $1/2$ found earlier is one point among a continuum's worth of dense company.

The proofs are elementary but the framework is not: it converts a vague question — how big is a body of mathematics? — into an exact combinatorial one, with a computable answer, certified error bars at every finite scale, and a clear roadmap (automata, deductive closure, resource bounds, multifractality) for the correlated cases where the answer is not yet known.
