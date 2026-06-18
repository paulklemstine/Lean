# Tropical Certified Robustness for Attention-Style Max-Affine Gating Networks via Pathwise Margin Decomposition

## Abstract

We formally prove that tropical geometry controls certified adversarial robustness for neural networks with **input-dependent routing** — the class of architectures encompassing attention mechanisms, mixture-of-experts, and gating networks. While existing tropical robustness results rely on fixed computational graph structure, attention and gating architectures dynamically change their routing as the input is perturbed, breaking the static path analysis that prior work depends on. We show that a global pathwise Lipschitz certificate nonetheless survives under dynamic routing, yielding the first formally verified certified robustness theorem for this architecture class.

Our main contributions are:

1. **Max-affine Lipschitz closure** (Theorem `maxAffine_lipschitz_inf`): A finite maximum of affine functions with L₁ weight norm bounded by K is K-Lipschitz in L∞.

2. **Gated combination bound** (Theorem `gatedCombine_lipschitz_inf`): For a simplex-gated convex combination F(x) = Σⱼ g(x)ⱼ · φⱼ(x), the Lipschitz constant is bounded by Kφ + k·Kg·B, decomposing into branch Lipschitz contribution Kφ and routing perturbation penalty k·Kg·B.

3. **Hard max routing closure** (Theorem `hardMaxRoute_lipschitz_inf`): Hard attention preserves Lipschitz bounds without penalty.

4. **Certified classification radius** (Theorem `tropical_attention_certified_radius`): Within an L∞ ball of radius m/(2K_trop), the predicted class cannot change.

5. **Compositional certificate** (Theorem `eval_lipschitz_of_cert`): A recursively defined syntax for gated tropical networks admits a sound, recursively computed Lipschitz certificate.

All results are formally verified in Lean 4 with Mathlib, with proofs checked by the Lean kernel. No axioms beyond `propext`, `Classical.choice`, and `Quot.sound` are used.

---

## 1. Introduction

### 1.1 The Problem

Neural networks are vulnerable to adversarial perturbations: small, carefully crafted changes to the input can cause dramatic changes in the output classification. This has led to a rich literature on **certified robustness** — provable guarantees that the classifier's prediction cannot change within a specified neighborhood of the input.

The tropical geometry approach to certified robustness exploits the fact that ReLU networks compute piecewise-linear functions, which can be represented as maxima of affine forms (tropical polynomials in the max-plus semiring). The Lipschitz constant of such a function is controlled by the L₁ norms of its weight vectors, giving a computable certificate for the maximum perturbation radius that preserves classification.

### 1.2 The Gap: Input-Dependent Routing

Existing tropical robustness results work for **fixed-graph architectures**: feedforward networks, residual networks, and other architectures where the computational graph does not depend on the input. However, modern architectures increasingly use **input-dependent routing**:

- **Attention mechanisms** (transformers): Attention weights are computed from the input, dynamically re-weighting value vectors.
- **Mixture-of-experts (MoE)**: A gating network selects which expert sub-networks to activate.
- **Soft routing / capsule networks**: Routing coefficients between layers depend on the input.

In all these cases, the set of active computational paths changes as the input is perturbed. The static path analysis that underlies prior tropical robustness work breaks down because perturbing the input not only changes the values flowing through the network, but also changes *which paths are active*.

### 1.3 Our Contribution

We show that tropical geometry still controls robustness under input-dependent routing. The key insight is a **pathwise margin decomposition**: we separate the effect of perturbation into two terms:

1. **Branch perturbation**: How much each branch's output changes (controlled by branch Lipschitz constants).
2. **Routing perturbation**: How much the routing coefficients change (controlled by gate smoothness and branch magnitude).

Under simplex constraints (the gating weights sum to 1 and are nonneg), the branch perturbation term is automatically averaged, while the routing perturbation term introduces an additive penalty proportional to gate Lipschitz constant × branch output bound × number of branches.

This decomposition is the attention analogue of the residual/DAG decomposition in prior work: the routing perturbation contributes an extra additive term, but the overall bound remains a clean Lipschitz certificate that can be composed across layers.

---

## 2. Mathematical Framework

### 2.1 Definitions

**Affine functions.** For w ∈ ℝⁿ and b ∈ ℝ, the affine function is a(x) = w · x + b.

**L∞ distance.** For x, y ∈ ℝⁿ, d∞(x, y) = maxᵢ |xᵢ - yᵢ|.

**Max-affine representation.** A function f : ℝⁿ → ℝ has a max-affine representation if f(x) = maxⱼ (Wⱼ · x + bⱼ) for finitely many weight vectors Wⱼ and biases bⱼ.

**Simplex gating.** A gating function g : ℝⁿ → Δᵏ maps inputs to the probability simplex: g(x)ⱼ ≥ 0 and Σⱼ g(x)ⱼ = 1.

**Gated combination.** F(x) = Σⱼ g(x)ⱼ · φⱼ(x), where g is a simplex-valued gate and φⱼ are branch functions.

**Hard max routing.** F(x) = maxⱼ φⱼ(x).

### 2.2 The L₁-L∞ Duality

The foundational estimate is the **L₁ weight norm vs L∞ perturbation duality**:

**Theorem (affine_lipschitz_inf).** For any affine function a(x) = w · x + b,
```
|a(x) - a(y)| ≤ (Σᵢ |wᵢ|) · d∞(x, y).
```

*Proof.* a(x) - a(y) = Σᵢ wᵢ(xᵢ - yᵢ). Taking absolute values: |a(x) - a(y)| ≤ Σᵢ |wᵢ| · |xᵢ - yᵢ| ≤ (Σᵢ |wᵢ|) · maxᵢ |xᵢ - yᵢ| = ‖w‖₁ · d∞(x,y). □

### 2.3 Closure Under Finite Maxima

**Theorem (sup'_lipschitz_inf).** If each φⱼ is K-Lipschitz in d∞, then maxⱼ φⱼ is also K-Lipschitz.

*Proof.* WLOG assume maxⱼ φⱼ(x) ≥ maxⱼ φⱼ(y). Let j* achieve the max at x. Then:
```
maxⱼ φⱼ(x) - maxⱼ φⱼ(y) = φⱼ*(x) - maxⱼ φⱼ(y)
                           ≤ φⱼ*(x) - φⱼ*(y)     [since maxⱼ φⱼ(y) ≥ φⱼ*(y)]
                           ≤ |φⱼ*(x) - φⱼ*(y)|
                           ≤ K · d∞(x, y).
```
By symmetry, |maxⱼ φⱼ(x) - maxⱼ φⱼ(y)| ≤ K · d∞(x, y). □

This immediately gives:

**Corollary (maxAffine_lipschitz_inf).** If f(x) = maxⱼ(Wⱼ · x + bⱼ) and ‖Wⱼ‖₁ ≤ K for all j, then |f(x) - f(y)| ≤ K · d∞(x, y).

**Corollary (hardMaxRoute_lipschitz_inf).** Hard max routing preserves Lipschitz bounds.

### 2.4 The Gated Combination Decomposition (Main Theorem)

**Theorem (gatedCombine_lipschitz_inf).** Let F(x) = Σⱼ g(x)ⱼ · φⱼ(x) where:
- g(x) ∈ Δᵏ for all x (simplex-valued gate),
- |g(x)ⱼ - g(y)ⱼ| ≤ Kg · d∞(x, y) for all j (gate is Kg-Lipschitz per coordinate),
- |φⱼ(x) - φⱼ(y)| ≤ Kφ · d∞(x, y) for all j (branches are Kφ-Lipschitz),
- |φⱼ(x)| ≤ B for all j, x (branches are bounded).

Then:
```
|F(x) - F(y)| ≤ (Kφ + k · Kg · B) · d∞(x, y).
```

*Proof.* Write:
```
F(x) - F(y) = Σⱼ g(x)ⱼ · (φⱼ(x) - φⱼ(y))  +  Σⱼ (g(x)ⱼ - g(y)ⱼ) · φⱼ(y).
```

**First sum** (branch perturbation):
```
|Σⱼ g(x)ⱼ · (φⱼ(x) - φⱼ(y))| ≤ Σⱼ g(x)ⱼ · |φⱼ(x) - φⱼ(y)|
                                ≤ Σⱼ g(x)ⱼ · Kφ · d∞(x, y)
                                = Kφ · d∞(x, y) · Σⱼ g(x)ⱼ
                                = Kφ · d∞(x, y).
```
(Using g(x)ⱼ ≥ 0 and Σⱼ g(x)ⱼ = 1.)

**Second sum** (routing perturbation):
```
|Σⱼ (g(x)ⱼ - g(y)ⱼ) · φⱼ(y)| ≤ Σⱼ |g(x)ⱼ - g(y)ⱼ| · |φⱼ(y)|
                                ≤ Σⱼ (Kg · d∞(x, y)) · B
                                = k · Kg · B · d∞(x, y).
```

Combining: |F(x) - F(y)| ≤ (Kφ + k · Kg · B) · d∞(x, y). □

**Remark.** The decomposition into branch perturbation and routing perturbation is the core novelty. The simplex constraint is essential: it ensures the branch Lipschitz contributions are *averaged* rather than summed, keeping the first term at Kφ (independent of k). The routing penalty k · Kg · B is the "price of soft attention" — it vanishes when the gate is constant (Kg = 0, i.e., hard routing) and grows with gate sensitivity, branch magnitude, and number of branches.

### 2.5 Certified Classification Radius

**Theorem (logitGap_lipschitz_inf).** If each class logit fₖ is K_trop-Lipschitz, then:
```
|(fₖ(x) - fₗ(x)) - (fₖ(y) - fₗ(y))| ≤ 2 · K_trop · d∞(x, y).
```

*Proof.* |(fₖ(x) - fₖ(y)) - (fₗ(x) - fₗ(y))| ≤ |fₖ(x) - fₖ(y)| + |fₗ(x) - fₗ(y)| ≤ 2K_trop · d∞(x, y). □

**Theorem (tropical_attention_certified_radius).** Let f : {1,...,C} → (ℝⁿ → ℝ) be a classifier with class logits fₖ, each K_trop-Lipschitz in d∞. If class c has margin m at x:
```
∀d ≠ c: m ≤ fₖ(x) - f_d(x),
```
then for any z with d∞(x, z) < m / (2 · K_trop):
```
∀d ≠ c: f_d(z) < fₖ(z).
```

*Proof.* For any d ≠ c:
```
fₖ(z) - f_d(z) ≥ (fₖ(x) - f_d(x)) - 2K_trop · d∞(x, z)
               ≥ m - 2K_trop · d∞(x, z)
               > m - 2K_trop · m/(2K_trop) = 0.
```
Hence f_d(z) < fₖ(z). □

### 2.6 Compositional Certificate

We define an inductive type `TropGateNet` representing gated tropical networks:
- **Affine**: a(x) = w · x + b, with certLip = ‖w‖₁.
- **HardMax**: max of sub-networks, with certLip = max of sub-certLips.
- **GatedMix**: simplex-gated combination, with certLip = max(sub-certLips) + (k+1) · Kg · B.

**Theorem (eval_lipschitz_of_cert).** For any well-formed TropGateNet N:
```
|N.eval(x) - N.eval(y)| ≤ N.certLip · d∞(x, y).
```

This is proved by structural induction, applying the affine, hard max, and gated combination Lipschitz theorems at each level.

---

## 3. Formal Verification

All theorems are formalized and proved in Lean 4 with Mathlib (v4.28.0). The development consists of approximately 450 lines of Lean code in a single file, with:

- 15 definitions (core primitives, architecture components, well-formedness predicate)
- 15 proved theorems and lemmas (no `sorry` remains)
- Only standard axioms: `propext`, `Classical.choice`, `Quot.sound`

Key design decisions in the formalization:

1. **Concrete index types**: We use `Fin n`, `Fin k`, `Fin C` throughout, avoiding the complexity of abstract index types while maintaining full generality for finite networks.

2. **`Finset.sup'` for maxima**: Since ℝ lacks a bottom element, we use `Finset.sup'` (which requires nonemptiness) rather than `Finset.sup`. This requires `[Nonempty (Fin n)]` typeclass arguments.

3. **Recursive well-formedness**: The `TropGateNet.WellFormed` predicate is recursively defined, ensuring that gating conditions (simplex-valued, Lipschitz, bounded) hold at every level of the network.

---

## 4. Discussion: Making Tropical Robustness Accessible

### A Bridge Between Geometry and Safety

Imagine you're building a self-driving car. Your neural network needs to correctly classify a stop sign even when it's partially obscured by rain, slightly tilted, or photographed in unusual lighting. How confident can you be that a tiny change in the input image won't cause the network to suddenly see a yield sign instead?

This is the core question of **adversarial robustness**, and it's not just academic — adversarial examples have been shown to fool real-world systems in physically realizable ways.

### The Tropical Geometry Insight

Tropical geometry studies what happens when you replace addition with maximum and multiplication with addition — the "max-plus" algebra. This might seem like an abstract mathematical curiosity, but it turns out to be deeply connected to neural networks. A ReLU neuron computes max(0, w·x + b), which is exactly a tropical polynomial. A deep ReLU network computes a composition of such operations, making the entire network a tropical rational function.

The beautiful insight is that the Lipschitz constant of a tropical polynomial — how much its output can change per unit of input change — is controlled by the **L₁ norms of its weight vectors**. This is the "tropical Lipschitz constant," and it gives us a computable certificate for robustness.

### The Attention Challenge

Modern neural networks, especially transformers, add a twist: **attention**. In an attention mechanism, the network doesn't just compute a fixed function of its input — it first decides *how to weight* different parts of the computation, and those weights themselves depend on the input.

Think of it like a panel of experts giving advice. In a fixed network, you always listen to the same experts in the same proportions. With attention, the network first looks at the input and decides which experts to pay attention to. This makes the network more powerful, but it also makes robustness analysis harder: perturbing the input not only changes what each expert says, but also changes *which experts are being consulted*.

### Our Solution: Decompose and Conquer

Our key theorem shows that the effect of perturbation on an attention/gating network can be cleanly decomposed into two terms:

1. **What the experts say changes** (branch Lipschitz): Each expert's output changes by at most Kφ per unit of input perturbation.
2. **Who we listen to changes** (routing perturbation): The attention weights shift by at most Kg per unit of input perturbation, and each expert's output is bounded by B.

The total Lipschitz constant is Kφ + k·Kg·B, where k is the number of experts. The first term is independent of k (thanks to the simplex constraint on attention weights), while the second grows linearly with the number of experts.

This gives a precise **cost of soft attention**: using input-dependent routing costs you k·Kg·B in your Lipschitz bound compared to hard (input-independent) routing. But this cost is bounded and computable, so you can still certify robustness — you just need a larger margin to achieve the same certified radius.

### Historical Context

This work sits at the intersection of several research threads:

- **Tropical geometry** (Mikhalkin, Itenberg-Mikhalkin-Shustin): The algebraic geometry of the max-plus semiring, which provides the mathematical language for analyzing piecewise-linear functions.
- **Certified robustness** (Wong-Kolter 2018, Cohen et al. 2019): Provable guarantees against adversarial perturbations, as opposed to empirical robustness testing.
- **Lipschitz neural networks** (Miyato et al. 2018, Anil et al. 2019): Constraining or computing the Lipschitz constant of neural networks for stability and robustness.
- **Formal verification of neural networks** (Katz et al. 2017, Huang et al. 2017): Using formal methods to verify properties of neural networks.

Our contribution bridges these threads by extending the tropical robustness program to handle the dynamic routing that characterizes modern attention architectures, and doing so with machine-checked formal proofs.

---

## 5. Applications

### 5.1 Certified Adversarial Defense for Transformers

Given a transformer with attention-based routing, our theorem provides a recipe for certified robustness:

1. Compute the L₁ weight norms of all affine layers.
2. Estimate the Lipschitz constant of the attention softmax.
3. Bound the magnitude of value vectors.
4. Compose using the gatedCombine theorem to get K_trop.
5. Compute the certified radius r = margin / (2 · K_trop).

### 5.2 Architecture Design Guidance

The decomposition Kφ + k·Kg·B reveals a clear design tradeoff:
- **Reducing Kg** (smoother gates) improves robustness but may reduce expressivity.
- **Reducing B** (bounded branch outputs) tightens the routing penalty.
- **Reducing k** (fewer experts) reduces the routing penalty linearly.
- Temperature scaling in softmax attention directly controls Kg.

### 5.3 Mixture-of-Experts Robustness

For MoE architectures, the theorem quantifies the robustness cost of using more experts. With k experts, each with output bound B and gate Lipschitz Kg, the routing penalty is k·Kg·B. This provides guidance for choosing the number of experts in safety-critical applications.

---

## 6. Future Directions

1. **Tighter gating bounds**: The current bound k·Kg·B uses per-coordinate gate Lipschitz bounds. Using an L₁ sum over gate coordinates (∑ⱼ Kg_j) could tighten this.

2. **Layer-wise composition**: Extending the compositional framework to handle sequential composition with shared intermediate representations.

3. **Empirical tightness**: Studying how tight the certified radius is in practice for real transformer architectures.

4. **Probabilistic certificates**: Combining tropical Lipschitz bounds with randomized smoothing for probabilistic robustness guarantees.

5. **Tropical degree bounds**: Connecting the Lipschitz analysis to tropical degree theory for finer structural understanding of the network's piecewise-linear geometry.

---

## References

The formal proofs are available in `TropicalAttentionRobustness.lean`. Python demonstrations with numerical experiments are in the `demos/` directory.
