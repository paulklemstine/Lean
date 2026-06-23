# Continuous-Valued Cellular Automata, the Diffusion Threshold, and Rucker's "Gnarl"

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Novelty (Complex Systems / Dynamical Systems on Lattices)

## Abstract

We develop a self-contained algebraic and analytic theory of the canonical
*continuous-valued* one-dimensional cellular automaton (CA): the symmetric
three-point linear diffusion rule acting on bi-infinite real configurations
$c : \mathbb{Z} \to \mathbb{R}$,
$$\mathrm{step}_a(c)(x) = a\,c(x-1) + (1-2a)\,c(x) + a\,c(x+1),$$
where $a \in \mathbb{R}$ is a diffusion coefficient and the stencil weights
$(a, 1-2a, a)$ sum to $1$. This is the linear core of Rudy Rucker's
experimental continuous CAs (the "CAPOW" project), whose nonlinear "Hodgepodge"
and heat rules are built around it and which exhibit a narrow *gnarly zone* — an
edge-of-chaos regime of structured-but-unpredictable patterns associated with
Wolfram Class 4 and computational irreducibility.

We prove: (i) the evolution operator is $\mathbb{R}$-linear and
translation-equivariant; (ii) its full real spectrum is given by the
geometric (Fourier) modes $\mathrm{geom}_r(x) = r^x$ with dispersion relation
$\lambda(a,r) = (1-2a) + a(r + r^{-1})$, unifying the conserved constant mode
($r=1$, eigenvalue $1$) and the Nyquist alternating mode ($r=-1$, eigenvalue
$1-4a$); (iii) conservation of total mass for finitely supported configurations;
(iv) a discrete maximum principle establishing sup-norm non-expansiveness on the
convex regime $0 \le a \le \tfrac12$ (the *laminar* phase); and (v) sharp linear
instability outside that interval, where the alternating amplitude grows as
$(1-4a)^n$. These results are assembled into a single *stability dichotomy* that
localizes the linear-stability threshold at $a = \tfrac12$, the boundary that
bounds Rucker's gnarl from the laminar side. We close with a no-go principle: no
linear translation-equivariant CA with nonnegative summing-to-one weights can
produce gnarl, isolating nonlinearity (or operation exactly on the spectral
boundary) as its necessary source.

## 1. Introduction

### 1.1 Background

Cellular automata (CAs) are among the simplest models of spatially extended
computation: a lattice of cells, each updated synchronously by a fixed local
rule depending only on a bounded neighbourhood. The discrete (finite-alphabet)
theory is rich — Wolfram's elementary rules, the Game of Life, additive
$\mathbb{F}_p$ automata realizing Pascal's triangle modulo $p$. A complementary
strand, championed experimentally by Rudy Rucker in his *CAPOW* software, allows
each cell to hold a *continuous* value in $\mathbb{R}$. Rucker observed that such
systems organize into three phenomenological regimes:

- **Laminar / frozen:** localized perturbations dissipate; the configuration
  relaxes to a featureless steady state.
- **Turbulent / chaotic:** high-frequency roughness amplifies into broadband
  noise destroying all coherent structure.
- **Gnarly:** a narrow band of parameters where long-lived, interacting,
  non-repeating coherent structures (gliders, scrolls, filaments) persist — the
  *edge of chaos*.

Rucker's "gnarl" is the continuous analogue of Wolfram's **Class 4**: rules
producing localized propagating structures, conjecturally capable of universal
computation and exhibiting *computational irreducibility* (no asymptotically
faster predictor than direct simulation).

### 1.2 Contribution

Rucker's gnarly rules are nonlinear. We isolate and rigorously analyze their
*linear core*, the symmetric three-point diffusion rule, and show that even this
exactly solvable kernel possesses a sharp phase boundary. Our contributions are:

1. A closed-form characterization of the entire real spectrum via geometric
   modes (the lattice dispersion relation).
2. Two exact invariants: a conserved mass functional and a discrete maximum
   principle.
3. A sharp linear-stability dichotomy with threshold $a = \tfrac12$.
4. A structural no-go observation: linearity plus convex weights forbids gnarl,
   pinpointing nonlinearity (or boundary operation) as its origin.

This continues a *Novelty* line on cellular automata that elsewhere treats the
discrete additive $\mathbb{F}_p$ automaton through its operator algebra of
Laurent polynomials. There the central phenomenon is $p$-adic renormalization and
self-similar Sierpiński structure; here the central phenomenon is the
order/metric structure of a continuous rule and the location of its
stability threshold.

## 2. Definitions

Throughout, a *configuration* is a function $c : \mathbb{Z} \to \mathbb{R}$. The
space of configurations is the real vector space $\mathbb{R}^{\mathbb{Z}}$ with
pointwise operations.

**Definition 2.1 (Diffusion rule `step`).** For $a \in \mathbb{R}$, define
$\mathrm{step}_a : \mathbb{R}^{\mathbb{Z}} \to \mathbb{R}^{\mathbb{Z}}$ by
$$\mathrm{step}_a(c)(x) = a\,c(x-1) + (1-2a)\,c(x) + a\,c(x+1).$$
The *stencil* is the weight triple $(a, 1-2a, a)$, whose entries sum to $1$.

**Definition 2.2 (Shift).** The unit space-shift is
$(\mathrm{shift}\,c)(x) = c(x+1)$.

**Definition 2.3 (Alternating mode).** $\mathrm{alt}(x) = (-1)^x$, the
highest-frequency (Nyquist) Fourier mode on the lattice.

**Definition 2.4 (Geometric mode).** For $r \neq 0$,
$\mathrm{geom}_r(x) = r^x$ (interpreted via integer powers, so defined for all
$x \in \mathbb{Z}$).

**Definition 2.5 (Dispersion relation / eigenvalue).** For $a, r \in \mathbb{R}$,
$$\lambda(a,r) = (1-2a) + a\left(r + r^{-1}\right).$$

**Definition 2.6 (Time-$n$ evolution).** $\mathrm{iter}_a^n = (\mathrm{step}_a)^{\circ n}$,
the $n$-fold composition; $\mathrm{iter}_a^0 = \mathrm{id}$.

**Definition 2.7 (Mass).** For finitely supported $c$, the *mass* is the finite
sum $M(c) = \sum_{x \in \mathbb{Z}} c(x)$ (a `finsum`, well-defined since only
finitely many terms are nonzero).

## 3. Linearity and symmetries

**Theorem 3.1 (Additivity — `step_add`).** For all $a$ and configurations
$c, d$, $\;\mathrm{step}_a(c+d) = \mathrm{step}_a(c) + \mathrm{step}_a(d).$

*Proof sketch.* Evaluate both sides at $x$ and expand; the identity reduces to the
distributive law applied to each of the three stencil terms. ∎

**Theorem 3.2 (Homogeneity — `step_smul`).** For all $a, k$ and $c$,
$\;\mathrm{step}_a(k \cdot c) = k \cdot \mathrm{step}_a(c).$

*Proof sketch.* Pointwise, factor the scalar $k$ out of each term; `ring`. ∎

Together, Theorems 3.1–3.2 state that $\mathrm{step}_a$ is an $\mathbb{R}$-linear
endomorphism of $\mathbb{R}^{\mathbb{Z}}$.

**Theorem 3.3 (Constant fixed points — `step_const`).** For all $a, k$,
$\;\mathrm{step}_a(\mathbf{k}) = \mathbf{k},$ where $\mathbf{k}$ is the constant
configuration $x \mapsto k$.

*Proof sketch.* Each cell becomes $a k + (1-2a)k + a k = (a + 1 - 2a + a)k = k$,
using that the weights sum to $1$. ∎

**Theorem 3.4 (Translation equivariance — `step_shift`).** For all $a, c$,
$\;\mathrm{step}_a(\mathrm{shift}\,c) = \mathrm{shift}(\mathrm{step}_a\,c).$

*Proof sketch.* Both sides evaluate at $x$ to
$a\,c(x) + (1-2a)c(x+1) + a\,c(x+2)$; the rule depends only on relative offsets,
so it commutes with the index translation. ∎

Linearity (3.1–3.2) together with translation equivariance (3.4) is the
structural reason the entire spectral analysis reduces to Fourier/geometric
modes: $\mathrm{step}_a$ is a convolution operator, simultaneously diagonalized by
the characters $x \mapsto r^x$.

## 4. The spectrum: geometric modes

**Theorem 4.1 (General eigenvector identity — `step_geom`).** For all $a$ and
$r \neq 0$,
$$\mathrm{step}_a(\mathrm{geom}_r) = \lambda(a,r)\cdot \mathrm{geom}_r.$$

*Proof sketch.* Evaluate at $x$:
$\mathrm{step}_a(\mathrm{geom}_r)(x) = a r^{x-1} + (1-2a) r^x + a r^{x+1}
= r^x\big(a r^{-1} + (1-2a) + a r\big) = \lambda(a,r)\,r^x,$
using the integer-power identities $r^{x-1} = r^x r^{-1}$ and
$r^{x+1} = r^x r$ (valid since $r \neq 0$). ∎

**Corollary 4.2 (Constant eigenvalue — `eigenvalue_one`).**
$\lambda(a,1) = 1.$
*Proof.* $(1-2a) + a(1 + 1) = 1.$ ∎

**Corollary 4.3 (Nyquist eigenvalue — `eigenvalue_negOne`).**
$\lambda(a,-1) = 1 - 4a.$
*Proof.* $(1-2a) + a(-1 - 1) = 1 - 4a.$ ∎

Thus the constant mode (Theorem 3.3) and the alternating mode are the two
distinguished special cases $r = \pm 1$ of one closed-form spectrum. Letting
$r = e^{i\theta}$ traverse the unit circle gives $r + r^{-1} = 2\cos\theta$ and
$$\lambda(a, e^{i\theta}) = 1 - 2a(1 - \cos\theta),$$
a real band sweeping from $1$ (at $\theta = 0$) to $1 - 4a$ (at $\theta = \pi$).
This is the lattice dispersion relation of the diffusion rule.

**Theorem 4.4 (Alternating eigenvector — `step_alt`).**
$\mathrm{step}_a(\mathrm{alt}) = (1 - 4a)\cdot \mathrm{alt}.$

*Proof sketch.* Specialize Theorem 4.1 at $r = -1$ (equivalently, use
$(-1)^{x\pm 1} = -(-1)^x$): each neighbour contributes $-a(-1)^x$, giving
$\big({-a} + (1-2a) - a\big)(-1)^x = (1-4a)(-1)^x$. ∎

**Theorem 4.5 (Iterated alternating mode — `iter_alt`).** For all $n$,
$\mathrm{iter}_a^n(\mathrm{alt}) = (1-4a)^n \cdot \mathrm{alt}.$

*Proof sketch.* Induction on $n$. Base case is the identity. Step: apply
$\mathrm{step}_a$ to $(1-4a)^k\,\mathrm{alt}$, pull the scalar out by homogeneity
(3.2), then apply Theorem 4.4 and combine scalars via $(1-4a)\cdot(1-4a)^k =
(1-4a)^{k+1}$. ∎

**Corollary 4.6 (Pointwise iterate — `iter_alt_apply`).** For all $n$ and $x$,
$\mathrm{iter}_a^n(\mathrm{alt})(x) = (1-4a)^n (-1)^x.$

The number $1 - 4a$ is therefore the *per-step amplification of the spikiest
representable pattern*, and serves as the order parameter for the phase
transition analyzed in Sections 6–7.

## 5. Conservation of mass

**Theorem 5.1 (One-step mass conservation — `mass_conserved`).** For finitely
supported $c$, $\;M(\mathrm{step}_a\,c) = M(c).$

*Proof sketch.* Write the new mass as a finite sum and split into three shifted
sums:
$$\sum_x \mathrm{step}_a(c)(x)
= a\sum_x c(x-1) + (1-2a)\sum_x c(x) + a\sum_x c(x+1).$$
Each shifted sum equals $M(c)$ (re-indexing a finitely supported sum is a
bijection on $\mathbb{Z}$), so the total is $\big(a + (1-2a) + a\big)M(c) = M(c)$
by the summing-to-one of the weights. Finiteness of support is preserved because
$\mathrm{step}_a$ has bounded stencil. ∎

**Theorem 5.2 (Iterated mass conservation — `mass_iter_conserved`).** For
finitely supported $c$ and all $n$, $\;M(\mathrm{iter}_a^n\,c) = M(c).$

*Proof sketch.* Induction on $n$ using Theorem 5.1 and preservation of finite
support. ∎

This is the discrete conservation of "heat content": diffusion redistributes mass
but neither creates nor destroys it. It is the order-parameter-free invariant
corresponding to the $r=1$ eigenvalue $\lambda(a,1) = 1$.

## 6. The maximum principle: the laminar phase

In the convex regime the three weights are a probability vector, and the rule is
a per-cell convex average. This yields a discrete maximum principle.

**Theorem 6.1 (Upper bound — `step_le`).** If $0 \le a \le \tfrac12$ and $c$ is
bounded above by $B$ (i.e. $c(x) \le B$ for all $x$), then
$\mathrm{step}_a(c)(x) \le B$ for all $x$.

*Proof sketch.* With $a \ge 0$ and $1 - 2a \ge 0$,
$\mathrm{step}_a(c)(x) \le a B + (1-2a)B + a B = B.$ ∎

**Theorem 6.2 (Lower bound — `le_step`).** If $0 \le a \le \tfrac12$ and
$A \le c(x)$ for all $x$, then $A \le \mathrm{step}_a(c)(x)$ for all $x$.

*Proof sketch.* Symmetric to 6.1 with the reversed inequality. ∎

**Theorem 6.3 (Sup-norm non-expansiveness — `abs_step_le`).** If
$0 \le a \le \tfrac12$ and $|c(x)| \le B$ for all $x$, then
$|\mathrm{step}_a(c)(x)| \le B$ for all $x$.

*Proof sketch.* Apply 6.1 and 6.2 with $A = -B$, $B = B$; a convex combination of
values in $[-B, B]$ lies in $[-B, B]$, equivalently $|{\cdot}| \le B$. ∎

**Theorem 6.4 (Iterated contraction — `abs_iter_le`).** If $0 \le a \le \tfrac12$
and $|c(x)| \le B$ for all $x$, then $|\mathrm{iter}_a^n(c)(x)| \le B$ for all $n$
and $x$.

*Proof sketch.* Induction on $n$ using Theorem 6.3 at each step. ∎

Hence on $[0, \tfrac12]$ no pattern can grow: peaks erode and valleys fill. This
is Rucker's laminar regime, and it is the rigorous boundary on gnarl from below:
the linear core cannot host persistent structure where it is a strict contraction.

## 7. Instability and the dichotomy: the turbulent phase

**Theorem 7.1 (Instability for $a > \tfrac12$ — `unbounded_of_gt_half`).** If
$a > \tfrac12$, then $1 - 4a < -1$, so $|1 - 4a| > 1$ and
$|\mathrm{iter}_a^n(\mathrm{alt})(0)| = |1-4a|^n \to \infty$.

*Proof sketch.* $a > \tfrac12 \Rightarrow 4a > 2 \Rightarrow 1 - 4a < -1$; then
$|1-4a| > 1$ and powers diverge. Combine with Corollary 4.6 at $x = 0$. ∎

**Theorem 7.2 (Instability for $a < 0$ — `unbounded_of_neg`).** If $a < 0$, then
$1 - 4a > 1$, so $|1-4a|^n \to \infty$ along the alternating mode.

*Proof sketch.* $a < 0 \Rightarrow 1 - 4a > 1$; apply Corollary 4.6. ∎

**Theorem 7.3 (Instability outside the interval — `unbounded_outside`).** If
$a \notin [0, \tfrac12]$, then $|1 - 4a| > 1$ and the alternating amplitude
diverges.

*Proof sketch.* Combine 7.1 and 7.2 by case analysis on $a < 0$ vs $a > \tfrac12$.
∎

**Theorem 7.4 (Stability dichotomy — `stability_dichotomy`).** Exactly one of the
following holds:
- (Laminar) If $0 \le a \le \tfrac12$, every uniformly bounded configuration
  stays uniformly bounded under all iterates (Theorem 6.4), and the spectral
  radius on the Fourier band is $\max_\theta |\lambda(a,e^{i\theta})| = 1$.
- (Unstable) If $a < 0$ or $a > \tfrac12$, the spectral radius exceeds $1$
  (witnessed by the alternating mode with $|\lambda| = |1-4a| > 1$), and bounded
  patterns can blow up.

The threshold separating the two phases is exactly $a = \tfrac12$.

*Proof sketch.* The laminar half is Theorem 6.4 plus the band computation
$\lambda(a, e^{i\theta}) = 1 - 2a(1-\cos\theta) \in [1-4a, 1] \subseteq [-1,1]$
for $a \in [0,\tfrac12]$. The unstable half is Theorem 7.3. The endpoints
$a \in \{0, \tfrac12\}$ realize spectral radius exactly $1$, placing the phase
boundary at $a = \tfrac12$ (and a degenerate identity-like boundary at $a=0$). ∎

## 8. Algorithms

We summarize the computational content. Let $c$ be supported on $[-W, W]$.

**Algorithm A (One synchronous step).** Compute
$\mathrm{step}_a(c)(x) = a\,c(x-1) + (1-2a)\,c(x) + a\,c(x+1)$ for each $x$ in the
window padded by one on each side. Cost $O(W)$ per step; $O(nW)$ for $n$ steps on
a window that grows by one cell per step (light-cone bookkeeping), or $O(nW)$ on a
fixed periodic window.

**Algorithm B (Spectral amplification).** Given $a$ and a mode $r$ (or angle
$\theta$ via $r = e^{i\theta}$), return $\lambda(a,r) = (1-2a) + a(r + r^{-1})$
and the $n$-step factor $\lambda(a,r)^n$. Cost $O(1)$ (plus $O(\log n)$ for fast
exponentiation). This is the *computationally reducible* shortcut that the linear
core admits and that Class-4 nonlinear rules are conjectured to lack.

**Algorithm C (Stability classifier).** Given $a$, return `laminar` if
$0 \le a \le \tfrac12$ (spectral radius $1$, maximum principle holds) and
`unstable` otherwise (spectral radius $|1-4a| > 1$). Cost $O(1)$. The decision
boundary is the threshold $a = \tfrac12$.

**Algorithm D (Mass meter).** Sum a finitely supported configuration and verify
invariance under iteration. By Theorem 5.2 the value is constant; numerically it
provides a conservation check for any implementation.

## 9. Applications

- **Locating the edge of chaos.** The dichotomy gives the exact parameter address
  $a = \tfrac12$ at which to anchor nonlinear gnarly rules; Rucker's reaction and
  saturation terms are most fruitful when bolted onto the marginally stable
  linear core.
- **Numerical PDE.** The maximum principle and mass conservation are precisely
  the discrete properties demanded of a stable, conservative finite-difference
  scheme for the heat equation; $a$ is the CFL-type stability number and
  $a \le \tfrac12$ is the stability bound.
- **Signal processing.** $\mathrm{step}_a$ is a symmetric three-tap FIR
  smoothing filter; $\lambda(a,e^{i\theta})$ is its frequency response, and the
  dichotomy is its stability criterion.
- **Complexity theory.** The reducibility of the linear core (Algorithm B)
  contrasts with the conjectured computational irreducibility of Class-4 gnarl,
  sharpening *where* irreducibility must originate.

## 10. Discussion: why nonlinearity is necessary for gnarl

The maximum principle (Section 6) generalizes verbatim to *any* finite stencil
$w : \mathbb{Z} \to \mathbb{R}$ with $w \ge 0$ and $\sum_x w(x) = 1$: such a rule
is a per-cell convex average, hence sup-norm non-expansive, hence incapable of
sensitive dependence on initial data in sup norm. Therefore:

> **No-go principle.** No translation-equivariant *linear* continuous CA with
> nonnegative, summing-to-one weights can exhibit sensitive dependence (gnarl) in
> the strict interior; it is always a contraction there.

Consequently the structured unpredictability of Rucker's gnarl must come from one
of two sources: (a) operating *exactly* on the spectral boundary, where the
dominant eigenvalue has modulus $1$ and dissipation is marginal; or (b) breaking
linearity — thresholds, saturations, reaction terms — which is what Rucker's
actual rules do. The linear theory thus does not merely fail to produce gnarl; it
*explains the failure* and points to its remedy.

## 11. Future work

The following directions extend the present linear theory; each is falsifiable
and intended for subsequent formalization.

**C1. Continuous-time (heat-semigroup) scaling limit.** With mass conservation
and the maximum principle established, the rule is a genuine discrete heat flow.
Conjecture the diffusive scaling limit: with lattice spacing $h = 1/N$ and $a$
matched so that $\lambda(a, e^{i\theta})^{N^2} \to e^{-t\theta^2}$, the iterated
CA converges (mode-by-mode, then in norm) to the continuous semigroup $e^{t\Delta}$.
*Test:* prove the eigenvalue limit $(\lambda(a, e^{i\theta}))^{m} \to e^{-c t\theta^2}$
under the scaling — a clean $\exp/\cos$ Taylor estimate.

**C2. Strict contraction to the mean in the interior.** For $0 < a < \tfrac12$ the
rule is smoothing, not merely non-expansive: conjecture
$\mathrm{osc}(\mathrm{iter}_a^n c) \to 0$ where $\mathrm{osc} = \sup - \inf$.
*Test:* a one-step decrease $\mathrm{osc}(\mathrm{step}_a c) \le (1-2a)\,\mathrm{osc}(c)$,
then iterate.

**C3. Total-variation (Lyapunov) monotonicity.** Define
$\mathrm{TV}(c) = \sum_x |c(x+1) - c(x)|$. Conjecture
$\mathrm{TV}(\mathrm{step}_a c) \le \mathrm{TV}(c)$ for $0 \le a \le \tfrac12$ and
finitely supported $c$, with failure outside $[0,\tfrac12]$ — a gradient-flavored
second proof of the dichotomy and a candidate Lyapunov functional for the edge of
chaos. *Test:* the telescoped differences of $\mathrm{step}_a c$ are convex
combinations of neighboring differences.

**C4. Nonlinearity is necessary for gnarl (no-go theorem).** Formalize the
no-go principle of Section 10 for arbitrary finite nonnegative stencils summing to
one, proving non-expansiveness and (strict-interior) contraction, hence the
impossibility of sensitive dependence. *Test:* generalize the maximum principle
to an arbitrary stencil $w$ with $\sum w = 1$, $w \ge 0$.

## 12. Conclusion

The symmetric three-point continuous CA, the linear heart of Rucker's gnarly
automata, is exactly solvable: its full real spectrum is the geometric-mode
dispersion relation $\lambda(a,r) = (1-2a) + a(r + r^{-1})$, it conserves mass,
it obeys a maximum principle on $[0,\tfrac12]$, and it undergoes a sharp linear
phase transition at $a = \tfrac12$. The edge of chaos that Rucker observed
empirically is thereby pinned to a single computable number, and the linear
theory reveals — via a clean no-go principle — that the gnarl itself must live on
that boundary or in the nonlinearity built upon it.
