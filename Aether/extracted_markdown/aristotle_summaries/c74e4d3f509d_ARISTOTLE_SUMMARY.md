# Summary of changes for run 7087d137-a991-4077-a314-6e82ee0a30a1
# Pullback Stability of Universal Approximation — Complete Package

## Formally Verified Mathematics (Lean 4)

All theorems are fully proved with **zero `sorry`s** and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). The formalization is in a single 276-line file:

**`Catalog/EML/PullbackApprox/Basic.lean`**

### Theorem inventory (all fully proved):

| Theorem | Statement |
|---------|-----------|
| `FiberConst` | Subalgebra of C(X,ℝ) of functions constant on fibers of φ |
| `pullbackAlg` | ℝ-algebra homomorphism C(Y,ℝ) →ₐ[ℝ] C(X,ℝ) via f ↦ f∘φ |
| `fiberConst_closed` | FiberConst(φ) is closed in the uniform topology |
| `norm_pullback_le` | ‖φ*f‖ ≤ ‖f‖ (pullback is norm-nonincreasing) |
| `pullback_isometry_of_surjective` | ‖φ*f‖ = ‖f‖ when φ is surjective |
| `fiberConst_eq_top_iff_injective` | FiberConst(φ) = ⊤ ↔ φ is injective (sharp, uses Urysohn) |
| `fiberConst_subset_range_pullback` | Every fiber-constant function is a pullback (via Tietze) |
| `fiberConst_eq_range_pullback_of_surjective` | FiberConst(φ) = range(φ*) when φ surjective |
| `closure_range_pullback_eq_fiberConst` | **Main theorem:** closure(φ*(A)) = FiberConst(φ) for dense A |
| `closure_range_pullback_eq_top_of_injective` | Injective case: closure = C(X,ℝ) |
| `exists_pullback_approx_of_fiberConst` | ε-approximation within FiberConst(φ) |
| `exists_pullback_approx_of_injective` | ε-approximation for all of C(X,ℝ) when φ injective |

### Proof architecture:
1. **Basic properties** — FiberConst as closed subalgebra, norm estimates
2. **Image factorization** — quotient map property of corestriction → continuous lift → Tietze extension
3. **Density transport** — closure_minimal for ⊆, factorization + density + norm estimate for ⊇
4. **Corollaries** — injective case, ε-approximation

## Python Demos (`demos/`)

**`pullback_approximation_demo.py`** — generates 5 publication-quality figures:
- **Fig 1:** Injective feature map — polynomial approximation of arbitrary targets
- **Fig 2:** Non-injective φ(x)=|2x−1| — fiber-constant targets approximable, others hit a barrier
- **Fig 3:** ε-convergence analysis showing error → 0 for fiber-constant targets vs permanent barrier for non-fiber-constant targets  
- **Fig 4:** Neural feature map φ(x₁,x₂)=(x₁+x₂, x₁x₂) — what a network can/cannot learn
- **Fig 5:** Fiber structure visualization for 6 different feature maps

## Research Paper (`paper/pullback_approximation.md`)

Complete mathematical paper including:
- Formal statement and proof of all results
- Applications to neural networks, invariant learning, dimensionality reduction, transfer learning
- "What the Telescope Can See" — Scientific American-style discussion using the telescope analogy
- Future directions (quantitative rates, equivariant extensions, non-compact domains)
- Formal verification details and theorem inventory

## Key Mathematical Insight

The theorem gives a precise topological invariance principle: universal approximation is stable under pullback along continuous feature maps, but only up to the information lost by the map. The subalgebra FiberConst(φ) captures exactly the observables visible through φ, cleanly separating **representation loss** (non-injective φ forces approximation only of fiber-constant targets) from **representation transport** (injective φ transports full universal approximation).