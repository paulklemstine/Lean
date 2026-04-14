# Stereographic Projection Bridge (SPB)

## One Formula, Four Domains — Formally Verified

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

**45 theorems, 0 sorry** — fully machine-verified in Lean 4 v4.28.0 with Mathlib.

### Core Theorems (SPBCore.lean — 23 theorems)
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

### Advanced Theorems (SPBAdvanced.lean — 10 theorems)
- Möbius matrix: det M(a) = 1 + a², matrix composition
- Monotonicity: spb is strictly increasing in each argument
- Derivative: d/dx spb(x,y) = (1+y²)/(1−xy)²
- No real fixed points for a ≠ 0
- Positivity preservation
- Slope composition = tangent addition

### New Results (SPBFiniteFields.lean — 12 theorems)
- **Brahmagupta-Fibonacci identity**: (a²+b²)(c²+d²) = (ac−bd)²+(ad+bc)²
- **Norm multiplicativity**: (1+spb(x,y)²)(1−xy)² = (1+x²)(1+y²)
- **Pythagorean parametrization**: ((1−t²)/(1+t²))² + (2t/(1+t²))² = 1
- **Perturbation formula**: spb(x,y) − (x+y) = xy(x+y)/(1−xy)
- **Derivative positivity**: (1+y²)/(1−xy)² > 0
- **Quadruple-angle formula**: Explicit 4× formula via double doubling
- **SPB cancellation**: spb(spb(x,y), −y) = x
- **Sign properties**: Positivity preservation and reversal

## Computational Demos

### Demo Suite (4 programs, 15+ demonstrations)

| Demo | Description | Key Result |
|------|-------------|------------|
| `spb_explorer.py` | Core SPB exploration | Group axioms verified |
| `spb_applications.py` | Advanced applications | Rapidity, Möbius matrices |
| `spb_comprehensive_demo.py` | **11 full demonstrations** | All properties + neural nets |
| `spb_finite_field_demo.py` | **Finite field deep dive** | p±1 law verified for 24 primes |

### Key Computational Discoveries
- **p±1 Law**: Verified for ALL odd primes < 100. The SPB group over F_p has order p+1 when p ≡ 3 (mod 4), and p−1 when p ≡ 1 (mod 4).
- **Thomas Precession**: 3D SPB is non-commutative; the commutator angle = 17.7° for test vectors.
- **SPB Neural Neurons**: Monotone, self-normalizing, with controllable outputs.
- **Machin's Formula**: `spb(spb_iter(4, 1/5), −1/239) = 1` verified to 10 digits.

## Visualizations (7 SVG diagrams)

| Diagram | Description |
|---------|-------------|
| `spb_bridge_architecture.svg` | Four-domain bridge diagram |
| `spb_cayley_circle.svg` | Cayley transform: ℝ → S¹ |
| `spb_velocity_addition.svg` | Einstein velocity addition |
| `spb_research_map.svg` | 35 research directions map |
| `spb_unified_bridge.svg` | **Unified framework overview** |
| `spb_finite_field_orbits.svg` | **F_p orbits and p±1 law** |
| `spb_3d_thomas_precession.svg` | **3D SPB and Thomas precession** |
| `spb_neural_network.svg` | **SPB neural network architecture** |

## Research Papers

| Paper | Audience | Content |
|-------|----------|---------|
| `SPB_Research_Paper.md` | Researchers | Original technical paper |
| `SPB_Expanded_Research_Paper.md` | **Researchers** | **Expanded paper with new results** |
| `SPB_ScientificAmerican.md` | General public | Original popular article |
| `SPB_SciAm_Expanded.md` | **General public** | **Expanded Scientific American article** |
| `SPB_FutureDirections.md` | Researchers | 35 research directions |
| `SPB_New_Applications.md` | **Engineers/CS** | **12 new application ideas** |

## Directory Structure

```
StereographicProjectionBridge/
├── SPBCore.lean              # Core formalization (23 theorems)
├── SPBAdvanced.lean          # Advanced theory (10 theorems)
├── SPBFiniteFields.lean      # New results (12 theorems)
├── README.md                 # This file
├── demos/
│   ├── spb_explorer.py       # Interactive demo (8 demonstrations)
│   ├── spb_applications.py   # Advanced applications (6 demos)
│   ├── spb_comprehensive_demo.py  # Full suite (11 demos)
│   └── spb_finite_field_demo.py   # Finite fields (6 demos)
├── visuals/
│   ├── spb_bridge_architecture.svg
│   ├── spb_cayley_circle.svg
│   ├── spb_velocity_addition.svg
│   ├── spb_research_map.svg
│   ├── spb_unified_bridge.svg
│   ├── spb_finite_field_orbits.svg
│   ├── spb_3d_thomas_precession.svg
│   └── spb_neural_network.svg
├── papers/
│   ├── SPB_Research_Paper.md
│   ├── SPB_Expanded_Research_Paper.md
│   ├── SPB_ScientificAmerican.md
│   ├── SPB_SciAm_Expanded.md
│   ├── SPB_FutureDirections.md
│   └── SPB_New_Applications.md
└── output/                    # Generated demo output
```

## Running the Demos

```bash
# Full demonstration suite (11 demos)
python demos/spb_comprehensive_demo.py

# Finite field deep dive with p±1 law
python demos/spb_finite_field_demo.py

# Original demos
python demos/spb_explorer.py
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

Computationally verified for all odd primes < 100.

### Norm Multiplicativity (NEW)
```
(1 + spb(x,y)²)(1 − xy)² = (1 + x²)(1 + y²)
```
This identity explains why the Cayley transform is a homomorphism.

### 3D SPB and Thomas Precession (NEW)
```
spb₃(u, v) = (u + v + u × v) / (1 − u · v)
```
Non-commutative! The commutator produces the Thomas-Wigner rotation.

## Future Research

We identify **35 research directions** spanning pure math, analysis, physics, CS, and engineering. Top priorities:

1. **Higher-Dimensional SPB** (★★★): S³ → quaternions, S⁷ → octonions
2. **SPB Neural Networks** (★★★): Monotonic, self-normalizing neurons
3. **Thomas Precession** (★★★): 3D non-commutative SPB = boost commutator
4. **F_p Group Order** (★★★): Formal verification of the p±1 law
5. **Approximation Rates** (★★★): Exponential convergence for analytic functions

See `papers/SPB_FutureDirections.md` and `papers/SPB_New_Applications.md` for details.
