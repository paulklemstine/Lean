# Future Directions: Information-Theoretic Inequalities and Entropy Power

## 1. Sharp Equality Conditions for Gibbs' Inequality

We proved that KL(p‖q) ≥ 0 for discrete distributions. The natural next step is to formalize the equality characterization: KL(p‖q) = 0 if and only if p = q on the support of p. The key insight is that log(t) = t − 1 holds if and only if t = 1, so equality in each term forces p(x)/q(x) = 1 wherever p(x) > 0. This extends to a quantitative stability bound: KL(p‖q) ≥ (1/2)·‖p − q‖₁² (Pinsker's inequality), which would bridge information theory to total variation distance.

**Why now?** The `kl_term_ge_diff` lemma already isolates the pointwise inequality, and the strict version of `Real.log_le_sub_one_of_pos` (equality iff argument = 1) is available in Mathlib. The infrastructure for TV distance exists via `MeasureTheory.Measure.totalVariation`.

## 2. Continuous Entropy Power Inequality via Fisher Information

The full EPI for continuous distributions states N(X+Y) ≥ N(X) + N(Y) where N(X) = (1/(2πe))·exp(2h(X)/n). The standard proof goes through Fisher information: J(X) ≥ n/N(X) (the Cramér-Rao bound), and the Fisher information inequality J(X+Y)⁻¹ ≥ J(X)⁻¹ + J(Y)⁻¹. The key insight is that Fisher information is additive for independent random variables under convolution, and the de Bruijn identity connects differential entropy to Fisher information via the heat equation. Our algebraic equivalence `entropy_power_ineq_iff` already captures the analytic skeleton.

**Why now?** Mathlib has `MeasureTheory.Measure.absolutelyContinuous`, Radon-Nikodym derivatives, and L² space infrastructure. The main gap is formalizing Fisher information as J(X) = E[(∂/∂x log f(x))²] and proving the Cramér-Rao bound. The abstract `EPIFunctional` structure we defined provides a target interface.

## 3. Rényi Entropy Power Inequality and Interpolation

The Shannon EPI generalizes to Rényi entropies: for order α ∈ (0,1), the Rényi entropy power N_α(X+Y) ≥ N_α(X) + N_α(Y). The key insight is that Rényi entropy H_α(p) = (1/(1−α))·log(∑ pᵢ^α) interpolates between min-entropy (α→∞), Shannon entropy (α→1), and collision entropy (α=2), and the EPI should be proved by showing the entropy power is concave along heat flow for each order. Our `max_entropy_exponential` theorem on exponential family optimality extends naturally: the Rényi entropy maximizer under moment constraints is a q-exponential distribution.

**Why now?** The algebraic framework of `entropyPower` and `entropy_power_ineq_iff` generalizes directly. The Rényi entropy is a simpler analytic object than Shannon entropy (finite sums of powers), making it more tractable for formalization. The monotonicity of Rényi entropy in α (H_α ≥ H_β for α < β) can be proved from Hölder's inequality, which is in Mathlib.

## 4. Discrete Brunn-Minkowski via Entropy Method

Our `brunn_minkowski_epi_bridge` shows the algebraic equivalence between BM and EPI. The next step is to prove the discrete Brunn-Minkowski inequality |A+B| ≥ |A| + |B| − 1 for finite subsets of ℤ, using the entropy method: assign the uniform distribution on A and B, compute entropies, and apply the discrete EPI. The key insight is that for independent uniform random variables X ∈ A, Y ∈ B, we have H(X+Y) ≥ max(H(X), H(Y)) = max(log|A|, log|B|), and the discrete EPI provides a sharper bound. This would close the loop between our abstract `EPIFunctional` and concrete combinatorial geometry.

**Why now?** We have `shannon_entropy_le_log_card` (entropy ≤ log of support size) and the abstract EPI framework. The discrete BM is a finite combinatorial statement that doesn't require measure theory. Mathlib's `Finset.add` (Minkowski sum of finsets) and cardinality lemmas provide the combinatorial substrate.

## 5. Entropic Central Limit Theorem

Our `epi_iterated_growth` shows that iterated convolution grows the entropy power linearly. The entropic CLT strengthens this: for i.i.d. X₁,...,Xₙ with finite variance σ², the normalized sum Sₙ = (X₁+...+Xₙ)/√n satisfies H(Sₙ) → H(N(0,σ²)) as n→∞, where N(0,σ²) is the Gaussian. The key insight is that the deficit D(Sₙ ‖ Gaussian) decreases monotonically by the EPI, and the rate of convergence is O(1/n) in KL divergence (Barron's theorem). This would connect our discrete infrastructure to the continuous limit and provide a quantitative version of the CLT.

**Why now?** The iterated growth theorem provides the qualitative bound. The abstract `EPIFunctional` can be instantiated with normalized sums. Mathlib has the Gaussian distribution (`MeasureTheory.Measure.gaussian`) and characteristic function machinery that could support the convergence argument.
