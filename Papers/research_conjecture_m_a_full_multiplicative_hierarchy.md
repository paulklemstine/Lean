# The Multiplicative Hierarchy of the Injective-Orbit Spectrum

**Aristotle**

*October 2026*

---

## Abstract

Let a group $G$ act on a finite set $X$ with $|X| = n$, and let $t_r$ be the number of $G$-orbits on injective $r$-tuples of $X$. We study how the terms of the sequence $(t_r)_{r \ge 0}$ constrain one another. Cutting an injective $(r+s)$-tuple into its first $r$ and last $s$ coordinates exhibits the orbits at level $r+s$ as fibred over the orbits at level $r$. The fibre over the orbit of $u$ is the orbit space of the pointwise stabiliser $\mathrm{Stab}(u)$ acting on the injective $s$-tuples that avoid $u$. This gives an **exact fibration formula**
$$t_{r+s} = \sum_{[u]} \#\big(\mathrm{Stab}(u)\backslash \mathrm{Inj}_s(X \setminus u)\big).$$
Estimating each fibre from both sides yields the **multiplicative hierarchy**
$$t_r\,(t_1 - r)^{\underline{s}} \;\le\; t_{r+s} \;\le\; t_r\,(n - r)^{\underline{s}},$$
whose lower bound is attained by trivial actions and whose upper bound is attained whenever injective $r$-tuples have trivial stabilisers. A refined lower bound in terms of avoidance counts is also proved. Finally we show that the natural coarse conjecture $t_{r+s} \ge t_r\,(t_s - r)$ is **false**; the smallest counterexample is the trivial group on three points with $(r, s) = (1, 2)$. We prove the corrected statement in which the correction $r$ is replaced by $n^{\underline{s}} - (n - r)^{\underline{s}}$, the number of injective $s$-tuples meeting a fixed injective $r$-tuple. Throughout we also describe $t_r$ as the multiplicity of the discrete equality pattern among the orbits of all $r$-tuples, which connects this spectrum to the decomposition of tuple-orbit counts by kernel patterns.

---

## 1. Introduction

Counting objects up to symmetry is one of the oldest themes in combinatorics. Burnside's lemma, Pólya's enumeration theorem and the theory of $k$-transitive permutation groups all count orbits of a group on configurations built from a finite set. A basic family of configurations is the **injective tuples**: ordered lists $(x_1, \dots, x_r)$ of pairwise distinct points. The number of orbits on them,
$$t_r = t_r(G, X) = \#\big(G \backslash \mathrm{Inj}_r(X)\big),$$
is the **injective-orbit spectrum** of the action. It records how transitive the action is at each level: $G$ is $r$-transitive exactly when $t_r = 1$, while the trivial action has the largest possible value $t_r = n^{\underline{r}} = n(n-1)\cdots(n-r+1)$.

This paper answers the question of how much $t_{r+s}$ is controlled by $t_r$ and by $t_1$. The guiding observation is that cutting an injective tuple into a head and a tail gives a fibration. It is $G$-equivariant, so it descends to orbit spaces, and the fibres of the descended map can be identified exactly. All of our results follow from this identification combined with elementary estimates on the fibres.

### Summary of results

Let $n = |X|$ and let $m^{\underline{s}}$ denote the falling factorial (Section 2).

1. **Exact fibration formula (Theorem 3.2).** $t_{r+s} = \sum_{[u]} c(u, s)$, where $c(u,s)$ is the number of $\mathrm{Stab}(u)$-orbits on injective $s$-tuples avoiding $u$.
2. **Refined hierarchy (Theorem 4.2).** $\sum_{[u]} a([u], s) \le t_{r+s}$, where $a([u],s)$ is the number of $G$-orbits of injective $s$-tuples that contain a tuple disjoint from $u$. Consequently $t_{r+s} \ge t_r \cdot m$ whenever every $a([u], s) \ge m$.
3. **One-step inequality (Theorem 4.4).** $t_{r+1} \ge t_r\,(t_1 - r)$.
4. **Multiplicative hierarchy and sandwich (Theorems 4.5 and 4.7).** $t_r\,(t_1 - r)^{\underline{s}} \le t_{r+s} \le t_r\,(n - r)^{\underline{s}}$; in particular $t_s \ge t_1^{\underline{s}}$.
5. **Sharpness (Theorems 5.1 and 5.2).** Trivial actions make every inequality of the hierarchy an equality; if every injective $r$-tuple has trivial stabiliser, then $t_{r+s} = t_r\,(n - r)^{\underline{s}}$.
6. **Failure of the coarse form (Theorem 6.1)** and **its repair (Theorem 6.3).** The inequality $t_{r+s} \ge t_r(t_s - r)$ fails in general, even under the natural restriction $r + s \le n$. The inequality $t_{r+s} \ge t_r\big(t_s - (n^{\underline{s}} - (n-r)^{\underline{s}})\big)$ always holds.

---

## 2. Setting and notation

Throughout, $G$ is a group acting on a finite set $X$, and $n = |X|$. The group need not be finite, but it acts through the finite symmetric group of $X$, so only finitely many permutations occur.

**Natural-number subtraction.** All counts are natural numbers. We write $a - b$ for **truncated subtraction**, $a - b = \max(a - b, 0)$, whenever both arguments are natural numbers.

**Definition 2.1 (Falling factorial).** For natural numbers $m$ and $s$,
$$m^{\underline{s}} = m\,(m-1)\,(m-2)\cdots(m-s+1) = \prod_{i=0}^{s-1} (m - i),$$
with $m^{\underline{0}} = 1$. With truncated subtraction, $m^{\underline{s}} = 0$ when $s > m$. The recursion $m^{\underline{s+1}} = m^{\underline{s}}\,(m - s)$ holds for all $m, s$, and so does the splitting $m^{\underline{r+s}} = m^{\underline{r}}\,(m - r)^{\underline{s}}$.

**Definition 2.2 (Injective tuples).** For a subset $Y \subseteq X$ and $r \ge 0$, let $\mathrm{Inj}_r(Y)$ be the set of injective maps $\{1, \dots, r\} \to Y$, i.e. ordered $r$-tuples of pairwise distinct elements of $Y$. Then $|\mathrm{Inj}_r(Y)| = |Y|^{\underline{r}}$.

The group acts diagonally on tuples, $g \cdot (x_1, \dots, x_r) = (g x_1, \dots, g x_r)$. This action preserves injectivity, so $G$ acts on $\mathrm{Inj}_r(X)$.

**Definition 2.3 (Spectrum).** The *injective-orbit spectrum* is
$$t_r = \#\big(G \backslash \mathrm{Inj}_r(X)\big), \qquad r \ge 0.$$
We have $t_0 = 1$ (the empty tuple), $t_1$ is the number of $G$-orbits on $X$, and $t_r = 0$ for $r > n$. Moreover $t_n = t_{n-1}$ when $n \ge 1$, because an injective $(n-1)$-tuple extends uniquely to an injective $n$-tuple.

**Definition 2.4 (Stabiliser, avoiding tuples).** For $u \in \mathrm{Inj}_r(X)$ write $\mathrm{im}(u) = \{u_1, \dots, u_r\}$ and $X \setminus u = X \setminus \mathrm{im}(u)$. The *stabiliser* of $u$ is the subgroup
$$\mathrm{Stab}(u) = \{ g \in G : g \cdot u = u \} = \{g \in G : g u_i = u_i \text{ for all } i\}.$$
A tuple $v$ *avoids* $u$ if $\mathrm{im}(v) \cap \mathrm{im}(u) = \varnothing$, i.e. $v \in \mathrm{Inj}_s(X \setminus u)$. Since $\mathrm{Stab}(u)$ fixes $\mathrm{im}(u)$ pointwise, it preserves $X \setminus u$ and hence acts on $\mathrm{Inj}_s(X \setminus u)$.

**Definition 2.5 (Relative count).** For $u \in \mathrm{Inj}_r(X)$ and $s \ge 0$,
$$c(u, s) = \#\big(\mathrm{Stab}(u) \backslash \mathrm{Inj}_s(X \setminus u)\big).$$

**Definition 2.6 (Avoidance count).** For an orbit $o = [u] \in G\backslash\mathrm{Inj}_r(X)$ and $s \ge 0$, let $a(o, s)$ be the number of $G$-orbits $O \in G \backslash \mathrm{Inj}_s(X)$ that contain at least one tuple avoiding $u$.

**Lemma 2.7.** Both $c(u,s)$ and $a([u], s)$ depend only on the orbit $[u]$.

*Proof.* If $u' = g u$, then $\mathrm{Stab}(u') = g\,\mathrm{Stab}(u)\,g^{-1}$ and $v \mapsto g v$ is a bijection $\mathrm{Inj}_s(X \setminus u) \to \mathrm{Inj}_s(X \setminus u')$ that carries $\mathrm{Stab}(u)$-orbits to $\mathrm{Stab}(u')$-orbits. This gives $c(u,s) = c(u',s)$. For $a$: a $G$-orbit $O$ contains a tuple $v$ avoiding $u$ iff it contains $g v$, which avoids $g u$. $\square$

### 2.1 The spectrum as a pattern multiplicity

Every $r$-tuple $f : \{1,\dots,r\} \to X$, injective or not, has a **kernel pattern**: the partition of $\{1, \dots, r\}$ into the classes $\{i : f(i) = x\}$, $x \in \mathrm{im}(f)$. The pattern is $G$-invariant, since $g$ is injective on $X$ and so $g f(i) = g f(j) \iff f(i) = f(j)$. Hence every orbit $o$ of $r$-tuples has a well-defined pattern, and the orbits of all $r$-tuples are partitioned by pattern. The **discrete pattern** is the partition of $\{1,\dots,r\}$ into singletons.

**Proposition 2.8 (Dictionary).** An orbit of $r$-tuples has the discrete pattern iff it consists of injective tuples. Consequently, $t_r$ equals the number of orbits of $r$-tuples whose pattern is discrete; that is, $t_r$ is the multiplicity of the discrete pattern in the decomposition of $G \backslash X^r$ by kernel patterns.

*Proof.* A tuple $f$ is injective iff its kernel pattern is discrete. If an orbit contains one injective tuple, all its members $g f$ are injective, because $g$ is a bijection of $X$. The map from orbits of injective tuples to orbits of $r$-tuples with discrete pattern is therefore a bijection. $\square$

Because of this dictionary, every result below can be read either as a statement about orbits of injective tuples or as a statement about the discrete layer of the pattern decomposition of $G \backslash X^r$.

---

## 3. The exact fibration formula

**Definition 3.1 (Restriction and concatenation).** For $r, s \ge 0$, the *restriction* map
$$\rho : \mathrm{Inj}_{r+s}(X) \to \mathrm{Inj}_r(X), \qquad (x_1, \dots, x_{r+s}) \mapsto (x_1, \dots, x_r)$$
forgets the last $s$ coordinates. For $u \in \mathrm{Inj}_r(X)$ and $v \in \mathrm{Inj}_s(X \setminus u)$, the *concatenation* $u \cdot v = (u_1, \dots, u_r, v_1, \dots, v_s)$ is an injective $(r+s)$-tuple with $\rho(u \cdot v) = u$. Conversely every $w$ with $\rho(w) = u$ is uniquely of the form $u \cdot v$ with $v$ avoiding $u$.

The map $\rho$ is $G$-equivariant, $\rho(g w) = g \rho(w)$, so it induces a map $\bar\rho : G\backslash \mathrm{Inj}_{r+s}(X) \to G \backslash \mathrm{Inj}_r(X)$.

**Theorem 3.2 (Exact fibration formula).** For every $r, s \ge 0$ and every orbit $o = [u]$ of injective $r$-tuples, the map
$$\Phi_u : \mathrm{Stab}(u) \backslash \mathrm{Inj}_s(X \setminus u) \longrightarrow \bar\rho^{-1}(o), \qquad \mathrm{Stab}(u)\, v \longmapsto [u \cdot v]$$
is a well-defined bijection. Consequently, choosing one representative $u$ in each orbit,
$$t_{r+s} \;=\; \sum_{[u] \in G \backslash \mathrm{Inj}_r(X)} c(u, s).$$

*Proof.* *Well defined:* if $v' = h v$ with $h \in \mathrm{Stab}(u)$, then $u \cdot v' = h u \cdot h v = h\,(u \cdot v)$, so the two concatenations lie in the same $G$-orbit, and this orbit lies over $[u]$.

*Surjective:* let $W = [w]$ lie over $o$, so $\rho(w) = g u$ for some $g$. Then $g^{-1} w$ has head $u$, so $g^{-1}w = u \cdot v$ for some $v$ avoiding $u$, and $\Phi_u(\mathrm{Stab}(u) v) = W$.

*Injective:* if $[u \cdot v] = [u \cdot v']$, choose $g$ with $g(u \cdot v) = u \cdot v'$. Comparing the first $r$ coordinates gives $g u = u$, so $g \in \mathrm{Stab}(u)$; comparing the last $s$ gives $g v = v'$.

The orbit set $G \backslash \mathrm{Inj}_{r+s}(X)$ is the disjoint union of the fibres $\bar\rho^{-1}(o)$, each of size $c(u,s)$ by the bijection. Summing over $o$ gives the formula. $\square$

**Remark 3.3.** For $r = 0$ the stabiliser of the empty tuple is $G$, the avoiding tuples are all of $\mathrm{Inj}_s(X)$, and the formula reduces to $t_s = t_s$. For $s = 0$ each fibre is a single point and the formula reads $t_r = t_r$. The content is in the mixed range $r, s \ge 1$.

**Example 3.4 (The square).** Let $G = D_4$, the symmetry group of order $8$ of a square, act on its vertices $\{0,1,2,3\}$ in cyclic order. All vertices are equivalent, so $t_1 = 1$. The stabiliser of $u = (0)$ is $\{1, \sigma\}$, where $\sigma$ is the reflection fixing $0$ and $2$ and swapping $1$ and $3$. The $6$ injective pairs from $\{1,2,3\}$ form $3$ orbits under $\sigma$: $\{(1,2),(3,2)\}$, $\{(2,1),(2,3)\}$ and $\{(1,3),(3,1)\}$. Hence $t_3 = c((0), 2) = 3$. Indeed $D_4$ acts freely on the $24$ injective triples, and $24/8 = 3$.

---

## 4. The multiplicative hierarchy

### 4.1 Lower estimate of a fibre

**Proposition 4.1.** For every $u \in \mathrm{Inj}_r(X)$ and $s \ge 0$, $a([u], s) \le c(u, s)$.

*Proof.* Inclusion $\mathrm{Stab}(u) \le G$ induces a map
$$\mathrm{Stab}(u) \backslash \mathrm{Inj}_s(X \setminus u) \to G \backslash \mathrm{Inj}_s(X), \qquad \mathrm{Stab}(u)\,v \mapsto G v.$$
Its image is exactly the set of $G$-orbits containing a tuple that avoids $u$, which has $a([u], s)$ elements. A finite set maps onto its image, so $c(u, s) \ge a([u], s)$. $\square$

**Theorem 4.2 (Refined hierarchy).** For all $r, s \ge 0$,
$$\sum_{[u] \in G \backslash \mathrm{Inj}_r(X)} a([u], s) \;\le\; t_{r+s}.$$
In particular, if $m$ is a natural number with $a(o, s) \ge m$ for every orbit $o$ of injective $r$-tuples, then
$$t_r \cdot m \;\le\; t_{r+s}.$$

*Proof.* Combine Theorem 3.2 with Proposition 4.1 termwise. The second statement follows because the sum has $t_r$ terms, each at least $m$. $\square$

**Remark 4.3.** The refined form can also be seen directly, without the fibration. Choose a representative $u_o$ of each orbit $o$ and, for each $G$-orbit $O$ of $s$-tuples that meets $\mathrm{Inj}_s(X \setminus u_o)$, a representative $v_{o,O}$ avoiding $u_o$. Then $(o, O) \mapsto [u_o \cdot v_{o,O}]$ is injective: the first $r$ coordinates recover $o$, and the last $s$ coordinates recover $O$.

### 4.2 The one-step inequality

**Theorem 4.4 (One step).** For every $r \ge 0$ and $u \in \mathrm{Inj}_r(X)$, $a([u], 1) \ge t_1 - r$. Consequently
$$t_{r+1} \;\ge\; t_r\,(t_1 - r).$$

*Proof.* The $G$-orbits on $X$ partition $X$. An orbit $O \subseteq X$ fails to contain a point avoiding $u$ only if $O \subseteq \mathrm{im}(u)$, and then $O$ contains at least one of the $r$ points $u_1,\dots,u_r$. Distinct orbits are disjoint, so at most $r$ orbits are contained in $\mathrm{im}(u)$, and at least $t_1 - r$ orbits contain a point avoiding $u$. Apply Theorem 4.2 with $s = 1$ and $m = t_1 - r$. $\square$

### 4.3 Iteration

**Theorem 4.5 (Multiplicative hierarchy).** For all $r, s \ge 0$,
$$t_{r+s} \;\ge\; t_r \cdot (t_1 - r)^{\underline{s}} = t_r\,(t_1 - r)(t_1 - r - 1)\cdots(t_1 - r - s + 1).$$

*Proof.* Induction on $s$. For $s = 0$ both sides equal $t_r$. Assume the claim for $s$. By Theorem 4.4 at level $r + s$ and the induction hypothesis,
$$t_{r+s+1} \ge t_{r+s}\,(t_1 - (r+s)) \ge t_r\,(t_1 - r)^{\underline{s}}\,\big((t_1 - r) - s\big) = t_r\,(t_1 - r)^{\underline{s+1}},$$
using $t_1 - (r + s) = (t_1 - r) - s$ for truncated subtraction and the recursion of Definition 2.1. $\square$

**Corollary 4.6 (Base case).** For every $s \ge 0$, $t_s \ge t_1^{\underline{s}}$.

In words, if the points fall into $k$ orbits, there are at least $k^{\underline{s}}$ orbits of injective $s$-tuples. Tuples whose entries come from pairwise distinct orbits, in different orders of orbits, can never be identified.

### 4.4 The upper estimate and the sandwich

**Theorem 4.7 (Sandwich).** For all $r, s \ge 0$,
$$t_r\,(t_1 - r)^{\underline{s}} \;\le\; t_{r+s} \;\le\; t_r\,(n - r)^{\underline{s}}.$$

*Proof.* The lower bound is Theorem 4.5. For the upper bound, $c(u, s) \le |\mathrm{Inj}_s(X \setminus u)| = (n - r)^{\underline{s}}$, because the orbit map from a finite set onto its orbit space is surjective. Summing over the $t_r$ orbits in Theorem 3.2 gives the claim. $\square$

**Remark 4.8 (Transitive actions).** If $G$ is transitive ($t_1 = 1$) and $r \ge 1$, the lower bound is $0$ for $s \ge 1$ and carries no information. In this regime the exact formula and the upper bound remain informative. For instance, the upper bound gives $t_{1+s} \le (n-1)^{\underline{s}}$ for transitive actions.

---

## 5. Sharpness

**Theorem 5.1 (Trivial actions).** If $g x = x$ for all $g \in G$ and $x \in X$, then $t_r = n^{\underline{r}}$ for every $r$. Every inequality of the hierarchy is an equality:
$$t_{r+s} = t_r\,(t_1 - r)^{\underline{s}} = t_r\,(n - r)^{\underline{s}}.$$

*Proof.* Every orbit is a singleton, so $t_r = |\mathrm{Inj}_r(X)| = n^{\underline{r}}$ and $t_1 = n$. The identity is the splitting $n^{\underline{r+s}} = n^{\underline{r}}\,(n-r)^{\underline{s}}$. $\square$

**Theorem 5.2 (Free actions saturate the fibration).** Fix $r$. If every injective $r$-tuple has trivial stabiliser (that is, $g u = u$ with $u$ injective implies $g = 1$), then for every $s \ge 0$
$$t_{r+s} = t_r\,(n - r)^{\underline{s}}.$$

*Proof.* Each $\mathrm{Stab}(u)$ is trivial, so $c(u, s) = |\mathrm{Inj}_s(X \setminus u)| = (n - r)^{\underline{s}}$. Apply Theorem 3.2. $\square$

**Example 5.3.** The cyclic group $C_n$ of rotations acts regularly on the vertices of an $n$-gon, so for every $r \ge 1$ every injective $r$-tuple has trivial stabiliser and $t_r = n^{\underline{r}}/n$. Theorem 5.2 with $r = 1$ gives $t_{1+s} = (n-1)^{\underline{s}}$. For $n = 6$ the spectrum is $(1, 1, 5, 20, 60, 120, 120)$. The dihedral group $D_6$ of order $12$ has spectrum $(1, 1, 3, 10, 30, 60, 60)$, strictly between the bounds $0$ and $5^{\underline{s}}$ for $r = 1$ and $1 \le s \le 4$. Strictness comes from reflections, which fix pairs of opposite vertices or no vertex at all, so some injective pairs have stabiliser of order $2$.

---

## 6. The coarse conjecture and its repair

The one-step inequality $t_{r+1} \ge t_r(t_1 - r)$ suggests the **coarse conjecture**
$$t_{r+s} \;\ge\; t_r\,(t_s - r) \qquad (r + s \le n). \tag{C}$$
It holds for $s = 0$ trivially and for $s = 1$ by Theorem 4.4.

**Theorem 6.1.** Inequality (C) is false in general. For the trivial group acting on a $3$-element set, with $r = 1$ and $s = 2$, we have $t_3 = 6$ while $t_1\,(t_2 - 1) = 3 \cdot 5 = 15$.

*Proof.* By Theorem 5.1, $t_1 = 3$, $t_2 = 3 \cdot 2 = 6$ and $t_3 = 3 \cdot 2 \cdot 1 = 6$, and $6 < 15$. $\square$

**Remark 6.2.** The failure is not special to trivial groups. For the regular action of $C_5$ on five points, $t = (1, 1, 4, 12, 24, 24)$, and with $(r, s) = (2, 3)$ we get $t_5 = 24 < t_2\,(t_3 - 2) = 4 \cdot 10 = 40$. For trivial actions on $n$ points, a direct computation shows that (C) fails for every $(r, s)$ with $r, s \ge 1$, $s \ge 2$ and $r + s \le n$ when $n \le 5$.

The heuristic behind (C) is that "a fixed $r$-tuple can obstruct at most $r$ orbits of $s$-tuples". This is correct for $s = 1$ but wrong for larger $s$: a single point obstructs every orbit all of whose members pass through it. The correct count of obstructions is the number of tuples meeting $u$.

**Theorem 6.3 (Repaired coarse inequality).** For all $r, s \ge 0$,
$$t_{r+s} \;\ge\; t_r \cdot \Big(t_s - \big(n^{\underline{s}} - (n - r)^{\underline{s}}\big)\Big).$$
For $s = 1$ the correction equals $n - (n - r) = r$ (when $r \le n$), and the inequality reduces to Theorem 4.4.

*Proof.* Fix $u \in \mathrm{Inj}_r(X)$. Let $B$ be the set of $G$-orbits of injective $s$-tuples containing **no** tuple that avoids $u$, so that $a([u], s) = t_s - |B|$. Every member of an orbit in $B$ meets $\mathrm{im}(u)$. Choose one member $v_O$ of each $O \in B$. Distinct orbits are disjoint, so $O \mapsto v_O$ is an injection of $B$ into the set of injective $s$-tuples meeting $\mathrm{im}(u)$. That set has $n^{\underline{s}} - (n - r)^{\underline{s}}$ elements: all injective $s$-tuples minus those avoiding $u$. Hence
$$a([u], s) \ge t_s - \big(n^{\underline{s}} - (n - r)^{\underline{s}}\big),$$
and Theorem 4.2 finishes the proof. $\square$

In the counterexample of Theorem 6.1 the correction is $3^{\underline 2} - 2^{\underline 2} = 6 - 2 = 4$, and the repaired bound $3 \cdot (6 - 4) = 6$ is attained.

---

## 7. Examples

The following spectra were computed by direct enumeration of orbits of injective tuples. All the inequalities of Sections 3–6 were checked against them for every $r + s \le n$.

| Action | $n$ | $\lvert G\rvert$ | $(t_0, t_1, \dots, t_n)$ |
|---|---|---|---|
| trivial | $4$ | $1$ | $(1, 4, 12, 24, 24)$ |
| cyclic $C_5$ (regular) | $5$ | $5$ | $(1, 1, 4, 12, 24, 24)$ |
| dihedral $D_4$ on a square | $4$ | $8$ | $(1, 1, 2, 3, 3)$ |
| dihedral $D_5$ on a pentagon | $5$ | $10$ | $(1, 1, 2, 6, 12, 12)$ |
| cyclic $C_6$ (regular) | $6$ | $6$ | $(1, 1, 5, 20, 60, 120, 120)$ |
| dihedral $D_6$ on a hexagon | $6$ | $12$ | $(1, 1, 3, 10, 30, 60, 60)$ |
| symmetric $S_4$ | $4$ | $24$ | $(1, 1, 1, 1, 1)$ |
| $C_2 \times C_2$ swapping $\{0,1\}$ and $\{2,3\}$, fixing $4$ | $5$ | $4$ | $(1, 3, 8, 18, 30, 30)$ |

For the last action $t_1 = 3$. Corollary 4.6 predicts $t_2 \ge 3 \cdot 2 = 6$ (actual value $8$) and $t_3 \ge 3 \cdot 2 \cdot 1 = 6$ (actual value $18$). The one-step bound at $r = 1$ predicts $t_2 \ge t_1(t_1 - 1) = 6$, and the upper bound gives $t_2 \le t_1 (n-1) = 12$.

As a consistency check, all spectra satisfy the classical consequence of Burnside's lemma
$$|G|\, t_r = \sum_{g \in G} \mathrm{fix}(g)^{\underline{r}},$$
which holds because $g$ fixes an injective tuple iff it fixes each entry. For example, for $D_4$ and $r = 2$: the identity contributes $4^{\underline 2} = 12$, the two diagonal reflections contribute $2^{\underline 2} = 2$ each, and every other element fixes at most one point and contributes $0$. This gives $16 = 8 \cdot 2$.

---

## 8. Algorithms

**Algorithm A (orbit counting by canonical forms).** Input: a list of the permutations of $G$ on $X = \{0,\dots,n-1\}$ and $r$. For each $u \in \mathrm{Inj}_r(X)$ compute the canonical form $\kappa(u) = \min_{g \in G} g \cdot u$ in lexicographic order. Return the number of distinct canonical forms. Correctness: $\kappa$ is constant on orbits and $\kappa(u) \in G u$, so distinct orbits have distinct canonical forms. Cost: $O(|G| \cdot n^{\underline{r}} \cdot r)$ time and $O(t_r)$ memory for the set of forms. Burnside's formula above gives an alternative costing $O(|G| \cdot n)$, which is preferable when only $t_r$ is needed.

**Algorithm B (fibration decomposition).** Input: $G$, $r$, $s$. Compute representatives $u$ of the orbits of $\mathrm{Inj}_r(X)$ by Algorithm A. For each $u$, compute $\mathrm{Stab}(u) = \{g : g u = u\}$, enumerate $\mathrm{Inj}_s(X \setminus u)$, and count $\mathrm{Stab}(u)$-orbits by canonical forms (giving $c(u,s)$) and $G$-orbits (giving $a([u], s)$). Output the table $(u, |\mathrm{Stab}(u)|, c(u,s), a([u],s))$. By Theorem 3.2 the column $c$ sums to $t_{r+s}$, and by Proposition 4.1 the column $a$ is dominated by it termwise. Cost: $O\big(t_r \cdot |G| \cdot (n - r)^{\underline{s}} \cdot s\big)$ plus the cost of Algorithm A.

**Algorithm C (hierarchy certificate).** Given only the spectrum $(t_0, \dots, t_n)$ and $n$, evaluate for every pair $r + s \le n$ the lower bound $t_r (t_1 - r)^{\underline{s}}$, the upper bound $t_r (n-r)^{\underline{s}}$, the coarse value $t_r(t_s - r)$ and the repaired value $t_r\big(t_s - (n^{\underline{s}} - (n-r)^{\underline{s}})\big)$. Report violations. By Theorems 4.7 and 6.3, a spectrum that violates the sandwich or the repaired inequality cannot come from any group action, so Algorithm C is a cheap necessary test for a sequence to be realisable as an injective-orbit spectrum. Cost: $O(n^2)$ arithmetic operations.

---

## 9. Discussion

**The fibration viewpoint.** The essential step is Theorem 3.2, which turns a global orbit count into a sum of local orbit counts for smaller groups acting on smaller sets. The two estimates of each local count, from below by whole-group orbits (Proposition 4.1) and from above by the size of the set (Theorem 4.7), give the two sides of the sandwich. Theorems 5.1 and 5.2 show that neither estimate can be improved without further hypotheses.

**Relation to transitivity.** For a $k$-transitive group ($t_k = 1$), the upper bound gives no restriction from level $k$ upward beyond $t_{k+s} \le (n-k)^{\underline{s}}$. Applied with $r = 0$ and $G$ finite, the orbit–stabiliser theorem gives the classical divisibility $n^{\underline{k}} \mid |G|$ for $k$-transitive groups: $\mathrm{Inj}_k(X)$ is a single orbit, so its size $n^{\underline{k}}$ equals the index of a stabiliser. The fibration formula refines this. Above a single orbit of heads, the count of orbits at the next levels is governed entirely by one stabiliser acting on the complement.

**Coarse versus refined.** The failure of (C) is instructive. The quantity subtracted from $t_s$ must bound the number of $s$-orbits that a fixed $r$-tuple can obstruct, and an $r$-tuple obstructs orbits through any of its points in any coordinate position. The refined statement (Theorem 4.2) avoids this difficulty by working with the avoidance counts directly. The repaired coarse inequality (Theorem 6.3) is the uniform consequence obtained by bounding obstructed orbits by obstructing tuples.

**Pattern decomposition.** By Proposition 2.8, all results concern the discrete layer of the decomposition of $G \backslash X^r$ by kernel patterns. Orbits with a non-discrete pattern $\pi$ correspond bijectively to orbits of injective tuples of length equal to the number of blocks of $\pi$. The whole orbit count therefore decomposes as $\#(G\backslash X^r) = \sum_{k} S(r, k)\, t_k$, where $S(r, k)$ is the Stirling number of the second kind. The hierarchy for $(t_k)$ thus gives two-sided estimates for the orbit counts of all tuples.

---

## 10. Future work

1. **Burnside form of the relative count.** For finite $G$ we expect
$$c(u, s) = \frac{1}{|\mathrm{Stab}(u)|} \sum_{h \in \mathrm{Stab}(u)} (\mathrm{fix}(h) - r)^{\underline{s}}.$$
Each $h \in \mathrm{Stab}(u)$ fixes the $r$ entries of $u$, so it has exactly $\mathrm{fix}(h) - r$ fixed points off $u$, and the injective tuples it fixes among those avoiding $u$ are the injective tuples in that set. Summed over orbits this should recover $|G|\,t_{r+s} = \sum_g \mathrm{fix}(g)^{\underline{r+s}}$.
2. **Equality in the upper bound.** For $s \ge 1$ and $r + s \le n$, conjecturally $t_{r+s} = t_r\,(n-r)^{\underline{s}}$ holds iff, for every injective $r$-tuple $u$, the stabiliser $\mathrm{Stab}(u)$ acts freely on $\mathrm{Inj}_s(X \setminus u)$. The "if" direction holds by the argument of Theorem 5.2. The converse should follow from a fibrewise count on the orbit map.
3. **Rigidity of the lower bound.** Conjecturally, equality $t_{r+s} = t_r\,(t_1 - r)^{\underline{s}}$ for all $r + s \le n$ holds iff the action is trivial.
4. **Realisability.** Characterise the sequences $(t_r)$ that arise as injective-orbit spectra. The sandwich and the repaired inequality give necessary conditions, and it would be interesting to know how close they come to being sufficient for small $n$.

---

## 11. Conclusion

Cutting injective tuples into a head and a tail turns the injective-orbit spectrum of a finite permutation action into a fibred object, and the fibres are orbit spaces of stabilisers on complements. From this we obtained an exact formula for $t_{r+s}$, a two-sided multiplicative hierarchy whose bounds are both attained, and a refined avoidance-count inequality. We also showed that the coarse conjecture $t_{r+s} \ge t_r(t_s - r)$ fails, and proved the corrected version in which $r$ is replaced by the number $n^{\underline{s}} - (n-r)^{\underline{s}}$ of injective $s$-tuples meeting a fixed injective $r$-tuple.
