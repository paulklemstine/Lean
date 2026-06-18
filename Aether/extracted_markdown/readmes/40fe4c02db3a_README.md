# EML Operator & OISCC Research Project

## The One Instruction Set Continuous Computer

**EML(a, b) = e^a − ln(b)** — a single binary operation that generates all elementary functions.

---

## Overview

The EML (Exp-Minus-Log) operator, combined with the constant 1, is sufficient to compute every elementary function: exp, ln, +, −, ×, ÷, powers, roots, and (via complex extension) all trigonometric functions. The OISCC (One Instruction Set Continuous Computer) is a stack-based processor that executes only PUSH and EML instructions — the simplest possible architecture for continuous computation.

This project contains:
- **90+ machine-verified theorems** in Lean 4 (Mathlib)
- **Python demos**: compiler, neural networks, chaos analysis, symbolic regression
- **SVG visuals**: architecture diagrams, computation trees, research roadmap
- **Research papers**: formal foundations, future directions, popular science articles

---

## Lean 4 Formalization

### Core Files (Sorry-Free ✓)

| File | Theorems | Contents |
|------|----------|----------|
| `Basic.lean` | 15+ | EML definition, exp/ln/arithmetic recovery, tree combinatorics, differentiability |
| `OISCC.lean` | 20+ | Stack machine semantics, program execution, arithmetic completeness, fixed points, e-tower constants |
| `Universality.lean` | 8+ | Complex EML, closure properties, anti-EML, expression trees |
| `NewTheorems.lean` | 10+ | Derivative structure, tree depth bounds, master formula parameters |
| `AdvancedTheorems.lean` | 20+ | Zero generation, non-associativity, fixed point existence/uniqueness, e-tower, continuity, differentiability |
| **`IntervalEML.lean`** | 12+ | **NEW** — Monotonicity, interval enclosure theorem, diagonal map, value bounds |
| **`Dynamics.lean`** | 10+ | **NEW** — One-minus-log iteration, exp-tower divergence, 2D EML map, Jacobian |
| **`Complexity.lean`** | 12+ | **NEW** — Tree bounds, PUSH-EML relation, instruction counts |

### Key Verified Results

- **Arithmetic Completeness**: exp, ln, +, −, ×, ÷ all expressed as EML compositions
- **Interval Arithmetic**: `EML(x_lo, y_hi) ≤ EML(x, y) ≤ EML(x_hi, y_lo)` — foundation for verified computing
- **No Positive Fixed Points**: `exp(x) − ln(x) > x` for all x > 0
- **Exp-Tower Divergence**: For any M, the iterated exp tower eventually exceeds M
- **Tree Combinatorics**: leaves = nodes + 1, leaves ≤ 2^depth
- **Zero Generation**: 0 = EML(1, EML(EML(1,1), 1)) — zero emerges at depth 3

---

## Python Demos

| Demo | Description |
|------|-------------|
| `eml_calculator.py` | Interactive OISCC simulator |
| `eml_compiler.py` | **NEW** — Arithmetic expression → PUSH/EML compiler |
| `eml_neural_network.py` | **NEW** — XOR network, softmax, PID controller on OISCC |
| `eml_chaos_analysis.py` | **NEW** — Diagonal map orbits, Lyapunov exponents, randomness tests |
| `eml_dynamics.py` | Dynamical systems visualization |
| `eml_complexity_explorer.py` | Complexity analysis tools |
| `eml_symbolic_regression.py` | Symbolic regression via EML trees |
| `oiscc_processor.py` | Full OISCC processor simulation |

---

## SVG Visuals

| Visual | Description |
|--------|-------------|
| `eml_research_roadmap.svg` | **NEW** — Complete research roadmap (35 directions) |
| `eml_interval_arithmetic.svg` | **NEW** — Interval enclosure theorem diagram |
| `eml_dynamical_systems.svg` | **NEW** — Three EML maps comparison |
| `eml_computation_graph.svg` | **NEW** — EML trees for exp, ln, subtraction |
| `oiscc_architecture.svg` | Processor architecture diagram |
| `eml_tree_exp.svg` / `eml_tree_ln.svg` | Expression trees |
| `eml_nand_comparison.svg` | NAND vs EML comparison |
| `eml_number_tower.svg` | Number tower from constant 1 |

---

## Research Papers

| Paper | Description |
|-------|-------------|
| `oiscc_verified_foundations.md` | **NEW** — Comprehensive paper with verified results |
| `sciam_one_equation_to_rule_them_all.md` | **NEW** — Scientific American–style feature |
| `future_research_comprehensive.md` | **NEW** — 50+ open problems, hardware/software roadmap |
| `research_paper.md` | Original research paper |
| `scientific_american_article.md` | Original SciAm article |

---

## Instruction Count Table

| Operation | EML ops | PUSH ops | Total |
|-----------|---------|----------|-------|
| exp(x)    | 1       | 2        | **3** |
| ln(x)     | 3       | 4        | **7** |
| x − y     | 5       | 6        | **11** |
| x + y     | 5       | 6        | **11** |
| x × y     | ~9      | ~10      | **~19** |
| x / y     | ~7      | ~8       | **~15** |

---

## Quick Start

### Lean 4
```bash
lake build EML.Basic EML.OISCC EML.IntervalEML EML.Dynamics EML.Complexity
```

### Python
```bash
python3 EML/Demos/eml_compiler.py          # Compiler demo
python3 EML/Demos/eml_neural_network.py     # Neural network demo
python3 EML/Demos/eml_chaos_analysis.py     # Chaos analysis demo
```

---

## Key Identity

The entire project flows from a single insight:

> **EML(ln(a), exp(b)) = e^(ln a) − ln(e^b) = a − b**

Because exp and ln cancel inside EML, the single operation EML captures all of arithmetic. Combined with EML(x, 1) = exp(x) for direct exponentials, this makes the OISCC arithmetically complete.

---

## Citation

Based on: Odrzywolek, A. (2025). "All elementary functions from a single operator."
