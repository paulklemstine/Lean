# Future Directions: Thermodynamic Inference and Tropical Optimization

## Overview

The formalized Gibbs variational principle and its tropical/Bayesian connections open a rich landscape of follow-up research. Below are five concrete next-step targets, each with theorem statements, required definitions, proof strategies, and cross-domain significance.

---

## 1. Donsker–Varadhan Variational Formula on Finite Spaces

### Statement

For any function `f : Fin n → ℝ` and probability distribution `p`,

```
log (∑ i, p i * exp (f i)) = sup over q on simplex of [∑ i, q i * f i - KL(q ‖ p)]
```

This is the finite-dimensional Donsker–Varadhan variational representation of the log-moment generating function.

### Required Definitions

- `logMGF (p : Fin n → ℝ) (f : Fin n → ℝ) : ℝ := log (∑ i, p i * exp (f i))`
- Reuse `klDiv` from the current file

### Proof Strategy

The supremum is achieved at the tilted distribution `q_i = p_i * exp(f_i) / (∑ p_j exp(f_j))`. The proof reduces to the KL decomposition identity we already proved: the gap between any q and the optimal tilted distribution is exactly the KL divergence, which is nonneg. The key step is showing the optimal value matches `logMGF` via algebraic manipulation identical to `free_energy_gap_eq_kl_div`.

### Cross-Domain Significance

- **Large deviation theory**: The Donsker–Varadhan formula is the foundation of large deviations for empirical measures
- **Risk-sensitive control**: The log-MGF appears in exponential utility functions
- **PAC-Bayes bounds**: Modern PAC-Bayes theorems use exactly this variational formula with f = empirical risk
- **Convex duality**: This is the Fenchel conjugate of KL divergence

---

## 2. Entropy-Regularized Dynamic Programming (Soft Bellman Equation)

### Statement

For an MDP with finite state space `Fin n`, finite action space `Fin m`, transition kernel `T`, reward `R`, and discount `γ`, define the soft Bellman operator:

```
(T_soft V)(s) = (1/β) * log (∑ a, exp(β * (R(s,a) + γ * ∑ s', T(s,a,s') * V(s'))))
```

Then prove:
1. `T_soft` is a contraction mapping with factor `γ` under the sup norm
2. The unique fixed point `V*` satisfies: the optimal policy is the Gibbs distribution over actions with energy = -(R + γ * expected future value)
3. As `β → ∞`, the soft Bellman equation converges to the standard (hard) Bellman equation

### Required Definitions

- `SoftBellmanOp` — the soft Bellman operator
- `SoftPolicy` — Gibbs policy over actions
- Reuse `partitionFun`, `gibbsWeight`, `free_energy_bounds_min`

### Proof Strategy

Contractivity follows from the non-expansiveness of log-sum-exp (which is 1-Lipschitz) composed with the γ-contraction of the expected future value. The fixed point characterization uses Banach's fixed point theorem (available in Mathlib as `ContractingWith.fixedPoint`). The tropical limit follows from `free_energy_tends_to_min` applied to each state.

### Cross-Domain Significance

- **Reinforcement learning**: This is the theoretical foundation of Soft Actor-Critic (SAC) and maximum entropy RL
- **Optimal control**: Connects Bellman equations to thermodynamic free energy
- **Planning under uncertainty**: Entropy regularization provides natural exploration

---

## 3. PAC-Bayes Bounds via Free Energy

### Statement

Given a prior distribution `w` over hypotheses `Fin n`, empirical risks `R_emp : Fin n → ℝ`, sample size `m`, and confidence `δ > 0`, prove:

```
∀ posterior q on simplex,
  E_q[true_risk] ≤ E_q[R_emp] + sqrt((KL(q ‖ w) + log(2*sqrt(m)/δ)) / (2*m))
```

And show that the optimal posterior (minimizing the bound) is exactly the Gibbs posterior:

```
q_opt(i) ∝ w(i) * exp(-2*m * R_emp(i))
```

### Required Definitions

- `pacBayesBound` — the PAC-Bayes bound functional
- Reuse `klDiv`, `posterior_as_free_energy_minimizer`

### Proof Strategy

The PAC-Bayes bound follows from a change-of-measure argument combined with Hoeffding's inequality and the Donsker–Varadhan formula. The optimization step is a direct application of `posterior_as_free_energy_minimizer` with β = 2m and L = R_emp.

### Cross-Domain Significance

- **Machine learning theory**: PAC-Bayes provides the tightest known generalization bounds
- **Model selection**: The bound naturally trades off fit (empirical risk) and complexity (KL divergence)
- **Neural network theory**: Recent work uses PAC-Bayes to explain deep learning generalization

---

## 4. Tropical Large Deviations Beyond Finite Types

### Statement

Generalize `free_energy_tends_to_min` and `free_energy_bounds_min` from `Fin n` to compact metric spaces:

For a continuous function `f : X → ℝ` on a compact metric space `X` with Borel measure `μ`,

```
lim_{β→∞} -(1/β) * log (∫ exp(-β * f) dμ) = inf_{x ∈ support(μ)} f(x)
```

with quantitative bounds:

```
inf f - (1/β) * log(μ(X)) ≤ -(1/β) * log(∫ exp(-β * f) dμ) ≤ inf f + ε(β)
```

where `ε(β) → 0` depends on the modulus of continuity of `f`.

### Required Definitions

- Integration of `exp(-β * f)` with respect to `μ` (using Mathlib's `MeasureTheory.integral`)
- `infOnSupport` — infimum of f on the support of μ
- Modulus of continuity for the error term

### Proof Strategy

The upper bound uses the Laplace method: near the minimizer, the integral is dominated by exp(-β * inf f). The lower bound uses compactness to extract a finite cover and reduce to the finite case (our `free_energy_bounds_min`). Key Mathlib tools: `IsCompact`, `MeasureTheory.integral`, `Filter.Tendsto`.

### Cross-Domain Significance

- **Tropical geometry**: This is the rigorous tropicalization of integrals, connecting algebraic geometry to optimization
- **Statistical mechanics**: This generalizes the thermodynamic limit to continuous systems
- **Probability theory**: This is Varadhan's lemma / Laplace principle in the compact case

---

## 5. Certified Convergence of Variational Inference

### Statement

For a target distribution `p*` and a parametric family of distributions `{q_θ}`, define the ELBO (Evidence Lower Bound):

```
ELBO(θ) = E_{q_θ}[log p*(x)] - KL(q_θ ‖ prior)
```

Prove:
1. `ELBO(θ) ≤ log(evidence)` for all θ (immediate from KL nonnegativity)
2. For the finite exponential family case, the ELBO is concave in the natural parameters
3. Gradient ascent on ELBO converges to the optimal variational approximation at rate O(1/t)

### Required Definitions

- `ELBO` — evidence lower bound functional
- `ExponentialFamily` — structure for exponential family distributions
- `naturalGradient` — natural gradient in the Fisher metric

### Proof Strategy

Statement 1 follows directly from `kl_div_nonneg_of_pos`. Statement 2 uses the convexity of KL divergence in the first argument (which follows from the convexity of x log x, already available as `Real.convexOn_mul_log`). Statement 3 combines concavity with standard convergence rates for gradient ascent on concave functions.

### Cross-Domain Significance

- **Machine learning**: Variational inference is the workhorse of modern Bayesian ML (VAEs, Bayesian neural nets)
- **Computational statistics**: Certified convergence removes the "black box" nature of VI
- **Information geometry**: Natural gradients connect to the Fisher-Rao metric on statistical manifolds

---

## Cross-Cutting Theme

All five directions share a common mathematical core: **the interplay between optimization, probability, and information geometry through free energy functionals**. The formalized Gibbs variational principle serves as the seed crystal from which each of these directions grows naturally:

- Direction 1 (Donsker–Varadhan) generalizes the variational representation
- Direction 2 (Soft Bellman) applies it to sequential decision-making
- Direction 3 (PAC-Bayes) applies it to statistical learning theory
- Direction 4 (Tropical large deviations) extends it to continuous spaces
- Direction 5 (Variational inference) applies it to approximate Bayesian computation

Together, they form a coherent program for **formally verified thermodynamic computation** — a new foundation for certified algorithms in machine learning, optimization, and statistical physics.
