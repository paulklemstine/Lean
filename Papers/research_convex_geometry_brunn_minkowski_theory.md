# The One-Dimensional Brunn–Minkowski Inequality: A Corner-Anchoring Proof for Compact Sets

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Convex Geometry / Geometric Measure Theory

## Abstract

We present a complete, self-contained development of the one-dimensional
Brunn–Minkowski inequality for compact subsets of the real line. For nonempty
compact sets $A, B \subseteq \mathbb{R}$ equipped with Lebesgue measure
$\operatorname{vol}$, we prove

$$\operatorname{vol}(A) + \operatorname{vol}(B) \;\le\; \operatorname{vol}(A + B),$$

where $A + B = \{a + b : a \in A,\, b \in B\}$ is the Minkowski sum. This is
exactly the $n = 1$ instance of the classical Brunn–Minkowski inequality
$\operatorname{vol}(A+B)^{1/n} \ge \operatorname{vol}(A)^{1/n} +
\operatorname{vol}(B)^{1/n}$, since the exponent $1/n$ collapses to $1$ in
dimension one. The proof is elementary and geometric: it places a translate of
$A$ flush against the right extreme of $A+B$ and a translate of $B$ flush against
the left extreme, observes that these two translates intersect in at most a single
point, and applies the inclusion–exclusion identity for measures. We isolate every
ingredient as a named lemma — translation invariance of volume, the two
sub-additivity inclusions, and the single-point intersection bound — and assemble
them into the main theorem. We discuss sharpness (intervals achieve equality),
the conjectural equality-rigidity statement, and a program of extensions:
the multiplicative convex-combination form, the higher-dimensional box case, the
$\sqrt{\cdot}$-concavity reformulation, and the discrete Cauchy–Davenport
analogue.

## 1. Introduction

The Brunn–Minkowski inequality is among the most consequential results in
geometry. In its general form it asserts that for nonempty compact sets
$A, B \subseteq \mathbb{R}^n$,

$$\operatorname{vol}_n(A + B)^{1/n} \;\ge\; \operatorname{vol}_n(A)^{1/n}
   + \operatorname{vol}_n(B)^{1/n}. \tag{BM}$$

Equivalently, the functional $A \mapsto \operatorname{vol}_n(A)^{1/n}$ is concave
with respect to Minkowski averaging on the class of convex bodies. From (BM) flow
the isoperimetric inequality, the classical theorem of Brunn on the concavity of
the root cross-sectional-area function of a convex body, the Prékopa–Leindler
functional inequality, the entropy power inequality of information theory, and —
through its discrete shadow — the Cauchy–Davenport theorem of additive
combinatorics.

In dimension $n = 1$ the exponent $1/n = 1$, and (BM) reduces to the clean
*additive* statement

$$\operatorname{vol}(A) + \operatorname{vol}(B) \;\le\; \operatorname{vol}(A + B),
   \tag{BM1}$$

where $\operatorname{vol}$ denotes one-dimensional Lebesgue measure (length). This
paper gives a rigorous, fully formalized proof of (BM1) for nonempty compact
$A, B \subseteq \mathbb{R}$, together with the supporting lemmas. While (BM1) is
classical, the value of the present treatment is its complete
machine-verifiable decomposition into reusable components and its emphasis on the
*corner-anchoring* mechanism, which is the cleanest finite-dimensional witness for
why Minkowski addition is super-additive on measures.

### 1.1 Notation and conventions

Throughout, $\mathbb{R}$ carries the Borel $\sigma$-algebra and Lebesgue measure,
denoted $\operatorname{vol}$ (the Lean `volume`). Measures take values in the
extended nonnegative reals $[0, +\infty]$; all the additions below are valid in
this complete ordered monoid, and no finiteness hypotheses are needed (although
compact sets automatically have finite measure). For sets $A, B \subseteq
\mathbb{R}$ and a scalar $c$, we write

$$A + B = \{a + b : a \in A,\, b \in B\}, \qquad
  A + \{b\} = \{a + b : a \in A\}, \qquad
  \{a\} + B = \{a + b : b \in B\}.$$

A set is **compact** iff it is closed and bounded. A nonempty compact subset of
$\mathbb{R}$ attains its supremum and infimum.

## 2. Definitions and preliminary structure

**Definition 2.1 (Minkowski sum).** For $A, B \subseteq \mathbb{R}$, the Minkowski
sum is $A + B = \{a + b : a \in A,\, b \in B\}$. Translation by a point $t$ is the
special case $A + \{t\}$.

**Definition 2.2 (Lebesgue volume).** $\operatorname{vol}(E)$ denotes the
Lebesgue measure of a measurable set $E \subseteq \mathbb{R}$, valued in
$[0, +\infty]$.

We rely on three standard facts about $(\mathbb{R}, +, \operatorname{vol})$:

1. **Translation invariance.** $\operatorname{vol}$ is invariant under the additive
   group action: $\operatorname{vol}(E + \{t\}) = \operatorname{vol}(E)$ for every
   $t$.
2. **Monotonicity.** $E \subseteq F \implies \operatorname{vol}(E) \le
   \operatorname{vol}(F)$.
3. **Inclusion–exclusion.** For measurable $U, V$,
   $\operatorname{vol}(U \cup V) + \operatorname{vol}(U \cap V) =
   \operatorname{vol}(U) + \operatorname{vol}(V)$.

Compactness of $A$ and $B$ enters in exactly two places: it guarantees the
attained extremes $\sup A \in A$ and $\inf B \in B$ used to construct the anchored
translates, and it ensures the relevant sets are measurable (the Minkowski sum of
compact sets is compact, hence Borel).

## 3. Supporting lemmas

We now state the four lemmas that constitute the proof. Each is elementary; their
combination is the whole argument.

**Lemma 3.1 (Right-translation invariance of volume; `translate_volume`).**
For every $A \subseteq \mathbb{R}$ and $b \in \mathbb{R}$,

$$\operatorname{vol}(A + \{b\}) = \operatorname{vol}(A).$$

*Proof sketch.* The map $x \mapsto x + b$ is a measure-preserving bijection of
$\mathbb{R}$; $A + \{b\}$ is the image of $A$ under it. Concretely,
$A + \{b\} = \{x : x - b \in A\}$ is the preimage of $A$ under $x \mapsto x - b$,
and Lebesgue measure is invariant under such shifts. $\qquad\blacksquare$

**Lemma 3.2 (Left-translation invariance of volume; `translate_volume'`).**
For every $B \subseteq \mathbb{R}$ and $a \in \mathbb{R}$,

$$\operatorname{vol}(\{a\} + B) = \operatorname{vol}(B).$$

*Proof sketch.* Identical to Lemma 3.1 with the roles symmetrized:
$\{a\} + B = \{x : x - a \in B\}$ is the preimage of $B$ under the
measure-preserving translation $x \mapsto x - a$. $\qquad\blacksquare$

**Lemma 3.3 (Containment of anchored translates; `subset_left`, `subset_right`).**
If $b \in B$ then $A + \{b\} \subseteq A + B$; symmetrically, if $a \in A$ then
$\{a\} + B \subseteq A + B$.

*Proof sketch.* Monotonicity of the Minkowski sum: $A + B$ is order-preserving in
each argument under inclusion. Since $\{b\} \subseteq B$ we get
$A + \{b\} \subseteq A + B$, and since $\{a\} \subseteq A$ we get
$\{a\} + B \subseteq A + B$. $\qquad\blacksquare$

**Lemma 3.4 (Single-point intersection bound; `inter_singleton_bound`).**
Let $A, B \subseteq \mathbb{R}$ be nonempty compact, and put $a = \sup A$,
$b = \inf B$. Then

$$\bigl(A + \{b\}\bigr) \cap \bigl(\{a\} + B\bigr) \;\subseteq\; \{a + b\}.$$

*Proof sketch.* Take $x$ in the intersection. From $x \in A + \{b\}$ we may write
$x = a' + b$ with $a' \in A$; since $a = \sup A$ is an upper bound, $a' \le a$, so
$x \le a + b$. From $x \in \{a\} + B$ we may write $x = a + b'$ with $b' \in B$;
since $b = \inf B$ is a lower bound, $b' \ge b$, so $x \ge a + b$. Combining,
$x = a + b$. $\qquad\blacksquare$

The geometric content of Lemma 3.4 is the crux: the translate $A + b$ lives
entirely *at or below* the value $a + b$, while the translate $a + B$ lives
entirely *at or above* $a + b$. They are pressed against each other from opposite
sides and can share only the seam point $a + b$, a set of length zero.

## 4. The main theorem

**Theorem 4.1 (One-dimensional Brunn–Minkowski; `brunn_minkowski_1d`).**
Let $A, B \subseteq \mathbb{R}$ be nonempty and compact. Then

$$\operatorname{vol}(A) + \operatorname{vol}(B) \;\le\; \operatorname{vol}(A + B).$$

*Proof.* Since $A$ is nonempty and compact it attains its supremum: there is
$a = \sup A$ with $a \in A$. Since $B$ is nonempty and compact it attains its
infimum: there is $b = \inf B$ with $b \in B$. Define the two anchored translates

$$U = A + \{b\}, \qquad V = \{a\} + B.$$

**Step 1 (both translates lie in the sum).** Because $b \in B$ and $a \in A$,
Lemma 3.3 gives $U \subseteq A + B$ and $V \subseteq A + B$, hence

$$U \cup V \subseteq A + B. \tag{4.1}$$

**Step 2 (the translates barely overlap).** By Lemma 3.4,

$$U \cap V \subseteq \{a + b\}. \tag{4.2}$$

**Step 3 (inclusion–exclusion).** The translate $V = \{a\} + B$ is measurable
(the Minkowski sum of the compact singleton $\{a\}$ with the compact set $B$ is
compact, hence Borel), so the modular identity applies:

$$\operatorname{vol}(U \cup V) + \operatorname{vol}(U \cap V)
   = \operatorname{vol}(U) + \operatorname{vol}(V). \tag{4.3}$$

In particular $\operatorname{vol}(U) + \operatorname{vol}(V) \le
\operatorname{vol}(U \cup V) + \operatorname{vol}(U \cap V)$.

**Step 4 (monotonicity).** Apply monotonicity of $\operatorname{vol}$ to (4.1) and
(4.2):

$$\operatorname{vol}(U \cup V) \le \operatorname{vol}(A + B), \qquad
  \operatorname{vol}(U \cap V) \le \operatorname{vol}(\{a + b\}) = 0.$$

Chaining through (4.3),

$$\operatorname{vol}(U) + \operatorname{vol}(V)
   \le \operatorname{vol}(U \cup V) + \operatorname{vol}(U \cap V)
   \le \operatorname{vol}(A + B) + 0.$$

**Step 5 (translation invariance).** By Lemmas 3.1 and 3.2,
$\operatorname{vol}(U) = \operatorname{vol}(A)$ and
$\operatorname{vol}(V) = \operatorname{vol}(B)$. Substituting,

$$\operatorname{vol}(A) + \operatorname{vol}(B) \le \operatorname{vol}(A + B).
   \qquad\blacksquare$$

**Remark 4.2 (why compactness).** The proof uses compactness only to obtain the
*attained* extremes $\sup A \in A$ and $\inf B \in B$ (so that the anchored
translates lie inside $A + B$) and to ensure measurability of the sets involved.
The inequality extends to broader classes (e.g. nonempty bounded measurable sets,
via inner regularity), but the compact case is the cleanest and the one formalized
here.

**Remark 4.3 (this is the $n=1$ Brunn–Minkowski).** Writing the general
inequality as $\operatorname{vol}(A+B)^{1/n} \ge \operatorname{vol}(A)^{1/n} +
\operatorname{vol}(B)^{1/n}$ and setting $n = 1$ gives precisely Theorem 4.1, since
$t^{1/1} = t$. Thus (BM1) is not a weakening but the exact one-dimensional case.

## 5. Sharpness and equality

**Proposition 5.1 (intervals are sharp).** If $A = [a_1, a_2]$ and
$B = [b_1, b_2]$ are nonempty compact intervals then $A + B = [a_1 + b_1,
a_2 + b_2]$, so

$$\operatorname{vol}(A + B) = (a_2 + b_2) - (a_1 + b_1)
   = (a_2 - a_1) + (b_2 - b_1)
   = \operatorname{vol}(A) + \operatorname{vol}(B).$$

*Proof sketch.* The sum of two intervals is the interval spanned by the sums of
their endpoints: the minimum reachable value is $a_1 + b_1$, the maximum is
$a_2 + b_2$, and convexity of intervals fills in everything between. The length
computation is immediate. $\qquad\blacksquare$

Thus Theorem 4.1 is best possible: the constant $1$ in front of each term cannot
be improved, and equality is attained on intervals. Conjecturally the converse
also holds (see C2 in Section 7): up to a Lebesgue-null adjustment, equality in
(BM1) forces both $A$ and $B$ to be intervals (or one to be a single point). The
failure of equality for non-intervals is easy to witness: with $A = [0,1] \cup
[3,4]$ (length $2$) and $B = [0,1]$ (length $1$) one has $A + B = [0,2] \cup [3,5]$
of length $4 > 3$.

## 6. Algorithmic content

Although Theorem 4.1 is a statement about arbitrary compact sets, its proof is
*constructive* on the class of finite unions of intervals, and this yields exact
numerical verification routines.

**Algorithm A (canonical-form length of a finite union of intervals).** Represent
a set as a finite list of closed intervals; merge overlapping/touching intervals
into disjoint canonical form by sorting endpoints and sweeping; sum the lengths.
Complexity $O(m \log m)$ for $m$ intervals.

**Algorithm B (Minkowski sum of interval unions).** For $A = \bigcup_i I_i$ and
$B = \bigcup_j J_j$, use distributivity $A + B = \bigcup_{i,j} (I_i + J_j)$, where
$[p,q] + [r,s] = [p+r,\, q+s]$; then canonicalize via Algorithm A. Complexity
$O(mn \log(mn))$ for $m, n$ intervals.

Together these let one compute $\operatorname{vol}(A)$, $\operatorname{vol}(B)$,
and $\operatorname{vol}(A+B)$ exactly (in rational arithmetic) and confirm the
inequality, the corner-anchoring construction $U, V$, and the strictness of the
gap for non-intervals. The accompanying demonstrations implement exactly these
routines.

## 7. Future directions

The following are concrete, testable conjectures extending the present result.

**C1. Multiplicative (dimension-free) 1-D form.** For nonempty compact
$A, B \subseteq \mathbb{R}$ and $t \in [0,1]$,
$\operatorname{vol}(tA + (1-t)B) \ge t\operatorname{vol}(A) + (1-t)\operatorname{vol}(B)$.
This is the convex-combination ("Prékopa–Leindler at $n=1$") restatement; it
follows from Theorem 4.1 via the scaling identity
$\operatorname{vol}(cA) = |c|\operatorname{vol}(A)$. Sanity check: $A=B=[0,1]$,
$t = 1/2$ gives $\operatorname{vol}[0,1] = 1 = 1$.

**C2. Equality rigidity in 1-D.** For nonempty compact $A, B$, equality
$\operatorname{vol}(A+B) = \operatorname{vol}(A) + \operatorname{vol}(B)$ holds iff
(up to a null set) both $A$ and $B$ are intervals (or one is a single point). The
forward "interval $\Rightarrow$ equality" direction is Proposition 5.1; the
converse requires a no-positive-measure-gap analysis. Falsifiable on
$A = [0,1] \cup [3,4]$, where equality fails.

**C3. Dimension-2 Brunn–Minkowski for axis-aligned boxes.** For boxes
$A = I_1 \times I_2$, $B = J_1 \times J_2 \subseteq \mathbb{R}^2$,
$\operatorname{vol}(A+B)^{1/2} \ge \operatorname{vol}(A)^{1/2} +
\operatorname{vol}(B)^{1/2}$. Since $A + B = (I_1 + J_1) \times (I_2 + J_2)$, this
reduces to the AM–GM-type inequality $\sqrt{(a+c)(b+d)} \ge \sqrt{ab} + \sqrt{cd}$
for nonnegative side lengths. This is the first genuinely $n > 1$ case.

**C4. The $\sqrt{\cdot}$-superadditivity (concavity) reformulation.** The map
$A \mapsto \operatorname{vol}(A)^{1/n}$ is concave under Minkowski averaging on
nonempty compact convex bodies. In $n=1$ it is exactly Theorem 4.1 (the exponent
is trivial); the $n=2$ box case (C3) is the inductive seed toward general $n$ via
products over coordinates.

**C5. Discrete (Cauchy–Davenport-flavored) analogue.** For nonempty finite
$A, B \subseteq \mathbb{Z}$, $|A + B| \ge |A| + |B| - 1$, with equality iff
$A, B$ are arithmetic progressions with equal common difference. The counting
bound mirrors the measure proof — overlap $A + \min B$ and $\max A + B$ at one
point — and bridges continuous Brunn–Minkowski theory to additive combinatorics.

## 8. Discussion

The corner-anchoring proof is a microcosm of the general theory. In every known
proof of (BM) — Hadwiger–Ohmann's induction, the transport/Knothe–Brenier
approach, the Prékopa–Leindler route — the essential phenomenon is that Minkowski
addition cannot compress measure, only spread it. The one-dimensional case strips
this to its essence: two translates, anchored at opposite extremes, touching at a
single point of measure zero. Everything downstream — isoperimetry, entropy power,
sumset growth — is a sophisticated elaboration of "spreading wins." Formalizing
the base case as a clean, reusable lemma cluster (translation invariance, the
containment inclusions, the single-point bound, and their assembly) provides a
verified foundation on which the higher-dimensional and discrete extensions of
Section 7 can be built.

## References

The Brunn–Minkowski inequality and its consequences are classical; this paper is
self-contained and the proof above depends only on the three measure-theoretic
facts itemized in Section 2 (translation invariance, monotonicity, and
inclusion–exclusion for Lebesgue measure on $\mathbb{R}$).
