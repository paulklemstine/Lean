# The Idempotent Representer Theorem: Kernel Methods Beyond Inner Products

## Abstract

We formalize in Lean 4 a representer theorem for max-plus (tropical) kernel regression over idempotent semimodules. The classical representer theorem for reproducing kernel Hilbert spaces (RKHS) guarantees that regularized empirical risk minimizers lie in the span of kernel sections centered at training points. We prove the tropical analogue: in a max-plus function semimodule, any minimizer of a regularized tropical empirical risk admits a representative in the tropical kernel span — the set of functions of the form f(z) = sup_{x ∈ train} (K(z,x) + c(x)). The proof replaces Hilbert-space orthogonal projection with an order-theoretic projection principle: any operator that maps functions into the kernel span, preserves training-set values, and does not increase the regularizer suffices. We prove the abstract theorem, construct a concrete projection from training interpolation, establish exact interpolation for Kronecker tropical kernels, and derive the algorithmic corollary that infinite-dimensional function optimization reduces to finite coefficient-space optimization. All results are machine-verified in Lean 4 with Mathlib, using no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound).

**Keywords**: representer theorem, max-plus algebra, tropical geometry, kernel methods, idempotent analysis, formal verification

---

## 1. Introduction

The representer theorem is one of the cornerstones of kernel-based machine learning. In its classical form (Kimeldorf & Wahba, 1971; Schölkopf, Herbrich & Smola, 2001), it states that every minimizer of a regularized empirical risk functional in a reproducing kernel Hilbert space (RKHS) can be written as a finite linear combination of kernel sections evaluated at the training points:

$$f^* = \sum_{i=1}^{n} \alpha_i K(\cdot, x_i)$$

This reduces an infinite-dimensional optimization problem to a finite-dimensional one, making kernel SVMs, Gaussian processes, and spline smoothing computationally tractable.

The classical proof relies on two pillars of Hilbert space theory:
1. **Orthogonal projection**: any element can be decomposed into a component in the span and an orthogonal complement.
2. **Pythagorean theorem**: the RKHS norm decomposes as ‖f‖² = ‖f_∥‖² + ‖f_⊥‖², so projecting onto the span does not increase the norm.

A natural question arises: *do kernel methods require inner products?*

We show the answer is no. The essential mechanism is not orthogonality but a **representation-preserving projection principle**: any operator that maps functions into a structured span, preserves relevant function values, and is contractive with respect to the regularizer. In the tropical (max-plus) setting, this projection is order-theoretic rather than metric.

### 1.1 The Max-Plus Semiring

The max-plus semiring (ℝ ∪ {-∞}, ⊕, ⊗) replaces the usual arithmetic:
- **Tropical addition**: a ⊕ b = max(a, b)
- **Tropical multiplication**: a ⊗ b = a + b (classical addition)
- **Tropical zero**: -∞ (identity for max)
- **Tropical one**: 0 (identity for +)

This algebraic structure appears throughout:
- **Optimization**: shortest paths, dynamic programming, scheduling
- **Algebraic geometry**: tropical varieties, Newton polygons
- **Statistical mechanics**: zero-temperature limits, large deviations
- **Neural networks**: ReLU networks compute tropical rational functions

### 1.2 Contribution

We formalize and machine-verify in Lean 4 the following results:

1. **Abstract representer theorem** (`representer_theorem_of_projection`): Given any projection operator satisfying three natural axioms (span membership, training preservation, regularizer contractivity), every minimizer of the regularized tropical objective admits a representative in the tropical kernel span with equal objective value.

2. **Minimizer existence transfer** (`exists_span_minimizer_of_exists_minimizer`): If a global minimizer exists, one exists in the kernel span.

3. **Concrete projection construction** (`representerProjOfInterp_is_projection`): Training interpolation provides a canonical representer projection.

4. **Kronecker kernel interpolation** (`exists_kernel_span_interpolant_of_trainKronecker`): The tropical identity kernel enables exact interpolation on any finite training set.

5. **Algorithmic reduction** (`optimization_reduces_to_coefficients`): Function-space optimization reduces to coefficient-space optimization over |train|-dimensional vectors.

---

## 2. Mathematical Framework

### 2.1 Tropical Kernel Span

Let X be a finite set, α a linearly ordered type with bottom element ⊥ and addition +, and K : X × X → α a kernel function. The **tropical kernel span** over a training set S ⊆ X is:

$$\text{TropSpan}_S(K) = \left\{ f : X \to \alpha \;\middle|\; \exists\, c : X \to \alpha,\; f(z) = \bigoplus_{x \in S} K(z,x) \otimes c(x) \right\}$$

In explicit notation: f(z) = max_{x ∈ S} (K(z,x) + c(x)).

This is the natural analogue of the RKHS span {f = Σ αᵢ K(·,xᵢ)}, with max replacing summation and + replacing scalar multiplication.

### 2.2 Regularized Tropical Objective

The **empirical risk** is the tropical sum (maximum) of pointwise losses:

$$\hat{R}(f) = \bigoplus_{x \in S} \ell(x, f(x), y(x)) = \max_{x \in S} \ell(x, f(x), y(x))$$

The **regularized objective** combines the empirical risk with a regularizer via tropical addition:

$$J(f) = \hat{R}(f) \oplus \text{reg}(f) = \max(\hat{R}(f), \text{reg}(f))$$

Note that the max-based risk is inherently a worst-case criterion: the objective is dominated by the worst training loss or the regularization penalty, whichever is larger.

### 2.3 Representer Projection

A map P : (X → α) → (X → α) is a **representer projection** for (K, S, reg) if:
1. **Span membership**: P(f) ∈ TropSpan_S(K) for all f.
2. **Training preservation**: P(f)(x) = f(x) for all x ∈ S.
3. **Regularizer contractivity**: reg(P(f)) ≤ reg(f) for all f.

This is the tropical analogue of the orthogonal projection in RKHS theory. The key difference: there is no inner product, no orthogonality, and no norm. The projection is defined purely in terms of order and set membership.

---

## 3. Main Results

### 3.1 Abstract Representer Theorem

**Theorem** (representer_theorem_of_projection). *Let P be a representer projection for (K, S, reg). Suppose the loss depends on f only through its values on S (training-wise). If f is a global minimizer of J, then P(f) ∈ TropSpan_S(K) and J(P(f)) = J(f).*

**Proof sketch**:
1. Set g = P(f). By axiom 1, g ∈ TropSpan_S(K).
2. By axiom 2, g agrees with f on S, so R̂(g) = R̂(f) (training-wise loss).
3. By axiom 3, reg(g) ≤ reg(f).
4. Therefore J(g) = max(R̂(g), reg(g)) ≤ max(R̂(f), reg(f)) = J(f).
5. Since f is a minimizer, J(f) ≤ J(g).
6. By antisymmetry, J(g) = J(f). ∎

The proof is 3 lines in Lean:
```lean
exact ⟨P f, hP.1 f,
  le_antisymm (objective_le_of_projection hP hloss_trainwise f) (hmin _)⟩
```

### 3.2 Kronecker Kernel Interpolation

**Theorem** (exists_kernel_span_interpolant_of_trainKronecker). *If K is a Kronecker tropical kernel on S (i.e., K(x,x) = 0 and K(z,x) = ⊥ for z ≠ x in S), and if ⊥ + a = ⊥ and 0 + a = a for all a, then K has training interpolation: every function f can be exactly represented on S by setting c = f.*

**Proof**: For x₀ ∈ S, the x₀-th term of the sup gives K(x₀,x₀) + f(x₀) = 0 + f(x₀) = f(x₀). Every other term gives K(x₀,z) + f(z) = ⊥ + f(z) = ⊥ ≤ f(x₀). So the sup equals f(x₀). ∎

### 3.3 Algorithmic Reduction

**Theorem** (optimization_reduces_to_coefficients). *If a global minimizer exists and a representer projection exists, then there exists a coefficient vector c* such that for all d:*

$$J_{\text{coeff}}(c^*) \leq J_{\text{coeff}}(d)$$

*where J_coeff(c) = J(z ↦ max_{x ∈ S}(K(z,x) + c(x))).*

This is the algorithmic payoff: instead of optimizing over all functions X → α, we optimize over coefficient vectors — a |S|-dimensional problem.

---

## 4. Discussion: Kernel Methods Without Inner Products

### 4.1 A Scientific American–Style Perspective

Imagine you're a chef trying to create the perfect recipe. You have a vast kitchen (the function space) with infinite ingredient combinations. The classical representer theorem says: "You only need to use the ingredients your tasters have already sampled" — the kernel sections at training points.

The classical proof assumes your kitchen has a very specific geometry: a Hilbert space where you can measure "orthogonality" between recipes. The tropical representer theorem reveals something deeper: **you don't need the geometry at all**. All you need is a way to *project* any recipe onto the space of training-based combinations such that:
1. The projection stays in the allowed combinations.
2. The projection tastes the same to your tasters (preserves training values).
3. The projection is no more complex (regularization doesn't increase).

This is like discovering that the recipe-simplification trick works not because of some special property of your measuring spoons, but because of a much more basic logical structure.

### 4.2 Historical Context

The shift from Hilbert spaces to ordered algebraic structures has deep roots:

- **Maslov (1987)** introduced idempotent analysis as a "dequantization" of classical analysis, where the Planck constant ℏ → 0 turns the quantum superposition principle (linear combination) into the classical variational principle (optimization).

- **Litvinov, Maslov, and Shpiz (2001)** developed the functional-analytic foundations of idempotent semimodules, showing that many results of classical functional analysis have tropical counterparts.

- **Cohen, Gaubert, and Quadrat (2004)** established separation and representation theorems in max-plus convexity, the algebraic framework underlying our representer theorem.

- **Zhang, Naitzat, and Lim (2018)** showed that ReLU neural networks compute tropical rational functions, creating a direct link between deep learning architectures and tropical geometry.

Our contribution connects this algebraic tradition to machine learning by identifying the **projection principle** — rather than the inner product — as the essential mechanism of the representer theorem.

### 4.3 Why Max-Plus?

The max-plus semiring is not just a mathematical curiosity. It naturally models:

- **Worst-case optimization**: The empirical risk max_{x} ℓ(x, f(x), y(x)) is a max-plus sum. Minimax robustness, adversarial training, and distributionally robust optimization all live in this world.

- **Timing and scheduling**: The completion time of a project is the maximum of its critical path lengths — a max-plus linear function of task durations.

- **Large deviations**: The rate function in Cramér's theorem is a Legendre-Fenchel transform — a max-plus integral. Rare-event probabilities decay exponentially, and the exponent satisfies max-plus linearity.

- **Morphological operations**: Dilation and erosion in image processing are max-plus and min-plus linear operations, respectively.

### 4.4 Connections to Tropical Geometry

The tropical kernel span TropSpan_S(K) is a tropical convex set: it is closed under tropical linear combinations (taking max of shifted copies). The representer theorem says that the optimal function in this tropical convex set can be found by finite-dimensional tropical linear programming.

This connects to the rapidly developing field of tropical convex geometry, where separation theorems, face structures, and duality theory mirror classical convex analysis but with fundamentally different combinatorial behavior.

---

## 5. Formalization Notes

### 5.1 Lean 4 and Mathlib

The formalization uses Lean 4.28.0 with Mathlib. Key design decisions:

- **Generality**: The abstract representer theorem works over any `SemilatticeSup` with `OrderBot` and `Add`, capturing max-plus, min-plus, and other idempotent semirings.

- **Finite setting**: We work with `Fintype X` and `Finset` training sets, avoiding topological compactness arguments while retaining the full algorithmic content.

- **Separation of concerns**: The abstract projection principle (Theorems 1–2) is cleanly separated from concrete projection constructions (Theorems 3–4), enabling reuse.

### 5.2 Axiom Usage

All theorems use only standard Lean axioms:
- `propext` (propositional extensionality)
- `Quot.sound` (quotient soundness)
- `Classical.choice` (used only in the concrete projection construction)

No custom axioms, `sorry`, or `@[implemented_by]` are used.

### 5.3 Proof Architecture

The proof architecture mirrors the mathematical structure:

```
objective_le_of_projection (helper)
  ↓
representer_theorem_of_projection (main abstract theorem)
  ↓
exists_span_minimizer_of_exists_minimizer (corollary)
  ↓
optimization_reduces_to_coefficients (algorithmic consequence)

exists_kernel_span_interpolant_of_trainKronecker
  ↓
representerProjOfInterp_is_projection (concrete projection)
  ↓
(feeds into abstract theorem via IsRepresenterProjection)
```

---

## 6. Applications

### 6.1 Robust Regression

The max-plus objective naturally encodes worst-case loss. A tropical kernel regressor that minimizes max_{x ∈ S} |f(x) - y(x)| ⊔ reg(f) is simultaneously:
- A minimax estimator (minimizing worst-case training error)
- A Chebyshev approximant (minimizing the ℓ∞ fitting error)

The representer theorem guarantees this can be solved as a finite max-plus linear program over |S| coefficients.

### 6.2 Scheduling and Resource Allocation

In project scheduling, completion times are max-plus linear functions of task durations. The representer theorem provides a finite parameterization of optimal schedules: the optimal resource allocation depends only on critical-path kernel sections at observed bottleneck points.

### 6.3 Anomaly Detection via Tropical Envelopes

A tropical kernel span defines an "envelope" function — the pointwise maximum of shifted kernel sections. Points where the data exceeds this envelope are anomalies. The representer theorem guarantees that the tightest envelope consistent with training data can be found in the kernel span, providing a principled anomaly detection method with worst-case guarantees.

---

## 7. Conclusion

We have formalized the first representer theorem for idempotent (max-plus) kernel regression, establishing that the projection principle — not the inner product — is the essential mechanism underlying representer theorems. The formalization is fully machine-verified in Lean 4, uses only standard axioms, and provides a reusable interface for tropical kernel methods.

The key conceptual insight is that "kernel methods" are not about Hilbert spaces. They are about **structured projections onto finite-dimensional spans that preserve the relevant information**. In the Hilbert setting, this projection is orthogonal; in the tropical setting, it is order-theoretic; in principle, any algebraic setting with a suitable notion of projection will admit a representer theorem.

This opens the door to kernel methods in settings where inner products are meaningless — optimization, scheduling, tropical geometry, and robust statistics — while maintaining the same finite-dimensionality guarantees that make classical kernel methods practical.

---

## References

1. Kimeldorf, G. and Wahba, G. (1971). Some results on Tchebycheffian spline functions. *J. Math. Anal. Appl.*, 33(1):82–95.

2. Schölkopf, B., Herbrich, R., and Smola, A. J. (2001). A generalized representer theorem. In *COLT*, pages 416–426.

3. Maslov, V. P. (1987). On a new principle of superposition for optimization problems. *Russian Math. Surveys*, 42(3):43–54.

4. Litvinov, G. L., Maslov, V. P., and Shpiz, G. B. (2001). Idempotent functional analysis: an algebraic approach. *Mathematical Notes*, 69(5):696–729.

5. Cohen, G., Gaubert, S., and Quadrat, J.-P. (2004). Duality and separation theorems in idempotent semimodules. *Linear Algebra and its Applications*, 379:395–422.

6. Zhang, L., Naitzat, G., and Lim, L.-H. (2018). Tropical geometry of deep neural networks. In *ICML*, pages 5824–5832.

7. Singer, I. (1997). *Abstract Convex Analysis*. Wiley.
