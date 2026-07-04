# A Multi-Kernel Support Law for Sidon Sets: Exact Difference-Set Cardinality and a Sharp Characterization

## Abstract

A finite set of integers is a *Sidon set* (or $B_2$ set) if all of its pairwise sums are distinct. We study the additive structure of such sets through a pair of convolution kernels — the sum kernel and the difference kernel — and establish an exact support law for the difference side. Our main results are twofold. First, for a nonempty Sidon set $s$ of cardinality $k$, the difference set attains the maximal possible size,
$$|s - s| = k^2 - k + 1, \qquad \text{equivalently} \qquad |s - s| + k = k^2 + 1.$$
Second, this extremal identity *characterizes* the Sidon property: a nonempty finite set of integers is Sidon **if and only if** its difference set has cardinality $k^2 - k + 1$. Both statements factor through a single structural equivalence — a set is Sidon precisely when the ordered-difference map is injective on the off-diagonal — after which the cardinalities follow from elementary counting. Combined with the classical sum-side identity $2\,|s+s| = k(k+1)$, we obtain a linear conservation law relating the two kernels, $2\,|s+s| = |s-s| + 2k - 1$. We discuss algorithmic detection of the Sidon property in $O(k^2)$ time, applications to autocorrelation-flat signal design and difference families, and a stability program measuring the deficit $k^2 - k + 1 - |s-s|$ as a quantitative distance to Sidon.

**Keywords:** Sidon set, $B_2$ set, difference set, correlation kernel, additive combinatorics, additive energy, conservation law.

## 1. Introduction

Sidon sets, introduced by Simon Sidon in the 1930s in connection with lacunary Fourier series, are among the most fundamental objects in additive combinatorics. A finite set $s \subseteq \mathbb{Z}$ is a *Sidon set* if the equation $a + b = c + d$ with $a,b,c,d \in s$ forces $\{a,b\} = \{c,d\}$; equivalently, all differences of distinct elements are pairwise distinct. Such sets are the extremal objects for a variety of counting problems: they have the fewest possible repeated sums, the smallest possible additive energy, and — as we make precise here — the largest possible difference set.

Modern treatments approach the additive structure of a set $s$ through its *representation kernels*. The **sum kernel** is the autoconvolution
$$r^{+}_s(x) = (\mathbf{1}_s * \mathbf{1}_s)(x) = \#\{(a,b) \in s \times s : a + b = x\},$$
and the **difference kernel** is the autocorrelation
$$r^{-}_s(x) = (\mathbf{1}_s \star \mathbf{1}_s)(x) = \#\{(a,b) \in s \times s : a - b = x\}.$$
The supports of these two kernels are the sumset $s + s = \{a+b : a,b \in s\}$ and the difference set $s - s = \{a - b : a,b \in s\}$. Together the pair $(r^{+}_s, r^{-}_s)$ constitutes a *multi-kernel* description of $s$: the sum kernel governs sumset size and additive energy, while the difference kernel — the focus of this paper — governs the geometry of pairwise gaps.

The classical theory pins down the sum side. For a Sidon set of size $k$, the $\binom{k}{2}$ sums of distinct pairs and the $k$ diagonal sums $2a$ are all distinct, giving
$$|s + s| = \binom{k}{2} + k = \frac{k(k+1)}{2}, \qquad \text{i.e.} \qquad 2\,|s+s| = k(k+1). \tag{1}$$
The difference side has received comparatively less attention as an *exact* extremal identity, despite being equally natural: a flat difference kernel is exactly what makes Sidon sets valuable in signal design. This paper supplies the missing exact law and, more importantly, shows that it is *sharp enough to characterize* the Sidon property.

### Contributions

1. **Exact difference-set cardinality (Theorem 4.1).** For a nonempty Sidon set of size $k$, $|s-s| = k^2 - k + 1$.
2. **Sharp characterization (Theorem 4.2).** A nonempty finite set is Sidon iff $|s-s| = k^2 - k + 1$.
3. **Conservation law (Corollary 4.3).** Combining with (1), $2\,|s+s| = |s-s| + 2k - 1$ for every nonempty Sidon set.
4. **An $O(k^2)$ detection algorithm** built directly on the characterization, and a stability/deficit framework.

## 2. Definitions

Throughout, $s$ denotes a finite subset of $\mathbb{Z}$ and $k = |s|$ its cardinality.

**Definition 2.1 (Sidon set).** A finite set $s \subseteq \mathbb{Z}$ is a *Sidon set* if for all $a,b,c,d \in s$,
$$a + b = c + d \implies a = c \ \text{or}\ a = d.$$
This is the additive $B_2$ condition: every integer has at most one representation as an unordered sum of two elements of $s$.

**Definition 2.2 (Difference set and sumset).** The *difference set* and *sumset* of $s$ are
$$s - s = \{a - b : a, b \in s\}, \qquad s + s = \{a + b : a, b \in s\}.$$

**Definition 2.3 (Off-diagonal and the difference map).** The *off-diagonal* of $s$ is
$$s^{\ne} = \{(a,b) \in s \times s : a \ne b\},$$
which has cardinality $k^2 - k$. The *difference map* is
$$\delta : \mathbb{Z} \times \mathbb{Z} \to \mathbb{Z}, \qquad \delta(a,b) = a - b.$$

We record two elementary facts about $\delta$ that we use repeatedly.

**Lemma 2.4 (No zeros off the diagonal).** For every $(a,b) \in s^{\ne}$, $\delta(a,b) \ne 0$. Consequently $0 \notin \delta(s^{\ne})$.

*Proof.* $\delta(a,b) = a - b = 0$ iff $a = b$, which is excluded on the off-diagonal. $\square$

**Lemma 2.5 (Decomposition of the difference set).** For any nonempty $s$,
$$s - s = \{0\} \cup \delta(s^{\ne}),$$
and the union is disjoint.

*Proof.* If $x \in s - s$, write $x = a - b$ with $a,b \in s$. If $a = b$ then $x = 0$; otherwise $(a,b) \in s^{\ne}$ and $x \in \delta(s^{\ne})$. Conversely $0 = c - c$ for any $c \in s$ (using nonemptiness), and every element of $\delta(s^{\ne})$ is visibly a difference. Disjointness is Lemma 2.4. $\square$

Taking cardinalities in Lemma 2.5 and using disjointness gives the pivotal bookkeeping identity
$$|s - s| = |\delta(s^{\ne})| + 1. \tag{2}$$

## 3. The structural equivalence

The engine behind every result in this paper is the following reformulation of the Sidon property in terms of a single injectivity statement.

**Theorem 3.1 (Sidon $\Leftrightarrow$ injective difference map).** A finite set $s \subseteq \mathbb{Z}$ is Sidon if and only if the difference map $\delta$ is injective on the off-diagonal $s^{\ne}$.

*Proof.* $(\Rightarrow)$ Suppose $s$ is Sidon and let $(a,b), (c,d) \in s^{\ne}$ with $\delta(a,b) = \delta(c,d)$, i.e. $a - b = c - d$. Rearranging gives $a + d = c + b$. Applying the Sidon condition to $a + d = c + b$ yields $a = c$ or $a = b$. The second is impossible since $(a,b)$ is off-diagonal, so $a = c$; then $a - b = c - d$ forces $b = d$. Hence $(a,b) = (c,d)$, proving injectivity.

$(\Leftarrow)$ Suppose $\delta$ is injective on $s^{\ne}$, and let $a,b,c,d \in s$ satisfy $a + b = c + d$. We must show $a = c$ or $a = d$. If $a = d$ we are done, so assume $a \ne d$. If $c = b$, then $a + b = c + d$ becomes $a + b = b + d$, so $a = d$, a contradiction; hence $c \ne b$. Now $(a,d)$ and $(c,b)$ both lie in $s^{\ne}$, and from $a + b = c + d$ we get $a - d = c - b$, i.e. $\delta(a,d) = \delta(c,b)$. Injectivity gives $(a,d) = (c,b)$, so in particular $a = c$. $\square$

Theorem 3.1 explains two design choices that are otherwise easy to get wrong. First, injectivity must be asserted on the *off-diagonal* rather than the full square $s \times s$: the diagonal always collapses to the single value $0$ under $\delta$, so $\delta$ is never injective on $s \times s$ when $k \ge 2$. Second, nonemptiness will be required for the cardinality statements because the decomposition (2) inserts the value $0$, which the empty set does not produce.

## 4. Main results

**Theorem 4.1 (Maximal difference-set cardinality).** Let $s \subseteq \mathbb{Z}$ be a nonempty Sidon set with $k = |s|$. Then
$$|s - s| + k = k^2 + 1, \qquad \text{equivalently} \qquad |s - s| = k^2 - k + 1.$$

*Proof.* By Theorem 3.1, $\delta$ is injective on $s^{\ne}$, so it preserves cardinality of that set under image:
$$|\delta(s^{\ne})| = |s^{\ne}| = k^2 - k.$$
Substituting into the bookkeeping identity (2),
$$|s - s| = |\delta(s^{\ne})| + 1 = (k^2 - k) + 1 = k^2 - k + 1.$$
Adding $k$ to both sides gives $|s-s| + k = k^2 + 1$. $\square$

The quantity $k^2 - k + 1$ is the *maximum* difference-set size for any $k$-element set: the difference set always contains $0$ and at most $k^2 - k$ nonzero values (one per ordered pair of distinct elements), so $|s-s| \le k^2 - k + 1$ unconditionally. Theorem 4.1 says Sidon sets meet this bound exactly. The converse makes the bound diagnostic.

**Theorem 4.2 (Characterization by extremal difference set).** Let $s \subseteq \mathbb{Z}$ be nonempty with $k = |s|$. Then $s$ is Sidon if and only if
$$|s - s| + k = k^2 + 1, \qquad \text{i.e.} \qquad |s - s| = k^2 - k + 1.$$

*Proof.* The forward direction is Theorem 4.1. For the converse, assume $|s-s| = k^2 - k + 1$. By the bookkeeping identity (2), $|\delta(s^{\ne})| = |s-s| - 1 = k^2 - k = |s^{\ne}|$. A map whose image has the same (finite) cardinality as its domain is injective; hence $\delta$ is injective on $s^{\ne}$, and by Theorem 3.1 the set $s$ is Sidon. $\square$

The proof of the converse is worth emphasizing: it recovers a genuinely structural property (Sidon) from a single scalar equation (a cardinality). The equivalence is not vacuous — it is a full-strength characterization, with the deficit
$$D(s) = (k^2 - k + 1) - |s - s| \ge 0$$
serving as an exact obstruction: $D(s) = 0$ iff $s$ is Sidon, and $D(s)$ counts the collapse of the difference map's image, i.e. the number of coincidences $a - b = c - d$ among distinct pairs (up to fiber structure).

**Corollary 4.3 (Sum–difference conservation law).** For every nonempty Sidon set $s$ of size $k$,
$$2\,|s + s| = |s - s| + 2k - 1.$$

*Proof.* Classically (1), $2\,|s+s| = k(k+1) = k^2 + k$. By Theorem 4.1, $|s-s| = k^2 - k + 1$, so $|s-s| + 2k - 1 = k^2 + k = 2\,|s+s|$. $\square$

The conservation law expresses a rigidity of the multi-kernel pair: for Sidon sets, the sizes of the sum and difference supports are not independent but are tied by a single linear identity. Equivalently, $|s+s| - |s-s|/2$ is a fixed affine function of $k$.

### Worked example

Let $s = \{1, 2, 4, 8\}$, so $k = 4$. One checks directly that all six pairwise differences of distinct elements are distinct, so $s$ is Sidon. The difference set is
$$s - s = \{0, \pm 1, \pm 2, \pm 3, \pm 4, \pm 6, \pm 7\}, \qquad |s-s| = 13 = 4^2 - 4 + 1,$$
confirming Theorem 4.1. The sumset is $s + s = \{2,3,4,5,6,8,9,10,12,16\}$ with $|s+s| = 10 = \tfrac{4\cdot 5}{2}$, and the conservation law reads $2 \cdot 10 = 13 + 2\cdot 4 - 1 = 20$. By contrast, the consecutive set $\{1,2,3,4\}$ (also $k=4$) has $s - s = \{0,\pm1,\pm2,\pm3\}$, so $|s-s| = 7$, giving deficit $D = 13 - 7 = 6 \ne 0$; Theorem 4.2 certifies it is not Sidon.

## 5. Algorithms

The characterization (Theorem 4.2) converts Sidon detection — a priori a search over $O(k^4)$ quadruples — into a single cardinality comparison computable in $O(k^2)$ time.

**Algorithm A (Difference-set Sidon test).** Given $s$ with $k = |s|$:
1. Compute the multiset of all $k^2$ ordered differences $a - b$.
2. Insert them into a hash set $D$; let $m = |D|$.
3. Return `Sidon` iff $m = k^2 - k + 1$.

Correctness is immediate from Theorem 4.2. The cost is $O(k^2)$ time and $O(k^2)$ space. An equivalent early-terminating variant inserts *nonzero* differences one at a time and reports `not Sidon` upon the first collision, which is asymptotically the same but faster in practice on non-Sidon inputs.

**Algorithm B (Deficit and collision profile).** Compute $D(s) = (k^2 - k + 1) - |s-s|$ and, for each value $x \in s - s$, the fiber size $r^-_s(x)$. The deficit measures distance to Sidon; the fiber-size histogram is the *difference kernel* itself and exposes which gaps are over-represented. This is the raw material for the stability program of Section 7.

## 6. Applications

**Autocorrelation-flat signal design.** The difference kernel $r^{-}_s$ is exactly the (aperiodic) autocorrelation of the indicator sequence of $s$. Sidon sets are precisely those whose off-zero autocorrelation is everywhere $\le 1$, i.e. whose autocorrelation is maximally flat. This is the design goal for radar/sonar pulse-position patterns and frequency-hopping schedules, where a shifted copy of the signal should never strongly resemble the original. Theorem 4.2 gives a single-count certificate that a candidate pattern has this property.

**Difference families and combinatorial design.** Difference sets and families are foundational in design theory and finite geometry. The extremal identity $|s-s| = k^2 - k + 1$ marks the top of the hierarchy of "how spread out" a difference set can be over the integers, and the characterization identifies exactly the configurations achieving it.

**Additive energy.** The additive energy $E(s) = \sum_x r^{-}_s(x)^2 = \sum_x r^{+}_s(x)^2$ counts additive quadruples. Sidon sets minimize energy: $E(s) = k^2 + 2\binom{k}{2}\cdot 1$ collapses to the diagonal contribution plus one for each off-diagonal fiber, i.e. $E(s) = 2k^2 - k$ for a Sidon set, the minimum over $k$-element sets. The deficit $D(s)$ and the excess energy $E(s) - (2k^2 - k)$ are two linear readouts of the same fiber-size distribution.

## 7. Discussion and future work

The results form the $h = 2$ base case of a broader program on the support laws of $B_h$ sets and their kernels. We highlight three directions.

**Higher-order support laws for $B_h$ sets.** A set is a $B_h$ set when every integer has at most one representation as an unordered sum of $h$ elements; Sidon sets are $h=2$. We conjecture that every $B_h$ set has an $h$-fold difference set whose cardinality is an explicit degree-$h$ polynomial in $k$, and that the family of $h$-fold sum and difference kernels obeys a single linear conservation identity whose correction terms are governed entirely by the degenerate (repeated-coordinate) configurations. The mechanism is the same as here: injectivity of a single representation map on the non-degenerate configurations, with corrections supplied by lower-dimensional degenerate strata counted by inclusion–exclusion. The clean $h=2$ stratification argument is ready to be lifted to all $h$.

**The conservation law modulo $n$ and perfect difference sets.** In a cyclic group $\mathbb{Z}/n\mathbb{Z}$ the difference kernel can wrap around, so the integer count $k^2 - k + 1$ may collapse. Singer perfect difference sets are the opposite extreme, with a perfectly flat difference kernel covering the whole group exactly once. We conjecture that modulo $n$ the conservation law deforms into a corrected identity whose defect term counts precisely the wrap-around collisions, and that the defect vanishes exactly for translates of perfect difference sets. The modular defect is itself an additive-energy quantity, so the counting law becomes an energy identity in the finite setting; the exact integer identity supplies the baseline against which the defect is measured.

**Stability: near-Sidon sets and the difference-set deficit.** Since $|s-s| \le k^2 - k + 1$ always, with equality iff Sidon, the deficit $D(s)$ is a natural distance-to-Sidon. We conjecture that $D(s)$ tightly controls the number of additive collisions, so that a set with small deficit is quantitatively close to Sidon and can be repaired into a genuine Sidon set by deleting a number of elements proportional to $D(s)$. The deficit and the collision count are two linear readouts of the same distribution of difference-map fiber sizes, so controlling one controls the other. The exact extremal count and its equality characterization provide the rigid baseline from which such stability estimates can be launched.

## 8. Conclusion

We have shown that the difference kernel of a Sidon set is maximally spread: its support attains the exact size $k^2 - k + 1$, and this extremal identity is not merely a consequence but a *characterization* of the Sidon property. Paired with the classical sum-side identity, it yields a linear conservation law binding the sum and difference kernels. All of this flows from one structural equivalence — Sidon means the difference map is injective off the diagonal — turning a quadruple-quantified condition into a single count computable in quadratic time. The framework, its extremal count, and its stability deficit set the stage for higher-order ($B_h$), modular, and quantitative refinements.
