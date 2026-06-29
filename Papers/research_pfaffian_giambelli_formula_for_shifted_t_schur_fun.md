# A Pfaffian Giambelli Formula for Shifted $t$-Schur Functions: The Algebraic Core

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Algebraic Combinatorics / Symmetric Functions)

## Abstract

The Schur $Q$-functions indexed by strict partitions admit a classical *Giambelli
formula* expressing each $s_\lambda^Q$ as the Pfaffian of a matrix of two-row Schur
$Q$-functions. Its $t$-deformation — the **shifted $t$-Schur functions** arising from the
odd Greaves–Jing–Zhu (GJZ) operators — preserves this Pfaffian shape exactly, so the
algebraic engine driving both the classical and the deformed formula is the Pfaffian
itself. In this paper we isolate and rigorously establish the structural backbone of that
engine for the two smallest nontrivial block sizes: the $2\times 2$ case ($k=1$) and the
$4\times 4$ case ($k=2$, the first genuinely interesting Pfaffian). Our main results are:
(i) an explicit first-row Laplace expansion of the $4\times 4$ determinant over an arbitrary
commutative ring; (ii) the Pfaffian–determinant identities $\det A = \operatorname{Pf}(A)^2$
for alternating $2\times 2$ and $4\times 4$ matrices, the degree-four polynomial identity in
twelve variables that pins the Pfaffian down as the canonical square root of the determinant;
(iii) the alternating sign law, $\operatorname{Pf}$ flips sign under a transposition of two
indices, the matrix-level shadow of Clifford anticommutation $\psi_i\psi_j = -\psi_j\psi_i$;
and (iv) the complementary-minor (Giambelli) expansion of the $4\times 4$ Pfaffian as an
alternating sum of products of $2\times 2$ Pfaffians, the $k=2$ instance of the recursive
Pfaffian Giambelli formula. All results hold over an arbitrary commutative ring. We discuss
how these facts feed the $t$-deformed construction, where a linear deformation $A + tB$ of the
Pfaffian entries yields a polynomial of degree $\le k$ in $t$ whose constant term is the
classical Schur $Q$-function and whose leading term is $\operatorname{Pf}(B)$.

## 1. Introduction

### 1.1 Motivation

Schur $Q$-functions are the symmetric functions attached to strict partitions. They control
the projective (spin) representation theory of the symmetric and alternating groups, the
structure of the cohomology rings of isotropic (Lagrangian and orthogonal) Grassmannians,
and the combinatorics of shifted Young tableaux. A cornerstone of their theory is the
*Giambelli formula*, which reduces an arbitrary Schur $Q$-function to a Pfaffian of two-row
ones. In recent work, a one-parameter deformation — the **shifted $t$-Schur functions**
$s_\lambda^Q(t)$ — has been constructed from a family of odd (fermionic) vertex operators,
the Greaves–Jing–Zhu operators, with the property that the Giambelli formula deforms *without
changing shape*:
$$s_\lambda^Q(t) = \operatorname{Pf}\big[\, Y_{\lambda_i - i + j}(t) + Y_{\lambda_j - j + i}(t)\,\big]_{1\le i<j\le k}\cdot \mathrm{vac},$$
where the $Y_m(t)$ are $t$-dependent operator modes and $\mathrm{vac}$ is the vacuum vector.
At $t=0$ this recovers the classical Schur $Q$-function Giambelli Pfaffian.

The Clifford / anticommutation structure of the GJZ operators is precisely what makes a
Pfaffian (rather than a determinant or a less symmetric expression) the correct combinatorial
object. The purpose of this paper is to lay down, with complete rigor and over an arbitrary
commutative ring, the algebraic facts about Pfaffians that every such formula rests upon, at
the two smallest block sizes where they can be exhibited concretely.

### 1.2 Contributions

We establish four families of results, all over an arbitrary commutative ring $R$:

1. **`det_fin_four`** — the explicit Laplace expansion of a $4\times 4$ determinant.
2. **`pf2_sq_eq_det`, `pf4_sq_eq_det`** — the Pfaffian–determinant identity
   $\det A = \operatorname{Pf}(A)^2$ for alternating $2\times 2$ and $4\times 4$ matrices.
3. **`pf4_swap12_neg`** — the alternating sign law for the $4\times 4$ Pfaffian.
4. **`pf4_giambelli`** — the complementary-minor expansion of the $4\times 4$ Pfaffian as a
   signed sum of products of $2\times 2$ Pfaffians.

These are the verified base cases ($k=1,2$) of the general recursive Pfaffian Giambelli
formula, and they form the reusable core upon which the $t$-deformed statements are built.

## 2. Definitions

Throughout, $R$ is a commutative ring (with unit), and matrices are indexed by $\mathrm{Fin}\,n
= \{0, 1, \dots, n-1\}$. We write $A_{ij}$ for the entry in row $i$, column $j$.

**Definition 2.1 (Alternating matrix).** A square matrix $A$ is *skew-symmetric* if
$A_{ij} = -A_{ji}$ for all $i,j$. It is *alternating* if, in addition, $A_{ii} = 0$ for all
$i$. Over a ring in which $2$ is not a zero divisor, skew-symmetry implies the zero diagonal;
in general the two conditions must be imposed separately, and "alternating" is the strictly
stronger notion. The Pfaffian–determinant identity requires the full alternating hypothesis,
whereas the sign law requires only skew-symmetry.

**Definition 2.2 (Pfaffian of a $2\times 2$ matrix, $k=1$).** For
$A \in \mathrm{Mat}_{2\times 2}(R)$,
$$\operatorname{Pf}_2(A) := A_{01}.$$
This is the sole super-diagonal entry, equivalently the sum over the unique perfect matching
of $\{0,1\}$.

**Definition 2.3 (Pfaffian of a $4\times 4$ matrix, $k=2$).** For
$A \in \mathrm{Mat}_{4\times 4}(R)$,
$$\operatorname{Pf}_4(A) := A_{01}A_{23} - A_{02}A_{13} + A_{03}A_{12}.$$
The three terms correspond to the three perfect matchings of $\{0,1,2,3\}$:
$\{01,23\}$, $\{02,13\}$, $\{03,12\}$, with signs $+,-,+$ given by the signature of the
associated permutation.

**Definition 2.4 (Submatrix / index restriction).** For an injection
$\iota : \mathrm{Fin}\,m \hookrightarrow \mathrm{Fin}\,n$, the submatrix
$A[\iota,\iota]$ has entries $(A[\iota,\iota])_{ab} = A_{\iota(a)\,\iota(b)}$. We write
$A_{ij}$ (in the Giambelli expansion) for the $2\times 2$ principal submatrix on rows and
columns $\{i,j\}$, i.e. $A[\{i,j\},\{i,j\}]$.

**Definition 2.5 (Strict partition).** A *strict partition* is a finite tuple
$\lambda = (\lambda_1 > \lambda_2 > \dots > \lambda_k \ge 0)$ of weakly decreasing,
distinct nonnegative integers. We write $q(n)$ for the number of strict partitions of $n$
and $p(n)$ for the number of all partitions of $n$; recall $p(n) = |\mathrm{ConjClasses}(S_n)|$.

## 3. Main Results

### 3.1 The $4\times 4$ determinant

**Theorem 3.1 (`det_fin_four`).** For every $A \in \mathrm{Mat}_{4\times 4}(R)$,
$$
\begin{aligned}
\det A =\;& A_{00}\big(A_{11}(A_{22}A_{33}-A_{23}A_{32}) - A_{12}(A_{21}A_{33}-A_{23}A_{31}) + A_{13}(A_{21}A_{32}-A_{22}A_{31})\big)\\
-\;& A_{01}\big(A_{10}(A_{22}A_{33}-A_{23}A_{32}) - A_{12}(A_{20}A_{33}-A_{23}A_{30}) + A_{13}(A_{20}A_{32}-A_{22}A_{30})\big)\\
+\;& A_{02}\big(A_{10}(A_{21}A_{33}-A_{23}A_{31}) - A_{11}(A_{20}A_{33}-A_{23}A_{30}) + A_{13}(A_{20}A_{31}-A_{21}A_{30})\big)\\
-\;& A_{03}\big(A_{10}(A_{21}A_{32}-A_{22}A_{31}) - A_{11}(A_{20}A_{32}-A_{22}A_{30}) + A_{12}(A_{20}A_{31}-A_{21}A_{30})\big).
\end{aligned}
$$

*Proof sketch.* This is the Laplace (cofactor) expansion along the first row. One reduces the
$4\times 4$ determinant to four $3\times 3$ determinants via expansion along row $0$
(`det_succ_row_zero`), applies the known $3\times 3$ formula (`det_fin_three`) to each minor,
and evaluates the resulting `Fin.succAbove` index shifts explicitly (each by direct
computation). Collecting terms and normalizing with ring arithmetic gives the stated
twenty-four-term expression. Although elementary, the formula is not provided by the ambient
library at this version, so it is established once here and reused. $\square$

### 3.2 The Pfaffian–determinant identity

**Theorem 3.2 (`pf2_sq_eq_det`, $k=1$).** If $A \in \mathrm{Mat}_{2\times 2}(R)$ is
alternating ($A_{ij} = -A_{ji}$ and $A_{ii}=0$), then
$$\det A = \operatorname{Pf}_2(A)^2.$$

*Proof sketch.* By the $2\times 2$ determinant formula, $\det A = A_{00}A_{11} - A_{01}A_{10}$.
Substituting $A_{00}=A_{11}=0$ and $A_{10} = -A_{01}$ gives $\det A = -A_{01}(-A_{01}) =
A_{01}^2 = \operatorname{Pf}_2(A)^2$. $\square$

**Theorem 3.3 (`pf4_sq_eq_det`, $k=2$).** If $A \in \mathrm{Mat}_{4\times 4}(R)$ is
alternating, then
$$\det A = \operatorname{Pf}_4(A)^2 = (A_{01}A_{23} - A_{02}A_{13} + A_{03}A_{12})^2.$$

*Proof sketch.* Start from the expansion of Theorem 3.1. Impose the alternating relations:
$A_{ii}=0$ for $i=0,1,2,3$, and $A_{10}=-A_{01}$, $A_{20}=-A_{02}$, $A_{30}=-A_{03}$,
$A_{21}=-A_{12}$, $A_{31}=-A_{13}$, $A_{32}=-A_{23}$. After substitution the twenty-four-term
determinant collapses, and a direct ring computation shows it equals the expansion of the
square $(A_{01}A_{23} - A_{02}A_{13} + A_{03}A_{12})^2$. This is a genuine degree-four
polynomial identity in the twelve independent entries $\{A_{ij} : i<j\}$ — equivalently the six
free entries above the diagonal — and it is the algebraic heart of the Pfaffian theory: it is
what guarantees that the Pfaffian, and not merely its square, is a well-defined polynomial
invariant. $\square$

**Remark 3.4.** The identity $\det A = \operatorname{Pf}(A)^2$ determines $\operatorname{Pf}(A)$
only up to sign as an abstract square root; the *definition* via the signed matching sum fixes
the sign canonically and makes $\operatorname{Pf}$ a polynomial with integer coefficients,
specializing to $+1$ on the standard alternating block $J = \bigoplus \left(\begin{smallmatrix}
0 & 1 \\ -1 & 0\end{smallmatrix}\right)$.

### 3.3 The alternating sign law

**Theorem 3.5 (`pf4_swap12_neg`).** Let $A \in \mathrm{Mat}_{4\times 4}(R)$ be skew-symmetric
($A_{ij}=-A_{ji}$; the zero diagonal is not needed). Let $\tau = (1\;2)$ denote the
transposition of indices $1$ and $2$, and let $A^\tau := A[\tau,\tau]$ be the matrix with
both rows and columns permuted by $\tau$. Then
$$\operatorname{Pf}_4(A^\tau) = -\operatorname{Pf}_4(A).$$

*Proof sketch.* Expanding the definition on the permuted matrix, $\tau$ fixes $0$ and $3$ and
swaps $1\leftrightarrow 2$, so
$\operatorname{Pf}_4(A^\tau) = A_{02}A_{13} - A_{01}A_{23} + A_{03}A_{21}$. Using only
$A_{21} = -A_{12}$ (skew-symmetry) and reordering, this equals $-(A_{01}A_{23} - A_{02}A_{13}
+ A_{03}A_{12}) = -\operatorname{Pf}_4(A)$. $\square$

**Remark 3.6.** The sign law is the matrix avatar of Clifford anticommutation. Under the
correspondence between alternating matrices and quadratic elements of a Clifford algebra, a
transposition of indices corresponds to swapping two generators $\psi_i, \psi_j$ with
$\psi_i\psi_j = -\psi_j\psi_i$; the Pfaffian is the Berezin integral (top fermionic coefficient)
of the exponential $\exp\!\big(\tfrac12 \sum_{i<j} A_{ij}\psi_i\psi_j\big)$, and its sign change
under reindexing is exactly anticommutation. Notably the law requires only skew-symmetry, one
hypothesis weaker than the alternating condition needed for $\operatorname{Pf}^2 = \det$ —
reflecting that "alternating" is strictly stronger than "skew" outside characteristic $\ne 2$.

### 3.4 The complementary-minor Giambelli expansion

**Theorem 3.7 (`pf4_giambelli`, $k=2$).** For every $A \in \mathrm{Mat}_{4\times 4}(R)$,
$$\operatorname{Pf}_4(A) =
\operatorname{Pf}_2(A_{01})\operatorname{Pf}_2(A_{23})
- \operatorname{Pf}_2(A_{02})\operatorname{Pf}_2(A_{13})
+ \operatorname{Pf}_2(A_{03})\operatorname{Pf}_2(A_{12}),$$
where $A_{ij} = A[\{i,j\},\{i,j\}]$ is the $2\times 2$ principal submatrix on indices $i,j$, so
$\operatorname{Pf}_2(A_{ij}) = A_{ij}$.

*Proof sketch.* By Definition 2.2, $\operatorname{Pf}_2(A_{ij}) = (A_{ij})_{01} = A_{ij}$.
Substituting these into the right-hand side reproduces $A_{01}A_{23} - A_{02}A_{13} +
A_{03}A_{12}$, which is exactly $\operatorname{Pf}_4(A)$ by Definition 2.3. $\square$

**Remark 3.8.** Read structurally, this is the recursive Pfaffian Giambelli formula at $k=2$:
the $4\times 4$ Pfaffian is the alternating sum, over the three ordered partitions of
$\{0,1,2,3\}$ into complementary $2$-element index sets, of products of the corresponding
$2\times 2$ Pfaffians. The signs $+,-,+$ are the signatures of the underlying matchings. In
the general first-row recursion,
$\operatorname{Pf}_{2k}(A) = \sum_{j=2}^{2k} (-1)^{j} A_{1j}\,\operatorname{Pf}_{2k-2}(A_{\hat 1 \hat j})$,
where $A_{\hat 1 \hat j}$ deletes rows and columns $1$ and $j$; the $k=2$ case is precisely
Theorem 3.7.

## 4. From the Pfaffian core to shifted $t$-Schur functions

### 4.1 The Giambelli Pfaffian for Schur $Q$-functions

For a strict partition $\lambda = (\lambda_1 > \dots > \lambda_k \ge 0)$ (padded with a zero to
even length $2k$ when $k$ is odd), the classical Giambelli formula reads
$$s_\lambda^Q = \operatorname{Pf}\big[\, s_{(\lambda_i,\lambda_j)}^Q \,\big]_{1\le i<j\le 2k},$$
with the two-row Schur $Q$-functions $s_{(a,b)}^Q = q_a q_b + 2\sum_{r=1}^{b}(-1)^r q_{a+r}q_{b-r}$
as Pfaffian entries (here $q_m$ are the one-row $Q$-functions). The matrix
$A_{ij} = s_{(\lambda_i,\lambda_j)}^Q$ for $i<j$, extended skew-symmetrically with zero diagonal,
is alternating, so Theorems 3.2–3.3 (and their general-$k$ analogue) certify that the Pfaffian
is well-defined and that $\operatorname{Pf}^2 = \det$. The $k=2$ instance reproduces the
classical two-by-two-block Giambelli identity for four-part strict partitions via Theorem 3.7.

### 4.2 The $t$-deformation

The shifted $t$-Schur functions replace each $q_m$ with a $t$-dependent operator mode $Y_m(t)$
built from the odd GJZ operators, whose Clifford anticommutation is the source of the sign law
(Theorem 3.5). The Giambelli Pfaffian persists:
$$s_\lambda^Q(t) = \operatorname{Pf}\big[\, Y_{\lambda_i - i + j}(t) + Y_{\lambda_j - j + i}(t)\,\big]_{1\le i<j\le k}\cdot\mathrm{vac}.$$
Writing the entry matrix as a linear pencil $A + tB$ in $t$ — where $A$ records the $t^0$ part
(the classical entries) and $B$ the $t^1$ part — multilinearity of the Pfaffian gives:

**Proposition 4.1 (degree bound, $k=2$).** For $A, B \in \mathrm{Mat}_{4\times 4}(R)$,
$$\operatorname{Pf}_4(A + tB) = \operatorname{Pf}_4(A) + t\,M(A,B) + t^2\,\operatorname{Pf}_4(B),$$
where $M(A,B) = (A_{01}B_{23} + B_{01}A_{23}) - (A_{02}B_{13} + B_{02}A_{13}) + (A_{03}B_{12} +
B_{03}A_{12})$ is the polarization (mixed) term. In particular the deformation is a polynomial
in $t$ of degree $\le 2$, with constant term $\operatorname{Pf}_4(A) = s_\lambda^Q(0)$ (the
classical Schur $Q$-function) and leading term $\operatorname{Pf}_4(B)$.

*Proof sketch.* Substitute $A+tB$ into Definition 2.3 and expand each product
$(A_{ij}+tB_{ij})(A_{kl}+tB_{kl})$; collect powers of $t$. The $t^0$ coefficient is
$\operatorname{Pf}_4(A)$, the $t^2$ coefficient is $\operatorname{Pf}_4(B)$, and the $t^1$
coefficient is $M(A,B)$ as stated. $\square$

This generalizes: since $\operatorname{Pf}_{2k}$ is homogeneous of degree $k$ in the entries,
$\operatorname{Pf}_{2k}(A+tB)$ is a polynomial in $t$ of degree $\le k$ with constant term
$\operatorname{Pf}_{2k}(A)$ and leading term $t^k\operatorname{Pf}_{2k}(B)$ — the conjectured
analytic structure of the GJZ deformation (Conjecture 2 below).

## 5. Algorithms

We summarize the computational content as explicit algorithms (full code in the demos):

**Algorithm A (signed-matching Pfaffian).** Given a skew-symmetric $2k\times 2k$ matrix,
enumerate all $(2k-1)!! = 1\cdot 3\cdot 5\cdots(2k-1)$ perfect matchings of $\{1,\dots,2k\}$ by
the recursion "fix the smallest free index, pair it with each remaining index, recurse";
accumulate the product of entries times the signature of the matching. Complexity $O((2k-1)!!\cdot k)$.

**Algorithm B (recursive Giambelli Pfaffian).** Compute $\operatorname{Pf}$ by first-row
cofactor recursion $\operatorname{Pf}_{2k}(A) = \sum_{j\ge 2}(-1)^j A_{1j}\operatorname{Pf}(A_{\hat 1\hat j})$,
deleting two indices per step; complexity $O((2k-1)!!)$ with memoization, and exact in any ring.

**Algorithm C (deformation expansion).** Given the pencil $A+tB$, return the coefficient list
$[\operatorname{Pf}(A), M(A,B), \dots, \operatorname{Pf}(B)]$ by expanding the matching sum
symbolically in $t$.

## 6. Applications

- **Projective representation theory.** Schur $Q$-functions are characters of the spin (projective)
  representations of $S_n$ and $A_n$; the Giambelli Pfaffian reduces arbitrary characters to
  two-row data.
- **Geometry of isotropic Grassmannians.** Schur $Q$-functions represent Schubert classes in the
  cohomology of Lagrangian and orthogonal Grassmannians; the Pfaffian structure mirrors the
  geometry of isotropic subspaces.
- **Statistical mechanics.** Pfaffians compute dimer-model partition functions and underlie the
  Pfaffian solution of the planar Ising model; $\det = \operatorname{Pf}^2$ is the identity
  linking dimer and fermionic formulations.
- **Free-fermion field theory.** The sign law is the combinatorial form of Wick's theorem for
  free fermions, where correlation functions are Pfaffians of two-point functions.

## 7. Discussion

The results above are deliberately confined to $k=1,2$, but they are not toy cases: $k=2$ is the
first size at which the Pfaffian is more than a single entry, at which $\det = \operatorname{Pf}^2$
becomes a nontrivial degree-four identity, and at which the Giambelli recursion has any content.
Two design choices deserve comment. First, the sign law (Theorem 3.5) needs only skew-symmetry,
while $\operatorname{Pf}^2 = \det$ (Theorem 3.3) needs the full alternating hypothesis; this is
the algebraic fingerprint of the distinction between "skew" and "alternating," which coincide
only when $2$ is invertible. Second, working over an arbitrary commutative ring (rather than a
field) is essential for the application: the GJZ entries live in a polynomial ring in $t$, and
the identities must hold there.

## 8. Future Directions

**Conjecture 1 (general-$k$ $\operatorname{Pf}^2 = \det$).** For every $k$, the signed
matching-sum polynomial $\operatorname{pf}_{2k}$ satisfies $\det A = \operatorname{pf}_{2k}(A)^2$
for all alternating $2k\times 2k$ matrices over a commutative ring, and admits the recursive
first-row complementary-minor expansion. The induction reduces to matching the bilinear
matching-sum recursion against cofactor expansion; the $k=1,2$ base cases and `det_fin_four`
are in hand.

**Conjecture 2 (polynomiality in $t$).** For a strict partition with $2k$ padded parts,
$s_\lambda^Q(t) = \operatorname{Pf}(A + tB)$ is polynomial in $t$ of degree $\le k$, with constant
term $s_\lambda^Q(0)$ and leading term $t^k\operatorname{Pf}(B)$; the $k=2$ quadratic law is
Proposition 4.1.

**Conjecture 3 (strict counting strict inequality).** For $n \ge 3$, $q(n) < p(n) =
|\mathrm{ConjClasses}(S_n)|$; the strict-into-all inclusion is never surjective once a
repeated-part partition exists.

**Conjecture 4 (full $S_{2k}$ sign action).** The map $\sigma \mapsto
\operatorname{pf}_{2k}(A[\sigma,\sigma])$ equals $\mathrm{sign}(\sigma)\cdot\operatorname{pf}_{2k}(A)$
for every permutation $\sigma$ — the global form of Theorem 3.5.

## 9. Conclusion

We have rigorously established the algebraic backbone of the Pfaffian Giambelli formula at block
sizes $k=1$ and $k=2$: the explicit $4\times 4$ determinant, the Pfaffian–determinant identities,
the anticommutation sign law, and the recursive complementary-minor expansion — all over an
arbitrary commutative ring. These are the load-bearing facts on which the general identity and
the full shifted $t$-Schur deformation are built, and they hold without gaps.

## References

This paper is self-contained; all stated results are proved inline or sketched in full. The
mathematical context (Schur $Q$-functions, Giambelli formulas, projective representations of
symmetric groups, Pfaffians in statistical mechanics) is classical and widely documented in the
standard literature on symmetric functions and algebraic combinatorics.
