# Stereographic Projection Bridge (SPB)

## One Formula, Four Domains

```
spb(x, y) = (x + y) / (1 − xy)
```

This single algebraic formula serves as a bridge connecting:

| Domain | Connection |
|--------|-----------|
| **Trigonometry** | tan(α + β) = spb(tan α, tan β) |
| **Group Theory** | (ℝ, spb) ≅ (S¹, ·) via Cayley transform |
| **Special Relativity** | spbH(u,v) = (u+v)/(1+uv) is Einstein velocity addition |
| **Approximation Theory** | SPB trees generate Chebyshev-like rational functions |

## Formal Verification

**25 theorems, 0 sorry** — fully machine-verified in Lean 4 v4.28.0 with Mathlib.

### Core Theorems (SPBCore.lean)
- Group axioms: commutativity, identity, inverse, associativity
- Tangent addition: tan(a+b) = spb(tan a, tan b)
- Double/triple angle formulas
- Cayley transform: cayley(spb(x,y)) = cayley(x) · cayley(y)
- Cayley on unit circle: |cayley(x)|² = 1
- Einstein velocity bound: |u|,|v| < 1 ⟹ |spbH(u,v)| < 1
- Rapidity: tanh(φ₁+φ₂) = spbH(tanh φ₁, tanh φ₂)
- Cocycle identity
- Field-generic associativity
- Negation and cancellation properties

### Advanced Theorems (SPBAdvanced.lean)
- Möbius matrix: det M(a) = 1 + a², matrix composition
- Monotonicity: spb is strictly increasing in each argument
- Derivative: d/dx spb(x,y) = (1+y²)/(1−xy)²
- No real fixed points for a ≠ 0
- Positivity preservation
- Slope composition = tangent addition

## Directory Structure

```
StereographicProjectionBridge/
├── SPBCore.lean          # Core formalization (17 theorems)
├── SPBAdvanced.lean      # Advanced theory (8 theorems)
├── README.md             # This file
├── demos/
│   ├── spb_explorer.py   # Interactive demo (8 demonstrations)
│   └── spb_applications.py # Advanced applications (6 demos)
├── visuals/
│   ├── spb_bridge_architecture.svg   # Four-domain bridge diagram
│   ├── spb_cayley_circle.svg         # Cayley transform visualization
│   ├── spb_velocity_addition.svg     # Einstein velocity addition
│   └── spb_research_map.svg          # 35 research directions map
└── papers/
    ├── SPB_Research_Paper.md          # Technical research paper
    ├── SPB_ScientificAmerican.md      # Popular science article
    └── SPB_FutureDirections.md        # 35 research directions (detailed)
```

## Running the Demos

```bash
# Interactive SPB explorer
python demos/spb_explorer.py

# Advanced applications
python demos/spb_applications.py
```

## Key Results

### The Cayley Transform Bridge
The map `cayley(x) = (1 + ix)/(1 − ix)` converts:
- SPB addition on ℝ → multiplication on S¹
- The identity 0 → the point 1
- The inverse −x → the conjugate

This is a **group isomorphism**, formally verified.

### Einstein's Velocity Bound
If |u| < c and |v| < c, then |spbH(u,v)| < c.
**Proof**: (1+uv)² − (u+v)² = (1−u²)(1−v²) > 0. ∎

### The p±1 Law
Over F_p, the SPB group has order:
- p + 1 when p ≡ 3 (mod 4)
- p − 1 when p ≡ 1 (mod 4)

This connects to quadratic extensions and norm maps.

## Future Research

We identify **35 research directions** spanning pure math, analysis, physics, CS, and engineering. Top priorities:

1. **Higher-Dimensional SPB** (★★★): S³ → quaternions, S⁷ → octonions
2. **SPB Neural Networks** (★★★): Monotonic, self-normalizing neurons
3. **Thomas Precession** (★★★): 3D non-commutative SPB = boost commutator
4. **F_p Group Order** (★★★): Formal verification of the p±1 law
5. **Approximation Rates** (★★★): Exponential convergence for analytic functions

See `papers/SPB_FutureDirections.md` for the complete roadmap.
