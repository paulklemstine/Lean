# The One-Dimensional Ising Model: Exact Partition Function, Thermodynamic Limit, and the Rigorous Absence of a Phase Transition

**Author:** Aristotle

**Date:** 2026-06-25

**Domain:** Statistical Mechanics / Probability

---

## Abstract

We give a complete, first-principles treatment of the one-dimensional Ising model
with free (open) boundary conditions, working directly from the sum over spin
configurations rather than from any postulated transfer-operator formalism. We
prove an exact closed form for the partition function,
$Z_n = 2\,(2\cosh(\beta J))^{n}$, for a chain of $n$ bonds at inverse temperature
$\beta$ and nearest-neighbor coupling $J$. The proof is a genuine induction over
chain length, built on the observation that summing a single boundary spin yields
the transfer-matrix eigenvalue $2\cosh(\beta J)$ independently of its neighbor — a
consequence of the parity of $\cosh$. From the closed form we establish the
existence of the thermodynamic limit of the free energy density,
$\frac{1}{n+1}\log Z_n \to \log(2\cosh(\beta J))$, and we prove that this limiting
free energy density is $C^\infty$ (indeed real-analytic) on all of $\mathbb{R}$.
Smoothness at every temperature is precisely the rigorous statement that the 1D
Ising model exhibits **no phase transition** at any positive temperature. We
contextualize the result against the two-dimensional model, whose Onsager critical
temperature $T_c = 2J/\big(k_B\ln(1+\sqrt 2)\big)$ marks a genuine singularity,
and we discuss the transfer-matrix, correlation, and mean-field extensions that
sharpen the dichotomy between dimensions. All results are stated with full
mathematical detail and accompanied by proof sketches.

---

## 1. Introduction

The Ising model, introduced by Lenz and studied by Ising in his 1925
dissertation, is the canonical lattice model of cooperative behavior. Spins
$\sigma_i \in \{+1, -1\}$ occupy the sites of a graph and interact
ferromagnetically with their nearest neighbors. Despite its disarming simplicity,
the model encodes the central drama of statistical mechanics: the competition
between energetic order and entropic disorder, and the possibility of a sharp
**phase transition** between an ordered (magnetized) and a disordered
(paramagnetic) regime.

A phase transition is identified mathematically with a loss of analyticity of the
free energy density in the thermodynamic limit. The fundamental question for any
Ising geometry is therefore: *is the limiting free energy density a smooth
function of temperature, or does it develop a singularity?*

In one dimension the answer is negative — there is no transition at positive
temperature — a fact discovered by Ising himself. In two dimensions the answer is
affirmative, as Onsager's celebrated 1944 exact solution showed, with a transition
at $T_c = 2J/\big(k_B\ln(1+\sqrt 2)\big)$. The gulf between these two outcomes,
produced by the same local interaction on lattices differing only in
dimension, is one of the most instructive phenomena in mathematical physics.

This paper provides a rigorous, self-contained derivation of the 1D result. Our
emphasis is on deriving everything from the raw configuration sum, so that the
transfer-matrix eigenvalue $2\cosh(\beta J)$ *emerges* from the combinatorics
rather than being imposed. We then read off the no-transition theorem as a
statement about the smoothness of $\log(2\cosh(\beta J))$.

### Summary of contributions

- **Theorem (exact partition function).** $Z_n = 2\,(2\cosh(\beta J))^n$, proved
  by induction on chain length (`Zfree_closed`).
- **Lemma (transfer recursion).** $Z_{n+1} = (2\cosh(\beta J))\, Z_n$
  (`Zfree_succ`), resting on the boundary-spin sum lemma `sum_bool_exp`.
- **Theorem (thermodynamic limit).**
  $\frac{1}{n+1}\log Z_n \to \log(2\cosh(\beta J))$ (`free_energy_density_limit`).
- **Theorem (no phase transition).** $\beta \mapsto \log(2\cosh(\beta J))$ is
  $C^\infty$ on all of $\mathbb{R}$ (`free_energy_smooth`).

---

## 2. Definitions and setup

### 2.1 Spins and configurations

We index a chain of $n+1$ sites by $\{0, 1, \dots, n\}$, formally the finite type
$\mathrm{Fin}(n+1)$. To exploit the two-valued nature of a spin we represent a
configuration as a Boolean assignment

$$s : \mathrm{Fin}(n+1) \to \{\mathrm{true}, \mathrm{false}\},$$

and convert to physical spin values via the **spin map**

$$\mathrm{sp}(b) = \begin{cases} +1 & b = \mathrm{true},\\ -1 & b = \mathrm{false}.\end{cases}$$

There are exactly $2^{n+1}$ configurations.

### 2.2 Energy, Boltzmann weight, and partition function

With inverse temperature $\beta$ and ferromagnetic coupling $J$, the
nearest-neighbor, zero-field energy of a configuration is
$E(s) = -J\sum_{i=0}^{n-1}\mathrm{sp}(s_i)\,\mathrm{sp}(s_{i+1})$, and its
Boltzmann weight $e^{-\beta E(s)}$ factorizes over the $n$ bonds of the open chain:

$$W(s) = \prod_{i=0}^{n-1} \exp\!\big(\beta J \,\mathrm{sp}(s_i)\,\mathrm{sp}(s_{i+1})\big).$$

The **free-boundary partition function** is the sum of these weights over all
configurations:

$$\boxed{\;Z_n(\beta, J) \;=\; \sum_{s : \mathrm{Fin}(n+1) \to \mathrm{Bool}}\;
   \prod_{i : \mathrm{Fin}\,n} \exp\!\big(\beta J\, \mathrm{sp}(s_{i})\,\mathrm{sp}(s_{i+1})\big).\;}$$

Here a chain of $n+1$ sites has $n$ bonds; the product runs over the $n$ edges and
the sum runs over all $2^{n+1}$ Boolean assignments. We write $Z_n$ for
$Z_n(\beta, J)$ when the parameters are clear.

### 2.3 Free energy density

The **free energy density** (free energy per site, in units absorbing $-1/\beta$)
is

$$f_n(\beta, J) = \frac{1}{n+1}\log Z_n(\beta, J),$$

and we study its limit as $n \to \infty$.

---

## 3. The transfer-matrix mechanism from first principles

The technical heart of the exact solution is that a single boundary spin can be
summed out to produce a factor independent of the neighboring spin.

### 3.1 Parity of the hyperbolic cosine

**Lemma 1 (`cosh_mul_sp`).** *For every $c \in \mathbb{R}$ and every spin
$b \in \{\mathrm{true}, \mathrm{false}\}$,*
$$\cosh(c \cdot \mathrm{sp}(b)) = \cosh(c).$$

*Proof sketch.* If $b = \mathrm{true}$ then $\mathrm{sp}(b) = 1$ and the claim is
trivial. If $b = \mathrm{false}$ then $\mathrm{sp}(b) = -1$ and the claim is the
evenness of $\cosh$: $\cosh(-c) = \cosh(c)$. $\qquad\blacksquare$

### 3.2 Summing a boundary spin

**Lemma 2 (`sum_bool_exp`).** *For every $c \in \mathbb{R}$ and every fixed
neighbor spin $b' \in \{\mathrm{true}, \mathrm{false}\}$,*
$$\sum_{b \in \{\mathrm{true}, \mathrm{false}\}} \exp\!\big(c\, \mathrm{sp}(b)\, \mathrm{sp}(b')\big) = 2\cosh(c).$$
*In particular the right-hand side does not depend on $b'$.*

*Proof sketch.* Expand the two-element Boolean sum and use
$\cosh(x) = \tfrac12(e^x + e^{-x})$. With $b'$ fixed, the two terms are
$e^{c\,\mathrm{sp}(b')}$ and $e^{-c\,\mathrm{sp}(b')}$, whose sum is
$2\cosh(c\,\mathrm{sp}(b')) = 2\cosh(c)$ by Lemma 1. Both cases
$b' = \mathrm{true}, \mathrm{false}$ give the same value, confirming independence
of the neighbor. $\qquad\blacksquare$

This independence is the precise reason the recursion has a *constant* multiplier
and hence the model is exactly solvable.

### 3.3 Factorization of the weight under prepending a spin

To run an induction that peels off site $0$, we record how the Boltzmann weight
behaves when a spin $b$ is prepended to a configuration $t$ of the shorter chain.
Write $\mathrm{cons}(b, t)$ for the configuration on $\mathrm{Fin}(n+2)$ obtained
by placing $b$ at site $0$ and shifting $t$ into sites $1, \dots, n+1$.

**Lemma 3 (`weight_cons`).** *For all $\beta, J$, all $n$, all spins $b$, and all
$t : \mathrm{Fin}(n+1) \to \mathrm{Bool}$,*
$$\prod_{i : \mathrm{Fin}(n+1)} \exp\!\big(\beta J\,\mathrm{sp}(\mathrm{cons}(b,t)_i)\,\mathrm{sp}(\mathrm{cons}(b,t)_{i+1})\big)
= \exp\!\big(\beta J\,\mathrm{sp}(b)\,\mathrm{sp}(t_0)\big)\;\prod_{i : \mathrm{Fin}\,n} \exp\!\big(\beta J\,\mathrm{sp}(t_i)\,\mathrm{sp}(t_{i+1})\big).$$

*Proof sketch.* Split the product over $\mathrm{Fin}(n+2)$ edges into the first
edge (between sites $0$ and $1$) and the rest. The first edge connects the new
spin $b$ with $t_0$, giving the factor $\exp(\beta J\,\mathrm{sp}(b)\,\mathrm{sp}(t_0))$.
The remaining edges, after re-indexing, are exactly the $n$ bonds of $t$, because
$\mathrm{cons}(b,t)$ agrees with $t$ on the shifted sites. $\qquad\blacksquare$

### 3.4 The transfer recursion

**Lemma 4 (`Zfree_succ`).** *For all $\beta, J$ and all $n$,*
$$Z_{n+1}(\beta, J) = \big(2\cosh(\beta J)\big)\, Z_n(\beta, J).$$

*Proof sketch.* Reindex the configuration sum over $\mathrm{Fin}(n+2)$ by the
equivalence $\mathrm{Bool} \times (\mathrm{Fin}(n+1) \to \mathrm{Bool}) \cong
(\mathrm{Fin}(n+2) \to \mathrm{Bool})$ that splits off the first spin $b$ from the
tail $t$. Apply Lemma 3 to factor the weight as
$\exp(\beta J\,\mathrm{sp}(b)\,\mathrm{sp}(t_0))\cdot W(t)$. Summing over $b$ first,
Lemma 2 turns the leading factor into the constant $2\cosh(\beta J)$, which pulls
out of the sum over $t$, leaving exactly $Z_n$. $\qquad\blacksquare$

---

## 4. Exact partition function and positivity

### 4.1 Base case

**Lemma 5 (`Zfree_zero`).** $Z_0(\beta, J) = 2.$

*Proof sketch.* A chain of zero bonds is a single site with two spin states and an
empty product of bond weights (each empty product equals $1$); summing over the
two states gives $2$. $\qquad\blacksquare$

### 4.2 Closed form

**Theorem 6 (`Zfree_closed`).** *For all $\beta, J \in \mathbb{R}$ and all
$n \in \mathbb{N}$,*
$$\boxed{\,Z_n(\beta, J) = 2\,\big(2\cosh(\beta J)\big)^n.\,}$$

*Proof sketch.* Induct on $n$. The base case $n = 0$ is Lemma 5:
$Z_0 = 2 = 2\,(2\cosh(\beta J))^0$. For the inductive step, Lemma 4 gives
$Z_{n+1} = (2\cosh(\beta J))\,Z_n = (2\cosh(\beta J))\cdot 2(2\cosh(\beta J))^n
= 2(2\cosh(\beta J))^{n+1}$. $\qquad\blacksquare$

This single identity replaces a sum over $2^{n+1}$ terms by one elementary
expression, valid at every temperature and every chain length.

### 4.3 Positivity

**Theorem 7 (`Zfree_pos`).** *For all $\beta, J$ and all $n$,
$Z_n(\beta, J) > 0$.*

*Proof sketch.* By Theorem 6, $Z_n = 2(2\cosh(\beta J))^n$. Since $\cosh > 0$
everywhere, the base $2\cosh(\beta J)$ is positive, its $n$-th power is positive,
and twice it is positive. (Equivalently, the partition function is a finite sum of
strictly positive Boltzmann weights.) Positivity is what makes $\log Z_n$
well-defined for every parameter value. $\qquad\blacksquare$

---

## 5. The thermodynamic limit

**Theorem 8 (`free_energy_density_limit`).** *For all $\beta, J \in \mathbb{R}$,*
$$\lim_{n\to\infty} \frac{1}{n+1}\log Z_n(\beta, J) = \log\!\big(2\cosh(\beta J)\big).$$

*Proof sketch.* Set $L = \log(2\cosh(\beta J))$, which is well-defined because
$2\cosh(\beta J) > 0$. Using Theorem 6 and $\log(ab) = \log a + \log b$,
$\log(x^n) = n\log x$, we decompose, for each $n$,
$$\frac{1}{n+1}\log Z_n = \frac{1}{n+1}\log 2 + \frac{n}{n+1}\,L.$$
As $n \to \infty$, the first term tends to $0$ (it is $\log 2$ times $1/(n+1) \to 0$)
and the coefficient $n/(n+1) \to 1$, so the second term tends to $L$. Summing the
two limits gives $L$. $\qquad\blacksquare$

The boundary term $\frac{1}{n+1}\log 2$ is the only finite-size correction; it
encodes the leftover, weakly-constrained boundary spin and is irrelevant in the
bulk. The limit $\log(2\cosh(\beta J))$ is the genuine bulk free energy density of
the infinite chain.

---

## 6. The main result: absence of a phase transition

**Theorem 9 (`free_energy_smooth`).** *For every fixed $J \in \mathbb{R}$, the
limiting free energy density*
$$f(\beta) = \log\!\big(2\cosh(\beta J)\big)$$
*is $C^\infty$ (infinitely differentiable, indeed real-analytic) on all of
$\mathbb{R}$.*

*Proof sketch.* The map $\beta \mapsto \beta J$ is linear, hence smooth.
Composition with $\cosh$, which is smooth (real-analytic) everywhere, gives a
smooth function $\beta \mapsto \cosh(\beta J)$. This function is strictly positive
everywhere (Lemma 1 region: $\cosh > 0$), so it stays inside the domain where
$\log$ is smooth. Composition of smooth maps is smooth; multiplying the argument
by the constant $2$ does not affect smoothness. Therefore
$f(\beta) = \log(2\cosh(\beta J))$ is $C^\infty$ on all of $\mathbb{R}$.
$\qquad\blacksquare$

### 6.1 Interpretation

A phase transition is, by definition, a point of non-analyticity of the
thermodynamic free energy density as a function of an external control parameter,
here the inverse temperature $\beta$. Theorem 9 asserts that $f(\beta)$ has **no
such point**: it is smooth, with all derivatives existing, for every real $\beta$,
in particular for every positive temperature $T = 1/(k_B\beta) > 0$. Hence the 1D
Ising model has no phase transition at any positive temperature.

The mechanism is transparent: the dominant transfer eigenvalue $2\cosh(\beta J)$
is a strictly positive, real-analytic function of $\beta$ that never vanishes and
never collides with a competing eigenvalue at finite $\beta$. The logarithm of
such a function is analytic, so the free energy cannot be singular. A genuine
transition would require the dominant eigenvalue to become degenerate (cross
another eigenvalue) at some finite $\beta$; in 1D nearest-neighbor with free
boundaries this never happens.

### 6.2 Physical reading via domain walls

The smoothness can be understood physically through the cost of disorder. Starting
from a fully ordered chain, a domain of flipped spins is bounded in 1D by exactly
two unhappy bonds, an energy cost of $4J$ *independent of the domain size*. There
are $\sim n$ places to insert such a wall, so the entropic gain ($\sim \log n$)
always overwhelms the fixed energy cost at any positive temperature. Order is
therefore destroyed for all $T > 0$, consistent with the analytic free energy.

---

## 7. Algorithms

The exact solution yields trivial, numerically stable algorithms; we record them
for completeness and for the accompanying demonstrations.

### 7.1 Exact partition function (closed form)

**Input:** $\beta, J \in \mathbb{R}$, $n \in \mathbb{N}$.
**Output:** $Z_n = 2(2\cosh(\beta J))^n$.

```
function Z_closed(beta, J, n):
    return 2 * (2 * cosh(beta * J)) ** n
```

Complexity: $O(1)$ arithmetic operations (plus the cost of one $\cosh$ and one
power). This is the entire computational content of the model.

### 7.2 Brute-force partition function (validation)

**Input:** $\beta, J$, $n$.
**Output:** $Z_n$ by direct summation over all $2^{n+1}$ configurations.

```
function Z_bruteforce(beta, J, n):
    total = 0
    for each s in {-1, +1}^(n+1):
        w = 1
        for i in 0 .. n-1:
            w = w * exp(beta * J * s[i] * s[i+1])
        total = total + w
    return total
```

Complexity: $O(n \cdot 2^{n+1})$. Used only to validate the closed form on small
chains; it agrees with $Z_{\text{closed}}$ to machine precision.

### 7.3 Transfer-matrix evaluation

**Input:** $\beta, J$, $n$.
**Output:** $Z_n$ via the $2\times 2$ transfer matrix
$T = \begin{pmatrix} e^{\beta J} & e^{-\beta J}\\ e^{-\beta J} & e^{\beta J}\end{pmatrix}$.

```
function Z_transfer(beta, J, n):
    T = [[exp(bJ), exp(-bJ)], [exp(-bJ), exp(bJ)]]
    v = [1, 1]                      # free boundary: sum over end spins
    for k in 1 .. n:
        v = T @ v
    return sum(v)
```

The eigenvalues of $T$ are $\lambda_+ = 2\cosh(\beta J)$ and
$\lambda_- = 2\sinh(\beta J)$; the free-boundary sum reproduces
$Z_n = 2(2\cosh(\beta J))^n$, while the periodic chain gives
$Z^{\text{per}}_n = \lambda_+^n + \lambda_-^n = (2\cosh\beta J)^n + (2\sinh\beta J)^n$.

---

## 8. Applications and context

### 8.1 The two-dimensional contrast: Onsager

The 1D result acquires its full meaning only beside the 2D one. On the square
lattice, Onsager (1944) showed that the free energy density develops a genuine
singularity at the critical temperature

$$T_c = \frac{2J}{k_B \ln(1+\sqrt 2)} \approx \frac{2.269\,J}{k_B},$$

where the heat capacity diverges logarithmically and spontaneous magnetization
appears below $T_c$. The Peierls argument explains *why*: in 2D the boundary of a
disordered droplet is a closed contour whose energy cost grows with its perimeter,
so large droplets are exponentially suppressed and long-range order survives at low
temperature. The decisive difference from 1D is purely geometric — the cost of a
domain wall scales with system size in 2D but is constant in 1D.

### 8.2 Correlations and correlation length

For the open 1D chain the two-point function is exactly
$\langle \sigma_0 \sigma_r \rangle = (\tanh\beta J)^r$, so connected correlations
decay exponentially with rate $-\log\tanh\beta J$. The associated correlation
length $\xi(\beta) = 1/\log(\coth\beta J)$ is finite for all $\beta < \infty$ and
diverges only as $\beta \to \infty$ ($T \to 0$): criticality in 1D lives at zero
temperature.

### 8.3 Methodological reach

The transfer-matrix principle — replacing an extended sum by repeated
multiplication by a small operator — is ubiquitous: it is the discrete ancestor of
the Feynman path integral, the engine of the forward–backward algorithm for hidden
Markov models, and a standard tool in the numerical renormalization group and
tensor-network methods. The 1D Ising chain is the cleanest place to see the idea in
its entirety.

---

## 9. Discussion

The results above form a tight logical package. The closed form (Theorem 6) is the
single source from which the thermodynamic limit (Theorem 8) and the no-transition
theorem (Theorem 9) flow by elementary analysis. The conceptual payoff is the
identification of the precise object whose analyticity governs the physics: the
dominant transfer eigenvalue $2\cosh(\beta J)$. Its strict positivity and
real-analyticity, with no finite-$\beta$ degeneracy, *is* the absence of a phase
transition.

It is worth stressing what is and is not claimed. We do **not** claim the 1D model
is featureless: it has a perfectly sensible energy, entropy, and a smooth Schottky
peak in its heat capacity. What it lacks is a *singularity* — a point of
non-analyticity — and that absence is exactly Theorem 9. The model orders only in
the strict $T \to 0$ limit, which is a boundary of parameter space rather than an
interior critical point.

---

## 10. Future directions

This research cycle established, fully formally, the exact solution of the
one-dimensional Ising model and the rigorous sense in which it has no phase
transition at any positive temperature, via the open-chain configuration sum:
$Z_n = 2(2\cosh\beta J)^n$, the free-energy-density limit
$\frac{1}{n+1}\log Z_n \to \log(2\cosh\beta J)$, and $C^\infty$-smoothness of the
limiting free energy in $\beta$. A companion periodic-chain treatment via the
transfer matrix yields the spectral decomposition $T^n = \lambda_+^n P_+ +
\lambda_-^n P_-$, the exact $Z^{\text{per}}_n = (2\cosh)^n + (2\sinh)^n$, the same
bulk free energy, and a spectral gap $g = \log(\coth\beta J) > 0$ for all
$\beta, J > 0$ with $g \to 0$ only as $\beta \to \infty$ (criticality at $T=0$).
The following are precise, testable targets for follow-up.

**Conjecture 1 (Transfer trace = configuration sum; the missing bridge).** For the
periodic chain, the transfer-matrix trace equals the cyclic configuration sum:
$\mathrm{trace}(T^n) = \sum_{s : \mathrm{Fin}\,n \to \mathrm{Bool}} \prod_i
\exp(\beta J\,\mathrm{sp}(s_i)\,\mathrm{sp}(s_{i+1}))$ with $i+1$ taken cyclically.
More generally, for any $M : \mathrm{Matrix}\,\iota\,\iota\,\mathbb{R}$,
$\mathrm{trace}(M^n) = \sum_{s : \mathrm{Fin}\,n \to \iota} \prod_i M(s_i, s_{i+1})$.
This closed-walk expansion is the one ingredient currently *defined* rather than
*derived*; proving it would make the periodic result as combinatorially grounded as
the open-chain result.

**Conjecture 2 (Exponential decay of correlations / finite correlation length).**
For the open chain the two-point function is exactly
$\langle\sigma_0\sigma_r\rangle = (\tanh\beta J)^r$, so connected correlations
decay exactly exponentially with rate $-\log\tanh\beta J = g$ (the spectral gap).
Hence there is no long-range order for any $\beta < \infty$. Testable refinement:
the correlation length $\xi(\beta) = 1/g(\beta) = 1/\log(\coth\beta J)$ satisfies
$\xi(\beta) \sim \tfrac12 e^{2\beta J}$ as $\beta \to \infty$.

**Conjecture 3 (Internal energy and heat capacity are bounded and smooth).**
Define $u(\beta) = -\tfrac{d}{d\beta}[\log(2\cosh\beta J)] = -J\tanh(\beta J)$
(energy per site) and $c(\beta) = du/d\beta$. Then $u$ and $c$ are real-analytic on
all of $\mathbb{R}$, $c(\beta) \ge 0$, and $c$ has a single smooth (Schottky)
maximum but no divergence — the hallmark distinguishing 1D (no transition) from 2D
(a log-divergent $c$ at $T_c$). Target: formalize $u, c$ and prove analyticity plus
the global bound.

**Conjecture 4 (Mean-field / Curie–Weiss transition as a contrast).** The
mean-field (Curie–Weiss) self-consistency $m = \tanh(\beta(Jzm + h))$ at $h=0$ has
$m=0$ as its only solution iff $\beta Jz \le 1$, and a nonzero solution iff
$\beta Jz > 1$. Hence the mean-field free energy is non-analytic at
$\beta_c = 1/(Jz)$: a genuine, formalizable phase transition. This isolates *why*
dimensionality and the transfer-matrix gap matter: the 1D gap never closes at
finite $\beta$, but the mean-field fixed-point structure bifurcates.

---

## 11. Conclusion

We have derived, from the raw configuration sum, the exact partition function of
the one-dimensional Ising model, $Z_n = 2(2\cosh\beta J)^n$; established the
thermodynamic limit of its free energy density,
$\frac{1}{n+1}\log Z_n \to \log(2\cosh\beta J)$; and proved that this limiting free
energy is infinitely differentiable on all of $\mathbb{R}$. The last statement is
the rigorous form of the classical fact that the 1D Ising model has no phase
transition at any positive temperature. The result, simple as it is, draws a clean
line: order in a system of locally agreeing agents is not guaranteed by the local
rule alone but by the dimension of the space they inhabit. One dimension is too
small; two, as Onsager showed, is just big enough.
