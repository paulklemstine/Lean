# Meta-Oracle Research: Five Cross-Domain Mathematical Hypotheses

## Overview

This research project investigates five hypotheses connecting disparate areas of mathematics, combining computational experiments, theoretical analysis, and formal verification in Lean 4.

## Structure

```
research/
├── README.md                          # This file
├── research_paper.md                  # Full technical paper
├── scientific_american_article.md     # Popular science writeup
├── applications.md                    # Proposed applications
├── demos/                             # Python experiments
│   ├── run_all.py                     # Master runner (runs all 5)
│   ├── hypothesis1_constellation_rigidity.py
│   ├── hypothesis2_spectral_mass_gap.py
│   ├── hypothesis3_fluid_prediction.py
│   ├── hypothesis4_approximation_universality.py
│   └── hypothesis5_erdos_straus.py
└── figures/                           # Experimental results (JSON)
    ├── hypothesis1_results.json
    ├── hypothesis2_results.json
    ├── hypothesis3_results.json
    ├── hypothesis4_results.json
    └── hypothesis5_results.json

core/Exploration/
└── MetaOracleHypotheses.lean          # Lean 4 formalizations
```

## Results Summary

| # | Hypothesis | Status | Key Finding |
|---|-----------|--------|-------------|
| 1 | **Constellation Rigidity** | ✅ CONFIRMED | G(n) ~ α·C₂(n)·n·ρ(n)² recovers Hardy-Littlewood |
| 2 | **Spectral Mass Gap** | 🟡 PARTIAL | Analogy-level; de Bruijn-Newman as mass parameter |
| 3 | **Fluid Prediction Hardness** | 🟡 PARTIAL | Forward direction supported; refined to decidability link |
| 4 | **Approximation Universality** | ✅ SUPPORTED | Lonely Runner + Littlewood unify via torus equidistribution |
| 5 | **Erdős-Straus Density** | 🔄 REFINED | Growth is D(n) ~ d(n)^α, not log(n); r=0.93 with d(n)² |

## Running the Experiments

```bash
pip install numpy scipy
python research/demos/run_all.py         # Run all 5 experiments
python research/demos/hypothesis1_constellation_rigidity.py  # Run individually
```

## Lean Formalizations

```bash
lake build core.Exploration.MetaOracleHypotheses
```

### What's Proven (no sorry)
- Lonely Runner base case (2 runners): `lonely_runner_two`
- Erdős-Straus for specific values: `erdos_straus_three`, `erdos_straus_five`, `erdos_straus_seven`
- Erdős-Straus for all even n: `erdos_straus_even`
- Erdős-Straus for all multiples of 4: `erdos_straus_div4`
- Erdős-Straus for all multiples of 3: `erdos_straus_div3`
- Prime counting bounds: `primeCount_le`, `primeCount_one`, `primeCount_two`
- Fractional distance properties: `fracDist_nonneg`, `fracDist_le_half`

### Formal Statements (open)
- `constellationRigidity`: Hardy-Littlewood Conjecture B in density form
- `irrational_orbit_dense`: Equidistribution of irrational multiples (sorry — Kronecker's theorem)

## Generated Hypotheses for Future Work

1. **de Bruijn-Newman Mass Correspondence:** Λ = lim f(Δ_N)/N²
2. **Decidability-Regularity Principle:** Blow-up prediction complexity = blow-up logical complexity
3. **Divisor Decomposition Law:** D(n) ~ C·d(n)^α for universal C, α
4. **Dual Equidistribution Theorem:** Avoidance and achievement controlled by same Diophantine data
5. **Goldbach-Density Equivalence:** Density-squared formula ⟺ Hardy-Littlewood Conjecture B
