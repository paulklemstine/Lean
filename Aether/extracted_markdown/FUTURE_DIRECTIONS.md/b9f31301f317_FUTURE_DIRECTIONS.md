# Future Directions: Entropy Power Inequality

## Synthesis

This cycle established the foundational information-theoretic inequalities in Lean 4: non-negativity of Shannon entropy, Gibbs' inequality (KL divergence ≥ 0), and the maximum entropy theorem (H ≤ log n). These are the three pillars upon which the full entropy power inequality (EPI) rests. Gibbs' inequality was proved via Jensen's inequality for the concave log function (`ConcaveOn.le_map_sum`), and the maximum entropy theorem was derived as a corollary by instantiating the reference distribution as uniform.

We also formalized the entropy power function `exp(2H/d)` and proved it is convex — which makes the EPI remarkable, since it asserts superadditivity of a convex function (normally convex functions are subadditive). The critical barrier to proving the full EPI in Lean is the absence of differential entropy, Fisher information, and convolution of probability measures in Mathlib. An initial attempt to prove `exp(a) + exp(b) ≤ exp(a+b)` for positive reals was identified as FALSE (counterexample: a = b = 0.1), saving a wasted proof cycle.

The structural insight is: the EPI's truth depends on the specific relationship between convolution and entropy — it cannot be derived from convexity/concavity arguments alone. The equality case (Gaussians) is algebraic, but the inequality requires either Fisher information monotonicity (Stam's proof) or optimal transport methods (Villani's approach). Both require infrastructure not yet in Mathlib.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `shannonEntropy_nonneg` | **proved** | Shannon entropy is non-negative for any probability distribution on Fin n |
| `gibbs_inequality` | **proved** | KL divergence is non-negative (the fundamental inequality of information theory) |
| `shannonEntropy_le_log_card` | **proved** | Maximum entropy is log n, achieved by the uniform distribution |
| `entropyPowerFn_pos` | **proved** | Entropy power is always positive |
| `entropyPowerFn_mono` | **proved** | Entropy power is monotone in entropy |
| `entropyPowerFn_convex` | **proved** | Entropy power function is convex (makes EPI non-trivial) |
| `IsStrictProbDist.le_one` | **proved** | Components of a strict probability distribution are at most 1 |

## Research Directions

### Direction 1: Conditional Entropy and Data Processing Inequality
**Hypothesis**: For jointly distributed random variables on finite alphabets, H(X|Y) ≤ H(X) (conditioning reduces entropy), and more generally the data processing inequality I(X;Z) ≤ I(X;Y) holds when X → Y → Z is a Markov chain.
**Test**: Define joint distributions on `Fin n × Fin m`, conditional entropy, and mutual information using the existing `shannonEntropy` infrastructure. Prove H(X|Y) ≤ H(X) via a reduction to `gibbs_inequality`.
**Why now**: The `gibbs_inequality` proof via Jensen provides the template — conditional entropy inequalities follow from the same Jensen argument applied to conditional distributions.
**If true**: Unlocks the full chain of information-theoretic inequalities (Fano's inequality, capacity bounds) in Lean 4.
**If false**: Would indicate a formalization gap in how we model joint distributions (not mathematically false).

### Direction 2: Log-Sobolev Inequality as EPI Proxy
**Hypothesis**: The log-Sobolev inequality `Ent_μ(f²) ≤ 2C · ∫ |∇f|² dμ` for Gaussian measure μ can be formalized using Mathlib's measure theory, and implies a form of the entropy power inequality via the Bakry-Émery method.
**Test**: Check if Mathlib has Gaussian measure and gradient norms; if so, state the log-Sobolev inequality and attempt to prove it via the Herbst argument or direct computation for Gaussians.
**Why now**: Mathlib's measure theory is mature enough for integration, and Gaussian measures may already be formalized. The key insight is that log-Sobolev is logically equivalent to hypercontractivity, which is equivalent to EPI for Gaussians.
**If true**: Provides an alternative route to EPI that avoids Fisher information entirely.
**If false**: Likely means Gaussian measure infrastructure is missing, guiding what to build next.

### Direction 3: Discrete Entropy Power Inequality (Tao's Sumset Bound)
**Hypothesis**: For independent random variables X, Y on ℤ with finite support, |supp(X+Y)| ≥ |supp(X)| + |supp(Y)| - 1 (the Cauchy-Davenport theorem over ℤ), which is the discrete analogue of the 1D Brunn-Minkowski inequality.
**Test**: Formalize `Finset` Minkowski sums on ℤ and prove the 1D sumset bound directly. This avoids all measure theory and captures the combinatorial core of EPI.
**Why now**: This is purely combinatorial and uses only `Finset` API. The key insight is that Cauchy-Davenport over ℤ is trivial (it's just interval arithmetic), unlike the ℤ/pℤ version which requires Fermat's little theorem.
**If true**: Gives the first formalized connection between EPI and additive combinatorics in Lean 4.
**If false**: Would be mathematically surprising — likely indicates a formalization bug.

### Direction 4: Rényi Entropy and the α-EPI
**Hypothesis**: The Rényi entropy `H_α(p) = (1/(1-α)) log(Σ p_i^α)` satisfies H_α(p) ≤ log n for all α > 0 (generalizing our maximum entropy theorem), and H_α(p) → H(p) as α → 1 (recovering Shannon entropy).
**Test**: Define Rényi entropy, prove `H_α ≤ log n` using the power mean inequality, and prove the limit α → 1 using L'Hôpital or direct Taylor expansion of x^α around α = 1.
**Why now**: The `shannonEntropy_le_log_card` proof structure (Jensen + uniform comparison) should generalize directly to Rényi entropy using the convexity of x^α. The key insight is that Rényi entropy is a one-parameter family interpolating between min-entropy (α → ∞) and max-entropy (α → 0).
**If true**: Opens the door to the α-entropy power inequality of Bobkov-Chistyakov, which provides tighter bounds than classical EPI.
**If false**: The limit α → 1 may require careful analysis of 0·log(0) conventions.

### Direction 5: Fisher Information and de Bruijn Identity
**Hypothesis**: Fisher information J(X) = E[(d/dx log f(X))²] for a density f can be defined for discrete distributions (using finite differences), and the discrete de Bruijn identity dH(X+√t Z)/dt = (1/2)J(X+√t Z) connects entropy and Fisher information.
**Test**: Define discrete Fisher information as Σ (p_{i+1} - p_i)² / p_i (the chi-squared divergence of the gradient), prove J ≥ 0, and establish the relationship H = ∫ J in the discrete heat equation setting.
**Why now**: The key insight is that the continuous de Bruijn identity is the heart of the Stam-Blachman proof of EPI, and discretizing it avoids measure-theoretic complications. Our existing entropy infrastructure handles the discrete setting cleanly.
**If true**: Provides the first step toward a full discrete EPI proof, completing the information-theoretic toolkit.
**If false**: Discrete Fisher information may not satisfy the right monotonicity — this would teach us what's special about the continuous case.
