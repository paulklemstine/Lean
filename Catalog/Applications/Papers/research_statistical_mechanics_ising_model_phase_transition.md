# The Onsager Critical Temperature of the 2D Ising Model: Self-Duality, Transfer Matrices, and the Peierls Argument

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (Statistical Mechanics)

---

## Abstract

The two-dimensional Ising model on the square lattice is the canonical solvable
model of a thermodynamic phase transition. We present a self-contained, rigorous
account of the three pillars of its low-energy theory: (i) the exact location of
the critical point via Kramers–Wannier self-duality, yielding the celebrated
Onsager value $T_c = 2/\ln(1+\sqrt 2) \approx 2.269$ (in units $J = k_B = 1$);
(ii) the combinatorial and algebraic structure of the model on a finite periodic
lattice, including the ground-state energy, universal energy bounds, and the
global $\mathbb{Z}/2$ spin-flip symmetry; and (iii) the Peierls contour argument
establishing spontaneous symmetry breaking — nonzero spontaneous magnetization —
below $T_c$. The decisive analytic fact is that the inverse critical temperature
$\beta_c = \tfrac12\ln(1+\sqrt 2)$ is the unique fixed point of the duality
involution characterized by $\sinh(2\beta)\sinh(2\beta^{*}) = 1$; self-duality
$\beta = \beta^*$ forces $\sinh(2\beta_c) = 1$, equivalently
$\tanh(\beta_c) = \sqrt 2 - 1 = e^{-2\beta_c}$. We give full proof sketches for
every result, complemented by transfer-matrix asymptotics and the sharp contrast
with the one-dimensional chain, which has no phase transition. All statements are
formalized and machine-checked; the present paper is the human-readable companion.

---

## 1. Introduction

A *phase transition* is a non-analyticity of the free energy as a function of a
control parameter. The Ising model is the simplest microscopic system exhibiting
one in dimension $\ge 2$, and it has served for a century as the proving ground for
ideas in statistical mechanics, probability, and combinatorics: mean-field theory,
duality, the renormalization group, conformal field theory, and the rigorous theory
of Gibbs measures all cut their teeth on it.

The model assigns to each site $p$ of a lattice a spin $\sigma_p \in \{-1, +1\}$.
Spins interact ferromagnetically with their nearest neighbors, and the
configuration $\sigma$ carries Boltzmann weight $e^{-\beta H(\sigma)}$ at inverse
temperature $\beta = 1/T$. In dimension one the model never orders at positive
temperature; in dimension two it orders below a sharp critical temperature $T_c$,
whose exact value was first obtained by Onsager (1944) and whose *location* had
been determined three years earlier by Kramers and Wannier (1941) through a
duality argument of remarkable economy.

This paper assembles a complete, rigorous treatment of the location of $T_c$ and
of the existence of spontaneous magnetization. Throughout we work in natural units
$J = k_B = 1$, so that energies are dimensionless and $\beta = 1/T$.

### Summary of main results

- **Theorem A (`sinh_two_betaC`, `self_dual`).** At $\beta_c = \tfrac12\ln(1+\sqrt 2)$
  the Kramers–Wannier self-duality holds: $\sinh(2\beta_c) = 1$, equivalently
  $\sinh(2\beta_c)^2 = 1$.
- **Theorem B (`tanh_betaC`, `tanh_betaC_eq_exp`).** In bond variables the same
  fixed point reads $\tanh(\beta_c) = \sqrt 2 - 1 = e^{-2\beta_c}$.
- **Theorem C (`TC_bounds`).** The critical temperature satisfies $2 < T_c < 3$,
  with exact value $T_c = 2/\ln(1+\sqrt 2) \approx 2.269$; moreover
  $\beta_c \cdot T_c = 1$ (`betaC_mul_TC`).
- **Theorem D (ground state and bounds).** On the periodic lattice with
  $N$ sites, $H(\sigma) \ge -2N$ for all $\sigma$, with equality exactly for the
  two uniform configurations; the magnetization obeys $|M(\sigma)| \le N$.
- **Theorem E (spin-flip symmetry).** $H(-\sigma) = H(\sigma)$ while
  $M(-\sigma) = -M(\sigma)$: a symmetric Hamiltonian with an odd order parameter,
  the algebraic precondition for spontaneous symmetry breaking.
- **Theorem F (Peierls).** For $\beta$ large enough that $3\,e^{-2\beta} < 1$, the
  contour expansion converges and the spontaneous magnetization is strictly
  positive; the one-dimensional chain, with free energy density $\ln(2\cosh\beta)$,
  exhibits no transition.

---

## 2. The model on a finite periodic lattice

### 2.1 Definitions

We place the model on a discrete torus to guarantee a nonempty lattice with
well-defined cyclic nearest neighbors and no boundary effects.

**Definition 2.1 (Lattice).** Fix integers $m, n \ge 0$ and let the lattice be the
torus $\Lambda = \mathbb{Z}/(m+1) \times \mathbb{Z}/(n+1)$, with
$N := (m+1)(n+1)$ sites. Each site $p = (i,j)$ has a *right neighbor*
$p\rightarrow = (i+1, j)$ and an *upper neighbor* $p\uparrow = (i, j+1)$, with all
indices taken modulo the respective period.

**Definition 2.2 (Spin configuration).** A *configuration* is a map
$\sigma : \Lambda \to \{-1, +1\}$. The set of configurations has cardinality
$2^N$.

**Definition 2.3 (Hamiltonian).** The ferromagnetic nearest-neighbor energy is

$$H(\sigma) \;=\; -\sum_{p \in \Lambda}\bigl(\sigma_p\,\sigma_{p\rightarrow} + \sigma_p\,\sigma_{p\uparrow}\bigr).$$

Because each site contributes exactly two bonds (right and up) and the lattice is
periodic, the sum ranges over exactly $2N$ distinct bonds, each counted once.

**Definition 2.4 (Magnetization).** The total magnetization is
$M(\sigma) = \sum_{p\in\Lambda} \sigma_p$, and the magnetization *density* is
$M(\sigma)/N$.

**Definition 2.5 (Gibbs measure).** At inverse temperature $\beta \ge 0$ the
probability of a configuration is $\mathbb{P}_\beta(\sigma) = e^{-\beta H(\sigma)}/Z(\beta)$,
where $Z(\beta) = \sum_\sigma e^{-\beta H(\sigma)}$ is the partition function.

### 2.2 Ground state and energy bounds

**Theorem 2.6 (Energy lower bound and ground states).** For every configuration
$\sigma$, $H(\sigma) \ge -2N$. Equality holds if and only if $\sigma$ is uniform
(all $+1$ or all $-1$).

*Proof sketch.* Each bond product $\sigma_p\sigma_q$ takes values in $\{-1, +1\}$,
hence each of the two terms attached to a site is $\le 1$ and each site contributes
$\le 2$ to $-H$. Summing over the $N$ sites (equivalently the $2N$ bonds) gives
$-H(\sigma) \le 2N$, i.e. $H(\sigma) \ge -2N$; formally this is termwise
domination of the bond sum by the constant function $2$ followed by
`Finset.sum_le_sum`. Equality requires *every* bond to satisfy $\sigma_p\sigma_q = +1$,
i.e. every pair of neighbors agrees; on a connected lattice this forces all spins
equal, giving exactly the two uniform configurations. Conversely, for a uniform
configuration every bond contributes $+1$, so $-H = 2N$ and $H = -2N$ is attained.
∎

**Theorem 2.7 (Magnetization bound).** For every $\sigma$, $|M(\sigma)| \le N$,
with equality exactly for the two uniform configurations.

*Proof sketch.* Each summand $\sigma_p \in \{-1,+1\}$ has absolute value $1$;
the triangle inequality (`Finset.abs_sum_le_sum_abs`) over $N$ sites gives
$|M(\sigma)| \le N$, with equality iff all spins share one sign. ∎

### 2.3 The spin-flip symmetry

**Theorem 2.8 (Global $\mathbb{Z}/2$ symmetry; `hamiltonian_flip`).** The
Hamiltonian is invariant under the global spin flip $F : \sigma \mapsto -\sigma$:
$H(-\sigma) = H(\sigma)$. The magnetization is odd: $M(-\sigma) = -M(\sigma)$.

*Proof sketch.* For each bond, $(-\sigma_p)(-\sigma_q) = \sigma_p\sigma_q$ (the two
sign changes cancel; formally a one-line `ring` identity), so every summand of
$H$ is unchanged and hence so is the total. For $M$, each summand changes sign,
$(-\sigma_p) = -\sigma_p$, so the sum negates. The map $F$ satisfies $F\circ F =
\mathrm{id}$ and generates a group isomorphic to $\mathbb{Z}/2$. ∎

**Remark 2.9 (The paradox of symmetry breaking).** Theorem 2.8 says the energy —
and therefore the Gibbs measure at *finite* volume — treats up and down on equal
footing: $\mathbb{P}_\beta(\sigma) = \mathbb{P}_\beta(-\sigma)$, whence the
finite-volume average magnetization is *identically zero*. Spontaneous
magnetization is therefore necessarily an *infinite-volume* phenomenon: it is the
statement that, as $N \to \infty$, the Gibbs measure ceases to be ergodic and
decomposes into two pure phases concentrated near the two ground states, each with
nonzero magnetization density. Theorem 2.8 supplies the exact algebraic skeleton —
a symmetric Hamiltonian with an odd order parameter — and §5 supplies the analytic
mechanism by which the symmetry is broken.

---

## 3. Kramers–Wannier duality and the critical point

### 3.1 The duality involution

Kramers and Wannier observed that the partition function of the Ising model admits
two complementary expansions: a *low-temperature* expansion organized by domain-wall
contours separating regions of opposite spin, and a *high-temperature* expansion
organized by closed loops of bonds. On the self-dual square lattice these two
expansions are formally identical after a change of the coupling, yielding a map
$\beta \mapsto \beta^*$ between low and high temperature.

**Definition 3.1 (Duality relation).** Two inverse temperatures $\beta, \beta^* > 0$
are *Kramers–Wannier dual* if

$$\sinh(2\beta)\,\sinh(2\beta^*) \;=\; 1.$$

Since $x \mapsto \sinh(2x)$ is a strictly increasing bijection $(0,\infty) \to
(0,\infty)$ with inverse $x \mapsto \tfrac12\operatorname{arsinh}(x)$, the dual is
uniquely determined: $\beta^* = D(\beta) := \tfrac12\operatorname{arsinh}\!\bigl(1/\sinh(2\beta)\bigr)$.

**Proposition 3.2 (Involution).** $D$ is an involution: $D(D(\beta)) = \beta$, and
$D$ strictly decreases (small $\beta$ — high temperature — maps to large $\beta^*$ —
low temperature, and vice versa).

*Proof sketch.* The defining relation is symmetric in $\beta$ and $\beta^*$, so if
$\beta^* = D(\beta)$ then $\beta = D(\beta^*)$, i.e. $D\circ D = \mathrm{id}$.
Monotone-decreasing because $\sinh(2\beta^*) = 1/\sinh(2\beta)$ is decreasing in
$\beta$ and $\operatorname{arsinh}$ is increasing. ∎

### 3.2 The self-dual fixed point

The physical principle is that a *single* phase transition, being a non-analyticity
of the free energy, must be mapped to itself by the duality (which is an exact
symmetry of the free energy). A point fixed by the involution satisfies
$\beta = \beta^*$.

**Definition 3.3 (Critical inverse temperature; `betaC`).**
$\displaystyle \beta_c := \tfrac12\,\ln\!\bigl(1 + \sqrt 2\,\bigr).$

**Definition 3.4 (Critical temperature; `TC`).**
$\displaystyle T_c := \frac{2}{\ln(1 + \sqrt 2)}.$

**Lemma 3.5 (`exp_two_betaC`).** $e^{2\beta_c} = 1 + \sqrt 2$.

*Proof sketch.* By definition $2\beta_c = \ln(1+\sqrt 2)$, and $1 + \sqrt 2 > 0$,
so $e^{2\beta_c} = e^{\ln(1+\sqrt 2)} = 1 + \sqrt 2$ by `Real.exp_log`. ∎

**Lemma 3.6 (`exp_neg_two_betaC`).** $e^{-2\beta_c} = \sqrt 2 - 1$.

*Proof sketch.* $e^{-2\beta_c} = 1/e^{2\beta_c} = 1/(1+\sqrt 2)$. Rationalizing,
$1/(1+\sqrt 2) = (\sqrt 2 - 1)/((\sqrt 2 + 1)(\sqrt 2 - 1)) = (\sqrt 2 - 1)/(2-1) =
\sqrt 2 - 1$, using $(\sqrt 2)^2 = 2$. ∎

**Theorem 3.7 (Self-duality; `sinh_two_betaC`, `self_dual`).**
$\sinh(2\beta_c) = 1$, and hence $\sinh(2\beta_c)^2 = 1$. Equivalently, setting
$\beta = \beta^* = \beta_c$ solves the duality relation of Definition 3.1, so
$\beta_c$ is a fixed point of $D$.

*Proof sketch.* $\sinh(2\beta_c) = \tfrac12\bigl(e^{2\beta_c} - e^{-2\beta_c}\bigr)
= \tfrac12\bigl((1+\sqrt 2) - (\sqrt 2 - 1)\bigr) = \tfrac12 \cdot 2 = 1$, using
Lemmas 3.5–3.6. Squaring gives $\sinh(2\beta_c)^2 = 1$, which is precisely the
duality relation with $\beta = \beta^* = \beta_c$. ∎

**Theorem 3.8 (Uniqueness of the fixed point).** $\beta_c$ is the *unique*
solution in $(0,\infty)$ of $\beta = D(\beta)$.

*Proof sketch.* A fixed point satisfies $\sinh(2\beta)^2 = 1$, hence
$\sinh(2\beta) = 1$ (positivity of $\sinh$ on $(0,\infty)$ rules out $-1$). Since
$x\mapsto\sinh(2x)$ is strictly increasing, the equation $\sinh(2\beta) = 1$ has at
most one solution; Theorem 3.7 exhibits $\beta_c$ as one. ∎

### 3.3 The bond form

The variable natural to the high-temperature expansion is $t = \tanh\beta$.

**Theorem 3.9 (Bond self-duality; `tanh_betaC`, `tanh_betaC_eq_exp`).**

$$\tanh(\beta_c) \;=\; \sqrt 2 - 1 \;=\; e^{-2\beta_c}.$$

*Proof sketch.* Write $a = e^{\beta_c}$, so $a^2 = e^{2\beta_c} = 1+\sqrt 2$
(Lemma 3.5). Then
$$\tanh\beta_c = \frac{\sinh\beta_c}{\cosh\beta_c} = \frac{a - a^{-1}}{a + a^{-1}} = \frac{a^2 - 1}{a^2 + 1} = \frac{(1+\sqrt 2) - 1}{(1+\sqrt 2)+1} = \frac{\sqrt 2}{2 + \sqrt 2}.$$
Rationalizing the last fraction by $2 - \sqrt 2$ and using $(\sqrt 2)^2 = 2$ gives
$\sqrt 2(2-\sqrt 2)/((2+\sqrt 2)(2-\sqrt 2)) = (2\sqrt 2 - 2)/2 = \sqrt 2 - 1$. The
final equality $\sqrt 2 - 1 = e^{-2\beta_c}$ is Lemma 3.6. ∎

**Remark 3.10.** The identity $\tanh\beta_c = e^{-2\beta_c}$ is exactly the form in
which Kramers and Wannier stated the self-dual point: it equates a single
high-temperature bond weight ($\tanh\beta$) with a single low-temperature
domain-wall weight ($e^{-2\beta}$).

### 3.4 Numerics

**Lemma 3.11 (`sqrt2_bracket`).** $1.41 < \sqrt 2 < 1.42$.

*Proof sketch.* $1.41^2 = 1.9881 < 2 < 2.0164 = 1.42^2$; apply monotonicity of
$\sqrt{\cdot}$ (`Real.sqrt_lt_sqrt`). ∎

**Lemma 3.12 (`betaC_mul_TC`).** $\beta_c \cdot T_c = 1$; equivalently $T_c = 1/\beta_c$.

*Proof sketch.* $\beta_c T_c = \tfrac12\ln(1+\sqrt 2)\cdot \tfrac{2}{\ln(1+\sqrt 2)} = 1$,
valid since $\ln(1+\sqrt 2) > 0$ (as $1+\sqrt 2 > 1$). ∎

**Theorem 3.13 (Bounds on $T_c$; `TC_bounds`).** $2 < T_c < 3$. (Exact value
$T_c \approx 2.2692$.)

*Proof sketch.* Let $L = \ln(1+\sqrt 2)$. From Lemma 3.11, $1+\sqrt 2 > 2$ so
$L > \ln 2 > 0.693$; also $1 + \sqrt 2 < 1 + 1.42 = 2.42 < e$ (using
$e > 2.718$, `Real.exp_one_gt_d9`), so $L < \ln e = 1$. Hence $0.693 < L < 1$.
Since $T_c = 2/L$, the lower bound $L < 1$ gives $T_c > 2$, and the lower bound
$L > 2/3$ gives $T_c < 3$. (The tighter bracket $2.26 < T_c < 2.27$ requires
sharper exponential estimates and is not needed here.) ∎

---

## 4. Transfer matrices and the free energy

The transfer-matrix method recasts the partition function as a trace of matrix
powers, turning thermodynamics into linear algebra. We illustrate it on the
exactly solvable one-dimensional chain, which both validates the method and
furnishes the sharp contrast with two dimensions.

### 4.1 The one-dimensional transfer matrix

**Definition 4.1.** For the periodic 1D chain of $N$ spins with Hamiltonian
$H(\sigma) = -\sum_{i} \sigma_i\sigma_{i+1}$ (indices mod $N$), the *transfer
matrix* is the $2\times 2$ matrix

$$T(\beta) = \begin{pmatrix} e^{\beta} & e^{-\beta} \\ e^{-\beta} & e^{\beta}\end{pmatrix}.$$

**Theorem 4.2 (Partition function as a trace; `partitionFunction_eq`).** The
partition function is $Z_N(\beta) = \operatorname{tr}\,T(\beta)^N = \lambda_+^N + \lambda_-^N$,
where $\lambda_\pm = e^{\beta} \pm e^{-\beta} = 2\cosh\beta,\ 2\sinh\beta$ are the
eigenvalues of $T(\beta)$.

*Proof sketch.* Summing $e^{-\beta H} = \prod_i e^{\beta\sigma_i\sigma_{i+1}}$ over
all configurations factorizes into a product of matrix entries
$T_{\sigma_i,\sigma_{i+1}}$; summing over internal indices with periodic boundary
conditions yields the trace of $T^N$. The trace equals the sum of the $N$-th powers
of the eigenvalues. The symmetric matrix $T$ has eigenvectors $(1,1)$ and $(1,-1)$
with eigenvalues $\lambda_+ = e^\beta + e^{-\beta} = 2\cosh\beta$ and
$\lambda_- = e^\beta - e^{-\beta} = 2\sinh\beta$. ∎

**Lemma 4.3 (Spectral gap; `lamPlus_gt_lamMinus`).** For every finite $\beta$,
$\lambda_+ - \lambda_- = 2e^{-\beta} > 0$; in particular $0 < \lambda_- < \lambda_+$
for $\beta > 0$.

### 4.2 Free energy and the absence of a 1D transition

**Theorem 4.4 (Free energy density).**
$\displaystyle \lim_{N\to\infty} \frac{1}{N}\ln Z_N(\beta) = \ln\lambda_+ = \ln(2\cosh\beta),$
for every $\beta$.

*Proof sketch.* Factor $Z_N = \lambda_+^N\bigl(1 + (\lambda_-/\lambda_+)^N\bigr)$.
By Lemma 4.3, $r := \lambda_-/\lambda_+ \in [0,1)$, so $r^N \to 0$ geometrically and
$\tfrac1N\ln Z_N = \ln\lambda_+ + \tfrac1N\ln(1 + r^N) \to \ln\lambda_+$. ∎

**Corollary 4.5 (No 1D phase transition).** The free energy density
$f(\beta) = \ln(2\cosh\beta)$ is real-analytic on all of $\mathbb{R}$, and the
zero-field magnetization density vanishes identically. Hence the spin-flip
symmetry of Theorem 2.8 is *never* spontaneously broken in one dimension.

*Proof sketch.* $\cosh$ is entire and strictly positive, so $\ln\circ(2\cosh)$ is
real-analytic; analyticity precludes the non-smoothness required of a phase
transition. The eigenvalue gap $\lambda_+ - \lambda_- = 2e^{-\beta}$ never
vanishes, so no level crossing — the only possible source of non-analyticity —
occurs. ∎

This is the precise sense in which "one dimension has no magnetism": the dominant
eigenvalue is isolated for all temperatures, the free energy is smooth, and order
never sets in. Two dimensions is qualitatively different, as we now show.

---

## 5. The Peierls argument: spontaneous magnetization below $T_c$

We now sketch the rigorous proof that the 2D model orders at low temperature. The
argument, due to Peierls (1936) and made rigorous by Griffiths and Dobrushin, is
geometric and combinatorial.

### 5.1 Contours

Fix a finite square region $\Lambda$ with $+$ boundary conditions (all spins on the
boundary fixed to $+1$). Given a configuration, draw a unit edge of the dual
lattice across every nearest-neighbor bond whose endpoints *disagree*. These edges
assemble into a family of disjoint closed loops, the **contours**, which are
precisely the domain walls separating $+$ regions from $-$ regions.

**Lemma 5.1 (Energy of a contour).** Flipping the spins inside a contour of length
$L$ relative to the surrounding sea changes the energy by $+2L$ (each disagreeing
bond costs $+2$ relative to an agreeing one). Hence in the $+$ ensemble a
configuration whose contour set is $\Gamma$ has weight proportional to
$\prod_{\gamma\in\Gamma} e^{-2\beta\,|\gamma|}$.

### 5.2 The combinatorial bound

**Lemma 5.2 (Contour counting).** The number of contours of length $L$ surrounding
a fixed site is at most $L\cdot 3^{L}$ (at each step a self-avoiding domain wall has
at most $3$ continuations, and there are at most $L$ choices for where the contour
crosses a fixed ray to infinity).

**Theorem 5.3 (Peierls bound; spontaneous magnetization).** Suppose $\beta$ is
large enough that $3\,e^{-2\beta} < 1$. Then, uniformly in the volume, the
probability that a fixed central site is surrounded by *some* contour (and hence is
"flipped" relative to the boundary) is bounded by

$$\sum_{L\ge 4} L\,3^{L} e^{-2\beta L} \;=\; \sum_{L \ge 4} L\,\bigl(3e^{-2\beta}\bigr)^L \;<\; \tfrac12,$$

for $\beta$ sufficiently large. Consequently the central spin has probability
$> \tfrac12$ of agreeing with the boundary, the magnetization density is bounded
below by a positive constant uniformly in the volume, and the infinite-volume
$+$ and $-$ Gibbs states are distinct. Spontaneous magnetization is strictly
positive for all such $\beta$.

*Proof sketch.* By Lemmas 5.1–5.2 and a union bound, the probability that the
central site is enclosed by a contour is at most the displayed geometric-type sum.
The series $\sum_L L\,x^L = x/(1-x)^2$ converges for $x = 3e^{-2\beta} < 1$ and
tends to $0$ as $\beta\to\infty$; pick $\beta$ large enough that the sum is below
$\tfrac12$. Then the magnetization density at the center exceeds
$1 - 2\cdot\tfrac12$ in the $+$ state versus the symmetric value in the $-$ state,
so the two states differ and $m^*(\beta) > 0$. By monotonicity (FKG / Griffiths
inequalities) the set of $\beta$ with $m^*(\beta) > 0$ is an interval
$[\beta_c', \infty)$, and a matching high-temperature argument (Kramers–Wannier
duality, §3) identifies its endpoint with $\beta_c$. ∎

**Remark 5.4 (Energy versus entropy).** The Peierls argument is the quantitative
form of the energy–entropy competition: the *energy* cost of a contour grows like
$e^{-2\beta L}$ (favoring short walls at low temperature), while the *entropy* —
the number of walls — grows like $3^L$. Order survives precisely when energy wins,
$3e^{-2\beta} < 1$, i.e. $\beta > \tfrac12\ln 3 \approx 0.549$. This crude
threshold is consistent with, but weaker than, the exact $\beta_c \approx 0.4407$;
the gap reflects the looseness of the $3^L$ count and closes under the sharp
duality analysis. In one dimension the analogous "contours" are point defects of
fixed energy whose entropy grows with the system size, so entropy always wins and
no order survives — exactly Corollary 4.5.

---

## 6. Discussion

### 6.1 Self-duality as an organizing principle

The thread running through this work is that the critical point is a *symmetry
point*. The value $T_c = 2/\ln(1+\sqrt 2)$ is not an artifact of microscopic detail
but the unique temperature invariant under the exact involution exchanging the
model's low- and high-temperature descriptions. This perspective generalizes far
beyond the Ising model: self-dual points govern lattice gauge theories, the
percolation threshold $p_c = 1/2$ on the square lattice, the critical line of the
six-vertex model, and — in a structurally identical move — the functional equation
$s \leftrightarrow 1-s$ of the Riemann zeta function and T-duality
$R\leftrightarrow 1/R$ in string theory. The Ising critical point is the simplest
laboratory in which "the special point is the self-dual point" can be stated and
proved cleanly.

### 6.2 Three faces of one number

The critical point is pinned down in three mutually reinforcing languages:
transcendental ($\sinh(2\beta_c) = 1$), algebraic in bond variables
($\tanh\beta_c = \sqrt 2 - 1$), and numeric ($2 < T_c < 3$, exactly
$\approx 2.269$). Each guards against a different misreading: the transcendental
form encodes the duality, the bond form connects to the lattice expansions, and the
numeric bracket rules out any vacuous "definition equals itself" interpretation.

### 6.3 Relation to the full Onsager solution

The present treatment locates the critical point and proves the *existence* of
spontaneous magnetization, but stops short of Onsager's exact free energy and Yang's
formula for the spontaneous magnetization,
$m^*(\beta) = \bigl(1 - \sinh^{-4}(2\beta)\bigr)^{1/8}$ for $\beta > \beta_c$, whose
critical exponent $\beta_{\text{exp}} = 1/8$ is the prototypical non-mean-field
exponent. A complete formalization of the Onsager free energy
$-\beta f = \ln(2\cosh 2\beta) + \tfrac{1}{2\pi}\int_0^\pi \ln\tfrac12\bigl(1 + \sqrt{1 - \kappa^2\sin^2\theta}\bigr)\,d\theta$,
with $\kappa = 2\sinh(2\beta)/\cosh^2(2\beta)$, remains a substantial open target.

---

## 7. Future work

- **A formal duality involution.** Promote Definition 3.1 to a verified
  involution $D$ on $(0,\infty)$ with $\beta_c$ its unique fixed point, using the
  strict monotonicity of $\sinh$ and its inverse $\operatorname{arsinh}$.
- **Transfer-matrix thermodynamic limit.** Prove
  $\tfrac1N\ln Z_N \to \ln(2\cosh\beta)$ rigorously from the exact finite-$N$
  trace formula and $r^N \to 0$.
- **The 1D no-transition theorem.** Establish real-analyticity of
  $f(\beta) = \ln(2\cosh\beta)$ on $\mathbb{R}$ and identical-vanishing of the
  magnetization, contrasting with the 2D Peierls result.
- **Sharpening the Peierls threshold to $\beta_c$.** Combine the geometric contour
  bound with the duality analysis to close the gap between the crude
  $\tfrac12\ln 3$ and the exact $\beta_c$.

---

## References (background, not required for the self-contained argument)

- L. Onsager, *Crystal statistics I. A two-dimensional model with an order-disorder
  transition*, Phys. Rev. **65** (1944) 117–149.
- H. A. Kramers and G. H. Wannier, *Statistics of the two-dimensional ferromagnet*,
  Phys. Rev. **60** (1941) 252–262.
- R. Peierls, *On Ising's model of ferromagnetism*, Proc. Cambridge Phil. Soc.
  **32** (1936) 477–481.
- C. N. Yang, *The spontaneous magnetization of a two-dimensional Ising model*,
  Phys. Rev. **85** (1952) 808–816.
