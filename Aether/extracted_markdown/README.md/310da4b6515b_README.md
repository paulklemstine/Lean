# Stereographic Neural Architectures

A research project formalizing and implementing **stereographic attention mechanisms** — a novel neural architecture that computes attention via stereographic projection onto the unit sphere.

## Project Structure

```
StereographicNeural/
├── README.md                          # This file
├── research_paper.md                  # Full research paper
├── scientific_american_article.md     # Popular science article
├── applications.md                    # Applications across domains
├── team.md                            # Research team structure & roadmap
├── demos/
│   ├── stereographic_attention.py     # Core implementation + demos
│   ├── train_stereographic_transformer.py  # Transformer architecture demo
│   └── visualization_demo.py         # ASCII + geometric visualizations
└── visuals/
    ├── stereographic_attention_architecture.svg  # Architecture diagram
    ├── conformal_kernel_heatmap.svg              # Kernel visualization
    └── gradient_flow_comparison.svg              # Gradient comparison

Geometry/StereographicResearch/NeuralArchitectures/
├── StereographicAttention.lean        # Core kernel & attention (Lean 4)
├── SphericalNormalization.lean        # Spherical norm theory (Lean 4)
└── ConformalBackprop.lean             # Gradient flow analysis (Lean 4)
```

## Key Results (Formally Verified in Lean 4)

All theorems are machine-verified with zero `sorry` statements:

| Theorem | Description |
|---------|-------------|
| `invStereo_on_sphere` | Inverse stereographic projection maps to the unit sphere |
| `stereo_kernel_symmetric` | The conformal kernel is symmetric |
| `stereoKernel_rational` | Kernel equals rational function of inner products |
| `stereoKernel_bounded` | Kernel values are bounded by n+1 |
| `stereoSoftmaxWeight_pos` | Attention weights are always positive |
| `stereoAttention_weight_sum_pos` | Weight sums are positive (normalization is valid) |
| `conformal_factor_bounded` | Conformal factor is in (0, 2] |
| `conformal_factor_sq` | cf(x)² = 4/D(x)² |
| `conformal_factor_product` | cf(x)·cf(y) = 4/(D(x)·D(y)) |
| `stereo_gradient_bounded` | Gradients bounded by 2× upstream gradient |
| `stereo_gradient_nonvanishing` | Positive gradients never vanish |
| `composedGradScale_bounded` | L-layer gradient bounded by 2^L |
| `stereo_spherical_norm_unit` | Spherical normalization produces unit vectors |
| `stereo_norm_zero_is_south_pole` | Zero maps to south pole |
| `stereo_norm_last_coord_bound` | Last coordinate bounded by 1 |
| `expMapNorm_unit` | Exponential map normalization produces unit vectors |

## Running the Demos

```bash
pip install numpy
python demos/stereographic_attention.py
python demos/train_stereographic_transformer.py
python demos/visualization_demo.py
```

## Building the Lean Proofs

```bash
lake build Geometry.StereographicResearch.NeuralArchitectures.StereographicAttention
lake build Geometry.StereographicResearch.NeuralArchitectures.SphericalNormalization
lake build Geometry.StereographicResearch.NeuralArchitectures.ConformalBackprop
```
