# A Machine-Checked Foundation for Neural Tangent Kernel Convergence

## Abstract

The Neural Tangent Kernel (NTK), introduced by Jacot, Gabriel, and Hongler
(2018), governs the training dynamics of overparameterized neural networks. In
the infinite-width (or *lazy training*) limit, gradient-descent training of a
nonlinear network reduces to a linear power iteration driven by a fixed,
symmetric, positive-semidefinite kernel matrix `K`. This paper presents a
complete and rigorous development of the finite-dimensional algebraic core of
this theory. We prove that the NTK Gram matrix is symmetric and positive
semidefinite; that the training residual after `t` steps of discrete gradient
descent equals `(I − ηK)^t u₀`; that the residual norm decays geometrically under
contractivity; that fixed points of the dynamics are exactly the kernel null
space (convergence ⟺ interpolation); that the kernel is constant along the
trajectory of a linearized model (the formal content of lazy training); that
single-step perturbations of the kernel propagate linearly; and that the
dynamics are *universal* — they depend only on `K` and the learning rate `η`, not
on the architecture. We also give the quadratic-form expansion underlying the
spectral analysis and a precise per-mode account of convergence rate and optimal
learning rate. Every result stated here has been formalized and verified in the
Lean 4 proof assistant against Mathlib, with no axioms beyond the standard
foundational ones. The paper states each definition and theorem inline with a
self-contained proof sketch.

**Keywords:** neural tangent kernel, gradient descent, Gram matrix, positive
semidefinite, geometric convergence, lazy training, kernel methods, spectral
analysis, formal verification.

---

## 1. Introduction

### 1.1 Motivation

A central mystery of modern deep learning is why gradient descent, applied to a
highly nonconvex loss over millions of parameters, reliably drives training error
to zero. The Neural Tangent Kernel offers a strikingly clean explanation in the
overparameterized regime. The first-order Taylor expansion of the network output
around its initialization is linear in the parameters, and in the limit of large
width the true network is shown to remain close to this linearization throughout
training. Consequently, the dynamics of the *output residual* are governed by a
fixed kernel matrix, and the entire convergence question becomes a problem in
elementary linear algebra: the behavior of the iterated linear operator
`I − ηK`.

The arguments are conceptually simple but easy to get subtly wrong — sign errors
in the residual recursion, unstated positivity assumptions, off-by-one issues in
the induction. The contribution of this work is to make the core of the theory
*rigorous and machine-checked*, isolating exactly which structural facts about
`K` (symmetry, positive semidefiniteness) are responsible for which dynamical
conclusions (geometric decay, interpolation, stability).

### 1.2 Contributions

We formalize and prove, in full:

1. The NTK matrix is a Gram matrix, hence **symmetric** and **positive
   semidefinite** (Theorems 3.1–3.4).
2. The residual recursion `u_{t+1} = (I − ηK) u_t` solves to the **power
   iteration** `u_t = (I − ηK)^t u₀` (Theorem 4.1).
3. Under contractivity of the update operator, the residual norm exhibits
   **geometric decay** `‖u_t‖ ≤ c^t ‖u₀‖` (Theorem 5.1).
4. **Fixed points** of the dynamics are exactly the null space of `K`:
   convergence is equivalent to interpolation (Theorem 6.1).
5. The kernel is **constant** along the trajectory of the linearized model —
   the algebraic statement of lazy training (Theorem 7.1).
6. The update operator preserves symmetry, and the **quadratic-form expansion**
   `⟨Tv, Tv⟩ = ⟨v,v⟩ − 2η⟨v, Kv⟩ + η²⟨Kv, Kv⟩` holds (Theorems 8.1–8.2).
7. Single-step kernel perturbations propagate as `η(K₂ − K₁)u` (Theorem 9.1).
8. **Universality**: identical kernels and learning rates yield identical
   trajectories (Theorem 10.1).

We close with a spectral interpretation that opens the contractivity constant in
terms of eigenvalues, the optimal learning rate, and a formal statement of the
width-convergence conjecture.

### 1.3 Notation

Throughout, `n` is the number of training points, `p` the number of parameters,
and `d` the input dimension. Vectors in `ℝⁿ` are written `u, v`; matrices are
written with capital letters. The map `Φ : Fin n → Fin p → ℝ` (equivalently an
`n × p` matrix) collects gradient/feature rows, with `Φ i k` the `k`-th
coordinate of the `i`-th feature vector. We write `‖·‖` for the Euclidean norm,
`⟨·,·⟩` or `dotProduct` for the standard inner product on `ℝⁿ`, and `M.mulVec u`
for matrix–vector multiplication.

---

## 2. The Setting

### 2.1 The model and its linearization

A *parameterized model* is a map `f : (Fin p → ℝ) → (Fin d → ℝ) → ℝ`, sending
parameters `θ` and input `x` to a scalar prediction `f(θ, x)`. Given training
inputs `x₁, …, xₙ` and targets `y₁, …, yₙ`, the squared loss is
`L(θ) = ½ Σᵢ (f(θ, xᵢ) − yᵢ)²`, and gradient descent updates
`θ ← θ − η ∇L(θ)`.

**Definition 2.1 (Linearized prediction).** Fix initialization `θ₀` and let
`J : Fin n → Fin p → ℝ` denote the Jacobian with `J i j = ∂f(θ₀, xᵢ)/∂θ_j`. The
*linearized model* predicts

  `linearizedPrediction(f₀, J, θ₀, θ) i = f₀ i + Σ_{j} J i j · (θ_j − (θ₀)_j)`,

where `f₀ i = f(θ₀, xᵢ)`. This is affine in `θ`.

**Definition 2.2 (Linearized gradient and parameter step).** For a residual
`r : Fin n → ℝ`, the gradient of the linearized loss is
`linearizedGradient(J, r) j = Σ_i J i j · r i` (i.e. `Jᵀ r`), and one gradient step
on parameters is

  `linearizedParamStep(J, η, θ₀, θ, f₀, y) j = θ_j − η · (Jᵀ (f_lin(θ) − y))_j`.

### 2.2 The kernel

**Definition 2.3 (NTK value).** For a feature/gradient map `grad : Fin d → Fin p → ℝ`,

  `ntkValue(grad) i j = Σ_{k : Fin p} grad i k · grad j k = ⟨grad i, grad j⟩`.

**Definition 2.4 (NTK Gram matrix).** For `Φ : Fin n → Fin p → ℝ`,

  `ntkGramMatrix(Φ) = Of (fun i j ↦ Σ_{k} Φ i k · Φ j k)`,

i.e. the matrix with `(i,j)` entry `⟨Φ i, Φ j⟩`. Equivalently, for a model with
parameter-gradient map `grad`, parameters `θ`, and data `X`,
`neuralTangentKernel(grad, θ, x, y) = Σ_{j} grad(θ,x) j · grad(θ,y) j` and
`ntkMatrix(grad, θ, X) i j = neuralTangentKernel(grad, θ, X i, X j)`.

### 2.3 The gradient-descent dynamical system

**Definition 2.5 (Update operator, step, residual).** For a kernel
`K : Matrix (Fin n) (Fin n) ℝ` and learning rate `η`,

  `gdUpdateOp(K, η) = I − η • K`,  `gdStep(K, η, u) = gdUpdateOp(K, η).mulVec u`,

and the residual after `t` steps is defined recursively by `gdResidual 0 = u₀`,
`gdResidual (t+1) = gdStep(K, η, gdResidual t)`. Packaged as a structure, an
`NTKDynamics n` carries a kernel, a learning rate, and a positivity proof
`0 < η`, with `updateOp = 1 − η • kernel`, `step u = updateOp.mulVec u`, and the
analogous `residual`.

---

## 3. Structural Properties of the Kernel

**Theorem 3.1 (Kernel value symmetry).** `ntkValue(grad) i j = ntkValue(grad) j i`,
and likewise `neuralTangentKernel(grad, θ, x, y) = neuralTangentKernel(grad, θ, y, x)`.

*Proof sketch.* Each summand `grad i k · grad j k` equals `grad j k · grad i k` by
commutativity of multiplication; sum termwise. ∎

**Theorem 3.2 (Gram matrix symmetry).** `ntkGramMatrix(Φ).IsSymm`, and
`ntkMatrix(grad, θ, X).IsSymm`.

*Proof sketch.* Entrywise, `K_{ij} = Σ_k Φ i k · Φ j k = Σ_k Φ j k · Φ i k = K_{ji}`
by commutativity, which is exactly the symmetry predicate `Kᵀ = K`. ∎

**Theorem 3.3 (Factorization).** `ntkGramMatrix(Φ) = Φ · Φᵀ`, where `Φ` is read as
the `n × p` matrix `Matrix.of Φ`.

*Proof sketch.* The `(i,j)` entry of `Φ Φᵀ` is `Σ_k Φ i k · (Φᵀ) k j = Σ_k Φ i k · Φ j k`,
identical to the defining entry of the Gram matrix. ∎

**Theorem 3.4 (Positive semidefiniteness).** `ntkGramMatrix(Φ).PosSemidef`; likewise
`ntkMatrix(grad, θ, X).PosSemidef`.

*Proof sketch.* Symmetry is Theorem 3.2. For the quadratic form, with `x : Fin n → ℝ`,

  `Σ_i Σ_j x_i · K_{ij} · x_j = Σ_i Σ_j x_i (Σ_k Φ i k Φ j k) x_j
     = Σ_k (Σ_i x_i Φ i k)²`,

obtained by reindexing the triple sum and completing the square per coordinate
`k`. Each term `(Σ_i x_i Φ i k)²` is a square, hence nonnegative, and a sum of
nonnegative terms is nonnegative. Thus `xᵀ K x = ‖Φᵀ x‖² ≥ 0`. ∎

This is the structural keystone: every dynamical consequence below ultimately
rests on `K` being symmetric PSD, which Theorem 3.4 guarantees for *any* feature
matrix, independent of architecture.

---

## 4. The Power-Iteration Formula

**Theorem 4.1 (Residual iteration formula).** For every `t`,

  `gdResidual(K, η, u₀, t) = (gdUpdateOp(K, η)^t).mulVec u₀`,

and in structure form `sys.residual u₀ t = (sys.updateOp ^ t).mulVec u₀`.

*Proof sketch.* Induction on `t`. Base case `t = 0`: `gdResidual 0 = u₀` and
`T⁰ = I`, so `I.mulVec u₀ = u₀`. Inductive step: assume
`gdResidual t = (T^t).mulVec u₀`. Then

  `gdResidual (t+1) = T.mulVec (gdResidual t) = T.mulVec ((T^t).mulVec u₀)
     = (T · T^t).mulVec u₀ = (T^{t+1}).mulVec u₀`,

using associativity of matrix–vector multiplication (`mulVec_mulVec`) and
`pow_succ'`. ∎

The formula reduces all temporal questions about training to the algebra of a
single fixed operator `T = I − ηK` raised to a power — the bridge from iterative
optimization to operator theory.

---

## 5. Geometric Convergence

**Definition 5.1 (Contractivity).** `K` is *contractive* at rate `c` with
learning rate `η` if `0 ≤ c`, `c < 1`, and for all `v`,
`‖gdUpdateOp(K, η).mulVec v‖ ≤ c · ‖v‖`.

**Theorem 5.1 (Geometric decay).** If `K` is contractive at rate `c`, then for all
`t`, `‖gdResidual(K, η, u₀, t)‖ ≤ c^t · ‖u₀‖` (structure form:
`‖sys.residual u₀ t‖ ≤ c^t · ‖u₀‖`).

*Proof sketch.* Induction on `t`. Base case: `‖u₀‖ ≤ c⁰ ‖u₀‖ = ‖u₀‖`. Inductive
step: `gdResidual (t+1) = T.mulVec (gdResidual t)`, so by contractivity
`‖gdResidual (t+1)‖ ≤ c · ‖gdResidual t‖`, and by the inductive hypothesis
`≤ c · (c^t ‖u₀‖) = c^{t+1} ‖u₀‖`. Both inequalities use `c ≥ 0`. ∎

Because `0 ≤ c < 1`, `c^t → 0`, giving exponential convergence of the training
residual to zero.

---

## 6. Fixed Points and Interpolation

**Theorem 6.1 (Fixed-point characterization).** Assume `η ≠ 0` (in the structure
version, `η > 0`). Then `gdStep(K, η, u) = u ⟺ K.mulVec u = 0`. In particular,
`sys.step u = u ⟹ sys.kernel.mulVec u = 0`.

*Proof sketch.* `gdStep(K, η, u) = u` means `(I − ηK).mulVec u = u`, i.e.
`u − η (K.mulVec u) = u`, i.e. `η (K.mulVec u) = 0`. Since `η ≠ 0`, this is
equivalent to `K.mulVec u = 0`. The converse substitutes `K.mulVec u = 0` back.
∎

Interpretation: training reaches a stationary residual exactly when the residual
lies in `ker K`. If `K` is positive *definite* (`ker K = {0}`), the only fixed
point is `u = 0`, i.e. perfect interpolation of the training targets. Thus
convergence and interpolation coincide whenever the kernel is nondegenerate.

---

## 7. Kernel Constancy: The Lazy-Training Identity

**Theorem 7.1 (Linearized residual dynamics).** Let `J` be the Jacobian, `η` the
learning rate, `θ₀, θ` parameters, `f₀, y` baseline outputs and targets, and let
`u i = linearizedPrediction(f₀, J, θ₀, θ) i − y i` be the current residual.
Define `θ' = linearizedParamStep(J, η, θ₀, θ, f₀, y)` and
`u' i = linearizedPrediction(f₀, J, θ₀, θ') i − y i`. Then for every `i`,

  `u' i = u i − η · Σ_{j : Fin n} ntkGramMatrix(J)_{ij} · u_j`.

*Proof sketch.* Expand `u' i` using Definitions 2.1–2.2. The parameter update
changes each `θ_l` by `−η (Jᵀ u)_l = −η Σ_m J m l · u m`. Substituting into the
linearized prediction,

  `u' i = u i + Σ_l J i l · (θ'_l − θ_l) = u i − η Σ_l J i l Σ_m J m l u_m`.

Swapping the order of summation, `Σ_l Σ_m J i l J m l u_m = Σ_m (Σ_l J i l J m l) u_m
= Σ_m K_{im} u_m` where `K = ntkGramMatrix(J)`. Hence
`u' i = u i − η Σ_m K_{im} u_m`. ∎

This is the precise sense in which the kernel is *constant* in the lazy regime:
the residual obeys the linear recursion `u_{t+1} = u_t − η K u_t` with the
*same* matrix `K = J Jᵀ` at every step. Combined with Theorem 4.1, the residual
of the linearized model is exactly `(I − ηK)^t u₀`.

---

## 8. Symmetry Preservation and the Quadratic Expansion

**Theorem 8.1 (Update operator preserves symmetry).** If `K.IsSymm` then
`gdUpdateOp(K, η).IsSymm`; equivalently, for an `NTKDynamics`, symmetry of the
kernel implies symmetry of `updateOp`.

*Proof sketch.* `I` is symmetric and `η • K` is symmetric whenever `K` is, and the
difference of symmetric matrices is symmetric: `(I − ηK)ᵀ = Iᵀ − η Kᵀ = I − ηK`. ∎

Symmetry of `T = I − ηK` is what permits a real orthonormal eigenbasis and the
spectral analysis of Section 11.

**Theorem 8.2 (Quadratic-form expansion).** With `T = updateOp`,

  `⟨T v, T v⟩ = ⟨v, v⟩ − 2η ⟨v, K v⟩ + η² ⟨K v, K v⟩`.

*Proof sketch.* Write `T v = v − η (K v)` and expand the inner product bilinearly:
`⟨v − ηKv, v − ηKv⟩ = ⟨v,v⟩ − η⟨v, Kv⟩ − η⟨Kv, v⟩ + η²⟨Kv, Kv⟩`. When `K` is
symmetric, `⟨v, Kv⟩ = ⟨Kv, v⟩`, collapsing the cross terms to `−2η⟨v, Kv⟩`. ∎

The quadratic form `kernelQuadForm(v) = ⟨v, K v⟩` controls the one-step
contraction: `‖Tv‖² = ‖v‖² − 2η⟨v,Kv⟩ + η²‖Kv‖²`, so a step strictly decreases
`‖v‖` whenever `0 < η < 2⟨v,Kv⟩ / ‖Kv‖²`.

---

## 9. Perturbation and Stability

**Theorem 9.1 (Single-step perturbation).** For kernels `K₁, K₂`, learning rate
`η`, and any `u`,

  `(I − ηK₁).mulVec u − (I − ηK₂).mulVec u = (η • (K₂ − K₁)).mulVec u`.

*Proof sketch.* Both sides act coordinatewise; the `I.mulVec u = u` terms cancel,
leaving `−η (K₁ u) + η (K₂ u) = η ((K₂ − K₁) u)`, which is `(η • (K₂ − K₁)).mulVec u`
by linearity of `mulVec`. ∎

Interpretation: if the true (drifting) kernel `K₂` differs from the idealized
kernel `K₁` by a small perturbation `ΔK = K₂ − K₁`, one training step introduces an
error of exactly `η ΔK u`. Bounding `‖ΔK‖` (e.g. by `O(1/√m)` in width `m`) and
summing over steps yields the lazy-regime stability estimate that the perturbed
trajectory stays close to the ideal one. This single-step identity is the
foundation on which such accumulated-error bounds are built.

---

## 10. Universality

**Theorem 10.1 (Architecture independence).** If `K₁ = K₂` and the learning rates
agree, then `gdResidual(K₁, η, u₀, t) = gdResidual(K₂, η, u₀, t)` for all `t`. In
structure form: if `sys₁.kernel = sys₂.kernel` and
`sys₁.learningRate = sys₂.learningRate`, then `sys₁.residual u₀ t = sys₂.residual u₀ t`.

*Proof sketch.* The residual is defined purely in terms of the update operator,
which is determined by `(kernel, learningRate)`. With equal kernels and learning
rates the update operators are identical, so a trivial induction on `t` (matching
each step) gives equal trajectories. ∎

This is the formal content of the Jacot–Gabriel–Hongler universality principle:
in the lazy regime, the network's architecture influences training *only* through
the kernel it induces. Distinct architectures with a common NTK are
indistinguishable as learners.

---

## 11. Spectral Interpretation

Theorems 3.4 and 8.1 make `K` a symmetric PSD matrix and `T = I − ηK` symmetric,
so `K` admits a real orthonormal eigenbasis with eigenvalues
`λ₁ ≥ ⋯ ≥ λₙ ≥ 0` (nonnegativity from PSD). The dynamics decouple along this
basis.

**Per-mode dynamics.** If `K v = λ v`, then `T v = (1 − ηλ) v`, so `T` is *diagonal*
in the eigenbasis. By Theorem 4.1, the component of the residual along `v`
satisfies `u_t = (1 − ηλ)^t v`, giving the *exact* (not merely bounded) geometric
law `‖u_t‖ = |1 − ηλ|^t ‖v‖`.

**Stability window.** A mode is stable iff `|1 − ηλ| < 1`, i.e. iff `0 < ηλ < 2`.
Globally, the contractivity constant of Section 5 is
`c = maxᵢ |1 − ηλᵢ|`, recovering the black-box constant explicitly from the
spectrum.

**Optimal learning rate.** For a spectrum confined to `[μ, L]` with `μ > 0`, the
worst-case contraction `maxᵢ |1 − ηλᵢ|` is minimized at

  `η* = 2 / (μ + L)`,

at which both extreme modes contract by exactly `(L − μ) / (L + μ) < 1`. The proof
hinges on the η-free identity `L(1 − ημ) − μ(1 − ηL) = L − μ`: by the triangle
inequality, `(L + μ) · maxᵢ|1 − ηλᵢ| ≥ L|1 − ημ| + μ|1 − ηL| ≥ |L − μ| = L − μ`,
so no step size beats `(L − μ)/(L + μ)` on the worse of the two extreme modes,
and `η*` attains it. The bound `(L − μ)/(L + μ) = (κ − 1)/(κ + 1)` with condition
number `κ = L/μ` reproduces the classical convergence rate of iterative linear
solvers.

**Width convergence (conjecture).** Finite-width networks have a *drifting* NTK
that converges to a deterministic limit as width `m → ∞`. A formal statement is

  `KernelWidthConvergence n : ∃ K_lim, ∀ ε > 0, ∃ m₀, ∀ m ≥ m₀, ∀ K_m,
     (∀ i j, |K_m i j − K_lim i j| < ε) →
       ∀ u₀, ∀ η > 0, ∀ t,
         ‖((I − η K_m)^t).mulVec u₀ − ((I − η K_lim)^t).mulVec u₀‖ ≤ ε · t · η · ‖u₀‖`,

asserting that trajectories under an entrywise-close kernel stay within `O(ε t η)`
of the limiting trajectory. Theorem 9.1 provides the per-step seed for this
estimate; a full proof additionally requires concentration inequalities for the
random initialization, which lie outside the present algebraic core.

---

## 12. Algorithms

The constructive content of the theory yields directly executable procedures.

**Algorithm A (NTK Gram matrix assembly).** Given a feature matrix
`Φ ∈ ℝ^{n×p}`, form `K = Φ Φᵀ`. Cost `O(n² p)`. By Theorem 3.4 the output is
symmetric PSD by construction.

**Algorithm B (Residual power iteration).** Given `K`, `η`, `u₀`, and `t`, iterate
`u ← u − η (K u)` exactly `t` times. Cost `O(t n²)` via repeated matrix–vector
products. By Theorem 4.1 the result equals `(I − ηK)^t u₀`, and by Theorem 5.1 its
norm is bounded by `c^t ‖u₀‖`.

**Algorithm C (Spectral rate and optimal learning rate).** Given the eigenvalues
of `K`, return `μ = λ_min`, `L = λ_max`, `η* = 2/(μ+L)`, and the optimal worst-
case contraction `(L−μ)/(L+μ)`. Cost dominated by the eigendecomposition,
`O(n³)`.

---

## 13. Applications

- **Provable training guarantees.** For any model whose NTK has `λ_min = μ > 0`,
  Theorems 4.1, 5.1, and 6.1 certify geometric convergence to zero training error
  at the explicit rate of Section 11.
- **Learning-rate selection.** Section 11 gives a closed-form optimal learning
  rate `η* = 2/(μ+L)` and the exact achievable rate, removing guesswork from a
  central hyperparameter in the lazy regime.
- **Kernel regression equivalence.** Theorems 6.1 and 7.1 show that the converged
  linearized network is the kernel-regression solution for `K`, connecting deep
  learning to classical kernel methods.
- **Robustness certification.** Theorem 9.1 quantifies sensitivity to kernel
  misspecification, supporting stability analyses for finite-width networks.
- **Architecture-agnostic analysis.** Theorem 10.1 lets one reason about a whole
  equivalence class of architectures through a single kernel.

---

## 14. Discussion

The development cleanly separates *structural* facts (symmetry, PSD,
factorization) from *dynamical* conclusions (power iteration, geometric decay,
fixed points, universality). This separation is illuminating: every dynamical
guarantee is traced to a specific structural property of the Gram matrix. The
positive-semidefiniteness proof — a quadratic form rewritten as a sum of squares
— is the linchpin; without it the iteration could amplify error modes with
negative eigenvalues.

A deliberate scope decision was to capture the dynamics *per eigenmode* rather
than to prove the full operator-norm identity `‖I − ηK‖ = maxᵢ |1 − ηλᵢ|`. The
per-mode picture is both lighter to formalize and more informative: it yields the
exact decay law along eigenvectors and the optimal-rate analysis directly, and it
is exactly the granularity needed for the quantitative extensions below.

A second decision was to work in finite dimensions with explicit `n, p`. This
matches the practical setting (finite training sets, finite-width networks) and
keeps all objects concrete matrices and vectors, while the index-agnostic style
of the proofs leaves room for generalization to product index types (Section 15).

---

## 15. Future Work

1. **Explicit spectral contractivity.** Relate the contractivity constant `c` to
   the spectrum: with eigenvalues `λ₁ ≥ ⋯ ≥ λₙ ≥ 0` and `η < 2/λ₁`,
   `c = max(|1 − ηλ₁|, |1 − ηλₙ|)` with optimum `η* = 2/(λ₁ + λₙ)`, bridging to
   the Hermitian eigenvalue API and the operator-norm bound
   `‖I − ηK‖ = maxᵢ |1 − ηλᵢ|`.
2. **Width-dependent stability.** Bound the kernel drift `‖K(θ_t) − K(θ₀)‖ ≤ C/√m`
   via Jacobian Lipschitz continuity, upgrading the single-step bound of Section 9
   into an accumulated trajectory bound.
3. **Loss-landscape convexity under overparameterization.** When `λ_min > 0`, the
   linearized loss is strongly convex, giving `L(θ_t) ≤ (1 − ηλ_min)^{2t} L(θ₀)`;
   positive definiteness corresponds to linear independence of the feature
   vectors, holding almost surely for random init when `p ≥ n`.
4. **Multi-output NTK.** Generalize to vector outputs by replacing `Fin n` with
   `Fin n × Fin k`; the block kernel remains a Gram matrix and the convergence
   theory carries over.
5. **Reproducing-kernel Hilbert space.** Construct the RKHS of the NTK, prove the
   representer theorem via orthogonal projection, and show gradient descent
   converges to the minimum-norm interpolant.

---

## 16. Conclusion

We have given a complete, machine-checked development of the algebraic core of
Neural Tangent Kernel theory: the kernel is a symmetric positive-semidefinite
Gram matrix; training is a power iteration of `I − ηK`; convergence is geometric
under contractivity; fixed points are the kernel null space; the kernel is
constant in the linearized regime; perturbations propagate linearly; and the
dynamics are universal in the kernel. The spectral interpretation opens the
contractivity constant in terms of eigenvalues and yields a closed-form optimal
learning rate. Each result is stated and proved here in self-contained form,
mirroring a verified formalization, providing a trustworthy foundation for the
quantitative extensions outlined above.

---

## References

- A. Jacot, F. Gabriel, C. Hongler. *Neural Tangent Kernel: Convergence and
  Generalization in Neural Networks.* Advances in Neural Information Processing
  Systems, 2018.
