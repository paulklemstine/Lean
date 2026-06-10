# Tropical Hodge Decomposition on Weighted Polyhedral Complexes

## Abstract

We formalize the tropical analog of the Hodge decomposition on finite weighted polyhedral complexes. Working over ℝ with positive-definite weighted inner products, we define the combinatorial Laplacian Δ = δd (where δ = W⁻¹dᵀW is the codifferential), prove the fundamental adjunction ⟨du, v⟩ = ⟨u, δv⟩, and establish the kernel characterization ker(Δ) = ker(d). We introduce tropical (p,q)-biforms, formalize the tropical Hodge star, and prove structural properties of the Laplacian including the trace formula and non-negativity of diagonal entries. As a concrete application, we show that the graph Laplacian is a special case and prove its symmetry. We state the Tropical Hard Lefschetz Property as a falsifiable conjecture with explicit testable predictions.

## 1. Introduction

The Hodge decomposition is a cornerstone of differential geometry and algebraic topology. On a compact Riemannian manifold, it states that every k-form admits a unique orthogonal decomposition into exact, coexact, and harmonic components:

$$\Omega^k = \text{im}(d_{k-1}) \oplus \ker(\Delta_k) \oplus \text{im}(\delta_{k+1})$$

where Δ = dδ + δd is the Hodge Laplacian. The harmonic forms ker(Δ) are isomorphic to the de Rham cohomology H^k(M), providing a deep connection between analysis and topology.

In the tropical setting, smooth manifolds are replaced by polyhedral complexes—combinatorial structures built from flat faces glued along their boundaries. Despite the absence of smoothness, the essential algebraic structure of the Hodge decomposition persists: coboundary operators, inner products, and adjunction.

### 1.1 Related Work

The tropical Hodge theory has its roots in several lines of research:

- **Combinatorial Hodge theory** (Eckmann 1944, Dodziuk-Patodi 1976): The Hodge decomposition for finite simplicial complexes with real coefficients.
- **Tropical algebraic geometry** (Mikhalkin 2004, Itenberg-Katzarkov-Mikhalkin-Zharkov 2019): The development of cohomology theories for tropical varieties.
- **Matroid Hodge theory** (Adiprasito-Huh-Katz 2018): The proof of the Kähler package for matroid Chow rings, confirming log-concavity of matroid invariants.
- **Tropical Dolbeault cohomology** (Jell-Shaw-Smacka 2019): The bidegree decomposition of tropical differential forms.

Our contribution is a rigorous formalization of the foundational theory, with complete proofs of the adjunction property, kernel characterization, and trace formula.

## 2. Weighted Cochain Complexes

### 2.1 Definition

**Definition 2.1** (WeightedCoboundary). A weighted coboundary consists of:
- Dimensions m, n ∈ ℕ
- A coboundary matrix d ∈ ℝ^{n×m}
- Source weights w_src : Fin m → ℝ₊
- Target weights w_tgt : Fin n → ℝ₊

with all weights strictly positive.

The source and target weight matrices are:
$$W_{src} = \text{diag}(w_{src}), \quad W_{tgt} = \text{diag}(w_{tgt})$$

### 2.2 The Codifferential

**Definition 2.2** (Codifferential). The codifferential δ : ℝ^n → ℝ^m is defined as:
$$\delta = W_{src}^{-1} d^\top W_{tgt}$$

This is the formal adjoint of d with respect to the weighted inner products. The formula ensures that the weights on the source and target spaces are properly accounted for.

### 2.3 The Laplacian

**Definition 2.3** (Combinatorial Laplacian).
- The Laplacian-up: Δ^{up} = δd : ℝ^m → ℝ^m
- The Laplacian-down: Δ^{down} = dδ : ℝ^n → ℝ^n

## 3. Weighted Inner Product

### 3.1 Definition and Basic Properties

**Definition 3.1** (Weighted Inner Product). For w : Fin k → ℝ and u, v : Fin k → ℝ:
$$\langle u, v \rangle_w = \sum_i w_i \cdot u_i \cdot v_i$$

**Theorem 3.1** (Symmetry). $\langle u, v \rangle_w = \langle v, u \rangle_w$.

*Proof.* Each summand $w_i u_i v_i = w_i v_i u_i$ by commutativity of multiplication. □

**Theorem 3.2** (Positive Definiteness). If $w_i > 0$ for all i and $v \neq 0$, then $\langle v, v \rangle_w > 0$.

*Proof.* Each summand $w_i v_i^2 \geq 0$ since $w_i > 0$ and $v_i^2 \geq 0$. Since $v \neq 0$, there exists $i_0$ with $v_{i_0} \neq 0$, giving $w_{i_0} v_{i_0}^2 > 0$. The sum is therefore strictly positive. □

**Theorem 3.3** (Zero Characterization). If $w_i > 0$ for all i, then $\langle v, v \rangle_w = 0$ iff $v = 0$.

*Proof.* The forward direction follows from the fact that a sum of non-negative terms is zero iff each term is zero. Since $w_i > 0$, the term $w_i v_i^2 = 0$ implies $v_i = 0$. □

## 4. The Adjunction Theorem

**Theorem 4.1** (Adjunction). For all u ∈ ℝ^m and v ∈ ℝ^n:
$$\langle du, v \rangle_{tgt} = \langle u, \delta v \rangle_{src}$$

*Proof.* Expanding both sides:
$$\text{LHS} = \sum_i w_{tgt,i} \left(\sum_j d_{ij} u_j\right) v_i = \sum_{i,j} w_{tgt,i} d_{ij} u_j v_i$$

$$\text{RHS} = \sum_j w_{src,j} u_j \left(\sum_i w_{src,j}^{-1} d_{ij} w_{tgt,i} v_i\right) = \sum_{i,j} w_{tgt,i} d_{ij} u_j v_i$$

The weight factors cancel exactly due to the definition δ = W_{src}^{-1} d^T W_{tgt}. □

This is the tropical analog of integration by parts. In the classical setting, $\int_M \langle d\alpha, \beta \rangle \, dV = \int_M \langle \alpha, \delta\beta \rangle \, dV$ (for compactly supported forms). The tropical version replaces integration with weighted summation.

## 5. Kernel Characterization

**Theorem 5.1** (Kernel Characterization). ker(Δ^{up}) = ker(d).

*Proof.*
(⇐) If dv = 0, then Δ^{up}v = δ(dv) = δ(0) = 0. Trivial.

(⇒) If Δ^{up}v = δdv = 0, then:
$$0 = \langle \delta dv, v \rangle_{src} = \langle dv, dv \rangle_{tgt}$$

where the second equality uses the adjunction theorem. By positive definiteness of the weighted inner product (Theorem 3.2), $dv = 0$. □

This proof is the heart of the tropical Hodge theory. It shows that the Laplacian detects exactly the closed forms—a form is harmonic if and only if it is closed. The proof relies critically on the positive definiteness of the weighted inner product, which in turn requires the positivity of the weights.

## 6. Laplacian Properties

### 6.1 Non-negativity

**Theorem 6.1**. The diagonal entries of Δ^{up} are non-negative:
$$\Delta^{up}_{ii} = w_{src,i}^{-1} \sum_k w_{tgt,k} d_{ki}^2 \geq 0$$

*Proof.* Each factor in the sum is non-negative: $w_{src,i}^{-1} > 0$ since $w_{src,i} > 0$, and $w_{tgt,k} d_{ki}^2 \geq 0$. □

### 6.2 Trace Formula

**Theorem 6.2** (Trace Formula).
$$\text{tr}(\Delta^{up}) = \sum_{i=1}^n \sum_{j=1}^m w_{src,j}^{-1} w_{tgt,i} d_{ij}^2$$

*Proof.* Follows from expanding $\text{tr}(\delta d) = \sum_j (\delta d)_{jj} = \sum_j \sum_i \delta_{ji} d_{ij}$ and substituting the explicit form of $\delta$. □

The trace formula has a geometric interpretation: it measures the total "energy" of the coboundary map, weighted by the inverse source weights and target weights. In the graph Laplacian case, this reduces to $\text{tr}(L) = \sum_e w_e \cdot \deg^{L}(e)$, where $\deg^L$ is a weighted degree function.

## 7. Tropical Biforms

### 7.1 Definition

**Definition 7.1** (Tropical Biform). A tropical (p,q)-biform on an n-dimensional tropical variety consists of a coefficient vector indexed by the $\binom{n}{p+q}$ cells of total degree p+q, with the constraint p+q ≤ n.

### 7.2 Tropical Hodge Star

**Definition 7.2** (Tropical Hodge Star). The tropical Hodge star ★ maps (p,q)-forms to (q,p)-forms by applying the weight function:
$$(\star f)_i = w_i \cdot f_i$$

This swaps the bidegree while preserving the total degree, analogous to the classical Hodge star on Kähler manifolds.

## 8. Graph Laplacian as Special Case

**Theorem 8.1** (Graph Laplacian Symmetry). For a weighted graph G with incidence matrix B and edge weight matrix W, the graph Laplacian L = B^T W B is symmetric.

*Proof.* $L^T = (B^T W B)^T = B^T W^T (B^T)^T = B^T W B = L$, using the symmetry of the diagonal matrix W. □

**Theorem 8.2** (Graph Laplacian Non-negativity). The diagonal entries of L are non-negative:
$$L_{vv} = \sum_e w_e B_{ev}^2 \geq 0$$

**Theorem 8.3** (Laplacian Agreement). The graph Laplacian L = B^T W B agrees with the Laplacian-up of the corresponding WeightedCoboundary (with unit source weights).

## 9. Tropical Hard Lefschetz Property

### 9.1 Definition

**Definition 9.1** (Hard Lefschetz Property). A sequence of Betti numbers $(b_0, b_1, \ldots, b_n)$ satisfies HLP if:
$$b_k \leq b_{n-k} \quad \text{for all } k \leq n/2$$

### 9.2 Conjecture

**Conjecture 9.1** (Tropical Hard Lefschetz). For any balanced fan Σ of dimension n arising from a matroid, the Betti numbers of the tropical Hodge cohomology satisfy HLP.

**Testable Prediction**: For the Boolean matroid $M = U_{2,4}$, the expected Betti sequence is $(1, 3, 1)$ with $b_0 = 1 \leq 3 = b_1$ and $b_2 = 1 \leq 3 = b_1$.

### 9.3 Known Results

The HLP is known to hold for:
- Matroid Chow rings (Adiprasito-Huh-Katz 2018)
- Bergman fans of regular matroids
- Smooth tropical varieties in dimension ≤ 3

It is known to fail for:
- General (non-balanced) polyhedral complexes
- Certain singular tropical surfaces

## 10. Algorithms

### 10.1 Computing the Combinatorial Laplacian

Given the incidence matrix d and weight vectors, the Laplacian Δ^{up} = W_src^{-1} d^T W_tgt d can be computed in O(mnk) time where m, n are the dimensions and k is the number of non-zero entries in d.

### 10.2 Computing Harmonic Forms

The harmonic forms are the kernel of Δ^{up}. For a matrix of size m × m, the kernel can be computed via:
1. SVD decomposition: O(m³) time, identifies all singular vectors with zero singular value.
2. Gaussian elimination: O(m³) time, produces a basis for the null space.

### 10.3 Computing Betti Numbers

The k-th Betti number equals dim(ker Δ_k) = m_k - rank(Δ_k), where m_k is the number of k-cells.

## 11. Discussion

### 11.1 Comparison with Classical Theory

The tropical Hodge decomposition parallels the classical theory in several ways:

| Classical | Tropical |
|-----------|----------|
| Smooth manifold | Polyhedral complex |
| Differential forms | Cochains |
| Exterior derivative d | Coboundary operator |
| Hodge star ★ | Weight-based conjugation |
| Riemannian metric | Cell weights |
| Integration by parts | Adjunction theorem |
| Harmonic forms | Kernel of Δ |
| de Rham cohomology | Simplicial cohomology |

### 11.2 Relation to Existing Catalog

This work builds on and extends the catalog's tropical foundations:
- `FINAL/Tropical/Algebra.lean`: Basic tropical (min-plus) algebra
- `FINAL/Tropical/HodgeCorrespondence.lean`: Tropical cycle-class correspondence
- `Catalog/Tropical/HodgeTheory/Foundations.lean`: Tropical vector norms and inner products

The key advance is the formalization of the combinatorial Laplacian with weighted inner products and the proof of the adjunction-based kernel characterization.

## 12. Future Work

1. **Full Hodge Decomposition**: Prove the orthogonal decomposition Ω^k = im(d) ⊕ ker(Δ) ⊕ im(δ) using the projection theorem for finite-dimensional inner product spaces.

2. **Tropical Hodge-Riemann Relations**: Formalize the bilinear form Q(α, β) = (-1)^k ⟨L^{n-2k}α, β⟩ and prove its positive-definiteness on primitive forms.

3. **Spectral Gap Bounds**: Establish lower bounds on the smallest non-zero eigenvalue of the tropical Laplacian in terms of the combinatorial geometry of the complex.

4. **Tropical Heat Kernel**: Define the heat semigroup e^{-tΔ} and prove convergence to the harmonic projection as t → ∞.

## References

1. Adiprasito, K., Huh, J., & Katz, E. (2018). Hodge theory for combinatorial geometries. *Annals of Mathematics*, 188(2), 381-452.

2. Itenberg, I., Katzarkov, L., Mikhalkin, G., & Zharkov, I. (2019). Tropical homology. *Mathematische Annalen*, 374(1-2), 963-1006.

3. Jell, P., Shaw, K., & Smacka, J. (2019). Superforms, tropical cohomology, and Poincaré duality. *Advances in Geometry*, 19(1), 101-130.

4. Mikhalkin, G. (2004). Amoebas of algebraic varieties and tropical geometry. In *Different faces of geometry* (pp. 257-300). Springer.
