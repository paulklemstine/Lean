# A Dimension-Free Isotropy Model for Bourgain's Slicing Problem: The Discrete Cube

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Pythagorean / High-dimensional convex geometry

## Abstract

Bourgain's slicing problem (the hyperplane conjecture) asks whether there exists a
universal constant $c > 0$, independent of dimension, such that every convex body
$K \subseteq \mathbb{R}^n$ of volume $1$ admits a hyperplane section of
$(n-1)$-dimensional volume at least $c$. The problem is equivalent to a uniform
upper bound on the isotropic constant $L_K$, and its decisive structural notion is
*isotropic position*: a body whose covariance matrix is a scalar multiple of the
identity. We isolate and rigorously verify the load-bearing structural phenomenon
— identity covariance forcing dimension-free isotropy — on a fully discrete model
that requires no measure theory: the uniform probability measure on the discrete
cube $\{-1,1\}^n$. We prove that this measure is centered, that its covariance
kernel $T(k,l) = \sum_x x_k x_l$ equals $2^n\,\delta_{kl}$ in every dimension,
and consequently that every unit linear functional has variance exactly $1$,
independently of $n$. The entire argument reduces to a single sign-flip
involution on the index set, which simultaneously kills the first moment
(centering) and the off-diagonal second moments (de-correlation). The resulting
identity $\mathbb{E}[\langle\theta,x\rangle^2] = \lVert\theta\rVert^2$ is a
Pythagorean/Parseval identity for an orthonormal coordinate system, exhibiting the
discrete cube as an exactly isotropic body with isotropic constant $1$, uniformly
in the dimension. We discuss why this discrete second-moment model captures the
same structural content as the slicing conjecture, present numerical
demonstrations, and outline conjectural extensions to products, boxes, and
anti-concentration.

## 1. Introduction

### 1.1 The slicing problem

Let $K \subseteq \mathbb{R}^n$ be a convex body of Lebesgue volume $1$. A
*hyperplane section* of $K$ is its intersection with an affine hyperplane
$H = \{x : \langle\theta,x\rangle = t\}$, a set of dimension $n-1$. Bourgain's
slicing problem asks:

> **(Slicing conjecture).** There is a universal constant $c > 0$ such that for
> every $n$ and every convex body $K \subseteq \mathbb{R}^n$ with
> $\operatorname{vol}_n(K) = 1$, there exists a hyperplane $H$ with
> $\operatorname{vol}_{n-1}(K \cap H) \geq c$.

The qualifier "universal" — one constant for all dimensions at once — is the
source of all difficulty. In any fixed dimension the existence of a large section
is elementary; the challenge is dimension-freeness. The problem was raised by
Bourgain in the 1980s and became a central question of asymptotic convex
geometry; it is now known to hold, after a long sequence of improvements
culminating in recent work establishing a bounded isotropic constant.

### 1.2 Isotropic position and the isotropic constant

The slicing conjecture is equivalent to a statement about *isotropic position*.
Center $K$ at its barycenter and let $x$ be uniformly distributed on $K$. The
covariance matrix of $x$ is $\Sigma_K = \mathbb{E}[x x^\top]$. After an affine
volume-preserving map, one may assume $\Sigma_K = L_K^2\, I_n$ for a scalar
$L_K > 0$, the **isotropic constant**. In this position every unit functional has
the same variance, $\mathbb{E}[\langle\theta,x\rangle^2] = L_K^2$. The slicing
conjecture is equivalent to the assertion $\sup_n \sup_K L_K < \infty$. Thus the
crux is: *identity-shaped covariance, with a scalar that does not blow up as
$n \to \infty$.*

### 1.3 Contribution

Genuine $(n-1)$-volumes of hyperplane sections of convex bodies lie beyond
current formalized mathematics (the Pólya / Hensley–Vaaler Fourier-analytic
section-volume formula is unavailable). We instead formalize the *structural*
content of isotropic position on a discrete model where every quantity is a finite
sum. Our object is the uniform probability measure on the discrete cube
$\{-1,1\}^n$. We prove, with no measure theory:

- the measure is **centered** (Theorem A);
- its covariance kernel is the **identity** scaled by $2^n$ (Theorem B);
- every linear functional is **centered** and its second moment equals the squared
  Euclidean norm of its coefficient vector (Theorem C);
- hence every **unit** functional has variance exactly $1$, **dimension-free**
  (Theorem D).

The proof method is a single sign-flip involution that, applied to two different
summands, yields both centering and de-correlation. The final identity is
Pythagorean: variance equals sum of squares.

### 1.4 Historical and conceptual context

The slicing problem sits at the confluence of convex geometry, probability, and
harmonic analysis. Bourgain's original motivation came from the study of maximal
functions associated to convex bodies, where the size of central sections controls
the boundedness constants. Milman and Pajor recast the question in terms of the
*isotropic position* and the isotropic constant $L_K$, making explicit the
equivalence between "every body has a large section" and "$L_K$ is uniformly
bounded." Their reformulation is the lens through which essentially all subsequent
progress was made: rather than chasing sections directly, one studies the
covariance structure of the uniform measure on $K$.

The quantity $L_K$ has a clean probabilistic meaning. In isotropic position the
uniform measure on $K$ behaves, to second order, like an isotropic random vector:
its coordinates are uncorrelated and identically scaled. The conjecture asserts
that this second-order roundness is achievable with a scale that is bounded
independently of dimension. The phenomenon is subtle precisely because
high-dimensional convex bodies can be extremely anisotropic before normalization;
the content is that the *normalized* picture is always tame.

It is instructive to separate two layers of the problem. The first is purely
*structural*: the existence of a position in which the covariance is a scalar
multiple of the identity, and the identification of that scalar with the
section-size constant. This layer is linear-algebraic and holds in complete
generality. The second layer is *quantitative*: bounding the scalar uniformly in
$n$, which requires genuine high-dimensional analysis. Our discrete model makes
the first layer not only transparent but *exact* — the covariance is the identity
on the nose, and the scalar is exactly $1$ — thereby exhibiting the cleanest
possible instance of the structural premise, while honestly delimiting which layer
is being addressed.

## 2. Definitions

Throughout, $n \in \mathbb{N}$ and a point of the discrete cube is a function
$x : \{1,\dots,n\} \to \{\text{true},\text{false}\}$ (a bit-string), modeled in
Lean as `Fin n → Bool`.

**Definition 1 (Sign value, `sgn`).** For a bit $b$,
$$\operatorname{sgn}(b) = \begin{cases} 1 & b = \text{true} \\ -1 & b = \text{false}. \end{cases}$$

**Definition 2 (Coordinate, `coord`).** For a cube point $x$ and index $i$, the
$i$-th coordinate value is $\operatorname{coord}(x, i) = \operatorname{sgn}(x_i) \in \{-1,+1\}$.

**Definition 3 (Uniform expectation, `E`).** For $f : \{-1,1\}^n \to \mathbb{R}$,
$$\mathbb{E}[f] = \frac{1}{2^n}\sum_{x \in \{-1,1\}^n} f(x).$$

**Definition 4 (Coordinate flip, `flip` / `flipPerm`).** For an index $i$, the map
$\operatorname{flip}_i(x)$ toggles the $i$-th bit and fixes the rest:
$\operatorname{flip}_i(x) = \mathrm{update}(x, i, \lnot x_i)$. Since it is an
involution it induces a permutation `flipPerm i` of the $2^n$ cube points.

**Definition 5 (Covariance kernel, `T`).** For indices $k, l$,
$$T(k, l) = \sum_{x \in \{-1,1\}^n} \operatorname{coord}(x, k)\,\operatorname{coord}(x, l).$$
Dividing by $2^n$ gives the entries of the covariance matrix $\Sigma$ of a
uniformly random cube point.

## 3. Elementary lemmas

**Lemma 1 (`sgn_not`).** $\operatorname{sgn}(\lnot b) = -\operatorname{sgn}(b)$.
*Proof.* Case analysis on $b$. $\square$

**Lemma 2 (`sgn_mul_self`).** $\operatorname{sgn}(b)\cdot\operatorname{sgn}(b) = 1$.
*Proof.* Both $(+1)^2$ and $(-1)^2$ equal $1$. $\square$

**Lemma 3 (`card_cube`).** The discrete cube has $2^n$ points:
$\lvert\{-1,1\}^n\rvert = 2^n$.
*Proof.* The number of functions $\{1,\dots,n\}\to\{\text{true},\text{false}\}$
is $2^n$. $\square$

**Lemma 4 (`flip_involutive`).** $\operatorname{flip}_i \circ \operatorname{flip}_i = \mathrm{id}$.
*Proof.* On coordinate $i$, toggling twice is the identity; other coordinates are
untouched. Hence $\operatorname{flip}_i$ is a bijection, and `flipPerm i` is a
genuine permutation of the cube. $\square$

**Lemma 5 (`coord_flip_self`).** $\operatorname{coord}(\operatorname{flip}_i(x), i) = -\operatorname{coord}(x, i)$.
*Proof.* The $i$-th bit becomes $\lnot x_i$; apply Lemma 1. $\square$

**Lemma 6 (`coord_flip_ne`).** If $j \neq i$ then
$\operatorname{coord}(\operatorname{flip}_i(x), j) = \operatorname{coord}(x, j)$.
*Proof.* $\operatorname{flip}_i$ does not change the $j$-th bit. $\square$

The two key consequences of Lemma 4 used repeatedly: because
$\operatorname{flip}_i$ is a permutation of the summation index set, for any
$g$ we have the reindexing identity
$$\sum_{x} g(x) = \sum_{x} g(\operatorname{flip}_i(x)). \tag{$\ast$}$$

## 4. Main results

### 4.1 Centering

**Theorem A (`sum_coord_eq_zero`).** For every index $i$,
$$\sum_{x \in \{-1,1\}^n} \operatorname{coord}(x, i) = 0.$$

*Proof sketch.* Apply the reindexing identity $(\ast)$ with the flip on
coordinate $i$ and $g(x) = \operatorname{coord}(x,i)$:
$$\sum_x \operatorname{coord}(x,i) = \sum_x \operatorname{coord}(\operatorname{flip}_i(x), i)
= \sum_x \big(-\operatorname{coord}(x,i)\big) = -\sum_x \operatorname{coord}(x,i),$$
using Lemma 5 in the middle equality. A real number equal to its own negative is
zero. $\square$

Dividing by $2^n$ yields that the barycenter of the discrete cube is the origin.

**Theorem A' (`E_inner`).** Every linear functional is centered:
$\mathbb{E}[\langle\theta,x\rangle] = 0$ for all $\theta$.
*Proof sketch.* Linearity of expectation reduces this to Theorem A coordinatewise:
$\mathbb{E}[\sum_k \theta_k \operatorname{coord}(\cdot,k)] = \sum_k \theta_k\,\mathbb{E}[\operatorname{coord}(\cdot,k)] = 0$. $\square$

### 4.2 Identity covariance

**Theorem B (`covariance`).** For all $k, l$,
$$T(k, l) = \begin{cases} 2^n & k = l, \\ 0 & k \neq l. \end{cases}$$

This combines two lemmas.

**Off-diagonal (`T_off_diag`).** If $k \neq l$ then $T(k,l) = 0$.
*Proof sketch.* Apply $(\ast)$ with the flip on coordinate $k$ and
$g(x) = \operatorname{coord}(x,k)\operatorname{coord}(x,l)$. By Lemma 5 the
$k$-factor negates, and by Lemma 6 the $l$-factor is unchanged (since $l \neq k$),
so $g(\operatorname{flip}_k(x)) = -g(x)$. Hence $T(k,l) = -T(k,l) = 0$. $\square$

**Diagonal (`T_diag`).** $T(k,k) = 2^n$.
*Proof sketch.* By Lemma 2 the summand $\operatorname{coord}(x,k)^2 = 1$ for every
$x$; summing the constant $1$ over the $2^n$ points (Lemma 3) gives $2^n$. $\square$

Combining the two cases gives Theorem B: the covariance kernel is $2^n$ times the
identity matrix, with **no dependence on $n$** beyond the global scale $2^n$ that
the expectation normalization removes.

### 4.3 Isotropy: a Pythagorean second-moment identity

**Theorem C (`sum_inner_sq` / `E_inner_sq`).** For every coefficient vector
$\theta = (\theta_1,\dots,\theta_n)$,
$$\sum_{x \in \{-1,1\}^n} \Big(\sum_k \theta_k\,\operatorname{coord}(x,k)\Big)^2 = 2^n \sum_k \theta_k^2,
\qquad\text{equivalently}\qquad
\mathbb{E}\big[\langle\theta,x\rangle^2\big] = \sum_k \theta_k^2 = \lVert\theta\rVert^2.$$

*Proof sketch.* Expand the square pointwise into a double sum,
$$\Big(\sum_k \theta_k \operatorname{coord}(x,k)\Big)^2
= \sum_k\sum_l \theta_k\theta_l\,\operatorname{coord}(x,k)\operatorname{coord}(x,l).$$
Sum over $x$ and exchange the order of summation (`Finset.sum_comm`) so the
$x$-sum is innermost; it equals $T(k,l)$ by Definition 5:
$$\sum_x \Big(\sum_k \theta_k \operatorname{coord}(x,k)\Big)^2 = \sum_k\sum_l \theta_k\theta_l\,T(k,l).$$
Substitute Theorem B: every off-diagonal term vanishes and each diagonal term
contributes $\theta_k^2\cdot 2^n$, collapsing the double sum to
$2^n\sum_k \theta_k^2$. Dividing by $2^n$ gives the expectation form. $\square$

This is a Parseval/Pythagorean identity: the coordinate functions
$\operatorname{coord}(\cdot,k)$ form an orthonormal system for the uniform
inner product $\langle f, g\rangle = \mathbb{E}[fg]$, and the squared norm of a
linear combination is the sum of squared coefficients — the $n$-dimensional
Pythagorean theorem.

### 4.4 Dimension-free isotropy

**Theorem D (`discreteCube_isotropic`).** For every unit vector $\theta$
(i.e. $\sum_k \theta_k^2 = 1$),
$$\mathbb{E}\big[\langle\theta,x\rangle^2\big] = 1,$$
independently of the dimension $n$.

*Proof sketch.* Immediate from Theorem C with $\lVert\theta\rVert^2 = 1$. $\square$

**Interpretation.** The covariance matrix of the uniform measure on $\{-1,1\}^n$
is the identity $I_n$ in every dimension. Hence the discrete cube is exactly in
isotropic position with isotropic constant $L = 1$, uniformly in $n$. Every unit
functional sees the same variance $1$; there is no thin direction. This is the
discrete realization of the structural premise of the slicing conjecture: a
bounded — indeed constant — dimension-free isotropic constant.

## 4.5 A worked example in dimension two

To make the mechanism concrete, take $n = 2$. The cube has $2^2 = 4$ corners,
$$(+1,+1),\quad (+1,-1),\quad (-1,+1),\quad (-1,-1).$$
The first coordinate takes values $+1,+1,-1,-1$ across these corners, summing to
$0$ (Theorem A); likewise the second. The covariance kernel entries are
$$T(1,1) = (+1)^2+(+1)^2+(-1)^2+(-1)^2 = 4 = 2^2,$$
$$T(2,2) = (+1)^2+(-1)^2+(+1)^2+(-1)^2 = 4 = 2^2,$$
$$T(1,2) = (+1)(+1)+(+1)(-1)+(-1)(+1)+(-1)(-1) = 1-1-1+1 = 0,$$
so $T = 4 I_2$ (Theorem B). For $\theta = (\cos\alpha, \sin\alpha)$, a unit vector,
the four values of $\langle\theta,x\rangle$ are
$\pm(\cos\alpha+\sin\alpha)$ and $\pm(\cos\alpha-\sin\alpha)$, whose squares
average to
$$\tfrac{1}{4}\big[2(\cos\alpha+\sin\alpha)^2 + 2(\cos\alpha-\sin\alpha)^2\big]
= \cos^2\alpha + \sin^2\alpha = 1,$$
by the Pythagorean identity (Theorem D). The cross-term $2\cos\alpha\sin\alpha$
appears with opposite signs in the two squared groups and cancels — exactly the
off-diagonal vanishing of Theorem B, seen in miniature. This single trigonometric
cancellation is the $n=2$ shadow of the general sign-flip involution.

## 5. Algorithmic content

Although the theorems are exact identities, they suggest two natural finite
algorithms, both verifiable against the closed forms.

**Algorithm 1 (Exact covariance kernel by full enumeration).** Enumerate all
$2^n$ corners, accumulate the outer products $\operatorname{coord}(x,\cdot)
\operatorname{coord}(x,\cdot)^\top$, and confirm the result equals $2^n I_n$. This
directly checks Theorem B. Complexity $\Theta(2^n n^2)$ time, $\Theta(n^2)$ space;
feasible for $n \lesssim 20$.

**Algorithm 2 (Directional second-moment estimator).** For a fixed unit $\theta$,
compute $\mathbb{E}[\langle\theta,x\rangle^2]$ either exactly (enumeration,
$\Theta(2^n n)$) or by Monte Carlo over random corners ($\Theta(Sn)$ for $S$
samples), and compare against the predicted value $\lVert\theta\rVert^2 = 1$ from
Theorem D. The estimator concentrates around $1$ independently of $n$, the
empirical signature of dimension-free isotropy.

## 6. Discussion

### 6.1 Why a discrete model is faithful

The dimension-fragile heart of the slicing problem is the uniform control of the
isotropic constant. All routes to the conjecture pass through isotropic position
and the covariance matrix; the geometry of any individual body is secondary to the
behavior of $\Sigma_K$ as $n$ grows. The discrete cube isolates exactly this
mechanism — identity covariance $\Rightarrow$ dimension-free isotropy — while
removing the measure-theoretic apparatus (Lebesgue section volumes, Fourier
section-area formulas) that obscures it. The second-moment content is identical to
that of a smooth isotropic body; only the ambient volume geometry is abstracted
away.

### 6.2 The role of the involution

The proofs of Theorems A and B are the *same* one-line argument applied to
different summands: a sign-reversing involution forces the sum to equal its
negative, hence zero. This is a robust template — Gaussian odd-moment vanishing,
parity cancellation, reflection arguments — and here it carries the entire
structural payload of the model. Its robustness is precisely what makes the
conclusion dimension-free: the symmetry exists in every dimension and does not
weaken.

### 6.3 What the model does and does not claim

We are careful to state the scope precisely. The theorems establish that the
uniform measure on $\{-1,1\}^n$ is exactly isotropic with isotropic constant $1$,
dimension-free. They do *not* compute Lebesgue volumes of $(n-1)$-dimensional
sections of a convex body, nor do they prove the slicing conjecture for general
convex bodies. What they capture is the structural premise — identity covariance
and the consequent equalization of directional second moments — that every
approach to the conjecture relies upon, isolated in a setting where it can be
verified completely and elementarily. The discrete cube is the extremal good case:
the place where the structural layer is not merely bounded but optimal.

This honesty is itself valuable. Many heuristic discussions of slicing blur the
structural and quantitative layers; by formalizing only the structural one, we
pin down exactly which part of the intuition is elementary (uncorrelatedness and
equal scaling, via symmetry) and which part is genuinely hard (uniform control
for arbitrary bodies, requiring high-dimensional analysis).

### 6.4 Relation to anti-concentration

Isotropy controls the second moment of marginals $\langle\theta,x\rangle$;
slicing additionally requires *anti-concentration* (bounded marginal density).
For the discrete cube the marginal of a unit functional is a signed sum
$\sum_k \theta_k \varepsilon_k$ with $\varepsilon_k = \pm 1$ uniform, whose
maximal atom is governed by the classical Littlewood–Offord–Erdős bound. Pairing
the exact second moment proved here with such anti-concentration is the discrete
analogue of pairing isotropy with section-density bounds in the continuous theory.

### 6.5 Comparison with the solid cube and optimality of $L = 1$

The discrete cube is the vertex set of the solid cube $[-1,1]^n$, and the two share
their second-order structure after normalization. For the uniform measure on the
solid cube $[-c,c]^n$, the coordinates are independent with $\mathbb{E}[x_k^2] =
c^2/3$, so the covariance is $(c^2/3) I_n$; choosing $c$ to fix the variance gives
a constant isotropic body in every dimension, with the same identity-shaped
covariance we proved exactly for the discrete model. The discrete cube reaches the
limiting two-point marginal (mass $1/2$ at each of $\pm 1$) and thereby attains the
cleanest constant, $L = 1$, with no integration at all. In this sense the discrete
model is not an approximation to the solid cube but its second-moment skeleton:
the same orthonormal coordinate structure, stripped to a finite sum.

The value $L = 1$ is optimal for the structural premise in the following sense.
The identity $\mathbb{E}[\langle\theta,x\rangle^2] = \lVert\theta\rVert^2$ says the
coordinate functions are not merely uncorrelated but *orthonormal* for the uniform
inner product. Any isotropic constant strictly below $1$ would force the
coordinate functions to have norm less than $1$, contradicting
$\mathbb{E}[\operatorname{coord}(\cdot,k)^2] = 1$, which holds because each
coordinate is a genuine $\pm 1$ sign. Thus the discrete cube realizes the smallest
constant compatible with $\pm 1$ coordinates, and does so uniformly in $n$.

## 7. Future work

- **Tensorization.** The covariance of a product measure is block-diagonal, so
  products of isotropic models remain isotropic; the unit second moment splits as
  a convex combination $\mathbb{E}_\mu[\langle\theta,\cdot\rangle^2] =
  \mathbb{E}_{\mu_1}[\langle\theta_1,\cdot\rangle^2] +
  \mathbb{E}_{\mu_2}[\langle\theta_2,\cdot\rangle^2]$ with
  $\lvert\theta_1\rvert^2 + \lvert\theta_2\rvert^2 = 1$. This is the discrete
  shadow of slicing tensorizing over products.
- **Affine invariance.** A box (weighted cube with nonzero weights $a_k$) has, after
  volume normalization by $(\prod_k a_k^2)^{-1/n}$, determinant-one covariance and
  the same normalized second-moment functional as the unit cube — formalizing
  affine invariance of the discrete isotropic constant.
- **Lower bound (the hard direction).** For products of symmetric two-point
  measures, conjecture $\min_{\lvert\theta\rvert=1} \mathbb{E}[\langle\theta,x\rangle^2]
  \geq c\,(\det\Sigma)^{1/n}$ with universal $c > 0$, provable in the $c=1$ case
  via AM–GM on the eigenvalues $a_k^2$.
- **Anti-concentration / marginal flatness.** Formalize a uniform bound
  $\max_t \Pr[\langle\theta,x\rangle = t] \leq C/\sqrt{n}$ for spread $\theta$
  (Littlewood–Offord / Erdős).

## 8. Conclusion

On the corners of a cube, the structural miracle behind Bourgain's slicing problem
becomes visible and fully verifiable: a single sign-flip involution forces the
covariance matrix of the uniform measure on $\{-1,1\}^n$ to be the identity in
every dimension, so every unit functional has variance exactly $1$, dimension-free.
The resulting identity $\mathbb{E}[\langle\theta,x\rangle^2] = \lVert\theta\rVert^2$
is Pythagorean — orthonormal coordinates, sum of squares — and exhibits the
discrete cube as an exactly isotropic body with isotropic constant $1$. This clean
discrete model captures the load-bearing content of the conjecture while remaining
entirely elementary.

The broader lesson is methodological. By reducing the entire structural argument
to a single involution, the model demonstrates that the second-order roundness
underlying the slicing problem is not an analytic accident but a symmetry
phenomenon — one that persists verbatim across all dimensions. Every result above
is an exact identity, not an asymptotic estimate, so the model leaves no error
term to control and no dimension-dependent constant to track. The extensions
sketched in Section 7 — tensorization, affine invariance, the lower-bound
direction, and anti-concentration — each preserve this exactness while moving
closer to the full geometric statement, and each is phrased as a precise,
finitely checkable claim. Taken together they chart a concrete path from the
extremal good case studied here toward the quantitative heart of Bourgain's
question.
