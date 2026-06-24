# The Self-Dual Critical Point of the Two-Dimensional Ising Model: A Formal Treatment of $\beta_c = \tfrac{1}{2}\log(1+\sqrt{2})$

**Author:** Aristotle

**Date:** 2026-06-23

**Domain:** Probability / Statistical Mechanics

---

## Abstract

The two-dimensional Ising model on the square lattice exhibits a continuous phase transition separating a low-temperature ferromagnetically ordered phase from a high-temperature disordered phase. The exact location of this transition is one of the central results of equilibrium statistical mechanics. We give a self-contained, rigorous account of the *critical inverse temperature*

$$\beta_c = \tfrac{1}{2}\log\!\left(1 + \sqrt{2}\right) \approx 0.4406868,$$

equivalently the critical temperature $T_c = 2/\log(1+\sqrt2) \approx 2.2691853$, characterized by the **Kramers–Wannier self-duality fixed-point condition** $\sinh(2\beta) = 1$. We establish four core facts and their supporting algebraic identities: (i) the reciprocal identity $(1+\sqrt2)^{-1} = \sqrt2 - 1$; (ii) the *critical value* statement $\sinh(2\beta_c) = 1$; (iii) the *uniqueness* statement that any positive $\beta$ solving $\sinh(2\beta) = 1$ equals $\beta_c$; and (iv) the *fixed-point characterization* that for $\beta > 0$, the squared condition $\sinh(2\beta)^2 = 1$ holds if and only if $\beta = \beta_c$. We additionally record the reciprocity $T_c \cdot \beta_c = 1$ and the positivity $\beta_c > 0$. The arguments rest only on elementary properties of the hyperbolic sine — its analytic form, strict monotonicity, and sign on the positive axis — illustrating how the deep statistical-mechanical content of the duality is, at the level of the critical point, captured by a single transcendental equation. We frame the result physically (Boltzmann weights, the Peierls argument for the existence of a transition, and the duality map relating high and low temperature), give complete proof sketches, present numerical demonstrations, and outline a program for formalizing the full duality and finite-volume partition function.

---

## 1. Introduction

The Ising model is the canonical lattice model of cooperative phenomena. Introduced by Wilhelm Lenz and studied in one dimension by Ernst Ising, it assigns to each site of a lattice a binary spin $\sigma_i \in \{-1, +1\}$ and weights configurations by an energy that rewards aligned neighbors. Despite its simplicity it captures the essence of a ferromagnetic phase transition and serves as the prototype for the modern theory of critical phenomena and universality.

In two dimensions on the square lattice, the model is exactly solvable. Lars Onsager's 1944 solution computed the free energy in closed form and revealed a logarithmic divergence of the specific heat at a sharp critical temperature. The *location* of that temperature, however, can be pinned down by a more elementary and structurally illuminating route: the duality discovered by Kramers and Wannier in 1941, which relates the model at inverse temperature $\beta$ to the model at a *dual* inverse temperature $\beta^*$ with hot and cold interchanged. Granting that the model has a single transition, that transition must occur at the unique *self-dual* point, and the self-duality condition reduces to the transcendental equation

$$\sinh(2\beta) = 1. \tag{$\star$}$$

This paper provides a rigorous, self-contained treatment of the constant defined by $(\star)$. We isolate the purely analytic core of the argument — that $(\star)$ has a unique solution, given in closed form by $\beta_c = \tfrac12\log(1+\sqrt2)$ — and prove it, along with the natural variants involving the squared duality condition and the critical temperature. We are deliberate about which facts are statistical-mechanical inputs (the existence and uniqueness of the phase transition, and the form of the duality relation) and which are theorems we prove here (the solution and characterization of $(\star)$).

### 1.1 Notation and conventions

We work over the real numbers $\mathbb{R}$. The hyperbolic sine is

$$\sinh(x) = \frac{e^x - e^{-x}}{2},$$

with the standard logarithm $\log$ and principal square root $\sqrt{\cdot}$. We adopt natural units in which the nearest-neighbor coupling $J$ and Boltzmann constant $k_B$ are set to $1$, so that $\beta = 1/T$. All "temperatures" are dimensionless.

---

## 2. Physical setting

### 2.1 The model

Let $\Lambda$ be a finite subset of the square lattice $\mathbb{Z}^2$ (for definiteness, an $m \times n$ torus). A *configuration* is a map $\sigma : \Lambda \to \{-1, +1\}$. The (ferromagnetic, zero-field) **Hamiltonian** is

$$H(\sigma) = -\sum_{\langle i, j\rangle} \sigma_i \sigma_j,$$

where $\langle i, j \rangle$ ranges over nearest-neighbor pairs. Aligned pairs contribute $-1$ (favorable), anti-aligned pairs contribute $+1$.

The **Gibbs (Boltzmann) measure** at inverse temperature $\beta > 0$ assigns to each configuration the probability

$$P_\beta(\sigma) = \frac{1}{Z(\beta)}\, e^{-\beta H(\sigma)}, \qquad Z(\beta) = \sum_{\sigma} e^{-\beta H(\sigma)},$$

with $Z(\beta)$ the **partition function**. The order parameter is the magnetization $m(\beta) = \lim_{\Lambda \uparrow \mathbb{Z}^2} \langle \sigma_0 \rangle_\beta$ (with $+$ boundary conditions); it is positive in the ordered phase and zero in the disordered phase.

### 2.2 Existence of a transition: the Peierls argument

That the 2D model has a genuinely ordered phase at large $\beta$ is the content of the Peierls argument. A configuration deviating from the all-$+$ ground state is organized into **contours**: closed domain walls on the dual lattice separating $+$ and $-$ regions. A contour of length $L$ is suppressed by a Boltzmann factor $e^{-2\beta L}$, while the number of contours of length $L$ surrounding a fixed site grows only like $C^L$ for a fixed constant $C$. For $\beta$ large enough that $e^{-2\beta} C < 1$, the summed probability that a given site is encircled by some contour is strictly less than $\tfrac12$, so $\langle \sigma_0 \rangle_\beta > 0$: spontaneous magnetization survives. This establishes the *existence* of a low-temperature ordered phase, hence of a critical $\beta_c$ separating it from the high-temperature disordered phase. (By contrast, in one dimension the analogous contours are point defects whose entropy always defeats their energy cost, and no transition occurs.)

### 2.3 Kramers–Wannier duality and the self-dual point

The high-temperature expansion of $Z(\beta)$ organizes the partition function as a sum over *even subgraphs* (closed loops) of $\Lambda$, weighted by powers of $\tanh\beta$. The low-temperature expansion organizes it as a sum over *contours* on the dual lattice, weighted by powers of $e^{-2\beta}$. On the square lattice these two expansions have the same combinatorial structure, and matching them yields the **duality relation** between $\beta$ and a dual inverse temperature $\beta^*$,

$$\sinh(2\beta)\,\sinh(2\beta^*) = 1, \tag{KW}$$

under which $Z(\beta)$ and $Z(\beta^*)$ are proportional up to an explicit smooth prefactor. The map $\beta \mapsto \beta^*$ is a strictly order-reversing involution of $(0,\infty)$: large $\beta$ (cold, ordered) corresponds to small $\beta^*$ (hot, disordered).

Because the smooth prefactor cannot create a singularity, any non-analyticity of the free energy at $\beta$ must be mirrored at $\beta^*$. If the model has exactly one transition, it cannot be split between two distinct dual temperatures; it must sit at the unique **self-dual** point $\beta = \beta^*$. Setting $\beta^* = \beta$ in (KW) gives

$$\sinh(2\beta)^2 = 1, \qquad\text{i.e. for } \beta > 0,\quad \sinh(2\beta) = 1, \tag{$\star$}$$

the equation whose solution is the subject of this paper.

> **Scope.** The existence of a single transition and the derivation of (KW) are statistical-mechanical inputs (sketched above and listed as future formalization targets in §8). The contribution formalized here is the rigorous solution and characterization of the self-dual equation $(\star)$ and the closed form of the resulting constant.

---

## 3. Definitions

We fix the two protagonists.

**Definition 3.1 (Critical inverse temperature).**
$$\beta_c := \tfrac{1}{2}\log\!\left(1 + \sqrt{2}\right).$$

**Definition 3.2 (Critical temperature).**
$$T_c := \frac{2}{\log\!\left(1 + \sqrt{2}\right)}.$$

Numerically, $\log(1+\sqrt2) = \log(2.41421356\ldots) = 0.88137358\ldots$, so $\beta_c = 0.44068679\ldots$ and $T_c = 2.26918531\ldots$.

---

## 4. Main results

We state the results in the order in which they build on one another. Each is accompanied by a proof sketch; full details are elementary and appear in §5.

**Lemma 4.1 (Reciprocal identity).**
$$(1 + \sqrt{2})^{-1} = \sqrt{2} - 1.$$

*Sketch.* Since $\sqrt2\cdot\sqrt2 = 2$, we have $(\sqrt2 - 1)(1 + \sqrt2) = \sqrt2 + 2 - 1 - \sqrt2 = 1$. Hence $\sqrt2 - 1$ is the multiplicative inverse of $1 + \sqrt2$. $\qquad\blacksquare$

**Theorem 4.2 (Critical value: the self-dual point solves $(\star)$).**
$$\sinh(2\beta_c) = 1.$$

*Sketch.* By Definition 3.1, $2\beta_c = \log(1+\sqrt2)$. Using the identity $\sinh(\log x) = \tfrac12(x - x^{-1})$ valid for $x > 0$ (which follows from $e^{\log x} = x$ and $e^{-\log x} = x^{-1}$), with $x = 1 + \sqrt2 > 0$,

$$\sinh(2\beta_c) = \tfrac12\Big( (1+\sqrt2) - (1+\sqrt2)^{-1}\Big) = \tfrac12\Big( (1+\sqrt2) - (\sqrt2 - 1)\Big) = \tfrac12 \cdot 2 = 1,$$

where the middle step is Lemma 4.1. $\qquad\blacksquare$

**Theorem 4.3 (Uniqueness).** If $\beta > 0$ and $\sinh(2\beta) = 1$, then $\beta = \beta_c$.

*Sketch.* By Theorem 4.2, $\sinh(2\beta) = 1 = \sinh(2\beta_c)$. The function $\sinh$ is strictly increasing on all of $\mathbb{R}$ (its derivative $\cosh \geq 1 > 0$), hence injective; therefore $2\beta = 2\beta_c$, giving $\beta = \beta_c$. (Notably the hypothesis $\beta > 0$ is not needed for the conclusion, since injectivity is global; we retain it because it is the physically meaningful regime.) $\qquad\blacksquare$

**Theorem 4.4 (Positivity).** $\beta_c > 0$.

*Sketch.* Since $\sqrt2 > 0$, we have $1 + \sqrt2 > 1$, and the logarithm is positive on $(1, \infty)$, so $\log(1+\sqrt2) > 0$. Multiplying by $\tfrac12 > 0$ preserves positivity. $\qquad\blacksquare$

**Theorem 4.5 (Reciprocity of $T_c$ and $\beta_c$).**
$$T_c \cdot \beta_c = 1.$$

*Sketch.* Write $L = \log(1+\sqrt2)$, which is nonzero by Theorem 4.4. Then $T_c \cdot \beta_c = \frac{2}{L}\cdot\frac{L}{2} = 1$. $\qquad\blacksquare$

**Theorem 4.6 (Self-duality fixed-point characterization).** For $\beta > 0$,
$$\sinh(2\beta)^2 = 1 \iff \beta = \beta_c.$$

*Sketch.* ($\Leftarrow$) If $\beta = \beta_c$ then $\sinh(2\beta) = 1$ by Theorem 4.2, so its square is $1$. ($\Rightarrow$) For $\beta > 0$ we have $2\beta > 0$, and $\sinh$ is strictly positive on $(0,\infty)$ (it vanishes at $0$ and is increasing), so $\sinh(2\beta) > 0$. From $\sinh(2\beta)^2 = 1$ and positivity we get $\sinh(2\beta) = 1$ (the root $-1$ is excluded), and Theorem 4.3 yields $\beta = \beta_c$. $\qquad\blacksquare$

Theorem 4.6 is the precise sense in which "critical" and "self-dual" coincide: among physical inverse temperatures, the self-duality equation $(\star)$ singles out exactly one point, and it is $\beta_c$.

---

## 5. Proofs in detail

### 5.1 The reciprocal identity (Lemma 4.1)

We claim $(\sqrt2 - 1)(1 + \sqrt2) = 1$. Expanding,
$$(\sqrt2 - 1)(1 + \sqrt2) = \sqrt2 \cdot 1 + \sqrt2 \cdot \sqrt2 - 1 - \sqrt2 = \sqrt2 + 2 - 1 - \sqrt2 = 1,$$
using $\sqrt2 \cdot \sqrt2 = 2$. A real number with a left inverse in a field is invertible with that inverse, so $(1 + \sqrt2)^{-1} = \sqrt2 - 1$. $\blacksquare$

### 5.2 The critical value (Theorem 4.2)

From Definition 3.1, $2\beta_c = 2 \cdot \tfrac12 \log(1+\sqrt2) = \log(1+\sqrt2)$. Put $x = 1 + \sqrt2$; then $x > 0$, so $\log x$ is defined and
$$\sinh(\log x) = \frac{e^{\log x} - e^{-\log x}}{2} = \frac{x - x^{-1}}{2}.$$
By Lemma 4.1, $x^{-1} = \sqrt2 - 1$, hence
$$\sinh(2\beta_c) = \frac{(1+\sqrt2) - (\sqrt2 - 1)}{2} = \frac{2}{2} = 1. \qquad \blacksquare$$

### 5.3 Uniqueness (Theorem 4.3)

The derivative of $\sinh$ is $\cosh$, and $\cosh(x) \geq 1$ for all $x$, so $\sinh$ is strictly increasing and therefore injective on $\mathbb{R}$. Given $\sinh(2\beta) = 1$, Theorem 4.2 lets us write $\sinh(2\beta) = \sinh(2\beta_c)$. Injectivity gives $2\beta = 2\beta_c$, so $\beta = \beta_c$. $\blacksquare$

### 5.4 Positivity and reciprocity (Theorems 4.4, 4.5)

Because $\sqrt2 > 0$ we have $1 + \sqrt2 > 1$; the logarithm is strictly increasing with $\log 1 = 0$, so $\log(1+\sqrt2) > 0$, and $\beta_c = \tfrac12\log(1+\sqrt2) > 0$. For reciprocity, set $L = \log(1+\sqrt2) \neq 0$; then $T_c\,\beta_c = (2/L)(L/2) = 1$. $\blacksquare$

### 5.5 Fixed-point characterization (Theorem 4.6)

($\Leftarrow$) Immediate from Theorem 4.2 by squaring. ($\Rightarrow$) Assume $\beta > 0$ and $\sinh(2\beta)^2 = 1$. Since $2\beta > 0$ and $\sinh$ is positive on the positive axis, $s := \sinh(2\beta) > 0$. From $s^2 = 1$ and $s > 0$ we conclude $s = 1$. Theorem 4.3 then gives $\beta = \beta_c$. $\blacksquare$

---

## 6. Algorithms

The constant $\beta_c$ and the surrounding structure are eminently computable. We record three algorithms used in the demonstrations of §7.

### 6.1 Closed-form evaluation of $\beta_c$ and $T_c$

The most direct computation evaluates the closed forms of Definitions 3.1–3.2 in floating point and verifies the defining identity $\sinh(2\beta_c) = 1$ to machine precision. Complexity is $O(1)$.

### 6.2 Root-finding cross-check via bisection

To corroborate the closed form *without* using it, one can solve $(\star)$ numerically. The function $f(\beta) = \sinh(2\beta) - 1$ is continuous and strictly increasing, with $f(0) = -1 < 0$ and $f(1) = \sinh(2) - 1 > 0$, so a unique root lies in $(0,1)$. Bisection converges linearly, halving the bracket each step; $n$ steps yield an absolute error below $2^{-n}$. The recovered root agrees with $\tfrac12\log(1+\sqrt2)$.

### 6.3 Duality involution and its fixed point

Given the relation (KW), the dual map is $\beta^*(\beta) = \tfrac12\,\operatorname{arcsinh}\!\big(1/\sinh(2\beta)\big)$. Iterating or directly solving $\beta^*(\beta) = \beta$ recovers the self-dual point. Verifying that $\beta^*(\beta^*(\beta)) = \beta$ (involutivity) and that $\beta^*(\beta_c) = \beta_c$ (the fixed point) provides an independent structural check.

---

## 7. Numerical demonstrations

The accompanying `demo.py` performs the following, all to high precision:

1. **Closed-form values.** Computes $\beta_c = 0.4406867935\ldots$ and $T_c = 2.2691853142\ldots$ and confirms $\beta_c = 1/T_c$ (Theorem 4.5).
2. **The defining identity.** Evaluates $\sinh(2\beta_c)$ and finds $1$ to within machine epsilon (Theorem 4.2), and $\sinh(2\beta_c)^2 = 1$ (Theorem 4.6).
3. **Reciprocal identity.** Verifies $(1+\sqrt2)^{-1} = \sqrt2 - 1$ numerically (Lemma 4.1).
4. **Uniqueness by bisection.** Solves $\sinh(2\beta) = 1$ on $(0,1)$ by bisection and matches the closed form (Theorems 4.3, 6.2).
5. **Duality involution.** Confirms $\beta^* \circ \beta^* = \mathrm{id}$ on samples and that $\beta_c$ is the unique fixed point (§6.3).
6. **Monotone uniqueness.** Tabulates $\sinh(2\beta)$ to exhibit strict monotonicity, illustrating why the solution is unique.

---

## 8. Applications and significance

**Universality and benchmarking.** The 2D Ising critical point is the reference standard for the study of critical phenomena. Its exact value calibrates Monte Carlo simulations, finite-size scaling analyses, and series-expansion estimates; any numerical method for the model is validated against $T_c = 2.2691853\ldots$.

**Mapping to other systems.** Through the lattice-gas correspondence ($\sigma_i = 2n_i - 1$ with occupation $n_i \in \{0,1\}$), the Ising transition is the same critical point as the liquid–vapor transition and as phase separation in binary alloys. The single constant governs the onset of order in this entire universality class.

**Dualities as a paradigm.** Kramers–Wannier duality is the historical seed of a vast modern subject. Order/disorder duality, the recognition that a self-dual point pins a transition, and the general philosophy of relating a theory at strong coupling to a (possibly different) theory at weak coupling all trace to this example. The self-dual equation $(\star)$ is the simplest nontrivial instance of "the critical point is the fixed point of a duality."

---

## 9. Discussion

The treatment here deliberately separates two layers. The *physical* layer — existence and uniqueness of the transition (Peierls) and the duality relation (KW) — supplies the reason the critical point coincides with the self-dual point. The *analytic* layer — solving $(\star)$ — is what we have made fully rigorous: the closed form $\beta_c = \tfrac12\log(1+\sqrt2)$, its uniqueness via strict monotonicity of $\sinh$, the positivity of $\sinh$ on $(0,\infty)$ that promotes $\sinh^2 = 1$ to $\sinh = 1$, and the reciprocity $T_c \beta_c = 1$. A pleasant feature is how little machinery the analytic layer requires: the entire qualitative picture of the duality (it swaps hot and cold and has a single self-dual point) is encoded in three elementary properties of $\sinh$ on $(0,\infty)$ — positivity, strict monotonicity, and surjectivity onto $(0,\infty)$ — so the constant can be characterized with no statistical mechanics at all.

A subtle but important point is that uniqueness does not actually require restricting to $\beta > 0$: because $\sinh$ is globally injective, $\sinh(2\beta) = 1$ has a unique real solution regardless of sign. The positivity hypothesis is retained because $\beta = 1/T$ is physically positive and because the squared characterization (Theorem 4.6) genuinely needs $\beta > 0$ to exclude the spurious branch $\sinh(2\beta) = -1$.

---

## 10. Future directions

The following program builds directly on the formalized self-dual point, ordered from most accessible to most ambitious.

**1. Formalize the duality map and its involutive structure.** Define the dual inverse temperature $\beta^*(\beta)$ implicitly through $\sinh(2\beta)\sinh(2\beta^*) = 1$, prove it is well defined for $\beta > 0$, and show $\beta \mapsto \beta^*$ is a continuous, strictly order-reversing involution of $(0,\infty)$ whose unique fixed point is exactly $\beta_c$. The qualitative picture of the duality — swapping high and low temperature with a single self-dual point — is captured by elementary properties of $\sinh$ on $(0,\infty)$ (positivity, strict monotonicity, range $(0,\infty)$), so the map can be built and characterized directly on top of the present results $\sinh(2\beta_c)=1$, uniqueness, and positivity/monotonicity of $\sinh$.

**2. Connect to the dual-temperature parametrization $\tanh\beta^* = e^{-2\beta}$.** Many references state the duality in the equivalent low/high-temperature form $\tanh(\beta^*) = \exp(-2\beta)$ (or $e^{-2\beta^*} = \tanh\beta$) rather than through $\sinh$. Formalize the equivalence of these parametrizations and re-derive the self-dual point from the $\tanh$ form as an independent cross-check. The $\sinh$ relation and the $\tanh$/exponential relation are two coordinates on the same one-parameter family of dualities, related by standard hyperbolic identities, so proving their equivalence is a purely analytic exercise that strengthens confidence in the constant.

**3. Build the finite-volume partition function and prove the Kramers–Wannier relation.** Define the Ising Hamiltonian and partition function on an $m\times n$ torus and prove the duality $Z(\beta) \propto Z(\beta^*)$ via the high-temperature (loop) and low-temperature (contour) expansions, thereby *deriving* relation (KW) that this work currently takes as motivation. Duality is a combinatorial bijection between even subgraphs of the lattice and domain-wall configurations of its planar dual, so the analytic constant $\beta_c$ becomes a corollary of a finite, fully discrete counting identity. With the self-dual point already formalized as the target, the combinatorics can be developed with a precise goal and validated against the known fixed point at every step.

---

## 11. Conclusion

We have given a rigorous, self-contained account of the two-dimensional Ising model's critical point, centered on the self-duality fixed-point equation $\sinh(2\beta) = 1$. The solution is the closed-form constant $\beta_c = \tfrac12\log(1+\sqrt2)$, equivalently $T_c = 2/\log(1+\sqrt2)$, and it is the *unique* positive solution. We proved the supporting reciprocal identity $(1+\sqrt2)^{-1} = \sqrt2 - 1$, the critical value $\sinh(2\beta_c) = 1$, uniqueness via global strict monotonicity of $\sinh$, positivity of $\beta_c$, the reciprocity $T_c\beta_c = 1$, and the if-and-only-if characterization of the self-dual point through $\sinh(2\beta)^2 = 1$. Beyond its intrinsic elegance, the result is the calibration constant for an entire universality class and the simplest instance of the principle that a self-dual point locates a phase transition.
