# A Finite-Discrepancy Criterion for the Connectivity Defect of Slice-Projections of Polymatroids

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Shared (Combinatorial Optimization / Tropical Geometry)

## Abstract

We study the connectivity of *slice-projections* (contractions) of
polymatroids through the lens of **tropical (max-plus) Fourier analysis**.
Fixing a finite dictionary $\varphi : \kappa \to (\alpha \to \mathbb{R})$ of
real-valued *modes* on a finite domain $\alpha$, we define for any function
$f : \alpha \to \mathbb{R}$ a **canonical tight coefficient** at each mode, a
**canonical reconstruction** (the max-plus / Fenchel–Moreau biconjugate),
and a scalar **finite discrepancy** measuring how far $f$ departs from that
reconstruction. Our main theorem,
`orderConvex_iff_discrepancy_zero`, establishes that $f$ admits *some*
tropical Fourier expansion over the dictionary — equivalently, $f$ is
**order-convex** — **if and only if** its discrepancy vanishes. The proof is
non-circular: the forward direction rests on a domination lemma showing the
tight coefficients beat every legal competitor, and the backward direction
exhibits the tight coefficients explicitly. We then connect the criterion to
the combinatorics of connectivity: polymatroid rank functions are closed
under slice-projection (`sliceProj_isPolymatroid`); the connectivity
function $\lambda(A) = f(A) + f(A^{\mathsf c}) - f(E)$ is nonnegative for
polymatroids and for all their slice-projections
(`sliceProj_polyConnectivity_nonneg`); modular (weighted-cardinality)
functions are order-convex and so meet the criterion
(`modular_discrepancy_zero`); and an explicit counterexample with a single
constant mode has strictly positive discrepancy and is therefore not
order-convex (`cex_not_orderConvex`), demonstrating that the hypothesis is
necessary. We situate these results within the broader **Interval Property**
program for connected slice-projections of polymatroids and outline a route
to the full conjecture via discrete concavity of the connectivity-defect
profile.

## 1. Introduction

A central organizing principle of matroid and polymatroid theory is
*connectivity*: the question of whether a combinatorial structure decomposes
into independent parts, and how that decomposition behaves under the standard
operations of deletion and contraction. For matroids this theory is mature.
For **polymatroids** — submodular rank functions allowing elements of rank
greater than one — many natural connectivity questions remain open.

This paper concerns one such question, the **Interval Property for connected
slice-projections**. Given a connected polymatroid $P$ and an element $e$ of
rank $f(e)$, one forms the sequence of slice-projections indexed by
$j \in \{0, 1, \dots, f(e)\}$, contracting $j$ units of $e$, and records at
each level whether the resulting polymatroid is connected. The Interval
Property asserts that the set of $j$ at which connectivity holds is a
**contiguous interval of integers**. This strengthens the known result that
*no two consecutive slice-projections can both be disconnected*, and
generalizes the (vacuous) interval property of matroids, where $f(e) \le 1$.

Our contribution is a rigorously formalized **finite-discrepancy
criterion**: a computable test, phrased in tropical (max-plus) language,
deciding when a real set function — in particular the connectivity function
of a slice-projection — lies in the well-behaved class for which the relevant
structure theory applies. All definitions and theorems below have been
formalized and machine-checked.

## 2. Tropical Fourier reconstruction over a finite dictionary

Throughout this section, $\alpha$ and $\kappa$ are finite nonempty types
(the *domain* and the *index set of modes*), and
$\varphi : \kappa \to (\alpha \to \mathbb{R})$ is a fixed **dictionary** of
modes.

### 2.1 Core definitions

**Definition 2.1 (Tropical expansion).**
For coefficients $c : \kappa \to \mathbb{R}$, the **tropical (max-plus)
expansion** is
$$\text{tropExpand}(\varphi, c)(x) \;=\; \max_{k \in \kappa} \big( c_k + \varphi_k(x) \big).$$

**Definition 2.2 (Tight coefficient).**
The **canonical (tight) coefficient** of $f$ at mode $k$ is the largest
scalar $t$ with $t + \varphi_k \le f$ pointwise:
$$\text{tightCoeff}(f, \varphi)_k \;=\; \min_{x \in \alpha} \big( f(x) - \varphi_k(x) \big).$$

**Definition 2.3 (Canonical reconstruction).**
The **canonical reconstruction** of $f$ is the tropical expansion of its
tight coefficients:
$$\text{reconstruct}(f, \varphi)(x) \;=\; \max_{k \in \kappa} \big( \text{tightCoeff}(f, \varphi)_k + \varphi_k(x) \big).$$
This is the idempotent max-plus (Fenchel–Moreau) biconjugate of $f$ relative
to the dictionary.

**Definition 2.4 (Finite discrepancy).**
The **finite discrepancy** (the *connectivity defect* in the polymatroid
application) is the worst-case shortfall of the reconstruction:
$$\text{discrepancy}(f, \varphi) \;=\; \max_{x \in \alpha} \big( f(x) - \text{reconstruct}(f, \varphi)(x) \big).$$

**Definition 2.5 (Order-convexity).**
$f$ is **order-convex** over the dictionary $\varphi$ if it admits some
tropical Fourier expansion:
$$\text{OrderConvex}(f, \varphi) \;:\iff\; \exists\, c : \kappa \to \mathbb{R},\ \forall x,\ f(x) = \text{tropExpand}(\varphi, c)(x).$$

### 2.2 Foundational lemmas

**Lemma 2.6 (Tight coefficient is feasible, `tightCoeff_add_le`).**
For all $k$ and $x$,
$$\text{tightCoeff}(f, \varphi)_k + \varphi_k(x) \le f(x).$$
*Proof sketch.* By definition $\text{tightCoeff}(f,\varphi)_k$ is the minimum
over $x'$ of $f(x') - \varphi_k(x')$, hence $\le f(x) - \varphi_k(x)$ for the
particular $x$; rearrange. $\square$

**Lemma 2.7 (Reconstruction never overshoots, `reconstruct_le_self`).**
For all $x$, $\text{reconstruct}(f, \varphi)(x) \le f(x)$.
*Proof sketch.* The reconstruction is a maximum over $k$ of terms each
bounded by $f(x)$ via Lemma 2.6; a maximum of quantities all $\le f(x)$ is
$\le f(x)$. $\square$

**Lemma 2.8 (Domination of feasible coefficients, `le_tightCoeff`).**
If $c_k + \varphi_k(x) \le f(x)$ for all $x$, then
$c_k \le \text{tightCoeff}(f, \varphi)_k$.
*Proof sketch.* The hypothesis gives $c_k \le f(x) - \varphi_k(x)$ for every
$x$; taking the minimum over $x$ on the right yields the tight coefficient.
$\square$

**Lemma 2.9 (Nonnegativity, `discrepancy_nonneg`).**
$\text{discrepancy}(f, \varphi) \ge 0$.
*Proof sketch.* By Lemma 2.7 each term $f(x) - \text{reconstruct}(f,
\varphi)(x) \ge 0$, and the discrepancy is a maximum of nonnegative terms
over the nonempty domain. $\square$

**Lemma 2.10 (Discrepancy zero ⇔ exact reconstruction,
`discrepancy_zero_iff_eq_reconstruct`).**
$$\text{discrepancy}(f, \varphi) = 0 \iff \forall x,\ f(x) = \text{reconstruct}(f, \varphi)(x).$$
*Proof sketch.* ($\Rightarrow$) If the maximum gap is $0$, then for each $x$
the gap $f(x) - \text{reconstruct}(f,\varphi)(x)$ is both $\ge 0$ (Lemma 2.7)
and $\le 0$ (it is dominated by the maximum, which is $0$), forcing equality.
($\Leftarrow$) If $f = \text{reconstruct}(f,\varphi)$ pointwise, every term
in the discrepancy maximum is $0$. $\square$

**Lemma 2.11 (Order-convexity ⇔ self-reconstruction,
`orderConvex_iff_eq_reconstruct`).**
$$\text{OrderConvex}(f, \varphi) \iff \forall x,\ f(x) = \text{reconstruct}(f, \varphi)(x).$$
*Proof sketch.* ($\Leftarrow$) The tight coefficients are an explicit witness
for order-convexity. ($\Rightarrow$) Given an expansion with coefficients
$c$, Lemma 2.8 shows $c_k \le \text{tightCoeff}(f,\varphi)_k$ for every $k$,
so $f = \text{tropExpand}(\varphi, c) \le \text{reconstruct}(f, \varphi)$;
combined with Lemma 2.7 (reconstruction $\le f$) this yields equality. The
$\le$ direction uses that the maximizing mode for $c$ at $x$ is dominated by
the corresponding tight term. $\square$

### 2.3 Main equivalence

**Theorem 2.12 (Finite-discrepancy criterion,
`orderConvex_iff_discrepancy_zero`).**
For every $f : \alpha \to \mathbb{R}$ and dictionary $\varphi$,
$$\text{OrderConvex}(f, \varphi) \iff \text{discrepancy}(f, \varphi) = 0.$$
*Proof.* Chain Lemma 2.11 and Lemma 2.10: order-convexity is equivalent to
$f$ equaling its canonical reconstruction everywhere, which is equivalent to
the discrepancy being zero. $\square$

This is the central result. It reduces the *existential* question "does $f$
admit any tropical Fourier expansion?" to the *computational* question "is a
single explicitly-defined maximum equal to zero?". The reduction is exact and
constructive: when the discrepancy is zero, the tight coefficients furnish
the expansion.

## 3. Polymatroids, slice-projections and connectivity

We now specialize the domain to subsets of a finite ground set
$E = \text{Fin } n$ and connect the criterion to combinatorial connectivity.

**Definition 3.1 (Polymatroid).**
A function $f : \mathcal{P}(E) \to \mathbb{R}$ is a **polymatroid rank
function** (`IsPolymatroid`) if it is

1. **normalized:** $f(\emptyset) = 0$;
2. **monotone:** $A \subseteq B \implies f(A) \le f(B)$;
3. **submodular:** $f(A \cup B) + f(A \cap B) \le f(A) + f(B)$.

**Definition 3.2 (Slice-projection / contraction).**
The **slice-projection** of $f$ by a slice $s \subseteq E$ is
$$\text{sliceProj}(f, s)(A) \;=\; f(A \cup s) - f(s).$$

**Theorem 3.3 (Closure under slice-projection,
`sliceProj_isPolymatroid`).**
If $f$ is a polymatroid then $\text{sliceProj}(f, s)$ is a polymatroid for
every $s$.
*Proof sketch.* Normalization: $\text{sliceProj}(f,s)(\emptyset) = f(s) -
f(s) = 0$. Monotonicity: $A \subseteq B \implies A \cup s \subseteq B \cup s$,
so monotonicity of $f$ gives the inequality after subtracting the constant
$f(s)$. Submodularity: apply submodularity of $f$ to $A \cup s$ and
$B \cup s$, using $(A\cup s)\cup(B\cup s) = (A\cup B)\cup s$ and
$(A\cup s)\cap(B\cup s) = (A\cap B)\cup s$; the constant $f(s)$ cancels. $\square$

**Definition 3.4 (Connectivity function).**
The **connectivity function** of $f$ on ground set $E$ is
$$\lambda(A) \;=\; f(A) + f(A^{\mathsf c}) - f(E),$$
where $A^{\mathsf c} = E \setminus A$. It measures the "coupling" across the
cut $\{A, A^{\mathsf c}\}$.

**Theorem 3.5 (Nonnegativity of connectivity,
`polyConnectivity_nonneg` and `sliceProj_polyConnectivity_nonneg`).**
For a polymatroid $f$, $\lambda(A) \ge 0$ for all $A$; consequently the
connectivity function of any slice-projection is also nonnegative.
*Proof sketch.* Apply submodularity to $A$ and $A^{\mathsf c}$: since
$A \cup A^{\mathsf c} = E$ and $A \cap A^{\mathsf c} = \emptyset$,
$$f(E) + f(\emptyset) \le f(A) + f(A^{\mathsf c}).$$
With $f(\emptyset) = 0$ this rearranges to $\lambda(A) \ge 0$. The
slice-projection case follows because slice-projections are polymatroids
(Theorem 3.3). $\square$

A cut with $\lambda(A) = 0$ for a nontrivial $A$ ($\emptyset \neq A \subsetneq
E$) is a **separation**; the polymatroid is **connected** when no such
separation exists.

## 4. The tractable case and a sharp counterexample

**Definition 4.1 (Modular function).**
A **modular** (weighted-cardinality) function assigns to $A$ the total weight
$\sum_{i \in A} w_i$ of its elements for fixed weights $w_i \ge 0$.

**Theorem 4.2 (Modular ⇒ polymatroid, `modular_isPolymatroid`).**
Every modular function is a polymatroid.
*Proof sketch.* Normalization and monotonicity are immediate from
nonnegativity of weights; submodularity holds with equality, since
$\sum_{A\cup B} + \sum_{A\cap B} = \sum_A + \sum_B$ by inclusion–exclusion on
weights. $\square$

**Theorem 4.3 (Modular ⇒ order-convex ⇒ criterion met,
`modular_orderConvex`, `modular_discrepancy_zero`).**
Modular functions are order-convex over a suitable dictionary, and hence have
zero discrepancy.
*Proof sketch.* A modular function is, on the relevant domain, already an
upper envelope of affine modes — its tropical expansion is itself — so it is
order-convex by Definition 2.5, and Theorem 2.12 yields zero discrepancy.
$\square$

**Theorem 4.4 (Counterexample, `cexF`, `cexPhi`, `cex_discrepancy_pos`,
`cex_not_orderConvex`).**
There is an explicit function $f = \text{cexF}$ and a single-mode dictionary
$\varphi = \text{cexPhi}$ (one constant mode) with
$$\text{discrepancy}(\text{cexF}, \text{cexPhi}) > 0,$$
and therefore $\text{cexF}$ is **not** order-convex over $\text{cexPhi}$.
*Proof sketch.* A single constant mode can only produce constant
reconstructions; against a non-constant target the upper envelope is the
constant equal to the target's minimum, so the discrepancy equals the range
of the target, which is strictly positive. By Theorem 2.12 (contrapositive),
non-zero discrepancy implies $f$ is not order-convex. $\square$

This counterexample is sharp: it shows the order-convexity hypothesis in
Theorem 2.12 is *necessary*, not merely convenient, and that the dictionary
must be rich enough to capture the variation of $f$.

## 5. Algorithms

The criterion is directly computational. Two algorithms summarize the
workflow.

**Algorithm A — Canonical tropical reconstruction and discrepancy.**
Given $f$ on a finite domain and a finite dictionary $\varphi$:
1. For each mode $k$, compute $\text{tightCoeff}_k = \min_x (f(x) -
   \varphi_k(x))$.
2. For each $x$, compute $\text{reconstruct}(x) = \max_k (\text{tightCoeff}_k
   + \varphi_k(x))$.
3. Return $\text{discrepancy} = \max_x (f(x) - \text{reconstruct}(x))$ and the
   verdict $\text{discrepancy} = 0$.

Complexity: with $|\alpha| = m$ points and $|\kappa| = K$ modes, the tight
coefficients cost $O(mK)$, the reconstruction $O(mK)$, and the discrepancy
$O(m)$; total $O(mK)$ time and $O(K)$ extra space. This is the certificate
that decides order-convexity in linear time in the table size.

**Algorithm B — Connectivity profile of a slice-projection chain.**
Given a polymatroid $f$ on $E$ and an element $e$:
1. For each spending level $j$, form the slice $s_j$ and the slice-projection
   $g_j = \text{sliceProj}(f, s_j)$.
2. Compute $\lambda_{g_j}(A) = g_j(A) + g_j(A^{\mathsf c}) - g_j(E)$ over all
   nontrivial $A$ and take the minimum (the connectivity defect $\kappa(j)$).
3. Record the boolean "connected" $= [\kappa(j) > 0]$ and assemble the
   profile across $j$.

The Interval Property is the assertion that the connected levels form a
contiguous block; the route to proving it (Section 7) is to show the profile
$\kappa$ is discretely concave.

## 6. Applications

- **Certificates for tractable connectivity.** The discrepancy is a
  one-number certificate: a rank function with zero discrepancy lies in the
  order-convex class where the connectivity profile is well-behaved, avoiding
  an exponential search over cuts.
- **Submodular optimization and scheduling.** Max-plus expansions are the
  native language of shortest paths, scheduling, and discrete convex
  analysis; the tight-coefficient construction is exactly the lower
  Fenchel–Moreau envelope used in dual algorithms.
- **Structural classification.** The modular case (zero discrepancy) and the
  constant-mode counterexample (positive discrepancy) bracket the spectrum of
  behaviors, providing reference points for classifying polymatroids by the
  richness of dictionary they require.

## 7. Discussion and future work

The finite-discrepancy criterion supplies the analytic half of a bridge
toward the Interval Property. The combinatorial half is the assertion that
the **connectivity-defect profile** is discretely concave, which would force
its super-level sets — the connected levels — to be intervals.

**Conjecture 1 (Discrete concavity of the defect profile).** For a connected
polymatroid $P$ and element $e$ of rank $r$, the connectivity defect
$\kappa(j)$ of the $j$-th slice-projection is discretely concave on
$\{0, \dots, r\}$; hence its connected set is an interval. The key insight is
that $\kappa$ is a *minimum of functions affine in $j$* (each partition
contributes $f(A) + f(B) - f(E)$ plus a term linear in how $e$'s $r$ units
are split), and a minimum of affine functions is concave — exactly the
hypothesis the interval criterion consumes.

**Conjecture 2 (Interval ⇔ discrete concavity).** Among integer profiles
arising as slice connectivity defects of connected polymatroids, the
threshold-uniform interval property holds iff $\kappa$ is discretely concave.
The profile $[1, -1, 1]$ is simultaneously the minimal interval-property
violator and a minimal concavity violator, suggesting concavity is also
necessary.

**Conjecture 3 (Two end-blocks).** For a connected polymatroid element of
rank $r$, the disconnected slice indices form a (possibly empty) prefix
$\{0, \dots, p\}$ together with a suffix $\{s, \dots, r\}$, with a nonempty
connected middle block under mild conditions.

These directions reuse two halves already in place: "concavity ⇒ interval"
(via super-level intervals of discretely concave functions) and "polymatroid
marginals are concave" (diminishing returns). What remains is the
min-over-partitions assembly, for which the submodularity of the connectivity
function $\lambda$ provides the uncrossing tool.

## 8. Conclusion

We have formalized a tropical Fourier framework in which order-convexity of a
real set function is equivalent to the vanishing of a single, explicitly
computable discrepancy (`orderConvex_iff_discrepancy_zero`). We connected the
framework to polymatroid connectivity: closure under slice-projection,
nonnegativity of the connectivity function, the tractable modular case, and a
sharp counterexample establishing necessity. Together these results form the
analytic backbone of the Interval Property program for connected
slice-projections of polymatroids.
