# Structural Properties of the Christoffel–Darboux Airy Kernel and the Gram Positivity of Determinantal Edge Processes

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Random Matrix Theory / Determinantal Point Processes)

---

## Abstract

The local statistics at the spectral edge of a random matrix ensemble form a determinantal point process whose correlation kernel is the **Airy kernel**, conjecturally universal across a broad class of ensembles (edge universality), with the rescaled largest eigenvalue converging to the **Tracy–Widom distribution**. Written in Christoffel–Darboux (integrable-kernel) form, the Airy kernel is assembled from two solutions $f, g$ of Airy's differential equation $y'' = x\,y$:
$$K(x,y) = \frac{f(x)\,g(y) - g(x)\,f(y)}{x - y}.$$
We establish three rigorous structural results. First, the kernel is **symmetric** ($K(x,y) = K(y,x)$), a consequence of the antisymmetry of numerator and denominator. Second, the off-diagonal kernel has a **removable singularity on the diagonal**, and — when $f,g$ solve Airy's equation — its limiting diagonal value equals $-W$, where $W$ is the Wronskian; because the Wronskian of two solutions of a second-order ODE with no first-order term is *constant*, this diagonal value is **the same constant at every base point**. The flatness of the diagonal is thus the analytic shadow of a conservation law. Third, we isolate the positivity underlying the determinantal structure: for any **Gram kernel** $K(x,y) = \langle \varphi(x), \varphi(y)\rangle$ arising from a wave map $\varphi$ into a real inner-product space (the genuine Airy kernel being of this form with $\varphi(x) = (t \mapsto \mathrm{Ai}(x+t))$), the $2\times 2$ correlation determinant is nonnegative (Cauchy–Schwarz) and the full $n\times n$ correlation matrix is positive semidefinite. Strikingly, this positivity requires **no Airy-specific input whatsoever** — the determinantal admissibility of the edge kernel is a purely geometric (Gram) fact. All results have been formally verified.

---

## 1. Introduction

### 1.1 Edge universality and the Tracy–Widom law

For a Hermitian random matrix of dimension $N$ drawn from a suitable ensemble, the empirical distribution of eigenvalues converges (after rescaling) to a deterministic limiting density supported on a compact interval — for the canonical Gaussian ensembles this is Wigner's semicircle law. The *edge* of this spectrum, where the largest eigenvalue $\lambda_{\max}$ lives, exhibits fluctuations on the scale $N^{-2/3}$. Rescaling appropriately,
$$N^{2/3}\bigl(\lambda_{\max} - 2\bigr) \xrightarrow{d} \mathrm{TW},$$
where $\mathrm{TW}$ is the **Tracy–Widom distribution**. The deep phenomenon of **edge universality** asserts that this limit is insensitive to the precise law of the matrix entries: Gaussian, Bernoulli, or more general distributions (subject to moment conditions) all yield the same Tracy–Widom limit.

The structural reason is that the edge eigenvalues form a **determinantal point process** whose correlation kernel converges, in the large-$N$ limit, to the **Airy kernel**. The Tracy–Widom distribution is then the Fredholm determinant of the Airy kernel restricted to a half-line. Consequently, the analytic properties of the Airy kernel are the load-bearing facts of the entire edge theory.

### 1.2 Scope and contribution

This paper formalizes and proves three foundational properties of the Christoffel–Darboux Airy kernel and of determinantal correlation kernels in general:

1. **Symmetry** of the kernel (Theorem 1).
2. The **removable singularity on the diagonal** and the identification of its limiting value with the constant Wronskian (Theorem 2). The constancy is inherited from a companion result on Airy's ODE, `airyWronskian_const`, which we treat as an imported lemma.
3. **Determinantal positivity** of Gram kernels: the $2\times 2$ determinant inequality (Theorem 3, Cauchy–Schwarz) and the $n\times n$ positive semidefiniteness (Theorem 4).

Our emphasis is on *which structure is responsible for which property*. We find a clean separation: the flatness of the diagonal is genuinely Airy-specific (it fails without the constant Wronskian), whereas the positivity that makes the kernel an admissible determinantal kernel is generic to all projection/Gram kernels and uses nothing about Airy's equation.

---

## 2. Definitions

Throughout, $f, g : \mathbb{R} \to \mathbb{R}$ are real functions, and $H$ denotes a real inner-product space with inner product $\langle \cdot, \cdot\rangle$.

### Definition 1 (Christoffel–Darboux Airy kernel)
For functions $f, g : \mathbb{R} \to \mathbb{R}$ and $x, y \in \mathbb{R}$,
$$\mathrm{airyKernel}(f,g)(x,y) \;:=\; \frac{f(x)\,g(y) - g(x)\,f(y)}{x - y}.$$
(For $x = y$ this expression is the indeterminate $0/0$; its diagonal value is treated as a limit in Theorem 2.)

### Definition 2 (Wronskian)
For differentiable $f, g$ with derivatives $f', g'$,
$$W(x) \;:=\; \mathrm{airyWronskian}(f, f', g, g')(x) \;=\; f(x)\,g'(x) - g(x)\,f'(x).$$

### Definition 3 (Gram / projection kernel)
For a *wave map* $\varphi : \mathbb{R} \to H$ into a real inner-product space $H$,
$$\mathrm{gramKernel}(\varphi)(x,y) \;:=\; \langle \varphi(x), \varphi(y)\rangle.$$
The genuine Airy kernel is of this form: with $\varphi(x) = \bigl(t \mapsto \mathrm{Ai}(x + t)\bigr) \in L^2([0,\infty))$, one has $K_{\mathrm{Ai}}(x,y) = \int_0^\infty \mathrm{Ai}(x+t)\,\mathrm{Ai}(y+t)\,dt = \langle \varphi(x), \varphi(y)\rangle$.

### Airy's differential equation
A function $y$ is an *Airy solution* if it satisfies $y''(x) = x\,y(x)$ for all $x$. The decaying solution is the Airy function $\mathrm{Ai}$; a second, independent (growing) solution is $\mathrm{Bi}$.

---

## 3. Main results

### Theorem 1 (Symmetry of the Airy kernel)
*For all $f, g : \mathbb{R} \to \mathbb{R}$ and all $x, y \in \mathbb{R}$ with $x \neq y$,*
$$\mathrm{airyKernel}(f,g)(x,y) = \mathrm{airyKernel}(f,g)(y,x).$$

**Proof sketch.** Cross-multiplying, the claim is equivalent to
$$\bigl(f(x)g(y) - g(x)f(y)\bigr)\,(y - x) = \bigl(f(y)g(x) - g(y)f(x)\bigr)\,(x - y),$$
which holds because the numerator is antisymmetric under $x \leftrightarrow y$ and the denominator changes sign. Formally one applies `div_eq_div_iff` (valid since $x - y \neq 0$ and $y - x \neq 0$) to reduce to a polynomial identity discharged by `ring`. $\qquad\blacksquare$

*(Lean: `airyKernel_symm`.)*

---

### Theorem 2 (Removable singularity; the diagonal equals the constant Wronskian)
*Suppose $f, g$ are twice differentiable with $\mathrm{HasDerivAt}$ chains $f \to f' \to f''$ and $g \to g' \to g''$, and that they solve Airy's equation: $f''(x) = x\,f(x)$ and $g''(x) = x\,g(x)$ for all $x$. Then for every base point $x \in \mathbb{R}$,*
$$\lim_{y \to x,\ y \neq x} \mathrm{airyKernel}(f,g)(x,y) \;=\; -\,W(0),$$
*where $W(0) = f(0)g'(0) - g(0)f'(0)$ is the (position-independent) Wronskian.*

**Proof sketch.** Fix $x$ and set $N(y) := f(x)\,g(y) - g(x)\,f(y)$, so that $N(x) = 0$. The kernel is, for $y \neq x$,
$$K(x,y) = \frac{N(y)}{x - y} = -\,\frac{N(y) - N(x)}{y - x} = -\,\mathrm{slope}(N)(x)(y).$$
Differentiating $N$ termwise, $N$ has derivative at $x$ equal to $f(x)g'(x) - g(x)f'(x) = W(x)$ (obtained via the product/scalar rules `HasDerivAt.const_mul` and `HasDerivAt.sub`). By `hasDerivAt_iff_tendsto_slope`, the slope of $N$ at $x$ tends to $W(x)$ as $y \to x$ within $\{y \neq x\}$; negating gives $\lim K(x,y) = -W(x)$.

It remains to replace the position-dependent $-W(x)$ by the constant $-W(0)$. The Wronskian is **constant** for two solutions of $y'' = xy$: differentiating $W = fg' - gf'$ yields $W' = fg'' - gf'' = f(xg) - g(xf) = 0$. This is the imported lemma `airyWronskian_const`, which gives $W(x) = W(0)$. Substituting closes the proof; the final reconciliation of the `slope` expression with the kernel formula is a `field_simp; ring` step on the domain $y \neq x$. $\qquad\blacksquare$

*(Lean: `airyKernel_diagonal_tendsto`, using `airyWronskian_const` from the companion `AiryODE` development.)*

**Remark (significance).** The diagonal value of $K$ controls the local one-point density of the determinantal process. Theorem 2 says this value is *uniform along the diagonal* — identical at every base point — precisely because the Wronskian is conserved. Removing the constancy hypothesis leaves a position-dependent limit $-W(x)$; the constancy is exactly the Airy-specific content. We do **not** here claim the specific numerical value of $W$ for the $(\mathrm{Ai}, \mathrm{Bi})$ pair (famously $1/\pi$, hence diagonal $-1/\pi$); pinning that constant is a normalization fact listed as future work, independent of the structural limit proved here.

---

### Theorem 3 ($2\times 2$ determinantal positivity)
*For any wave map $\varphi : \mathbb{R} \to H$ and any $x, y \in \mathbb{R}$,*
$$\mathrm{gramKernel}(\varphi)(x,x)\cdot \mathrm{gramKernel}(\varphi)(y,y) - \mathrm{gramKernel}(\varphi)(x,y)\cdot \mathrm{gramKernel}(\varphi)(y,x) \;\ge\; 0.$$

**Proof sketch.** Writing $K(a,b) = \langle \varphi(a), \varphi(b)\rangle$ and using symmetry of the real inner product, the left-hand side equals
$$\langle \varphi(x),\varphi(x)\rangle\,\langle \varphi(y),\varphi(y)\rangle - \langle \varphi(x),\varphi(y)\rangle^2 = \|\varphi(x)\|^2\|\varphi(y)\|^2 - \langle \varphi(x),\varphi(y)\rangle^2,$$
which is nonnegative by the **Cauchy–Schwarz inequality** $|\langle u, v\rangle| \le \|u\|\,\|v\|$ (Lean: `abs_real_inner_le_norm`). This is the $n=2$ instance of determinantal positivity. $\qquad\blacksquare$

*(Lean: `gram_corr_det_nonneg`.)*

---

### Theorem 4 ($n\times n$ determinantal positivity)
*For any wave map $\varphi : \mathbb{R} \to H$ and any finite family of base points $p : \{1,\dots,n\} \to \mathbb{R}$, the correlation matrix*
$$M_{ij} = \mathrm{gramKernel}(\varphi)(p_i, p_j) = \langle \varphi(p_i), \varphi(p_j)\rangle$$
*is positive semidefinite.*

**Proof sketch.** Two checks. (i) *Symmetry/Hermitianity:* $M_{ji} = \langle \varphi(p_j), \varphi(p_i)\rangle = \langle \varphi(p_i), \varphi(p_j)\rangle = M_{ij}$ by `real_inner_comm`. (ii) *Nonnegativity of the quadratic form:* for any weight vector $x = (x_i)$,
$$x^{\mathsf T} M\, x = \sum_{i,j} x_i\,\langle \varphi(p_i), \varphi(p_j)\rangle\,x_j = \Bigl\langle \sum_i x_i\,\varphi(p_i),\ \sum_j x_j\,\varphi(p_j)\Bigr\rangle = \Bigl\| \sum_i x_i\,\varphi(p_i)\Bigr\|^2 \ge 0,$$
using bilinearity (`sum_inner`, `inner_sum`, `inner_smul_left`, `inner_smul_right`) to pull the sums and scalars through the inner product, and `real_inner_self_nonneg` for the final step. $\qquad\blacksquare$

*(Lean: `gram_corr_posSemidef`.)*

**Remark (the surprise).** Theorem 4 establishes the structural positivity required for the Airy kernel to define an honest determinantal point process — yet its proof never mentions Airy's equation, the Wronskian, or any special function. The admissibility of the edge kernel as a correlation kernel is a *generic Gram fact*. In the dependency structure of the theory, the genuinely Airy-specific ingredient is the flat diagonal (Theorem 2), not the positivity.

---

## 4. Discussion: where the special structure lives

It is instructive to contrast the three results by *how much of the Airy structure each consumes*:

| Result | Ingredient used | Airy-specific? |
|---|---|---|
| Symmetry (Thm 1) | Sign cancellation in $\tfrac{\text{antisym}}{\text{antisym}}$ | No — holds for all $f,g$ |
| Flat diagonal (Thm 2) | Slope/derivative **and** constancy of Wronskian ($y''=xy$) | **Yes** — fails without constant $W$ |
| Positivity (Thm 3,4) | Cauchy–Schwarz / Gram representation | No — holds for all wave maps |

This dependency analysis is the conceptual contribution. Folklore might suggest that proving the Airy kernel defines a valid determinantal process is "the hard analytic part." Our decomposition shows the opposite: positivity is the *most generic* property, true of every projection kernel, while the only place where being an Airy solution is genuinely required is the diagonal limit — and there it enters through a single conservation law (the constant Wronskian), not through any fine asymptotics of special functions.

The Christoffel–Darboux/integrable-kernel form $K = (fg' \text{-type numerator})/(x-y)$ is precisely the form in which this separation becomes visible. The numerator carries the differential structure (its derivative is the Wronskian); the denominator carries the singularity that calculus removes.

---

## 5. Algorithms

The results above are constructive enough to be checked and explored numerically. We describe two algorithms used in the accompanying demonstrations.

### Algorithm A — Removable-Singularity Diagonal-Limit Estimator
**Goal.** Numerically confirm Theorem 2: that $K(x,y) \to -W$ as $y \to x$, and that the limit is the same constant for every base point $x$.

**Idea.** For a base point $x$ and a small offset $h$, evaluate $K(x, x+h)$ and compare to $-W(x)$ computed directly from $f, f', g, g'$. As $h \to 0$ the discrepancy $\to 0$ at first order. Sweeping $x$ confirms position-independence of the limit when $f, g$ are Airy solutions (constant $W$).

**Complexity.** $O(1)$ per evaluation; $O(P\cdot H)$ for a sweep over $P$ base points and $H$ offsets.

### Algorithm B — Gram Correlation-Matrix PSD Verifier
**Goal.** Numerically confirm Theorems 3 and 4: that the $n\times n$ matrix $M_{ij} = \langle \varphi(p_i), \varphi(p_j)\rangle$ is symmetric PSD.

**Idea.** Discretize $\varphi(x) = (t \mapsto \mathrm{Ai}(x+t))$ on a grid, build the column vectors $\varphi(p_i)$, assemble $M = \Phi^{\mathsf T}\Phi$ (a Gram matrix by construction), and verify symmetry, the $2\times2$ determinant inequality, and the nonnegativity of all eigenvalues.

**Complexity.** $O(n^2 d)$ to assemble ($d$ = grid size), $O(n^3)$ for the eigenvalue check.

---

## 6. Applications

- **Random matrix theory.** The Airy kernel is the universal scaling limit of edge correlation kernels for Wigner and invariant ensembles; its Fredholm determinant gives the Tracy–Widom law for $\lambda_{\max}$.
- **KPZ universality.** Growth models (corner growth, polynuclear growth, ASEP), last-passage percolation, and the longest-increasing-subsequence problem all exhibit Tracy–Widom edge fluctuations governed by the Airy process.
- **Random tilings and dimers.** The Airy process describes the fluctuations of the frozen/liquid boundary (e.g. the Aztec diamond arctic circle).
- **Multivariate statistics.** Tracy–Widom appears as the limiting law of the largest eigenvalue of sample covariance matrices, with applications to principal component analysis and high-dimensional hypothesis testing.

---

## 7. Future directions

These directions are stated to be attemptable directly as formal developments; each is falsifiable.

- **C1 — Normalizing the diagonal constant.** For the genuine $(\mathrm{Ai}, \mathrm{Bi})$ pair, the diagonal value $-W$ is the constant $-1/\pi$. Theorem 2 already reduces this to pinning the *single* value $W(\mathrm{Ai},\mathrm{Bi}) = 1/\pi$; no new structural analysis is needed.
- **C2 — Two-dimensional solution space.** The map $(a,b) \mapsto a\,\mathrm{Ai} + b\,\mathrm{Bi}$ is a linear isomorphism onto the solution space of $y'' = xy$. Injectivity follows from the nonzero Wronskian (linear independence); surjectivity follows from ODE uniqueness (Picard–Lindelöf).
- **C3 — Positivity is necessary, not just sufficient.** A symmetric kernel admits a Gram representation $K(x,y) = \langle \varphi(x), \varphi(y)\rangle$ **iff** every finite correlation matrix is PSD. Theorem 4 is the forward direction; the converse is the Moore–Aronszajn reproducing-kernel construction.
- **C4 — Non-algebraicity of higher edge-kernel generators.** Whether the analytic non-algebraicity of the Airy generators propagates to all higher edge kernels.

---

## 8. Conclusion

We have given rigorous, formally verified proofs of three structural properties of the Christoffel–Darboux Airy kernel: symmetry, a uniform removable singularity on the diagonal equal to the constant Wronskian, and the determinantal positivity (Cauchy–Schwarz at order two, Gram positive semidefiniteness at all orders) that licenses the kernel as a correlation kernel of a determinantal point process. The unifying lesson is a clean dependency analysis: the determinantal admissibility is generic to all projection kernels, while the genuinely Airy-specific structure is the *flat diagonal*, an analytic manifestation of the conservation law that the Wronskian of Airy solutions is constant.

---

## Appendix: index of formal results

- `airyKernel` — Definition 1.
- `airyKernel_symm` — Theorem 1.
- `airyKernel_diagonal_tendsto` — Theorem 2 (uses `airyWronskian_const`).
- `gramKernel` — Definition 3.
- `gram_corr_det_nonneg` — Theorem 3.
- `gram_corr_posSemidef` — Theorem 4.

All results verified with allowed axioms `{propext, Classical.choice, Quot.sound}`.
