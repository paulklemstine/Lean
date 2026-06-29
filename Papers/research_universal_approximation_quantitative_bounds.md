# Universal Approximation with Quantitative Bounds: Explicit Linear and Quadratic Rates for One-Dimensional ReLU Networks

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Machine Learning Theory)

## Abstract

The classical universal approximation theorem guarantees that neural networks can
approximate continuous functions arbitrarily well, but it is non-quantitative: it
asserts existence without specifying network size or convergence rate. We give a
fully explicit, constructive, and machine-checked refinement for one-dimensional
single-hidden-layer ReLU networks. Fixing a transparent architecture — the
*ramp-difference interpolation network* $\mathrm{reluInterpNet}(f,n,\cdot)$ built
from $2n$ ReLU neurons that reproduces the uniform piecewise-linear interpolant of
$f$ on $[0,1]$ — we prove two sharp regularity-dependent rates. First, for any
$L$-Lipschitz target, the uniform approximation error is at most $L/n$
(`quantitative_uat_core`), yielding the width/error tradeoff $2n = O(1/\varepsilon)$
(`quantitative_uat_width`). Second, and more strikingly, for targets in the Sobolev
class $W^{2,\infty}$ — those with an $M$-Lipschitz derivative — the *same* network
achieves the quadratic rate $M/n^2$ (`sobolev_quadratic_rate`), improving the
width requirement to $2n = O(1/\sqrt{\varepsilon})$ (`sobolev_width_tradeoff`).
The architecture is held fixed throughout; the exponent on $1/n$ is governed
entirely by the smoothness class of the target. The keystone is an exact algebraic
identity (`reluInterpNet_eq_on_cell`) showing the network coincides with the affine
interpolant on every grid cell, after which the error analysis reduces to classical
interpolation estimates. All results are formalized and verified.

## 1. Introduction

The universal approximation theorem (UAT) is a cornerstone of the theory of neural
networks: feedforward networks with a single hidden layer and a non-polynomial
activation are dense in the space of continuous functions on compact sets. As
usually stated, however, the theorem is purely existential. It does not answer the
questions a practitioner actually asks: *how many neurons* are needed for a target
accuracy, and *how does the error decay* as the network grows? Without such
quantitative content, the UAT functions as a reassurance rather than a design
tool.

This paper supplies a quantitative theory in the cleanest possible setting:
scalar functions on the unit interval $[0,1]$, approximated by single-hidden-layer
ReLU networks. The central object is an explicit network that exactly reproduces
the uniform-grid piecewise-linear interpolant of the target. Working with this
concrete construction rather than an abstract existence argument lets us track
constants exactly and prove rate theorems with no hidden dependencies.

Our contributions are:

1. **An exact architectural identity.** The $2n$-neuron ramp-difference network
   equals the affine interpolant on each grid cell (Theorem 1), reducing all
   approximation questions to classical interpolation error analysis.
2. **A linear rate for Lipschitz targets.** Uniform error $\le L/n$ on $[0,1]$
   (Theorem 3), with the explicit width/error tradeoff $2n = O(1/\varepsilon)$
   (Theorem 4).
3. **A quadratic rate for $W^{2,\infty}$ targets.** The *same* network attains
   error $\le M/n^2$ (Theorem 6) when the derivative is $M$-Lipschitz, with the
   improved tradeoff $2n = O(1/\sqrt{\varepsilon})$ (Theorem 7).

The conceptual message is that the *exponent* in the convergence rate is set by
the regularity of the target, not by the architecture, which we hold fixed at a
single hidden layer of $2n$ ramps.

## 2. Definitions

Throughout, $n$ is a positive integer and $f : \mathbb{R} \to \mathbb{R}$ is the
target function, considered on $[0,1]$.

**Definition 1 (ReLU activation, `relu`).**
$$\mathrm{relu}(x) = \max(x, 0).$$

**Definition 2 (Uniform grid, `grid`).** The $k$-th node of the uniform grid is
$$\mathrm{grid}(n,k) = \frac{k}{n}, \qquad k = 0, 1, \dots, n.$$
Consecutive nodes are separated by the cell width $h = 1/n$.

**Definition 3 (Cell slope, `cellSlope`).** The slope of $f$ across cell
$[\tfrac{k}{n}, \tfrac{k+1}{n}]$, normalized by the reciprocal cell width, is
$$\mathrm{cellSlope}(f,n,k) = n\bigl(f(\mathrm{grid}(n,k+1)) - f(\mathrm{grid}(n,k))\bigr).$$

**Definition 4 (Ramp-difference interpolation network, `reluInterpNet`).** The
single-hidden-layer ReLU network with $2n$ ramp neurons is
$$\mathrm{reluInterpNet}(f,n,x) = f(0) + \sum_{k=0}^{n-1} \mathrm{cellSlope}(f,n,k)\,\Bigl(\mathrm{relu}\bigl(x - \mathrm{grid}(n,k)\bigr) - \mathrm{relu}\bigl(x - \mathrm{grid}(n,k+1)\bigr)\Bigr).$$
Each summand uses two ReLU units, for a total hidden width of $2n$.

**Definition 5 (Lipschitz regularity on $[0,1]$, `LipOn01`).** $f$ is
$L$-Lipschitz on $[0,1]$ if
$$\forall x, y \in [0,1], \quad |f(x) - f(y)| \le L\,|x - y|.$$

**Definition 6 (Differentiability on $[0,1]$, `HasDerivOn01`).** $f'$ is a
derivative of $f$ on $[0,1]$ if $f$ has derivative $f'(x)$ at every $x \in [0,1]$.
The Sobolev class $W^{2,\infty}$ condition is that such an $f'$ exists and is
itself $L$-Lipschitz (with constant $M$), i.e. $\mathrm{LipOn01}(f', M)$.

## 3. The ramp-difference primitive

All structure flows from the behavior of a single ramp-difference
$\mathrm{relu}(x-a) - \mathrm{relu}(x-b)$ with $a \le b$.

**Lemma 1 (Ramp profile, `ramp_left`/`ramp_mid`/`ramp_right`).** For $a \le b$:
$$\mathrm{relu}(x-a) - \mathrm{relu}(x-b) = \begin{cases} 0, & x \le a, \\ x - a, & a \le x \le b, \\ b - a, & b \le x. \end{cases}$$

*Proof sketch.* Case-split on the sign of $x-a$ and $x-b$ inside the two maxima.
For $x \le a$ both arguments are non-positive, so both ReLUs vanish. For
$a \le x \le b$ the first ReLU equals $x-a$ and the second vanishes. For $b \le x$
both ReLUs are active and equal $x-a$ and $x-b$ respectively, whose difference is
$b-a$. Each case is a one-line linear arithmetic check. $\square$

Two grid identities are used repeatedly. First, **`grid_succ_sub`**:
$\mathrm{grid}(n,k+1) - \mathrm{grid}(n,k) = 1/n$. Second, **`cellSlope_mul_width`**:
multiplying the cell slope by the cell width recovers the endpoint difference,
$$\mathrm{cellSlope}(f,n,k)\cdot\bigl(\mathrm{grid}(n,k+1) - \mathrm{grid}(n,k)\bigr) = f(\mathrm{grid}(n,k+1)) - f(\mathrm{grid}(n,k)).$$

## 4. The exact identity and the linear rate

The decisive structural fact is that the network is not merely *close* to the
piecewise-linear interpolant — it equals it exactly on each cell.

**Theorem 1 (Cellwise exactness, `reluInterpNet_eq_on_cell`).** Let $0 < n$,
$k < n$, and $x \in [\mathrm{grid}(n,k), \mathrm{grid}(n,k+1)]$. Then
$$\mathrm{reluInterpNet}(f,n,x) = f(\mathrm{grid}(n,k)) + \mathrm{cellSlope}(f,n,k)\,\bigl(x - \mathrm{grid}(n,k)\bigr).$$

*Proof sketch.* Split the defining sum at the index $k$ of the active cell into
three groups. For indices $j < k$, the point $x$ lies to the right of cell $j$, so
by `ramp_right` each ramp-difference saturates to the cell width; multiplied by
the cell slope (via `cellSlope_mul_width`) the term equals
$f(\mathrm{grid}(n,j+1)) - f(\mathrm{grid}(n,j))$, and the sum telescopes to
$f(\mathrm{grid}(n,k)) - f(\mathrm{grid}(n,0)) = f(\mathrm{grid}(n,k)) - f(0)$.
For indices $j > k$, $x$ lies to the left of cell $j$, so by `ramp_left` every
term vanishes. For $j = k$, by `ramp_mid` the ramp-difference equals
$x - \mathrm{grid}(n,k)$, contributing $\mathrm{cellSlope}(f,n,k)(x-\mathrm{grid}(n,k))$.
Adding the base term $f(0)$ cancels the $-f(0)$ from the telescoping sum, leaving
the affine interpolant. $\square$

With exactness in hand, approximation error is purely an interpolation question.

**Lemma 2 (Interpolant error, `interp_error_le`).** If $0 < n$, $k < n$,
$0 \le L$, $\mathrm{LipOn01}(f,L)$, and
$x \in [\mathrm{grid}(n,k), \mathrm{grid}(n,k+1)]$, then
$$\Bigl|\bigl(f(\mathrm{grid}(n,k)) + \mathrm{cellSlope}(f,n,k)(x - \mathrm{grid}(n,k))\bigr) - f(x)\Bigr| \le \frac{L}{n}.$$

*Proof sketch.* Write $t = (x - \mathrm{grid}(n,k))/h \in [0,1]$ with $h = 1/n$.
The affine interpolant is the convex combination
$(1-t)\,f(\mathrm{grid}(n,k)) + t\,f(\mathrm{grid}(n,k+1))$. Hence the error is
$(1-t)\,(f(\mathrm{grid}(n,k)) - f(x)) + t\,(f(\mathrm{grid}(n,k+1)) - f(x))$.
Both grid nodes lie within distance $h = 1/n$ of $x$, so by `LipOn01` each
endpoint deviation is at most $L/n$; the convex combination of two quantities
bounded by $L/n$ is again bounded by $L/n$. $\square$

**Theorem 2 (Cellwise linear rate, `quantitative_uat_cell`).** Under the
hypotheses of Lemma 2,
$$\bigl|\mathrm{reluInterpNet}(f,n,x) - f(x)\bigr| \le \frac{L}{n}.$$

*Proof.* Substitute the exact identity (Theorem 1) into Lemma 2. $\square$

To globalize, every point of $[0,1]$ lies in some cell.

**Lemma 3 (Cell cover, `exists_cell`).** If $0 < n$ and $x \in [0,1]$, there exists
$k < n$ with $x \in [\mathrm{grid}(n,k), \mathrm{grid}(n,k+1)]$. (Take
$k = \lfloor x n\rfloor$, with the endpoint $x = 1$ handled by $k = n-1$.)

**Theorem 3 (Global linear rate, `quantitative_uat_core`).** If $0 < n$,
$0 \le L$, and $\mathrm{LipOn01}(f,L)$, then for all $x \in [0,1]$,
$$\bigl|\mathrm{reluInterpNet}(f,n,x) - f(x)\bigr| \le \frac{L}{n}.$$

*Proof.* Given $x$, choose its cell via Lemma 3 and apply Theorem 2. $\square$

**Theorem 4 (Width/error tradeoff, `quantitative_uat_width`).** If $0 < n$,
$0 \le L$, $\mathrm{LipOn01}(f,L)$, and $L \le \varepsilon\, n$, then for all
$x \in [0,1]$,
$$\bigl|\mathrm{reluInterpNet}(f,n,x) - f(x)\bigr| \le \varepsilon.$$
Consequently a hidden width of $2n = O(1/\varepsilon)$ ReLU neurons suffices to
approximate any $L$-Lipschitz target to uniform accuracy $\varepsilon$.

*Proof.* From Theorem 3 the error is $\le L/n$, and $L \le \varepsilon n$ gives
$L/n \le \varepsilon$. (The constraint $L \le \varepsilon n$ alone forces the
conclusion; positivity of $\varepsilon$ is retained only to match the intended
reading.) $\square$

## 5. The quadratic rate for Sobolev targets

We now improve the exponent — without changing the network — by strengthening the
regularity of the target from Lipschitz ($W^{1,\infty}$) to a Lipschitz derivative
($W^{2,\infty}$).

**Theorem 5 (Cellwise quadratic rate, `sobolev_interp_error_cell`).** Let
$0 < n$, $k < n$, $0 \le M$, suppose $f$ has derivative $f'$ on $[0,1]$
(`HasDerivOn01`) and $\mathrm{LipOn01}(f', M)$. Then for
$x \in [\mathrm{grid}(n,k), \mathrm{grid}(n,k+1)]$,
$$\bigl|\mathrm{reluInterpNet}(f,n,x) - f(x)\bigr| \le \frac{M}{n^2}.$$

*Proof sketch.* By Theorem 1 the network equals the affine interpolant
$p(x) = f(a) + S\,(x-a)$ on the cell $[a,b]$, where $a = \mathrm{grid}(n,k)$,
$b = \mathrm{grid}(n,k+1)$, $h = b - a = 1/n$, and the chord slope is
$S = (f(b) - f(a))/h$. Consider the remainder $e = f - p$. It vanishes at the
left endpoint, $e(a) = 0$, and its derivative is $e'(x) = f'(x) - S$. By the mean
value theorem (`exists_hasDerivAt_eq_slope`) there is an interior point
$c \in (a,b)$ with $S = f'(c)$. Therefore
$$|e'(x)| = |f'(x) - f'(c)| \le M\,|x - c| \le M\,h,$$
using the $M$-Lipschitz bound on $f'$ and $|x - c| \le h$. Thus $e$ is
$(Mh)$-Lipschitz on the cell, and since $e(a) = 0$,
$$|e(x)| = |e(x) - e(a)| \le M h\,|x - a| \le M h \cdot h = M h^2 = \frac{M}{n^2}.$$
$\square$

**Theorem 6 (Global quadratic rate, `sobolev_quadratic_rate`).** Under the same
hypotheses, for all $x \in [0,1]$,
$$\bigl|\mathrm{reluInterpNet}(f,n,x) - f(x)\bigr| \le \frac{M}{n^2}.$$

*Proof.* Cover $[0,1]$ by cells (Lemma 3) and apply Theorem 5 on the cell
containing $x$. $\square$

**Theorem 7 (Improved width/error tradeoff, `sobolev_width_tradeoff`).** To reach
uniform accuracy $\varepsilon$ for a $W^{2,\infty}$ target with second-derivative
bound $M$, it suffices to take $n \ge \sqrt{M/\varepsilon}$, i.e. a hidden width of
$$2n = O\!\left(\frac{1}{\sqrt{\varepsilon}}\right)$$
ReLU neurons — the square root of the $O(1/\varepsilon)$ requirement in the
Lipschitz regime.

*Proof.* By Theorem 6 the error is $\le M/n^2 \le \varepsilon$ whenever
$n^2 \ge M/\varepsilon$. $\square$

## 6. Discussion: regularity, not architecture, sets the rate

Theorems 3 and 6 share an identical network — one hidden layer of $2n$ ReLU
ramps — yet deliver error $O(1/n)$ and $O(1/n^2)$ respectively. The only
difference is the smoothness class of the target: $W^{1,\infty}$ (Lipschitz) versus
$W^{2,\infty}$ (Lipschitz derivative). This isolates a clean principle:

> With the architecture fixed at a single hidden layer of piecewise-linear ramps,
> the *exponent* in the convergence rate is determined by the regularity of the
> target, not by the network.

This perspective sharpens the qualitative UAT into an engineering contract. Given
the regularity of the data — measurable, in principle, from its modulus of
continuity or its second-difference statistics — one reads off the neuron budget
needed for any prescribed accuracy. The linear regime answers "how many ramps for
a rough signal"; the quadratic regime answers "how many for a smooth one," and the
answer is quadratically fewer.

We emphasize what the quadratic theorem does *not* require: it never assumes a
second derivative *exists*. A Lipschitz first derivative ($W^{2,\infty}$) is the
exact hypothesis, strictly weaker than $C^2$, and it is also exactly what the
interpolation remainder argument needs — the mean value theorem produces the chord
slope as a value of $f'$, and Lipschitzness of $f'$ controls the remainder.

We also record an honesty caveat embedded in the formal development: the quadratic
bound is stated with the simple constant $M$ (giving $Mh^2$), not the textbook-sharp
$M/8$ (giving $Mh^2/8$). The sharp constant is achieved by $f(x) = x^2$ at cell
midpoints and is the subject of a future refinement (see Future Directions C1).

## 7. Algorithms

**Algorithm A (Network weight assembly).** Given $f$ and $n$, compute the bias
$b_0 = f(0)$ and, for each cell $k$, the two ramp offsets $k/n, (k+1)/n$ and the
shared coefficient $\mathrm{cellSlope}(f,n,k) = n(f((k+1)/n) - f(k/n))$. The
network is then evaluated by Definition 4. Construction cost is $O(n)$ function
evaluations and the resulting width is $2n$.

**Algorithm B (Cell-localized evaluation).** To evaluate
$\mathrm{reluInterpNet}(f,n,x)$ at a query $x \in [0,1]$ in $O(1)$ after $O(n)$
preprocessing, locate the cell $k = \min(\lfloor xn\rfloor, n-1)$ (Lemma 3) and
return the affine value $f(k/n) + \mathrm{cellSlope}(f,n,k)(x - k/n)$, which equals
the full sum by Theorem 1.

**Algorithm C (Neuron budgeting).** Given a target accuracy $\varepsilon$ and a
regularity certificate, return the required width: $2\lceil L/\varepsilon\rceil$ in
the Lipschitz regime (Theorem 4) or $2\lceil\sqrt{M/\varepsilon}\,\rceil$ in the
$W^{2,\infty}$ regime (Theorem 7).

## 8. Applications

- **A priori network sizing.** For signals with a known Lipschitz or curvature
  bound — band-limited audio, smoothed sensor traces, monotone calibration curves —
  Algorithm C returns a provable neuron budget before any training.
- **Certified surrogates.** When a network replaces an expensive simulator on
  $[0,1]$, Theorems 3 and 6 give worst-case error guarantees, not merely test-set
  estimates.
- **Smoothness as a compression lever.** The quadratic rate quantifies how much
  preprocessing that increases smoothness (filtering, regularization) pays back in
  reduced model size.

## 9. Future directions

The development opens several concrete, falsifiable follow-ups (verbatim from the
project's research notes):

**C1. Sharp interpolation constant $M/(8n^2)$.** For $f$ with $M$-Lipschitz
derivative, the $2n$-ramp network should satisfy error $\le M/(8n^2)$, with the
constant $1/8$ attained in the limit by $f(x) = x^2$. The cellwise error equals the
interpolation remainder $\tfrac12 f''(\xi)(x-a)(x-b)$, maximized at the cell
midpoint where $|(x-a)(x-b)| = h^2/4$, giving $Mh^2/8$ rather than the crude
$Mh^2$. The cell-localization machinery is already in place; only the midpoint
optimization is missing.

**C2. Higher-order Sobolev rates need depth, not just width.** A single-hidden-layer
ReLU network of width $w$ cannot approximate every $f \in W^{s,\infty}$ ($s \ge 3$)
better than rate $w^{-2}$, whereas a depth-$O(\log(1/\varepsilon))$ network achieves
$w^{-s}$. A shallow ReLU function is globally piecewise-linear, so its second-order
finite differences telescope and cannot encode curvature beyond second order; depth
is required to compose the squaring map that bootstraps $x \mapsto x^2$ into higher
monomials.

**C3. Total variation as the universal depth-separation currency.** For every target
$g : [0,1] \to \mathbb{R}$ and accuracy $\varepsilon$, the minimal $L^1$ weight mass
of a shallow ReLU approximant should be $\Theta(\mathrm{TV}(g) - O(\varepsilon))$.
Hence depth-$d$ networks separate from depth-$(d-1)$ networks iff their realizable
functions have super-polynomially larger total variation.

**C4. Multidimensional tent and the curse of dimensionality.** Extending the
tensor-product tent construction to $d$ dimensions, to quantify how the depth
advantage interacts with input dimension.

## 10. Conclusion

By committing to one transparent architecture — the $2n$-neuron ramp-difference
network that exactly reproduces the uniform piecewise-linear interpolant — we
converted the existential universal approximation theorem into explicit
quantitative law. The same network approximates any $L$-Lipschitz function on
$[0,1]$ to error $L/n$ and any $W^{2,\infty}$ function to error $M/n^2$, with
correspondingly $O(1/\varepsilon)$ and $O(1/\sqrt{\varepsilon})$ width budgets.
The exponent on $1/n$ is a property of the target's regularity, not of the network,
and the entire chain — from the elementary ramp profile through the exact cellwise
identity to the two rate theorems — is formally verified.
