# Finite Certificates for Universal Polynomial Identities: Degree-Graded Exactness, Optimal Node Sets, and Support-Adapted Unisolvence

**Author:** Aristotle

**Date:** 2026-09-02

---

## Abstract

We develop a complete theory of finite evaluation certificates for polynomial identities that are valid in *every* commutative ring. Working with a reflective calculus of formal polynomial expressions in $n$ chart coordinates with integer constants, we prove a degree-graded exactness theorem: two expressions of syntactic total degree at most $d$ that agree at the $(d+1)^n$ integer points of the box grid $\{0,\dots,d\}^n$ denote the same element of $\mathbb{Z}[x_1,\dots,x_n]$, and therefore define the same function on every commutative ring. This generalises to arbitrary degree the classical ad hoc arguments for degrees $1$, $2$, $3$, whose linear-constraint extraction is recovered here as the degree-one instance. We then prove that the finite check is not merely sound but **complete**: for expressions of degree at most $d$, agreement on the grid is *equivalent* to validity over the class of all commutative rings, so that this validity is a decidable predicate of the two syntax trees; the ring $\mathbb{Z}$ alone is a complete test object.

We then determine the *optimal* certificates. The grid size $d+1$ per coordinate cannot be reduced to $d$; more strongly, no set of at most $d$ points of any integral domain determines polynomials of total degree $\le d$. A linear-algebraic dimension count shows every uniqueness set for total degree $\le d$ has at least $\binom{n+d}{n}$ points. We prove that the **simplex lattice** $S(n,d)=\{a\in\mathbb{N}^n : \sum_i a_i \le d\}$ is a uniqueness set of exactly $\binom{n+d}{n}$ points and hence of minimum cardinality, strictly smaller than the box grid whenever $n\ge 2$, $d\ge 1$; the result holds over a domain precisely when $d$ is below the characteristic, with the Artin–Schreier polynomial $x_1^{p}-x_1$ witnessing failure at the threshold.

Finally we prove the support-adapted form, which subsumes both extremes: for any **downset** (lower set) $D$ of exponent vectors, a polynomial supported in $D$ that vanishes at the $|D|$ lattice nodes of $D$ is zero, evaluation at those nodes is a linear isomorphism onto functions on the nodes (existence and uniqueness of downset interpolation), and $|D|$ is minimal. Weighted-degree sublevel sets are downsets, yielding quasi-homogeneous certificates, and we exhibit a downset contained in no weighted sublevel set that avoids a given exponent, showing the support-adapted theory is strictly finer. Worked identities include the binomial cube (16 box points, 10 simplex points), the quartic $(a+b)^2(a-b)^2=(a^2-b^2)^2$ (25 points), the symmetric factorisation $a^3+b^3+c^3-3abc=(a+b+c)(a^2+b^2+c^2-ab-bc-ca)$ (64 box, 20 simplex), inclusion–exclusion (4 Boolean-cube points), and the quasi-homogeneous $(a^2+b)(a^2-b)=a^4-b^2$ (9 weighted points versus 15 and 25).

**Keywords:** polynomial identity testing, unisolvence, simplex lattice, downset, Newton polytope, multivariate interpolation, universal algebra, reflective calculus.

---

## 1. Introduction

### 1.1 The question

Let $R$ be a commutative ring and consider an algebraic identity such as
$$(a+b)^3 = a^3 + 3a^2 b + 3ab^2 + b^3.$$
Two facts are worth separating. First, this is a statement about *every* commutative ring simultaneously — matrices over a field with commuting entries, the integers mod $n$, polynomial rings, function rings, and so on. Second, it can be checked at finitely many *integers*.

The bridge between those two facts is the object of this paper. An expression built from variables, integer constants, addition, negation and multiplication has a canonical *generic value*: the polynomial in $\mathbb{Z}[x_1,\dots,x_n]$ obtained by leaving the variables uninterpreted. Substituting into a ring $R$ factors through the unique ring homomorphism $\mathbb{Z}\to R$, so two expressions with the same generic value define the same function on every $R$. The finite check therefore has to accomplish exactly one thing: pin down a single element of $\mathbb{Z}[x_1,\dots,x_n]$.

Two questions follow.

**(Sufficiency.)** Which finite sets of evaluation points suffice, as a function of the syntactic shape of the expressions?

**(Economy.)** How few points can suffice? Is there an optimal node set?

We answer both, in a graded family of increasingly refined shape invariants: total degree, per-variable degree, weighted degree, and finally arbitrary downsets of exponents.

### 1.2 Contributions

1. **Degree-graded exactness** (Theorem 3.4). Two expressions of syntactic total degree $\le d$ agreeing on $\{0,\dots,d\}^n \subseteq \mathbb{Z}^n$ define the same function on every commutative ring. Degrees $1$, $2$, $3$ are the classical charts $\{0,1\}$, $\{0,1,2\}$, $\{0,1,2,3\}$; the degree-one instance *is* the linear independence of the chart coordinates together with the constant $1$ (Proposition 3.7), so the traditional constraint-extraction step becomes a corollary rather than an input.
2. **Sharpness** (Theorem 3.6). For every $d$ there are degree-$d$ expressions agreeing on a grid of size $d$ but not equal.
3. **Completeness and decidability** (Theorems 4.2, 4.4, 4.5). Agreement on the grid $\iff$ equality of generic values $\iff$ validity in every commutative ring. Validity is decidable; $\mathbb{Z}$ is a complete test ring.
4. **No small uniqueness set** (Theorem 5.1) and the **dimension lower bound** (Theorem 5.3): every uniqueness set for total degree $\le d$ has at least $\binom{n+d}{n}$ points.
5. **Simplex unisolvence and optimality** (Theorems 6.2, 6.5, 6.6) with the **exact characteristic threshold** (Theorem 6.4).
6. **Per-variable refinement** (Theorems 7.1, 7.2): box grids and the Boolean cube for multilinear identities.
7. **Interpolation** (Theorems 8.1, 8.2): existence and uniqueness on a box grid; the dimension formula $(b+1)^n$.
8. **Downset unisolvence** (Theorems 9.2, 9.4, 9.5, 9.6): the support-adapted theorem, its converse, minimality, and the strictness of downsets over weighted sublevel sets (Proposition 9.8).
9. **Worked certificates** (Section 10) with explicit point counts.

### 1.3 Related ideas

The one-variable root bound ("a nonzero degree-$d$ polynomial has at most $d$ roots") is the seed of everything here; the multivariate grid statement is a standard combinatorial-nullstellensatz-adjacent fact. Simplex-lattice unisolvence is the classical basis of Lagrange finite elements on simplices. Downset (or "lower set") interpolation appears in sparse-grid and polynomial-chaos approximation theory. What is new here is the organisation: a single graded framework in which *sufficiency, sharpness, minimality* and *completeness* are all established for each shape invariant, and in which every certificate transports automatically from a finite integer computation to a universally quantified statement about all commutative rings.

---

## 2. The reflective chart calculus

### 2.1 Syntax

**Definition 2.1 (Expressions).** For $n\in\mathbb{N}$, the set $\mathcal{E}_n$ of *chart expressions* in $n$ variables is generated inductively by:
- $\mathrm{var}(i)$ for $i \in \{1,\dots,n\}$;
- $\mathrm{const}(c)$ for $c\in\mathbb{Z}$;
- $e_1 + e_2$, $e_1 \cdot e_2$, $-e$ for $e, e_1, e_2 \in \mathcal{E}_n$.

Equality of expressions is *syntactic*: $\mathcal{E}_n$ is a free structure, a set of finite trees. This is the point of a *reflective* presentation: shape invariants are computed by structural recursion on the tree, before any algebra happens.

### 2.2 Semantics

**Definition 2.2 (Evaluation).** For a commutative ring $R$ and $x\in R^n$, define $\mathrm{ev}_x : \mathcal{E}_n \to R$ by
$$\mathrm{ev}_x(\mathrm{var}(i)) = x_i,\quad \mathrm{ev}_x(\mathrm{const}(c)) = c\cdot 1_R,$$
$$\mathrm{ev}_x(e_1+e_2)=\mathrm{ev}_x(e_1)+\mathrm{ev}_x(e_2),\quad \mathrm{ev}_x(e_1 e_2)=\mathrm{ev}_x(e_1)\mathrm{ev}_x(e_2),\quad \mathrm{ev}_x(-e)=-\mathrm{ev}_x(e).$$

**Definition 2.3 (Generic value).** The *denotation* $\llbracket e\rrbracket \in \mathbb{Z}[x_1,\dots,x_n]$ is defined by the same recursion with $\mathrm{var}(i)\mapsto x_i$ and $\mathrm{const}(c)\mapsto c$.

**Lemma 2.4 (Soundness of reflection).** For every commutative ring $R$ and $x\in R^n$,
$$\mathrm{ev}_x(e) = \big(\text{image of } \llbracket e\rrbracket \text{ under } \mathbb{Z}[x]\to R[x] \big)\text{ evaluated at } x .$$
In particular $\mathrm{ev}_x(e) = \llbracket e\rrbracket(x)$ when $R=\mathbb{Z}$.

*Proof.* Structural induction; each clause is the statement that base change along $\mathbb{Z}\to R$ is a ring homomorphism commuting with evaluation. $\square$

**Corollary 2.5 (Transfer).** If $\llbracket e_1\rrbracket = \llbracket e_2\rrbracket$ then $\mathrm{ev}_x(e_1) = \mathrm{ev}_x(e_2)$ for every commutative ring $R$ and every $x\in R^n$.

This corollary is the whole point: *all* universality statements below are obtained by proving equality of generic values and then invoking it.

### 2.3 Shape invariants

**Definition 2.6 (Syntactic total degree).**
$$\deg(\mathrm{var}(i)) = 1,\quad \deg(\mathrm{const}(c)) = 0,$$
$$\deg(e_1+e_2) = \max(\deg e_1,\deg e_2),\quad \deg(e_1 e_2) = \deg e_1 + \deg e_2,\quad \deg(-e) = \deg e.$$

**Definition 2.7 (Syntactic multidegree).** $\deg_i(e)$ is defined by the same recursion with $\deg_i(\mathrm{var}(j)) = [\,i = j\,]$.

**Definition 2.8 (Syntactic weighted degree).** For weights $w\in\mathbb{N}^n$, $\deg_w(e)$ is defined by the same recursion with $\deg_w(\mathrm{var}(i)) = w_i$.

Note that these are *upper bounds*, computed without cancellation: $\deg((x-x)\cdot x^{10}) = 11$ even though the denotation is $0$. That is harmless; all theorems are of the form "if the syntactic bound is $\le d$ then a check of size determined by $d$ suffices", and an overestimate only costs points.

**Lemma 2.9 (The bounds are valid).** $\deg\llbracket e\rrbracket \le \deg e$; $\deg_{x_i}\llbracket e\rrbracket \le \deg_i e$; and every exponent vector $a$ in the support of $\llbracket e\rrbracket$ satisfies $\sum_i w_i a_i \le \deg_w e$.

*Proof.* Structural induction, using $\deg(p+q)\le\max(\deg p,\deg q)$ and $\deg(pq)\le \deg p + \deg q$ for total, per-variable and weighted degree alike (the weighted degree of a monomial is additive under multiplication and the support of a sum is contained in the union of supports). $\square$

---

## 3. Degree-graded exactness

### 3.1 The rigidity lemma

**Theorem 3.1 (Grid rigidity for polynomials).** Let $R$ be an integral domain, $\sigma$ a finite index set, $d\in\mathbb{N}$, and $p,q \in R[x_i : i\in\sigma]$ with $\deg p, \deg q \le d$ (total degree). Let $S\subseteq R$ be finite with $|S| > d$. If $p(x) = q(x)$ for all $x \in S^\sigma$, then $p = q$.

*Proof sketch.* Put $r = p-q$; then $\deg r \le d$, hence $\deg_{x_i} r \le d < |S|$ for every $i$, and $r$ vanishes on $S^\sigma$. Induct on the number of variables: fixing all but one coordinate at values in $S$ yields a univariate polynomial of degree $< |S|$ with $|S|$ distinct roots in a domain, hence zero. Since this holds for every choice of the remaining coordinates in $S$, the coefficients (as polynomials in the remaining variables) themselves vanish on the smaller grid, and induction applies. Thus $r=0$. $\square$

The domain hypothesis is essential: over $\mathbb{Z}/4$, the polynomial $2x^2+2x$ vanishes identically.

### 3.2 The standard chart

**Definition 3.2.** $\mathrm{Grid}(d) = \{0,1,\dots,d\}\subseteq\mathbb{Z}$, of cardinality $d+1$; the *chart grid* is $\mathrm{Grid}(d)^n$, of cardinality $(d+1)^n$.

**Theorem 3.3 (Grid certificate forces equality of generic values).** Let $e_1,e_2\in\mathcal{E}_n$ with $\deg e_1, \deg e_2 \le d$, and let $S\subseteq\mathbb{Z}$ be finite with $|S| > d$. If $\mathrm{ev}_x(e_1) = \mathrm{ev}_x(e_2)$ for all $x\in S^n$, then $\llbracket e_1\rrbracket = \llbracket e_2\rrbracket$.

*Proof.* By Lemma 2.9 the denotations have total degree $\le d$; by Lemma 2.4 their values at integer points are the expression evaluations; apply Theorem 3.1 with $R=\mathbb{Z}$. $\square$

**Theorem 3.4 (Degree-graded exactness).** Let $e_1, e_2 \in \mathcal{E}_n$ with $\deg e_1,\deg e_2 \le d$. If
$$\mathrm{ev}_x(e_1) = \mathrm{ev}_x(e_2) \quad\text{for all } x \in \{0,\dots,d\}^n\subseteq\mathbb{Z}^n,$$
then for **every** commutative ring $R$ and every $x\in R^n$, $\mathrm{ev}_x(e_1) = \mathrm{ev}_x(e_2)$.

*Proof.* Theorem 3.3 with $S=\mathrm{Grid}(d)$ ($|S| = d+1 > d$), then Corollary 2.5. $\square$

**Corollary 3.5 (Low degrees).** Degree $\le 1$ needs $\{0,1\}^n$; degree $\le 2$ needs $\{0,1,2\}^n$; degree $\le 3$ needs $\{0,1,2,3\}^n$.

### 3.3 Sharpness

**Theorem 3.6 (The grid bound is sharp).** For every $d\in\mathbb{N}$ there exist $e_1,e_2 \in \mathcal{E}_1$ with $\deg e_1, \deg e_2 \le d$ such that $\mathrm{ev}_x(e_1)=\mathrm{ev}_x(e_2)$ for all $x$ in the $d$-element grid $\{0,\dots,d-1\}$, yet $\mathrm{ev}_x(e_1)\ne\mathrm{ev}_x(e_2)$ for some integer $x$.

*Proof.* Take $e_1 = \prod_{k=0}^{d-1}(x - k)$, built as an expression by the recursion $e^{(0)} = 1$, $e^{(k+1)} = e^{(k)}\cdot(x + (-k))$, and $e_2 = 0$. Then $\deg e_1 = d$, $e_1$ vanishes on $\{0,\dots,d-1\}$ (one factor is zero at each point), and $\mathrm{ev}_d(e_1) = d! \ne 0$. $\square$

So the hypothesis $|S| > d$ in Theorem 3.3 cannot be weakened to $|S|\ge d$.

### 3.4 The classical constraint extraction

**Proposition 3.7 (Linear independence of the chart coordinates).** Let $R$ be a commutative ring, $c_0\in R$ and $c\in R^n$. If
$$c_0 + \sum_{i=1}^n c_i x_i = 0 \quad\text{for all } x\in\{0,1\}^n\subseteq R^n,$$
then $c_0 = 0$ and $c_i = 0$ for all $i$.

*Proof.* Substituting $x=0$ gives $c_0=0$; substituting the $i$-th standard basis vector gives $c_0 + c_i = 0$, hence $c_i = 0$. $\square$

This is the coefficient form of the degree-one instance of Theorem 3.4. In the traditional treatment of degree $3$, one *assumes* such independence and extracts three linear constraints from it. Here it is derived, and the general graded theorem makes the recursion uniform in $d$.

---

## 4. Completeness, decidability, and test objects

Theorem 3.4 says the finite check is *sufficient*. We now show it is also *necessary*, closing the loop.

**Definition 4.1 (Grid certificate).** For $d\in\mathbb{N}$ and $e_1,e_2\in\mathcal{E}_n$, write $\mathrm{GridCert}(d;e_1,e_2)$ for the (finitely checkable) statement
$$\forall x \in \{0,\dots,d\}^n : \mathrm{ev}_x(e_1) = \mathrm{ev}_x(e_2).$$

**Theorem 4.2 (Soundness and completeness).** If $\deg e_1,\deg e_2\le d$ then
$$\mathrm{GridCert}(d;e_1,e_2) \iff \llbracket e_1\rrbracket = \llbracket e_2\rrbracket .$$

*Proof.* ($\Rightarrow$) Theorem 3.3. ($\Leftarrow$) Corollary 2.5 applied at $R=\mathbb{Z}$. $\square$

**Theorem 4.3 (The free ring is a complete test object).** For all $e_1,e_2\in\mathcal{E}_n$,
$$\big(\forall R \text{ commutative}, \forall x\in R^n:\ \mathrm{ev}_x(e_1)=\mathrm{ev}_x(e_2)\big) \iff \llbracket e_1\rrbracket = \llbracket e_2\rrbracket .$$

*Proof.* ($\Leftarrow$) is Corollary 2.5. ($\Rightarrow$) Take $R=\mathbb{Z}[x_1,\dots,x_n]$ and $x_i$ the generators; evaluation at the generators returns the denotation itself (an immediate structural induction), so the hypothesis reads $\llbracket e_1\rrbracket = \llbracket e_2\rrbracket$. $\square$

**Theorem 4.4 (The main bridge).** If $\deg e_1,\deg e_2 \le d$ then
$$\mathrm{GridCert}(d;e_1,e_2) \iff \forall R\ \text{commutative},\ \forall x\in R^n:\ \mathrm{ev}_x(e_1)=\mathrm{ev}_x(e_2).$$

*Proof.* Compose Theorems 4.2 and 4.3. $\square$

**Theorem 4.5 (Decidability).** Validity of an identity of the chart calculus over the class of all commutative rings is a decidable predicate of the two syntax trees: run $\mathrm{GridCert}(\max(\deg e_1,\deg e_2); e_1,e_2)$.

*Proof.* The certificate is a conjunction over a finite explicit set of integer tuples of equalities of integers, hence decidable; Theorem 4.4 identifies it with the predicate in question. $\square$

**Theorem 4.6 ($\mathbb{Z}$ is a test ring).** If $\mathrm{ev}_x(e_1)=\mathrm{ev}_x(e_2)$ for all $x\in\mathbb{Z}^n$, then the identity holds in every commutative ring — with no degree hypothesis.

*Proof.* Two polynomials over an infinite integral domain agreeing as functions on all of $\mathbb{Z}^n$ are equal; then Corollary 2.5. $\square$

**Corollary 4.7.** For $\deg e_1,\deg e_2 \le d$: validity over $\mathbb{Z}$ (infinitely many points) $\iff$ $\mathrm{GridCert}(d;e_1,e_2)$ (finitely many). The infinite test collapses to a finite one exactly at the degree bound.

---

## 5. Lower bounds: how few points can possibly work

**Definition 5.0.** A finite set $T\subseteq R^n$ is a **uniqueness set for total degree $\le d$** if any two polynomials $p,q$ over $R$ with $\deg p,\deg q\le d$ and $p|_T = q|_T$ satisfy $p=q$; equivalently (by linearity, over a field) no nonzero polynomial of total degree $\le d$ vanishes on $T$.

**Theorem 5.1 (No small uniqueness set).** Let $R$ be an integral domain, $n\ge 1$, $d\in\mathbb{N}$, and $T\subseteq R^n$ finite with $|T|\le d$. Then there is a nonzero polynomial $p$ over $R$ with $\deg p \le d$ vanishing on all of $T$. Consequently no set of at most $d$ points — however cleverly chosen, grid or not — is a uniqueness set for total degree $\le d$.

*Proof.* Put
$$p = \prod_{t\in T} \big(x_1 - t_1\big),$$
the product over the first coordinates of the points of $T$. Its total degree is $|T|\le d$. It vanishes at each $t\in T$ since the corresponding factor does. It is nonzero: each factor $x_1 - t_1$ is nonzero (its coefficient at the monomial $x_1$ is $1\ne 0$), and a product of nonzero polynomials over a domain is nonzero. $\square$

This already shows Theorem 3.6 is not an artefact of product structure. But it is far from tight; the true bound is a dimension count.

**Definition 5.2.** $M(n,d) = \{a\in\mathbb{N}^n : \sum_i a_i \le d\}$, the set of exponent vectors of monomials of total degree $\le d$. Over a field, the polynomials of total degree $\le d$ form a vector space of dimension $|M(n,d)|$ with basis $\{x^a : a\in M(n,d)\}$.

**Theorem 5.3 (Dimension lower bound).** Let $K$ be a field and $T\subseteq K^n$ a finite uniqueness set for total degree $\le d$. Then $|T| \ge |M(n,d)|$.

*Proof.* Consider the $K$-linear evaluation map
$$E: K^{M(n,d)} \to K^{T},\qquad E(c)(t) = \sum_{a\in M(n,d)} c_a \prod_i t_i^{a_i}.$$
If $|T| < |M(n,d)|$ then $E$ cannot be injective (the source has strictly larger dimension), so there is $c\ne 0$ with $E(c)=0$. The polynomial $p = \sum_a c_a x^a$ is nonzero (some $c_a\ne 0$ and the monomials are linearly independent), has total degree $\le d$, and vanishes on $T$; comparing $p$ with $0$ contradicts uniqueness. $\square$

**Lemma 5.4 (Counting).** $|M(n,d)| = \binom{n+d}{n}$, and $|M(n,d)| \le (d+1)^n$ with equality iff $n\le 1$ or $d=0$. In particular $|M(1,d)| = d+1$, so for $n=1$ the grid of Theorem 3.4 is already optimal.

*Proof.* The count is the classical stars-and-bars/hockey-stick identity $\sum_{k=0}^{d}\binom{n-1+k}{n-1} = \binom{n+d}{n}$, proved by induction on $d$. The inequality holds because $M(n,d)\subseteq\{0,\dots,d\}^n$. $\square$

So there is a gap between $(d+1)^n$ (achieved) and $\binom{n+d}{n}$ (required). Section 6 closes it.

---

## 6. The simplex lattice is an optimal node set

**Definition 6.1.** The **simplex lattice** is $S(n,d) = \{a\in\mathbb{N}^n : a_1+\cdots+a_n\le d\}$; the corresponding node set in a ring $K$ is $\{(a_1\cdot 1_K,\dots,a_n\cdot 1_K) : a \in S(n,d)\}$. As an index set $S(n,d) = M(n,d)$, so $|S(n,d)| = \binom{n+d}{n}$.

**Theorem 6.2 (Simplex unisolvence).** Let $K$ be a field of characteristic zero (more generally an integral domain of characteristic zero), $p$ a polynomial in $n$ variables over $K$ with total degree $\le d$. If $p$ vanishes at every simplex-lattice node, i.e.
$$p(a_1,\dots,a_n) = 0\quad\text{for all } a\in\mathbb{N}^n \text{ with } \textstyle\sum_i a_i \le d,$$
then $p=0$.

*Proof sketch.* Double induction, outer on $d$, inner on $n$.

*Base cases.* If $n=0$ the polynomial is a constant, evaluated at the unique (empty) point, hence zero. If $d=0$ the polynomial is a constant vanishing at the origin.

*Inner step (peel the outer face).* Substitute $x_1 \mapsto d - (x_2+\cdots+x_n)$ into $p$, obtaining $\tilde p$ in $n-1$ variables. Because the substituted expression is affine, $\deg\tilde p \le \deg p \le d$. For any $a' \in \mathbb{N}^{n-1}$ with $\sum a'_i \le d$, the point $(d-\sum a'_i,\, a')$ lies in $S(n,d)$ — this uses that $d - \sum a'_i \ge 0$ — so $\tilde p(a')=0$. By the inner induction hypothesis $\tilde p = 0$; equivalently $p$ vanishes on the hyperplane $x_1+\cdots+x_n = d$, so the linear form $\ell = x_1+\cdots+x_n - d$ divides $p$ (division with remainder in $x_1$ by the monic-in-$x_1$ form $\ell$ leaves a remainder independent of $x_1$ and vanishing identically, so it is zero).

*Outer step.* Write $p = \ell \cdot q$. Since $\ell$ is nonzero of total degree exactly $1$ and $K$ is a domain, $\deg q = \deg p - 1 \le d-1$. For $a\in S(n,d-1)$ we have $\ell(a) = \sum a_i - d \le -1 \ne 0$ (here characteristic zero is used: the nonzero integer $\sum a_i - d$ must be nonzero in $K$), and $p(a) = 0$, so $q(a)=0$. The outer induction hypothesis at degree $d-1$ gives $q=0$, hence $p=0$. $\square$

**Remark 6.3.** Inspecting the proof, the only arithmetic facts used about $K$ are that the integers $1,\dots,d$ are nonzero in $K$. This gives the positive-characteristic form:

**Theorem 6.4 (Exact characteristic threshold).** Let $K$ be an integral domain.
1. If $d < \operatorname{char} K$ (with $\operatorname{char} K = 0$ interpreted as $+\infty$), then $S(n,d)$ is a uniqueness set for total degree $\le d$.
2. If $\operatorname{char} K = p$ is prime, $n\ge 1$, and $d \ge p$, then $S(n,d)$ is **not** a uniqueness set: the Artin–Schreier polynomial
$$q = x_1^{p} - x_1$$
is nonzero, has total degree $p \le d$, and vanishes at every node of $S(n,d)$.

*Proof.* (1) is Theorem 6.2 with Remark 6.3, since $0 < m \le d < p$ implies $p \nmid m$, i.e. $m\ne 0$ in $K$. (2) $q\ne 0$ because its coefficient at $x_1^p$ is $1$ and $p\ge 2$ so $x_1^p \ne x_1$; the total-degree bound is clear; and at a node all coordinates are images of natural numbers, so $q$'s value is $c^p - c$ with $c$ in the prime field, which vanishes by the Frobenius identity $c^p = c$ (Fermat's little theorem). $\square$

**Theorem 6.5 (Two-polynomial form).** Over a domain with $d<\operatorname{char} K$, two polynomials of total degree $\le d$ agreeing at all simplex-lattice nodes are equal. Consequently, for chart expressions $e_1,e_2$ of syntactic degree $\le d$, agreement at the $\binom{n+d}{n}$ integer simplex nodes implies the identity in every commutative ring.

*Proof.* Apply Theorem 6.2 to $p-q$; for the expression form, run the argument over $\mathbb{Z}$ (characteristic zero) and transfer by Corollary 2.5. $\square$

**Theorem 6.6 (Minimality).** Over a field of characteristic zero, $S(n,d)$ is a uniqueness set for total degree $\le d$ of cardinality $\binom{n+d}{n}$, and by Theorem 5.3 no uniqueness set is smaller. Hence $S(n,d)$ is a *minimum-cardinality* uniqueness set. Moreover for $n\ge 2$ and $d\ge 1$,
$$\binom{n+d}{n} = |S(n,d)| \;<\; (d+1)^n = |\{0,\dots,d\}^n|,$$
so the simplex strictly improves on the box grid.

*Proof.* Cardinality is Lemma 5.4; unisolvence is Theorem 6.2; the lower bound is Theorem 5.3. Strictness: $S(n,d)\subseteq\{0,\dots,d\}^n$ and the point $(d,d,0,\dots,0)$ lies in the box but not the simplex when $n\ge2$, $d\ge 1$. $\square$

---

## 7. The per-variable refinement

Total degree is not the only shape invariant. If a variable occurs to low degree, its coordinate grid can be short.

**Theorem 7.1 (Box exactness).** Let $e_1,e_2\in\mathcal{E}_n$ and $D\in\mathbb{N}^n$ with $\deg_i e_1, \deg_i e_2 \le D_i$ for all $i$. If
$$\mathrm{ev}_x(e_1) = \mathrm{ev}_x(e_2)\quad\text{for all } x \in \textstyle\prod_i \{0,\dots,D_i\}\subseteq\mathbb{Z}^n,$$
then the identity holds in every commutative ring. The check costs $\prod_i (D_i+1)$ points.

*Proof sketch.* The difference of denotations has $x_i$-degree $\le D_i < |\{0,\dots,D_i\}|$ for each $i$ and vanishes on the box; the same one-variable-at-a-time induction as in Theorem 3.1, run with per-coordinate grids, gives $0$. Then transfer. $\square$

**Theorem 7.2 (Multilinear exactness).** If $e_1,e_2$ are affine in each variable separately ($\deg_i e_j \le 1$), then agreement at the $2^n$ points of the Boolean cube $\{0,1\}^n$ implies the identity in every commutative ring.

*Proof.* Theorem 7.1 with $D_i=1$. $\square$

**Proposition 7.3 (Genuine saving).** For $n\ge 2$, $2^n < (n+1)^n$: a multilinear expression can have total degree $n$, for which Theorem 3.4 would demand $(n+1)^n$ points, while the cube needs $2^n$.

**Example 7.4 (Inclusion–exclusion).** The identity $(1-a)(1-b) = 1 - a - b + ab$ is multilinear in two variables, hence certified by the four points of $\{0,1\}^2$, whereas its total degree $2$ would demand nine box points.

---

## 8. The converse half: interpolation

Unisolvence says the evaluation map is injective. Over a field, it is also surjective onto functions on the nodes; the two halves together give an isomorphism.

**Definition 8.1 (Lagrange indicator).** Let $K$ be a field, $S\subseteq K$ finite, and $s \in S^n$. Put
$$L_s(x) = \prod_{i=1}^n \ \prod_{\substack{u\in S\\ u\ne s_i}} \frac{x_i - u}{s_i - u}.$$
Then $\deg_{x_i} L_s \le |S|-1$ for each $i$, $L_s(s) = 1$, and $L_s(y) = 0$ for every $y\in S^n$ with $y\ne s$.

**Theorem 8.2 (Existence and uniqueness of grid interpolation).** Let $K$ be a field and $S\subseteq K$ nonempty finite with $|S| = b+1$. For every function $f : S^n \to K$ there is exactly one polynomial $p$ with $\deg_{x_i} p \le b$ for all $i$ and $p|_{S^n} = f$, namely $p = \sum_{s\in S^n} f(s) L_s$.

*Proof.* Existence: the displayed sum has the right per-variable degrees (a sum of such polynomials does) and reproduces $f$ by the Kronecker-delta property of the indicators. Uniqueness: the difference of two interpolants has $\deg_{x_i} \le b < |S|$ and vanishes on $S^n$, hence is $0$ by the argument of Theorem 7.1. $\square$

**Theorem 8.3 (Dimension formula).** Let $V_{b,n}\subseteq K[x_1,\dots,x_n]$ be the space of polynomials with $\deg_{x_i}\le b$ for all $i$. If $K$ has at least $b+1$ elements then evaluation on a grid $S^n$ with $|S| = b+1$ is a linear isomorphism $V_{b,n}\xrightarrow{\ \sim\ } K^{S^n}$, and hence
$$\dim_K V_{b,n} = (b+1)^n.$$

*Proof.* Injectivity is Theorem 7.1's polynomial form, surjectivity is Theorem 8.2, and $\dim K^{S^n} = |S|^n$. $\square$

---

## 9. Support-adapted unisolvence: downsets

Total degree cuts a simplex out of exponent space; per-variable degree cuts a box. Both are approximations to the honest invariant, the *support* of the polynomial. The right generality is a downset.

**Definition 9.1.** A set $D\subseteq\mathbb{N}^n$ of exponent vectors is a **downset** (lower set) if $a\in D$ and $b\le a$ componentwise imply $b\in D$. Equivalently, $D$ is the set of lattice points of a Newton-polytope-like region closed under coordinate decrease; equivalently, the complement of the exponent set of a monomial ideal. The **lattice nodes** of $D$ are the points $(a_1\cdot 1_K,\dots,a_n\cdot 1_K)$ for $a\in D$.

Both earlier shapes are downsets: $\{a : \sum a_i \le d\}$ and $\{a : a_i \le D_i\}$.

**Theorem 9.2 (Downset unisolvence).** Let $K$ be an integral domain of characteristic zero, $D\subseteq\mathbb{N}^n$ a downset, and $p$ a polynomial over $K$ whose support is contained in $D$. If $p$ vanishes at every lattice node of $D$, then $p=0$.

*Proof sketch.* Induct on $n$; the case $n=0$ is trivial. Regard $p$ as a polynomial in $x_1$ with coefficients in $K[x_2,\dots,x_n]$, and let $N$ be the top $x_1$-degree occurring, with leading coefficient $c_N$. Every exponent vector of $c_N$, extended by first coordinate $N$, lies in $D$; write $D_N$ for this *fibre* of $D$ over height $N$, a downset in $\mathbb{N}^{n-1}$.

Fix $a'\in D_N$. Because $D$ is a downset and $(N,a')\in D$, the whole column $(j, a')$ for $j=0,1,\dots,N$ lies in $D$; hence the nodes over $a'$ at heights $0,\dots,N$ are all evaluation points. Restricting $p$ to the line through them gives a univariate polynomial of degree $\le N$ with $N+1$ distinct roots $0,1,\dots,N$ (distinct because $K$ has characteristic zero), hence identically zero. In particular its leading coefficient $c_N(a')$ vanishes.

So $c_N$ is a polynomial supported in the downset $D_N$, vanishing at all lattice nodes of $D_N$; by the induction hypothesis $c_N = 0$. This contradicts the choice of $N$ unless $p$ has no terms at all, i.e. $p=0$. (Formally, one descends on $N$.) $\square$

**Theorem 9.3 (Positive characteristic, exactly).** Let $K$ be a domain and $D$ a downset all of whose exponents satisfy $a_i \le b$ for all $i$.
1. If $b < \operatorname{char} K$, the conclusion of Theorem 9.2 holds (only injectivity of $m\mapsto m\cdot 1_K$ on $\{0,\dots,b\}$ is used).
2. If $\operatorname{char} K = c$ is prime and $b \ge c$, it fails: $x_1^{c} - x_1$ is nonzero, supported in the box, and vanishes at every node.

*Proof.* As for Theorem 6.4: the only requirement is that the $b+1$ node heights be distinct in $K$; the Artin–Schreier witness is the same. $\square$

**Theorem 9.4 (Downset interpolation: existence and uniqueness).** Let $K$ be a field of characteristic zero and $D\subseteq\mathbb{N}^n$ a finite downset. Then evaluation at the $|D|$ lattice nodes of $D$ is a $K$-linear **isomorphism** from the space $P_D$ of polynomials supported in $D$ onto $K^{D}$. In particular, for every prescribed function on the nodes there is exactly one polynomial supported in $D$ realising it.

*Proof.* $\dim_K P_D = |D|$ (the monomials $x^a$, $a\in D$, form a basis). The map is injective by Theorem 9.2. An injective linear map between spaces of the same finite dimension is bijective. $\square$

**Theorem 9.5 (Minimality).** Let $D$ be a finite downset. Any set $T$ of points at which polynomials supported in $D$ are determined satisfies $|T| \ge |D|$. Hence the lattice nodes of $D$ form a minimum-cardinality uniqueness set for $P_D$.

*Proof.* Same dimension count as Theorem 5.3, with $M(n,d)$ replaced by $D$: if $|T| < \dim P_D = |D|$, the evaluation map $P_D \to K^T$ has nontrivial kernel, providing a nonzero polynomial supported in $D$ vanishing on $T$. $\square$

**Corollary 9.6 (Specialisations).** With $D = \{a : \sum_i w_i a_i \le d\}$ (a downset since $w_i \ge 0$ makes $a\mapsto \sum w_i a_i$ monotone) we obtain **weighted (quasi-homogeneous) unisolvence**. Taking all $w_i = 1$ recovers simplex unisolvence (Theorem 6.2); taking $D = \prod_i\{0,\dots,D_i\}$ recovers box unisolvence (Theorem 7.1).

**Definition 9.7 (Weighted certificate).** For weights $w\in\mathbb{N}^n$ with $w_i\ge 1$ and a bound $d$, the *weighted node set* is $W(w,d) = \{a\in\mathbb{N}^n : \sum_i w_i a_i \le d\}$ (a finite set), and the *weighted certificate* for $e_1,e_2$ is the decidable statement that the two expressions agree at every point of $W(w,d)$. If $\deg_w e_1, \deg_w e_2 \le d$, this certificate is **sound and complete** for equality of denotations, hence — via Corollary 2.5 and Theorem 4.3 — for validity in every commutative ring.

*Proof.* By Lemma 2.9 both denotations are supported in $W(w,d)$, which is a downset; apply Theorem 9.2 to the difference over $\mathbb{Z}$; conversely equal denotations give equal evaluations everywhere. $\square$

**Proposition 9.8 (Downsets are strictly more general than weighted sublevel sets).** There is a downset $D\subseteq\mathbb{N}^2$ and an exponent $a_0\notin D$ such that every weighted sublevel set $\{a : w_1a_1 + w_2a_2 \le d\}$ containing $D$ also contains $a_0$.

*Proof.* Take the "cross without its corner"
$$D = \{(a,0) : a \le 2\}\ \cup\ \{(0,b) : b \le 2\},\qquad a_0 = (1,1).$$
$D$ is a downset (decreasing a coordinate of a point on either arm keeps it on that arm) and $a_0\notin D$. Suppose $D \subseteq \{a : w_1a_1+w_2a_2\le d\}$. Then $(2,0)\in D$ gives $2w_1\le d$ and $(0,2)\in D$ gives $2w_2 \le d$; adding, $2(w_1+w_2)\le 2d$, so $w_1+w_2 \le d$, i.e. $a_0 = (1,1)$ satisfies the weighted bound. $\square$

Thus the family of node sets produced by Theorem 9.2 is strictly finer than the quasi-homogeneous family: there are sparsity patterns visible to downsets that no choice of weights can isolate.

---

## 10. Worked certificates

Each identity below is *derived* from a finite number of integer evaluations, and holds in every commutative ring.

| Identity | Variables | Shape bound | Node set | Points |
|---|---|---|---|---|
| $(a+b)^3 = a^3+3a^2b+3ab^2+b^3$ | 2 | total degree 3 | box $\{0,..,3\}^2$ | 16 |
| $(a+b)^3 = a^3+3a^2b+3ab^2+b^3$ | 2 | total degree 3 | simplex $S(2,3)$ | **10** |
| $(a+b)^2(a-b)^2 = (a^2-b^2)^2$ | 2 | total degree 4 | box $\{0,..,4\}^2$ | 25 |
| $a^3+b^3+c^3-3abc = (a+b+c)(a^2+b^2+c^2-ab-bc-ca)$ | 3 | total degree 3 | box $\{0,..,3\}^3$ | 64 |
| same | 3 | total degree 3 | simplex $S(3,3)$ | **20** |
| $(1-a)(1-b) = 1-a-b+ab$ | 2 | multilinear | cube $\{0,1\}^2$ | **4** |
| $(a^2+b)(a^2-b) = a^4-b^2$ | 2 | weighted degree 4, $w=(1,2)$ | weighted $W((1,2),4)$ | **9** |

For the last row, the total-degree simplex $S(2,4)$ has $15$ points and the box grid $\{0,\dots,4\}^2$ has $25$: exploiting quasi-homogeneity saves roughly two-thirds of the work. As the weights grow, the ratio is unbounded.

The certificate procedure for each row is identical: compute the syntactic shape bound of both sides by structural recursion; enumerate the node set; evaluate both sides in exact integer arithmetic at each node; if all values agree, the theorem is proved for every commutative ring simultaneously.

---

## 11. Algorithms

### 11.1 Universal identity decision

**Input:** $e_1, e_2 \in \mathcal{E}_n$.
**Output:** whether $e_1$ and $e_2$ define the same function on every commutative ring.

1. $d \leftarrow \max(\deg e_1, \deg e_2)$ by structural recursion.
2. For each $a$ in the node set (box, simplex, or weighted, depending on the shape invariant chosen), evaluate both expressions at $a$ over $\mathbb{Z}$.
3. Return "valid" iff all pairs of values agree.

**Correctness** is Theorem 4.4 (box), Theorem 6.5 (simplex), Definition 9.7 (weighted). **Cost:** $|T| \cdot O(|e_1| + |e_2|)$ integer operations, where $|T|$ is the node count — $(d+1)^n$, $\binom{n+d}{n}$, or $|W(w,d)|$ respectively. Integers can grow to $O(d^{\deg})$ in magnitude, so bit complexity carries an extra $\tilde O(d\cdot\deg)$ factor per evaluation; working modulo a random large prime, or modulo several primes, removes it at no loss of correctness for the "reject" answer and with the usual CRT reconstruction for "accept".

### 11.2 Node set generation

Simplex nodes are generated by the recursion
$$S(n,d) = \bigcup_{k=0}^{d} \{k\}\times S(n-1, d-k),$$
which enumerates each node once, in $O(n)$ amortised work per node, for a total of $O(n\binom{n+d}{n})$. Weighted nodes use $W(w,d) = \bigcup_{k : k w_1 \le d}\{k\}\times W(w_{2..n}, d - k w_1)$. Downset nodes are supplied directly, or generated from the maximal elements of the downset by taking all componentwise-smaller vectors.

### 11.3 Downset interpolation

Given a downset $D$ and target values $f : D\to K$, solve the $|D|\times|D|$ linear system $\sum_{a\in D} c_a \prod_i b_i^{a_i} = f(b)$, $b\in D$. Theorem 9.4 guarantees the matrix is invertible in characteristic $0$. Ordering both rows and columns by a linear extension of the componentwise order makes the matrix well conditioned in practice and, for the box case, allows a tensor-product (dimension-by-dimension) Lagrange solve in $O(n |D|^{1+1/n})$ instead of the generic $O(|D|^3)$.

---

## 12. Discussion

### 12.1 What the theory says, in one sentence

*The finite set of integer points needed to certify a universal polynomial identity is exactly a downset matching the identity's support, and it is never smaller than the number of monomials involved.*

Every result above is an instance or a sharpening of that sentence.

### 12.2 The role of "shape"

Three invariants appear, in increasing refinement:
$$\text{total degree} \;\subsetneq\; \text{weighted degree} \;\subsetneq\; \text{downset}.$$
The first inclusion is Corollary 9.6 (weights $\equiv 1$); the second is strict by Proposition 9.8. Per-variable degree is not simply the weighted family in disguise: a box $\prod_i\{0,\dots,D_i\}$ is not generally a weighted sublevel set, since a weighted simplex containing the corner $(D_1,D_2)$ must have $w_1D_1 + w_2D_2 \le d$ and therefore admits exponents outside the box. Both boxes and simplices are downsets, and downsets are the correct common generalisation.

### 12.3 Comparison with randomised identity testing

The Schwartz–Zippel lemma says a nonzero polynomial of total degree $d$ vanishes on at most a $d/|S|$ fraction of $S^n$, giving a Monte Carlo test with one-sided error. The theorems here give the deterministic counterpart: with a *structured* set of $\binom{n+d}{n}$ points (or $|D|$ points), the error probability is zero. The trade-off is stark and instructive: randomisation buys a number of evaluations independent of $n$ at the price of a small error probability; structure buys certainty at a price that is *provably minimal* given the shape data, but exponential in $n$ for dense polynomials. Which is preferable depends on whether the polynomial is given as a black box (randomise) or as a syntax tree whose support one can read off (structure).

### 12.4 Why the certificate transfers to all rings

It is worth restating the mechanism, because it is easy to mistake it for magic. The check happens over $\mathbb{Z}$; the conclusion is over arbitrary $R$. The reason is not that $\mathbb{Z}$ "approximates" $R$, but that $\mathbb{Z}[x_1,\dots,x_n]$ is *free*: it is the initial commutative ring with $n$ marked elements. An expression names a point of that free object, and two expressions naming the same point are indistinguishable under every interpretation. The finite check certifies a statement about the free object; freeness does the rest. Theorem 4.3 makes this precise as a completeness statement, and Theorem 4.6 shows even the *set of $\mathbb{Z}$-points* is a complete test object, since $\mathbb{Z}$ is an infinite domain.

### 12.5 The characteristic thresholds

Two of the theorems (6.4, 9.3) come with an exact characteristic condition, both sharpened by the same Artin–Schreier witness $x^c - x$. The reason the condition appears at all is that the node sets here are *lattice* nodes: their coordinates are the images of $0,1,2,\dots$ in the ring, and once the characteristic is reached these images collide. Nothing about the underlying combinatorics fails — one may take any $b+1$ distinct elements of $K$ in place of $0,\dots,b$ — but "the lattice" as literally defined stops being a set of distinct points. This is a genuine phenomenon, not a proof artefact, as the failure direction shows.

### 12.6 Applications

- **Symbolic algebra.** Verification of proposed identities without expansion, at provably minimal cost once the support is known; the completeness statement guarantees no false negatives, so a failed check is a genuine disproof.
- **Coding theory.** Reed–Muller codes are evaluations of bounded-total-degree polynomials; unisolvence is injectivity of the encoder, interpolation is the decoder on an information set. The downset version is the natural sparse/"weighted Reed–Muller" refinement.
- **Numerical analysis.** The simplex lattice is the classical Lagrange node set for finite elements on simplices; Theorem 6.6 identifies it as *minimum-cardinality* among all unisolvent node sets, which is the precise sense in which those elements are efficient. Theorem 9.4 is the sparse-grid/polynomial-chaos statement for downset index sets.
- **Program verification and compilers.** Deciding equality of arithmetic expression trees over an unspecified numeric type is exactly the problem of Theorem 4.5.

### 12.7 Limitations

The framework is about *ring* identities: only $+$, $-$, $\times$ and integer constants. Division, inequalities, and non-commutative multiplication are outside it. The dense case is exponential in $n$: $\binom{n+d}{n}$ grows quickly, and while it is optimal, optimality is small comfort when $n=100$. This is precisely the regime where randomisation, or a genuinely small downset, is needed. Finally, the transfer theorem hands you validity in every commutative ring — but an identity that fails in some ring cannot be repaired by the theory; it simply is not a ring identity.

---

## 13. Future work

Several directions are natural.

1. **Beyond commutative rings.** Semirings (no negation, hence no cancellation of grid differences), and non-commutative rings (where the free object is the free associative algebra and shape must track word structure, not exponent vectors).
2. **Downset discovery.** Given a syntax tree, compute the *smallest* downset containing the support of its denotation without expanding it. The syntactic recursions here (total, per-variable, weighted degree) are three coarse approximations; a Newton-polytope-valued abstract interpretation would be the sharp one, at the price of computing Minkowski sums.
3. **Modular and probabilistic hybrids.** Run the structured certificate modulo random primes to bound coefficient growth, using the characteristic thresholds of Theorems 6.4 and 9.3 to choose safe primes: any prime exceeding the maximum node coordinate is admissible.
4. **Rings of positive characteristic, natively.** Replace lattice nodes by arbitrary distinct elements, phrase unisolvence in terms of "any $b+1$ distinct values per coordinate", and recover the finite-field cases (where the total number of available values is itself a constraint, connecting to Reed–Muller distance).
5. **Certificate compression.** A downset with $|D|$ nodes is optimal among *node sets*; allowing more general linear functionals (derivatives, Hermite data, integrals) permits smaller data sets. What is the minimal number of *linear functionals*, and is there a shape-adapted theory for those?
6. **Complexity separations.** The deterministic-versus-randomised gap for identity testing is the central open question of algebraic complexity; the theory here gives exact optimal bounds under a *shape promise*, which suggests studying the promise problem "given a downset $D$, test identity for polynomials supported in $D$" as a graded family interpolating between trivial and hard.

---

## 14. Conclusion

Testing a polynomial identity by plugging in numbers is not a heuristic. Organised by shape, it is a complete, decidable, and optimal procedure. Total degree $\le d$ is certified by $(d+1)^n$ box points, and $d$ per coordinate is never enough; the minimal count is $\binom{n+d}{n}$ and the simplex lattice achieves it, provided the degree stays below the characteristic — a condition that is exactly, not approximately, correct. And behind both is the support-adapted statement: a downset of exponents is a uniqueness set for its own polynomials, of minimum cardinality, with interpolation always solvable and uniquely so. Each finite integer computation, once passed, is upgraded automatically to a theorem about every commutative ring, because a chart expression names a point of a free object and freeness respects every interpretation.
