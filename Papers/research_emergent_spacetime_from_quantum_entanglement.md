# Emergent Spacetime from Entanglement: Min-Cut Geometries, the ER = EPR Dictionary, and a Non-Geometric Five-Party Entropy Vector

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

We develop, in a finite and completely rigorous setting, the mathematics behind the proposal that spacetime geometry is built out of quantum entanglement. A *bulk geometry* is a finite symmetric nonnegatively weighted graph, some of whose cells are designated *boundary* cells; the entanglement entropy of a boundary region is the minimum cut weight over bulk regions homologous to it, the discrete Ryu–Takayanagi prescription. We isolate a single engine — the **contraction principle**: any Boolean recombination rule that is nonexpansive for Hamming distance yields an entropy inequality — and use it to derive subadditivity, strong subadditivity, monogamy of mutual information, and a five-party cyclic inequality
$$\sum_{j\in\mathbb{Z}_5} S(A_jA_{j+1}) + S(A_0A_1A_2A_3A_4) \le \sum_{j\in\mathbb{Z}_5} S(A_jA_{j+1}A_{j+2}).$$

We then prove the two halves of the ER = EPR correspondence in this model. **Reconstruction:** for geometries without hidden bulk cells, every edge weight equals half the mutual information of its endpoints, $w(u,v) = I(u:v)/2$; consequently the two-point correlation table determines every region entropy and the entire bridge (connectivity) structure, and this is sharp — the self-loop weights are pure gauge, and one hidden cell already destroys uniqueness (an explicit star/triangle pair). **Bridges:** geometric disconnection forces exact additivity of entropies, hence zero mutual information, and contrapositively any two boundary regions with positive mutual information are joined by a positive-area bulk path. For a real two-qubit pure state $\psi$ with concurrence $C(\psi) = 2|\det\psi|$, the single-throat geometry of area $C(\psi)$ contains an Einstein–Rosen bridge if and only if $\psi$ is entangled; the throat mutual information is $2C(\psi)$ and the linear entanglement entropy $2(1-\operatorname{Tr}\rho^2)$ equals $C(\psi)^2$.

Finally we chart the obstruction side. The four-party GHZ entropy pattern satisfies subadditivity and strong subadditivity but violates monogamy, so it admits no bulk dual. Our main new result is an explicit five-party entropy vector $S_w$ on the $32$ subsets of a five-element set which satisfies **subadditivity, strong subadditivity, weak monotonicity and monogamy of mutual information on all disjoint arguments** — verified exhaustively over all $32^3 = 32768$ triples of subsets — yet violates the cyclic inequality by exactly one unit. Hence the cyclic inequality is independent of those four families, and no bulk geometry whatsoever realises $S_w$: the cone of geometric entropy vectors is strictly smaller than the cone cut out by the classical constraints, and the obstruction is invisible to all of them.

**Keywords:** holographic entropy cone; Ryu–Takayanagi; min-cut; monogamy of mutual information; ER = EPR; entanglement entropy; emergent geometry; concurrence.

---

## 1. Introduction

Two 1935 papers of Einstein — one with Rosen on bridges in the gravitational field, one with Podolsky and Rosen on correlated quantum systems — were unified in spirit by the ER = EPR proposal of Maldacena and Susskind: entangled pairs *are* microscopic wormholes. The proposal sits inside a broader programme, initiated by the Ryu–Takayanagi formula and the observation that entanglement entropy in a holographic conformal field theory computes the area of a minimal bulk surface, according to which spacetime geometry is emergent from entanglement.

Making these statements precise requires a model in which "geometry" and "entropy" are both finite, computable objects. The natural candidate is a weighted graph together with the min-cut functional. This is the setting of the *holographic entropy cone* programme, and it is the setting we adopt. The point of view we push here is that the entire theory of min-cut entropy inequalities reduces to a single combinatorial fact about Boolean maps, and that once one has that fact one can equally well investigate the *failures* of the geometry–entanglement dictionary.

Our contributions, in order of appearance:

1. **A contraction calculus** (§3). A Boolean map $\chi : \{0,1\}^k \to \{0,1\}^m$ that does not increase Hamming distance produces an entropy inequality $\sum_j S(B_j) \le \sum_i S(A_i)$ whenever the boundary traces are compatible. Subadditivity, strong subadditivity, monogamy and the cyclic inequality are all instances, obtained from explicit, finitely checkable certificates.

2. **A five-party cyclic inequality** (§4), with its certificate: the rule $\mathrm{cyc}(c_0,\dots,c_4) = c_4 \wedge \lnot c_2 \wedge (c_0 \vee (c_1 \wedge \lnot c_3))$ in five rotations, plus the union.

3. **Reconstruction of geometry from entanglement** (§5), $w(u,v) = I(u:v)/2$, with its rigidity, connectivity and gauge-sharpness corollaries, and with an explicit counterexample showing that one hidden bulk cell already destroys uniqueness.

4. **The ER = EPR dictionary** (§6): no bridge $\Rightarrow$ no entanglement; positive entanglement $\Rightarrow$ a bridge; the two-qubit throat model with throat area equal to the concurrence; the $n$-Bell-pair matching geometry.

5. **Obstructions** (§7): GHZ has no geometric dual; and the main new result, a five-party entropy vector $S_w$ satisfying subadditivity, strong subadditivity, weak monotonicity and monogamy while violating the cyclic inequality, establishing the independence of the latter and exhibiting a non-geometric entropy vector invisible to the four classical families.

Everything below is stated for finite structures and every verification is a finite computation.

---

## 2. The model

### 2.1 Bulk geometries

**Definition 2.1 (Bulk geometry).** Let $V$ be a finite set of *cells*. A **bulk geometry** on $V$ is a function $w : V \times V \to \mathbb{R}$ with
$$w(u,v) = w(v,u), \qquad w(u,v) \ge 0 \quad \text{for all } u,v \in V.$$
We read $w(u,v)$ as the area of the wall separating cells $u$ and $v$; $w(u,v) = 0$ means the cells are not directly joined.

**Definition 2.2 (Region and separation indicator).** A **region** is a Boolean function $f : V \to \{0,1\}$. For $a,b \in \{0,1\}$ set $\mathrm{sep}(a,b) = 0$ if $a = b$ and $1$ otherwise. Thus $\mathrm{sep}(f(u),f(v))$ records whether the region $f$ separates $u$ from $v$.

**Definition 2.3 (Area of a region).** The **area** of a region $f$ in the geometry $w$ is
$$\mathcal{A}_w(f) \;=\; \frac{1}{2}\sum_{u \in V}\sum_{v \in V} \mathrm{sep}\bigl(f(u),f(v)\bigr)\, w(u,v).$$

Three elementary properties will be used constantly:

* $\mathcal{A}_w(f) \ge 0$;
* $\mathcal{A}_w(\text{constant}) = 0$;
* $\mathcal{A}_w(\lnot f) = \mathcal{A}_w(f)$, since $\mathrm{sep}(\lnot a, \lnot b) = \mathrm{sep}(a,b)$;
* the diagonal never contributes, since $\mathrm{sep}(a,a) = 0$; hence $\mathcal{A}_w$ depends only on the off-diagonal weights.

### 2.2 Holographic models and min-cut entropy

**Definition 2.4 (Holographic model).** A **holographic model** is a bulk geometry $w$ on a finite set $V$ together with a *boundary* subset $\partial \subseteq V$. Cells outside $\partial$ are **hidden**.

**Definition 2.5 (Admissibility).** A region $f$ is **admissible** for a boundary region $A$ if $f(v) = A(v)$ for every $v \in \partial$. The set of admissible regions is nonempty (it contains $A$ itself) and finite.

**Definition 2.6 (Min-cut entropy).** The **entanglement entropy** of a boundary region $A$ is
$$S(A) \;=\; \min\bigl\{\, \mathcal{A}_w(f) \;:\; f \text{ admissible for } A \,\bigr\}.$$
A minimiser is a **minimal surface** for $A$. Since the admissible set is a nonempty finite set, minimisers exist.

Two consequences are immediate: $S(A) \ge 0$, and $S(A) \le \mathcal{A}_w(f)$ for every admissible $f$ — the second is the workhorse of every proof below, since it converts *any* construction of an admissible region into an upper bound on entropy.

**Proposition 2.7 (Normalisation and purity).** $S(\emptyset) = 0$ and $S(\partial) = 0$. Moreover $S$ depends on $A$ only through $A \cap \partial$.

*Proof.* The constant regions $0$ and $1$ are admissible for $\emptyset$ and $\partial$ respectively, and have area $0$; entropy is nonnegative. The last claim holds because admissibility only constrains $A$ on $\partial$. $\square$

**Theorem 2.8 (Complementarity).** For every boundary region $A$, $S(\partial \setminus A) = S(A)$.

*Proof.* Let $f$ be a minimal surface for $A$. Then $\lnot f$ is admissible for $\partial \setminus A$: on the boundary $\lnot f(v) = \lnot A(v)$, which is the indicator of $\partial\setminus A$ there. Hence $S(\partial\setminus A) \le \mathcal{A}_w(\lnot f) = \mathcal{A}_w(f) = S(A)$. Applying the same bound to $\partial \setminus A$ and using $\partial\setminus(\partial\setminus A) = A\cap\partial$ together with Proposition 2.7 gives the reverse inequality. $\square$

This is the model's statement that the global state is pure: a region and its complement carry equal entropy.

**Definition 2.9 (Mutual and tripartite information).**
$$I(A:B) \;=\; S(A) + S(B) - S(A\cup B), \qquad
I_3(A:B:C) \;=\; I(A:B) + I(A:C) - I(A : B\cup C).$$

---

## 3. The contraction calculus

Everything in §3–§4 rests on one lemma.

**Lemma 3.1 (Recombination principle).** Let $F_1,\dots,F_k$ and $G_1,\dots,G_m$ be regions such that for every pair of cells $u,v$ with $w(u,v) \ne 0$,
$$\sum_{j=1}^{m}\mathrm{sep}\bigl(G_j(u),G_j(v)\bigr) \;\le\; \sum_{i=1}^{k}\mathrm{sep}\bigl(F_i(u),F_i(v)\bigr).$$
Then $\sum_{j} \mathcal{A}_w(G_j) \le \sum_i \mathcal{A}_w(F_i)$.

*Proof.* Multiply the hypothesis by $w(u,v) \ge 0$ (the inequality is trivial when $w(u,v) = 0$), sum over all $u,v$, exchange the order of summation between the family index and the cell indices, and divide by $2$. $\square$

**Definition 3.2 (Contraction map).** A map $\chi : \{0,1\}^k \to \{0,1\}^m$ is a **contraction** if for all $a,b \in \{0,1\}^k$,
$$d_H\bigl(\chi(a),\chi(b)\bigr) \;\le\; d_H(a,b),$$
where $d_H$ is Hamming distance. Equivalently, $\sum_j \mathrm{sep}(\chi(a)_j, \chi(b)_j) \le \sum_i \mathrm{sep}(a_i,b_i)$.

Note that $m$ may exceed $k$: a contraction may have more outputs than inputs, and the useful ones do.

**Theorem 3.3 (Contraction principle).** Let $\chi$ be a contraction $\{0,1\}^k \to \{0,1\}^m$, let $A_1,\dots,A_k$ and $B_1,\dots,B_m$ be boundary regions, and suppose the **boundary-trace compatibility** condition holds:
$$\chi\bigl(A_1(v),\dots,A_k(v)\bigr)_j = B_j(v) \qquad \text{for all } v \in \partial, \; j = 1,\dots,m.$$
Then
$$\sum_{j=1}^{m} S(B_j) \;\le\; \sum_{i=1}^{k} S(A_i).$$

*Proof.* Choose a minimal surface $F_i$ for each $A_i$ and set $G_j(v) = \chi(F_1(v),\dots,F_k(v))_j$. For $v \in \partial$ we have $F_i(v) = A_i(v)$, so $G_j(v) = B_j(v)$ by compatibility: each $G_j$ is admissible for $B_j$. Applying the contraction property pointwise at each pair of cells and invoking Lemma 3.1,
$$\sum_j S(B_j) \le \sum_j \mathcal{A}_w(G_j) \le \sum_i \mathcal{A}_w(F_i) = \sum_i S(A_i). \qquad\square$$

Thus every holographic entropy inequality of this shape is certified by a finite Boolean object, and the search for inequalities becomes a search over Hamming-nonexpansive maps — a finite search for each $k$.

### 3.1 Intersection–union: subadditivity and strong subadditivity

**Lemma 3.4.** The map $\chi_{\wedge\vee}(a_1,a_2) = (a_1\wedge a_2,\; a_1 \vee a_2)$ is a contraction $\{0,1\}^2 \to \{0,1\}^2$.

*Proof.* Sixteen cases. Equivalently, submodularity of the cut: $\mathrm{sep}(a_1\wedge a_2, b_1 \wedge b_2) + \mathrm{sep}(a_1\vee a_2, b_1\vee b_2) \le \mathrm{sep}(a_1,b_1) + \mathrm{sep}(a_2,b_2)$. $\square$

**Theorem 3.5 (Subadditivity).** For all boundary regions $A,B$: $\;S(A\cup B) \le S(A) + S(B)$.

*Proof.* Let $F,G$ be minimal surfaces for $A,B$. Then $F\vee G$ is admissible for $A\cup B$, so $S(A\cup B) \le \mathcal{A}_w(F\vee G)$. By Lemma 3.4 and Lemma 3.1, $\mathcal{A}_w(F\wedge G) + \mathcal{A}_w(F \vee G) \le \mathcal{A}_w(F) + \mathcal{A}_w(G) = S(A) + S(B)$, and $\mathcal{A}_w(F\wedge G) \ge 0$. $\square$

**Corollary 3.6.** $I(A:B) \ge 0$, and $I$ is symmetric.

**Theorem 3.7 (Strong subadditivity).** For boundary regions $A,B,C$ with $A$ and $C$ disjoint,
$$S(A\cup B\cup C) + S(B) \;\le\; S(A\cup B) + S(B\cup C).$$

*Proof.* Let $F$ be minimal for $A\cup B$ and $G$ minimal for $B\cup C$. On the boundary $F = A\vee B$ and $G = B\vee C$, so — using disjointness of $A$ and $C$ — $F \vee G$ traces out $A\cup B\cup C$ and $F\wedge G$ traces out $B$. Both are therefore admissible for their targets, and Lemma 3.4 with Lemma 3.1 gives
$$S(A\cup B\cup C) + S(B) \le \mathcal{A}_w(F\vee G) + \mathcal{A}_w(F\wedge G) \le \mathcal{A}_w(F) + \mathcal{A}_w(G),$$
which is $S(A\cup B) + S(B\cup C)$. $\square$

In the geometric setting the Lieb–Ruskai theorem is thus nothing more than submodularity of a minimum cut.

### 3.2 The minority rule: monogamy of mutual information

**Lemma 3.8 (Minority contraction).** The map
$$\chi_{\min}(a_1,a_2,a_3) = \bigl(a_1\wedge a_2\wedge\lnot a_3,\; a_1\wedge a_3 \wedge \lnot a_2,\; a_2 \wedge a_3 \wedge \lnot a_1,\; a_1\vee a_2\vee a_3\bigr)$$
is a contraction $\{0,1\}^3 \to \{0,1\}^4$.

*Proof.* Exhaustive check over the $2^6 = 64$ pairs of input patterns. $\square$

**Remark 3.9 (The negations are essential).** Replacing the minority regions by the plain pairwise intersections $a_i \wedge a_j$ destroys the property: for $a = (1,1,1)$ and $b = (0,0,0)$ the three intersections and the union all separate the pair, giving $4 \le 3$. The minority rule is the unique nearby recipe that works, and this is why monogamy is genuinely subtler than subadditivity.

**Theorem 3.10 (Monogamy of mutual information).** For pairwise disjoint boundary regions $A,B,C$,
$$S(A) + S(B) + S(C) + S(A\cup B\cup C) \;\le\; S(A\cup B) + S(B\cup C) + S(A\cup C).$$

*Proof.* Let $F, G, H$ be minimal surfaces for $A\cup B$, $B\cup C$, $A\cup C$. On the boundary, using pairwise disjointness, one checks case by case that $F \wedge H \wedge \lnot G$ traces out $A$, that $F\wedge G \wedge \lnot H$ traces out $B$, that $G\wedge H\wedge\lnot F$ traces out $C$, and that $F\vee G\vee H$ traces out $A\cup B\cup C$. Each of the four is therefore admissible for its target, and Lemma 3.8 with Lemma 3.1 bounds the sum of their areas by $\mathcal{A}_w(F) + \mathcal{A}_w(G) + \mathcal{A}_w(H)$. $\square$

**Corollary 3.11 (Nonpositive tripartite information).** For pairwise disjoint $A,B,C$: $\;I_3(A:B:C) \le 0$, equivalently $I(A : B\cup C) \ge I(A:B) + I(A:C)$.

Monogamy fails for general quantum states (see §7.1); it is a signature of geometry.

---

## 4. The five-party cyclic inequality

**Definition 4.1 (The cyclic rule).** For $c_0,\dots,c_4 \in \{0,1\}$ put
$$\mathrm{cyc}(c_0,c_1,c_2,c_3,c_4) \;=\; c_4 \wedge \lnot c_2 \wedge \bigl(c_0 \vee (c_1 \wedge \lnot c_3)\bigr).$$

**Lemma 4.2 (Cyclic contraction).** The map $\{0,1\}^5 \to \{0,1\}^6$
$$\chi_{\mathrm{cyc}}(a_0,\dots,a_4) = \Bigl(\mathrm{cyc}(a_j, a_{j+1}, a_{j+2}, a_{j+3}, a_{j+4})\Bigr)_{j\in\mathbb{Z}_5} \;\frown\; \bigl(a_0\vee a_1 \vee a_2 \vee a_3 \vee a_4\bigr)$$
(indices modulo $5$) is a contraction: six outputs from five inputs.

*Proof.* Exhaustive verification over all $2^{10} = 1024$ pairs of input patterns. $\square$

**Lemma 4.3 (Boundary trace).** If at most one of $a_0,\dots,a_4$ is $1$ — the pointwise form of pairwise disjointness of five regions — then, writing $t_j = a_j \vee a_{j+1} \vee a_{j+2}$ for the consecutive triples,
$$\mathrm{cyc}(t_0,t_1,t_2,t_3,t_4) \;=\; a_0 \vee a_1 .$$

*Proof.* Exhaustive check over the six admissible patterns (all zero, or exactly one coordinate set). $\square$

So on the boundary the cyclic rule turns the five consecutive *triples* into the five consecutive *pairs*, one rotation at a time.

**Theorem 4.4 (Five-party cyclic inequality).** Let $A_0,\dots,A_4$ be pairwise disjoint boundary regions, indices modulo $5$. Then
$$\sum_{j\in\mathbb{Z}_5} S(A_jA_{j+1}) \;+\; S(A_0A_1A_2A_3A_4) \;\;\le\;\; \sum_{j\in\mathbb{Z}_5} S(A_jA_{j+1}A_{j+2}),$$
where juxtaposition denotes union.

*Proof.* Choose a minimal surface $F_j$ for each triple $A_jA_{j+1}A_{j+2}$. Set $G_j = \mathrm{cyc}(F_j, F_{j+1}, F_{j+2}, F_{j+3}, F_{j+4})$ and $G_5 = F_0 \vee \cdots \vee F_4$. On the boundary $F_j$ traces out $A_jA_{j+1}A_{j+2}$, so Lemma 4.3 (applied to the $j$-th rotation of the disjointness pattern) says $G_j$ traces out $A_jA_{j+1}$, and clearly $G_5$ traces out the full union. Each $G$ is admissible for its target; Lemma 4.2 with Lemma 3.1 bounds the total area of the $G$'s by the total area of the $F$'s, which is the right-hand side. $\square$

The inequality is *false* for general quantum states, and — as we prove in §7.2 — it is not a consequence of monogamy either.

---

## 5. Reconstruction: geometry from entanglement

Throughout this section a model is **hidden-cell-free** if $\partial = V$.

**Lemma 5.1.** In a hidden-cell-free model, $S(A) = \mathcal{A}_w(A)$ for every region $A$: the only admissible region for $A$ is $A$ itself.

**Definition 5.2.** Write $\{u\}$ for the singleton region supported at $u$.

**Theorem 5.3 (Metric reconstruction).** Let the model be hidden-cell-free and let $u \ne v$. Then
$$w(u,v) \;=\; \tfrac{1}{2}\, I\bigl(\{u\} : \{v\}\bigr).$$

*Proof sketch.* By Lemma 5.1, $I(\{u\}:\{v\}) = \mathcal{A}_w(\{u\}) + \mathcal{A}_w(\{v\}) - \mathcal{A}_w(\{u,v\})$. Compare the three cut sums term by term. For a pair of cells $x,y$ with $\{x,y\} \cap \{u,v\} = \emptyset$ all three separation indicators vanish. For $x \notin \{u,v\}$ the pair $(x,u)$ is separated by $\{u\}$ and by $\{u,v\}$, and $(x,v)$ by $\{v\}$ and by $\{u,v\}$, so those contributions cancel in the alternating sum. The only surviving term is the pair $(u,v)$, separated by $\{u\}$ and by $\{v\}$ but *not* by $\{u,v\}$; it contributes $2w(u,v)$ to the sum after the factor $\tfrac12$. Hence $I(\{u\}:\{v\}) = 2w(u,v)$. $\square$

**Corollary 5.4 (Rigidity).** Two hidden-cell-free models on the same cell set with equal two-point mutual informations have equal off-diagonal weights.

**Theorem 5.5 (Spacetime from entanglement).** Let $M$ and $N$ be hidden-cell-free models on the same finite cell set. The following are equivalent:

1. $I_M(\{u\}:\{v\}) = I_N(\{u\}:\{v\})$ for all $u, v$;
2. $S_M(A) = S_N(A)$ for every region $A$.

Moreover (1) implies that $M$ and $N$ have identical **bridge relations**: writing $u \sim v$ for the reflexive–transitive closure of the relation $w(u,v) > 0$, we have $u \sim_M v \iff u \sim_N v$ for all $u,v$.

*Proof.* (2) $\Rightarrow$ (1) is the definition of mutual information. For (1) $\Rightarrow$ (2), Corollary 5.4 gives equality of off-diagonal weights, and areas depend only on off-diagonal weights (the diagonal is never separated), so all entropies agree by Lemma 5.1. For the bridge relation: a self-loop step never moves a path, so bulk connectivity also depends only on the off-diagonal weights, and positivity of those is common to $M$ and $N$. $\square$

Thus for hidden-cell-free models the table of pairwise mutual informations determines the entire emergent spacetime — every area and the whole connectivity structure.

**Theorem 5.6 (Sharpness: the diagonal is gauge).** Let $w$ be a bulk geometry and let $w'$ agree with $w$ off the diagonal, with arbitrary nonnegative self-loop weights. Then $\mathcal{A}_{w'}(f) = \mathcal{A}_{w}(f)$ for every region $f$, and $w$ and $w'$ have the same bridge relation.

Hence entanglement determines exactly the off-diagonal data — no more (Theorem 5.5), and no less (Theorem 5.6).

**Theorem 5.7 (One hidden cell destroys uniqueness).** There exist two holographic models on the same four cells, with the same three boundary cells $\{0,1,2\}$ and one hidden cell $3$, such that $S$ agrees on every boundary region while the geometries differ:

* the **star**: $w(i,3) = 1$ for $i = 0,1,2$ and $w(i,j) = 0$ for distinct boundary cells $i,j$;
* the **triangle**: $w(i,j) = \tfrac12$ for distinct boundary cells $i,j$, and $w(i,3) = 0$.

Both assign entropy $0$ to $\emptyset$ and to $\{0,1,2\}$, and entropy $1$ to every other boundary region; yet $w_{\mathrm{star}}(0,1) = 0 \ne \tfrac12 = w_{\mathrm{tri}}(0,1)$.

*Proof sketch.* With a single hidden cell $c$, the min-cut entropy of a boundary region $A$ is the minimum of the two areas obtained by placing $c$ inside or outside: $S(A) = \min\{\mathcal{A}_w(A \cup \{c\}), \mathcal{A}_w(A)\}$. For the star, a boundary region that is neither empty nor everything cuts either one or two unit throats depending on where $c$ is placed, and the minimum is $1$; the empty and full regions cut nothing. For the triangle there is nothing to minimise: a region with one boundary cell in and two out cuts two edges of weight $\tfrac12$, total $1$, and symmetrically. The eight boundary regions therefore have matching entropies. $\square$

**Remark 5.8 (Entanglement without an edge).** The star also illustrates the bridge theorem of §6 in its purest form. Its boundary cells $0$ and $1$ satisfy $I(\{0\}:\{1\}) = 1 + 1 - 1 = 1 > 0$, so they must be joined by a bulk path — and they are, although $w(0,1) = 0$: the path runs $0 \to 3 \to 1$ through the hidden cell. Entanglement with no direct wall, mediated by the deep bulk.

**Theorem 5.9 (Stability).** Let $M, M'$ be two models with the same boundary, and define the geometry distance $d(w,w') = \tfrac12\sum_{u,v}|w(u,v) - w'(u,v)|$. Then for every boundary region $A$,
$$\bigl|S_M(A) - S_{M'}(A)\bigr| \;\le\; d(w,w').$$

*Proof sketch.* For any fixed region $f$, $|\mathcal{A}_w(f) - \mathcal{A}_{w'}(f)| \le d(w,w')$ since separation indicators are bounded by $1$. Evaluating each model's entropy against the other's minimiser — admissibility depends only on the boundary, which is shared — gives the two-sided bound. $\square$

So the map from geometries to entanglement data is $1$-Lipschitz: the correspondence is robust, not a knife-edge coincidence.

---

## 6. The ER = EPR dictionary

**Definition 6.1 (Adjacency and bridges).** Cells $u, v$ are **adjacent** if $w(u,v) > 0$. A **bridge** from $u$ to $v$ is a chain of adjacent steps, i.e. $u \sim v$ in the reflexive–transitive closure of adjacency.

### 6.1 Disconnection implies no entanglement

**Theorem 6.2 (Additivity across a geometric split).** Let $U \subseteq V$ be a set of cells with $w(x,y) = 0$ whenever $x \in U$ and $y \notin U$. Let $A \subseteq U$ and $B \subseteq V \setminus U$ be boundary regions. Then
$$S(A \cup B) \;=\; S(A) + S(B), \qquad\text{hence}\qquad I(A:B) = 0.$$

*Proof sketch.* Subadditivity gives "$\le$". For "$\ge$", take a minimal surface $f$ for $A \cup B$ and split it: let $f_A = f \wedge \mathbf{1}_U$ and $f_B = f \wedge \mathbf{1}_{V\setminus U}$. These are admissible for $A$ and $B$ respectively, and because no positive-weight wall crosses between $U$ and its complement, every separated pair carrying nonzero weight lies entirely inside $U$ or entirely outside; hence $\mathcal{A}_w(f_A) + \mathcal{A}_w(f_B) = \mathcal{A}_w(f)$. Therefore $S(A) + S(B) \le \mathcal{A}_w(f) = S(A\cup B)$. $\square$

**Theorem 6.3 (Entanglement forces a bridge).** If $I(A:B) > 0$ for boundary regions $A, B$, then there exist cells $u \in A$ and $v \in B$ with a bridge from $u$ to $v$.

*Proof.* Contrapositive. If no cell of $A$ is bridged to a cell of $B$, let $U$ be the union of the connected components (for the adjacency relation) meeting $A$. Then no positive-weight wall crosses out of $U$, $A \subseteq U$ and $B \cap U = \emptyset$, so Theorem 6.2 gives $I(A:B) = 0$. $\square$

**Theorem 6.4 (The two networks coincide).** In a hidden-cell-free model, call $u,v$ *directly entangled* if $I(\{u\}:\{v\}) > 0$. Then $u \sim v$ (a chain of bridges) if and only if $u$ and $v$ are joined by a chain of directly entangled pairs.

*Proof.* By Theorem 5.3, for $u \ne v$ adjacency $w(u,v) > 0$ is *equivalent* to direct entanglement $I(\{u\}:\{v\}) > 0$. The two relations have the same reflexive–transitive closure. $\square$

### 6.2 One qubit pair, one throat

**Definition 6.5.** A real two-qubit pure state is a $2\times 2$ real matrix $\psi$ with $\sum_{ij}\psi_{ij}^2 = 1$; it is a **product state** if $\psi_{ij} = x_i y_j$ for some vectors $x,y$. Its **concurrence** is $C(\psi) = 2\,|\det \psi|$.

**Lemma 6.6.** $\psi$ is a product state if and only if $\det \psi = 0$, i.e. if and only if $C(\psi) = 0$.

*Proof sketch.* A product matrix has rank $\le 1$, so zero determinant. Conversely, if $\det\psi = 0$ then $\psi$ has rank $\le 1$; explicitly, if $\psi_{00} \ne 0$ take $x = (1, \psi_{10}/\psi_{00})$ and $y = (\psi_{00}, \psi_{01})$, and check the four entries using $\psi_{00}\psi_{11} = \psi_{01}\psi_{10}$; the degenerate cases $\psi_{00} = 0$ are handled separately. $\square$

**Definition 6.7 (Single-throat geometry).** For $t \ge 0$ let $P_t$ be the hidden-cell-free model on two cells $\{0,1\}$ with $w(0,1) = t$ (and $w(0,0)=w(1,1)=0$).

**Proposition 6.8.** $I_{P_t}(\{0\}:\{1\}) = 2t$, and there is a bridge from $0$ to $1$ in $P_t$ if and only if $t > 0$.

*Proof.* The first claim is Theorem 5.3. For the second, the only possible step is the single edge. $\square$

**Theorem 6.9 (ER = EPR in the toy model).** Let $\psi$ be a real two-qubit pure state and assign to it the geometry $P_{C(\psi)}$: a single throat whose area is the concurrence. Then
$$\psi \text{ is entangled} \iff P_{C(\psi)} \text{ contains a bridge between its two cells} \iff I(\{0\}:\{1\}) > 0 .$$
Quantitatively $I(\{0\}:\{1\}) = 2\,C(\psi)$.

*Proof.* Combine Lemma 6.6 (entangled $\iff C(\psi) > 0$) with Proposition 6.8. $\square$

**Theorem 6.10 (Throat area is the square root of the linear entropy).** Let $\rho$ be the reduced state of the first qubit, $\rho_{ik} = \sum_j \psi_{ij}\psi_{kj}$, and let $S_{\mathrm{lin}}(\psi) = 2\bigl(1 - \operatorname{Tr}\rho^2\bigr)$ be the linear entanglement entropy. Then for a normalised $\psi$,
$$S_{\mathrm{lin}}(\psi) = C(\psi)^2, \qquad\text{hence}\qquad I(\{0\}:\{1\})^2 = 4\,S_{\mathrm{lin}}(\psi).$$

*Proof sketch.* Expand $\operatorname{Tr}\rho^2 = \sum_{i,k}\rho_{ik}^2$ in the entries of $\psi$ and use the normalisation $\sum_{ij}\psi_{ij}^2 = 1$; the resulting polynomial identity is $2(1 - \operatorname{Tr}\rho^2) = 4(\det\psi)^2 = C(\psi)^2$. The second claim follows from $I = 2C(\psi)$. $\square$

For a Bell state $C = 1$: throat area $1$, mutual information $2$, linear entropy $1$. For a product state everything vanishes: no throat, no bridge, no correlation.

### 6.3 Many pairs: the matching geometry

**Definition 6.11.** Given areas $t_0,\dots,t_{n-1} \ge 0$, the **matching geometry** has cell set $\{0,\dots,n-1\}\times\{0,1\}$, all cells on the boundary, and $w\bigl((i,b),(j,c)\bigr) = t_i$ if $i = j$ and $b \ne c$, and $0$ otherwise: $n$ disjoint throats.

**Theorem 6.12.** In the matching geometry:

1. **Partners:** $I\bigl(\{(i,0)\} : \{(i,1)\}\bigr) = 2t_i$.
2. **Strangers:** if $i \ne j$ then $I\bigl(\{(i,b)\}:\{(j,c)\}\bigr) = 0$ for all $b,c$.
3. **Bridges:** there is a bridge from $(i,b)$ to $(j,c)$ if and only if either $(i,b) = (j,c)$, or $i = j$ and $t_i > 0$.
4. **Reconstruction:** every throat area is recovered as $t_i = \tfrac12 I\bigl(\{(i,0)\}:\{(i,1)\}\bigr)$.

*Proof sketch.* (1) and (4) are Theorem 5.3. For (3), every positive-weight step preserves the first coordinate, so by induction so does every bridge; within a pair, a bridge exists exactly when the throat has positive area. (2) then follows from Theorem 6.3, or directly from Theorem 6.2 with $U$ the $i$-th pair. $\square$

So $n$ independent Bell pairs of concurrences $C_i$ produce exactly $n$ disjoint wormholes of areas $C_i$: entanglement between partners, none across pairs, and no bridge across pairs. The dictionary is complete and quantitative in both directions.

---

## 7. Obstructions: entanglement with no geometry

### 7.1 The GHZ pattern has no bulk dual

**Theorem 7.1.** There is no holographic model, of any size and with any arrangement of hidden cells, admitting three pairwise disjoint boundary regions $A,B,C$ with
$$S(A) = S(B) = S(C) = S(AB) = S(BC) = S(AC) = S(ABC) = 1.$$

*Proof.* Monogamy (Theorem 3.10) would require $1+1+1+1 \le 1+1+1$. $\square$

These are precisely the marginal entropies of three of the four parties of the GHZ state $(|0000\rangle + |1111\rangle)/\sqrt2$. Hence that state has no geometric dual.

**Proposition 7.2 (The obstruction is not visible to the general quantum inequalities).** Define $S_{\mathrm{GHZ}}(X) = 0$ if $X = \emptyset$ and $1$ otherwise, on subsets of a three-element set. Then $S_{\mathrm{GHZ}}$ satisfies subadditivity, $S(X \cup Y) \le S(X) + S(Y)$, and strong subadditivity in submodular form, $S(X\cup Y) + S(X \cap Y) \le S(X) + S(Y)$, for all $X, Y$; but it violates monogamy.

*Proof.* Finite check over all pairs of subsets; the monogamy violation is $4 \le 3$. $\square$

So the geometric constraint is strictly stronger than the constraints valid for all quantum states, and Theorem 7.1 is not vacuous.

### 7.2 A five-party entropy vector that no geometry realises

The natural next question is whether monogamy is the *only* extra geometric constraint. It is not, and the following is our main new result.

Encode subsets of $\{0,1,2,3,4\}$ as bitmasks $0 \le m < 32$, bit $i$ marking party $i$; union is bitwise OR and disjointness is bitwise AND equal to $0$.

**Definition 7.3 (The witness vector).** Let $S_w : \{0,\dots,31\} \to \mathbb{Z}_{\ge 0}$ be given by

| $m$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|---|---|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|
| $S_w(m)$ | 0 | 3 | 2 | 5 | 4 | 5 | 6 | 5 | 2 | 5 | 4 | 7 | 6 | 6 | 7 | 5 |

| $m$ | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | 29 | 30 | 31 |
|---|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| $S_w(m)$ | 3 | 6 | 5 | 7 | 5 | 4 | 6 | 4 | 4 | 5 | 6 | 6 | 4 | 3 | 5 | 2 |

In particular $S_w(\emptyset) = 0$ and $S_w(\text{all five parties}) = 2$. The vector was found by local search over integer vectors constrained by the four families below.

**Theorem 7.4 (The witness is classically consistent).** For all bitmasks $X,Y,Z < 32$:

1. **Subadditivity.** If $X \wedge Y = 0$ then $S_w(X \vee Y) \le S_w(X) + S_w(Y)$.
2. **Strong subadditivity.** If $X,Y,Z$ are pairwise disjoint then $S_w(X\vee Y\vee Z) + S_w(Y) \le S_w(X\vee Y) + S_w(Y \vee Z)$.
3. **Weak monotonicity.** If $X,Y,Z$ are pairwise disjoint then $S_w(X) + S_w(Z) \le S_w(X\vee Y) + S_w(Y\vee Z)$.
4. **Monogamy.** If $X,Y,Z$ are pairwise disjoint then
$$S_w(X\vee Y\vee Z) + S_w(X) + S_w(Y) + S_w(Z) \le S_w(X\vee Y) + S_w(Y\vee Z) + S_w(X\vee Z).$$

*Proof.* Exhaustive evaluation: $32^2$ instances for (1) and $32^3 = 32768$ instances for each of (2)–(4), one arithmetic comparison per instance. Every instance holds. $\square$

Note that these families are imposed on **all** disjoint bitmask arguments, not merely on singleton parties: $S_w$ behaves like a legitimate entropy vector at the full strength of the four constraint families.

**Theorem 7.5 (The witness violates the cyclic inequality).** With parties $0,\dots,4$ in cyclic order, the consecutive pairs are the masks $3, 6, 12, 24, 17$ and the consecutive triples are $7, 14, 28, 25, 19$. Then
$$\underbrace{S_w(3)+S_w(6)+S_w(12)+S_w(24)+S_w(17)+S_w(31)}_{5+6+6+4+6+2 \,=\, 29} \;>\; \underbrace{S_w(7)+S_w(14)+S_w(28)+S_w(25)+S_w(19)}_{5+7+4+5+7\,=\,28}.$$
The cyclic inequality of Theorem 4.4 fails by exactly $1$.

**Corollary 7.6 (Independence).** The five-party cyclic inequality is not a consequence of subadditivity, strong subadditivity, weak monotonicity and monogamy of mutual information: there is a five-party entropy vector satisfying all four families on all disjoint arguments and violating the cyclic inequality.

*Proof.* $S_w$, by Theorems 7.4 and 7.5. Since the four families hold for $S_w$ and the cyclic inequality does not, no derivation of the latter from the former can exist. $\square$

**Theorem 7.7 (No bulk geometry realises the witness).** There is no holographic model $M$, of any size and with any arrangement of hidden cells, and no five pairwise disjoint boundary regions $A_0,\dots,A_4$, such that for every sub-family $T \subseteq \{0,\dots,4\}$,
$$S_M\Bigl(\bigcup_{i\in T} A_i\Bigr) = S_w\bigl(\text{mask}(T)\bigr).$$

*Proof.* Suppose such a model and regions existed. The ten unions appearing in Theorem 4.4 — the five consecutive pairs, the five consecutive triples, and the full union — are all of the stated form, so their entropies would be the corresponding values of $S_w$. Substituting into Theorem 4.4 yields $29 \le 28$, a contradiction. $\square$

**Discussion.** Theorem 7.7 is stronger than it may first appear. The vector $S_w$ is not exotic: it satisfies *every instance* of the four best-known entropy constraint families, at full disjoint-argument strength — $32768$ instances per family, all verified. A search for a geometric dual guided by those constraints would find nothing wrong with it. Yet no graph, no assignment of wall areas, and no number of hidden cells can produce it. The obstruction is detected by exactly one thing: the cyclic inequality.

Together with §7.1 this gives a strict chain of cones over five parties:
$$\{\text{geometric entropy vectors}\} \;\subsetneq\; \{\text{vectors obeying SA, SSA, WM, MMI}\} \;\subsetneq\; \{\text{vectors obeying SA, SSA, WM}\},$$
the first inclusion strict by $S_w$ and the second by the GHZ pattern.

---

## 8. Algorithms

The development is constructive and every object above is computable. We record the three procedures that matter.

**Algorithm 8.1 (Min-cut entropy by hidden-cell enumeration).** Given a weight matrix on $n$ cells with $h$ hidden cells and a boundary region $A$: for each of the $2^{h}$ assignments of the hidden cells, form the corresponding region, compute its area in $O(n^2)$, and take the minimum. Cost $O(2^{h} n^2)$. For $h = 0$ this is a single area evaluation. (For large instances one would instead call a max-flow routine, since the minimisation is a genuine minimum cut with terminals fixed by the boundary; the enumeration is used here because $h$ is small and the code is transparent.)

**Algorithm 8.2 (Contraction certification).** Given a Boolean map $\chi : \{0,1\}^k \to \{0,1\}^m$, iterate over all $4^k$ pairs of inputs and compare Hamming distances. Cost $O(4^{k}(k+m))$: $16$ comparisons for intersection–union, $64$ for the minority rule, $1024$ for the cyclic rule. A positive answer is a complete proof of the corresponding entropy inequality, by Theorem 3.3.

**Algorithm 8.3 (Entropy-vector validation).** Given $S : \{0,\dots,2^p-1\} \to \mathbb{Z}$, check subadditivity over all disjoint pairs of masks and strong subadditivity, weak monotonicity and monogamy over all pairwise disjoint triples; then evaluate any candidate inequality of interest. Cost $O(8^{p})$; for $p=5$ this is $32768$ instances per triple-family, run in milliseconds. Applying it to $S_w$ certifies Theorems 7.4 and 7.5, hence Corollary 7.6 and Theorem 7.7.

---

## 9. Applications and interpretation

**Which correlation patterns can be geometry?** The results assemble into a map of the boundary between the quantum and the geometric. Monogamy (Theorem 3.10) is the first wall: GHZ-type democratic tripartite correlation is geometrically impossible. The cyclic inequality (Theorem 4.4) is a second, independent wall (Corollary 7.6), with $S_w$ sitting behind the first and in front of the second. If spacetime is emergent, then the states of the underlying quantum system that give rise to a geometry form a strictly and intricately constrained subclass.

**How much of geometry is recoverable?** Exactly the off-diagonal weights, and exactly from two-point mutual informations (Theorems 5.3, 5.5, 5.6) — provided there are no hidden cells. With even one hidden cell, distinct geometries become indistinguishable (Theorem 5.7). This is a sharp, finite model of the bulk-reconstruction problem: the boundary data determines the geometry up to a well-understood gauge, and beyond that, up to the redundancy introduced by hidden bulk degrees of freedom.

**What is a wormhole made of?** In this model, precisely of correlation: disconnection forces exact additivity (Theorem 6.2), correlation forces a bridge (Theorem 6.3), and in the hidden-cell-free case the bridge graph and the entanglement graph are the same graph (Theorem 6.4). For a two-qubit state the throat area is the concurrence, the mutual information is twice it, and the linear entropy is its square (Theorems 6.9, 6.10). This is ER = EPR as a theorem rather than a slogan, in a setting small enough to be fully controlled.

**Robustness.** Theorem 5.9 shows the geometry-to-entropy map is $1$-Lipschitz for the total-area distance, so the correspondence survives perturbation of the geometry — the dictionary is stable, not accidental.

---

## 10. Discussion and future work

Several directions follow naturally.

**Completeness of the contraction calculus.** Every inequality proved here came from a Hamming-nonexpansive Boolean map. *Conjecture:* a linear inequality $\sum_j c_j S(B_j) \le \sum_i d_i S(A_i)$ with nonnegative integer coefficients holds for the min-cut entropies of every finite bulk geometry if and only if it is witnessed by a contraction map (after replacing each region by $d_i$, respectively $c_j$, parallel copies). The intuition is that min-cut entropy is a minimum of linear functionals of Boolean patterns, so a valid inequality must survive the worst-case pattern, and that test is exactly Hamming contraction. The search space over $k \le 5$ inputs is small enough to be settled exhaustively before a general proof is attempted.

**Reconstruction beyond the hidden-cell-free case.** Call a model *bulk-minimal* if no hidden cell can be deleted or merged into a boundary cell without changing some entropy. *Conjecture:* two bulk-minimal models with identical boundary entropy functions are isomorphic as weighted graphs, so that Theorem 5.3 extends from hidden-cell-free to bulk-minimal models. The star/triangle pair of Theorem 5.7 would then not be a genuine counterexample but a redundancy: the star's hidden cell is free, and quotienting it produces the triangle. The concrete first test is to prove that the star is not bulk-minimal and that all four- and five-cell counterexamples arise the same way.

**Is the cyclic inequality a facet?** We have shown it is not implied by the four classical families. The next question is whether it is a *facet* of the five-party geometric entropy cone — an extreme, non-redundant constraint — and whether the family of contraction maps on five inputs generates all of that cone's facets. More broadly: how many independent walls are there at each number of parties?

**Beyond graphs.** The min-cut model discretises a spatial slice. Extending the contraction calculus to weighted hypergraphs, to time-dependent (covariant) settings, and to the quantum error-correcting-code models of holography would test how much of the picture is an artifact of the graph approximation and how much is structural.

---

## 11. Summary of results

* **Contraction principle** (Theorem 3.3). A Hamming-nonexpansive Boolean recombination rule, plus boundary-trace compatibility, yields an entropy inequality. All the inequalities below are instances.
* **Subadditivity, strong subadditivity, complementarity, purity** (Theorems 2.8, 3.5, 3.7).
* **Monogamy of mutual information** (Theorem 3.10), from the minority/union rule; the naive pairwise-intersection rule provably fails (Remark 3.9).
* **Five-party cyclic inequality** (Theorem 4.4), from the rule $c_4 \wedge \lnot c_2 \wedge (c_0 \vee (c_1 \wedge \lnot c_3))$ in five rotations plus the union.
* **Reconstruction** (Theorem 5.3): $w(u,v) = I(u:v)/2$ with no hidden cells; **rigidity and connectivity** (Theorem 5.5); **gauge sharpness** (Theorem 5.6); **failure with one hidden cell** (Theorem 5.7); **stability** (Theorem 5.9).
* **ER = EPR**: disconnection $\Rightarrow$ additivity (Theorem 6.2); correlation $\Rightarrow$ bridge (Theorem 6.3); the bridge network equals the entanglement network (Theorem 6.4); throat area $=$ concurrence and bridge $\iff$ entangled (Theorem 6.9); linear entropy $=$ concurrence squared (Theorem 6.10); the $n$-Bell-pair matching geometry (Theorem 6.12).
* **Obstructions**: GHZ has no geometric dual (Theorem 7.1) though it satisfies the general quantum inequalities (Proposition 7.2); and the witness vector $S_w$ satisfies subadditivity, strong subadditivity, weak monotonicity and monogamy on all disjoint arguments yet violates the cyclic inequality by one (Theorems 7.4, 7.5), proving the cyclic inequality independent (Corollary 7.6) and exhibiting an entropy vector realised by no bulk geometry at all (Theorem 7.7).
