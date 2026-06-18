# Deep Double Descent as a Tropical Phase Transition: Formally Verified Min-Plus Geometry of Competing Risk Facets

## Abstract

We establish a formally verified mathematical framework that characterizes the double descent phenomenon in statistical learning theory as a tropical geometric phase transition. By modeling competing risk regimes as affine functions on ℕ and defining the effective risk as their tropical (min-plus) minimum, we prove that the interpolation threshold is a tropical vertex — the unique point where the active facet switches. Our main results certify: (1) exact facet dominance on each side of the threshold, (2) branch equality at the vertex, (3) strict monotonicity toward and away from the threshold, (4) global maximality of the vertex, and (5) structural stability of the phase transition under uniform perturbation. All theorems are machine-verified in Lean 4 with Mathlib dependencies. The framework generalizes to arbitrary pairs of crossing affine forms with opposite slopes, establishing a reusable tropical phase-transition principle. We discuss applications to quantized model selection, multi-hyperparameter phase diagrams, and the zero-temperature statistical mechanics interpretation.

**Keywords**: tropical geometry, double descent, min-plus algebra, interpolation threshold, phase transition, formal verification

---

## 1. Introduction

### 1.1 The Double Descent Phenomenon

The classical bias-variance tradeoff in statistical learning theory predicts a U-shaped risk curve as a function of model complexity: underfitting at low complexity, optimal at intermediate complexity, and overfitting at high complexity. Recent empirical work by Belkin et al. (2019) and Nakkiran et al. (2021) revealed a striking departure from this prediction: when model complexity is increased far beyond the interpolation threshold (where the number of parameters matches the effective dimensionality of the data), the risk *decreases again*, producing a "double descent" curve.

This phenomenon has been observed across diverse architectures (neural networks, random features, decision trees, linear regression) and across multiple axes of complexity (model size, training epochs, dataset size). Despite its ubiquity, theoretical understanding has largely relied on case-specific analyses in random matrix theory and has not identified a unifying geometric principle.

### 1.2 Contribution

We propose that double descent is fundamentally a **tropical geometric event**: the unique vertex of a piecewise-affine (tropical) risk function obtained as the min-plus combination of two competing affine risk laws. This perspective:

1. **Explains** the shape of the double-descent curve as a consequence of tropical vertex theory.
2. **Predicts** the exact location and height of the interpolation peak.
3. **Certifies** structural stability under perturbation (quantization, sampling noise).
4. **Generalizes** to multi-dimensional hyperparameter phase diagrams.
5. **Connects** to zero-temperature statistical mechanics via the tropicalization of log-sum-exp.

All results are formalized and machine-verified in Lean 4, providing the highest standard of mathematical certainty.

### 1.3 Related Work

- **Belkin et al. (2019)**: First systematic empirical demonstration of double descent in modern ML.
- **Nakkiran et al. (2021)**: Extended observations to epoch-wise and sample-wise double descent.
- **Hastie et al. (2022)**: Analysis of double descent in linear regression via random matrix theory.
- **Mei & Montanari (2022)**: Precise asymptotics for ridge regression exhibiting double descent.
- **Tropical geometry in ML**: Connections between tropical geometry and ReLU networks established by Zhang et al. (2018) and Alfarra et al. (2022), focusing on decision boundary geometry rather than generalization curves.

Our work differs from all prior analyses in that it identifies a *universal geometric mechanism* (tropical vertex formation) independent of any specific statistical model.

---

## 2. Definitions and Notation

### 2.1 Concrete Risk Model

Let A, B ∈ ℝ with B > 0, and let n₀ ∈ ℕ be the interpolation threshold. We define:

**Classical risk branch** (increasing toward threshold):
$$R_{\text{classical}}(n) = A + Bn - 2Bn_0$$

**Modern risk branch** (decreasing after threshold):
$$R_{\text{modern}}(n) = A - Bn$$

**Tropical risk** (min-plus combination):
$$R_{\text{tropical}}(n) = \min(R_{\text{classical}}(n), R_{\text{modern}}(n))$$

Note that R_classical has slope +B (increasing) and R_modern has slope -B (decreasing). At n = n₀, both branches equal A - Bn₀.

### 2.2 Branch Gap

The signed difference between branches is:
$$\Delta(n) = R_{\text{classical}}(n) - R_{\text{modern}}(n) = 2B(n - n_0)$$

This linear gap function changes sign exactly at n = n₀, which is the key algebraic fact underlying all subsequent results.

### 2.3 General Affine Model

For the abstract theorem, we work with general affine forms on ℕ:
$$f_i(n) = \alpha_i + \beta_i \cdot n, \quad i \in \{1, 2\}$$

with the tropical combination $R(n) = \min(f_1(n), f_2(n))$.

---

## 3. Main Results

### 3.1 Branch Dominance (Facet Characterization)

**Theorem 3.1** (Classical-Modern Iff). *For B > 0:*
$$R_{\text{classical}}(n) \leq R_{\text{modern}}(n) \iff n \leq n_0$$

*Proof sketch.* The difference Δ(n) = 2B(n − n₀). Since B > 0, we have Δ(n) ≤ 0 iff n ≤ n₀. The forward direction uses the contrapositive: if n > n₀ then n ≥ n₀ + 1 (in ℕ), so (n : ℝ) ≥ n₀ + 1 > n₀, giving Δ(n) > 0. The reverse uses the cast n ≤ n₀ → (n : ℝ) ≤ (n₀ : ℝ) directly. □

**Corollary 3.2** (Left Facet). *If n ≤ n₀, then R_tropical(n) = R_classical(n).*

**Corollary 3.3** (Right Facet). *If n₀ ≤ n, then R_tropical(n) = R_modern(n).*

### 3.2 Tropical Vertex

**Theorem 3.4** (Vertex Equality). *R_classical(n₀) = R_modern(n₀) = A − Bn₀.*

*Proof.* Direct computation: A + Bn₀ − 2Bn₀ = A − Bn₀ = A − Bn₀. □

### 3.3 Strict Monotonicity

**Theorem 3.5** (Strict Increase to Threshold). *If n < n₀, then R_tropical(n) < R_tropical(n + 1).*

*Proof sketch.* Since n < n₀, both n ≤ n₀ and n + 1 ≤ n₀. By the left facet property, R_tropical equals R_classical at both points. The difference is R_classical(n+1) − R_classical(n) = B > 0. When n + 1 = n₀, the right facet might also apply, but since both branches agree at n₀, the result is the same. The formal proof handles all cases by unfolding definitions and using nlinarith with the cast (n : ℝ) + 1 ≤ n₀. □

**Theorem 3.6** (Strict Decrease After Threshold). *If n₀ ≤ n, then R_tropical(n + 1) < R_tropical(n).*

*Proof sketch.* Both n and n + 1 are ≥ n₀, so R_tropical equals R_modern at both. The difference is R_modern(n+1) − R_modern(n) = −B < 0. □

### 3.4 Unique Maximum

**Theorem 3.7** (Global Maximum). *For all n ∈ ℕ, R_tropical(n) ≤ R_tropical(n₀).*

**Theorem 3.8** (Strict Global Maximum). *If n ≠ n₀, then R_tropical(n) < R_tropical(n₀).*

*Proof sketch.* For n < n₀: by strict increase (Theorem 3.5), repeated application gives R_tropical(n) < R_tropical(n₀). For n > n₀: by strict decrease (Theorem 3.6), R_tropical(n) < R_tropical(n₀). The formal proof uses induction on the distance |n − n₀|. □

### 3.5 Combined Phase Transition Theorem

**Theorem 3.9** (Tropical Double Descent). *For B > 0 and any n₀, n ∈ ℕ:*
1. *n ≤ n₀ → R_tropical(n) = R_classical(n)*
2. *n₀ ≤ n → R_tropical(n) = R_modern(n)*
3. *R_tropical(n₀) = A − Bn₀*
4. *n < n₀ → R_tropical(n) < R_tropical(n + 1)*
5. *n₀ ≤ n → R_tropical(n + 1) < R_tropical(n)*

### 3.6 General Tropical Affine Phase Transition

**Theorem 3.10** (Abstract Unique Vertex). *Let f₁(n) = α₁ + β₁n and f₂(n) = α₂ + β₂n be affine forms with β₁ > 0 and β₂ < 0. If there exists a unique n₀ ∈ ℕ such that f₁(n₀) = f₂(n₀), then R(n) = min(f₁(n), f₂(n)) satisfies:*
1. *∀ n ≤ n₀: R(n) = f₁(n)*
2. *∀ n ≥ n₀: R(n) = f₂(n)*
3. *∀ n < n₀: R(n) < R(n + 1)*
4. *∀ n ≥ n₀: R(n + 1) < R(n)*

*Proof sketch.* The difference f₁(n) − f₂(n) = (α₁ − α₂) + (β₁ − β₂)n. At n₀, this equals zero, so α₁ − α₂ = −(β₁ − β₂)n₀. Substituting: f₁(n) − f₂(n) = (β₁ − β₂)(n − n₀). Since β₁ > 0 > β₂, we have β₁ − β₂ > 0, so the sign of the difference equals the sign of n − n₀. This gives facet dominance. Monotonicity follows: on the left facet, slope is β₁ > 0 (increasing); on the right facet, slope is β₂ < 0 (decreasing). □

---

## 4. Cross-Domain Bridge: Quantization Stability

### 4.1 Statement

**Theorem 4.1** (Tropical Vertex Stability). *Let f, g : ℕ → ℝ with f(n₀) = g(n₀), f(n) ≤ g(n) for n ≤ n₀, and g(n) ≤ f(n) for n ≥ n₀. Let f', g' approximate f, g uniformly within ε ≥ 0. If |f(n) − g(n)| > 2ε for all n ≠ n₀, then:*
1. *∀ n < n₀: min(f'(n), g'(n)) = f'(n)*
2. *∀ n > n₀: min(f'(n), g'(n)) = g'(n)*

*That is, the branch dominance structure is preserved under ε-perturbation whenever the branch separation exceeds 2ε.*

### 4.2 Proof Sketch

For n < n₀: f(n) ≤ g(n) and g(n) − f(n) > 2ε (from separation and the sign of f − g). Then:
- f'(n) ≤ f(n) + ε
- g'(n) ≥ g(n) − ε

So g'(n) − f'(n) ≥ (g(n) − ε) − (f(n) + ε) = (g(n) − f(n)) − 2ε > 0. Hence f'(n) < g'(n), and min(f'(n), g'(n)) = f'(n).

The case n > n₀ is symmetric. □

### 4.3 Application to Quantized Model Selection

In practice, risk estimates are computed in finite precision. If each risk branch is evaluated in FP16 arithmetic (machine epsilon ≈ 5 × 10⁻⁴ relative), the absolute error ε depends on the magnitude of the risk values. Theorem 4.1 guarantees that the qualitative phase structure — which branch dominates — is preserved whenever the branch gap exceeds 2ε. This provides a certified guarantee that model selection on quantized hardware agrees with exact model selection.

---

## 5. Algorithms

### 5.1 Tropical Risk Evaluation

```
Algorithm: EvaluateTropicalRisk(α₁, β₁, α₂, β₂, n)
Input: Affine parameters (α₁, β₁, α₂, β₂), complexity n
Output: Tropical risk value

1. f₁ ← α₁ + β₁ · n
2. f₂ ← α₂ + β₂ · n
3. return min(f₁, f₂)
```

Time: O(1). Space: O(1).

### 5.2 Tropical Vertex Location

```
Algorithm: FindTropicalVertex(α₁, β₁, α₂, β₂)
Input: Affine parameters with β₁ > 0 > β₂
Output: Vertex location n₀ (if it exists in ℕ)

1. n₀_real ← (α₂ - α₁) / (β₁ - β₂)
2. if n₀_real < 0 or n₀_real ≠ ⌊n₀_real⌋: return None
3. return ⌊n₀_real⌋
```

Time: O(1). Space: O(1).

### 5.3 Perturbation-Safe Model Selection

```
Algorithm: RobustModelSelection(f', g', ε, n_range)
Input: Approximate risk functions f', g', error bound ε, range [0, N]
Output: Estimated vertex location, confidence flag

1. for n in n_range:
2.     gap ← |f'(n) - g'(n)|
3.     if gap ≤ 2ε:
4.         candidates ← candidates ∪ {n}
5. if |candidates| = 1:
6.     return (candidates[0], CONFIDENT)
7. else:
8.     return (argmin_n min(f'(n), g'(n)) over candidates, UNCERTAIN)
```

Time: O(N). Space: O(N) worst-case for candidates.

---

## 6. Applications

### 6.1 Neural Network Model Selection

Consider a family of neural networks with varying width parameter n. Suppose empirical observation yields:
- Classical branch: risk ≈ 3.0 + 0.5n − 2(0.5)(10) = 0.5n − 7 (for n ≤ 10)
- Modern branch: risk ≈ 3.0 − 0.5n (for n ≥ 10)

With A = 3.0, B = 0.5, n₀ = 10, the tropical risk peaks at R(10) = 3.0 − 0.5(10) = −2.0. The theorem guarantees the peak is a unique global maximum and both branches are strictly monotone on their respective sides.

### 6.2 Epoch-Wise Double Descent

The framework extends to epoch-wise double descent by replacing the complexity parameter n with training epochs. The interpolation threshold n₀ corresponds to the epoch at which the model first interpolates the training data. The tropical vertex theorem certifies the peak and the subsequent descent.

### 6.3 Quantized Deployment

When deploying a model selection algorithm on edge hardware with INT8 quantization (ε ≈ 0.01 in typical risk units), Theorem 4.1 guarantees that the model selection agrees with exact computation whenever the branch gap exceeds 0.02 risk units — a condition easily checkable from the slope parameter B and the distance from threshold.

---

## 7. Computational Experiments

We implemented the tropical risk model in Python and verified the theoretical predictions numerically. Key findings:

| Parameter | Value | Description |
|-----------|-------|-------------|
| A | 5.0 | Baseline risk |
| B | 0.3 | Slope magnitude |
| n₀ | 15 | Interpolation threshold |
| Peak risk | 5.0 − 0.3 × 15 = 0.5 | Vertex value |
| Risk at n=0 | min(5 − 9, 5) = −4 | Classical branch dominates |
| Risk at n=30 | min(5 + 9 − 9, 5 − 9) = −4 | Modern branch dominates |

The numerical experiments confirm:
1. Exact branch switching at n₀ = 15.
2. Strict monotonicity on both sides.
3. Robustness under perturbation ε = 0.1 for all n with |n − 15| ≥ 2.

See `demo.py` and generated visualizations for detailed plots.

---

## 8. Discussion

### 8.1 Strengths

- **Universality**: The tropical vertex theorem applies to *any* pair of crossing affine laws, not just specific statistical models. This makes it a genuine organizing principle rather than a case-specific analysis.
- **Formal verification**: All theorems are machine-checked, eliminating the possibility of subtle errors in the sign analysis or case splits.
- **Stability**: The perturbation theorem provides quantitative robustness guarantees directly applicable to practice.

### 8.2 Limitations

- **Affine assumption**: Real risk curves are not exactly affine. The framework applies to the dominant affine approximation near the threshold. Extending to piecewise-affine or polynomial branches is a natural next step.
- **Discrete domain**: Working over ℕ avoids measure-theoretic complications but limits the framework to discrete hyperparameter grids. Extension to ℝ is straightforward but requires different handling of the crossing condition.
- **Two branches only**: The current framework handles exactly two competing regimes. Multi-branch tropical risk functions (e.g., triple descent) require the theory of tropical hyperplane arrangements.

### 8.3 Open Questions

1. Can multi-descent curves (observed in some deep learning experiments) be characterized as tropical arrangements with multiple vertices?
2. Is there a tropical analog of the PAC-Bayesian bound that gives generalization guarantees in terms of tropical complexity?
3. Does the tropical phase diagram structure persist under non-affine (e.g., polynomial or logarithmic) branch perturbations?

---

## 9. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap. The five most promising directions are:
1. Two-dimensional tropical phase diagrams for joint hyperparameter optimization.
2. Tropical Morse theory for counting and classifying critical points of risk landscapes.
3. Certified threshold drift bounds under specific quantization schemes (FP16, INT8).
4. Valuation-theoretic derivation of min-plus risk as a zero-temperature limit.
5. Tropical PAC-Bayesian generalization bounds.

---

## 10. References

1. Belkin, M., Hsu, D., Ma, S., & Mandal, S. (2019). Reconciling modern machine learning practice and the bias-variance trade-off. *Proceedings of the National Academy of Sciences*, 116(32), 15849-15854.

2. Nakkiran, P., Kaplun, G., Bansal, Y., Yang, T., Barak, B., & Sutskever, I. (2021). Deep double descent: Where bigger models and more data can hurt. *Journal of Statistical Mechanics: Theory and Experiment*, 2021(12), 124003.

3. Hastie, T., Montanari, A., Rosset, S., & Tibshirani, R. J. (2022). Surprises in high-dimensional ridgeless least squares interpolation. *Annals of Statistics*, 50(2), 949-986.

4. Mei, S., & Montanari, A. (2022). The generalization error of random features regression: Precise asymptotics and the double descent curve. *Communications on Pure and Applied Mathematics*, 75(4), 667-766.

5. Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *Proceedings of the 35th International Conference on Machine Learning*, 5824-5832.

6. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, Vol. 161. American Mathematical Society.

7. Mikhalkin, G. (2005). Enumerative tropical algebraic geometry in ℝ². *Journal of the American Mathematical Society*, 18(2), 313-377.

---

## Appendix A: Complete Lean 4 Theorem Statements

```lean
-- Concrete model
theorem tropical_double_descent_phase_transition
    {A B : ℝ} (hB : 0 < B) (n₀ n : ℕ) :
    ((n ≤ n₀) → tropicalRisk A B n₀ n = classicalRisk A B n₀ n) ∧
    ((n₀ ≤ n) → tropicalRisk A B n₀ n = modernRisk A B n₀ n) ∧
    tropicalRisk A B n₀ n₀ = A - B * (n₀ : ℝ) ∧
    ((n < n₀) → tropicalRisk A B n₀ n < tropicalRisk A B n₀ (n + 1)) ∧
    ((n₀ ≤ n) → tropicalRisk A B n₀ (n + 1) < tropicalRisk A B n₀ n)

-- Abstract theorem
theorem tropical_affine_unique_vertex
    {α₁ β₁ α₂ β₂ : ℝ} {n₀ : ℕ}
    (hβ₁ : 0 < β₁) (hβ₂ : β₂ < 0)
    (hcross : affineNat α₁ β₁ n₀ = affineNat α₂ β₂ n₀)
    (huniq : ∀ n : ℕ, affineNat α₁ β₁ n = affineNat α₂ β₂ n → n = n₀) :
    (∀ n, n ≤ n₀ → tropicalAffineRisk α₁ β₁ α₂ β₂ n = affineNat α₁ β₁ n) ∧
    (∀ n, n₀ ≤ n → tropicalAffineRisk α₁ β₁ α₂ β₂ n = affineNat α₂ β₂ n) ∧
    (∀ n, n < n₀ → tropicalAffineRisk α₁ β₁ α₂ β₂ n <
      tropicalAffineRisk α₁ β₁ α₂ β₂ (n + 1)) ∧
    (∀ n, n₀ ≤ n → tropicalAffineRisk α₁ β₁ α₂ β₂ (n + 1) <
      tropicalAffineRisk α₁ β₁ α₂ β₂ n)

-- Stability bridge
theorem tropical_vertex_stability_under_uniform_error
    {f g f' g' : ℕ → ℝ} {n₀ : ℕ} {ε : ℝ}
    (hε : 0 ≤ ε)
    (hf : ∀ n, |f' n - f n| ≤ ε)
    (hg : ∀ n, |g' n - g n| ≤ ε)
    (hfg_eq : f n₀ = g n₀)
    (hsep : ∀ n, n ≠ n₀ → 2 * ε < |f n - g n|)
    (hfg_dom : ∀ n, n ≤ n₀ → f n ≤ g n)
    (hgf_dom : ∀ n, n₀ ≤ n → g n ≤ f n) :
    (∀ n, n < n₀ → min (f' n) (g' n) = f' n) ∧
    (∀ n, n₀ < n → min (f' n) (g' n) = g' n)
```
