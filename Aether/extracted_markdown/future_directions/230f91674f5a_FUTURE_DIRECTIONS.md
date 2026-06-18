# Future Directions: Tropical Convex Duality Toolkit

## Overview

The quadratic Legendre duality package establishes the first formally verified bridge between classical convex conjugation and tropical (min-plus) algebra. This document outlines five concrete next-step research directions, each with precise theorem targets, proof strategies, and cross-domain significance.

---

## 1. Legendre Duality for Shifted Quadratics

### Statement
For a > 0, b ∈ ℝ, c ∈ ℝ, the convex conjugate of f(x) = a(x − b)²/2 + c is:

$$f^\star(y) = \frac{y^2}{2a} + by - c$$

with biconjugation f★★ = f.

### Lean Encoding
```lean
theorem legendre_shifted_quadratic (a b c y : ℝ) (ha : 0 < a) :
    legendreTransform (fun x => a * (x - b)^2 / 2 + c) y =
    y^2 / (2 * a) + b * y - c := by sorry
```

### Proof Strategy
1. Complete the square: x·y − a(x−b)²/2 − c = y²/(2a) + by − c − a(x − (y/a + b))²/2
2. The supremum is attained at x = y/a + b
3. Upper bound from nonnegativity of squares; attainment gives the exact value

### Cross-Domain Significance
- **Optimal transport with non-unit variance**: the cost c(x,y) = a|x−y|²/2 appears in regularized transport
- **Gaussian families**: the rate function for N(b, 1/a) distributions
- **Parametric optimization**: sensitivity analysis under quadratic perturbations

### Difficulty: ★★☆☆☆

---

## 2. Finite-Support Tropical Legendre Transform

### Statement
For a finite set S = {x₁, ..., xₙ} ⊂ ℝ with weights w : S → ℝ, define the finite tropical Legendre transform:

$$F(y) = \max_{i=1}^n (x_i y - w(x_i))$$

Then F is piecewise linear and convex, and is the supremum of n affine functions.

### Lean Encoding
```lean
def finiteLegendre (s : Finset ℝ) (w : ℝ → ℝ) (y : ℝ) : ℝ :=
  s.sup' hs (fun x => x * y - w x)

theorem finiteLegendre_convex (s : Finset ℝ) (w : ℝ → ℝ)
    (hs : s.Nonempty) :
    ConvexOn ℝ Set.univ (finiteLegendre s w hs) := by sorry

theorem finiteLegendre_piecewise_linear (s : Finset ℝ) (w : ℝ → ℝ)
    (hs : s.Nonempty) (y₁ y₂ : ℝ) (t : ℝ) (ht₀ : 0 ≤ t) (ht₁ : t ≤ 1) :
    finiteLegendre s w hs (t * y₁ + (1 - t) * y₂) ≤
    t * finiteLegendre s w hs y₁ + (1 - t) * finiteLegendre s w hs y₂ := by sorry
```

### Proof Strategy
1. Each function x ↦ x·y − w(x) is affine in y
2. The supremum of affine functions is convex (standard Mathlib result)
3. For finitely many affines, the sup is piecewise linear
4. The breakpoints occur where two affine functions cross

### Cross-Domain Significance
- **Tropical polyhedral geometry**: finite Legendre transforms are tropical polytopes
- **ReLU neural networks**: max of affines = single-hidden-layer ReLU network
- **Computational geometry**: upper envelope of line arrangements
- **Auction theory**: the max-of-bids function in combinatorial auctions

### Difficulty: ★★★☆☆

---

## 3. Tropical Inf-Convolution Theorem

### Statement
The inf-convolution of f and g is defined by:

$$(f \square g)(x) = \inf_y [f(y) + g(x - y)]$$

The Legendre transform converts inf-convolution to pointwise addition:

$$(f \square g)^\star = f^\star + g^\star$$

For the quadratic case: (x²/2 □ x²/2)★ = x² (sum of two half-squares).

### Lean Encoding
```lean
def infConvolution (f g : ℝ → ℝ) (x : ℝ) : ℝ :=
  sInf (Set.range fun y : ℝ => f y + g (x - y))

theorem legendre_inf_conv_add (f g : ℝ → ℝ)
    (hf : ∀ y, legendreTransform f y = f y)  -- self-dual
    (hg : ∀ y, legendreTransform g y = g y)  -- self-dual
    (y : ℝ) :
    legendreTransform (infConvolution f g) y =
    legendreTransform f y + legendreTransform g y := by sorry

-- Concrete quadratic case:
theorem inf_conv_half_sq (x : ℝ) :
    infConvolution (fun x => x^2 / 2) (fun x => x^2 / 2) x = x^2 / 4 := by sorry
```

### Proof Strategy
1. For the concrete quadratic case: minimize y²/2 + (x−y)²/2 over y
2. Complete the square in y: this gives minimum at y = x/2 with value x²/4
3. For the abstract case: exchange sup and inf using minimax-type arguments
4. The formal proof may require Fenchel–Moreau regularity conditions

### Cross-Domain Significance
- **Regularization**: inf-convolution = Moreau envelope = proximal smoothing
- **Probability**: convolution of distributions in the tropical limit
- **Signal processing**: tropical deconvolution
- **Stochastic control**: Bellman equation as tropical inf-convolution

### Difficulty: ★★★★☆

---

## 4. Weak-to-Strong Duality Bridge with Kantorovich

### Statement
For the one-dimensional quadratic cost transport problem between point masses δ_a and δ_b:

**Primal**: W₂²(δ_a, δ_b) = (a − b)²/2

**Dual**: sup{φ(a) + ψ(b) | φ(x) + ψ(y) ≤ |x−y|²/2} = (a − b)²/2

Strong duality holds: primal = dual.

### Lean Encoding
```lean
theorem kantorovich_strong_duality_points (a b : ℝ) :
    (a - b)^2 / 2 =
    sSup (Set.range fun φψ : (ℝ → ℝ) × (ℝ → ℝ) =>
      if ∀ x y, φψ.1 x + φψ.2 y ≤ (x - y)^2 / 2
      then φψ.1 a + φψ.2 b
      else 0) := by sorry

-- Easier version: verify the optimal dual potentials
theorem kantorovich_optimal_potentials (a b x y : ℝ) :
    (x^2 / 2 - a * x + a^2 / 2) + (y^2 / 2 - b * y + b^2 / 2) ≤
    (x - y)^2 / 2 + (a - b)^2 / 2 := by sorry

-- At the optimal points:
theorem kantorovich_strong_at_points (a b : ℝ) :
    (a^2 / 2 - a * a + a^2 / 2) + (b^2 / 2 - b * b + b^2 / 2) = 0 := by sorry
```

### Proof Strategy
1. The dual potentials φ(x) = x²/2 − a·x, ψ(y) = y²/2 − b·y are feasible by Fenchel–Young
2. They achieve value φ(a) + ψ(b) = −a²/2 − b²/2
3. The primal value (a−b)²/2 = a²/2 − ab + b²/2
4. Strong duality follows from the attainment of equality in Fenchel–Young at x = y

### Cross-Domain Significance
- **Optimal transport**: exact solution for point masses
- **Wasserstein distance**: connects to the W₂ metric on probability measures
- **Generative models**: Wasserstein GANs use this dual formulation
- **Economic theory**: competitive equilibrium as transport duality

### Difficulty: ★★★☆☆

---

## 5. Hopf–Lax Tropical Semigroup

### Statement
Define the Hopf–Lax operator for the quadratic cost:

$$(Q_t u)(x) = \inf_y \left[ u(y) + \frac{(x-y)^2}{2t} \right]$$

Then:
1. **Semigroup property**: Q_s ∘ Q_t = Q_{s+t}
2. **Monotonicity**: u ≤ v implies Q_t u ≤ Q_t v
3. **Contraction**: |Q_t u(x) − Q_t v(x)| ≤ sup|u − v|
4. **Initial condition**: Q_t u → u as t → 0⁺

### Lean Encoding
```lean
noncomputable def hopfLax (u : ℝ → ℝ) (t : ℝ) (x : ℝ) : ℝ :=
  sInf (Set.range fun y : ℝ => u y + (x - y)^2 / (2 * t))

-- Monotonicity
theorem hopfLax_mono (u v : ℝ → ℝ) (t : ℝ) (ht : 0 < t)
    (h : ∀ x, u x ≤ v x) (x : ℝ) :
    hopfLax u t x ≤ hopfLax v t x := by sorry

-- Contraction
theorem hopfLax_contraction (u v : ℝ → ℝ) (t : ℝ) (ht : 0 < t)
    (C : ℝ) (hC : ∀ x, |u x - v x| ≤ C) (x : ℝ) :
    |hopfLax u t x - hopfLax v t x| ≤ C := by sorry

-- Semigroup (for quadratic initial data)
theorem hopfLax_semigroup_quadratic (s t : ℝ) (hs : 0 < s) (ht : 0 < t) (x : ℝ) :
    hopfLax (hopfLax (fun y => y^2 / 2) t) s x =
    hopfLax (fun y => y^2 / 2) (s + t) x := by sorry
```

### Proof Strategy
1. **Monotonicity**: u(y) ≤ v(y) for all y implies each term in the infimum is larger
2. **Contraction**: bound the difference of infima by the supremum of differences
3. **Semigroup**: for quadratic data, compute explicitly:
   - Q_t(x²/2) = x²/(2(1+t)) by completing the square
   - Q_s(Q_t(x²/2)) = x²/(2(1+s+t))
   - Q_{s+t}(x²/2) = x²/(2(1+s+t))

### Cross-Domain Significance
- **Viscosity solutions**: the Hopf–Lax formula gives the unique viscosity solution
- **Dynamic programming**: Q_t is the dynamic programming operator for optimal control
- **Tropical convolution**: Q_t is inf-convolution with the quadratic cost kernel
- **Image processing**: morphological operators are tropical semigroups

### Difficulty: ★★★★★

---

## Research Roadmap

### Phase 1 (Near-term): Generalize the Quadratic
- Direction 1 (shifted quadratics) — extends the existing algebraic engine
- Fenchel–Young for general p-norms (Young's inequality)

### Phase 2 (Medium-term): Finite Tropical Structures
- Direction 2 (finite support) — connects to polyhedral geometry and neural networks
- Tropical polyhedra and Newton polytopes

### Phase 3 (Long-term): Infinite-Dimensional Duality
- Direction 3 (inf-convolution) — enters abstract convex analysis
- Direction 4 (Kantorovich) — connects to measure theory
- Direction 5 (Hopf–Lax) — enters PDE theory

### Cross-Cutting Theme
Every direction should maintain the dual perspective: each theorem should have both a classical (sup/convex) and a tropical (inf/min-plus) formulation, connected by the min-max bridge theorem.

---

## Team Directive

Create a team to pursue these directions with the following workflow:
1. **Formulate hypotheses**: State precise theorems with Lean type signatures
2. **Validate computationally**: Test with Python numerical experiments
3. **Build proof skeletons**: Write Lean files with sorry'd lemmas
4. **Prove bottom-up**: Start with algebraic identities, build to supremum/infimum results
5. **Cross-validate**: Ensure classical and tropical formulations are equivalent
6. **Document**: Update the knowledge base with each proven theorem
7. **Iterate**: Each proved theorem suggests the next target
