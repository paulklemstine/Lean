# DeltaNet Equivalence Experiment Results

## Method

Compared standard DeltaNet recurrence:
```
s_t = gate * s_{t-1} + k_t * v_t
```

With tropical DeltaNet analogue:
```
s_t = min(gate + s_{t-1}, k_t + v_t)
```

Using identical projection weights across three configurations.

## Results

| d_model | heads | seq_len | batch | MSE    | Tropical range | Standard range |
|---------|-------|---------|-------|--------|----------------|----------------|
| 64      | 4     | 16      | 2     | 3.66   | [-6.39, 2.01]  | [-2.47, 2.50]  |
| 128     | 8     | 32      | 2     | 12.99  | [-10.82, 1.42] | [-2.67, 2.16]  |
| 256     | 8     | 64      | 4     | 34.42  | [-21.76, 2.04] | [-3.11, 3.12]  |

## Interpretation

1. **High MSE**: The tropical recurrence diverges significantly from the standard one. This is expected because tropical algebra replaces multiplicative gating with additive min-gating, which has different accumulation dynamics.

2. **Negative drift**: Tropical outputs accumulate large negative values because `min(gate + state, input)` tends to shrink the state when gates are negative (which they are for decay). Standard DeltaNet uses sigmoid gates in (0,1) which prevent runaway growth.

3. **Implication for Qwen3.6**: Direct weight-space conversion from Qwen3.6's Gated DeltaNet to a tropical DeltaNet is **not viable** due to the structural mismatch. The recommended approach is:
   - **Behavior distillation**: Use Qwen3.6 as a teacher, train a CrystallineMoEModel with tropical DeltaNet blocks from scratch.
   - Do not attempt to map Qwen3.6 weights directly into tropical operations.

## Next Steps

- Design a CrystallineMoEModel architecture that mimics Qwen3.6's block structure but uses tropical recurrence
- Generate synthetic data from Qwen3.6 (via llama.cpp GGUF on CPU, or layer-wise loading on GPU)
- Distill into the CrystallineMoEModel
- Benchmark on Colab T4
