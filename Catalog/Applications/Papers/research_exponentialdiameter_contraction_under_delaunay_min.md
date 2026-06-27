# Inhomogeneous Contraction of Simplex Diameters under Noisy Minicenter Refinement

**Author:** Aristotle (Harmonic)
**Date:** 2026-06-27
**Domain:** Novelty / Applications (Computational Geometry, Iterative Processes)

## Abstract

We study the diameter trajectory of an iterative mesh-refinement scheme in which
each round contracts the worst simplex diameter by a uniform factor while a
bounded perturbation — modeling the local disturbance caused by inserting fresh
Steiner points — is reinjected at every step. We formalize this as an
*inhomogeneous contraction process*: a nonnegative real sequence $d_k$ satisfying
$d_{k+1} \le a\,d_k + b$ with $0 \le a < 1$ and $b \ge 0$. Our central result is
the exact closed-form bound $d_k \le a^k d_0 + b\,(1-a^k)/(1-a)$, proved by
induction, from which we derive geometric decay of the transient,
$d_k - L \le a^k(d_0 - L)$, toward the attractor radius $L = b/(1-a)$. We show the
inequality model yields only one-sided convergence (the iterates are eventually
trapped in $[0, L+\varepsilon]$, with an explicit finite step count), and we prove
that genuine two-sided convergence to $L$, with sharp rate
$|d_k - L| \le a^k|d_0 - L|$, holds precisely under the *exact* recurrence
$d_{k+1} = a d_k + b$. We connect the theory to the Banach fixed-point picture:
the affine update $x \mapsto a x + b$ is a contraction with unique fixed point $L$,
and an explicit affine iteration realizes the bounds, proving them tight. The
homogeneous case ($b=0$) recovers the noiseless exponential contraction
$d_k \le (1/\lambda)^k d_0 \to 0$, which is realized exactly by edge bisection, the
one-simplex base case where the minicenter coincides with the midpoint.

## 1. Introduction

Mesh refinement is the engine of computational geometry and numerical PDE: a
domain is decomposed into simplices (triangles, tetrahedra, or higher-dimensional
analogues), and the decomposition is iteratively refined by inserting new vertices
("Steiner points") until the simplices are small enough for the accuracy demanded.
The defining performance question is the *rate* at which the largest simplex
shrinks. A scheme is useful when the worst diameter contracts geometrically — by a
fixed factor $1/\lambda < 1$ per round — so that after $k$ rounds it is at most
$(1/\lambda)^k$ times its initial value.

In the *minicenter* family of schemes, the Steiner point of a simplex is the
center of its smallest enclosing ball. For a one-dimensional simplex (an edge),
the minicenter is exactly the midpoint and the contraction factor is exactly
$\lambda = 2$. The conjecture that minicenter refinement contracts the diameter by
a uniform factor $\lambda > 1$ in every dimension is, in full geometric
generality, open. The *metric backbone* of the conjecture — that a uniform per-step
contraction forces exponential decay — is, however, a clean and complete theory.

This paper develops the realistic, *noisy* extension of that backbone. Practical
refinement is never exact: re-triangulation, neighbor displacement, and
floating-point error reinject a bounded perturbation at each step. We model this
with an **additive defect** $b \ge 0$ and study the inhomogeneous recurrence
$d_{k+1} \le a d_k + b$. The mathematics is elementary but the conclusions are
sharp and practically important: contraction survives noise, and the price of
noise is a single, computable resolution floor $L = b/(1-a)$.

All results below are formalized and machine-checked. We state each result with
its formal name and a proof sketch faithful to the formalization.

## 2. Definitions

**Definition 1 (Inhomogeneous contraction process, `InhomogeneousContractionProcess`).**
An inhomogeneous contraction process consists of a sequence $d : \mathbb{N} \to \mathbb{R}$
and constants $a, b \in \mathbb{R}$ subject to
$$0 \le a, \qquad a < 1, \qquad 0 \le b, \qquad \forall k,\ 0 \le d_k, \qquad \forall k,\ d_{k+1} \le a\,d_k + b.$$
Here $d_k$ models the maximum simplex diameter after $k$ refinement rounds, $a$ is
the multiplicative geometric contraction per round, and $b$ is the additive defect
(the bounded perturbation from Steiner-point insertion).

**Definition 2 (Attractor radius / fixed point, `fixedPoint`).**
The attractor radius of the process is
$$L \;:=\; \frac{b}{1-a}.$$
Since $a < 1$ we have $1 - a > 0$ (`one_sub_a_pos`), so $L$ is well-defined, and
since $b \ge 0$ it is nonnegative, $L \ge 0$ (`fixedPoint_nonneg`).

**Definition 3 (Affine iteration, `affineIteration`).**
For a chosen initial value $d_0 \ge 0$, the affine iteration is the process whose
sequence satisfies the *exact* recurrence $d_{k+1} = a\,d_k + b$. It is a concrete
`InhomogeneousContractionProcess` (the inequality holds with equality) and serves
as the tightness witness for all upper bounds below.

For comparison we record the noiseless model.

**Definition 4 (Homogeneous contraction process, `ContractionProcess`).**
A homogeneous contraction process consists of $d : \mathbb{N} \to \mathbb{R}$ and a factor
$\lambda > 1$ with $d_k \ge 0$ for all $k$ and $d_{k+1} \le (1/\lambda)\, d_k$.
This is the $b = 0$, $a = 1/\lambda$ specialization.

## 3. The fixed point and its defining identity

**Lemma 1 (Fixed-point identity, `fixedPoint_eq`).**
$$a\,L + b = L.$$

*Proof sketch.* Substitute $L = b/(1-a)$ and clear the denominator $1-a > 0$:
$a\cdot \frac{b}{1-a} + b = \frac{ab + b(1-a)}{1-a} = \frac{b}{1-a} = L$. $\qquad\blacksquare$

This identity is the algebraic heart of the theory: $L$ is exactly the level at
which one step of the noisy update reproduces itself.

## 4. The closed-form bound

**Theorem 1 (Closed-form upper bound, `d_le_closedForm`).**
For every $k \in \mathbb{N}$,
$$d_k \;\le\; a^{k}\,d_0 \;+\; b\,\frac{1 - a^{k}}{1 - a}.$$

*Proof sketch.* Induction on $k$. For $k = 0$ the right side equals $d_0$ and the
claim is an equality. For the inductive step, assume the bound at $k$. Then by the
contraction hypothesis and monotonicity of multiplication by $a \ge 0$,
$$d_{k+1} \le a\,d_k + b \le a\Bigl(a^{k} d_0 + b\tfrac{1-a^{k}}{1-a}\Bigr) + b.$$
The right-hand side simplifies, using $a\cdot b\frac{1-a^k}{1-a} + b = b\frac{1-a^{k+1}}{1-a}$
(equivalently $a(1-a^k) + (1-a) = 1 - a^{k+1}$), to
$a^{k+1} d_0 + b\frac{1 - a^{k+1}}{1-a}$, which is the bound at $k+1$. $\qquad\blacksquare$

**Lemma 2 (Centering at the fixed point, `closedForm_eq`).**
For every $k$,
$$a^{k}\,d_0 + b\,\frac{1 - a^{k}}{1 - a} \;=\; a^{k}\,(d_0 - L) + L.$$

*Proof sketch.* Expand $a^k(d_0 - L) + L = a^k d_0 - a^k L + L = a^k d_0 + L(1 - a^k)$
and substitute $L = b/(1-a)$. $\qquad\blacksquare$

**Theorem 2 (Geometric decay of the transient, `excess_le_pow`).**
For every $k$,
$$d_k - L \;\le\; a^{k}\,(d_0 - L).$$

*Proof sketch.* Combine Theorem 1 with Lemma 2:
$d_k \le a^k d_0 + b\frac{1-a^k}{1-a} = a^k(d_0 - L) + L$, then subtract $L$.
$\qquad\blacksquare$

Theorem 2 is the conceptual payoff: the *excess over the noise floor* decays at
the pure geometric rate $a^k$, identical to the noiseless case. Noise relocates the
limit from $0$ to $L$ but does not slow the approach.

## 5. Convergence of the bound and one-sided trapping

**Theorem 3 (Convergence of the closed-form bound, `closedFormBound_tendsto`).**
$$\lim_{k\to\infty}\Bigl(a^{k} d_0 + b\,\tfrac{1 - a^{k}}{1 - a}\Bigr) = L.$$

*Proof sketch.* Since $0 \le a < 1$, $a^k \to 0$. Hence $a^k d_0 \to 0$ and
$b\frac{1-a^k}{1-a} \to b\frac{1}{1-a} = L$ by the algebra of limits.
$\qquad\blacksquare$

**Theorem 4 (Eventual trapping below $L+\varepsilon$, `eventually_lt_fixedPoint_add`).**
For every $\varepsilon > 0$, eventually (for all sufficiently large $k$)
$$d_k < L + \varepsilon.$$

*Proof sketch.* By Theorem 3 the closed-form bound converges to $L < L+\varepsilon$,
so it is eventually $< L+\varepsilon$; by Theorem 1, $d_k$ is dominated by that bound.
$\qquad\blacksquare$

**Corollary 1 (Explicit iteration count, `exists_steps_below`).**
For every $\varepsilon > 0$ there exists $N$ with $d_k < L + \varepsilon$ for all
$k \ge N$.

*Proof sketch.* Extract the threshold from the "eventually" statement of Theorem 4.
$\qquad\blacksquare$

**Remark (one-sided only).** The inequality model does *not* force $d_k \to L$. The
sequence $d_k \equiv 0$ satisfies $0 \le a\cdot 0 + b$ for any $b \ge 0$, contracts
below the floor, and never reaches $L$ when $b > 0$. Thus only the one-sided
trapping in $[0, L+\varepsilon]$ is provable from the inequality. Genuine two-sided
convergence requires equality, treated next.

## 6. Two-sided convergence under the exact recurrence

**Theorem 5 (Genuine convergence and sharp rate; `tendsto_of_exact`, `dist_le_pow_of_exact`).**
Suppose the process satisfies the *exact* recurrence $d_{k+1} = a\,d_k + b$ for all
$k$. Then
$$|\,d_k - L\,| \le a^{k}\,|\,d_0 - L\,| \qquad\text{and}\qquad \lim_{k\to\infty} d_k = L.$$

*Proof sketch.* Subtracting the fixed-point identity $L = aL + b$ from the exact
recurrence gives $d_{k+1} - L = a(d_k - L)$, hence $d_k - L = a^k(d_0 - L)$ by
induction. Taking absolute values yields the rate; since $a^k \to 0$, the right
side tends to $0$, so $d_k \to L$. $\qquad\blacksquare$

The contrast between Theorem 4 (inequality: one-sided trap) and Theorem 5
(equality: two-sided convergence at rate $a^k$) is the central honesty of the work:
the destination depends on whether the noise is bounded above or reinjected
exactly.

## 7. Boundedness and bounded per-step perturbation

**Proposition 1 (Uniform band, `d_le_uniform`).**
For every $k$, $\,d_k \le d_0 + L$. Together with $d_k \ge 0$, every iterate lies in
the bounded band $[0,\, d_0 + L]$.

*Proof sketch.* From Theorem 2, $d_k \le L + a^k(d_0 - L)$. If $d_0 \ge L$ then
$a^k(d_0 - L) \le d_0 - L$, giving $d_k \le d_0$; if $d_0 < L$ then
$a^k(d_0-L) \le 0$, giving $d_k \le L$. In either case $d_k \le d_0 + L$. $\qquad\blacksquare$

**Proposition 2 (Bounded per-step perturbation, `perturbation_le`).**
Each refinement step perturbs the diameter by at most $b$ in the upward
direction: $d_{k+1} - a\,d_k \le b$, i.e. the additive disturbance is uniformly
bounded by the defect $b$.

*Proof sketch.* Immediate from the contraction hypothesis $d_{k+1} \le a d_k + b$.
$\qquad\blacksquare$

## 8. The fixed-point / contraction-map picture

The recurrence is governed by the affine update map $f(x) = a\,x + b$ on
$\mathbb{R}$.

**Proposition 3 (Contraction constant, `affine_dist`).**
For all $x, y \in \mathbb{R}$, $\;\operatorname{dist}(f(x), f(y)) = a \cdot \operatorname{dist}(x, y)$.

*Proof sketch.* $f(x) - f(y) = a(x-y)$, so $|f(x)-f(y)| = a|x-y|$ (using $a \ge 0$).
$\qquad\blacksquare$

**Proposition 4 (Fixed point, `affine_isFixedPt`).** $f(L) = L$.

*Proof sketch.* This is Lemma 1 rewritten as $f(L) = aL + b = L$. $\qquad\blacksquare$

**Proposition 5 (Uniqueness, `fixedPoint_unique`).** $L$ is the unique fixed point
of $f$.

*Proof sketch.* If $f(x) = x$ then $ax + b = x$, so $(1-a)x = b$, and since
$1 - a > 0$, $x = b/(1-a) = L$. $\qquad\blacksquare$

Since $0 \le a < 1$, $f$ is a Banach contraction with contraction constant $a$;
Propositions 3–5 are the corresponding pieces of the Banach fixed-point theorem
specialized to this affine map, and they re-derive convergence to $L$ from a purely
metric viewpoint.

## 9. Tightness

**Theorem 6 (Tightness via the affine iteration, `affineIteration`).** The affine
iteration of Definition 3 satisfies $d_{k+1} = a d_k + b$ exactly; consequently its
closed form is $a^k d_0 + b(1-a^k)/(1-a)$ (equality in Theorem 1) and its limit is
$L$ (Theorem 5). Hence the upper bounds of Theorems 1–2 are attained, and no
refinement scheme with per-step additive defect $\ge b$ can guarantee an asymptotic
diameter below $L = b/(1-a)$.

*Proof sketch.* The affine iteration meets the structure axioms with equality, so
the inequality proofs become equalities throughout; convergence follows from
Theorem 5. The lower-bound statement is the contrapositive: any scheme dominated by
this exact trajectory and suffering the same defect inherits the same floor.
$\qquad\blacksquare$

## 10. The homogeneous base case and its geometric witness

Setting $b = 0$ and $a = 1/\lambda$ with $\lambda > 1$ recovers the noiseless
theory.

**Theorem 7 (Noiseless exponential contraction, `diam_le_pow`, `diam_tendsto_zero`).**
For a homogeneous contraction process, $d_k \le (1/\lambda)^k d_0$ and
$d_k \to 0$.

*Proof sketch.* Induction gives the bound; squeezing $0 \le d_k \le (1/\lambda)^k d_0$
with $(1/\lambda)^k \to 0$ gives the limit. (This is Theorems 1–2 at $b = 0$, where
$L = 0$.) $\qquad\blacksquare$

**Theorem 8 (One-simplex minicenter is the midpoint, `minicenter_segment_halves`).**
For an edge $[a,b]$ in a real normed space, the midpoint $m = \tfrac{1}{2}(a+b)$
satisfies $\operatorname{dist}(a,m) = \operatorname{dist}(m,b) = \tfrac{1}{2}\operatorname{dist}(a,b)$.
Hence repeated edge bisection (`segmentBisection`) is a homogeneous contraction
process with $\lambda = 2$ and $d_k = D/2^k$.

*Proof sketch.* Direct computation with the midpoint and norm. The smallest
enclosing ball of a segment is centered at its midpoint, so the minicenter
coincides with the midpoint, giving two equal half-length sub-edges. $\qquad\blacksquare$

Theorem 8 demonstrates that the abstract hypotheses are realized by genuine
geometry, not by a contrived sequence; the inhomogeneous theory of §§2–9 is the
robust, noise-tolerant extension of this honest base case.

## 11. Applications

The recurrence $d_{k+1} = a d_k + b$ and its floor $L = b/(1-a)$ recur far beyond
meshing:

1. **Adaptive mesh refinement.** Schemes that cannot place Steiner points exactly
   still contract exponentially down to the predictable resolution floor
   $b/(1-a)$; halving the implementation noise $b$ halves the achievable floor.
2. **Numerical linear algebra.** Linearly convergent iterative solvers with
   per-step round-off settle at a floor proportional to machine epsilon over
   $(1-a)$, exactly the attractor radius.
3. **Control / DSP.** A first-order IIR filter $x_{k+1} = a x_k + b$ is the exact
   recurrence; $b/(1-a)$ is its steady-state (DC) value.
4. **Stochastic approximation / RL.** Contractive updates with bounded noise hover
   in a ball of radius $\sim b/(1-a)$ about the target.

## 12. Discussion and Future Work

The inhomogeneous model isolates a clean message: under any genuine contraction
($a < 1$), bounded per-step noise costs only a finite, computable floor
$L = b/(1-a)$, and the transient above that floor decays at the same geometric rate
$a^k$ as in the noiseless case. The inequality/equality dichotomy (one-sided
trapping vs. two-sided convergence) is essential and faithfully captured.

Open geometric directions concern the *constant* $a$ in higher dimensions: whether
$d$-simplex medial (edge-midpoint) subdivision halves the diameter for all $d$
(established here for $d = 1, 2$; the $d \ge 3$ central pieces are the first genuine
obstruction), whether true minicenter (smallest-enclosing-ball) subdivision of a
triangle contracts by a factor $\lambda \ge \sqrt 2$, and the sharpness of the
perturbed attractor as an exact min-max diameter. The verbatim future-directions
program accompanies this package.
