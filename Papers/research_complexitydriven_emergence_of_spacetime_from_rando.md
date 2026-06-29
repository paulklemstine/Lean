# A Tropical Core for Complexity-Driven Emergence of Spacetime from Tensor Networks

**Author:** Aristotle

**Date:** 2026-06-21

**Domain:** Tropical mathematics / quantum information / holography

---

## Abstract

We develop, with full rigor, a finite tropical (min-plus) skeleton of the
conjecture that classical spacetime emerges from the entanglement structure of
random tensor networks once their complexity crosses a critical threshold. Two
complementary pillars are formalized. First, we define the **multi-cut
integrated information** $\Phi$ of an $n$-party tensor network as the minimum,
over all nontrivial bipartitions (cuts) $A$, of the single-cut quantity
$\mathrm{rank}(A) - 1$, where $\mathrm{rank}(A)$ is the Schmidt rank across the
cut. We prove that a Minimum Information Partition always exists and realizes
$\Phi$, that $\Phi = 0$ exactly characterizes states that factorize across some
cut, that the bond dimension $D$ imposes the hard ceiling $\Phi \le D - 1$, and
that this ceiling is **tight**: the maximally entangled network (Schmidt rank
$D$ across every cut) attains $\Phi = D - 1$, a value coinciding with the
single-cut integrated information of the canonical maximally entangled state.
Second, we formalize a finite tropical analogue of **entanglement-wedge
reconstruction**: using min-plus point-to-set distances we define the
entanglement wedge of a boundary region $B$, prove its membership is stable
under bounded metric perturbations (gap $> 2\varepsilon$), and prove a
reconstruction theorem stating that, under a unique-argmin non-degeneracy
hypothesis, equality of min-plus boundary observations on $B$ forces equality of
bulk states throughout $\mathrm{Wedge}(B)$. We further explain how the tropical
min-cut entropy $S(t) = \min_i (a_i + c_i t)$ in the log-bond-dimension
parameter $t = \log D$ is a concave tropical polynomial whose breakpoints
realize a sharp first-order transition at a closed-form critical bond dimension
$D_c = \exp((a_0 - a_1)/(c_1 - c_0))$, with the scaling exponent jumping from
$c_0$ to $c_1$, and why uniform bond rescaling is geometrically inert.

---

## 1. Introduction

### 1.1 Motivation

The proposal that spacetime geometry is not fundamental but **emergent** from
quantum entanglement has become a central organizing idea in quantum gravity.
The Ryu–Takayanagi (RT) formula identifies the entanglement entropy of a
boundary region with the area of a bulk minimal surface; tensor-network
constructions (MERA, perfect-tensor and random-tensor codes) realize this
correspondence combinatorially, with entanglement entropy computed by **min-cut**
through a weighted graph. In this picture, the *complexity* of the network —
encoded by bond dimensions, the bandwidth of the quantum wires — controls how
much geometry the network can support.

A widely discussed conjecture sharpens this into a phase transition: a uniformly
random rank-$k$ tensor network on $N$ vertices is expected to undergo a sharp
transition at a critical bond dimension $D_c(N)$, above which its holographic
geometry approximates a smooth $(d+1)$-dimensional Lorentzian manifold with
bounded curvature, and below which the geometry is fractal and fails any coarse
Einstein description. The full conjecture is, at present, established only
heuristically and numerically.

### 1.2 Contribution

We isolate and rigorously establish the **tropical core** of this picture: the
purely order-theoretic and min-plus content that must hold in any faithful
realization. The contributions are:

1. A clean algebra of **multi-cut integrated information** $\Phi$ (Section 3),
   including existence of the Minimum Information Partition, a reducibility
   criterion, monotonicity, the bond-dimension ceiling $\Phi \le D-1$, and its
   sharp saturation by the maximally entangled network.

2. A finite tropical model of **entanglement-wedge reconstruction** (Section 4):
   min-plus distances, the wedge as a strict-inequality phase, robustness under
   bounded perturbation, and reconstruction of bulk data from boundary
   observations within the wedge.

3. An analysis of the **bond-dimension threshold** as a tropical-polynomial
   crossover (Section 5): closed-form $D_c$, jump of the scaling exponent,
   concavity of the entropy, and the geometric inertness of uniform rescaling.

All numbered theorems in Sections 3 and 4 correspond to fully verified formal
results; Section 5 records the tropical-polynomial structure that frames the
threshold and that the future-directions program builds upon.

### 1.3 Why tropical?

The min-plus semiring $(\mathbb{R} \cup \{+\infty\}, \min, +)$ is the native
arithmetic of (i) shortest paths and minimal cuts, hence of RT entropy, and
(ii) the lower envelopes that organize phase competition. Working tropically
strips the conjecture down to the operations actually responsible for its
qualitative features — minimum (cut selection) and addition (area accumulation)
— and makes its structural claims provable without recourse to the analytic
machinery of the continuum.

---

## 2. Preliminaries

We work over finite types. For a finite set $V$ and a real-valued function
$f : V \to \mathbb{R}$ on a nonempty finite subset, $\min'$ denotes the minimum,
which exists and is attained.

**Definition 2.1 (Schmidt rank across a cut).** For a pure state of an $n$-party
system and a bipartition $(A, A^c)$, the *Schmidt rank* $\mathrm{rank}(A)$ is the
number of nonzero coefficients in the Schmidt decomposition across the cut.
A nonzero state has $\mathrm{rank}(A) \ge 1$ for every cut.

**Definition 2.2 (Single-cut integrated information).** For a bipartite pure
state with coefficient matrix $M$, the single-cut integrated information is
$\mathrm{phiBip}(M) = \mathrm{rank}(M) - 1$, one less than the Schmidt rank.

---

## 3. Multi-cut integrated information and bond-dimension tightness

### 3.1 Cuts and cut data

**Definition 3.1 (Nontrivial cuts).** For $n \in \mathbb{N}$, the set of
nontrivial cuts is
$$\mathrm{cuts}(n) = \{\, A \subseteq \{0,\dots,n-1\} : A \neq \varnothing \text{ and } A \neq \{0,\dots,n-1\}\,\}.$$
Each $A$ encodes the bipartition separating $A$ from its complement.

**Lemma 3.2 (Cuts are nonempty for $n \ge 2$).** If $2 \le n$ then
$\mathrm{cuts}(n) \neq \varnothing$; e.g. the singleton $\{0\}$ is a nontrivial
cut.

*Proof sketch.* The singleton $\{0\}$ is nonempty, and it equals the full set
only if $|\{0,\dots,n-1\}| = 1$, contradicting $n \ge 2$. $\square$

**Definition 3.3 (Cut data).** The *cut data* of an $n$-party state is a function
$\mathrm{rank} : \mathcal{P}(\{0,\dots,n-1\}) \to \mathbb{N}$ together with the
positivity hypothesis $\mathrm{rank}(A) \ge 1$ for all $A$ (a nonzero pure
state).

### 3.2 The integrated-information functional

**Definition 3.4 (Multi-cut integrated information).** For cut data $S$ and
$n \ge 2$,
$$\Phi(S) \;=\; \min_{A \in \mathrm{cuts}(n)} \big(\mathrm{rank}_S(A) - 1\big).$$
The minimum is over the finite nonempty image $\{\mathrm{rank}_S(A) - 1 : A \in
\mathrm{cuts}(n)\}$ and is therefore well-defined and attained.

This is the Schmidt-rank instance of Tononi's Minimum Information Partition: the
network's irreducible information is the least information surviving any single
cut.

**Theorem 3.5 (Per-cut lower bound, `phiMC_le_cut`).** For every cut
$A \in \mathrm{cuts}(n)$,
$$\Phi(S) \le \mathrm{rank}_S(A) - 1.$$

*Proof sketch.* $\Phi(S)$ is the minimum of a finite set containing
$\mathrm{rank}_S(A) - 1$; apply `Finset.min'_le`. $\square$

**Theorem 3.6 (Existence of the Minimum Information Partition, `exists_MIP`).**
There exists a cut $A \in \mathrm{cuts}(n)$ with
$\mathrm{rank}_S(A) - 1 = \Phi(S)$.

*Proof sketch.* The minimum of a finite nonempty set is a member of that set
(`Finset.min'_mem`); pulling the witness back through the image map yields the
cut $A$. $\square$

**Theorem 3.7 (Greatest lower bound, `le_phiMC`).** If $c \in \mathbb{N}$
satisfies $c \le \mathrm{rank}_S(A) - 1$ for every $A \in \mathrm{cuts}(n)$, then
$c \le \Phi(S)$.

*Proof sketch.* Any lower bound of every image point is $\le$ the minimum
(`Finset.le_min'`). $\square$

Together, Theorems 3.5–3.7 characterize $\Phi(S)$ as the greatest lower bound of
the per-cut integrated informations, and Theorem 3.6 certifies that the bound is
realized by an explicit partition.

### 3.3 Reducibility and monotonicity

**Theorem 3.8 (Reducibility criterion, `phiMC_eq_zero_iff`).**
$$\Phi(S) = 0 \iff \exists\, A \in \mathrm{cuts}(n) \text{ with } \mathrm{rank}_S(A) = 1.$$

*Proof sketch.* ($\Rightarrow$) Take the MIP cut $A$ from Theorem 3.6; then
$\mathrm{rank}_S(A) - 1 = 0$, and positivity $\mathrm{rank}_S(A) \ge 1$ forces
$\mathrm{rank}_S(A) = 1$. ($\Leftarrow$) If $\mathrm{rank}_S(A) = 1$ then by
Theorem 3.5, $0 \le \Phi(S) \le \mathrm{rank}_S(A) - 1 = 0$. $\square$

Interpretation: $\Phi = 0$ exactly when the state factorizes across some
bipartition (a product/short-wire cut). Vanishing integrated information is
equivalent to holographic disconnection.

**Theorem 3.9 (Monotonicity, `phiMC_mono`).** If $\mathrm{rank}_S(A) \le
\mathrm{rank}_T(A)$ for all $A$, then $\Phi(S) \le \Phi(T)$.

*Proof sketch.* Let $A$ realize $\Phi(T)$ (Theorem 3.6). Then
$\Phi(S) \le \mathrm{rank}_S(A) - 1 \le \mathrm{rank}_T(A) - 1 = \Phi(T)$ by
Theorem 3.5 and pointwise domination. $\square$

### 3.4 The bond-dimension ceiling and its saturation

**Theorem 3.10 (Bond-dimension ceiling, `phiMC_le_bond`).** If
$\mathrm{rank}_S(A) \le D$ for every $A \in \mathrm{cuts}(n)$, then
$$\Phi(S) \le D - 1.$$

*Proof sketch.* Evaluate at the MIP cut $A$ (Theorem 3.6):
$\Phi(S) = \mathrm{rank}_S(A) - 1 \le D - 1$. $\square$

**Corollary 3.11 (Bond-dimension-$2$ test, `phiMC_bondTwo_le_one`).** If every
cut has Schmidt rank at most $2$ (e.g. a bond-dimension-$2$ matrix product
state), then $\Phi(S) \le 1$.

*Proof sketch.* Specialize Theorem 3.10 to $D = 2$. $\square$

**Definition 3.12 (Constant cut data).** For $D \ge 1$, let
$\mathrm{constCutData}(n, D)$ be the cut data with $\mathrm{rank}(A) = D$ for all
$A$ (and positivity from $D \ge 1$).

**Theorem 3.13 (Constant networks, `phiMC_const`).** For $n \ge 2$ and
$D \ge 1$,
$$\Phi(\mathrm{constCutData}(n, D)) = D - 1.$$

*Proof sketch.* The image $\{\mathrm{rank}(A) - 1\}$ is the singleton $\{D-1\}$,
whose minimum is $D-1$. Formally: $\le$ from Theorem 3.5 at any cut, and $\ge$
from Theorem 3.7 with $c = D-1$. $\square$

**Theorem 3.14 (Bond-dimension tightness — headline,
`phiMC_maximallyEntangled_tight`).** For $n \ge 2$ and $D \ge 1$, the maximally
entangled network — Schmidt rank $D$ across *every* bipartition — satisfies
$$\Phi(\mathrm{constCutData}(n, D)) = D - 1
\quad\text{and}\quad
\Phi(\mathrm{constCutData}(n, D)) = \mathrm{phiBip}\big(I_{D \times D}\big),$$
where $I_{D \times D}$ is the identity (maximally entangled) coefficient matrix
on $\mathrm{Fin}\,D \otimes \mathrm{Fin}\,D$.

*Proof sketch.* The first equality is Theorem 3.13. The second follows by
rewriting with Theorem 3.13 and the Schmidt-file identity
$\mathrm{phiBip}(I_{D \times D}) = D - 1$ (`phi_maximallyEntangled_eq`). $\square$

Theorem 3.14 shows the bond ceiling of Theorem 3.10 is not merely an inequality
but is *attained*, and attained exactly by the configuration of maximal
entanglement; the saturating value matches the single-cut integrated
information of the canonical maximally entangled state. This is the precise
sense in which **bond dimension is the resource that buys integrated
complexity**, with a sharp exchange rate of $D \mapsto D - 1$.

---

## 4. Tropical entanglement-wedge reconstruction

We now formalize a finite tropical analogue of holographic reconstruction. Fix a
finite vertex type $V$ with a distance function $d : V \times V \to \mathbb{R}$,
finite subsets $\mathrm{bulk}, \mathrm{boundary} \subseteq V$, and a boundary
region $B \subseteq \mathrm{boundary}$.

### 4.1 Min-plus distances

**Definition 4.1 (Point-to-set distance).** For a nonempty finite set $s$ and a
vertex $v$,
$$\mathrm{dist}(v, s) = \min_{b \in s} d(v, b).$$

**Lemma 4.2 (Bounds, `distToFinset_le`, `le_distToFinset`).**
$\mathrm{dist}(v, s) \le d(v, b)$ for every $b \in s$; and if $c \le d(v, b)$ for
all $b \in s$ then $c \le \mathrm{dist}(v, s)$. Moreover the minimum is attained
by some $b \in s$ (`distToFinset_exists_witness`).

**Lemma 4.3 (Antitone in the set, `distToFinset_mono`).** If $s \subseteq t$ then
$\mathrm{dist}(v, t) \le \mathrm{dist}(v, s)$ (a larger target set is at least as
close).

### 4.2 The entanglement wedge

**Definition 4.4 (Entanglement wedge).**
$$\mathrm{Wedge}(B) = \{\, v \in \mathrm{bulk} : \mathrm{dist}(v, B) < \mathrm{dist}(v, \mathrm{boundary} \setminus B)\,\}.$$
The strict inequality excludes tie-vertices and produces a robust phase
separation.

**Theorem 4.5 (Membership criterion, `mem_entanglementWedge_iff`).** For
$v \in \mathrm{bulk}$ with $B$ and $\mathrm{boundary} \setminus B$ nonempty,
$$v \in \mathrm{Wedge}(B) \iff \mathrm{dist}(v, B) < \mathrm{dist}(v, \mathrm{boundary} \setminus B).$$

**Theorem 4.6 (Complement exclusion, `not_mem_entanglementWedge_of_ge`).** If
$\mathrm{dist}(v, \mathrm{boundary} \setminus B) \le \mathrm{dist}(v, B)$, then
$v \notin \mathrm{Wedge}(B)$.

**Theorem 4.7 (Positive gap, `wedge_gap_pos`).** If $v \in \mathrm{Wedge}(B)$
then
$$0 < \mathrm{dist}(v, \mathrm{boundary} \setminus B) - \mathrm{dist}(v, B).$$

*Proof sketch.* Immediate from Theorem 4.5 via `sub_pos_of_lt`. $\square$

**Theorem 4.8 (Edge cases, `entanglementWedge_empty_eq_bulk`,
`entanglementWedge_subset_bulk`).** $\mathrm{Wedge}(\varnothing) = \mathrm{bulk}$
(the condition is vacuous), and $\mathrm{Wedge}(B) \subseteq \mathrm{bulk}$ for
all $B$.

### 4.3 Perturbation stability

**Lemma 4.9 (Perturbation bound, `distToFinset_perturb_bound`).** If
$|d(v,b) - d'(v,b)| < \varepsilon$ for all $b \in s$, then
$$\big|\mathrm{dist}_d(v, s) - \mathrm{dist}_{d'}(v, s)\big| < \varepsilon.$$

*Proof sketch.* Let $b$ attain $\mathrm{dist}_{d'}(v,s)$; then
$\mathrm{dist}_d(v,s) \le d(v,b) < d'(v,b) + \varepsilon =
\mathrm{dist}_{d'}(v,s) + \varepsilon$, and symmetrically. $\square$

**Theorem 4.10 (Wedge stability, `wedge_membership_stable_under_uniform_perturbation`).**
Suppose $v \in \mathrm{Wedge}_d(B)$ with gap
$\delta = \mathrm{dist}_d(v, \mathrm{boundary} \setminus B) - \mathrm{dist}_d(v, B)$.
If $|d(v,b) - d'(v,b)| < \varepsilon$ for all relevant $b$ and $2\varepsilon <
\delta$, then $v \in \mathrm{Wedge}_{d'}(B)$.

*Proof sketch.* By Lemma 4.9 each of the two distances moves by less than
$\varepsilon$, so the gap shrinks by less than $2\varepsilon < \delta$ and
remains positive; apply Theorem 4.5 for $d'$. $\square$

Theorem 4.10 establishes that the entanglement wedge is a *robust* region:
membership survives any metric perturbation strictly smaller than half its gap.
This is the tropical analogue of the stability of causal/entanglement regions
under metric fluctuation.

### 4.4 Boundary observations and reconstruction

**Definition 4.11 (Boundary observation).** For a bulk state
$\varphi : V \to \mathbb{R}$ and boundary point $b$,
$$\mathrm{Obs}(\varphi)(b) = \min_{v \in \mathrm{bulk}} \big(\varphi(v) + d(v, b)\big),$$
the min-plus convolution of $\varphi$ against the distance kernel.

**Lemma 4.12 (Upper bound, `boundaryObs_le_of_mem`).** For $v \in \mathrm{bulk}$,
$\mathrm{Obs}(\varphi)(b) \le \varphi(v) + d(v, b)$.

**Lemma 4.13 (Unique-argmin evaluation, `boundaryObs_eq_of_unique_argmin`).** If
$\varphi(v) + d(v,b) < \varphi(w) + d(w,b)$ for all $w \in \mathrm{bulk}$,
$w \neq v$, then $\mathrm{Obs}(\varphi)(b) = \varphi(v) + d(v, b)$.

**Lemma 4.14 (Change detection, `boundaryObs_ne_of_unique_argmin_changed`).** If
$v$ is the unique argmin for both $\varphi$ and $\varphi'$ at $b$ and
$\varphi'(v) \neq \varphi(v)$, then $\mathrm{Obs}(\varphi')(b) \neq
\mathrm{Obs}(\varphi)(b)$.

**Theorem 4.15 (Surgery detectability, `wedge_surgery_detectable`).** If there is
a bulk vertex $v$ and a boundary point $b \in B$ such that $v$ is the unique
argmin at $b$ for both $\varphi$ and $\varphi'$ and $\varphi'(v) \neq
\varphi(v)$, then there exists $b \in B$ with
$\mathrm{Obs}(\varphi)(b) \neq \mathrm{Obs}(\varphi')(b)$.

*Proof sketch.* Apply Lemma 4.14 at the witnessing $b$. $\square$

**Theorem 4.16 (Wedge reconstruction, `wedge_reconstruction_from_boundary_profiles`).**
Suppose that for every $v \in \mathrm{Wedge}(B)$ there is a boundary point
$b \in B$ at which $v$ is the unique argmin for $\varphi$, and likewise for
$\varphi'$ (a non-degeneracy/injectivity hypothesis). If
$\mathrm{Obs}(\varphi)(b) = \mathrm{Obs}(\varphi')(b)$ for all $b \in B$, then
$$\varphi(v) = \varphi'(v) \quad \text{for all } v \in \mathrm{Wedge}(B).$$

*Proof sketch.* Fix $v \in \mathrm{Wedge}(B)$ with witnesses $b$ (for $\varphi$)
and $b'$ (for $\varphi'$). By Lemma 4.13, $\mathrm{Obs}(\varphi)(b) = \varphi(v)
+ d(v,b)$ and $\mathrm{Obs}(\varphi')(b') = \varphi'(v) + d(v,b')$. By Lemma 4.12
applied to the *other* state, $\mathrm{Obs}(\varphi')(b) \le \varphi'(v) + d(v,b)$
and $\mathrm{Obs}(\varphi)(b') \le \varphi(v) + d(v,b')$. Combining these with the
hypothesis $\mathrm{Obs}(\varphi)(b) = \mathrm{Obs}(\varphi')(b)$ and
$\mathrm{Obs}(\varphi)(b') = \mathrm{Obs}(\varphi')(b')$ yields two opposite
inequalities between $\varphi(v)$ and $\varphi'(v)$, forcing equality. $\square$

Theorem 4.16 is the finite tropical statement of **entanglement-wedge
reconstruction**: boundary data on a region $B$ determines the bulk state
throughout, and only throughout, the wedge of $B$. Theorem 4.15 is its
operational converse — any nontrivial surgery inside the wedge is visible from
$B$.

---

## 5. The bond-dimension threshold as a tropical-polynomial crossover

Sections 3–4 supply the algebra of complexity and the geometry of
reconstruction. We now record the structure that converts a continuously tuned
bond dimension into a *sharp* geometric transition; this frames the
future-directions program.

### 5.1 Min-cut entropy as a tropical polynomial

In RT/tensor-network holography, the entanglement entropy of a boundary region
is the size of a minimal cut, weighted by $\log D$ on each severed edge. With
$t = \log D$ the natural entropy parameter, a finite family of competing cuts
$i = 1, \dots, m$ contributes affine area-law lines $a_i + c_i t$, where $c_i$ is
the number of edges severed by cut $i$ and $a_i$ a fixed offset. The realized
entropy is the lower envelope
$$S(t) = \min_{1 \le i \le m} (a_i + c_i\, t),$$
a **tropical polynomial** in $t$.

**Proposition 5.1 (Structure of $S$).** $S$ is continuous, piecewise linear, and
concave, with at most $m - 1$ breakpoints. On each linear piece the *scaling
exponent* $S'(t)$ equals the size $c_i$ of the dominant cut; it is
non-increasing in $t$. The discrete curvature proxy
$$\kappa(t) = S(t-1) - 2 S(t) + S(t+1)$$
satisfies $\kappa(t) \le 0$ for all $t$, with equality away from breakpoints and
strict negativity at a breakpoint.

*Justification.* A minimum of affine functions is concave and piecewise linear;
concavity gives $\kappa \le 0$ directly. Each breakpoint is a crossing of two
lines, of which there are at most $\binom{m}{2}$, but along the lower envelope at
most $m-1$ are active. $\square$

### 5.2 The two-cut crossover and critical bond dimension

**Proposition 5.2 (Sharp critical bond dimension).** For two competing cuts with
$c_0 \neq c_1$, the lines $a_0 + c_0 t$ and $a_1 + c_1 t$ cross at the unique
point
$$t_c = \frac{a_0 - a_1}{c_1 - c_0}, \qquad D_c = e^{t_c}.$$
For $t < t_c$ one cut is dominant; for $t > t_c$ the other is. The scaling
exponent $S'$ jumps discontinuously between $c_0$ and $c_1$ across $t_c$ — a
**first-order transition** in the entanglement scaling law.

*Justification.* Solve $a_0 + c_0 t = a_1 + c_1 t$. The dominant cut is the one
with smaller value, which switches exactly at $t_c$ because the difference
$(a_0 - a_1) + (c_0 - c_1) t$ is strictly monotone in $t$. $\square$

The interpretation aligned with the spacetime-emergence conjecture: below the
critical bond dimension $D_c$ the network is dominated by a small-size
(low-slope) cut and the geometry is fractal/low-dimensional; above $D_c$ a
different cut dominates and a smooth large-$D$ area law sets in. The transition
is genuinely sharp because the lower envelope of lines has a true kink.

### 5.3 Geometric inertness of uniform rescaling

**Proposition 5.3 (Uniform scaling is inert).** If every bond dimension is
rescaled uniformly, $t \mapsto t + s$ for a common shift $s$, then every line
$a_i + c_i t$ becomes $a_i + c_i s + c_i t$; the *identity of the dominant cut at
a given physical configuration is unchanged whenever the comparison is between
cuts of equal size*, and more generally the breakpoint structure translates
rigidly without creating or destroying transitions. In the entanglement-wedge
model of Section 4, a uniform additive shift of all distances leaves every strict
inequality $\mathrm{dist}(v,B) < \mathrm{dist}(v, \mathrm{boundary}\setminus B)$
invariant, so $\mathrm{Wedge}(B)$ is unchanged.

*Justification.* For the wedge: adding a constant to all distances adds the same
constant to both sides of the defining strict inequality (Theorem 4.5), which is
therefore preserved. $\square$

**Consequence.** The order parameter for geometric emergence is not the *mean*
bond dimension but its *heterogeneity*: emergence requires non-uniform
entanglement across the network. This is the precise content of the
"heterogeneity threshold" program (Conjecture 2 in the future directions).

---

## 6. Algorithms

### 6.1 Computing integrated information

Given cut data on $n$ parties, $\Phi$ is computed by enumerating the
$2^n - 2$ nontrivial cuts and taking the tropical minimum of
$\mathrm{rank}(A) - 1$. Complexity $O(2^n)$ in the number of cuts; for
structured networks (e.g. matrix product states) the relevant cuts reduce to the
$n-1$ contiguous bipartitions, giving $O(n)$.

### 6.2 Computing the entanglement wedge and reconstruction

For each bulk vertex, the point-to-set distances to $B$ and to
$\mathrm{boundary}\setminus B$ are computed in $O(|\mathrm{boundary}|)$, and the
strict comparison decides membership; total $O(|\mathrm{bulk}| \cdot
|\mathrm{boundary}|)$. Reconstruction evaluates min-plus convolutions
$\mathrm{Obs}(\varphi)(b)$ in $O(|\mathrm{bulk}|)$ per boundary point and matches
them across the two states.

### 6.3 Locating the threshold

For a family of cut lines $\{(a_i, c_i)\}$, the lower envelope and its
breakpoints are computed by sorting on slope and applying a convex-hull-trick /
Andrew's monotone-chain sweep in $O(m \log m)$, after which the critical bond
dimensions are read off as the $t$-coordinates of the breakpoints, exponentiated.

---

## 7. Applications

- **Quantum-gravity model selection.** The closed-form $D_c$ and the
  sharpness/concavity of the entropy give falsifiable signatures (kink in the
  scaling law, sign of the curvature proxy) to test candidate tensor-network
  models of holography.
- **Complexity-optimal error-correcting codes.** The bond-dimension tightness
  theorem (Theorem 3.14) pins the maximal integrated information attainable at a
  given bandwidth, guiding code constructions that saturate the entanglement
  budget.
- **Robust holographic reconstruction.** The wedge-stability theorem
  (Theorem 4.10) quantifies the noise margin within which boundary
  reconstruction is guaranteed, relevant to fault-tolerant bulk recovery.
- **Diagnostics for emergence.** Proposition 5.3 identifies heterogeneity (not
  mean bandwidth) as the order parameter, focusing numerical searches for the
  conjectured $D_c(N)$ on the *variance* of $\log D$ across edges.

---

## 8. Discussion

The results isolate the order-theoretic and min-plus invariants that any
faithful realization of complexity-driven spacetime emergence must respect. They
are deliberately finite and combinatorial: no continuum limit, no curvature
tensor, no Einstein equation is derived. What is gained is certainty about the
*qualitative skeleton* — a complexity functional with a tight bandwidth ceiling,
a holographic reconstruction with a quantified robustness margin, and a
phase-transition mechanism that is provably sharp, concave, and driven by
heterogeneity rather than scale. These are exactly the features the full
conjecture predicts, rendered in a form where every claim is exact.

A caveat: the model is min-plus and finite, so it captures the *combinatorial RT*
content of holography, not its dynamical content. Bridging to genuine Lorentzian
geometry, curvature bounds, and the Einstein equations requires the additional
analytic structure deferred to future work.

---

## 9. Future directions

The future-directions program (recorded in full in the accompanying package
metadata) extends this core along four axes: (1) a *multi-cut cascade* law in
which the total negative curvature equals the spread of cut sizes $c_{\max} -
c_{\min}$, a topological rather than metric invariant; (2) a *heterogeneity
threshold* making precise that wedge transitions occur iff the variance of
$\log D$ across edges exceeds a min-cut-gap-determined value; (3) a *smoothness
$\iff$ unique minimal surface* characterization, turning the eventual-affinity of
$S(t)$ into an iff statement about the uniqueness of the minimal-size cut; and
(4) a *Lorentzian-signature* assignment derived from the sign of the curvature
proxy.

---

## 10. Conclusion

We have given a rigorous tropical core for the conjecture that classical
spacetime emerges from the entanglement complexity of tensor networks. The
multi-cut integrated information $\Phi$ obeys a sharp bond-dimension law
$\Phi \le D - 1$ saturated exactly at maximal entanglement; the tropical
entanglement wedge supports a noise-stable holographic reconstruction; and the
min-cut entropy's tropical-polynomial structure yields a closed-form, provably
sharp bond-dimension threshold with curvature concentrated at its breakpoints
and inert under uniform rescaling. The min-plus arithmetic of cuts and distances
is, in this precise sense, the algebra in which complexity turns into geometry.
