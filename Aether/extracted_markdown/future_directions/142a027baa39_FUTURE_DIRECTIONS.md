# FUTURE_DIRECTIONS.md

## Synthesis

This cycle established a bridge between Pythagorean triple theory and gradient descent convergence analysis through 8 fully proved theorems (0 sorries). The Pythagorean section proved the parametric triple generation formula over ℕ, parity obstruction, and hypotenuse strictness. The NTK convergence section formalized the contraction mapping iteration bound — the core engine behind gradient descent convergence on strongly convex functions — both in ℝ and in arbitrary metric spaces. The kernel PSD section proved sum-of-squares nonnegativity and finite-dimensional Cauchy-Schwarz, which are foundational for NTK Gram matrix analysis.

The key structural insight is that the contraction bound `|G^n(x₀) - x*| ≤ κⁿ|x₀ - x*|` does NOT require κ < 1 — only κ ≥ 0. The condition κ < 1 is needed separately for convergence (geometric_convergence_to_zero). This decomposition is cleaner than the typical textbook presentation and gives a more general intermediate result.

The generalization from ℝ to MetricSpace was proved with an identical inductive argument, confirming that the proof structure is purely metric and contains no ℝ-specific reasoning. This validates the approach of proving in ℝ first, then lifting.

## Results Summary

- `pythagorean_triple_parametric`: **proved** — Forward direction of classical parametrization (m²-n², 2mn, m²+n²) over ℕ
- `pythagorean_triple_no_all_odd`: **proved** — Parity obstruction: both legs odd forces hypotenuse even
- `pythagorean_hypotenuse_strict`: **proved** — Hypotenuse strictly exceeds each positive leg
- `gradient_descent_contraction_bound`: **proved** — Contraction iteration bound |G^n x₀ - x*| ≤ κⁿ|x₀ - x*| in ℝ
- `geometric_convergence_to_zero`: **proved** — Geometric decay κⁿC → 0 for 0 ≤ κ < 1
- `sum_sq_nonneg`: **proved** — Σ fᵢ² ≥ 0, building block for PSD kernel theory
- `inner_product_cauchy_schwarz`: **proved** — (Σ fᵢgᵢ)² ≤ (Σ fᵢ²)(Σ gᵢ²), NTK kernel bound foundation
- `contraction_bound_generalized`: **proved** — Full metric space generalization of the contraction bound

## Research Directions

### Direction 1: Banach Fixed-Point Theorem (Existence + Uniqueness)
**Hypothesis**: For a κ-contraction G with κ < 1 on a complete metric space, there exists a unique fixed point x*, and G^n(x₀) → x* for any x₀.
**Test**: Formalize in Lean 4 using Mathlib's `CompleteSpace` and `CauchySeq`. The contraction bound (already proved) gives the convergence rate; the missing piece is existence via Cauchy completeness and uniqueness by contradiction.
**Why now**: The contraction iteration bound `contraction_bound_generalized` is already proved. The key insight is that {G^n(x₀)} is Cauchy because d(G^m x₀, G^n x₀) ≤ κⁿ/(1-κ) · d(x₀, G x₀), which is a geometric series tail. Completeness gives the limit.
**If true**: Completes the NTK convergence theory — gradient descent not only contracts but provably reaches the optimum.
**If false**: Would indicate a formalization gap in Mathlib's metric space API.

### Direction 2: NTK Gram Matrix Minimum Eigenvalue Bound
**Hypothesis**: For an NTK kernel K(x,y) = ⟨φ(x), φ(y)⟩ with φ: ℝᵈ → ℝᵐ, if the feature vectors {φ(xᵢ)} are linearly independent, then the Gram matrix Kᵢⱼ = K(xᵢ, xⱼ) has λ_min > 0.
**Test**: Formalize using Mathlib's `Matrix.PosSemidef` and `Matrix.IsHermitian`. Show that the Gram matrix G = Φᵀ Φ is PSD (using inner_product_cauchy_schwarz as a building block) and that linear independence of rows of Φ gives positive definiteness.
**Why now**: The Cauchy-Schwarz inequality bounds off-diagonal entries K(xᵢ,xⱼ)² ≤ K(xᵢ,xᵢ)K(xⱼ,xⱼ). The key insight is that diagonal dominance plus PSD gives a computable lower bound on λ_min via Gershgorin circles.
**If true**: Gives the missing ingredient for NTK convergence: the step size η = 1/L where L depends on λ_min.
**If false**: Would mean the NTK convergence guarantee requires stronger assumptions than linear independence.

### Direction 3: Pythagorean Triple Reverse Parametrization
**Hypothesis**: Every primitive Pythagorean triple (a, b, c) with a odd, b even, gcd(a,b)=1 has the form a = m²-n², b = 2mn, c = m²+n² for unique m > n > 0 with gcd(m,n)=1 and m-n odd.
**Test**: Prove the reverse direction in Lean 4. The forward direction (pythagorean_triple_parametric) is already done. The reverse requires showing that c-a and c+a are perfect squares.
**Why now**: The forward parametrization is proved. The key insight is that a²+b²=c² with a odd implies c-a and c+a are both even, and (c-a)/2 · (c+a)/2 = (b/2)², and coprimality forces both factors to be perfect squares.
**If true**: Completes the classical characterization of Pythagorean triples.
**If false**: N/A — this is a classical result; failure would indicate formalization difficulty, not mathematical falsity.

### Direction 4: Multi-Dimensional Gradient Descent (ℝⁿ → ℝ)
**Hypothesis**: For f: ℝⁿ → ℝ that is L-smooth and μ-strongly convex, gradient descent xₖ₊₁ = xₖ - (1/L)∇f(xₖ) satisfies ‖xₖ - x*‖ ≤ (1-μ/L)ᵏ ‖x₀ - x*‖.
**Test**: Formalize using `EuclideanSpace ℝ (Fin n)` with the Fréchet derivative. The 1D version is already proved; the multi-dimensional version requires replacing |·| with ‖·‖ and scalar multiplication with matrix operations.
**Why now**: The contraction_bound_generalized already works for arbitrary metric spaces. The key insight is that the gradient descent map G(x) = x - (1/L)∇f(x) is a κ-contraction with κ = 1-μ/L when f is L-smooth and μ-strongly convex, so the general contraction bound applies directly.
**If true**: Gives a complete formalization of the standard gradient descent convergence theorem used in deep learning theory.
**If false**: Would indicate that Mathlib's calculus API lacks sufficient infrastructure for optimization theory.

### Direction 5: Pythagorean-NTK Spectral Connection
**Hypothesis**: The Berggren tree matrices {A, B, C} generating all primitive Pythagorean triples have spectral radius 1 in the Lorentzian metric, and this spectral property is analogous to the NTK kernel's eigenvalue structure controlling convergence.
**Test**: Compute the eigenvalues of the 3×3 Berggren matrices in the indefinite inner product ⟨x,y⟩_L = x₁y₁ + x₂y₂ - x₃y₃ and show they preserve the Lorentzian norm. Compare the resulting spectral structure with the NTK Gram matrix eigenvalue bounds.
**Why now**: Both the Pythagorean parametrization and NTK contraction bounds are proved. The key insight is that Berggren matrices are O(2,1) isometries (Lorentzian orthogonal group), and the NTK Gram matrix is PSD in the Euclidean metric — the bridge is that both structures are governed by spectral radius conditions, one preserving an indefinite form and the other a definite one.
**If true**: Establishes a novel cross-domain bridge between number-theoretic tree generation and neural network optimization.
**If false**: Would demonstrate that the Lorentzian and Euclidean spectral structures are fundamentally incompatible, which is itself an interesting structural insight.
