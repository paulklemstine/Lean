# Fibonacci-Base Factoring: Exploiting Zeckendorf Arithmetic for Integer Factorization

## Overview

This project explores a novel approach to analyzing integer factorization through **Fibonacci base (Zeckendorf) arithmetic**. Every positive integer has a unique representation as a sum of non-consecutive Fibonacci numbers. We show that multiplication in this base has fundamentally different structural properties than binary multiplication:

- **Bidirectional carries**: The rule `2·F(n) = F(n+1) + F(n-2)` propagates digits both *upward* and *downward*, unlike binary's unidirectional carries.
- **Multi-position product spread**: A single digit interaction `F(i)·F(j)` contributes to multiple digit positions of the product.
- **Non-adjacency invariant**: No two consecutive digits can both be 1, reducing the search space by ~2.6× per digit.

## Contents

### Lean 4 Formalizations
- **`Basic.lean`** — 30+ formally verified theorems covering:
  - Fibonacci carry rules (bidirectional) and adjacency normalization
  - Cassini's identity (both parities), d'Ocagne and Vajda identities
  - Zeckendorf representation counting (F(k+2) valid k-digit strings)
  - Search space reduction (F(k+2) < 2^k for k ≥ 2)
  - Pisano period properties (mod 2, 3, 5)
  - Fibonacci GCD identity and divisibility
  - Parity structure of Fibonacci numbers
  - Product spread verification examples

- **`ResearchFormalization.lean`** — Formalizations addressing the 5 research questions:
  - Q1: Search space ratio and shrinkage rate (proven)
  - Q2: Fibonacci GCD identity and divisibility (ECM foundation)
  - Q3: Growth rate bounds (subexponential, coprimality)
  - Q5: Non-adjacency propagation (forward & backward), carry cascade reach
  - Pisano period constraints (mod 2 period 3, mod 6 period 24)

### Core Python Library
- **`fibonacci_base.py`** — Complete implementation of Zeckendorf encoding/decoding, normalized Fibonacci-base arithmetic (with correct bidirectional carries), multiplication with partial product tracking, and constraint analysis tools. Self-tested against all multiplications up to 50×50.

### Python Demos
- **`demo_factoring.py`** — Eight interactive demonstrations covering binary vs. Fibonacci comparison, product spread, constraint propagation, golden ratio structure, Pisano periods, digit density patterns.

- **`demo_constraint_solver.py`** — End-to-end factoring demonstration showing search space reduction, digit-level constraint deduction, and carry cascade analysis.

- **`demo_research_questions.py`** — Computational experiments for all 5 research questions:
  - Q1: Search space reduction measurements (2^k vs φ^k)
  - Q2: Pisano parity filter effectiveness
  - Q3: Comparison of Fibonacci, Tribonacci, binary, and Ostrowski bases
  - Q4: Grover speedup estimates and Fibonacci anyon connection
  - Q5: Constraint graph edge counts and treewidth estimates

### SVG Visuals (`visuals/`)
Thirteen publication-quality SVG diagrams:
1. **Zeckendorf representation overview** — How numbers are written in Fibonacci base
2. **Binary vs. Fibonacci multiplication** — Side-by-side comparison
3. **Carry propagation diagram** — Bidirectional carry rule visualized
4. **Product spread heatmap** — How F(i)·F(j) products distribute
5. **Factoring worked example** — Step-by-step 17 × 19 = 323
6. **Constraint entanglement web** — Carry cascades across 6+ positions
7. **Pisano periodicity** — Modular structure of Fibonacci numbers
8. **Search space reduction** (Q1) — Binary vs Fibonacci bar chart
9. **Hybrid strategies** (Q2) — Three hybrid approach flowcharts
10. **Base comparison** (Q3) — Constraint tightness number line
11. **Quantum landscape** (Q4) — Shor vs Grover vs Adiabatic
12. **Constraint graph comparison** (Q5) — Binary vs Fibonacci graph structure
13. **Application map** — Technology landscape with 8 domains

### Research Documents
- **`research_paper.md`** — Full research paper with theorems, proofs, experimental results, and open questions.
- **`research_answers.md`** — Detailed answers to all 5 open research questions with mathematical analysis and formal verification references.
- **`scientific_american_article.md`** — Accessible popular science article: "The Golden Key: How Fibonacci Numbers Could Crack the Code of Factoring"
- **`applications_brainstorm.md`** — 30+ application ideas across cryptography, error-correcting codes, hardware design, machine learning, signal processing, quantum computing, with priority rankings.

## Quick Start

```bash
# Run self-tests
python3 fibonacci_base.py

# Run all demos
python3 demo_factoring.py
python3 demo_constraint_solver.py
python3 demo_research_questions.py

# Generate SVG visuals
python3 generate_visuals.py
python3 generate_research_visuals.py
```

## Research Question Summary

| Question | Key Finding | Formalized? |
|----------|------------|-------------|
| Q1: Complexity | No asymptotic speedup; provable φ^k/2^k search reduction | ✓ Lean |
| Q2: Hybrid approaches | Three strategies: QS parity filter, NFS ℤ[φ], ECM Fibonacci | Partially ✓ |
| Q3: Optimal base | Golden ratio is universally optimal; √N-adapted is per-instance best | ✓ Growth bounds |
| Q4: Quantum | Fibonacci anyon connection; φ^(k/2) Grover improvement | Analysis |
| Q5: SAT/CSP | Treewidth ≈ 2k/3 vs k/2; 3× propagation advantage per decision | ✓ Lean |

## Key Insight

In binary multiplication, when column `i` overflows (value ≥ 2), the carry goes to column `i+1` only. In Fibonacci multiplication, the carry goes to column `i+1` **AND** column `i-2`. This means:

```
Binary:    overflow at position 8 → affects position 9
Fibonacci: overflow at position 8 → affects positions 9, 6, 7, 4, 5, 2, ...
```

A single overflow can cascade across **two-thirds** of all digit positions, creating a web of constraints that couples distant digit positions of the factors. This structural richness is absent in binary and suggests new avenues for constraint-based factoring algorithms.
