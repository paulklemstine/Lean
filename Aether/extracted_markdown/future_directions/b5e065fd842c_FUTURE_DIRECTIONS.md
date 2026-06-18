# Future Directions: Idempotent Einstein–Hamilton–Jacobi Duality

## Overview

The four-way equivalence (stationarity ↔ calibration ↔ skeleton membership ↔ conserved momentum) established in this work opens several concrete breakthrough research directions. Each direction below includes specific theorem targets, proof strategies, and cross-domain impact.

---

## Direction 1: Tropical Curvature from Bellman Potentials

### Vision
Define discrete curvature of a Bellman potential V on a finite weighted graph as the defect of the Bellman equation under perturbation. This would yield **tropical Einstein equations**: the skeleton geometry is "flat" (zero curvature) precisely when V is a Bellman fixed point.

### Concrete Theorem Target
```
theorem tropical_einstein_eq :
  ∀ V, IsBellmanFixedPoint c V ↔ TropicalCurvature c V = 0
```
where `TropicalCurvature c V x = bellmanOp c V x - V x` measures the defect.

### Proof Strategy
- Define curvature as the Bellman residual at each vertex (not edge)
- Show curvature vanishes iff V is a fixed point (essentially tautological from definition)
- The non-trivial extension: relate second-order curvature (Hessian analogue) to geodesic deviation — how nearby calibrated paths diverge

### Cross-Domain Impact
- **General relativity**: discrete analogue of Einstein field equations in tropical spacetime
- **Network science**: curvature-based community detection and flow analysis
- **Optimal transport**: Wasserstein-like distances from tropical curvature bounds

---

## Direction 2: Idempotent Causal Cones and Lorentzian Semimodule Structures

### Vision
Define a tropical causal structure: given a Bellman potential V, the "future cone" at a vertex x consists of all vertices reachable via calibrated (skeleton) paths. Prove that this causal structure satisfies discrete analogues of Lorentzian causality axioms.

### Concrete Theorem Target
```
theorem causal_cone_transitivity :
  ∀ x y z, InFutureCone V x y → InFutureCone V y z → InFutureCone V x z

theorem no_closed_causal_curves :
  (∀ x y, CalibratedEdge c V x y → V y > V x) →
  ¬∃ γ, CalibratedPath c V γ ∧ γ.head? = γ.getLast? ∧ γ.length > 1
```

### Proof Strategy
- Define `InFutureCone V x y ↔ ∃ γ, PathInSkeleton (GeodesicSkeleton c V) γ ∧ γ.head? = x ∧ γ.getLast? = y`
- Transitivity follows from path concatenation
- No closed causal curves follows from strict monotonicity of V along calibrated edges (V increases along the causal direction)
- Connect to existing order theory in Mathlib

### Cross-Domain Impact
- **Quantum gravity**: finite causal set models with algebraic structure
- **Distributed systems**: causal consistency from tropical potential ordering
- **Blockchain**: partially ordered transaction validation via tropical potentials

---

## Direction 3: Viscosity Extension to Infinite-State Tropical HJ

### Vision
Extend the finite four-way equivalence to countable or continuous state spaces using viscosity solution techniques. The finite theorem provides the template; the extension requires careful analysis of compactness and approximation.

### Concrete Theorem Target
```
theorem viscosity_calibration_limit :
  ∀ ε > 0, ∃ N, ∀ n ≥ N,
    ‖V_n - V_∞‖ < ε ∧
    (CalibratedPath c_n V_n γ → ε_CalibratedPath c_∞ V_∞ γ ε)
```

### Proof Strategy
- Approximate continuous state space by finite grids of increasing resolution
- Use the finite certified reconstruction at each resolution level
- Show convergence of Bellman potentials (monotone convergence in the value iteration)
- Prove that calibrated paths on fine grids converge to viscosity characteristics
- Use Mathlib's metric space and filter convergence infrastructure

### Cross-Domain Impact
- **PDE theory**: new constructive approach to Hamilton–Jacobi viscosity solutions
- **Reinforcement learning**: finite certified approximations to continuous optimal control
- **Computational geometry**: tropical curve approximation via finite skeletons

---

## Direction 4: Tropical Symplectic Structure and Groupoid Momentum

### Vision
Upgrade the conserved momentum from a scalar residual to a tropical symplectic structure. Define the tropical cotangent bundle as the space of Bellman sub-differentials, and show that calibrated paths are Lagrangian submanifolds of this structure.

### Concrete Theorem Target
```
theorem tropical_symplectic_conservation :
  CalibratedPath c V γ →
  ∀ i j, i < j → j < γ.length →
    tropicalSymplecticForm c V (γ[i], γ[i+1]) = tropicalSymplecticForm c V (γ[j], γ[j+1])
```

### Proof Strategy
- Define the tropical symplectic form as the antisymmetrized Bellman residual: `ω(x,y) = bellmanResidual c V x y - bellmanResidual c V y x`
- Show conservation along calibrated paths (both terms vanish)
- For the groupoid structure: define composition of momentum sections and show it is compatible with path concatenation
- Connect to Mathlib's symplectic geometry infrastructure if available

### Cross-Domain Impact
- **Classical mechanics**: tropical analogue of Hamiltonian mechanics
- **Geometric quantization**: dequantization via tropical limits of symplectic manifolds
- **Integrable systems**: tropical Lax pairs and soliton analogues

---

## Direction 5: Certified Planning and Explainable ML via Closure-Stable Geodesic Backbones

### Vision
Apply the certified reconstruction theorem to sequential decision problems in explainable AI. The geodesic skeleton provides an "interpretable causal backbone" — only skeleton paths are certified optimal, and the Bellman potential provides human-readable cost certificates.

### Concrete Theorem Target
```
theorem explanation_certificate :
  ∀ γ, ClStationary c V Admissible γ →
  ∃ cert : ExplanationCertificate,
    cert.verifiable_in_poly_time ∧
    cert.witnesses_optimality γ ∧
    cert.skeleton_factors γ (GeodesicSkeleton c V)
```

### Proof Strategy
- Define `ExplanationCertificate` as the tuple (V, skeleton edges along γ, residual = 0 witnesses)
- Verification is polynomial: check Bellman equalities at each edge (O(|γ|) comparisons)
- Use the certified reconstruction to extract the certificate
- Prove that the certificate is complete: every optimal path has a certificate

### Cross-Domain Impact
- **Explainable AI**: certified optimal explanations for sequential decisions
- **Autonomous systems**: provably safe trajectory planning with interpretable certificates
- **Regulatory compliance**: machine-checkable optimality proofs for algorithmic decisions
- **Game theory**: certified Nash equilibrium paths in extensive-form games

---

## Cross-Cutting Technical Infrastructure Needed

1. **Tropical matrix algebra in Mathlib**: min-plus matrix multiplication, Kleene star (shortest path closure), eigenvalues
2. **Weighted graph library**: formal shortest path algorithms (Dijkstra, Bellman–Ford) with correctness proofs
3. **Viscosity solution framework**: sub/super-solution definitions for discrete and continuous HJ equations
4. **Tropical convexity**: min-plus convex sets, tropical polytopes, extremal generators

## Priority Ranking

1. **Direction 5** (Certified Planning/EML) — highest immediate impact, most concrete
2. **Direction 2** (Causal Cones) — elegant theory with clear theorem targets
3. **Direction 1** (Tropical Curvature) — foundational for directions 2-4
4. **Direction 3** (Viscosity Extension) — technically challenging, high long-term value
5. **Direction 4** (Symplectic Structure) — most speculative, but deepest if achieved
