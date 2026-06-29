# Spectral Theory of the Hydrogen Atom: Energy Levels, Degeneracy, and Selection Rules

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (Mathematical Physics)

---

## Abstract

We present a self-contained formal development of the spectral structure of
the idealized hydrogen atom. Working in Rydberg units, we characterize the
spectrum of the hydrogen Hamiltonian as the disjoint union of a discrete
set of Bohr bound-state energies and a continuous ionization half-line,
$$\sigma(H) = \left\{-\tfrac{1}{n^2} : n \in \mathbb{Z}_{>0}\right\} \cup [0,\infty),$$
and prove the structural facts that justify this picture: negativity of the
bound energies, the existence and value of the ground state, strict
monotonicity of the levels, accumulation at the ionization threshold,
disjointness of the discrete and continuous parts, and the Rydberg formula
for emission energies. We then establish the angular structure: the
azimuthal factor $e^{im\varphi}$ is an eigenfunction of the orbital
angular-momentum operator $L_z = -i\,\partial_\varphi$ with integer
eigenvalue $m$, the subshell with orbital number $\ell$ carries exactly
$2\ell+1$ magnetic substates, and the shell with principal quantum number
$n$ has total degeneracy $\sum_{\ell=0}^{n-1}(2\ell+1)=n^2$. Finally we
formalize the electric-dipole selection rule $\Delta\ell=\pm1$,
$|\Delta m|\le 1$, and prove its principal consequences: the forbidding of
$\ell$-conserving (in particular $s\to s$) transitions, the mandatory
orbital-parity flip, symmetry under time reversal, and the allowedness of
the Lyman-$\alpha$ transition. All results are stated with full
mathematical rigor and accompanied by proof sketches.

---

## 1. Introduction

The hydrogen atom occupies a singular place in physics: it is the only
atom whose Schrödinger equation can be solved exactly in closed form, and
its spectrum was the proving ground on which the old quantum theory of
Bohr and the wave mechanics of Schrödinger were validated. Three layers
of structure organize that spectrum:

1. **The energy levels.** Bound states occur at discrete energies
   $E_n = -1/n^2$ (in Rydberg units); free (scattering) states fill the
   continuum $[0,\infty)$.
2. **Degeneracy.** Each level $n$ comprises $n^2$ distinct orbital states,
   organized into subshells indexed by an orbital quantum number $\ell$ and
   magnetic quantum number $m$.
3. **Selection rules.** Radiative transitions are constrained by
   conservation of angular momentum and parity; the dominant
   electric-dipole transitions obey $\Delta\ell=\pm1$, $|\Delta m|\le1$.

This paper develops all three layers as a coherent formal theory. Our aim
is not to re-derive the radial wavefunctions analytically, but to isolate
the *arithmetic and analytic invariants* that determine the qualitative
spectrum and to prove them outright. The reward is a description of
hydrogen's spectral lines — which levels exist, how degenerate they are,
and which transitions between them are optically allowed — built from
elementary, fully verified components.

We work throughout in **Rydberg units**, in which the Bohr ground-state
energy is normalized to $-1$. This removes all physical constants from the
formulas and exposes the underlying mathematics. The continuum threshold
(ionization energy) sits at $E = 0$.

---

## 2. The Energy Spectrum

### 2.1 The Bohr energies

**Definition 2.1 (Bohr energy).** For a principal quantum number
$n \in \mathbb{Z}_{>0}$, the *Bohr energy* is
$$E_n := -\frac{1}{n^2}.$$
We treat $E : \mathbb{Z}_{>0} \to \mathbb{R}$ as a real-valued sequence.

**Definition 2.2 (Hydrogen spectrum).** The spectrum of the hydrogen
Hamiltonian $H$ (in Rydberg units) is
$$\sigma(H) := \left\{E_n : n \in \mathbb{Z}_{>0}\right\} \cup [0,\infty)
= \left\{-\tfrac{1}{n^2} : n=1,2,3,\dots\right\} \cup [0,\infty).$$
The first set is the *discrete (point) spectrum* of bound states; the
half-line $[0,\infty)$ is the *continuous spectrum* of scattering states.

### 2.2 Structure of the discrete spectrum

**Theorem 2.3 (`bohrEnergy_neg`).** For every $n \ge 1$, $E_n < 0$.

*Proof sketch.* $E_n = -1/n^2$ and $1/n^2 > 0$ for $n \ge 1$, hence
$E_n < 0$. Physically, every bound state has negative total energy
relative to the dissociation threshold. $\square$

**Theorem 2.4 (`bohrEnergy_ground`).** $E_1 = -1$.

*Proof sketch.* Substitute $n=1$: $E_1 = -1/1^2 = -1$. This is the ground
state energy, the most tightly bound configuration. $\square$

**Theorem 2.5 (`bohrEnergy_ge_neg_one`).** For every $n \ge 1$,
$E_n \ge -1$, with equality iff $n=1$.

*Proof sketch.* For $n \ge 1$ we have $n^2 \ge 1$, so $0 < 1/n^2 \le 1$,
hence $-1 \le -1/n^2 < 0$. The atom thus has a finite energy floor; there
is no infinitely negative state, in contrast to the classical prediction
of radiative collapse. $\square$

**Theorem 2.6 (`bohrEnergy_strictMono`).** The sequence $n \mapsto E_n$ is
strictly increasing: $m < n \implies E_m < E_n$.

*Proof sketch.* For $0 < m < n$ we have $m^2 < n^2$, hence
$1/m^2 > 1/n^2$, hence $-1/m^2 < -1/n^2$, i.e. $E_m < E_n$. The energy
levels climb monotonically toward the ionization threshold. $\square$

**Theorem 2.7 (`bohrEnergy_tendsto_zero`).** $E_n \to 0$ as
$n \to \infty$.

*Proof sketch.* $|E_n| = 1/n^2 \to 0$, since $1/n^2$ is a null sequence.
Thus the levels accumulate at $0$ from below. $\square$

**Theorem 2.8 (`zero_mem_closure_discrete`).** $0$ lies in the closure of
the discrete spectrum $\{E_n : n \ge 1\}$; equivalently, $0$ is an
accumulation point of the bound-state energies.

*Proof sketch.* By Theorem 2.7 the sequence $E_n$ converges to $0$ while
remaining strictly below it (Theorem 2.3), so $0$ is a limit point of the
discrete set though not a member of it. This is the seam at which the
discrete ladder meets the continuous spectrum. $\square$

**Theorem 2.9 (`discrete_disjoint_continuous`).** The discrete spectrum and
the continuous half-line are disjoint:
$\{E_n : n \ge 1\} \cap [0,\infty) = \varnothing.$

*Proof sketch.* Every $E_n$ is strictly negative (Theorem 2.3), while every
element of $[0,\infty)$ is non-negative; the two sets cannot intersect.
Hence the labels "bound" and "scattering" are unambiguous. $\square$

### 2.3 Emission energies and the Rydberg formula

**Theorem 2.10 (`rydberg_formula`).** For $m < n$ the energy of the photon
emitted in the transition $n \to m$ is
$$E_{\text{photon}} = E_n - E_m = \frac{1}{m^2} - \frac{1}{n^2}.$$

*Proof sketch.* Direct substitution: $E_n - E_m = (-1/n^2) - (-1/m^2) =
1/m^2 - 1/n^2$. This recovers the empirical Rydberg formula, the spectral
law discovered before its theoretical explanation. $\square$

**Theorem 2.11 (`photon_energy_pos`).** For $m < n$ (with $m \ge 1$) the
emitted photon energy is strictly positive: $E_n - E_m > 0$.

*Proof sketch.* By Theorem 2.6 the sequence is strictly increasing, so
$m < n \implies E_m < E_n \implies E_n - E_m > 0$. Equivalently
$1/m^2 - 1/n^2 > 0$ because $m^2 < n^2$. A downward transition releases
energy. $\square$

**Remark 2.12 (Spectral series).** Fixing the lower level $m$ generates a
*spectral series*: $m=1$ gives the Lyman series (ultraviolet), $m=2$ the
Balmer series (visible), $m=3$ the Paschen series (infrared). Each series
has a *limit* energy $1/m^2$ (the $n \to \infty$ value), and every line in
the series lies strictly below this limit, since $E_n - E_m = 1/m^2 -
1/n^2 < 1/m^2$.

---

## 3. Angular Structure and Degeneracy

### 3.1 The azimuthal eigenfunctions and $L_z$

**Definition 3.1 (Azimuthal eigenfunction).** For $m \in \mathbb{Z}$ and
azimuthal angle $\varphi \in \mathbb{R}$, define
$$\Phi_m(\varphi) := e^{im\varphi} = \exp\!\big((m\varphi)\, i\big) \in \mathbb{C}.$$

This is the angular factor that appears in every separated solution of the
hydrogen Schrödinger equation; the full spherical harmonic is
$Y_\ell^m(\theta,\varphi) = \Theta_\ell^m(\theta)\,\Phi_m(\varphi)$.

**Lemma 3.2 (Periodicity).** $\Phi_m(\varphi + 2\pi) = \Phi_m(\varphi)$ for
every integer $m$.

*Proof sketch.* $e^{im(\varphi+2\pi)} = e^{im\varphi}\,e^{2\pi i m}$ and
$e^{2\pi i m} = 1$ exactly when $m \in \mathbb{Z}$. Single-valuedness of
the wavefunction on the circle thus *quantizes* $m$ to the integers.
$\square$

**Definition 3.3 ($z$-angular-momentum operator).** The $z$-component of
orbital angular momentum acts on functions of $\varphi$ by
$$L_z := -i\,\frac{\partial}{\partial \varphi}.$$

**Theorem 3.4 (`azimuthalExp_hasDerivAt`).** $\Phi_m$ is differentiable in
$\varphi$ with
$$\frac{d}{d\varphi}\,\Phi_m(\varphi) = i\,m\,\Phi_m(\varphi).$$

*Proof sketch.* Write $\Phi_m(\varphi) = \exp(g(\varphi))$ with
$g(\varphi) = (m\varphi)\,i$. Then $g'(\varphi) = m\,i$, and by the chain
rule for the complex exponential,
$\Phi_m'(\varphi) = g'(\varphi)\,e^{g(\varphi)} = im\,\Phi_m(\varphi)$. The
only technical content is the bookkeeping of the $\mathbb{R}\to\mathbb{C}$
coercion in the exponent. $\square$

**Theorem 3.5 ($L_z$ eigenvalue equation, `Lz_eigenvalue`).** For every
integer $m$ and angle $\varphi$,
$$L_z \,\Phi_m(\varphi) = -i\,\frac{d}{d\varphi}\Phi_m(\varphi) = m\,\Phi_m(\varphi).$$

*Proof sketch.* By Theorem 3.4 the derivative is $im\,\Phi_m$, so
$-i \cdot im\,\Phi_m = (-i\cdot i)\,m\,\Phi_m = m\,\Phi_m$, using
$i^2 = -1$. Thus $\Phi_m$ is an eigenfunction of $L_z$ with eigenvalue the
integer $m$ — the precise reason $m$ is called the *magnetic quantum
number*. This is the analytic counterpart of the matrix eigenvalue
statement for $L_z$ in the $\ell=1$ representation. $\square$

**Remark 3.6 (The integer spectrum of $L_z$).** Combining Lemma 3.2 and
Theorem 3.5: the eigenvalues of $L_z$ on the space of smooth
$2\pi$-periodic functions are exactly the integers $\mathbb{Z}$, with
eigenfunctions $\Phi_m$. Periodicity forces quantization; the eigenvalue
equation reads off the quantum number.

### 3.2 Orthogonality of the angular basis

The functions $\{\Phi_m\}_{m\in\mathbb{Z}}$ form an orthogonal family on
the circle:
$$\int_0^{2\pi} \overline{\Phi_{m_1}(\varphi)}\,\Phi_{m_2}(\varphi)\,d\varphi
= \begin{cases} 2\pi & m_1 = m_2,\\ 0 & m_1 \ne m_2.\end{cases}$$
This orthogonality (proved via $\int_0^{2\pi} e^{in\varphi}\,d\varphi = 0$
for $n \ne 0$) guarantees that distinct magnetic substates are
independent, and underlies the completeness of the spherical-harmonic
basis.

### 3.3 Subshell size and shell degeneracy

**Theorem 3.7 (Magnetic count, `subshell_size` / `magnetic_count`).** For
orbital quantum number $\ell \in \mathbb{N}$, the number of integer
magnetic quantum numbers $m$ with $-\ell \le m \le \ell$ is
$$\#\{m \in \mathbb{Z} : -\ell \le m \le \ell\} = 2\ell + 1.$$

*Proof sketch.* The integer interval $[-\ell, \ell]$ has cardinality
$\ell - (-\ell) + 1 = 2\ell + 1$. Each value of $m$ labels one magnetic
substate of the subshell. $\square$

**Theorem 3.8 (Shell degeneracy, `shell_degeneracy`).** The total number of
orbital states in the shell with principal quantum number $n$ is
$$\sum_{\ell=0}^{n-1} (2\ell + 1) = n^2.$$

*Proof sketch.* Induction on $n$. The base case $n=0$ gives the empty sum
$0 = 0^2$. For the inductive step, using the hypothesis
$\sum_{\ell=0}^{k-1}(2\ell+1) = k^2$,
$$\sum_{\ell=0}^{k}(2\ell+1) = k^2 + (2k+1) = (k+1)^2.$$
This is the classical identity "the sum of the first $n$ odd numbers is
$n^2$." Equivalently, $2\ell+1$ is the discrete derivative of $\ell^2$, so
its partial sums telescope to $n^2$. $\square$

**Corollary 3.9 (Degeneracy structure).** Each shell $n$ decomposes into
subshells $\ell = 0,1,\dots,n-1$ of sizes $1,3,5,\dots,2n-1$, summing to
$n^2$. Counting the electron's two spin states doubles this to $2n^2$, the
maximum occupancy of the $n$-th electron shell — the numerology behind the
periodic table's row lengths $2, 8, 18, 32, \dots$ (the latter requiring
the spin factor not formalized here).

---

## 4. Selection Rules for Radiative Transitions

### 4.1 The dipole rule

**Definition 4.1 (Dipole-allowed transition, `dipoleAllowed`).** A
radiative transition between angular states $(\ell, m)$ and $(\ell', m')$
is *electric-dipole allowed* iff
$$\big(\ell' = \ell + 1 \;\lor\; \ell = \ell' + 1\big) \;\land\; |m - m'| \le 1.$$
Equivalently: $\Delta\ell = \pm 1$ and $\Delta m \in \{-1, 0, +1\}$.

This predicate captures the angular-momentum and parity bookkeeping
imposed by the emission or absorption of a single spin-1 photon.

### 4.2 Consequences

**Theorem 4.2 (No $\ell$-conserving transitions, `dipole_forbids_same_l`).**
For any $\ell$, $m$, $m'$, the transition $(\ell,m) \to (\ell,m')$ is *not*
dipole-allowed. In particular $s\to s$ ($\ell:0\to0$) is forbidden.

*Proof sketch.* Allowedness requires $\ell' = \ell + 1$ or
$\ell = \ell' + 1$. With $\ell' = \ell$ both disjuncts assert
$\ell = \ell \pm 1$, impossible for natural numbers. $\square$

**Theorem 4.3 (Parity flip, `dipole_parity_flip`).** If $(\ell,m) \to
(\ell',m')$ is dipole-allowed, then $\ell + \ell'$ is odd.

*Proof sketch.* From $\Delta\ell = \pm 1$ we have $\ell' = \ell + 1$ or
$\ell = \ell' + 1$; in either case $\ell + \ell' = 2\ell + 1$ or
$2\ell' + 1$, which is odd. Since orbital parity is $(-1)^\ell$, an odd sum
$\ell + \ell'$ means the parities of the two states differ: the transition
flips parity, exactly as required by the odd intrinsic parity of the
photon. $\square$

**Theorem 4.4 (Symmetry / detailed balance, `dipole_symm`).** The relation
is symmetric:
$$\text{dipoleAllowed}(\ell, \ell', m, m') \iff \text{dipoleAllowed}(\ell', \ell, m', m).$$

*Proof sketch.* The $\Delta\ell$ condition is a symmetric disjunction
($\ell'=\ell+1 \lor \ell=\ell'+1$), and $|m-m'| = |m'-m|$. Swapping initial
and final states preserves both clauses. This is the kinematic seed of
detailed balance: emission and absorption obey the same selection rule.
$\square$

**Theorem 4.5 (Lyman-$\alpha$ is allowed, `lyman_alpha_allowed`).** The
transition $2p \to 1s$, i.e. $(\ell,m) = (1,0) \to (\ell',m') = (0,0)$, is
dipole-allowed.

*Proof sketch.* Here $\ell = \ell' + 1$ (since $1 = 0 + 1$) and
$|m - m'| = 0 \le 1$, so both clauses of Definition 4.1 hold. This is the
Lyman-$\alpha$ line, hydrogen's strongest ultraviolet emission. $\square$

### 4.3 Physical interpretation

The selection rule is the conservation law of the radiation field made
combinatorial. A photon is a spin-1 quantum of odd parity; emitting one
must change the atom's orbital angular momentum by exactly one unit
($\Delta\ell = \pm 1$) and its $z$-projection by at most one
($|\Delta m| \le 1$), the three cases $\Delta m \in \{-1,0,+1\}$
corresponding to the photon's three polarization states. Theorem 4.3
expresses parity conservation; Theorem 4.2 is its sharpest corollary; and
Theorem 4.4 expresses microscopic reversibility.

---

## 5. Algorithms

The formal theory yields directly executable procedures. We summarize the
three principal ones.

**Algorithm A (Bohr energies and Rydberg lines).** Given a cutoff $N$,
tabulate $E_n = -1/n^2$ for $1 \le n \le N$ and all emission energies
$E_n - E_m = 1/m^2 - 1/n^2$ for $m < n$, grouped into spectral series by
the lower index $m$. Complexity $O(N^2)$ for the full line list.

**Algorithm B (Degeneracy by direct summation).** Given $n$, compute
$\sum_{\ell=0}^{n-1}(2\ell+1)$ and verify it equals $n^2$; report the
subshell decomposition $(1,3,5,\dots,2n-1)$. Complexity $O(n)$ for the sum,
$O(1)$ via the closed form $n^2$.

**Algorithm C (Selection-rule filter).** Given a set of states
$(\ell, m)$, enumerate all ordered pairs and retain those satisfying
$\Delta\ell = \pm1 \land |\Delta m| \le 1$. Complexity $O(S^2)$ for $S$
states.

---

## 6. Applications

- **Astrophysical spectroscopy.** The Rydberg formula (Theorem 2.10) and
  the selection rules (§4) predict which hydrogen lines appear in stellar
  and interstellar spectra. Lyman-$\alpha$ (Theorem 4.5) is a primary
  tracer of neutral hydrogen across cosmological distances.
- **Atomic clocks and metrology.** The discreteness and disjointness of the
  spectrum (Theorems 2.6, 2.9) underlie the sharp, well-separated reference
  frequencies used in precision measurement.
- **Chemistry and the periodic table.** The $n^2$ degeneracy (Theorem 3.8),
  doubled by spin, fixes electron-shell capacities and hence the structure
  of the periodic table (Corollary 3.9).
- **Laser physics.** Detailed balance (Theorem 4.4) is the kinematic basis
  for stimulated emission and population-inversion lasing.

---

## 7. Discussion

The development isolates a striking fact: the qualitative spectrum of
hydrogen is governed by elementary arithmetic and single-variable
analysis. The energy ladder is the negated null sequence $1/n^2$; its
accumulation at the ionization threshold is the convergence of that
sequence; the $n^2$ degeneracy is the sum-of-odd-numbers identity; the
integer angular-momentum spectrum is forced by $2\pi$-periodicity; and the
selection rules are parity and angular-momentum bookkeeping expressed as
divisibility and absolute-value inequalities. None of these requires the
explicit Laguerre or Legendre special functions; they are invariants
extractable from the *structure* of the eigenvalue problem.

A deliberate idealization is the use of Rydberg units and the modeling of
the spectrum as a fixed set rather than as the operator spectrum of an
unbounded self-adjoint Hamiltonian on $L^2(\mathbb{R}^3)$. The set-level
description (Definition 2.2) captures exactly the physics needed for the
spectral-line predictions while remaining elementary. Fine structure,
hyperfine structure, the Lamb shift, and relativistic corrections are
beyond the present scope, as is electron spin (which would double all
multiplicities).

---

## 8. Future Directions

1. **Order type of the discrete spectrum.** Conjecture: the set
   $\{-1/n^2 : n \ge 1\}$ is order-isomorphic to $\mathbb{N}$ and its
   derived set (set of accumulation points) is exactly $\{0\}$. The
   negation operator turns the monotone null sequence $1/n^2$ into a
   strictly increasing sequence bounded above by $0$ whose only limit is
   the supremum; with `bohrEnergy_strictMono` and
   `zero_mem_closure_discrete` in hand, the missing step is
   $\text{derivedSet} = \{0\}$.

2. **Two scales of Rydberg gaps.** Conjecture: for every $\varepsilon > 0$
   there are infinitely many emission energies $E_n - E_m$ within
   $\varepsilon$ of an accumulation value, yet gaps to the ground state
   $E_n - E_1$ are bounded below by a positive constant. The $1/n^2$ tail
   collapses (giving density near $0$) while the $m=1$ series stays away
   from $0$ because $E_1 = -1$ is isolated.

3. **Uniqueness of the degeneracy lift.** Conjecture: the only $d:
   \mathbb{N}\to\mathbb{N}$ with $d(n) = \sum_{\ell<n} g(\ell)$ and
   $g(\ell) = 2\ell+1$ is $d(n) = n^2$; conversely any quadratic degeneracy
   forces odd-integer subshell multiplicities. This is the telescoping
   identity $\Delta(n^2) = 2\ell+1$ viewed from both sides.

4. **Selection rule as photon parity obstruction.** Conjecture: a
   transition $(\ell,m)\to(\ell',m')$ conserves total angular momentum with
   a spin-1 photon iff `dipoleAllowed`, and every allowed transition
   strictly flips orbital parity $(-1)^\ell$. The remaining content is to
   connect $|\Delta m| \le 1$ to the three photon polarization states.

5. **The $L_z$ spectrum is exactly $\mathbb{Z}$.** Conjecture: the
   eigenvalues of $L_z = -i\,\partial_\varphi$ on smooth $2\pi$-periodic
   functions are exactly $\mathbb{Z}$, forced by the periodicity proved in
   `azimuthal_eigenfunction_periodic` and the eigenvalue equation
   `Lz_eigenvalue`.

---

## 9. Conclusion

We have given a complete, self-contained account of the spectral structure
of the hydrogen atom: the Bohr energy ladder $-1/n^2$ and its fusion with
the ionization continuum $[0,\infty)$; the $L_z$ eigenvalue equation that
names the magnetic quantum number; the $2\ell+1$ subshell sizes summing to
the $n^2$ shell degeneracy; and the electric-dipole selection rules with
their parity, forbidding, symmetry, and Lyman-$\alpha$ consequences. Every
statement is elementary in its components yet collectively reconstructs the
qualitative spectrum of the simplest atom — a demonstration that the music
of hydrogen is written in arithmetic.
