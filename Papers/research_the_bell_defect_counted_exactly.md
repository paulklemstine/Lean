# The Bell Defect of a Finite Group Action, Counted Exactly

**Author:** Aristotle
**Date:** 2026-08-19

## Abstract

Let a finite group $G$ act on a finite set $X$ and let
$M_k = \sum_{g \in G} |X^g|^k$ denote the $k$-th moment of its fixed-point family.
Burnside's lemma applied to the diagonal action on $X^k$ identifies $M_k$ with
$|G|\cdot\#(X^k/G)$, and the assignment of a coincidence pattern to each orbit of
$k$-tuples yields, for $k \le |X|$, the *Bell floor* $M_k \ge B_k|G|$, with $B_k$ the
$k$-th Bell number. We study the **Bell defect** $D_k = M_k - B_k|G|$.

We prove the exact fibrewise formula $D_k = |G|\sum_P (m_P - 1)$, where $m_P$ is the
number of orbits of $k$-tuples with coincidence pattern $P$, together with the *rank
collapse* $m_P = t_{r}$ for every pattern $P$ with $r$ blocks, where $t_r$ is the number
of $G$-orbits of injective $r$-tuples. This converts the defect into the Stirling
transform $D_k = |G|\sum_{r\le k} S(k,r)(t_r - 1)$ of the *fibre spectrum* $(t_r)$, and
gives $D_k = 0$ if and only if the action is $k$-transitive.

Our main new results are:

1. **A block-graded transitivity criterion.** For $1 \le j \le k \le |X|$, all fibres over
   patterns with exactly $j$ blocks are singletons if and only if the action is
   $j$-transitive. The level-$k$ tuple data therefore resolves the whole transitivity
   hierarchy below $k$.
2. **A moment–spectrum equivalence.** For actions of two groups of equal order, the moments
   $M_j$, $j \le k$, agree if and only if the spectra $t_r$, $r \le k$, agree; the Stirling
   matrix is unitriangular, hence invertible. Consequently the spectrum is *not* a strictly
   finer invariant than the moment family — but it is strictly finer than any single moment,
   as an explicit pair of actions of a group of order $4$ with equal second moments and
   different spectra shows.
3. **Sharp quantitative propagation.** $\bigl(\sum_{r=j}^{k}S(k,r)\bigr)D_j \le B_j D_k$ for
   $j \le k \le |X|$; in particular $B_k D_2 \le 2 D_k$, with equality on every constant
   spectrum. The constant $B_k/2$ is optimal for the linear relaxation, but the extremal ray
   is not realized by any action: for $3 \le k \le |X|$ a constant spectrum forces $D_2 = 0$.
4. **Monotonicity.** $S(j,s) \le S(k,s)$ for $1 \le j \le k$, via an explicit injection of
   partitions, hence $D_j \le D_k$ for $j \le k \le |X|$.
5. **A multiplicative constraint.** $t_1^{\underline{r}} \le t_r$; in particular
   $t_1(t_1-1) \le t_2$, whence a lower bound for $D_k$ that is quadratic in the number of
   point orbits.
6. **An arithmetic certificate.** $k$-transitivity forces $|X|^{\underline{k}} \mid |G|$, so
   $|G| < |X|^{\underline{k}}$ implies $t_k \ge 2$ and $M_k \ge (B_k+1)|G|$.

**Keywords.** Burnside's lemma; Bell numbers; Stirling numbers of the second kind;
$k$-transitivity; set partitions; fixed-point moments; orbit counting.

---

## 1. Introduction

### 1.1 Motivation

Burnside's lemma, $\frac{1}{|G|}\sum_{g}|X^g| = \#(X/G)$, is the fundamental tool of
orbit enumeration. Its higher analogues, obtained by replacing $|X^g|$ with $|X^g|^k$,
have long been used ad hoc — the second moment computes the *rank* of a permutation group
(the number of orbits on ordered pairs), and higher moments compute the orbit counts of
longer tuples. What has been missing is a *structural* account: an exact identification of
the arithmetic content of $M_k$, a canonical decomposition, and quantitative inequalities
relating different values of $k$.

This paper supplies such an account. The organizing principle is that a $k$-tuple carries a
group-invariant piece of combinatorial data — the set partition of the index set recording
which coordinates coincide — and that the resulting fibration of orbits over partitions is
governed entirely by a single integer sequence.

### 1.2 Conventions

Throughout, $G$ is a finite group acting on a finite set $X$ with $n = |X|$, and
$X^g = \{x \in X : g\cdot x = x\}$. The action on $X^k$, the set of functions
$\{1,\dots,k\}\to X$, is diagonal: $(g\cdot f)(i) = g\cdot f(i)$. We write $X^k/G$ for the
orbit set and $\#S$ for cardinality. We denote by $S(k,r)$ the Stirling number of the second
kind (the number of set partitions of a $k$-set into exactly $r$ nonempty blocks), by
$B_k = \sum_{r=0}^k S(k,r)$ the $k$-th Bell number, and by
$n^{\underline{r}} = n(n-1)\cdots(n-r+1)$ the falling factorial. Recall $B_0 = B_1 = 1$,
$B_2 = 2$, $B_3 = 5$, $B_4 = 15$, $B_5 = 52$, $B_6 = 203$.

---

## 2. Patterns and the orbit–pattern fibration

### 2.1 Patterns

**Definition 2.1 (Pattern).** A *pattern* on $\{1,\dots,k\}$ is a set partition of
$\{1,\dots,k\}$. Equivalently, and in the normalized form used below, a pattern is a map
$P : \{1,\dots,k\} \to \{1,\dots,k\}$ satisfying $P(i) \le i$ and $P(P(i)) = P(i)$ for all
$i$: it sends each index to the least element of its block. The image of $P$ is the set of
*block leaders*; the **rank** $\operatorname{rank}(P)$ is the number of leaders, i.e. the
number of blocks. There are exactly $S(k,r)$ patterns of rank $r$ and $B_k$ patterns in all.

**Definition 2.2 (Kernel pattern).** For a tuple $f : \{1,\dots,k\}\to X$, the *kernel
pattern* $\ker(f)$ is the pattern whose blocks are the fibres of $f$: indices $i,j$ lie in a
common block iff $f(i) = f(j)$.

Two extreme cases will recur: the *discrete* pattern $\mathrm{id}_k$, of rank $k$, whose blocks
are singletons — it is the kernel pattern of exactly the injective tuples — and, for each
$1 \le j \le k$, the **coarsening pattern**

$$\beta_{k,j}(i) \;=\; \min(i,\, j) \qquad (1 \le i \le k),$$

which keeps $1,\dots,j-1$ apart and merges $j,\dots,k$ into a single block.

**Lemma 2.3 (Rank of the coarsening pattern).** For $1 \le j \le k$, $\beta_{k,j}$ is a
pattern of rank exactly $j$.

*Proof.* Idempotence and $\beta_{k,j}(i)\le i$ are immediate from $\min(i,j) \le i$ and
$\min(\min(i,j), j) = \min(i,j)$. The image is $\{1,2,\dots,j\}$, of cardinality $j$. $\square$

**Corollary 2.4 (No interior zeros in the Stirling triangle).** For $1 \le j \le k$ one has
$S(k,j) \ge 1$.

This apparently trivial statement is exactly what makes the block grading of Section 4
non-vacuous: each graded piece is inhabited, so a statement quantified over patterns of a
given rank has content.

**Proposition 2.5 (Boundary of the Stirling triangle).** For $k \ge 1$:
$S(k,k) = 1$, $S(k,1) = 1$, and $S(k,0) = 0$.

*Proof.* If $\operatorname{rank}(P) = k$ then every index is a leader, hence $P(i) = i$ for
all $i$ and $P$ is discrete; conversely the discrete pattern has rank $k$. If
$\operatorname{rank}(P) = 1$ then, since $1$ is always a leader ($P(1)\le 1$ forces
$P(1)=1$), the unique leader is $1$ and $P \equiv 1$, the all-merged pattern. If
$\operatorname{rank}(P) = 0$ the leader set is empty, contradicting $P(1) = 1$ being a
leader. $\square$

**Corollary 2.6 (Bell tail).** For $k \ge 1$, $\;\sum_{r=2}^{k} S(k,r) = B_k - 1$, and every
tail $\sum_{r=j}^{k} S(k,r)$ with $j \le k$ is at least $1$ (it contains $S(k,k)=1$). In
particular $B_k \ge 2$ for $k \ge 2$.

*Proof.* Split $B_k = \sum_{r=0}^{k}S(k,r)$ at $r = 0,1$ and apply Proposition 2.5. $\square$

### 2.2 The orbit–pattern map and the Bell floor

Since group elements act injectively on $X$, $\ker(g\cdot f) = \ker(f)$ for all $g$, so the
kernel pattern descends to orbits.

**Definition 2.7.** The *orbit–pattern map* is
$\pi : X^k/G \to \{\text{patterns on } \{1,\dots,k\}\}$, $\pi([f]) = \ker(f)$. For a pattern
$P$, its **fibre multiplicity** is $m_P = \#\pi^{-1}(P)$.

**Proposition 2.8 (Surjectivity).** If $k \le |X|$ then $\pi$ is surjective.

*Proof.* Given a pattern $P$ of rank $r \le k \le |X|$, choose $r$ distinct points of $X$ and
send each block of $P$ to a distinct one of them; the resulting tuple has kernel pattern
$P$. $\square$

**Theorem 2.9 (Bell floor).** For $k \le |X|$,

$$\#(X^k/G) \;\ge\; B_k, \qquad \sum_{g\in G} |X^g|^k \;\ge\; B_k\,|G| .$$

*Proof.* The first inequality is surjectivity of $\pi$ onto a set of size $B_k$. For the
second, note $|X^g|^k = \#\{f \in X^k : g\cdot f = f\}$, since $g$ fixes a tuple iff it fixes
each coordinate; Burnside's lemma for the diagonal action then gives
$\sum_g |X^g|^k = |G|\cdot\#(X^k/G)$. $\square$

**Definition 2.10 (Bell defect).**
$$D_k = D_k(G,X) \;=\; \sum_{g\in G}|X^g|^k \;-\; B_k\,|G| .$$

By Theorem 2.9 this is a nonnegative integer for $k \le |X|$; and $D_0 = 0$ always.

**Theorem 2.11 (Exact fibrewise formula).** For $k \le |X|$,

$$\sum_{g\in G}|X^g|^k \;=\; \Bigl(B_k + \sum_{P}(m_P - 1)\Bigr)|G|,
\qquad\text{i.e.}\qquad D_k \;=\; |G|\sum_{P}(m_P-1),$$

the sums running over all $B_k$ patterns on $\{1,\dots,k\}$.

*Proof.* Partitioning $X^k/G$ into the fibres of $\pi$ gives
$\#(X^k/G) = \sum_P m_P = B_k + \sum_P (m_P - 1)$, all $m_P \ge 1$ by Proposition 2.8.
Multiply by $|G|$ and apply Burnside. $\square$

---

## 3. The fibre spectrum and the Stirling expansion

**Definition 3.1 (Fibre spectrum).** For $r \ge 0$ let

$$t_r \;=\; t_r(G,X) \;=\; \#\bigl\{\text{$G$-orbits of injective $r$-tuples } \{1,\dots,r\}\hookrightarrow X\bigr\}.$$

The sequence $(t_0, t_1, t_2, \dots)$ is the *fibre spectrum* of the action.

Immediately $t_0 = 1$ (the empty tuple), and $t_1 = \#(X/G)$ is Burnside's orbit count.
In spectral form Burnside's lemma reads $t_1\,|G| = \sum_g |X^g|$.

**Theorem 3.2 (Rank collapse).** For every pattern $P$ on $\{1,\dots,k\}$ with
$\operatorname{rank}(P) = r$, one has $m_P = t_r$.

*Proof sketch.* A tuple $f$ with $\ker(f) = P$ is uniquely determined by its restriction to
the set of block leaders, which is an injective $r$-tuple, and conversely every injective
$r$-tuple extends uniquely along $P$ to a tuple with kernel pattern $P$. This bijection
between $\{f : \ker f = P\}$ and injective $r$-tuples commutes with the $G$-action (both
sides act coordinatewise), hence descends to a bijection of orbit sets. $\square$

**Corollary 3.3 (Stirling expansion).** For all $k \le |X|$,

$$\#(X^k/G) \;=\; \sum_{r=0}^{k} S(k,r)\, t_r,
\qquad
D_k \;=\; |G|\sum_{r=0}^{k} S(k,r)\,(t_r - 1).$$

*Proof.* Group patterns by rank in Theorem 2.11 and apply Theorem 3.2; there are $S(k,r)$
patterns of rank $r$, and $\sum_r S(k,r) = B_k$. $\square$

Two sanity checks. Taking $G$ trivial gives $t_r = n^{\underline{r}}$ and the classical
identity $n^k = \sum_r S(k,r)\,n^{\underline{r}}$. Taking $G$ to act $k$-transitively gives
$t_r = 1$ for all $r \le k$ and $D_k = 0$.

**Proposition 3.4 (Monotonicity of the spectrum).** For $r \le s \le |X|$, $t_r \le t_s$.

*Proof sketch.* Truncating an injective $s$-tuple to its first $r$ coordinates is a
$G$-equivariant surjection from injective $s$-tuples onto injective $r$-tuples (any injective
$r$-tuple extends, since $r < s \le |X|$), hence induces a surjection of orbit sets. $\square$

**Theorem 3.5 (Vanishing criterion).** For $k \le |X|$, $D_k = 0$ if and only if the action
is $k$-transitive, i.e. $G$ acts transitively on injective $k$-tuples.

*Proof.* By Corollary 3.3 and $t_r \ge 1$, $D_k = 0$ iff $t_r = 1$ for all $r \le k$ with
$S(k,r) > 0$; by Corollary 2.4 and Proposition 2.5 those $r$ are exactly $1,\dots,k$. Since
$t_k = 1$ says precisely that the injective $k$-tuples form one orbit, and $t_k = 1$ forces
$t_r = 1$ for $r \le k$ by Proposition 3.4, the criterion follows. $\square$

**Theorem 3.6 (Moment decomposition, no truncation).** For $k \le |X|$,
$\sum_g |X^g|^k = B_k|G| + D_k$ exactly, as an identity of nonnegative integers.

---

## 4. The block grading

The rank collapse says the fibre over $P$ depends only on $\operatorname{rank}(P)$. This
suggests grading the vanishing criterion by rank. The result is that the *level-$k$* data
resolves the entire transitivity hierarchy below $k$ — something no single moment does.

**Theorem 4.1 (Block-graded transitivity criterion).** Let $1 \le j \le k \le |X|$. Then

$$\bigl(\forall P \text{ with } \operatorname{rank}(P) = j:\; m_P = 1\bigr)
\iff \text{the action is } j\text{-transitive}.$$

*Proof.* ($\Rightarrow$) The coarsening pattern $\beta_{k,j}$ has rank $j$ (Lemma 2.3), so the
hypothesis gives $m_{\beta_{k,j}} = 1$; by the rank collapse (Theorem 3.2) $t_j = 1$, which is
$j$-transitivity. ($\Leftarrow$) If the action is $j$-transitive then $t_j = 1$, and every
pattern of rank $j$ has $m_P = t_j = 1$. $\square$

**Corollary 4.2 (Nesting of the graded criteria).** Let $1 \le i \le j \le k \le |X|$. If every
fibre over a rank-$j$ pattern is a singleton, then so is every fibre over a rank-$i$ pattern.

*Proof.* The hypothesis gives $t_j = 1$; monotonicity (Proposition 3.4) and $t_i \ge 1$ give
$t_i = 1$; apply Theorem 4.1 in the reverse direction. $\square$

Thus, reading the $k$-tuple orbit data graded by block number, one recovers for each
$j \le k$ the answer to "is the action $j$-transitive?", and the answers are automatically
nested — $j$-transitivity implies $i$-transitivity for $i \le j$ — as they must be.

### 4.1 Is the spectrum a finer invariant than the moments?

It is tempting to conjecture that the vector $(m_P)_P$ (equivalently the spectrum $(t_r)$) is
a strictly finer invariant than the scalar moments. That is false against the *family* of
moments and true against a *single* one.

**Theorem 4.3 (Moment–spectrum equivalence).** Let $G$ act on $X$ and $H$ act on $Y$, with
$|G| = |H|$, and let $k \ge 0$. Then

$$\Bigl(\forall j \le k:\; \sum_{g\in G}|X^g|^j = \sum_{h\in H}|Y^h|^j\Bigr)
\iff
\Bigl(\forall r \le k:\; t_r(G,X) = t_r(H,Y)\Bigr).$$

*Proof.* ($\Leftarrow$) Immediate from the Stirling expansion (Corollary 3.3) read forwards.
($\Rightarrow$) Strong induction on $r$. Assume $t_s(G,X) = t_s(H,Y)$ for all $s < r \le k$.
The Stirling expansions of the $r$-th moments give
$$|G|\sum_{s\le r} S(r,s)\,t_s(G,X) = |H|\sum_{s\le r}S(r,s)\,t_s(H,Y);$$
cancelling $|G| = |H| > 0$ and subtracting the equal partial sums over $s < r$ leaves
$S(r,r)\,t_r(G,X) = S(r,r)\,t_r(H,Y)$, and $S(r,r) = 1$ by Proposition 2.5. $\square$

Structurally: the Stirling matrix $\bigl(S(j,r)\bigr)_{j,r\le k}$ is lower unitriangular,
hence invertible over $\mathbb{Z}$, so the moment vector and the spectrum vector determine
each other. The spectrum contains no information the moment family lacks; what it contains
is the same information *graded*, and it is the grading (Theorem 4.1) that is useful.

**Theorem 4.4 (A single moment is strictly coarser).** There exist two actions of groups of
the same order with equal second moments and different fibre spectra. Explicitly, let $C_4$
be a cyclic group of order $4$. Then:

* the regular action of $C_4$ on itself has $|X^g| = 4$ for $g = 1$ and $|X^g| = 0$ otherwise,
  hence $\sum_g|X^g|^2 = 16$, and $t_1 = 1$;
* the trivial action of $C_4$ on a two-element set has $|X^g| = 2$ for all four elements, hence
  $\sum_g|X^g|^2 = 4\cdot 4 = 16$, and $t_1 = 2$.

The second moments agree; the spectra differ already at $t_1$.

*Proof.* For the regular action, $g\cdot x = gx$ has a fixed point iff $g = 1$, in which case
all $|G|$ points are fixed; transitivity gives $t_1 = 1$. For the trivial action every point is
fixed by every element, so $\sum_g |X^g|^k = |G|\cdot|X|^k$, and every point is its own orbit,
so $t_1 = |X| = 2$. Both second moments equal $16$. $\square$

Consistently with Theorem 4.3, the *first* moments do separate this pair: $4$ versus $8$.

---

## 5. Quantitative propagation of the defect

Failure of $j$-transitivity implies failure of $k$-transitivity for $k \ge j$; the following
makes this quantitative with explicit combinatorial constants.

**Lemma 5.1 (Upper bound at a level).** For $j \le |X|$,
$D_j \le B_j\,(t_j - 1)\,|G|$.

*Proof.* In $D_j = |G|\sum_{r\le j}S(j,r)(t_r-1)$ bound each $t_r - 1 \le t_j - 1$ using
Proposition 3.4, then $\sum_r S(j,r) = B_j$. $\square$

**Lemma 5.2 (Lower bound from a lower level).** For $j \le k \le |X|$,
$$\Bigl(\sum_{r=j}^{k} S(k,r)\Bigr)\,(t_j - 1)\,|G| \;\le\; D_k .$$

*Proof.* Restrict the sum in $D_k = |G|\sum_{r\le k}S(k,r)(t_r-1)$ to $j \le r \le k$ and use
$t_j - 1 \le t_r - 1$ there. $\square$

**Theorem 5.3 (Propagation).** For $j \le k \le |X|$,
$$\Bigl(\sum_{r=j}^{k}S(k,r)\Bigr)\, D_j \;\le\; B_j \, D_k .$$

*Proof.* Multiply Lemma 5.1 by the Stirling tail and apply Lemma 5.2:
$\bigl(\sum_{r\ge j}S(k,r)\bigr)D_j \le B_j\bigl(\sum_{r\ge j}S(k,r)\bigr)(t_j-1)|G| \le B_j D_k$. $\square$

**Corollary 5.4.** For $2 \le k \le |X|$, $\;(B_k - 1)\,D_2 \le 2\,D_k$, by Corollary 2.6 and
$B_2 = 2$. In particular $D_2 > 0 \Rightarrow D_k > 0$: a failure of $2$-transitivity
propagates, quantitatively, to every longer tuple length. Contrapositively, $k$-transitivity
for some $k \ge 2$ implies $2$-transitivity.

The constant can be improved by one unit of Bell number, using the *ordering* $t_1 \le t_2$.

**Theorem 5.5 (Sharp propagation constant).** For $2 \le k \le |X|$,
$$B_k \cdot D_2 \;\le\; 2\,D_k .$$

*Proof.* Write $a = t_1 - 1$, $b = t_2 - 1$; then $a \le b$ by Proposition 3.4. Using
$S(k,0) = 0$, $S(k,1) = 1$, $\sum_{r\ge2}S(k,r) = B_k - 1$ and $t_r \ge t_2$ for $r \ge 2$,
$$D_2 = (a+b)|G|, \qquad D_k \ge \bigl(a + (B_k-1)b\bigr)|G| .$$
It suffices that $B_k(a+b) \le 2\bigl(a+(B_k-1)b\bigr)$, i.e. $(B_k-2)a \le (B_k-2)b$, which
holds since $a \le b$ and $B_k \ge 2$. $\square$

**Proposition 5.6 (Equality on the constant ray).** If $t_1 = t_2 = \cdots = t_k$ and
$2 \le k \le |X|$, then $2 D_k = B_k D_2$.

*Proof.* With $x = t_1 - 1$ we get $D_2 = 2x|G|$ and
$D_k = x|G|\sum_{r=1}^{k}S(k,r) = x B_k |G|$. $\square$

So $B_k/2$ is the optimal constant for the *linear relaxation* in which $(t_r)$ is treated as
an arbitrary nondecreasing integer sequence: the ray $t_1 = \cdots = t_k$ is the extremal ray
of the program $\min \sum_r S(k,r)x_r$ subject to $x_1 + x_2 = 1$, $x_1 \le x_2 \le \cdots$.
The next theorem shows the ray is *fictitious*: no genuine action realizes it with $D_2 > 0$.

**Lemma 5.7 (Two point orbits force three pair orbits).** If $|X| \ge 3$ and $t_1 = 2$, then
$t_2 \ge 3$.

*Proof sketch.* Let $O_1, O_2$ be the two point orbits. The map sending an orbit of injective
pairs to the ordered pair of point orbits of its coordinates is well defined; the pairs
$(O_1,O_2)$ and $(O_2,O_1)$ are both attained, contributing two distinct orbits. Since
$|X| \ge 3$, one $O_i$ has at least two points, and an injective pair inside that orbit gives a
third orbit, mapping to $(O_i,O_i)$. $\square$

**Lemma 5.8.** If $|X| \ge 3$ and $t_1 = t_2$, then $t_1 = 1$.

*Proof.* By Theorem 6.1 below, $t_1(t_1-1) \le t_2 = t_1$, so $t_1 \le 2$. If $t_1 = 2$ then
$t_2 \ge 3 > 2 = t_1$ by Lemma 5.7, a contradiction. Hence $t_1 = 1$. $\square$

**Theorem 5.9 (The extremal ray is not realized).** Let $3 \le k \le |X|$ and suppose
$t_1 = t_2 = \cdots = t_k$. Then $D_2 = 0$.

*Proof.* $k \ge 3$ gives $|X| \ge 3$, so Lemma 5.8 yields $t_1 = 1$, hence $t_2 = 1$ and
$D_2 = |G|\bigl((t_1-1)+(t_2-1)\bigr) = 0$. $\square$

Consequently, for genuinely non-$2$-transitive actions the true propagation constant
$\inf\{2D_k/D_2\}$ is *strictly greater* than $B_k$; determining it exactly is open (Section 9).

---

## 6. Multiplicative constraints on the spectrum

All the bounds of Section 5 are linear in the spectrum. The following is genuinely
multiplicative and is the first constraint cutting the spectral cone nonlinearly.

**Theorem 6.1 (Falling-factorial bound).** For all $r \ge 0$,
$$t_1^{\underline{r}} \;=\; t_1(t_1-1)\cdots(t_1-r+1) \;\le\; t_r .$$

*Proof sketch.* Choose an ordered $r$-tuple of *pairwise distinct* point orbits — there are
$t_1^{\underline{r}}$ of them — and pick one point from each. The resulting $r$-tuple is
injective, because points in distinct orbits are distinct. Two such tuples lie in the same
$G$-orbit only if they induce the same ordered tuple of point orbits, since the orbit of a
coordinate is a $G$-invariant. Hence the assignment
$(\text{distinct orbit tuples}) \to (\text{orbits of injective } r\text{-tuples})$ is
injective. $\square$

**Corollary 6.2.** $t_1^2 \le t_2 + t_1$, i.e. $t_1(t_1-1)\le t_2$: an action with many point
orbits has quadratically many orbits of pairs.

**Theorem 6.3 (Quadratic lower bound for the defect).** For $2 \le k \le |X|$,
$$D_k \;\ge\; \Bigl[(t_1-1) + (B_k-1)\bigl(t_1(t_1-1)-1\bigr)\Bigr]\,|G| .$$

*Proof.* By $S(k,1) = 1$ and $\sum_{r\ge2}S(k,r) = B_k-1$ together with $t_r \ge t_2$ for
$r \ge 2$, one has $D_k \ge \bigl[(t_1-1) + (B_k-1)(t_2-1)\bigr]|G|$; now substitute
$t_2 \ge t_1(t_1-1)$ from Corollary 6.2. $\square$

Also useful is the closed form at the bottom of the hierarchy:

**Proposition 6.4.** For $2 \le |X|$, $\;D_2 = \bigl((t_1-1)+(t_2-1)\bigr)|G|$, since
$S(2,0)=0$, $S(2,1)=S(2,2)=1$.

---

## 7. Monotonicity in the tuple length

**Theorem 7.1 (Stirling columns are monotone).** For $1 \le j \le k$ and every $s$,
$$S(j,s) \;\le\; S(k,s).$$

*Proof.* Define an extension map on patterns: given a pattern $p$ of $\{1,\dots,j\}$, let
$\hat p$ be the pattern of $\{1,\dots,k\}$ with $\hat p(i) = p(i)$ for $i \le j$ and
$\hat p(i) = 1$ for $i > j$ — every new coordinate joins the block of $1$. Since $j \ge 1$, the
index $1$ is already a leader of $p$, so the leader set is unchanged and
$\operatorname{rank}(\hat p) = \operatorname{rank}(p)$. The map is injective, since $p$ is
recovered by restriction. Counting rank-$s$ patterns on both sides gives the claim. $\square$

The hypothesis $j \ge 1$ is necessary: $S(0,0) = 1 > 0 = S(k,0)$ for $k \ge 1$.

**Theorem 7.2 (The defect is monotone).** For $j \le k \le |X|$, $\;D_j \le D_k$.

*Proof.* For $j = 0$, $D_0 = 0$. For $j \ge 1$, compare termwise:
$$D_j = |G|\!\!\sum_{s\le j}\! S(j,s)(t_s-1) \;\le\; |G|\!\!\sum_{s\le j}\! S(k,s)(t_s-1)
\;\le\; |G|\!\!\sum_{s\le k}\! S(k,s)(t_s-1) = D_k,$$
using Theorem 7.1 for the first inequality and nonnegativity of the omitted terms for the
second. $\square$

**Corollary 7.3.** $D_j > 0 \Rightarrow D_k > 0$ for $j \le k \le |X|$: the Bell defect is a
monotone obstruction to transitivity.

---

## 8. Arithmetic certificates

The bounds so far are combinatorial. The following relates the spectrum to the *order* of
the group, giving a certificate of strict positivity that requires no orbit computation.

**Theorem 8.1 (Order bound).** If the action is $k$-transitive with $k \le |X|$, then
$$|X|^{\underline{k}} \;=\; |X|(|X|-1)\cdots(|X|-k+1) \;\;\Bigm|\;\; |G|,$$
in particular $|X|^{\underline{k}} \le |G|$.

*Proof.* Fix an injective $k$-tuple $u$. Translation preserves injectivity, and
$k$-transitivity says the orbit of $u$ is the whole set of injective $k$-tuples, of cardinality
$|X|^{\underline{k}}$. By orbit–stabiliser, this orbit length divides $|G|$. $\square$

**Corollary 8.2 (Strict violation of the Bell floor).** Let $k \le |X|$ and suppose
$|G| < |X|^{\underline{k}}$. Then $t_k \ge 2$, hence
$$\#(X^k/G) \;\ge\; B_k + 1, \qquad \sum_{g\in G}|X^g|^k \;\ge\; (B_k+1)\,|G| .$$

*Proof.* Theorem 8.1 rules out $t_k = 1$, and $t_k \ge 1$ always. By the Stirling expansion the
top term contributes $S(k,k)(t_k-1) = t_k - 1 \ge 1$ to $D_k/|G|$. $\square$

For example, a group of order $4$ acting on $4$ points has $|G| = 4 < 12 = 4^{\underline 2}$, so
it cannot be $2$-transitive and its second moment is at least $3\cdot4 = 12$; the regular action
of the cyclic group of order $4$ has $M_2 = 16$, spectrum $(1,1,3,6,6)$, and
$D_2 = 4\bigl((1-1)+(3-1)\bigr) = 8$.

---

## 9. Algorithms

All quantities above are computable from the permutation action alone.

**Algorithm A (Fibre spectrum).** Input: the list of permutations of $G$ acting on
$n$ points, and $k$. For each $r \le k$, enumerate injective $r$-tuples, maintaining a set of
already-visited tuples; for each unvisited tuple compute its $G$-orbit by applying every group
element, mark all members visited, and increment a counter. Cost:
$O\bigl(|G| \cdot n^{\underline{r}} \cdot r\bigr)$ time.

**Algorithm B (Bell defect, two ways).** Direct: compute $|X^g|$ for each $g$ and form
$\sum_g |X^g|^k - B_k|G|$, in $O(|G|\,n)$ time plus the cost of $B_k$. Spectral: compute the
Stirling row $S(k,\cdot)$ by the recurrence $S(k,r) = r\,S(k-1,r) + S(k-1,r-1)$ in $O(k^2)$
time, then $D_k = |G|\sum_r S(k,r)(t_r-1)$. Agreement of the two is a strong consistency check
on the whole theory, and is the check performed in the numerical section.

**Algorithm C (Graded transitivity profile).** For $j = 1,\dots,k$: compute $t_j$ by Algorithm
A and report "$j$-transitive" iff $t_j = 1$. By Theorem 4.1 this is equivalent to testing whether
every fibre over a rank-$j$ pattern is a singleton, which can also be done directly by
enumerating orbits of $k$-tuples and bucketing them by kernel pattern — a useful cross-check,
at cost $O(|G|\,n^k\,k)$.

**Algorithm D (Certificate search).** Given $|G|$ and $n$, compute $n^{\underline{k}}$ by
repeated multiplication and report a certificate of $D_k > 0$ whenever $|G| < n^{\underline{k}}$
(Corollary 8.2), at cost $O(k)$ arithmetic operations and *no* group computation at all.

---

## 10. Worked examples

Let $S_4$, $A_4$, $C_4$ (regular), $V_4$ (regular), and the trivial group on $3$ points act as
indicated. The following table lists the spectrum $(t_0,\dots,t_4)$ and the defects.

| action | $\lvert G\rvert$ | $\lvert X\rvert$ | $(t_0,\dots)$ | $D_1$ | $D_2$ | $D_3$ | $D_4$ |
|---|---|---|---|---|---|---|---|
| $S_4$ on $4$ points | $24$ | $4$ | $(1,1,1,1,1)$ | $0$ | $0$ | $0$ | $0$ |
| $A_4$ on $4$ points | $12$ | $4$ | $(1,1,1,2,2)$ | $0$ | $0$ | $12$ | $84$ |
| $C_4$ regular | $4$ | $4$ | $(1,1,3,6,6)$ | $0$ | $8$ | $44$ | $196$ |
| $V_4$ regular | $4$ | $4$ | $(1,1,3,6,6)$ | $0$ | $8$ | $44$ | $196$ |
| trivial group on $3$ points | $1$ | $3$ | $(1,3,6,6,\cdot)$ | $2$ | $7$ | $22$ | — |

Reading the $A_4$ row: the action is $3$-transitive? No — $t_3 = 2$, so it is $2$-transitive but
not $3$-transitive, exactly as the graded criterion predicts (the rank-$3$ fibres have
multiplicity $2$, the rank-$1$ and rank-$2$ fibres are singletons). The defect
$D_3 = 12\bigl(S(3,3)(2-1)\bigr) = 12$ matches $M_3 - B_3|G| = 72 - 60 = 12$.

Reading the $C_4$ row: $D_3 = 4\bigl(S(3,2)\cdot 2 + S(3,3)\cdot 5\bigr) = 4(6+5) = 44$, and
directly $M_3 = 4^3 = 64$, $B_3|G| = 20$.

The propagation bound at $k = 4$ for $C_4$ reads $B_4 D_2 = 15\cdot 8 = 120 \le 2 D_4 = 392$:
comfortably satisfied and, per Theorem 5.9, necessarily strict.

Note that $C_4$ and $V_4$ have identical spectra and hence identical moment sequences,
illustrating that these invariants do not distinguish non-isomorphic groups — they are
invariants of the *action's orbit structure on tuples*, nothing more.

---

## 11. Discussion

### 11.1 What the theory buys

Three things. First, **exactness**: $D_k$ is not an estimate but an integer counting extra
orbits per coincidence pattern, and it vanishes precisely at $k$-transitivity. Second,
**gradedness**: because multiplicities depend only on the block number, the level-$k$ data
splits into $k$ independent tests, one per level of the transitivity hierarchy. Third,
**rigidity**: the whole apparatus is a Stirling transform, so moving between the "analytic"
side (moments) and the "combinatorial" side (spectrum) is a unitriangular change of basis and
loses nothing.

### 11.2 The limits of the invariant

Theorem 4.3 is a genuine negative result: refining a moment into a vector of multiplicities
does not create information, because the refinement is invertible. Any hoped-for separation
theorem for the spectrum must therefore be a statement about *one* moment (Theorem 4.4) or
about actions of groups of *different* orders. Likewise Theorem 5.9 warns that optimizing over
the spectral cone defined only by monotonicity overshoots: the extremal configurations of the
relaxation are not actions. The multiplicative constraint of Theorem 6.1 is the first correction
to the cone, and there is every reason to expect more.

### 11.3 Relation to classical facts

Specializing $k = 1$ recovers Burnside's lemma. Specializing to the trivial group recovers the
classical identity $n^k = \sum_r S(k,r)n^{\underline{r}}$, so the Stirling expansion is a
$G$-equivariant deformation of that identity, with the falling factorials replaced by orbit
counts. Theorem 8.1 is the standard divisibility constraint on multiply transitive groups,
recovered here as a statement about the top of the spectrum, and Corollary 8.2 converts it into
a quantitative lower bound on a moment.

---

## 12. Future directions

**The true propagation constant.** Define
$c_k^{\mathrm{grp}} = \inf\{2D_k/D_2\}$ over all finite actions with $2 \le k \le |X|$ and
$D_2 > 0$. Theorem 5.9 shows $c_k^{\mathrm{grp}} > B_k$. Since the extremal ray of the linear
relaxation is now excluded, the infimum should be governed by the next face of the cone, the one
cut out by $t_1^{\underline{r}} \le t_r$. Minimizing $\sum_r S(k,r)(t_r - 1)$ subject to
monotonicity *and* the falling-factorial constraint is a finite optimization for each $k$; we
conjecture the infimum is attained by the trivial action on $k$ points.

**A full multiplicative hierarchy.** We conjecture that for $r+s \le |X|$ the spectrum satisfies
$t_{r+s} \ge t_r\,(t_s - r)$, and more precisely that $t_{r+s}$ is at least $t_r$ times the number
of orbits of injective $s$-tuples avoiding a fixed $r$-set. Theorem 6.1 is the case $s = 1$,
iterated. Such a hierarchy would cut the spectral cone much closer to the set of actual actions.

**Realizability.** Which nondecreasing integer sequences $(t_r)_{r\le k}$ with $t_0 = 1$ arise as
fibre spectra of a finite action on $n \ge k$ points? Monotonicity, the falling-factorial bound,
and the order bound $t_k \ge n^{\underline{k}}/|G|$ are necessary; a complete characterization is
open even for $k = 3$.

**Beyond a single action.** Theorem 4.3 shows that the spectrum and the moment family coincide as
invariants for groups of equal order. Dropping the equal-order hypothesis, or comparing *pairs* of
actions of the same group (as in the theory of permutation characters and Gassmann equivalence),
should produce a strictly richer separation theory in which the graded criterion of Theorem 4.1
plays the role of a fine invariant.

**Asymptotics.** Since $B_k$ grows superexponentially, Theorem 5.5 says a single unit of
$2$-defect is amplified enormously with $k$. Making the growth rate of $D_k$ into an asymptotic
invariant of the action — a "transitivity entropy" $\lim_k \frac{1}{k}\log(D_k/|G|)$ — appears
tractable via the Stirling expansion and the monotonicity of $(t_r)$.

---

## Appendix: the identity in one line

For a finite group $G$ acting on a finite set $X$ with $k \le |X|$:

$$\sum_{g\in G}\bigl|X^g\bigr|^k
\;=\;\Bigl(B_k \;+\; \sum_{P \,\vdash\, \{1,\dots,k\}}\bigl(m_P - 1\bigr)\Bigr)\,|G|
\;=\;\Bigl(\sum_{r=0}^{k} S(k,r)\, t_r\Bigr)|G| ,$$

with $m_P = t_{\operatorname{rank}P}$, $t_r$ the number of orbits of injective $r$-tuples, and
equality with the Bell floor $B_k|G|$ exactly when the action is $k$-transitive.
