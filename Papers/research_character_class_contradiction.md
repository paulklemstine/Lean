# The Character Class Contradiction: A Rank-One Zeta Computation and the Failure of Higher-Trace Vanishing

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty

---

## Abstract

We study the rank-one all-ones matrix $A = \left(\begin{smallmatrix} 1 & 1 \\ 1 & 1 \end{smallmatrix}\right)$
over the rationals and the dynamical/arithmetic zeta function it generates through the
classical exponential-of-traces construction. We prove a complete chain of elementary
but tightly interlocked results: the quadratic relation $A^2 = 2A$; the closed form
$A^{n+1} = 2^n A$ for the powers; the point-count formula $N_r := \operatorname{trace}(A^r) = 2^r$
for all $r \ge 1$; the spectral determinant identity $\det(1 - tA) = 1 - 2t$; and the
evaluation of the zeta function $Z(t) = \exp\bigl(\sum_{r \ge 1} N_r t^r / r\bigr) = (1 - 2t)^{-1}$
on the disc $|t| < \tfrac12$. We then use these to refute a tempting heuristic — that a
rank-one ("degenerate") object should have vanishing higher counts, $N_r = 0$ for
$r \ne 1$ — by exhibiting the explicit obstruction $N_2 = 4$. The example is the
smallest faithful model of the full shift on two symbols, and its determinant
$\det(1 - A) = -1$ connects it to the $K$-theory of the Cuntz–Krieger algebra
$\mathcal{O}_2$. We give proof sketches, an algorithmic treatment of trace counting and
zeta evaluation, and a discussion of how the construction generalizes to arbitrary
$0$–$1$ matrices (subshifts of finite type) and to the eigenvalue dichotomy underlying
the ordinary/supersingular distinction in arithmetic geometry. Every result stated here
has been formally verified.

---

## 1. Introduction

### 1.1 Motivation

A recurring meta-theorem in mathematics asserts that *counting at all scales is governed
by a finite spectrum*. This principle takes many concrete forms:

- In algebraic geometry, the **Weil conjectures** (Dwork, Grothendieck, Deligne) state
  that the zeta function of a variety over a finite field is rational, with numerator and
  denominator controlled by the eigenvalues of Frobenius on cohomology.
- In dynamics, the **Bowen–Lanford formula** computes the Artin–Mazur zeta function of a
  subshift of finite type with transition matrix $A$ as $1/\det(1 - tA)$.
- In operator algebras, the same $0$–$1$ matrices define **Cuntz–Krieger algebras**
  $\mathcal{O}_A$, whose $K$-theory is the cokernel of $1 - A^{\mathsf T}$.

All three viewpoints share a single algebraic engine: the identity

$$\exp\!\left( \sum_{r \ge 1} \frac{\operatorname{trace}(A^r)}{r}\, t^r \right) = \frac{1}{\det(1 - tA)}. \tag{$\ast$}$$

This paper isolates the **smallest nontrivial instance** of ($\ast$) and uses it to make a
methodological point. The "Character Class Contradiction" of the title is the refutation
of a plausible but false expectation: that a rank-one matrix, being maximally degenerate,
should have vanishing higher point counts. We show in complete detail why this fails, and
we frame the failure as a clean dichotomy between *spatial degeneracy* (low rank) and
*dynamical triviality* (vanishing iterated traces).

### 1.2 The object of study

Throughout, fix

$$A = \begin{pmatrix} 1 & 1 \\ 1 & 1 \end{pmatrix} \in \mathrm{M}_2(\mathbb{Q}).$$

This is the adjacency matrix of the complete directed graph on two vertices with loops —
equivalently, the transition matrix of the **full shift on two symbols**, whose set of
admissible length-$r$ words has cardinality $2^r$. The number $2^r$ will appear as the
point count, and its generating zeta function as a rational function. We work over
$\mathbb{Q}$ for the algebraic identities and pass to $\mathbb{R}$ for the analytic
(series-convergence) statement.

### 1.3 Contributions

1. A fully verified derivation of the closed-form powers, traces, spectral determinant,
   and zeta function of $A$ (Sections 3–5).
2. An explicit, honest treatment of the $r = 0$ boundary anomaly, where the naive formula
   $N_r = 2^r$ fails because $\operatorname{trace}(A^0) = \operatorname{trace}(I_2) = 2 \ne 1 = 2^0$ (Section 3.3).
3. A precise refutation of the higher-trace-vanishing heuristic (Section 6).
4. An algorithmic and numerical companion (Sections 7–8), and a discussion connecting the
   example to subshifts, Cuntz–Krieger $K$-theory, and the ordinary/supersingular
   dichotomy (Section 9).

---

## 2. Preliminaries and Notation

For a square matrix $M \in \mathrm{M}_n(R)$ over a commutative ring $R$:

- $\operatorname{trace}(M) = \sum_{i} M_{ii}$ denotes the trace.
- $M^r$ denotes the $r$-th matrix power, with $M^0 = I_n$ the identity by convention.
- Scalar multiplication is written $c \cdot M$ or $c\, M$; we use the relation
  $\operatorname{trace}(c\, M) = c \operatorname{trace}(M)$ and $(c\, M) N = c (MN)$ freely.

For the $2 \times 2$ case we use the explicit formulas
$\operatorname{trace}\left(\begin{smallmatrix} a & b \\ c & d \end{smallmatrix}\right) = a + d$ and
$\det\left(\begin{smallmatrix} a & b \\ c & d \end{smallmatrix}\right) = ad - bc$.

The analytic input is the logarithmic power series: for real $x$ with $|x| < 1$,

$$\sum_{n \ge 0} \frac{x^{n+1}}{n+1} = \sum_{r \ge 1} \frac{x^r}{r} = -\log(1 - x). \tag{L}$$

---

## 3. Powers and Traces of the Rank-One Matrix

### 3.1 The quadratic relation

**Theorem 3.1 (`A_mul_A_eq_two_mul_A`).** $A \cdot A = 2 A.$

*Proof sketch.* Direct entrywise computation. Each entry of $A^2$ is a sum of two
products of $1$'s: $(A^2)_{ij} = \sum_{k} A_{ik} A_{kj} = 1\cdot 1 + 1 \cdot 1 = 2 = 2 A_{ij}$,
since every $A_{ij} = 1$. Formally one checks all four $(i,j) \in \{0,1\}^2$ and reduces by
ring arithmetic. $\square$

This single relation is the algebraic source of every subsequent identity: $A$ satisfies
the minimal polynomial $X^2 - 2X = X(X-2)$, so its eigenvalues are $0$ and $2$.

### 3.2 Closed form for the powers

**Theorem 3.2 (`A_pow_succ`).** For all $n \in \mathbb{N}$, $\;A^{n+1} = 2^n A.$

*Proof sketch.* Induction on $n$. Base case $n = 0$: $A^1 = A = 2^0 A$. Inductive step:
assume $A^{k+1} = 2^k A$. Then
$$A^{k+2} = A \cdot A^{k+1} = A \cdot (2^k A) = 2^k (A \cdot A) = 2^k (2A) = 2^{k+1} A,$$
using Theorem 3.1 in the penultimate step and the scalar–matrix associativity
$A(c\,A) = c(A\,A)$. $\square$

Thus the orbit $\{A^r\}_{r \ge 1}$ lies on the single ray $\mathbb{Q}_{>0} \cdot A$: powering
$A$ only rescales it. Geometrically, $A$ projects onto the line spanned by $(1,1)^{\mathsf T}$
and stretches by a factor of $2$, so the $r$-fold iterate stretches by $2^{r-1}$ on that
line and kills the orthogonal complement.

### 3.3 Traces and the boundary anomaly

**Theorem 3.3 (`trace_A`).** $\operatorname{trace}(A) = 2.$

*Proof sketch.* $\operatorname{trace}(A) = A_{00} + A_{11} = 1 + 1 = 2$. $\square$

**Theorem 3.4 (`trace_pow_two_shift`).** For all $r \ge 1$,
$\;\operatorname{trace}(A^r) = 2^r.$

*Proof sketch.* Write $r = n + 1$ with $n \ge 0$. By Theorem 3.2,
$A^r = 2^n A$, so
$$\operatorname{trace}(A^r) = \operatorname{trace}(2^n A) = 2^n \operatorname{trace}(A) = 2^n \cdot 2 = 2^{n+1} = 2^r,$$
using Theorem 3.3. $\square$

**The hypothesis $r \ge 1$ is essential.** At $r = 0$ we have $A^0 = I_2$ and
$\operatorname{trace}(I_2) = 2$, whereas $2^0 = 1$. Hence
$$\operatorname{trace}(A^0) = 2 \ne 1 = 2^0,$$
and the formula $\operatorname{trace}(A^r) = 2^r$ is **false** at $r = 0$. This is not a
defect: in the zeta construction below, the $r = 0$ summand is annihilated by the factor
$1/r$, so the discrepancy never propagates. But any statement of Theorem 3.4 that omitted
the hypothesis would be incorrect, and the formal development records $1 \le r$ explicitly.

We package the counts as a definition:

**Definition 3.5 (`N`).** The point counts are $N_r := \operatorname{trace}(A^r)$ for
$r \in \mathbb{N}$. Explicitly $N_0 = 2$ and $N_r = 2^r$ for $r \ge 1$.

---

## 4. The Spectral Determinant

**Theorem 4.1 (`det_one_sub_t_mul_A`).** For every $t \in \mathbb{Q}$,
$$\det(I_2 - t A) = 1 - 2t.$$

*Proof sketch.* Compute the matrix
$$I_2 - tA = \begin{pmatrix} 1 - t & -t \\ -t & 1 - t \end{pmatrix},$$
then apply the $2 \times 2$ determinant formula:
$$\det(I_2 - tA) = (1-t)(1-t) - (-t)(-t) = (1 - 2t + t^2) - t^2 = 1 - 2t. \qquad \square$$

This polynomial is the **reversed characteristic polynomial** of $A$. Factoring,
$1 - 2t = (1 - 0\cdot t)(1 - 2 t)$, exhibits the eigenvalues $0$ and $2$: the eigenvalue
$\lambda$ contributes a factor $(1 - \lambda t)$. The eigenvalue $0$ contributes the
trivial factor $1$, which is precisely why it leaves no trace (literally) in the counts.

---

## 5. The Zeta Function

### 5.1 Definition

**Definition 5.1 (`Z`).** For $t \in \mathbb{Q}$ define the (real-valued) zeta function
$$Z(t) = \exp\!\left( \sum_{r \in \mathbb{N}} \frac{N_r\, t^r}{r} \right),$$
where the $r = 0$ term is interpreted as $N_0 \cdot t^0 / 0 = 0$ (division by zero is $0$
in the Lean/`ℝ` convention, matching the analytic fact that this term is conventionally
absent from the logarithmic series).

### 5.2 Evaluation

**Theorem 5.2 (`zeta_function`).** For every rational $t$ with $|t| < \tfrac12$,
$$Z(t) = \frac{1}{1 - 2t}.$$

*Proof sketch.* Set $x = 2t$, so $|x| < 1$. We show the exponent equals $-\log(1 - x)$.

1. **Term identification.** For $n \ge 0$, using $N_{n+1} = 2^{n+1}$ (Theorem 3.4),
   $$\frac{N_{n+1}\, t^{n+1}}{n+1} = \frac{2^{n+1} t^{n+1}}{n+1} = \frac{(2t)^{n+1}}{n+1} = \frac{x^{n+1}}{n+1}.$$
2. **Summation.** By the logarithmic series (L) with $|x| < 1$,
   $$\sum_{n \ge 0} \frac{x^{n+1}}{n+1} = -\log(1 - x),$$
   and by step 1 this equals $\sum_{n \ge 0} \frac{N_{n+1} t^{n+1}}{n+1}$, i.e. the tail of
   the defining sum from $r = 1$ onward.
3. **Reinsertion of $r = 0$.** The $r = 0$ term is $N_0 t^0 / 0 = 0$, so adding it back does
   not change the sum: $\sum_{r \ge 0} \frac{N_r t^r}{r} = -\log(1 - x)$.
4. **Exponentiation.** Since $|x| < 1$ gives $1 - x > 0$,
   $$Z(t) = \exp\bigl(-\log(1 - x)\bigr) = \frac{1}{1 - x} = \frac{1}{1 - 2t}. \qquad \square$$

### 5.3 The role of the convergence hypothesis

The bound $|t| < \tfrac12$ (equivalently $|x| < 1$) is the radius of convergence of the
defining logarithmic series and **cannot be dropped**. Outside the disc the series
$\sum_r (2t)^r / r$ diverges, so $Z(t)$ is not even defined by its series there, and the
clean identity $Z(t) = 1/(1 - 2t)$ holds only on the disc of convergence. The rational
function $1/(1-2t)$ extends meromorphically to all $t \ne \tfrac12$, but that extension is
*not* computed by the convergent exponential-of-traces series. This mirrors the general
situation for dynamical zeta functions, whose Euler-product/exponential definitions
converge only inside a disc determined by the spectral radius, even though the resulting
rational function lives on a larger domain.

### 5.4 The Bowen–Lanford identity in this case

Combining Theorems 4.1 and 5.2 yields the instance of ($\ast$):
$$\exp\!\left( \sum_{r \ge 1} \frac{\operatorname{trace}(A^r)}{r}\, t^r \right) = \frac{1}{\det(I_2 - tA)} = \frac{1}{1 - 2t}.$$
The denominator of the zeta function is exactly the spectral determinant. The poles of
$Z$ are the reciprocals of the nonzero eigenvalues; here the single pole $t = \tfrac12$
corresponds to the eigenvalue $2$.

---

## 6. The Contradiction

### 6.1 The heuristic

A natural but naive expectation, often voiced for "degenerate" objects, is:

> *Rank-one (degenerate) objects carry information only at the first level; their higher
> point counts vanish, $N_r = 0$ for all $r \ne 1$.*

The matrix $A$ is the ideal stress test: it is genuinely rank one (its rows are equal),
so it is as degenerate as a nonzero $2\times 2$ matrix can be.

### 6.2 The refutation

**Theorem 6.1 (`naive_expectation_false`).** It is **not** the case that
$\operatorname{trace}(A^r) = 0$ for all $r \ne 1$. Concretely,
$$\operatorname{trace}(A^2) = 4 \ne 0.$$

*Proof sketch.* Suppose for contradiction that $\operatorname{trace}(A^r) = 0$ for every
$r \ne 1$. Instantiate at $r = 2$ (which satisfies $2 \ne 1$): by Theorem 3.4,
$\operatorname{trace}(A^2) = 2^2 = 4$, so the assumption forces $4 = 0$ in $\mathbb{Q}$, a
contradiction. $\square$

### 6.3 Interpretation: degeneracy in space $\ne$ triviality in time

The refutation is not an accident of the specific matrix; it reflects a structural fact.
Rank one means $A$ has only one nonzero eigenvalue, but that eigenvalue ($\lambda = 2$) is
**greater than one**, so its powers $\lambda^r = 2^r$ grow without bound and dominate every
trace. The correct invariant controlling higher-trace vanishing is not the rank but the
spectrum: $\operatorname{trace}(A^r) = \sum_i \lambda_i^r = 0^r + 2^r$, which vanishes only
when all eigenvalues are zero (a nilpotent matrix). A rank-one matrix is nilpotent iff its
unique nonzero eigenvalue is absent, i.e. iff $\operatorname{trace}(A) = 0$. Since
$\operatorname{trace}(A) = 2 \ne 0$, $A$ is rank-one but emphatically not nilpotent, and its
counts form the geometric tower $2, 4, 8, 16, \dots$. **Spatial degeneracy (low rank) and
dynamical triviality (nilpotence) are independent**, and conflating them is exactly the
error the heuristic commits.

---

## 7. Algorithms

We extract two algorithms implicit in the proofs. Full type-hinted implementations appear
in the companion demo; here we give the mathematical content and complexity.

### 7.1 Point-count via the closed form

Rather than forming $A^r$ by repeated multiplication ($O(r)$ matrix products), Theorem 3.4
collapses the computation to a single exponentiation.

```
Algorithm POINT_COUNT(r):
    input:  natural number r
    output: N_r = trace(A^r)
    if r == 0:
        return 2            # trace(I_2) = 2  (boundary anomaly)
    else:
        return 2 ** r       # Theorem 3.4
```

Complexity: $O(1)$ arithmetic operations (or $O(\log r)$ bit operations via fast
exponentiation for the integer $2^r$), versus $O(r)$ for the naive matrix-power approach.
Correctness is exactly Theorems 3.3–3.4 plus the recorded boundary value.

### 7.2 Zeta evaluation via the spectral determinant

```
Algorithm ZETA(t):
    input:  rational t with |t| < 1/2
    output: Z(t) = 1 / (1 - 2 t)
    require |t| < 1/2          # radius of convergence
    return 1 / (1 - 2 * t)     # Theorems 4.1 + 5.2
```

Complexity: $O(1)$. The nontrivial content is the *proof* that this closed form equals the
exponential of the infinite trace series; the computation itself is one division. A
partial-sum routine that truncates $\sum_{r=1}^{R} (2t)^r/r$ and exponentiates converges to
the same value at geometric rate $|2t|^{R}$, providing an independent numerical check.

---

## 8. Numerical Illustrations

The companion `demo.py` computes, for the matrix $A$:

- the powers $A^r$ and verifies $A^{n+1} = 2^n A$ exactly with integer arithmetic;
- the traces $N_r$ and verifies $N_r = 2^r$ for $r \ge 1$ while exhibiting $N_0 = 2 \ne 1$;
- the determinant $\det(I_2 - tA) = 1 - 2t$ at sample $t$;
- the truncated zeta series against the closed form $1/(1-2t)$, showing geometric
  convergence inside $|t| < \tfrac12$ and divergence outside;
- the contradiction witness $N_2 = 4 \ne 0$.

A representative table of counts:

| $r$ | $\operatorname{trace}(A^r)$ | $2^r$ | agree? |
|----:|----------------------------:|------:|:------:|
| 0   | 2                           | 1     | no (boundary) |
| 1   | 2                           | 2     | yes |
| 2   | 4                           | 4     | yes |
| 3   | 8                           | 8     | yes |
| 4   | 16                          | 16    | yes |
| 5   | 32                          | 32    | yes |

---

## 9. Discussion and Applications

### 9.1 The full shift on two symbols

$A$ is the transition matrix of the full $2$-shift; the count $N_r = 2^r$ is the number of
length-$r$ binary words, and the Artin–Mazur zeta function $1/(1-2t)$ is the standard
dynamical zeta function of this system. The general Bowen–Lanford theorem,
$\zeta(t) = 1/\det(1 - tA)$ for any $0$–$1$ transition matrix $A$, is the broad statement
of which our Theorem 5.2 is the rank-one base case.

### 9.2 Cuntz–Krieger $K$-theory

For a $0$–$1$ matrix $A$, the Cuntz–Krieger algebra $\mathcal{O}_A$ has
$K_0(\mathcal{O}_A) = \operatorname{coker}(1 - A^{\mathsf T})$. For our $A$,
$\det(I_2 - A) = 1 - 2 = -1$, a unit, so $1 - A^{\mathsf T}$ is unimodular over
$\mathbb{Z}$, its cokernel is trivial, and $\mathcal{O}_A$ is $\mathcal{O}_2$-like with
$K_0 = 0$. The single determinant evaluation $\det(I_2 - A) = -1$ thus simultaneously fixes
the pole of the zeta function and the triviality of an infinite-dimensional $K$-theoretic
invariant — a concrete instance of the slogan that "one matrix controls dynamics, zeta,
and operator $K$-theory at once."

### 9.3 Eigenvalue dichotomy

The relation $A^2 = 2A$ forces the maximally degenerate spectrum $\{0, 2\}$. The sign of
the higher counts is governed entirely by the dominant eigenvalue: the counts
$\operatorname{trace}(A^r) = 0^r + 2^r$ are eventually positive precisely because the
dominant eigenvalue $2$ is real and exceeds $1$. This is the rank-one shadow of the
ordinary/supersingular dichotomy for $\mathrm{GL}_2$ Frobenius elements, where the position
of eigenvalues relative to the unit circle (or the $\sqrt{p}$ circle, via the Weil bound)
separates qualitatively different arithmetic behaviour.

### 9.4 The methodological payoff

The contradiction (Theorem 6.1) is a permanent caution: low rank does not imply trivial
higher invariants. Whenever a degenerate object tempts one to declare its higher
characteristic data zero "by symmetry," the matrix $A$ is the minimal counterexample —
compute $\operatorname{trace}(A^2)$ first.

---

## 10. Future Directions

The following research directions extend the present rank-one computation toward general
subshifts, operator $K$-theory, and arithmetic dichotomies.

- **Primitive zeta factorization for general $0$–$1$ matrices.** For an irreducible $0$–$1$
  matrix $A$ (a general subshift of finite type), conjecture that the Bowen–Lanford zeta
  reciprocal $\det(1 - tA)$ factors over $\mathbb{Z}[t]$ into "primitive" pieces whose
  constant terms multiply to $\pm \det(1 - A) = \pm |K_0(\mathcal{O}_A)|$, with the
  factorization visible as a direct-sum decomposition of $K_0$. The full-shift base case
  $\det(1 - tJ) = 1 - nt$, $K_0 = \mathbb{Z}/(n-1)$ is already established; extending the
  power identities to block/companion forms is the next step.

- **Eigenvalue dichotomy as an ordinary/supersingular shadow.** For any $2\times 2$ integer
  "Frobenius" $A$ with $\det A \ge 0$, conjecture that the period counts
  $\operatorname{trace}(A^r)$ are eventually positive iff the dominant eigenvalue is real
  and $> 1$; the repeated-eigenvalue boundary case is the formal trace of "supersingular"
  behaviour. The relation $A^2 = 2A$ forcing eigenvalues $\{0,2\}$ is the cleanest
  maximally degenerate instance.

- **$K_0(\mathcal{O}_A) = 0 \iff 1 - A^{\mathsf T}$ unimodular $\iff$ flow-equivalence to
  $\mathcal{O}_2$.** For an irreducible non-permutation $0$–$1$ matrix $A$, conjecture that
  $\mathcal{O}_A$ is $\mathcal{O}_2$-like ($K_0 = 0$) iff $\det(1 - A) = \pm 1$, detected
  purely by $1 - A^{\mathsf T}$ being a unit in $\mathrm{GL}_n(\mathbb{Z})$. The
  triviality of $K_0(\mathcal{O}_2)$ has been reduced to $\det(1 - A) = -1$; the converse is
  a Smith-normal-form statement.

- **Multiplicativity over shift products.** For full shifts on $m$ and $n$ symbols, the
  product subshift (Kronecker product $J_m \otimes J_n$) should have point count
  $(mn)^r$, and its zeta reciprocal should factor compatibly, expressing multiplicativity
  of the construction under products of dynamical systems.

---

## 11. Conclusion

From the four ones of $A$ we derived a closed-form power law, an exact point-count
$N_r = 2^r$, a spectral determinant $1 - 2t$, and a rational zeta function $1/(1-2t)$, all
locked together by the lone eigenvalue $2$. The same data refutes the higher-trace
vanishing heuristic via the one-line witness $\operatorname{trace}(A^2) = 4$. Small as it
is, the example is a faithful microcosm of the rationality phenomena that animate the Weil
conjectures, Bowen–Lanford theory, and Cuntz–Krieger $K$-theory, and a reusable guardrail
against confusing spatial degeneracy with dynamical triviality.
