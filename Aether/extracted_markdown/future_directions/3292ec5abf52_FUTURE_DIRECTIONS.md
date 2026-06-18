# Future Directions: Neural Network Training as Renormalization Group Flow

The file `RGFlowTraining.lean` establishes a rigorous, machine-checked core of
the analogy *training = renormalization-group (RG) flow*. We model a
coarse-graining step by an idempotent linear operator `P` on parameter space,
identify the residual `R = id - P` as the gradient of the quadratic relevance
loss `½‖θ - Pθ‖²`, and prove that:

* SGD critical points (`R θ = 0`) **coincide** with RG fixed points (`P θ = θ`);
* the closed-form flow `rgFlow` solves the gradient ODE `θ' = -Rθ`;
* it relaxes exponentially (`‖θ(t) − Pθ₀‖ = e^{-t}‖Rθ₀‖`) onto the fixed-point
  manifold (range of `P`);
* the limit is determined solely by the coarse-grained class `Pθ₀`
  (**universality**: `rg_universality`); and
* each irrelevant eigenmode of the linearized beta-operator decays at its own
  critical rate `λ` (`rg_spectral_decay`).

These results build on and complement the finite-dimensional NTK / lazy-training
algebra in `NTKCore.lean` (Jacot–Gabriel–Hongler), where gradient flow under a
fixed kernel `K` gives `u_t = (I − ηK)^t u₀`. The RG viewpoint reinterprets the
fixed kernel's spectral projections as coarse-graining operators.

Below are five testable, falsifiable directions that extend this work.

## 1. Multi-mode spectral RG flow and the full critical spectrum

We proved single-mode decay (`rg_spectral_decay`). The next step is to assemble
the modes: for a self-adjoint coarse-graining beta-operator `A`, prove that the
flow `e^{-tA} x₀` converges to the orthogonal projection of `x₀ onto ker A`,
decomposing the trajectory over the eigenbasis with mode-specific rates.

**The key insight is** that the orthogonal projection `P` onto `ker A` is itself
the RG fixed-point operator, so the spectral theorem turns "the flow forgets
irrelevant modes" into "negative/zero eigenspaces of the beta-function are the
relevant/marginal couplings." **Why now?** Mathlib now has the finite-dimensional
spectral theorem (`LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces`
and `DiagonalizableOn` machinery), so the eigen-decomposition that previously
forced a `sorry` is within reach. *Falsifiable:* if some eigenmode failed to
decay at exactly rate `λ`, `rgFlow_dist`'s generalization would be violated.

## 2. Idempotency is necessary as well as sufficient

We assumed `P` idempotent. Conjecture: among bounded linear `P`, the
fixed-point/range correspondence `rg_fixedPoint_iff_mem_range` holds for *all*
`x` **iff** `P` is idempotent on its range. Formalize the converse and the exact
hypothesis class for which "coarse-graining is a projection" is forced.

**The key insight is** that a coarse-graining operator must be a retraction onto
the manifold of relevant configurations — applying it twice cannot remove more
than applying it once — which is precisely idempotency. **Why now?** With the
clean separation of `rgResidual` and `rgFlow`, the converse is a short linear
algebra argument and pins down the minimal axioms for a valid RG step.
*Falsifiable:* exhibit a non-idempotent `P` whose fixed set still equals its
range to refute it.

## 3. Discrete (finite step-size) RG flow and stability threshold

Replace the continuous flow by the Euler/SGD iteration `θ_{k+1} = θ_k − η R θ_k
= (1−η)θ_k + η Pθ_k`. Prove it converges to `Pθ₀` iff `0 < η < 2`, with rate
`|1−η|`, recovering the continuous result as `η → 0`, and diverging for `η ≥ 2`.

**The key insight is** that the learning-rate window `(0,2)` is exactly the
contraction interval of `(1−η)` on the irrelevant subspace, making the optimal
step `η = 1` (one-shot projection) the discrete analog of the RG fixed point.
**Why now?** This directly parallels `NTKCore.lean`'s `u_t = (I − ηK)^t u₀`
geometric-convergence lemma, so the two files can share a contraction lemma and
the threshold becomes a quantitative, testable prediction. *Falsifiable:* a
convergent run at `η ≥ 2` or a divergent run at `η ∈ (0,2)` would break it.

## 4. ReLU two-layer networks: piecewise-linear coarse-graining

The original concept targets a 2-layer ReLU network `f(x)=Σ aⱼ ReLU(wⱼ·x+bⱼ)`.
On each activation region the network is linear, so the parameter space is
stratified and `P` becomes a *piecewise* projection. Conjecture: within a fixed
activation pattern the RG flow theorems above apply verbatim, and the global
fixed points are the per-region fixed points that are consistent across region
boundaries.

**The key insight is** that ReLU's piecewise linearity makes the network a
gluing of linear models, so RG universality holds *per stratum* and the
data's activation statistics select the universality class. **Why now?** Mathlib
has enough convex-geometry and `ContinuousLinearMap` support to formalize
activation regions as polyhedral cones, letting us lift the linear theory to the
canonical nonlinear test case. *Falsifiable:* find a ReLU fixed point not equal
to any region-wise projection of the initialization.

## 5. Data-distribution universality classes via the NTK spectrum

Make "same universality class ⇒ same fixed point" data-driven: define the class
of a data distribution by the spectral decomposition of its NTK Gram operator,
let `P` be the projection onto the top-`r` eigenspaces, and prove two datasets
with the same dominant eigenspaces converge (under `rgFlow`) to the same
fixed point even if their kernels differ in the tail.

**The key insight is** that `rg_universality` already shows the fixed point
depends only on `Pθ₀`; choosing `P` from the NTK spectrum turns abstract
"coarse-grained class" into the concrete, measurable spectral fingerprint of the
data. **Why now?** `NTKCore.lean` already proves the NTK Gram matrix is PSD and
diagonalizable, so its eigenprojections are exactly the operators `P` this file
needs — the two results compose immediately into a quantitative universality
theorem. *Falsifiable:* two datasets sharing top-`r` NTK eigenspaces that
nonetheless converge to different fixed points would disprove it.
