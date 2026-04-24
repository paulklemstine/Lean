# Crystalline Framework

A new AI framework for minimal-VRAM, high-speed inference inspired by tropical algebra and crystallization theory.

## Overview

Crystalline replaces standard neural network operations with tropical (min-plus) algebra:
- **Tropical matmul**: `C[m,n] = min_k(A[m,k] + B[k,n])` — zero multiplications
- **Crystallization**: Weights snapped to discrete values in {-1, 0, 1}
- **Sheffer completeness**: All operations decompose to NAND gates
- **DeltaNet-compatible**: Tropical gated recurrence for linear attention

## Quick Start

### Colab (Recommended)

Open `app_crystalline_qwen25.ipynb` in Google Colab with a GPU runtime.

### Local

```bash
pip install -r requirements-colab.txt
python -m pytest tests/test_crystalline.py -v
```

## Architecture

```
crystalline/
  core.py          -- Tropical primitives (add, mul, matmul, state_update)
  deltanet.py      -- CrystallineDeltaLayer with tropical recurrence
  moe.py           -- Tropical Mixture-of-Experts
  model.py         -- CrystallineModel and CrystallineConfig
  crystallize.py   -- Weight crystallization and Sheffer NAND
  triton_kernels.py -- GPU kernels (with PyTorch fallbacks)
  train.py         -- Distillation + crystallization training loop
```

## Pipeline

1. **Download**: Cache Qwen2.5 from HuggingFace to Google Drive
2. **Baseline**: Benchmark FP16 teacher model
3. **Distill**: Train Crystalline student with KL divergence + CE loss
4. **Crystallize**: Snap weights to {-1, 0, 1}
5. **Benchmark**: Measure VRAM, throughput, latency
6. **Telemetry**: Save results to Drive with pandas/matplotlib charts

## References to Lean Theorems

- `TropicalDeepLearningFoundations.lean` — tropical semiring primitives
- `CrystallizationTheory.lean` — weight clustering and error bounds
- `DistillationLoss.lean` — temperature-scaled KL divergence
- `NeuralCompilationTeams.lean` — synthesis trilemma and tropical bounds
- `SubQuadraticAttention.lean` — L1-distance attention

## License

Apache 2.0
