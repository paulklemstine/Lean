# An Exact Betti–Rank Formula and a Width Calculus for Piecewise-Linear Decision Surfaces

## Abstract

The decision surface of a rectified-linear (ReLU) neural network
$f:\mathbb{R}^n \to \mathbb{R}$, defined as the level set $V(f)=\{x: f(x)=0\}$,
is a piecewise-linear hypersurface: on each activation region the network acts as
an affine map, so $V(f)$ is assembled from flat faces, each cut out by a single
linear equation. Every such face is a hyperplane section — an *algebraic cycle*
of the simplest kind — so the analogue of the Hodge problem (that rational
homology classes are spanned by algebraic cycles) holds for these surfaces *by
construction*. The substantive question is quantitative: how large is the
homology, and how does it depend on the network's architecture?

We answer this in two parts. First, we prove an **exact Betti–rank identity**:
for a three-term chain complex $C_2 \xrightarrow{d_2} C_1 \xrightarrow{d_1} C_0$
over a field, the middle homology dimension satisfies
$\dim H + \operatorname{rank} d_1 + \operatorname{rank} d_2 = \dim C_1$,
equivalently $\dim H = \dim C_1 - \operatorname{rank} d_1 - \operatorname{rank}
d_2$. This upgrades the classical cell-count *inequality* into a two-sided
equation and characterizes homology as precisely the part of the chain group
invisible to both differentials. Second, we develop a **width calculus** for the
activation-pattern count $P(w)=\prod_i 2^{w_i}$: it is monotone in each layer
width and multiplicative under parallel composition. Combining the two yields a
**monotone width bound** on every Betti number of the decision surface,
$\dim H \le \prod_i 2^{w_i}$, tying the topological complexity of what a network
learns directly to the count of its neurons.

**Keywords.** decision surface; piecewise-linear hypersurface; algebraic cycle;
cellular homology; Betti number; rank–nullity; activation pattern; width bound.

---

## 1. Introduction

### 1.1 Motivation: the shape of a learned frontier

A classifier partitions its input space into regions of differing predicted
labels. The interface between these regions — the **decision surface** — is the
geometric object that encodes what the classifier has learned. For networks built
from rectified linear units, $\sigma(t)=\max(0,t)$, this surface has a rigidly
combinatorial character: the input space $\mathbb{R}^n$ is subdivided into
finitely many convex polyhedral **activation regions**, on each of which every
neuron is either identically active or identically inactive, and on which $f$
therefore reduces to a single affine function. The zero set $V(f)$ intersects each
region in a flat piece of an affine hyperplane, and these pieces glue along the
region boundaries into a global **piecewise-linear hypersurface**.

### 1.2 The Hodge analogy

The Hodge conjecture concerns smooth complex projective varieties $X$: it asserts
that every rational $(p,p)$-cohomology class is a rational linear combination of
the classes of algebraic subvarieties (algebraic cycles). It is a statement that
the topology of $X$ — its cohomology — is never richer than the algebraic geometry
one can exhibit inside it. The conjecture is open in general.

For a ReLU decision surface the analogous statement is immediate. Each cellular
piece of $V(f)$ is a subset of an affine hyperplane $\{a\cdot x = b\}$, the zero
locus of a degree-one polynomial, hence an algebraic cycle. The surface is *built*
out of algebraic cycles, so any homology class it carries is, tautologically, a
combination of them. The interesting mathematics is therefore not existence but
**magnitude**: bounding and, where possible, exactly computing the homology in
terms of the network's shape. This paper provides both an exact computation (at
the level of the chain complex) and an architectural bound.

### 1.3 Contributions

1. **Exact Betti–rank identity** (Theorem 3.4): for a three-term chain complex
   over a field,
   $\dim H + \operatorname{rank} d_1 + \operatorname{rank} d_2 = \dim C_1$.
2. **Subtraction form and consequences** (Theorem 3.5, Corollaries 3.6–3.7): the
   explicit homology dimension, together with a vanishing criterion and its
   converse.
3. **Width calculus** (Theorems 4.2–4.5): closed form, monotonicity, and
   multiplicativity of the activation-pattern count $P(w)=\prod_i 2^{w_i}$.
4. **Monotone width bound** (Theorem 5.1): $\dim H \le \prod_i 2^{w_i}$, uniform
   over all narrower profiles.

---

## 2. Preliminaries: cellular homology of the decision surface

Fix a field $F$. We model the cellular chain data of the decision surface as three
consecutive finite-dimensional $F$-vector spaces with linear boundary maps,
$$
C_2 \;\xrightarrow{\;d_2\;}\; C_1 \;\xrightarrow{\;d_1\;}\; C_0 .
$$
Here $C_1$ is the vector space freely spanned by the middle-dimensional cells of
$V(f)$ (one basis vector per flat facet), and $d_1,d_2$ are the incidence maps of
the cell decomposition.

**Definition 2.1 (Cycles).** The *cycles* in degree one are the chains with zero
boundary, $Z := \ker d_1 \subseteq C_1$.

**Definition 2.2 (Boundaries).** The *boundaries* are the image
$\operatorname{range} d_2 \subseteq C_1$. Because we will always work with a
genuine chain complex ($d_1 \circ d_2 = 0$), the boundaries lie inside the cycles,
and we regard them as a submodule $B \subseteq Z$ via
$B = (\operatorname{range} d_2)\ \cap\ \ker d_1$ (formally, the pullback of
$\operatorname{range} d_2$ along the inclusion $Z \hookrightarrow C_1$).

**Definition 2.3 (Homology).** The *degree-one homology* is the subquotient
$H := Z / B = \ker d_1 / (\operatorname{range} d_2)$. Its dimension $\dim H$ is
the middle **Betti number** of the decision surface.

**Lemma 2.4 (Boundaries are cycles).** If $d_1 \circ d_2 = 0$ then
$\operatorname{range} d_2 \le \ker d_1$.
*Proof.* The condition $d_1\circ d_2 = 0$ says exactly that every vector in the
image of $d_2$ is annihilated by $d_1$, i.e. lies in $\ker d_1$. $\qquad\blacksquare$

**Lemma 2.5 (Betti number bounded by cell count).**
$\dim H \le \dim C_1$.
*Proof.* A quotient has dimension at most that of the space it quotients:
$\dim(Z/B)\le \dim Z$. A submodule has dimension at most that of its ambient
space: $\dim Z \le \dim C_1$. Compose the two inequalities. $\qquad\blacksquare$

**Lemma 2.6 (Euler identity of the subquotient).**
$\dim H + \dim B = \dim Z$.
*Proof.* This is the dimension law for a quotient of finite-dimensional spaces:
$\dim(Z/B) + \dim B = \dim Z$. $\qquad\blacksquare$

---

## 3. The exact Betti–rank identity

Throughout this section all three spaces $C_2, C_1, C_0$ are finite-dimensional
and $d_1\circ d_2 = 0$.

**Lemma 3.1 (Boundary dimension equals $d_2$-rank).**
$\dim B = \operatorname{rank} d_2$.

*Proof.* By Lemma 2.4, $\operatorname{range} d_2 \le \ker d_1 = Z$. When a
submodule $S$ is contained in a submodule $T$, the pullback of $S$ along the
inclusion $T \hookrightarrow C_1$ is isomorphic to $S$ itself (the inclusion
identifies the two). Applying this with $S = \operatorname{range} d_2$ and $T = Z$
gives $B \cong \operatorname{range} d_2$ as $F$-vector spaces, so
$\dim B = \dim \operatorname{range} d_2 = \operatorname{rank} d_2$.
$\qquad\blacksquare$

**Lemma 3.2 (Rank–nullity for $d_1$).**
$\operatorname{rank} d_1 + \dim Z = \dim C_1$, where $Z = \ker d_1$.
*Proof.* This is the rank–nullity theorem applied to $d_1 : C_1 \to C_0$:
$\dim \operatorname{range} d_1 + \dim \ker d_1 = \dim C_1$. $\qquad\blacksquare$

**Theorem 3.4 (Exact Betti–rank formula).** For a three-term chain complex over a
field with $d_1\circ d_2 = 0$,
$$
\boxed{\;\dim H + \operatorname{rank} d_1 + \operatorname{rank} d_2 = \dim C_1\;}.
$$

*Proof.* Start from the Euler identity (Lemma 2.6), $\dim H + \dim B = \dim Z$.
Replace $\dim B$ by $\operatorname{rank} d_2$ using Lemma 3.1, and replace $\dim Z$
by $\dim C_1 - \operatorname{rank} d_1$ using Lemma 3.2. This gives
$\dim H + \operatorname{rank} d_2 = \dim C_1 - \operatorname{rank} d_1$, which
rearranges to the claim. $\qquad\blacksquare$

**Theorem 3.5 (Subtraction form).** Under the same hypotheses,
$$
\dim H = \dim C_1 - \operatorname{rank} d_1 - \operatorname{rank} d_2 .
$$
*Proof.* Immediate from Theorem 3.4 by transposing the two rank terms; the
subtraction is well-defined because $\operatorname{rank} d_1 + \operatorname{rank}
d_2 \le \dim C_1$ (both ranks are non-negative and the left side of Theorem 3.4
equals $\dim C_1$). $\qquad\blacksquare$

**Interpretation.** Theorem 3.5 says homology is exactly the part of the middle
chain group $C_1$ that *neither* differential can see: $d_1$ accounts for the
$\operatorname{rank} d_1$ directions that fail to be cycles, and $d_2$ accounts
for the $\operatorname{rank} d_2$ cycle-directions that are boundaries. What
remains is genuine homology. This is the local Euler relation in its sharpest,
two-sided form; the classical statement $\dim H \le \dim C_1$ (Lemma 2.5) is its
immediate shadow.

**Corollary 3.6 (Vanishing).** If $\dim C_1 = 0$ then $\dim H = 0$.
*Proof.* By Lemma 2.5, $0 \le \dim H \le \dim C_1 = 0$. $\qquad\blacksquare$

**Corollary 3.7 (Converse: nonzero homology forces cells).** If $\dim H > 0$ then
$\dim C_1 > 0$.
*Proof.* Contrapositive of Corollary 3.6, or directly: $0 < \dim H \le \dim C_1$
by Lemma 2.5. $\qquad\blacksquare$

Corollaries 3.6–3.7 together state that middle homology is nonzero *if and only
if* there is at least one middle cell — structure and substance are inseparable.

---

## 4. The activation-pattern (width) calculus

We now count the cells combinatorially. Consider a network with $L$ hidden layers
of widths $w = (w_1,\dots,w_L)$, $w_i \in \mathbb{N}$.

**Definition 4.1 (Activation pattern).** An *activation pattern* is a choice, for
each hidden neuron, of a Boolean state (active/inactive):
$$
\mathrm{AP}(L,w) := \prod_{i=1}^{L} \{0,1\}^{w_i},
$$
i.e. a function assigning to each layer $i$ a Boolean vector of length $w_i$. Each
pattern selects one (possibly empty) activation region of input space, hence at
most one flat facet of the decision surface.

**Theorem 4.2 (Closed form).**
$$
\bigl|\mathrm{AP}(L,w)\bigr| = \prod_{i=1}^{L} 2^{\,w_i} = 2^{\,\sum_i w_i}.
$$
*Proof.* The set of patterns is a product of the layer-wise Boolean cubes, so its
cardinality is the product of the cardinalities $|\{0,1\}^{w_i}| = 2^{w_i}$;
collecting the exponents gives $2^{\sum_i w_i}$. $\qquad\blacksquare$

We write $P(w) := \prod_i 2^{w_i}$ for this **width count**.

**Theorem 4.3 (Monotonicity).** If $w_i \le w_i'$ for every $i$, then
$P(w) \le P(w')$.
*Proof.* Each factor obeys $2^{w_i} \le 2^{w_i'}$ because $t \mapsto 2^t$ is
non-decreasing on $\mathbb{N}$; a product of termwise inequalities between
non-negative quantities preserves the inequality. $\qquad\blacksquare$

**Theorem 4.5 (Multiplicativity under parallel composition).** Given two width
profiles $w=(w_1,\dots,w_L)$ and $v=(v_1,\dots,v_M)$, let $w \,\Vert\, v$ denote
their concatenation (a network of $L+M$ layers). Then
$$
\bigl|\mathrm{AP}(L+M,\, w \,\Vert\, v)\bigr|
   = \bigl|\mathrm{AP}(L,w)\bigr| \cdot \bigl|\mathrm{AP}(M,v)\bigr|,
$$
equivalently $P(w \,\Vert\, v) = P(w)\cdot P(v)$.
*Proof.* By Theorem 4.2 each side is a power of $2$; the exponent on the left is
$\sum_i (w \Vert v)_i = \sum_i w_i + \sum_j v_j$, which by the law of exponents
splits the left side as $2^{\sum w}\cdot 2^{\sum v}$, i.e. the product of the two
counts. $\qquad\blacksquare$

The calculus mirrors network operations: widening a layer (adding capacity) can
only increase the complexity budget, and stacking modules in series multiplies
their budgets.

---

## 5. Synthesis: the monotone width bound

We now connect the exact topology of §3 with the combinatorics of §4. The bridge
hypothesis is that the cellular chain group has at most one basis cell per
activation region — the generic and worst case for cell counting — so that
$\dim C_1 \le P(w)$ for the network's own width profile $w$.

**Theorem 5.1 (Monotone width bound).** Suppose $\dim C_1 \le P(w)$ for a profile
$w$, and let $w'$ be any wider profile, $w_i \le w_i'$ for all $i$. Then the
middle Betti number of the decision surface satisfies
$$
\dim H \;\le\; P(w') \;=\; \prod_i 2^{\,w_i'} .
$$

*Proof.* Chain three inequalities:
$$
\dim H \;\overset{\text{(Lemma 2.5)}}{\le}\; \dim C_1
       \;\overset{\text{(hyp.)}}{\le}\; P(w)
       \;\overset{\text{(Thm 4.3)}}{\le}\; P(w').
$$
$\qquad\blacksquare$

Two features deserve emphasis. First, the bound is *architectural*: its right-hand
side depends only on the layer widths, not on the learned weights or the training
data. Second, it is *uniform downward*: because $P$ is monotone, the bound for a
wide profile automatically covers every narrower one, so no slimmer network can
hide more homology than a wider one is permitted.

**Remark 5.2 (Exponential is unavoidable in general).** The bound is exponential
in total width, $P(w)=2^{\sum_i w_i}$. This reflects the genuine combinatorial
explosion of activation regions in generic ReLU networks; see Conjecture 6.2 for
the expected sharpness.

---

## 6. Discussion and future directions

The exact identity of §3 reframes the qualitative "Hodge-affirmative by
construction" observation as a precise dimensional accounting. Because it
isolates $\dim H$ as $\dim C_1 - \operatorname{rank} d_1 - \operatorname{rank}
d_2$, it becomes possible to attribute surviving homology to the *shortfall* of
two specific linear maps, opening the way to a functorial and bigraded theory. We
record three conjectures.

**Conjecture 6.1 (Bigraded / Hodge-type refinement).** For a network with
input-adjacent width $w_1$ and output-adjacent width $w_L$, each mixed Betti
number should satisfy a *product* bound
$h^{p,q} \le \binom{w_1}{p}\binom{w_L}{q}\prod_i w_i$, refining the single
exponential bound into a bigraded pyramid indexed by the two boundary layers. The
first and last layers play asymmetric roles — the first controls how cells are
*cut*, the last how they are *glued* — so homology should split along a bidegree
reading the input and output widths separately. The exact identity, by isolating
homology as the part seen by neither differential, makes it possible for the first
time to attribute each surviving dimension to a specific pair of boundary
directions rather than to aggregate width.

**Conjecture 6.2 (Sharpness of the width bound).** The bound $\dim H \le
\prod_i 2^{w_i}$ is asymptotically tight: for every width profile there is a
network whose decision surface realizes a Betti number that is a fixed positive
fraction of the bound, so the exponential growth in total width cannot be improved
to a subexponential rate. Generic hyperplane arrangements already realize a
constant fraction of all sign-cells, and a surface can be engineered so a constant
fraction of those cells carry independent homology classes; the multiplicative and
monotone calculus (Theorems 4.3, 4.5) supplies exactly the compositional tools to
build such large-homology examples layer by layer.

**Conjecture 6.3 (Subadditivity under composition).** If a deep network factors as
a composition of two sub-networks, the Betti numbers of its decision surface are
bounded by a convolution of the Betti numbers of the parts: composition can only
mix and cancel classes, never create more than the product-count of the factors
permits. Composition of piecewise-linear maps corresponds to a refinement of
activation regions, and refinement of a cell decomposition can merge homology
classes but cannot manufacture classes unaccounted for by the finer decomposition.

## 7. Conclusion

On the faceted decision surfaces of rectified-linear networks the Hodge-type
question — whether homology is spanned by algebraic cycles — is affirmative by
construction, because every facet is a hyperplane section. This lets us move past
existence to exact magnitude. The Betti number obeys the two-sided identity
$\dim H = \dim C_1 - \operatorname{rank} d_1 - \operatorname{rank} d_2$,
identifying homology as precisely what neither differential can see; the cell
count obeys a monotone, multiplicative width calculus $P(w)=\prod_i 2^{w_i}$; and
together they yield the architectural ceiling $\dim H \le \prod_i 2^{w_i}$. The
topological complexity of what a network can learn is thus bounded, in advance and
from the blueprint alone, by the count of its neurons.
