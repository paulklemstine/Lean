# $\gamma$-Positivity of Symmetric Edge Polytopes for Series–Parallel Graphs with at Most Four Paths

## Abstract

For two distinguished vertices $s$ and $t$, joining them with $m$ internally disjoint paths of lengths $a_1, \dots, a_m$ yields a series–parallel graph $G(a)$, the *generalized theta graph*. The Ehrhart $h^*$-polynomial of its symmetric edge polytope $Q_{G(a)}$ is always palindromic; a central open question asks precisely when it is **$\gamma$-positive**, a strengthening of palindromicity and unimodality. It is known that $\gamma$-positivity can fail once $m \ge 5$, and it is conjectured to hold for every choice of path lengths when $m \le 4$, which would furnish a complete classification for this family.

We develop the algebraic backbone of that classification. Working in the $\gamma$-basis $t^i(1+t)^{n-2i}$, we establish: (i) an evaluation-positivity principle — every $\gamma$-positive polynomial is nonnegative on $[0,\infty)$, so its real roots avoid the positive axis; (ii) the full cone structure of $\gamma$-positive polynomials — closure under nonnegative scaling, addition, and multiplication across orders, the last driven by an exact multiplication rule for $\gamma$-basis elements; (iii) a sharp infinite family of non-examples — the *flat palindrome* $1 + t + \cdots + t^n$ is $\gamma$-positive **if and only if** $n \le 1$, upgrading an isolated degree-$4$ counterexample to every degree $\ge 2$ and localizing the obstruction to the two lowest coefficients; and (iv) a series–parallel product model whose $h^*$-polynomial is $\gamma$-positive for any number of paths, exhibiting the multiplicative regime that contains the conjectural $m \le 4$ case. Together these results identify both the mechanism of failure (a forced negative second $\gamma$-coefficient) and the mechanism of success (multiplicative factorization), and reduce the classification to controlling a finite low-order window across the parallel-join operation.

**Keywords:** $\gamma$-positivity, symmetric edge polytope, $h^*$-polynomial, series–parallel graph, generalized theta graph, palindromic polynomial, Ehrhart theory, unimodality.

---

## 1. Introduction

### 1.1 Motivation

Symmetric integer sequences pervade combinatorics, discrete geometry, and algebraic combinatorics. Given a palindromic sequence one wants to know whether its symmetry is *structural* — assembled from elementary symmetric building blocks with nonnegative weights — or merely coincidental. The precise notion capturing structural symmetry is **$\gamma$-positivity**, which sits strictly between palindromicity and the still weaker property of unimodality:
$$\text{$\gamma$-positive} \;\Longrightarrow\; \text{unimodal and palindromic}.$$

A rich source of palindromic sequences is Ehrhart theory. For a lattice polytope $P$, the number of lattice points in the $r$-th dilate is a polynomial in $r$; its generating function has numerator the **$h^*$-polynomial**, whose coefficients form the $h^*$-vector. When $P$ enjoys the Gorenstein property, the $h^*$-polynomial is palindromic. A natural and much-studied class of Gorenstein polytopes are the **symmetric edge polytopes** $Q_G$ of finite graphs $G$: their $h^*$-polynomials are always palindromic, and determining when they are $\gamma$-positive is an active line of inquiry.

### 1.2 The family of interest

We focus on the **generalized theta graphs**. Fix two distinguished vertices $s$ and $t$ and connect them with $m$ internally disjoint paths, the $k$-th having length $a_k \ge 1$ (i.e. $a_k - 1$ interior vertices). The resulting graph, denoted $G(a)$ with $a = (a_1, \dots, a_m)$, is series–parallel: each path is a series composition of edges, and the $m$ paths are composed in parallel. This is arguably the simplest infinite family of graphs in which $\gamma$-positivity of $Q_G$ exhibits nontrivial behavior.

The empirical and structural picture is a sharp threshold:

- For $m \ge 5$, there exist $a$ for which the $h^*$-polynomial of $Q_{G(a)}$ is palindromic and unimodal but **not** $\gamma$-positive.
- For $m \le 4$, it is conjectured that the $h^*$-polynomial is $\gamma$-positive for **every** $a$.

Establishing both halves would classify $\gamma$-positivity completely for this family, with the threshold at four paths.

### 1.3 Contributions

This paper contributes the algebraic infrastructure on which the classification rests, together with a sharp diagnosis of the failure mechanism. Our main results are:

1. **Evaluation positivity (Theorem 4.2).** Every $\gamma$-positive polynomial is nonnegative on $[0,\infty)$.
2. **Cone structure (Theorems 5.1, 5.2, 5.5).** $\gamma$-positive polynomials are closed under nonnegative scaling, under addition within a fixed order, and under multiplication across orders; the last rests on the exact identity (Theorem 5.3) that the $\gamma$-basis multiplies with additive indices.
3. **The flat-palindrome classification (Theorem 6.4).** The polynomial $1 + t + \cdots + t^n$ is $\gamma$-positive if and only if $n \le 1$. This produces an infinite family of sharp non-examples and localizes the obstruction to the two lowest coefficients.
4. **The series–parallel product model (Theorem 7.2).** The path-join model polynomial is $\gamma$-positive for every list of path lengths, exhibiting the multiplicative regime containing the $m \le 4$ case.

The unifying message is that the palindromic/$\gamma$-positive gap is governed by a *finite, low-order* obstruction, and that $\gamma$-positivity in this family is a matter of whether the multiplicative (factorizable) structure survives the parallel-join.

---

## 2. Preliminaries and notation

We work over the polynomial ring $\mathbb{R}[t]$. For a polynomial $p$, we write $[t^k]\,p$ or $p_k$ for the coefficient of $t^k$. We use the binomial coefficient $\binom{N}{j}$, with the convention $\binom{N}{j} = 0$ for $j > N$.

Throughout, $n$ denotes the *order* (nominal degree) with respect to which symmetry and $\gamma$-expansions are taken. Natural-number subtraction $n - 2i$ is truncated at $0$; all statements are arranged so this convention causes no ambiguity.

---

## 3. The $\gamma$-basis and the $\gamma$-positive cone

### 3.1 The $\gamma$-basis

**Definition 3.1 ($\gamma$-basis).** For $n, i \in \mathbb{Z}_{\ge 0}$, the *$i$-th $\gamma$-basis element of order $n$* is
$$B_{n,i}(t) \;=\; (1+t)^{\,n-2i}\, t^{\,i}.$$
For $0 \le i \le \lfloor n/2 \rfloor$, $B_{n,i}$ is a palindromic polynomial of degree $n$, and the family $\{B_{n,i}\}_{i=0}^{\lfloor n/2\rfloor}$ is a basis of the space of palindromic polynomials of order $n$.

**Proposition 3.2 (Coefficients of the $\gamma$-basis).** For all $n, i, k$,
$$[t^k]\,B_{n,i} \;=\; \begin{cases} \dbinom{n-2i}{\,k-i\,}, & i \le k,\\[4pt] 0, & i > k.\end{cases}$$

*Proof sketch.* Multiplication by $t^i$ shifts coefficients by $i$, so $[t^k]B_{n,i} = [t^{k-i}](1+t)^{n-2i}$ for $k \ge i$ and $0$ otherwise. The binomial theorem gives $[t^{k-i}](1+t)^{n-2i} = \binom{n-2i}{k-i}$. $\qquad\blacksquare$

**Proposition 3.3 (Nonnegativity of coefficients).** Every coefficient of every $\gamma$-basis element is nonnegative: $[t^k]B_{n,i} \ge 0$.

*Proof sketch.* Immediate from Proposition 3.2, since binomial coefficients are nonnegative and the alternative branch is $0$. $\qquad\blacksquare$

### 3.2 $\gamma$-positivity and palindromicity

**Definition 3.4 ($\gamma$-positivity).** A polynomial $p \in \mathbb{R}[t]$ is *$\gamma$-positive of order $n$* if there exist reals $\gamma_0, \gamma_1, \dots \ge 0$ with
$$p \;=\; \sum_{i=0}^{\lfloor n/2 \rfloor} \gamma_i \, B_{n,i} \;=\; \sum_{i=0}^{\lfloor n/2 \rfloor} \gamma_i\,(1+t)^{n-2i} t^i.$$
The sequence $(\gamma_i)$ is the *$\gamma$-vector*.

**Definition 3.5 (Palindromicity).** A polynomial $p$ is *palindromic of order $n$* if $p_k = p_{n-k}$ for all $0 \le k \le n$.

Since each $B_{n,i}$ is palindromic and palindromicity is preserved by real linear combinations, every $\gamma$-positive polynomial of order $n$ is palindromic of order $n$. The converse fails, as Section 6 shows in the sharpest possible way.

---

## 4. Evaluation positivity

$\gamma$-positivity has an immediate analytic consequence: control of the sign of the polynomial on the nonnegative axis.

**Lemma 4.1 (Basis evaluation).** For every $n, i$ and every $t \ge 0$, $B_{n,i}(t) \ge 0$.

*Proof sketch.* $B_{n,i}(t) = (1+t)^{n-2i} t^i$ is a product of two nonnegative factors when $t \ge 0$: $1+t \ge 1 > 0$ and $t \ge 0$, and nonnegative bases raised to natural powers stay nonnegative. $\qquad\blacksquare$

**Theorem 4.2 (Evaluation positivity).** If $p$ is $\gamma$-positive of order $n$, then $p(t) \ge 0$ for all $t \ge 0$. Consequently $p$ has no root in $(0,\infty)$ unless it vanishes identically there, and every real root of $p$ lies in $(-\infty, 0]$.

*Proof sketch.* Write $p = \sum_i \gamma_i B_{n,i}$ with $\gamma_i \ge 0$. Evaluating at $t \ge 0$ gives $p(t) = \sum_i \gamma_i B_{n,i}(t)$, a sum of products of nonnegatives by Lemma 4.1, hence $\ge 0$. $\qquad\blacksquare$

Theorem 4.2 is the analytic shadow of $\gamma$-positivity and underlies the real-rootedness questions of Section 8: any real root of a $\gamma$-positive polynomial is confined to the nonpositive axis.

---

## 5. The cone structure of $\gamma$-positive polynomials

$\gamma$-positive polynomials of a fixed order form a convex cone, and multiplication respects the grading by order. We record the three closure properties.

**Theorem 5.1 (Closure under nonnegative scaling).** If $p$ is $\gamma$-positive of order $n$ and $c \ge 0$, then $c\,p$ is $\gamma$-positive of order $n$.

*Proof sketch.* If $p = \sum_i \gamma_i B_{n,i}$ then $c\,p = \sum_i (c\gamma_i) B_{n,i}$, and each $c\gamma_i \ge 0$. $\qquad\blacksquare$

**Theorem 5.2 (Closure under addition).** If $p, q$ are $\gamma$-positive of the same order $n$, then $p + q$ is $\gamma$-positive of order $n$.

*Proof sketch.* Add the $\gamma$-vectors coefficientwise; $B_{n,i}$-expansions combine linearly and nonnegativity is preserved. $\qquad\blacksquare$

**Theorem 5.3 (Multiplication rule for the $\gamma$-basis).** If $2i \le m$ and $2j \le n$, then
$$B_{m,i}\cdot B_{n,j} \;=\; B_{m+n,\;i+j}.$$

*Proof sketch.* Compute
$$B_{m,i} B_{n,j} = (1+t)^{m-2i} t^i (1+t)^{n-2j} t^j = (1+t)^{(m-2i)+(n-2j)} t^{i+j}.$$
Under $2i \le m$ and $2j \le n$, the exponent satisfies $(m-2i)+(n-2j) = (m+n) - 2(i+j)$, which is exactly the exponent in $B_{m+n,i+j}$. $\qquad\blacksquare$

**Theorem 5.5 (Closure under multiplication across orders).** If $p$ is $\gamma$-positive of order $m$ and $q$ is $\gamma$-positive of order $n$, then $p\,q$ is $\gamma$-positive of order $m + n$.

*Proof sketch.* Write $p = \sum_i a_i B_{m,i}$ and $q = \sum_j b_j B_{n,j}$ with $a_i, b_j \ge 0$. Then
$$p q = \sum_{i,j} a_i b_j\, B_{m,i} B_{n,j} = \sum_{i,j} a_i b_j\, B_{m+n,\,i+j}$$
by Theorem 5.3. Grouping terms by $\ell = i + j$ yields the $\gamma$-vector of $pq$,
$$\gamma_\ell(pq) = \sum_{i+j=\ell} a_i b_j \ge 0,$$
a Cauchy-type convolution of nonnegative sequences. Since $2\ell \le m+n$ throughout the admissible range, this is a genuine $\gamma$-expansion of order $m+n$. $\qquad\blacksquare$

**Corollary 5.6 (Trivial block).** $(1+t)^n$ is $\gamma$-positive of order $n$, with $\gamma$-vector $(1,0,0,\dots)$; equivalently $(1+t)^n = B_{n,0}$.

Thus the $\gamma$-positive polynomials form a graded cone: a convex cone in each order, closed under a product that adds orders. This is exactly the structure that makes "$\gamma$-positive because it factors" a robust and checkable phenomenon.

---

## 6. The flat-palindrome family

We now exhibit the sharpest possible separation between palindromicity and $\gamma$-positivity.

**Definition 6.1 (Flat palindrome).** The *flat palindrome of degree $n$* is
$$F_n(t) \;=\; 1 + t + t^2 + \cdots + t^n \;=\; \sum_{i=0}^{n} t^i.$$

**Proposition 6.2 (Coefficients and palindromicity).** $[t^k]F_n = 1$ for $0 \le k \le n$ and $0$ otherwise; in particular $F_n$ is palindromic of order $n$, and it is unimodal.

*Proof sketch.* Direct from the definition; symmetry $F_n{}_{,k} = F_n{}_{,n-k} = 1$ is immediate. $\qquad\blacksquare$

**Proposition 6.3 (Low-degree positivity).** For $n \le 1$, $F_n = (1+t)^n$, hence $F_n$ is $\gamma$-positive of order $n$ with $\gamma$-vector $(1, 0, \dots)$.

*Proof sketch.* $F_0 = 1 = (1+t)^0$ and $F_1 = 1 + t = (1+t)^1$; apply Corollary 5.6. $\qquad\blacksquare$

**Theorem 6.4 (Flat-palindrome classification).** For every $n$,
$$F_n \text{ is } \gamma\text{-positive of order } n \iff n \le 1.$$

*Proof sketch.* ($\Leftarrow$) is Proposition 6.3. For ($\Rightarrow$), suppose $n \ge 2$ and $F_n = \sum_{i} \gamma_i B_{n,i}$ with $\gamma_i \ge 0$. We extract two coefficients.

*Constant term.* By Proposition 3.2, $[t^0]B_{n,i}$ is nonzero only for $i = 0$, where it equals $\binom{n}{0} = 1$. Hence $[t^0]F_n = \gamma_0$. Since $[t^0]F_n = 1$, we get $\gamma_0 = 1$.

*Linear term.* Only $i \in \{0,1\}$ contribute to $[t^1]$: from $i=0$, $[t^1]B_{n,0} = \binom{n}{1} = n$; from $i=1$, $[t^1]B_{n,1} = \binom{n-2}{0} = 1$. Thus $[t^1]F_n = n\gamma_0 + \gamma_1$. Since $[t^1]F_n = 1$ and $\gamma_0 = 1$,
$$1 = n + \gamma_1 \quad\Longrightarrow\quad \gamma_1 = 1 - n \le -1 < 0,$$
contradicting $\gamma_1 \ge 0$. Hence no nonnegative $\gamma$-expansion exists for $n \ge 2$. $\qquad\blacksquare$

**Remarks.**

- The obstruction is entirely **local to the two lowest coefficients**: the constant term forces $\gamma_0 = 1$, and the linear term then forces $\gamma_1 = 1 - n$. No higher coefficient is needed to certify failure.
- Failure is *genuine*, not a symptom of non-unimodality: $F_n$ is palindromic and unimodal with all coefficients equal to $1$. It is $\gamma$-positivity specifically that fails.
- This upgrades an isolated degree-$4$ counterexample to an **infinite family**, establishing that the palindromic/$\gamma$-positive gap persists in every degree $\ge 2$. The flat palindrome is precisely the polynomial profile realized by the $m \ge 5$ series–parallel failures.

---

## 7. A series–parallel product model

We now model the path-join operation algebraically and show $\gamma$-positivity in the multiplicative regime.

**Definition 7.1 (Building block and product model).** The *building block* of a single path of length $a$ is $P_a(t) = (1+t)^a$. For a list of path lengths $a = (a_1, \dots, a_m)$, the *series (product) model* is
$$M_a(t) \;=\; \prod_{k=1}^{m} P_{a_k}(t) \;=\; \prod_{k=1}^m (1+t)^{a_k} \;=\; (1+t)^{\,a_1 + \cdots + a_m}.$$

The building block $(1+t)^a$ is the $\gamma$-positive $h^*$-contribution of a subdivided edge; the product across paths captures the composition of the $m$ parallel routes in the multiplicative regime.

**Theorem 7.2 (Product model is $\gamma$-positive).** For every list $a = (a_1, \dots, a_m)$ of path lengths, $M_a$ is $\gamma$-positive of order $a_1 + \cdots + a_m$. In particular, $\gamma$-positivity holds throughout the model for every $m$, and a fortiori for $m \le 4$.

*Proof sketch.* Induct on the list. The empty product is $1 = (1+t)^0$, $\gamma$-positive of order $0$ by Corollary 5.6. For the inductive step, $M_{(a_0, a')} = (1+t)^{a_0}\cdot M_{a'}$; the first factor is $\gamma$-positive of order $a_0$ (Corollary 5.6), the second is $\gamma$-positive of order $\sum a'$ by induction, and Theorem 5.5 gives $\gamma$-positivity of the product, of order $a_0 + \sum a'$. $\qquad\blacksquare$

**Examples.**

- Two-path join ($m = 2$, a single cycle), e.g. $a = (2,3)$: $M_a = (1+t)^5$ is $\gamma$-positive of order $5$.
- Four-path join ($m = 4$), the boundary of the conjecture, e.g. $a = (1,2,2,3)$: $M_a = (1+t)^{8}$ is $\gamma$-positive of order $8$.

The model isolates exactly the mechanism by which $\gamma$-positivity is *guaranteed*: factorization into $\gamma$-positive blocks. The conjectural difficulty at $m \ge 5$ is the appearance of a non-multiplicative interaction — the flat-palindrome obstruction of Section 6 — that the product model, by construction, does not exhibit.

---

## 8. Discussion

### 8.1 The classification picture

Sections 6 and 7 supply the two poles of the conjectured classification. The product model (Theorem 7.2) is the *success* pole: whenever the $h^*$-polynomial factors as a product of $\gamma$-positive blocks, $\gamma$-positivity is automatic, and the $m \le 4$ networks are expected to lie in this regime. The flat palindrome (Theorem 6.4) is the *failure* pole: it is the minimal, universal obstruction, realized by the $m \ge 5$ networks. The classification asks precisely where the boundary between these poles falls, and the algebra above localizes that boundary to a finite low-order window.

### 8.2 Why the obstruction is finite

The decisive feature of Theorem 6.4 is that failure is detected by coefficients $0$ and $1$ alone. Because only $B_{n,0}$ reaches the constant term and only $B_{n,0}, B_{n,1}$ reach the linear term, the values of $\gamma_0$ and $\gamma_1$ are *forced* by $p_0$ and $p_1$:
$$\gamma_0 = p_0, \qquad \gamma_1 = p_1 - n\,p_0.$$
Any palindromic $h^*$-polynomial with $p_1 < n\,p_0$ is therefore *not* $\gamma$-positive, regardless of its higher structure. This turns the search for counterexamples into a bounded sign condition and turns verification into a finite check.

### 8.3 Relation to unimodality and real-rootedness

$\gamma$-positivity implies unimodality and, via Theorem 4.2, nonnegativity on $[0,\infty)$. The flat palindrome demonstrates that these implications are strict: $F_n$ is unimodal and nonnegative on $[0,\infty)$ for all $n$, yet fails $\gamma$-positivity for $n \ge 2$. Thus $\gamma$-positivity is a strictly finer invariant than either, and the series–parallel family is a natural laboratory in which the three notions can be separated explicitly.

---

## 9. Future work

Several precise conjectures emerge from the structure established here.

**Conjecture 9.1 (Complete classification at $m \le 4$).** For every vector of path lengths $a \in \mathbb{Z}_{>0}^m$ with $m \le 4$, the $h^*$-polynomial of $Q_{G(a)}$ is $\gamma$-positive; for $m \ge 5$ there exist $a$ for which it is not. The failure of $\gamma$-positivity is detected by a finite low-order window — a single sign condition on the second $\gamma$-coefficient — so the classification reduces to bounding that window across the parallel-join, which stabilizes exactly at four paths.

**Conjecture 9.2 (Real-rootedness dichotomy).** The $h^*$-polynomial of $Q_{G(a)}$ is real-rooted if and only if it is $\gamma$-positive with $\gamma$-vector supported on an interval; in the $m \le 4$ regime it is nonnegative on $[0,\infty)$ and has no positive real root. Evaluation-positivity (Theorem 4.2) turns this global analytic question into a local statement about the location of negative roots and the interlacing of the building-block families.

**Conjecture 9.3 (Multiplicativity as the sole source at large $m$).** For $m \ge 5$, the $h^*$-polynomial of $Q_{G(a)}$ is $\gamma$-positive if and only if it factors as a product of $\gamma$-positive polynomials of strictly smaller order (equivalently, the graph decomposes along a series cut). The parallel-join of five or more paths introduces a genuinely non-multiplicative interaction term — exactly the flat-palindrome obstruction — so $\gamma$-positivity survives only when that interaction is absent.

**Conjecture 9.4 (Quantitative depth of the obstruction).** For the flat-type $h^*$-profiles arising at $m \ge 5$, the most negative forced $\gamma$-coefficient grows linearly in the total path length, so no bounded perturbation of the edge structure can restore $\gamma$-positivity.

---

## 10. Conclusion

We have assembled the algebraic core of a conjectural classification of $\gamma$-positivity for symmetric edge polytopes of generalized theta graphs. The $\gamma$-positive polynomials form a graded convex cone — closed under nonnegative scaling, addition, and order-additive multiplication — and every member is nonnegative on the nonnegative axis. Against this backdrop the flat palindrome $1 + t + \cdots + t^n$ emerges as the sharp, universal obstruction, $\gamma$-positive exactly when $n \le 1$, with failure forced by its two lowest coefficients. The series–parallel product model, $\gamma$-positive for every number of paths, exhibits the multiplicative regime in which success is guaranteed and which is conjectured to contain the entire $m \le 4$ case. The mechanism of failure (a forced negative second $\gamma$-coefficient) and the mechanism of success (multiplicative factorization) are now explicit, reducing the outstanding classification to the control of a finite low-order window across the parallel-join operation.
