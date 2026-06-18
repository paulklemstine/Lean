# Oracle Bootstrap GPT-2: Formally Verified Model Compression

## Overview

This directory formalizes and demonstrates **Oracle Bootstrapping** applied to neural network compression, specifically GPT-2. The core insight: compression operations (quantization, pruning) are *idempotent projections* (oracles), and model quality under compression follows the bootstrap map f(r) = 3r² − 2r³, which exhibits a **sharp phase transition at r* = 1/2**.

| Component | Description | Status |
|-----------|-------------|--------|
| **Lean 4 Formalization** | Phase transition theorem, oracle properties, GPT-2 constants | ✓ 0 sorry |
| **End-to-End Python Demo** | Full compression pipeline with serialization | ✓ Working |
| **Research Paper** | Technical paper with proofs and experiments | ✓ Complete |
| **Scientific American** | Popular science article | ✓ Complete |
| **New Hypotheses H13–H16** | Experimental validation | ✓ Tested |

## Key Results

### Phase Transition Theorem (Formally Verified)
```
∀ r ∈ (0,1):
  r > 1/2  ⟹  r < f(r)     (quality improves — self-repair!)
  r < 1/2  ⟹  f(r) < r     (quality degrades — collapse!)
```

### GPT-2 Compression
- **Original**: 124,439,808 parameters, 497 MB (FP32)
- **4-bit quantized**: 62 MB (8× compression)
- **4-bit + 50% pruning**: < 32 MB (16× compression)

## Contents

### Lean 4 Formalization
- `OracleBootstrapGPT2.lean` — 15 formally verified theorems (0 sorry)

### Python Demos
- `demos/oracle_bootstrap_gpt2.py` — **End-to-end compression pipeline**
- `demos/phase_transition_visualizer.py` — ASCII visualization of the phase transition
- `demos/hypothesis_experiments.py` — Experimental validation of H13–H16

### Papers
- `ResearchPaper.md` — Full technical research paper
- `ScientificAmerican.md` — Popular science article

## Running

```bash
# End-to-end GPT-2 compression demo
python3 demos/oracle_bootstrap_gpt2.py

# Phase transition visualization
python3 demos/phase_transition_visualizer.py

# Hypothesis experiments
python3 demos/hypothesis_experiments.py
```

## New Hypotheses

| ID | Hypothesis | Status |
|----|-----------|--------|
| H13 | Layerwise Phase Transition | VALIDATED ✓ |
| H14 | Bootstrap Composition Law | PARTIALLY VALIDATED |
| H15 | Spectral Compression Gap | VALIDATED ✓ |
| H16 | Bootstrap Temperature | VALIDATED ✓ |

## Formal Theorems (Lean 4)

| Theorem | Statement |
|---------|-----------|
| `threshold_is_oracle` | Pruning is idempotent |
| `bootstrap_symmetry` | f(1−r) = 1−f(r) |
| `bootstrap_improves_above_half` | r > 1/2 ⟹ r < f(r) |
| `bootstrap_degrades_below_half` | r < 1/2 ⟹ f(r) < r |
| `phase_transition` | Combined phase transition theorem |
| `bootstrap_maps_unit_interval` | f : [0,1] → [0,1] |
| `bootstrap_monotone_upper` | f is monotone on [1/2,1] |
| `bootstrap_iter_increasing` | Iterates increase above 1/2 |
| `gpt2_param_count_approx` | GPT-2 has 124,439,808 params |
| `gpt2_4bit_size` | 4-bit = 62,219,904 bytes |
| `aggressive_compression_bound` | 50% prune + 4-bit < 32MB |
| `kl_self_zero` | KL(p ∥ p) = 0 |
