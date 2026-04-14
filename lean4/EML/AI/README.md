# EML for AI and Machine Learning

## Overview

This directory contains the formally verified mathematical foundations, Python demonstrations, SVG visualizations, and research papers for applying the EML (Exp-Minus-Log) operator to artificial intelligence and machine learning.

## Directory Structure

```
EML/AI/
├── README.md                     # This file
├── UniversalApproximation.lean   # Stone-Weierstrass prerequisites (all verified ✅)
├── TrainingDynamics.lean         # Dual-gradient decomposition (verified ✅)
├── LearningTheory.lean           # VC dimension, MDL bounds (verified ✅)
├── EMLNeuralNetworks.lean        # EML neuron properties (verified ✅)
├── FormulaCompression.lean       # Compression ratios (verified ✅)
├── SymbolicRegression.lean       # Search space completeness (verified ✅)
├── DepthEfficiency.lean          # NEW: Depth vs width theorems (verified ✅)
├── PACLearning.lean              # NEW: PAC bounds, minimax rates (verified ✅)
├── Demos/
│   ├── eml_dual_gradient_training.py  # Dual-gradient phase transition demo
│   ├── eml_symbolic_distillation.py   # NN → EML formula distillation
│   ├── eml_mcts_regression.py         # MCTS symbolic regression
│   └── eml_scientific_discovery.py    # Automated physics law discovery
├── Visuals/
│   ├── dual_gradient_dynamics.svg     # Gradient decomposition visualization
│   ├── eml_ai_architecture.svg        # Full EML-AI pipeline architecture
│   ├── eml_depth_vs_width.svg         # Depth efficiency comparison
│   └── eml_distillation_pipeline.svg  # Distillation pipeline diagram
└── Papers/
    ├── future_research_eml_ai_ml.md   # Comprehensive research paper (50+ directions)
    ├── scientific_american_eml_ai.md  # Popular science article
    └── applications_brainstorm.md     # Applications and open questions
```

## Key Results (Formally Verified)

| # | Result | File | Status |
|---|--------|------|--------|
| 1 | EML neurons separate points | `UniversalApproximation.lean` | ✅ |
| 2 | EML neurons are nonvanishing | `UniversalApproximation.lean` | ✅ |
| 3 | EML neurons are continuous | `UniversalApproximation.lean` | ✅ |
| 4 | Gradient decomposes into exp + log | `TrainingDynamics.lean` | ✅ |
| 5 | Gradient explosion/vanishing bounds | `TrainingDynamics.lean` | ✅ |
| 6 | VC dimension ≤ 2k | `LearningTheory.lean` | ✅ |
| 7 | VC(EML) < VC(NN) | `LearningTheory.lean` | ✅ |
| 8 | MDL = 2k + kb | `LearningTheory.lean` | ✅ |
| 9 | 250× compression ratio | `FormulaCompression.lean` | ✅ |
| 10 | Kepler's Third Law in EML | `SymbolicRegression.lean` | ✅ |
| 11 | Tower functions via depth | `DepthEfficiency.lean` | ✅ |
| 12 | Depth exponentially beats width (d≥3) | `DepthEfficiency.lean` | ✅ |
| 13 | Lipschitz bounds for EML neurons | `DepthEfficiency.lean` | ✅ |
| 14 | Complexity subadditivity | `DepthEfficiency.lean` | ✅ |
| 15 | Self-adjoint for Stone-Weierstrass | `DepthEfficiency.lean` | ✅ |
| 16 | PAC sample complexity | `PACLearning.lean` | ✅ |
| 17 | EML sample advantage over NNs | `PACLearning.lean` | ✅ |
| 18 | Optimal complexity k* ≈ n^(1/4) | `PACLearning.lean` | ✅ |
| 19 | Catalan topology counting | `PACLearning.lean` | ✅ |
| 20 | Topology bits are linear | `PACLearning.lean` | ✅ |

## Running the Demos

```bash
cd EML/AI/Demos
python eml_dual_gradient_training.py    # See gradient phase transitions
python eml_symbolic_distillation.py     # Distill NNs to formulas
python eml_mcts_regression.py           # Discover formulas via MCTS
python eml_scientific_discovery.py      # Rediscover physical laws
```

## Building the Lean Files

```bash
lake build EML.AI.DepthEfficiency
lake build EML.AI.PACLearning
```

All Lean files compile without sorry (zero remaining proof obligations in the new files).
