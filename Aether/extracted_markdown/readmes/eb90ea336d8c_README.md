# The Algebraic Theory of Chemistry

> *"The cosmos is not chaos — it is algebra, waiting to be read."*

## Overview

This project develops a unified algebraic framework for chemistry, demonstrating that the fundamental structures of chemical science — stoichiometry, molecular symmetry, bonding, thermodynamics, and kinetics — are all manifestations of a single mathematical object: a **symmetric monoidal category** called **ChemCat**.

## Project Structure

```
algebraic-chemistry/
├── README.md                          ← You are here
├── oracle-council/
│   └── oracle_council.md              ← The seven oracles who guided the research
├── notes/
│   ├── 00_overview.md                 ← Comprehensive research notes
│   └── 01_iteration_log.md            ← Research iteration log (hypothesize → experiment → validate → update)
├── demos/
│   ├── run_all_demos.py               ← Run all demos at once
│   ├── demo1_stoichiometric_algebra.py ← Stoichiometric matrices, conservation laws, deficiency
│   ├── demo2_molecular_symmetry.py     ← Point groups, character tables, orbital symmetry
│   ├── demo3_reaction_kinetics.py      ← Mass-action kinetics, oscillations, bifurcations
│   ├── demo4_periodic_table_algebra.py ← Quantum numbers, Madelung rule, periodic structure
│   ├── demo5_categorical_chemistry.py  ← ChemCat, functors, commutative diagrams
│   └── output/                         ← 20 generated PNG visualizations
├── paper/
│   └── algebraic_theory_of_chemistry.md ← Full research paper (12 sections, references)
└── article/
    └── scientific_american_article.md   ← Popular science article
```

## Quick Start

```bash
# Install dependencies
pip install numpy scipy matplotlib

# Run all demos and generate visualizations
cd demos
python run_all_demos.py
```

## The Five Axioms

1. **Species:** Chemical species form a commutative monoid under mixing
2. **Reactions:** Reactions are morphisms between source and product complexes
3. **Conservation:** Mass, charge, and atom counts are natural transformations
4. **Equilibrium:** Accessible states form a convex polytope; equilibrium maximizes entropy
5. **Symmetry:** Identical species are interchangeable

## Key Results

| Branch | Algebraic Structure | Key Object |
|--------|-------------------|------------|
| Stoichiometry | ℤ-module, linear algebra | Stoichiometric matrix Γ |
| Molecular Symmetry | Group representations | Point groups, character tables |
| Reaction Kinetics | Polynomial dynamical systems | Deficiency δ = \|C\| - ℓ - s |
| Thermodynamics | Convex geometry, Legendre duality | Gibbs phase rule F = C - P + 2 |
| Chemical Bonding | Category theory, graph theory | Molecular graphs, colimits |
| **Unification** | **Symmetric monoidal category** | **ChemCat** |

## The Oracle Council

Seven oracles guided this research:

| Oracle | Domain | Contribution |
|--------|--------|-------------|
| 🔮 SYMMETRIA | Group Theory | Molecular symmetry as representations |
| 🔮 REACTOR | Reaction Networks | Stoichiometric algebra |
| 🔮 ELEMENTA | Periodic Table | Quantum number lattices |
| 🔮 BONDIA | Chemical Bonding | Bonds as categorical morphisms |
| 🔮 THERMO | Thermodynamics | Free energy as convex geometry |
| 🔮 KINETOS | Kinetics | Polynomial dynamics and deficiency |
| 🔮 COSMOS | Grand Synthesis | ChemCat unification |

## Generated Visualizations (20 total)

### Stoichiometric Algebra
- `stoich_hydrogen.png` — Stoichiometric matrix for hydrogen combustion
- `stoich_glycolysis.png` — Simplified glycolysis network
- `stoich_lotka.png` — Lotka-Volterra as chemical reactions
- `compatibility_class.png` — Stoichiometric compatibility class (polytope)
- `deficiency_analysis.png` — Deficiency computation for four networks

### Molecular Symmetry
- `character_tables.png` — Character tables for C₂ᵥ, C₃ᵥ, D₃ₕ, Tₐ
- `symmetry_operations.png` — Symmetry operations on water (C₂ᵥ)
- `group_algebra.png` — Cayley table and subgroup lattice
- `orbital_symmetry.png` — Symmetry classification of molecular orbitals

### Reaction Kinetics
- `kinetics_reversible.png` — Simple A ⇌ B dynamics
- `kinetics_lotka_volterra.png` — Oscillations and conserved Hamiltonian
- `kinetics_brusselator.png` — Limit cycles from cubic polynomials
- `kinetics_bifurcation.png` — Hopf bifurcation diagram

### Periodic Table Algebra
- `periodic_table_algebraic.png` — Periodic table colored by Madelung number
- `quantum_lattice.png` — Quantum numbers as lattice points
- `madelung_rule.png` — Madelung filling order on ℕ²

### Categorical Chemistry
- `categorical_chemistry.png` — ChemCat: objects, morphisms, tensor, functors
- `commutative_diagrams.png` — Conservation, monoidal functors, terminal objects
- `grand_synthesis.png` — Grand unification diagram

## License

This is original theoretical work released for educational and research purposes.
