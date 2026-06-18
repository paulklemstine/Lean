# Future Directions: Spectral Chain Framework — L²(π) Operator Layer

## Synthesis

This cycle built the **Spectral Chain** framework for finite reversible Markov chains
from a cold start and lifted it into operator theory on the weighted Hilbert space
`L²(π)`. Two self-contained modules were produced. `Core.lean` fixes the combinatorial
foundations: the `ReversibleChain` structure (a row-stochastic kernel `P` with a positive
stationary distribution `π` satisfying detailed balance), the functionals `mean`, `Var`,
and the Dirichlet energy `DirichletForm`, a certified Poincaré inequality `SpectralGapCert`,
and the cross-domain bridge `cheeger_easy_inequality` showing that a spectral gap forces a
conductance/cut lower bound `γ·π(S)(1−π(S)) ≤ E(1_S)`. `L2Operator.lean` then proves that
the *algebra* of `Core` is genuinely *operator theory*: the Markov action `applyP` and the
weighted inner product `innerPi` satisfy four structural identities, culminating in a
one-step contraction on mean-zero observables.

The central structural insight is that **detailed balance is exactly self-adjointness of
`P` in `L²(π)`** (`innerPi_self_adjoint`), and that **the Dirichlet form is the quadratic
form of `I − P`** (`DirichletForm_eq_innerPi_sub`). Once these two identities are in place,
the combinatorial spectral gap (`SpectralGapCert`) converts mechanically into the analytic
one-step contraction `⟨Pf,f⟩_π ≤ (1−γ)⟨f,f⟩_π` (`applyP_inner_contraction`). Every centering
argument reduces to writing `f = g + mean(f)` with `g` mean-zero and applying `reversible`
once after a single sum swap.

The most informative negative result was the **disproof** of the natural strengthening
`Var(Pf) ≤ (1−γ)²·Var(f)`. The two-state bipartite swap chain (`swapChain`) has spectrum
`{1, −1}`; it admits a valid Poincaré certificate with gap `1` (`swapCert`, since its
Dirichlet form is exactly twice its variance), yet `Pf = −f` on the mean-zero line, so
`Var(Pf) = Var(f) > 0 = (1−1)²·Var(f)` (`Var_applyP_contraction_false`). This pins down the
exact missing ingredient — a *lower* spectral bound (an absolute/lazy gap) — and so directly
seeds Direction 1 below.

## Results Summary

- `SpectralChain.Var_nonneg`: proved — variance is nonnegative on every observable.
- `SpectralChain.DirichletForm_nonneg`: proved — the Dirichlet energy is nonnegative.
- `SpectralChain.mean_const`: proved — the stationary mean of a constant is that constant.
- `SpectralChain.Var_const`: proved — constants have zero variance.
- `SpectralChain.Var_indicator`: proved — `Var(1_S) = π(S)(1−π(S))`, reducing an indicator's variance to a pure measure computation.
- `SpectralChain.cheeger_easy_inequality`: proved — cross-domain bridge: a spectral gap forces a conductance/cut lower bound `γ·π(S)(1−π(S)) ≤ E(1_S)`.
- `SpectralChain.mean_applyP`: proved — the kernel preserves the stationary mean (`P` is a Markov operator on observables).
- `SpectralChain.innerPi_self_adjoint`: proved — reversibility is exactly self-adjointness of `P` in `L²(π)`.
- `SpectralChain.DirichletForm_eq_innerPi_sub`: proved — the energy is the quadratic form of `I − P`.
- `SpectralChain.Var_eq_innerPi_sub_mean_sq`: proved — `Var(f) = ⟨f,f⟩_π − mean(f)²` (the mean-zero norm).
- `SpectralChain.applyP_inner_contraction`: proved — a Poincaré gap gives the one-step contraction `⟨Pf,f⟩_π ≤ (1−γ)⟨f,f⟩_π`.
- `SpectralChain.swap_poincare` / `SpectralChain.swapCert`: proved — the bipartite swap chain satisfies Poincaré with gap `1`.
- `SpectralChain.Var_applyP_contraction_false`: disproved — `Var(Pf) ≤ (1−γ)²·Var(f)` is FALSE in general; the swap chain is an explicit counterexample.

## Research Directions

### Direction 1: Geometric ergodicity under an absolute spectral gap
**Hypothesis**: If a chain additionally satisfies an *absolute* gap
`⟨Pf,f⟩_π ≥ −(1−γ)⟨f,f⟩_π` for all mean-zero `f` (e.g. a lazy chain `P' = (I+P)/2`), then
`Var(Pᵗf) ≤ (1−γ)^{2t}·Var(f)` for all `t`.
**Test**: Add an `AbsoluteGapCert` field carrying the lower bound, prove the single-step
operator-norm contraction `‖Pf − mean(f)‖_π ≤ (1−γ)‖f − mean(f)‖_π` by combining
`applyP_inner_contraction` with the new lower bound and Cauchy–Schwarz, then iterate by
induction on `t`.
**Why now**: `Var_applyP_contraction_false` shows precisely that the *only* missing
ingredient is the lower bound; `applyP_inner_contraction` and `Var_eq_innerPi_sub_mean_sq`
already supply everything else. The key insight is that the squared variance bound is an
operator-*norm* statement, and self-adjointness (`innerPi_self_adjoint`) makes the norm
computable from the two-sided inner-product bounds alone.

### Direction 2: `applyP` as a `LinearMap` and its spectrum
**Hypothesis**: `applyP` extends to a self-adjoint `LinearMap ℝ (V → ℝ) (V → ℝ)` on the
inner-product space `(V → ℝ, innerPi)`, whose largest eigenvalue is `1` (eigenvector `1`)
and whose spectral gap equals `1 − λ₂`.
**Test**: Register `innerPi` as an `InnerProductSpace` (positive-definiteness follows from
`weight_pos`), package `applyP` as a `LinearMap`, and discharge `IsSelfAdjoint` using
`innerPi_self_adjoint`; then read off eigenvalues with Mathlib's finite spectral API.
**Why now**: The single nontrivial hypothesis of the finite spectral theorem
(self-adjointness) is already a theorem here. The key insight is that `SpectralGapCert`
stops being a hand-supplied certificate and becomes a *computed* quantity `1 − λ₂`.

### Direction 3: Variational (Courant–Fischer) optimal gap
**Hypothesis**: The optimal Poincaré constant equals the Rayleigh-quotient minimum
`γ* = inf_{f ⊥_π 1} E(f)/Var(f)`, and an optimal `SpectralGapCert` always *exists*.
**Test**: Use `DirichletForm_eq_innerPi_sub` and `Var_eq_innerPi_sub_mean_sq` to rewrite the
ratio as `⟨(I−P)f,f⟩_π / ⟨f,f⟩_π` on the mean-zero subspace, then invoke the min–max theorem
for the self-adjoint operator of Direction 2.
**Why now**: Both rewriting lemmas are proved and mutually compatible, so the Rayleigh
quotient is expressible today. The key insight is that `E(f)/Var(f)` is literally the
Rayleigh quotient of `I − P`, whose infimum over the mean-zero subspace is the smallest
nonzero eigenvalue.

### Direction 4: Tensorisation — the gap of a product chain
**Hypothesis**: For reversible chains `C₁, C₂`, the product chain `C₁ ⊗ C₂` (Kronecker
kernel `P₁ ⊗ P₂`, product weight) has gap `min(γ(C₁), γ(C₂))`.
**Test**: Define the product chain, prove the additive splitting of the Dirichlet form along
coordinates via `Finset.sum_product`, and apply `applyP_inner_contraction` coordinatewise to
obtain the lower bound `min(γ₁, γ₂)`; supply an eigenvector to show the bound is attained.
**Why now**: The operator layer makes the tensor structure expressible and the splitting is a
pure index rearrangement. The key insight is that the inner product factorises over the
product index, so the one-step contraction transfers factorwise with no new analysis.

### Direction 5: A log-Sobolev layer comparable to the spectral gap
**Hypothesis**: A `LogSobolevCert` with constant `α` (i.e. `Ent(f²) ≤ (2/α)·E(f)`) always
satisfies `α ≤ γ`; i.e. the log-Sobolev constant never exceeds the spectral gap.
**Test**: Define the entropy functional `Ent(g) = ∑ᵢ πᵢ gᵢ log gᵢ − (∑ πᵢ gᵢ) log(∑ πᵢ gᵢ)`,
linearise it around its mean to recover `Var`, and compare the two inequalities using the
shared right-hand side `DirichletForm_eq_innerPi_sub`.
**Why now**: `DirichletForm`, `mean`, and the inner-product machinery are all in place, and
entropy needs only `Real.log` and `Finset.sum`. The key insight is that the *same* Dirichlet
form drives both inequalities, so the comparison `α ≤ γ` reduces to the second-order Taylor
expansion of entropy at its mean.
**If true**: places two mixing regimes (variance decay vs. hypercontractivity) into one comparable hierarchy inside the framework.
**If false**: would mean the entropy linearisation does not dominate the variance, indicating a sign or normalisation error in the entropy functional to diagnose.
