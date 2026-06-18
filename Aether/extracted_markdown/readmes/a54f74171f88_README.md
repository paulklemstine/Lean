# The Riemann Connection: Integer Energy and Robin's Inequality

## Overview

This directory contains a comprehensive research package investigating the
Riemann Hypothesis through the lens of **integer energy** and **Robin's inequality**.

### The Core Insight

The Riemann Hypothesis — the most important unsolved problem in mathematics — is
equivalent to a simple arithmetic statement: the divisor energy σ(n)/n of every
integer n ≥ 5041 is bounded by e^γ · ln(ln(n)). The number **5040 = 7!** is the
last integer whose energy exceeds this ceiling.

## Contents

### Research Documents

| File | Description |
|------|-------------|
| `ORACLE_TEAM_NOTES.md` | Detailed research notes from the Oracle team investigation |
| `RESEARCH_PAPER.md` | Formal research paper with computational and theoretical results |
| `SCIENTIFIC_AMERICAN_ARTICLE.md` | Accessible article for general audiences |

### Python Demos (with visualizations)

| Script | Description | Outputs |
|--------|-------------|---------|
| `demos/demo1_robin_inequality.py` | Robin's inequality verification & landscape | `robin_inequality_landscape.png`, `energy_champions.png`, `why_5040_is_special.png` |
| `demos/demo2_energy_landscape.py` | Multi-dimensional energy landscape | `energy_landscape.png`, `robin_heatmap.png`, `colossally_abundant_approach.png` |
| `demos/demo3_prime_zeta_connection.py` | Prime distribution, zeta zeros, explicit formula | `prime_zeta_connection.png`, `prime_zeta_explicit.png`, `euler_product_connection.png` |
| `demos/demo4_lagarias_and_nicolas.py` | Three equivalent formulations of RH | `three_formulations.png`, `harmonic_connection.png` |
| `demos/demo5_energy_thermodynamics.py` | Thermodynamic framework for integer energy | `energy_thermodynamics.png`, `top_energy_champions.png` |

### Visualizations

All 13 generated PNG files are in `visuals/`.

### Lean 4 Formalization

The formal proofs are in `../RiemannConnection.lean`, containing:
- σ(5040) = 19344 (machine-verified)
- 5040 = 7! (machine-verified)
- d(5040) = 60 (machine-verified)
- Robin's inequality as a formal predicate
- Conditional consequences of Robin's inequality (i.e., assuming RH)
- Divisor function properties (σ at primes, abundance bounds)
- Highly composite and superabundant number characterizations
- Energy advantage comparisons (HCN vs prime)

**All proofs compile without sorry or non-standard axioms.**

## Running the Demos

```bash
pip install matplotlib numpy
python demos/demo1_robin_inequality.py
python demos/demo2_energy_landscape.py
python demos/demo3_prime_zeta_connection.py
python demos/demo4_lagarias_and_nicolas.py
python demos/demo5_energy_thermodynamics.py
```

## Key Results

1. **Robin's inequality verified** for all n ∈ [5041, 20000] — all 26 violations lie at or below 5040
2. **Three equivalent formulations** (Robin, Lagarias, Nicolas) all verified computationally
3. **5040 = 7!** identified as the critical boundary due to its extremal factorization structure
4. **Thermodynamic framework** interpreting RH as an energy equilibrium transition
5. **Machine-verified proofs** in Lean 4 establishing key numerical and structural facts
