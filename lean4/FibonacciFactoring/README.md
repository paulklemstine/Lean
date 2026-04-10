# Fibonacci-Base Factoring: Exploiting Zeckendorf Arithmetic for Integer Factorization

## Overview

This project explores a novel approach to analyzing integer factorization through **Fibonacci base (Zeckendorf) arithmetic**. Every positive integer has a unique representation as a sum of non-consecutive Fibonacci numbers. We show that multiplication in this base has fundamentally different structural properties than binary multiplication:

- **Bidirectional carries**: The rule `2·F(n) = F(n+1) + F(n-2)` propagates digits both *upward* and *downward*, unlike binary's unidirectional carries.
- **Multi-position product spread**: A single digit interaction `F(i)·F(j)` contributes to multiple digit positions of the product.
- **Non-adjacency invariant**: No two consecutive digits can both be 1, reducing the search space by ~2.6× per digit.

## Contents

### Core Library
- **`fibonacci_base.py`** — Complete implementation of Zeckendorf encoding/decoding, normalized Fibonacci-base arithmetic (with correct bidirectional carries), multiplication with partial product tracking, and constraint analysis tools. Self-tested against all multiplications up to 50×50.

### Python Demos
- **`demo_factoring.py`** — Eight interactive demonstrations:
  1. Binary vs. Fibonacci constraint comparison
  2. Product digit spread analysis
  3. Constraint propagation for semiprimes
  4. Golden ratio structure in carries
  5. Parity and modular constraints (Pisano periods)
  6. Constrained factor enumeration
  7. Digit density patterns (primes vs. composites)
  8. Binary vs. Fibonacci multiplication cost

- **`demo_constraint_solver.py`** — End-to-end factoring demonstration showing search space reduction, digit-level constraint deduction, and carry cascade analysis for specific semiprimes.

### SVG Visuals (`visuals/`)
Seven publication-quality SVG diagrams:
1. **Zeckendorf representation overview** — How numbers are written in Fibonacci base
2. **Binary vs. Fibonacci multiplication** — Side-by-side comparison of the two multiplication processes
3. **Carry propagation diagram** — The bidirectional carry rule visualized
4. **Product spread heatmap** — How F(i)·F(j) products distribute across digit positions
5. **Factoring worked example** — Step-by-step multiplication of 17 × 19 = 323
6. **Constraint entanglement web** — How a single carry cascades across 6+ positions
7. **Pisano periodicity** — Modular structure of Fibonacci numbers

### Written Materials
- **`research_paper.md`** — Full research paper with theorems, proofs, experimental results, and open questions.
- **`scientific_american_article.md`** — Accessible popular science article: "The Golden Key: How Fibonacci Numbers Could Crack the Code of Factoring"
- **`applications_brainstorm.md`** — 30+ application ideas across cryptography, error-correcting codes, hardware design, machine learning, signal processing, quantum computing, and more, with priority rankings.

## Quick Start

```bash
# Run self-tests
python3 fibonacci_base.py

# Run all demos
python3 demo_factoring.py

# Run constraint solver demo
python3 demo_constraint_solver.py

# Generate SVG visuals
python3 generate_visuals.py
```

## Key Insight

In binary multiplication, when column `i` overflows (value ≥ 2), the carry goes to column `i+1` only. In Fibonacci multiplication, the carry goes to column `i+1` **AND** column `i-2`. This means:

```
Binary:    overflow at position 8 → affects position 9
Fibonacci: overflow at position 8 → affects positions 9, 6, 7, 4, 5, 2, ...
```

A single overflow can cascade across **two-thirds** of all digit positions, creating a web of constraints that couples distant digit positions of the factors. This structural richness is absent in binary and suggests new avenues for constraint-based factoring algorithms.
