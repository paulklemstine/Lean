# Structural Theory of One-Variable Max-Plus Tropical Polynomial Functions

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Tropical mathematics

## Abstract

We develop the elementary structural theory of the one-variable max-plus tropical polynomial function over the real numbers,
$$\text{tropPoly}_c(x) = \max_{0 \le i \le d}\bigl(c_i + i\,x\bigr),$$
where $c = (c_0, \dots, c_d)$ is a tuple of real coefficients indexed by $i \in \{0, 1, \dots, d\}$. Building on a single reusable primitive — the finite maximum of a real-valued function on a nonempty finite index set, together with its attainment and upper-bound characterization — we establish the full suite of first-order structural properties of $\text{tropPoly}_c$: each monomial is a pointwise lower bound; the maximum is attained at some index for every input; an upper-bound holds iff it holds monomial-by-monomial; the function is monotone non-decreasing; it is convex in the Jensen sense; the leading (highest-slope) monomial dominates pointwise under a local dominance hypothesis and, more strongly, dominates for all inputs beyond any threshold at which it dominates; and the degree-one and degree-two cases admit explicit closed forms as nested binary maxima. A central methodological theme is that every structural theorem is obtained by a single uniform schema — *reduce a property of the envelope to the same property of each affine constituent, then observe the constituents satisfy it trivially*. We discuss the resulting proof-strategy template, numerical illustrations, algorithmic consequences (corner detection, leading-term thresholds), and connections to convex analysis, optimization, and piecewise-linear neural networks.

## 1. Introduction

Tropical mathematics replaces the field operations $(+, \times)$ of ordinary arithmetic with the **max-plus semiring** operations $(\max, +)$: "addition" is taking the maximum, and "multiplication" is ordinary addition. Under this dictionary, an ordinary monomial $c_i x^i$ — a product of the scalar $c_i$ with $i$ copies of $x$ — becomes the affine expression $c_i + i\,x$, and the sum of monomials becomes their pointwise maximum. The image of a degree-$d$ polynomial is therefore a finite maximum of $d+1$ affine functions whose slopes are the exponents $0, 1, \dots, d$.

Such functions are ubiquitous. They are exactly the value functions of finite-horizon dynamic programs in the $(\max,+)$ algebra; they describe shortest- and longest-path costs; and, in machine learning, a single maxout unit and the ReLU activation are precisely degree-one tropical polynomials. The geometry of tropical polynomial functions — piecewise linearity, convexity, and the eventual dominance of the steepest term — is the geometry that makes these applications tractable.

This paper presents a complete, self-contained elementary theory of the one-variable case. Our emphasis is twofold. First, we give precise statements and proof sketches for every structural property. Second, we extract the *proof strategy* that recurs throughout: a higher-order schema in which a statement about the upper envelope of affine functions is reduced, via an upper-bound characterization, to the same statement about each affine constituent, which then holds trivially because affine functions are simultaneously monotone (for nonnegative slope), convex, and closed under the relevant operations. This schema is itself the reusable artifact — a template for proving facts about maxima of structured families.

All results stated below have been formally verified. The paper is self-contained: every definition, theorem, and proof sketch appears inline.

## 2. The finite-maximum primitive

Let $n \in \mathbb{N}$ and let $f : \{0, 1, \dots, n\} \to \mathbb{R}$ be a real-valued function on the nonempty finite index set of size $n+1$.

**Definition 2.1 (Finite maximum).** Define
$$\text{finMax}(f) = \max_{0 \le i \le n} f(i),$$
the supremum of $f$ over the nonempty finite index set (which is attained, hence a maximum).

The entire downstream theory rests on three facts about $\text{finMax}$.

**Lemma 2.2 (Upper bound, `le_finMax`).** For every index $i$, $\;f(i) \le \text{finMax}(f).$

*Proof sketch.* $f(i)$ is one of the finitely many values over which the supremum is taken, so it cannot exceed it. $\square$

**Lemma 2.3 (Attainment, `exists_finMax_eq`).** There exists an index $i$ with $\;\text{finMax}(f) = f(i).$

*Proof sketch.* A supremum over a nonempty finite set is achieved at one of its members; choose that member. $\square$

**Lemma 2.4 (Upper-bound characterization, `finMax_le_iff`).** For every $y \in \mathbb{R}$,
$$\text{finMax}(f) \le y \quad\Longleftrightarrow\quad \forall i,\; f(i) \le y.$$

*Proof sketch.* ($\Rightarrow$) Combine with Lemma 2.2: $f(i) \le \text{finMax}(f) \le y$. ($\Leftarrow$) If $y$ bounds every value, it bounds their maximum, since the maximum equals some $f(i_0) \le y$ by Lemma 2.3. $\square$

Lemma 2.4 is the pivotal tool: it converts any *upper-bound goal about the maximum* into a *family of upper-bound goals about the individual values*. Every structural theorem below is an application of this reduction.

## 3. The tropical polynomial and its first-order properties

**Definition 3.1 (Tropical polynomial).** Given a degree $d \in \mathbb{N}$ and coefficients $c : \{0, \dots, d\} \to \mathbb{R}$, define the one-variable max-plus tropical polynomial function
$$\text{tropPoly}_c(x) = \text{finMax}\bigl(i \mapsto c_i + i\,x\bigr) = \max_{0 \le i \le d}\bigl(c_i + i\,x\bigr), \qquad x \in \mathbb{R}.$$
Each term $m_i(x) = c_i + i\,x$ is the **$i$-th monomial line**, an affine function of slope $i$ and intercept $c_i$.

The three primitives instantiate immediately.

**Theorem 3.2 (Monomial lower bound, `tropPoly_monomial_le`).** For every $i$ and $x$,
$$c_i + i\,x \le \text{tropPoly}_c(x).$$
*Proof sketch.* Direct instance of Lemma 2.2 with $f(i) = c_i + i\,x$. $\square$

**Theorem 3.3 (Attainment, `tropPoly_eq_monomial`).** For every $x$ there exists $i$ with
$$\text{tropPoly}_c(x) = c_i + i\,x.$$
*Proof sketch.* Direct instance of Lemma 2.3. $\square$

**Theorem 3.4 (Upper-bound characterization, `tropPoly_le_iff`).** For all $x, y$,
$$\text{tropPoly}_c(x) \le y \quad\Longleftrightarrow\quad \forall i,\; c_i + i\,x \le y.$$
*Proof sketch.* Direct instance of Lemma 2.4. $\square$

Theorems 3.2–3.4 are the entire interface used in the remainder of the paper. We never again unfold the maximum directly.

## 4. Monotonicity

**Theorem 4.1 (Monotonicity, `tropPoly_mono`).** If $x \le y$ then $\;\text{tropPoly}_c(x) \le \text{tropPoly}_c(y).$

*Proof sketch.* By Theorem 3.4 it suffices to show $c_i + i\,x \le \text{tropPoly}_c(y)$ for each $i$. The slope $i$ is a natural number, hence $i \ge 0$, so $x \le y$ gives $i\,x \le i\,y$ and thus $c_i + i\,x \le c_i + i\,y$. By Theorem 3.2, $c_i + i\,y \le \text{tropPoly}_c(y)$. Chaining the two inequalities closes the goal. $\square$

The schema is visible: the *envelope* statement (monotonicity of $\text{tropPoly}_c$) is reduced by Theorem 3.4 to a *per-line* statement (monotonicity of each $m_i$), which holds because each line has nonnegative slope.

## 5. Convexity

**Theorem 5.1 (Convexity, Jensen form, `tropPoly_convex`).** For all $x, y, t \in \mathbb{R}$ with $0 \le t \le 1$,
$$\text{tropPoly}_c\bigl(t x + (1-t) y\bigr) \;\le\; t\,\text{tropPoly}_c(x) + (1-t)\,\text{tropPoly}_c(y).$$

*Proof sketch.* By Theorem 3.4, fix $i$ and bound $m_i\bigl(t x + (1-t)y\bigr)$ by the right-hand side. Affinity of $m_i$ gives the exact algebraic split
$$c_i + i\bigl(t x + (1-t)y\bigr) = t\bigl(c_i + i\,x\bigr) + (1-t)\bigl(c_i + i\,y\bigr).$$
Apply Theorem 3.2 to each piece: $c_i + i\,x \le \text{tropPoly}_c(x)$ and $c_i + i\,y \le \text{tropPoly}_c(y)$. Since $t \ge 0$ and $1 - t \ge 0$, multiplying preserves the inequalities, and summing yields
$$t\bigl(c_i + i\,x\bigr) + (1-t)\bigl(c_i + i\,y\bigr) \le t\,\text{tropPoly}_c(x) + (1-t)\,\text{tropPoly}_c(y).$$
This bounds $m_i$ at the blend point by the desired right-hand side; the maximum over $i$ then satisfies the same bound. $\square$

The same template recurs: the envelope inherits convexity because each affine constituent is convex (indeed affine), and the nonnegative blending weights preserve the per-line bounds.

## 6. Leading-term dominance

Write $m_d(x) = c_d + d\,x$ for the **leading monomial**, the line of maximal slope $d$.

**Theorem 6.1 (Pointwise dominance, `tropPoly_eq_leading`).** Fix $x$. If
$$c_i + i\,x \le c_d + d\,x \quad \text{for all } i,$$
then $\;\text{tropPoly}_c(x) = c_d + d\,x.$

*Proof sketch.* Antisymmetry. Upper bound: by Theorem 3.4 with $y = c_d + d\,x$, the hypothesis is exactly the per-line condition, so $\text{tropPoly}_c(x) \le c_d + d\,x$. Lower bound: Theorem 3.2 at $i = d$ gives $c_d + d\,x \le \text{tropPoly}_c(x)$. The two bounds coincide. $\square$

**Theorem 6.2 (Threshold dominance, `tropPoly_eq_leading_threshold`).** Fix a threshold $T$. If
$$c_i + i\,T \le c_d + d\,T \quad \text{for all } i,$$
then for every $x \ge T$,
$$\text{tropPoly}_c(x) = c_d + d\,x.$$

*Proof sketch.* It suffices, by Theorem 6.1, to verify the pointwise dominance hypothesis at $x$. Decompose each side around $T$:
$$c_i + i\,x = (c_i + i\,T) + i\,(x - T), \qquad c_d + d\,x = (c_d + d\,T) + d\,(x - T).$$
The hypothesis controls the first bracket: $c_i + i\,T \le c_d + d\,T$. For the second, since $i \le d$ (as $i$ ranges up to the degree) and $x - T \ge 0$, we have $i\,(x - T) \le d\,(x - T)$. Adding the two inequalities gives $c_i + i\,x \le c_d + d\,x$, which is exactly the hypothesis of Theorem 6.1. $\square$

Theorem 6.2 is the tropical analog of the classical fact that the highest-degree term of a polynomial dominates for large arguments — but sharper: it provides an *explicit threshold* beyond which the leading line is the function exactly, not merely asymptotically. The mechanism is the nonnegative slope gap $d - i \ge 0$, which guarantees that any lead held by $m_d$ at $T$ only widens to the right.

## 7. Explicit low-degree expansions

**Theorem 7.1 (Degree one, `tropPoly_deg1`).** For $c = (c_0, c_1)$ and all $x$,
$$\text{tropPoly}_c(x) = \max\bigl(c_0,\; c_1 + x\bigr).$$
*Proof sketch.* Antisymmetry. ($\le$) By Theorem 3.4, check the two lines: $c_0 + 0\cdot x = c_0$ and $c_1 + 1\cdot x = c_1 + x$, both $\le$ the binary max. ($\ge$) Each branch of the binary max is a monomial value, hence $\le \text{tropPoly}_c(x)$ by Theorem 3.2; take the max. $\square$

This is exactly the graph of a clamped ramp — flat at height $c_0$ until $x = c_0 - c_1$, then slope $1$ — i.e. (a shifted) ReLU.

**Theorem 7.2 (Degree two, `tropPoly_deg2`).** For $c = (c_0, c_1, c_2)$ and all $x$,
$$\text{tropPoly}_c(x) = \max\bigl(c_0,\; \max(c_1 + x,\; c_2 + 2x)\bigr).$$
*Proof sketch.* Identical structure to Theorem 7.1 over the three slopes $0, 1, 2$: the upper bound checks each of the three monomial values against the nested max via Theorem 3.4, and the lower bound bounds each branch of the nested max by $\text{tropPoly}_c$ via Theorem 3.2. $\square$

The degree-two graph is a convex piecewise-linear curve with up to two corners and segment slopes $0, 1, 2$, the steepest of which eventually dominates per Theorem 6.2.

## 8. The proof-strategy schema

The proofs above are striking in their uniformity. Abstracting the common pattern yields a reusable higher-order schema for reasoning about upper envelopes of structured families.

> **Envelope-inheritance schema.** Let $g(x) = \max_{i} m_i(x)$ be a finite maximum of functions $m_i$. To prove that $g$ satisfies an *upper-bound-shaped* property $P$ (monotonicity, convexity, a closed-form upper estimate, etc.):
> 1. **Reduce.** Use the upper-bound characterization ($g \le y \iff \forall i,\; m_i \le y$) to replace the goal about $g$ with a family of goals about each $m_i$.
> 2. **Discharge per constituent.** Prove the reduced goal for each $m_i$, exploiting whatever structure the constituents share (here: affinity, nonnegative slope, the slope ordering $i \le d$).
> 3. **Reassemble (when needed).** For *equalities* (Theorems 6.1, 7.1, 7.2), pair the reduced upper bound with the attainment/lower-bound fact ($m_{i_0} \le g$) and conclude by antisymmetry.

Each theorem in §4–§7 is an instance: monotonicity uses constituent monotonicity (nonnegative slope); convexity uses constituent affinity and weight nonnegativity; leading-term dominance uses the slope gap plus attainment at $i = d$; the low-degree expansions use the finite case-split over slopes. This is precisely the kind of structural pattern that "proof-strategy mining" seeks to surface: a single template that compresses a routine fact about affine functions into a family of theorems about their envelope.

## 9. Algorithms

The structural theory yields directly implementable algorithms.

**Algorithm A (Evaluate / argmax monomial).** Given $c$ and $x$, compute $\text{tropPoly}_c(x)$ and a witnessing index by scanning the $d+1$ monomial values $c_i + i\,x$ and tracking the running maximum and its argument. Correctness is Theorem 3.3 (attainment); complexity $O(d)$ per evaluation.

**Algorithm B (Leading-term threshold).** Given $c$, find a threshold $T$ beyond which $\text{tropPoly}_c \equiv m_d$. For each $i < d$ with $i < d$, the leading line overtakes line $i$ where $c_i + i\,T = c_d + d\,T$, i.e. at $T_i = (c_i - c_d)/(d - i)$; the required threshold is $T = \max_i T_i$ (or $-\infty$ if $c_d$ already dominates everywhere). Correctness is Theorem 6.2; complexity $O(d)$.

**Algorithm C (Corner / break-point enumeration).** The corners of the convex graph are the abscissae where the active monomial changes. They coincide with the vertices of the lower convex hull of the points $(i, -c_i)$; computing that hull (e.g. by Andrew's monotone chain) in $O(d \log d)$ yields the ordered list of corners and the active segment between consecutive corners. This is the constructive content behind a tropical fundamental theorem of algebra (counting corners with slope-jump multiplicity equals $d$), with attainment (Theorem 3.3) identifying which monomials are active.

## 10. Applications

- **Optimization / $(\max,+)$ dynamic programming.** Tropical polynomials are value functions; monotonicity (Theorem 4.1) and convexity (Theorem 5.1) guarantee well-behaved optimization landscapes with no spurious local optima.
- **Piecewise-linear neural networks.** A maxout unit and ReLU are degree-one tropical polynomials (Theorem 7.1); compositions and sums build the expressive piecewise-linear functions realized by deep networks. Leading-term dominance describes asymptotic behavior of a unit, and convexity constrains the geometry of a single layer.
- **Tropical algebraic geometry.** Corners (Algorithm C) are the tropical roots; their count with multiplicity recovers the degree, making classical root-counting a finite convex-hull computation.

## 11. Discussion and future work

The development deliberately routes everything through the finite-maximum primitive (§2) and its upper-bound characterization, so the index type $\{0,\dots,d\}$ is incidental: the same proofs apply to any nonempty finite family of affine functions. This polymorphism is the gateway to several extensions.

1. **A tropical fundamental theorem of algebra.** Formalize the corner locus and prove that the number of corners, weighted by slope-jump, equals the degree — counting tropical roots with multiplicity — via the lower-hull bijection of Algorithm C, using attainment (Theorem 3.3) and the upper-bound characterization (Theorem 3.4) to identify active monomials.

2. **Legendre–Fenchel duality.** Show $\text{tropPoly}_c$ is the max-plus Legendre transform of the coefficient sequence and that essential monomials are the extreme points of the dual; with convexity (Theorem 5.1) already in hand, this connects to the standard biconjugation framework.

3. **Multivariate max-plus polynomials.** Replace the index $\{0,\dots,d\}$ by a finite subset of $\mathbb{N}^k$; monotonicity and convexity lift verbatim because they hold for arbitrary pointwise maxima of affine functions.

4. **Continuity and Lipschitz bounds.** A finite maximum of $L$-Lipschitz functions is $L$-Lipschitz; since each monomial of slope $i \le d$ is $d$-Lipschitz, $\text{tropPoly}_c$ is globally $d$-Lipschitz and continuous, and one may study stability under coefficient perturbation.

5. **Verified tropical/maxout network layers.** Interpret $\text{tropPoly}_c$ as a single maxout/ReLU unit and assemble compositional bounds for layered max-plus networks.

## 12. Conclusion

From one primitive — the finite maximum with its attainment and upper-bound characterization — we obtained the complete first-order structural theory of one-variable max-plus tropical polynomials: monomial bounds, attainment, monotonicity, convexity, pointwise and threshold leading-term dominance, and explicit low-degree forms. Beyond the individual theorems, the recurring envelope-inheritance schema is itself the deliverable: a reusable higher-order template that derives properties of an envelope from the shared structure of its affine constituents.
