# Stereographic Neural Architectures

A research project formalizing and implementing **stereographic attention mechanisms** — a novel neural architecture that computes attention via stereographic projection onto the unit sphere. All core theorems are **machine-verified in Lean 4 with zero `sorry` statements**.

## Project Structure

```
StereographicNeural/
├── README.md                          # This file
├── research_paper.md                  # Full research paper (14 sections)
├── scientific_american_article.md     # Popular science article
├── applications.md                    # Applications across 13 domains
├── team.md                            # Research team structure & roadmap
├── demos/
│   ├── stereographic_attention.py     # Core implementation + demos
│   ├── train_stereographic_transformer.py  # Transformer architecture
│   ├── visualization_demo.py          # ASCII + geometric visualizations
│   └── multihead_and_moebius_demo.py  # Multi-head, Möbius, PE, gauge demos
└── visuals/
    ├── stereographic_attention_architecture.svg  # Architecture diagram
    ├── conformal_kernel_heatmap.svg              # Kernel visualization
    ├── gradient_flow_comparison.svg              # Gradient comparison
    ├── multihead_stereographic.svg               # Multi-head architecture
    ├── gauge_theory_connection.svg               # Gauge field visualization
    ├── positional_encoding_spiral.svg            # Spiral PE on sphere
    └── moebius_attention.svg                     # Möbius transform pipeline

Geometry/StereographicResearch/NeuralArchitectures/
├── StereographicAttention.lean        # Core kernel & attention (Lean 4)
├── SphericalNormalization.lean        # Spherical norm theory (Lean 4)
├── ConformalBackprop.lean             # Gradient flow analysis (Lean 4)
├── MultiHeadStereographic.lean        # Multi-head with rotated poles (Lean 4)
├── MoebiusTransforms.lean             # Learnable Möbius parameters (Lean 4)
├── StereographicPositionalEncoding.lean  # Spiral PE & geodesic bias (Lean 4)
├── GaugeTheory.lean                   # Gauge field, curvature, mass (Lean 4)
└── TrainingTheory.lean                # Convergence & regularization (Lean 4)
```

## Key Results (Formally Verified in Lean 4 — Zero `sorry` Statements)

### Core Attention (StereographicAttention.lean)
| Theorem | Description |
|---------|-------------|
| `invStereo_on_sphere` | Inverse stereographic projection maps to the unit sphere |
| `stereo_kernel_symmetric` | The conformal kernel is symmetric |
| `stereoKernel_rational` | Kernel equals rational function of inner products |
| `stereoKernel_bounded` | Kernel values are bounded by n+1 |
| `stereoSoftmaxWeight_pos` | Attention weights are always positive |
| `stereoAttention_weight_sum_pos` | Weight sums are positive |
| `conformal_factor_bounded` | Conformal factor is in (0, 2] |

### Spherical Normalization (SphericalNormalization.lean)
| Theorem | Description |
|---------|-------------|
| `stereo_spherical_norm_unit` | Spherical normalization produces unit vectors |
| `stereo_norm_zero_is_south_pole` | Zero maps to south pole |
| `stereo_norm_last_coord_bound` | Last coordinate bounded by 1 |
| `expMapNorm_unit` | Exponential map produces unit vectors |

### Gradient Flow (ConformalBackprop.lean)
| Theorem | Description |
|---------|-------------|
| `stereo_gradient_bounded` | Gradients bounded by 2× upstream gradient |
| `stereo_gradient_nonvanishing` | Positive gradients never vanish |
| `composedGradScale_bounded` | L-layer gradient bounded by 2^L |

### Multi-Head Attention (MultiHeadStereographic.lean)
| Theorem | Description |
|---------|-------------|
| `generalInvStereo_on_sphere` | General inverse stereo maps to sphere |
| `multiHeadKernel_symmetric` | Per-head kernel is symmetric |
| `multihead_weight_sum_pos` | Per-head weight sums are positive |
| `headConformalFactor_bounded` | Per-head conformal factor in (0,2] |
| `multihead_gradient_bounded` | Multi-head gradient bounded by 2H |

### Möbius Transforms (MoebiusTransforms.lean)
| Theorem | Description |
|---------|-------------|
| `moebiusDet_composition` | det(μ₁∘μ₂) = det(μ₁)·det(μ₂) |
| `idMoebius_det` | Identity has unit determinant |
| `moebiusConfFactor_nonneg` | Conformal factor is non-negative |
| `moebius_param_efficiency` | 8 params vs d² for linear projection |

### Positional Encoding (StereographicPositionalEncoding.lean)
| Theorem | Description |
|---------|-------------|
| `spiralPos_on_sphere` | Spiral PE lies on unit sphere |
| `stereoPosEnc_symm` | PE is symmetric |
| `stereoPosEnc_self` | Self-encoding = 1 |
| `relativePosBias_pos` | Geodesic bias is positive |
| `relativePosBias_le_one` | Geodesic bias ≤ 1 |
| `relativePosBias_self` | Self-bias = 1 |

### Gauge Theory (GaugeTheory.lean)
| Theorem | Description |
|---------|-------------|
| `gaugeField_positive` | Gauge field is positive |
| `gaugeField_le_two` | Gauge field ≤ 2 |
| `gaugeInvariantKernel_symm` | Gauge-invariant kernel is symmetric |
| `gaugeConnection_parity` | Connection has odd parity |
| `gaugeCurvature_zero_origin` | Curvature vanishes at origin |
| `effectiveMass_formula` | m(x) = (1+‖x‖²)/2 |
| `effectiveMass_pos` | Effective mass is positive |

### Training Theory (TrainingTheory.lean)
| Theorem | Description |
|---------|-------------|
| `stereo_gradient_advantage` | Stereo gradient ≤ 2 |
| `standard_gradient_unbounded` | Standard gradient is unbounded |
| `stereoLearningRate_decreasing` | LR schedule is decreasing |
| `sphericalRegularizer_nonneg` | Regularizer is non-negative |

## Five Open Questions — Addressed

1. **Multi-head stereographic attention** ✅ — Each head uses a different rotation R_h before projection, effectively projecting from a different pole. Formalized in `MultiHeadStereographic.lean`.

2. **Learnable Möbius transforms** ✅ — Möbius transforms f(z)=(az+b)/(cz+d) replace linear Q/K/V projections. Only 8 params per head (vs d²). Formalized in `MoebiusTransforms.lean`.

3. **Stereographic positional encoding** ✅ — Spiral curve on S² encodes positions. Geodesic distance provides natural position bias. Formalized in `StereographicPositionalEncoding.lean`.

4. **Gauge theory connection** ✅ — Conformal factor as U(1) gauge field, Möbius transforms as gauge transformations, effective mass via symmetry breaking. Formalized in `GaugeTheory.lean`.

5. **Training experiments** ✅ (theoretical) — Gradient advantage proofs, convergence bounds, learning rate schedules. Formalized in `TrainingTheory.lean`. Python demos provide forward-pass experiments.

## Running the Demos

```bash
pip install numpy
python demos/stereographic_attention.py
python demos/train_stereographic_transformer.py
python demos/visualization_demo.py
python demos/multihead_and_moebius_demo.py
```

## Building the Lean Proofs

```bash
lake build Geometry.StereographicResearch.NeuralArchitectures.StereographicAttention
lake build Geometry.StereographicResearch.NeuralArchitectures.SphericalNormalization
lake build Geometry.StereographicResearch.NeuralArchitectures.ConformalBackprop
lake build Geometry.StereographicResearch.NeuralArchitectures.MultiHeadStereographic
lake build Geometry.StereographicResearch.NeuralArchitectures.MoebiusTransforms
lake build Geometry.StereographicResearch.NeuralArchitectures.StereographicPositionalEncoding
lake build Geometry.StereographicResearch.NeuralArchitectures.GaugeTheory
lake build Geometry.StereographicResearch.NeuralArchitectures.TrainingTheory
```

All build with **zero errors** and **zero sorry statements**.
