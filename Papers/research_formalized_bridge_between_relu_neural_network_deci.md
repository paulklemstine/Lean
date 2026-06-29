# Maslov Dequantization Isometry: Certified Robustness for Neural Classifiers via Tropical Geometry

## Abstract

We establish a formally verified bridge between ReLU neural network classifiers and tropical algebraic geometry, culminating in the first certified adversarial robustness guarantee derived from Maslov dequantization. Our main result — the **Maslov Dequantization Isometry Theorem** — proves that for an EML (Emergent Meta-Language) classifier with *m* classes and *d* affine pieces per class, built from *L*-Lipschitz component functions: (i) the Maslov map is a semiring homomorphism modulo ε·log 2; (ii) the pointwise dequantization error is bounded by ε·log d; (iii) the Lipschitz constant is preserved exactly through dequantization; and (iv) certified L∞ robustness transfers from the tropical to the smooth classifier with an explicit radius formula. All results are formalized in Lean 4 with Mathlib and compile without `sorry` or non-standard axioms. Supporting results include the depth-width asymmetry inequality (w+1)^L ≥ Lw + 1, ReLU-as-tropical-polynomial identities, tropical distributivity, and exact characterization of the log-sum-exp approximation gap.

**Keywords**: tropical geometry, neural networks, certified robustness, Maslov dequantization, ReLU, log-sum-exp, Lipschitz continuity, formal verification

---

## 1. Introduction

### 1.1 Motivation

The connection between ReLU neural networks and tropical geometry was first observed by Zhang et al. (2018), who noted that a ReLU network computes a tropical rational function — a difference of convex piecewise linear functions expressible as max-plus polynomials. This connection has inspired a growing body of work relating network architecture to the combinatorial complexity of decision boundaries (Montúfar et al., 2014; Arora et al., 2018).

However, a fundamental gap has persisted between the *tropical* (piecewise linear) analysis and the *smooth* functions that networks actually compute in practice, where softmax layers and temperature scaling replace hard maximums. The Maslov dequantization — the classical construction that deforms the tropical (max, +) semiring into the ordinary (×, +) semiring via the family of maps x ↦ ε·log(exp(x/ε)) — provides a natural bridge, but its quantitative properties for neural network analysis had not been formalized.

### 1.2 Contributions

This work makes the following contributions:

1. **Maslov Dequantization Isometry Theorem** (Theorem 4.1): A unified four-part result proving semiring approximation, pointwise error bounds, exact Lipschitz preservation, and certified robustness transfer. This is formalized as `maslov_dequantization_isometry` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean].

2. **Log-sum-exp Approximation Theory** (§3): Tight two-sided bounds for both binary and d-term log-sum-exp, including the 1-Lipschitz property of the scalar log-sum-exp function. Formalized as `logsumexp_binary_upper`, `logsumexp_binary_lower`, `logsumexp_d_lower`, `logsumexp_d_upper`, and `logsumexp_one_lipschitz` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean].

3. **Tropical Foundations for ReLU Networks** (§2): ReLU as tropical addition (`relu_eq_tropAdd_zero`), tropical distributivity (`tropMul_tropAdd_distrib`), depth-width region bounds (`depth_exponential`, `depth_double_squares`), and the activation barrier theorem (`activation_barrier`). Formalized in @file[Catalog/Tropical/TropicalDeepLearningFoundations.lean].

4. **Tropical Metric and Spectral Theory** (§5): Triangle inequality for tropical distance, Hodge orthogonality for tropical 1-forms, ReLU Lipschitz bounds, and Maslov dequantization in the min-plus convention. Formalized in @file[Catalog/Tropical/Bridges.lean].

5. **Tropical Circuit Duality** (§5): Full duality between min-plus and max-plus formulations via negation, with contraction bounds for individual gates. Formalized in @file[Catalog/Tropical/TropicalTrapdoorResearch.lean].

### 1.3 Formal Verification

All results are formalized in Lean 4 using Mathlib. Proofs compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). The formalization serves as both a machine-checked certificate and a precise specification of assumptions.

---

## 2. Tropical Foundations

### 2.1 The Tropical Semiring

The **tropical semiring** (ℝ ∪ {−∞}, ⊕, ⊗) consists of the extended reals with:
- **Tropical addition**: a ⊕ b := max(a, b)
- **Tropical multiplication**: a ⊗ b := a + b

The additive identity is −∞ and the multiplicative identity is 0. Tropical multiplication distributes over tropical addition:

**Theorem 2.1** (Tropical Distributivity). *For all a, b, c ∈ ℝ:*
$$a \otimes (b \oplus c) = (a \otimes b) \oplus (a \otimes c)$$

*Proof sketch.* This is the identity max(a + b, a + c) = a + max(b, c), which follows from the translation invariance of the maximum. Formalized as `tropMul_tropAdd_distrib` in @file[Catalog/Tropical/TropicalDeepLearningFoundations.lean]. □

### 2.2 ReLU as Tropical Addition

The Rectified Linear Unit is defined as ReLU(x) = max(x, 0). This is precisely tropical addition with the multiplicative identity:

**Theorem 2.2** (ReLU–Tropical Identity). *ReLU(x) = x ⊕ 0 for all x ∈ ℝ.*

*Proof.* By definition, x ⊕ 0 = max(x, 0) = ReLU(x). Formalized as `relu_eq_tropAdd_zero` in @file[Catalog/Tropical/TropicalDeepLearningFoundations.lean]. □

**Theorem 2.3** (Activation Barrier). *There is no affine function f(x) = ax + b satisfying f(0) = 0, f(1) = 1, and f(−1) = 0. In particular, ReLU is not affine.*

*Proof sketch.* From f(0) = b = 0, f(1) = a = 1, but then f(−1) = −1 ≠ 0, contradiction. Formalized as `activation_barrier` and `relu_not_affine'` in @file[Catalog/Tropical/TropicalDeepLearningFoundations.lean]. □

### 2.3 Region Counting and Depth-Width Asymmetry

A ReLU network with depth L and width w in one-dimensional input space partitions its domain into at most (w + 1)^L linear regions.

**Definition 2.4.** `max_regions_1d(w, L) := (w + 1)^L`

**Theorem 2.5** (Width is Linear). *max_regions_1d(w, 1) = w + 1.*

**Theorem 2.6** (Depth is Exponential). *max_regions_1d(w, L) = (w + 1)^L.*

**Theorem 2.7** (Depth Doubling Squares Regions). *max_regions_1d(w, 2L) = (max_regions_1d(w, L))².*

These are formalized as `width_linear`, `depth_exponential`, and `depth_double_squares` in @file[Catalog/Tropical/TropicalDeepLearningFoundations.lean].

The fundamental inequality underlying these results is:

**Theorem 2.8** (Depth-Width Asymmetry). *For all w, L ∈ ℕ: (w + 1)^L ≥ Lw + 1.*

This quantifies the exponential advantage of depth over width: L layers of width w yield exponentially more regions than a single layer of width Lw.

---

## 3. Log-Sum-Exp Approximation Theory

### 3.1 Binary Bounds

The log-sum-exp function LSE(a, b) = log(exp(a) + exp(b)) is a smooth approximation to the maximum. We establish tight two-sided bounds:

**Theorem 3.1** (Binary LSE Lower Bound). *For all a, b ∈ ℝ:*
$$\max(a, b) \leq \log(\exp(a) + \exp(b))$$

*Proof sketch.* Since exp(a) + exp(b) ≥ exp(a) and exp(a) + exp(b) ≥ exp(b), by monotonicity of log, log(exp(a) + exp(b)) ≥ max(log(exp(a)), log(exp(b))) = max(a, b). Formalized as `logsumexp_binary_lower` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean]. □

**Theorem 3.2** (Binary LSE Upper Bound). *For all a, b ∈ ℝ:*
$$\log(\exp(a) + \exp(b)) \leq \max(a, b) + \log 2$$

*Proof sketch.* We have exp(a) + exp(b) ≤ 2·exp(max(a, b)), so log(exp(a) + exp(b)) ≤ log(2·exp(max(a, b))) = max(a, b) + log 2. Formalized as `logsumexp_binary_upper` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean]. □

### 3.2 Scaled Binary Bounds (EML Addition)

For the scaled version with temperature parameter ε > 0, define:

**Definition 3.3.** `emlAdd(ε, f, g)(x) := ε · log(exp(f(x)/ε) + exp(g(x)/ε))`

**Definition 3.4.** `tropAdd(f, g)(x) := max(f(x), g(x))`

**Theorem 3.5** (EML-Tropical Addition Bound). *For all ε > 0, f, g, and x:*
$$|{\rm emlAdd}(\varepsilon, f, g)(x) - {\rm tropAdd}(f, g)(x)| \leq \varepsilon \cdot \log 2$$

*Proof sketch.* Apply the binary LSE bounds to a = f(x)/ε, b = g(x)/ε, then scale by ε. The scaling preserves the sandwich inequality and the error becomes ε·log 2. Formalized as `emlAdd_tropAdd_bound` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean]. □

### 3.3 Multi-Term Bounds

For d-term log-sum-exp with d ≥ 1, define:

**Definition 3.6.** `emlClassifier(Φ, ε)(x)(k) := ε · log(Σᵢ exp(Φ(k,i,x)/ε))`

**Definition 3.7.** `tropClassifier(Φ)(x)(k) := supᵢ Φ(k,i,x)`

**Theorem 3.8** (d-Term LSE Lower Bound). *For d ≥ 1, z : Fin d → ℝ, and ε > 0:*
$$\sup_i z_i \leq \varepsilon \cdot \log\left(\sum_i \exp(z_i/\varepsilon)\right)$$

*Proof sketch.* For each i, exp(zᵢ/ε) ≤ Σⱼ exp(zⱼ/ε), so zᵢ/ε ≤ log(Σⱼ exp(zⱼ/ε)), giving zᵢ ≤ ε·log(Σⱼ exp(zⱼ/ε)). Taking the supremum preserves the inequality. Formalized as `logsumexp_d_lower` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean]. □

**Theorem 3.9** (d-Term LSE Upper Bound). *For d ≥ 1, z : Fin d → ℝ, and ε > 0:*
$$\varepsilon \cdot \log\left(\sum_i \exp(z_i/\varepsilon)\right) \leq \sup_i z_i + \varepsilon \cdot \log d$$

*Proof sketch.* Since exp(zᵢ/ε) ≤ exp(supⱼ zⱼ/ε) for all i, summing gives Σᵢ exp(zᵢ/ε) ≤ d · exp(supⱼ zⱼ/ε). Applying log and scaling by ε yields the bound. Formalized as `logsumexp_d_upper` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean]. □

**Corollary 3.10** (Classifier Approximation). *For all k ∈ Fin m:*
$$|{\rm emlClassifier}(\Phi, \varepsilon)(x)(k) - {\rm tropClassifier}(\Phi)(x)(k)| \leq \varepsilon \cdot \log d$$

Formalized as `emlClassifier_tropClassifier_bound` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean].

### 3.4 The 1-Lipschitz Property

**Theorem 3.11** (Log-Sum-Exp is 1-Lipschitz in L∞). *For d ≥ 1, ε > 0, and z, w : Fin d → ℝ:*
$$\left|\varepsilon \cdot \log\left(\sum_i e^{z_i/\varepsilon}\right) - \varepsilon \cdot \log\left(\sum_i e^{w_i/\varepsilon}\right)\right| \leq \|z - w\|_\infty$$

*Proof sketch.* The key step is the ratio bound: Σᵢ exp(zᵢ/ε) ≤ exp(‖z−w‖∞/ε) · Σᵢ exp(wᵢ/ε), which follows from zᵢ ≤ wᵢ + ‖z−w‖∞. Applying log to both sides and scaling by ε gives ε·LSE(z) ≤ ε·LSE(w) + ‖z−w‖∞. The reverse direction follows by symmetry. Formalized as `logsumexp_one_lipschitz` with supporting lemma `logsumexp_ratio_bound` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean]. □

---

## 4. Main Result: Maslov Dequantization Isometry

### 4.1 Setup

Consider:
- An input space ℝⁿ with the L∞ norm
- m ≥ 2 classes, each scored by d affine pieces Φ(k, i, ·) : ℝⁿ → ℝ
- A temperature parameter ε > 0
- Each component Φ(k, i) is L-Lipschitz in L∞ with L > 0
- A true label y ∈ Fin m with tropical margin γ > 0

### 4.2 The Theorem

**Theorem 4.1** (Maslov Dequantization Isometry). *Under the above hypotheses, if the tropical margin satisfies γ + 2ε·log d ≤ classMargin(tropClassifier(Φ), x, y), then:*

*(i) Semiring Homomorphism:* For all f, g and x':
$$|{\rm emlAdd}(\varepsilon, f, g)(x') - {\rm tropAdd}(f, g)(x')| \leq \varepsilon \cdot \log 2$$

*(ii) Pointwise Dequantization Bound:* For all k ∈ Fin m:
$$|{\rm emlClassifier}(\Phi, \varepsilon)(x)(k) - {\rm tropClassifier}(\Phi)(x)(k)| \leq \varepsilon \cdot \log d$$

*(iii) Exact Lipschitz Preservation:* For all k ∈ Fin m, the map x ↦ emlClassifier(Φ, ε)(x)(k) is L-Lipschitz.

*(iv) Certified Robustness:* The EML classifier is certified robust at x with label y and radius r* = γ/(2L):
$$\forall \delta \in \mathbb{R}^n,\; \|\delta\|_\infty < \frac{\gamma}{2L} \implies \arg\max_k\; {\rm emlClassifier}(\Phi, \varepsilon)(x + \delta)(k) = y$$

*Proof sketch.* Parts (i)-(iii) follow directly from the log-sum-exp bounds and the 1-Lipschitz property established in §3. For part (iv), the argument proceeds in three steps:

1. The pointwise bound from (ii) gives |C_ε(x)(k) − C_0(x)(k)| ≤ ε·log d for all k.
2. By the class margin approximation lemma (`classMargin_approx_bound`), classMargin(C_ε, x, y) ≥ classMargin(C_0, x, y) − 2ε·log d ≥ γ.
3. By the margin-to-robustness transfer (`certified_robust_from_margin_bound`), any L-Lipschitz classifier with margin ≥ γ is certified robust with radius γ/(2L).

Formalized as `maslov_dequantization_isometry` in @file[Catalog/Bridges/MaslovDequantizationRobustness.lean]. □

### 4.3 Discussion of Part (iii)

The exact Lipschitz preservation in part (iii) is perhaps the most surprising component. One might expect the log-sum-exp aggregation to amplify Lipschitz constants — after all, it sums d exponential terms. The key insight is that log-sum-exp is a *weighted average* of its arguments (via the softmax weights), and a weighted average of L-Lipschitz functions is again L-Lipschitz with the *same* constant.

This is formalized through the `logsumexp_one_lipschitz` lemma: the scalar log-sum-exp ε·log(Σ exp(zᵢ/ε)) is 1-Lipschitz as a function of the vector z = (z₁,...,z_d) in L∞. Composing with the L-Lipschitz map x ↦ (Φ(k,1,x),...,Φ(k,d,x)) gives L-Lipschitz overall, with no factor of d.

---

## 5. Supporting Results

### 5.1 Tropical Metric Space Structure

The tropical distance d∞(u, v) = maxᵢ |uᵢ − vᵢ| defines a metric on ℝⁿ⁺¹.

**Theorem 5.1** (Tropical Triangle Inequality). *d∞(u, w) ≤ d∞(u, v) + d∞(v, w).*

**Theorem 5.2** (Positive Definiteness). *d∞(u, v) = 0 ⟺ u = v.*

Formalized as `tropDistance_triangle` and `tropDistance_eq_zero_iff` in @file[Catalog/Tropical/Bridges.lean].

### 5.2 Tropical Hodge Orthogonality

The discrete tropical de Rham complex on n + 1 vertices has a Hodge-type orthogonality:

**Theorem 5.3** (Hodge Orthogonality). *Let f : Fin(n+1) → ℝ and η an antisymmetric form with zero row sums. Then ⟨d₀f, η⟩ = 0.*

This connects the tropical 1-form inner product to graph Laplacian theory. Formalized as `exact_ortho_closed_row` in @file[Catalog/Tropical/Bridges.lean].

### 5.3 ReLU Properties

**Theorem 5.4** (ReLU Idempotence). *ReLU(ReLU(x)) = ReLU(x).*

**Theorem 5.5** (ReLU 1-Lipschitz). *|ReLU(x) − ReLU(y)| ≤ |x − y|.*

Formalized as `tropReLU_idempotent` and `tropReLU_lipschitz` in @file[Catalog/Tropical/Bridges.lean].

### 5.4 Tropical Circuit Duality

**Theorem 5.6** (Full Duality). *For all a, b ∈ ℝ:*
- *−min(a, b) = max(−a, −b)*
- *−max(a, b) = min(−a, −b)*  
- *−(a + b) = (−a) + (−b)*

**Theorem 5.7** (Gate Contraction). *|max(a₁, b₁) − max(a₂, b₂)| ≤ max(|a₁ − a₂|, |b₁ − b₂|).*

Formalized as `tropical_circuit_duality` and `max_gate_contraction` in @file[Catalog/Tropical/TropicalTrapdoorResearch.lean].

### 5.5 Maslov Dequantization in Min-Plus Convention

The min-plus convention uses −T·log(exp(−a/T) + exp(−b/T)) as a smooth approximation to min(a, b):

**Theorem 5.8** (Maslov Upper Bound, Min-Plus). *For T > 0:*
$$-T \cdot \log(\exp(-a/T) + \exp(-b/T)) \leq \min(a, b)$$

Formalized as `maslov_dequantization_upper` in @file[Catalog/Tropical/Bridges.lean].

---

## 6. Algorithms

### 6.1 Robustness Certification Algorithm

Given a trained network with parameters defining Φ, temperature ε, Lipschitz constant L, and an input-label pair (x, y):

```
CERTIFY-ROBUSTNESS(Φ, ε, L, x, y):
  1. Compute tropical scores: s_k = max_i Φ(k, i, x) for each class k
  2. Compute tropical margin: γ_trop = s_y - max_{k ≠ y} s_k
  3. Compute effective margin: γ_eff = γ_trop - 2ε·log(d)
  4. If γ_eff > 0: return certified radius r* = γ_eff / (2L)
  5. Else: return "not certifiable at this ε"
```

### 6.2 Temperature-Robustness Tradeoff

The certified radius r* = (γ_trop − 2ε·log d)/(2L) is a decreasing function of ε. This suggests:

```
OPTIMIZE-TEMPERATURE(Φ, L, x, y, ε_min, ε_max):
  1. Binary search for optimal ε in [ε_min, ε_max]
  2. For each candidate ε:
     a. Compute γ_trop (independent of ε)
     b. Compute r*(ε) = (γ_trop - 2ε·log d) / (2L)
     c. Verify network accuracy at temperature ε
  3. Return ε maximizing r*(ε) subject to accuracy constraint
```

---

## 7. Applications

### 7.1 Safety-Critical Systems

The certified robustness guarantee applies to any system using softmax-based classification:
- **Autonomous driving**: Certify that road sign classification is invariant to sensor noise within a specified L∞ ball.
- **Medical imaging**: Guarantee that diagnostic classifications (malignant/benign) are stable under acquisition artifacts.
- **Fraud detection**: Certify that adversarial perturbations to transaction features cannot change fraud classifications.

### 7.2 Network Architecture Selection

The depth-width asymmetry (Theorem 2.8) provides a principled criterion: for a fixed parameter budget, prefer deeper, narrower architectures to maximize the number of decision regions. The exponential gap (w+1)^L vs. Lw + 1 makes this tradeoff quantitative.

### 7.3 Temperature Calibration

The dequantization error ε·log d provides a formal basis for temperature selection in softmax layers. Lower temperatures tighten the tropical approximation but may impair gradient flow during training. The bound makes this tradeoff explicit and measurable.

---

## 8. Related Work

**Tropical geometry and neural networks.** Zhang et al. (2018) first observed the tropical connection. Montúfar et al. (2014) established asymptotic region bounds. Arora et al. (2018) studied the number of linear regions for deep networks. Our contribution is the formal verification of these foundations and the novel robustness transfer.

**Certified robustness.** Hein and Andriushchenko (2017) established Lipschitz-based robustness certificates. Cohen et al. (2019) developed randomized smoothing. Our approach differs in deriving exact (not probabilistic) certificates from the algebraic structure of the network.

**Maslov dequantization.** Litvinov (2007) and Viro (2001) developed the mathematical foundations. Our contribution is the first application to neural network robustness certification with formal verification.

**Formal verification in ML.** Prior work has formalized properties of individual neurons (Selsam et al., 2017) and specific architectures. Our work is the first to formalize the tropical-to-smooth bridge with certified robustness transfer.

---

## 9. Limitations and Scope

Several limitations should be acknowledged:

1. **Affine component assumption**: The main theorem assumes each class score is built from affine pieces Φ(k, i, ·). While this is the natural form for ReLU networks, it excludes networks with other activation functions (sigmoid, GELU, etc.).

2. **Lipschitz constant computation**: The certified radius depends on the Lipschitz constant L, which must be computed or estimated separately. For deep networks, naive Lipschitz estimates can be extremely loose (product of weight matrix norms), though tighter methods exist.

3. **L∞ norm specificity**: The robustness guarantee is stated for L∞ perturbations. Extension to L² perturbations would require different techniques.

4. **Temperature-accuracy tradeoff**: Lower temperatures ε give tighter robustness guarantees but may degrade classification accuracy. The theorem provides the robustness bound but does not address the accuracy side of this tradeoff.

5. **Scalability of tropical analysis**: For very large networks (millions of parameters), extracting the full tropical form is computationally expensive. The theoretical bounds hold regardless, but practical certification may require approximations.

---

## 10. Future Work

Several directions extend this framework:

### 10.1 Finset-Based Maslov Dequantization

Generalize the binary bounds to n-element log-sum-exp using Finset operations. The proof structure is identical — the lower bound uses exp(max/ε) ≤ Σ exp(aᵢ/ε) and the upper bound uses Σ exp(aᵢ/ε) ≤ n·exp(max/ε) — but formalization requires navigating the Finset.sup' and Finset.sum API in Lean/Mathlib. This would give a fully general dequantization theorem directly applicable to softmax layers with arbitrary numbers of classes.

### 10.2 Tropical Betti Number Bounds

A tropical Morse theory would bound the topological complexity (connected components, holes, higher-dimensional voids) of decision boundaries. The conjecture is that Σ_k β_k ≤ 2(w+1)^L · C(n-1+L, L), where β_k are the Betti numbers. Each breakpoint of a tropical polynomial acts like a critical point in Morse theory, and the tropical Morse inequality should bound Betti numbers by counting these critical points. The combinatorial region bound (w+1)^L provides the critical point count.

### 10.3 Convolutional Network Tropical Forms

Characterize the tropical structure of ConvNets, including term count bounds (at most c^L · k^L essential terms for c channels and filter size k) and Newton polygon symmetry from weight sharing. The translation invariance of convolution should manifest as a lattice symmetry of the Newton polygon.

### 10.4 Training Dynamics

Investigate whether the tropical degree (term count in canonical form) follows a phase transition during gradient descent — rapid growth during memorization, monotonic decrease during generalization. If confirmed, this would provide a geometric explanation for implicit regularization and Occam's razor in deep learning.

### 10.5 VC Dimension Bounds

Use the region count and hyperplane arrangement bounds to derive tight VC dimension estimates for ReLU networks. The tropical perspective suggests VCdim ≤ L·Σ_{k=0}^n C(w,k), which would give PAC learning sample complexity bounds directly from architecture parameters.

---

## References

- Arora, R., Basu, A., Mianjy, P., and Mukherjee, A. (2018). Understanding deep neural networks with rectified linear units. *ICLR*.
- Cohen, J., Rosenfeld, E., and Kolter, Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML*.
- Hein, M. and Andriushchenko, M. (2017). Formal guarantees on the robustness of a classifier against adversarial manipulation. *NeurIPS*.
- Litvinov, G. L. (2007). The Maslov dequantization, idempotent and tropical mathematics. *Journal of Mathematical Sciences*, 140(3):209–325.
- Montúfar, G., Pascanu, R., Cho, K., and Bengio, Y. (2014). On the number of linear regions of deep neural networks. *NeurIPS*.
- Viro, O. (2001). Dequantization of real algebraic geometry on logarithmic paper. *European Congress of Mathematics*.
- Zhang, L., Naitzat, G., and Lim, L.-H. (2018). Tropical geometry of deep neural networks. *ICML*.
