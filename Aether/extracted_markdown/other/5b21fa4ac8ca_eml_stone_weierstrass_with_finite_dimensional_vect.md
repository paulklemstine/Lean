# Vector-Valued EML Stone–Weierstrass via Affine Partition-of-Unity Coding

**A Formally Verified Density Theorem for Barycentric Approximation of Continuous Maps into Finite-Dimensional Spaces**

---

## Abstract

We prove a vector-valued extension of the Stone–Weierstrass density theorem for EML (Exponential-Logistic-Monomial) function classes: if a set S of continuous scalar functions is uniformly dense in C(X, ℝ) for a compact Hausdorff space X, then the set of *affine codings* — finite sums ∑ᵢ φᵢ(x) · vᵢ with φᵢ ∈ S and vᵢ ∈ ℝᵐ constant — is uniformly dense in C(X, ℝᵐ). The proof is fully formalized in Lean 4 using the Mathlib library and produces no axioms beyond the standard propext, Classical.choice, and Quot.sound.

As a corollary, the EML subalgebra closure, which is known to be all of C(X, ℝ) by the classical Stone–Weierstrass theorem, generates a dense set of vector-valued affine codings in C(X, ℝᵐ). We also prove a quantitative perturbation bound for affine codings: when scalar weight functions are perturbed, the resulting vector error is controlled by the sum of scalar perturbation norms times a bound on the output vectors.

## 1. Introduction

Universal approximation theorems are foundational results in machine learning and approximation theory. The classical Stone–Weierstrass theorem states that any subalgebra of continuous real-valued functions on a compact Hausdorff space that separates points and contains constants is dense. This has been applied to neural networks, kernel methods, and numerous other function approximation settings.

However, many applications require *vector-valued* outputs: multiclass classification produces probability vectors on the simplex, embeddings map inputs to high-dimensional feature spaces, and regression targets may be multi-dimensional. The naive approach — "approximate each coordinate independently" — works mathematically but obscures the geometric structure of the output space. In particular, it does not reveal that approximations can be constructed as *affine combinations* of finitely many anchor points, with weights coming from the scalar approximation class.

### 1.1 Contributions

We make three contributions:

1. **Definition of VecEML.** We define the class of vector-valued affine codings VecEML(S, m) as the set of continuous maps F : X → ℝᵐ that can be written as F(x) = ∑ᵢ φᵢ(x) · vᵢ for finitely many scalar functions φᵢ ∈ S and constant output vectors vᵢ ∈ ℝᵐ.

2. **Density theorem.** We prove that if S is uniformly dense in C(X, ℝ) (for X compact Hausdorff and nonempty), then VecEML(S, m) is uniformly dense in C(X, ℝᵐ) for all m ≥ 1.

3. **Perturbation bound.** We prove a quantitative stability result: perturbing the scalar weight functions by at most δ in sup-norm produces at most n · δ · B error in the vector output, where n is the number of weight functions and B bounds the output vectors.

All results are formalized in Lean 4 and verified by the Lean type checker.

## 2. Definitions

### 2.1 Scalar-vector product

For a continuous scalar function f : C(X, ℝ) and a constant vector v ∈ ℝᵐ, the **scalar-vector product** is:

```
scalarVec(f, v)(x) = f(x) · v
```

i.e., scalarVec(f, v) : C(X, ℝᵐ) with scalarVec(f, v)(x)(j) = f(x) · v(j).

### 2.2 Vector EML class

Given a set S ⊆ C(X, ℝ) of scalar functions, the **vector EML class** is:

```
VecEML(S, m) = { F ∈ C(X, ℝᵐ) | ∃ n, ∃ φ₁,...,φₙ ∈ S, ∃ v₁,...,vₙ ∈ ℝᵐ,
                  F = ∑ᵢ scalarVec(φᵢ, vᵢ) }
```

This is the set of all finite linear combinations of "scalar gate × constant output" pairs.

## 3. Main Results

### 3.1 Pointwise perturbation bound

**Theorem (affine_coding_error_bound_pointwise).** For any scalar weight functions ψᵢ, φᵢ : C(X, ℝ) and output vectors yᵢ ∈ ℝᵐ,

```
‖(∑ᵢ ψᵢ(x) · yᵢ) - (∑ᵢ φᵢ(x) · yᵢ)‖ ≤ ∑ᵢ |ψᵢ(x) - φᵢ(x)| · ‖yᵢ‖
```

The proof rewrites the left side as ‖∑ᵢ (ψᵢ(x) - φᵢ(x)) · yᵢ‖, applies the triangle inequality for sums, and uses the norm-scalar product identity.

### 3.2 Sup-norm perturbation bound

**Theorem (affine_coding_error_bound).** Under the same setup, if ‖yᵢ‖ ≤ B for all i, then:

```
‖∑ᵢ scalarVec(ψᵢ, yᵢ) - ∑ᵢ scalarVec(φᵢ, yᵢ)‖_∞ ≤ (∑ᵢ ‖ψᵢ - φᵢ‖_∞) · B
```

This follows from the pointwise bound by taking suprema and using the characterization of the continuous-map norm via ContinuousMap.norm_le.

### 3.3 Vector-valued density

**Theorem (vecEML_dense_of_scalar_dense).** Let X be a compact Hausdorff nonempty topological space. If S ⊆ C(X, ℝ) is uniformly dense — meaning for every f ∈ C(X, ℝ) and ε > 0, there exists g ∈ S with ‖f - g‖ < ε — then for every m ≥ 1, F ∈ C(X, ℝᵐ), and ε > 0:

```
∃ G ∈ VecEML(S, m), ‖F - G‖ < ε
```

*Proof sketch.* Decompose F into coordinate projections: let fⱼ(x) = F(x)(j) for each j ∈ Fin m. By scalar density, choose gⱼ ∈ S with ‖fⱼ - gⱼ‖ < ε/m. Define:

```
G = ∑ⱼ scalarVec(gⱼ, eⱼ)
```

where eⱼ = Pi.single j 1 is the j-th standard basis vector. Then G ∈ VecEML(S, m) by construction. The perturbation bound gives:

```
‖F - G‖ ≤ ∑ⱼ ‖fⱼ - gⱼ‖ · ‖eⱼ‖ = ∑ⱼ ‖fⱼ - gⱼ‖ < m · (ε/m) = ε
```

### 3.4 EML-specific corollary

**Theorem (eml_vec_dense).** Let X be a compact Hausdorff nonempty space with a point-separating family Φ : Fin n → C(X, ℝ), n ≥ 1. Then VecEML(EMLClosure(Φ), m) is dense in C(X, ℝᵐ) for all m ≥ 1.

This follows immediately from the scalar EML Stone–Weierstrass theorem (the EML subalgebra's topological closure is ⊤ by Stone–Weierstrass, since it separates points) combined with vecEML_dense_of_scalar_dense.

## 4. Formalization

The formalization comprises approximately 200 lines of Lean 4 code in a single file `VecEML.lean`. Key design decisions:

- **Output type:** We use `Fin m → ℝ` with Mathlib's `Pi.seminormedAddCommGroup` instance, giving the sup norm ‖v‖ = supⱼ |vⱼ|.
- **Continuous map norm:** We use Mathlib's `ContinuousMap.instBoundedContinuousMapNormedAddCommGroup` for the sup norm on C(X, ℝᵐ).
- **Index type:** Sums over Fin n avoid Finset bookkeeping.
- **Self-contained:** The file imports only Mathlib and defines all EML-specific constructs inline.

### 4.1 Axiom audit

All theorems depend only on the standard Lean axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No additional axioms, `sorry`, or `@[implemented_by]` are used.

## 5. Applications

### 5.1 Multiclass classification

In multiclass classification, a model maps inputs to the probability simplex Δᵏ ⊂ ℝᵏ. The VecEML theorem shows that any continuous classifier can be uniformly approximated by:

```
F̂(x) = ∑ᵢ φᵢ(x) · pᵢ
```

where φᵢ are scalar EML functions and pᵢ ∈ Δᵏ are "prototype" probability vectors. This is precisely the architecture of attention-based mixture models and prototype networks.

### 5.2 Embedding approximation

Word embeddings, sentence embeddings, and other learned representations map discrete or continuous inputs to ℝᵈ. VecEML density guarantees that any continuous embedding can be approximated by a finite affine coding — a linear combination of finitely many "anchor embeddings" with scalar weights. This provides a theoretical foundation for codebook-based vector quantization methods.

### 5.3 Neural network output layers

The affine coding structure ∑ᵢ φᵢ(x) · vᵢ is exactly the form of a neural network's output layer: the φᵢ are hidden-unit activations and vᵢ are the columns of the output weight matrix. VecEML density says this architecture is universal for vector-valued approximation, provided the scalar activations φᵢ come from a dense class.

### 5.4 Certified robustness

For certified robustness of multiclass classifiers, one needs to control how perturbations to the input affect the output probability vector. The perturbation bound theorem provides exactly this: if the scalar weight functions change by at most δ (in sup norm), the output vector changes by at most n · δ · B. This is directly applicable to Lipschitz analysis of simplex-valued networks.

## 6. Discussion: The Geometry of Scalar Universality

*A Scientific American-style exposition*

Imagine you're an artist with a peculiar constraint: you can only use a fixed palette of colors (the anchor vectors vᵢ), and for each point on your canvas, you choose how much of each color to apply using scalar "dial" functions φᵢ. The question is: can you paint any picture?

The classical Stone–Weierstrass theorem says "yes" for black-and-white pictures — any shade of gray can be approximated by the right combinations of scalar functions. Our vector-valued theorem extends this to full color: if your scalar dials are rich enough to approximate any single number, then by combining them with the right color anchors, you can approximate any continuous color field.

What makes this non-trivial? The key insight is that you don't need separate scalar function classes for each color channel. A *single* dense set of scalar functions, combined with constant color anchors, suffices. The mathematical content is that the "tensor product" of scalar universality with finite-dimensional geometry gives vector universality — and the proof goes through affine coding, which is the natural geometric structure.

This has a beautiful physical analogy. In quantum mechanics, any state of a system can be written as a superposition of basis states: |ψ⟩ = ∑ᵢ cᵢ|eᵢ⟩. Our theorem is the functional-analytic analog: any continuous vector-valued function can be written (approximately) as a superposition of basis vectors with spatially-varying scalar coefficients.

The connection to machine learning is direct. A neural network's last layer computes exactly this: it takes scalar activations from hidden neurons and forms a linear combination with learned output vectors. Our theorem proves that this architecture is universal for any vector-valued target — not just for each coordinate independently, but for the entire vector simultaneously.

### 6.1 Why barycentric coding matters

The specific structure of the approximation — scalar weights times constant vectors — is not just a mathematical convenience. It corresponds to important computational architectures:

- **Attention mechanisms:** In transformers, the attention output is a weighted sum of value vectors: output = ∑ᵢ αᵢ · vᵢ. This is exactly an affine coding where αᵢ are data-dependent scalar weights and vᵢ are the value vectors.

- **Mixture-of-experts:** The gating network produces scalar weights φᵢ(x), and each expert produces a constant (or nearly constant) output vᵢ. The mixture output is ∑ᵢ φᵢ(x) · vᵢ.

- **Nearest-neighbor interpolation:** K-nearest-neighbor regression computes ∑ᵢ wᵢ(x) · yᵢ where wᵢ(x) are distance-based weights and yᵢ are training labels. This is affine coding with data-dependent weights.

### 6.2 Historical context

The scalar Stone–Weierstrass theorem dates to 1937 (Stone's generalization of Weierstrass's 1885 polynomial approximation theorem). Vector-valued extensions have been known informally, but the specific formulation through "affine coding" — emphasizing the geometric structure of scalar weights times constant output vectors — appears to be new in this form. The formalization in Lean 4 with Mathlib is, to our knowledge, the first machine-verified proof of this result.

### 6.3 Future directions

1. **Quantitative rates:** The current theorem is qualitative (density). Adding modulus-of-continuity bounds would give quantitative approximation rates.

2. **Constrained outputs:** Extend to maps into convex subsets (simplices, balls) by adding constraints on the weight functions (nonnegativity, sum-to-one).

3. **Infinite-dimensional targets:** Generalize from ℝᵐ to Banach-space-valued maps, where the proof strategy requires more care.

4. **Computational complexity:** Relate the number of terms n in the affine coding to the approximation accuracy ε, giving a "width-accuracy" tradeoff for vector-valued EML networks.

## 7. Conclusion

We have formally verified a vector-valued density theorem for EML function classes, showing that scalar universality lifts to vector-valued universality through affine coding. The key technical tools — the pointwise and sup-norm perturbation bounds — are independently useful for Lipschitz analysis of vector-valued function approximation. The entire development is machine-checked in Lean 4, providing the highest level of mathematical certainty.

## References

1. Stone, M.H. (1937). "Applications of the theory of Boolean rings to general topology." *Trans. AMS* 41(3): 375–481.

2. de Branges, L. (1959). "The Stone–Weierstrass theorem." *Proc. AMS* 10(5): 822–824.

3. Mathlib Community (2024). *Mathlib4: The Lean 4 Mathematical Library.* https://github.com/leanprover-community/mathlib4
