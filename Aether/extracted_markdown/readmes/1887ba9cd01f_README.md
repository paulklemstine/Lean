# Fibonacci-Base Factoring: Exploiting Zeckendorf Arithmetic

## Overview

This project investigates integer factorization through the lens of Fibonacci-base (Zeckendorf) arithmetic. Every positive integer has a unique representation as a sum of non-consecutive Fibonacci numbers. We show that multiplication in this base exhibits fundamentally different structural properties than binary multiplication — most notably **bidirectional carry propagation** — creating a richer constraint landscape for analyzing factors.

## Project Structure

### Formal Mathematics (Lean 4)

- **`Basic.lean`** — Lean 4 formalization of core mathematical results with machine-verified proofs:

  **Carry Propagation & Identities:**
  - `fib_adjacency_rule`: F(n) + F(n+1) = F(n+2) — adjacency normalization
  - `fib_carry_rule`: 2·F(n+2) = F(n+3) + F(n) — **the key bidirectional carry identity**
  - `carry_reaches_down`: 2·F(n) = F(n+1) + F(n-2) for n ≥ 4
  - `fib_triple`: 3·F(n) = F(n+2) + F(n-2) — iterated carry rule
  - `fib_ge_half`: n ≤ 2·F(n) for n ≥ 1 — Fibonacci growth bound

  **Product Identities:**
  - `cassini_even` / `cassini_odd`: Cassini's identity (both parities)
  - `fib_docagne_even`: d'Ocagne identity
  - `fib_vajda_even` / `fib_vajda_odd`: Vajda's identity — **key for product spread analysis**
  - `fib_add_formula`: F(m+n+1) = F(m)·F(n) + F(m+1)·F(n+1) — addition formula

  **Search Space & Counting:**
  - `noAdjacentOnes_eq_fib`: #{binary strings of length n with no adjacent 1s} = F(n+2)
  - `zeckendorf_search_space_smaller`: F(n+2) < 2^n for n ≥ 2
  - `zeckendorf_fraction_decreasing`: F(n+3) < 2^(n+1) for n ≥ 2

  **Pisano Period & Divisibility:**
  - `fib_mod_periodic`: ∃ π > 0, ∀ n, F(n+π) ≡ F(n) (mod m) — Pisano period existence
  - `pisano_period_2` / `pisano_period_3` / `pisano_period_5`: concrete Pisano periods
  - `fib_gcd`: gcd(F(m), F(n)) = F(gcd(m,n))
  - `fib_dvd_fib_mul`: F(n) | F(k·n)

  **Parity Structure:**
  - `fib_3k_even`: F(3k) is even for k ≥ 1
  - `fib_3k1_odd` / `fib_3k2_odd`: F(3k+1) and F(3k+2) are odd

  **Product Spread (Computational Verification):**
  - F(2k+1)² Zeckendorf decompositions for k = 1..4, confirming spread = k+1
  - Constraint density examples: F(i)·F(j) spread across multiple positions

  All proofs are complete — **zero `sorry` statements**, standard axioms only.

### Python Implementations

- **`fibonacci_base.py`** — Core library: Zeckendorf encoding/decoding, normalization, multiplication, constraint analysis
- **`demo_factoring.py`** — 8 interactive demos showing binary vs. Fibonacci constraint comparison, product spread, carry propagation, parity constraints, and more
- **`demo_constraint_solver.py`** — Constraint-propagation factoring demo with search space statistics
- **`demo_analysis.py`** — Quantitative analysis for the five research questions: search space ratios, constraint density, carry cascades, digit patterns, constraint graph properties, Pisano periods

### SVG Visualizations (`visuals/`)

1. **Zeckendorf Overview** — How numbers are represented in Fibonacci base
2. **Binary vs. Fibonacci** — Side-by-side comparison of digit structures
3. **Carry Propagation** — Bidirectional carry rule visualization
4. **Product Spread** — How F(i)·F(j) spreads across positions
5. **Factoring Example** — Worked example: 17 × 19 = 323
6. **Constraint Web** — Constraint graph structure
7. **Pisano Periodicity** — Fibonacci mod m patterns
8. **Constraint Graph Comparison** — Binary vs. Fibonacci graph structure
9. **Search Space Comparison** — 2^n vs. φ^(1.44n) growth

### Research Documents

- **`research_paper.md`** — Full technical paper with theorems, proofs, and analysis
- **`scientific_american_article.md`** — Popular science article for general audiences
- **`research_questions_analysis.md`** — Detailed answers to the five open research questions
- **`applications_brainstorm.md`** — 30+ application ideas across cryptography, coding theory, hardware, ML, physics, and more

## Key Results

### Formally Verified (Lean 4)

| Theorem | Statement |
|---------|-----------|
| `fib_adjacency_rule` | F(n) + F(n+1) = F(n+2) |
| `fib_carry_rule` | 2·F(n+2) = F(n+3) + F(n) |
| `fib_triple` | 3·F(n) = F(n+2) + F(n-2) for n ≥ 2 |
| `noAdjacentOnes_eq_fib` | #{valid strings of length n} = F(n+2) |
| `zeckendorf_search_space_smaller` | F(n+2) < 2^n for n ≥ 2 |
| `cassini_even` / `cassini_odd` | F(n)·F(n+2) + (-1)^n = F(n+1)² |
| `fib_vajda_even` / `fib_vajda_odd` | Vajda's identity for Fibonacci products |
| `fib_docagne_even` | d'Ocagne's identity |
| `fib_add_formula` | F(m+n+1) = F(m)F(n) + F(m+1)F(n+1) |
| `fib_mod_periodic` | ∃ π > 0, ∀ n, F(n+π) ≡ F(n) (mod m) |
| `pisano_period_2/3/5` | Concrete Pisano periods for m=2,3,5 |
| `fib_gcd` | gcd(F(m), F(n)) = F(gcd(m,n)) |
| `fib_dvd_fib_mul` | F(n) ∣ F(k·n) |
| `fib_3k_even` | 2 ∣ F(3k) for k ≥ 1 |
| `fib_3k1_odd` / `fib_3k2_odd` | F(3k+1), F(3k+2) are odd |

### Research Question Answers (Summary)

1. **Complexity**: No provable asymptotic speedup, but different constraint structure provides complementary information
2. **Hybrid approaches**: Natural integration points with QS, NFS, and ECM via modular filtering
3. **Optimal base**: Fibonacci (golden ratio) is maximally constrained among Ostrowski systems
4. **Quantum**: Marginal advantage for Grover-based approaches; interesting Fibonacci anyon connection
5. **SAT/CSP**: Treewidth Θ(n) same as binary, but higher local clustering and longer-range edges

## Running the Code

```bash
# Python demos
python3 fibonacci_base.py          # Self-tests and basic demo
python3 demo_factoring.py          # Interactive factoring demonstrations
python3 demo_constraint_solver.py  # Constraint solver demo
python3 demo_analysis.py           # Quantitative analysis

# Generate SVG visuals
python3 generate_visuals.py
python3 generate_treewidth_visual.py

# Build Lean formalization
lake build FibonacciFactoring
```
