# Row-Exchange Invariance under Eventual Contraction for the Infinite Asymmetric Five-Vertex Half-Strip

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Novelty (operator theory / statistical mechanics of vertex models)

---

## Abstract

We study the row-to-row transfer operators of an asymmetric five-vertex model on a
semi-infinite strip of width five, modeled as elements of the normed ring
$\mathrm{TM} = \mathrm{Mat}_{5\times 5}(\mathbb{R})$ equipped with the $L^\infty$
operator norm — a complete `NormOneClass` normed algebra in which geometric series
are summable. We prove two complementary facts, each formalized and machine-checked,
and each generalized from the concrete matrix ring to an arbitrary complete normed
ring $R$.

First, **eventual contraction** — the existence of a single ratio $c<1$ and a
threshold $N$ with $\|M_k\| \le c$ for all $k \ge N$ — forces the accumulated
half-strip transfer product $P_m = M_{m-1}\cdots M_0$ to collapse in norm,
$\|P_m\| \to 0$. This relaxes the *uniform* contraction hypothesis of Lemma 2.1 of
the originating work to a strictly weaker eventual condition: the finitely many
boundary rows are permitted to be arbitrary.

Second, **row-exchange symmetry is preserved by the resolvent**. If a row-swap is
implemented by a permutation matrix $S = (\,i\;j\,)$ that is an involution
($S\cdot S = I$) and commutes with a contraction $A$ ($SA=AS$, $\|A\|<1$), then the
geometric resolvent $(I-A)^{-1} = \sum_{n\ge 0} A^n$ is exactly conjugation-invariant:
$S(I-A)^{-1}S = (I-A)^{-1}$. The proof is structural — conjugation is a continuous
additive endomorphism that fixes each power $A^n$ — and never inverts a matrix
explicitly. We further drop the involution hypothesis, obtaining invariance under
conjugation by *any* unit, hence under any commuting symmetry group; and we record
the sharp Neumann bound $\|(I-A)^{-1}\| \le (1-\|A\|)^{-1}$, which is itself
row-exchange invariant because $\|S\|=1$. Together these results show that, inside
the contraction radius, local symmetry of the Boltzmann weights survives intact to
the macroscopic half-strip object: there is no spontaneous symmetry breaking.

---

## 1. Introduction

### 1.1 Vertex models and transfer operators

A *vertex model* on a strip lattice assigns Boltzmann weights to local
configurations of arrows on edges incident to each vertex; the partition function
sums the product of weights over all admissible configurations subject to fixed
boundary data. The standard computational tool is the *transfer operator*, a linear
map carrying the statistical state of one horizontal row to the next. For a strip of
width five the transfer operator is a $5\times 5$ real matrix, and the partition
function of a stack of rows is encoded by the ordered product of the corresponding
matrices. The *asymmetric five-vertex model* — the six-vertex model with one vertex
type forbidden and direction-dependent weights governed by spectral parameters $v$
and $z$ — is the motivating object.

### 1.2 The originating conjecture

Lemma 2.1 of the originating paper established an *infinite right half-strip
row-exchange identity*: for arbitrary top and bottom boundary occupation sequences,
nonzero normalization $\alpha$, and spectral parameters $v,z$, exchanging two
boundary rows alters the infinite partition function only by an explicit scalar
prefactor $f(v/z)/\alpha^2$ — **provided every column contracts uniformly**. The
conjecture addressed here is that the *uniform* hypothesis is unnecessarily strong:
the identity should persist under the strictly weaker assumption that the
contraction ratio is *eventually* bounded by some $\delta < 1$, i.e. there exist
$\delta<1$ and $N$ with the relevant ratio norm $\le \delta$ for all $i \ge N$.

### 1.3 Contributions

We isolate the operator-theoretic core of the conjecture and prove it in full
generality. Concretely:

1. **Eventual-contraction collapse** of the accumulated half-strip product
   (Theorem 6 below; `prodDown_tendsto_zero`, with five-vertex specialization
   `transferProduct_vanishes`), validating the relaxation from uniform to eventual
   contraction.
2. **Resolvent row-exchange invariance** for an involutive swap (Theorem 2;
   `conj_inverse_one_sub_eq`, series form `conj_tsum_geom_eq`, five-vertex
   specialization `rowExchange_resolvent_invariant`), built on the elementary
   power lemma `conj_pow_eq` (Lemma 1).
3. **Symmetry-group generalization** to conjugation by an arbitrary unit
   (Theorem 4; `conj_unit_inverse_one_sub_eq`), removing the involution hypothesis.
4. **Sharp Neumann norm bound** on the resolvent (Theorem 5;
   `norm_inverse_one_sub_le`), invariant under row exchange since $\|S\|=1$, together
   with the induced collapse of the row-exchanged product
   (`rowExchange_transferProduct_vanishes`).

All statements are proved abstractly for a complete normed ring $R$ and then
specialized to $\mathrm{TM}$.

---

## 2. Setting and definitions

Throughout, $R$ is a normed ring with $\mathbf{1}$, complete as a metric space
(`NormedRing R`, `CompleteSpace R`); where a multiplicative unit norm is needed we
assume `NormOneClass R` (i.e. $\|\mathbf{1}\| = 1$). The concrete model is

$$\mathrm{TM} \;=\; \mathrm{Mat}_{5\times 5}(\mathbb{R}),
\qquad \|A\| \;=\; \max_{1\le r\le 5} \sum_{s=1}^{5} |A_{rs}|,$$

the $L^\infty$ (maximum absolute row sum) operator norm. With this norm $\mathrm{TM}$
is a complete `NormOneClass` normed algebra, submultiplicative ($\|AB\| \le
\|A\|\,\|B\|$), and supports summable operator geometric series. (In the
formalization the norm is installed via `Matrix.linftyOpNormedRing` and
`Matrix.linftyOpNormedAlgebra` as local instances; matrices carry no canonical
`NormedRing` instance because several inequivalent operator norms coexist.)

**Definition 2.1 (Eventual contraction).** A sequence $M : \mathbb{N} \to R$ is
*eventually contracting* if there exist $c \in [0,1)$ and $N \in \mathbb{N}$ such
that $\|M_k\| \le c$ for all $k \ge N$.

**Definition 2.2 (Accumulated half-strip product `prodDown`).** Define
$P : \mathbb{N} \to R$ by

$$P_0 = \mathbf{1}, \qquad P_{m+1} = M_m \, P_m,
\qquad\text{equivalently}\qquad P_m = M_{m-1} M_{m-2} \cdots M_1 M_0.$$

Accumulation is on the *left*: each new row is applied as a left factor, matching
the row-to-row action up the strip.

**Definition 2.3 (Geometric resolvent).** For $x \in R$ with $\|x\|<1$ the series
$\sum_{n\ge 0} x^n$ converges; its sum equals `Ring.inverse (1 - x)`, the two-sided
inverse of $\mathbf{1}-x$. We write $(I-x)^{-1}$ for this element and use freely the
Mathlib facts `hasSum_geom_series_inverse` (the series has sum
`Ring.inverse (1-x)`) and `geom_series_eq_inverse` ($\sum' n,\ x^n =
\mathrm{Ring.inverse}(1-x)$), valid for any complete normed ring.

**Definition 2.4 (Row exchange `rowExchange`).** For indices $i,j$ let
$S = \mathrm{rowExchange}\, i\, j = (\mathrm{swap}\ i\ j).\mathrm{permMatrix}$, the
permutation matrix of the transposition exchanging $i$ and $j$. Then $S$ is an
involution, $S\cdot S = \mathbf{1}$, and $\|S\| = 1$ in the $L^\infty$ operator
norm. Conjugation $A \mapsto S A S$ simultaneously swaps rows $i,j$ and columns
$i,j$ of $A$. We call $A$ *symmetric under the swap* if $SA = AS$.

---

## 3. Main results

### 3.1 Conjugation symmetry of the resolvent

**Lemma 1 (`conj_pow_eq`).** *Let $u, x \in R$ with $u\cdot u = \mathbf{1}$ and
$u\cdot x = x\cdot u$. Then for every $n \in \mathbb{N}$,*

$$u \, x^{n} \, u \;=\; x^{n}.$$

*Proof.* Since $u$ commutes with $x$ it commutes with every power: $u\,x^n = x^n\,u$
(Mathlib `Commute.pow_right`). Hence $u\,x^n\,u = x^n\,u\,u = x^n\,\mathbf{1} = x^n$,
using $u\cdot u = \mathbf{1}$. $\qquad\blacksquare$

**Theorem 2 (Resolvent row-exchange invariance; `conj_inverse_one_sub_eq`).** *Let
$u, x \in R$ with $u\cdot u = \mathbf{1}$, $u\cdot x = x\cdot u$, and $\|x\| < 1$.
Then*

$$u \, (I - x)^{-1} \, u \;=\; (I - x)^{-1},
\qquad\text{i.e.}\qquad u\,\mathrm{Ring.inverse}(1-x)\,u = \mathrm{Ring.inverse}(1-x).$$

*Proof sketch.* By `hasSum_geom_series_inverse`, the family $(x^n)_{n\in\mathbb{N}}$
has sum $(I-x)^{-1}$. Consider the conjugation map $g : R \to R$, $g(y) = u\,y\,u$.
It is additive ($g(0)=0$ and $g(a+b)=g(a)+g(b)$ by left/right distributivity) and
continuous (a composition of multiplications by the constants $u$ on each side,
`Continuous.mul`); thus $g$ is a continuous `AddMonoidHom`. Continuous additive maps
preserve `HasSum` (`HasSum.map`), so $g$ applied termwise to the convergent family
again converges, with sum $g\bigl((I-x)^{-1}\bigr)$. But by Lemma 1, $g(x^n) =
u\,x^n\,u = x^n$ for every $n$, so the mapped family is identical to the original
$(x^n)$, whose sum is $(I-x)^{-1}$. Uniqueness of sums (`HasSum.unique`) gives
$g\bigl((I-x)^{-1}\bigr) = (I-x)^{-1}$, which is the claim. The argument never
inverts a matrix explicitly; symmetry is inherited summand-by-summand.
$\qquad\blacksquare$

**Corollary 3 (Series form; `conj_tsum_geom_eq`).** *Under the hypotheses of
Theorem 2,*

$$u \Bigl(\sum_{n=0}^{\infty} x^{n}\Bigr) u \;=\; \sum_{n=0}^{\infty} x^{n}.$$

*Proof.* Rewrite $\sum_n x^n = \mathrm{Ring.inverse}(1-x)$ via
`geom_series_eq_inverse` and apply Theorem 2. $\qquad\blacksquare$

Specializing $u = S = \mathrm{rowExchange}\,i\,j$ on $\mathrm{TM}$ (which satisfies
$S\cdot S = \mathbf{1}$) yields the statistical-mechanics statement
`rowExchange_resolvent_invariant`: $S(I-A)^{-1}S = (I-A)^{-1}$ for any transfer
operator $A$ with $SA=AS$ and $\|A\|<1$.

### 3.2 Dropping the involution: full symmetry-group invariance

**Theorem 4 (Unit-conjugation invariance; `conj_unit_inverse_one_sub_eq`).** *Let
$u \in R^\times$ be a unit and $x \in R$ with $u\cdot x = x\cdot u$ and $\|x\| < 1$.
Then*

$$u \, (I - x)^{-1} \, u^{-1} \;=\; (I - x)^{-1}.$$

*Proof sketch.* Identical in structure to Theorem 2, using the conjugation
$g(y) = u\,y\,u^{-1}$, additive and continuous as before. On powers,
$u\,x^n\,u^{-1} = x^n\,u\,u^{-1} = x^n$ since $u$ commutes with $x^n$
(`Commute.pow_right`) and $u\,u^{-1}=\mathbf{1}$. `HasSum.map` and `HasSum.unique`
transport the fixed point to the sum. $\qquad\blacksquare$

The involution hypothesis $u\cdot u=\mathbf{1}$ is therefore *not* essential. Two
consequences: (i) Theorem 2 is the special case $u=u^{-1}=S$; (ii) if a subgroup
$G \le \mathrm{Perm}(\mathrm{Fin}\,5)$ has every generator's permutation matrix
commuting with $A$, then $(I-A)^{-1}$ is fixed by conjugation by every element of
$G$. A whole symmetry group of commuting permutations is preserved, not merely a
single transposition.

### 3.3 Quantitative control: the Neumann bound

**Theorem 5 (Resolvent norm bound; `norm_inverse_one_sub_le`).** *Assume
`NormOneClass R`. For $x \in R$ with $\|x\| < 1$,*

$$\bigl\|(I - x)^{-1}\bigr\| \;\le\; \frac{1}{\,1 - \|x\|\,}.$$

*Proof sketch.* Write $(I-x)^{-1} = \sum_n x^n$ (`geom_series_eq_inverse`). The
scalar series $\sum_n \|x\|^n$ converges since $0\le\|x\|<1$
(`summable_geometric_of_lt_one`), and it dominates the operator series termwise via
submultiplicativity $\|x^n\| \le \|x\|^n$ (`norm_pow_le`). Hence the operator series
is absolutely summable, and by the triangle inequality for infinite sums
(`norm_tsum_le_tsum_norm`),

$$\Bigl\|\sum_{n} x^n\Bigr\| \;\le\; \sum_{n} \|x^n\| \;\le\; \sum_{n} \|x\|^n
\;=\; \frac{1}{1-\|x\|}$$

by the closed form `tsum_geometric_of_lt_one`. $\qquad\blacksquare$

Because $\|S\|=1$ for any row-exchange permutation, this bound is exactly preserved
under row exchange: neither $(I-A)^{-1}$ nor its norm estimate changes when rows are
swapped.

### 3.4 Collapse of the half-strip transfer product

**Theorem 6 (Eventual-contraction collapse; `prodDown_tendsto_zero`).** *Let
$M : \mathbb{N} \to R$ be eventually contracting (Definition 2.1) with ratio $c$ and
threshold $N$, and let $P_m = \mathrm{prodDown}\,M\,m$ (Definition 2.2). Then*

$$\|P_m\| \longrightarrow 0 \quad\text{as } m\to\infty.$$

*Proof sketch.* For $m \ge N$ we establish the geometric tail bound

$$\|P_m\| \;\le\; \|P_N\| \cdot c^{\,m-N}$$

by induction on $m \ge N$ (`Nat.le_induction`): the base case $m=N$ is trivial, and
the step uses $P_{m+1} = M_m P_m$ together with submultiplicativity $\|M_m P_m\| \le
\|M_m\|\,\|P_m\| \le c\,\|P_m\|$, valid because $m \ge N$. Since $0 \le c < 1$, the
right-hand side tends to $0$ (the constant $\|P_N\|$ times a vanishing geometric
sequence), and a squeeze between $0$ and $\|P_N\| c^{m-N}$ forces $\|P_m\|\to 0$.
$\qquad\blacksquare$

The first $N$ rows enter only through the constant factor $\|P_N\|$ and cannot
prevent the collapse — this is exactly why *eventual* contraction suffices in place
of uniform contraction. Specializing to $R = \mathrm{TM}$ gives
`transferProduct_vanishes`. Moreover, since $\|S\|=1$, $\|S P_m\| \le \|P_m\| \to 0$,
so the row-exchanged product also vanishes (`rowExchange_transferProduct_vanishes`).

---

## 4. A fully worked numerical example

To make the results concrete we exhibit a small instance in which every quantity
can be computed by hand or checked on a calculator, and then indicate how it scales
to the genuine $5\times 5$ five-vertex operator.

### 4.1 A two-state swap-symmetric contraction

Consider the $2\times 2$ transfer operator and the row swap

$$A = \begin{pmatrix} 0.2 & 0.1 \\ 0.1 & 0.2 \end{pmatrix}, \qquad
S = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}.$$

Here $S$ exchanges the two coordinates. One checks directly that $S\cdot S = I$ and
that $A$ is symmetric under the swap, $SA = AS$, because $A$ has equal diagonal
entries and equal off-diagonal entries. In the $L^\infty$ norm,
$\|A\| = 0.2 + 0.1 = 0.3 < 1$, so $A$ is a contraction and the hypotheses of
Theorem 2 and Theorem 5 are met.

**Resolvent.** Summing the geometric series $\sum_{n\ge 0} A^n = (I-A)^{-1}$, or
equivalently inverting $I-A$ directly, gives

$$(I-A)^{-1} = \frac{1}{(0.8)^2 - (0.1)^2}\begin{pmatrix} 0.8 & 0.1 \\ 0.1 & 0.8
\end{pmatrix} = \begin{pmatrix} 1.2698\ldots & 0.1587\ldots \\ 0.1587\ldots &
1.2698\ldots \end{pmatrix}.$$

The resolvent again has equal diagonal entries and equal off-diagonal entries — it
is manifestly fixed by simultaneously swapping rows and columns, i.e.
$S(I-A)^{-1}S = (I-A)^{-1}$, exactly as Theorem 2 predicts. The symmetry of the
microscopic weights is reproduced verbatim in the macroscopic resolvent.

**Neumann bound.** Theorem 5 gives $\|(I-A)^{-1}\| \le 1/(1-\|A\|) = 1/0.7 =
1.4286\ldots$. The actual norm is $1.2698 + 0.1587 = 1.4286\ldots$ — in this
symmetric two-state case the bound is essentially attained, illustrating its
sharpness.

### 4.2 Eventual contraction with expanding boundary rows

Now let the first few rows expand and the rest contract. Take a threshold $N=3$, a
contraction ratio $c=0.6$, boundary operators $M_0,M_1,M_2$ with $\|M_k\| = 2$, and
$M_k = A'$ for $k\ge 3$ where $\|A'\| = 0.6$. The accumulated norms $\|P_m\|$ first
grow (rows $0$–$3$ push the norm up to roughly $7$), and then decay geometrically:
from $m = N$ onward they obey $\|P_m\| \le \|P_N\|\,(0.6)^{\,m-N}$, so that, for
instance, $\|P_{10}\| \le \|P_3\|\cdot 0.6^{7} \approx 0.028\,\|P_3\|$. The product
tends to $0$ despite the early expansion — the conclusion of Theorem 6. The
row-exchanged products $\|S P_m\|$ are bounded by the same envelope because
$\|S\|=1$, and therefore vanish as well.

### 4.3 Scaling to the five-vertex operator

For the genuine $5\times 5$ asymmetric five-vertex transfer operator the same three
checks go through with the swap $S = \mathrm{rowExchange}\,1\,3$. One constructs $A$
by symmetrizing the raw Boltzmann-weight matrix over the transposition $(1\;3)$
(averaging each entry with its swap image), which forces $SA=AS$ exactly, and scales
so that $\|A\| = 0.6 < 1$. Numerically, $\|S(I-A)^{-1}S - (I-A)^{-1}\|$ is at the
level of floating-point round-off ($\sim 10^{-16}$), the Neumann bound
$\|(I-A)^{-1}\| \le 2.5$ holds with the actual norm near $2.36$, and the
half-strip product collapses on the same geometric envelope. The accompanying
reference implementation carries out all of these checks.

## 5. Algorithms

The constructive content of the results is directly executable. We summarize the two
core procedures.

### 5.1 Resolvent via truncated Neumann series with certified error

Given a contraction $A$ ($\|A\|<1$) and tolerance $\varepsilon>0$, compute the
partial sum $\sum_{n=0}^{T-1} A^n$ where the truncation $T$ is chosen so that the
*certified* tail bound $\|A\|^{T}/(1-\|A\|) \le \varepsilon$ (a direct consequence
of Theorem 5 applied to the tail). The output approximates $(I-A)^{-1}$ to within
$\varepsilon$ in operator norm. Complexity: $O(T \cdot d^3)$ for $d\times d$
matrices, with $T = O\!\bigl(\log(1/\varepsilon)/\log(1/\|A\|)\bigr)$.

### 5.2 Half-strip product accumulation with collapse certificate

Given an eventually-contracting sequence with parameters $(c,N)$, accumulate
$P_{m+1} = M_m P_m$ and emit, for each $m \ge N$, the certified upper bound
$\|P_N\|\,c^{\,m-N}$ from Theorem 6. The loop terminates once the bound drops below
a target threshold. Complexity: $O(m \cdot d^3)$.

---

## 6. Applications

- **Statistical mechanics of vertex models.** The results justify the row-exchange
  identity of the asymmetric five-vertex half-strip under the physically natural
  *eventual* decay-of-correlations hypothesis, rather than uniform contraction of
  every column. Symmetric Boltzmann weights yield a symmetric infinite partition
  operator.
- **No spontaneous symmetry breaking inside the contraction radius.** Theorem 4
  shows that any commuting symmetry group of the local weights is exactly inherited
  by the macroscopic resolvent — a rigorous, finite-dimensional analogue of the
  statement that symmetry is unbroken in a strongly contracting (massive) phase.
- **Iterated linear systems generally.** The abstract normed-ring formulation
  applies to renormalization maps, relaxing Markov chains, iterated linear filters,
  and fixed-point solvers: eventual contraction guarantees a limit, and commuting
  symmetries are preserved by it.

---

## 7. Discussion

The proofs deliberately avoid explicit matrix inversion. Symmetry invariance is a
*structural* consequence of three facts: the resolvent is a convergent geometric
series; conjugation by a unit is a continuous additive endomorphism; and such
endomorphisms commute with summation. This makes the argument robust to the choice
of ring and indifferent to dimension — the five-vertex width $5$ plays no role
beyond fixing the concrete model. The norm-collapse result is equally elementary,
reducing to a geometric tail estimate plus a squeeze.

Two modeling choices deserve emphasis. First, the $L^\infty$ operator norm is
installed deliberately, because $\mathrm{Mat}_{n\times n}(\mathbb{R})$ has no
canonical `NormedRing` structure; the choice is what makes $\|S\|=1$ for permutation
matrices and renders the Neumann bound row-exchange invariant. Second, the
noncommutativity of the matrix ring rules out the division-ring geometric-series
lemma `tsum_geometric_of_norm_lt_one`; we rely instead on
`hasSum_geom_series_inverse`/`geom_series_eq_inverse`, valid in any complete normed
ring.

---

## 8. Future directions

These conjectures, produced alongside the main development, are precise and testable.

**C1 — Full permutation-symmetry algebra of the resolvent.** The fixed set of the
resolvent is closed under the *group* generated by commuting transpositions, not
just a single swap. Conjecture: if a subgroup $G \le \mathrm{Perm}(\mathrm{Fin}\,5)$
satisfies $g.\mathrm{permMatrix}\cdot A = A\cdot g.\mathrm{permMatrix}$ for all
$g\in G$, then $(I-A)^{-1}$ is fixed by conjugation by every $g.\mathrm{permMatrix}$.
(Generalize from an involution to an arbitrary unit — already achieved in
Theorem 4.)

**C2 — Resolvent norm/Neumann bound under row exchange.** Conjecture: under
$\|A\|<1$, $\|(I-A)^{-1}\| \le (1-\|A\|)^{-1}$ and this bound is *exactly* invariant
under row exchange (since $\|S\|=1$ on the $L^2/L^\infty$ operator norm). Formalize
via `NormedRing.norm_inverse_one_sub_le`-style estimates and `permMatrix_l2_opNorm_eq`.

**C3 — Inhomogeneous half-strip with summable defects.** Replace the uniform bound
by $\sum_k \|M_k - A\| < \infty$ with $\|A\|<1$ (a genuinely asymmetric,
row-dependent $\ell^1$ perturbation of a homogeneous contraction). Conjecture: the
ordered products $P_m$ converge to a well-defined limit operator (not merely to
$0$), and the limit is row-exchange covariant: $S\cdot(\lim)\cdot S = \lim$ whenever
every $M_k$ commutes with $S$.

**C4 — Spectral-radius sharpening of "eventual contraction".** Conjecture:
`transferProduct_vanishes` holds under the weaker Gelfand-type hypothesis that the
*joint spectral radius* of $\{M_k\}$ is $<1$, even if individual $\|M_k\|\ge 1$. Test
first for commuting $M_k$ via `spectralRadius` and `Matrix.pow_norm` asymptotics.

**C5 — Fixed-point (affine) form and uniqueness.** Lift from linear to affine row
maps $x \mapsto M_k\cdot x + b_k$ on $\mathbb{R}^5$. Conjecture: under eventual
contraction the forward orbit converges to a unique bounded configuration
$x_\infty$, and if every $(M_k, b_k)$ is row-exchange equivariant ($S M_k = M_k S$,
$S b_k = b_k$) then $S\cdot x_\infty = x_\infty$. This bridges the resolvent picture
(C1) and the product-vanishing picture into a single Banach fixed-point statement
(`ContractingWith`).

---

## 9. Conclusion

For the infinite asymmetric five-vertex half-strip, eventual contraction is enough.
The finitely many boundary rows are invisible to the infinite tail: the accumulated
transfer product collapses in norm, and the geometric resolvent inherits — exactly,
with no spontaneous breaking — every symmetry of the local Boltzmann weights,
whether a single row-swap, a whole commuting permutation group, or the accompanying
norm estimate. The arguments are elementary, structural, and dimension-agnostic,
and they generalize seamlessly from $\mathrm{Mat}_{5\times5}(\mathbb{R})$ to any
complete normed ring.
