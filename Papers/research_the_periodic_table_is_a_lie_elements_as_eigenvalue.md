# Shell Structure as Spectral Degeneracy: Closed Shells and Magic Numbers as Cumulative Eigenvalue Multiplicities

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

We develop a spectral reading of the shell structure underlying both the
electronic periodic table and the nuclear shell model. The unifying
principle is that a shell-structured Hamiltonian is, in an appropriate
basis, a *diagonal operator*, so that the "elements" — closed shells,
noble-gas configurations, and nuclear magic numbers — are exactly the
*cumulative degeneracies of its eigenvalues*. We treat two shell models
side by side. For the hydrogenic (Coulomb) model, the $n$-th shell has
degeneracy $2n^2$, arising from the angular-momentum sum rule
$\sum_{l=0}^{n-1}(2l+1)=n^2$ and spin doubling; the cumulative fillings
$2,10,28,60,110,\dots$ obey the closed form $3\sum_{k=1}^{n}2k^2 =
n(n+1)(2n+1)$. For the isotropic three-dimensional harmonic-oscillator
(nuclear) model, level $N$ has degeneracy $(N+1)(N+2)$, and the
cumulative fillings $2,8,20,40,70,112,\dots$ obey $3\sum_{N=0}^{n}
(N+1)(N+2)=(n+1)(n+2)(n+3)$; the first three, $2,8,20$, are exactly the
first three nuclear magic numbers. We prove both filling sequences are
strictly increasing, and we make the spectral picture literal: placing
shell energies on the diagonal of a Hermitian matrix, we exhibit each
standard basis vector as an eigenvector with the corresponding shell
energy as eigenvalue, and identify the trace with the total shell
energy. We close by analyzing precisely where each model diverges from
empirical data — the Madelung $(n+l)$ ordering for electrons and
spin–orbit splitting for nuclei — showing these are reorderings and
perturbations of the same spectra rather than new phenomena.

## 1. Introduction

The periodic table arranges the chemical elements by atomic number $Z$,
the nuclear charge. Its most striking feature is not that the elements
form a list but that chemical behaviour *recurs periodically*: the
noble gases, the alkali metals, and the halogens each reappear at regular
intervals. Periodicity of this kind is the hallmark of an underlying
eigenvalue problem. In quantum mechanics the allowed energies of a
bound particle are the eigenvalues of a self-adjoint Hamiltonian, and
degeneracies — several independent states sharing one energy — organize
those eigenvalues into *shells*.

The central thesis of this paper is that **shell structure is
degeneracy structure**: the closed-shell numbers (noble gases for
electrons, magic numbers for nucleons) are cumulative sums of the
degeneracies of a shell Hamiltonian's eigenvalues. We formalize this for
two canonical models and show that in each case the entire "table" is
encoded in a single cubic polynomial, obtained by summing a quadratic
degeneracy law. We then render the picture concretely by exhibiting a
diagonal Hermitian Hamiltonian whose eigenvectors are standard basis
vectors and whose eigenvalues are the shell energies. Finally we give a
careful account of the models' validity: the mathematics is exact, while
the identification with observed atomic and mass numbers is
model-dependent and fails at precise, physically meaningful places.

## 2. Definitions

Throughout, $n, N, k, l, m$ denote non-negative integers, and sums over
$l \in \{0,\dots,n-1\}$ are written $\sum_{l<n}$.

**Definition 2.1 (Angular count).** The number of magnetic sublevels
summed over the sub-shells $l = 0, \dots, n-1$ is
$$A(n) := \sum_{l < n} (2l + 1).$$
Physically, $A(n)$ counts the distinct spatial orientations of angular
momentum available in the first $n$ sub-shells; each $l$ contributes the
$2l+1$ magnetic quantum numbers $m \in \{-l, \dots, l\}$.

**Definition 2.2 (Coulomb shell degeneracy).** The degeneracy of the
$n$-th hydrogenic shell, including the factor of two for electron spin,
is
$$D(n) := 2n^2.$$

**Definition 2.3 (Coulomb cumulative filling).** The number of electrons
filling the first $n$ Coulomb shells is
$$F(n) := \sum_{k < n} D(k+1) = \sum_{k=1}^{n} 2k^2.$$

**Definition 2.4 (Oscillator level degeneracy).** The degeneracy of the
$N$-th level of the isotropic three-dimensional harmonic oscillator is
$$d(N) := (N+1)(N+2).$$

**Definition 2.5 (Oscillator cumulative filling).** The number of
particles filling oscillator levels $0$ through $n$ is
$$G(n) := \sum_{N=0}^{n} (N+1)(N+2).$$

**Definition 2.6 (Diagonal shell Hamiltonian).** Given shell energies
$E_0, \dots, E_{d-1} \in \mathbb{R}$, the associated shell Hamiltonian is
the $d \times d$ matrix $H$ with $H_{jj} = E_j$ and $H_{ij} = 0$ for
$i \neq j$.

## 3. Main results

### 3.1 The angular-momentum sum rule and spin doubling

**Theorem 3.1 (Angular-momentum sum rule).** For every $n$,
$$A(n) = \sum_{l < n} (2l+1) = n^2.$$

*Proof sketch.* Induction on $n$. For $n=0$ the empty sum is $0 = 0^2$.
Assuming $A(n) = n^2$, the sub-shell $l = n$ contributes $2n+1$, so
$A(n+1) = n^2 + (2n+1) = (n+1)^2$. $\square$

**Theorem 3.2 (Spin doubling).** For every $n$, $D(n) = 2\,A(n)$; that
is, $2n^2 = 2\sum_{l<n}(2l+1)$.

*Proof sketch.* Immediate from Definition 2.2 and Theorem 3.1. $\square$

Thus the Coulomb shell degeneracies are $D(1),D(2),\dots = 2,8,18,32,\dots$,
the idealized row lengths of the periodic table.

### 3.2 Closed form for the Coulomb fillings

**Theorem 3.3 (Coulomb filling recurrence).** For every $n$,
$$F(n+1) = F(n) + 2(n+1)^2.$$

*Proof sketch.* The last term of the sum defining $F(n+1)$ is
$D(n+1) = 2(n+1)^2$. $\square$

**Theorem 3.4 (Closed form for Coulomb fillings).** For every $n$,
$$3\,F(n) = n(n+1)(2n+1).$$
Equivalently $F(n) = \tfrac{1}{3}n(n+1)(2n+1)$, giving
$F(1),\dots,F(5) = 2, 10, 28, 60, 110$.

*Proof sketch.* Induction on $n$ using Theorem 3.3; the inductive step
reduces to the polynomial identity
$n(n+1)(2n+1) + 3\cdot 2(n+1)^2 = (n+1)(n+2)(2n+3)$, verified by
expansion. $\square$

**Theorem 3.5 (Strict monotonicity of Coulomb fillings).** The map
$n \mapsto F(n)$ is strictly increasing.

*Proof sketch.* By Theorem 3.3, $F(n+1) - F(n) = 2(n+1)^2 > 0$, and a
sequence with strictly positive successive differences is strictly
increasing. $\square$

Monotonicity guarantees the closed shells are distinct and well-ordered:
no two Coulomb shells ever close at the same electron count.

### 3.3 Closed form for the oscillator fillings

**Theorem 3.6 (Closed form for oscillator fillings).** For every $n$,
$$3\,G(n) = (n+1)(n+2)(n+3).$$
Equivalently $G(n) = \tfrac{1}{3}(n+1)(n+2)(n+3)$, giving
$G(0),\dots,G(5) = 2, 8, 20, 40, 70, 112$.

*Proof sketch.* Induction on $n$. The base case $G(0) = 1\cdot 2 = 2$ and
$3\cdot 2 = 1\cdot 2\cdot 3$. The inductive step adds
$d(n+1) = (n+2)(n+3)$ and uses
$(n+1)(n+2)(n+3) + 3(n+2)(n+3) = (n+2)(n+3)(n+4)$. $\square$

**Theorem 3.7 (Strict monotonicity of oscillator fillings).** The map
$n \mapsto G(n)$ is strictly increasing.

*Proof sketch.* $G(n+1) - G(n) = (n+2)(n+3) > 0$. $\square$

The first three values $G(0), G(1), G(2) = 2, 8, 20$ coincide with the
first three empirical nuclear magic numbers. Moreover $F(1) = G(0) = 2$:
both models agree on the very first closed shell (helium; the $Z=2$
magic number).

### 3.4 Elements as eigenvalues: the diagonal spectrum

**Theorem 3.8 (Self-adjointness).** The shell Hamiltonian $H$ of
Definition 2.6 is Hermitian: $H^{\dagger} = H$.

*Proof sketch.* A real diagonal matrix equals its conjugate transpose
entrywise. $\square$

**Theorem 3.9 (Basis vectors are eigenvectors).** For each index $j$,
the standard basis vector $e_j$ satisfies $H e_j = E_j\, e_j$; hence
$e_j$ is an eigenvector of $H$ with eigenvalue $E_j$, the $j$-th shell
energy.

*Proof sketch.* The $i$-th component of $H e_j$ is $\sum_k H_{ik}(e_j)_k
= H_{ij} = E_j\,\delta_{ij}$, which is the $i$-th component of
$E_j e_j$. $\square$

**Theorem 3.10 (Trace is total shell energy).** The trace of $H$ equals
the total shell energy: $\operatorname{tr} H = \sum_{j} E_j$.

*Proof sketch.* The trace is the sum of diagonal entries, and
$H_{jj} = E_j$. $\square$

Because the trace is invariant under change of orthonormal basis,
$\sum_j E_j$ is a conserved bookkeeping invariant of the configuration —
a *sum rule* independent of representation. Theorems 3.8–3.10 make the
slogan "elements are eigenvalues" literal: a configuration is read off
from the spectrum and multiplicities of a self-adjoint operator.

### 3.5 The subshell count as magnetic quantum numbers

The integer $2l+1$ summed in Definition 2.1 is not an abstract weight:
it is the cardinality of the set of magnetic quantum numbers
$\{-l, -l+1, \dots, l\}$. Each such $m$ indexes an azimuthal
eigenfunction $\phi_m(\theta) = e^{i m \theta}$, which is $2\pi$-periodic
in the angle $\theta$ precisely because $m$ is an integer. Thus the
degeneracy factor $2l+1$ that drives the entire shell-filling arithmetic
is the count of admissible, single-valued angular wavefunctions at
angular momentum $l$ — grounding the combinatorics in the geometry of
the sphere.

## 4. Algorithms

We summarize the computational content in three algorithms.

**Algorithm 1 (Closed-shell generator).** Given a degeneracy law
$d(k) = ak^2 + bk + c$ with $a > 0$, compute the cumulative fillings
$F(n) = \sum_{k \le n} d(k)$ for $n = 0, \dots, M$. Because the running
sum of a quadratic is a cubic, this runs in $O(M)$ arithmetic
operations, and each $F(n)$ can alternatively be evaluated in $O(1)$
from the closed-form cubic.

**Algorithm 2 (Woods–Saxon eigenvalue solver).** Discretize the radial
Schrödinger equation for a realistic nuclear mean-field potential
$V(r) = -V_0 / (1 + e^{(r-R)/a})$ on a grid, assemble the tridiagonal
Hamiltonian for each angular momentum $l$, and diagonalize. Collecting
eigenvalues across $l$ and sorting by energy reproduces the shell
ordering; the degeneracy $2(2l+1)$ of each level, accumulated, yields the
predicted closed shells. Complexity is $O(P^3)$ per angular channel for a
grid of $P$ points.

**Algorithm 3 (Diagonal spectrum reader).** Given shell energies
$E_0, \dots, E_{d-1}$, build the diagonal Hamiltonian $H$, verify
$He_j = E_j e_j$ for each $j$, and report the trace $\sum_j E_j$. This is
$O(d)$ and provides an executable witness of Theorems 3.8–3.10.

## 5. Applications

**Unification of two classification schemes.** The same summation
principle produces the electronic periodic table skeleton and the
nuclear magic numbers, exhibiting chemistry and nuclear stability as two
instances of one spectral bookkeeping law.

**Compression of the table.** A quadratic degeneracy law is three
numbers $(a,b,c)$; the entire cumulative filling sequence follows as a
cubic. This replaces a memorized list of closed-shell numbers with a
generating polynomial.

**Diagnostic value of failure.** The precise points where each model
diverges from data localize the missing physics: past $Z=10$ for the
Coulomb table (Madelung ordering) and past $20$ for the oscillator
(spin–orbit splitting).

## 6. Discussion

Both models are exact as mathematics and heuristic as physics. The
Coulomb fillings $2,10,28,60,110$ are the correct cumulative
degeneracies of an $n^2$-degenerate spectrum but are *not* the observed
noble gases $2,10,18,36,\dots$. Real electron filling follows the
Madelung rule — orbitals fill in order of increasing $n+l$, ties broken
by increasing $n$ — which is a *reordering* of the same eigenvalues, not
a new spectrum. The first deviation occurs exactly past $Z=10$, where
$(n+l)$ ordering first overtakes pure $n$ ordering.

The oscillator fillings $2,8,20,40,70,112$ reproduce the first three
magic numbers and then overshoot: the empirical values are
$2,8,20,28,50,82,126$. The discrepancy is resolved by adding a diagonal
spin–orbit term $\xi\, \mathbf{l}\cdot\mathbf{s}$, which splits each
level's sublevels and lowers the highest-$j$ sublevel into the shell
below, converting $40,70$ into $28,50$. The islands of stability are
therefore a *perturbed* spectrum, not an independent phenomenon.

The honest reading is that the theorems — sum rules, cubic fillings,
strict monotonicity, and the diagonal spectrum — are exact, while the
identification with real atomic and mass numbers is model-dependent.
Even so, the framework's predictive successes ($2,8,20$; the row lengths
$2,8,18,32$) and its precisely located failures make it a productive lens
rather than a mere analogy.

## 7. Future directions

**A two-parameter family of periodic tables.** For every affine-quadratic
degeneracy law $d(k) = ak^2 + bk + c$ with $a>0$, the cumulative filling
$F(n) = \sum_{k\le n} d(k)$ is a cubic polynomial, and $(a,b,c)$ is
uniquely recoverable from any four consecutive fillings. Each admissible
triple names a distinct shell table; the Coulomb and oscillator tables
are two lattice points in this space.

**Spin–orbit as a rank-one spectral perturbation.** Adding a diagonal
spin–orbit term to the isotropic oscillator should shift the fillings
$2,8,20,40,70,112$ to the empirical magic numbers
$2,8,20,28,50,82,126$, with the shifts equal to the partial sums of the
highest-$j$ sublevel sizes.

**The Madelung rule as a spectral ordering theorem.** The observed
noble-gas numbers $2,10,18,36,54,86$ should be the cumulative degeneracies
of the same $2n^2$ shells re-summed in order of increasing $n+l$ (ties by
increasing $n$) — the ordered eigenvalue multiplicities of a Hamiltonian
whose energies are monotone in $n+l$.

**Trace invariants as chemical sum rules.** Truncations of the diagonal
shell Hamiltonian should yield trace and higher-moment invariants that
serve as configuration-independent chemical sum rules.

## 8. Conclusion

Shell structure is degeneracy structure. Closed shells — noble gases and
magic numbers alike — are cumulative sums of eigenvalue multiplicities of
a shell Hamiltonian, and these sums collapse to cubic polynomials
generated by quadratic degeneracy laws. Made literal on a diagonal
Hermitian matrix, the periodic table becomes the spectrum and
multiplicity list of a self-adjoint operator. Chemistry, at the level of
degeneracy bookkeeping, is applied spectral theory.
