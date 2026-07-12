# The Periodic Table as a Spectrum: Elements as Eigenvalues of a Self-Adjoint Operator

## Abstract

The periodic table orders the chemical elements by atomic number $Z$, the
integer charge of the nucleus. We recast this ordering spectrally. On the
$n$-dimensional real Hilbert space of coordinate lists we define a single
self-adjoint operator — the *nuclear Hamiltonian* $H_n$ — as the diagonal
operator whose entries are the atomic numbers $1, 2, \dots, n$. We prove that
$H_n$ is a genuine quantum observable (self-adjoint) and that its spectrum is
*exactly* the set of atomic numbers, with both inclusions established: every
atomic number is an eigenvalue, and every eigenvalue is an atomic number. We then
develop the operator's spectral invariants and show that each one recovers a
classical arithmetic identity: the trace equals the Gauss triangular number
$n(n+1)/2$; the determinant equals $n!$; the characteristic polynomial factors
into linear terms rooted at the atomic numbers; and, most generally, the trace of
the $k$-th power of $H_n$ equals the $k$-th power sum $\sum_i z_i^{\,k}$, a full
power-sum ladder of which the trace identity is the first rung. The result is a
clean cross-domain bridge between spectral/linear algebra and elementary number
theory, packaged around a physically motivated reinterpretation of the periodic
table. We conclude with several natural extensions: off-diagonal (Jacobi)
couplings and interlacing, infinite-dimensional and unbounded formulations,
isotope-weighted multiplicities, and spectral zeta/heat-trace invariants.

**Keywords:** self-adjoint operator, spectrum, eigenvalue, trace, determinant,
characteristic polynomial, triangular number, factorial, power sums, periodic
table.

---

## 1. Introduction

The periodic table is organized by the atomic number $Z$: the count of protons
in a nucleus. Since Moseley's X-ray experiments in 1913, $Z$ has been understood
as the true ordinal of an element, superseding atomic weight. Yet $Z$ is, in the
end, a *label* — an integer index attached to a physical species.

The purpose of this paper is to argue, and to prove, that the atomic numbers are
better understood not as primitive labels but as the **spectrum** of a single
operator. In quantum mechanics an observable is a self-adjoint operator, and the
values it can return upon measurement are exactly its eigenvalues. We show that
there is a natural self-adjoint operator whose set of eigenvalues is precisely
the atomic numbers of the first $n$ elements. In this sense the periodic table
*is* a spectrum.

The construction is deliberately minimal: we take the diagonal operator with the
atomic numbers on the diagonal. What is interesting is not the construction but
its consequences. Because the object is an operator, it carries the full battery
of spectral invariants — trace, determinant, characteristic polynomial, and the
higher spectral moments (power-sum traces). We prove that each of these
invariants coincides with a classical object of elementary number theory:
triangular numbers, factorials, and power sums. The periodic table thereby
becomes a dictionary translating spectral quantities into arithmetic ones.

The contribution is threefold:

1. **A faithful spectral realization** of the periodic table: an explicit
   self-adjoint operator whose spectrum equals the set of atomic numbers, with
   both inclusions rigorously established (Section 3).
2. **A family of spectral–arithmetic bridges** identifying the trace with the
   triangular number, the determinant with the factorial, the characteristic
   polynomial with a product of linear factors, and the $k$-th power trace with
   the $k$-th power sum (Section 4).
3. **A program of extensions** turning the reframing into a research direction:
   couplings and interlacing, infinite dimensions, isotope multiplicities, and
   spectral zeta/heat-trace invariants (Section 6).

---

## 2. Definitions and Setup

Throughout, $n$ is a fixed nonnegative integer (the number of elements under
consideration), and we work over the real numbers. We index elements by
$i \in \{0, 1, \dots, n-1\}$ (a zero-based index), and use a one-based atomic
number.

### 2.1 The state space

Let $V_n = \mathbb{R}^n$ be the space of real coordinate lists of length $n$,
regarded as a finite-dimensional real Hilbert space with the standard inner
product. We think of $V_n$ as the state space of a system with $n$ available
slots, one per element. The standard basis vectors $e_0, \dots, e_{n-1}$
(with $e_i$ equal to $1$ in coordinate $i$ and $0$ elsewhere) are the "single
slot" states.

### 2.2 Atomic numbers

> **Definition 2.1 (Atomic number).** The atomic number of the $i$-th element is
> the real scalar
> $$z_i \;=\; i + 1, \qquad i \in \{0, \dots, n-1\},$$
> so that $z_0 = 1, z_1 = 2, \dots, z_{n-1} = n$.

### 2.3 The nuclear Hamiltonian

> **Definition 2.2 (Nuclear Hamiltonian).** The *nuclear Hamiltonian* is the
> diagonal operator
> $$H_n \;=\; \operatorname{diag}(z_0, z_1, \dots, z_{n-1}) \;=\;
> \operatorname{diag}(1, 2, \dots, n)$$
> acting on $V_n$. Explicitly, $(H_n x)_i = z_i\, x_i$ for every state $x \in V_n$
> and every index $i$.

As a matrix, $H_n$ has $(i,i)$-entry $z_i$ and all off-diagonal entries $0$. As a
linear map it acts coordinatewise by scaling.

### 2.4 Eigenvalues and spectrum

Recall that $\mu \in \mathbb{R}$ is an **eigenvalue** of a linear operator $T$ on
$V_n$ if there exists a nonzero vector $x$ (an **eigenvector**, or eigenstate)
with $Tx = \mu x$. The **spectrum** of $T$ is the set of its eigenvalues,
$\sigma(T) = \{\mu \in \mathbb{R} : \mu \text{ is an eigenvalue of } T\}$. (In
finite dimensions the spectrum coincides with the set of eigenvalues; there is no
continuous or residual part.)

---

## 3. The Spectrum Is the Periodic Table

We now establish the central claim in three steps: $H_n$ is a legitimate
observable; every atomic number lies in its spectrum; and nothing else does.

### 3.1 Self-adjointness

> **Theorem 3.1 (Observable).** The nuclear Hamiltonian $H_n$ is self-adjoint:
> $H_n^{*} = H_n$.

*Proof.* A diagonal matrix with real diagonal entries equals its own conjugate
transpose, because transposition fixes diagonal entries and the entries are real
so conjugation fixes them too. Hence $H_n^{*} = H_n$. $\qquad\blacksquare$

Self-adjointness is the abstract guarantee that all measured values are real and
that the operator possesses a complete orthonormal eigenbasis — precisely the
properties required of a physical observable.

### 3.2 Every atomic number is an eigenvalue

> **Theorem 3.2 (Elements are spectral lines).** For each index $i$, the atomic
> number $z_i$ is an eigenvalue of $H_n$, with eigenstate the standard basis
> vector $e_i$.

*Proof.* Compute $H_n e_i$ coordinatewise. For coordinate $j$,
$(H_n e_i)_j = z_j (e_i)_j$. If $j = i$ this equals $z_i \cdot 1 = z_i$; if
$j \ne i$ it equals $z_j \cdot 0 = 0$. Hence $H_n e_i = z_i\, e_i$. Since
$e_i \ne 0$, $z_i$ is an eigenvalue with eigenvector $e_i$. $\qquad\blacksquare$

### 3.3 Every eigenvalue is an atomic number

> **Theorem 3.3 (No ghost eigenvalues).** If $\mu$ is an eigenvalue of $H_n$,
> then $\mu = z_j$ for some index $j$.

*Proof.* Let $x \ne 0$ satisfy $H_n x = \mu x$. Since $x \ne 0$, some coordinate
$x_j$ is nonzero. Reading off coordinate $j$ of the eigenvalue equation gives
$z_j\, x_j = \mu\, x_j$. Because $x_j \ne 0$ we may cancel it (working over a
field), obtaining $\mu = z_j$. $\qquad\blacksquare$

### 3.4 The spectral realization

Combining Theorems 3.2 and 3.3 yields the headline result.

> **Theorem 3.4 (The periodic table is a spectrum).** The spectrum of the nuclear
> Hamiltonian equals the set of atomic numbers:
> $$\sigma(H_n) \;=\; \{\, z_i : 0 \le i < n \,\}.$$

*Proof.* The inclusion $\supseteq$ is Theorem 3.2; the inclusion $\subseteq$ is
Theorem 3.3. $\qquad\blacksquare$

Finally we identify this set concretely.

> **Proposition 3.5 (The eigenvalues are the integers $1, \dots, n$).**
> $$\{\, z_i : 0 \le i < n \,\} \;=\; \{\, k \in \mathbb{Z} : 1 \le k \le n \,\}.$$

*Proof.* As $i$ ranges over $\{0, \dots, n-1\}$, the value $z_i = i+1$ ranges over
$\{1, \dots, n\}$ bijectively. Conversely, any integer $k$ with $1 \le k \le n$
equals $z_{k-1}$. $\qquad\blacksquare$

Thus $H_n$ is a self-adjoint operator whose spectrum is *exactly* the atomic
numbers $1, 2, \dots, n$ — the periodic table, realized as a measurement.

---

## 4. Spectral–Arithmetic Bridges

We now harvest the operator's invariants. Each is a standard construction of
linear algebra; the point is that each *evaluates* to a classical arithmetic
object.

### 4.1 Trace and the triangular number

The trace of an operator is the sum of its diagonal entries, and equals the sum
of its eigenvalues (with multiplicity). For $H_n$ these coincide with the atomic
numbers.

> **Theorem 4.1 (Trace–triangular bridge).**
> $$\operatorname{tr}(H_n) \;=\; \sum_{i=0}^{n-1} z_i \;=\; 1 + 2 + \cdots + n
> \;=\; \frac{n(n+1)}{2}.$$

*Proof.* The trace of a diagonal matrix is the sum of its diagonal entries, i.e.
$\sum_i z_i$. This is the arithmetic series $\sum_{k=1}^n k$, which evaluates to
$n(n+1)/2$ by induction on $n$: the base case $n=0$ gives $0$, and the inductive
step adds $(k+1)$ to $k(k+1)/2$, yielding $(k+1)(k+2)/2$. $\qquad\blacksquare$

The right-hand side is the $n$-th *triangular number*, the count of dots in a
triangular array with $n$ rows.

### 4.2 Determinant and the factorial

The determinant of an operator is the product of its eigenvalues (with
multiplicity).

> **Theorem 4.2 (Determinant–factorial bridge).**
> $$\det(H_n) \;=\; \prod_{i=0}^{n-1} z_i \;=\; 1 \cdot 2 \cdots n \;=\; n!.$$

*Proof.* The determinant of a diagonal matrix is the product of its diagonal
entries, $\prod_i z_i = \prod_{k=1}^n k$. This equals $n!$ by induction: the base
case $n=0$ gives the empty product $1 = 0!$, and the inductive step multiplies
$k!$ by $(k+1)$ to give $(k+1)!$. $\qquad\blacksquare$

### 4.3 The characteristic polynomial

> **Theorem 4.3 (Characteristic polynomial factorization).** The characteristic
> polynomial of $H_n$ factors completely into linear terms rooted at the atomic
> numbers:
> $$\chi_{H_n}(X) \;=\; \det(X\,I - H_n) \;=\; \prod_{i=0}^{n-1} \big(X - z_i\big)
> \;=\; \prod_{k=1}^{n} (X - k).$$

*Proof.* The characteristic polynomial of a diagonal matrix is the product over
its diagonal entries of $(X - \text{entry})$, since $X I - H_n$ is diagonal with
entries $X - z_i$ and the determinant of a diagonal matrix is the product of the
diagonal. The roots are exactly the $z_i$, consistent with Theorem 3.4.
$\qquad\blacksquare$

The characteristic polynomial is the generating fingerprint whose roots recover
the entire spectrum; here it literally spells out the periodic table one factor
at a time. Its expanded coefficients are (up to sign) the elementary symmetric
polynomials of $1, \dots, n$ — the unsigned Stirling numbers of the first kind.

### 4.4 The power-sum ladder

The trace bridge (Theorem 4.1) generalizes to an infinite ladder indexed by an
exponent $k$. For a diagonal operator, powers act diagonally: $H_n^{\,k}$ is the
diagonal operator with entries $z_i^{\,k}$.

> **Theorem 4.4 (Power-sum ladder).** For every nonnegative integer $k$,
> $$\operatorname{tr}\big(H_n^{\,k}\big) \;=\; \sum_{i=0}^{n-1} z_i^{\,k}
> \;=\; 1^k + 2^k + \cdots + n^k.$$

*Proof.* Since $H_n = \operatorname{diag}(z_i)$ is diagonal, its $k$-th power is
the diagonal operator $\operatorname{diag}(z_i^{\,k})$. The trace of this diagonal
operator is $\sum_i z_i^{\,k}$. $\qquad\blacksquare$

The specializations are the classical summation formulas:

| $k$ | $\operatorname{tr}(H_n^{\,k}) = \sum_{k'=1}^n (k')^{k}$ | closed form |
|-----|--------------------------------------------------------|-------------|
| $0$ | $\sum 1$ | $n$ |
| $1$ | $\sum k'$ | $\dfrac{n(n+1)}{2}$ |
| $2$ | $\sum (k')^2$ | $\dfrac{n(n+1)(2n+1)}{6}$ |
| $3$ | $\sum (k')^3$ | $\left(\dfrac{n(n+1)}{2}\right)^2$ |

Thus a single operator generates an entire family of number-theoretic identities
through its spectral moments. The moments (power sums) and the coefficients of
$\chi_{H_n}$ (elementary symmetric polynomials) are linked by **Newton's
identities**, closing the loop between the two families of invariants.

---

## 5. Algorithms

The results are constructive and immediately computable. We record the key
procedures; full type-hinted implementations accompany this paper.

### 5.1 Assemble the nuclear Hamiltonian

Given $n$, produce the $n \times n$ diagonal matrix with entries $1, \dots, n$.
Complexity: $O(n^2)$ to materialize the dense matrix (or $O(n)$ if stored as a
diagonal vector).

### 5.2 Verify the spectrum

Compute the eigenvalues of the assembled matrix numerically and compare (up to
sorting and floating-point tolerance) against $\{1, \dots, n\}$. For the diagonal
matrix the eigenvalues are read directly off the diagonal, giving a self-checking
oracle: the numerical eigensolver output must match the diagonal.

### 5.3 Spectral invariants versus closed forms

Compute the trace, determinant, and $k$-th power traces numerically and compare
against the closed forms $n(n+1)/2$, $n!$, and $\sum_{k'=1}^n (k')^k$
respectively. Compute the characteristic polynomial and verify its roots are
$1, \dots, n$ and its coefficients are the (signed) elementary symmetric
polynomials.

### 5.4 Newton's identities check

From the power sums $p_1, \dots, p_n$ recover the elementary symmetric
polynomials $e_1, \dots, e_n$ via Newton's recursion
$$e_k = \frac{1}{k}\sum_{j=1}^{k} (-1)^{j-1} e_{k-j}\, p_j,$$
and confirm that the resulting $e_k$ match the coefficients of $\chi_{H_n}$. This
verifies numerically that the two families of invariants determine each other.

---

## 6. Extensions and Future Directions

The value of the spectral reframing is that it exports the periodic table into
spectral theory, where a large toolbox awaits. We list the natural extensions.

1. **Complex / infinite dimensional.** Move from $\mathbb{R}^n$ to a separable
   Hilbert space and treat the operator as a (possibly unbounded) self-adjoint
   operator, recovering the spectrum as a closed subset of $\mathbb{R}$.

2. **Non-diagonal Hamiltonians.** Add off-diagonal "coupling" terms (e.g. a
   tridiagonal Jacobi matrix) and study how the spectrum deforms; prove
   interlacing (Cauchy) bounds relating the perturbed spectrum to the atomic
   numbers.

3. **Isotope multiplicities.** Weight each eigenvalue by the number of stable
   isotopes, giving a self-adjoint operator on a space whose dimension is the
   total isotope count, and connect the trace to observed isotope statistics.

4. **Spectral zeta / partition function.** Study $\sum_i z_i^{-s}$ and
   $\sum_i \exp(-\beta z_i)$ (the heat trace), linking to $\zeta$-values and to
   the thermodynamics of the model.

5. **Power-sum invariants.** The power-sum ladder is realized by Theorem 4.4
   ($\operatorname{tr}(H_n^{\,k}) = \sum_i z_i^{\,k}$). A natural next step is to
   connect these power sums back to the elementary symmetric functions (trace,
   $\dots$, determinant) via Newton's identities, closing the loop between the
   spectral moments and the coefficients of the characteristic polynomial.

---

## 7. Discussion

The construction is intentionally minimal, and this is a feature. By taking the
simplest operator whose spectrum is the atomic numbers — the diagonal one — we
isolate exactly what is intrinsic to the periodic table (its ordered set of
integer labels) from what is a modeling choice (couplings, dynamics). Everything
proved here is a theorem about *that intrinsic content*, phrased in the language
of operators.

Two lessons emerge. First, the periodic table's arithmetic is spectral: Gauss's
triangular number, the factorial, the sum-of-powers formulas, and the elementary
symmetric polynomials are not incidental facts *about* the elements but
*invariants of a single observable* whose spectrum is the elements. Second, the
reframing is generative: each entry in Section 6 is a well-posed problem that
would not be visible if one insisted on reading the periodic table as a static
list.

None of the results depends on the physical interpretation; the mathematics is a
clean bridge between spectral/linear algebra and elementary number theory. The
periodic-table framing supplies the motivation and the naming, and points toward
the physically richer extensions (couplings, isotopes, thermodynamics) where the
model could make contact with data.

---

## 8. Conclusion

We defined a self-adjoint nuclear Hamiltonian whose spectrum is exactly the
atomic numbers $1, \dots, n$, and we showed that its principal spectral
invariants recover classical arithmetic: the trace is the triangular number, the
determinant is the factorial, the characteristic polynomial factors over the
atomic numbers, and the $k$-th power trace is the $k$-th power sum. The periodic
table, read this way, is not a list of integers but the spectrum of an operator —
and its familiar arithmetic is that operator's spectral shadow.
