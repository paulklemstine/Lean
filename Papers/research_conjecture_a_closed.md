# Trace Distributions of Finite Group Actions are Determined by Orbit Counts on Tuples

**Author:** Aristotle
**Date:** 2026-08-18

## Abstract

Let $G$ be a finite group acting on a finite set $X$. We compare two invariants of the action: the *trace distribution* $\mathrm{tr}(X) = \{\!\{\,|X^g| : g \in G\,\}\!\}$, the multiset of fixed-point counts of the group elements (the permutation character viewed as an unordered multiset), and the *orbit spectrum* $k \mapsto N_k(X)$, where $N_k(X)$ is the number of $G$-orbits on the set of $k$-tuples of elements of $X$ under the diagonal action. We prove that these two invariants carry exactly the same information, and that the equivalence is witnessed by an explicitly bounded, finite range of $k$.

The key structural identity is a *graded Burnside lemma*: $N_k(X)\cdot|G| = \sum_{g\in G}|X^g|^k$, exhibiting the orbit spectrum as the sequence of power sums of the trace distribution. The bridge from equal power sums back to equal multisets is a rigidity theorem for multisets of natural numbers, proved by Lagrange-interpolation duality rather than Newton's identities; the interpolation argument requires no equal-cardinality hypothesis and yields a threshold governed by the number of *distinct* values present.

Our main theorem states that two finite $G$-sets $X, Y$ satisfy $\mathrm{tr}(X) = \mathrm{tr}(Y)$ if and only if $N_k(X) = N_k(Y)$ for all $k \le \max(|X|,|Y|)$; a bootstrapping corollary shows this finite window forces agreement for *all* $k$, so the orbit spectrum is a rigid sequence. A refinement replaces the threshold by $2|G|$, independent of the size of the sets acted on, and the two bounds combine to $\min(2|G|, \max(|X|,|Y|)+1)$. We also record a gradewise $q$-series formulation: the fixed-point generating polynomial $Z_X(q) = \sum_{g\in G} q^{|X^g|} \in \mathbb{Z}[q]$ is a complete invariant, equal for $X$ and $Y$ precisely when the finitely many orbit counts agree.

Both thresholds are sharp. The alternating binomial (finite-difference) pair provides, for each $n$, two distinct multisets with values in $\{0,\dots,n\}$, joint support all of $\{0,\dots,n\}$, whose power sums agree for every $k<n$ and differ at $k=n$ by exactly $n!$. On the group side, the regular $G$-set and the one-point $G$-set agree on $0$- and $1$-tuples for every $G$ but differ on $2$-tuples whenever $|G|\ge 2$, so no version of the main theorem with range $k\le 1$ can hold. We conclude with algorithms, worked examples, and open problems on pointwise (Gassmann) refinement and on realisability of the extremal pairs as permutation characters.

**Keywords.** Burnside's lemma; permutation character; orbit counting; power sums; Lagrange interpolation; finite differences; Gassmann equivalence; Burnside ring.

---

## 1. Introduction

### 1.1 The question

Let $G$ be a finite group acting on a finite set $X$. Consider an observer who can measure only the following quantities: for each $k \ge 0$, the number $N_k(X)$ of orbits of $G$ on the set $X^{(k)}$ of ordered $k$-tuples $(x_1,\dots,x_k)$ from $X$, under the diagonal action $g\cdot(x_1,\dots,x_k) = (gx_1,\dots,gx_k)$. What can the observer infer about the action?

The sequence $N_0, N_1, N_2, \dots$ is a natural and much-used enumerative invariant. $N_1$ is the ordinary orbit count; $N_2$ counts *orbitals* and is the fundamental invariant in the theory of association schemes and coherent configurations; $N_k$ for all $k$ is the *profile* of the permutation group, closely related to the theory of oligomorphic groups when $X$ is infinite.

We show the observer can determine, exactly, the multiset of fixed-point counts $\{\!\{|X^g| : g\in G\}\!\}$ — no more and no less — and that a finite, explicitly bounded window of measurements suffices.

### 1.2 Summary of results

Throughout, $G$ is a finite group, and $X$, $Y$ are finite $G$-sets. All multisets are finite multisets of non-negative integers, written $\{\!\{\cdot\}\!\}$, and $p_k(A) = \sum_{a\in A} a^k$ denotes the $k$-th power sum, with the convention $0^0 = 1$ so that $p_0(A) = |A|$ counts entries with multiplicity.

1. **Graded Burnside lemma** (Theorem 3.3). $N_k(X)\cdot|G| = \sum_{g\in G}|X^g|^k = p_k(\mathrm{tr}(X))$ for every $k\ge 0$.
2. **Power-sum rigidity** (Theorem 4.3, Corollary 4.4). If the joint support of two multisets $A,B$ has at most $n$ distinct values and $p_k(A)=p_k(B)$ for all $k<n$, then $A=B$. In particular this holds if all elements of $A$ and $B$ are $< n$.
3. **Main theorem** (Theorem 5.3). $\mathrm{tr}(X)=\mathrm{tr}(Y) \iff N_k(X)=N_k(Y)$ for all $k \le \max(|X|,|Y|)$.
4. **Rigidity of the orbit spectrum** (Corollary 5.4). Agreement over the window $k \le \max(|X|,|Y|)$ implies agreement for all $k \ge 0$.
5. **Group-order threshold** (Theorem 5.6, Corollary 5.7). Agreement for $k < 2|G|$ suffices, independently of $|X|,|Y|$; combining, only $k < \min(2|G|,\max(|X|,|Y|)+1)$ is ever needed.
6. **$q$-series form** (Theorem 6.3). $Z_X(q)=Z_Y(q) \iff N_k(X)=N_k(Y)$ for all $k \le \max(|X|,|Y|)$, where $Z_X(q)=\sum_{g\in G}q^{|X^g|}$.
7. **Sharpness of the multiset threshold** (Theorem 7.5). For every $n$ there exist distinct multisets $A_n \ne B_n$ with all values $\le n$, joint support $\{0,\dots,n\}$, and $p_k(A_n)=p_k(B_n)$ for all $k<n$, while $p_n(A_n)-p_n(B_n)=n!$.
8. **Sharpness on the group side** (Theorem 8.3). No statement of the form "$N_0,N_1$ agree $\Rightarrow$ trace distributions agree" is true.

### 1.3 Relation to classical themes

The pointwise condition $|X^g|=|Y^g|$ for all $g\in G$ is *Gassmann equivalence* (also called linear equivalence, or equality of permutation characters). It is the engine behind arithmetically equivalent number fields and behind Sunada's isospectral non-isometric manifolds. Our results identify precisely the *unordered* shadow of that condition — the trace distribution — as the exact information content of the orbit spectrum. Section 9 discusses how the two might be reconciled by restricting to cyclic subgroups.

---

## 2. Definitions

Fix a finite group $G$.

**Definition 2.1 (Fixed-point count / mark).** For a $G$-set $X$ and $g\in G$, the *fixed set* is $X^g = \{x\in X : g\cdot x = x\}$, and the *mark* of $g$ on $X$ is $\mathrm{fix}_X(g) = |X^g| \in \mathbb{N}$.

**Definition 2.2 (Trace distribution).** For a finite $G$-set $X$, the *trace distribution* is the multiset
$$\mathrm{tr}(X) \;=\; \{\!\{\, \mathrm{fix}_X(g) \;:\; g\in G \,\}\!\},$$
indexed by group elements, so that $|\mathrm{tr}(X)| = |G|$ always (Lemma 5.5).

**Definition 2.3 (Orbit spectrum).** For $k\ge 0$ let $X^{(k)}$ be the set of functions $\{1,\dots,k\}\to X$, i.e. ordered $k$-tuples, with the diagonal $G$-action. Set
$$N_k(X) \;=\; \bigl|\,X^{(k)}/G\,\bigr|,$$
the number of orbits. Note $X^{(0)}$ is a single (empty) tuple, so $N_0(X)=1$ for every $X$, including $X=\varnothing$.

**Definition 2.4 (Fixed-point generating polynomial / $q$-series).**
$$Z_X(q) \;=\; \sum_{g\in G} q^{\,\mathrm{fix}_X(g)} \;\in\; \mathbb{Z}[q].$$

**Definition 2.5 (Power sums).** For a finite multiset $A$ of natural numbers, $p_k(A) = \sum_{a\in A} a^k$ (sum with multiplicity), with $0^0=1$.

---

## 3. The graded Burnside lemma

We recall the classical statement.

**Theorem 3.1 (Burnside / Cauchy–Frobenius).** For a finite group $G$ acting on a finite set $\beta$,
$$\sum_{g\in G} |\beta^g| \;=\; |\beta/G|\cdot|G|.$$

*Proof sketch.* Double count the incidence set $I=\{(g,x)\in G\times\beta : gx=x\}$. Summing over $g$ gives $\sum_g|\beta^g|$; summing over $x$ gives $\sum_x |\mathrm{Stab}(x)| = \sum_x |G|/|Gx|$, and grouping the $x$ by orbit turns each orbit's contribution into exactly $|G|$. $\square$

The observation that makes the theorem *graded* is the following elementary equivalence.

**Lemma 3.2 (Tensor-power structure of fixed sets).** For every $g\in G$ and $k\ge 0$ there is a bijection
$$\bigl(X^{(k)}\bigr)^g \;\cong\; \bigl(X^g\bigr)^{k},$$
natural in $X$. Consequently $\bigl|(X^{(k)})^g\bigr| = |X^g|^k$.

*Proof.* A tuple $f : \{1,\dots,k\}\to X$ satisfies $g\cdot f = f$ if and only if $g\cdot f(i)=f(i)$ for every $i$, since the action is coordinatewise. Hence $f\mapsto (i\mapsto f(i))$ is a bijection from $g$-fixed tuples to $k$-tuples of $g$-fixed points, with the evident inverse. $\square$

**Theorem 3.3 (Graded Burnside lemma).** For every finite $G$-set $X$ and every $k\ge 0$,
$$N_k(X)\cdot|G| \;=\; \sum_{g\in G} |X^g|^{\,k} \;=\; p_k\bigl(\mathrm{tr}(X)\bigr).$$

*Proof.* Apply Theorem 3.1 to $\beta = X^{(k)}$, which is finite, and rewrite each term using Lemma 3.2. The last equality is the definition of the power sum of the multiset $\mathrm{tr}(X)$, whose entries are indexed by $g\in G$. $\square$

**Remark 3.4.** Specialising: $k=0$ gives $N_0 |G| = |G|$; $k=1$ recovers Burnside's lemma; $k=2$ says the number of orbitals times $|G|$ equals $\sum_g |X^g|^2$, a form frequently attributed to Frobenius in the theory of permutation groups (the *rank* of a transitive group).

Thus the orbit spectrum is, up to the fixed nonzero factor $|G|$, the sequence of moments of a finitely supported non-negative-integer "measure": the trace distribution. Everything now reduces to a discrete moment problem.

---

## 4. Power-sum rigidity by interpolation duality

We work over $\mathbb{Q}$.

**Lemma 4.1 (Vanishing lemma / interpolation duality).** Let $S$ be a finite set with $|S|\le n$, let $v : S\to\mathbb{Q}$ be injective, and let $c : S\to\mathbb{Q}$ be any function. If
$$\sum_{m\in S} c(m)\, v(m)^k \;=\; 0 \qquad\text{for all } 0\le k<n,$$
then $c \equiv 0$ on $S$.

*Proof.* The hypothesis says that the linear functional $\Lambda(P) = \sum_{m\in S} c(m)\,P(v(m))$ on $\mathbb{Q}[x]$ vanishes on the monomials $1,x,\dots,x^{n-1}$, hence by linearity on the whole space $\mathbb{Q}[x]_{<n}$ of polynomials of degree $<n$. Fix $m_0\in S$ and form the Lagrange basis polynomial
$$L_{m_0}(x) \;=\; \prod_{m\in S\setminus\{m_0\}} \frac{x-v(m)}{v(m_0)-v(m)},$$
well defined because $v$ is injective. It has degree $|S|-1 \le n-1$, so $\Lambda(L_{m_0})=0$. On the other hand $L_{m_0}(v(m))=\delta_{m,m_0}$, so $\Lambda(L_{m_0})=c(m_0)$. Hence $c(m_0)=0$. $\square$

**Lemma 4.2 (Power sums as multiplicity-weighted sums).** Let $A$ be a finite multiset of naturals and $S$ a finite set of naturals containing every element of $A$. Then for all $k$,
$$p_k(A) \;=\; \sum_{m\in S} \mathrm{mult}_A(m)\cdot m^k .$$

*Proof.* Group the terms of $\sum_{a\in A}a^k$ by value; values in $S\setminus\mathrm{supp}(A)$ contribute $0$. $\square$

**Theorem 4.3 (Support form of power-sum rigidity).** Let $A,B$ be finite multisets of naturals whose joint support $S = \mathrm{supp}(A)\cup\mathrm{supp}(B)$ satisfies $|S|\le n$. If $p_k(A)=p_k(B)$ for all $k<n$, then $A=B$.

*Proof.* Define $c(m) = \mathrm{mult}_A(m)-\mathrm{mult}_B(m) \in \mathbb{Q}$ for $m\in S$, and take $v(m)=m$, injective on $S\subseteq\mathbb{N}\subseteq\mathbb{Q}$. By Lemma 4.2 and the hypothesis, for each $k<n$,
$$\sum_{m\in S} c(m)\,m^k \;=\; p_k(A)-p_k(B) \;=\; 0 .$$
Lemma 4.1 gives $c\equiv 0$ on $S$, i.e. $\mathrm{mult}_A(m)=\mathrm{mult}_B(m)$ for $m\in S$; outside $S$ both multiplicities are $0$. Hence $A=B$. $\square$

**Corollary 4.4 (Value-bound form).** If every element of $A$ and of $B$ is $<n$, and $p_k(A)=p_k(B)$ for all $k<n$, then $A=B$.

*Proof.* The joint support is contained in $\{0,\dots,n-1\}$, so has at most $n$ elements; apply Theorem 4.3. $\square$

**Remark 4.5 (Why not Newton's identities).** The classical approach converts power sums to elementary symmetric functions via Newton's identities, then compares the monic polynomials $\prod_{a\in A}(x-a)$ and $\prod_{b\in B}(x-b)$. That route requires knowing in advance that $|A|=|B|$ (otherwise the polynomials have different degrees) and involves division by $1,2,\dots$ The interpolation-duality proof above needs neither: the hypothesis at $k=0$ *is* $|A|=|B|$, obtained for free, and the argument is a single application of linear duality between the space of polynomials of degree $<n$ and the space of signed measures on $\le n$ nodes. Moreover, it delivers the sharper *support* bound, which is what yields the group-order threshold of Theorem 5.6.

---

## 5. The main theorem

Throughout this section $X$ and $Y$ are finite $G$-sets.

**Lemma 5.1 (Elementary structure of $\mathrm{tr}$).**
(i) $\mathrm{fix}_X(g)\le|X|$ for all $g$, with equality at $g=1$: $\mathrm{fix}_X(1)=|X|$.
(ii) Every element of $\mathrm{tr}(X)$ is of the form $\mathrm{fix}_X(g)$, hence $\le|X|$; and $|X|\in\mathrm{tr}(X)$.
(iii) Consequently $\mathrm{tr}(X)=\mathrm{tr}(Y)$ implies $|X|=|Y|$: the trace distribution knows the size of the set, as its maximum entry.

*Proof.* (i) $X^g \subseteq X$ and $X^1 = X$. (ii) is immediate from the definition. (iii) $|X|\in\mathrm{tr}(X)=\mathrm{tr}(Y)$ gives $|X|\le|Y|$ by (ii) applied to $Y$; symmetrically $|Y|\le|X|$. $\square$

**Theorem 5.2 (Easy direction).** If $\mathrm{tr}(X)=\mathrm{tr}(Y)$ then $N_k(X)=N_k(Y)$ for every $k\ge 0$.

*Proof.* Equal multisets have equal power sums. By Theorem 3.3, $N_k(X)\,|G| = p_k(\mathrm{tr}(X)) = p_k(\mathrm{tr}(Y)) = N_k(Y)\,|G|$, and $|G|>0$ may be cancelled in $\mathbb{N}$. $\square$

**Theorem 5.3 (Main theorem).** Let $M=\max(|X|,|Y|)$. Then
$$\mathrm{tr}(X)=\mathrm{tr}(Y) \quad\Longleftrightarrow\quad N_k(X)=N_k(Y)\ \text{ for all } k\le M .$$

*Proof.* ($\Rightarrow$) Theorem 5.2.

($\Leftarrow$) Put $n=M+1$. By Lemma 5.1(ii), every element of $\mathrm{tr}(X)$ is $\le|X|\le M<n$, and likewise for $\mathrm{tr}(Y)$. For each $k<n$, i.e. $k\le M$, Theorem 3.3 and the hypothesis give
$$p_k(\mathrm{tr}(X)) = N_k(X)\,|G| = N_k(Y)\,|G| = p_k(\mathrm{tr}(Y)).$$
Corollary 4.4 with this $n$ yields $\mathrm{tr}(X)=\mathrm{tr}(Y)$. $\square$

**Corollary 5.4 (Rigidity of the orbit spectrum).** If $N_k(X)=N_k(Y)$ for all $k\le\max(|X|,|Y|)$, then $N_k(X)=N_k(Y)$ for *all* $k\ge0$.

*Proof.* Compose Theorem 5.3 ($\Leftarrow$) with Theorem 5.2. $\square$

Thus the orbit spectrum, an infinite sequence, is entirely determined by an initial window whose length is bounded by the size of the sets. There is no way for two actions to agree on the window and diverge later.

**Lemma 5.5 (Cardinality of the trace distribution).** $|\mathrm{tr}(X)| = |G|$.

*Proof.* $\mathrm{tr}(X)$ is by definition the image multiset of the map $g\mapsto \mathrm{fix}_X(g)$ on the $|G|$-element index set $G$, so it has $|G|$ entries counted with multiplicity. $\square$

**Theorem 5.6 (Group-order threshold).** If $N_k(X)=N_k(Y)$ for all $k<2|G|$, then $\mathrm{tr}(X)=\mathrm{tr}(Y)$. Consequently
$$\mathrm{tr}(X)=\mathrm{tr}(Y) \iff N_k(X)=N_k(Y)\ \text{ for all } k<2|G|,$$
a criterion independent of $|X|$ and $|Y|$.

*Proof.* By Lemma 5.5, the multiset $\mathrm{tr}(X)+\mathrm{tr}(Y)$ (disjoint union) has $2|G|$ entries, hence at most $2|G|$ distinct values; that is, the joint support satisfies $|S|\le 2|G|$. For $k<2|G|$, Theorem 3.3 converts the hypothesis into $p_k(\mathrm{tr}(X))=p_k(\mathrm{tr}(Y))$. Theorem 4.3 with $n=2|G|$ finishes. The converse is Theorem 5.2. $\square$

**Corollary 5.7 (Combined threshold).** If $N_k(X)=N_k(Y)$ for all
$$k \;<\; \min\bigl(2|G|,\ \max(|X|,|Y|)+1\bigr),$$
then $N_k(X)=N_k(Y)$ for all $k$, and $\mathrm{tr}(X)=\mathrm{tr}(Y)$.

*Proof.* Whichever of the two quantities is the minimum, the hypothesis supplies the full range required by Theorem 5.6 or by Theorem 5.3 respectively; then apply Theorem 5.2. $\square$

**Example 5.8.** For $G=\mathbb{Z}/2$ acting on a set of $10^6$ points, $\max(|X|,|Y|)+1 = 10^6+1$ while $2|G|=4$: orbit counts on $k$-tuples for $k\le 3$ already decide the question.

---

## 6. The gradewise $q$-series form

**Lemma 6.1 (Coefficients of $Z_X$).** For every $m\ge 0$,
$$[q^m]\,Z_X(q) \;=\; \#\{g\in G : |X^g| = m\} \;=\; \mathrm{mult}_{\mathrm{tr}(X)}(m).$$

*Proof.* Expand $Z_X = \sum_{g}q^{\mathrm{fix}_X(g)}$ and collect terms with the same exponent. $\square$

**Proposition 6.2 ($Z$ is a complete invariant of $\mathrm{tr}$).** $Z_X = Z_Y$ in $\mathbb{Z}[q]$ if and only if $\mathrm{tr}(X)=\mathrm{tr}(Y)$.

*Proof.* Two multisets are equal iff all their multiplicity functions agree; two polynomials are equal iff all their coefficients agree; by Lemma 6.1 these are the same condition. $\square$

**Theorem 6.3 (Gradewise form).** For finite $G$-sets $X,Y$,
$$Z_X(q) = Z_Y(q) \quad\Longleftrightarrow\quad N_k(X)=N_k(Y) \ \text{ for all } k\le\max(|X|,|Y|),$$
and then, by Corollary 5.4, for all $k$.

*Proof.* Combine Proposition 6.2 and Theorem 5.3. $\square$

**Remark 6.4 (Functoriality).** Marks are additive on disjoint unions and multiplicative on products:
$$\mathrm{fix}_{X\sqcup Y}(g) = \mathrm{fix}_X(g)+\mathrm{fix}_Y(g), \qquad \mathrm{fix}_{X\times Y}(g) = \mathrm{fix}_X(g)\cdot\mathrm{fix}_Y(g),$$
because a point of a disjoint union is fixed iff its representative is, and a pair is fixed iff both components are. Marks are also invariant under equivariant bijections. It follows that if $X,X'$ have equal marks pointwise and so do $Y,Y'$, then $X\sqcup Y$ and $X'\sqcup Y'$, and likewise $X\times Y$ and $X'\times Y'$, have equal marks pointwise, hence equal trace distributions and equal orbit spectra. This gives a calculus for producing new pairs of actions with identical orbit spectra from old ones.

**Remark 6.5 (Generating function of the spectrum).** Combining Theorem 3.3 with Lemma 6.1, the exponential generating function of the orbit spectrum is
$$\sum_{k\ge0} N_k(X)\frac{t^k}{k!} \;=\; \frac{1}{|G|}\sum_{g\in G} e^{|X^g|\,t} \;=\; \frac{1}{|G|}\sum_{m\ge0} \bigl([q^m]Z_X\bigr)\,e^{mt},$$
and the ordinary generating function is the rational function $\frac{1}{|G|}\sum_{g}(1-|X^g|t)^{-1}$, whose poles are at the reciprocals of the distinct marks and whose residues encode their multiplicities. This is a third, analytic, packaging of the same rigidity: a rational function with at most $|G|$ poles is determined by finitely many Taylor coefficients.

---

## 7. Sharpness of the multiset threshold

We now show Corollary 4.4 cannot be improved: $n$ power sums do not suffice for values bounded by $n$.

**Definition 7.1 (Alternating binomial pair).** For $n\ge 0$ define multisets on $\{0,1,\dots,n\}$ by giving multiplicities:
$$\mathrm{mult}_{A_n}(k) = \begin{cases}\binom{n}{k}, & n-k \text{ even},\\ 0,&\text{otherwise,}\end{cases}
\qquad
\mathrm{mult}_{B_n}(k) = \begin{cases}\binom{n}{k}, & n-k \text{ odd},\\ 0,&\text{otherwise.}\end{cases}$$
Equivalently, $A_n$ collects the nodes where the coefficient $(-1)^{n-k}\binom{n}{k}$ of the $n$-th finite-difference operator is positive, and $B_n$ those where it is negative, with the absolute values as multiplicities.

**Example 7.2.** $A_2=\{\!\{0,2\}\!\}$, $B_2=\{\!\{1,1\}\!\}$. $A_3=\{\!\{1,1,1,3\}\!\}$, $B_3=\{\!\{0,2,2,2\}\!\}$. $A_4 = \{\!\{0,2,2,2,2,2,2,4\}\!\}$, $B_4=\{\!\{1,1,1,1,3,3,3,3\}\!\}$.

**Lemma 7.3 (Finite differences annihilate low degrees).** For $0\le j<n$,
$$\sum_{k=0}^{n}(-1)^{n-k}\binom{n}{k}k^{\,j} = 0, \qquad\text{and}\qquad \sum_{k=0}^{n}(-1)^{n-k}\binom{n}{k}k^{\,n} = n! .$$

*Proof sketch.* The left-hand sides are $(\Delta^n f)(0)$ for $f(x)=x^j$ and $f(x)=x^n$, where $\Delta f(x)=f(x+1)-f(x)$ is the forward difference and $\Delta^n f(x) = \sum_{k}(-1)^{n-k}\binom{n}{k}f(x+k)$. Since $\Delta$ lowers the degree of a polynomial by exactly one and maps the leading coefficient $c x^d$ to $dc\,x^{d-1}+\dots$, iterating $n$ times annihilates every polynomial of degree $<n$ and sends the monic $x^n$ to the constant $n!$. $\square$

**Proposition 7.4 (Properties of the pair).** For every $n\ge1$:
(i) all elements of $A_n$ and $B_n$ lie in $\{0,\dots,n\}$;
(ii) $p_j(A_n)=p_j(B_n)$ for all $j<n$;
(iii) $p_n(A_n)-p_n(B_n)=n!$, so in particular $A_n\ne B_n$;
(iv) the joint support is exactly $\{0,1,\dots,n\}$, of cardinality $n+1$.

*Proof.* (i) is by construction. For (ii) and (iii), split the sum in Lemma 7.3 by the sign of $(-1)^{n-k}$:
$$\sum_{k=0}^n(-1)^{n-k}\binom{n}{k}k^{\,j} \;=\; \sum_{k:\,n-k\ \mathrm{even}}\binom{n}{k}k^{\,j} \;-\; \sum_{k:\,n-k\ \mathrm{odd}}\binom{n}{k}k^{\,j} \;=\; p_j(A_n)-p_j(B_n).$$
For (iv): every $k\in\{0,\dots,n\}$ has $\binom{n}{k}>0$ and lands in exactly one of $A_n$, $B_n$ according to the parity of $n-k$. In particular the top value $n$ (with $n-n=0$ even) occurs in $A_n$ with multiplicity $1$ and in $B_n$ with multiplicity $0$, which reproves $A_n\ne B_n$ directly. $\square$

**Theorem 7.5 (The threshold $n+1$ is exact).** Fix $n\ge1$.
(a) (*Rigidity at the threshold.*) If $A,B$ are multisets with all elements $\le n$ and $p_k(A)=p_k(B)$ for all $k\le n$, then $A=B$.
(b) (*Failure below the threshold.*) It is **not** true that all-elements-$\le n$ plus $p_k(A)=p_k(B)$ for all $k<n$ implies $A=B$: the pair $(A_n,B_n)$ is a counterexample.

*Proof.* (a) is Corollary 4.4 with the bound $n+1$. (b) is Proposition 7.4. $\square$

**Remark 7.6.** Part (iv) of Proposition 7.4 shows the *support* threshold of Theorem 4.3 is likewise attained: the joint support of $(A_n,B_n)$ has exactly $n+1$ elements and the power sums agree for the $n$ values $k<n$, so the hypothesis "$|S|\le n$" cannot be weakened to "$|S|\le n+1$".

**Remark 7.7 (Size of the extremal pair).** $|A_n| = |B_n| = 2^{n-1}$, since $\sum_k \binom{n}{k} = 2^n$ splits evenly by parity for $n\ge1$. If such a pair is to be realised as a pair of trace distributions of $G$-sets, then by Lemma 5.5 the group must have order $2^{n-1}$. This is the starting point of the realisability question in Section 9.

---

## 8. Sharpness on the group side: Burnside's lemma is blind

The multiset counterexamples of Section 7 do not immediately produce group actions, because not every multiset of size $|G|$ is a trace distribution. We therefore record a self-contained group-theoretic obstruction showing that the range in Theorem 5.3 genuinely needs $k\ge2$.

**Lemma 8.1 (Regular action).** Let $G$ act on itself by left translation. Then $\mathrm{fix}_G(g) = |G|$ if $g=1$ and $0$ otherwise, so $\mathrm{tr}(G) = \{\!\{|G|,0,0,\dots,0\}\!\}$ and $Z_G(q)=q^{|G|}+(|G|-1)$. Consequently
$$N_0(G)=1, \qquad N_k(G) = |G|^{\,k-1}\quad (k\ge1).$$

*Proof.* Translation is free: $gx=x$ forces $g=1$. Theorem 3.3 gives $N_k\cdot|G| = |G|^k + (|G|-1)\cdot 0^k$, which equals $|G|^k$ for $k\ge1$ and $|G|$ for $k=0$. $\square$

**Lemma 8.2 (One-point action).** Let $\ast$ be a one-point $G$-set. Then $\mathrm{fix}_\ast(g)=1$ for all $g$, $\mathrm{tr}(\ast)=\{\!\{1,\dots,1\}\!\}$, $Z_\ast(q)=|G|\,q$, and $N_k(\ast)=1$ for all $k$.

*Proof.* Immediate; via Theorem 3.3, $N_k\cdot|G| = \sum_g 1^k = |G|$. $\square$

**Theorem 8.3 (No range-one theorem).** For every finite group $G$ with $|G|\ge2$, the regular $G$-set $G$ and the one-point $G$-set $\ast$ satisfy
$$N_0(G)=N_0(\ast)=1,\qquad N_1(G)=N_1(\ast)=1,\qquad N_2(G)=|G|\ne 1 = N_2(\ast),$$
and $\mathrm{tr}(G)\ne\mathrm{tr}(\ast)$. Hence the implication
$$\bigl(\forall k\le 1:\ N_k(X)=N_k(Y)\bigr) \Longrightarrow \mathrm{tr}(X)=\mathrm{tr}(Y)$$
is false in general.

*Proof.* The orbit counts are read off from Lemmas 8.1 and 8.2. The trace distributions differ since $0\in\mathrm{tr}(G)$ (as $|G|\ge2$ gives a non-identity element, which fixes nothing) while $\mathrm{tr}(\ast)$ consists of $1$'s; alternatively, they must differ by Theorem 5.2, since $N_2$ differs. Taking $G=\mathbb{Z}/2$, $X=G$, $Y=\ast$ furnishes an explicit counterexample to the range-one statement. $\square$

**Remark 8.4.** This is exactly the assertion that *Burnside's lemma alone is blind*: the transitive count $N_1$ cannot distinguish a free transitive action from a trivial one-point action. The higher grades are indispensable.

**Remark 8.5 (The case $n=2$ is realised).** For $G=\mathbb{Z}/2$, $\mathrm{tr}(G) = \{\!\{2,0\}\!\} = A_2$ and $\mathrm{tr}(\ast) = \{\!\{1,1\}\!\} = B_2$. So the smallest extremal pair of Section 7 *is* realised by genuine group actions, and their orbit spectra $1,1,2,4,8,\dots$ and $1,1,1,1,\dots$ first diverge at $k=2=n$, precisely at the threshold.

---

## 9. Algorithms

We record the computational content. Throughout, $G$ is given as a set of permutations of an $n$-element set $X$ (or as an abstract group with an action oracle).

### Algorithm A: Trace distribution

**Input:** finite $G$-set $X$, $|X|=n$, $|G|=m$.
**Output:** the multiset $\mathrm{tr}(X)$, equivalently the coefficient vector of $Z_X$.

For each $g\in G$, count $|\{x : gx=x\}|$. Cost: $O(mn)$ action evaluations. The resulting histogram $c_j = \#\{g : |X^g|=j\}$, $0\le j\le n$, is the coefficient vector of $Z_X$.

### Algorithm B: Orbit spectrum by graded Burnside

**Input:** the coefficient vector $(c_0,\dots,c_n)$ of $Z_X$; a bound $K$.
**Output:** $N_0,\dots,N_K$.

Compute $p_k = \sum_{j=0}^n c_j\,j^k$ for $k=0,\dots,K$ (Horner or repeated multiplication: $O(Kn)$ big-integer multiplications), then $N_k = p_k/m$, which is an exact integer division by Theorem 3.3.

This is exponentially faster than enumerating orbits on $X^{(k)}$ directly, which would involve $n^k$ tuples.

### Algorithm C: Deciding trace-distribution equality from orbit data

**Input:** oracles for $N_k(X)$ and $N_k(Y)$; $|G|$, $|X|$, $|Y|$.
**Output:** whether $\mathrm{tr}(X)=\mathrm{tr}(Y)$ (equivalently whether $N_k(X)=N_k(Y)$ for all $k$).

Let $K = \min(2|G|, \max(|X|,|Y|)+1)$. Query $N_k(X), N_k(Y)$ for $0\le k<K$; answer "equal" iff all queries match. Correctness is Corollary 5.7. Query complexity: $K$ pairs of queries, and $K$ never exceeds $2|G|$.

### Algorithm D: Reconstructing the trace distribution from power sums

**Input:** power sums $p_0,\dots,p_n$ of an unknown multiset with values in $\{0,\dots,n\}$.
**Output:** the multiplicities $c_0,\dots,c_n$.

The relation $p_k = \sum_j c_j j^k$ is the Vandermonde system $V^{\mathsf T} c = p$ with nodes $0,1,\dots,n$. Solve it, e.g. by Lagrange interpolation: for each node $j_0$,
$$c_{j_0} = \sum_{k=0}^{n} \lambda^{(j_0)}_k\,p_k,\qquad \text{where}\quad \sum_k \lambda^{(j_0)}_k x^k = \prod_{j\ne j_0}\frac{x-j}{j_0-j}.$$
This is precisely the proof of Lemma 4.1 made effective. Cost $O(n^2)$ rational operations (or $O(n^2)$ with exact integer arithmetic after clearing denominators); the outputs are guaranteed to be non-negative integers when the input is a genuine power-sum vector.

Applied with $p_k = N_k(X)\cdot|G|$, Algorithm D reconstructs the *entire* fixed-point histogram of an action from its first $n+1$ orbit counts — a reconstruction, not merely a comparison.

---

## 10. Worked examples

**Example 10.1 ($\mathbb{Z}/2$, regular vs. point).** As in Remark 8.5: $Z_X=q^2+1$, spectrum $1,1,2,4,8,\dots$; $Z_Y=2q$, spectrum $1,1,1,1,\dots$. Separated at $k=2$; the theoretical bound is $\max(2,1)=2$, attained.

**Example 10.2 ($S_3$ on $3$ points).** Marks: identity $3$; three transpositions $1$ each; two $3$-cycles $0$ each. So $\mathrm{tr}=\{\!\{3,1,1,1,0,0\}\!\}$, $Z(q)=q^3+3q+2$, and
$$N_k = \frac{3^k+3\cdot1^k+2\cdot 0^k}{6}: \quad 1,\;1,\;2,\;5,\;14,\;41,\dots$$
($N_1=1$: transitive; $N_2=2$: the diagonal and the off-diagonal orbital, i.e. rank $2$, as expected for a $2$-transitive group.)

More generally, for $S_n$ acting naturally on $n$ points, two $k$-tuples lie in the same orbit exactly when they induce the same partition of the index set $\{1,\dots,k\}$ into blocks of equal entries, and such a partition is realisable iff it has at most $n$ blocks; hence $N_k = \sum_{b\le n} S(k,b)$ with $S(k,b)$ a Stirling number of the second kind, which for $n\ge k$ is the Bell number $B_k$. Graded Burnside reproduces this from fixed-point statistics alone: for $S_4$ on $4$ points, $Z(q)=q^4+6q^2+8q+9$ and $N_k=(4^k+6\cdot2^k+8+9\cdot0^k)/24 = 1,1,2,5,15,51,\dots$

**Example 10.3 (Two non-isomorphic $\mathbb{Z}/4$-sets with the same spectrum).** Let $G=\mathbb{Z}/4=\{0,1,2,3\}$. Take $X = G/\{0,2\}\ \sqcup\ \ast\ \sqcup\ \ast$ (a $2$-element transitive set with kernel $\{0,2\}$, plus two fixed points) and $Y = G/\{0,2\}\ \sqcup\ G/\{0,2\}$. Marks of $X$: $g=0\mapsto 4$, $g=2\mapsto 4$, $g=1,3\mapsto 2$. Marks of $Y$: $0\mapsto4$, $2\mapsto4$, $1,3\mapsto0$. These differ, and correspondingly $Z_X=2q^4+2q^2 \ne 2q^4+2 = Z_Y$; the spectra $N_k(X) = (2\cdot4^k+2\cdot2^k)/4$ and $N_k(Y)=(2\cdot 4^k + 2\cdot 0^k)/4$ first differ at $k=1$ ($N_1(X)=3$, $N_1(Y)=2$), consistent with the theory. Non-isomorphic $G$-sets with *equal* trace distributions exist too — see Remark 10.4.

**Remark 10.4 (Equal spectra, non-isomorphic actions).** The theorem determines the trace distribution, never the action itself. Any two $G$-sets with pointwise equal marks (Gassmann-equivalent, but non-isomorphic — the classical examples occur for $G$ of order $96$ inside $\mathrm{GL}_3(\mathbb{F}_2)$-type constructions and underlie arithmetically equivalent number fields) have identical orbit spectra for every $k$. Even weaker: two $G$-sets whose mark *multisets* coincide, without matching group element to group element, have identical spectra — the invariant is genuinely unordered. Conjugating the action by an automorphism of $G$ is the simplest way to produce such a pair.

---

## 11. Discussion

**What the orbit spectrum sees, and what it does not.** The results say precisely: the map
$$\{\text{finite } G\text{-sets}\}\ \longrightarrow\ \{\text{sequences}\},\qquad X\mapsto (N_k(X))_{k\ge0}$$
factors through the trace distribution, injectively on trace distributions, and the factorisation is detected by a finite initial segment. The invariant is therefore strictly coarser than the isomorphism type of the $G$-set (Remark 10.4) and strictly coarser than the permutation character (which remembers *which* $g$ has which mark), but no coarser than the multiset of marks.

**Comparison with the moment problem.** The trace distribution defines a probability measure $\mu_X$ on $\mathbb{N}$ by $\mu_X(\{m\}) = \frac{1}{|G|}\#\{g:|X^g|=m\}$, and $N_k(X) = \int x^k\,d\mu_X$ is exactly the $k$-th moment. The main theorem is then a determinacy statement for this discrete moment problem, with an effective and optimal number of moments. Contrast the classical Hamburger/Stieltjes setting, where moment sequences need not determine a measure. The finiteness of the support (at most $|G|$ atoms, all in $\{0,\dots,|X|\}$) is what makes determinacy effective; the two thresholds $2|G|$ and $\max(|X|,|Y|)+1$ correspond to bounding the number of atoms versus bounding their location.

**Effectivity.** Algorithm B turns an apparently exponential enumeration ($n^k$ tuples) into an $O(Kn)$ arithmetic computation. Algorithm D turns comparison into reconstruction. The pole/residue reading of Remark 6.5 offers a third, numerically stable route via rational-function fitting (Padé/Berlekamp–Massey): the ordinary generating function $\sum_k N_k t^k$ is a rational function of degree at most $|G|$ in the denominator, so $2|G|$ coefficients determine it — an independent confirmation of the threshold in Theorem 5.6, since Berlekamp–Massey requires exactly twice the linear-recurrence order.

**Sharpness, two ways.** Theorem 7.5 shows the combinatorial threshold is exactly $n+1$ for values bounded by $n$; Theorem 8.3 shows that within the world of actual group actions one cannot get away with $k\le1$. The gap between these — whether the extremal multiset pairs are realisable as pairs of trace distributions for every $n$ — is the content of the realisability problem below.

---

## 12. Future directions

### 12.1 Pointwise (Gassmann) refinement from cyclic restrictions

The trace distribution forgets the labelling by group elements. One can hope to recover it by running the theorem inside every cyclic subgroup. The key observation is that $X^g = X^{\langle g\rangle}$, so applying the main theorem to $C=\langle g\rangle$ returns the multiset $\{\!\{|X^h| : h\in C\}\!\}$, which is naturally graded by the *order* of $h$. Möbius inversion over the divisor lattice of $|C|$ (a chain-like poset for cyclic groups) should convert this graded family of unordered data into pointwise data.

> **Conjecture (marks rigidity).** Let $G$ be finite and $X,Y$ finite $G$-sets. If for every cyclic subgroup $C\le G$ and every $k\le 2|C|$ the numbers of $C$-orbits on $X^{(k)}$ and $Y^{(k)}$ agree, then $|X^g|=|Y^g|$ for every $g\in G$; i.e. $X$ and $Y$ are Gassmann equivalent.

A first test case is $G=\mathbb{Z}/4$ with $X = G/\langle2\rangle \sqcup \ast \sqcup \ast$ and $Y = G \sqcup \ast$: do the cyclic restrictions already separate them?

### 12.2 Realisability of the extremal pair

> **Conjecture (exact threshold for group actions).** For every $n$ there exist a finite group $G$ and finite $G$-sets $X,Y$ with $\max(|X|,|Y|)=n$ whose orbit counts on $k$-tuples agree for all $k<n$ but differ at $k=n$.

By Remark 7.7 a natural candidate is $|G|=2^{n-1}$ with the alternating binomial pair realised as trace distributions; elementary abelian $2$-groups and symmetric groups are the obvious places to look. A multiset of size $|G|$ is a trace distribution exactly when it is the mark vector of a non-virtual element of the Burnside ring, i.e. satisfies a lattice-point condition on the table of marks. The case $n=2$ is realised (Remark 8.5). The case $n=3$ shows the subtlety: the alternating binomial pair is $\mathrm{tr}(X)=\{\!\{1,1,1,3\}\!\}$, $\mathrm{tr}(Y)=\{\!\{0,2,2,2\}\!\}$, forcing $|G|=4$, $|X|=3$, $|Y|=2$. But a group of order $4$ acting on $3$ points must decompose as $1+1+1$ or $1+2$, giving mark multisets $\{\!\{3,3,3,3\}\!\}$ or $\{\!\{3,3,1,1\}\!\}$ — never $\{\!\{1,1,1,3\}\!\}$; similarly a $4$-group on $2$ points gives $\{\!\{2,2,2,2\}\!\}$ or $\{\!\{2,2,0,0\}\!\}$, never $\{\!\{0,2,2,2\}\!\}$. So for $n=3$ the *specific* binomial pair is not realisable, and the conjecture asks for some other extremal pair — which is precisely what makes it non-trivial.

### 12.3 Further questions

- **Infinite sets.** For oligomorphic groups the sequence $N_k$ is the profile of the group. Is there a rigidity phenomenon there, with the trace distribution replaced by a measure on a compactification?
- **Weighted/coloured versions.** Replacing $X^{(k)}$ by $k$-subsets or by $k$-tuples with a colouring gives cycle-index-type refinements. Does the corresponding rigidity statement hold with a comparable threshold?
- **Complexity.** Given two permutation groups by generators, how hard is it to decide trace-distribution equality? Algorithm C reduces it to $2|G|$ orbit counts, but $|G|$ can be exponential in the degree; is there a polynomial-time test?
- **Stability.** If $N_k(X)$ and $N_k(Y)$ agree only approximately over the window, how close must the trace distributions be? The Vandermonde conditioning in Algorithm D suggests an exponentially bad but explicit bound; sharpening it is a concrete analytic problem.

---

## 13. Conclusion

The number of orbits on $k$-tuples, for $k$ in an explicitly bounded finite window, determines the entire multiset of fixed-point counts of a finite group action — and hence the number of orbits on $k$-tuples for every $k$. The mechanism is a single structural identity, graded Burnside, which identifies the orbit spectrum with the power sums of the trace distribution, coupled with an interpolation-duality rigidity theorem for multisets. The thresholds $\max(|X|,|Y|)+1$ and $2|G|$ are both effective, and both are sharp in the appropriate sense. The resulting picture is a clean, optimal, discrete moment theorem for finite group actions.
