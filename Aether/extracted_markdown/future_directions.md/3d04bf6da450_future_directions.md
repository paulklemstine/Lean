# Future Directions — Pinsker / Information-Geometry Cycle

These notes seed the next research cycle. The proved information-geometric
KL sandwich lives in `Catalog/Speculative/AutoResearch/FisherInformationMetric.lean`,
which establishes the upper two-sided control
`0 ≤ KL(p‖q) ≤ χ²(p‖q) = g_q(p−q, p−q)` (Gibbs + Fisher form). The
missing piece is the lower control by the L¹ (total-variation) norm — Pinsker's
inequality `(1/2)(∑|pᵢ−qᵢ|)² ≤ KL(p‖q)` — recorded as the open conjecture
`klDiv_ge_half_tv_sq`.

## 1. General Pinsker Inequality for Finite Distributions

The natural next step is the general Pinsker inequality `TV(Q, P)² ≤ KL(Q ‖ P) / 2`
for arbitrary finite distributions Q, P over a type α. The key insight is that the
general Pinsker inequality reduces to the Bernoulli case via the data-processing
inequality (or equivalently, by projecting onto binary events). For any set A ⊆ α,
define Q_A = Q(A) and P_A = P(A). Then KL(Ber(Q_A) ‖ Ber(P_A)) ≤ KL(Q ‖ P) by data
processing, and TV(Q, P) = max_A |Q(A) - P(A)| ≤ √(KL(Q ‖ P)/2) follows from the
Bernoulli case. The Bernoulli base case uses an MVT-based approach (factoring the
derivative as (q-p)·(1−2q)²/(q(1−q))) that avoids the usual convex duality
arguments. Formalizing the data-processing inequality for finite distributions
would complete the picture and unlock tighter PAC-Bayes bounds.

## 2. Spectral Convergence Rate with Eigenvalue Decay

The spectral contraction constant for the update operator I − ηK equals (κ−1)/(κ+1)
at the optimal learning rate, where κ = λ_max/λ_min is the condition number. For
overparameterized neural networks, the NTK eigenvalues typically decay as a power
law: λ_k ~ k^{−α} for some α > 1. Under power-law spectral decay, the effective
condition number for the top-k eigenvalues grows as k^α, so convergence of the
first k components takes O(k^α · log(1/ε)) steps. A formal theorem would bound the
residual ‖u_t − u*‖ by decomposing into spectral components and summing geometric
decays with different rates, using `Matrix.IsHermitian.spectral_theorem`.

## 3. Lazy Training Regime: Kernel Perturbation Bounds

The next step is to formalize the perturbation theory: if the actual (nonlinear)
kernel deviates from the initial kernel by at most δ at each step, how does the
trajectory diverge from the kernel regression solution? The key insight is a
Gronwall-type stability estimate: if ‖K_t − K_0‖_op ≤ δ for all t, then
‖u_t^{actual} − u_t^{linear}‖ ≤ C · δ · t · ‖u_0‖ · exp(η · ‖K_0‖_op · t). This
exponential growth is tamed by the finite training time T ~ log(1/ε) / (η · λ_min),
giving a polynomial-in-parameters bound. The discrete Gronwall lemma in Mathlib
(`Finset.prod_le_prod`) provides the induction machinery.

## 4. PAC-Bayes Generalization Bounds via Catoni's Method

With the Pinsker inequality and the Catoni bound infrastructure both formalized, we
can prove end-to-end generalization bounds for NTK-trained networks: for an NTK
model with n training points and kernel condition number κ, the generalization gap
is O(√(κ · log(n) / n)). The PAC-Bayes framework with the Catoni bound combined with
the Bernoulli Pinsker inequality converts KL control of the posterior into risk
bounds. The NTK spectral theory provides the KL bound through the effective dimension
d_eff = Σ_k λ_k/(λ_k + λ), connecting kernel spectrum to model complexity.

## 5. Stochastic Gradient Descent Extension

Extending to SGD requires formalizing the martingale structure of the gradient noise
and proving that the NTK remains approximately constant under mini-batch updates.
Under the lazy training regime, SGD on the linearized model is equivalent to kernel
regression with noise-perturbed updates. The residual satisfies
u_{t+1} = (I − η_t K) u_t + η_t ξ_t where ξ_t is a martingale difference sequence
with E[ξ_t | F_t] = 0 and E[‖ξ_t‖² | F_t] ≤ σ². The convergence rate becomes O(1/t)
for appropriately decaying learning rates, matching the minimax optimal rate for
kernel regression. Mathlib's measure theory library now includes conditional
expectation and martingale convergence theorems.
