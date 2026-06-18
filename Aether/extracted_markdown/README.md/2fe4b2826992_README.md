# 🌌 The Algebraic Theory of Space

> *"Space is not the stage. Space is the algebra of observations upon it."*

## Overview

This directory contains the complete development of the **Algebraic Theory of Space** —
a unified framework demonstrating that every concept of spatial geometry (points,
topology, dimension, continuity, curvature) emerges from purely algebraic structures.

## Contents

### 📓 Oracle Notes (`oracle_notes/`)
Research process documented as a dialogue between seven specialist oracles:
- `00_divine_consultation.md` — The initial oracle consultation establishing the five pillars
- `01_oracle_team_assembly.md` — Assembly of the seven-oracle research team
- `02_research_log.md` — Complete research log with hypotheses, experiments, and validations

### 🎨 Python Demos (`demos/`)
Six interactive visualization scripts with 13 generated figures:

| Script | Pillar | Figures |
|--------|--------|---------|
| `01_points_from_algebra.py` | I: Points | Spec(ℝ[x]), Spec(ℝ[x,y]), Spec(ℤ) |
| `02_zariski_topology.py` | II: Topology | Galois connection, Zariski vs Euclidean |
| `03_krull_dimension.py` | III: Dimension | Dimension ladder, product rule |
| `04_arrows_reverse.py` | IV: Continuity | Contravariance principle |
| `05_curvature_from_derivations.py` | V: Curvature | Surfaces, parallel transport |
| `06_grand_unification.py` | Synthesis | Rosetta Stone, theory map |

### 📄 Research Paper (`paper/`)
- `research_paper.md` — Full academic research paper with 10 sections
- `scientific_american_article.md` — Popular science article for general audiences

### 🔧 Lean Formalization (`lean/`)
- `AlgebraicSpaceTheory.lean` — 12 formally verified theorems covering all five pillars

Also available as a buildable Lean module at `AlgebraicSpaceTheory/AlgebraicSpaceTheory.lean`.

## The Five Pillars

| # | Spatial Concept | Algebraic Concept | Status |
|---|----------------|-------------------|--------|
| I | **Points** | Maximal ideals / Characters | ✅ Formalized |
| II | **Topology** | Ideal lattice / Zariski topology | ✅ Formalized |
| III | **Dimension** | Krull dimension (prime chains) | ✅ Formalized |
| IV | **Continuity** | Ring homomorphisms (contravariant) | ✅ Formalized |
| V | **Curvature** | Commutator of derivations | ✅ Formalized |

## Running the Demos

```bash
cd demos/
pip install matplotlib numpy
python 01_points_from_algebra.py
python 02_zariski_topology.py
python 03_krull_dimension.py
python 04_arrows_reverse.py
python 05_curvature_from_derivations.py
python 06_grand_unification.py
```

## Building the Lean Proofs

```bash
lake build AlgebraicSpaceTheory.AlgebraicSpaceTheory
```

All 12 theorems compile without `sorry` — fully machine-verified.
