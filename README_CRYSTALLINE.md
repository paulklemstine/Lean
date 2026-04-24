# Crystalline Framework

A new AI framework for minimal-VRAM, high-speed inference inspired by tropical algebra and crystallization theory.

[![Open Qwen2.5 Notebook](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/raver1975/lean/blob/master/app_crystalline_qwen25.ipynb)
[![Open Qwen3.6 Notebook](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/raver1975/lean/blob/master/app_crystalline_qwen36.ipynb)

## Overview

Crystalline replaces standard neural network operations with tropical (min-plus) algebra:
- **Tropical matmul**: `C[m,n] = min_k(A[m,k] + B[k,n])` — zero floating-point multiplications
- **Crystallization**: Weights snapped to discrete values in `{-1, 0, 1}`
- **Sheffer completeness**: All operations decompose to NAND gates for hardware simplicity
- **DeltaNet-compatible**: Tropical gated recurrence for linear attention complexity
- **MoE support**: Tropical router with expert offloading simulation for Qwen3.6-style architectures

## Quick Start

### Colab (Recommended)

| Notebook | Purpose |
|----------|---------|
| `app_crystalline_qwen25.ipynb` | Qwen2.5 baseline, distillation, crystallization |
| `app_crystalline_qwen36.ipynb` | Qwen3.6 config analysis, MoE simulation, DeltaNet research |

### Local

```bash
pip install -r requirements-colab.txt
python -m pytest tests/test_crystalline.py -v
```

## Architecture

```
crystalline/
  core.py            -- Tropical primitives (add, mul, matmul, state_update, dot_product)
  deltanet.py        -- CrystallineDeltaLayer with tropical recurrence
  moe.py             -- CrystallineRouter + CrystallineMoELayer with vectorized top-k routing
  model.py           -- CrystallineModel, CrystallineConfig, CrystallineMoEModel
  crystallize.py     -- Weight crystallization, Sheffer NAND, tropical_to_sheffer
  triton_kernels.py  -- GPU kernels (with PyTorch fallbacks)
  train.py           -- Distillation + crystallization training loop
```

## Pipeline

1. **Download**: Cache Qwen2.5 / Qwen3.6 config from HuggingFace to Google Drive
2. **Baseline**: Benchmark FP16 teacher model (TTFT, TPOT, tokens/sec, VRAM)
3. **Distill**: Train Crystalline student with KL divergence + CE loss + crystallization penalty
4. **Crystallize**: Snap weights to `{-1, 0, 1}`
5. **Benchmark**: Measure VRAM, throughput, latency
6. **Telemetry**: Save results to Drive with pandas/matplotlib charts

## Usage Example

```python
from crystalline import CrystallineModel, CrystallineConfig

config = CrystallineConfig(
    vocab_size=32000,
    d_model=512,
    num_layers=6,
    num_heads=8,
    use_delta_net=True,   # Enable tropical DeltaNet
    num_experts=8,        # Enable MoE
    top_k=2,
)
model = CrystallineModel(config)

# Train...
model.crystallize()  # Snap all weights to {-1, 0, 1}
```

## MoE + DeltaNet (Qwen3.6)

```python
from crystalline import CrystallineMoEModel

model = CrystallineMoEModel.from_qwen3_6_config(
    vocab_size=151936,
    d_model=512,
    num_layers=6,
    num_experts=8,
    top_k=2,
)

# Simulate expert offloading VRAM savings
sim = model.simulate_expert_offloading(
    num_experts=256,
    active_experts=8,
    vram_per_expert_mb=60.0,
)
print(sim["offload_ratio"])  # ~0.97
```

## References to Lean Theorems

- `TropicalDeepLearningFoundations.lean` — tropical semiring primitives
- `CrystallizationTheory.lean` — weight clustering and error bounds
- `DistillationLoss.lean` — temperature-scaled KL divergence
- `NeuralCompilationTeams.lean` — synthesis trilemma and tropical bounds
- `SubQuadraticAttention.lean` — L1-distance attention
- `MixtureOfExpertsTheory.lean` — MoE routing and load balancing

## Testing

```bash
# Crystalline framework tests
python -m pytest tests/test_crystalline.py -v

# Legacy qwen_optimizer tests
python -m pytest tests/test_all.py -v
```

## License

Apache 2.0
