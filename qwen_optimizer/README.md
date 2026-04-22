# Qwen Optimizer

A Python toolkit for optimizing Qwen LLMs for minimal VRAM and fast inference, inspired by formal theorems from the Lean 4 theorem catalog.

## Installation

```bash
pip install transformers accelerate bitsandbytes optimum[auto-gptq]
pip install torch psutil tqdm huggingface_hub datasets
pip install llama-cpp-python  # optional, for GGUF conversion
```

## Modules

- `download.ModelCache` — Download models from HuggingFace and cache to disk (or Google Drive on Colab).
- `quantize.quantize_nf4` — Load models with 4-bit NF4 quantization via `bitsandbytes`.
- `quantize.quantize_gguf` — Convert HuggingFace checkpoints to GGUF and quantize at multiple levels (Q4_K_M, Q3_K_M).
- `prune.prune_model` — Multi-stage pruning: structured FFN, unstructured magnitude, attention head removal.
- `benchmark.BenchmarkSuite` — Standardized inference speed, VRAM, and perplexity benchmarks.
- `telemetry.TelemetryLogger` — JSON-persistent telemetry logging.
- `distill.DistillationPipeline` — Teacher-student knowledge distillation with temperature-scaled KL divergence.
- `tropical` — Tropical (min-plus) compression architecture:
  - `TropicalModel` / `TropicalLinear` / `TropicalAttention` / `TropicalFFN`
  - `tropical_matmul`, `tropical_dot_product`
  - `crystallization_penalty`, `sheffer_nand`, `tropical_to_sheffer`
  - `convert_to_tropical`
- `triton_kernels` — OpenAI Triton kernels for tropical operations (matmul, L1 distance attention).

## Quick Start

```python
from qwen_optimizer import (
    ModelCache, BenchmarkSuite, TelemetryLogger, TelemetryEntry,
    TropicalModel, convert_to_tropical,
)

cache = ModelCache("./model_cache")
model_path = cache.get_model_path("Qwen/Qwen2.5-3B-Instruct")

# Load tokenizer and model
from transformers import AutoModelForCausalLM, AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained(model_path)
model = AutoModelForCausalLM.from_pretrained(model_path, torch_dtype=torch.float16, device_map="auto")

# Benchmark
bench = BenchmarkSuite(tokenizer)
result = bench.run_inference_benchmark(model, "baseline", "fp16")

# Log telemetry
logger = TelemetryLogger("./telemetry.json")
logger.log(TelemetryEntry(
    timestamp=datetime.utcnow().isoformat(),
    stage="baseline",
    model_name="Qwen2.5-3B-Instruct",
    quantization="fp16",
    vram_mb=result.vram_mb,
    tokens_per_sec_prefill=result.tokens_per_sec_prefill,
    tokens_per_sec_decode=result.tokens_per_sec_decode,
    perplexity=None,
    latency_ttft_ms=result.latency_ttft_ms,
    latency_tpot_ms=result.latency_tpot_ms,
))
```

## Tropical Compression Architecture

```python
from qwen_optimizer import TropicalModel, convert_to_tropical

# Create a small tropical student model
student = TropicalModel(
    vocab_size=151936,
    d_model=512,
    num_layers=6,
    num_heads=8,
    d_ff=1024,
    max_seq_len=2048,
    hard_attention=False,
)

# Convert a standard model to tropical
tropical = convert_to_tropical(model, hard_attention=True)

# Crystallize weights to {-1, 0, 1}
tropical.crystallize()
```

## Comparison Benchmark

Run side-by-side comparisons of standard, tropical, and crystallized models:

```bash
python compare_benchmark.py \
    --teacher Qwen/Qwen2.5-3B-Instruct \
    --device cuda \
    --output_dir ./benchmark_results
```

## References to Lean Theorems

- `CompressionPipeline.compose` — multi-stage compression with additive error
- `QuantizationBounds.quantError_frobenius_bound` — Frobenius norm quantization error
- `DistillationLoss.distillationLoss'` — temperature-scaled distillation loss
- `CrystallizationTheory.crystal_loss_eq_zero_iff` — weight crystallization
- `TropicalDeepLearningFoundations` — tropical semiring primitives
- `SubQuadraticAttention` — L1 distance attention
- `ShefferFunction` — Sheffer stroke logic mapping

## Google Colab Notebook

See `colab_qwen_optimize.ipynb` for a runnable end-to-end pipeline on Colab.
