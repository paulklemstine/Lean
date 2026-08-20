# The Molien Invariant Is the Cyclic Shadow of the Burnside Mark Vector

**Author:** Aristotle
**Date:** 2026-08-20

## Abstract

For a finite group $G$ acting on a finite set $X$ there are two classical subgroup-indexed invariants: the *Burnside mark vector* $H \mapsto |X^H|$, recording the number of points fixed by all of $H$, and the *Molien invariant* $H \mapsto \frac{1}{|H|}\sum_{h\in H}|X^h|$, the subgroup-wise average of the permutation character. Conjecture D10 asserts that these two invariants agree up to a scalar. We settle the conjecture completely.

On the positive side we prove the **Averaging Theorem**: the Molien invariant at $H$ equals the average over $h \in H$ of the marks at the cyclic subgroups $\langle h\rangle$; consequently the mark vector always determines the Molien invariant, by a linear map independent of $X$. As a sharp converse we prove the **Cyclic Recovery Theorem**: if two finite $G$-sets have equal permutation characters, their marks agree at every cyclic subgroup; hence over a group all of whose subgroups are cyclic the Molien data determines the whole mark vector with scaling factor exactly $1$.

On the negative side we exhibit, for the Klein four group $V = (\mathbb{Z}/2)^2$, two six-element $V$-sets with identical Molien invariants at every subgroup whose mark vectors are not proportional, refuting Conjecture D10; and we generalise this to an infinite family, one for each prime $p$, over $E = (\mathbb{Z}/p)^2$, comparing $\bigsqcup_{\ell \in \mathbb{P}^1(\mathbb{F}_p)} E/\ell$ with $E \sqcup (p \text{ fixed points})$. The obstruction is located exactly: the averaging only samples cyclic subgroups, so a rank-two elementary abelian subgroup is precisely what breaks the conjecture.

We also record the structural comparison $|X^H| \le \operatorname{Mol}_X(H)$ with its equality case ($H$ acts trivially), the Burnside orbit-counting identity in this normalisation, and the resulting divisibility $|H| \mid \sum_{h\in H}|X^h|$. Applying the last of these to colouring representations yields, via the cycle-index identity $|X^g| = k^{c(g)}$, the necklace congruence $n \mid \sum_{a \in \mathbb{Z}/n} k^{\gcd(n,a)}$ and, at a prime, Fermat's little theorem $k^p \equiv k \pmod p$. Thus the coarser of the two invariants nevertheless carries genuine arithmetic content.

**Keywords:** Burnside table of marks, Molien invariant, permutation character, orbit counting, elementary abelian group, necklace congruence, Fermat's little theorem.

---

## 1. Introduction

Let $G$ be a finite group. The category of finite $G$-sets is controlled by two classical, closely related linear invariants.

The first is the **table of marks**, introduced by Burnside. It records, for each finite $G$-set $X$ and each subgroup $H \le G$, the cardinality $|X^H|$ of the set of points fixed by every element of $H$. Two finite $G$-sets are isomorphic if and only if they have equal mark vectors; the mark vector is therefore a complete invariant, and it provides a coordinate system on the Burnside ring $A(G)$.

The second is the **permutation character** $g \mapsto |X^g|$, or equivalently its subgroup-wise averages. For a subgroup $H$ define
$$\operatorname{Mol}_X(H) \;=\; \frac{1}{|H|}\sum_{h \in H} |X^{h}| .$$
This is the constant-term data of the Molien series of the permutation representation restricted to $H$, and — by Burnside's orbit-counting lemma — the number of $H$-orbits of $X$. We call $H \mapsto \operatorname{Mol}_X(H)$ the **Molien invariant** of $X$.

**Conjecture D10.** *The Molien invariant is exactly the Burnside mark vector modulo scaling*: if two finite $G$-sets $X$, $Y$ satisfy $\operatorname{Mol}_X(H) = \operatorname{Mol}_Y(H)$ for all $H \le G$, then there is a constant $c \in \mathbb{Q}$ with $|X^H| = c\,|Y^H|$ for all $H \le G$.

The purpose of this paper is to settle Conjecture D10 in both directions and to identify the exact structural boundary of its validity. The results are summarised as follows.

1. **Marks determine Molien, always** (Theorem 4.1, the Averaging Theorem): $\operatorname{Mol}_X(H) = \frac{1}{|H|}\sum_{h\in H} |X^{\langle h\rangle}|$. The Molien invariant is a fixed linear image of the mark vector, sampling only *cyclic* subgroups.
2. **Molien determines marks when all subgroups are cyclic** (Theorem 5.2, the Cyclic Recovery Theorem), and then with scaling factor $1$.
3. **Conjecture D10 is false** (Theorem 6.5), by a six-point counterexample over the Klein four group, and false for every prime (Theorem 7.6), by a $(p^2+p)$-point counterexample over $(\mathbb{Z}/p)^2$.
4. The structural inequality $|X^H| \le \operatorname{Mol}_X(H)$ holds with equality iff $H$ acts trivially (Theorems 3.3 and 3.5).
5. The arithmetic corollary $|H| \mid \sum_{h\in H}|X^h|$ (Corollary 3.8), applied to colouring actions, yields the necklace congruences and Fermat's little theorem (Section 8).

The moral is contained in item 1: *averaging over a subgroup can only see the cyclic subgroups it contains*. Item 2 says that when there is nothing else to see, nothing is lost; items 3 say that as soon as there is something else — a rank-two elementary abelian subgroup, the minimal non-cyclic obstruction — the loss is total enough to defeat even the weak "up to scaling" formulation.

## 2. Definitions

Throughout, $G$ is a group, $X$ and $Y$ are finite $G$-sets (finite sets with a $G$-action), and $H \le G$ denotes a finite subgroup.

**Definition 2.1 (Fixed-point count / permutation character).** For $g \in G$,
$$\operatorname{fix}_X(g) \;=\; \bigl|\{x \in X : g\cdot x = x\}\bigr| .$$
The function $g \mapsto \operatorname{fix}_X(g)$ is the *permutation character* of $X$: it is the trace of the permutation matrix of $g$.

**Definition 2.2 (Burnside mark).** For a finite subgroup $H \le G$,
$$\operatorname{mark}_X(H) \;=\; \bigl|X^H\bigr| \;=\; \bigl|\{x \in X : h\cdot x = x \text{ for all } h \in H\}\bigr| .$$
The family $(\operatorname{mark}_X(H))_{H \le G}$ is the *mark vector* of $X$.

**Definition 2.3 (Molien invariant).** For a finite subgroup $H \le G$,
$$\operatorname{Mol}_X(H) \;=\; \frac{1}{|H|}\sum_{h\in H} \operatorname{fix}_X(h) \;\in\; \mathbb{Q}.$$

**Definition 2.4 (Proportionality).** Two mark vectors are *proportional* if there is a single $c \in \mathbb{Q}$ with $\operatorname{mark}_X(H) = c\cdot\operatorname{mark}_Y(H)$ for all subgroups $H$. Conjecture D10 asserts that equality of Molien invariants implies proportionality of mark vectors.

Two normalisation remarks. First, the mark at the trivial subgroup is $\operatorname{mark}_X(\{1\}) = |X|$, and likewise $\operatorname{Mol}_X(\{1\}) = |X|$; both invariants recover the cardinality. Second, $\operatorname{fix}_X(1) = |X|$. These trivial-subgroup values will do real work in the refutations: they pin the hypothetical scalar $c$ to be $1$.

## 3. Basic structure: comparison, equality case, orbit counting

**Lemma 3.1.** $\operatorname{fix}_X(1) = |X|$ and $\operatorname{fix}_X(g) \le |X|$ for all $g$. Moreover $\operatorname{mark}_X(\{1\}) = |X|$ and $\operatorname{Mol}_X(\{1\}) = |X|$.

*Proof.* Immediate from the definitions: the identity fixes all points, all counts are counts of subsets of $X$, and the trivial subgroup imposes no condition. $\square$

**Lemma 3.2 (Marks bound individual fixed-point counts).** For every $h \in H$, $\operatorname{mark}_X(H) \le \operatorname{fix}_X(h)$.

*Proof.* A point fixed by all of $H$ is in particular fixed by $h$, so $X^H \subseteq X^h$. $\square$

**Theorem 3.3 (Structural comparison).** For every finite subgroup $H \le G$,
$$\operatorname{mark}_X(H) \;\le\; \operatorname{Mol}_X(H).$$

*Proof sketch.* By Lemma 3.2, $\sum_{h\in H}\operatorname{fix}_X(h) \ge \sum_{h\in H}\operatorname{mark}_X(H) = |H|\cdot\operatorname{mark}_X(H)$; divide by $|H| > 0$. $\square$

**Lemma 3.4 (Full-mark criterion).** $\operatorname{mark}_X(H) = |X|$ if and only if $h\cdot x = x$ for all $h \in H$ and all $x \in X$, i.e. $H$ acts trivially on $X$.

*Proof sketch.* The mark is the cardinality of the subset $X^H \subseteq X$; it equals $|X|$ iff $X^H = X$, which is the stated condition. $\square$

**Theorem 3.5 (Equality case).** $\operatorname{Mol}_X(H) = \operatorname{mark}_X(H)$ if and only if $H$ acts trivially on $X$.

*Proof sketch.* ($\Rightarrow$) Equality means $\sum_{h\in H}\operatorname{fix}_X(h) = |H|\cdot \operatorname{mark}_X(H) = \sum_{h\in H}\operatorname{mark}_X(H)$, a sum-wise equality between two families of naturals with the term-wise inequality of Lemma 3.2. Hence each term agrees: $\operatorname{fix}_X(h) = \operatorname{mark}_X(H)$ for all $h \in H$. Take $h = 1$: by Lemma 3.1, $\operatorname{mark}_X(H) = |X|$, and Lemma 3.4 finishes. ($\Leftarrow$) If $H$ acts trivially then $\operatorname{fix}_X(h) = |X|$ for all $h \in H$, so the average is $|X|$, which is also the mark by Lemma 3.4. $\square$

**Theorem 3.6 (Burnside's lemma, Molien normalisation).** For every finite subgroup $H\le G$,
$$\sum_{h\in H}\operatorname{fix}_X(h) \;=\; |X/H|\cdot |H|, \qquad\text{equivalently}\qquad \operatorname{Mol}_X(H) \;=\; |X/H| ,$$
where $|X/H|$ denotes the number of $H$-orbits of $X$.

*Proof sketch.* Count the set of incident pairs $\{(h,x) \in H\times X : h\cdot x = x\}$ in two ways: summing over $h$ gives $\sum_h \operatorname{fix}_X(h)$; summing over $x$ gives $\sum_x |\operatorname{Stab}_H(x)| = \sum_x |H|/|H\cdot x|$, which, grouped by orbit, contributes $|H|$ per orbit. $\square$

**Corollary 3.7 (Integrality).** $\operatorname{Mol}_X(H)$ is a nonnegative integer.

**Corollary 3.8 (Arithmetic divisibility).** $|H| \;\bigm|\; \sum_{h\in H}\operatorname{fix}_X(h)$. In particular, for a finite group $G$ acting on a finite set $X$, $|G| \mid \sum_{g\in G}\operatorname{fix}_X(g)$.

Corollary 3.8 is the engine of Section 8.

## 4. The positive half of D10: marks determine Molien

The key observation is elementary but decisive.

**Lemma 4.0 (Powers preserve fixed points).** If $g\cdot x = x$ then $g^{n}\cdot x = x$ for every $n \in \mathbb{Z}$.

*Proof sketch.* Induction on $n \ge 0$ using $g^{n+1}\cdot x = g\cdot(g^n\cdot x)$; for negative exponents, apply $g^{-1}$ to the identity $g\cdot x = x$. $\square$

**Lemma 4.1 (Element = cyclic subgroup).** For every $g \in G$ (with $\langle g\rangle$ finite),
$$\operatorname{fix}_X(g) \;=\; \operatorname{mark}_X(\langle g\rangle).$$

*Proof sketch.* $X^{\langle g \rangle} \subseteq X^g$ trivially since $g \in \langle g\rangle$; conversely if $x \in X^g$ then by Lemma 4.0 every element $g^n$ of $\langle g\rangle$ fixes $x$. $\square$

**Theorem 4.2 (Averaging Theorem; positive half of D10).** For every finite subgroup $H \le G$,
$$\operatorname{Mol}_X(H) \;=\; \frac{1}{|H|}\sum_{h\in H} \operatorname{mark}_X\bigl(\langle h\rangle\bigr).$$

*Proof.* Substitute Lemma 4.1 termwise into Definition 2.3. $\square$

Three consequences deserve emphasis.

- **Marks $\Rightarrow$ Molien.** The Molien invariant of $X$ is obtained from the mark vector of $X$ by a fixed $\mathbb{Q}$-linear map, depending only on $G$ and not on $X$. Thus equal mark vectors force equal Molien invariants — the trivial direction of D10 holds in the strongest possible form (equality, not merely proportionality).
- **Only cyclic subgroups are sampled.** The right-hand side involves $\operatorname{mark}_X(K)$ only for cyclic $K \le H$. All non-cyclic subgroups are structurally invisible to the Molien invariant.
- **Molien $\equiv$ character.** Since $\operatorname{Mol}_X$ is determined by the permutation character and conversely (evaluating at the cyclic subgroups $\langle g\rangle$ and applying Möbius inversion on the cyclic poset, or simply noting $\operatorname{Mol}_X(\langle g\rangle)$ determines $\operatorname{fix}_X$ inductively), the Molien invariant carries exactly the information of the character. In particular:

**Proposition 4.3.** If $\operatorname{fix}_X(g) = \operatorname{fix}_Y(g)$ for all $g \in G$, then $\operatorname{Mol}_X(H) = \operatorname{Mol}_Y(H)$ for every finite subgroup $H$.

*Proof.* The Molien invariant is defined by a formula in the character values alone. $\square$

## 5. The sharp positive result: cyclic subgroups

**Proposition 5.1 (Marks are isomorphism invariants).** If $e : X \to Y$ is a bijection with $e(g\cdot x) = g\cdot e(x)$ for all $g,x$, then $\operatorname{mark}_X(H) = \operatorname{mark}_Y(H)$ for every $H$.

*Proof sketch.* $e$ restricts to a bijection $X^H \to Y^H$: if $x$ is $H$-fixed then $h\cdot e(x) = e(h\cdot x) = e(x)$, and the inverse map is handled symmetrically using injectivity of $e$. $\square$

**Theorem 5.2 (Cyclic Recovery Theorem).** Suppose $\operatorname{fix}_X(g) = \operatorname{fix}_Y(g)$ for all $g \in G$. Then for every **cyclic** finite subgroup $H \le G$,
$$\operatorname{mark}_X(H) = \operatorname{mark}_Y(H).$$

*Proof.* Write $H = \langle g\rangle$. By Lemma 4.1, $\operatorname{mark}_X(H) = \operatorname{fix}_X(g) = \operatorname{fix}_Y(g) = \operatorname{mark}_Y(H)$. $\square$

**Corollary 5.3 (D10 holds, with scaling factor 1, over locally cyclic groups).** If every subgroup of $G$ is cyclic — for instance if $G$ is cyclic — then equal permutation characters (equivalently, equal Molien invariants at every subgroup) imply equal mark vectors: $\operatorname{mark}_X(H) = \operatorname{mark}_Y(H)$ for all $H \le G$. In particular the two $G$-sets are isomorphic.

Thus over cyclic groups the conjecture holds in a form strictly stronger than conjectured: the scalar is forced to be $1$, and the invariants are equivalent, not merely proportional.

## 6. The refutation: the Klein four group

Let $V = \mathbb{Z}/2 \times \mathbb{Z}/2$, the Klein four group, written multiplicatively. Its subgroup lattice consists of $\{1\}$, three subgroups of order $2$ (all cyclic), and $V$ itself. The unique non-cyclic subgroup is $V$.

The three surjections $V \to \mathbb{Z}/2$ are
$$\chi_0(a,b) = a,\qquad \chi_1(a,b) = b,\qquad \chi_2(a,b) = a+b,$$
with distinct kernels $A_0, A_1, A_2$, the three subgroups of index two.

**Definition 6.1 (The two $V$-sets).**

- $X_{\mathrm{three}} \;=\; V/A_0 \sqcup V/A_1 \sqcup V/A_2$. Concretely, $X_{\mathrm{three}} = \mathbb{Z}/2 \times \{0,1,2\}$ with $g\cdot(t,i) = (t + \chi_i(g),\, i)$: three two-element sets ("dominoes"), the $i$-th one acted on through $\chi_i$.
- $X_{\mathrm{reg}} \;=\; V \sqcup \{\bullet_0,\bullet_1\}$, the regular $V$-set (translation) together with two fixed points.

Both have $6$ elements.

**Lemma 6.2 (Equal characters).** $\operatorname{fix}_{X_{\mathrm{three}}}(g) = \operatorname{fix}_{X_{\mathrm{reg}}}(g)$ for all $g \in V$; both characters are $(6,2,2,2)$ (value $6$ at the identity, value $2$ at each of the three involutions).

*Proof sketch.* At $g = 1$ both counts are $6$. For $g \ne 1$: on $X_{\mathrm{three}}$, $g$ fixes both points of the $i$-th domino iff $\chi_i(g) = 0$ and no point of it otherwise; each nonzero $g \in V$ lies in exactly one of $A_0, A_1, A_2$ (the three kernels intersect pairwise trivially and cover $V$: the nonzero elements $(1,0), (0,1), (1,1)$ lie in $A_1$, $A_0$, $A_2$ respectively). So $\operatorname{fix}(g) = 2$. On $X_{\mathrm{reg}}$, translation by $g \ne 0$ is fixed-point free on the regular part and fixes both added points, so $\operatorname{fix}(g) = 2$. (Concretely: this is a finite check over the four elements of $V$.) $\square$

**Corollary 6.3 (Equal Molien invariants).** $\operatorname{Mol}_{X_{\mathrm{three}}}(H) = \operatorname{Mol}_{X_{\mathrm{reg}}}(H)$ for every subgroup $H \le V$.

*Proof.* Proposition 4.3 applied to Lemma 6.2. $\square$

**Lemma 6.4 (Marks at the extremes).**
$$\operatorname{mark}_{X_{\mathrm{three}}}(V) = 0,\quad \operatorname{mark}_{X_{\mathrm{reg}}}(V) = 2,\quad \operatorname{mark}_{X_{\mathrm{three}}}(\{1\}) = \operatorname{mark}_{X_{\mathrm{reg}}}(\{1\}) = 6 .$$

*Proof sketch.* A point $(t,i)$ of $X_{\mathrm{three}}$ is $V$-fixed only if $\chi_i(g) = 0$ for all $g$, which fails since $\chi_i$ is surjective. In $X_{\mathrm{reg}}$ the two added points are $V$-fixed and no point of the regular part is (translation is free). The trivial-subgroup marks are the cardinalities. $\square$

**Theorem 6.5 (Conjecture D10 is false).** The $V$-sets $X_{\mathrm{three}}$ and $X_{\mathrm{reg}}$ satisfy
$$\operatorname{Mol}_{X_{\mathrm{three}}}(H) = \operatorname{Mol}_{X_{\mathrm{reg}}}(H)\quad\text{for every } H \le V,$$
yet there is **no** $c \in \mathbb{Q}$ with $\operatorname{mark}_{X_{\mathrm{three}}}(H) = c \cdot \operatorname{mark}_{X_{\mathrm{reg}}}(H)$ for all $H \le V$.

*Proof.* Equality of Molien invariants is Corollary 6.3. Suppose such a $c$ existed. At $H = \{1\}$, Lemma 6.4 gives $6 = 6c$, so $c = 1$. At $H = V$ it gives $0 = 1\cdot 2$, a contradiction. $\square$

**Corollary 6.6 (Strict refinement).** $X_{\mathrm{three}}$ and $X_{\mathrm{reg}}$ are not isomorphic as $V$-sets, although their permutation characters — and hence their Molien invariants — coincide. Consequently the Burnside mark vector is a strictly finer invariant of finite $G$-sets than the Molien invariant.

*Proof.* An equivariant bijection would force equal marks at $V$ by Proposition 5.1, contradicting Lemma 6.4. $\square$

**Proposition 6.7 (The failure is exactly at the non-cyclic subgroup).** $V$ is not cyclic, and $\operatorname{mark}_{X_{\mathrm{three}}}(H) = \operatorname{mark}_{X_{\mathrm{reg}}}(H)$ for every cyclic $H \le V$; hence the two mark vectors differ *only* at $H = V$.

*Proof.* Non-cyclicity: every element of $V$ squares to the identity, so every cyclic subgroup has order at most $2 < 4 = |V|$. Agreement on cyclic subgroups is Theorem 5.2 applied to Lemma 6.2. $\square$

Proposition 6.7 shows that the hypothesis in Corollary 5.3 is not an artefact of the proof: it is precisely the boundary of the conjecture's validity.

## 7. An infinite family: elementary abelian groups of rank two

The Klein four group is the case $p = 2$ of a uniform family.

Fix a prime $p$ and let $E = (\mathbb{Z}/p)^2$, viewed as a two-dimensional $\mathbb{F}_p$-vector space. Its subgroups of index $p$ are the $p+1$ lines through the origin, equivalently the kernels of the $p+1$ pairwise non-proportional linear functionals. We index them by the projective line $\mathbb{P}^1(\mathbb{F}_p) = \mathbb{F}_p \cup \{\infty\}$, defining for $i \in \mathbb{F}_p \cup \{\infty\}$
$$\chi_i(v_1,v_2) = \begin{cases} v_1 + i\,v_2, & i \in \mathbb{F}_p,\\ v_2, & i = \infty.\end{cases}$$
Each $\chi_i$ is additive (Lemma 7.1) and each vanishes on a distinct line.

**Lemma 7.1 (Additivity).** $\chi_i(u+v) = \chi_i(u) + \chi_i(v)$ and $\chi_i(0) = 0$.

**Lemma 7.2 (A nonzero vector lies on exactly one line).** For $v \ne 0$ in $\mathbb{F}_p^2$,
$$\#\{ i \in \mathbb{P}^1(\mathbb{F}_p) : \chi_i(v) = 0\} \;=\; 1 .$$

*Proof.* If $v_2 = 0$ then $v_1 \ne 0$, and $\chi_\infty(v) = 0$ while $\chi_c(v) = v_1 \ne 0$ for $c \in \mathbb{F}_p$: exactly one index. If $v_2 \ne 0$ then $\chi_\infty(v) = v_2 \ne 0$, and $\chi_c(v) = v_1 + c v_2 = 0$ holds precisely for the unique $c = -v_1/v_2$, the division being legitimate in the field $\mathbb{F}_p$. $\square$

**Definition 7.3 (The two $E$-sets).**

- $X_{\mathrm{lines}}(p) \;=\; \bigsqcup_{i \in \mathbb{P}^1(\mathbb{F}_p)} E/\ker\chi_i$. Concretely $\mathbb{F}_p \times \mathbb{P}^1(\mathbb{F}_p)$ with $g\cdot(t,i) = (t + \chi_i(g),\, i)$: $p+1$ transitive $E$-sets of size $p$.
- $X_{\mathrm{reg}}(p) \;=\; E \sqcup (\text{$p$ fixed points})$: the regular $E$-set together with $p$ points on which $E$ acts trivially.

Both have $p(p+1) = p^2 + p$ elements.

**Lemma 7.4 (Character of $X_{\mathrm{lines}}(p)$).**
$$\operatorname{fix}_{X_{\mathrm{lines}}(p)}(g) = \begin{cases} p^2+p, & g = 0,\\ p, & g \ne 0.\end{cases}$$

*Proof sketch.* Translation by $\chi_i(g)$ on the $i$-th copy fixes all $p$ of its points if $\chi_i(g) = 0$ and none otherwise. Hence $\operatorname{fix}(g) = p\cdot\#\{i : \chi_i(g) = 0\}$, which is $p(p+1)$ for $g = 0$ and, by Lemma 7.2, $p\cdot 1 = p$ for $g \ne 0$. $\square$

**Lemma 7.5 (Character of $X_{\mathrm{reg}}(p)$).** The same values: $p^2+p$ at $g = 0$, and $p$ for $g \ne 0$ (translation acts freely on the regular part; the $p$ added points are always fixed).

**Theorem 7.6 (D10 fails for every elementary abelian group of rank two).** For every prime $p$, the $E$-sets $X_{\mathrm{lines}}(p)$ and $X_{\mathrm{reg}}(p)$ have equal permutation characters, hence
$$\operatorname{Mol}_{X_{\mathrm{lines}}(p)}(H) = \operatorname{Mol}_{X_{\mathrm{reg}}(p)}(H) \quad\text{for every } H \le E,$$
but no $c \in \mathbb{Q}$ satisfies $\operatorname{mark}_{X_{\mathrm{lines}}(p)}(H) = c\cdot \operatorname{mark}_{X_{\mathrm{reg}}(p)}(H)$ for all $H \le E$.

*Proof.* Equality of characters is Lemmas 7.4 and 7.5; equality of Molien invariants then follows from Proposition 4.3. For the marks: at $H = \{1\}$ both marks equal the common cardinality $p^2+p > 0$, forcing $c = 1$. At $H = E$: no point of $X_{\mathrm{lines}}(p)$ is fixed by all of $E$, since a point $(t,i)$ would require $\chi_i \equiv 0$, contradicting surjectivity of $\chi_i$; so the mark is $0$. In $X_{\mathrm{reg}}(p)$ the $p$ added points are $E$-fixed and the regular part has no fixed point, so the mark is $p$. With $c = 1$ we would need $0 = p$, contradicting $p \ge 2$. $\square$

**Remark 7.7 (The relation in the Burnside ring).** Theorem 7.6 exhibits, for each prime $p$, the relation
$$\bigsqcup_{\ell \in \mathbb{P}^1(\mathbb{F}_p)} E/\ell \;\sim\; E \;\sqcup\; p\cdot \mathrm{pt}$$
in the kernel of the natural surjection from the Burnside ring $A(E)$ to the ring of virtual permutation characters. For $p=2$ this is precisely the Klein relation of Section 6. The mark difference vector is supported at the single non-cyclic subgroup $E$, with value $-p$.

## 8. The coarse invariant retains the arithmetic: necklaces and Fermat

The refutation shows that the Molien invariant forgets *structure*. It does not forget *number theory*. The bridge is Corollary 3.8 combined with a cycle-index computation.

**Definition 8.1 (Colouring action).** Let $G$ act on a finite set $Y$, and let $k \ge 0$. Put $\mathrm{Col}(Y,k) = \{f : Y \to \{1,\dots,k\}\}$, with $G$ acting by $(g\cdot f)(y) = f(g^{-1}\cdot y)$.

**Lemma 8.2 (Fixed colourings).** $g\cdot f = f$ if and only if $f(g\cdot y) = f(y)$ for all $y$, i.e. iff $f$ is constant on each $\langle g\rangle$-orbit of $Y$.

**Theorem 8.3 (Cycle-index identity).** With $c(g) = \#\{\langle g\rangle\text{-orbits of } Y\}$,
$$\operatorname{fix}_{\mathrm{Col}(Y,k)}(g) \;=\; k^{\,c(g)} .$$

*Proof sketch.* By Lemma 8.2 a $g$-fixed colouring is precisely a function on the orbit set $Y/\langle g\rangle$; the assignment $f \mapsto \bar f$ is a bijection between $g$-fixed colourings of $Y$ and all colourings of $Y/\langle g\rangle$, and the latter number $k^{c(g)}$. $\square$

**Corollary 8.4 (Frobenius-type congruence for arbitrary actions).** For any finite group $G$ acting on any finite set $Y$ and any $k \ge 0$,
$$|G| \;\Bigm|\; \sum_{g\in G} k^{\,c(g)} .$$

*Proof.* Apply Corollary 3.8 to $X = \mathrm{Col}(Y,k)$ and use Theorem 8.3. $\square$

Now specialise to rotations.

**Lemma 8.5 (Cycles of a rotation).** Let $\mathbb{Z}/n$ act on itself by translation. The translation by $a$ generates a subgroup of order $n/\gcd(n,a)$ acting freely, so the number of its orbits is $c(a) = \gcd(n,a)$.

*Proof sketch.* Translation is a free action, so all orbits of $\langle a\rangle$ have size $|\langle a\rangle| = n/\gcd(n,a)$; hence the number of orbits is $n \big/ (n/\gcd(n,a)) = \gcd(n,a)$. $\square$

**Theorem 8.6 (Necklace congruence).** For all $n \ge 1$ and $k \ge 0$,
$$n \;\Bigm|\; \sum_{a \in \mathbb{Z}/n} k^{\gcd(n,a)} .$$

*Proof.* Combine Corollary 8.4 for $G = Y = \mathbb{Z}/n$ with Lemma 8.5. Equivalently: $\frac{1}{n}\sum_a k^{\gcd(n,a)}$ is the number of $k$-coloured necklaces with $n$ beads, hence an integer. $\square$

**Lemma 8.7 (Prime splitting).** For $p$ prime, $\sum_{a\in\mathbb{Z}/p} k^{\gcd(p,a)} = k^{p} + (p-1)k$.

*Proof sketch.* The term $a = 0$ contributes $k^{\gcd(p,0)} = k^{p}$; for $a \ne 0$ we have $0 < a < p$, so $p \nmid a$ and $\gcd(p,a) = 1$, contributing $k$ each, $p-1$ times. $\square$

**Theorem 8.8 (Fermat's little theorem).** For every prime $p$ and every integer $k \ge 0$,
$$k^{p} \equiv k \pmod p .$$

*Proof.* By Theorem 8.6 and Lemma 8.7, $p \mid k^p + (p-1)k = (k^p - k) + pk$, hence $p \mid k^p - k$. $\square$

This derivation is the classical necklace proof, but obtained here as a strict corollary of the Molien/orbit-counting machinery: only the *averaged* invariant is used, never the marks at non-cyclic subgroups. The arithmetic content survives the compression that destroys the structural content.

## 9. Algorithms

All the objects above are finite and effectively computable. We record the three procedures that a computation of the results uses.

**Algorithm A (Subgroup-indexed invariant tables).** *Input:* a finite group $G$ given by its multiplication table, and a finite $G$-set $X$ given by the permutation action. *Output:* the mark vector and the Molien vector of $X$.
1. Enumerate the subgroups of $G$ by closing every subset of generators under multiplication (or, for small $G$, by closing all subsets).
2. For each $g$, compute $\operatorname{fix}_X(g) = |\{x : g\cdot x = x\}|$ in $O(|X|)$.
3. For each subgroup $H$, compute $\operatorname{mark}_X(H) = |\{x : \forall h \in H,\ h\cdot x = x\}|$ in $O(|H||X|)$ and $\operatorname{Mol}_X(H) = \frac{1}{|H|}\sum_{h\in H}\operatorname{fix}_X(h)$ in $O(|H|)$.

Total cost $O(s\,|G|\,|X|)$ where $s$ is the number of subgroups. The two invariants can then be compared directly, and the *proportionality test* of Conjecture D10 is: compute the ratio forced at the trivial subgroup ($c = |X|/|Y|$) and test all remaining subgroups against it.

**Algorithm B (Orbit counting).** By Theorem 3.6, $\operatorname{Mol}_X(H)$ can be computed *without averaging*, by a union–find over the generators of $H$ acting on $X$, in near-linear time $O(|X|\cdot|\text{gens}|\cdot\alpha)$. The agreement of Algorithms A and B on every input is a numerical confirmation of Burnside's lemma in this normalisation.

**Algorithm C (Necklace counting).** For $n,k$ compute $N(n,k) = \frac{1}{n}\sum_{a=0}^{n-1}k^{\gcd(n,a)}$, equivalently $\frac{1}{n}\sum_{d\mid n}\varphi(n/d)\,k^{d}$. Integrality of the output for all inputs is Theorem 8.6; at $n = p$ prime it is exactly Fermat's little theorem.

## 10. Discussion

**What the refutation says about invariants.** The Burnside ring $A(G)$ has the mark homomorphism as a faithful coordinate system: mark vectors classify finite $G$-sets up to isomorphism. The permutation character defines a ring homomorphism $A(G) \to R(G)$ into the representation ring. Theorem 4.2 identifies this homomorphism concretely at the level of coordinates: *the character (equivalently the Molien vector) is the restriction of the mark vector to the cyclic part of the subgroup poset, averaged*. Conjecture D10 is thus asking whether this restriction is injective up to scaling, and Theorem 6.5 answers no as soon as a non-cyclic subgroup exists in a suitable position.

**Why "up to scaling" is a red herring.** In any counterexample the trivial subgroup pins $c$ to $|X|/|Y|$. Because the two sets in our examples have the same cardinality, $c$ must be $1$, and the freedom promised by "modulo scaling" evaporates. This is a general phenomenon: for the scaling formulation to have any content, one would need families with different cardinalities but proportional marks — but proportionality of the trivial-subgroup marks plus equality of Molien invariants (which include the cardinality) already forces $c = 1$.

**Sharpness.** Corollary 5.3 (all subgroups cyclic $\Rightarrow$ D10 with $c=1$) and Proposition 6.7 (the Klein marks differ precisely at the unique non-cyclic subgroup) sandwich the truth. The general expectation, formulated in the next section, is that the dichotomy is exact.

**Arithmetic robustness.** Section 8 demonstrates that the information destroyed by averaging is not the information used in classical counting arguments. Every congruence obtained from Burnside's lemma — necklaces, Fermat, and their relatives — factors through the Molien invariant.

## 11. Future directions

*After the refutation of Conjecture D10.* The conjecture is false, and the reason is now precisely located: the Molien invariant only sees the marks at *cyclic* subgroups. We have shown that the Molien invariant is the average of the marks at the cyclic subgroups $\langle h\rangle$, $h \in H$, so marks always determine Molien; that over a group whose subgroups are all cyclic, Molien determines marks with scaling factor $1$; and that for the Klein four group, and more generally for $(\mathbb{Z}/p)^2$ for every prime $p$, there are two $G$-sets with identical Molien invariants at every subgroup whose mark vectors are not proportional. The following are the natural next targets.

**C1. The cyclic dichotomy is exact.** *Conjecture.* For a finite group $G$ the following are equivalent: (i) any two finite $G$-sets with equal permutation characters have equal Burnside mark vectors; (ii) every subgroup of $G$ is cyclic.

The key insight is that a failure of injectivity of "mark vector $\mapsto$ character" is forced by a single non-cyclic section: the $(\mathbb{Z}/p)^2$ family shows that a rank-two elementary abelian subquotient already produces a character-equal, mark-different pair, and by Cauchy's theorem a non-cyclic finite abelian group contains such a subgroup — the general case should follow by inducing the pair up along $G/H$. Direction (ii) $\Rightarrow$ (i) and the elementary abelian instances of (i) $\Rightarrow$ (ii) are both settled; only the induction step (transport of a counterexample along induction of $G$-sets) is missing, and it is a finite, purely combinatorial construction.

**C2. Quantitative defect: the corank of the character map.** *Conjecture.* The kernel of the map "Burnside mark vector $\mapsto$ permutation character" has rank equal to (number of conjugacy classes of subgroups of $G$) $-$ (number of conjugacy classes of cyclic subgroups of $G$); for $(\mathbb{Z}/p)^2$ this is exactly $1$, matching the single relation $\bigsqcup_\ell E/\ell \sim E \sqcup p\cdot\mathrm{pt}$ proved above.

The key insight is that the mark matrix is triangular with respect to the subgroup order, so the character map factors through the "cyclic part" of the table of marks; the defect is therefore an index count on the subgroup lattice rather than a representation-theoretic computation. The single relation for $(\mathbb{Z}/p)^2$ is established uniformly in $p$, and the Averaging Theorem already exhibits the factorisation through cyclic subgroups; the remaining content is linear algebra over the (finite) subgroup poset.

**C3. Graded Molien series versus marks.** For a permutation representation the *graded* Molien series $M_X(t) = \frac{1}{|G|}\sum_g \prod_{\text{cycles } c \text{ of } g} (1-t^{|c|})^{-1}$ refines the constant-term data studied here. One asks how much of the mark vector the graded series recovers: it records the full cycle type of each element, hence strictly more than the fixed-point counts, and it is plausible that the graded invariant separates $G$-sets exactly when the ungraded one does — or that the cycle-type refinement already suffices to separate the $(\mathbb{Z}/p)^2$ pair, in which case the cyclic dichotomy would take a different, finer form for graded data.

**C4. Arithmetic consequences beyond necklaces.** The route from orbit counting to Fermat's little theorem generalises: any family of actions with a computable cycle index yields a congruence family. Natural targets include Gauss's congruence $\sum_{d\mid n}\mu(n/d)k^{d} \equiv 0 \pmod n$, its analogues for non-cyclic groups, and congruences arising from actions on colourings of higher-dimensional grids.

## 12. Conclusion

Conjecture D10 — that the Molien invariant is exactly the Burnside mark vector modulo scaling — is false. The precise state of affairs is:

- The Molien invariant is *always* a linear image of the mark vector: at $H$ it is the average of the marks at the cyclic subgroups generated by the elements of $H$.
- Conversely, if every subgroup of $G$ is cyclic, the Molien data determines the mark vector *exactly* (scaling factor $1$), and hence determines the $G$-set up to isomorphism.
- For the Klein four group there are two six-element $G$-sets with identical Molien invariants at every subgroup whose mark vectors are non-proportional; the same happens over $(\mathbb{Z}/p)^2$ for every prime $p$, with sets of size $p^2+p$. The mark vectors differ only at the non-cyclic subgroups, so the cyclic hypothesis is exactly the boundary of validity.
- Nevertheless the coarse invariant retains full arithmetic strength: $|H|$ divides $\sum_{h\in H}|X^h|$, and applying this to colouring actions of $\mathbb{Z}/n$ produces the necklace congruence $n \mid \sum_a k^{\gcd(n,a)}$ and Fermat's little theorem $k^p \equiv k \pmod p$.

Averaging over a group sees only its cyclic shadows: enough for counting, not enough for classification.
