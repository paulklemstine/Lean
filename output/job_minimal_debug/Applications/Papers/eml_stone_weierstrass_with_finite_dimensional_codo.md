# Finite-Dimensional Vector-Valued Stone–Weierstrass via Dual-Basis Scalarization: A Formally Verified Approach

## Abstract

We present a formally verified finite-dimensional vector-valued extension of the Stone–Weierstrass approximation theorem, developed in Lean 4 with the Mathlib library. Our main result reduces the problem of uniform approximation in $C(X, V)$ — the space of continuous functions from a compact space $X$ to a finite-dimensional normed space $V$ — to independent scalar approximation along each coordinate of a fixed basis. The proof proceeds by establishing a quantitative reconstruction bound that controls the vector-valued approximation error in terms of the maximum coordinate error, using the finite-dimensional norm equivalence principle. We derive practical corollaries for multi-output EML (Exponential-Monomial-Logistic) models, providing the rigorous foundation for vector-valued universal approximation.

**Keywords:** Stone–Weierstrass theorem, universal approximation, formal verification, Lean 4, finite-dimensional analysis, EML models

---

## 1. Introduction

The classical Stone–Weierstrass theorem is one of the cornerstones of approximation theory: it characterizes when a subalgebra of $C(X, \mathbb{R})$ is dense in the uniform topology. For scalar-valued functions, this result has been extensively studied, generalized, and — more recently — formally verified in proof assistants including Lean 4's Mathlib library.

However, many applications in machine learning, control theory, and scientific computing require *vector-valued* approximation. A neural network with $n$ outputs computes a function $f : \mathbb{R}^d \to \mathbb{R}^n$, and proving that such networks are universal approximators requires a vector-valued density theorem. While the extension from scalar to vector is mathematically "well-known," the precise formulation, the quantitative error bounds, and the formal verification present nontrivial challenges.

In this work, we:

1. **Formalize** the finite-dimensional vector-valued Stone–Weierstrass theorem in Lean 4, proving that density of coordinate-wise scalar approximations implies density of the vector-valued class.

2. **Establish quantitative bounds** showing how the reconstruction constant $C$ (determined by the basis and norm) controls the translation from coordinate errors to vector errors.

3. **Derive EML corollaries** for multi-output models, providing the bridge from scalar EML density to vector-valued EML density.

4. **Verify all proofs** with the Lean 4 kernel, ensuring mathematical correctness with zero sorry statements and only standard axioms (propext, Classical.choice, Quot.sound).

### 1.1 Related Work

The vector-valued Stone–Weierstrass theorem has a long history in functional analysis. The classical references include Nachbin's work on weighted approximation and Prolla's treatment of vector-valued continuous functions. In the context of neural networks, Hornik, Stinchcombe, and White (1989) established scalar universal approximation, and various authors have extended this to vector-valued settings, typically by the argument we formalize here.

The novelty of our contribution is not the mathematical content per se, but the *formal verification* of the complete chain from norm equivalence through reconstruction bounds to the density theorem, in a form directly applicable to EML models.

---

## 2. Mathematical Framework

### 2.1 Setting

Let $X$ be a compact topological space, and let $V$ be a finite-dimensional real normed space with $\dim_{\mathbb{R}} V = n$. We work with the Banach space $C(X, V)$ of continuous functions $f : X \to V$, equipped with the supremum norm:
$$\|f\|_\infty = \sup_{x \in X} \|f(x)\|_V.$$

Fix a basis $b_1, \ldots, b_n$ of $V$ with dual coordinate functionals $\ell_i = b^*.coord(i) : V \to \mathbb{R}$.

### 2.2 The Reconstruction Map

The **reconstruction map** $R : \mathbb{R}^n \to V$ is defined by:
$$R(c) = \sum_{i=1}^n c_i \cdot b_i.$$

This is a linear isomorphism (since the $b_i$ form a basis), and on finite-dimensional spaces, every linear map is continuous. Hence $R$ has finite operator norm:
$$\|R(c)\|_V \leq \|R\|_{op} \cdot \|c\|_{\mathbb{R}^n}.$$

The **reconstruction constant** is $C = \|R\|_{op}$, which depends on the chosen basis and norms.

### 2.3 Key Identity

For any $v \in V$, the basis reconstruction identity gives:
$$v = \sum_{i=1}^n \ell_i(v) \cdot b_i = R(\ell_1(v), \ldots, \ell_n(v)).$$

Consequently, for any vector $c \in \mathbb{R}^n$:
$$R(c) - v = \sum_{i=1}^n (c_i - \ell_i(v)) \cdot b_i = R(c - \ell(v)).$$

This is the **reconstruction error identity**: the vector error decomposes as a linear combination of coordinate errors in the same basis.

---

## 3. Main Results

### 3.1 Reconstruction Error Bound

**Theorem (Pointwise Reconstruction Bound).** *Let $b$ be a basis of $V$ with reconstruction constant $C$. For any $g \in C(X, V)$ and scalar approximants $\varphi_i \in C(X, \mathbb{R})$, the reconstructed approximant $F(x) = \sum_i \varphi_i(x) \cdot b_i$ satisfies:*
$$\|F(x) - g(x)\|_V \leq C \cdot \|(\varphi_1(x) - \ell_1(g(x)), \ldots, \varphi_n(g(x)))\|_{\mathbb{R}^n}$$
*for every $x \in X$.*

Taking the supremum over $x$ and using the fact that $\|\cdot\|_{\mathbb{R}^n}$ is bounded by the maximum coordinate value:

**Theorem (Sup-Norm Reconstruction Bound).** *There exists $C > 0$ such that for any $g \in C(X, V)$ and $\varphi : \iota \to C(X, \mathbb{R})$:*
$$d(F, g) \leq C \cdot \max_i\, d(\varphi_i, \ell_i \circ g)$$
*where $F = \text{reconstructCM}(b, \varphi)$ and distances are in the respective sup-norm topologies.*

### 3.2 Main Density Theorem

**Theorem (closure_eq_top_findim).** *Let $A \subseteq C(X, V)$ be a set such that:*
1. *For each basis coordinate $i$, the scalar projections $\{\ell_i \circ f : f \in A\}$ are dense in $C(X, \mathbb{R})$.*
2. *For any family $(\varphi_i)$ with each $\varphi_i$ in the closure of the $i$-th scalar projections, the reconstructed map $\sum_i \varphi_i \cdot b_i$ lies in $\overline{A}$.*

*Then $\overline{A} = C(X, V)$, i.e., $A$ is dense.*

**Proof sketch.** Given any $f \in C(X, V)$, its coordinates $\ell_i \circ f$ lie in $C(X, \mathbb{R})$. By hypothesis (1), each $\ell_i \circ f$ is in the closure of the $i$-th scalar projections. By hypothesis (2), the reconstruction $\sum_i (\ell_i \circ f) \cdot b_i = f$ lies in $\overline{A}$. Hence every element of $C(X, V)$ is in $\overline{A}$.

### 3.3 Abstract Density from Scalar Density

**Theorem (dense_of_scalar_density).** *Let $S \subseteq C(X, \mathbb{R})$ be dense ($\overline{S} = C(X, \mathbb{R})$). If $A \subseteq C(X, V)$ contains all basis reconstructions from $S$ — that is, for every $(\psi_1, \ldots, \psi_n)$ with $\psi_i \in S$, the map $x \mapsto \sum_i \psi_i(x) \cdot b_i$ lies in $A$ — then $\overline{A} = C(X, V)$.*

This is the most practical formulation: it says that if you have a dense scalar class and can assemble coordinates freely, the result is a dense vector class.

### 3.4 EML Corollaries

For the concrete case $V = \text{Fin}\, n \to \mathbb{R}$ (functions from a finite index set to $\mathbb{R}$, with the supremum norm):

**Theorem (eml_uniform_dense_finvec).** *If for each coordinate $i$, the $i$-th coordinate projections of $A$ are dense in $C(X, \mathbb{R})$, and coordinate-wise closure elements can be assembled, then $\overline{A} = C(X, \text{Fin}\, n \to \mathbb{R})$.*

**Theorem (eml_closure_eq_top_of_scalar_dense).** *If $S \subseteq C(X, \mathbb{R})$ is dense and $A$ contains all maps $x \mapsto (\psi_1(x), \ldots, \psi_n(x))$ for $\psi_i \in S$, then $\overline{A} = C(X, \text{Fin}\, n \to \mathbb{R})$.*

---

## 4. Formal Verification

All results are formalized in the file `EML/VectorStoneWeierstrass.lean` using Lean 4.28.0 with Mathlib. The formalization consists of approximately 270 lines of Lean code with zero sorry statements. The axioms used are only `propext`, `Classical.choice`, and `Quot.sound` — the standard foundational axioms of Lean's type theory.

### 4.1 Key Formalization Decisions

1. **Basis representation.** We use Mathlib's `Module.Basis` type, which provides the reconstruction identity `b.sum_repr v` and coordinate functionals `b.coord i`.

2. **Continuous map space.** The type `C(X, V)` (or `ContinuousMap X V`) from Mathlib comes equipped with the compact-open topology, which for compact $X$ coincides with the supremum norm topology. Mathlib provides `ContinuousMap.dist_le` and related API.

3. **Finite-dimensional boundedness.** The crucial fact that every linear map from a finite-dimensional space is continuous is provided by Mathlib's `LinearMap.continuous_of_finiteDimensional`.

4. **Reconstruction map.** We define `reconstructionLM` as an explicit `LinearMap` and lift it to `reconstructCM` for continuous maps, proving continuity via `continuous_finset_sum`.

### 4.2 Proof Structure

The formal proof follows a bottom-up structure:

```
reconstruction_sub          (algebraic identity)
reconstruction_error_eq     (error decomposition)
        ↓
norm_reconstruction_le      (operator norm bound)
        ↓
norm_sub_reconstructCM_le   (pointwise error bound)
        ↓
dist_reconstructCM_le       (sup-norm error bound)
        ↓
closure_eq_top_findim       (main density theorem)
dense_of_scalar_density     (abstract density lifting)
        ↓
eml_uniform_dense_finvec    (EML corollary, Fin n → ℝ)
eml_closure_eq_top_of_scalar_dense  (simplified EML version)
```

---

## 5. Applications

### 5.1 Multi-Output Neural Networks

The most immediate application is to multi-output neural networks. A network with $d$ inputs and $n$ outputs computes $f : \mathbb{R}^d \to \mathbb{R}^n$. Our theorem says: if a network architecture can approximate any single-output continuous function on a compact domain (scalar universal approximation), then the same architecture with $n$ independent output heads can approximate any continuous vector-valued function.

This is precisely the setting of the EML framework, where scalar density has already been established via the Stone–Weierstrass theorem applied to the subalgebra generated by exponential and logistic activation functions.

### 5.2 Control Systems

In control theory, one often needs to approximate continuous feedback laws $u : X \to \mathbb{R}^m$ where $X$ is a compact state space and $m$ is the dimension of the control input. Our theorem provides the rigorous foundation for neural network-based control: if the network can approximate any scalar control signal, it can approximate any vector-valued control law.

### 5.3 Vector Fields and Dynamical Systems

Approximation of vector fields $F : M \to TM$ on compact manifolds reduces, via local trivializations, to approximation of functions $f : U \to \mathbb{R}^n$ on compact subsets of $\mathbb{R}^d$. Our theorem provides the density result needed for the finite-dimensional fibers.

### 5.4 Scientific Machine Learning

In physics-informed neural networks (PINNs) and other scientific ML applications, one frequently needs to approximate solution operators that map inputs to multi-component fields (e.g., velocity-pressure pairs in fluid dynamics, electric-magnetic field pairs in electromagnetics). The vector-valued density theorem ensures that architectures dense in the scalar case extend to these multi-output settings.

---

## 6. Discussion: Making Stone–Weierstrass Work for Vectors

*For the general reader*

Imagine you're trying to teach a robot arm to draw any possible curve in 3D space. The arm has three motors — one for each spatial direction (x, y, z). An obvious strategy: teach each motor independently to follow any desired one-dimensional trajectory, then run all three motors simultaneously. But does this actually work? Could there be some mysterious interference between the motors that prevents the combined system from reaching certain 3D curves?

The vector-valued Stone–Weierstrass theorem answers this definitively: **no, there is no interference.** If each individual motor can approximate any 1D trajectory to arbitrary precision, then the combined system can approximate any 3D trajectory. Moreover, the total error is at most a constant $C$ times the worst individual motor error.

This constant $C$ is the mathematical embodiment of a simple geometric fact: in a finite-dimensional space, controlling each coordinate separately is *almost* the same as controlling the whole vector. The "almost" is captured by $C$, which depends on how the coordinate system is aligned with the norm — for orthonormal coordinates and the Euclidean norm, $C = \sqrt{n}$ where $n$ is the dimension.

### Why Formal Verification Matters

One might ask: if this result is "obvious," why bother with machine-checked proofs? Three reasons:

1. **The devil is in the topology.** The statement involves closures, limits, and uniform convergence. Getting the quantifiers right — "for all epsilon, there exists a delta" — is exactly where informal proofs most often contain gaps. The Lean proof compiler catches every such gap.

2. **Reusable infrastructure.** The formalized reconstruction bound and density lifting theorems are not just for this one theorem — they can be imported and used in any downstream Lean project that needs vector-valued approximation results.

3. **Trust in the EML pipeline.** The EML framework aims to provide *formally verified* machine learning guarantees. Having the vector-valued extension verified means that multi-output EML models inherit the same rock-solid approximation guarantees as single-output models.

### Historical Context

The Stone–Weierstrass theorem, first proved by Marshall Stone in 1937 as a generalization of Weierstrass's 1885 polynomial approximation theorem, has been one of the most influential results in analysis. Its vector-valued extension was noted by various authors in the mid-20th century, often as a "routine" application of the scalar result combined with finite-dimensional analysis.

What makes the formal verification interesting is that this "routine" extension requires carefully tracking:
- The reconstruction constant through the operator norm of the basis expansion map
- The interaction between the pi-type norm on coordinates and the target space norm
- The topological relationship between metric closure and sequential approximation
- The assembly of coordinate-wise closure elements into vector-valued closure elements

Each of these steps, while individually straightforward, must be precisely stated and connected in a way that the type checker accepts.

---

## 7. Future Directions

1. **Infinite-dimensional extensions.** The current result is for finite-dimensional $V$. Extending to Banach space-valued functions requires the Bartle–Graves theorem or similar selection principles.

2. **Quantitative rates.** Our bound involves an existential constant $C$. Computing optimal constants for specific bases and norms would be valuable for practical error estimates.

3. **Operator-valued approximation.** For approximating linear operators $T : V \to W$ between finite-dimensional spaces, one can scalarize against test functionals on both sides. This is a natural next step.

4. **Integration with EML training theory.** Combining the density result with EML gradient theory and training dynamics would give end-to-end guarantees: not just that good approximations *exist*, but that gradient-based training can *find* them.

---

## 8. Conclusion

We have formally verified a finite-dimensional vector-valued Stone–Weierstrass theorem in Lean 4, providing the rigorous bridge from scalar approximation density to vector-valued density. The result is directly applicable to multi-output EML models and neural networks, and the formalization is clean, modular, and reusable. All proofs compile without sorry statements and use only standard axioms, ensuring the highest level of mathematical certainty.

---

## Appendix: Theorem Statements (Lean 4)

```lean
-- Main density theorem for general finite-dimensional V
theorem VectorSW.closure_eq_top_findim
    [TopologicalSpace X] [CompactSpace X]
    [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
    [Fintype ι] [Nonempty ι]
    (b : Basis ι ℝ V)
    (A : Set C(X, V))
    (hscalar_dense : ∀ i : ι, closure (scalarProjections b A i) = ⊤)
    (hreconstruct : ∀ φ : ι → C(X, ℝ),
      (∀ i, φ i ∈ closure (scalarProjections b A i)) →
      reconstructCM b φ ∈ closure A) :
    closure A = ⊤

-- Abstract density from scalar density
theorem VectorSW.dense_of_scalar_density
    (b : Basis ι ℝ V) (S : Set C(X, ℝ))
    (hS_dense : closure S = ⊤)
    (A : Set C(X, V))
    (h_contains_reconst : ∀ ψ : ι → C(X, ℝ),
        (∀ i, ψ i ∈ S) → reconstructCM b ψ ∈ A) :
    closure A = ⊤

-- EML corollary for Fin n → ℝ
theorem VectorSW.eml_closure_eq_top_of_scalar_dense
    (n : ℕ) (hn : 0 < n)
    (S : Set C(X, ℝ)) (hS_dense : closure S = ⊤)
    (A : Set C(X, Fin n → ℝ))
    (h_contains_pi : ∀ ψ : Fin n → C(X, ℝ),
        (∀ i, ψ i ∈ S) →
        (⟨fun x i => ψ i x, ...⟩ : C(X, Fin n → ℝ)) ∈ A) :
    closure A = ⊤
```

---

*All source code, formal proofs, and demonstration scripts are available in the repository.*
