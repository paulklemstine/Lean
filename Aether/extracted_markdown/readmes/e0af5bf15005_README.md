# Tropical Neural Networks: A Unified Research Project

## Overview

This project investigates five frontiers of tropical neural networks — neural networks whose operations are interpreted in the tropical (max-plus) semiring **(ℝ ∪ {-∞}, max, +)**. It combines formal verification (Lean 4), computational experiments (Python), and theoretical analysis.

The core identity: **ReLU(x) = max(x, 0) = x ⊕ₜ 0** — the most important nonlinearity in deep learning IS a tropical operation.

## Research Areas

| # | Area | Status | Key Finding |
|---|------|--------|-------------|
| 1 | **Tropical Vision Transformers** | Early-stage | Attention crystallizes via Maslov dequantization (T→0) |
| 2 | **Self-Learning Tropical NNs** | Validated (small scale) | Evolutionary training outperforms subgradient descent |
| 3 | **Zero-Shot Compilation** | Exact for ReLU | Combinatorial explosion at GPT-2 scale |
| 4 | **GPT-2 Tropical Compilation** | MLP exact, attention approx | GELU gap bounded, LayerNorm → projective |
| 5 | **Tropical Training** | Three approaches proposed | Maslov training protocol preserves accuracy |

## Project Structure

```
TropicalNeuralNetworks/
├── README.md                     # This file
├── demos/                        # Python implementations
│   ├── demo1_tropical_semiring.py          # Semiring foundations
│   ├── demo2_relu_tropical_compilation.py  # ReLU → tropical compilation
│   ├── demo3_tropical_attention.py         # Tropical ViT & attention
│   ├── demo4_tropical_training.py          # Training algorithms
│   └── demo5_tropical_geometry_visualization.py  # Geometry & grand diagram
├── visuals/                      # Generated figures (9 PNG files)
│   ├── tropical_semiring_foundations.png
│   ├── relu_tropical_compilation.png
│   ├── relu_1d_tropical.png
│   ├── attention_annealing.png
│   ├── logsumexp_convergence.png
│   ├── tropical_training_comparison.png
│   ├── tropical_training_curves.png
│   ├── tropical_geometry.png
│   └── grand_unified_diagram.png
├── notes/
│   └── research_notes.md          # Detailed research log
└── paper/
    ├── tropical_neural_networks.md     # Full research paper
    └── scientific_american_article.md  # Popular science article
```

## Formal Verification (Lean 4)

Machine-verified proofs are in `../Tropical/`:
- `TropicalNNCompilation.lean` — Core semiring, ReLU identity, compilation
- `TropicalViTFormalization.lean` — ViT formalization, LogSumExp bounds
- `TropicalNNFrontier.lean` — Advanced theorems

## Running the Demos

```bash
pip install numpy matplotlib
cd TropicalNeuralNetworks

python demos/demo1_tropical_semiring.py          # ~2s
python demos/demo2_relu_tropical_compilation.py  # ~30s (region enumeration)
python demos/demo3_tropical_attention.py         # ~5s
python demos/demo4_tropical_training.py          # ~30s (training loops)
python demos/demo5_tropical_geometry_visualization.py  # ~5s
```

All demos generate figures in `visuals/`.

## Key Equations

| Name | Equation | Significance |
|------|----------|-------------|
| Tropical addition | a ⊕ b = max(a, b) | Replaces classical + |
| Tropical multiplication | a ⊙ b = a + b | Replaces classical × |
| ReLU identity | ReLU(x) = x ⊕ 0 | Core bridge to deep learning |
| Maslov dequantization | T·log(Σexp(xᵢ/T)) → max(xᵢ) | Softmax → tropical max |
| LSE bound | max(x) ≤ LSE_T(x) ≤ max(x) + T·log(n) | Quantitative control |
| Tropical compilation | f(x) = max_σ(A_σx + b_σ) | ReLU nets = tropical polys |

## Novel Hypotheses

1. **Tropical Interpretability**: The tropical form IS the mechanistic explanation
2. **Tropical Compression**: Store K active regions instead of N neurons
3. **Tropical Continual Learning**: max(old, new) ≥ old — never forget
4. **Tropical Phase Transition**: Critical temperature T* separating smooth/crystalline
5. **Tropical-Optimal Transport**: Tropical polys as natural Wasserstein approximators
