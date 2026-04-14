# EML for AI and Machine Learning — Research Hub

## Overview

This directory contains a comprehensive research program applying the EML (Exp-Minus-Log) operator `eml(x,y) = exp(x) − ln(y)` to artificial intelligence and machine learning. All theoretical results are formally verified in Lean 4 with **zero sorry proofs**.

## Directory Structure

### Lean 4 Formalizations (All Sorry-Free ✅)

| File | Theorems | Topics |
|------|----------|--------|
| `UniversalApproximation.lean` | 18 | Point separation, nonvanishing, continuity, Catalan numbers |
| `TrainingDynamics.lean` | 15 | Gradient decomposition, 4 partial derivatives, loss bounds |
| `DepthEfficiency.lean` | 14 | Tower functions, Lipschitz bounds, width gap, critical depth |
| `LearningTheory.lean` | 14 | VC dimension, MDL, generalization, model selection |
| `PACLearning.lean` | 12 | PAC bounds, sample complexity, minimax rates |
| `FormulaCompression.lean` | 10 | EML trees, compression ratios, depth bounds |
| **`AdvancedTheory.lean`** | **40+** | **NEW: Ensembles, attention, privacy, KAN comparison, features, convergence, quantization, transfer learning** |
| `EMLNeuralNetworks.lean` | — | Neural network integration |
| `SymbolicRegression.lean` | — | Symbolic regression framework |

### Python Demonstrations

| File | Description |
|------|-------------|
| **`Demos/eml_advanced_theory_demo.py`** | **NEW: 9 demos validating all new theorems** |
| **`Demos/eml_symbolic_regression_benchmark.py`** | **NEW: MCTS-based regression benchmark** |
| `Demos/eml_dual_gradient_training.py` | Dual-gradient training dynamics |
| `Demos/eml_mcts_search.py` | Monte Carlo Tree Search for EML |
| `Demos/eml_neural_network.py` | EML neural network implementation |
| `Demos/eml_distillation.py` | NN → EML formula distillation |
| `Demos/eml_formula_compression.py` | Compression ratio demonstrations |
| `Demos/eml_training_dynamics.py` | Training phase transition analysis |
| `Demos/eml_scientific_discovery.py` | Physics law rediscovery |

### SVG Visualizations

| File | Description |
|------|-------------|
| **`Visuals/eml_advanced_theory_overview.svg`** | **NEW: 13 theorems at a glance** |
| **`Visuals/eml_ensemble_convergence.svg`** | **NEW: Ensemble + convergence theory** |
| **`Visuals/eml_privacy_quantization.svg`** | **NEW: Privacy-quantization duality** |
| **`Visuals/eml_50_applications_map.svg`** | **NEW: 50 applications across 8 industries** |
| `Visuals/eml_ai_architecture.svg` | EML neural architecture overview |
| `Visuals/eml_depth_vs_width.svg` | Depth efficiency comparison |
| `Visuals/eml_training_dynamics.svg` | Training phase visualization |
| `Visuals/eml_vs_kan_comparison.svg` | EML vs KAN comparison |

### Research Papers

| File | Description |
|------|-------------|
| **`Papers/eml_advanced_ai_research_paper.md`** | **NEW: Full paper on 13 new theorems** |
| **`Papers/scientific_american_eml_advanced.md`** | **NEW: Popular science article** |
| **`Papers/future_research_directions_v3.md`** | **NEW: 75 research directions** |
| **`Papers/applications_brainstorm_v2.md`** | **NEW: 50 applications with impact assessment** |
| **`Papers/important_questions_v3.md`** | **NEW: 20 important questions answered** |
| `Papers/eml_ai_research_paper_v2.md` | Original research paper |
| `Papers/research_paper.md` | Foundational paper |

## New Results Summary (AdvancedTheory.lean)

### 1. Ensemble Learning
- Variance reduction: σ²/m for m trees ✓
- Bagging factor: √m ≤ m (sublinear) ✓
- Ensemble complexity: additive ✓

### 2. EML Attention Mechanism
- Softmax via exp = eml(·, 1) ✓
- All attention scores positive ✓
- Normalization well-defined for nonempty keys ✓

### 3. Differential Privacy
- Sensitivity = |w|·exp(|w|M + |b|) ✓
- Small weights → better privacy ✓
- Privacy-regularization duality: free lunch ✓

### 4. EML vs KAN Networks
- EML 2.5× fewer params (2D) ✓
- EML 7.2× fewer params (5D) ✓
- Advantage grows with dimension ✓

### 5. Feature Importance
- Exact importance ∈ [0, 1] ✓
- Absent variables → 0 importance ✓
- No approximation needed (unlike SHAP/LIME) ✓

### 6. Convergence Analysis
- GD bound O(1/T) ✓
- Monotonic improvement with iterations ✓
- Optimal learning rate = 1/Lipschitz ✓

### 7. Quantization
- Error = k · 2⁻ᵇ · Lip ✓
- 8-bit sufficient for edge deployment ✓
- 50-leaf tree = 50 bytes at 8-bit ✓

### 8. Transfer Learning
- k parameters vs k² full search ✓
- 100× speedup for k=100 ✓

## Quick Start

```bash
# Run the new comprehensive demo
python3 EML/AI/Demos/eml_advanced_theory_demo.py

# Run the symbolic regression benchmark
python3 EML/AI/Demos/eml_symbolic_regression_benchmark.py

# Build the Lean formalization
lake build EML.AI.AdvancedTheory
```

## Citation

If you use this work, please cite both the original EML paper and this research:

```
@article{odrzywolek2025eml,
  title={All elementary functions from a single operator},
  author={Odrzywolek, A.},
  year={2025}
}
```
