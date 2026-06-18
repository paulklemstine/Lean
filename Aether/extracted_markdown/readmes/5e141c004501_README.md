# OISCC V9: One Instruction Set Continuous Computer

## Comprehensive Research Package

---

### Overview

The OISCC (One Instruction Set Continuous Computer) is a computational architecture based on a single binary operation:

> **EML(a, b) = e^a − ln(b)**

This single instruction suffices to recover all basic arithmetic, making the OISCC a minimal yet complete computational system. This package contains **40+ machine-verified theorems**, Python demos, SVG visuals, and research papers.

---

### Directory Structure

```
OISCC_V9/
├── lean/                          # Lean 4 formal proofs
│   ├── DepthHierarchy.lean        # Growth separation, e-tower, BB_EML
│   ├── DensityTheory.lean         # EML closure, density building blocks, e is irrational
│   ├── DivergenceTheory.lean      # 2D Phi map, Lyapunov function, no fixed points
│   └── AlgebraicStructure.lean    # Magma properties, T_c semigroup, chain rule
│
├── demos/                         # Python demonstrations
│   ├── oiscc_v9_explorer.py       # Comprehensive EML calculator & OISCC simulator
│   └── oiscc_v9_dynamics.py       # Dynamics analysis & orbit visualization
│
├── visuals/                       # SVG diagrams
│   ├── oiscc_v9_architecture.svg       # Processor architecture
│   ├── oiscc_v9_depth_hierarchy.svg    # Depth hierarchy visualization
│   ├── oiscc_v9_research_roadmap.svg   # Research status overview
│   └── oiscc_v9_arithmetic_recovery.svg # How EML recovers arithmetic
│
├── papers/                        # Research documents
│   ├── research_paper.md               # Technical research paper
│   ├── scientific_american_article.md  # Popular science article
│   └── future_research_directions_v9.md # Updated research roadmap
│
└── README.md                      # This file
```

---

### Key Proven Results

| # | Result | File |
|---|--------|------|
| 1 | EML recovers exp, ln, +, −, ×, ÷ | AlgebraicStructure.lean |
| 2 | Depth hierarchy is strict (growth separation) | DepthHierarchy.lean |
| 3 | exp^(n+2)(x) > exp^(n+1)(Cx+D) eventually | DepthHierarchy.lean |
| 4 | e-tower is strictly monotone and unbounded | DepthHierarchy.lean |
| 5 | BB_EML(n) ≥ e↑↑n | DepthHierarchy.lean |
| 6 | Diagonal d(x) > x for all x > 0 | DivergenceTheory.lean |
| 7 | Diagonal d(x) ≥ 2 for all x > 0 | DivergenceTheory.lean |
| 8 | 2D map Φ has no fixed points in ℝ²₊ | DivergenceTheory.lean |
| 9 | Lyapunov V(Φ(x,y)) = exp(exp(x))/y + exp(exp(y))/x | DivergenceTheory.lean |
| 10 | Trace Tr(x,y) ≥ 4 for x,y > 0 | DivergenceTheory.lean |
| 11 | Max-coordinate growth for max(x,y) ≥ 2 | DivergenceTheory.lean |
| 12 | EML is non-commutative | AlgebraicStructure.lean |
| 13 | EML is non-associative | AlgebraicStructure.lean |
| 14 | EML has no left identity | AlgebraicStructure.lean |
| 15 | EML has no right identity | AlgebraicStructure.lean |
| 16 | EML is right-cancellative | AlgebraicStructure.lean |
| 17 | T_c semigroup is non-commutative | AlgebraicStructure.lean |
| 18 | EML chain rule (derivative formula) | AlgebraicStructure.lean |
| 19 | EML(x,x) ≥ 2 for x > 0 | AlgebraicStructure.lean |
| 20 | EML tower is strictly monotone | AlgebraicStructure.lean |
| 21 | e is irrational | DensityTheory.lean |
| 22 | Log-split identity | DensityTheory.lean |
| 23 | EML(0,x) maps (1,e) to (0,1) | DensityTheory.lean |
| 24 | EML(EML(0,x), 1) = e/x for x > 0 | DensityTheory.lean |
| 25 | Double negation: EML(0, exp(EML(0, exp(x)))) = x | DensityTheory.lean |
| 26 | Triple exp exceeds double exp + single exp | DepthHierarchy.lean |

---

### Running the Demos

```bash
# Main explorer (arithmetic, e-tower, K_EML, dynamics, OISCC programs)
python3 demos/oiscc_v9_explorer.py

# Dynamics analysis (diagonal map, Phi map, Lyapunov, EML-Collatz)
python3 demos/oiscc_v9_dynamics.py
```

---

### Building the Lean Proofs

```bash
lake build OISCC_V9.lean.DepthHierarchy
lake build OISCC_V9.lean.DensityTheory
lake build OISCC_V9.lean.DivergenceTheory
lake build OISCC_V9.lean.AlgebraicStructure
```

---

### Open Problems

1. **Is the EML closure of {1} dense in ℝ₊?**
2. **What is K_EML(2)?** (minimum depth to reach 2 from {1})
3. **Does every orbit of Φ in ℝ²₊ diverge?**
4. **Is the theory of (ℝ, EML, 1) decidable?**
5. **Is exp(exp(1)) irrational?** (requires Lindemann-Weierstrass, not in Mathlib)

---

*OISCC V9 — April 2026*
