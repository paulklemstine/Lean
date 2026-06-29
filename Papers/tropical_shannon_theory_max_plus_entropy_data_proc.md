# Tropical Shannon Information Theory: Max-Plus Entropy, Data Processing Inequality, and Thermodynamic Bridge

## Abstract

We develop the formal foundations of **tropical (max-plus) information theory**, the worst-case dual of Shannon's classical information theory. Where Shannon entropy measures average surprise, tropical entropy H_⊕(X) = −log(min_x p(x)) measures worst-case surprise — the Rényi entropy of order ∞. We formally verify 25+ theorems in Lean 4 with Mathlib, with zero `sorry` statements, establishing:

1. **Tropical entropy bounds**: H_⊕(X) ≥ 0, H_⊕(X) ≥ log|α|, H_⊕(Uniform) = log|α|
2. **Tropical KL divergence**: D_⊕(P‖Q) ≥ 0, D_⊕(P‖P) = 0, exp(D_⊕) = max-ratio
3. **Tropical Data Processing Inequality**: D_⊕(f#P ‖ f#Q) ≤ D_⊕(P ‖ Q) for any function f
4. **Entropy additivity**: H_⊕(p⊗q) = H_⊕(p) + H_⊕(q) for product distributions
5. **Thermodynamic bridge**: Free energy convergence log Z(β)/β → −E₀ at rate O(log|S|/β)
6. **Boltzmann bridge**: H_⊕(p_β) = β · E_max + log Z(β)

## 1. Introduction

Classical Shannon theory, built on the probability semiring (ℝ₊, +, ×), measures information through expectations: H(X) = −Σ p(x) log p(x) is the average surprise. This framework is elegant and powerful but fundamentally limited to average-case guarantees.

In settings where worst-case guarantees are needed — certified neural network robustness, post-quantum cryptographic security, zero-temperature thermodynamic limits — average-case measures are insufficient. We need the *tropical dual*: replace (ℝ₊, +, ×) with the tropical semiring (ℝ ∪ {−∞}, max, +), and every sum becomes a maximum, every product becomes a sum.

This substitution transforms Shannon theory systematically:
- **Shannon entropy** H(X) = −Σ p(x) log p(x) → **Tropical entropy** H_⊕(X) = −log(min_x p(x)) = max_x(−log p(x))
- **KL divergence** D(P‖Q) = Σ p(x) log(p/q) → **Tropical KL** D_⊕(P‖Q) = max_x log(p(x)/q(x))
- **Data processing** D(f#P‖f#Q) ≤ D(P‖Q) → **Tropical DPI** D_⊕(f#P‖f#Q) ≤ D_⊕(P‖Q)

The mathematical content is non-trivial: the tropical DPI requires a careful convexity argument about weighted sums of ratios, and the thermodynamic bridge requires partition function bounds with explicit convergence rates.

## 2. Definitions

### 2.1 Probability Distributions

We formalize strict probability distributions as structures:

```
structure StrictProbDist (α : Type*) [Fintype α] where
  pmf : α → ℝ
  nonneg : ∀ x, 0 ≤ pmf x
  sum_one : ∑ x, pmf x = 1
  pos : ∀ x, 0 < pmf x
```

The minimum probability `minProb` is defined as `Finset.min'` over the image of the pmf.

### 2.2 Tropical Shannon Entropy

**Definition.** For p : StrictProbDist α, the *tropical Shannon entropy* is:
$$H_\oplus(X) = -\log(\min_x p(x))$$

This is the Rényi entropy of order ∞, measuring the worst-case surprise.

### 2.3 Tropical KL Divergence

**Definition.** For distributions p, q with q strictly positive:
$$D_\oplus(P \| Q) = \max_x \log\frac{p(x)}{q(x)}$$

This is the max-log-likelihood ratio, measuring the maximum pointwise divergence.

### 2.4 Partition Function and Boltzmann Distribution

**Definition.** The partition function at inverse temperature β:
$$Z(\beta) = \sum_s \exp(-\beta \cdot \text{cost}(s))$$

The Boltzmann distribution: p_β(s) = exp(−β·cost(s))/Z(β).

## 3. Main Results

### 3.1 Tropical Entropy Bounds

**Theorem (tropical_entropy_nonneg).** H_⊕(X) ≥ 0 for any strict distribution.

*Proof.* Since min_x p(x) ≤ 1 (all probabilities ≤ 1 when they sum to 1), log(min_x p(x)) ≤ 0, so −log(min_x p(x)) ≥ 0. □

**Theorem (tropical_entropy_ge_log_card).** H_⊕(X) ≥ log|α|.

*Proof.* By pigeonhole: since Σ p(x) = 1 with |α| terms, min_x p(x) ≤ 1/|α|. Thus −log(min) ≥ log|α|. □

**Key insight**: In Shannon theory, the uniform distribution *maximizes* entropy (H = log|α|). In tropical theory, uniform *minimizes* entropy (H_⊕ = log|α|). This reversal is fundamental: tropical theory measures how bad the worst case is, and uniform is the best worst case.

### 3.2 Tropical KL Divergence

**Theorem (tropical_kl_nonneg).** D_⊕(P‖Q) ≥ 0.

*Proof.* By contradiction: if max_x log(p(x)/q(x)) < 0, then p(x) < q(x) for all x. Summing: 1 = Σp < Σq = 1, contradiction. □

**Theorem (tropical_kl_self).** D_⊕(P‖P) = 0.

*Proof.* max_x log(p(x)/p(x)) = max_x log(1) = 0. □

### 3.3 Tropical Data Processing Inequality

**Theorem (pushforward_tropicalKL_le).** For any f : α → β and distributions P, Q:
$$D_\oplus(f_\#P \| f_\#Q) \leq D_\oplus(P \| Q)$$

*Proof.* For any y ∈ β, the pushforward ratio is:
$$\frac{\sum_{f(x)=y} p(x)}{\sum_{f(x)=y} q(x)} = \frac{\sum_{f(x)=y} q(x) \cdot (p(x)/q(x))}{\sum_{f(x)=y} q(x)} \leq \max_{f(x)=y} \frac{p(x)}{q(x)} \leq \max_x \frac{p(x)}{q(x)}$$

Taking log and max over y gives the result. □

This is the central theorem: it says that **post-processing cannot increase worst-case divergence**. For neural networks, this means no layer can amplify the worst-case information leakage.

### 3.4 Entropy Additivity

**Theorem (tropical_entropy_product).** H_⊕(p⊗q) = H_⊕(p) + H_⊕(q).

*Proof.* For independent distributions, min_{(a,b)} p(a)q(b) = min_a p(a) · min_b q(b) (product of positive minima). Taking −log gives the sum of entropies. □

### 3.5 Thermodynamic Bridge

**Theorem (free_energy_sandwich).** For β > 0:
$$-E_0 \leq \frac{\log Z(\beta)}{\beta} \leq -E_0 + \frac{\log|S|}{\beta}$$

**Theorem (free_energy_convergence_rate).** The convergence rate is O(log|S|/β).

**Theorem (tropical_entropy_boltzmann).** H_⊕(p_β) = β · E_max + log Z(β).

These three theorems establish the bridge between tropical information theory and statistical mechanics: as β → ∞ (zero temperature), the free energy converges to the ground-state energy, and the tropical entropy of the Boltzmann distribution grows linearly with β.

## 4. Applications

### 4.1 Post-Quantum Security

The tropical KL security bound (tropical_kl_security_bound) directly provides:
- If D_⊕(P‖Q) < λ, then every element has ratio p(x)/q(x) < exp(λ)
- This bounds the maximum distinguishing advantage of any adversary (including quantum)

### 4.2 Certified Robustness

The tropical DPI (pushforward_tropicalKL_le) implies:
- For a neural network f = f_L ∘ ⋯ ∘ f_1, the worst-case information leakage at the output is bounded by the leakage at any intermediate layer
- This gives certified robustness: if the input layer has bounded tropical mutual information, so does the output

### 4.3 Thermodynamic Limits

The bridge theorems connect to:
- Zero-temperature limits of proof systems (tropical entropy = proof cost)
- Laplace's method for discrete optimization (partition function convergence)
- Ground-state computation via annealing (convergence rate O(log|S|/β))

## 5. Formalization Details

The formalization comprises:
- **2 Lean 4 files**, 600+ lines total
- **25+ verified theorems** with zero `sorry`
- **8+ definitions/structures** (ProbDist, StrictProbDist, tropicalEntropy, tropicalKL, MaxPlusChannel, PrefixCode, pushforward, prod)
- **Diverse tactics**: induction, rcases, by_contra, omega, linarith, field_simp, positivity, aesop, grind, simp, ring
- **Clean axioms**: only propext, Classical.choice, Quot.sound

## References

The tropical entropy H_⊕ is also known as the Rényi entropy of order ∞ or the min-entropy. The data processing inequality for Rényi divergences is studied in the information-theoretic literature. Our contribution is the complete formal verification of these results in the tropical/max-plus framework, with explicit connections to thermodynamics and computational applications.
