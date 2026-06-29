# Renormalization Fixed Points in Transformer In-Context Learning via p-adic Attention

## Abstract

We develop the mathematical backbone of a theory of *universality* in
transformer in-context learning (ICL), built on two complementary pillars. The
first is **geometric**: we show that summarizing attention score rows through a
non-Archimedean (p-adic / ultrametric) valuation forces the resulting summaries
to organize into a rigorous **hierarchical tree** (dendrogram). Concretely, in
any ultrametric space the closed balls are *nested or disjoint*, the
same-resolution "same-cluster" relation is an equivalence relation at every
scale whose classes are exactly the closed balls, and decreasing the resolution
*refines* the partition. No probabilistic or learned structure is required; the
entire hierarchy is forced by the strong (isosceles) triangle inequality, and
hence holds in particular for the p-adic numbers $\mathbb{Q}_p$. The second
pillar is **dynamical**: modeling the ICL error under prompt-length rescaling as
a renormalization-group (RG) flow, we establish a universal fixed-point
structure. In the real affine model $x \mapsto g x + b$ there is a unique fixed
point $b/(1-g)$, an exact closed-form flow law $g^{n}(x - x^\*)$, convergence
for every initialization when $|g| < 1$, and exact independence of
initialization (any two trajectories merge). In the p-adic model the RG map is
multiplication by the uniformizer $p$, which is intrinsically contracting,
giving $\|p^n x\|_p = p^{-n}\|x\|_p$, universal convergence to the fixed point
$0$, and exact data collapse of normalized error curves onto the master curve
$n \mapsto p^{-n}$. All stated results are fully formalized and machine-checked,
and are `sorry`-free. We give precise statements, proof sketches, algorithms,
numerical demonstrations, and a falsifiable empirical program.

**Keywords.** in-context learning, renormalization group, universality,
ultrametric geometry, p-adic numbers, attention, hierarchical clustering, fixed
points, scaling laws.

---

## 1. Introduction

### 1.1 Motivation

Large transformer language models exhibit *in-context learning* (ICL): given a
prompt containing a few demonstrations of a task, the model performs the task
without any weight updates. Empirically, ICL error as a function of prompt
length (the number of in-context examples) often follows clean scaling curves,
and — across seeds, training corpora, and model widths — these curves frequently
**collapse** onto one another under appropriate rescaling. Such data collapse is
the empirical fingerprint of *universality*, the phenomenon, ubiquitous in
statistical physics, whereby microscopically different systems share identical
macroscopic critical behavior.

The organizing conjecture of this program is that ICL universality is governed
by a **renormalization group (RG)** acting on error curves under prompt-length
rescaling, and that the natural geometric substrate is **non-Archimedean**:
attention score matrices, compressed via p-adic valuations, live in an
ultrametric space whose intrinsic tree structure carries the relevant
multi-scale information. Refutation occurs if no architecture-stable
universality class appears, or if the p-adic compression destroys predictive
scaling structure.

### 1.2 Contributions

We isolate and prove the two load-bearing claims, deliberately split along the
Archimedean / non-Archimedean seam.

1. **Geometry (the tree).** In any ultrametric space — and hence in
   $\mathbb{Q}_p$ — the p-adic compression of attention summaries yields a
   genuine rooted hierarchical tree. We prove the nested-or-disjoint property of
   balls, the equivalence-relation structure of same-resolution clustering, the
   identification of clusters with closed balls, and the refinement of the
   partition under decreasing resolution.

2. **Dynamics (the fixed point).** Modeling the ICL error flow as an affine RG
   step, we prove existence/uniqueness of the fixed point, the exact closed-form
   flow law, convergence from every initialization, and exact universality
   (initialization/corpus independence). In the p-adic model we prove the exact
   contraction law, universal convergence, and exact data collapse onto
   $n \mapsto p^{-n}$.

All results below are formalized and verified; the prose statements correspond
one-to-one to machine-checked theorems.

---

## 2. Non-Archimedean preliminaries

### 2.1 Ultrametric spaces

Let $(S, d)$ be a pseudometric space. It is an **ultrametric space** if $d$
satisfies the *strong triangle inequality*: for all $x, y, z \in S$,

$$ d(x, z) \;\le\; \max\big(d(x, y),\, d(y, z)\big). \tag{U} $$

Inequality (U) strictly strengthens the ordinary triangle inequality
$d(x,z) \le d(x,y) + d(y,z)$. A standard consequence ("all triangles are
isosceles") is that if $d(x,y) \ne d(y,z)$ then $d(x,z) = \max(d(x,y), d(y,z))$.

### 2.2 The p-adic instance

Fix a prime $p$. For a nonzero rational $r$ written as $p^{k} \cdot a/b$ with
$\gcd(a,p) = \gcd(b,p) = 1$, the **p-adic valuation** is $v_p(r) = k$ and the
**p-adic absolute value** is $|r|_p = p^{-k}$ (with $|0|_p = 0$). The completion
of $\mathbb{Q}$ under $|\cdot|_p$ is the field of **p-adic numbers**
$\mathbb{Q}_p$, and $d_p(x,y) = |x - y|_p$ is an ultrametric. Thus every theorem
proved for an abstract ultrametric space specializes to $\mathbb{Q}_p$.

For attention, the intended map is a *compression*: an attention score row
$(a_1, \dots, a_m)$ is summarized by p-adic data (e.g. valuations of suitably
quantized scores), placing each row's summary in $\mathbb{Q}_p$ (or a finite
product thereof). The geometry below then applies verbatim.

### 2.3 Closed balls

For $x \in S$ and radius $r \in \mathbb{R}$, the **closed ball** is
$\overline{B}(x, r) = \{ y \in S : d(x,y) \le r \}$.

---

## 3. Pillar I — the hierarchical tree of ultrametric attention summaries

Throughout this section $(S, d)$ is an ultrametric space.

### 3.1 Balls are nested or disjoint

**Lemma 3.1 (small-in-large containment).** *Let $x, y \in S$ and
$r \le s$ in $\mathbb{R}$. If $\overline{B}(x,r) \cap \overline{B}(y,s)$ is
nonempty, then $\overline{B}(x,r) \subseteq \overline{B}(y,s)$.*

*Proof sketch.* Let $z$ be a common point, so $d(x,z) \le r$ and $d(z,y) \le s$.
By (U) and $r \le s$, $d(x,y) \le \max(d(x,z), d(z,y)) \le s$. Now take any
$w \in \overline{B}(x,r)$; then $d(w,x) \le r \le s$, and by (U) again
$d(w,y) \le \max(d(w,x), d(x,y)) \le s$, so $w \in \overline{B}(y,s)$. $\square$

(Formalized as `ultrametric_balls_subset_of_le`.)

**Theorem 3.2 (tree property).** *For $x, y \in S$ and $r \le s$,*
$$ \overline{B}(x,r) \subseteq \overline{B}(y,s) \quad\text{or}\quad
   \overline{B}(x,r) \cap \overline{B}(y,s) = \varnothing. $$

*Proof sketch.* Either the intersection is empty (disjoint) or it is nonempty,
in which case Lemma 3.1 gives containment. $\square$

(Formalized as `ultrametric_balls_nested_or_disjoint`.) This nested-or-disjoint
dichotomy is exactly the defining property of a hierarchical tree
(dendrogram): there is no partial overlap, so the collection of balls at all
radii forms a rooted hierarchy.

### 3.2 Same-cluster relation and its levels

**Definition 3.3 (same cluster).** For $\varepsilon \in \mathbb{R}$, define
$$ \mathrm{SameCluster}(\varepsilon, x, y) \;:\Longleftrightarrow\; d(x,y) \le \varepsilon. $$

**Lemma 3.4 (equivalence).** *For every $\varepsilon \ge 0$,
$\mathrm{SameCluster}(\varepsilon, \cdot, \cdot)$ is an equivalence relation.*

*Proof sketch.* **Reflexivity:** $d(x,x) = 0 \le \varepsilon$. **Symmetry:**
$d(x,y) = d(y,x)$. **Transitivity:** if $d(x,y) \le \varepsilon$ and
$d(y,z) \le \varepsilon$, then by (U),
$d(x,z) \le \max(d(x,y), d(y,z)) \le \varepsilon$. Transitivity is precisely the
strong triangle inequality and *fails* for ordinary metrics. $\square$

(Formalized as `sameCluster_refl`, `sameCluster_symm`, `sameCluster_trans`,
bundled into the equivalence `clusterSetoid (ε) (hε : 0 ≤ ε)`.)

**Lemma 3.5 (clusters are balls).** *For every $\varepsilon$ and $x$,*
$$ \{ y : \mathrm{SameCluster}(\varepsilon, x, y) \} = \overline{B}(x, \varepsilon). $$

*Proof sketch.* Unfold both definitions; $d(x,y) \le \varepsilon$ iff
$y \in \overline{B}(x,\varepsilon)$ (using $d(x,y)=d(y,x)$). $\square$

(Formalized as `cluster_eq_closedBall`.)

**Lemma 3.6 (coarsening / refinement).** *If $\varepsilon_1 \le \varepsilon_2$
and $\mathrm{SameCluster}(\varepsilon_1, x, y)$, then
$\mathrm{SameCluster}(\varepsilon_2, x, y)$.*

*Proof sketch.* $d(x,y) \le \varepsilon_1 \le \varepsilon_2$. $\square$

(Formalized as `sameCluster_mono`.) Increasing $\varepsilon$ merges clusters;
decreasing it refines the partition. These are the levels of the tree.

**Theorem 3.7 (the dendrogram is a genuine rooted tree).** *For
$\varepsilon_1 \le \varepsilon_2$ and any $x, y \in S$, the cluster classes*
$$ \{ z : \mathrm{SameCluster}(\varepsilon_1, x, z) \} \subseteq
   \{ z : \mathrm{SameCluster}(\varepsilon_2, y, z) \}
   \quad\text{or they are disjoint.} $$

*Proof sketch.* Rewrite each class as a closed ball via Lemma 3.5, then apply
Theorem 3.2. $\square$

(Formalized as `clusters_nested_or_disjoint`.)

### 3.3 Interpretation

Pillar I says: *the moment attention summaries are read non-Archimedeanly, a
rooted hierarchical clustering of context exists, automatically.* It is forced
by a single inequality; no training, probability, or optimization is invoked.
This extends the Euclidean view of attention to the ultrametric regime and
provides the geometric object on which the RG dynamics of Pillar II act.

---

## 4. Pillar II — renormalization fixed points of the ICL error flow

### 4.1 The Archimedean (affine) RG flow

We model the in-context-learning error, in the linearized regime near a fixed
point, as transforming under one prompt-length-rescaling step by an **affine
map**.

**Definition 4.1 (RG step).** For gain $g$, source $b$, and error $x$,
$$ \mathrm{rgStep}(g, b, x) \;=\; g\,x + b. $$
Here $g$ encodes the universal multiplicative attenuation per rescaling and $b$
the irreducible contribution of the finite set of relevant operators.

**Definition 4.2 (fixed point).** For $g \ne 1$,
$$ \mathrm{rgFixed}(g, b) \;=\; \frac{b}{1 - g}. $$

**Proposition 4.3 (fixed point).** *$x^\* = \mathrm{rgFixed}(g,b)$ is the unique
solution of $g x + b = x$.*

*Proof sketch.* $g x^\* + b = x^\* \iff b = (1-g) x^\*$, which for $g \ne 1$ has
the unique solution $x^\* = b/(1-g)$. $\square$

**Theorem 4.4 (exact flow law).** *For all $n \in \mathbb{N}$ and all $x$,*
$$ \mathrm{rgStep}(g,b,\cdot)^{[n]}(x) - x^\* \;=\; g^{\,n}\,\big(x - x^\*\big), $$
*where $\cdot^{[n]}$ denotes $n$-fold iteration.*

*Proof sketch.* Induction on $n$. Base case $n=0$ is trivial. Inductive step:
$\mathrm{rgStep}(g,b, y) - x^\* = g y + b - (g x^\* + b) = g(y - x^\*)$; apply
with $y = \mathrm{rgStep}^{[n]}(x)$ and use the inductive hypothesis. $\square$

**Theorem 4.5 (convergence from every initialization).** *If $|g| < 1$, then for
every $x$, $\mathrm{rgStep}(g,b,\cdot)^{[n]}(x) \to x^\*$ as $n \to \infty$.*

*Proof sketch.* By Theorem 4.4 the deviation is $g^n(x - x^\*)$; since
$|g| < 1$, $g^n \to 0$, so the deviation $\to 0$. (Formalized as
`rg_flow_converges`.) $\square$

**Theorem 4.6 (exact universality / initialization independence).** *For any two
initializations $x_1, x_2$ and $|g| < 1$,*
$$ \mathrm{rgStep}^{[n]}(x_1) - \mathrm{rgStep}^{[n]}(x_2)
   \;=\; g^{\,n}\,(x_1 - x_2) \;\to\; 0. $$

*Proof sketch.* Subtract two instances of Theorem 4.4; the $x^\*$ terms cancel,
leaving $g^n(x_1 - x_2) \to 0$. (Formalized as `rg_universality`.) $\square$

Theorem 4.6 is the RG account of data collapse: any two trajectories — differing
only by initialization and training corpus, both folded into the starting error
— converge together, so after sufficient rescaling the curves coincide.

### 4.2 The non-Archimedean (p-adic) RG flow

In the p-adic model the RG map is multiplication by the uniformizer $p$, which
needs no smallness hypothesis because it is intrinsically contracting.

**Definition 4.7 (p-adic RG step).** On $x \in \mathbb{Q}_p$,
$$ \mathrm{padicRGStep}(x) \;=\; p \cdot x, \qquad
   \mathrm{padicRGStep}^{[n]}(x) = p^{\,n} x. $$

**Theorem 4.8 (exact contraction law).** *For all $n$ and all
$x \in \mathbb{Q}_p$,*
$$ \big\| p^{\,n} x \big\|_p \;=\; p^{-n}\, \|x\|_p. $$

*Proof sketch.* The p-adic norm is multiplicative and $\|p\|_p = p^{-1}$, hence
$\|p^n x\|_p = \|p\|_p^{\,n} \|x\|_p = p^{-n}\|x\|_p$. (Formalized as
`padicRG_norm`.) $\square$

**Theorem 4.9 (universal convergence).** *For every $x \in \mathbb{Q}_p$,
$p^{n} x \to 0$ as $n \to \infty$; the unique fixed point of
$\mathrm{padicRGStep}$ is $0$.*

*Proof sketch.* By Theorem 4.8, $\|p^n x\|_p = p^{-n}\|x\|_p \to 0$; and
$p \cdot 0 = 0$ identifies the fixed point. (Formalized as
`padicRG_converges`.) $\square$

**Theorem 4.10 (exact data collapse).** *For every $x \ne 0$, the normalized
error curve is exactly the architecture-independent master curve*
$$ n \;\longmapsto\; \frac{\| p^{n} x \|_p}{\| x \|_p} \;=\; p^{-n}. $$

*Proof sketch.* Divide Theorem 4.8 by $\|x\|_p \ne 0$. The right-hand side
$p^{-n}$ depends only on the prime $p$ and on $n$ — not on $x$, hence not on
initialization, corpus, or width. (Formalized as `padicRG_data_collapse`.)
$\square$

Theorem 4.10 is the sharpest possible form of data collapse: not an asymptotic
match but an *exact* identity, with critical exponent fixed by $\log p$.

### 4.3 Relation to prior single-mode models

The affine flow generalizes a purely linear single-mode contraction
(multiplication by $g$ with $b = 0$, fixed point $0$) to an affine flow with a
genuine nonzero infrared fixed point $b/(1-g)$ and an explicit source term $b$
encoding relevant operators.

---

## 5. Algorithms

We summarize the constructive content as algorithms (Python implementations
appear in `demo.py` and in `PACKAGE.json`).

### 5.1 Ultrametric single-linkage dendrogram

Given a finite set of attention summaries with an ultrametric distance, build the
rooted tree by sweeping the resolution $\varepsilon$ upward and recording merges.
Because balls are nested or disjoint (Theorem 3.2), single-linkage clustering on
an ultrametric is *exact*: the resulting dendrogram is canonical and
order-independent. Complexity $O(m^2)$ in the number of summaries $m$ for the
distance matrix, $O(m^2 \log m)$ for the merge sort.

### 5.2 p-adic compression of an attention row

Quantize each attention score, extract its p-adic valuation, and emit an
ultrametric summary whose pairwise distances are $p^{-(\text{depth of lowest
common ancestor})}$. Complexity $O(m \log_p(\text{scale}))$ per row.

### 5.3 RG flow iterator and collapse check

Iterate $\mathrm{rgStep}$ (real) or $\mathrm{padicRGStep}$ (p-adic), normalize by
the initial error, and verify collapse onto $g^n$ (resp. $p^{-n}$). Complexity
$O(n)$ per trajectory.

---

## 6. Applications

- **Scale transfer.** If real transformers fall into an architecture-stable
  universality class, critical exponents measured on small models predict
  large-model ICL behavior, à la universality classes in physics.
- **Interpretability.** The ultrametric dendrogram of attention summaries gives
  an interpretable, multi-scale hierarchy of token relationships, replacing an
  opaque score matrix with a tree.
- **Principled architecture design.** Identifying the relevant operators (the
  source term $b$ and the gain $g$) suggests which architectural degrees of
  freedom control the infrared fixed point.
- **Diagnostics.** Exact data collapse onto $p^{-n}$ is a crisp, falsifiable
  signature to test on measured ICL error curves.

---

## 7. Discussion and limitations

The theorems establish the *mathematical possibility and structure* of the
conjecture: the tree is forced by ultrametricity, and the fixed point is forced
by affine contraction. They do **not** by themselves assert that empirical
transformers realize the p-adic compression with a nontrivial gain; that is the
falsifiable empirical content. The linearized affine model is valid near the
fixed point; far from it, nonlinear RG terms may matter. The p-adic model uses a
single uniformizer (scalar gain); real systems likely require a *spectrum* of
gains (diagonal operators), distinguishing relevant from irrelevant directions.

---

## 8. Future directions

(See the `future_directions` field of the accompanying package for the full
Phase A statement.) The headline next step is to generalize the scalar p-adic
step to a **diagonal RG operator** on a finite product $\prod \mathbb{Q}_p$,
realizing the relevant/irrelevant operator dichotomy as a **spectral gap** in
the p-adic gain: directions with $\|g_i\|_p < 1$ are irrelevant (flow to the
fixed point), the marginal/relevant directions set the universality class. Other
directions include data-collapse theorems for genuinely nonlinear RG maps,
matching critical exponents to measured ICL curves, and connecting the
ultrametric dendrogram to mechanistic interpretability.

---

## 9. Conclusion

We have isolated and proved two pillars of a theory of universality in
in-context learning. Geometrically, p-adic compression of attention forces a
rigorous hierarchical tree: balls are nested or disjoint, same-resolution
clustering is an equivalence relation whose classes are closed balls, and
resolution controls refinement. Dynamically, the RG flow of ICL error has a
universal fixed point: affinely, with closed-form flow $g^n(x-x^\*)$ and exact
initialization independence; p-adically, with exact contraction $p^{-n}\|x\|_p$
and exact data collapse onto $n \mapsto p^{-n}$. Renormalization, ultrametric
geometry, and neural computation meet at a single, fully verified point.
