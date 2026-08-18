# Orbital Rigidity: Equality at Arity Two Forces Triviality

**Author:** Aristotle
**Date:** 2026-08-18

## Abstract

Let $G$ be a group acting on a set $X$. The diagonal action of $G$ on $X \times X$ partitions the square into *orbitals*, and every orbital is contained in a product $\mathrm{orb}(x) \times \mathrm{orb}(y)$ of two orbits; thus the orbital partition always refines the square of the orbit partition. We determine exactly when the refinement is an equality: **never, unless the action is trivial**. We prove this in three forms of increasing strength. (i) A set-theoretic form, valid for an arbitrary group acting on an arbitrary set with no finiteness hypotheses: every orbital is a product of orbits if and only if every group element fixes every point. (ii) A counting form for finite $G$ and $X$. Writing $n = |X|$, $r$ for the number of orbits, $s$ for the number of orbitals and $F(g)$ for the number of points fixed by $g$, Burnside's lemma identifies $r$ and $s$ with the first and second moments of $F$ under the uniform measure on $G$, whence the *variance identity*
$$|G|\,(s - r^2) = \sum_{g \in G} (F(g) - r)^2 :$$
the rigidity defect is precisely the variance of the fixed-point statistic. Bounding the variance below by the contribution of the kernel $K$ and correcting the complement by Cauchy–Schwarz yields the sharp quantitative bound $|K|(n-r)^2 \le (|G| - |K|)(s - r^2)$, and we classify the extremal actions: for a nontrivial action equality holds if and only if every element outside the kernel fixes the same number of points. (iii) A higher-arity form: a Chebyshev/monovariance argument gives $s_{k+1} \ge s_k \cdot r$ for the orbit counts $s_k$ on $X^k$, and hence $s_k > r^k$ for every $k \ge 2$ unless the action is trivial. Finally we isolate the structural mechanism behind (i): orbits on $X \times Y$ are products of orbits exactly when every point stabiliser $G_x$ remains transitive on every $G$-orbit of $Y$, and a $G$-set is never independent of itself unless the action is trivial. We also record a negative result: no bound of the form $s - r^2 \ge c\,n$ with an absolute constant $c > 0$ can hold.

**Keywords:** permutation group, orbital, orbit counting, Burnside's lemma, rank, rigidity, fixed-point statistic, variance, Chebyshev's sum inequality, Frobenius group.

---

## 1. Introduction

### 1.1 The question

Let a group $G$ act on a set $X$. The action induces a diagonal action on $X \times X$ by $g \cdot (x,y) = (g\cdot x, g \cdot y)$; the orbits of this diagonal action are the **orbitals** of the action, and the number of orbitals of a transitive action is its classical **rank**. Orbitals are among the most heavily used invariants in permutation group theory: they are the edge sets of the orbital graphs, the basis relations of the coherent configuration attached to the action, and the natural home of $2$-transitivity (rank $2$ for a transitive action).

There are two partitions of $X \times X$ in sight. On the one hand, the orbital partition. On the other, the *square of the orbit partition*: the partition whose blocks are the sets $\mathrm{orb}(x) \times \mathrm{orb}(y)$. Since a group element acting on a pair acts on each coordinate, the first refines the second (Lemma 3.1 below). The question addressed here is:

> **When is the refinement an equality?**

Equivalently: when is the pair structure of a $G$-set determined by its point structure? When does the orbit of $(x,y)$ contain all pairs whose coordinates are individually reachable? Call an action with this property **pair-independent**.

### 1.2 The answer

Pair-independence is a rigidity condition of the strongest possible kind: it holds only in the degenerate case.

> **Main Theorem (Orbital Rigidity).** *A group action is pair-independent if and only if it is trivial, i.e. $g\cdot x = x$ for all $g \in G$ and $x \in X$.*

No finiteness is needed. In the finite case the statement can be sharpened from a dichotomy into a quantitative estimate, because the defect $s - r^2$ turns out to be exactly a variance.

### 1.3 Organisation

Section 2 sets notation and definitions. Section 3 gives the set-theoretic rigidity theorem and an equivalent formulation in terms of orbit relations. Section 4 records the fixed-point counts of diagonal and $k$-fold diagonal actions and states Burnside's lemma as a moment computation. Section 5 proves the variance identity and its consequences, including the counting form of rigidity. Section 6 sharpens the quantitative bound by a Cauchy–Schwarz correction and classifies the extremal actions. Section 7 establishes the higher-arity hierarchy. Section 8 identifies the structural mechanism through an independence criterion for two $G$-sets. Section 9 presents computational evidence. Section 10 discusses applications, limitations and open problems.

---

## 2. Definitions and notation

Throughout, $G$ is a group acting on a set $X$ (on the left). We write $g\cdot x$ for the action and

$$\mathrm{orb}(x) = \{g \cdot x : g \in G\}, \qquad G_x = \{g \in G : g\cdot x = x\}$$

for the orbit and the stabiliser of $x$, and $\mathrm{Fix}(g) = \{x \in X : g\cdot x = x\}$ for the fixed-point set of $g$.

**Definition 2.1 (Orbit count).** $r = r(G,X)$ denotes the number of $G$-orbits on $X$, i.e. the cardinality of the quotient of $X$ by the orbit equivalence relation. More generally $s_k$ denotes the number of $G$-orbits on $X^k$ under the coordinatewise action, so $s_1 = r$; we write $s = s_2$ for the number of orbitals.

**Definition 2.2 (Fixed-point statistic).** For $g \in G$, $F(g) = |\mathrm{Fix}(g)|$ is the number of points of $X$ fixed by $g$. When $G$ is finite, $F$ is a random variable on $G$ equipped with the uniform probability measure.

**Definition 2.3 (Trivial action).** The action is **trivial** if $g\cdot x = x$ for every $g \in G$ and $x \in X$. The **kernel** of the action is $K = \{g \in G : g\cdot x = x \text{ for all } x \in X\}$, a normal subgroup of $G$; the action is trivial exactly when $K = G$.

**Definition 2.4 (Pair-independence).** The action is **pair-independent** if
$$\mathrm{orb}\bigl((x,y)\bigr) = \mathrm{orb}(x) \times \mathrm{orb}(y) \qquad \text{for all } x,y \in X,$$
where the orbit on the left is taken with respect to the diagonal action on $X\times X$.

**Definition 2.5 (Rigidity defect).** For finite $G$ and $X$, the **rigidity defect** is $\Delta = s - r^2$.

---

## 3. The set-theoretic rigidity theorem

We begin with the inclusion that makes the question meaningful.

**Lemma 3.1 (Refinement).** *For all $x, y \in X$,*
$$\mathrm{orb}\bigl((x,y)\bigr) \subseteq \mathrm{orb}(x) \times \mathrm{orb}(y).$$

*Proof.* An element of the left-hand side is $(g\cdot x, g\cdot y)$ for some $g \in G$. Its first coordinate lies in $\mathrm{orb}(x)$, witnessed by $g$; its second lies in $\mathrm{orb}(y)$, witnessed by the same $g$. $\square$

The content of the theory is that the reverse inclusion is a rigidity condition.

**Theorem 3.2 (Rigidity at arity two).** *Let $G$ be any group acting on any set $X$. Then the action is pair-independent if and only if it is trivial. No finiteness hypothesis is required, and $X$ may be empty.*

*Proof.* ($\Leftarrow$) Suppose the action is trivial. Then every orbit is a singleton: $\mathrm{orb}(x) = \{x\}$ and $\mathrm{orb}(y) = \{y\}$, and the diagonal orbit of $(x,y)$ is $\{(x,y)\}$, which is exactly $\{x\}\times\{y\}$. (Equivalently, combine Lemma 3.1 with the observation that any $(a,b)$ in the product satisfies $a = x$, $b = y$ and is therefore hit by the identity.)

($\Rightarrow$) Suppose the action is pair-independent, and fix $g \in G$ and $x \in X$. Consider the pair $(x, g\cdot x)$. Its first coordinate lies in $\mathrm{orb}(x)$ (witnessed by the identity) and its second coordinate lies in $\mathrm{orb}(x)$ (witnessed by $g$), so
$$(x,\ g\cdot x) \in \mathrm{orb}(x)\times\mathrm{orb}(x) = \mathrm{orb}\bigl((x,x)\bigr),$$
the last equality by hypothesis. Hence there exists a single $a \in G$ with $a\cdot(x,x) = (x, g\cdot x)$, that is,
$$a\cdot x = x \quad \text{and} \quad a\cdot x = g\cdot x.$$
Comparing the two, $g \cdot x = x$. As $g$ and $x$ were arbitrary, the action is trivial. $\square$

**Remark 3.3.** The proof is a genuine two-jobs-one-element argument: pair-independence demands a group element that simultaneously *stabilises* $x$ and *transports* $x$ to $g\cdot x$, and only $g\cdot x = x$ resolves the conflict. It uses a single instance of the hypothesis, namely the case $y = x$ with target pair $(x, g\cdot x)$. In particular the diagonal blocks alone already carry the whole obstruction.

It is convenient to have the statement in relational form.

**Theorem 3.4 (Relational form).** *The action is trivial if and only if, for all $x,y,x',y' \in X$,*
$$\Bigl(\exists g \in G:\ g\cdot x = x'\Bigr) \wedge \Bigl(\exists g \in G:\ g\cdot y = y'\Bigr) \iff \Bigl(\exists g\in G:\ g\cdot x = x' \text{ and } g\cdot y = y'\Bigr).$$

*Proof.* The displayed equivalence, quantified over all four points, says exactly that the orbit relation on pairs is the product of the orbit relations, which is a restatement of pair-independence; apply Theorem 3.2. Concretely: the left-to-right implication of the displayed statement is what fails for nontrivial actions, and the right-to-left implication is Lemma 3.1 in relational dress. $\square$

Thus the orbit equivalence relation on $X\times X$ is the product of two copies of the orbit relation on $X$ only in the trivial case: *the orbit relation is never a product of itself with itself*.

---

## 4. Fixed points and Burnside's lemma as a moment computation

From here on $G$ and $X$ are finite; $n = |X|$.

**Lemma 4.1 (Fixed points of the identity).** $F(1) = n$.

**Lemma 4.2 (Fixed points on powers).** *For every $g \in G$ and $k \ge 0$, the number of $k$-tuples fixed by $g$ under the coordinatewise action is $F(g)^k$. In particular the number of pairs fixed by $g$ is $F(g)^2$.*

*Proof.* A tuple $(x_1,\dots,x_k)$ is fixed by $g$ iff each coordinate is fixed, so the fixed set of $g$ on $X^k$ is $\mathrm{Fix}(g)^k$. $\square$

**Theorem 4.3 (Burnside's lemma).** *The number of orbits of $G$ on a finite $G$-set is the average number of fixed points:*
$$r = \frac{1}{|G|}\sum_{g\in G} F(g).$$

Combining Theorem 4.3 with Lemma 4.2 applied to $X^k$ yields the moment interpretation on which the entire quantitative theory rests.

**Corollary 4.4 (Moment formula).** *For every $k \ge 1$,*
$$s_k = \frac{1}{|G|}\sum_{g\in G} F(g)^k .$$
*In particular $r$ is the first moment and $s = s_2$ the second moment of the fixed-point statistic $F$ under the uniform measure on $G$.*

**Remark 4.5.** The orbitals of $G$ on $X\times X$ and the orbits of $G$ on the set of functions $\{1,2\}\to X$ are counted by the same number, since the two $G$-sets are isomorphic. We use the two descriptions interchangeably; the second is the convenient one for induction on arity.

---

## 5. The variance identity and the counting form of rigidity

**Theorem 5.1 (Variance identity).** *For a finite group $G$ acting on a finite set $X$,*
$$|G|\cdot\bigl(s - r^2\bigr) = \sum_{g\in G}\bigl(F(g) - r\bigr)^2 .$$
*Equivalently, the rigidity defect $\Delta = s - r^2$ is the variance of $F$ under the uniform measure on $G$.*

*Proof.* Expand the right-hand side:
$$\sum_{g}\bigl(F(g)-r\bigr)^2 = \sum_g F(g)^2 - 2r\sum_g F(g) + |G|\,r^2 .$$
By Corollary 4.4, $\sum_g F(g) = r|G|$ and $\sum_g F(g)^2 = s|G|$. Substituting,
$$\sum_{g}\bigl(F(g)-r\bigr)^2 = s|G| - 2r\cdot r|G| + |G|r^2 = |G|(s - r^2). \qquad \square$$

Two immediate consequences.

**Corollary 5.2 (Second-moment inequality).** $r^2 \le s$, *always.*

*Proof.* The right-hand side of Theorem 5.1 is a sum of squares, hence nonnegative; divide by $|G| > 0$. (This is Cauchy–Schwarz for the pair $(F,1)$.) $\square$

**Theorem 5.3 (Rigidity, counting form).** *For a finite group acting on a finite set, $s = r^2$ if and only if the action is trivial.*

*Proof.* If the action is trivial then every orbit is a singleton, so $r = n$ and every orbital is a singleton, so $s = n^2 = r^2$. Conversely suppose $s = r^2$. By Theorem 5.1 the variance of $F$ vanishes, so $F$ is constant on $G$; the constant is $F(1) = n$ by Lemma 4.1, and it equals the mean $r$ by Burnside, so $r = n$. But $r = n$ forces every orbit to be a singleton, i.e. the action is trivial. $\square$

**Remark 5.4.** Theorem 5.3 is the finite shadow of Theorem 3.2, obtained by an entirely different route: rigidity as the vanishing locus of a variance rather than as a logical impossibility. The two proofs generalise in different directions, and the probabilistic one is what makes quantitative refinement possible.

It is worth recording the elementary counting fact used above in its own right.

**Lemma 5.5 (Orbit deficiency).** *For a finite $G$-set, $r \le n$, with equality if and only if the action is trivial. Consequently, for a nontrivial action, $n - r \ge 1$.*

*Proof.* Orbits partition $X$ into nonempty blocks, so $r \le n$ with equality iff every block is a singleton, i.e. iff $\mathrm{orb}(x) = \{x\}$ for all $x$, i.e. iff the action is trivial. $\square$

**Theorem 5.6 (Quantitative rigidity, first form).** *With $K$ the kernel of the action,*
$$|K|\cdot (n-r)^2 \ \le\ |G| \cdot (s - r^2).$$

*Proof.* Every $g \in K$ satisfies $\mathrm{Fix}(g) = X$, so $F(g) = n$ and its contribution to the variance sum in Theorem 5.1 is $(n-r)^2$. Discarding the (nonnegative) contributions of $G \setminus K$ gives
$$\sum_{g\in G}(F(g)-r)^2 \ \ge\ \sum_{g\in K}(n - r)^2 = |K|(n-r)^2,$$
and the left-hand side equals $|G|(s-r^2)$. $\square$

Since $1 \in K$ always and $n - r \ge 1$ for a nontrivial action (Lemma 5.5), Theorem 5.6 recovers $s > r^2$ for nontrivial actions and hence Theorem 5.3, with an explicit lower bound on the defect. But the bound is wasteful, as the next section shows.

---

## 6. The sharp bound and the extremal actions

Theorem 5.6 uses only the kernel's contribution to the variance and throws away the rest. The complement can be exploited through a conservation law.

**Lemma 6.1 (Deviations sum to zero).** $\displaystyle \sum_{g \in G}\bigl(F(g) - r\bigr) = 0.$

*Proof.* Immediate from $\sum_g F(g) = r|G|$ (Corollary 4.4). $\square$

**Corollary 6.2 (Complementary deviation).** $\displaystyle \sum_{g \notin K}\bigl(F(g)-r\bigr) = -\,|K|\,(n-r).$

*Proof.* On $K$ each deviation equals $n - r$, so the kernel's total is $|K|(n-r)$; subtract from Lemma 6.1. $\square$

**Theorem 6.3 (Sharp quantitative rigidity).** *For a finite group acting on a finite set, with $K$ the kernel,*
$$|K|\cdot (n-r)^2 \ \le\ \bigl(|G| - |K|\bigr)\cdot\bigl(s - r^2\bigr).$$

*Proof.* Write $A = |K|$, $B = |G| - |K|$, $D = n - r$, and split the variance sum:
$$|G|\,\Delta \;=\; \sum_{g\in K}(F(g)-r)^2 + \sum_{g\notin K}(F(g)-r)^2 \;=\; A D^2 + S, \qquad S := \sum_{g\notin K}(F(g)-r)^2 .$$
If $B = 0$ the action is trivial, $D = 0$ and both sides vanish, so assume $B > 0$. By Cauchy–Schwarz on the complement, using Corollary 6.2,
$$\Bigl(\sum_{g\notin K}(F(g)-r)\Bigr)^2 \le B \cdot S, \qquad \text{i.e.} \qquad A^2 D^2 \le B\,S .$$
Therefore $S \ge A^2D^2/B$, and
$$(A+B)\,\Delta \;=\; A D^2 + S \;\ge\; A D^2 + \frac{A^2D^2}{B} \;=\; \frac{A D^2 (A+B)}{B}.$$
Dividing by $A + B = |G| > 0$ gives $\Delta \ge AD^2/B$, i.e. $A D^2 \le B\,\Delta$. $\square$

Theorem 6.3 strictly improves Theorem 5.6 (whose right-hand side carries $|G|$ instead of $|G|-|K|$) whenever $\Delta > 0$, and unlike Theorem 5.6 it is attained.

**Definition 6.4 (Constant fixity).** An action has **constant fixity** if there is $c \in \mathbb{N}$ with $F(g) = c$ for every $g \notin K$.

Regular actions ($c = 0$), sharply $t$-transitive actions and Frobenius groups all have constant fixity.

**Theorem 6.5 (Equality for constant fixity).** *If the action has constant fixity, then*
$$|K|(n-r)^2 = \bigl(|G| - |K|\bigr)\bigl(s - r^2\bigr).$$

*Proof sketch.* With $F \equiv c$ off $K$, Cauchy–Schwarz on the complement is an equality, since the vector of deviations is constant there. Explicitly, $S = B(c-r)^2$ and, by Corollary 6.2, $B(c-r) = -AD$, so $(c - r) = -AD/B$ and $S = A^2D^2/B$; substituting into $(A+B)\Delta = AD^2 + S$ gives $B\Delta = AD^2$. $\square$

**Theorem 6.6 (Classification of the extremal actions).** *Let the action be nontrivial. Then*
$$|K|(n-r)^2 = \bigl(|G| - |K|\bigr)\bigl(s - r^2\bigr)$$
*holds if and only if the action has constant fixity.*

*Proof sketch.* One direction is Theorem 6.5. Conversely, the proof of Theorem 6.3 shows that equality in the bound forces equality in the Cauchy–Schwarz step applied to the vector $\bigl(F(g)-r\bigr)_{g\notin K}$ against the all-ones vector on $G\setminus K$ (nonempty, since the action is nontrivial). Equality in Cauchy–Schwarz against the all-ones vector means the vector is constant, i.e. $F(g) - r$ takes a single value off $K$, i.e. $F$ is constant off $K$. $\square$

**Remark 6.7 (Constant fixity is weaker than a common fixed set).** Constant fixity constrains the *size* of $\mathrm{Fix}(g)$, not the set itself. The Klein four-group acting on six points, generated by the double transpositions $(0\,1)(2\,3)$ and $(2\,3)(4\,5)$, has three involutions fixing three *different* pairs of points, yet each fixes exactly two points. Here $n=6$, $|G|=4$, $F = (6,2,2,2)$, $r=3$, $s=12$, and $|K|(n-r)^2 = 9 = (|G|-|K|)(s-r^2)$. The extremal class is therefore genuinely wider than the naive guess.

**Remark 6.8 (Theorem 5.6 is never tight for nontrivial actions).** If the action is nontrivial then $|G| - |K| > 0$ and $\Delta > 0$, so $(|G|-|K|)\Delta < |G|\Delta$; combined with Theorem 6.3, the inequality of Theorem 5.6 is strict. This is visible in every nontrivial row of the table in Section 9.

---

## 7. The higher-arity hierarchy

Recall $s_k$ is the number of orbits on $X^k$, so $s_1 = r$, $s_2 = s$, and by Corollary 4.4 $s_k$ is the $k$-th moment of $F$.

**Lemma 7.1 (Monovariance).** *For every $k$, the functions $g \mapsto F(g)^k$ and $g\mapsto F(g)$ monovary: whenever $F(g_1) < F(g_2)$ we also have $F(g_1)^k \le F(g_2)^k$.*

*Proof.* $t\mapsto t^k$ is nondecreasing on the nonnegative integers. $\square$

**Theorem 7.2 (Geometric growth of tuple-orbit counts).** *For every $k \ge 0$,*
$$s_k \cdot r \ \le\ s_{k+1}.$$

*Proof.* Chebyshev's sum inequality for monovarying families states
$$\Bigl(\sum_{g} F(g)^k\Bigr)\Bigl(\sum_{g}F(g)\Bigr) \ \le\ |G| \sum_{g} F(g)^{k}\,F(g) = |G|\sum_g F(g)^{k+1}.$$
Applying Corollary 4.4 to each of the three sums turns this into
$$\bigl(s_k |G|\bigr)\bigl(r|G|\bigr) \le |G|\bigl(s_{k+1}|G|\bigr),$$
and cancelling $|G|^2 > 0$ gives the claim. $\square$

**Theorem 7.3 (Strict rigidity at every arity).** *If the action is nontrivial then $s_k > r^k$ for every $k \ge 2$.*

*Proof.* Since the action is nontrivial, $X$ is nonempty, hence $r \ge 1$. The base case $k = 2$ is $s_2 > r^2$, which follows from Corollary 5.2 and Theorem 5.3. For the induction step, assume $s_k > r^k$ with $k \ge 2$; then by Theorem 7.2 and $r\ge 1$,
$$s_{k+1} \ \ge\ s_k \cdot r \ >\ r^k \cdot r = r^{k+1}. \qquad \square$$

**Theorem 7.4 (Rigidity at arity $k$).** *For every $k \ge 2$, $s_k = r^k$ if and only if the action is trivial.*

*Proof.* If the action is trivial then $r = n$ and the action on $X^k$ is trivial as well, so $s_k = |X^k| = n^k = r^k$. Conversely, if the action is nontrivial then $s_k > r^k$ by Theorem 7.3. $\square$

Thus once independence fails at arity two, it fails at every higher arity, and the gap $s_k - r^k$ is nondecreasing in a strong sense: $s_{k+1} - r^{k+1} \ge r\,(s_k - r^k)$.

---

## 8. The structural mechanism: an independence criterion for two $G$-sets

Rigidity at arity two is the diagonal case of a general independence phenomenon which explains *why* it holds.

**Theorem 8.1 (Independence criterion).** *Let $G$ act on sets $X$ and $Y$. Then*
$$\mathrm{orb}\bigl((x,y)\bigr) = \mathrm{orb}(x)\times \mathrm{orb}(y) \quad \text{for all } x\in X,\ y \in Y$$
*if and only if, for every $x \in X$ and every $y \in Y$,*
$$\mathrm{orb}_{G_x}(y) = \mathrm{orb}_G(y),$$
*i.e. every point stabiliser $G_x$ is still transitive on every $G$-orbit of $Y$.*

*Proof.* ($\Rightarrow$) The inclusion $\mathrm{orb}_{G_x}(y) \subseteq \mathrm{orb}_G(y)$ is trivial. For the converse, let $b = g\cdot y \in \mathrm{orb}_G(y)$. Then $(x,b) \in \mathrm{orb}(x)\times\mathrm{orb}(y) = \mathrm{orb}((x,y))$, so there is $a\in G$ with $a\cdot x = x$ and $a\cdot y = b$. The first equation says $a \in G_x$, so $b \in \mathrm{orb}_{G_x}(y)$.

($\Leftarrow$) The inclusion $\subseteq$ is Lemma 3.1. Conversely let $(a,b) \in \mathrm{orb}(x)\times\mathrm{orb}(y)$, say $a = g\cdot x$ and $b = g'\cdot y$. Then $g^{-1}\cdot b = (g^{-1}g')\cdot y \in \mathrm{orb}_G(y) = \mathrm{orb}_{G_x}(y)$, so there is $k \in G_x$ with $k\cdot y = g^{-1}\cdot b$. Then
$$(gk)\cdot(x,y) = \bigl(g\cdot(k\cdot x),\ g\cdot (k\cdot y)\bigr) = \bigl(g\cdot x,\ g\cdot(g^{-1}\cdot b)\bigr) = (a,b). \qquad \square$$

In words: two $G$-sets are independent precisely when fixing a point of one costs nothing on the other. Specialising $Y = X$ collapses the criterion.

**Theorem 8.2 (Self-independence forces triviality).** *For a $G$-set $X$, the following are equivalent: (i) $\mathrm{orb}_{G_x}(y) = \mathrm{orb}_G(y)$ for all $x,y\in X$; (ii) the action is trivial.*

*Proof.* (i)$\Rightarrow$(ii): take $y = x$. Every element of $\mathrm{orb}_{G_x}(x)$ has the form $k\cdot x$ with $k \in G_x$, hence equals $x$; so $\mathrm{orb}_{G_x}(x) = \{x\}$. By (i), $\mathrm{orb}_G(x) = \{x\}$, i.e. $g\cdot x = x$ for all $g$. As $x$ was arbitrary, the action is trivial. (ii)$\Rightarrow$(i): if the action is trivial, both orbits are $\{y\}$. $\square$

Combining Theorems 8.1 and 8.2 with $Y = X$ gives a second, purely structural proof of Theorem 3.2. The conceptual reading is worth stating: *a $G$-set is never independent of itself, because a stabiliser cannot move the point it stabilises*. Pair rigidity is self-independence failing, and the failure is as elementary as it could be.

**Remark 8.3 (Orbitals are suborbits).** Theorem 8.1 also encodes the classical fact that the orbital decomposition of $\{x\}\times X$ is the decomposition of $X$ into $G_x$-orbits — the *suborbits*. For a transitive action, therefore, $s$ equals the number of suborbits, and orbital counting becomes stabiliser counting one level down. This is the recursion that governs the entire hierarchy of Section 7.

---

## 9. Computational evidence

The following data were computed by explicit Burnside sums over small permutation groups, cross-checked against direct enumeration of orbits and orbitals. As before $n = |X|$, $r$ is the number of orbits, $s$ the number of orbitals, $K$ the kernel, and $F$ the vector of fixed-point counts of the group elements.

| action | $n$ | $\lvert G\rvert$ | $F$ | $r$ | $s$ | $s - r^2$ | $\lvert K\rvert(n-r)^2$ | $(\lvert G\rvert-\lvert K\rvert)(s-r^2)$ | $\lvert G\rvert(s-r^2)$ |
|---|---|---|---|---|---|---|---|---|---|
| trivial on $3$ points | 3 | 1 | $[3]$ | 3 | 9 | 0 | 0 | 0 | 0 |
| $\mathbb{Z}/2$ swap on $2$ | 2 | 2 | $[2,0]$ | 1 | 2 | 1 | 1 | **1** | 2 |
| $\mathbb{Z}/2$ swap $(0\,1)$ on $3$ | 3 | 2 | $[3,1]$ | 2 | 5 | 1 | 1 | **1** | 2 |
| $\mathbb{Z}/3$ rotation on $3$ | 3 | 3 | $[3,0,0]$ | 1 | 3 | 2 | 4 | **4** | 6 |
| $S_3$ on $3$ | 3 | 6 | $[3,1,1,1,0,0]$ | 1 | 2 | 1 | 4 | 5 | 6 |
| $\mathbb{Z}/2$ $(0\,1)(2\,3)$ on $4$ | 4 | 2 | $[4,0]$ | 2 | 8 | 4 | 4 | **4** | 8 |
| Klein four regular on $4$ | 4 | 4 | $[4,0,0,0]$ | 1 | 4 | 3 | 9 | **9** | 12 |
| $\mathbb{Z}/4$ regular on $4$ | 4 | 4 | $[4,0,0,0]$ | 1 | 4 | 3 | 9 | **9** | 12 |
| $D_4$ on the square | 4 | 8 | $[4,0,0,0,0,0,2,2]$ | 1 | 3 | 2 | 9 | 14 | 16 |
| $\mathbb{Z}/5$ regular on $5$ | 5 | 5 | $[5,0,0,0,0]$ | 1 | 5 | 4 | 16 | **16** | 20 |
| $\mathbb{Z}/3$ on $5$ points | 5 | 3 | $[5,2,2]$ | 3 | 11 | 2 | 4 | **4** | 6 |
| Klein four on $6$ points | 6 | 4 | $[6,2,2,2]$ | 3 | 12 | 3 | 9 | **9** | 12 |

Readings of the table.

1. **Rigidity.** $s = r^2$ occurs only in the first row, the trivial action — Theorem 5.3.
2. **Sharpness.** Bold entries mark equality in Theorem 6.3. They are exactly the rows whose non-identity elements all have the same number of fixed points, as Theorem 6.6 requires. $S_3$ (with $F = [3,1,1,1,0,0]$) and $D_4$ (with $F = [4,0,0,0,0,0,2,2]$) have non-constant fixity and are strict: $4 < 5$ and $9 < 14$.
3. **The last row.** The Klein four-group on six points shows that the extremal class is wider than "same fixed set" (Remark 6.7).
4. **The weak bound is never tight.** The last column strictly exceeds the second-to-last in every nontrivial row (Remark 6.8): the Cauchy–Schwarz correction of Section 6 is exactly what makes the bound sharp.

**Higher arity.** The orbit counts $s_k$ on $X^k$ against the independence prediction $r^k$, for $k = 2,3,4$:

| action | $r$ | $r^2, r^3, r^4$ | $s_2, s_3, s_4$ |
|---|---|---|---|
| trivial on $3$ points | 3 | $9,\ 27,\ 81$ | $9,\ 27,\ 81$ |
| $\mathbb{Z}/3$ rotation on $3$ | 1 | $1,\ 1,\ 1$ | $3,\ 9,\ 27$ |
| $S_3$ on $3$ | 1 | $1,\ 1,\ 1$ | $2,\ 5,\ 14$ |
| $\mathbb{Z}/5$ regular on $5$ | 1 | $1,\ 1,\ 1$ | $5,\ 25,\ 125$ |
| $\mathbb{Z}/3$ on $5$ points | 3 | $9,\ 27,\ 81$ | $11,\ 47,\ 219$ |
| Klein four on $6$ points | 3 | $9,\ 27,\ 81$ | $12,\ 60,\ 336$ |

Equality holds only in the trivial row, in accordance with Theorem 7.4; and in every row $s_{k+1}\ge s_k r$, as Theorem 7.2 requires. (For $S_3$ on three points the counts $2,5,14$ have a clean description: the orbits of the full symmetric group on $X$ acting on $k$-tuples are in bijection with the set partitions of $\{1,\dots,k\}$ into at most $|X|$ blocks, since a tuple is determined up to symmetry by which coordinates agree.)

**A negative result.** One might hope for a bound $\Delta \ge c\,n$ with an absolute constant $c > 0$. This is false. Let $G = \mathbb{Z}/2$ act on $n \ge 2$ points by a single transposition. Then $r = n-1$ and $s = (n-1)^2 + 1$, so
$$\Delta = 1 \qquad \text{for every } n,$$
verified numerically for $2 \le n \le 10$. The defect is not controlled by the size of $X$; the correct control is the quantity $|K|(n-r)^2/(|G|-|K|)$ appearing in Theorem 6.3, which for this family equals $1$ for all $n$ — the sharp bound is exactly attained, as it must be, since the transposition is the only non-identity element and fixity is trivially constant off the kernel.

---

## 10. Discussion

### 10.1 What the three proofs buy

Theorem 3.2 is a purely logical statement: pair-independence asks one group element to hold a point still and move it, which cannot be done. It needs no hypotheses whatsoever and applies to infinite groups, infinite sets, and non-faithful actions. Theorem 5.3 is a probabilistic statement: the defect is a variance, and a variance vanishes only for constant random variables. It requires finiteness but repays it with Theorems 5.6, 6.3 and 6.6 — an explicit lower bound and a complete description of when that bound is attained. Theorem 8.2 is a structural statement: a $G$-set is never independent of itself, because stabilisers cannot move their own point. It generalises to a criterion (Theorem 8.1) for when two *different* $G$-sets are independent, and that criterion is the entry point to a recursion through the stabiliser chain.

### 10.2 Relation to classical permutation group theory

For a transitive action, $s$ is the rank, and Theorem 8.1 recovers the classical identification of orbitals with suborbits of a point stabiliser. Rigidity says the rank of a nontrivial transitive action always exceeds $r^2 = 1$, i.e. is at least $2$ — trivially true, but the general (intransitive) statement $s > r^2$ is the correct generalisation, and the quantitative bound of Theorem 6.3 is new content even in the transitive case, where $r = 1$, $K$ is the kernel of a transitive action, and the bound reads $|K|(n-1)^2 \le (|G|-|K|)(s-1)$. For a *faithful* transitive action $|K| = 1$ and this becomes
$$s \ \ge\ 1 + \frac{(n-1)^2}{|G|-1},$$
a lower bound on the rank in terms of the degree and the order — nontrivial precisely for groups that are small relative to their degree.

### 10.3 Limitations

Three caveats deserve emphasis. First, the quantitative results require finiteness; the qualitative Theorem 3.2 does not, but no quantitative analogue for infinite actions is offered here. Second, the defect is *not* controlled by $|X|$ alone (Section 9). Third, Theorem 6.6 classifies equality only for nontrivial actions; for trivial actions both sides vanish and the constant-fixity condition is vacuous.

### 10.4 Algorithms

All quantities above are computable from the fixed-point vector $F$ alone, which for a permutation group of order $m$ on $n$ points is obtained in $O(mn)$ time. From $F$ one gets $r$, all the $s_k$, the kernel size $|K| = |\{g : F(g) = n\}|$, the defect, and the two bounds in $O(m)$ arithmetic operations per arity. In particular the entire rigidity profile of an action is a single pass over the group.

### 10.5 Future directions

**Conjecture (rank gap / quantitative 2-transitivity).** For a faithful transitive action of $G$ on $X$ with $|X| = n \ge 2$, the number of orbitals satisfies
$$s \ \ge\ 1 + \Bigl\lceil \frac{n-1}{m} \Bigr\rceil, \qquad m = \text{the largest suborbit length},$$
and consequently $s = 2$ forces $2$-transitivity. Formally, $s = 2$ should be equivalent to the conjunction of transitivity on $X$ and transitivity on the set of ordered pairs of distinct points. The key insight is that the orbital partition of $\{x\}\times X$ is precisely the suborbit decomposition of the stabiliser $G_x$ (Remark 8.3), so orbital counting is stabiliser counting one level down — the arity hierarchy of Section 7 read as a recursion on the point stabiliser.

**Moment rigidity as an invariant of the kernel.** The whole sequence $(s_k)_{k\ge 1}$ is the moment sequence of $F$; since $F$ takes finitely many values, the moment sequence determines the distribution of $F$, hence in particular $|K| = |\{g : F(g) = n\}|$ and the fixity profile. It is natural to ask how much of the action is recoverable from $(s_k)$ — for instance whether the extremal condition of Theorem 6.6 is detectable from $s_1, s_2, s_3$ alone. (It is: constant fixity off the kernel means $F$ has a two-point distribution, and a two-point distribution is determined by three moments.)

**Sharpening beyond the second moment.** Cauchy–Schwarz on the complement uses only first and second moments off the kernel. A Chebyshev or power-mean refinement using $s_3$ should give a strictly stronger lower bound on $\Delta$ for actions with non-constant fixity, e.g. for $S_3$ and $D_4$ in the table of Section 9, where the sharp bound is strict.

**Infinite and topological analogues.** For a compact group acting continuously on a compact space, Burnside's average is replaced by integration against Haar measure and the variance identity should persist verbatim, with $r$ and $s$ interpreted as suitable dimensions of invariant function spaces. Rigidity would then read: the space of invariant functions on $X\times X$ is the tensor square of the space of invariant functions on $X$ only for the trivial action.

---

## 11. Summary of results

1. **Rigidity at arity two.** For any group acting on any set, every orbital is a product of two orbits if and only if the action is trivial.
2. **Relational form.** The orbit relation on pairs is the product of the orbit relations if and only if the action is trivial.
3. **Variance identity.** For finite actions, $|G|(s - r^2) = \sum_{g}(F(g)-r)^2$: the rigidity defect is the variance of the fixed-point statistic.
4. **Counting rigidity.** $s = r^2$ if and only if the action is trivial; always $s \ge r^2$.
5. **Quantitative rigidity.** $|K|(n-r)^2 \le |G|(s-r^2)$, and sharply $|K|(n-r)^2 \le (|G|-|K|)(s-r^2)$.
6. **Extremal classification.** For a nontrivial action the sharp bound is an equality if and only if all elements outside the kernel fix the same number of points.
7. **Higher arity.** $s_{k+1}\ge s_k\,r$, and for every $k\ge 2$, $s_k = r^k$ if and only if the action is trivial.
8. **Structural mechanism.** Orbits on $X\times Y$ are products of orbits if and only if every stabiliser $G_x$ is transitive on every $G$-orbit of $Y$; a $G$-set is never independent of itself unless the action is trivial.
9. **A negative result.** No bound $s - r^2 \ge c\,n$ with an absolute $c>0$ holds: a single transposition on $n$ points has defect $1$ for every $n$.
