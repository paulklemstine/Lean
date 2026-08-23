# The Burnside Moment Hierarchy

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

Let a finite group $G$ act on a finite set $X$, and let $a(g) = |X^g|$ denote the number of points fixed by $g$. Burnside's lemma (the Cauchy–Frobenius orbit-counting theorem) evaluates the first moment $\sum_{g\in G} a(g)$ as $|G|$ times the number of orbits. We develop the full **moment hierarchy** of the fixed-point statistic. The organising result is the identity
$$\sum_{g\in G} |X^g|^k \;=\; |G| \cdot \#\bigl(X^k/G\bigr), \qquad k \ge 0,$$
where $G$ acts diagonally on ordered $k$-tuples. Its instances are classical: $k=0$ is a tautology, $k=1$ is Burnside's lemma, and $k=2$ computes the *rank* of the permutation action. We prove a mixed-family generalisation $\sum_g \prod_i |X_i^g| = |G|\cdot\#\bigl((\prod_i X_i)/G\bigr)$, which identifies orbit counting on products with the inner product of permutation characters, and derive from it a Cauchy–Schwarz inequality for orbit counts. Writing $o_k = \#(X^k/G)$, we show that the hierarchy is monotone ($o_k \le o_{k+1}$ for $k\ge1$), log-convex ($o_{k+1}^2 \le o_k o_{k+2}$), superexponentially growing ($o_1^k \le o_k$ for $X$ non-empty), sandwiched ($|X|^k \le |G|o_k \le |G||X|^k$), and that $|G|$ divides every moment. A Markov-type bound converts high moments into bounds on the number of group elements with many fixed points. At $k=2$ we prove a rank splitting $\#\bigl((X\times X)/G\bigr) = \#(X/G) + \#(\mathrm{offDiag}/G)$, a second-moment characterisation of $2$-transitivity, and the identification of the rank of a transitive action with the number of suborbits of a point stabiliser. Instantiating at the full symmetric group, we classify orbits on $k$-tuples by kernel partitions and obtain the exact **Poisson moment theorem** $\sum_{\sigma \in \mathrm{Sym}(X)} |\mathrm{fix}\,\sigma|^k = P(k)\cdot n!$ for $k \le n = |X|$, where $P(k)$ is the number of set partitions of a $k$-set; log-convexity of the hierarchy then yields log-convexity of the Bell sequence $P(k+1)^2 \le P(k)P(k+2)$.

**Keywords:** Burnside's lemma, orbit counting, moment sequence, permutation rank, log-convexity, Bell numbers, permutation characters, suborbits.

---

## 1. Introduction

Orbit counting is one of the oldest computational tools in group theory. Given a finite group $G$ acting on a finite set $X$, the number of orbits $\#(X/G)$ is the number of configurations "up to symmetry", and Burnside's lemma computes it as an average over the group of a purely local quantity:
$$\#(X/G) \;=\; \frac{1}{|G|}\sum_{g\in G} |X^g|, \qquad X^g = \{x \in X : g\cdot x = x\}.$$
The lemma is elementary — it is double counting on the incidence set $\{(g,x) : g\cdot x = x\}$ combined with the orbit–stabiliser theorem — yet it underlies most practical enumeration up to symmetry.

The observation driving this paper is that the right-hand side of Burnside's lemma is a *statistical* quantity. Endow $G$ with the uniform probability measure and consider the random variable
$$A : G \to \mathbb{Z}_{\ge 0}, \qquad A(g) = |X^g|.$$
Burnside's lemma is the assertion $\mathbb{E}[A] = \#(X/G)$. A random variable with values in $\mathbb{Z}_{\ge 0}$ on a finite probability space is determined by its moment sequence, and it is natural to ask what the higher moments $\mathbb{E}[A^k]$ compute. The answer is complete and clean: **they are again orbit counts, on tuples.** This turns a single lemma into an infinite hierarchy, indexed by $k$, whose low levels are classical invariants and whose structural properties are inherited from general facts about moment sequences.

Two features distinguish the hierarchy from a routine generalisation.

1. **Structure transfer.** Because $o_k = \mathbb{E}[A^k]$ up to the constant $|G|$, inequalities valid for arbitrary moment sequences of non-negative variables (Cauchy–Schwarz, Markov, monotonicity for $A \ge 1$-supported statistics) descend to inequalities about orbit counts, and the factor $|G|$ cancels. The resulting statements are purely combinatorial and are not obvious from the combinatorial side.
2. **Exact Poisson behaviour.** For the full symmetric group, the hierarchy has closed form: level $k$ is the $k$-th Bell number, provided $k \le n$. Since the Bell numbers are exactly the moments of a Poisson($1$) variable (Dobiński's formula), the classical asymptotic statement "the number of fixed points of a random permutation is asymptotically Poisson($1$)" is upgraded to an exact finite identity, moment by moment, in the range $k \le n$.

Throughout, all counts are cardinalities of finite sets; no decidability or choice-of-representative assumptions are required, and all statements are cardinality statements about (possibly quotient) types.

### Notation

- $G$ is a finite group; $X$, $Y$, $X_i$ are finite $G$-sets.
- $X^g = \{x : g\cdot x = x\}$; $a(g) = |X^g|$.
- $X^k$ denotes the set of ordered $k$-tuples, i.e. functions $\{1,\dots,k\} \to X$, with the **diagonal** action $g\cdot(x_1,\dots,x_k) = (g x_1,\dots,g x_k)$.
- $o_k = o_k(G,X) = \#(X^k/G)$, the $k$-th **orbit count**, and $S_k = \sum_{g\in G} a(g)^k$, the $k$-th **moment**.
- $\mathrm{offDiag}(X) = \{(x,y) \in X\times X : x \ne y\}$, a $G$-invariant subset of $X\times X$.
- $\mathrm{Stab}_G(x) = \{g : g\cdot x = x\}$.
- $P(k)$ denotes the number of set partitions of a $k$-element set (equivalently, the number of equivalence relations on it); this is the $k$-th Bell number.

---

## 2. Fixed points of derived actions

The entire hierarchy rests on the elementary fact that fixed-point sets are multiplicative under the constructions that build tuples.

**Lemma 2.1 (Fixed points of a power action).** Let $I$ be a finite index set and give $X^I$ (functions $I \to X$) the pointwise action. Then for every $g\in G$,
$$f \in (X^I)^g \iff f(i) \in X^g \text{ for all } i \in I,$$
and consequently $(X^I)^g$ is in canonical bijection with $(X^g)^I$, so
$$\bigl|(X^I)^g\bigr| \;=\; |X^g|^{|I|}.$$

*Proof.* The action on $X^I$ is $(g\cdot f)(i) = g\cdot f(i)$, so $g\cdot f = f$ holds if and only if $g \cdot f(i) = f(i)$ for each $i$, by extensionality of functions. The map $f \mapsto (i \mapsto f(i))$, with values now regarded as elements of $X^g$, is a bijection $(X^I)^g \to (X^g)^I$ with the obvious inverse. Counting functions gives the exponential formula. $\square$

**Lemma 2.2 (Fixed points of a product action).** For $G$-sets $X, Y$ and $g\in G$, a pair $(x,y)$ lies in $(X\times Y)^g$ iff $x \in X^g$ and $y \in Y^g$; hence
$$\bigl|(X\times Y)^g\bigr| \;=\; |X^g|\cdot|Y^g|.$$

**Lemma 2.3 (Fixed points of a family product).** For a finite family $(X_i)_{i\in I}$ of $G$-sets with the pointwise action on $\prod_i X_i$,
$$\Bigl|\bigl(\textstyle\prod_i X_i\bigr)^g\Bigr| \;=\; \prod_i |X_i^g|.$$

Each is proved by the same extensionality argument as Lemma 2.1, and Lemma 2.2 is the two-factor case of Lemma 2.3.

We also record Burnside's lemma in the form we use.

**Theorem 2.4 (Burnside / Cauchy–Frobenius).** For a finite group $G$ acting on a finite set $X$,
$$\sum_{g\in G} |X^g| \;=\; \#(X/G)\cdot|G|.$$

*Proof sketch.* Count the incidence set $F = \{(g,x) \in G\times X : g\cdot x = x\}$ in two ways. Summing over $g$ gives $\sum_g |X^g|$. Summing over $x$ gives $\sum_x |\mathrm{Stab}_G(x)|$. By orbit–stabiliser, $|\mathrm{Stab}_G(x)| = |G|/|Gx|$, and summing over the points of a single orbit contributes $|G|$; summing over all orbits gives $\#(X/G)\cdot|G|$. $\square$

---

## 3. The moment identity

**Theorem 3.1 (Moment identity).** Let $G$ be a finite group acting on a finite set $X$. For every $k \ge 0$,
$$\boxed{\;\sum_{g\in G} |X^g|^k \;=\; \#\bigl(X^k/G\bigr)\cdot |G|.\;}$$
Equivalently, $S_k = o_k\,|G|$, i.e. the $k$-th moment of the fixed-point statistic under the uniform measure on $G$ is the number of orbits on ordered $k$-tuples.

*Proof.* Apply Theorem 2.4 to the $G$-set $X^k$ (finite, since $X$ is finite and $k$ is finite): $\sum_{g} |(X^k)^g| = \#(X^k/G)\cdot|G|$. By Lemma 2.1 with $I = \{1,\dots,k\}$, $|(X^k)^g| = |X^g|^k$ termwise. Substituting gives the claim. $\square$

The proof is short, but the statement is the organising principle: *every* moment of the fixed-point statistic is a Burnside average one level up.

**Theorem 3.2 (Mixed moment identity).** For any finite family $(X_i)_{i\in I}$ of finite $G$-sets,
$$\sum_{g\in G} \prod_{i\in I} |X_i^g| \;=\; \#\Bigl(\bigl(\textstyle\prod_{i} X_i\bigr)/G\Bigr)\cdot|G|.$$
Taking all $X_i = X$ and $|I| = k$ recovers Theorem 3.1.

*Proof.* Theorem 2.4 applied to $\prod_i X_i$, with Lemma 2.3 rewriting each term of the sum. $\square$

**Corollary 3.3 (Bilinear Burnside).** For finite $G$-sets $X, Y$,
$$\sum_{g\in G} |X^g|\cdot|Y^g| \;=\; \#\bigl((X\times Y)/G\bigr)\cdot|G|.$$

The function $\chi_X(g) = |X^g|$ is the **permutation character** of the $G$-set $X$: it is the character of the linear permutation representation on the free vector space with basis $X$, since the matrix of $g$ is a permutation matrix whose trace counts fixed basis vectors. Corollary 3.3 therefore says
$$\langle \chi_X, \chi_Y\rangle \;=\; \frac{1}{|G|}\sum_{g}\chi_X(g)\chi_Y(g) \;=\; \#\bigl((X\times Y)/G\bigr),$$
using $\chi_Y(g^{-1}) = \chi_Y(g)$ for permutation characters (they are real-valued, and $|Y^{g}| = |Y^{g^{-1}}|$). This is the classical Burnside–Frobenius interpretation of the character inner product, and it identifies the orbit-counting pairing as a positive-semidefinite bilinear form on the semiring of $G$-sets. The moment hierarchy is precisely the diagonal of this form.

### 3.1 Low levels

**Level $k = 0$.** There is exactly one map $\emptyset \to X$, so $X^0$ is a one-point set with trivial action and $o_0 = 1$. The identity reads $|G| = |G|$.

**Level $k=1$.** $X^1 \cong X$ as $G$-sets, so $o_1 = \#(X/G)$ and Theorem 3.1 is Burnside's lemma.

**Level $k=2$.** $X^2 \cong X\times X$, so
$$\sum_{g\in G}|X^g|^2 \;=\; \#\bigl((X\times X)/G\bigr)\cdot|G|,$$
and $\#\bigl((X\times X)/G\bigr)$ is by definition the **rank** of the permutation action.

**Proposition 3.4 (Transitivity from the first moment).** If $X$ is non-empty, then the action is transitive if and only if $\sum_{g\in G}|X^g| = |G|$.

*Proof.* By Burnside, the sum equals $\#(X/G)\cdot|G|$; since $X \ne \emptyset$ the orbit count is a positive integer, and it equals $1$ iff the quotient is a singleton, i.e. iff the action is transitive. Conversely, if the sum equals $|G|$ then $\#(X/G)\cdot|G| = |G|$; were $\#(X/G) \ge 2$ we would get $2|G| \le |G|$, impossible. $\square$

---

## 4. The rank level in detail

Fix a finite group $G$ acting on a finite set $X$. Recall $\mathrm{offDiag}(X) = \{(x,y): x\ne y\}$, which is $G$-invariant since the action is by bijections.

**Lemma 4.1.** For every $g$, $\bigl|\mathrm{offDiag}(X)^g\bigr| + |X^g| = |X^g|^2$.

*Proof.* A pair $(x,y)$ with $x \ne y$ is fixed by $g$ iff both $x$ and $y$ are, so $\mathrm{offDiag}(X)^g = \mathrm{offDiag}(X^g)$, the set of ordered pairs of *distinct* $g$-fixed points. For any finite set $F$, $|\mathrm{offDiag}(F)| + |F| = |F|^2$, since the ordered pairs from $F$ split into the diagonal (a copy of $F$) and the rest. $\square$

**Theorem 4.2 (Rank splitting).**
$$\#\bigl((X\times X)/G\bigr) \;=\; \#(X/G) \;+\; \#\bigl(\mathrm{offDiag}(X)/G\bigr).$$

*Proof.* Multiply each side by $|G|$ and use Burnside three times: the left side becomes $\sum_g |X^g|^2$; the right side becomes $\sum_g |X^g| + \sum_g |\mathrm{offDiag}(X)^g|$. Lemma 4.1 makes the two equal termwise. Cancel the positive factor $|G|$. $\square$

Note that the argument is *not* the (also valid) direct decomposition of the quotient; it is a moment computation, and it is typical of the method: an identity between orbit counts is proved by proving the corresponding identity between fixed-point counts, elementwise in $G$.

**Corollary 4.3 (Rank at least two).** If $|X| \ge 2$ and the action is transitive, then $\sum_{g\in G}|X^g|^2 \ge 2|G|$.

*Proof.* Transitivity gives $\#(X/G) = 1$; since $|X|\ge2$ there is a pair $x \ne y$, so $\mathrm{offDiag}(X)$ is non-empty and its orbit count is at least $1$. Theorem 4.2 gives rank $\ge 2$; multiply by $|G|$. $\square$

**Theorem 4.4 (Second-moment characterisation of $2$-transitivity).** Suppose $|X| \ge 2$. Then $G$ acts transitively on $X$ *and* transitively on $\mathrm{offDiag}(X)$ if and only if
$$\sum_{g\in G} |X^g|^2 \;=\; 2\,|G|.$$

*Proof.* By Theorem 3.1 and Theorem 4.2 the left-hand side equals $\bigl(\#(X/G) + \#(\mathrm{offDiag}(X)/G)\bigr)|G|$. Both orbit counts are $\ge 1$ (both sets are non-empty because $|X|\ge2$). Hence the sum equals $2|G|$ iff both counts equal $1$, i.e. iff both actions are transitive. $\square$

**Remark 4.5 (A tempting false statement).** It is *not* true that transitivity alone forces rank $2$. The dihedral group of order $8$ acting on the four vertices of a square is transitive, but its fixed-point statistic is $(4,0,0,0,2,2,0,0)$, giving $\sum_g |X^g|^2 = 24 = 3\cdot 8$: rank $3$. The orbits on ordered pairs are the diagonal, the adjacent pairs, and the opposite pairs. Theorem 4.4 is stated with the off-diagonal transitivity hypothesis for exactly this reason.

### 4.1 Suborbits: the local form of the second moment

**Theorem 4.6 (Rank equals the number of suborbits).** Let $G$ act transitively on $X$, let $x_0 \in X$ and $H = \mathrm{Stab}_G(x_0)$. Then
$$\#\bigl((X\times X)/G\bigr) \;=\; \#(X/H).$$

*Proof.* Define $\Phi : X/H \to (X\times X)/G$ by $\Phi(Hy) = G\cdot(x_0,y)$. *Well-defined:* if $y' = h\cdot y$ with $h \in H$, then $h\cdot(x_0,y) = (x_0, y')$, so the pairs lie in the same $G$-orbit. *Injective:* if $(x_0,y)$ and $(x_0,y')$ are in the same $G$-orbit, say $g\cdot(x_0,y') = (x_0,y)$, then $g\cdot x_0 = x_0$, so $g \in H$ and $g\cdot y' = y$, whence $Hy = Hy'$. *Surjective:* given $(x,y)$, transitivity provides $a$ with $a\cdot x_0 = x$; then $a^{-1}\cdot(x,y) = (x_0, a^{-1}y)$, so $G\cdot(x,y) = \Phi(H a^{-1}y)$. $\square$

**Corollary 4.7.** For a transitive action of a finite $G$ on a finite $X$ with $x_0 \in X$ and $H = \mathrm{Stab}_G(x_0)$,
$$\sum_{g\in G} |X^g|^2 \;=\; \#(X/H)\cdot|G|,$$
and if moreover $|X| \ge 2$,
$$\#(X/H) \;=\; 1 + \#\bigl(\mathrm{offDiag}(X)/G\bigr).$$

*Proof.* Combine Theorem 3.1 at $k=2$ with Theorem 4.6 for the first claim; combine Theorem 4.6 with Theorem 4.2 and $\#(X/G)=1$ for the second. $\square$

Thus the second moment — a global average over the whole group — is computable inside a single point stabiliser, and its "excess above 1" measures failure of $2$-transitivity.

---

## 5. Structural properties of the hierarchy

Throughout this section $G$ is a finite group acting on a finite $X$, and $o_k = \#(X^k/G)$, $S_k = \sum_g |X^g|^k = o_k|G|$.

**Proposition 5.1 (Divisibility).** For every $k$, $|G|$ divides $S_k = \sum_{g\in G}|X^g|^k$.

*Proof.* Immediate from Theorem 3.1, since $o_k$ is a non-negative integer. $\square$

This is a non-trivial constraint on the integer sequence $S_k$ that makes no reference to orbits.

**Proposition 5.2 (Bottom of the hierarchy).** $o_0 = 1$; and if $X \ne \emptyset$ then $o_k \ge 1$ for all $k$.

**Theorem 5.3 (Monotonicity).** For every $k \ge 1$, $o_k \le o_{k+1}$.

*Proof.* For each $g$, either $|X^g| = 0$, in which case $|X^g|^k = |X^g|^{k+1} = 0$ (here $k\ge 1$ is needed, since $0^0 = 1$), or $|X^g| \ge 1$, in which case $|X^g|^k \le |X^g|^{k+1}$. Summing, $S_k \le S_{k+1}$, i.e. $o_k|G| \le o_{k+1}|G|$; cancel $|G| > 0$. $\square$

The hypothesis $k \ge 1$ is necessary: for $X = \emptyset$ one has $o_0 = 1 > 0 = o_1$.

**Lemma 5.4 (Pointwise AM–GM).** For non-negative integers $x, y$ and any $k \ge 0$,
$$2\,x^{k+1}y^{k+1} \;\le\; x^k y^{k+2} + y^k x^{k+2}.$$

*Proof.* $2xy \le x^2 + y^2$ since $(x-y)^2 \ge 0$. Multiply by $x^ky^k \ge 0$ and expand:
$x^ky^k(2xy) = 2x^{k+1}y^{k+1}$ and $x^ky^k(x^2+y^2) = y^kx^{k+2} + x^ky^{k+2}$. $\square$

**Lemma 5.5 (Cauchy–Schwarz for moment sequences).** Let $S$ be a finite index set and $a : S \to \mathbb{Z}_{\ge0}$. Then for every $k \ge 0$,
$$\Bigl(\sum_{i\in S} a_i^{k+1}\Bigr)^{2} \;\le\; \Bigl(\sum_{i\in S} a_i^{k}\Bigr)\Bigl(\sum_{i \in S} a_i^{k+2}\Bigr).$$

*Proof.* Expand both sides as double sums: the left is $\sum_{i,j} a_i^{k+1}a_j^{k+1}$ and the right is $\sum_{i,j} a_i^k a_j^{k+2}$. Doubling the right and symmetrising the summation index gives $\sum_{i,j}\bigl(a_i^ka_j^{k+2} + a_j^ka_i^{k+2}\bigr)$, which dominates $\sum_{i,j} 2a_i^{k+1}a_j^{k+1}$ termwise by Lemma 5.4. Halving gives the claim. (This is Cauchy–Schwarz applied to the vectors $\bigl(a_i^{k/2}\bigr)$ and $\bigl(a_i^{(k+2)/2}\bigr)$, arranged to stay inside the integers.) $\square$

**Theorem 5.6 (Log-convexity of the orbit hierarchy).** For every $k \ge 0$,
$$o_{k+1}^2 \;\le\; o_k \cdot o_{k+2}.$$

*Proof.* Apply Lemma 5.5 with $S = G$ and $a(g) = |X^g|$ to obtain $S_{k+1}^2 \le S_k S_{k+2}$. Substituting $S_j = o_j|G|$ yields $o_{k+1}^2|G|^2 \le o_k o_{k+2} |G|^2$; cancel $|G|^2 > 0$. $\square$

**Theorem 5.7 (Superexponential growth).** If $X \ne \emptyset$ then for all $k \ge 0$,
$$o_1\cdot o_k \;\le\; o_{k+1}, \qquad\text{and hence}\qquad o_1^{\,k} \;\le\; o_k .$$

*Proof.* The first inequality by induction on $k$. For $k = 0$ it reads $o_1 \cdot 1 \le o_1$. Assume $o_1 o_n \le o_{n+1}$. Then
$$(o_1 o_{n+1})\,o_n = (o_1 o_n)\,o_{n+1} \le o_{n+1}^2 \le o_n o_{n+2},$$
using the inductive hypothesis and Theorem 5.6. Since $X\ne\emptyset$ gives $o_n > 0$, we may cancel $o_n$ to get $o_1 o_{n+1} \le o_{n+2}$. The second inequality follows by induction: $o_1^{n+1} = o_1\cdot o_1^n \le o_1 o_n \le o_{n+1}$. $\square$

Thus $\#(X/G)^k \le \#(X^k/G)$: the number of orbits on $k$-tuples is at least the $k$-th power of the number of orbits on points — the naive lower bound obtained by remembering only which orbit each coordinate lies in, now proved by pure moment manipulation.

**Theorem 5.8 (Sandwich).** For all $k$,
$$|X|^k \;\le\; |G|\cdot o_k \;\le\; |G|\cdot|X|^k.$$

*Proof.* The lower bound: the identity element fixes everything, so $|X|^k = |X^1|^k$ is one term of the non-negative sum $S_k = |G| o_k$. The upper bound: $|X^g| \le |X|$ for every $g$, so $S_k \le |G|\cdot|X|^k$. $\square$

Equivalently $|X|^k/|G| \le o_k \le |X|^k$: the hierarchy is pinned between the naive count divided by the group order and the naive count itself.

**Theorem 5.9 (Moment / Markov bound).** For all $t, k \ge 0$,
$$\#\{g \in G : |X^g| \ge t\}\cdot t^k \;\le\; \#\bigl(X^k/G\bigr)\cdot|G| .$$

*Proof.* Restrict the sum $S_k = \sum_g |X^g|^k$ to the set $T = \{g : |X^g| \ge t\}$; every remaining term is $\ge t^k$, giving $|T| t^k \le S_k = o_k|G|$. $\square$

Taking $k$ large makes this a strong constraint: if the hierarchy grows slowly, then very few group elements can fix many points. Conversely, the existence of many heavily-fixing elements forces the higher levels of the hierarchy to be large.

**Theorem 5.10 (Cauchy–Schwarz for orbit counts).** For finite $G$-sets $X$ and $Y$,
$$\#\bigl((X\times Y)/G\bigr)^2 \;\le\; \#\bigl((X\times X)/G\bigr)\cdot\#\bigl((Y\times Y)/G\bigr).$$

*Proof.* Set $a(g)=|X^g|$, $b(g)=|Y^g|$. Corollary 3.3 gives $\#\bigl((X\times Y)/G\bigr)|G| = \sum_g a(g)b(g)$, and Theorem 3.1 at $k=2$ gives $\#\bigl((X\times X)/G\bigr)|G| = \sum_g a(g)^2$ and likewise for $Y$. Cauchy–Schwarz $(\sum ab)^2 \le (\sum a^2)(\sum b^2)$, followed by cancelling $|G|^2$, gives the claim. $\square$

This is the statement that the orbit-counting pairing on $G$-sets is positive semidefinite — visible directly, without ever mentioning representations.

### 5.1 An extreme case: the regular action

**Theorem 5.11 (Regular action).** Let $G$ act on itself by left translation and let $k \ge 1$. Then
$$o_k(G, G) \;=\; |G|^{\,k-1}.$$

*Proof.* For the regular action, $g\cdot x = x$ forces $g = 1$; hence $|G^g| = 0$ for $g \ne 1$ and $|G^1| = |G|$. So $S_k = |G|^k$ (only the identity term survives, using $k \ge 1$), and $o_k = S_k/|G| = |G|^{k-1}$. $\square$

The regular action saturates the lower end of the sandwich of Theorem 5.8: $|G| o_k = |G|^k = |X|^k$ exactly. It is also the extreme case of Theorem 5.7, since $o_1 = 1$ and the growth is exactly geometric with ratio $|G|$.

---

## 6. The symmetric group: kernels, Bell numbers and exact Poisson moments

Let $X$ be a finite set with $|X| = n$ and let $G = \mathrm{Sym}(X)$ act naturally. Then $|X^\sigma| = |\mathrm{fix}\,\sigma|$ and the hierarchy becomes the moment sequence of the number of fixed points of a uniformly random permutation.

**Definition 6.1 (Kernel of a tuple).** For $f : \{1,\dots,k\} \to X$, the **kernel** of $f$ is the equivalence relation $\ker f$ on $\{1,\dots,k\}$ defined by $i \sim j \iff f(i) = f(j)$; equivalently, the set partition of $\{1,\dots,k\}$ into the fibres of $f$.

**Theorem 6.2 (Kernel classification of orbits).** Two $k$-tuples $f, f' : \{1,\dots,k\} \to X$ lie in the same $\mathrm{Sym}(X)$-orbit if and only if $\ker f = \ker f'$.

*Proof.* ($\Rightarrow$) If $f' = \sigma \circ f$ for a bijection $\sigma$, then $f'(i) = f'(j) \iff \sigma f(i) = \sigma f(j) \iff f(i) = f(j)$, so the kernels agree.
($\Leftarrow$) Suppose $\ker f = \ker f'$. Then the assignment $f(i) \mapsto f'(i)$ is a well-defined injection from the image of $f$ onto the image of $f'$: well-defined because $f(i)=f(j)$ forces $f'(i)=f'(j)$, and injective by the converse implication. The two images therefore have the same cardinality, hence so do their complements in $X$; choose any bijection between the complements and glue. The resulting permutation $\sigma$ of $X$ satisfies $\sigma\circ f = f'$. $\square$

**Theorem 6.3 (Realisability).** If $k \le n$, every equivalence relation $r$ on $\{1,\dots,k\}$ arises as $\ker f$ for some $f : \{1,\dots,k\}\to X$.

*Proof.* The quotient $\{1,\dots,k\}/r$ has at most $k \le n = |X|$ classes, so there is an injection $\iota$ from the set of classes into $X$; take $f(i) = \iota([i])$. Then $f(i) = f(j) \iff [i] = [j] \iff i \sim_r j$. $\square$

**Corollary 6.4 (Orbits on tuples are set partitions).** For $k \le n$,
$$o_k\bigl(\mathrm{Sym}(X), X\bigr) \;=\; P(k),$$
the number of set partitions of a $k$-element set (the $k$-th Bell number).

*Proof.* By Theorem 6.2 the map "orbit $\mapsto$ kernel" is a well-defined injection from $X^k/\mathrm{Sym}(X)$ into the set of equivalence relations on $\{1,\dots,k\}$, and by Theorem 6.3 it is surjective when $k \le n$. $\square$

**Theorem 6.5 (Poisson moment theorem).** Let $|X| = n$ and $k \le n$. Then
$$\sum_{\sigma\in \mathrm{Sym}(X)} |\mathrm{fix}\,\sigma|^{\,k} \;=\; P(k)\cdot n!.$$
Equivalently, if $\sigma$ is a uniformly random permutation of an $n$-set, then $\mathbb{E}\bigl[|\mathrm{fix}\,\sigma|^k\bigr] = P(k)$ for every $k \le n$.

*Proof.* Theorem 3.1 with $G = \mathrm{Sym}(X)$, $|G| = n!$, and $o_k = P(k)$ by Corollary 6.4. $\square$

**Remark 6.6 (Why "Poisson").** Dobiński's formula states $P(k) = e^{-1}\sum_{m\ge0} m^k/m!$, which is exactly the $k$-th raw moment of a Poisson random variable of mean $1$. Theorem 6.5 therefore says: the fixed-point count of a random permutation of an $n$-set agrees with a Poisson($1$) variable in *all* moments up to order $n$ — exactly, not asymptotically. Since a distribution on $\mathbb{Z}_{\ge0}$ with sufficiently controlled moments is determined by them, this is a quantitative, finitary form of the classical Poisson limit for fixed points.

**Remark 6.7 (Sharpness of $k \le n$).** For $n = 3$ the fixed-point counts over the six permutations are $3,1,1,1,0,0$, giving $S_1 = 6 = 1\cdot 3!$, $S_2 = 12 = 2\cdot3!$, $S_3 = 30 = 5\cdot3!$ — matching $P(1),P(2),P(3) = 1,2,5$. At $k=4$, however, $S_4 = 84 = 14\cdot 3!$ while $P(4)=15$: the partition of $\{1,2,3,4\}$ into four singletons is not realisable by a $4$-tuple of points from a $3$-set. Beyond $k = n$ the hierarchy undercounts partitions by exactly the number of partitions with more than $n$ blocks.

**Theorem 6.8 (Low levels and $2$-transitivity of $\mathrm{Sym}(X)$).** For $n \ge 1$, $\sum_\sigma |\mathrm{fix}\,\sigma| = n!$, and for $n \ge 2$, $\sum_\sigma |\mathrm{fix}\,\sigma|^2 = 2\cdot n!$.

*Proof.* The natural action is transitive, so Proposition 3.4 gives the first. For the second, $\mathrm{Sym}(X)$ is transitive on ordered pairs of distinct points: given $a\ne b$ and $c \ne d$, the product of two transpositions $\bigl(\,\sigma_1 = (a\,c)$, then $\sigma_2 = (\sigma_1(b)\; d)\,\bigr)$ carries $(a,b)$ to $(c,d)$, the second transposition being chosen to fix $c$ because $\sigma_1(b) \ne c$. Now apply Theorem 4.4. $\square$

These are the cases $P(1) = 1$, $P(2) = 2$ of Theorem 6.5, recovered independently.

**Theorem 6.9 (Log-convexity of the Bell numbers).** For all $k\ge0$,
$$P(k+1)^2 \;\le\; P(k)\cdot P(k+2).$$

*Proof.* Choose $n \ge k+2$ and apply Theorem 5.6 to the natural action of $\mathrm{Sym}(X)$ on an $n$-set; by Corollary 6.4 the three levels involved are $P(k), P(k+1), P(k+2)$. $\square$

The first values $P(0),\dots,P(5) = 1,1,2,5,15,52$ satisfy $1 \le 2$, $4\le5$, $25\le30$, $225\le260$. It is worth stressing what has happened: a classical inequality about set partitions has been obtained as Cauchy–Schwarz for the moments of a random permutation's fixed-point count, without any combinatorial manipulation of partitions.

**Small values by measurement.** The identity can also be run backwards to *compute* partition counts. For $n=3$, direct enumeration of the six permutations gives $\sum_\sigma|\mathrm{fix}\,\sigma|^3 = 30$, hence $P(3) = 30/6 = 5$. For $n = 4$, the $24$ permutations have fixed-point counts $4$ (once), $2$ (six transpositions), $1$ (eight $3$-cycles), $0$ (three double transpositions and six $4$-cycles), giving $\sum_\sigma|\mathrm{fix}\,\sigma|^4 = 256 + 6\cdot16 + 8\cdot1 = 360$, hence $P(4) = 360/24 = 15$. Both values are consistent with Theorem 6.9 at $k=2$: $P(3)^2 = 25 \le 2\cdot15 = P(2)P(4)$.

---

## 7. Algorithms

The hierarchy is computationally friendly precisely because the identity has a cheap side and an expensive side.

**Algorithm 7.1 (Moment ladder from a fixed-point profile).**
Input: the multiset $\{a(g) : g\in G\}$ of fixed-point counts, and a bound $K$.
Output: $o_0, \dots, o_K$.
For each $k$, compute $S_k = \sum_g a(g)^k$ and set $o_k = S_k/|G|$ (an exact integer division, by Proposition 5.1). Cost: $O(|G|\cdot K)$ arithmetic operations after the profile is known, versus the $\Theta(|X|^k)$ cost of enumerating orbits on $k$-tuples directly. For a permutation group given by generators, the profile itself costs $O(|G|\cdot|X|)$ by enumeration, or can be read off from a cycle-index computation.

**Algorithm 7.2 (Rank and $2$-transitivity test).**
Compute $S_1$ and $S_2$ from the profile. Report transitive iff $S_1 = |G|$; report the rank as $S_2/|G|$; report $2$-transitive iff $S_2 = 2|G|$ (with $|X|\ge2$). By Theorem 4.2 the number of orbits on distinct ordered pairs is $S_2/|G| - S_1/|G|$. This avoids any explicit search over the $|X|^2$ pairs.

**Algorithm 7.3 (Certified structural checks).**
Given the computed ladder $o_0,\dots,o_K$, verify: $o_0=1$; $o_k \le o_{k+1}$ for $1\le k <K$; $o_{k+1}^2 \le o_ko_{k+2}$; $o_1^k \le o_k$; and $|X|^k \le |G|o_k \le |G||X|^k$. These are guaranteed by Theorems 5.3, 5.6, 5.7, 5.8, so a violation is a certificate of an implementation error — a useful self-test for orbit-counting software.

**Algorithm 7.4 (Bell numbers from a symmetric group).**
For $k \le n$, enumerate the fixed-point profile of $\mathrm{Sym}(\{1,\dots,n\})$ (or use the exact count $\#\{\sigma : |\mathrm{fix}\,\sigma| = m\} = \binom{n}{m}D_{n-m}$ with $D$ the derangement numbers) and output $P(k) = S_k/n!$. Using the derangement form this costs $O(n + k\log k)$ big-integer operations and gives an independent route to the Bell numbers via Theorem 6.5.

---

## 8. Applications and interpretation

**Enumeration up to symmetry, refined.** Classical applications of Burnside's lemma — necklaces, colourings, chemical isomers, switching classes of graphs — all live at level $k=1$ applied to a set of colourings. The hierarchy says the same input data (a table of fixed-point counts) simultaneously answers questions about *ordered tuples* of configurations up to simultaneous symmetry, at no extra modelling cost. In particular the rank $o_2$ measures how many essentially different "relative positions" two configurations can have.

**Permutation group theory.** Rank, subdegrees and suborbits are the standard first invariants of a transitive permutation group, and $2$-transitivity is a gateway hypothesis in the classification of finite simple groups' permutation representations. Theorem 4.4 packages $2$-transitivity as a single quadratic identity in the fixed-point profile, and Theorem 4.6 identifies the second level with a stabiliser computation.

**Representation theory.** By Corollary 3.3, $o_2 = \langle\chi_X,\chi_X\rangle$ is the sum of squares of the multiplicities of the irreducible constituents of the permutation representation. Hence $o_2 = 2$ (rank $2$, i.e. $2$-transitivity) is equivalent to the permutation representation splitting as the trivial representation plus a single irreducible — the classical fact that $2$-transitive actions have irreducible standard representation. Higher $o_k$ constrain the decomposition of tensor powers.

**Probabilistic combinatorics.** Theorem 6.5 gives exact moments for the fixed-point statistic of a random permutation, and Theorem 5.9 turns any level of the hierarchy into a tail bound. This is a fully combinatorial substitute for probabilistic machinery in the finite regime.

**Software correctness.** Because the ladder must be monotone, log-convex and sandwiched, these become cheap oracles for testing orbit-enumeration code, as in Algorithm 7.3.

---

## 9. Discussion

The moment identity is, in a precise sense, the statement that the map
$$\text{$G$-set } Z \;\longmapsto\; \#(Z/G)$$
is a linear functional on the Burnside semiring of finite $G$-sets, that it is computed by averaging the permutation character, and that the semiring's multiplication (product of $G$-sets) corresponds to multiplication of characters. The hierarchy is what one sees on the diagonal subsemiring generated by a single $G$-set $X$. From this vantage:

- Monotonicity, log-convexity and growth are statements about a single character being multiplied by itself; they hold for the same reason that moment sequences of non-negative variables are log-convex, and the group order cancels because the functional is an average.
- The bilinear identity (Corollary 3.3) explains why level-$2$ information is representation-theoretic: it is a genuine inner product, so Cauchy–Schwarz (Theorem 5.10) is available and equality analysis is meaningful.
- The symmetric-group case is extremal: the fixed-point statistic is as spread out as possible, and the hierarchy saturates at the Bell numbers, the largest values compatible with kernel classification.

Two limitations are worth naming. First, the hierarchy is *not* a complete invariant of a $G$-set: two non-isomorphic $G$-sets can have the same permutation character (Gassmann equivalence), hence the same ladder at every level. Second, the range $k \le n$ in the symmetric-group results is essential and not a technicality (Remark 6.7); for $k > n$ the orbit count equals the number of partitions of a $k$-set into at most $n$ blocks, i.e. a partial Bell sum, and the clean Poisson statement degrades accordingly.

---

## 10. Future directions

**Bell recurrence via orbit surgery.** The Bell recurrence $B_{n+1} = \sum_i \binom{n}{i}B_{n-i}$ should be the orbit-counting shadow of a surgery on $(n+1)$-tuples: split off the block containing the last coordinate. Since the kernel classification already identifies orbits with partitions, only the block-decomposition bijection is missing.

**Stirling transform of the hierarchy.** The $k$-th level decomposes over kernel types: $o_k = \sum_j S(k,j)\, d_j$, where $S(k,j)$ are Stirling numbers of the second kind and $d_j$ is the number of orbits on *injective* $j$-tuples. This generalises the $k=2$ splitting $o_2 = o_1 + \#(\mathrm{offDiag}/G)$ proved above; the general case needs the decomposition of the tuple space by kernel type.

**Multiplicity-free actions from moment saturation.** The hierarchy sees representation-theoretic multiplicities: $o_2$ is the sum of squared multiplicities in the permutation representation, so $o_2$ equal to the number of irreducible constituents characterises multiplicity-free (Gelfand pair) actions. Higher levels should detect finer decomposition data of tensor powers, giving purely combinatorial criteria for representation-theoretic conditions.

**Sharpness and equality analysis.** When is log-convexity an equality? For the regular action, $o_k = |G|^{k-1}$ makes $o_{k+1}^2 = o_ko_{k+2}$ exactly, so the geometric sequences are equality cases; a classification of actions with exactly log-linear hierarchies would sharpen the growth theory.

**Effective tail bounds.** Optimising Theorem 5.9 over $k$ for concrete families (symmetric, alternating, classical groups of Lie type) should reproduce and possibly sharpen known bounds on the number of elements with many fixed points.

---

## 11. Summary of results

1. **Moment identity.** $\sum_{g\in G}|X^g|^k = \#(X^k/G)\cdot|G|$ for all $k \ge 0$.
2. **Mixed moment identity.** $\sum_{g\in G}\prod_i|X_i^g| = \#\bigl((\prod_iX_i)/G\bigr)\cdot|G|$; the two-factor case identifies the permutation-character inner product with orbit counting on the product.
3. **Level $k=2$.** Rank splitting $\#\bigl((X\times X)/G\bigr) = \#(X/G)+\#(\mathrm{offDiag}/G)$; the second-moment criterion $\sum_g|X^g|^2 = 2|G|$ for $2$-transitivity; rank equals the number of suborbits of a point stabiliser for transitive actions.
4. **Structure.** Monotonicity for $k\ge1$; log-convexity $o_{k+1}^2\le o_ko_{k+2}$; superexponential growth $o_1^k \le o_k$; the sandwich $|X|^k\le|G|o_k\le|G||X|^k$; divisibility of every moment by $|G|$; a Markov bound on elements with many fixed points; Cauchy–Schwarz $\#\bigl((X\times Y)/G\bigr)^2 \le \#\bigl((X\times X)/G\bigr)\#\bigl((Y\times Y)/G\bigr)$.
5. **Regular action.** $o_k(G,G) = |G|^{k-1}$ for $k\ge1$.
6. **Symmetric group.** Kernel classification of orbits on $k$-tuples; $o_k = P(k)$ for $k\le n$; the exact Poisson moment theorem $\sum_\sigma|\mathrm{fix}\,\sigma|^k = P(k)\,n!$ for $k\le n$; log-convexity of the Bell numbers $P(k+1)^2\le P(k)P(k+2)$.
