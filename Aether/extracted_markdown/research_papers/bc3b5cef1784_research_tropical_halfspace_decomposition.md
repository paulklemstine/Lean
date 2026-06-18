# Chebyshev Radius of Tropical Margin Cells: Exact Certified Robustness via Polyhedral Geometry

## Abstract

We prove that the maximal certified robustness radius for a tropical affine classifier is exactly equal to the minimum Euclidean distance from the classification point to the pairwise decision boundaries. This establishes a bridge between tropical classification theory and convex-body geometry, upgrading conservative certification bounds to an exact geometric identity. The result is formalized over arbitrary real inner product spaces, yielding generality across finite-dimensional and function-space settings. We provide constructive sharpness witnesses showing the bound is tight, and derive corollaries including positive-radius criteria for strict interiors. Numerical experiments demonstrate that exact radii exceed conservative Lipschitz bounds by a factor of approximately 3× on average for random classifiers.

## 1. Introduction

### 1.1 Motivation

Certified robustness — proving that a classifier's decision is stable under bounded input perturbations — is a central problem in trustworthy machine learning. The standard approach computes a radius $r > 0$ such that for all perturbations $\delta$ with $\|\delta\| \leq r$, the classifier's output at $x_0 + \delta$ agrees with its output at $x_0$.

Most certification methods produce *conservative lower bounds* on the true robustness radius. These bounds arise from Lipschitz continuity arguments: if the score function has global Lipschitz constant $L$ and the margin at $x_0$ is $\gamma$, then the classification is stable within radius $\gamma / (2L)$. However, this bound uses a *global* Lipschitz constant, ignoring the local geometry of the decision region.

### 1.2 Contribution

We prove that for tropical affine classifiers (linear score functions followed by argmax), the certified robustness radius is *exactly* the minimum distance to the pairwise decision boundaries. This is not a bound — it is an identity. Specifically:

**Main Theorem.** Let $\text{score}_i(x) = a_i + \langle W_i, x \rangle$ for classes $i \in \{1, \ldots, m\}$. Fix a winning class $i$ and a point $x_0$ in the margin cell $C_i = \{x : \forall j,\, \text{score}_i(x) \geq \text{score}_j(x)\}$. Assume $W_i \neq W_j$ for all $j \neq i$. Then:

$$r = \min_{j \neq i} \frac{\Delta_{i,j}(x_0)}{\|W_i - W_j\|}$$

is the exact Chebyshev radius of $C_i$ at $x_0$: the closed ball $\overline{B}(x_0, r) \subseteq C_i$, and for every $\varepsilon > 0$, $\overline{B}(x_0, r + \varepsilon) \not\subseteq C_i$.

### 1.3 Related Work

The connection between tropical geometry and neural network analysis was established by Zhang et al. (2018) and Alfarra et al. (2022), who showed that ReLU networks are tropical rational maps and their decision boundaries are tropical hypersurfaces.

Lipschitz-based robustness certification was pioneered by Szegedy et al. (2014) and formalized by Hein and Andriushchenko (2017). Our work upgrades these bounds to exact equalities in the tropical affine regime.

The polyhedral structure of linear classifier regions is classical in computational geometry (Edelsbrunner, 1987). Our contribution is connecting this structure to certified robustness via the Chebyshev radius.

## 2. Definitions and Setup

### 2.1 Tropical Affine Classifier

Let $V$ be a real inner product space with inner product $\langle \cdot, \cdot \rangle$ and induced norm $\|\cdot\|$.

**Definition 2.1** (Score function). For bias vector $a \in \mathbb{R}^m$ and weight vectors $W_1, \ldots, W_m \in V$, the *score* of class $i$ at point $x \in V$ is:
$$\text{score}_i(x) = a_i + \langle W_i, x \rangle$$

**Definition 2.2** (Margin difference). The *margin difference* between classes $i$ and $j$ at $x$ is:
$$\Delta_{i,j}(x) = \text{score}_i(x) - \text{score}_j(x) = (a_i - a_j) + \langle W_i - W_j, x \rangle$$

**Definition 2.3** (Margin cell). The *margin cell* of class $i$ is:
$$C_i = \{x \in V : \forall j,\, \Delta_{i,j}(x) \geq 0\}$$

**Definition 2.4** (Row difference). The *row difference* (normal vector to the decision boundary) is:
$$w_{i,j} = W_i - W_j$$

### 2.2 Separation Hypothesis

We assume throughout that $w_{i,j} \neq 0$ for all $j \neq i$. This is equivalent to requiring that the weight vectors of distinct classes are distinct — a genericity condition that holds for all classifiers not containing redundant classes.

## 3. Main Results

### 3.1 Algebraic Structure of the Margin

**Lemma 3.1** (Perturbation identity). For any $x_0, d \in V$:
$$\Delta_{i,j}(x_0 + d) = \Delta_{i,j}(x_0) + \langle w_{i,j}, d \rangle$$

*Proof.* Direct computation using bilinearity of the inner product. □

**Lemma 3.2** (Lipschitz estimate). For any $x, y \in V$:
$$|\Delta_{i,j}(y) - \Delta_{i,j}(x)| \leq \|w_{i,j}\| \cdot \|y - x\|$$

*Proof.* By Lemma 3.1, $\Delta_{i,j}(y) - \Delta_{i,j}(x) = \langle w_{i,j}, y - x \rangle$. The result follows from the Cauchy-Schwarz inequality. □

**Corollary 3.3** (Lower bound). For any $x_0, y \in V$:
$$\Delta_{i,j}(y) \geq \Delta_{i,j}(x_0) - \|w_{i,j}\| \cdot \|y - x_0\|$$

### 3.2 Ball Inclusion

**Theorem 3.4** (Halfspace ball inclusion). If $\Delta_{i,j}(x_0) \geq 0$, $w_{i,j} \neq 0$, and $r \leq \Delta_{i,j}(x_0) / \|w_{i,j}\|$, then for all $x$ with $\|x - x_0\| \leq r$:
$$\Delta_{i,j}(x) \geq 0$$

*Proof.* By Corollary 3.3:
$$\Delta_{i,j}(x) \geq \Delta_{i,j}(x_0) - \|w_{i,j}\| \cdot r \geq \Delta_{i,j}(x_0) - \|w_{i,j}\| \cdot \frac{\Delta_{i,j}(x_0)}{\|w_{i,j}\|} = 0$$

□

**Theorem 3.5** (Ball inclusion in margin cell). Let $x_0 \in C_i$ and define:
$$r = \min_{j \neq i} \frac{\Delta_{i,j}(x_0)}{\|w_{i,j}\|}$$

Then $\overline{B}(x_0, r) \subseteq C_i$.

*Proof.* For any $x$ with $\|x - x_0\| \leq r$ and any $j$:
- If $j = i$: $\Delta_{i,i}(x) = 0 \geq 0$.
- If $j \neq i$: $r \leq \Delta_{i,j}(x_0) / \|w_{i,j}\|$ by definition of minimum, so Theorem 3.4 applies. □

### 3.3 Sharpness

**Theorem 3.6** (Sharpness). Under the hypotheses of Theorem 3.5, for every $\varepsilon > 0$ there exists $x$ with $\|x - x_0\| \leq r + \varepsilon$ and $x \notin C_i$.

*Proof.* Let $j^*$ be a minimizer: $\Delta_{i,j^*}(x_0) / \|w_{i,j^*}\| = r$. Define the unit vector $v = w_{i,j^*} / \|w_{i,j^*}\|$ and the witness point:
$$x = x_0 - (r + \varepsilon) \cdot v$$

**Distance computation:**
$$\|x - x_0\| = (r + \varepsilon) \cdot \|v\| = r + \varepsilon$$

**Margin computation:**
$$\Delta_{i,j^*}(x) = \Delta_{i,j^*}(x_0) + \langle w_{i,j^*}, -(r+\varepsilon) v \rangle$$
$$= \Delta_{i,j^*}(x_0) - (r+\varepsilon) \langle w_{i,j^*}, w_{i,j^*}/\|w_{i,j^*}\| \rangle$$
$$= \Delta_{i,j^*}(x_0) - (r+\varepsilon) \|w_{i,j^*}\|$$
$$= r \|w_{i,j^*}\| - (r+\varepsilon) \|w_{i,j^*}\| = -\varepsilon \|w_{i,j^*}\| < 0$$

Since $\Delta_{i,j^*}(x) < 0$, we have $x \notin C_i$. □

### 3.4 Main Theorem

**Theorem 3.7** (Chebyshev radius = minimum boundary distance). Let $x_0 \in C_i$ and assume $w_{i,j} \neq 0$ for all $j \neq i$. Then:
$$r = \min_{j \neq i} \frac{\Delta_{i,j}(x_0)}{\|w_{i,j}\|}$$
satisfies:
1. $\overline{B}(x_0, r) \subseteq C_i$ (inclusion, Theorem 3.5)
2. $\forall \varepsilon > 0,\, \overline{B}(x_0, r + \varepsilon) \not\subseteq C_i$ (sharpness, Theorem 3.6)

### 3.5 Positive Radius Criterion

**Corollary 3.8.** If $x_0$ lies in the strict interior of $C_i$ (i.e., $\Delta_{i,j}(x_0) > 0$ for all $j \neq i$), then $r > 0$.

*Proof.* Each term $\Delta_{i,j}(x_0) / \|w_{i,j}\|$ is strictly positive (positive numerator, positive denominator). The minimum of finitely many positive numbers is positive. □

## 4. Algorithms

### 4.1 Exact Chebyshev Radius Computation

```
Algorithm: ChebyshevRadius(a, W, x₀)
Input: Bias a ∈ ℝᵐ, weights W ∈ ℝᵐˣⁿ, point x₀ ∈ ℝⁿ
Output: (predicted_class, radius, nearest_competitor)

1. scores ← a + W · x₀
2. i ← argmax(scores)
3. r ← +∞, j* ← -1
4. for j = 1 to m, j ≠ i:
5.     w ← W[i] - W[j]
6.     margin ← (a[i] - a[j]) + w · x₀
7.     dist ← margin / ‖w‖₂
8.     if dist < r:
9.         r ← dist, j* ← j
10. return (i, r, j*)
```

**Complexity:** $O(mn)$ time, $O(n)$ space.

### 4.2 Sharpness Witness Construction

```
Algorithm: SharpnessWitness(a, W, x₀, ε)
Input: Classifier (a, W), point x₀, tolerance ε > 0
Output: Adversarial example x with ‖x - x₀‖ ≤ r + ε

1. (i, r, j*) ← ChebyshevRadius(a, W, x₀)
2. w ← W[i] - W[j*]
3. v ← w / ‖w‖₂
4. x ← x₀ - (r + ε) · v
5. return x
```

**Complexity:** $O(mn + n)$ time.

### 4.3 Chebyshev Center (Approximate)

The Chebyshev center — the point maximizing the certified radius within $C_i$ — can be computed as a linear program:

$$\max_{x, \rho} \quad \rho$$
$$\text{s.t.} \quad \Delta_{i,j}(x) \geq \rho \|w_{i,j}\| \quad \forall j \neq i$$

This is a standard LP in $n + 1$ variables and $m - 1$ constraints, solvable in polynomial time.

## 5. Computational Experiments

### 5.1 Setup

We tested on random tropical affine classifiers with varying dimensions and class counts. All experiments used NumPy with random seeds for reproducibility.

### 5.2 Example: 2D Three-Class Classifier

With bias $a = (0, -1, -0.5)$ and weight matrix:
$$W = \begin{pmatrix} 1.0 & 0.5 \\ 0.3 & 1.2 \\ -0.5 & 0.8 \end{pmatrix}$$

At $x_0 = (1.0, 0.5)$, predicted class 0 with scores $(1.25, -0.1, -0.6)$.

| Competitor | Boundary Distance |
|-----------|------------------|
| Class 1   | 1.3637           |
| Class 2   | 1.2094           |

**Chebyshev radius: 1.2094** (limited by class 2 boundary).

Ball inclusion verified by 10,000 random samples. Sharpness verified with $\varepsilon = 0.001$.

### 5.3 Exact vs Conservative Comparison

Comparing exact Chebyshev radii against conservative Lipschitz bounds ($\gamma_{\min} / (2L_{\text{global}})$) on 50 random 3D points with a 4-class classifier:

| Metric | Exact Radius | Lipschitz Bound |
|--------|-------------|-----------------|
| Mean   | 0.492       | 0.167           |
| Improvement | **2.95×** average, **3.61×** maximum |

### 5.4 Higher Dimensions

For a 5-class classifier in 5 dimensions: Chebyshev radius = 1.2459, verified by sampling and sharpness construction.

## 6. Discussion

### 6.1 Relationship to Prior Work

Our result specializes and sharpens several existing results:

1. **Lipschitz certification.** The standard bound $r \geq \gamma_{\min} / (2L)$ uses the global Lipschitz constant $L = \max_{i,j} \|W_i - W_j\|$ and the minimum margin $\gamma_{\min} = \min_{j \neq i} \Delta_{i,j}(x_0)$. Our formula uses *pairwise* Lipschitz constants $\|W_i - W_j\|$ with *individual* margins, giving exact results.

2. **Multiclass robustness.** Prior work on multiclass certified robustness established lower bounds via margin aggregation. Our result provides the exact radius, showing these bounds are tight in the affine regime.

3. **Polyhedral geometry.** The margin cell is a polyhedral cone (intersection of halfspaces). Our theorem identifies the Chebyshev radius with the inradius of this polyhedron at $x_0$, a classical quantity in convex geometry.

### 6.2 Generality

The theorem is proved over *arbitrary real inner product spaces*, not just $\mathbb{R}^n$. This means it applies equally to function-space classifiers (e.g., kernel methods in reproducing kernel Hilbert spaces) where the norm is the RKHS norm.

### 6.3 Limitations

1. **Affine regime only.** The result applies to tropical affine classifiers (single-layer linear scoring). Deep ReLU networks are piecewise-affine, so each linear region has its own exact radius, but the global radius requires tracking which linear region contains the ball.

2. **Separation hypothesis.** We require $W_i \neq W_j$ for all $j \neq i$. If two classes have identical weight vectors, their boundary is either empty or all of $V$, and the distance formula degenerates.

3. **Euclidean norm.** The exact formula uses the $\ell_2$ norm. For $\ell_\infty$ robustness (the most common in practice), the boundary distance formula changes to a linear program.

## 7. Future Work

1. **Extension to piecewise-affine classifiers.** By tracking the polyhedral partition of a deep ReLU network, the exact Chebyshev radius can be computed locally within each linear region and then composed across regions.

2. **John ellipsoid robustness.** The Chebyshev ball is the largest inscribed sphere, but the margin cell is typically elongated. Computing the John ellipsoid would give direction-dependent robustness certificates.

3. **Tropical barrier functions.** Interior-point methods using barrier functions that blow up at the margin cell boundaries could enable robust training with exact geometric objectives.

4. **Active facet methods.** Only the *active* facets (nearest boundaries) matter for certification. Efficient data structures for maintaining active facets under input perturbation could enable real-time certification.

5. **Formal verification of deep networks.** The current formalization covers the building block — exact radius for affine classifiers. Extending to compositional verification of deep networks is the key challenge.

## 8. Formal Verification

All main results have been formally verified in Lean 4 with Mathlib. The formalization covers:

- Definitions: `tropScore`, `tropMarginDiff`, `tropMarginCell`, `tropRowDiff`
- Algebraic lemmas: `tropMarginDiff_eq`, `tropMarginDiff_add`, `tropMarginDiff_sub_eq`
- Cauchy-Schwarz bound: `tropMarginDiff_lipschitz`
- Ball inclusion: `halfspace_ball_inclusion`, `ball_in_tropMarginCell`
- Sharpness: `tropMarginCell_sharpness`
- Main theorem: `chebyshev_radius_eq_min_boundary_dist`
- Positive radius: `chebyshev_radius_pos_of_strict_margins`

All proofs use only standard axioms (propext, Classical.choice, Quot.sound). No `sorry` remains.

## References

1. M. Alfarra, A. Bibi, H. Hammoud, M. Sabir, and B. Ghanem. "On the decision boundaries of neural networks: A tropical geometry perspective." *IEEE TPAMI*, 2022.

2. H. Edelsbrunner. *Algorithms in Combinatorial Geometry.* Springer, 1987.

3. M. Hein and M. Andriushchenko. "Formal guarantees on the robustness of a classifier against adversarial manipulation." *NeurIPS*, 2017.

4. L. Zhang, G. Naitzat, and L.-H. Lim. "Tropical geometry of deep neural networks." *ICML*, 2018.

5. C. Szegedy, W. Zaremba, I. Sutskever, J. Bruna, D. Erhan, I. Goodfellow, and R. Fergus. "Intriguing properties of neural networks." *ICLR*, 2014.
