# A Pell Obstruction to a Proposed Family of Optimal Equidistant Codes for $n \equiv 2 \pmod 4$

## Abstract

An optimal equidistant binary code of length $n \equiv 2 \pmod 4$ is equivalent to a symmetric $2\text{-}(v,k,\lambda)$ block design. A recent speculative proposal suggested that a new, uncharted infinite family of such optimal codes exists, indexed by a nonnegative integer $u$, with parameters $v = 12u^2 + 8u + 2$, $k = 6u^2 + u$, and $\lambda = k(k-1)/(v-1)$. We carry out an adversarial analysis of this proposal. First, we prove that the awkward quotient defining $\lambda$ collapses to the polynomial $\lambda = 3u^2 - u$, so that the design order is $k - \lambda = u(3u+2)$. Second, we show $v \equiv 2 \pmod 4$ is always even, so the Bruck–Ryser–Chowla theorem forces the order to be a perfect square. Third — the central observation — the identity $(3u+1)^2 = 3\,u(3u+2) + 1$ converts the perfect-square condition into the Pell equation $x^2 - 3y^2 = 1$ with $x = 3u+1$. Consequently the admissible parameters are not dense in $\mathbb{N}$ but form a sparse Pell orbit $u = 0, 2, 32, 450, \dots$. In particular the bold existence claim is false at its smallest non-trivial instance $u = 1$, where the order would be $5$, a non-square, ruling out the symmetric $2\text{-}(22,7,2)$ design. We give the correct Diophantine characterization, exhibit explicit admissible members, and prove that a Pell step produces infinitely many admissible parameters. The corrected statement replaces a vague "exists for all $u$" claim with an exact arithmetic law.

**Keywords:** equidistant codes, symmetric designs, balanced incomplete block designs, Bruck–Ryser–Chowla theorem, Pell equation, Diophantine analysis.

## 1. Introduction

### 1.1 Equidistant codes and symmetric designs

A binary code $C \subseteq \{0,1\}^n$ is **equidistant** if there is a constant $d$ such that every pair of distinct codewords is at Hamming distance exactly $d$. Equidistant codes generalize the geometric idea of a simplex — a maximally symmetric configuration of equally spaced points — to the discrete Hamming cube, and they arise naturally in the study of Fisher-type inequalities, resolvable designs, and optimal signalling sets.

Write $\mathrm{EC}(n, d, m)$ for an equidistant binary code of length $n$, constant pairwise distance $d$, and $m$ codewords. Such a code is **optimal** when $m$ attains the maximum possible number of codewords for the given $(n,d)$. There is a classical dictionary — a staple of the coding-theory and design-theory literature — connecting optimal equidistant codes to combinatorial designs. In the regime relevant here, an optimal $\mathrm{EC}\!\left(n, \tfrac{n-2}{2}, m^*\right)$ with $n \equiv 2 \pmod 4$ is equivalent to a **symmetric block design**, i.e. a symmetric balanced incomplete block design.

### 1.2 Symmetric designs

A **$2\text{-}(v,k,\lambda)$ design** is a pair $(P, \mathcal{B})$ where $P$ is a set of $v$ **points**, $\mathcal{B}$ is a collection of $k$-element subsets called **blocks**, and every pair of distinct points lies in exactly $\lambda$ blocks. The design is **symmetric** if the number of blocks equals the number of points. For a symmetric design, standard counting yields the fundamental identity relating the parameters:

$$\lambda(v-1) = k(k-1). \tag{1.1}$$

The single most important invariant of a symmetric design is its **order**,

$$\text{order} = k - \lambda.$$

Two classical necessary conditions govern the existence of symmetric designs:

- **(Fisher / Ryser)** the parameters must satisfy (1.1) with $0 < \lambda < k < v$;
- **(Bruck–Ryser–Chowla, BRC)** if $v$ is even, then $k - \lambda$ must be a perfect square.

The BRC theorem is among the sharpest non-existence tools in design theory: for even $v$, a non-square order rules out the design outright.

### 1.3 The proposal under scrutiny

The proposal considered a two-parameter quadratic family, indexed by $u \in \mathbb{N}$:

$$v = 12u^2 + 8u + 2, \qquad k = 6u^2 + u, \qquad \lambda = \frac{k(k-1)}{v-1}, \tag{1.2}$$

asserting that (a) each triple is realized by an optimal equidistant code (equivalently, a symmetric design), and (b) the family is genuinely new. We show that claim (a) fails and give the precise Diophantine truth that survives.

### 1.4 Summary of results

1. **($\lambda$ collapse, Theorem 3.1)** The quotient in (1.2) is an exact polynomial: $\lambda = 3u^2 - u$, because $v - 1 = (2u+1)(6u+1)$ divides $k(k-1) = u(6u+1)(2u+1)(3u-1)$ exactly.
2. **(Order formula, Theorem 3.4)** $k - \lambda = u(3u+2)$.
3. **(Parity, Theorem 4.1)** $v \equiv 2 \pmod 4$; in particular $v$ is even, so BRC applies.
4. **(Pell bridge, Theorems 5.1–5.2)** $(3u+1)^2 = 3\,u(3u+2) + 1$, so the order is a perfect square iff $(3u+1, m)$ solves the Pell equation $x^2 - 3y^2 = 1$.
5. **(Obstruction, Theorem 6.1)** For $u = 1$ the order is $5$, a non-square; the symmetric $2\text{-}(22,7,2)$ design does not exist, refuting the bold claim.
6. **(Explicit members, Theorems 6.3–6.4)** $u = 2$ gives $(66,26,10)$ with order $16 = 4^2$; $u = 32$ gives order $3136 = 56^2$.
7. **(Infinitude, Theorems 7.1–7.3)** A Pell step generates infinitely many admissible parameters, the Pell-indexed sequence $u = 0, 2, 32, 450, \dots$.

## 2. Definitions and notation

Throughout, $u$ ranges over the integers (we specialize to $u \ge 0$ where positivity is needed). Define the three parameter functions

$$v(u) = 12u^2 + 8u + 2, \qquad k(u) = 6u^2 + u, \qquad \lambda(u) = 3u^2 - u.$$

We reserve the phrase "the proposed design at $u$" for the parameter triple $(v(u), k(u), \lambda(u))$. We call $u$ **admissible** when the order $u(3u+2)$ is a perfect square — the necessary condition imposed by BRC. A **Pell solution** is a pair $(x,y) \in \mathbb{Z}^2$ with $x^2 - 3y^2 = 1$.

## 3. The index collapses to a polynomial

**Theorem 3.1 ($\lambda$ collapse).** For every integer $u$, the defining relation (1.1) holds with $\lambda = 3u^2 - u$; equivalently,

$$\lambda(u)\,(v(u) - 1) = k(u)\,(k(u) - 1).$$

*Proof.* Both sides are polynomials in $u$. Expanding,

$$\lambda(u)(v(u)-1) = (3u^2 - u)(12u^2 + 8u + 1),$$
$$k(u)(k(u)-1) = (6u^2 + u)(6u^2 + u - 1).$$

Multiplying out, both equal $36u^4 + 12u^3 - 5u^2 - u$. $\quad\blacksquare$

The collapse is transparent once the two sides are factored.

**Theorem 3.2 (denominator factorization).** $v(u) - 1 = (2u+1)(6u+1)$.

*Proof.* $(2u+1)(6u+1) = 12u^2 + 8u + 1 = v(u) - 1$. $\quad\blacksquare$

**Theorem 3.3 (numerator factorization).** $k(u)\,(k(u)-1) = u(6u+1)(2u+1)(3u-1)$.

*Proof.* $k(u) = u(6u+1)$ and $k(u) - 1 = 6u^2 + u - 1 = (2u+1)(3u-1)$; multiply. $\quad\blacksquare$

Comparing Theorems 3.2 and 3.3, the factors $(2u+1)$ and $(6u+1)$ of the denominator appear intact in the numerator and cancel, leaving

$$\frac{k(u)(k(u)-1)}{v(u)-1} = u(3u-1) = 3u^2 - u = \lambda(u).$$

Thus $v-1$ divides $k(k-1)$ exactly for all $u$, and the index is genuinely integral — the family is internally consistent as candidate design parameters.

**Theorem 3.4 (order formula).** $k(u) - \lambda(u) = u(3u+2)$.

*Proof.* $(6u^2 + u) - (3u^2 - u) = 3u^2 + 2u = u(3u+2)$. $\quad\blacksquare$

## 4. The point count is even

**Theorem 4.1 (parity).** For every $u$, $v(u) \equiv 2 \pmod 4$; in particular $v(u)$ is even.

*Proof.* $v(u) = 12u^2 + 8u + 2 = 4(3u^2 + 2u) + 2$, which leaves remainder $2$ on division by $4$. $\quad\blacksquare$

Since $v$ is always even, the Bruck–Ryser–Chowla theorem applies to *every* member of the family, and demands that the order $u(3u+2)$ be a perfect square. This is the pivot on which the whole analysis turns.

## 5. The Pell bridge

**Theorem 5.1 (Pell identity).** For every integer $u$,

$$(3u+1)^2 = 3\,\big(u(3u+2)\big) + 1.$$

*Proof.* $(3u+1)^2 = 9u^2 + 6u + 1 = 3(3u^2 + 2u) + 1 = 3\,u(3u+2) + 1$. $\quad\blacksquare$

**Theorem 5.2 (square $\Leftrightarrow$ Pell).** The order $u(3u+2)$ is a perfect square if and only if $(3u+1, m)$ solves the Pell equation $x^2 - 3y^2 = 1$ for some integer $m$:

$$\big(\exists m,\ u(3u+2) = m^2\big) \iff \big(\exists m,\ (3u+1)^2 - 3m^2 = 1\big).$$

*Proof.* ($\Rightarrow$) If $u(3u+2) = m^2$, then by Theorem 5.1, $(3u+1)^2 = 3m^2 + 1$, i.e. $(3u+1)^2 - 3m^2 = 1$. ($\Leftarrow$) If $(3u+1)^2 - 3m^2 = 1$, then Theorem 5.1 gives $3\,u(3u+2) + 1 = 3m^2 + 1$, so $u(3u+2) = m^2$. $\quad\blacksquare$

The substitution $x = 3u+1$ thus converts the *quadratic* condition "order is a square" into the *Pell* condition $x^2 - 3y^2 = 1$. Because Pell solutions are rare and rigidly structured, admissibility is not a scattered arithmetic accident but a single well-ordered orbit.

## 6. The obstruction and explicit members

**Theorem 6.1 (the $u=1$ obstruction).** The equation $1\cdot(3\cdot 1 + 2) = m^2$ has no integer solution; i.e. the order $5$ at $u = 1$ is not a perfect square.

*Proof.* Suppose $m^2 = 5$. Then $|m| \le 2$ (else $m^2 \ge 9$), and $m^2 \in \{0,1,4\}$ for $|m| \le 2$, none equal to $5$. Contradiction. $\quad\blacksquare$

**Theorem 6.2 ($u = 1$ parameters).** $(v(1), k(1), \lambda(1)) = (22, 7, 2)$.

*Proof.* Direct substitution. $\quad\blacksquare$

**Corollary 6.2$'$.** No symmetric $2\text{-}(22,7,2)$ design exists, and hence no optimal equidistant code with these parameters. Indeed $v = 22$ is even and the order $k - \lambda = 5$ is not a perfect square, so Bruck–Ryser–Chowla forbids the design. This refutes the bold existence hypothesis at its smallest non-trivial instance.

**Theorem 6.3 (first non-trivial admissible member, $u=2$).** $(v(2), k(2), \lambda(2)) = (66, 26, 10)$, the order is $2\cdot 8 = 16 = 4^2$, and $(x,y) = (7,4)$ solves $x^2 - 3y^2 = 1$ (since $49 - 48 = 1$).

*Proof.* Direct computation. $\quad\blacksquare$

**Theorem 6.4 (second non-trivial admissible member, $u=32$).** The order is $32 \cdot 98 = 3136 = 56^2$, and $(97, 56)$ solves the Pell equation (since $9409 - 9408 = 1$).

*Proof.* Direct computation. $\quad\blacksquare$

We stress that passing BRC (i.e. being admissible) is *necessary* but not known to be *sufficient*: whether $(66, 26, 10)$ and the larger members correspond to genuine symmetric designs is a separate existence question requiring finer invariants.

## 7. Infinitely many admissible parameters

**Theorem 7.1 (Pell step).** If $(x, y)$ solves $x^2 - 3y^2 = 1$, then so does $(2x + 3y,\ x + 2y)$.

*Proof.*
$$(2x+3y)^2 - 3(x+2y)^2 = (4x^2 + 12xy + 9y^2) - 3(x^2 + 4xy + 4y^2) = x^2 - 3y^2 = 1. \quad\blacksquare$$

Translating the Pell step through $x = 3u+1$ gives an *admissibility step* on the parameter $u$ itself.

**Theorem 7.2 (admissibility step).** Suppose $u \ge 0$, $m \ge 1$, and $(3u+1)^2 - 3m^2 = 1$. Set

$$u' = 7u + 4m + 2, \qquad m' = 12u + 7m + 4.$$

Then $(3u'+1)^2 - 3(m')^2 = 1$ and $u' > u$.

*Proof.* A direct expansion using $(3u+1)^2 - 3m^2 = 1$ verifies $(3u'+1)^2 - 3(m')^2 = 1$; the substitution corresponds to applying the Pell step (Theorem 7.1) and preserves $x \equiv 1 \pmod 3$. The inequality $u' = 7u + 4m + 2 > u$ is immediate from $u \ge 0$, $m \ge 1$. $\quad\blacksquare$

**Theorem 7.3 (infinitude).** For every bound $N$ there exists an admissible parameter $u > N$; concretely, there exist $u, m$ with $N < u$, $0 \le u$, $1 \le m$, and $(3u+1)^2 - 3m^2 = 1$. The admissible $u$ form the infinite Pell-indexed sequence $0, 2, 32, 450, 6272, \dots$.

*Proof.* Start from the base admissible pair $(u_0, m_0) = (2, 4)$, which satisfies $(3\cdot 2+1)^2 - 3\cdot 4^2 = 49 - 48 = 1$. Iterating the admissibility step (Theorem 7.2) produces a strictly increasing sequence of admissible parameters, each satisfying the Pell equation. Since each step increases $u$ by at least $1$, after finitely many steps $u$ exceeds any given $N$. $\quad\blacksquare$

**Remark 7.4 (recurrences).** The admissible indices satisfy the second-order linear recurrence

$$u_{n+1} = 14\,u_n - u_{n-1} + 4, \qquad u_0 = 0,\ u_1 = 2,$$

and the corresponding order roots $m_n$ (with $u_n(3u_n+2) = m_n^2$) satisfy

$$m_{n+1} = 14\,m_n - m_{n-1}, \qquad m_0 = 0,\ m_1 = 4.$$

Both recurrences are inherited from the companion recurrence of the fundamental Pell automorphism $(x,y) \mapsto (2x+3y, x+2y)$ (whose square has trace $14$), because $u_n$ and $m_n$ are linear images of a single Pell orbit.

## 8. Discussion

The proposal made two assertions: existence *for all $u$*, and novelty. The first is false — decisively, at $u = 1$. But the manner of failure is illuminating. The linear substitution $x = 3u+1$ transforms the "order is a perfect square" condition into the Pell equation $x^2 - 3y^2 = 1$, and Pell equations have rare, geometrically structured solution sets. The correct statement is therefore not an existence theorem but a **Diophantine characterization**: BRC-admissibility holds precisely along the Pell orbit $u = 0, 2, 32, 450, \dots$.

Two structural lessons emerge. First, quotient parameters like $\lambda = k(k-1)/(v-1)$ should always be simplified before drawing conclusions; here the fraction hid a clean polynomial and, ultimately, a clean order formula $u(3u+2)$. Second, BRC-admissibility is *necessary but not sufficient*: the Pell orbit is, in effect, engineered to produce exactly the perfect squares BRC requires, so genuine existence for the surviving members must be settled by finer combinatorial or spectral invariants, not the square test.

## 9. Future work

- **Exactness of the orbit.** Prove that the admissible index set is *exactly* the single Pell orbit $\{(x-1)/3 : x^2 - 3y^2 = 1,\ x \equiv 1 \pmod 3\}$, with no stray admissible values outside it.
- **Beyond BRC.** Determine, for each surviving member $(66,26,10)$, the $u = 32$ member, and their Pell successors, whether a symmetric design actually exists, using multiplier theorems, eigenvalue/Fisher constraints, or explicit construction / non-existence certificates.
- **Generalization.** Investigate whether analogous two-parameter quadratic families of symmetric-design parameters arising from optimal equidistant codes for $n \equiv 2 \pmod 4$ all reduce, via a linear substitution, to a Pell or Pell-like obstruction.

## References

1. R. C. Bose, *A note on Fisher's inequality for balanced incomplete block designs*.
2. R. H. Bruck, H. J. Ryser, and S. Chowla, *On the non-existence of certain finite projective planes and symmetric block designs*.
3. J. H. van Lint, *Introduction to Coding Theory* (equidistant codes, Fisher-type bounds, and the design–code dictionary).
4. R. Mathon and A. Rosa, tables of symmetric designs and admissible parameters.
5. Surveys of equidistant codes and their equivalence with symmetric designs.
