# Future Directions: Tropical Statistical Mechanics of Training Dynamics

## Overview

This document outlines 5 concrete breakthrough research directions opened by the tropical phase transition framework for grokking. Each direction includes an exact conjecture statement, significance, connection to existing theorems, and likely proof route.

---

## Direction 1: Deep Tropical Phase Transitions via Compositional Score Functions

### Conjecture

**Compositional Corner-Locus Theorem**: For a depth-L tropical neural network with class score expressed as a composition of max-plus polynomials:

```
classScore_deep(P, c, x) = T_L ∘ T_{L-1} ∘ ... ∘ T_1(x)
```

the set of inputs where two class scores are equal (the corner locus) is a tropical hypersurface arrangement whose complexity grows at most polynomially in the number of pieces at each layer.

Furthermore, the tropical boundary gap for the deep network satisfies:

```
gap_deep(P, x) = 0 ↔ onCornerLocus_deep(P, x)
```

and an analogue of Theorem B (order parameter collapse) holds for the compositional gap.

### Why It Matters

The current framework handles single-layer max-plus scores. Real neural networks are deep compositions. Extending to depth would make the framework applicable to practical architectures and would connect to the theory of tropical rational functions (compositions of tropical polynomials and their duals).

### What It Builds On

- Theorem A (corner-locus characterization for single-layer scores)
- Zhang & Mikhailiuk's correspondence between ReLU networks and tropical rational maps

### Likely Proof Route

1. Define `classScore_deep` as iterated application of max-plus layers
2. Prove that composition of max-plus polynomials is again piecewise-linear (by induction on depth)
3. Show the corner locus of the composed function is contained in a finite union of tropical hypersurfaces (one from each layer)
4. The iff for gap = 0 should follow from the single-layer case applied to the final output
5. Order parameter collapse follows from the same Finset.sum_lt_sum argument

**Formalization target**: `theorem deep_tropicalBoundaryGap_eq_zero_iff_onCornerLocus`

---

## Direction 2: Tropical Susceptibility and Critical Exponents

### Conjecture

**Tropical Susceptibility Divergence**: Define the tropical susceptibility as the discrete derivative of the order parameter along a training trajectory:

```
χ(t) = |Φ(t+1) - Φ(t)|
```

At the grokking phase transition (the step where a sample first hits the corner locus), χ exhibits a spike whose magnitude is bounded below by the boundary gap of the witness sample:

```
χ(t*) ≥ gap(P_{t*}, x_witness)
```

where t* is the transition step. Furthermore, the "critical exponent" governing the rate of approach to the corner locus satisfies:

```
gap(P_t, x) ~ |t - t*|^α for some α > 0
```

when the trajectory is piecewise-linear in parameter space.

### Why It Matters

Critical exponents classify phase transitions. If grokking has a well-defined critical exponent (and if it's universal — independent of architecture details), this would establish grokking as a genuine universality class in the statistical mechanics sense.

### What It Builds On

- Theorem B (strict order parameter drop)
- The correspondence to statistical mechanics order parameters

### Likely Proof Route

1. Define tropical susceptibility as the absolute first difference of Φ
2. The lower bound on χ(t*) follows directly from Theorem B: the drop at the transition step is at least gap(P_{t*-1}, x_witness)
3. For piecewise-linear trajectories in parameter space, classScore is piecewise-linear in t (since it's a max of affine functions of the parameters), so the gap approaches 0 linearly, giving α = 1
4. For curved trajectories, the exponent depends on the order of tangency at the corner locus

**Formalization target**: `theorem tropical_susceptibility_spike_at_transition`

---

## Direction 3: Unification of Grokking and Double Descent

### Conjecture

**Tropical Criticality Unification Theorem**: Define a generic `TropicalCriticalObservable` structure:

```lean
structure TropicalCriticalObservable (α : Type*) where
  value : α → ℝ
  nonneg : ∀ a, 0 ≤ value a
  collapse_witness : α → α → Prop
  collapse_implies_strict_drop : ∀ a b, collapse_witness a b →
    (∀ ..., value b ≤ value a) → value b < value a
```

Both the tropical order sum (for grokking) and the double descent complexity measure (from `tropical_double_descent_phase_transition`) are instances of this structure.

Furthermore, both phase transitions can be characterized as passages through corner loci of the respective tropical score/loss functions.

### Why It Matters

If grokking and double descent share a common tropical-geometric mechanism, this would be a major conceptual unification in learning theory. It would suggest that all "sharp transitions" in neural network training are fundamentally tropical-geometric events.

### What It Builds On

- Theorem B (grokking order parameter collapse)
- The existing `tropical_double_descent_phase_transition` catalog theorem
- `order_parameter_nonneg` from the catalog

### Likely Proof Route

1. Define the abstract `TropicalCriticalObservable` structure
2. Instantiate for the grokking order sum (this paper's Φ) — nonnegativity and collapse are Theorems 3.1 and 3.4
3. Instantiate for the double descent measure — extract the relevant properties from the existing theorem
4. Prove a generic phase-transition meta-theorem for any TropicalCriticalObservable
5. Derive both grokking and double descent transitions as corollaries

**Formalization target**: `theorem tropical_criticality_unification`

---

## Direction 4: Continuous-Time Tropical Gradient Flow

### Conjecture

**Tropical Gradient Flow Crossing Theorem**: Consider the continuous-time gradient flow on the tropical loss landscape:

```
dθ/dt = -∇_θ L(θ)
```

where L is a piecewise-linear tropical loss function. The flow is well-defined (Lipschitz) almost everywhere, with singularities at the corner locus. If the gradient flow trajectory starts in one tropical cell and converges to a point in a different cell, then:

1. The trajectory crosses the corner locus in finite time
2. At the crossing, the tropical order parameter has a kink (left and right derivatives differ)
3. The crossing corresponds to a change in the "active monomial" — the affine piece achieving the maximum in the tropical polynomial

This would be a tropical analogue of the Łojasiewicz gradient inequality applied to piecewise-linear potentials.

### Why It Matters

Moving from discrete to continuous dynamics would connect the tropical framework to the theory of gradient flows, Wasserstein geometry, and neural tangent kernels. It would also enable the use of ODE/PDE techniques for predicting grokking timing.

### What It Builds On

- Theorem C (discrete sign-change crossing)
- The piecewise-linearity of tropical score functions

### Likely Proof Route

1. Formalize piecewise-linear gradient flow as a differential inclusion
2. Prove existence and uniqueness of solutions within each tropical cell (where the function is affine, so the flow is linear ODE)
3. Use the tropical cell decomposition to reduce crossing analysis to a finite sequence of linear flows
4. Apply an exit time argument: the flow exits each cell in finite time (bounded by the cell diameter / gradient norm)
5. The kink at crossing follows from the change in the active affine piece

**Formalization target**: `theorem tropical_gradient_flow_crossing_time`

---

## Direction 5: Tropical Morse Theory for Training Landscapes

### Conjecture

**Tropical Morse Lemma for Neural Losses**: The tropical loss function L(θ) on parameter space decomposes into tropical cells (regions where a fixed set of affine pieces is active). The critical points of L are:

1. **Tropical smooth critical points**: where ∇L = 0 within a cell (standard critical points of affine functions, hence only global min/max within the cell)
2. **Tropical corner critical points**: points on the corner locus where the gradients of adjacent cells point in opposing directions (no descent direction exists without crossing the locus)

Furthermore, the Morse index of a tropical corner critical point equals the number of pairs of adjacent cells whose gradient projections along the corner locus have opposite sign.

A tropical Morse inequality bounds the number of corner critical points by the topology of the tropical loss landscape (measured by tropical homology).

### Why It Matters

Tropical Morse theory would provide a complete topological characterization of the training landscape, including:
- How many grokking-type transitions a trajectory must undergo
- Whether alternative paths with fewer transitions exist
- The relationship between model complexity and the number of tropical cells (connecting to double descent)

### What It Builds On

- Theorem A (corner-locus characterization)
- Classical Morse theory and its piecewise-linear generalparts
- Tropical homology theory (Itenberg, Katzarkov, Mikhalkin, Zharkov)

### Likely Proof Route

1. Formalize the tropical cell decomposition of parameter space
2. Define tropical Morse indices at corner critical points
3. Prove the tropical Morse inequalities using the cellular chain complex
4. Apply to neural training: count the minimum number of corner-locus crossings needed to reach a global minimum from a given initialization

**Formalization target**: `theorem tropical_morse_inequality_for_training`

---

## Research Team Structure

### Formalization Lead
- Maintains the Lean 4 codebase
- Extends definitions to compositional (deep) tropical polynomials
- Proves foundational lemmas for new structures

### Tropical Geometer
- Designs corner-locus and tropical hypersurface statements
- Develops the Morse theory direction
- Connects to algebraic geometry literature

### Learning Theorist
- Interprets order-parameter collapse as generalization onset
- Designs computational experiments on real neural networks
- Validates theoretical predictions against empirical grokking data

### Statistical Mechanics Architect
- Abstracts the phase-transition framework
- Develops the susceptibility and critical exponent theory
- Pursues the unification of grokking and double descent

### Proof Engineer
- Removes coercion and Finset obstacles in Lean
- Optimizes proof structure for maintainability
- Manages Mathlib dependencies and API evolution

---

## Priority Ranking

1. **Direction 3 (Unification)** — highest conceptual impact, builds directly on existing theorems, likely formalizable in current framework
2. **Direction 2 (Susceptibility)** — concrete and provable, would add quantitative depth to the phase-transition picture
3. **Direction 1 (Deep networks)** — most practically relevant, extends applicability to real architectures
4. **Direction 5 (Morse theory)** — deepest mathematically, but requires substantial new infrastructure
5. **Direction 4 (Continuous flow)** — important for connecting to optimization theory, but requires analysis not yet in Mathlib
