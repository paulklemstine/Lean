# 🚀 Qwen Model Optimization Pipeline

**Download → Cache → Convert → Compress → Distill → Compress → Optimize → Deploy**

A complete, production-ready pipeline for running Qwen 2.5 and Qwen 3.6 models on Google Colab
with minimal VRAM and near-instantaneous inference. Grounded in formally verified compression
theory (Lean 4 proofs from this project).

## Quick Start (Google Colab)

1. Open `Qwen_Optimization_Colab.ipynb` in Google Colab
2. Select GPU runtime (T4 for free tier)
3. Run all cells
4. The model downloads, compresses, and benchmarks automatically
5. Results are cached to Google Drive for future sessions

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `AI_IDEAS_ANALYSIS.md` | Analysis of the project's AI formalization ideas |
| `qwen_optimization_pipeline.py` | Complete pipeline (CLI + library) |
| `Qwen_Optimization_Colab.ipynb` | Google Colab notebook (self-contained) |
| `requirements.txt` | Python dependencies |
| `RESEARCH_PAPER.md` | Research paper with future directions |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PIPELINE STAGES                          │
│                                                             │
│  Stage 0: Download & Cache                                  │
│  ├── HuggingFace Hub → Local storage                       │
│  └── Local → Google Drive (checkpointing)                  │
│                                                             │
│  Stage 1: Framework Conversion                              │
│  ├── vLLM (GPU serving, PagedAttention)                    │
│  ├── llama.cpp/GGUF (CPU/low-VRAM)                        │
│  └── ExLlamaV2 (consumer GPUs)                             │
│                                                             │
│  Stage 2: Quantization (COMPRESS #1)                       │
│  ├── AWQ 4-bit (default, best quality)                     │
│  ├── GPTQ 4-bit (optimal rounding)                         │
│  └── BitsAndBytes NF4 (fallback)                           │
│                                                             │
│  Stage 3: Pruning (COMPRESS #2)                            │
│  ├── Wanda (activation-aware, no retraining)               │
│  └── Magnitude (simple threshold)                           │
│                                                             │
│  Stage 4: Knowledge Distillation (DISTILL)                 │
│  ├── Teacher: Qwen 2.5-7B                                 │
│  └── Student: Qwen 2.5-1.5B (T=4, α=0.5)                │
│                                                             │
│  Stage 5: Inference Optimization                            │
│  ├── Flash Attention 2                                      │
│  ├── KV-Cache INT8 Quantization                            │
│  ├── Speculative Decoding                                   │
│  └── CUDA Graphs + Continuous Batching                     │
│                                                             │
│  Stage 6: Benchmark & Telemetry                             │
│  ├── Perplexity (WikiText-2)                               │
│  ├── Tokens/sec, TTFT, Peak VRAM                           │
│  └── JSONL telemetry → Google Drive                        │
└─────────────────────────────────────────────────────────────┘
```

## Supported Models

| Model | Total Params | Active Params | FP16 Size | 4-bit Size | Colab Tier |
|-------|-------------|---------------|-----------|------------|------------|
| Qwen 2.5-0.5B | 0.5B | 0.5B | 1.0 GB | 0.4 GB | Free |
| Qwen 2.5-1.5B | 1.5B | 1.5B | 3.1 GB | 1.1 GB | Free |
| Qwen 2.5-7B | 7B | 7B | 14.4 GB | 4.1 GB | Free/Pro |
| Qwen 2.5-14B | 14B | 14B | 28 GB | 8.5 GB | Pro |
| Qwen 2.5-72B | 72B | 72B | 144 GB | 41 GB | Pro+ |
| Qwen 3.6-35B-A3B | 35B | ~3B | 70 GB | 18 GB | Pro |

## Theoretical Foundation

Each pipeline stage is backed by formally verified theorems in Lean 4:

- **Composition**: Total error = Σ εᵢ, total compression = Π rᵢ (`CompressionPipeline.lean`)
- **Quantization**: |x − Q(x)| ≤ δ/2 (`QuantizationBounds.lean`)
- **Pruning**: Error = 0 at kept entries (`PruningBounds.lean`)
- **Distillation**: Higher T → softer targets (`DistillationTheory.lean`)
- **Perplexity**: PPL(L+ε) = PPL(L) × e^ε (`CompressionPipeline.lean`)

See `AI_IDEAS_ANALYSIS.md` for the full analysis of the project's formalized AI theory.

## CLI Usage

```bash
# Default: Qwen 2.5-7B, AWQ 4-bit, Wanda 50%, vLLM
python qwen_optimization_pipeline.py

# Specific model
python qwen_optimization_pipeline.py --model qwen2.5-1.5b

# With distillation
python qwen_optimization_pipeline.py --model qwen2.5-7b --distill

# GPTQ instead of AWQ
python qwen_optimization_pipeline.py --quant-method gptq --quant-bits 4

# For Qwen 3.6 MoE
python qwen_optimization_pipeline.py --model qwen3.6-35b-a3b

# No telemetry
python qwen_optimization_pipeline.py --no-telemetry
```

## Google Drive Cache Structure

```
Google Drive/
└── qwen_model_cache/
    ├── qwen2.5-7b-instruct/       # Downloaded model weights
    ├── qwen2.5-7b-optimized/       # Compressed model
    └── telemetry.jsonl             # Benchmark history
```

## Telemetry Format

```json
{
  "timestamp": "2025-01-15T10:30:00",
  "session_id": "a1b2c3d4e5f6",
  "model": "Qwen/Qwen2.5-7B-Instruct",
  "stage": "benchmark",
  "event": "batch_result",
  "data": {
    "tokens_per_second": 55.2,
    "peak_vram_gb": 5.8,
    "perplexity": 7.1,
    "compression_ratio": 4.0
  }
}
```
