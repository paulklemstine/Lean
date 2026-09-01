# Sheet Numbers and Relative Trivialisations of Coverings

**Author:** Aristotle
**Date:** 2026-09-01

## Abstract

We develop a *relative* theory of even coverings. For a map $f : E \to X$ of topological spaces we study the **sheet number** $\mathrm{sh}_f(x) := \#\,f^{-1}(x)$, defined as a natural number with the convention that empty and infinite fibres both receive the value $0$. Our first group of results establishes the rigidity of this invariant on the locus where $f$ is a covering map: being evenly covered with a fixed fibre is an open condition on the base point; consequently the sheet number is locally constant on any set $S$ over which $f$ is a covering map, it is both lower and upper semicontinuous at every point of $S$, it is continuous into the discrete natural numbers, and it is constant whenever $S$ is preconnected. Running the same argument on the proposition "the fibre is nonempty" rather than on its cardinality yields a **dichotomy**: over a preconnected set on which $f$ is a covering map, either every fibre is empty or every fibre is nonempty — in particular, a covering over a connected base that hits one point is surjective.

Our second and principal contribution is the **relative trivialisation theorem**. The standard definition of an evenly covered point produces *some* trivialising neighbourhood, with no control over its location; in applications one has committed in advance to an open region $U$ of the base and needs the trivialisation to live inside $U$. We introduce the notion of a **sheet system** over a set $V \subseteq X$ indexed by a set $\iota$: a family of partial homeomorphisms $\varphi_i : E \rightharpoonup X$ with open sources, all with target exactly $V$, each agreeing with $f$ on its source, with pairwise disjoint sources whose union is $f^{-1}(V)$. We prove that sheet systems restrict along open subsets of the base *without changing the index set*, that they can be reindexed along bijections, and that they can be built explicitly from any abstract even covering. Combining these gives: if $f$ is a covering map on an open $U$ and $x \in U$, there exists an open $V$ with $x \in V \subseteq U$ carrying a sheet system indexed by the fibre $f^{-1}(x)$. Conversely, a sheet system over an open $V$ exhibits every point of $V$ as evenly covered by its own fibre, with no topology on the index set required. We obtain a clean characterisation: for open $U$, $f$ is a covering map on $U$ if and only if every point of $U$ has an open neighbourhood inside $U$ over which $f$ admits a sheet system. We discuss the specialisation to piecewise-linear and polyhedral (tropical) maps, where sheet systems are supplied directly by the cell structure and the characterisation becomes a finite combinatorial check.

**Keywords:** covering map, evenly covered neighbourhood, sheet number, local trivialisation, semicontinuity, locally constant function, piecewise-linear map, tropical geometry.

---

## 1. Introduction

### 1.1 The problem

Let $f : E \to X$ be a map of topological spaces. The simplest invariant attached to a point $x \in X$ is the cardinality of its fibre $f^{-1}(x)$. In general this invariant is wildly discontinuous: the squaring map $\mathbb{C} \to \mathbb{C}$ has a fibre of size $1$ over the origin and of size $2$ everywhere else; a polynomial family acquires and loses roots as parameters vary; a projection of a polyhedral complex has fibre counts that jump across walls.

The class of maps for which the fibre count is rigid is the class of *covering maps*, and the mechanism is entirely local. Recall the classical definition.

**Definition 1.1 (Evenly covered point).** Let $I$ be a topological space. A point $x \in X$ is *evenly covered by $f$ with fibre $I$* if there is an open set $U \subseteq X$ with $x \in U$ such that $f^{-1}(U)$ is open in $E$, together with a homeomorphism
$$H : f^{-1}(U) \;\xrightarrow{\ \sim\ }\; U \times I$$
satisfying $\pi_U \circ H = f$ on $f^{-1}(U)$, where $\pi_U$ is the first projection. In applications $I$ is discrete.

**Definition 1.2 (Relative covering map).** For $S \subseteq X$, the map $f$ is a *covering map on $S$* if every $x \in S$ is evenly covered by $f$ with some discrete fibre.

Two features of Definition 1.1 create friction in practice.

1. **The neighbourhood is not under our control.** The definition asserts existence of *some* $U$. If a construction or a hypothesis is only valid on a prescribed open region $U_0$, the trivialising $U$ may spill outside $U_0$, and the trivialisation cannot be used verbatim.
2. **The trivialisation is an abstract homeomorphism.** For gluing, for computation, and for combinatorial models, one wants a concrete finite (or indexed) list of open pieces upstairs, each equipped with a genuine inverse map, rather than a single opaque isomorphism onto a product.

The purpose of this paper is to remove both frictions, and to record the rigidity consequences of the local picture in the precise forms in which they are used.

### 1.2 Results

Section 2 develops the sheet number and its rigidity: openness of the even-covering condition (Theorem 2.3), local constancy (Theorem 2.7), constancy on preconnected sets (Theorem 2.8), the two-sided semicontinuity package and continuity into the discrete integers (Theorems 2.9–2.11), and the fibre dichotomy (Theorem 2.12).

Section 3 introduces sheet systems (Definition 3.1) and derives their basic calculus: injectivity and surjectivity of $f$ on each sheet (Propositions 3.3, 3.4), the sheetwise detection of openness (Proposition 3.5), and the fact that a sheet system over an open base exhibits even coverings, both with the given index set and, intrinsically, with the fibre itself (Theorems 3.6, 3.7), whence constancy of the sheet number over the base (Corollary 3.8).

Section 4 constructs sheet systems from abstract even coverings (Theorem 4.2) and proves the restriction theorem (Theorem 4.3) and the reindexing lemma (Lemma 4.4).

Section 5 assembles these into the relative trivialisation theorem (Theorem 5.1) and the resulting characterisation of relative covering maps by sheet decompositions (Theorem 5.2).

Section 6 specialises to piecewise-linear and polyhedral maps and describes the algorithms that the characterisation supports. Sections 7 and 8 discuss applications, limitations, and future directions.

### 1.3 Conventions

All maps are between topological spaces; no separation, local connectedness, or local compactness hypotheses are imposed anywhere. "Preconnected" means the space cannot be separated by two open sets meeting it in disjoint nonempty subsets whose union covers it; unlike "connected", a preconnected set may be empty. A *partial homeomorphism* $\varphi : E \rightharpoonup X$ consists of an open *source* $\Sigma \subseteq E$, an open *target* $T \subseteq X$, and mutually inverse continuous bijections between them; we write $\varphi$ also for the induced map on the source and $\varphi^{-1}$ for its inverse defined on $T$.

The **cardinality convention** matters. We define $\mathrm{sh}_f(x)$ to be the natural number $\#\,f^{-1}(x)$, where an infinite set is assigned the value $0$. Thus $\mathrm{sh}_f(x) = 0$ means "the fibre is empty or infinite". This is a bookkeeping choice which makes the invariant $\mathbb{N}$-valued and hence available for semicontinuity statements; the loss of information at $0$ is exactly compensated by the dichotomy of Theorem 2.12, which tracks emptiness separately and is insensitive to finiteness.

---

## 2. The sheet number and its rigidity

**Definition 2.1 (Sheet number).** For $f : E \to X$ and $x \in X$,
$$\mathrm{sh}_f(x) \;:=\; \#\, f^{-1}(x) \in \mathbb{N},$$
with the convention above.

The following elementary observation is the source of every result in this section.

**Lemma 2.2 (Fibres of an even covering).** If $x$ is evenly covered with fibre $I$, via $H : f^{-1}(U) \cong U \times I$, then for every $y \in U$ the restriction of $H$ induces a bijection $f^{-1}(y) \cong \{y\} \times I \cong I$.

*Proof.* Since $\pi_U \circ H = f$, a point $e \in f^{-1}(U)$ lies in $f^{-1}(y)$ exactly when $H(e) \in \{y\}\times I$; and $f^{-1}(y) \subseteq f^{-1}(U)$ because $y \in U$. As $H$ is a bijection onto $U \times I$, it restricts to a bijection $f^{-1}(y) \to \{y\}\times I$. $\square$

**Theorem 2.3 (Even covering is an open condition).** If $x$ is evenly covered by $f$ with fibre $I$, then every point of some neighbourhood of $x$ is evenly covered by $f$ with the *same* fibre $I$. Formally, $\{y : y \text{ is evenly covered with fibre } I\}$ contains an open neighbourhood of $x$.

*Proof.* Let $U, H$ witness even covering at $x$. For any $y \in U$ the *same* data $U, H$ witness even covering at $y$: the only clause of Definition 1.1 that mentions the point is "$x \in U$", and $y \in U$ holds by assumption. Since $U$ is open and contains $x$, the assertion is a statement about a neighbourhood of $x$. $\square$

Theorem 2.3 is trivial to prove and decisive in effect: it upgrades a pointwise hypothesis into a neighbourhood-wide one at no cost, and every subsequent theorem is a corollary of it applied to a suitable invariant.

**Corollary 2.4 (Sheet number of an evenly covered point).** If $x$ is evenly covered with fibre $I$, then $\mathrm{sh}_f(x) = \# I$.

*Proof.* Immediate from Lemma 2.2 and the invariance of cardinality under bijection. $\square$

**Corollary 2.5 (Nonemptiness of an evenly covered fibre).** If $x$ is evenly covered with fibre $I$, then $f^{-1}(x) \ne \emptyset$ if and only if $I \ne \emptyset$.

*Proof.* Again by the bijection $f^{-1}(x) \cong I$ of Lemma 2.2, explicitly: given $e \in f^{-1}(x)$ the second component of $H(e)$ is an element of $I$; given $i \in I$ the point $H^{-1}(x, i)$ lies in $f^{-1}(x)$. $\square$

**Proposition 2.6 (Local invariance).** If $x$ is evenly covered with fibre $I$, then:
1. $\mathrm{sh}_f(y) = \mathrm{sh}_f(x)$ for all $y$ in a neighbourhood of $x$;
2. $\big(f^{-1}(y) \ne \emptyset \iff f^{-1}(x) \ne \emptyset\big)$ for all $y$ in a neighbourhood of $x$.

*Proof.* By Theorem 2.3 there is a neighbourhood on each point of which $f$ is evenly covered with fibre $I$. On that neighbourhood, Corollary 2.4 gives $\mathrm{sh}_f(y) = \#I = \mathrm{sh}_f(x)$, and Corollary 2.5 gives $f^{-1}(y) \ne \emptyset \iff I \ne \emptyset \iff f^{-1}(x) \ne \emptyset$. $\square$

We now fix a subset $S \subseteq X$ and assume throughout that $f$ is a covering map on $S$.

**Theorem 2.7 (Local constancy).** Let $f$ be a covering map on $S$ and $x \in S$. Then $\mathrm{sh}_f(y) = \mathrm{sh}_f(x)$ for all $y$ in a neighbourhood of $x$ in $X$. Consequently the restriction $\mathrm{sh}_f|_S : S \to \mathbb{N}$ is locally constant.

*Proof.* The first claim is Proposition 2.6(1) applied to the even covering at $x$ furnished by the hypothesis. For the second, local constancy of a function on the subspace $S$ is equivalent to the statement that around every point of $S$ the function is eventually constant along the neighbourhood filter of $S$; the inclusion $S \hookrightarrow X$ is continuous, so the eventual equality in $X$ pulls back to eventual equality in $S$. $\square$

**Theorem 2.8 (Constancy on preconnected sets).** Let $f$ be a covering map on a preconnected set $S$. Then for all $x, y \in S$, $\mathrm{sh}_f(x) = \mathrm{sh}_f(y)$.

*Proof.* $S$ with the subspace topology is a preconnected space, and by Theorem 2.7 the function $\mathrm{sh}_f|_S$ is locally constant on it. A locally constant function on a preconnected space is constant: the preimage of any value is open, as is the preimage of its complement, and these two open sets partition $S$; preconnectedness forces one of them to be empty. Apply this to the value $\mathrm{sh}_f(x)$. $\square$

The two one-sided forms are separately useful.

**Theorem 2.9 (Lower semicontinuity).** Let $f$ be a covering map on $S$ and $x \in S$. Then $\mathrm{sh}_f$ is lower semicontinuous at $x$: for every $n < \mathrm{sh}_f(x)$ one has $n < \mathrm{sh}_f(y)$ for all $y$ in a neighbourhood of $x$.

**Theorem 2.10 (Upper semicontinuity).** Under the same hypotheses, for every $n > \mathrm{sh}_f(x)$ one has $n > \mathrm{sh}_f(y)$ for all $y$ in a neighbourhood of $x$.

**Theorem 2.11 (Continuity).** Under the same hypotheses, $\mathrm{sh}_f$ is continuous at $x$, where $\mathbb{N}$ carries the discrete topology.

*Proof of 2.9–2.11.* All three follow from Theorem 2.7. For 2.9, take the neighbourhood on which $\mathrm{sh}_f(y) = \mathrm{sh}_f(x)$ and rewrite the strict inequality. For 2.10, symmetrically. For 2.11, the constant net at $\mathrm{sh}_f(x)$ converges to $\mathrm{sh}_f(x)$, and $\mathrm{sh}_f$ agrees with it on a neighbourhood, so the two have the same limit along the neighbourhood filter of $x$. $\square$

**Remark.** Constancy implies all three, so as *theorems about the covering locus* they carry no extra content. Their value is that they are the *stable* half of the phenomenon and remain meaningful where constancy fails. In the presence of degeneration, one-sided estimates typically survive on one side only: fibre counts of algebraic maps are lower semicontinuous under perturbation away from the covering locus (roots split), while fibre counts of proper maps are upper semicontinuous (roots collide but do not appear from nowhere). The theorems above delimit precisely the region where both hold, and record the local input in the two shapes a global argument will want to consume.

**Theorem 2.12 (Fibre dichotomy).** Let $f$ be a covering map on a preconnected set $S$. Then exactly one of the following holds unless $S = \emptyset$ (in which case both hold vacuously):
1. $f^{-1}(x) = \emptyset$ for every $x \in S$;
2. $f^{-1}(x) \ne \emptyset$ for every $x \in S$.

*Proof.* Consider the function
$$P : S \to \{\text{true}, \text{false}\}, \qquad P(y) := \big(f^{-1}(y) \ne \emptyset\big),$$
with the two-element codomain discrete. By Proposition 2.6(2), around each $y \in S$ the truth value $P$ is constant on a neighbourhood — indeed, on the trivialising neighbourhood the value equals "$I \ne \emptyset$", independently of the point. Hence $P$ is locally constant on the preconnected space $S$, so it is constant.

If $S = \emptyset$ then alternative (1) holds vacuously. Otherwise pick $x_0 \in S$. If $f^{-1}(x_0) \ne \emptyset$ then $P \equiv \text{true}$, which is alternative (2); if $f^{-1}(x_0) = \emptyset$ then $P \equiv \text{false}$, which is alternative (1). $\square$

**Corollary 2.13 (All-or-nothing surjectivity).** If $f$ is a covering map on a connected set $S$ and $f^{-1}(x_0) \ne \emptyset$ for some $x_0 \in S$, then $S \subseteq f(E)$.

Corollary 2.13 is the workhorse form: it converts a single witness into global surjectivity, and it is the reason that lifting arguments over connected bases are possible at all.

**Remark (sharpness).** Preconnectedness cannot be dropped. Let $X = \{0, 1\}$ discrete, $E = \{\ast\}$, and $f(\ast) = 0$. Then $f$ is a covering map on $X$ (over $\{0\}$ the preimage is a single point, over $\{1\}$ it is empty, and both are products with a discrete fibre of size $1$ resp. $0$), the sheet number is $1$ at $0$ and $0$ at $1$, and neither alternative of the dichotomy holds on $X$. Both theorems hold on each of the two connected components separately.

---

## 3. Sheet systems

We now make the local picture concrete.

**Definition 3.1 (Sheet system).** Let $f : E \to X$, let $V \subseteq X$, and let $\iota$ be a set. A **sheet system** for $f$ over $V$ indexed by $\iota$ consists of a family $(\varphi_i)_{i \in \iota}$ of partial homeomorphisms $E \rightharpoonup X$, with sources $\Sigma_i := \mathrm{dom}(\varphi_i)$ (open in $E$) and targets $T_i := \mathrm{ran}(\varphi_i)$ (open in $X$), subject to:

- **(S1) Common target.** $T_i = V$ for every $i \in \iota$.
- **(S2) Restriction of $f$.** $\varphi_i(e) = f(e)$ for every $i$ and every $e \in \Sigma_i$.
- **(S3) Disjointness.** $\Sigma_i \cap \Sigma_j = \emptyset$ whenever $i \ne j$.
- **(S4) Exhaustion.** $\bigcup_{i \in \iota} \Sigma_i = f^{-1}(V)$.

We call $\Sigma_i$ the $i$-th **sheet** and $\varphi_i^{-1} : V \to \Sigma_i$ the $i$-th **section**.

Axiom (S1) forces $V$ to be open whenever $\iota \ne \emptyset$; when $\iota = \emptyset$, axiom (S4) forces $f^{-1}(V) = \emptyset$ and $V$ may be arbitrary. In statements where openness of $V$ is needed we assume it explicitly, so that the empty-index case is covered uniformly.

The definition is deliberately *unstructured in the index*: $\iota$ is a bare set, carrying no topology. One of the payoffs below is that this costs nothing.

**Example 3.2.** (a) For $f(t) = e^{2\pi i t}$ from $\mathbb{R}$ to the unit circle and $V$ the arc $\{e^{2\pi i \theta} : \theta \in (0, 1)\}$, the sheets are the intervals $\Sigma_n = (n, n+1)$, $n \in \mathbb{Z}$, with $\varphi_n = f|_{\Sigma_n}$ and $\varphi_n^{-1}(e^{2\pi i \theta}) = n + \theta$. (b) For $f(z) = z^n$ on the unit circle and $V$ a proper open arc, the sheets are the $n$ preimage arcs. (c) For a piecewise-affine $f : \mathbb{R} \to \mathbb{R}$ and $V$ an open interval containing no critical value, the sheets are the maximal open intervals on which $f$ is affine and $f$-image contains $V$, intersected with $f^{-1}(V)$.

Throughout this section, let $S = (\varphi_i)_{i\in\iota}$ be a sheet system for $f$ over $V$.

**Proposition 3.3 (Injectivity on sheets).** For each $i$, $f$ is injective on $\Sigma_i$.

*Proof.* Let $a, b \in \Sigma_i$ with $f(a) = f(b)$. By (S2), $\varphi_i(a) = f(a) = f(b) = \varphi_i(b)$, and $\varphi_i$ is injective on its source. $\square$

**Proposition 3.4 (Surjectivity onto the base).** For each $i$ and each $y \in V$, the point $\varphi_i^{-1}(y)$ lies in $\Sigma_i$ and satisfies $f(\varphi_i^{-1}(y)) = y$. Hence $f(\Sigma_i) = V$.

*Proof.* By (S1), $y$ lies in the target of $\varphi_i$, so $e := \varphi_i^{-1}(y) \in \Sigma_i$. By (S2) and the inverse property, $f(e) = \varphi_i(e) = y$. $\square$

Thus each sheet maps *bijectively* onto $V$ under $f$; the sheets are honest, complete copies of $V$ sitting inside $E$, and by (S3), (S4) they partition $f^{-1}(V)$. In particular, for every $y \in V$ the map $i \mapsto \varphi_i^{-1}(y)$ is a bijection $\iota \to f^{-1}(y)$: it lands in the fibre by Proposition 3.4, it is injective by (S3), and it is surjective by (S4) combined with Proposition 3.3.

**Proposition 3.5 (Sheetwise detection of openness).** Fix $i \in \iota$ and let $W \subseteq V$. Then
$$W \text{ is open in } X \iff f^{-1}(W) \cap \Sigma_i \text{ is open in } E.$$

*Proof.* By (S1), $W$ is contained in the target of $\varphi_i$. The key identity is
$$\varphi_i^{-1}(W) \;=\; f^{-1}(W) \cap \Sigma_i .$$
Indeed, for a partial homeomorphism the preimage of $W$ under $\varphi_i^{-1}$ (equivalently, the image of $W$ under the inverse) equals $\Sigma_i \cap \varphi_i^{-1}(W)$ as sets of points of the source, and on the source $\varphi_i$ agrees with $f$ by (S2), so $\varphi_i^{-1}(W) = \Sigma_i \cap f^{-1}(W)$. Now $\varphi_i$ is a homeomorphism from $\Sigma_i$ (open in $E$) onto its target (open in $X$); hence a subset of the target is open exactly when its inverse image in the source is open. Applying this to $W$ gives the equivalence. $\square$

Proposition 3.5 is the technical mechanism turning a sheet system into a genuine local trivialisation: it says the topology of $V$ is faithfully reproduced by each sheet.

**Theorem 3.6 (A sheet system exhibits even coverings).** Suppose $V$ is open and $S$ is a sheet system for $f$ over $V$ indexed by $\iota$; give $\iota$ the discrete topology. Then every $x \in V$ is evenly covered by $f$ with fibre $\iota$.

*Proof.* If $\iota = \emptyset$ then by (S4) $f^{-1}(V) = \emptyset$, and the even covering at $x$ is witnessed by $U := V$ together with the unique (empty) homeomorphism $\emptyset \cong V \times \emptyset$.

If $\iota \ne \emptyset$, define $H : f^{-1}(V) \to V \times \iota$ by $H(e) = (f(e), i)$ where $i$ is the unique index with $e \in \Sigma_i$; uniqueness and existence are (S3) and (S4). Its inverse is $(y, i) \mapsto \varphi_i^{-1}(y)$, well defined by Proposition 3.4. Compatibility with $f$ is immediate: the first component of $H(e)$ is $f(e)$.

It remains to check that $H$ is a homeomorphism, and this is exactly the content of the data: the sheets $\Sigma_i$ are open and disjoint with union $f^{-1}(V)$ (so $f^{-1}(V)$ is open in $E$, and a subset of it is open iff its trace on each $\Sigma_i$ is open); $f$ is injective on each $\Sigma_i$ (Proposition 3.3) and maps it onto $V$ (Proposition 3.4); and openness is detected sheetwise (Proposition 3.5). These four facts are precisely the hypotheses of the standard construction of a trivialisation with discrete fibre from a disjoint open decomposition of the preimage, and they produce a homeomorphism $f^{-1}(V) \cong V \times \iota$ over $V$ whose base set is $V$. Since $x \in V$, the point $x$ is evenly covered. $\square$

The next theorem removes the index set from the statement.

**Theorem 3.7 (Intrinsic indexing).** Suppose $V$ is open and $f$ admits a sheet system over $V$ indexed by *any* set $\iota$. Then every $x \in V$ is evenly covered by $f$ with fibre $f^{-1}(x)$, given the discrete topology.

*Proof.* Equip $\iota$ with the discrete topology and apply Theorem 3.6: $x$ is evenly covered with fibre $\iota$. By Lemma 2.2 the fibre $f^{-1}(x)$ is in bijection with $\iota$, and this bijection is a homeomorphism because both sides are discrete ($f^{-1}(x)$ is discrete as a subspace, since the trivialisation identifies it with $\{x\}\times\iota$). Transporting the trivialisation along it exhibits $x$ as evenly covered with fibre $f^{-1}(x)$. $\square$

Theorem 3.7 explains why the absence of a topology on $\iota$ in Definition 3.1 is harmless: whatever labelling one used, the geometry only ever sees the fibre.

**Corollary 3.8 (Sheet number over the base of a sheet system).** If $V$ is open and $f$ admits a sheet system over $V$ indexed by $\iota$, then $\mathrm{sh}_f(x) = \#\iota$ for every $x \in V$.

*Proof.* Theorem 3.6 and Corollary 2.4. $\square$

---

## 4. Construction, restriction, reindexing

### 4.1 Building sheets from an abstract trivialisation

**Construction 4.1 (Sheet charts of an even covering).** Let $U \subseteq X$ be open with $f^{-1}(U)$ open, let $I$ be discrete, and let $H : f^{-1}(U) \to U \times I$ be a homeomorphism with $\pi_U \circ H = f$. For $i \in I$ define
$$\Sigma_i \;:=\; \{ e \in f^{-1}(U) \;:\; \pi_I(H(e)) = i \}, \qquad \varphi_i := f|_{\Sigma_i}, \qquad \varphi_i^{-1}(y) := H^{-1}(y, i)\ (y \in U).$$

**Theorem 4.2 (Existence of sheet systems at evenly covered points).** With the data of Construction 4.1, $(\varphi_i)_{i\in I}$ is a sheet system for $f$ over $U$ indexed by $I$. Consequently, if $x$ is evenly covered with fibre $I$, then there is an open $V \ni x$ over which $f$ admits a sheet system indexed by $I$.

*Proof sketch.* Each $\Sigma_i$ is the preimage under the continuous map $\pi_I \circ H$ of the open (because $I$ is discrete) singleton $\{i\}$, then pushed forward along the open inclusion $f^{-1}(U) \hookrightarrow E$; since $f^{-1}(U)$ is open, $\Sigma_i$ is open in $E$.

*Source and target.* $\varphi_i$ maps $\Sigma_i$ into $U$ because $\Sigma_i \subseteq f^{-1}(U)$. Conversely, for $y \in U$ the point $H^{-1}(y, i)$ lies in $\Sigma_i$ and has $f$-image $y$, by the compatibility $\pi_U \circ H = f$. So the target is exactly $U$, giving (S1).

*Mutual inversion.* For $e \in \Sigma_i$ we have $H(e) = (f(e), i)$ — the first coordinate by compatibility, the second by definition of $\Sigma_i$ — hence $H^{-1}(f(e), i) = e$, i.e. $\varphi_i^{-1}(\varphi_i(e)) = e$. For $y \in U$, $f(H^{-1}(y,i)) = \pi_U(H(H^{-1}(y,i))) = y$, i.e. $\varphi_i(\varphi_i^{-1}(y)) = y$.

*Continuity.* $\varphi_i$ is continuous on $\Sigma_i$ because on $f^{-1}(U)$ it factors as $e \mapsto \pi_U(H(e))$, a composite of continuous maps. Its inverse is continuous because it factors as $y \mapsto H^{-1}(y, i)$ followed by the inclusion of $f^{-1}(U)$ in $E$.

*(S2)* holds by construction ($\varphi_i$ *is* a restriction of $f$). *(S3)*: if $e \in \Sigma_i \cap \Sigma_j$ then $\pi_I(H(e))$ equals both $i$ and $j$, so $i = j$. *(S4)*: any $e \in f^{-1}(U)$ lies in $\Sigma_i$ for $i := \pi_I(H(e))$, and conversely every $\Sigma_i$ is contained in $f^{-1}(U)$.

For the final statement, take $U$ and $H$ from the even covering at $x$ and set $V := U$; when $I = \emptyset$ the preimage $f^{-1}(U)$ is empty and the empty family is a sheet system over $U$. $\square$

### 4.2 Restriction: the relative step

This is the technical heart of the paper. It is what converts a trivialisation over an uncontrolled neighbourhood into a trivialisation over a neighbourhood we choose.

**Theorem 4.3 (Restriction of sheet systems).** Let $(\varphi_i)_{i\in\iota}$ be a sheet system for $f$ over $V$, and let $W \subseteq X$ be open. Define $\psi_i := \iota_W \circ \varphi_i$, where $\iota_W$ is the partial homeomorphism of $X$ given by the identity on $W$; explicitly, $\psi_i$ is $\varphi_i$ with source $\Sigma_i \cap f^{-1}(W)$ and target $W \cap V$. Then $(\psi_i)_{i\in\iota}$ is a sheet system for $f$ over $W \cap V$, indexed by the **same** set $\iota$.

*Proof.* Write $\Sigma_i' := \mathrm{dom}(\psi_i)$. Composition of partial homeomorphisms yields a partial homeomorphism, so each $\psi_i$ is one; we verify the four axioms.

*Source identification.* By definition of composition, $\Sigma_i' = \Sigma_i \cap \varphi_i^{-1}(W)$, and by (S2) for $\varphi_i$ this equals $\Sigma_i \cap f^{-1}(W)$: for $e \in \Sigma_i$ we have $\varphi_i(e) \in W \iff f(e) \in W$.

*(S1).* The target of the composite is the image under $\iota_W$ of $W \cap T_i = W \cap V$, i.e. $W \cap V$, using (S1) for $\varphi_i$.

*(S2).* For $e \in \Sigma_i'$ we have $\psi_i(e) = \iota_W(\varphi_i(e)) = \varphi_i(e) = f(e)$, the last step by (S2) for $\varphi_i$ and $e \in \Sigma_i$.

*(S3).* $\Sigma_i' \subseteq \Sigma_i$, so disjointness is inherited: for $i \ne j$, $\Sigma_i' \cap \Sigma_j' \subseteq \Sigma_i \cap \Sigma_j = \emptyset$.

*(S4).* Using the source identification and distributivity of intersection over unions,
$$\bigcup_i \Sigma_i' \;=\; \Big(\bigcup_i \Sigma_i\Big) \cap f^{-1}(W) \;=\; f^{-1}(V) \cap f^{-1}(W) \;=\; f^{-1}(V \cap W) \;=\; f^{-1}(W \cap V). \qquad \square$$

Two features deserve emphasis.

* **The index set is unchanged.** Shrinking the base neither loses nor duplicates sheets. This is what makes the construction composable: restricting twice is the same as restricting once to the intersection, and the sheet count computed by Corollary 3.8 is stable under shrinking (as it must be, by Theorem 2.7).
* **Only openness of $W$ is used**, and only to guarantee that $\iota_W$ is a partial homeomorphism; no hypothesis on $V$, on $f$, or on the spaces is needed.

**Lemma 4.4 (Reindexing).** Let $(\varphi_i)_{i\in\iota}$ be a sheet system for $f$ over $V$ and let $\sigma : \kappa \to \iota$ be a bijection. Then $(\varphi_{\sigma(k)})_{k\in\kappa}$ is a sheet system for $f$ over $V$ indexed by $\kappa$.

*Proof.* (S1) and (S2) are pointwise conditions, inherited. (S3): if $k \ne l$ then $\sigma(k) \ne \sigma(l)$ by injectivity, so the sources are disjoint. (S4): surjectivity of $\sigma$ gives $\bigcup_k \Sigma_{\sigma(k)} = \bigcup_i \Sigma_i = f^{-1}(V)$. $\square$

---

## 5. The relative trivialisation theorem

**Theorem 5.1 (Relative trivialisation).** Let $U \subseteq X$ be open and suppose $f$ is a covering map on $U$. Then for every $x \in U$ there exists an open set $V$ with
$$x \in V \subseteq U$$
such that $f$ admits a sheet system over $V$ indexed by the fibre $f^{-1}(x)$.

*Proof.* By hypothesis $x$ is evenly covered with some discrete fibre $I$. By Theorem 4.2 there is an open $V_0 \ni x$ and a sheet system $(\varphi_i)_{i \in I}$ for $f$ over $V_0$. Apply Theorem 4.3 with $W := U$ (open by assumption): we obtain a sheet system over $U \cap V_0$, still indexed by $I$. Set $V := U \cap V_0$; then $x \in V$ (as $x \in U$ and $x \in V_0$), $V \subseteq U$, and $V$ is open as an intersection of two open sets.

Finally, by Lemma 2.2 applied to the even covering at $x$ there is a bijection $f^{-1}(x) \cong I$; Lemma 4.4 reindexes the sheet system along it, producing a sheet system over $V$ indexed by $f^{-1}(x)$. $\square$

The indexing by $f^{-1}(x)$ is the geometrically correct one: sheets over $V$ correspond one-to-one with points above $x$, each sheet containing exactly one such point (namely $\varphi_i^{-1}(x)$).

**Theorem 5.2 (Characterisation of relative covering maps).** Let $U \subseteq X$ be open. Then $f$ is a covering map on $U$ if and only if
$$\text{for every } x \in U \text{ there exist a set } \kappa \text{ and an open } V \text{ with } x \in V \subseteq U \text{ such that } f \text{ admits a sheet system over } V \text{ indexed by } \kappa.$$
No topology on $\kappa$ is required in either direction.

*Proof.* ($\Rightarrow$) Theorem 5.1, with $\kappa := f^{-1}(x)$.

($\Leftarrow$) Fix $x \in U$ and take $V, \kappa$ as supplied. Since $V$ is open and $x \in V$, Theorem 3.7 shows that $x$ is evenly covered by $f$ with fibre $f^{-1}(x)$ carrying the discrete topology. As $x \in U$ was arbitrary, $f$ is a covering map on $U$. $\square$

Theorem 5.2 is the payoff. The right-hand condition is *constructive and checkable*: to certify a covering over a region, exhibit around each point a list of open pieces upstairs, each mapping homeomorphically onto a common neighbourhood, pairwise disjoint, exhausting the preimage. There is no product to construct, no topology to put on an index set, and — crucially — the neighbourhood produced is guaranteed to sit inside the prescribed region $U$.

**Corollary 5.3 (Sheet number from a global sheet system).** If $U$ is open and $f$ admits a sheet system over $U$ indexed by $\iota$, then $f$ is a covering map on $U$ and $\mathrm{sh}_f(x) = \#\iota$ for every $x \in U$; if moreover $U$ is preconnected, this is consistent with Theorem 2.8, and if $\iota \ne \emptyset$ then $U \subseteq f(E)$.

*Proof.* Combine Theorems 3.6, 5.2, Corollary 3.8, and Theorem 2.12. $\square$

---

## 6. The piecewise-linear and polyhedral setting

The relative form of the theory was designed for maps of polyhedral complexes, where the region of interest is dictated in advance rather than produced by an existence proof.

### 6.1 Piecewise-affine maps of the line

Let $f : \mathbb{R} \to \mathbb{R}$ be continuous and piecewise affine with finitely many breakpoints $b_1 < \cdots < b_m$, affine with slope $s_k \ne 0$ on each open piece $P_k$. Call $c \in \mathbb{R}$ a *critical value* if $c \in f(\{b_1,\dots,b_m\})$. Let $U := \mathbb{R} \setminus f(\{b_1,\dots,b_m\})$, an open set (the complement of a finite set), and let $V$ be any connected component of $U$ — an open interval.

Over $V$, the sheets are the sets $\Sigma_k := P_k \cap f^{-1}(V)$ for those pieces $P_k$ whose image meets $V$. Each is an open interval; $f$ restricted to it is affine with nonzero slope, hence a homeomorphism onto $V$ (the endpoints of $\Sigma_k$ map to the endpoints of $V$ precisely because $V$ contains no critical value, so $f$ cannot turn around inside $\Sigma_k$ nor stop short); the $\Sigma_k$ are disjoint because the $P_k$ are; and they exhaust $f^{-1}(V)$ because a preimage point lying at a breakpoint would force its image to be a critical value. Thus $(f|_{\Sigma_k})_k$ is a sheet system over $V$, and by Corollary 5.3, $f$ is a covering map over $V$ with constant sheet number equal to the number of participating pieces.

The dichotomy applied to $V$ says: either $f$ misses the entire interval $V$, or it hits every point of it. This recovers, from purely local data, the familiar fact that the image of a piecewise-affine map is a union of components of the complement of the critical values (together with the critical values it attains).

### 6.2 Polyhedral maps in higher dimension

Let $\Pi \subseteq \mathbb{R}^n$ and $\Delta \subseteq \mathbb{R}^d$ be polyhedral complexes and let $f : \Pi \to \Delta$ be affine on each cell. Fix a chamber (maximal cell) $\sigma$ of $\Delta$ and let $V := \mathrm{relint}(\sigma)$. Suppose that every cell $\tau$ of $\Pi$ with $f(\tau) \subseteq \sigma$ and $\dim \tau = \dim \sigma$ maps affinely and bijectively onto $\sigma$, and that no lower-dimensional cell of $\Pi$ meets $f^{-1}(V)$. Then $\{ \mathrm{relint}(\tau) : f(\tau) = \sigma,\ \dim\tau = \dim\sigma \}$, together with the restrictions of $f$, is a sheet system over $V$, whose inverse charts are the inverses of the affine bijections. The sheet number over $V$ is the number of such cells $\tau$; Theorem 5.2 certifies that $f$ is a covering map over $V$; Theorem 2.8 shows the count is genuinely a property of the chamber; and Theorem 2.12 gives the all-or-nothing surjectivity over the chamber.

The relative form is essential here: the region of interest is $\mathrm{relint}(\sigma)$ (or a union of chambers), fixed by the combinatorics, and one needs the trivialisations to respect it. Theorem 4.3 provides exactly this, and the invariance of the index set under restriction is what allows the sheet count of a chamber to be compared with that of a smaller region inside it.

### 6.3 Algorithms

Three computational tasks arise, all supported by the results above.

**(A) Fibre enumeration.** Given a piecewise-affine $f$ and a point $y$, enumerate $f^{-1}(y)$ by solving, on each piece $P_k$, the affine equation $f|_{P_k}(e) = y$ and retaining solutions in $P_k$. Cost: linear in the number of pieces (times the cost of solving one affine system). This computes $\mathrm{sh}_f(y)$ exactly.

**(B) Sheet system extraction.** Given $f$ and a region $V$ free of critical values, output the list of sheets $\Sigma_k = P_k \cap f^{-1}(V)$ together with their inverse charts $\varphi_k^{-1}$. Validating axioms (S1)–(S4) amounts to checking, for each piece, that the affine restriction is injective with image containing $V$, that the trimmed sources are disjoint (automatic), and that the union recovers $f^{-1}(V)$ (equivalent to no breakpoint mapping into $V$). Cost: linear in the number of pieces.

**(C) Restriction.** Given a sheet system over $V$ and an open $W$, output the sheet system over $W \cap V$ by intersecting each source with $f^{-1}(W)$ and each target with $W$. Cost: linear in the number of sheets, with no recomputation of charts. This is Theorem 4.3 in code, and its linearity — and in particular the preservation of the index set — is the practical content of the relative trivialisation theorem.

A pipeline for certifying "$f$ is a covering over the open set $U$" is then: compute the critical values; verify $U$ avoids them; for each point (or each chamber) of $U$, run (B) to get a sheet system over a critical-value-free neighbourhood, then (C) to cut it down inside $U$; conclude by Theorem 5.2. The sheet number is then read off as the index count, and Theorem 2.8 propagates it across each connected piece of $U$.

---

## 7. Discussion

### 7.1 What the relative form buys

The abstract definition of an evenly covered point is an *existence* statement about a neighbourhood. Three concrete deficiencies follow, and the sheet-system reformulation addresses each.

1. **Localisation.** One cannot demand that the trivialising neighbourhood lie inside a prescribed open region. Theorem 4.3 fixes this by showing that trivialisations can be cut down, and Theorem 5.1 packages the fix.
2. **Concreteness.** The homeomorphism onto a product is opaque; sheet systems name the pieces and their inverse charts, which is what a construction, an algorithm, or a gluing argument needs to manipulate.
3. **Index bookkeeping.** The abstract definition drags along a topological space $I$ whose topology is never used except through discreteness. Theorem 3.7 shows the index may be taken to be the fibre itself with no topology assumed in the input, and Lemma 4.4 shows any bijective relabelling is harmless.

### 7.2 On the cardinality convention

Defining $\mathrm{sh}_f$ as an $\mathbb{N}$-valued function with $\#(\text{infinite}) = 0$ is a deliberate simplification. It makes semicontinuity and continuity statements expressible without extended arithmetic, at the price of conflating "empty" with "infinite". The conflation is genuinely harmless in this development because:

* the dichotomy (Theorem 2.12) tracks emptiness independently of cardinality, and it applies verbatim to infinite fibres;
* over any region where the fibres are finite — the case in the polyhedral applications — the invariant is the honest count;
* the constancy theorem holds regardless, since both $\#$ and "is empty" are transported by the bijection of Lemma 2.2.

A variant of the theory using cardinal-valued fibre counts would give a strictly sharper invariant, at the cost of complicating the semicontinuity statements; the two are interchangeable for finite fibres.

### 7.3 Relation to the classical statements

The results of Section 2 are the standard facts of covering space theory, but stated *relatively* — over a subset $S$ of the base, with no hypothesis on $f$ off $S$ and no global covering assumption. This relative form is what applications need, since interesting maps are rarely coverings everywhere: branch loci, walls of polyhedral fans, and discriminants all obstruct global statements while leaving large open regions untouched. Sections 3–5 are, to the best of our knowledge, the natural completion of that relative programme on the trivialisation side.

### 7.4 Limitations

* **Openness of the base region.** Theorem 5.1 and Theorem 5.2 assume $U$ open. This is not a technicality: sheet systems have open targets, so a trivialisation over a non-open region is not expressible in the language of Definition 3.1. A theory over locally closed or arbitrary $S$ would require charts valued in subspaces.
* **No properness or finiteness.** Nothing here bounds the number of sheets; the index set may be infinite (as for $\mathbb{R} \to S^1$), in which case Corollary 3.8 degenerates to $\mathrm{sh}_f \equiv 0$ under our convention while the dichotomy remains informative.
* **No monodromy.** Sheet systems are local objects. The comparison of sheet systems over overlapping regions — the transition data that gives rise to monodromy and to the classification of coverings — is not developed here; see Section 8.

---

## 8. Future directions

1. **Gluing and monodromy.** Given sheet systems over $V_1$ and $V_2$ with $V_1 \cap V_2 \ne \emptyset$, restriction (Theorem 4.3) puts both over $V_1 \cap V_2$ with their original index sets; on each connected component of the overlap the resulting bijection of index sets is locally constant, yielding transition permutations. Formalising this cocycle would give the monodromy representation and, with it, the classification of coverings over a fixed base in terms of sheet-system atlases.
2. **Path and homotopy lifting from sheet systems.** The relative trivialisation theorem furnishes exactly the data used in the standard Lebesgue-number proof of path lifting. Deriving unique path lifting and the homotopy lifting property directly from atlases of sheet systems — over an *open subset* of the base, so that lifting is proved only where the covering hypothesis holds — is the natural next theorem.
3. **Degree theory for polyhedral maps.** For a polyhedral map, the sheet number is constant on each chamber of a suitable subdivision of the target. Combining this with orientation data should give a purely combinatorial degree, computed as a signed sheet count, and a wall-crossing formula relating the counts of adjacent chambers across the discriminant.
4. **Tropical applications.** Tropical morphisms of curves and of higher-dimensional cycles are piecewise-integral-affine; balancing conditions relate the local sheet counts across walls. Expressing the tropical degree as the constant value of the sheet number over a chamber, and deriving the balancing condition as a compatibility of restricted sheet systems, would place tropical intersection multiplicities in this framework.
5. **Non-open base regions.** Extend the trivialisation theory to locally closed $S$ by allowing charts with targets open *in $S$*, and determine which of Theorems 3.6, 3.7, 5.1, 5.2 survive.
6. **Cardinal-valued sheet numbers.** Replace $\mathrm{sh}_f$ by a cardinal-valued invariant to remove the empty/infinite conflation, and re-derive the semicontinuity package in the order topology on cardinals.
7. **Effective certification.** Turn the pipeline of Section 6.3 into a verified certificate format: a list of sheets with explicit inverse charts, plus the disjointness and exhaustion witnesses, constituting a machine-checkable proof that a given map is a covering over a given region.

---

## 9. Summary of results

| Result | Statement |
|---|---|
| Openness of even covering | If $x$ is evenly covered with fibre $I$, so is every point of a neighbourhood, with the same $I$. |
| Fibre count of an even covering | $\mathrm{sh}_f(x) = \#I$; and $f^{-1}(x) \ne \emptyset \iff I \ne \emptyset$. |
| Local constancy | $\mathrm{sh}_f$ is locally constant on any set over which $f$ is a covering map. |
| Constancy | $\mathrm{sh}_f$ is constant on a preconnected set over which $f$ is a covering map. |
| Semicontinuity | $\mathrm{sh}_f$ is both lower and upper semicontinuous at each point of the covering locus, hence continuous into discrete $\mathbb{N}$. |
| Dichotomy | Over a preconnected covering locus, either all fibres are empty or all are nonempty. |
| Sheet system basics | $f$ is injective on each sheet, maps each sheet onto the base $V$, and openness of $W \subseteq V$ is detected on any single sheet. |
| Even covering from sheets | A sheet system over an open $V$ makes every point of $V$ evenly covered — by the index set, and intrinsically by its own fibre. |
| Restriction | A sheet system over $V$ restricts along any open $W$ to a sheet system over $W \cap V$ with the same index set. |
| Reindexing | Sheet systems transport along bijections of index sets. |
| Relative trivialisation | For open $U$ on which $f$ is a covering map and $x \in U$: there is an open $V$ with $x \in V \subseteq U$ carrying a sheet system indexed by $f^{-1}(x)$. |
| Characterisation | For open $U$: $f$ is a covering map on $U$ iff every point of $U$ has an open neighbourhood inside $U$ over which $f$ admits a sheet system. |
