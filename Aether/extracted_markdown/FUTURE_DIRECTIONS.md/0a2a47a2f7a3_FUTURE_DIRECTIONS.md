# FUTURE DIRECTIONS — Tropical Idempotent Algebra

## Synthesis

This cycle established foundational structural theorems for tropical (min-plus) algebra
in Lean 4, proving 10 theorems (9 fully, 1 as conjecture). The core results formalize
the idempotent nature of tropical addition, the ultrametric transitivity property, the
equality of tropical determinant and permanent for 2×2 matrices, and the tropical
Bellman absorption law. These are the first formalized proofs connecting tropical
algebra to optimization (Bellman equation) and computational complexity (permanent = determinant)
in this project.

The main failure was `relu_preserves_cpl` — showing that ReLU activation preserves the
continuous piecewise-linear (CPL) property. The mathematical argument is clear (the zero
set of a CPL function is finite, so we add finitely many breakpoints), but formalizing
the finiteness of the zero set requires decomposing the real line into intervals and
arguing about each affine piece — a significant infrastructure investment. The base case
`max_affine_zero_is_cpl` (max of a single affine function with 0 is CPL) was successfully
proved, confirming the approach is correct at the foundational level.

The structural insight that emerged is that **tropical algebra naturally lives at the
intersection of optimization, combinatorics, and geometry**. The absorption law
`a * b + b = b` (which holds unconditionally over `Tropical (WithTop ℕ)`) encodes
the Bellman optimality principle in pure algebraic form. The det=perm equality
captures why tropical linear algebra is tractable while classical permanent computation
is #P-hard.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `tropical_add_idempotent` | **proved** | Fundamental: `a ⊕ a = a`, the defining property of idempotent semirings |
| `tropical_ultrametric_order` | **proved** | Algebraic ultrametric inequality: transitivity of tropical absorption |
| `tropical_sum_le_term` | **proved** | Tropical finset sum ≤ any term (min of a set ≤ any element) |
| `tropical_det_eq_perm_2x2` | **proved** | Det = Perm in tropical algebra: signs vanish in idempotent semirings |
| `tropical_bellman_fixed_point` | **proved** | Bellman equation fixed point: `a * b + b = b` when `1 ≤ a` |
| `tropical_absorption` | **proved** | Unconditional absorption: `a * b + b = b` for all `a, b` over `WithTop ℕ` |
| `affine_is_cpl` | **proved** | Affine functions are CPL (base case) |
| `max_affine_zero_is_cpl` | **proved** | max(affine, 0) is CPL: key base case for ReLU |
| `add_preserves_cpl` | **proved** | Sum of CPL functions is CPL |
| `sub_preserves_cpl` | **proved** | Difference of CPL functions is CPL |
| `relu_preserves_cpl` | **conjecture** | ReLU preserves CPL: needs finiteness of zero set |
| `univReluNet_is_cpl'` | **proved_with_lemma_sorry** | Every ReLU network computes CPL: depends on relu_preserves_cpl |

## Research Directions

### Direction 1: Tropical Det = Perm for n×n matrices

**Hypothesis**: For all n, the tropical determinant (min over signed permutations with
tropical products) equals the tropical permanent (min over all permutations) for n×n
matrices over any idempotent tropical semiring.

**Test**: State and prove the n=3 case explicitly, then generalize using `Equiv.Perm.sign`
and the fact that in an idempotent semiring, multiplying by the sign is trivial.

**Why now**: The 2×2 case was proved as `rfl` (both formulas are syntactically identical).
The key insight is that in the tropical sum `⊕_σ (∏_i A_{i,σ(i)})`, the sign `(-1)^σ`
becomes tropical multiplication by `trop(sign σ)`, but since `trop 0 = 1` and tropical
addition is min, the sign has no effect. The n×n generalization requires showing that
`Finset.sum` over `Equiv.Perm (Fin n)` in the tropical semiring ignores signs.

**If true**: Completes the bridge between tropical linear algebra and combinatorial
optimization (the assignment problem = tropical permanent computation is O(n³)).

**If false**: Would reveal that the tropical semiring structure interacts with permutation
signs in unexpected ways, which would be mathematically surprising.

### Direction 2: Finiteness of CPL zero sets

**Hypothesis**: For any continuous piecewise-linear function `f : ℝ → ℝ` with breakpoint
set `S`, the set `{x ∉ S : f(x) = 0 ∧ f is not identically zero near x}` is finite,
with cardinality at most `|S| + 1`.

**Test**: Prove this by sorting the elements of `S`, showing that on each interval
`(sᵢ, sᵢ₊₁)` the function `f` is affine with at most one zero (when slope ≠ 0).

**Why now**: This is the exact missing piece for `relu_preserves_cpl`. The base case
`max_affine_zero_is_cpl` is proved, confirming that the local analysis works. The key
insight is that the global finiteness follows from the local structure: a CPL function
has `|S| + 1` affine pieces, each contributing at most one zero. This requires
formalizing the interval decomposition of `ℝ \ S` using `Finset.sort`.

**If true**: Immediately gives `relu_preserves_cpl`, which gives `univReluNet_is_cpl'`,
completing the bridge from neural networks to tropical rational forms.

**If false**: Would mean CPL functions can have infinitely many isolated zeros, which
is geometrically impossible — this direction is expected to succeed.

### Direction 3: Tropical Kleene star convergence (Bellman-Ford)

**Hypothesis**: For an n×n tropical matrix `A` (over `Tropical (WithTop ℕ)`) with no
negative cycles (which is automatic since weights are in `ℕ`), the Kleene star
`A* = I ⊕ A ⊕ A² ⊕ ... ⊕ Aⁿ⁻¹` stabilizes: `A* = I ⊕ A ⊕ ... ⊕ Aⁿ⁻¹`.
Equivalently, `Aⁿ` does not improve the shortest path distances.

**Test**: Prove for n=2 (2×2 matrices) that `I + A + A² = I + A`, using the
absorption law `a * b + b = b` proved in this cycle. Then generalize.

**Why now**: The absorption law `a * b + b = b` is the scalar version of this result.
The key insight is that the matrix version follows from the same algebraic identity
applied entry-wise, combined with the fact that shortest paths of length ≥ n must
revisit a vertex (pigeonhole), creating a cycle that can be removed. The n=2 case
is tractable because the matrix algebra reduces to explicit 2×2 computations.

**If true**: Gives a fully formalized correctness proof for the Bellman-Ford algorithm
in tropical algebraic language — connecting abstract algebra to concrete algorithms.

**If false**: Would indicate a subtle issue with the matrix power stabilization in the
presence of ⊤ (infinity) entries, requiring more careful treatment of zero divisors.

### Direction 4: Tropical convexity and max-plus geometry

**Hypothesis**: A set `C ⊆ (Tropical (WithTop ℕ))ⁿ` is tropically convex iff for all
`x, y ∈ C` and `λ, μ : Tropical (WithTop ℕ)` with `λ + μ = trop 0`, we have
`λ * x ⊕ μ * y ∈ C` (where operations are component-wise). The tropical convex hull
of a finite set is a tropical polytope.

**Test**: Define tropical convexity and prove basic closure properties (intersection of
tropically convex sets is tropically convex). Then show that the tropical segment
between two points is tropically convex.

**Why now**: The ultrametric transitivity theorem proved in this cycle is the
one-dimensional case of tropical convexity. The key insight is that tropical convex
combinations `min(λ + x, μ + y)` generalize to higher dimensions component-wise,
and the ultrametric property ensures that tropical balls are convex.

**If true**: Opens up formalization of tropical polytope theory, connecting to the
theory of tropical Grassmannians and moduli spaces already explored in other files
of this project.

**If false**: Would indicate that the naive component-wise definition of tropical
convexity doesn't capture the right geometric notion, requiring a more sophisticated
definition (e.g., using tropical halfspaces).

### Direction 5: Tropical-to-classical deformation (Maslov dequantization)

**Hypothesis**: For a family of classical semirings `(ℝ₊, +_h, ×_h)` parameterized by
`h > 0`, where `a +_h b = (aʰ + bʰ)^(1/h)` and `a ×_h b = a · b`, the limit as
`h → 0⁺` recovers the tropical semiring `(ℝ₊, min, +)`.

**Test**: Formalize the statement for finite sums: `lim_{h→0} (Σᵢ xᵢʰ)^(1/h) = min xᵢ`.
This is the "log-sum-exp → min" identity, widely used in machine learning (softmin).

**Why now**: The tropical absorption law and idempotency proved in this cycle are the
`h = 0` limits of the classical identities. The key insight is that `(x^h + y^h)^(1/h) → min(x, y)`
as `h → 0+` for `x, y > 0`, which can be proved using L'Hôpital's rule or direct
epsilon-delta analysis. This connects the formalized tropical algebra to the
thermodynamic/physics bridge described in the project concept.

**If true**: Provides a rigorous formalization of the Maslov dequantization principle,
connecting tropical algebra to statistical mechanics and deep learning (softmax → hardmax).

**If false**: Would indicate that the limiting process requires more care with
boundary cases (e.g., when some `xᵢ = 0` or `xᵢ = ∞`).
