# The Suspension Tower and the Exact $\mathbb{Z}_2$-Coindex of Combinatorial Spheres

**Author:** Aristotle

## Abstract

We study antipodal (equivariant) simplicial maps between combinatorial spheres realized as boundaries of cross-polytopes, equipped with the free $\mathbb{Z}_2$-action given by the antipodal map. We prove that such a map $S^m \to S^n$ exists if and only if $m \le n$, giving a completely elementary, all-dimensions form of the Borsuk–Ulam theorem in this model. The engine of the result is a structural characterization we call the *Coordinate Injectivity Principle*: an equivariant simplicial self-map of cross-polytopes is simplicial precisely when the induced map on coordinate axes is injective, with signs entirely free. As consequences we obtain the exact value of the $\mathbb{Z}_2$-coindex, $\mathrm{coind}(S^n) = n$; the construction of the $k$-fold *suspension tower* as a functor on equivariant maps; and the *exactness* of the tower — suspension preserves the excess $n - m$, so a fair map exists at level $k$ if and only if it exists at the base, and every level of the tower is Borsuk–Ulam sharp. We include algorithms, numerical demonstrations, and a discussion of what changes when one leaves the octahedral model.

**Keywords:** Borsuk–Ulam theorem, $\mathbb{Z}_2$-coindex, cross-polytope, antipodal map, equivariant simplicial map, suspension, free $\mathbb{Z}_2$-complex, pigeonhole principle.

---

## 1. Introduction

The Borsuk–Ulam theorem asserts that every continuous antipodal map $S^m \to S^n$ forces $m \le n$; equivalently, there is no continuous map $S^{n+1} \to S^n$ commuting with the antipodal involution. It is among the most widely applied theorems in mathematics, with consequences ranging from the ham-sandwich theorem to Lovász's resolution of the Kneser conjecture and beyond.

A standard invariant packaging its content is the **$\mathbb{Z}_2$-coindex** of a free $\mathbb{Z}_2$-space $X$: the largest $m$ such that there is an equivariant map $S^m \to X$. Borsuk–Ulam is the statement $\mathrm{coind}(S^n) = n$. In the smooth or topological category this equality already requires nontrivial machinery (degree theory, or cohomological index theory).

This paper develops a fully **combinatorial** and **elementary** account in the *cross-polytope model*, in which spheres are boundaries of orthoplexes and maps are simplicial and antipodally equivariant. In this model we obtain not only the coindex but the exact behaviour of the entire *suspension tower* — the sequence of spheres obtained by iterated suspension — and prove that every rung of the tower is Borsuk–Ulam sharp. Our central technical observation reduces the entire simpliciality condition to injectivity of a finite map on axis labels, whence all impossibility statements become instances of the pigeonhole principle.

### 1.1 Contributions

1. **The Coordinate Injectivity Principle** (Theorem 4.1): simpliciality of an equivariant vertex map $\Longleftrightarrow$ injectivity of its induced coordinate (axis) map.
2. **Exact existence criterion** (Theorem 5.1): a fair map $S^m \to S^n$ exists $\iff m \le n$.
3. **Borsuk–Ulam in all dimensions** (Corollary 5.2): $S^{n+1} \not\to S^n$ for every $n$.
4. **Exact coindex** (Theorem 6.1): $\mathrm{coind}(S^n) = n$.
5. **The suspension tower as a functor** (Definition 7.1, Proposition 7.2), and its **exactness and sharpness** (Theorems 7.3–7.5): suspension preserves the excess $n - m$; the tower is Borsuk–Ulam sharp at every level.

---

## 2. The cross-polytope model

### 2.1 Vertices and the antipodal action

**Definition 2.1 (Combinatorial sphere).** For $n \in \mathbb{N}$, the *$n$-dimensional combinatorial sphere* $S^n$ is the boundary complex of the $(n{+}1)$-dimensional cross-polytope. Its vertex set is
$$
V(S^n) = \{\pm e_0, \pm e_1, \dots, \pm e_n\},
$$
the signed standard basis vectors of $\mathbb{R}^{n+1}$. We encode a vertex as a pair
$$
(i, b) \in \{0,1,\dots,n\} \times \{\mathrm{true}, \mathrm{false}\},
$$
where $i$ is the axis index and $b$ records the sign ($\mathrm{true} \mapsto +$, $\mathrm{false} \mapsto -$). We write $\mathrm{SVert}(n)$ for this set; it has $2(n{+}1)$ elements.

The faces of $S^n$ are exactly the subsets of $V(S^n)$ containing at most one of each antipodal pair $\{+e_i, -e_i\}$; equivalently, the "no antipodal pair" subsets. We will not need faces beyond edges: a pair $\{u, v\}$ spans an edge iff $u \ne v$ and $u \ne -v$.

**Definition 2.2 (Antipodal map).** The free $\mathbb{Z}_2$-action is the antipodal involution
$$
\mathrm{anti}(i, b) = (i, \lnot b).
$$

**Lemma 2.3.** For all $p$: $\mathrm{anti}(\mathrm{anti}(p)) = p$ and $\mathrm{anti}(p) \ne p$.

*Proof.* Flipping a bit twice restores it, so $\mathrm{anti}$ is an involution. Since a Boolean value is never equal to its negation, $\mathrm{anti}$ has no fixed point. $\square$

Thus $S^n$ is a **free $\mathbb{Z}_2$-complex**: the involution acts without fixed points, which is precisely the setting for the antipodal game.

### 2.2 Equivariant simplicial maps

**Definition 2.4 (Fair map / $\mathbb{Z}_2$-map).** A *$\mathbb{Z}_2$-map* (or *fair map*) $F : S^m \to S^n$ is a vertex map $F : \mathrm{SVert}(m) \to \mathrm{SVert}(n)$ satisfying:

- **(Equivariance)** $F(\mathrm{anti}(p)) = \mathrm{anti}(F(p))$ for all $p$;
- **(Simpliciality)** for all $p, q$: if $F(p) = \mathrm{anti}(F(q))$ then $p = \mathrm{anti}(q)$.

The simpliciality clause is the vertex-level statement that $F$ maps faces to faces: it forbids two non-antipodal vertices from being sent to an antipodal (hence non-face) pair. Contrapositively, whenever $p \ne \mathrm{anti}(q)$, the images $F(p)$ and $F(q)$ are not antipodal, so $\{F(p), F(q)\}$ is again a legal face.

We write $\mathrm{Z2Map}(m, n)$ for the set of such maps, and ask when it is nonempty.

**Example 2.5 (Identity).** The identity vertex map $S^n \to S^n$ is equivariant (trivially) and simplicial (if $p = \mathrm{anti}(q)$ then indeed $p = \mathrm{anti}(q)$). Hence $\mathrm{Z2Map}(n,n) \ne \varnothing$.

---

## 3. Reduction to positive-vertex data

Equivariance means a fair map is determined by its values on the *positive* vertices $(i, \mathrm{true})$.

**Definition 3.1 (Induced map).** Given data $g : \{0,\dots,m\} \to \mathrm{SVert}(n)$, define $\mathrm{induced}(g) : \mathrm{SVert}(m) \to \mathrm{SVert}(n)$ by
$$
\mathrm{induced}(g)(i, b) = \begin{cases} g(i), & b = \mathrm{true},\\ \mathrm{anti}(g(i)), & b = \mathrm{false}. \end{cases}
$$

**Lemma 3.2.** $\mathrm{induced}(g)$ is equivariant for every $g$.

*Proof.* For $b = \mathrm{true}$, $\mathrm{induced}(g)(\mathrm{anti}(i,\mathrm{true})) = \mathrm{induced}(g)(i,\mathrm{false}) = \mathrm{anti}(g(i)) = \mathrm{anti}(\mathrm{induced}(g)(i,\mathrm{true}))$; the case $b=\mathrm{false}$ is symmetric using $\mathrm{anti}\circ\mathrm{anti}=\mathrm{id}$. $\square$

**Proposition 3.3 (Positive-vertex reduction).** $\mathrm{Z2Map}(m,n) \ne \varnothing$ if and only if there exists $g : \{0,\dots,m\} \to \mathrm{SVert}(n)$ such that $\mathrm{induced}(g)$ is simplicial, i.e.
$$
\forall p, q,\quad \mathrm{induced}(g)(p) = \mathrm{anti}(\mathrm{induced}(g)(q)) \ \Rightarrow\ p = \mathrm{anti}(q).
$$

*Proof.* ($\Rightarrow$) Given $F \in \mathrm{Z2Map}(m,n)$, set $g(i) = F(i, \mathrm{true})$. Equivariance gives $\mathrm{induced}(g) = F$ on all vertices (on positive vertices by definition; on negative vertices because $F(i,\mathrm{false}) = F(\mathrm{anti}(i,\mathrm{true})) = \mathrm{anti}(F(i,\mathrm{true})) = \mathrm{anti}(g(i))$). Hence $\mathrm{induced}(g)$ inherits simpliciality from $F$.

($\Leftarrow$) By Lemma 3.2, $\mathrm{induced}(g)$ is equivariant; the hypothesis is exactly simpliciality, so $\mathrm{induced}(g) \in \mathrm{Z2Map}(m,n)$. $\square$

---

## 4. The Coordinate Injectivity Principle

**Definition 4.1 (Coordinate map).** For $g : \{0,\dots,m\} \to \mathrm{SVert}(n)$, its *coordinate map* is
$$
\sigma = \mathrm{coordMap}(g) : \{0,\dots,m\} \to \{0,\dots,n\}, \qquad \sigma(i) = \big(g(i)\big)_1,
$$
the axis index of $g(i)$, discarding the sign.

**Theorem 4.2 (Coordinate Injectivity Principle).** The induced map $\mathrm{induced}(g)$ is simplicial if and only if its coordinate map $\sigma = \mathrm{coordMap}(g)$ is injective.

*Proof.*

*(Simplicial $\Rightarrow$ injective.)* Suppose $\mathrm{induced}(g)$ is simplicial and $\sigma(i) = \sigma(j)$; we show $i = j$. Write $g(i) = (\sigma(i), \beta_i)$ and $g(j) = (\sigma(j), \beta_j) = (\sigma(i), \beta_j)$.
- If $\beta_i = \beta_j$, then $g(i) = g(j)$. Then $\mathrm{induced}(g)(i,\mathrm{true}) = g(i) = g(j) = \mathrm{anti}(\mathrm{anti}(g(j))) = \mathrm{anti}(\mathrm{induced}(g)(j, \mathrm{false}))$. Simpliciality yields $(i,\mathrm{true}) = \mathrm{anti}(j,\mathrm{false}) = (j, \mathrm{true})$, so $i = j$.
- If $\beta_i \ne \beta_j$, then $g(i) = \mathrm{anti}(g(j))$, so $\mathrm{induced}(g)(i,\mathrm{true}) = g(i) = \mathrm{anti}(g(j)) = \mathrm{anti}(\mathrm{induced}(g)(j,\mathrm{true}))$. Simpliciality yields $(i,\mathrm{true}) = \mathrm{anti}(j,\mathrm{true}) = (j, \mathrm{false})$, forcing the sign bits $\mathrm{true} = \mathrm{false}$, a contradiction; this case cannot occur when $\sigma(i)=\sigma(j)$ with the axis already equal. In either admissible case $i = j$, so $\sigma$ is injective.

*(Injective $\Rightarrow$ simplicial.)* Suppose $\sigma$ is injective and $\mathrm{induced}(g)(p) = \mathrm{anti}(\mathrm{induced}(g)(q))$ with $p = (i,b)$, $q = (j,c)$. Taking axis (first) components, the sign-flip in $\mathrm{anti}$ does not affect the axis, and the induced-map cases only ever apply $\mathrm{anti}$ (which preserves the axis) to $g$; hence the axis of $\mathrm{induced}(g)(p)$ is $\sigma(i)$ and that of $\mathrm{anti}(\mathrm{induced}(g)(q))$ is $\sigma(j)$. Thus $\sigma(i) = \sigma(j)$, and injectivity gives $i = j$. With $i = j$ fixed, comparing sign components in the equation $\mathrm{induced}(g)(i,b) = \mathrm{anti}(\mathrm{induced}(g)(i,c))$ forces $b = \lnot c$, i.e. $(i,b) = \mathrm{anti}(i,c)$, so $p = \mathrm{anti}(q)$. $\square$

**Interpretation.** A fair simplicial self-map of cross-polytopes can do exactly one thing: *injectively relabel coordinate axes, with an arbitrary independent sign on each.* The signs are pure gauge; the only obstruction is axis collision. This is the geometric core from which everything else follows by counting.

---

## 5. The exact existence criterion and Borsuk–Ulam

**Theorem 5.1 (Existence criterion).** $\mathrm{Z2Map}(m,n) \ne \varnothing$ if and only if $m \le n$.

*Proof.* By Proposition 3.3 and Theorem 4.2, $\mathrm{Z2Map}(m,n) \ne \varnothing$ iff there is $g$ whose coordinate map $\sigma : \{0,\dots,m\} \to \{0,\dots,n\}$ is injective.

($\Rightarrow$) An injection between finite sets forces $|\{0,\dots,m\}| \le |\{0,\dots,n\}|$, i.e. $m+1 \le n+1$, hence $m \le n$.

($\Leftarrow$) If $m \le n$ then $m + 1 \le n + 1$, so an injection $\sigma : \{0,\dots,m\} \hookrightarrow \{0,\dots,n\}$ exists (e.g. the inclusion). Take $g(i) = (\sigma(i), \mathrm{true})$; its coordinate map is $\sigma$, injective, so $\mathrm{induced}(g)$ is a fair map. $\square$

**Corollary 5.2 (Borsuk–Ulam, all dimensions).** For every $n$, $\mathrm{Z2Map}(n+1, n) = \varnothing$: there is no fair map $S^{n+1} \to S^n$.

*Proof.* By Theorem 5.1 this would require $n + 1 \le n$, which is false. $\square$

This upgrades the base cases $n = 0, 1$ (checkable by finite enumeration) to *all* dimensions in one stroke.

---

## 6. The exact coindex

**Definition 6.1 ($\mathbb{Z}_2$-coindex).** The *$\mathbb{Z}_2$-coindex* of $S^n$ is
$$
\mathrm{coind}(S^n) = \sup\{\, m \in \mathbb{N} : \mathrm{Z2Map}(m,n) \ne \varnothing \,\}.
$$

**Theorem 6.2 (Exact coindex).** $\mathrm{coind}(S^n) = n$.

*Proof.* By Theorem 5.1 the admissible set is $\{m : \mathrm{Z2Map}(m,n) \ne \varnothing\} = \{m : m \le n\} = \{0,1,\dots,n\}$, whose supremum is $n$. $\square$

Thus in the cross-polytope model the coindex is a *complete* invariant of the sphere: it equals the dimension exactly, with no slack. In particular there is no gap phenomenon here — a point we revisit in §9.

---

## 7. The suspension tower

### 7.1 Suspension of a single map

Suspension embeds $S^n$ into $S^{n+1}$ by reusing the old axes and adjoining a new pole axis.

**Definition 7.1 (Suspended vertex).** For $p = (i, b) \in \mathrm{SVert}(n)$, let $\mathrm{suspV}(p) = (\hat{\imath}, b) \in \mathrm{SVert}(n+1)$, where $\hat{\imath}$ is the image of $i$ under the inclusion $\{0,\dots,n\} \hookrightarrow \{0,\dots,n+1\}$ (the "old" axes). The new axis $n{+}1$ (the *pole*) is not in the image.

**Definition 7.2 (Suspension of a map).** For $F \in \mathrm{Z2Map}(m,n)$, define $\mathrm{susp}(F) : \mathrm{SVert}(m+1) \to \mathrm{SVert}(n+1)$ by
$$
\mathrm{susp}(F)(i, b) = \begin{cases} (\text{new pole of } S^{n+1},\ b), & i = \text{new pole of } S^{m+1},\\[2pt] \mathrm{suspV}\big(F(j, b)\big), & i = \hat{\jmath}\ \text{an old axis}. \end{cases}
$$
That is, the two new source poles map to the two new target poles (signs preserved), and old vertices are routed through $F$ and then embedded among the old target axes.

**Proposition 7.3.** $\mathrm{susp}(F) \in \mathrm{Z2Map}(m+1, n+1)$.

*Proof sketch.* *Equivariance:* on the pole the sign bit flips correctly; on old axes, $\mathrm{suspV}$ commutes with $\mathrm{anti}$ and $F$ is equivariant, so $\mathrm{susp}(F)(\mathrm{anti}(p)) = \mathrm{anti}(\mathrm{susp}(F)(p))$. *Simpliciality:* suppose $\mathrm{susp}(F)(p) = \mathrm{anti}(\mathrm{susp}(F)(q))$. Comparing axis components, a pole image (axis $n{+}1$) can equal only another pole image, and an old-axis image (axis $< n{+}1$) only another old-axis image, because the pole axis is strictly greater than every old axis; so $p, q$ are of the same type. In the pole case the sign bits force $p = \mathrm{anti}(q)$ directly. In the old-axis case, $\mathrm{suspV}$ is injective and sign-compatible, reducing the equation to $F(j,b) = \mathrm{anti}(F(j',c))$, whence simpliciality of $F$ gives $(j,b) = \mathrm{anti}(j',c)$ and therefore $p = \mathrm{anti}(q)$. $\square$

### 7.2 The tower and its exactness

**Definition 7.4 ($k$-fold suspension).** Define $\mathrm{suspIter}^0(F) = F$ and $\mathrm{suspIter}^{k+1}(F) = \mathrm{susp}(\mathrm{suspIter}^{k}(F))$. Then $\mathrm{suspIter}^{k}$ maps $\mathrm{Z2Map}(m,n)$ into $\mathrm{Z2Map}(m+k, n+k)$. The sequence of spheres $S^n, S^{n+1}, S^{n+2}, \dots$ together with these functors is the **suspension tower**.

**Theorem 7.5 (Constructive raising).** If $\mathrm{Z2Map}(m,n) \ne \varnothing$, then $\mathrm{Z2Map}(m+k, n+k) \ne \varnothing$ for every $k$.

*Proof.* Apply $\mathrm{suspIter}^k$ to any $F \in \mathrm{Z2Map}(m,n)$. $\square$

**Theorem 7.6 (Exactness of the tower).** For all $m, n, k$,
$$
\mathrm{Z2Map}(m+k,\, n+k) \ne \varnothing \iff \mathrm{Z2Map}(m,n) \ne \varnothing.
$$
Equivalently, suspension preserves the *excess* $n - m$ exactly, and the coindex increment of the $k$-fold suspension is exactly $k$.

*Proof.* By Theorem 5.1 both sides are equivalent to arithmetic inequalities: the left to $m+k \le n+k$ and the right to $m \le n$, which are equivalent. $\square$

**Theorem 7.7 (Sharpness at every level).** For all $n, k$: $\mathrm{Z2Map}(n+k+1,\ n+k) = \varnothing$; there is no fair map $S^{n+k+1} \to S^{n+k}$.

*Proof.* Apply Corollary 5.2 with $n$ replaced by $n + k$. $\square$

**Corollary 7.8.** $\mathrm{coind}(S^{n+k}) = n + k = \mathrm{coind}(S^n) + k$: the coindex rises by exactly one per rung, forever.

---

## 8. Algorithms

We record three procedures made rigorous by the theory. Full implementations appear in the accompanying demonstration code.

**(A) Existence oracle.** To decide whether a fair map $S^m \to S^n$ exists, return $m \le n$. Correct by Theorem 5.1; runtime $O(1)$.

**(B) Constructive map builder.** Given $m \le n$, output positive-vertex data $g(i) = (i, +)$ for $i = 0, \dots, m$; equivalently the axis injection $\sigma = \mathrm{incl}$. This is a witnessing fair map. Runtime $O(m)$.

**(C) Simpliciality checker via coordinate injectivity.** Given arbitrary positive-vertex data $g$, decide simpliciality by testing whether $\sigma = \mathrm{coordMap}(g)$ is injective — a single duplicate scan — rather than checking all $O((2(m{+}1))^2)$ vertex pairs. Correct by Theorem 4.2; runtime $O(m)$ with hashing, versus $O(m^2)$ naively.

**(D) Suspension.** Given $g$ realizing a map $S^m \to S^n$, produce $g'$ for the suspension by embedding each $g(i)$ into the old axes and appending the new pole datum. Iterating gives the $k$-fold suspension. Runtime $O(m + k)$ per level.

---

## 9. Discussion

The results collapse a family of impossibility theorems onto the pigeonhole principle. The lever is the Coordinate Injectivity Principle: in the octahedral model, simpliciality of an equivariant map is *equivalent* to injectivity of the underlying axis map, with signs free. This equivalence is what makes the coindex a complete invariant equal to the dimension, and makes the suspension tower exact — preserving the excess $n - m$ with no slack.

It is important to delimit the model-dependence. The equivalence "simplicial antipodal map $\iff$ coordinate injection" is *special* to cross-polytopes. For a general free simplicial $\mathbb{Z}_2$-complex $K$, the coindex is **not** determined by dimension alone; the upper bound $\mathrm{coind}(K) \le \dim K$ genuinely requires the combinatorial content of **Tucker's lemma**, and there exist complexes with a strict gap between the $\mathbb{Z}_2$-*index* (equivariant maps *out of* $K$ into spheres) and the coindex. The clean picture here is thus a sharp special case rather than the general phenomenon — a transparent laboratory in which the mechanism is fully exposed.

---

## 10. Future directions

- **Beyond cross-polytopes.** Formalize Tucker's lemma and recover $\mathrm{coind}(K) \le \dim K$ for arbitrary free simplicial $\mathbb{Z}_2$-complexes $K$, where the coordinate-injection shortcut is unavailable.
- **The index/coindex gap.** Introduce the $\mathbb{Z}_2$-index (equivariant maps from $K$ into spheres) and study complexes with $\mathrm{ind}(K) < \mathrm{coind}(K)$. The cross-polytope spheres are extremal, with $\mathrm{ind} = \mathrm{coind} = n$.
- **Chromatic applications.** Connect the coindex of neighborhood and box complexes to lower bounds on chromatic numbers, in the spirit of the topological method in combinatorics.
- **Higher symmetry.** Replace $\mathbb{Z}_2$ by a finite group $G$ acting freely, and investigate a $G$-equivariant analogue of the suspension tower and its exactness.

---

## Appendix: table of admissible dimensions

For target dimension $n$, the admissible source dimensions $\{m : \mathrm{Z2Map}(m,n) \ne \varnothing\}$ are exactly $\{0,1,\dots,n\}$, and $\mathrm{coind}(S^n) = n$:

| $n$ | admissible $m$ | $\mathrm{coind}(S^n)$ |
|----:|:---------------|:---------------------:|
| 0 | $\{0\}$ | 0 |
| 1 | $\{0,1\}$ | 1 |
| 2 | $\{0,1,2\}$ | 2 |
| 3 | $\{0,1,2,3\}$ | 3 |
| $n$ | $\{0,\dots,n\}$ | $n$ |
