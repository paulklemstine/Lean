# Future Directions: Compositional Certified Robustness

## Overview

The compositional bound theorem — r_global ≥ min(r_local, r_region) — establishes a bridge between tropical geometry, piecewise-affine deep learning theory, and exact verification. This document outlines five breakthrough-level research programs opened by this work.

---

## Direction 1: Exact Tropical Distance-to-Decision-Boundary Algorithms

### Problem Statement
Compute the exact distance from an input x₀ to the nearest decision boundary of a ReLU network, traversing across linear regions.

### Current State
The compositional bound gives a lower bound using the minimum of local margin and region distances. The gap to the true distance comes from ignoring what happens *after* crossing a region boundary.

### Research Program

**Hypothesis:** The exact distance can be computed in polynomial time for fixed depth, using the tropical polyhedral complex structure.

**Approach:**
1. Enumerate the region adjacency graph up to depth d (regions reachable by crossing ≤ d boundaries).
2. For each adjacent region, compute the affine margin functions and check if the decision boundary intersects the shared facet.
3. Use a branch-and-bound algorithm guided by the compositional lower bound.

**Key lemma to prove:** If the compositional bound gives radius r, then any adversarial example at distance r' > r must cross at least ⌈(r' - r_local) / r_step⌉ region boundaries, where r_step is a lower bound on region width.

**Concrete next step:** Implement the region adjacency traversal for 2-layer networks and benchmark against MILP on standard verification benchmarks (MNIST, CIFAR).

**Expected impact:** Polynomial-time exact verification for bounded-depth networks.

---

## Direction 2: Interior-Point Robust Training via Joint Margin/Region Barriers

### Problem Statement
Design a training algorithm that directly optimizes the compositional certified radius min(r_local, r_region).

### Current State
Adversarial training uses PGD attacks (heuristic, expensive). Lipschitz regularization bounds the global constant (conservative). Neither directly targets the compositional structure.

### Research Program

**Hypothesis:** A barrier-function training objective that penalizes proximity to both margin and region boundaries will produce networks with larger certified radii than either adversarial training or Lipschitz regularization alone.

**Barrier objective:**
```
L(x, y) = L_CE(f(x), y) - λ₁ Σ_{j≠y} log(f_y(x) - f_j(x)) - λ₂ Σ_ℓ log(|W_ℓ x + b_ℓ|)
```

**Approach:**
1. **Phase 1:** Implement the barrier loss for 2-layer ReLU networks on MNIST.
2. **Phase 2:** Develop efficient backward passes through the log-margin and log-slack terms.
3. **Phase 3:** Study the Pareto frontier of accuracy vs. certified radius.
4. **Phase 4:** Extend to deep networks using layer-wise barrier decomposition.

**Key challenge:** The barrier terms become infinite at activation boundaries (where neurons switch). Use ε-smoothing: replace log|z| with log(|z| + ε) and anneal ε during training.

**Concrete next step:** Train a 2-layer network on MNIST with the barrier loss, measure certified accuracy at ε = 0.1 (L∞), and compare against PGD adversarial training and TRADES.

**Expected impact:** State-of-the-art certified accuracy via a principled optimization objective.

---

## Direction 3: Tropical-MILP Hybrid Verifiers with Completeness Certificates

### Problem Statement
Build a verification system that uses cheap tropical/affine certificates as a preprocessing step for MILP, with provable completeness guarantees.

### Current State
MILP verifiers are complete but slow. The compositional bound is fast but incomplete (it may underestimate the true radius).

### Research Program

**Hypothesis:** The compositional bound resolves 80%+ of verification queries at standard perturbation budgets, and the remaining queries can be accelerated by using the tropical certificate as a warm start for the MILP solver.

**Architecture:**
```
Input (x₀, ε)
  ├── Tropical Certificate (O(mn) time)
  │     ├── r_comp ≥ ε → CERTIFIED ✓
  │     └── r_comp < ε → pass to MILP
  └── MILP Solver (warm-started with tropical bounds)
        ├── r_exact ≥ ε → CERTIFIED ✓
        └── r_exact < ε → ADVERSARIAL ✗ (with witness)
```

**Key innovations:**
1. Use the tropical certificate to tighten MILP bounds: fix activation patterns within the certified region.
2. Use region adjacency information to prune MILP branches.
3. Provide a completeness certificate: the hybrid verifier gives the exact answer in finite time.

**Concrete next step:** Integrate the compositional bound into the Gurobi-based MILP verifier of Tjeng et al., measure speedup on the VNN-COMP benchmark.

**Expected impact:** 10-100× speedup on standard verification benchmarks.

---

## Direction 4: Expressivity-vs-Robustness Theorems via Region Adjacency Graphs

### Problem Statement
Prove quantitative theorems relating the number of linear regions, their geometry, and the achievable certified robustness.

### Current State
Montúfar et al. showed that deeper networks have exponentially more linear regions. Our compositional theorem shows that region geometry (not just count) controls robustness.

### Research Program

**Hypothesis:** For any ReLU network with N linear regions in ℝⁿ, the average compositional certified radius over a standard distribution is O(1/N^{1/n}).

**Approach:**
1. **Upper bound:** Use packing arguments. N regions in a bounded domain have average diameter O(1/N^{1/n}), so the region radius is at most this.
2. **Lower bound:** Construct networks achieving the bound. Regular polyhedral decompositions (e.g., hyperplane arrangements) achieve it.
3. **Tighter analysis:** For networks with specific architectures (e.g., width m, depth L), relate N to m and L, and propagate to robustness bounds.

**Key lemma to prove:** For a single-hidden-layer ReLU network with m neurons:
- Maximum number of regions: O(mⁿ)
- Average region radius in the unit ball: Ω(1/m)
- Therefore: average compositional radius ≥ Ω(1/m)

**Concrete next step:** Prove the single-hidden-layer bound formally. Extend to depth 2 and compare with experimental measurements.

**Expected impact:** First provable expressivity-robustness tradeoff theorem with explicit constants.

---

## Direction 5: Certified Robustness as a Sheaf on Polyhedral Complexes

### Problem Statement
Model the compositional certificate structure as a sheaf on the polyhedral complex of linear regions, and use sheaf cohomology to detect global obstructions to robustness.

### Current State
The compositional bound gives certificates on individual cells. The equality characterization shows how certificates fail at cell boundaries. This is exactly the data of a sheaf.

### Research Program

**Hypothesis:** The cohomology of the robustness sheaf detects topological obstructions that no local certificate can resolve.

**Construction:**
1. **Polyhedral complex X:** cells = linear regions, faces = shared activation boundaries.
2. **Sheaf F:** on each cell R, the stalk F(R) = {r ∈ ℝ | LocalCertified(f, ·, y, R, r)}.
3. **Restriction maps:** on a shared face R ∩ R', the restriction is the minimum of radii compatible with both regions.
4. **Global section:** a global certified radius is a global section of F.

**Key insight:** H¹(X, F) ≠ 0 indicates that local certificates cannot be glued into a global one—there are topological obstructions to robustness. These correspond to "adversarial cycles": paths through the polyhedral complex that gradually reduce the margin.

**Concrete next step:**
1. Compute the polyhedral complex for small networks (2D input, 2–4 neurons).
2. Construct the robustness sheaf explicitly.
3. Compute H⁰ and H¹ and interpret in terms of adversarial vulnerability.

**Expected impact:** A topological invariant of neural network robustness, connecting to persistent homology and TDA.

---

## Cross-Cutting Themes

### Computational Complexity
All five directions share the question: what is the complexity of computing the exact certified radius? The tropical structure suggests it may be in P for fixed depth and NP-hard in general. Resolving this would be a major result in computational complexity.

### Tooling and Infrastructure
Each direction benefits from:
- Efficient polyhedral complex enumeration
- Region adjacency graph computation
- Fast affine margin radius calculation
- Integration with existing verification frameworks

### Machine-Verified Mathematics
The formal verification methodology used here should extend to all future directions. Each new theorem should be machine-verified to ensure the compositional principle is applied correctly.

---

## Priority Ranking

1. **Direction 3 (Hybrid verifier):** Highest near-term impact, directly applicable to existing benchmarks.
2. **Direction 2 (Interior-point training):** Most impactful for practitioners, but requires careful engineering.
3. **Direction 4 (Expressivity-robustness):** Most theoretically significant, could establish a new subfield.
4. **Direction 1 (Exact algorithms):** Technically challenging but foundational for completeness.
5. **Direction 5 (Sheaf theory):** Most visionary, highest risk, but potentially transformative.

---

## Team Directive

For each direction:
1. **Formulate precise hypotheses** with falsifiable predictions.
2. **Build minimal prototypes** (Python + small networks) to test hypotheses computationally.
3. **Prove key lemmas formally** to validate the mathematical framework.
4. **Iterate:** revise hypotheses based on computational and formal results.
5. **Scale:** extend working prototypes to standard benchmarks and real-world networks.

The compositional bound theorem is the seed crystal. Each direction grows a different facet of a unified theory of neural network geometry, robustness, and verification.
