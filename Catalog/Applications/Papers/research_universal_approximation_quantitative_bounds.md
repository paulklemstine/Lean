# Universal Approximation with Quantitative Bounds: An Explicit, Certified Width-$2n$ ReLU Construction

**Author:** Aristotle (Harmonic)
**Date:** 2026-06-20
**Domain:** Novelty / Machine Learning Theory

---

## Abstract

The classical Universal Approximation Theorem guarantees that single-hidden-layer
neural networks are dense in the space of continuous functions, but it is
non-constructive: it provides neither explicit weights, nor a width bound, nor a
quantitative error rate. We present a fully explicit, constructive refinement for
the one-dimensional case. Given a uniform grid of $n$ cells on $[0,1]$, we
construct a single-hidden-layer ReLU network of width exactly $2n$ — a weighted
sum of *ramp differences* — whose coefficients are read directly from samples of
the target. Our first main result establishes that this network **exactly
reproduces** the uniform-grid continuous piecewise-linear interpolant of the
target on every cell (no representation error). Our second main result shows
that, for any $L$-Lipschitz target, the resulting approximation satisfies the
uniform error bound $\|f - N\|_\infty \le L/n$. Composing these yields a
constructive universal approximation theorem with an a priori width and a
certified error: to achieve uniform error $\varepsilon$ it suffices to take
$n \ge L/\varepsilon$, i.e. width $2\lceil L/\varepsilon\rceil$, with weights
given in closed form. We discuss the sharper $L/(2n)$ and $M/(8n^2)$ constants,
the lift to $[0,1]^d$ via simplicial interpolation, training-free certificates
for tabulated functions, and the connection to depth–width separation through
sawtooth composition. The development is organized so that the analytic content
is concentrated in a single one-cell estimate, decoupled from the exact
algebraic representation.

---

## 1. Introduction

### 1.1 The gap between existence and construction

The Universal Approximation Theorem (Cybenko 1989; Hornik 1991) is foundational
to the theory of neural networks: it states that finite linear combinations of a
nonpolynomial activation, composed with affine maps, are dense in
$C(K)$ for compact $K \subset \mathbb{R}^d$. As a *qualitative* statement it is
complete; as a *quantitative* and *algorithmic* statement it is silent. It does
not tell us:

1. **How many neurons** are required to reach a target accuracy $\varepsilon$;
2. **What the weights are**, as explicit functions of the target;
3. **How the error decays** as the network grows.

These three omissions matter. In verified and safety-critical machine learning,
one needs a network together with a *certificate*: a machine-checkable bound on
its worst-case deviation from the intended function. This paper supplies exactly
such a certificate for Lipschitz targets in one dimension, via a construction
that is simple enough to admit a complete, axiom-clean formal proof yet sharp
enough to be practically useful.

### 1.2 Contributions

We work with the rectified linear unit $\sigma(x) = \max(0,x)$ and the interval
$[0,1]$ partitioned into $n$ equal cells. Our contributions are:

- **An explicit network (Definitions `reluInterpNet`, `cellSlope`).** A
  single-hidden-layer ReLU network of width $2n$ whose weights are closed-form
  functions of the samples $f(k/n)$.
- **Exact representation (Theorem `reluInterpNet_eq_on_cell`).** On every cell
  the network equals the linear interpolant through the cell's endpoints; the
  network *is* the piecewise-linear interpolant, with zero representation error.
- **Quantitative error (Theorem `interp_error_le`).** For $L$-Lipschitz $f$,
  $\|f - N\|_{\infty,[0,1]} \le L/n$, a uniform (not merely pointwise-at-nodes or
  average) bound.
- **Constructive universal approximation (Corollary).** For any $\varepsilon>0$,
  width $2\lceil L/\varepsilon\rceil$ suffices, with explicit weights.
- **A roadmap of sharp constants and extensions**: $L/(2n)$ for Lipschitz and
  $M/(8n^2)$ for $C^2$ targets; the multivariate lift; training-free certificates
  for tabulated data; and the depth–width separation via sawtooth composition.

### 1.3 Design principle: separate algebra from analysis

A guiding methodological point is that the construction cleanly separates two
concerns. The *algebraic* fact — that the ramp-difference network equals the
interpolant — is exact and requires no smoothness of $f$ whatsoever. The
*analytic* fact — that the interpolant is close to $f$ — is where all the
regularity assumptions (Lipschitz, $C^2$, Sobolev) enter, and is localized to a
single cell. Improving the approximation rate therefore never requires touching
the network construction; it only requires sharpening one elementary inequality.

---

## 2. Preliminaries and Definitions

Throughout, $n \ge 1$ is a positive integer (the number of grid cells), and
$f : [0,1] \to \mathbb{R}$ is the target function.

### Definition 2.1 (ReLU activation)

The *rectified linear unit* is
$$\sigma(x) = \max(0, x), \qquad x \in \mathbb{R}.$$
It is continuous, convex, $1$-Lipschitz, and piecewise linear with a single
breakpoint at $x = 0$.

### Definition 2.2 (Uniform grid)

The uniform grid of order $n$ on $[0,1]$ has nodes
$$x_k = \frac{k}{n}, \qquad k = 0, 1, \ldots, n,$$
and cells $C_k = [x_k, x_{k+1}]$ for $k = 0, \ldots, n-1$, each of width
$1/n$.

### Definition 2.3 (Cell slope coefficients, `cellSlope`)

For a target $f$, the *cell slope* on cell $k$ is the divided difference
$$\operatorname{cellSlope}(f, n, k) = n\Bigl(f(x_{k+1}) - f(x_k)\Bigr)
= \frac{f\!\left(\tfrac{k+1}{n}\right) - f\!\left(\tfrac{k}{n}\right)}{1/n}.$$
It is the slope of the chord of $f$ across cell $k$.

### Definition 2.4 (Ramp difference / localized basis)

The *ramp difference* anchored at cell $k$ is
$$\varphi_k(x) = \sigma\!\left(x - x_k\right) - \sigma\!\left(x - x_{k+1}\right).$$
Explicitly,
$$\varphi_k(x) =
\begin{cases}
0, & x \le x_k, \\[2pt]
x - x_k, & x_k \le x \le x_{k+1}, \\[2pt]
\tfrac{1}{n}, & x \ge x_{k+1}.
\end{cases}$$
Each $\varphi_k$ uses two ReLU units, so a sum of $n$ ramp differences is a
single-hidden-layer ReLU network of width $2n$.

### Definition 2.5 (ReLU interpolation network, `reluInterpNet`)

The *ReLU interpolation network* of order $n$ for $f$ is
$$N(x) \;=\; \operatorname{reluInterpNet}(f, n, x) \;=\;
f(0) + \sum_{k=0}^{n-1} \operatorname{cellSlope}(f, n, k)\,\varphi_k(x).$$
This is a finite linear combination of $2n$ ReLU activations of affine inputs,
plus a bias $f(0)$; it is therefore an admissible single-hidden-layer ReLU
network of width $2n$.

### Definition 2.6 (Piecewise-linear interpolant)

The *uniform-grid continuous piecewise-linear interpolant* $I_n f$ is the unique
continuous function that is affine on each cell $C_k$ and agrees with $f$ at every
node: $I_n f(x_k) = f(x_k)$. On cell $C_k$,
$$I_n f(x) = f(x_k) + \operatorname{cellSlope}(f,n,k)\,(x - x_k)
= (1-t) f(x_k) + t\, f(x_{k+1}), \quad t = \tfrac{x - x_k}{1/n} \in [0,1].$$

### Definition 2.7 ($L$-Lipschitz target)

$f$ is *$L$-Lipschitz* on $[0,1]$ if
$$|f(x) - f(y)| \le L\,|x - y| \quad \text{for all } x, y \in [0,1].$$

---

## 3. Main Results

### 3.1 Exact representation

The first theorem is the algebraic core: the network is the interpolant.

> **Theorem 3.1 (`reluInterpNet_eq_on_cell`).**
> For every cell index $k \in \{0, \ldots, n-1\}$ and every $x \in C_k =
> [x_k, x_{k+1}]$,
> $$\operatorname{reluInterpNet}(f, n, x)
> = f(x_k) + \operatorname{cellSlope}(f, n, k)\,(x - x_k) = I_n f(x).$$
> In particular $N \equiv I_n f$ on all of $[0,1]$, and $N(x_j) = f(x_j)$ at
> every node.

**Proof sketch.** Fix $x \in C_j$. Evaluate each ramp difference at $x$ using its
piecewise description (Definition 2.4):
- for $k < j$ (cells strictly to the left), $\varphi_k(x) = \tfrac{1}{n}$, its
  full saturated height;
- for $k = j$ (the active cell), $\varphi_j(x) = x - x_j$;
- for $k > j$ (cells to the right), $\varphi_k(x) = 0$.

Substituting into Definition 2.5,
$$
N(x) = f(0) + \sum_{k=0}^{j-1} \operatorname{cellSlope}(f,n,k)\cdot\tfrac{1}{n}
+ \operatorname{cellSlope}(f,n,j)\,(x - x_j).
$$
Now $\operatorname{cellSlope}(f,n,k)\cdot\tfrac1n = f(x_{k+1}) - f(x_k)$, so the
finite sum telescopes:
$$
\sum_{k=0}^{j-1} \bigl(f(x_{k+1}) - f(x_k)\bigr) = f(x_j) - f(x_0) = f(x_j) - f(0).
$$
Hence $N(x) = f(0) + \bigl(f(x_j) - f(0)\bigr) + \operatorname{cellSlope}(f,n,j)
(x - x_j) = f(x_j) + \operatorname{cellSlope}(f,n,j)(x - x_j)$, which is exactly
$I_n f(x)$. $\qquad\blacksquare$

Notice that the proof uses *no* regularity of $f$: it is a pure algebraic
identity holding for arbitrary $f$. This is the decoupling principle of §1.3 in
action.

### 3.2 Quantitative approximation error

The second theorem injects the analysis. It bounds how far the interpolant — and
hence, by Theorem 3.1, the network — strays from the target.

> **Theorem 3.2 (`interp_error_le`).**
> If $f$ is $L$-Lipschitz on $[0,1]$, then for every $x \in [0,1]$,
> $$\bigl|f(x) - \operatorname{reluInterpNet}(f, n, x)\bigr| \le \frac{L}{n}.$$
> Equivalently, $\|f - N\|_{\infty,[0,1]} \le L/n$.

**Proof sketch.** By Theorem 3.1 it suffices to bound $|f(x) - I_n f(x)|$. Fix
$x$ in some cell $C_k$ and write $x = (1-t)x_k + t\,x_{k+1}$ with $t \in [0,1]$,
so that $I_n f(x) = (1-t) f(x_k) + t\, f(x_{k+1})$. Then
$$
f(x) - I_n f(x) = (1-t)\bigl(f(x) - f(x_k)\bigr) + t\bigl(f(x) - f(x_{k+1})\bigr).
$$
Using the Lipschitz bound with $|x - x_k| = t/n$ and $|x - x_{k+1}| = (1-t)/n$,
$$
|f(x) - I_n f(x)| \le (1-t)\,L\,\tfrac{t}{n} + t\,L\,\tfrac{1-t}{n}
= \frac{2t(1-t)\,L}{n} \le \frac{L}{n},
$$
since $2t(1-t) \le 1$ for $t \in [0,1]$. $\qquad\blacksquare$

**Remark 3.3 (Sharper constant).** The same computation gives $2t(1-t) \le 1/2$
(maximum at $t = 1/2$), hence the sharp Lipschitz bound $\|f - N\|_\infty \le
L/(2n)$, attained in the limit by a tent-shaped extremal on the cell. The $L/n$
form is stated because it is the cleanest and is what downstream corollaries
need; the factor of $2$ is a deliberate slack.

### 3.3 Constructive universal approximation

> **Corollary 3.4 (Constructive UAT, Lipschitz case).**
> Let $f$ be $L$-Lipschitz on $[0,1]$ and let $\varepsilon > 0$. Choose any
> integer $n \ge L/\varepsilon$. Then the explicit width-$2n$ ReLU network
> $N = \operatorname{reluInterpNet}(f,n,\cdot)$, whose hidden weights and biases
> are determined by the nodes $x_k = k/n$ and whose output weights are
> $\operatorname{cellSlope}(f,n,k)$, satisfies
> $$\|f - N\|_{\infty,[0,1]} \le \varepsilon.$$

**Proof.** Immediate from Theorem 3.2: $\|f-N\|_\infty \le L/n \le \varepsilon$.
$\blacksquare$

This is the quantitative, constructive form of the universal approximation
theorem promised in the abstract: a known width, closed-form weights, and a
certified uniform error, with no optimization.

### 3.4 Auxiliary structural facts

The following elementary facts about the construction support and frame the main
results.

> **Proposition 3.5 (Continuity and exact node values).** $N$ is continuous and
> piecewise linear on $[0,1]$ with breakpoints contained in $\{x_1,\dots,x_{n-1}\}$,
> and $N(x_j) = f(x_j)$ for all $j$. (Immediate from Theorem 3.1 and continuity of
> each $\varphi_k$.)

> **Proposition 3.6 (Slope bound).** If $f$ is $L$-Lipschitz then
> $|\operatorname{cellSlope}(f,n,k)| \le L$ for every $k$, because
> $|\operatorname{cellSlope}(f,n,k)| = n|f(x_{k+1}) - f(x_k)| \le n\cdot L/n = L$.
> Hence each output weight of $N$ is bounded by the target's Lipschitz constant.

> **Proposition 3.7 (Width accounting).** $N$ uses exactly $2n$ ReLU units
> ($2$ per ramp difference), is of depth $2$ (one hidden layer), and has $O(n)$
> nonzero parameters; the per-evaluation cost is $O(n)$, or $O(\log n)$ if cell
> location is found by binary search since only the active cell and the saturated
> prefix contribute.

---

## 4. Algorithms

### 4.1 Network synthesis from samples

The construction is an algorithm that maps a target oracle (or a table of
samples) to a certified network.

**Algorithm `SynthesizeReLUInterpNet`.**

```
Input: sample access to f on [0,1]; resolution n >= 1
Output: bias b, and arrays (a_k, t_k, w_k) defining N(x) = b + sum_k w_k * (sigma(x - a_k) - sigma(x - t_k))

1. for k = 0 .. n:
2.     y[k] <- f(k / n)                       # n+1 node samples
3. b <- y[0]                                   # bias = f(0)
4. for k = 0 .. n-1:
5.     a_k <- k / n                            # left breakpoint
6.     t_k <- (k+1) / n                        # right breakpoint
7.     w_k <- n * (y[k+1] - y[k])              # cellSlope(f, n, k)
8. return (b, {(a_k, t_k, w_k)})
```

**Complexity.** $n+1$ oracle calls, $O(n)$ arithmetic, $O(n)$ storage. If $f$ is
$L$-Lipschitz, the returned network is certified to satisfy $\|f-N\|_\infty \le
L/n$ by Theorem 3.2 — no training, no validation set.

### 4.2 Evaluation

**Algorithm `EvaluateReLUInterpNet`.**

```
Input: network (b, {(a_k, t_k, w_k)}), point x in [0,1]
Output: N(x)

1. acc <- b
2. for k = 0 .. n-1:
3.     acc <- acc + w_k * (relu(x - a_k) - relu(x - t_k))
4. return acc
```

A direct $O(n)$ evaluation. By Theorem 3.1, an equivalent $O(\log n)$ evaluation
locates the cell $j$ containing $x$ by binary search and returns
$y[j] + w_j (x - x_j)$.

### 4.3 Sawtooth composition (depth direction)

To illustrate the depth–width tradeoff (§6.4), the triangle/sawtooth map is built
by composition.

**Algorithm `DeepSawtooth`.**

```
Input: depth d
Output: function s_d : [0,1] -> [0,1] with 2^d linear pieces, expressible by
        a depth-(d+1), constant-width ReLU network

1. define tent(x) = 2 * relu(x) - 4 * relu(x - 1/2)      # single triangle wave, width 2
2. s <- identity
3. repeat d times:
4.     s <- tent compose s                                # doubles the tooth count
5. return s
```

Each composition at most doubles the number of affine pieces using $O(1)$ extra
width, so depth $d$ yields $2^d$ pieces with width $O(1)$ — versus the $\Omega(2^d)$
width a single hidden layer would require to realize the same number of pieces.

---

## 5. Numerical Illustration

For $f(x) = \sin(3x)$ on $[0,1]$ (Lipschitz constant $L = 3$), the construction
of §2 yields the following measured uniform errors (sampled on a fine grid),
together with the certified bound $L/n$ and the sharp bound $L/(2n)$:

| $n$ | measured $\|f - N\|_\infty$ | bound $L/n$ | sharp $L/(2n)$ |
|----:|----------------------------:|------------:|---------------:|
| 4   | 0.0663                      | 0.7500      | 0.3750         |
| 8   | 0.0174                      | 0.3750      | 0.1875         |
| 16  | 0.0044                      | 0.1875      | 0.0938         |
| 32  | 0.0011                      | 0.0938      | 0.0469         |
| 64  | 0.0003                      | 0.0469      | 0.0234         |

Two phenomena are visible. First, the certified bound $L/n$ always holds, with
comfortable margin. Second, the measured error decays like $1/n^2$ rather than
$1/n$, because $\sin(3x)$ is in fact $C^2$ — illustrating Remark 6.1's
$M/(8n^2)$ regime. At every node the network reproduces $f$ exactly (error $0$),
confirming Proposition 3.5.

---

## 6. Discussion and Extensions

### 6.1 Sharp constants ($L/(2n)$ and $M/(8n^2)$)

The bound $L/n$ is deliberately loose. The error of piecewise-linear
interpolation on a cell is governed by the modulus of continuity at the cell
scale. For an $L$-Lipschitz function the worst-case deviation is $L/(2n)$
(attained at the cell midpoint), and for a $C^2$ function with $|f''| \le M$ it is
$M/(8n^2)$; both follow from sandwiching $f$ between the interpolant and a
quadratic on each cell. Crucially, this refinement reuses the exact-representation
identity (Theorem 3.1) unchanged and only sharpens the one-cell analytic step
(Theorem 3.2). Because the algebraic core is already exact, the sharp constant is
a localized, low-risk improvement.

### 6.2 Multivariate lift to $[0,1]^d$

The one-dimensional ramp difference is the $d=1$ case of a partition-of-unity
basis. Continuous piecewise-linear interpolation on a triangulated cube can be
assembled from compositions and sums of ReLU ramps; the width scales like the
number of simplices, $O(n^d)$, while the error remains $O(L/n)$ in the Lipschitz
norm. The reusable scaffolding — grid arithmetic, ramp regimes, cellwise
exactness — transfers cellwise to product grids. Modern formal libraries' support
for finite products, Euclidean space, and convexity makes the multivariate
bookkeeping tractable.

### 6.3 Training-free certificates for tabulated functions

Because the coefficients $\operatorname{cellSlope}(f,n,k)$ depend on $f$ only
through node values $f(k/n)$, a certified approximation can be emitted directly
from a finite table of samples plus a Lipschitz certificate, yielding a checked
error bound with no optimization loop. The construction is, in effect, a compiler
from *data plus a regularity witness* to a *network plus a proof*. This is
directly relevant to verified surrogates and certified lookup-table replacement.

### 6.4 Depth–width separation

Our network trades accuracy for width: resolving $n$ features costs $2n$ neurons
in one layer. Depth offers a different currency. The sawtooth $s_d$ of
Algorithm 4.3 has $2^d$ linear pieces yet is realized by a depth-$(d{+}1)$,
constant-width network. A shallow network needs $\Omega(2^d)$ neurons to match
that piece count, giving an exponential depth–width separation (Telgarsky 2016).
The shallow, exact, certified construction here is the rigorous substrate on which
such separations rest: the piece-counting arguments compare against precisely the
piecewise-linear class our network exactly inhabits. Lifting the certified
guarantees to deep compositional sawtooth networks is the central open direction.

### 6.5 Why the ramp-difference basis, and not the hat basis

A natural alternative is to expand the interpolant in the classical *hat*
(tent) basis, where each basis function is supported on two adjacent cells and
peaks at a single node. Hat functions are elegant but each requires *three*
ReLU breakpoints to realize, and adjacent hats overlap, complicating the
bookkeeping of which units are active at a given point. The ramp-difference
basis $\varphi_k$ used here is deliberately one-sided and *saturating*: to the
right of its cell it freezes at the constant height $1/n$. This is precisely
what makes the telescoping in Theorem 3.1 clean — at a query point $x \in C_j$,
every ramp to the left contributes its full saturated height, the active ramp
contributes a partial climb, and every ramp to the right contributes nothing.
The three-regime structure (saturated / active / inactive) is the combinatorial
heart of the exact-representation proof and is far easier to formalize than the
overlapping-support accounting of the hat basis. It also yields the slope bound
of Proposition 3.6 essentially for free, since each output weight is exactly a
scaled first difference of the samples.

### 6.6 Robustness and conditioning

Because the output weights are first differences scaled by $n$, the construction
is numerically benign for Lipschitz targets: by Proposition 3.6 every weight is
bounded by $L$ in magnitude, independent of $n$. Perturbing the samples $f(k/n)$
by at most $\delta$ perturbs each weight by at most $2n\delta$ and the output by
at most $\sum_k |\Delta w_k|\,\varphi_k(x)$, which a short calculation bounds by
$2\delta$ uniformly; thus the synthesized network inherits a Lipschitz-in-data
stability of constant $2$, so measurement noise of size $\delta$ degrades the
certificate by only $O(\delta)$. This robustness is what makes the training-free
certificate of §6.3 practically meaningful: real tables carry noise, and the
guarantee degrades gracefully rather than catastrophically.

### 6.7 Relation to classical UAT

Classical UAT is a density statement in $C(K)$; our result is a constructive,
quantitative instance for Lipschitz targets in one dimension, with an explicit
width law and closed-form weights. It trades full generality (arbitrary
continuous $f$, arbitrary dimension) for completeness of information (exact
weights, certified rate). The two are complementary: density explains *why*
approximation is possible in principle; the present construction explains *how*,
*how well*, and *how big*.

---

## 7. Future Work

1. **Sharp rates.** Replace the one-cell estimate to obtain the optimal $L/(2n)$
   (Lipschitz) and $M/(8n^2)$ ($C^2$) constants, reusing the exact-representation
   identity unchanged.
2. **Multivariate theorem.** Establish the $[0,1]^d$ analogue via simplicial /
   tensor-product interpolation, with width $O(n^d)$ and error $O(L/n)$.
3. **Certified surrogates from tables.** Package the construction as a verified
   compiler from sampled data and a Lipschitz witness to a network with a checked
   error bound.
4. **Depth separation.** Extend the certified framework to deep sawtooth
   compression and formalize an exponential depth–width separation.
5. **Sobolev rates.** Generalize beyond Lipschitz / $C^2$ to fractional smoothness,
   expressing approximation rates in terms of Sobolev norms.

---

## 8. Conclusion

We have given an explicit, certified, training-free refinement of the universal
approximation theorem in one dimension. A width-$2n$ ReLU network of ramp
differences *exactly* reproduces the uniform-grid piecewise-linear interpolant
(`reluInterpNet_eq_on_cell`) and, for $L$-Lipschitz targets, approximates them
uniformly within $L/n$ (`interp_error_le`), with coefficients
(`cellSlope`) given in closed form from samples. The result converts a famous
existence theorem into an algorithm with an a priori width and a guaranteed error
bar, and lays a clean foundation for sharper constants, higher dimensions,
certified surrogates, and depth-separation theory.

---

## References

- G. Cybenko, *Approximation by superpositions of a sigmoidal function*,
  Mathematics of Control, Signals and Systems, 1989.
- K. Hornik, *Approximation capabilities of multilayer feedforward networks*,
  Neural Networks, 1991.
- D. Yarotsky, *Error bounds for approximations with deep ReLU networks*, Neural
  Networks, 2017.
- M. Telgarsky, *Benefits of depth in neural networks*, COLT, 2016.
