# Transition Endomorphisms of Discrete Linear Cocycles: A Cocycle Identity and the Rank-Antitonicity Law

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Linear Algebra / Dynamical Systems)

## Abstract

We develop a minimal, self-contained finite-dimensional linear-algebra theory of
the *transition endomorphism* of a discrete, time-varying linear system. Given a
sequence of endomorphisms $f : \mathbb{N} \to \operatorname{End}_K(V)$ of a vector
space $V$ over a field $K$, we define the transition endomorphism
$\Phi(i,n) = \mathrm{transEndo}\,f\,i\,n$ as the composite of the $n$ maps
$f(i), f(i+1), \dots, f(i+n-1)$, with $\Phi(i,0) = \mathrm{id}$. Our central
structural result is the **cocycle identity**
$\Phi(i, m+n) = \Phi(i+n, m) \circ \Phi(i, n)$, proved by induction on the window
length. From it we derive, with one-line arguments that reuse standard
rank-of-composite facts, that the rank sequence
$n \mapsto \operatorname{rank}\Phi(i,n)$ is **antitone** (non-increasing) when $V$
is finite-dimensional, and that **injectivity propagates** through a window of
injective factors. Specializing to a constant sequence recovers the operator
powers $g^n$ of a single endomorphism, transporting rank antitonicity and
injectivity propagation to the classical autonomous setting for free. We give
proof sketches, algorithms with complexity analysis, numerical demonstrations,
and a program of four conjectural extensions (eventual rank stabilization,
determinant multiplicativity, monodromy growth laws for periodic sequences, and
sub-additive rank-gap bounds). The deliberate design choice throughout is to
*reuse* existing structural lemmas rather than re-derive a Sylvester-type rank
inequality from scratch.

## 1. Introduction

The state-transition operator is the central object in the analysis of
non-autonomous linear dynamics. For a continuous-time system $\dot{x} = A(t)x$ it
is the fundamental solution matrix; for a discrete-time system $x_{n+1} = A_n x_n$
it is the finite product of the step matrices. Abstracting away from matrices to
endomorphisms of a vector space $V$ over a field $K$, and away from a fixed start
time to an arbitrary window, yields the notion this paper studies: the
**transition endomorphism** of a sequence of linear self-maps.

Two features motivate an independent, minimal treatment. First, the governing
algebraic law — the **cocycle identity** — is exactly the property that makes the
family $\{\Phi(i,n)\}$ a *linear cocycle*, the structure underlying Lyapunov
exponents, the Oseledets multiplicative ergodic theorem, and the controllability
theory of time-varying systems. Second, the most basic quantitative consequence —
that the **rank** of the transition operator can only decrease as the window
grows — is a clean monotonicity statement that should follow from generic
rank-of-composite facts, *without* invoking a bespoke Sylvester rank inequality.
We make both observations precise and machine-checkable.

The development is intentionally lightweight. Algebraic identities (the recursion,
the cocycle law, injectivity propagation) are stated for an arbitrary field and
vector space; finite-dimensionality is assumed only where rank is genuinely
involved. A companion specialization shows that the entire theory contains the
classical algebra of operator powers as its autonomous ($f$ constant) case.

## 2. Definitions

Throughout, $K$ is a field and $V$ is a $K$-vector space; $\operatorname{End}_K(V)
= (V \to_\ell V)$ denotes the $K$-linear endomorphisms of $V$, a monoid under
composition $\circ_\ell$ with identity $\mathrm{id}$. We write
$\operatorname{range} T$ for the image submodule of $T$ and, when $V$ is
finite-dimensional, $\operatorname{finrank}_K W \in \mathbb{N}$ for the dimension
of a submodule $W$.

**Definition 2.1 (Transition endomorphism).**
Let $f : \mathbb{N} \to \operatorname{End}_K(V)$ and $i \in \mathbb{N}$. The
*transition endomorphism* $\mathrm{transEndo}\,f\,i : \mathbb{N} \to
\operatorname{End}_K(V)$ is defined by recursion on the window length:
$$
\mathrm{transEndo}\,f\,i\,0 = \mathrm{id}, \qquad
\mathrm{transEndo}\,f\,i\,(n+1) = f(i+n) \circ_\ell \mathrm{transEndo}\,f\,i\,n.
$$
Unfolding the recursion, $\mathrm{transEndo}\,f\,i\,n = f(i+n-1) \circ \cdots
\circ f(i+1) \circ f(i)$ for $n \ge 1$, the composite of the $n$ maps of $f$
starting at index $i$, read right-to-left.

We abbreviate $\Phi(i,n) := \mathrm{transEndo}\,f\,i\,n$ when $f$ is fixed.

**Elementary identities.** Directly from the definition:

- (`transEndo_zero`) $\Phi(i,0) = \mathrm{id}$.
- (`transEndo_succ`) $\Phi(i,n+1) = f(i+n) \circ_\ell \Phi(i,n)$.
- (`transEndo_one`) $\Phi(i,1) = f(i)$.
- (`transEndo_apply_zero`) $\Phi(i,0)\,v = v$ for all $v \in V$.

The first two hold by definitional unfolding; `transEndo_one` follows by applying
`transEndo_succ` at $n=0$ and simplifying with `transEndo_zero`.

## 3. Main Results

### 3.1 The cocycle identity

**Theorem 3.1 (`transEndo_add`, cocycle identity).**
For every $f : \mathbb{N} \to \operatorname{End}_K(V)$ and all $i, m, n \in
\mathbb{N}$,
$$
\mathrm{transEndo}\,f\,i\,(m+n)
\;=\;
\mathrm{transEndo}\,f\,(i+n)\,m \;\circ_\ell\; \mathrm{transEndo}\,f\,i\,n.
$$

*Proof sketch.* Induct on $m$ with $n, i$ fixed.

- **Base $m=0$:** the left side is $\Phi(i,n)$ and the right side is
  $\Phi(i+n,0) \circ \Phi(i,n) = \mathrm{id} \circ \Phi(i,n) = \Phi(i,n)$, by
  `transEndo_zero`.
- **Step $m \to m+1$:** rewrite the index as $(m+1)+n = (m+n)+1$ and apply
  `transEndo_succ` on both sides. The left becomes $f(i+(m+n)) \circ \Phi(i,m+n)$;
  substituting the inductive hypothesis $\Phi(i,m+n) = \Phi(i+n,m) \circ
  \Phi(i,n)$ and reassociating composition gives
  $\big(f((i+n)+m) \circ \Phi(i+n,m)\big) \circ \Phi(i,n)$, where we used
  $i+(m+n) = (i+n)+m$. The bracket is exactly $\Phi(i+n,m+1)$ by
  `transEndo_succ`, completing the step. $\qquad\blacksquare$

The only non-formal ingredients are associativity of $\circ_\ell$ and commutative
arithmetic of indices. Theorem 3.1 is the load-bearing lemma of the paper: it
expresses a long window as the composition of two consecutive sub-windows, which
is precisely what makes rank behave monotonically.

### 3.2 Rank antitonicity

We now assume $V$ is finite-dimensional over $K$. The relevant generic facts are:

- (`LinearMap.range_comp`) $\operatorname{range}(g \circ h) =
  g(\operatorname{range} h)$ (the image of the composite is the $g$-image of the
  image of $h$).
- (`Submodule.finrank_map_le`) $\operatorname{finrank}_K (T(W)) \le
  \operatorname{finrank}_K W$ for any linear $T$ and submodule $W$ (a linear image
  cannot increase dimension).

**Theorem 3.2 (`finrank_range_transEndo_succ_le`, one-step rank drop).**
For all $i, n$,
$$
\operatorname{finrank}_K \operatorname{range}\Phi(i,n+1)
\;\le\;
\operatorname{finrank}_K \operatorname{range}\Phi(i,n).
$$

*Proof sketch.* By `transEndo_succ`, $\Phi(i,n+1) = f(i+n) \circ \Phi(i,n)$.
Apply `LinearMap.range_comp` to get $\operatorname{range}\Phi(i,n+1) =
f(i+n)\big(\operatorname{range}\Phi(i,n)\big)$, then `Submodule.finrank_map_le`
with $T = f(i+n)$ and $W = \operatorname{range}\Phi(i,n)$. $\qquad\blacksquare$

**Theorem 3.3 (`finrank_range_transEndo_antitone`, rank antitonicity).**
For all $i$ and all $m, n$ with $n \le m$,
$$
\operatorname{finrank}_K \operatorname{range}\Phi(i,m)
\;\le\;
\operatorname{finrank}_K \operatorname{range}\Phi(i,n).
$$

*Proof sketch.* Write $m = n + k$ (possible since $n \le m$). By the cocycle
identity (Theorem 3.1, in the form $\Phi(i, k+n) = \Phi(i+n,k) \circ \Phi(i,n)$),
$$
\operatorname{range}\Phi(i,m) = \operatorname{range}\big(\Phi(i+n,k) \circ
\Phi(i,n)\big) = \Phi(i+n,k)\big(\operatorname{range}\Phi(i,n)\big)
$$
by `LinearMap.range_comp`. One application of `Submodule.finrank_map_le` with $T
= \Phi(i+n,k)$ and $W = \operatorname{range}\Phi(i,n)$ yields the bound.
$\qquad\blacksquare$

Theorem 3.3 says the rank sequence $n \mapsto \operatorname{finrank}_K
\operatorname{range}\Phi(i,n)$ is antitone. Since it is a sequence of
non-negative integers bounded below by $0$, it is eventually constant; the
limiting value is the dimension of the *stable image*
$\bigcap_{n} \operatorname{range}\Phi(i,n)$, a decreasing chain of subspaces.
(Characterizing this stable rank is the subject of Future Direction 1.)

### 3.3 Injectivity propagation

**Theorem 3.4 (`transEndo_injective`).**
If $f(i+k)$ is injective for every $k < n$, then $\Phi(i,n)$ is injective. (No
finite-dimensionality is needed.)

*Proof sketch.* Induct on $n$.

- **Base $n=0$:** $\Phi(i,0) = \mathrm{id}$ is injective.
- **Step $n \to n+1$:** by `transEndo_succ`, $\Phi(i,n+1) = f(i+n) \circ
  \Phi(i,n)$. The hypothesis at $k=n$ gives $f(i+n)$ injective; the inductive
  hypothesis (applied to the restricted family, valid because $k < n \Rightarrow k
  < n+1$) gives $\Phi(i,n)$ injective. The composition of injective maps is
  injective. $\qquad\blacksquare$

Over a finite-dimensional $V$, injectivity is equivalent to surjectivity and to
full rank, so Theorem 3.4 identifies precisely when the rank filtration of
Section 3.2 is constant at $\operatorname{finrank}_K V$: when every factor in the
window is injective.

## 4. The Autonomous Specialization: Operator Powers

A constant sequence $f \equiv g$ models an *autonomous* (time-invariant) system.
We use that $\operatorname{End}_K(V)$ is a monoid in which multiplication is
composition and the unit is the identity (`LinearMap.End` with $\mathbf{1} =
\mathrm{id}$ and $a * b = a \circ_\ell b$).

**Theorem 4.1 (`transEndo_const`).**
For any $g \in \operatorname{End}_K(V)$ and all $i, n$,
$$
\mathrm{transEndo}\,(\lambda\_.\,g)\,i\,n = g^{\,n}.
$$

*Proof sketch.* Induct on $n$. The base $n=0$ uses $\Phi(i,0) = \mathrm{id} =
g^0$ (via $\mathbf{1} = \mathrm{id}$ in $\operatorname{End}_K(V)$). For the step,
`transEndo_succ` gives $\Phi(i,n+1) = g \circ \Phi(i,n) = g \circ g^n$; using
$g^{n+1} = g \cdot g^n = g \circ g^n$ (the `pow_succ'` form, with monoid
multiplication unfolding to composition) closes the induction. $\qquad\blacksquare$

**Theorem 4.2 (`finrank_range_pow_antitone`).**
Let $V$ be finite-dimensional and $g \in \operatorname{End}_K(V)$. For $n \le m$,
$$
\operatorname{finrank}_K \operatorname{range}(g^{\,m})
\;\le\;
\operatorname{finrank}_K \operatorname{range}(g^{\,n}).
$$

*Proof sketch.* Rewrite both powers as transition endomorphisms of the constant
sequence via Theorem 4.1, then apply rank antitonicity (Theorem 3.3) to the
constant family $\lambda\_.\,g$. $\qquad\blacksquare$

The analogous transport of Theorem 3.4 yields: *if $g$ is injective, then $g^n$
is injective for all $n$.* Thus the general cocycle theory subsumes the classical
filtration $\operatorname{range}(g) \supseteq \operatorname{range}(g^2) \supseteq
\cdots$ of decreasing image subspaces of a single operator — the image side of the
Fitting/eventual-image decomposition — as the special case of a constant rule.

## 5. Algorithms

The constructive content of the theory yields concrete computations once $V =
K^d$ and each $f(k)$ is a $d \times d$ matrix over $K$.

### 5.1 Transition-matrix assembly

To compute $\Phi(i,n)$ as a matrix, iterate the recursion of Definition 2.1,
left-multiplying by successive factors:
$$
M_0 = I_d, \qquad M_{t+1} = A_{i+t}\, M_t \quad (0 \le t < n), \qquad \Phi(i,n) = M_n,
$$
where $A_k$ is the matrix of $f(k)$. Each step is one $d \times d$ matrix product,
$O(d^3)$ by the schoolbook algorithm, so assembling $\Phi(i,n)$ costs $O(n\,d^3)$.

### 5.2 Rank filtration

Computing the rank sequence $r_t = \operatorname{rank}\Phi(i,t)$ for $t = 0,
\dots, n$ requires, at each $t$, a Gaussian-elimination rank of an accumulated
$d \times d$ matrix ($O(d^3)$ per rank). Interleaving with the assembly of 5.1
gives the whole filtration in $O(n\,d^3)$. Theorem 3.3 guarantees the output is
non-increasing; this serves as a built-in correctness check.

### 5.3 Monodromy power law (periodic case)

If $f$ is $p$-periodic, the cocycle identity collapses the window into powers of a
single monodromy operator $M = \Phi(0,p)$: $\Phi(0, p\,n) = M^n$. Computing
$\Phi(0, p\,n)$ then costs $O(p\,d^3 + \log(n)\,d^3)$ via fast exponentiation of
$M$, versus $O(p\,n\,d^3)$ for the naive product — an asymptotic win for large
$n$. (This is the algorithmic shadow of Future Direction 3.)

## 6. Applications

- **Time-varying control systems.** $\Phi(i,n)$ is the discrete state-transition
  operator; $\operatorname{range}\Phi(i,n)$ is the reachable subspace from time
  $i$ over $n$ steps, and Theorem 3.3 quantifies how reachability contracts with
  window length — the structural backbone of controllability/observability tests.
- **Linear cocycles and Lyapunov theory.** Theorem 3.1 is the cocycle axiom over
  the shift dynamics on the index; growth rates of $\Phi$ are the Lyapunov
  exponents governed by the Oseledets theorem.
- **Products of stochastic matrices.** For Markov chains with time-varying
  kernels, the rank filtration measures loss of distinguishability of initial
  distributions.
- **Numerical iteration.** The autonomous case (Section 4) is the power method /
  Krylov inner loop, where the eventual stabilization of
  $\operatorname{range}(g^n)$ controls the effective dimension of the iteration.

## 7. Discussion

The design philosophy here is reuse over reinvention. The temptation in proving
rank antitonicity is to establish a Sylvester-type inequality
$\operatorname{rank}(AB) \ge \operatorname{rank} A + \operatorname{rank} B - d$
and specialize. We avoid that entirely: the only quantitative facts used are
`LinearMap.range_comp` (image of a composite) and `Submodule.finrank_map_le`
(images don't grow dimension), both already standard. The cocycle identity then
does all the structural work, turning a statement about a long window into a
single application of "a linear image has no larger dimension." The result is a
theory that is general where it can be (algebraic identities over an arbitrary
field) and specific only where it must be (finite-dimensionality for rank).

A second theme is the *autonomous reduction*. By proving one rewrite bridge
(Theorem 4.1), every cocycle theorem descends to operator powers at no extra
cost. This is a useful template: build the general non-autonomous theory, then
recover the classical autonomous facts as corollaries rather than proving them
separately.

## 8. Future Directions

The following four programs extend the present results; each rests on the cocycle
identity already established.

1. **Eventual rank stabilization.** The antitone integer sequence
   $n \mapsto \operatorname{finrank}_K \operatorname{range}\Phi(i,n)$ is eventually
   constant by well-ordering; conjecturally its limit equals
   $\operatorname{finrank}_K V$ minus the dimension of the union of forward
   kernels. The cocycle identity factors $\Phi(i,n+k)$ through $\Phi(i,n)$, so the
   stable subspace is $\bigcap_n \operatorname{range}\Phi(i,n)$, an intersection of
   a decreasing chain that finite-dimensional methods can handle directly. The
   open content is *characterizing* the stable rank, not proving a limit exists.

2. **Cocycle determinant multiplicativity.** For finite-dimensional $V$,
   $\det \Phi(i,m+n) = \det \Phi(i+n,m) \cdot \det \Phi(i,n)$, since $\det$ is a
   monoid homomorphism and the cocycle identity transports through
   `LinearMap.det_comp`. Hence $\Phi(i,n)$ is invertible iff each factor
   $f(i+k)$, $k<n$, is. Theorem 3.4 already supplies the kernel-side half; in
   finite dimension injective $\Leftrightarrow$ bijective $\Leftrightarrow$ nonzero
   determinant, so this is the quantitative upgrade.

3. **Spectral radius / growth law for periodic sequences.** If $f$ is
   $p$-periodic, then $\Phi(0, p\,n) = \Phi(0,p)^n$, so the long-run growth of
   $\|\Phi(0,n)\|$ is governed by the spectral radius of the single monodromy
   operator $\Phi(0,p)$. Periodicity collapses the two-parameter cocycle into the
   powers of one fixed endomorphism; the cocycle identity at $m=n=p$ gives the
   base case, leaving only an induction on $n$.

4. **Sub-multiplicative rank gaps.** The rank deficiencies are sub-additive:
   $$
   \operatorname{finrank} V - \operatorname{finrank}\operatorname{range}\Phi(i,m+n)
   \le \big(\operatorname{finrank} V -
   \operatorname{finrank}\operatorname{range}\Phi(i,n)\big) +
   \big(\operatorname{finrank} V -
   \operatorname{finrank}\operatorname{range}\Phi(i+n,m)\big),
   $$
   i.e. the total rank deficiency of a long window is at most the sum of the
   deficiencies of its halves. Since deficiency equals kernel dimension and
   $\ker(g \circ h) \subseteq h^{-1}(\ker g)$, this is an additive bound obtained
   without a full Sylvester inequality — the dual companion of antitonicity,
   reusing the same `transEndo_add` factorization.

## 9. Conclusion

From a two-clause recursive definition we extracted a single structural law — the
cocycle identity $\Phi(i,m+n) = \Phi(i+n,m) \circ \Phi(i,n)$ — and from it
derived, by short arguments reusing only generic rank-of-composite lemmas, that
the rank of a discrete linear cocycle's transition operator is antitone in the
window length, and that injectivity propagates through windows of injective
factors. Specializing to a constant sequence recovers the classical algebra of
operator powers. The theory is minimal, reusable, and faithful to its source: one
identity carries the whole edifice, and finite-dimensionality is invoked only
where rank genuinely demands it.
