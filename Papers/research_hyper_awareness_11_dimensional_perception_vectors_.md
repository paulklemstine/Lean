# Lossless Rectified Perception in Eleven Dimensions: Exact Width, Sharp Frame Bounds, and Rigidity at the Optimum

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We determine exactly how wide a single rectified-linear layer must be in order to process an
$n$-dimensional percept without information loss, and we analyse the geometry of the resulting
optimum. Writing a layer as $\Phi_{W,b}(x)_i = \mathrm{relu}(\langle w_i, x\rangle + b_i)$ for
$x \in \mathbb{R}^n$ and $i$ ranging over a finite index set, we prove that $\Phi_{W,b}$ is
injective only if the layer has at least $2n$ units, and that $2n$ units suffice — realised by
the positive/negative split layer $x \mapsto (x^+, x^-)$, which even admits a *linear* left
inverse. In the mission dimension $n = 11$ the least lossless width is therefore exactly $22$.

We then upgrade injectivity to a metric statement: the optimal split layer is a frame with
bounds $1/2$ and $1$, i.e.
$\tfrac12\|x-y\|^2 \le \|\Phi(x)-\Phi(y)\|^2 \le \|x-y\|^2$, and both constants are attained,
so the decoding condition number is exactly $\sqrt{2}$, with antipodal percepts the unique
worst case. Next we show that architectures at the width optimum are rigid: a lossless layer
on $\mathbb{R}^n$ with exactly $2n$ units admits two percepts whose active-unit sets partition
the units into two blocks of size exactly $n$; consequently every unit has a nonzero weight row
— no dead units, no constant detectors, no prunable redundancy. We prove that depth cannot
repair a narrow sensory interface: any network whose first hidden layer has fewer than $2n$
rectified units identifies two distinct percepts, regardless of what the remaining layers
compute; conversely towers of optimal split layers remain lossless at every depth. Extending to
order-$k$ tensor percepts in $(\mathbb{R}^{11})^{\otimes k}$ we obtain the exact width law
$2 \cdot 11^k$: $22$, $242$, $2662$ for $k = 1, 2, 3$.

Finally we quantify two structural constraints on eleven-dimensional linear processing. Imposing
permutation equivariance on the perception axes reduces a linear layer to the two-parameter Deep
Sets form $x \mapsto a x + b (\sum_j x_j)\mathbf{1}$, with the parameters unique; imposing in
addition sign equivariance forces the layer to be a scalar multiple of the identity, destroying
all cross-channel computation. On the positive side, oddness of $11$ guarantees that every
linear perception layer on $\mathbb{R}^{11}$ possesses an invariant percept direction, a
guarantee that fails in even dimension, as the planar quarter-turn shows.

**Keywords:** rectified linear units, injective neural layers, frame bounds, width lower bounds,
equivariance, Deep Sets, hyperoctahedral group, tensor percepts.

---

## 1. Introduction

### 1.1 The design question

Consider a sensing system whose instantaneous state is an $11$-dimensional real vector: a
*percept* $x \in \mathbb{R}^{11}$ whose coordinates are independent sensory channels. The
canonical first stage of any artificial neural architecture applied to such a signal is a
rectified-linear layer: a finite family of units, each computing a rectified affine functional
of the percept.

Such a layer is a lossy compression device by default. The rectifier $\mathrm{relu}(t) =
\max(t,0)$ collapses the entire half-line $t \le 0$ to a single value. Whether the layer as a
whole preserves the percept depends on how the units' half-spaces are arranged. The question
this paper answers exactly is:

> **What is the minimal number of rectified units in a layer on $\mathbb{R}^n$ that is
> injective, and what does an architecture at that minimum look like?**

The answer is $2n$ — hence $22$ for $n = 11$ — and the geometry at the optimum is completely
determined.

### 1.2 Why the naive answers fail

Two naive answers suggest themselves and both are wrong.

*"$n$ units suffice, since $n$ numbers determine $n$ numbers."* This ignores rectification.
A layer of $n$ units with linearly independent weight rows is injective as a *linear* map, but
after rectification an entire polyhedral cone of percepts is mapped to the same output — for
example the layer $x \mapsto (\mathrm{relu}(x_1), \dots, \mathrm{relu}(x_n))$ sends every vector
with all coordinates negative to the origin.

*"Enough units chosen at random will do."* This is true but does not identify the threshold,
and the threshold matters: it is the point below which no amount of downstream depth,
capacity, or training can help (Theorem 6.1).

### 1.3 Results

Throughout, $\iota$ denotes a finite index set of units, $W : \iota \times \{1,\dots,n\} \to
\mathbb{R}$ the weight matrix with rows $w_i$, and $b : \iota \to \mathbb{R}$ the biases.

1. **Exact width law (Theorems 3.5, 4.2, 4.4).** $\Phi_{W,b}$ injective $\Rightarrow |\iota| \ge
   2n$; and $2n$ units are achieved by the split layer. For $n = 11$, $22$ is the least width.
2. **Sharp frame bounds (Theorems 5.2, 5.3, 5.5).** The split layer satisfies
   $\tfrac12\|x-y\|^2 \le \|\Phi(x)-\Phi(y)\|^2 \le \|x-y\|^2$, both constants attained.
3. **Rigidity at the optimum (Theorems 7.1, 7.2).** A lossless layer of width exactly $2n$
   partitions, at suitable probes, into two active blocks of size exactly $n$; every unit has a
   nonzero weight row.
4. **Depth is no substitute for interface width (Theorem 6.1, Proposition 6.2).**
5. **Tensor percepts (Theorem 8.1).** Order-$k$ eleven-dimensional percepts need exactly
   $2\cdot 11^k$ units.
6. **Equivariance costs (Theorems 9.2, 9.4, 9.5).** Permutation equivariance $\Rightarrow$ two
   parameters (Deep Sets); hyperoctahedral equivariance $\Rightarrow$ one parameter (global
   gain), with no cross-channel processing possible.
7. **The parity dividend (Theorem 10.1, Proposition 10.2).** Every linear layer on
   $\mathbb{R}^{11}$ has an invariant percept direction; in dimension $2$ this fails.

### 1.4 Organisation

Section 2 fixes definitions. Section 3 proves the lower bound through three steps: a genericity
lemma, a local rank bound, and an antipodal duality argument. Section 4 gives the matching
construction. Section 5 establishes metric stability. Section 6 treats depth, Section 7
rigidity, Section 8 tensors, Section 9 equivariance, Section 10 parity. Section 11 reports exact
rational numerical experiments; Section 12 discusses applications and open problems.

---

## 2. Definitions

**Definition 2.1 (Rectifier).** $\mathrm{relu} : \mathbb{R} \to \mathbb{R}$,
$\mathrm{relu}(t) = \max(t, 0)$.

Two immediate facts are used constantly: $\mathrm{relu}(t) = 0$ for $t \le 0$,
$\mathrm{relu}(t) = t$ for $t \ge 0$, and the **split identity**

$$\mathrm{relu}(t) - \mathrm{relu}(-t) = t \qquad (t \in \mathbb{R}). \tag{2.1}$$

**Definition 2.2 (Pre-activation and layer).** Given a finite index set $\iota$, weights
$W : \iota \to \mathbb{R}^n$ (rows $w_i$, entries $W_{ij}$) and biases $b : \iota \to
\mathbb{R}$, the *pre-activation* of unit $i$ at percept $x \in \mathbb{R}^n$ is

$$p_i(x) \;=\; \sum_{j=1}^n W_{ij} x_j + b_i,$$

and the *rectified layer* is the map
$\Phi_{W,b} : \mathbb{R}^n \to \mathbb{R}^{\iota}$, $\Phi_{W,b}(x)_i = \mathrm{relu}(p_i(x))$.

**Definition 2.3 (Losslessness).** The layer is *lossless* if $\Phi_{W,b}$ is injective:
distinct percepts always yield distinct responses.

**Definition 2.4 (Active rows).** For a percept $x$, the set of *active rows* is

$$A(x) \;=\; \{\, i \in \iota \;:\; p_i(x) > 0 \text{ and } w_i \ne 0 \,\}.$$

The second condition excludes units that are constant in the input; such a unit can be "on" but
transmits nothing about $x$, and the counting arguments below must not credit it.

**Definition 2.5 (Split layer).** For $n \ge 1$ the *positive/negative split layer* has index set
$\{1,\dots,n\} \sqcup \{1,\dots,n\}$, zero biases, and weight rows $w_{(+,i)} = e_i$,
$w_{(-,i)} = -e_i$. Explicitly

$$\Phi^{\mathrm{split}}(x) \;=\; \big(\mathrm{relu}(x_1),\dots,\mathrm{relu}(x_n),\,
\mathrm{relu}(-x_1),\dots,\mathrm{relu}(-x_n)\big) \;=\; (x^+, x^-).$$

**Definition 2.6 (Squared distance).** For $x, y$ indexed by a finite set,
$d^2(x,y) = \sum_i (x_i - y_i)^2$.

**Two elementary scaling lemmas.** The lower bound uses the following two facts, whose proofs are
routine but which we isolate because they carry the analytic content.

**Lemma 2.7 (Small perturbation preserves inactivity).** Let $S$ be a finite set, $p, c : S \to
\mathbb{R}$ with $p_i < 0$ for all $i \in S$. Then there is $t > 0$ with $p_i + t\,c_i \le 0$ for
all $i \in S$.

*Proof.* Take $t = \min_{i \in S} \dfrac{-p_i}{1 + |c_i|} > 0$. Then $t(1 + |c_i|) \le -p_i$ and
$c_i \le |c_i|$, so $t c_i \le t|c_i| \le -p_i - t < -p_i$. (If $S = \emptyset$, take $t=1$.)
$\square$

**Lemma 2.8 (Far field dominates the biases).** Let $d, b : \iota \to \mathbb{R}$ with $\iota$
finite. Then there is $s > 0$ such that $|b_i| < s\,|d_i|$ for every $i$ with $d_i \ne 0$.

*Proof.* Take $s = 1 + \max\{ |b_i| / |d_i| : d_i \ne 0 \}$ (and $s=1$ if no such $i$ exists).
$\square$

---

## 3. The lower bound: a lossless layer on $\mathbb{R}^n$ needs $2n$ units

The proof has three movements: genericity (find a probe direction transverse to all rows),
a local rank bound (at generic points, active rows must span), and duality (probe in two
opposite directions and add).

### 3.1 A transverse probe direction

**Lemma 3.1 (Generic direction).** For any finite family of rows $w_i \in \mathbb{R}^n$ there
exists $u \in \mathbb{R}^n$ with $\langle w_i, u\rangle \ne 0$ for every $i$ with $w_i \ne 0$.

*Proof sketch.* To each nonzero row $w_i$ associate the univariate real polynomial
$P_i(X) = \sum_{j=1}^n W_{ij} X^{j-1}$. Since some coefficient $W_{ik}$ is nonzero, $P_i \ne 0$.
The product $P = \prod_i P_i$ over the nonzero rows is therefore a nonzero polynomial, and a
nonzero polynomial over an infinite field has a non-root: choose $t \in \mathbb{R}$ with
$P(t) \ne 0$. Setting $u = (1, t, t^2, \dots, t^{n-1})$ gives
$\langle w_i, u\rangle = P_i(t) \ne 0$ for every nonzero row, since a product is nonzero only if
all factors are. $\square$

This is the *Vandermonde probe*: a single moment curve point suffices to be transverse to
finitely many hyperplanes at once. No measure theory or genericity-in-the-topological-sense is
needed.

### 3.2 The local rank bound

**Theorem 3.2 (Active rows span).** Let $\Phi_{W,b}$ be injective and let $x \in \mathbb{R}^n$ be
a percept at which no input-dependent unit sits exactly on its kink, i.e. for every $i$ either
$w_i = 0$ or $p_i(x) \ne 0$. Then the rows $\{w_i : i \in A(x)\}$ span $\mathbb{R}^n$; in
particular $|A(x)| \ge n$.

*Proof.* Consider the linear map $L : \mathbb{R}^n \to \mathbb{R}^{A(x)}$, $L(v)_i = \langle w_i,
v\rangle$. We claim $L$ is injective, which gives $n = \dim \mathbb{R}^n \le |A(x)|$ and, dually,
that the active rows span.

Suppose $L(v) = 0$, i.e. $\langle w_i, v\rangle = 0$ for all $i \in A(x)$. Put $c_i = \langle
w_i, v\rangle$ and $S = \{ i : c_i \ne 0 \}$. We first check $p_i(x) < 0$ on $S$. Fix $i \in S$.
Then $w_i \ne 0$ (otherwise $c_i = 0$), so by hypothesis $p_i(x) \ne 0$; if we had $p_i(x) > 0$
then $i \in A(x)$ and hence $c_i = 0$, a contradiction. Thus $p_i(x) < 0$ for all $i \in S$.

By Lemma 2.7 choose $t > 0$ with $p_i(x) + t c_i \le 0$ for all $i \in S$. Now compare
$\Phi_{W,b}(x + tv)$ with $\Phi_{W,b}(x)$ unit by unit, using the affine identity $p_i(x + tv) =
p_i(x) + t c_i$:

- if $c_i = 0$ the pre-activations agree, hence so do the outputs;
- if $c_i \ne 0$ then $i \in S$, so $p_i(x) < 0$ and $p_i(x) + t c_i \le 0$, and both units
  output $0$.

Hence $\Phi_{W,b}(x + tv) = \Phi_{W,b}(x)$; injectivity gives $x + tv = x$, so $tv = 0$ and,
since $t > 0$, $v = 0$. $\square$

The mechanism deserves a sentence of interpretation. A percept perturbation invisible to all
*lit* units is invisible to the whole layer, because dark units are dark on an open set and a
sufficiently small perturbation cannot wake them. Losslessness therefore requires that the lit
units, at every generic percept, already carry a full-rank linear measurement of the percept.

### 3.3 Antipodal duality

**Theorem 3.3 (Antipodal probes).** If $\Phi_{W,b}$ is injective then there exist percepts $x,y$
with $|A(x)| \ge n$, $|A(y)| \ge n$, and $A(x) \cap A(y) = \emptyset$.

*Proof.* Pick a transverse direction $u$ by Lemma 3.1 and set $d_i = \langle w_i, u\rangle$, so
$d_i \ne 0$ whenever $w_i \ne 0$. Pick $s > 0$ by Lemma 2.8 with $|b_i| < s|d_i|$ whenever
$d_i \ne 0$. Along the line $\sigma \mapsto \sigma u$ we have $p_i(\sigma u) = \sigma d_i + b_i$.

*No kinks at the probes.* For $|\sigma| = s$ and any $i$ with $w_i \ne 0$: if
$\sigma d_i + b_i = 0$ then $|b_i| = |\sigma d_i| = s|d_i|$, contradicting $|b_i| < s|d_i|$.
So $x = su$ and $y = -su$ both satisfy the hypothesis of Theorem 3.2, giving $|A(x)| \ge n$ and
$|A(y)| \ge n$.

*Disjointness.* Suppose $i \in A(x) \cap A(y)$. Then $w_i \ne 0$, hence $d_i \ne 0$ and
$|b_i| < |s d_i|$, so $-|sd_i| < b_i < |sd_i|$. Activity at both probes gives
$s d_i + b_i > 0$ and $-s d_i + b_i > 0$; adding, $2 b_i > 0$, and each inequality then forces
$|b_i| > |s d_i|$ — contradiction. Concretely: if $sd_i > 0$ then $-sd_i + b_i > 0$ gives
$b_i > sd_i = |sd_i|$; if $sd_i < 0$ then $sd_i + b_i > 0$ gives $b_i > -sd_i = |sd_i|$. Either
way $|b_i| > |sd_i|$, contradicting the choice of $s$. $\square$

**Theorem 3.4 (Width lower bound).** If $\Phi_{W,b} : \mathbb{R}^n \to \mathbb{R}^\iota$ is
injective then $|\iota| \ge 2n$.

*Proof.* With $x,y$ as in Theorem 3.3, $2n \le |A(x)| + |A(y)| = |A(x) \cup A(y)| \le |\iota|$,
the middle equality by disjointness. $\square$

**Theorem 3.5 (Eleven dimensions).** A lossless rectified perception layer on $\mathbb{R}^{11}$
has at least $22$ units. Contrapositively, no layer on $\mathbb{R}^{11}$ with fewer than $22$
units is injective. $\square$

**Remark 3.6 (Where the factor 2 comes from).** A rectified unit is a half-space detector: it
reports on one side of a hyperplane and is silent on the other. Injectivity requires a full-rank
measurement on *both* far sides of a generic line, and no unit can serve both sides. The factor
$2$ is exactly the cost of one-sidedness.

---

## 4. The matching construction

**Theorem 4.1 (Exact linear reconstruction).** For the split layer of Definition 2.5 and every
$x \in \mathbb{R}^n$, $j \in \{1,\dots,n\}$,

$$\Phi^{\mathrm{split}}(x)_{(+,j)} - \Phi^{\mathrm{split}}(x)_{(-,j)} \;=\; x_j.$$

*Proof.* This is the split identity (2.1) applied to $t = x_j$: if $x_j \le 0$ the left side is
$0 - (-x_j) = x_j$; if $x_j \ge 0$ it is $x_j - 0 = x_j$. $\square$

**Theorem 4.2 (Sufficiency).** $\Phi^{\mathrm{split}}$ is injective. $\square$

Indeed it has a *linear* left inverse, namely $(u,v) \mapsto u - v$. This is stronger than
injectivity: decoding requires no case analysis, no optimisation, and no knowledge of which
units fired.

**Lemma 4.3 (Re-indexing).** Injectivity is invariant under bijective relabelling of units.
$\square$

**Theorem 4.4 (Exact width law in dimension 11).** $22$ is the least element of
$\{ m \in \mathbb{N} : \exists W \in \mathbb{R}^{m \times 11},\, b \in \mathbb{R}^m,\,
\Phi_{W,b} \text{ injective} \}$.

*Proof.* Membership: the split layer with $m = 22$, re-indexed by any bijection
$\{1,\dots,22\} \to \{1,\dots,11\}\sqcup\{1,\dots,11\}$ (Lemma 4.3, Theorem 4.2). Lower bound:
Theorem 3.5. $\square$

---

## 5. Metric stability: sharp frame bounds for the optimum

Injectivity is not, by itself, an engineering guarantee. A map can be injective while
compressing some direction arbitrarily strongly, so that inverting it amplifies noise without
bound. The relevant quantitative property is the frame (bi-Lipschitz) condition. For the optimal
layer it holds with explicit and sharp constants.

**Lemma 5.1 (Coordinatewise sandwich).** For all $a, b \in \mathbb{R}$,

$$\frac{(a-b)^2}{2} \;\le\; \big(\mathrm{relu}(a)-\mathrm{relu}(b)\big)^2 +
\big(\mathrm{relu}(-a)-\mathrm{relu}(-b)\big)^2 \;\le\; (a-b)^2 .$$

*Proof sketch.* Write $u = \mathrm{relu}(a)-\mathrm{relu}(b)$ and $v = \mathrm{relu}(-a)-
\mathrm{relu}(-b)$. By (2.1), $u - v = a - b$. The elementary inequality $(u-v)^2 \le 2(u^2+v^2)$
yields the lower bound. For the upper bound one checks the four sign cases of $(a,b)$: when $a,b$
have the same sign one of $u,v$ vanishes and the other equals $\pm(a-b)$, giving equality; when
they straddle zero, say $a \le 0 \le b$, then $u = -b$ (up to sign conventions) and $v = -a$, so
$u^2 + v^2 = a^2 + b^2 \le (a-b)^2 = a^2 - 2ab + b^2$ because $-2ab \ge 0$. $\square$

The straddling case is precisely where information is lost: the split layer records $|a|$ and
$|b|$ separately but the *cross term* $-2ab$ is missing from the output energy. This is the
entire source of the constant $1/2$.

**Theorem 5.2 (Upper frame bound; $1$-Lipschitz).** For all $x,y \in \mathbb{R}^n$,
$d^2(\Phi^{\mathrm{split}}(x), \Phi^{\mathrm{split}}(y)) \le d^2(x,y)$.

*Proof.* Sum the right inequality of Lemma 5.1 over coordinates, using
$d^2(\Phi^{\mathrm{split}}(x),\Phi^{\mathrm{split}}(y)) = \sum_j [(\mathrm{relu}(x_j)-
\mathrm{relu}(y_j))^2 + (\mathrm{relu}(-x_j)-\mathrm{relu}(-y_j))^2]$. $\square$

**Theorem 5.3 (Lower frame bound).** For all $x,y \in \mathbb{R}^n$,
$\tfrac12 d^2(x,y) \le d^2(\Phi^{\mathrm{split}}(x), \Phi^{\mathrm{split}}(y))$. $\square$

**Corollary 5.4.** The split layer is a frame with bounds $1/2$ and $1$; the worst-case
amplification of decoding error (the condition number) is $\sqrt{2}$. The lower bound re-proves
injectivity without any combinatorics: if the outputs agree then $d^2(x,y) \le 0$, so $x = y$.
$\square$

**Theorem 5.5 (Both constants are attained; $n = 11$).** Let $e_0$ be the first standard basis
vector.

- *(Upper, exact)* $d^2(\Phi^{\mathrm{split}}(e_0), \Phi^{\mathrm{split}}(0)) = 1 = d^2(e_0, 0)$.
- *(Lower, exact)* $d^2(\Phi^{\mathrm{split}}(e_0), \Phi^{\mathrm{split}}(-e_0)) = 2 =
  \tfrac12 \cdot 4 = \tfrac12 d^2(e_0, -e_0)$.

*Proof.* Direct computation. In the first case only the unit $(+,0)$ changes, contributing $1$.
In the second, $\Phi^{\mathrm{split}}(e_0)$ has a $1$ in slot $(+,0)$ and zeros elsewhere, while
$\Phi^{\mathrm{split}}(-e_0)$ has a $1$ in slot $(-,0)$; the squared distance is $1 + 1 = 2$,
whereas the input squared distance is $\|2e_0\|^2 = 4$. $\square$

So the *unique* worst case is a percept and its antipode: rectification loses exactly a factor of
two of energy across a sign flip, and nothing worse can happen.

**Proposition 5.6 (General contraction).** For *any* rectified layer,
$d^2(\Phi_{W,b}(x), \Phi_{W,b}(y)) \le \sum_i (p_i(x) - p_i(y))^2$.

*Proof.* Coordinatewise, $|\mathrm{relu}(s) - \mathrm{relu}(t)| \le |s - t|$ since
$\mathrm{relu}$ is $1$-Lipschitz (indeed $|\max(s,0) - \max(t,0)| \le |s-t|$); square and sum.
$\square$

This explains structurally why the split layer's upper constant can be as small as $1$: its
linear part is an isometry onto its image up to the factor accounted for by the two halves, and
rectification only ever contracts.

---

## 6. Depth cannot repair a narrow sensory interface

**Theorem 6.1 (Narrow first layer is fatal at any depth).** Let $\Phi_{W,b} : \mathbb{R}^{11} \to
\mathbb{R}^{\iota}$ be a rectified layer with $|\iota| < 22$, and let $g : \mathbb{R}^\iota \to
\mathcal{A}$ be an *arbitrary* map — any composition of further layers, nonlinearities,
normalisations, attention blocks, or anything else, into any target set. Then
$g \circ \Phi_{W,b}$ is not injective.

*Proof.* Suppose $g \circ \Phi_{W,b}$ were injective. If $\Phi_{W,b}(x) = \Phi_{W,b}(y)$ then
$g(\Phi_{W,b}(x)) = g(\Phi_{W,b}(y))$, whence $x = y$; so $\Phi_{W,b}$ itself is injective. But
$|\iota| < 22$ contradicts Theorem 3.5. $\square$

The statement is trivial to prove and non-trivial in consequence. It says the sensory interface is
a *bottleneck in the information-theoretic sense*: whatever is identified there is identified
forever. Capacity added downstream is capacity added after the loss. In architecture search, the
width of the first hidden layer relative to the input dimension is thus qualitatively different
from every other width hyperparameter: below $2n$ it is not "suboptimal", it is *impossible*.

**Proposition 6.2 (Depth is otherwise free).** The composition of the optimal split layer
$\mathbb{R}^n \to \mathbb{R}^{2n}$ with the optimal split layer $\mathbb{R}^{2n} \to
\mathbb{R}^{4n}$ is injective; inductively, towers of optimal split layers are injective at every
depth.

*Proof.* A composition of injective maps is injective; each factor is injective by Theorem 4.2.
$\square$

Hence $22$ units at the interface are necessary, sufficient, and compatible with unbounded depth:
the constraint is purely local to the input.

---

## 7. Rigidity at the optimum

The width law says that the optimum is $2n$. This section says that architectures *at* the
optimum have no slack whatsoever.

**Theorem 7.1 (Balanced activation at the optimum).** Let $\Phi_{W,b} : \mathbb{R}^n \to
\mathbb{R}^{\iota}$ be injective with $|\iota| = 2n$ *exactly*. Then there exist percepts
$x, y \in \mathbb{R}^n$ with

$$|A(x)| = n, \qquad |A(y)| = n, \qquad A(x) \cap A(y) = \emptyset, \qquad A(x) \cup A(y) =
\iota.$$

*Proof.* Take $x, y$ from Theorem 3.3: $|A(x)| \ge n$, $|A(y)| \ge n$, and the sets are disjoint,
so $|A(x)| + |A(y)| = |A(x) \cup A(y)| \le |\iota| = 2n$. Both cardinalities are therefore exactly
$n$, their union has $2n$ elements, and a subset of $\iota$ with $|\iota|$ elements is $\iota$.
$\square$

**Theorem 7.2 (Every unit is essential).** Under the hypotheses of Theorem 7.1, every unit
$i \in \iota$ has $w_i \ne 0$.

*Proof.* By Theorem 7.1, $i$ lies in $A(x)$ or in $A(y)$; membership in an active set includes,
by Definition 2.4, the requirement $w_i \ne 0$. $\square$

**Corollary 7.3 (No pruning, no dead units).** A lossless $22$-unit layer on $\mathbb{R}^{11}$
contains no constant detector and no unit whose deletion preserves losslessness — deleting any
unit leaves $21 < 22$ units, which cannot be lossless. Every one of the $22$ units genuinely
depends on the percept. $\square$

**Interpretation.** Theorem 7.1 is a strong structural statement obtained from pure counting: no
assumption whatsoever was made about the weights, yet the layer is *forced* to exhibit the
signature of the canonical positive/negative split — two disjoint, exactly-balanced blocks of $n$
units, activated by an antipodal pair of probes. Half the units carry the "positive half" of the
percept and half carry the "negative half".

**Proposition 7.4 (The canonical optimum realises the pattern concretely).** For the split layer
with zero biases and any percept $x$ with all coordinates strictly positive, the active units are
exactly the $n$ units of the positive block.

*Proof.* Unit $(+,j)$ has pre-activation $x_j > 0$ and nonzero row $e_j$, so it is active; unit
$(-,j)$ has pre-activation $-x_j < 0$, so it is not. $\square$

Reversing the percept exchanges the two blocks; the pair $(x, -x)$ is exactly the antipodal probe
pair whose existence Theorem 7.1 asserts in general.

---

## 8. Order-$k$ tensor percepts

Perception is frequently higher-order: an $11\times11$ matrix of pairwise channel correlations,
an $11\times11\times11$ array of triple interactions, and so on. An *order-$k$ eleven-dimensional
percept* is an element of $(\mathbb{R}^{11})^{\otimes k}$, i.e. a function
$\{1,\dots,11\}^k \to \mathbb{R}$, a space of dimension $11^k$.

**Theorem 8.1 (Exact tensor width law).** A lossless rectified layer on order-$k$
eleven-dimensional tensor percepts requires at least $2 \cdot 11^k$ units, and $2 \cdot 11^k$
units suffice.

*Proof.* The lower bound is Theorem 3.4 applied with $n = 11^k$, after the (dimension-preserving)
identification of $(\mathbb{R}^{11})^{\otimes k}$ with $\mathbb{R}^{11^k}$. The upper bound is the
coordinatewise split layer of Definition 2.5 on $\mathbb{R}^{11^k}$, injective by Theorem 4.2, of
width $2 \cdot 11^k$. $\square$

**Corollary 8.2.** The lossless widths are
$$k = 1: 22, \qquad k = 2: 242, \qquad k = 3: 2662. \qquad \square$$

Two readings. Optimistically, the *overhead* of losslessness is a constant factor $2$ at every
order — rectification never costs more than doubling. Pessimistically, the base cost grows as
$11^k$, so lossless order-$3$ processing already demands thousands of units at the interface;
any practical architecture at order $3$ or above is necessarily lossy, and the theorem quantifies
exactly what price is being paid to avoid that.

---

## 9. The cost of symmetry

Equivariance is the standard route to parameter economy. Here we quantify how much of an
eleven-dimensional linear layer survives natural symmetry demands. Throughout this section
$M \in \mathbb{R}^{n\times n}$ acts by $L_M(x)_i = \sum_j M_{ij} x_j$, and $n \ge 2$.

**Definition 9.1.** $M$ is *permutation equivariant* if $L_M(x \circ \sigma^{-1}) = L_M(x) \circ
\sigma^{-1}$ for every permutation $\sigma$ of the axes — equivalently
$M_{\sigma(i)\sigma(j)} = M_{ij}$ for all $i, j, \sigma$. $M$ is *sign equivariant* if
$L_M(\varepsilon \odot x) = \varepsilon \odot L_M(x)$ for every sign vector $\varepsilon \in
\{\pm1\}^n$, where $\odot$ is coordinatewise product.

**Theorem 9.2 (Deep Sets form).** $M$ is permutation equivariant if and only if there are
$a, b \in \mathbb{R}$ with $M_{ij} = a$ for $i = j$ and $M_{ij} = b$ for $i \ne j$; equivalently,
if and only if

$$L_M(x)_i \;=\; (a-b)\, x_i \;+\; b \sum_{j=1}^n x_j \qquad \text{for all } x, i.$$

Moreover the pair $(a,b)$ is *uniquely* determined by $M$.

*Proof sketch.* Permutation equivariance of $L_M$ is equivalent to invariance of the matrix
entries under the simultaneous action $M_{ij} \mapsto M_{\sigma(i)\sigma(j)}$. The symmetric group
acts transitively on the diagonal positions and, being $2$-transitive, transitively on the
ordered pairs of distinct positions; hence all diagonal entries share a value $a$ and all
off-diagonal entries share a value $b$. Substituting into $\sum_j M_{ij} x_j$ and splitting
$M_{ij} = b + (a-b)\delta_{ij}$ gives the displayed formula. Uniqueness: evaluate at two entries,
$a = M_{11}$ and $b = M_{12}$ (using $n \ge 2$). $\square$

This is exactly the classical *Deep Sets* linear layer: **two** learnable parameters regardless of
$n$. For $n = 11$, permutation equivariance takes a $121$-parameter layer down to $2$.

**Theorem 9.3 (Sign equivariance kills off-diagonal weights).** If $M$ is sign equivariant then
$M_{ij} = 0$ for all $i \ne j$.

*Proof.* Fix $i \ne j$. Take $\varepsilon$ with $\varepsilon_j = -1$ and $\varepsilon_k = 1$ for
$k \ne j$, and take $x = e_j$. Then $\varepsilon \odot x = -e_j$, so the left side of the
equivariance identity at coordinate $i$ is $-M_{ij}$, while the right side is
$\varepsilon_i M_{ij} = M_{ij}$ (as $i \ne j$ gives $\varepsilon_i = 1$). Hence
$M_{ij} = -M_{ij}$, i.e. $M_{ij} = 0$. $\square$

**Theorem 9.4 (Hyperoctahedral rigidity).** For $n \ge 2$, a linear layer is equivariant for both
the permutations and the sign flips of the $n$ axes — that is, for the full hyperoctahedral group
$B_n = \{\pm1\}^n \rtimes S_n$ — if and only if $M = a I$ for some scalar $a$. In particular a
hyperoctahedral-equivariant perception layer on $\mathbb{R}^{11}$ is a global gain control
$x \mapsto a x$, with a single learnable parameter.

*Proof.* ($\Rightarrow$) Permutation equivariance gives the two-parameter form of Theorem 9.2, and
sign equivariance forces the off-diagonal value $b$ to be $0$ by Theorem 9.3; so $M = aI$.
($\Leftarrow$) Scalars commute with permutation matrices and with diagonal sign matrices. $\square$

**Theorem 9.5 (No symmetric channel mixing).** No hyperoctahedral-equivariant linear layer on
$\mathbb{R}^{11}$ can implement the exchange of two perception channels; i.e. there is no such
$M$ with $L_M(x) = x \circ (0\;1)$ for all $x$.

*Proof.* By Theorem 9.4, $L_M(x) = a x$. Take $x = e_1$. Then $L_M(x)_0 = a\,(e_1)_0 = 0$, while
the channel swap requires $(x \circ (0\;1))_0 = x_1 = 1$. Contradiction. $\square$

**Discussion.** These three theorems form a sharp trade-off statement for eleven-dimensional
architectures. The symmetry hierarchy
$$\text{none } (121 \text{ params}) \;\to\; S_{11} \;(2) \;\to\; B_{11} \;(1)$$
is not gradual: the last step annihilates all cross-channel computation. If the eleven channels
are genuinely interchangeable *and* sign-symmetric, the linear part of the architecture cannot do
anything except rescale, and all expressive power must come from the nonlinearity or from
deliberately broken symmetry (e.g. equivariance under a proper subgroup, or an equivariant
*bilinear* stage). Combined with Section 3, this delineates the design space: the interface must
be at least $22$ wide, and if it is also fully $B_{11}$-symmetric in its linear part, that width
is doing nothing but replicating a scalar.

---

## 10. The parity dividend: eleven is odd

**Theorem 10.1 (Invariant percept direction).** Every linear perception layer on $\mathbb{R}^{11}$
— with no hypothesis on the weights — has an invariant percept direction: there exist $a \in
\mathbb{R}$ and $v \in \mathbb{R}^{11}$, $v \ne 0$, with $Mv = a v$. If the layer is injective, the
gain $a$ is nonzero.

*Proof.* The characteristic polynomial $\chi_M(\lambda) = \det(\lambda I - M)$ is a monic real
polynomial of odd degree $11$. A monic real polynomial of odd degree has a real root: it tends to
$+\infty$ as $\lambda \to +\infty$ and to $-\infty$ as $\lambda \to -\infty$, so by the
intermediate value theorem it vanishes somewhere. Let $a$ be such a root; then $aI - M$ is
singular and any nonzero kernel vector $v$ satisfies $Mv = av$. If additionally $L_M$ is injective
and $a = 0$, then $L_M(v) = 0 = L_M(0)$ forces $v = 0$, a contradiction; hence $a \ne 0$.
$\square$

**Proposition 10.2 (Parity is essential).** In the even dimension $2$ the quarter-turn layer
$$M = \begin{pmatrix} 0 & -1 \\ 1 & 0 \end{pmatrix}$$
has no invariant percept direction at all.

*Proof.* Suppose $Mv = av$ with $v \ne 0$. The two coordinates read $-v_2 = a v_1$ and
$v_1 = a v_2$. Substituting, $-v_2 = a^2 v_2$, i.e. $(1 + a^2) v_2 = 0$, so $v_2 = 0$ since
$1 + a^2 > 0$; symmetrically $v_1 = 0$. Hence $v = 0$, a contradiction. $\square$

**Interpretation.** An odd-dimensional perception system always has at least one *stable
perceptual mode*: a direction in percept space that the layer merely rescales rather than
rotating into other channels. This is a structural guarantee with no analogue in even dimensions,
where the whole state space can be rotated with no fixed axis. For the eleven-channel design
this means: however the weights are learned, there is always a percept pattern the layer
preserves in shape, and (for a lossless layer) preserves with nonzero gain. The existence of such
a mode is a useful diagnostic handle — it is a canonical direction along which the layer's
behaviour is one-dimensional and completely transparent.

---

## 11. Exact numerical experiments

All experiments below are exact rational computations, so no floating-point tolerance is
involved.

**Experiment 1: the collision one unit below the optimum.** Build the $21$-unit layer with all
$11$ positive detectors $x \mapsto \mathrm{relu}(x_j)$ but only $10$ negative detectors
$x \mapsto \mathrm{relu}(-x_j)$, $j = 1,\dots,10$ — the negative detector of channel $11$ is
missing. Take
$$x_A = (0,\dots,0,-1), \qquad x_B = (0,\dots,0,-2).$$
Every unit outputs $0$ at both percepts: the positive detectors see nonpositive values, and the
present negative detectors see zero. So the layer maps $x_A$ and $x_B$ to the same point, while
$x_A \ne x_B$. This is a fully explicit certificate that $21$ units do not suffice, complementing
the abstract lower bound.

**Experiment 2: frame ratios.** For the optimal $22$-unit split layer $\Phi$ define the squared
expansion ratio $\rho(x,y) = \|\Phi(x)-\Phi(y)\|^2 / \|x-y\|^2$. With $e_0$ the first basis
vector, $v_1 = (j-5)_{j=0}^{10}$ and $v_2 = ((j-3)(-1)^j)_{j=0}^{10}$:

| pair | $\rho$ |
|---|---|
| $(e_0, -e_0)$ | $1/2$ |
| $(e_0, 0)$ | $1$ |
| $(v_1, v_2)$ | $61/102 \approx 0.598$ |
| $(v_1, -v_1)$ | $1/2$ |
| $(v_2, 0)$ | $1$ |

Every value lies in $[1/2, 1]$, as Theorems 5.2–5.3 require; the extremes $1/2$ and $1$ are both
attained, confirming sharpness (Theorem 5.5). Note the pattern: antipodal pairs realise the
minimum $1/2$ exactly, comparisons with the origin realise the maximum $1$, and generic pairs sit
strictly between.

**Experiment 3: activation counts.** For the split layer, count the strictly active units at $x$
and at $-x$. For $v_1$ and $v_2$ (both of which have a zero coordinate) the counts are $(10,10)$;
for the strictly positive percept $x = (1,2,\dots,11)$ the counts are $11$ and $11$. The latter is
Theorem 7.1 in action — a perfectly balanced partition into two blocks of $11$ — and the former
shows that the balance requires *generic* probes: a percept with a vanishing coordinate leaves
one unit inactive on both sides, which is exactly why the general theorems quantify over
transverse probe directions and use far-field probes rather than arbitrary ones.

---

## 12. Discussion

### 12.1 Practical readings

**Set the interface width from the input dimension, not from folklore.** For an $n$-dimensional
input, a rectified first layer of width $< 2n$ is provably lossy, and no downstream capacity
recovers the loss. Width $2n$ is achievable with a linear decoder and condition number $\sqrt2$.
The interval $[n, 2n)$ — precisely the range that dimension-counting intuition suggests is safe —
is entirely infeasible.

**Losslessness at the optimum implies no prunable units.** Structured pruning of a first layer
that sits at the threshold cannot preserve losslessness, and Theorem 7.2 rules out the usual
targets of pruning heuristics (dead units, constant units, zero rows): at the optimum there are
none.

**Bounded conditioning is available for free.** The split layer's frame bounds are absolute,
uniform in the percept, and independent of any learned parameter. Architectures that route the
raw percept through a split encoder alongside a learned branch enjoy a certified reconstruction
path with worst-case noise amplification $\sqrt2$.

**Beware of over-symmetrising.** Full hyperoctahedral equivariance reduces the linear stage to one
scalar. Any architecture that imposes both permutation and reflection symmetry on its channels
must obtain all of its cross-channel expressivity elsewhere.

### 12.2 Relation to the general picture

The factor $2$ in the width law is a manifestation of one-sidedness that recurs throughout the
theory of nonnegative and rectified representations: recovering a signed quantity from
nonnegative measurements requires representing both signs. The split identity
$\mathrm{relu}(t) - \mathrm{relu}(-t) = t$ is the minimal instance; the frame constant $1/2$ is
the price of not recording the cross term across a sign change. Theorem 7.1 shows that this is
not merely one convenient construction but the *forced* shape of any optimum.

### 12.3 Limitations

The width law concerns a single rectified layer with arbitrary weights and biases; it does not
address quantisation, noise in the units, or approximate (rather than exact) losslessness. The
frame bounds are proved for the canonical split optimum, not for every optimum; whether all
optima share the constants $1/2$ and $1$ is precisely the content of the uniqueness conjecture
below. The equivariance results concern the linear part of a layer; nonlinear equivariant maps
are strictly richer.

### 12.4 Open problems

**Conjecture A (Uniqueness of the bias-free optimum up to symmetry).** Let $W$ be a
$22\times 11$ real matrix with zero bias such that $x \mapsto \mathrm{relu}(Wx)$ is injective.
Then there are a permutation $\pi$ of the $22$ units, positive scalars $c_i > 0$, and an
invertible $A \in GL_{11}(\mathbb{R})$ such that $w_{\pi(i)} = c_i \, A e_i$ for $i \le 11$ and
$w_{\pi(i)} = -c_i\, A e_{i-11}$ for $i > 11$: every optimal architecture is a reparametrised
positive/negative split. The balanced-activation theorem supplies the missing combinatorial
input — two disjoint spanning blocks of size exactly $11$ — and the remaining step is a
sign-pattern classification in finite-dimensional linear algebra. A single injective bias-free
$22 \times 11$ layer whose rows are not of this form would refute it.

**Conjecture B (Stability of the width law).** For every $m \ge 22$ there is an injective
rectified layer $\mathbb{R}^{11} \to \mathbb{R}^m$ whose lower frame constant satisfies
$\alpha \ge \tfrac12 + c\,(m-22)/m$ for an absolute $c > 0$, and no injective layer of width $m$
achieves $\alpha > \tfrac12 + C(m-22)/m$. In particular the optimal condition number $\sqrt2$ at
$m = 22$ improves *continuously* with excess width rather than discontinuously.

**Further directions.** (i) Approximate losslessness: how many units are needed for a layer that
is injective on a $\delta$-net, or bi-Lipschitz with a prescribed constant? (ii) Tensor structure:
Theorem 8.1 ignores the tensor structure of order-$k$ percepts; can a layer that is *required* to
respect the tensor factorisation still meet the bound $2\cdot 11^k$, or does structure impose a
strictly larger cost? (iii) Equivariant optima: what is the least width of a lossless layer that
is additionally $S_{11}$-equivariant, or $B_{11}$-equivariant, as a nonlinear map? (iv) Other
activations: leaky rectifiers with slope $\lambda \in (0,1)$ are injective at width $n$, so the
threshold jumps from $n$ to $2n$ exactly at $\lambda = 0$; quantifying the conditioning as
$\lambda \downarrow 0$ interpolates between the two regimes. (v) Invariant modes: can the
invariant percept direction guaranteed in odd dimensions be located stably, and does it carry
interpretable meaning in trained systems?

---

## 13. Summary of results

| Result | Statement |
|---|---|
| Width lower bound | A lossless rectified layer on $\mathbb{R}^n$ has $\ge 2n$ units |
| Width upper bound | The split layer $x \mapsto (x^+,x^-)$ is lossless with $2n$ units and a linear decoder |
| Exact law, $n=11$ | $22$ is the least lossless width |
| Frame bounds | $\tfrac12\|x-y\|^2 \le \|\Phi^{\mathrm{split}}(x)-\Phi^{\mathrm{split}}(y)\|^2 \le \|x-y\|^2$ |
| Sharpness | Both constants attained; condition number exactly $\sqrt2$; antipodes are the worst case |
| Balanced activation | At width exactly $2n$, two probes partition the units into blocks of exactly $n$ |
| Essentiality | At width exactly $2n$, every unit has a nonzero weight row |
| Depth | First layer narrower than $2n$ $\Rightarrow$ the whole network is lossy, at any depth |
| Depth (positive) | Towers of split layers stay lossless |
| Tensors | Order-$k$ percepts need exactly $2\cdot11^k$ units: $22,\,242,\,2662$ |
| Permutation equivariance | Exactly the two-parameter form $a x + b(\sum_j x_j)\mathbf1$, parameters unique |
| Hyperoctahedral equivariance | Exactly $x \mapsto a x$; no channel swap is realisable |
| Parity dividend | Every linear layer on $\mathbb{R}^{11}$ has an invariant percept direction |
| Parity is essential | The planar quarter-turn has none |
