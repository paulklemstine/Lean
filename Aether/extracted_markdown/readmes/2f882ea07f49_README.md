# EML Operator & OISCC Research Project

## The One Instruction Set Continuous Computer

**EML(a, b) = e^a − ln(b)** — a single binary operation that generates all elementary functions.

---

## Overview

The EML (Exp-Minus-Log) operator, combined with the constant 1, is sufficient to compute every elementary function: exp, ln, +, −, ×, ÷, powers, roots, and (via complex extension) all trigonometric functions. The OISCC (One Instruction Set Continuous Computer) is a stack-based processor that executes only PUSH and EML instructions — the simplest possible architecture for continuous computation.

This project contains:
- **170+ machine-verified theorems** in Lean 4 (Mathlib), all sorry-free
- **Python demos**: compiler, neural networks, chaos analysis, Kalman filter, signal processing, neuromorphic computing, cryptographic hashing, Black-Scholes option pricing, K_EML explorer, 2D dynamics, pseudorandom number generation
- **SVG visuals**: architecture diagrams, computation trees, research roadmap, algebraic structure, application ecosystem
- **Research papers**: formal foundations, open problems, future directions, popular science articles

---

## Lean 4 Formalization

### Core Files (Sorry-Free ✓)

| File | Theorems | Contents |
|------|----------|----------|
| `Basic.lean` | 15+ | EML definition, exp/ln/arithmetic recovery, tree combinatorics, differentiability |
| `OISCC.lean` | 20+ | Stack machine semantics, program execution, arithmetic completeness, fixed points |
| `Universality.lean` | 8+ | Complex EML, closure properties, anti-EML, expression trees |
| `NewTheorems.lean` | 10+ | Derivative structure, tree depth bounds, master formula parameters |
| `AdvancedTheorems.lean` | 20+ | Zero generation, non-associativity, fixed point existence/uniqueness, e-tower |
| `IntervalEML.lean` | 12+ | Monotonicity, interval enclosure theorem, diagonal map, value bounds |
| `Dynamics.lean` | 10+ | One-minus-log iteration, exp-tower divergence, 2D EML map, Jacobian |
| `Complexity.lean` | 12+ | Tree bounds, PUSH-EML relation, instruction counts |
| **`OpenProblems.lean`** | **25+** | **NEW** — Complex EML trigonometry, depth hierarchy, no identity element, tropical EML, sigmoid bounds, chain rule, Catalan numbers, condition numbers |

### Key New Results (OpenProblems.lean)

- **Complex EML = Trigonometry**: `ceml(ix, 1) = cos(x) + i·sin(x)` (Euler's formula via EML)
- **Depth Hierarchy Strict**: `exp(exp(x)) ∉ {exp(ax+b)}` (depth 2 ⊋ depth 1)
- **No Identity Element**: Neither left nor right identity exists for EML
- **Tropical EML = Subtraction**: `tropicalEML(a,b) = a - b` with verified algebraic properties
- **EML Chain Rule**: `d/dt EML(g(t),h(t)) = g'·exp(g) - h'/h`
- **Sigmoid via EML**: `0 < σ(x) < 1` and `σ'(x) = σ(x)(1-σ(x))`
- **Log-Split**: `EML(x, y·z) = EML(x,y) - ln(z)` for y, z > 0
- **Catalan Tree Counting**: C(4) = 14 (number of EML tree shapes)
- **Condition Numbers**: `κ_x(0,y) = 0` and `κ_x(x,1) = |x|`

---

## Python Demos

| Demo | Description |
|------|-------------|
| `eml_calculator.py` | Interactive OISCC simulator |
| `eml_compiler.py` | Arithmetic expression → PUSH/EML compiler |
| `eml_neural_network.py` | XOR network, softmax, PID controller on OISCC |
| `eml_chaos_analysis.py` | Diagonal map orbits, Lyapunov exponents, randomness tests |
| **`eml_kalman_filter.py`** | **NEW** — Scalar Kalman filter via EML operations |
| **`eml_signal_processing.py`** | **NEW** — FM demod, wavelet transform, spectral analysis |
| **`eml_neuromorphic_simulation.py`** | **NEW** — EML neurons, winner-take-all, spiking networks |
| **`eml_cryptographic_hash.py`** | **NEW** — EML-based hash function with statistical analysis |
| `eml_dynamics.py` | Dynamical systems visualization |
| `eml_complexity_explorer.py` | Complexity analysis tools |
| `eml_symbolic_regression.py` | Symbolic regression via EML trees |
| `oiscc_processor.py` | Full OISCC processor simulation |

---

## SVG Visuals

| Visual | Description |
|--------|-------------|
| **`eml_open_problems_map.svg`** | **NEW** — 10 open problems with status and connections |
| **`oiscc_applications_ecosystem.svg`** | **NEW** — 6 application domains with specs |
| **`eml_algebraic_structure.svg`** | **NEW** — Verified algebraic properties and hierarchy |
| `eml_research_roadmap.svg` | Complete research roadmap (35 directions) |
| `eml_interval_arithmetic.svg` | Interval enclosure theorem diagram |
| `eml_dynamical_systems.svg` | Three EML maps comparison |
| `eml_computation_graph.svg` | EML trees for exp, ln, subtraction |
| `oiscc_architecture.svg` | Processor architecture diagram |

---

## Research Papers

| Paper | Description |
|-------|-------------|
| **`oiscc_open_problems_resolved.md`** | **NEW** — Resolved open problems with proofs |
| **`sciam_the_equation_that_does_everything.md`** | **NEW** — Scientific American feature article |
| **`future_research_directions_v4.md`** | **NEW** — 60+ open problems, team structure, timeline |
| **`important_questions_v2.md`** | **NEW** — 15 deep Q&A with mathematical detail |
| `oiscc_verified_foundations.md` | Comprehensive paper with verified results |
| `sciam_one_equation_to_rule_them_all.md` | Scientific American–style feature |
| `future_research_comprehensive.md` | 50+ open problems, hardware/software roadmap |

---

## Quick Start

### Lean 4
```bash
lake build EML
```

### Python
```bash
python3 EML/Demos/eml_kalman_filter.py           # Kalman filter demo
python3 EML/Demos/eml_signal_processing.py        # Signal processing demo
python3 EML/Demos/eml_neuromorphic_simulation.py   # Neuromorphic demo
python3 EML/Demos/eml_cryptographic_hash.py        # Hash function demo
python3 EML/Demos/eml_compiler.py                  # Compiler demo
python3 EML/Demos/eml_neural_network.py            # Neural network demo
```

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
| σ(x)      | ~7      | ~8       | **~15** |

---

## Key Identity

> **EML(ln(a), exp(b)) = e^(ln a) − ln(e^b) = a − b**

Because exp and ln cancel inside EML, the single operation EML captures all of arithmetic.

---

## Citation

Based on: Odrzywolek, A. (2025). "All elementary functions from a single operator."
