# Future Directions: Approximate Adjunctions Between Theories

## Overview

The approximate adjunction framework establishes a compositional calculus for quantitative lower-bound transfer between theories. The following directions represent concrete next steps at breakthrough level, each with specific theorem targets and proof strategies.

---

## Direction 1: Approximate Closure/Interior Operators and Fixed-Point Theory

### Hypothesis
The round-trip compositions $g \circ f : A \to A$ and $f \circ g : B \to B$ from an approximate adjunction induce bounded closure/interior operators. Their fixed points characterize the "stable" objects under the adjunction, and iterating these operators converges to a bounded neighborhood of the fixed-point set.

### Specific Theorem Targets

```
theorem closure_idempotent_approx (h : TheoryAdj A B) (a : A.Obj) :
    |v_A(g(f(g(f(a))))) - v_A(g(f(a)))| ≤ left_loss + right_loss

theorem closure_fixed_point_characterization (h : TheoryAdj A B) :
    ∀ a, v_A(g(f(a))) = v_A(a) ↔ (left_loss = 0 ∧ right_loss = 0) ∨ [specific condition]

theorem closure_iteration_convergence (h : TheoryAdj A B) (a : A.Obj) (n : ℕ) :
    v_A((g ∘ f)^n(a)) ≤ v_A(a) + n * (left_loss + right_loss)
```

### Proof Strategy
Use the round-trip inequality `v_A(g(f(a))) ≤ v_A(a) + ℓ + r` iteratively. The key insight is that the operator $g \circ f$ inflates values by at most $\ell + r$ per application, so $n$ applications inflate by at most $n(\ell + r)$. For exact adjunctions, $g \circ f$ is non-expanding and its orbit is bounded.

### Cross-Domain Connections
- **Abstract interpretation**: Closure operators in Galois connections define sound abstractions; the approximate version defines abstractions with bounded precision loss.
- **Dynamical systems**: Iteration of approximate closure operators is a discrete dynamical system with controlled Lyapunov function.

---

## Direction 2: Multiplicative and Affine Distortion Adjunctions

### Hypothesis
Many complexity-theoretic simulations have multiplicative overhead: $v_B(\text{sim}(a)) \leq K \cdot v_A(a)$. Generalizing the framework to affine distortion $v_B(f(a)) \leq K \cdot v_A(a) + C$ recovers sharper transfer theorems and multiplicative composition laws.

### Specific Theorem Targets

```
structure AffineTheoryAdj (A B : TheorySpec) where
    left : A.Obj → B.Obj
    right : B.Obj → A.Obj
    left_mult : ℤ        -- multiplicative factor
    left_add : ℤ          -- additive constant
    right_mult : ℤ
    right_add : ℤ
    left_bound : ∀ a, v_B(left(a)) ≤ left_mult * v_A(a) + left_add
    right_bound : ∀ b, v_A(right(b)) ≤ right_mult * v_B(b) + right_add

theorem AffineTheoryAdj.comp :
    -- composed multiplicative factors multiply, additive constants compose affinely
    (left_mult₁ * left_mult₂, left_mult₂ * left_add₁ + left_add₂, ...)

theorem AffineTheoryAdj.transfer (L : ℤ) (hL : ∀ a, L ≤ v_A(a)) :
    ∀ b, (L - right_add) / right_mult ≤ v_B(b)  -- approximate
```

### Proof Strategy
The composition of affine maps $x \mapsto K_2(K_1 x + C_1) + C_2 = K_1 K_2 x + K_2 C_1 + C_2$ gives the affine composition law. Transfer with multiplicative overhead yields $L \leq K \cdot v_B(b) + C$, so $v_B(b) \geq (L-C)/K$.

### Cross-Domain Connections
- **Legendre-Fenchel duality**: The conjugate transform satisfies affine bounds, so Legendre duality becomes an affine adjunction.
- **Polynomial simulation**: Many simulation theorems have polynomial overhead, which is captured by the multiplicative factor.

---

## Direction 3: The Category of Theories Under Approximate Adjunction

### Hypothesis
Theories with approximate adjunctions form a preorder category (or enriched category over $(\mathbb{Z}^2, +)$). The structure of this category — its connected components, order-theoretic properties, and universal objects — encodes deep information about the landscape of computational complexity.

### Specific Theorem Targets

```
-- Theories form a preorder under adjunction
theorem adj_preorder :
    (TheoryAdj.id A).comp = id ∧ (h₁.comp h₂).comp h₃ = h₁.comp (h₂.comp h₃)

-- Equivalence classes under exact adjunction
def TheoryEquiv (A B : TheorySpec) := ∃ h : TheoryAdj A B, h.IsExact

theorem theoryEquiv_is_equivalence : Equivalence TheoryEquiv

-- Loss metric on theory space
def adj_distance (A B : TheorySpec) : ℤ∞ :=
    inf { h.left_loss + h.right_loss | h : TheoryAdj A B }

theorem adj_distance_triangle :
    adj_distance A C ≤ adj_distance A B + adj_distance B C
```

### Proof Strategy
The identity adjunction and composition give the category structure. The loss function defines a generalized metric (potentially infinite, potentially non-symmetric). The triangle inequality follows directly from the composition theorem.

### Cross-Domain Connections
- **Complexity zoo**: The preorder category of theories under adjunction organizes the complexity zoo into a structured hierarchy.
- **Metric geometry**: The loss metric on theory space has connections to Gromov-Hausdorff distance between metric spaces.

---

## Direction 4: Tropical-Fourier Adjunction

### Hypothesis
The tropical Fourier transform (mapping functions to their tropical Fourier coefficients) and its inverse form an approximate adjunction. Coefficient bounds like `tropical_fourier_coeff_bound` are instances of the general transfer framework.

### Specific Theorem Targets

```
def TropicalFunctionTheory : TheorySpec where
    Obj := (Fin n → ℤ) → ℤ   -- tropical polynomials
    val := tropicalDegree

def TropicalCoefficientTheory : TheorySpec where
    Obj := Fin n → ℤ          -- coefficient vectors
    val := maxCoefficient

theorem tropical_fourier_adj :
    TheoryAdj TropicalFunctionTheory TropicalCoefficientTheory

theorem fourier_coeff_transfer (L : ℤ)
    (hL : ∀ f, tropicalDegree f ≥ L) :
    ∀ c, maxCoefficient c ≥ L - fourier_loss
```

### Proof Strategy
Use the explicit structure of tropical Fourier analysis. The forward map sends a function to its coefficient vector; the backward map reconstructs a function from coefficients. The loss is controlled by the sup-norm distance between the original and reconstructed functions.

### Cross-Domain Connections
- **Harmonic analysis**: Classical Fourier analysis satisfies Parseval's equality (exact adjunction); the tropical version introduces controlled loss.
- **Signal processing**: The framework quantifies how much spectral information survives tropical discretization.

---

## Direction 5: Abstract Interpretation of Complexity

### Hypothesis
Abstract interpretation frameworks (Cousot & Cousot 1977) use Galois connections between concrete and abstract domains. Extending to approximate adjunctions creates a theory of *bounded-precision abstract interpretation* where sound abstractions have quantifiable precision loss, and lower bounds on program behavior transfer between abstract and concrete domains.

### Specific Theorem Targets

```
-- Abstract domain preserves lower bounds with bounded loss
theorem abstract_preserves_lower_bounds
    (concrete abstract : TheorySpec)
    (h : TheoryAdj concrete abstract)
    (property_bound : ℤ)
    (h_concrete : ∀ p, property_bound ≤ concrete.val p) :
    ∀ a, property_bound - h.right_loss ≤ abstract.val a

-- Composing abstractions
theorem abstraction_chain
    (T₁ T₂ T₃ : TheorySpec)
    (h₁₂ : TheoryAdj T₁ T₂) (h₂₃ : TheoryAdj T₂ T₃) :
    TheoryAdj T₁ T₃  -- with additive loss

-- Precision-optimal abstraction
def optimal_abstraction (concrete : TheorySpec) (abstractions : List TheorySpec)
    (adjs : ∀ i, TheoryAdj concrete (abstractions.get i)) :
    -- find the abstraction with minimum right_loss
    Fin abstractions.length
```

### Proof Strategy
The key insight is that abstract interpretation's soundness theorem is a special case of the adjunction transfer theorem. The abstraction function $\alpha$ is the left map, the concretization function $\gamma$ is the right map, and the Galois connection condition ensures zero loss. Relaxing to approximate adjunctions allows for sound-but-imprecise abstractions.

### Cross-Domain Connections
- **Static analysis**: Precision of abstract interpreters becomes a formal metric via adjunction loss.
- **Verified compilation**: Compiler correctness proofs via simulation can be phrased as exact adjunctions.
- **Machine learning verification**: Neural network verification abstractions (intervals, zonotopes, polytopes) form approximate adjunctions with the concrete execution semantics.

---

## Research Program Summary

| Direction | Core Theorem | Difficulty | Impact |
|-----------|-------------|------------|--------|
| 1. Closure/Interior | Bounded iteration convergence | Medium | Foundational |
| 2. Affine Distortion | Multiplicative composition law | Medium | High (complexity) |
| 3. Theory Category | Triangle inequality, equivalence classes | Medium-Hard | Structural |
| 4. Tropical-Fourier | Explicit Fourier adjunction | Hard | Novel |
| 5. Abstract Interpretation | Precision-bounded soundness | Medium | Applied |

### Recommended Execution Order

1. **Direction 1** (closure operators) — extends the existing framework with minimal new definitions.
2. **Direction 2** (affine distortion) — immediately applicable to complexity theory.
3. **Direction 3** (category structure) — provides organizing framework for the rest.
4. **Direction 5** (abstract interpretation) — highest applied impact.
5. **Direction 4** (tropical-Fourier) — most technically challenging, highest novelty.

### Team Directive

Create a team to pursue these directions in parallel:
- **Team A (Foundations)**: Directions 1 and 3 — extend the formalized framework.
- **Team B (Applications)**: Directions 2 and 5 — connect to complexity theory and verification.
- **Team C (Deep Theory)**: Direction 4 — tropical-Fourier adjunction.

Each team should:
1. Formalize the key definitions in Lean 4.
2. State the main theorem targets with `sorry`.
3. Prove the theorems, starting from the simplest helper lemmas.
4. Test computational predictions with Python experiments.
5. Write up results for publication.

Iterate weekly, sharing cross-team insights about proof techniques and API design.
