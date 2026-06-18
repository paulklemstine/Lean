# Stone–Weierstrass Universal Approximation for EML-Generated Subalgebras

## Abstract

We establish a formally verified Stone–Weierstrass-style universal approximation framework for Exponential-Multiplicative-Logarithmic (EML) generated subalgebras of continuous functions. Working in Lean 4 with Mathlib, we prove three main results: (1) any point-separating subalgebra of $C(X, \mathbb{R})$ on a compact Hausdorff space has dense topological closure, yielding uniform $\varepsilon$-approximation; (2) density transfers through pullback along continuous maps, with the pullback's closure exactly capturing the subalgebra of functions factoring through the map; and (3) when the continuous map is injective, the pullback subalgebra is dense in the full function space. These results provide the missing functional-analytic bridge between EML's algebraic closure properties and a rigorous, architecture-independent universal approximation theorem.

## 1. Introduction

Universal approximation theorems are foundational results in machine learning theory, establishing that certain function classes can approximate any continuous function to arbitrary precision. The classical results of Cybenko (1989) and Hornik–Stinchcombe–White (1989) showed this for single-hidden-layer neural networks with sigmoidal activation. The Stone–Weierstrass theorem, however, provides a far more general and elegant framework: *any point-separating unital subalgebra of $C(X, \mathbb{R})$ is uniformly dense*.

The EML (Exponential-Multiplicative-Logarithmic) program develops a compositional framework for continuous function approximation based on exponential generators $x \mapsto \exp(\sum_i w_i \phi_i(x) + b)$ and their algebraic combinations. Previous work in this program established closure properties of EML classes under addition, multiplication, and composition, as well as pullback stability. What was missing was the decisive upgrade from "closed under expressive operations" to "uniformly dense in all continuous observables."

This paper fills that gap with machine-verified proofs in Lean 4, organized around three main theorems.

## 2. Main Results

### 2.1 Stone–Weierstrass Core

Let $X$ be a compact Hausdorff topological space and let $A$ be a subalgebra of $C(X, \mathbb{R})$ (the algebra of continuous real-valued functions on $X$ with the supremum norm).

**Theorem 1** (Topological closure equals top). *If $A$ separates points of $X$, then $A^{\mathrm{cl}} = C(X, \mathbb{R})$.*

```lean
theorem eml_topologicalClosure_eq_top_of_separatesPoints
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : A.SeparatesPoints) :
    A.topologicalClosure = ⊤
```

**Theorem 2** (Universal $\varepsilon$-approximation). *Under the same hypotheses, for every $f \in C(X, \mathbb{R})$ and $\varepsilon > 0$, there exists $g \in A$ with $\|g - f\|_\infty < \varepsilon$.*

```lean
theorem eml_exists_uniform_approx
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : A.SeparatesPoints)
    (f : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ g : A, ‖(g : C(X, ℝ)) - f‖ < ε
```

These results are direct consequences of Mathlib's formalization of the Stone–Weierstrass theorem. Their significance lies in their generality: they apply to *any* compact Hausdorff space $X$ and *any* point-separating subalgebra, not just neural network architectures on Euclidean domains.

### 2.2 Pullback Density Transfer

Given a continuous map $\varphi : X \to Y$ between compact Hausdorff spaces, we define:

- The **precomposition algebra homomorphism** $\varphi^* : C(Y, \mathbb{R}) \to C(X, \mathbb{R})$ by $g \mapsto g \circ \varphi$.
- The **pullback subalgebra** $\varphi^*(A) = \{g \circ \varphi \mid g \in A\}$ for a subalgebra $A \leq C(Y, \mathbb{R})$.
- The **factors-through subalgebra** $\mathcal{F}_\varphi = \{f \in C(X, \mathbb{R}) \mid \exists g \in C(Y, \mathbb{R}),\, f = g \circ \varphi\}$.

**Theorem 3** (Density transfer). *If $A^{\mathrm{cl}} = C(Y, \mathbb{R})$, then $\varphi^*(A)^{\mathrm{cl}} = \mathcal{F}_\varphi$.*

```lean
theorem pullback_closure_eq_factorsThrough
    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ))
    (hA : A.topologicalClosure = ⊤) :
    (pullbackSubalgebra φ A).topologicalClosure = factorsThroughSubalgebra φ
```

The proof has two directions:
- **$\leq$**: The factors-through subalgebra is topologically closed (it equals $\{f \mid \forall x_1\, x_2,\, \varphi(x_1) = \varphi(x_2) \Rightarrow f(x_1) = f(x_2)\}$, an intersection of closed sets). Since $\varphi^*(A) \subseteq \mathcal{F}_\varphi$ and $\mathcal{F}_\varphi$ is closed, the closure of $\varphi^*(A)$ is contained in $\mathcal{F}_\varphi$.
- **$\geq$**: For any $f = g \circ \varphi \in \mathcal{F}_\varphi$, since $A$ is dense, there exist $a_n \in A$ with $a_n \to g$ uniformly. By continuity of precomposition, $a_n \circ \varphi \to g \circ \varphi = f$ uniformly. Since $a_n \circ \varphi \in \varphi^*(A)$, we have $f \in \varphi^*(A)^{\mathrm{cl}}$.

A key lemma is the norm contractivity of precomposition:

$$\|g \circ \varphi - h \circ \varphi\|_\infty \leq \|g - h\|_\infty$$

This follows immediately from the fact that $\varphi(X) \subseteq Y$.

### 2.3 Injective Pullback: Full Density

**Theorem 4** (Factoring through injective maps). *If $\varphi : X \to Y$ is injective, then $\mathcal{F}_\varphi = C(X, \mathbb{R})$, i.e., every continuous function factors through $\varphi$.*

```lean
theorem factorsThrough_eq_top_of_injective
    (φ : C(X, Y)) (hφinj : Function.Injective φ) :
    factorsThroughSubalgebra φ = ⊤
```

The proof uses two topological facts:
1. An injective continuous map from a compact space to a Hausdorff space is a closed embedding.
2. The Tietze extension theorem: any continuous real-valued function on a closed subset of a normal space extends to the whole space.

Since compact Hausdorff spaces are normal, combining these yields: for any $f : X \to \mathbb{R}$, define $\tilde{f}$ on $\varphi(X)$ by $\tilde{f}(\varphi(x)) = f(x)$ (well-defined by injectivity), extend to all of $Y$ by Tietze, obtaining $g$ with $g \circ \varphi = f$.

**Corollary** (Injective pullback density). *If $A^{\mathrm{cl}} = C(Y, \mathbb{R})$ and $\varphi$ is injective, then $\varphi^*(A)^{\mathrm{cl}} = C(X, \mathbb{R})$.*

```lean
theorem pullback_dense_of_injective
    (φ : C(X, Y)) (hφinj : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : A.topologicalClosure = ⊤) :
    (pullbackSubalgebra φ A).topologicalClosure = ⊤
```

### 2.4 EML Universal Approximation

Combining the above, we obtain the definitive EML result:

**Theorem 5** (EML pullback universal approximation). *Let $A \leq C(Y, \mathbb{R})$ be a point-separating subalgebra (e.g., generated by EML primitives). Let $\varphi : X \hookrightarrow Y$ be an injective continuous map (e.g., a feature embedding). Then for every $f \in C(X, \mathbb{R})$ and $\varepsilon > 0$, there exists $g \in A$ with $\|g \circ \varphi - f\|_\infty < \varepsilon$.*

```lean
theorem eml_pullback_exists_approx
    (φ : C(X, Y)) (hφinj : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hsep : A.SeparatesPoints)
    (f : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ g : pullbackSubalgebra φ A, ‖(g : C(X, ℝ)) - f‖ < ε
```

## 3. Proof Architecture

The formalization consists of approximately 290 lines of Lean 4 code organized into four sections:

1. **Stone–Weierstrass Core** (~30 lines): Direct application of Mathlib's `subalgebra_topologicalClosure_eq_top_of_separatesPoints`.
2. **Pullback Infrastructure** (~130 lines): Definition of `precompAlgHom`, `pullbackSubalgebra`, `factorsThroughSubalgebra`, and the density transfer theorem.
3. **Injective Pullback** (~30 lines): The Tietze-based factoring theorem and its corollary.
4. **EML Corollaries** (~40 lines): Packaging the abstract results into EML-specific statements.

Key Mathlib dependencies:
- `ContinuousMap.subalgebra_topologicalClosure_eq_top_of_separatesPoints` (Stone–Weierstrass)
- `ContinuousMap.compRightAlgHom` (precomposition algebra homomorphism)
- `ContinuousMap.compRightAlgHom_continuous` (continuity of precomposition)
- `ContinuousMap.exists_extension` (Tietze extension)
- `Continuous.isClosedEmbedding` (injective maps from compact to Hausdorff are closed embeddings)

All proofs compile without `sorry` and use only the standard Lean axioms (`propext`, `Classical.choice`, `Quot.sound`).

## 4. Applications

### 4.1 Neural Network Universal Approximation

The classical universal approximation theorem for neural networks is an immediate corollary. Let $X = [0,1]^n$ (compact Hausdorff) and let $A$ be the subalgebra generated by $\{\sigma(\mathbf{w} \cdot \mathbf{x} + b) \mid \mathbf{w} \in \mathbb{R}^n, b \in \mathbb{R}\}$ where $\sigma$ is a non-polynomial continuous activation. If $A$ separates points (which follows from the existence of non-constant affine functions and the non-polynomial nature of $\sigma$), then $A$ is dense.

### 4.2 Feature-Based Learning

The pullback theorem formalizes the intuition behind feature engineering in machine learning:

- Let $Y$ be a high-dimensional feature space.
- Let $\varphi : X \to Y$ be a learned feature embedding (e.g., a deep network backbone).
- Let $A$ be a simple function class on $Y$ (e.g., linear functions).

If $A$ is dense in $C(Y, \mathbb{R})$ and $\varphi$ is injective (the embedding doesn't collapse distinct inputs), then $\{g \circ \varphi \mid g \in A\}$ can approximate any continuous function on $X$.

This provides a rigorous justification for the "learn a good representation, then fit a simple model" paradigm.

### 4.3 Kernel Methods

In kernel methods, data $x \in X$ is mapped to a reproducing kernel Hilbert space via $\varphi : X \to \mathcal{H}$. The pullback theorem shows that if the kernel feature map is injective (equivalently, the kernel is universal), then functions in $\mathcal{H}$ composed with $\varphi$ can approximate all continuous functions on $X$.

### 4.4 Compositional Model Design

The density transfer theorem provides a modular framework for compositional model design:

1. Establish density of a base function class $A$ on a simple domain $Y$.
2. Design feature maps $\varphi_i : X \to Y$ for different aspects of the input.
3. Combine pullbacks to cover all of $C(X, \mathbb{R})$.

This mirrors practical architectures where different "heads" or "branches" of a neural network process different aspects of the input.

## 5. Discussion: A Scientific American Perspective

### The Art of Approximation

Imagine you're a portrait artist, but you can only use a specific set of brushstrokes — say, smooth exponential curves. Can you still paint any picture? The Stone–Weierstrass theorem says: *yes, as long as your brushstrokes can distinguish between any two points on the canvas*.

This is a profound mathematical insight. It doesn't matter what specific shapes your brushstrokes take — they could be exponentials, polynomials, wavelets, or any other family. What matters is a single, elegant property: *point separation*. If for any two distinct points, some brushstroke looks different at those points, then you can combine finitely many brushstrokes to approximate any continuous picture to any desired accuracy.

### From Algebra to Approximation

The key conceptual leap is from *algebraic closure* to *analytic density*. An algebra of functions is closed under addition, multiplication, and scalar multiplication — you can add, multiply, and scale your brushstrokes to create new ones. The Stone–Weierstrass theorem says this algebraic structure, combined with point separation, automatically gives you analytic power: uniform approximation.

This is remarkable because algebra (combining things) and analysis (taking limits) are very different mathematical operations. The theorem builds a bridge between them.

### The Pullback Principle

Our second main contribution — the pullback density theorem — addresses a question that arises naturally in modern machine learning: *if I know how to approximate functions in one space, can I transfer that ability to another space?*

Think of it this way. Suppose you're an expert painter of landscapes on a flat canvas. Now someone asks you to paint on a curved surface — say, a sphere. If you can "unroll" the sphere onto your flat canvas (using a continuous map), then your flat-canvas skills transfer to the curved surface. The pullback theorem makes this precise: density transfers through continuous maps, and when the map is injective (no information is lost in the unrolling), you get full approximation power.

In machine learning terms, the "flat canvas" is a feature space $Y$, and the "curved surface" is the input space $X$. The "unrolling" is the feature map $\varphi : X \to Y$. The theorem says: if your model class is universal on the feature space and your feature map doesn't collapse distinct inputs, then your model is universal on the input space.

### Why Formal Verification?

These theorems have been "known" in various informal forms for decades. So why formalize them? Three reasons:

1. **Precision**: Mathematical papers often gloss over technical hypotheses. Our formal proof makes every assumption explicit — compact Hausdorff domain, real-valued functions, subalgebra structure, point separation. This is especially important for the pullback theorem, where the closedness of the factors-through subalgebra is a non-trivial fact that's easy to overlook informally.

2. **Composability**: Formal proofs compose reliably. Our pullback theorem can be instantiated with specific EML generators, specific feature maps, and specific domains, with Lean's type system ensuring all hypotheses are satisfied.

3. **Trust**: In an era where AI systems make consequential decisions, having machine-verified guarantees about their approximation capabilities provides a level of assurance that informal arguments cannot.

### Historical Context

The Stone–Weierstrass theorem has a distinguished pedigree. Weierstrass proved in 1885 that polynomials are dense in continuous functions on $[a,b]$. Stone generalized this vastly in 1937-1948, replacing polynomials with arbitrary point-separating subalgebras and $[a,b]$ with arbitrary compact Hausdorff spaces. This generalization was crucial for functional analysis and has found applications far beyond its original setting — including, as we show here, in the foundations of machine learning.

The Tietze extension theorem (1915), which we use for the injective pullback result, is another classical gem. It says that continuous real-valued functions on closed subsets of normal spaces can be extended to the whole space. In our context, it bridges the gap between "the feature map is injective" and "every function factors through the feature map."

## 6. Future Directions

1. **Quantitative approximation rates**: Our theorems are existential — they guarantee approximation within $\varepsilon$ but say nothing about how many generators are needed. Quantitative versions would connect to the computational complexity of approximation.

2. **Non-compact domains**: Many practical settings involve non-compact domains (e.g., all of $\mathbb{R}^n$). Extending the framework to weighted function spaces or locally compact spaces would broaden applicability.

3. **Lattice Stone–Weierstrass**: The lattice version of Stone–Weierstrass (replacing the subalgebra condition with closure under max and min) may be more natural for ReLU-based architectures. Formalizing this variant could unify more of the universal approximation landscape.

4. **Constructive approximation**: Converting existence proofs into algorithms that compute the approximating functions would bridge the gap between theory and practice.

## 7. Conclusion

We have established a formally verified universal approximation framework for EML-generated subalgebras, bridging the gap between algebraic closure properties and functional-analytic density. The three main theorems — Stone–Weierstrass density, pullback transfer, and injective pullback — provide a clean, modular theory that applies to any point-separating subalgebra on any compact Hausdorff space.

The formalization in Lean 4 ensures that every step is machine-checkable, every hypothesis is explicit, and the results compose reliably with the existing EML infrastructure. This represents the conceptual endpoint of the EML approximation program: from syntax (EML generators) through algebra (subalgebra closure) to analysis (uniform density).

## References

- Cybenko, G. (1989). Approximation by superpositions of a sigmoidal function. *Mathematics of Control, Signals, and Systems*, 2(4), 303-314.
- Hornik, K., Stinchcombe, M., & White, H. (1989). Multilayer feedforward networks are universal approximators. *Neural Networks*, 2(5), 359-366.
- Stone, M. H. (1948). The generalized Weierstrass approximation theorem. *Mathematics Magazine*, 21(4/5), 167-184, 237-254.
- Tietze, H. (1915). Über Funktionen, die auf einer abgeschlossenen Menge stetig sind. *Journal für die reine und angewandte Mathematik*, 145, 9-14.
- Weierstrass, K. (1885). Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen. *Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften zu Berlin*, 633-639, 789-805.
