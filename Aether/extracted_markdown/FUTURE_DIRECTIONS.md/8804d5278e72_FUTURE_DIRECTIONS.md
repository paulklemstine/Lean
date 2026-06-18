# Future Directions: Tropical Pruning Theory

## Breakthrough Research Opportunities

This document outlines five concrete research programs opened by the tropical polynomial pruning framework. Each direction is specific enough to pursue with clear hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Layer-Compositional Pruning for Deep ReLU Networks

### Hypothesis
Canonical pruning composes through tropical polynomial layers: if each layer is pruned independently while preserving its input-output map on the relevant intermediate domain, the composition of pruned layers preserves the end-to-end function.

### Theorem Target
```
theorem compositional_pruning_sound
  (D : Finset (Fin n → ℝ))
  (p₁ : TPoly n) (p₂ : TPoly n)
  (compose : TPoly n → TPoly n → TPoly n) :
  ∀ x ∈ D, compose (p₁.canonicalOn D) (p₂.canonicalOn (image_domain D p₁)) |>.eval x
    = compose p₁ p₂ |>.eval x
```

### Proof Strategy
1. Define the image domain of layer 1: D₁ = {p₁(x) | x ∈ D}.
2. Prune layer 1 on D and layer 2 on D₁.
3. Prove that composition preserves evaluation by chaining the single-layer preservation theorems.
4. The key challenge is formalizing tropical polynomial composition (which involves max of sums of maxes, reducible to a larger tropical polynomial).

### Cross-Domain Impact
- Enables certified pruning of multi-layer ReLU architectures
- Connects to tropical rational functions (quotients of tropical polynomials)
- Opens path to architecture-aware compression where different layers are pruned to different levels

### Difficulty: High
Main obstacles: formalizing the tropical composition operation, tracking intermediate domains, handling the explosion of monomials in composed polynomials.

---

## Direction 2: Polytope-Domain Extremal Reduction

### Hypothesis
For affine templates on a compact convex polytope K, strict domination on K can be checked on the extreme points (vertices) of K alone. This reduces the infinite-domain pruning problem to a finite computation.

### Theorem Target
```
theorem domination_on_polytope_iff_on_vertices
  (K : ConvexBody (Fin n → ℝ))
  (m m' : TPMonomial n) :
  StrictlyDominatedOnSet K m m' ↔ StrictlyDominatedOn (extremePoints K) m m'
```

### Proof Strategy
1. The difference d(x) = m'(x) - m(x) is affine, hence convex and concave.
2. An affine function on a compact convex set attains its minimum on an extreme point.
3. If m ≤ m' on all extreme points, then m ≤ m' on all of K (by convexity/affinity).
4. If m < m' on some extreme point, then m < m' there, giving strict domination.
5. Conversely, if d(x₀) > 0 for some x₀ ∈ K but d(v) ≤ 0 for all vertices v, then d is non-positive on K by affinity—contradicting d(x₀) > 0.

### Cross-Domain Impact
- Makes tropical pruning efficiently certifiable on continuous domains
- Connects to classical polyhedral computation (vertex enumeration)
- Enables "certified robustness regions" where pruning is guaranteed sound
- Links to support function theory and Legendre-Fenchel duality

### Difficulty: Medium
The mathematical content is classical (affine functions on polytopes). The formalization challenge is working with convex bodies and extreme points in Lean/Mathlib.

---

## Direction 3: Tropical Explanation Complexity Invariant

### Hypothesis
The *tropical explanation complexity* of a function f on domain D—defined as the minimum number of affine templates needed to represent f as their maximum on D—is an invariant of the semantic function, independent of the particular tropical polynomial representation.

### Theorem Target
```
theorem tropical_complexity_invariant
  (D : Finset (Fin n → ℝ))
  (p₁ p₂ : TPoly n)
  (hfun : ∀ x ∈ D, p₁.eval x = p₂.eval x) :
  (p₁.canonicalOn D).support.card = (p₂.canonicalOn D).support.card
```

### Proof Strategy
1. Show that canonical pruning produces a *minimal* representation: no proper subset of the canonical support represents the same function on D.
2. Prove that any two minimal representations have the same cardinality (analogous to the uniqueness of dimension for vector spaces).
3. The key insight: at each domain point, the active template is determined by the function value, not the representation. Two minimal representations must have the same activation pattern.

### Subtlety
This may require additional genericity assumptions (no ties). With ties, two representations might have different canonical sizes. The clean version might restrict to "generic position" domains where no two monomials agree at any domain point.

### Cross-Domain Impact
- Defines a new complexity measure for piecewise-linear models
- Enables comparison of architectures by semantic complexity rather than parameter count
- Connects to VC dimension and Rademacher complexity in learning theory
- Could lead to generalization bounds based on tropical complexity

### Difficulty: High
Proving minimality and uniqueness of canonical representations requires careful handling of tie-breaking and degeneracy.

---

## Direction 4: Robustness-Preserving Pruning

### Hypothesis
If a tropical polynomial p has a certified robustness margin ε > 0 on domain D (meaning the output is stable under ε-perturbations of the input), then canonical pruning preserves this robustness margin.

### Theorem Target
```
theorem pruning_preserves_robustness
  (D : Finset (Fin n → ℝ))
  (p : TPoly n)
  (ε : ℝ) (hε : 0 < ε)
  (hrob : ∀ x ∈ D, ∀ δ : Fin n → ℝ, ‖δ‖ < ε →
    p.argmax_idx (x + δ) = p.argmax_idx x) :
  ∀ x ∈ D, ∀ δ : Fin n → ℝ, ‖δ‖ < ε →
    (p.canonicalOn D).argmax_idx (x + δ) = (p.canonicalOn D).argmax_idx x
```

### Proof Strategy
1. Define "robustness" as stability of the active template index under perturbation.
2. If the active template at x is m and m survives pruning, then m is still active at x in the pruned polynomial (by preservation of evaluation).
3. Under the ε-robustness hypothesis, m is still active at x + δ in the original polynomial.
4. The pruned polynomial evaluates identically on D but may differ off D. However, if D is an ε-net of the region of interest, the robustness transfers.

### Cross-Domain Impact
- Bridges tropical pruning to neural network verification
- Enables certified model compression that preserves adversarial robustness
- Connects to Lipschitz analysis of piecewise-linear functions
- Could integrate with existing verification tools (Marabou, α-β-CROWN)

### Difficulty: Medium-High
The main challenge is that pruning preserves evaluation on D but not necessarily on the ε-neighborhood of D. An expanded domain approach (pruning on D_ε = {x + δ : x ∈ D, ‖δ‖ ≤ ε}) would work but increases the domain size.

---

## Direction 5: Logical Extraction from Canonical Templates

### Hypothesis
Canonical tropical monomials on a discretized domain correspond to Boolean/tropical decision clauses, and canonical pruning is equivalent to clause minimization in a semiring semantics.

### Theorem Target
```
theorem canonical_templates_are_minimal_clauses
  (D : Finset (Fin n → Bool))
  (p : TropicalBoolPoly n) :
  (p.canonicalOn D).support = minimalClauseSet D p
```

### Proof Strategy
1. Specialize to the Boolean domain: each input variable is 0 or 1.
2. A tropical monomial on {0,1}ⁿ reduces to a weighted sum of input bits, which can be viewed as a "soft clause" measuring how many conditions are satisfied.
3. The maximum over such soft clauses selects the clause whose conditions are best met.
4. Canonical pruning removes clauses that are logically implied by others (dominated).
5. This is a tropical analogue of Boolean clause minimization (as in Quine-McCluskey or Espresso).

### Formalization Approach
Define `TropicalBoolPoly` as a tropical polynomial specialized to Boolean inputs. Show that strict domination on {0,1}ⁿ corresponds to logical implication between clauses. Prove that canonical pruning produces a minimal clause set.

### Cross-Domain Impact
- Bridges tropical geometry to Boolean satisfiability and circuit complexity
- Enables symbolic distillation: extracting logical rules from trained networks
- Connects to explainable AI through rule extraction
- Could lead to tropical complexity lower bounds for Boolean functions

### Difficulty: Medium
The Boolean specialization simplifies many aspects (finite domain, decidable equality). The main challenge is connecting the tropical and Boolean clause semantics rigorously.

---

## Research Team Directive

Each direction should be pursued by a team that:

1. **Formulates precise theorem statements** in Lean 4 before attempting proofs
2. **Tests conjectures computationally** with Python experiments before formalization
3. **Decomposes into helper lemmas** of ≤10 lines each for the proof assistant
4. **Validates cross-domain connections** by consulting both tropical geometry and ML/verification literature
5. **Iterates on definitions** when theorems fail, documenting the mathematical reasons for design choices (as we did with strict vs. weak domination)
6. **Produces both formal proofs and working implementations** so that theoretical results are immediately usable

### Priority Order
1. **Direction 2** (Polytope reduction) — most tractable, highest immediate impact
2. **Direction 4** (Robustness preservation) — most practically relevant
3. **Direction 5** (Logical extraction) — most novel cross-domain connection
4. **Direction 1** (Compositional pruning) — most technically ambitious
5. **Direction 3** (Complexity invariant) — most theoretically deep

### Timeline Estimate
- Directions 2, 5: 2–4 weeks each for formalization
- Directions 1, 4: 4–8 weeks each
- Direction 3: 6–12 weeks (requires resolving degeneracy/uniqueness issues)

---

## Long-Term Vision

The ultimate goal is a **certified tropical compiler** for neural network compression:

1. Take a trained ReLU network as input
2. Decompose it into tropical polynomial layers
3. Apply canonical pruning layer-by-layer with formal certificates
4. Reconstruct a smaller ReLU network with provably identical behavior on the certified domain
5. Output a machine-checked proof of equivalence

This would be the first formally verified neural network compression pipeline, combining tropical algebra, polyhedral geometry, and interactive theorem proving into a practical tool for deploying safe AI systems.
