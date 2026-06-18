# Tropical Certified Robustness for Attention-Style Max-Affine Gating Networks via Pathwise Logit-Gap Margins

## Abstract

We present a formally verified theory of robustness certificates for attention-style gating networks, extending the tropical geometry framework from static max-affine architectures to dynamically routed piecewise-affine networks. Our central result establishes that if a multiclass piecewise-affine network with global L∞ Lipschitz constant K has pairwise logit-gap margin m > 0 at an input x, then every perturbation δ with ‖δ‖∞ < m/(2K) preserves the predicted class. The key mathematical insight is that finite-valued routing does not destroy the tropical affine structure — it merely refines the polyhedral cell decomposition. All results are formalized and verified in Lean 4 with Mathlib, providing machine-checked guarantees of correctness.

**Keywords:** certified robustness, tropical geometry, mixture of experts, gating networks, piecewise-affine networks, formal verification

---

## 1. Introduction

Neural network robustness — the guarantee that small input perturbations do not change a network's prediction — is a central concern in deploying machine learning systems for safety-critical applications. While significant progress has been made in certifying robustness for feedforward ReLU networks, modern architectures increasingly employ *dynamic routing* mechanisms: attention layers, mixture-of-experts (MoE) modules, and gating networks that select different computational paths depending on the input.

These routing mechanisms pose a fundamental challenge to existing certification methods. When the network's computational graph changes with the input, classical analyses based on a single fixed computation no longer directly apply. However, we observe that for *finite-valued* routing — where the routing function takes values in a discrete set — the network remains piecewise-affine, and the tropical geometric perspective provides exactly the right framework.

### 1.1 Contributions

1. **Formal model of gated affine blocks.** We define attention-style gating modules as finite families of affine experts combined via selector-weighted convex combinations, with a finite-valued routing function determining which combination is applied.

2. **Cellwise affine theorem.** We prove that on each route fiber (the preimage of a fixed route value), the gated block reduces to a single affine map — the *combined affine map*. This is the structural lemma enabling all subsequent analysis.

3. **Lipschitz bounds for gated blocks.** We prove that the L∞ operator norm of the combined affine map is bounded by the maximum expert norm when the selector coefficients are convex. This yields same-cell Lipschitz bounds.

4. **Gap Lipschitz and margin-to-robustness theorem.** We prove that the logit gap function is 2K-Lipschitz, and derive the main robustness certificate: margin m > 0 and perturbation ‖δ‖∞ < m/(2K) imply class preservation.

5. **Compositional Lipschitz bounds.** We prove that Lipschitz constants compose multiplicatively through network layers, enabling certificates for deep gated architectures.

6. **Formal verification.** All results are formalized in Lean 4 with Mathlib, with machine-checked proofs depending only on the standard axioms (propext, Classical.choice, Quot.sound).

---

## 2. Mathematical Framework

### 2.1 Affine Maps and Gated Blocks

An *affine map* from ℝ^d to ℝ^o is represented as a pair (A, b) where A ∈ ℝ^{o×d} is a matrix and b ∈ ℝ^o is a bias vector. Its evaluation at x ∈ ℝ^d is:

$$\text{eval}(A, b, x)_i = \sum_j A_{ij} x_j + b_i$$

A *gated block* consists of:
- A finite family of affine experts {E_i}_{i ∈ ι} (each mapping ℝ^d → ℝ^o)
- A finite selector family {sel_s}_{s ∈ σ} (each giving convex weights over experts)
- A routing function route: ℝ^d → σ (mapping inputs to selector indices)

The evaluation of a gated block at x is:

$$B(x)_k = \sum_{i \in \iota} \text{sel}(\text{route}(x), i) \cdot E_i(x)_k$$

### 2.2 The Combined Affine Map

**Definition.** For a fixed selector value s, the *combined affine map* is:

$$\text{combined}(s) = \left(\sum_i \text{sel}(s,i) \cdot A_i, \quad \sum_i \text{sel}(s,i) \cdot b_i\right)$$

**Theorem 1 (Cellwise Affine Structure).** For any x with route(x) = s:

$$B(x) = \text{eval}(\text{combined}(s), x)$$

*Proof sketch.* Expand both sides coordinatewise. The left side is a weighted sum of expert evaluations; the right side is the evaluation of the weighted-sum affine map. The key step is exchanging the order of finite sums: ∑_i sel(s,i) · (∑_j A_{i,k,j} · x_j + b_{i,k}) = ∑_j (∑_i sel(s,i) · A_{i,k,j}) · x_j + ∑_i sel(s,i) · b_{i,k}.

This theorem is the bridge between dynamic routing and static affine analysis. It shows that although the gate depends on the input, once the routing decision is made, the computation is purely affine.

### 2.3 Convex Selector Property

A selector is *convex* if for every s: (1) sel(s, i) ≥ 0 for all i, and (2) ∑_i sel(s, i) = 1. This models the common case where expert outputs are combined via softmax attention or normalized gating weights.

---

## 3. Lipschitz Analysis

### 3.1 Row-Sum Operator Norm

For an affine map (A, b), the L∞ operator norm of the linear part is the maximum row-sum of absolute values:

$$\|A\|_{\infty \to \infty} = \max_i \sum_j |A_{ij}|$$

**Theorem 2 (Affine Lipschitz Bound).** For any affine map E = (A, b):

$$|E(x)_i - E(y)_i| \leq \left(\sum_j |A_{ij}|\right) \cdot \|x - y\|_\infty$$

*Proof.* The bias cancels in the difference. Then |∑_j A_{ij}(x_j - y_j)| ≤ ∑_j |A_{ij}| · |x_j - y_j| ≤ (∑_j |A_{ij}|) · ‖x - y‖_∞.

### 3.2 Convex Combination Norm Bound

**Theorem 3 (Combined Norm Bound).** If the selector is convex, then for each output coordinate k, the row-sum of the combined matrix is bounded by a convex combination of expert row-sums:

$$\sum_j |\text{combined}(s)_{kj}| \leq \sum_i \text{sel}(s,i) \cdot \sum_j |A_{i,k,j}|$$

Combined with the convex combination bound (∑ w_i · v_i ≤ max v_i when ∑ w_i = 1, w_i ≥ 0), this gives:

$$\sum_j |\text{combined}(s)_{kj}| \leq \max_i \sum_j |A_{i,k,j}| \leq K$$

where K bounds all expert row-sums.

### 3.3 Same-Cell Lipschitz Bound

**Theorem 4 (Gated Block Lipschitz).** For a gated block with convex selector and expert bound K:

$$\text{route}(x) = \text{route}(y) \implies |B(x)_k - B(y)_k| \leq K \cdot \|x - y\|_\infty$$

*Proof.* Rewrite both evaluations using the same combined affine map (by Theorem 1), then apply Theorem 2 with the norm bound from Theorem 3.

---

## 4. Robustness Certificates

### 4.1 Gap Lipschitz

For a network f: ℝ^d → ℝ^C with predicted class c, define the *logit gap* for class j as g_j(x) = f(x)_c - f(x)_j.

**Theorem 5 (Gap Lipschitz).** If f is K-Lipschitz coordinatewise, then each gap function is 2K-Lipschitz:

$$|g_j(x) - g_j(y)| = |(f(x)_c - f(x)_j) - (f(y)_c - f(y)_j)| \leq 2K \cdot \|x - y\|_\infty$$

*Proof.* Rewrite as |(f(x)_c - f(y)_c) - (f(x)_j - f(y)_j)| ≤ |f(x)_c - f(y)_c| + |f(x)_j - f(y)_j| ≤ 2K · ‖x - y‖_∞.

### 4.2 Main Robustness Theorem

**Theorem 6 (Margin-to-Robustness).** Let f: ℝ^d → ℝ^C be K-Lipschitz coordinatewise, with K > 0. If at input x, class c has margin m = min_{j≠c} (f(x)_c - f(x)_j) > 0, then for every perturbation δ with ‖δ‖_∞ < m/(2K):

$$\forall j \neq c: \quad f(x + \delta)_j < f(x + \delta)_c$$

*Proof.* For each j ≠ c, by gap Lipschitz:

$$f(x+\delta)_c - f(x+\delta)_j \geq (f(x)_c - f(x)_j) - 2K\|\delta\|_\infty \geq m - 2K\|\delta\|_\infty > 0$$

The last inequality holds because ‖δ‖_∞ < m/(2K) implies 2K‖δ‖_∞ < m.

### 4.3 Same-Route Local Certificate

**Theorem 7 (Local Robustness).** For a gated block B with convex selector and expert bound K, if route(x + δ) = route(x), margin m > 0, and ‖δ‖_∞ < m/(2K), then:

$$\forall j \neq c: \quad B(x+\delta)_j < B(x+\delta)_c$$

This theorem is stronger than the global certificate because it uses the route stability hypothesis to apply the same-cell Lipschitz bound directly, without needing to account for route changes along the perturbation path.

### 4.4 Compositional Bounds

**Theorem 8 (Composition).** If f is Kf-Lipschitz and g is Kg-Lipschitz (both coordinatewise, with nonneg constants), then g ∘ f is (Kg · Kf)-Lipschitz.

For an L-layer network with per-layer bounds K₁, ..., K_L, the overall bound is K = ∏ᵢ Kᵢ.

---

## 5. Formal Verification

All theorems are formalized and verified in Lean 4 with Mathlib. The formalization consists of approximately 280 lines of Lean code with complete proofs depending only on standard axioms.

### 5.1 Formalization Highlights

The key definitions use Lean's type system to capture the mathematical structure precisely:

```lean
structure GatedBlock (d o : ℕ) (ι σ : Type) [Fintype ι] [Fintype σ] where
  experts : ι → AffineMapVec d o
  selector : σ → SelectorVec ι
  route : (Fin d → ℝ) → σ
```

The `CoordLipschitz` predicate captures the L∞ Lipschitz condition:

```lean
def CoordLipschitz {d o : ℕ} (f : (Fin d → ℝ) → Fin o → ℝ) (K : ℝ) : Prop :=
  ∀ x y : Fin d → ℝ, ∀ i : Fin o, |f x i - f y i| ≤ K * ‖x - y‖
```

The main robustness theorem in Lean:

```lean
theorem robust_of_pairwise_margin_lipschitz
    {d C : ℕ} (f : (Fin d → ℝ) → Fin C → ℝ)
    (K : ℝ) (hKpos : 0 < K)
    (hK : CoordLipschitz f K)
    (x : Fin d → ℝ) (c : Fin C) (m : ℝ)
    (hm : 0 < m)
    (hmargin : ∀ j, j ≠ c → m ≤ f x c - f x j)
    (δ : Fin d → ℝ) (hδ : ‖δ‖ < m / (2 * K)) :
    ∀ j, j ≠ c → f (x + δ) j < f (x + δ) c
```

### 5.2 Axiom Audit

All theorems depend only on the standard Lean 4 axioms: `propext`, `Classical.choice`, and `Quot.sound`. No additional axioms, `sorry` placeholders, or `@[implemented_by]` annotations are used.

---

## 6. Discussion: Why Tropical Geometry Sees Through Dynamic Routing

*A perspective for the general reader*

Imagine a city's road network where traffic lights change the available routes depending on the time of day. A driver's journey from home to work traverses different streets at different times — yet at any given moment, the route is determined and the travel time is a simple function of the distances. The city hasn't fundamentally changed; the routing decision has simply selected one of finitely many possible fixed networks.

This is precisely the insight behind tropical certified robustness for gating networks. Modern neural networks, especially those using attention mechanisms or mixture-of-experts modules, operate like this adaptive road network. The "gates" in the network dynamically decide which computational experts to engage, based on the input — just as traffic lights select available routes based on conditions.

The mathematical framework of *tropical geometry* provides the ideal lens for analyzing these systems. In tropical geometry, the operations of addition and multiplication are replaced by maximum and addition, transforming polynomial equations into piecewise-linear ones. A ReLU neural network — where the activation function is max(0, x) — is inherently a tropical object: its output is a piecewise-linear function of its input, with the "pieces" forming a polyhedral complex.

Our key theorem says: **dynamic routing doesn't break this picture — it only adds more pieces.** When a gating network routes an input to a particular combination of experts, the result on that routing cell is still a single affine function. The gate refines the polyhedral decomposition of input space but doesn't introduce any fundamentally new complexity. This means all the standard tools — Lipschitz analysis, margin bounds, perturbation certificates — carry over intact.

The practical consequence is a *certified robustness radius*: given a network's prediction at a point, we can compute a provably safe perturbation radius within which the prediction cannot change. For a network with Lipschitz constant K and logit-gap margin m, any perturbation smaller than m/(2K) in L∞ norm is guaranteed safe.

What makes this work formally verified? Unlike typical mathematical proofs that might contain subtle errors, our proofs are checked by the Lean 4 theorem prover — a computer program that mechanically verifies every logical step. The computer confirms that our robustness guarantee follows rigorously from the definitions, with no gaps or hidden assumptions.

---

## 7. Applications

### 7.1 Certified Adversarial Robustness

The most direct application is computing certified perturbation radii for deployed models. Given a trained gating network:

1. Compute the Lipschitz bound K from the expert weight matrices (max row-sum norm over all experts).
2. For each input, compute the logit-gap margin m.
3. The certified radius r = m/(2K) guarantees robustness against any L∞ perturbation within r.

### 7.2 Architecture Design

The theorem suggests design principles for robust gating networks:
- **Smaller expert norms yield larger certified radii.** Weight regularization on individual experts directly improves robustness certificates.
- **Convex selectors preserve bounds.** Using softmax-normalized gating weights ensures the combined map inherits the expert norm bound.
- **Route stability improves local certificates.** Networks where the routing decision is stable under small perturbations benefit from tighter local bounds.

### 7.3 Comparison with Existing Methods

| Method | Scope | Verified? | Dynamic Routing? |
|--------|-------|-----------|-----------------|
| IBP/CROWN | ReLU networks | No | No |
| Randomized smoothing | Any classifier | No | Yes (statistical) |
| Tropical feedforward | Max-affine networks | Partially | No |
| **This work** | **Gating networks** | **Yes (Lean 4)** | **Yes (deterministic)** |

---

## 8. Future Directions

1. **Sparse top-k selectors.** Extending from dense convex combinations to sparse top-k expert selection, common in MoE architectures.

2. **Score-based routing analysis.** Proving certificates for networks where the routing function is itself differentiable and its gradient contributes to the overall Lipschitz constant.

3. **Tighter class-specific constants.** Using the active expert pattern to derive class-specific Lipschitz bounds, potentially yielding larger certified radii for specific classes.

4. **Integration with training.** Incorporating the certified radius as a training objective, using the formal structure to design differentiable proxies for the certificate.

5. **Extension to tropical attention layers.** Formalizing score-based finite routing as a tropical max operation, connecting to the theory of tropical rational functions.

---

## 9. Conclusion

We have established a formally verified theory of robustness certificates for attention-style gating networks. The central insight — that finite-valued routing preserves cellwise affine structure — bridges the gap between tropical geometric analysis of static architectures and the dynamic routing mechanisms used in modern deep learning. All results are machine-checked in Lean 4, providing the strongest possible guarantee of mathematical correctness.

---

## References

The proofs use foundational results from Mathlib (the Lean mathematical library), including:
- Pi norm theory for finite-dimensional L∞ spaces
- Finset sum manipulation lemmas
- Real absolute value and triangle inequality

The tropical geometry perspective on neural networks draws on the broader program connecting ReLU networks to tropical rational functions and piecewise-linear topology.

---

*Formal proofs: `MachineLearning/TropicalGating.lean`*
*Python demonstrations: `MachineLearning/demo_tropical_gating.py`*
