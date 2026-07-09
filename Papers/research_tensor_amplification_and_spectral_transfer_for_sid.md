# Tensor Amplification and Spectral Transfer for Sidorenko-Type Inequalities

**Author:** Aristotle
**Date:** 2026-07-09

## Abstract

We develop a *tensor-amplification framework* for Sidorenko-type inequalities in
the setting of weighted graphs — finite graphons represented by symmetric real
matrices with the uniform (counting) measure. The framework rests on a single
algebraic identity, **spectral transfer**, which states that closed-walk counts
are multiplicative under the tensor (Kronecker) product:
$\mathrm{tr}\big((A\otimes B)^k\big) = \mathrm{tr}(A^k)\,\mathrm{tr}(B^k)$.
From this identity we derive that all homomorphism densities, and hence the
Sidorenko ratio $R(A) = t(C_k,A)/t(K_2,A)^k$, are multiplicative under tensoring.
Two transfer principles follow immediately: (I) the class of weighted graphs
satisfying the Sidorenko property for a cycle $C_k$ is closed under tensor
products; and (II) self-tensoring squares the Sidorenko ratio, so that under
iterated self-tensoring the ratio behaves as a discrete dynamical system with
exactly two fixed points, $0$ and $1$, repelling strict surpluses to $+\infty$
and attracting strict deficits to $0$. To make the framework non-vacuous we
supply two analytic seeds — the even cycles $C_2$ and $C_4$ — proving
$t(C_2,A)\ge t(K_2,A)^2$ and $t(C_4,A)\ge t(K_2,A)^4$ for *every symmetric
weighted graph*, with **no positivity hypothesis** on the entries. Both proofs
are pure spectral Cauchy–Schwarz arguments organizing closed-walk counts as sums
of squares. Combined with Transfer Principle I for even cycles, the seeds
generate an entire tensor-closed class of weighted graphs satisfying the
even-cycle Sidorenko inequality, again with no sign restriction.

## 1. Introduction

Sidorenko's conjecture is one of the central open problems in extremal graph
theory. In its density formulation it asserts that for every bipartite graph $H$
and every graphon $W$,
$$t(H, W) \;\ge\; t(K_2, W)^{e(H)},$$
where $t(H,W)$ is the homomorphism density of $H$ in $W$ and $e(H)$ is the number
of edges of $H$. Equivalently, among all graphons of a given edge density the
constant (quasirandom) graphon minimizes the number of copies of any bipartite
pattern. The conjecture is known in many special cases and open in general.

This paper isolates a structural mechanism behind inequalities of this type. We
work in the discrete, uniform-measure model: a *weighted graph* on a finite
vertex set $\iota$ is a symmetric matrix $A \in \mathbb{R}^{\iota\times\iota}$.
For cycles $C_k$ the relevant densities admit clean spectral descriptions, and
the tensor product of matrices provides a product operation under which those
densities are multiplicative. The multiplicativity converts qualitative
statements about the Sidorenko inequality into statements about a
one-dimensional multiplicative dynamical system.

Our contributions are:

1. **Spectral transfer** (Section 3): closed-walk counts, edge counts, and all
   normalized densities are multiplicative under the tensor product.
2. **Transfer Principle I** (Section 4): structural closure of the Sidorenko
   class under tensor products, with an especially clean even-cycle form
   requiring no positivity.
3. **Transfer Principle II** (Section 4): strict amplification of surpluses and
   deficits under self-tensoring, and the fixed-point structure $\{0,1\}$.
4. **Analytic seeds** (Section 5): sign-free Cauchy–Schwarz proofs of Sidorenko
   for $C_2$ and $C_4$, valid for all symmetric real weightings.
5. **A tensor-closed class** (Section 6): the even-cycle inequality propagated
   over an entire tensor-closed family.

## 2. Definitions

Throughout, $\iota$ and $\kappa$ denote finite vertex sets, and $N = |\iota|$.

**Weighted graph.** A weighted graph on $\iota$ is a matrix $A \in
\mathbb{R}^{\iota\times\iota}$. It is *symmetric* if $A_{ij} = A_{ji}$ for all
$i,j$. We impose no sign condition unless stated.

**Edge count and density.** The homomorphism count of a single edge $K_2$ is the
total weight
$$\mathrm{hom}(K_2, A) = \sum_{i}\sum_{j} A_{ij},$$
and its density is $t(K_2, A) = \mathrm{hom}(K_2,A)/N^2$.

**Cycle count and density.** The homomorphism count of the $k$-cycle $C_k$ is the
number of closed walks of length $k$, which equals the trace of the $k$-th matrix
power:
$$\mathrm{hom}(C_k, A) = \mathrm{tr}(A^k),$$
with density $t(C_k, A) = \mathrm{tr}(A^k)/N^k$.

**Sidorenko property.** The weighted graph $A$ satisfies the *Sidorenko property
for $C_k$* if
$$t(K_2, A)^k \;\le\; t(C_k, A).$$

**Sidorenko ratio.** The *Sidorenko ratio* of $A$ for $C_k$ is
$$R_k(A) = \frac{t(C_k, A)}{t(K_2, A)^k}.$$
The Sidorenko property is $R_k(A) \ge 1$ (whenever $t(K_2,A) \ne 0$).

**Tensor (Kronecker) product.** For $A \in \mathbb{R}^{\iota\times\iota}$ and
$B \in \mathbb{R}^{\kappa\times\kappa}$, the tensor product
$A \otimes B \in \mathbb{R}^{(\iota\times\kappa)\times(\iota\times\kappa)}$ has
entries
$$(A\otimes B)_{(i,i'),(j,j')} = A_{ij}\,B_{i'j'}.$$
It has $N_A N_B$ vertices and is symmetric whenever $A$ and $B$ are.

## 3. Spectral Transfer

The algebraic heart of the framework is the multiplicativity of closed-walk
counts.

**Lemma 3.1 (Tensor power splits).** For all $k$,
$(A\otimes B)^k = A^k \otimes B^k$.

*Proof.* Induction on $k$. The base case $k=0$ is the identity
$I_{\iota\times\kappa} = I_\iota \otimes I_\kappa$. For the inductive step, use
the mixed-product law $(A\otimes B)(C\otimes D) = (AC)\otimes(BD)$ with the
inductive hypothesis:
$(A\otimes B)^{k+1} = (A\otimes B)^k(A\otimes B) = (A^k\otimes B^k)(A\otimes B) =
A^{k+1}\otimes B^{k+1}$. $\square$

**Theorem 3.2 (Spectral transfer).** For all $k$,
$$\mathrm{tr}\big((A\otimes B)^k\big) = \mathrm{tr}(A^k)\cdot\mathrm{tr}(B^k).$$

*Proof.* By Lemma 3.1 the left side equals $\mathrm{tr}(A^k \otimes B^k)$, and
the trace of a Kronecker product factors as $\mathrm{tr}(X\otimes Y) =
\mathrm{tr}(X)\,\mathrm{tr}(Y)$. $\square$

**Lemma 3.3 (Edge count is multiplicative).**
$\mathrm{hom}(K_2, A\otimes B) = \mathrm{hom}(K_2, A)\cdot\mathrm{hom}(K_2, B)$.

*Proof.* The double sum over $\iota\times\kappa$ factors:
$\sum_{(i,i'),(j,j')} A_{ij}B_{i'j'} = \big(\sum_{i,j}A_{ij}\big)\big(\sum_{i',j'}B_{i'j'}\big)$.
$\square$

**Corollary 3.4 (Densities factor).** Using $|\iota\times\kappa| = N_A N_B$,
$$t(C_k, A\otimes B) = t(C_k,A)\,t(C_k,B), \qquad
t(K_2, A\otimes B) = t(K_2,A)\,t(K_2,B).$$

*Proof.* Each density is a count divided by the appropriate power of the vertex
count; both the counts (Theorem 3.2, Lemma 3.3) and the normalizations
($(N_AN_B)^k = N_A^k N_B^k$) are multiplicative, so the quotients multiply. No
positivity is needed. $\square$

**Theorem 3.5 (Ratio is multiplicative).**
$$R_k(A\otimes B) = R_k(A)\cdot R_k(B).$$

*Proof.* Immediate from Corollary 3.4:
$R_k(A\otimes B) = \dfrac{t(C_k,A)t(C_k,B)}{\big(t(K_2,A)t(K_2,B)\big)^k}
= R_k(A)R_k(B)$. $\square$

## 4. The Two Transfer Principles

### 4.1 Transfer Principle I: structural closure

**Theorem 4.1 (Closure).** Suppose $A$ and $B$ satisfy the Sidorenko property for
$C_k$, and suppose $t(K_2,A) \ge 0$ and $t(K_2,B) \ge 0$. Then $A\otimes B$
satisfies the Sidorenko property for $C_k$.

*Proof.* By Corollary 3.4,
$t(K_2, A\otimes B)^k = t(K_2,A)^k\,t(K_2,B)^k$ and
$t(C_k, A\otimes B) = t(C_k,A)\,t(C_k,B)$. Multiplying the two hypotheses
$t(K_2,A)^k \le t(C_k,A)$ and $t(K_2,B)^k \le t(C_k,B)$, both sides of which are
nonnegative under the stated sign conditions, yields
$t(K_2,A\otimes B)^k \le t(C_k, A\otimes B)$. $\square$

**Theorem 4.2 (Closure for even cycles, sign-free).** If $k$ is even and $A, B$
satisfy the Sidorenko property for $C_k$, then so does $A\otimes B$ — with no
positivity hypothesis.

*Proof.* For even $k$, $t(K_2, \cdot)^k$ is an even power and hence automatically
nonnegative, so the positivity hypotheses of Theorem 4.1 are free. $\square$

### 4.2 Transfer Principle II: amplification

**Theorem 4.3 (Ratio squares under self-tensoring).**
$R_k(A\otimes A) = R_k(A)^2$.

*Proof.* Set $B = A$ in Theorem 3.5. $\square$

**Corollary 4.4 (Amplification of surplus).** If $R_k(A) > 1$ then
$R_k(A) < R_k(A\otimes A)$.

*Proof.* $R_k(A\otimes A) = R_k(A)^2 > R_k(A)$ since $x^2 > x$ for $x > 1$.
$\square$

**Corollary 4.5 (Amplification of deficit).** If $0 < R_k(A) < 1$ then
$R_k(A\otimes A) < R_k(A)$.

*Proof.* $R_k(A\otimes A) = R_k(A)^2 < R_k(A)$ since $x^2 < x$ for
$0 < x < 1$. $\square$

**Corollary 4.6 (Fixed points).** $R_k(A) = 1 \implies R_k(A\otimes A) = 1$.

**Discussion.** Iterated self-tensoring produces the orbit
$R, R^2, R^4, R^8, \dots$. The squaring map on $[0,\infty)$ has exactly the two
fixed points $0$ and $1$; it repels away from $1$ toward $\infty$ for arguments
greater than $1$, and attracts toward $0$ for arguments in $(0,1)$. Hence the
Sidorenko inequality has no *stable almost-tight regime*: the existence of any
surplus or deficit, however small, already witnesses arbitrarily extreme
behaviour under tensoring, and $R = 1$ is the unique nontrivial equilibrium (the
sharp/extremal, quasirandom case).

## 5. Analytic Seeds: the Even Cycles $C_2$ and $C_4$

The transfer principles only propagate; they need a source. We supply two, both
sign-free.

**Lemma 5.1 (Trace of the square).** For symmetric $A$,
$\mathrm{tr}(A^2) = \sum_{i}\sum_{j} A_{ij}^2$.

*Proof.* $\mathrm{tr}(A^2) = \sum_i (A^2)_{ii} = \sum_i \sum_j A_{ij}A_{ji}$, and
symmetry gives $A_{ji} = A_{ij}$, so each term is $A_{ij}^2$. $\square$

**Lemma 5.2 (Cauchy–Schwarz over ordered pairs).** For any $A$,
$$\Big(\sum_{i}\sum_{j} A_{ij}\Big)^2 \le N^2 \sum_{i}\sum_{j} A_{ij}^2.$$

*Proof.* Cauchy–Schwarz for the $N^2$-term family $\{A_{ij}\}$ against the
all-ones family: $\big(\sum_p f_p\big)^2 \le |P| \sum_p f_p^2$ with $P =
\iota\times\iota$ and $|P| = N^2$. $\square$

**Theorem 5.3 (Sidorenko for $C_2$).** Every symmetric weighted graph satisfies
$$t(C_2, A) \ge t(K_2, A)^2.$$

*Proof.* Write $S = \sum_{i,j}A_{ij}$. By Lemma 5.1,
$t(C_2,A) = \mathrm{tr}(A^2)/N^2 = \big(\sum_{i,j}A_{ij}^2\big)/N^2$, while
$t(K_2,A)^2 = S^2/N^4$. The claim $S^2/N^4 \le \big(\sum A_{ij}^2\big)/N^2$ is,
after clearing denominators, exactly Lemma 5.2. (The degenerate empty vertex set
$N = 0$ makes both sides $0$.) $\square$

**Lemma 5.4 ($A^2$ is symmetric).** If $A$ is symmetric, so is $A^2$.

*Proof.* $(A^2)_{ij} = \sum_k A_{ik}A_{kj} = \sum_k A_{ki}A_{jk} = (A^2)_{ji}$ by
symmetry and commutativity. $\square$

**Lemma 5.5 (Total weight of $A^2$).** For symmetric $A$,
$$\sum_{i}\sum_{j} (A^2)_{ij} = \sum_{k}\Big(\sum_{i} A_{ik}\Big)^2.$$

*Proof.* Expanding and reordering,
$\sum_{i,j}(A^2)_{ij} = \sum_{i,j,k} A_{ik}A_{kj}
= \sum_k \big(\sum_i A_{ik}\big)\big(\sum_j A_{kj}\big)$, and symmetry turns the
second factor into $\sum_j A_{jk} = \sum_i A_{ik}$, giving the squared column
sum. $\square$

**Theorem 5.6 (Sidorenko for $C_4$).** Every symmetric weighted graph satisfies
$$t(C_4, A) \ge t(K_2, A)^4.$$

*Proof.* Set $S = \sum_{i,j}A_{ij}$, $T = \sum_{i,j}(A^2)_{ij}$, and
$\mathrm{Tr} = \mathrm{tr}(A^4)$. Since $A^4 = (A^2)^2$ and $A^2$ is symmetric
(Lemma 5.4), Lemma 5.1 gives
$\mathrm{Tr} = \sum_{i,j}\big((A^2)_{ij}\big)^2$. Two Cauchy–Schwarz steps follow.

*Step 1 (Lemma 5.2 applied to $A^2$):* $T^2 \le N^2\,\mathrm{Tr}$.

*Step 2 (Cauchy–Schwarz on the $N$ column sums, using Lemma 5.5):*
$T = \sum_k\big(\sum_i A_{ik}\big)^2$ and $S = \sum_k \sum_i A_{ik}$, so
$S^2 \le N\,T$, and in particular $T \ge 0$.

Combining: $N^6 T^2 \le N^6(N^2\,\mathrm{Tr}) = N^8\,\mathrm{Tr}$, and
$N^4 S^4 = N^4(S^2)^2 \le N^4(NT)^2 = N^6 T^2$. Chaining the two gives
$N^4 S^4 \le N^8\,\mathrm{Tr}$, i.e. $S^4/N^8 \le \mathrm{Tr}/N^4$, which is
exactly $t(K_2,A)^4 \le t(C_4,A)$. (Again $N=0$ is the trivial degenerate case.)
$\square$

**Remark 5.7 (Sign-freeness and sharpness).** Neither proof inspects the sign of
any entry: the intermediate quantities $\sum A_{ij}^2$, $\sum(A^2)_{ij} =
\sum_k(\text{column sum}_k)^2$, and $\mathrm{tr}(A^4) = \sum((A^2)_{ij})^2$ are
sums of squares and hence automatically nonnegative. The usual nonnegativity
hypothesis on graphons is therefore unnecessary for even cycles. Both
inequalities are sharp: constant weightings give equality, so neither is vacuous.
Odd cycles are genuinely excluded — $C_3$ does not satisfy Sidorenko in general —
matching the classical restriction of the conjecture to bipartite host patterns.

## 6. A Tensor-Closed Class

**Theorem 6.1 (Closure of the $C_4$-Sidorenko class).** If $A$ and $B$ are
symmetric weighted graphs, then $A\otimes B$ satisfies the four-cycle Sidorenko
inequality $t(C_4, A\otimes B) \ge t(K_2, A\otimes B)^4$.

*Proof.* By Theorem 5.6 both $A$ and $B$ satisfy $C_4$-Sidorenko, and $A\otimes B$
is symmetric (its entries are $A_{ij}B_{i'j'} = A_{ji}B_{j'i'}$). Since $4$ is
even, Theorem 4.2 applies with no positivity hypothesis. $\square$

Starting from the seeds of Section 5 and applying Theorem 6.1 (and its iterates),
one obtains an entire tensor-closed family of symmetric weighted graphs all
satisfying the even-cycle Sidorenko inequality — with no sign restriction
anywhere in the construction.

## 7. Algorithms

The framework is entirely constructive. Three computational primitives suffice to
exercise every result.

- **Density evaluation.** Given a symmetric matrix $A$, compute $t(K_2,A)$ from
  the total weight and $t(C_k,A)$ from $\mathrm{tr}(A^k)$ (via repeated squaring
  of $A$). Complexity $O(N^3 \log k)$ using fast matrix powering, or $O(N^3 k)$
  naively.
- **Ratio orbit under self-tensoring.** Compute $R_k(A)$ once, then produce the
  orbit $R, R^2, R^4, \dots$ by squaring the scalar — never materializing the
  exponentially large tensor powers. This exploits Theorem 4.3.
- **Tensor closure check.** Given several Sidorenko-satisfying seeds, verify that
  arbitrary tensor products stay in the class by multiplying ratios
  (Theorem 3.5), again at scalar cost.

## 8. Applications

Homomorphism-density inequalities of Sidorenko type govern quasirandomness
(pseudorandom structures behave like random ones precisely when such
inequalities are tight), extremal graph theory (bounds on the number of copies of
a pattern in terms of density alone), and the analysis of large networks through
graph limits. The tensor-amplification viewpoint recasts a family of analytic
inequalities as a single multiplicative dynamical system on the ratio $R$, whose
fixed-point structure $\{0,1\}$ explains the absence of any stable near-tight
regime and pinpoints the quasirandom case $R = 1$ as the unique nontrivial
equilibrium.

## 9. Discussion and Future Work

The results separate the framework cleanly into an *algebraic engine* (spectral
transfer and its two transfer principles) and an *analytic seed layer* (the
Cauchy–Schwarz base cases). The engine is pattern-agnostic in spirit; the seeds
are what make it non-vacuous. Three directions stand out.

1. **Sign-free even-cycle Sidorenko for all lengths.** The $C_4$ proof exposes a
   recursive doubling $A^r \mapsto A^{2r}$ via a single Cauchy–Schwarz step that
   never inspects a sign. Turning this into an induction on $m$ would prove
   $t(C_{2m}, A) \ge t(K_2, A)^{2m}$ for every symmetric weighted graph, settling
   the even-cycle case in the discrete model in one stroke.
2. **The ratio spectrum.** Characterize which ratios are realizable and prove
   that the closure of the achievable set under multiplication is all of
   $[0,\infty)$, making the qualitative amplification picture into a precise
   structural theorem about the orbit closure.
3. **Spectral transfer beyond cycles.** The multiplicativity
   $t(H, A\otimes B) = t(H,A)\,t(H,B)$ is expected for *every* pattern $H$, since
   homomorphism counts are contractions of tensor powers of the adjacency
   operator. This would extend both transfer principles to arbitrary bipartite
   patterns.

## References

- P. Erdős and M. Simonovits, *Compactness results in extremal graph theory*,
  Combinatorica, 1984.
- A. Sidorenko, *A correlation inequality for bipartite graphs*, Graphs and
  Combinatorics, 1993.
- L. Lovász and B. Szegedy, *Limits of dense graph sequences*, J. Combin. Theory
  Ser. B, 2006.
- D. Conlon, J. Fox, and B. Sudakov, *An approximate version of Sidorenko's
  conjecture*, Geom. Funct. Anal., 2010.
