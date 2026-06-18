# Future Directions: EML Description Complexity

## Conjecture 1: Balanced Tree Depth Improvement

**Conjecture:** For k functions each bounded by B on [a,b], the EML description complexity of their product satisfies:

```
EMLComplexityOn(a, b, ∏ f_i, ε) ≤ (∑ᵢ EMLComplexityOn(a, b, f_i, δ_balanced)) + ⌈log₂ k⌉
```

where δ_balanced = ε / (2 ⌈log₂ k⌉ · B^(k-1)) — a logarithmic overhead instead of linear.

**Test:** Implement both left-associated and balanced-tree product constructions. For families of k = 2^n Chebyshev polynomials bounded by 1 on [-1,1], compare the achieved approximation error at matching tree sizes. If the balanced tree consistently achieves lower error at the same total size, this supports the conjecture. If there exist families where balanced trees require strictly more total nodes for the same approximation quality (due to sharper intermediate bounds in the linear chain), the conjecture would be refuted in its naive form.

**Impact:** A logarithmic-depth bound would connect to NC (Nick's Class) in circuit complexity, showing that product approximation can be massively parallelized. This matters for GPU-based scientific computing where parallel depth is the bottleneck.

---

## Conjecture 2: Tight Lower Bound for Product Complexity

**Conjecture:** There exist families of functions f₁, ..., f_k on [0,1], each with EMLComplexityOn(0, 1, f_i, δ) = c, such that:

```
EMLComplexityOn(0, 1, ∏ f_i, ε) ≥ k · c / C
```

for some absolute constant C > 0 and appropriate ε depending on k, B, δ. In other words, the linear growth in the sum of individual complexities is not just an upper bound but is essentially necessary.

**Test:** Construct random bounded trigonometric polynomials on [0,1] with controlled complexity. Estimate the complexity of their products numerically by finding best expression-tree approximations at various sizes. If the product complexity consistently grows linearly with k · c, this supports the conjecture. A sublinear growth rate would refute it.

**Impact:** Would establish that multiplicative subadditivity is tight, completing the complexity calculus with matching upper and lower bounds. This is the approximation-theoretic analogue of proving circuit lower bounds — a famously hard problem in computational complexity.

---

## Conjecture 3: Entropy-Like Inequality for Description Cost

**Conjecture:** For independent bounded random processes X and Y on a probability space, the expected EML description complexity satisfies:

```
𝔼[EMLComplexityOn(a, b, X · Y, ε)] ≤ 𝔼[EMLComplexityOn(a, b, X, δ)] + 𝔼[EMLComplexityOn(a, b, Y, δ)] + O(1)
```

mimicking the subadditivity of Shannon entropy: H(X, Y) ≤ H(X) + H(Y).

**Test:** Sample pairs of random bounded functions (e.g., random Fourier series with bounded coefficients). Compute EML complexity estimates for each factor and their product. Plot 𝔼[C(X·Y)] against 𝔼[C(X)] + 𝔼[C(Y)]. If the ratio consistently exceeds 1 + o(1), the subadditivity is genuine; if it exceeds 1 by a factor growing with the function space dimension, the O(1) term needs refinement.

**Impact:** Would establish EML complexity as an information measure for function spaces, creating a bridge between approximation theory and information theory. Could lead to a minimum-description-length framework for function learning.

---

## Conjecture 4: Division Complexity Bound

**Conjecture:** If f and g are B-bounded on [a,b] with g bounded away from zero (|g(x)| ≥ c > 0 for x ∈ [a,b]), then:

```
EMLComplexityOn(a, b, f/g, ε) ≤ EMLComplexityOn(a, b, f, δ₁) + EMLComplexityOn(a, b, 1/g, δ₂) + 1
```

where δ₁, δ₂ are computed from ε, B, and c by an explicit budget formula.

**Test:** Approximate rational functions p(x)/q(x) on intervals where q is bounded away from zero. Compare the complexity of the ratio with the sum of complexities of p and 1/q. The budget formula δ₁ = ε·c/(2(B+c)) and δ₂ = ε/(2(B/c + 1)) should give a clean bound. Test with Padé approximants of known complexity.

**Impact:** Division closure would extend the compositional calculus to rational function approximation, which is important for Padé approximation, control theory, and many-body Green's functions in physics.

---

## Conjecture 5: Neural Network Architecture Implications

**Conjecture:** For ReLU networks with multiplicative gates (as in NALU, gating mechanisms, or attention), the multiplicative subadditivity theorem implies:

```
Approximation error of a depth-L network with k multiplicative gates ≤ 
  O(k · B^(k-1)) × (per-gate approximation error)
```

In particular, networks with O(log n) multiplicative gates in a balanced arrangement can approximate degree-n polynomials with polylogarithmic depth and polynomial width, matching known circuit complexity bounds.

**Test:** Train networks with explicit multiplicative gates on polynomial target functions. Measure how the test error scales with the number of multiplicative gates and compare with the theoretical prediction k · B^(k-1) · δ. If the empirical scaling is significantly better than the theoretical bound, the bound can be tightened; if worse, the construction is suboptimal.

**Impact:** Would provide the first rigorous connection between compositional approximation complexity and neural network architecture design. Could guide the design of networks for scientific computing where polynomial and rational function approximation is critical.
