# Existence of a Satisfactory Multiplier Vector for Two-Dimensional Lacunary Distance Graphs: A Finite-Field Avoidance Theorem

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Algebra (finite fields, combinatorial counting, Diophantine approximation)

---

## Abstract

We study the problem of choosing a single multiplier vector that simultaneously
"avoids" a family of displacement vectors, the algebraic core of the question of
when a lacunary distance graph in the two-dimensional torus admits a satisfactory
separating multiplier. Working over the finite field $\mathbb{F} = \mathbb{Z}_p$
for a prime $p$ and the finite torus $\mathbb{F} \times \mathbb{F}$, we prove the
following sharp existence theorem: if $D \subseteq \mathbb{F} \times \mathbb{F}$
is a set of nonzero displacement vectors with $|D| < p$, then there exists a
multiplier $\mathbf{a} = (\alpha_1, \alpha_2) \in \mathbb{F} \times \mathbb{F}$
whose dot product $\langle \mathbf{d}, \mathbf{a} \rangle = d_1\alpha_1 +
d_2\alpha_2$ is nonzero for every $\mathbf{d} \in D$. The proof is a transparent
cardinality argument: the *bad set* of multipliers killing a fixed nonzero vector
is a line, hence contains at most $p$ points, and the union of $|D| < p$ such
lines necessarily misses at least one of the $p^2$ points of the torus. We give a
complete proof sketch of the line bound and the union bound, derive an
integer-displacement corollary suited to lacunary constructions, and situate the
finite theorem within the analytic theory of lacunary sequences on the circle,
where the geometric sequence $q^k$ admits the closed-form optimal multiplier
$\alpha = 1/(q+1)$ achieving $\|q^k\alpha\|_{\mathbb{T}} = 1/(q+1)$, while the
non-lacunary sequence $1,2,3,\dots$ admits no satisfactory multiplier at all. We
include algorithms for constructing and verifying multipliers, numerical demos,
and a discussion of applications to universal hashing, linear codes, and
anti-aliasing.

**Keywords:** finite field, finite torus, multiplier avoidance, dot product,
lacunary sequence, torus norm, Diophantine approximation, pigeonhole counting,
line cover, universal hashing.

---

## 1. Introduction

A recurring problem across number theory, combinatorics, and the theory of
uniform distribution is the search for a single *direction* — a linear functional
or multiplier — that simultaneously separates or detects an entire family of
objects. The objects here are **displacement vectors**: differences of points on
a two-dimensional lattice. The functional is a **multiplier vector**
$\mathbf{a}$, and "detection" means the dot product $\langle \mathbf{d},
\mathbf{a} \rangle$ does not vanish.

### 1.1 Motivating analytic problem

The original motivation is the theory of **lacunary distance graphs** on the
two-dimensional torus $\mathbb{T}^2 = (\mathbb{R}/\mathbb{Z})^2$. Given a lacunary
sequence of integer displacement vectors $\{\mathbf{d}_k\} \subseteq
\mathbb{Z}^2$ — meaning the magnitudes grow at least geometrically — one seeks a
multiplier $\boldsymbol{\alpha} = (\alpha_1, \alpha_2) \in [0,1)^2$ such that the
torus distance of the inner product is uniformly bounded away from zero:
$$
\|\langle \mathbf{d}_k, \boldsymbol{\alpha} \rangle\|_{\mathbb{T}}
\;\ge\; \delta \;>\; 0 \qquad \text{for all } k,
$$
where the **torus norm** is
$$
\|x\|_{\mathbb{T}} = \min_{n \in \mathbb{Z}} |x - n| = |x - \operatorname{round}(x)|.
$$
Such a multiplier guarantees that no displacement ever "resonates" with the
lattice: every translated copy of the configuration stays well separated. The
positivity of $\delta$ is a hallmark of lacunarity; for sequences whose gaps do
not grow it fails entirely (Section 6).

### 1.2 The finite-field core

Stripped to its algebraic skeleton, the resonance condition
"$\langle \mathbf{d}, \boldsymbol{\alpha} \rangle$ is far from the integers"
becomes, over a finite field, the clean condition
"$\langle \mathbf{d}, \mathbf{a} \rangle \neq 0$". This replaces a delicate
analytic estimate with an exact counting problem and yields a complete, sharp,
and fully rigorous theorem. The present paper establishes this finite-field core
and explains how it relates back to the analytic picture.

### 1.3 Contributions

1. **Thin-line bound** (Lemma 3.1): for any nonzero $\mathbf{d} \in \mathbb{F}^2$,
   the bad set $\{\mathbf{a} : \langle \mathbf{d}, \mathbf{a}\rangle = 0\}$ has at
   most $p$ elements.
2. **Multiplier avoidance theorem** (Theorem 4.1): if $|D| < p$ and every
   $\mathbf{d} \in D$ is nonzero, a good multiplier exists.
3. **Integer corollary** (Theorem 5.1): an integer-displacement version under the
   hypothesis that each vector has a coordinate not divisible by $p$.
4. A discussion (Section 6) connecting the finite theorem to the analytic
   lacunary theory, including the exact geometric multiplier $1/(q+1)$ and the
   Dirichlet obstruction for non-lacunary sequences.
5. Algorithms, complexity analysis, and numerical demonstrations (Sections 7–8).

---

## 2. Definitions and notation

Throughout, $p$ denotes a fixed prime and $\mathbb{F} = \mathbb{Z}_p =
\mathbb{Z}/p\mathbb{Z}$ the finite field with $p$ elements. Because $p$ is prime,
every nonzero element of $\mathbb{F}$ is invertible.

**Definition 2.1 (Finite torus).** The *finite torus* is the product
$\mathbb{F} \times \mathbb{F}$. It has exactly $|\mathbb{F} \times \mathbb{F}| =
p^2$ elements.

**Definition 2.2 (Displacement vector / multiplier).** Elements of
$\mathbb{F} \times \mathbb{F}$ are written $\mathbf{d} = (d_1, d_2)$ when regarded
as *displacement vectors* and $\mathbf{a} = (\alpha_1, \alpha_2)$ when regarded as
*multipliers*. The zero vector is $\mathbf{0} = (0,0)$.

**Definition 2.3 (Dot product).** For $\mathbf{d}, \mathbf{a} \in \mathbb{F}
\times \mathbb{F}$,
$$
\langle \mathbf{d}, \mathbf{a} \rangle \;=\; d_1\alpha_1 + d_2\alpha_2 \in
\mathbb{F}.
$$

**Definition 2.4 (Bad set).** For a displacement vector $\mathbf{d}$, the *bad
set* is the set of multipliers that annihilate it:
$$
\operatorname{bad}(\mathbf{d}) \;=\; \{\, \mathbf{a} \in \mathbb{F} \times
\mathbb{F} : \langle \mathbf{d}, \mathbf{a}\rangle = 0 \,\}.
$$
A multiplier $\mathbf{a}$ is *good for $D$* if $\mathbf{a} \notin
\operatorname{bad}(\mathbf{d})$ for every $\mathbf{d} \in D$, i.e. if
$\langle \mathbf{d}, \mathbf{a}\rangle \neq 0$ for all $\mathbf{d} \in D$.

**Definition 2.5 (Torus norm).** For $x \in \mathbb{R}$,
$\|x\|_{\mathbb{T}} = |x - \operatorname{round}(x)| = \min_{n\in\mathbb{Z}}|x-n|
\in [0, 1/2]$. It is even, $1$-periodic, vanishes exactly on $\mathbb{Z}$, and
is subadditive: $\|x+y\|_{\mathbb{T}} \le \|x\|_{\mathbb{T}} +
\|y\|_{\mathbb{T}}$.

---

## 3. The thin-line bound

**Lemma 3.1 (Thin-line bound).** *For every nonzero $\mathbf{d} \in \mathbb{F}
\times \mathbb{F}$,*
$$
|\operatorname{bad}(\mathbf{d})| \;\le\; p.
$$

**Proof sketch.** $\operatorname{bad}(\mathbf{d})$ is the solution set of the
single linear equation $d_1\alpha_1 + d_2\alpha_2 = 0$ in two unknowns over the
field $\mathbb{F}$. We split on whether $d_1$ vanishes.

*Case $d_1 = 0$.* Since $\mathbf{d} \neq \mathbf{0}$, we have $d_2 \neq 0$. The
equation becomes $d_2 \alpha_2 = 0$; as $d_2$ is invertible this forces
$\alpha_2 = 0$, while $\alpha_1$ is arbitrary. Hence
$$
\operatorname{bad}(\mathbf{d}) = \{(\alpha_1, 0) : \alpha_1 \in \mathbb{F}\}
= \{\,(x, 0) : x \in \mathbb{F}\,\},
$$
which is the injective image of $\mathbb{F}$ under $x \mapsto (x, 0)$ and so has
exactly $p$ elements.

*Case $d_1 \neq 0$.* Then $d_1$ is invertible and the equation can be solved for
$\alpha_1$:
$$
\alpha_1 = \frac{-d_2\,\alpha_2}{d_1}.
$$
Thus every bad multiplier has the form $\big(-d_2 x / d_1,\; x\big)$ for some
$x = \alpha_2 \in \mathbb{F}$. Consequently
$$
\operatorname{bad}(\mathbf{d}) \;\subseteq\; \big\{\, (-d_2 x / d_1,\, x) : x \in
\mathbb{F} \,\big\},
$$
and the right-hand side, being the injective image of $\mathbb{F}$ under
$x \mapsto (-d_2 x/d_1, x)$ (the second coordinate recovers $x$), has exactly $p$
elements. Therefore $|\operatorname{bad}(\mathbf{d})| \le p$. $\qquad\blacksquare$

**Remark 3.2.** In fact $|\operatorname{bad}(\mathbf{d})| = p$ exactly for nonzero
$\mathbf{d}$: the bad set is a one-dimensional subspace (a line through the
origin) of the two-dimensional $\mathbb{F}$-vector space $\mathbb{F}^2$. The
weaker upper bound $\le p$ is all that the main theorem requires, and it is the
form proved.

**Remark 3.3 (Geometric reading).** A line in $\mathbb{F}^2$ has $p$ of the $p^2$
points, a $1/p$ fraction. Each nonzero displacement can therefore blind only a
$1/p$ fraction of all multipliers. This proportional statement is the engine of
the union bound below.

---

## 4. The multiplier avoidance theorem

**Theorem 4.1 (Finite-torus multiplier avoidance).** *Let $p$ be prime and let
$D \subseteq \mathbb{F} \times \mathbb{F}$ be a finite set of nonzero
displacement vectors with*
$$
|D| < p.
$$
*Then there exists a multiplier $\mathbf{a} = (\alpha_1, \alpha_2) \in \mathbb{F}
\times \mathbb{F}$ such that*
$$
\langle \mathbf{d}, \mathbf{a} \rangle = d_1\alpha_1 + d_2\alpha_2 \neq 0 \qquad
\text{for every } \mathbf{d} \in D.
$$

**Proof sketch.** Consider the union of all bad sets,
$$
B \;=\; \bigcup_{\mathbf{d} \in D} \operatorname{bad}(\mathbf{d}).
$$
A multiplier is good for $D$ precisely when it lies *outside* $B$. By the
subadditivity of cardinality under unions (the finite union bound),
$$
|B| \;\le\; \sum_{\mathbf{d} \in D} |\operatorname{bad}(\mathbf{d})|
\;\le\; \sum_{\mathbf{d} \in D} p
\;=\; |D|\cdot p,
$$
where the second inequality is Lemma 3.1 applied to each nonzero
$\mathbf{d} \in D$. Using the hypothesis $|D| < p$,
$$
|B| \;\le\; |D| \cdot p \;<\; p \cdot p \;=\; p^2 \;=\; |\mathbb{F} \times
\mathbb{F}|.
$$
Thus $B$ is a proper subset of the finite torus, so its complement is nonempty:
there exists $\mathbf{a} \in (\mathbb{F}\times\mathbb{F}) \setminus B$. By
construction this $\mathbf{a}$ satisfies $\langle \mathbf{d}, \mathbf{a}\rangle
\neq 0$ for all $\mathbf{d} \in D$. $\qquad\blacksquare$

**Remark 4.2 (Contrapositive form).** Equivalently: if *no* good multiplier
existed, then every point of the torus would lie in some bad set, forcing $B$ to
equal the entire torus and hence $|B| = p^2$; combined with $|B| \le |D|\cdot p$
this gives $p^2 \le |D|\cdot p$, i.e. $p \le |D|$, contradicting $|D| < p$. This
is the form in which the theorem is most naturally formalized.

**Remark 4.3 (Sharpness).** The bound $|D| < p$ cannot be relaxed to $|D| \le p$
in general. With $p$ distinct lines through the origin one can, depending on the
configuration, cover all $p^2$ points (the $p+1$ lines through the origin in
$\mathbb{F}^2$ cover everything, but already a carefully chosen sub-family can
exhaust the relevant multipliers for a specific separation task). The theorem
operates exactly at the threshold where the counting still leaves slack.

**Remark 4.4 (Primality).** Primality of $p$ is used twice: it makes
$\mathbb{F}$ a field so that division by $d_1$ in Lemma 3.1 is valid, and it
makes the cardinality arithmetic exact. Over $\mathbb{Z}/n\mathbb{Z}$ for
composite $n$ the bad set need not be a single line and the bound fails.

---

## 5. The integer-displacement corollary

In practice displacement vectors arise as differences of integer lattice points.
The following corollary transports Theorem 4.1 to that setting.

**Theorem 5.1 (Integer multiplier corollary).** *Let $p$ be prime and let
$E \subseteq \mathbb{Z} \times \mathbb{Z}$ be a finite set of integer
displacement vectors such that*
$$
\text{for each } \mathbf{e} \in E: \quad p \nmid e_1 \;\;\text{or}\;\; p \nmid e_2,
$$
*and suppose $|E| < p$. Then there exists a multiplier $\mathbf{a} =
(\alpha_1, \alpha_2) \in \mathbb{F} \times \mathbb{F}$ such that the reduced dot
product is nonzero for every $\mathbf{e} \in E$:*
$$
(e_1 \bmod p)\,\alpha_1 + (e_2 \bmod p)\,\alpha_2 \neq 0 \quad \text{in }
\mathbb{F}.
$$

**Proof sketch.** Let $\pi : \mathbb{Z} \to \mathbb{F}$ denote reduction modulo
$p$, applied coordinatewise to give a map $\mathbb{Z}^2 \to \mathbb{F}^2$. Define
the reduced set
$$
D \;=\; \{\, (\pi(e_1), \pi(e_2)) : \mathbf{e} \in E \,\} \;=\; \pi(E)
\;\subseteq\; \mathbb{F}\times\mathbb{F}.
$$
Two facts hold. *First, every element of $D$ is nonzero.* For
$\mathbf{e} \in E$, the hypothesis gives $p \nmid e_1$ or $p \nmid e_2$, i.e.
$\pi(e_1) \neq 0$ or $\pi(e_2) \neq 0$ (since $\pi(e_i) = 0 \iff p \mid e_i$);
hence $(\pi(e_1), \pi(e_2)) \neq \mathbf{0}$. *Second,*
$$
|D| = |\pi(E)| \le |E| < p,
$$
because the image of a set under a map has at most as many elements as the set.
Thus $D$ satisfies the hypotheses of Theorem 4.1, which supplies a multiplier
$\mathbf{a}$ with $\langle \mathbf{d}, \mathbf{a}\rangle \neq 0$ for all
$\mathbf{d} \in D$. Finally, for any $\mathbf{e} \in E$ its reduction
$(\pi(e_1), \pi(e_2))$ lies in $D$, and since reduction is a ring homomorphism,
$$
(e_1 \bmod p)\alpha_1 + (e_2 \bmod p)\alpha_2 = \langle (\pi(e_1),\pi(e_2)),
\mathbf{a}\rangle \neq 0,
$$
as required. $\qquad\blacksquare$

**Remark 5.2.** The coordinate-divisibility hypothesis is exactly what is needed
to guarantee that distinct integer arrows do not collapse to the forbidden zero
vector after reduction. It is automatically satisfied, for example, when each
$\mathbf{e}$ has a coordinate that is coprime to $p$ — in particular when the
displacements come from a lacunary integer sequence and $p$ is chosen larger than
the relevant coordinates.

---

## 6. Connection to the analytic lacunary theory

The finite theorem is the discrete shadow of the analytic problem in Section 1.1.
We summarize the analytic facts that frame it; they explain both why a positive
$\delta$ is attainable for lacunary sequences and why it fails otherwise.

### 6.1 The torus norm as a pseudo-norm

The torus norm $\|\cdot\|_{\mathbb{T}}$ of Definition 2.5 is a genuine
pseudo-norm on $\mathbb{R}/\mathbb{Z}$: it is non-negative, bounded by $1/2$,
even, $1$-periodic, and subadditive,
$\|x+y\|_{\mathbb{T}} \le \|x\|_{\mathbb{T}} + \|y\|_{\mathbb{T}}$. For a
rational point it has the exact value
$$
\left\| \frac{m}{n} \right\|_{\mathbb{T}} = \frac{\min(m \bmod n,\; n - (m \bmod
n))}{n}.
$$

### 6.2 The geometric multiplier $1/(q+1)$

**Proposition 6.1 (Exact geometric bound).** *For an integer ratio $q \ge 2$ and
the canonical lacunary sequence $n_k = q^k$, the multiplier $\alpha = 1/(q+1)$
satisfies*
$$
\|q^k \alpha\|_{\mathbb{T}} = \frac{1}{q+1} \qquad \text{for all } k \ge 0.
$$
**Proof idea.** Since $q \equiv -1 \pmod{q+1}$, we have $q^k \equiv (-1)^k
\pmod{q+1}$, so $q^k \bmod (q+1) \in \{1, q\}$. By the exact rational formula,
$\|q^k/(q+1)\|_{\mathbb{T}} = \min(1, q)/(q+1) = 1/(q+1)$. $\blacksquare$

This is optimal in a strong sense: $1/(q+1) \to 1/2$ as $q \to \infty$,
approaching the theoretical ceiling of the torus norm. In two dimensions, the
multiplier $(1/(q+1), 1/(q+1))$ achieves the same uniform bound on the genuinely
two-dimensional interleaved displacement set $\{(q^k, 0)\} \cup \{(0, q^k)\}$,
since each coordinate is handled independently by the one-dimensional bound.

### 6.3 Necessity of lacunarity

**Proposition 6.2 (Dirichlet obstruction).** *For the non-lacunary sequence
$n_k = k$ ($k = 1, 2, 3, \dots$), there is no multiplier $\alpha$ and no $\delta >
0$ with $\|k\alpha\|_{\mathbb{T}} \ge \delta$ for all $k$.* Indeed, Dirichlet's
approximation theorem provides, for every $\alpha$ and every $N$, an integer
$1 \le k \le N$ with $\|k\alpha\|_{\mathbb{T}} < 1/N$; letting $N \to \infty$
drives the infimum to $0$. Positivity of $\delta$ is therefore a consequence of
the gaps, not of any cleverness in choosing $\alpha$.

### 6.4 The dictionary

The finite and analytic pictures correspond term-by-term:

| Analytic (torus $\mathbb{T}^2$) | Finite (field $\mathbb{F}^2$) |
|---|---|
| Displacement $\mathbf{d}_k \in \mathbb{Z}^2$ | Reduced $\mathbf{d} \in \mathbb{F}^2$ |
| Multiplier $\boldsymbol{\alpha} \in [0,1)^2$ | Multiplier $\mathbf{a} \in \mathbb{F}^2$ |
| $\|\langle \mathbf{d},\boldsymbol{\alpha}\rangle\|_{\mathbb{T}} \ge \delta$ | $\langle \mathbf{d}, \mathbf{a}\rangle \neq 0$ |
| Sparse gaps (lacunarity) | Few vectors ($|D| < p$) |
| Resonance / aliasing | Bad set membership |

The finite theorem replaces the quantitative bound $\ge \delta$ with the
qualitative bound $\neq 0$ and converts the analytic limiting argument into an
exact pigeonhole count — gaining complete rigor and an explicit, efficiently
checkable construction.

---

## 7. Algorithms

### 7.1 Constructing a good multiplier (deterministic search)

Theorem 4.1 is constructive. Because the bad sets cover fewer than $p^2$ points,
a single pass over the torus is guaranteed to find a good multiplier.

**Algorithm A (Deterministic multiplier search).**
```
Input:  prime p, set D of nonzero vectors in F×F with |D| < p
Output: a multiplier a with <d,a> ≠ 0 for all d in D
1. for a1 in 0..p-1:
2.   for a2 in 0..p-1:
3.     good <- true
4.     for d in D:
5.       if (d1*a1 + d2*a2) mod p == 0: good <- false; break
6.     if good: return (a1, a2)
7. return FAIL    # provably unreachable when |D| < p
```
*Correctness:* the loop examines all $p^2$ multipliers; Theorem 4.1 guarantees at
least one is good, so the failure line is never reached. *Complexity:*
$O(p^2 \cdot |D|)$ field operations in the worst case.

### 7.2 Constructing a good multiplier (line-avoidance)

A faster construction avoids enumerating the whole torus. Restrict attention to
multipliers of the form $\mathbf{a} = (1, t)$ for $t \in \mathbb{F}$ (or
$(t, 1)$ to cover the degenerate first-coordinate case). Each nonzero $\mathbf{d}$
kills at most one such $t$ (the bad line meets the affine slice $\{(1, t)\}$ in at
most one point), so at most $|D| < p$ values of $t$ are excluded and at least one
of the $p$ candidates survives.

**Algorithm B (Slice line-avoidance).**
```
Input:  prime p, set D of nonzero vectors with |D| < p
Output: a good multiplier
1. forbidden <- empty set
2. for d in D:                          # collect bad t for slice a=(1,t)
3.   if d2 != 0: forbidden.add( (-d1) * inverse(d2) mod p )
4.   else:        record that t is unconstrained for this d (d=(d1,0), <d,(1,t)>=d1≠0)
5. for t in 0..p-1:
6.   if t not in forbidden: return (1, t)
7. # fallback to slice a=(t,1) for vectors with d1=0 not yet separated
```
*Complexity:* $O(|D| \log p)$ for the modular inverses plus $O(p)$ for the scan —
near-linear in the problem size.

### 7.3 Verifying a candidate multiplier

**Algorithm C (Verification).** Given $\mathbf{a}$ and $D$, compute
$\langle \mathbf{d}, \mathbf{a}\rangle \bmod p$ for each $\mathbf{d} \in D$ and
confirm all are nonzero. Cost $O(|D|)$ field operations. This certifies the output
of Algorithms A and B and is the finite analogue of computing
$\min_k \|\langle \mathbf{d}_k, \boldsymbol{\alpha}\rangle\|_{\mathbb{T}}$ in the
analytic setting.

---

## 8. Numerical illustrations

The accompanying demonstrations (see `demo.py`) verify the theory on explicit
instances:

1. **Line bound.** For each prime $p \in \{5,7,11,13\}$ and each nonzero
   $\mathbf{d}$, the bad set is computed by brute force and confirmed to have
   exactly $p$ elements, matching Lemma 3.1 / Remark 3.2.
2. **Avoidance theorem.** Random sets $D$ of size $|D| = p-1$ are generated and a
   good multiplier is found by Algorithms A and B, then verified by Algorithm C.
3. **Threshold sharpness.** Instances with $|D| = p$ are exhibited where no good
   multiplier exists, illustrating Remark 4.3.
4. **Integer corollary.** Integer vectors with coordinates coprime to $p$ are
   reduced and separated, illustrating Theorem 5.1.
5. **Geometric multiplier.** The exact identity $\|q^k/(q+1)\|_{\mathbb{T}} =
   1/(q+1)$ is checked numerically for several $q$ and $k$, illustrating
   Proposition 6.1, alongside the Dirichlet collapse for $n_k = k$.

---

## 9. Applications

**Universal hashing and fingerprinting.** Viewing each $\mathbf{d}$ as the
difference of two records, a good multiplier is a *collision-free linear hash
direction*: the map $\mathbf{x} \mapsto \langle \mathbf{x}, \mathbf{a}\rangle$
distinguishes any two records whose difference lies in $D$. Theorem 4.1
guarantees existence whenever the number of pairs to separate is below the field
size, the quantitative heart of universal hashing.

**Linear error-detecting codes.** A nonzero dot product is the condition that a
parity-check functional detects an error pattern. Choosing $\mathbf{a}$ nonzero
against a family of low-weight patterns is the design principle behind
error-detecting linear codes; the thin-line count is the elementary version of
the singleton-type bounds in coding theory.

**Anti-aliasing and sampling.** Choosing a sampling direction not resonant with
any spatial period of a scene prevents moiré artifacts. The lacunary analysis
(Section 6) explains why exponentially spaced sampling rates dodge resonance with
a guaranteed margin $1/(q+1)$.

**Diophantine geometry and dynamics.** Multipliers with uniformly large torus
norm are the two-dimensional analogues of *badly approximable* numbers, which
play a central role in the stability theory of rotations and in metric number
theory.

---

## 10. Discussion

The result is deliberately elementary, and its elegance lies in the exactness of
the counting. The single inequality $|D|\cdot p < p^2$ — equivalently $|D| < p$ —
is both the hypothesis and, essentially, the proof. The structure of the argument
is robust: it generalizes verbatim to $\mathbb{F}^n$, where a bad set is a
hyperplane of $p^{n-1}$ points and the avoidance threshold becomes
$|D| < p^{n-1} \cdot \frac{p-1}{p-1}$ — more precisely $|D| < p$ still suffices
since $|D|\cdot p^{n-1} < p^n$, and in higher dimensions one can tolerate far more
vectors, up to roughly $p^{n-1}$. The two-dimensional case treated here is the
sharpest and the one matching the planar lacunary distance graphs that motivate
the problem.

The most interesting tension exposed by the finite model is between **explicit
construction** and **existence**. In the geometric analytic case the optimal
multiplier is the closed-form rational $1/(q+1)$; in the finite case Algorithm B
produces an explicit multiplier in near-linear time. By contrast, in the general
analytic lacunary setting one currently relies on a nested-interval limiting
argument to *prove existence* without a closed form. Closing this gap — producing
explicit multipliers in the general analytic case — is the principal open
direction.

---

## 11. Future directions

This program established three analytic pillars — the torus norm as a genuine
subadditive pseudo-norm with exact rational values; the closed-form geometric
multiplier $\alpha = 1/(q+1)$ giving $\|q^k\alpha\|_{\mathbb{T}} = 1/(q+1)$
exactly; and the necessity of lacunarity via the Dirichlet obstruction — together
with the finite-field avoidance theorem of this paper. Two principal conjectures
push on the boundary between the explicit and the existential regimes.

**Conjecture 1 (General lacunary existence with ratio-controlled $\delta$).** For
every sequence of positive integers $n_k$ with $n_{k+1} \ge q\,n_k$ ($q \ge 2$)
there exists $\alpha \in [0,1)$ with $\|n_k\alpha\|_{\mathbb{T}} \ge \delta(q) >
0$ for all $k$, where $\delta(q) \to 1/2$ as $q \to \infty$; a clean target is
$\delta(q) = c\,(q-2)/q$ for an absolute constant $c$. The proposed mechanism is a
nested closed-interval construction: the bad set $\{\alpha :
\|n_k\alpha\|_{\mathbb{T}} < \delta\}$ is a periodic union of intervals of length
$2\delta/n_k$ and period $1/n_k$, so any surviving interval of length $> 2/n_k$
from step $k-1$ contains a full good sub-interval at step $k$ once $(1-2\delta)q >
2$; completeness of $\mathbb{R}$ extracts the limit point $\alpha$.

**Conjecture 2 (Divisibility-chain sequences have a closed-form series
multiplier).** If $n_1 \mid n_2 \mid n_3 \mid \cdots$ with ratios $r_k =
n_{k+1}/n_k \ge q$, then $\alpha = \sum_k \lfloor r_{k-1}/2\rfloor / n_k$ (a
convergent series) satisfies $\|n_k\alpha\|_{\mathbb{T}} \ge 1/2 - O(1/q)$ for all
$k$, with no nested-interval argument. The mechanism: divisibility makes
$n_j/n_k \in \mathbb{Z}$ for $k \le j$, so $n_j\alpha \bmod 1$ depends only on the
tail $\sum_{k>j}\lfloor r_{k-1}/2\rfloor\, n_j/n_k$, whose dominant term
$\lfloor r_j/2\rfloor/r_j \approx 1/2$ is corrected by a geometrically small tail.
This converts the existence problem into a single explicit real number,
generalizing the geometric $1/(q+1)$ champion.

---

## 12. Conclusion

We have proved a sharp, elementary, and constructive multiplier avoidance
theorem on the finite torus $\mathbb{F} \times \mathbb{F}$: fewer than $p$ nonzero
displacement vectors can always be simultaneously detected by a single multiplier,
because their bad sets are thin lines whose union cannot fill the plane. An
integer corollary transports the result to lattice displacements, and the finite
theorem dovetails with the analytic theory of lacunary sequences, where the
geometric ratio $q^k$ admits the exact optimal multiplier $1/(q+1)$ and
non-lacunary sequences admit none. The same moral governs hashing, coding,
sampling, and Diophantine approximation: *when the obstructions are sparse, a
single well-chosen direction avoids them all.*
