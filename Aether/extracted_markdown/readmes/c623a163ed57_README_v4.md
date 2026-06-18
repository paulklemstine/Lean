# EML Research Program — Version 4

## The Continuous Sheffer Stroke: eml(x,y) = exp(x) − ln(y)

---

## What's New in v4

### Formal Mathematics (Lean 4)
- **47 new theorems** across 2 new files, **0 sorry's**
- `FundamentalTheory.lean`: Magma properties, e-tower exponential growth, tropical EML, contraction mapping, gradient structure, functional inequalities
- `PolynomialGeneration.lean`: All arithmetic via EML, polynomial building blocks, iterated exponentials, division and reciprocals
- Total across all files: **120+ theorems, 0 sorry's**

### Key New Results
1. **EML has no identity elements** — Neither left nor right identity exists (proved)
2. **e-tower ≥ 2ⁿ** — The e-tower grows at least exponentially (proved)
3. **Fixed-point contraction** — The iteration g(z) = e − ln(z) converges with rate 1/z* ≈ 0.496 (proved)
4. **Tropical EML degeneracy** — Tropical EML with leaf=1 generates only 1 value (discovered computationally), demonstrating that EML's universality critically depends on the transcendental nature of exp and ln
5. **Complete arithmetic reconstruction** — Addition, subtraction, multiplication, division, powers, roots all formally verified via EML

### Papers
- `Papers/eml_research_paper_v4.md` — Full research paper with all results
- `Papers/eml_scientific_american_v2.md` — Popular science article
- `Papers/eml_future_research_v4.md` — 60+ open problems across 14 fields

### Python Demos
- `Demos/eml_comprehensive_explorer.py` — Complete EML exploration: constants, fixed points, dynamics, arithmetic
- `Demos/eml_julia_set_v2.py` — Julia set computation and SVG generation
- `Demos/eml_symbolic_regression_v3.py` — EML-based symbolic regression engine
- `Demos/eml_tropical_explorer.py` — Tropical EML analysis (new discovery!)

### SVG Visuals
- `Visuals/eml_research_overview_v4.svg` — Research roadmap across 12 fields
- `Visuals/eml_arithmetic_construction.svg` — How EML builds all arithmetic
- `Visuals/eml_diagonal_map_v2.svg` — Diagonal map analysis with proved properties
- `Visuals/eml_e_tower_growth.svg` — e-tower visualization
- `Visuals/eml_magma_structure.svg` — Algebraic hierarchy of the EML magma

---

## File Structure

```
EML/
├── Basic.lean                    # Core definitions, identities (25+ thms)
├── AdvancedTheorems.lean         # Trees, Catalan, differentiability (25+ thms)
├── ExtendedTheory.lean           # Diagonal map, convexity, Lambert W (30+ thms)
├── FundamentalTheory.lean    ★   # Magma, e-tower ≥ 2ⁿ, tropical (30 thms)
├── PolynomialGeneration.lean ★   # Arithmetic via EML, polynomials (17 thms)
├── Universality.lean             # Closure, EDL, anti-EML (10+ thms)
├── NewTheorems.lean              # Derivatives, master formula (10+ thms)
├── OISCC.lean                    # Additional results
├── PythagoreanBridge.lean        # Pythagorean connections
├── Demos/
│   ├── eml_comprehensive_explorer.py  ★
│   ├── eml_julia_set_v2.py           ★
│   ├── eml_symbolic_regression_v3.py  ★
│   ├── eml_tropical_explorer.py       ★
│   └── ... (previous demos)
├── Papers/
│   ├── eml_research_paper_v4.md       ★
│   ├── eml_scientific_american_v2.md  ★
│   ├── eml_future_research_v4.md      ★
│   └── ... (previous papers)
├── Visuals/
│   ├── eml_research_overview_v4.svg   ★
│   ├── eml_arithmetic_construction.svg ★
│   ├── eml_diagonal_map_v2.svg        ★
│   ├── eml_e_tower_growth.svg         ★
│   ├── eml_magma_structure.svg        ★
│   └── ... (previous visuals)
└── README_v4.md                       ★
```

★ = new in v4

---

## Running the Demos

```bash
# Full EML exploration
python3 EML/Demos/eml_comprehensive_explorer.py

# Tropical EML (new discovery!)
python3 EML/Demos/eml_tropical_explorer.py

# Symbolic regression
python3 EML/Demos/eml_symbolic_regression_v3.py

# Julia set
python3 EML/Demos/eml_julia_set_v2.py
```

---

## Building the Lean Proofs

```bash
lake build EML
```

All 120+ theorems compile with 0 sorry's on Lean 4.28.0 / Mathlib v4.28.0.

---

## Key Discoveries

### 1. The EML Magma is "Maximally Weak"
The EML operator defines a magma (set + binary operation) that fails every standard algebraic axiom:
- Not commutative (eml(0,1) = 1 ≠ e = eml(1,1))
- Not associative (eml(eml(0,1),1) = e ≠ 0 = eml(0,eml(1,1)))
- No left identity
- No right identity

Yet this "bare" algebraic structure generates ALL elementary functions. This is the fundamental paradox of EML.

### 2. Tropical EML Loses Universality
The tropical shadow trop_eml(x,y) = max(x, -y) with leaf value 1 generates only the single value 1. This proves that EML's universality critically depends on the transcendental nature of exp and ln — their tropical linearization destroys the generative power.

### 3. The e-Tower Grows Faster than Any Exponential
We proved eTower(n) ≥ 2ⁿ, but the growth is far faster: tetration. The e-tower is one of the fastest-growing sequences constructible by a simple mathematical operation.

### 4. Fixed-Point Iteration Converges
The iteration g(z) = e − ln(z) converges to z* ≈ 2.01678 with rate |g'(z*)| = 1/z* ≈ 0.496. This fixed point satisfies z* · exp(z*) = e^e, connecting EML to the Lambert W function.
