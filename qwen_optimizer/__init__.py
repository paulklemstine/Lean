"""
qwen_optimizer: A toolkit for optimizing Qwen LLMs for minimal VRAM and fast inference.

Inspired by formal theorems in the Lean 4 theorem catalog:
- CompressionPipeline: multi-stage compression with error bounds
- QuantizationBounds: uniform quantization and Frobenius error bounds
- DistillationLoss: temperature-scaled KL divergence
- CrystallizationTheory: weight clustering and sparse optimization
- TropicalDeepLearningFoundations: tropical semiring (min-plus algebra)
- TropicalFFN: tropical feed-forward networks
- SubQuadraticAttention: sub-quadratic tropical attention
- ShefferFunction: Sheffer stroke logic mapping
"""

__version__ = "0.2.0"

from .download import ModelCache
from .quantize import quantize_nf4, quantize_gguf, QuantizationConfig
from .benchmark import BenchmarkSuite
from .telemetry import TelemetryLogger, TelemetryEntry
from .distill import DistillationPipeline
from .prune import (
    prune_ffn_intermediate,
    unstructured_magnitude_prune,
    prune_attention_heads,
    compute_sparsity,
    prune_model,
)
from .tropical import (
    TropicalModel,
    TropicalLinear,
    TropicalAttention,
    TropicalFFN,
    TropicalTransformerBlock,
    tropical_matmul,
    tropical_dot_product,
    crystallization_penalty,
    sheffer_nand,
    tropical_to_sheffer,
    tropical_distillation_loss,
    convert_to_tropical,
)

try:
    from .triton_kernels import (
        TRITON_AVAILABLE,
        triton_tropical_matmul,
        triton_tropical_l1_distance,
        _tropical_matmul_kernel,
        _tropical_l1_distance_kernel,
    )
except ImportError:
    TRITON_AVAILABLE = False
    triton_tropical_matmul = None
    triton_tropical_l1_distance = None
    _tropical_matmul_kernel = None
    _tropical_l1_distance_kernel = None

__all__ = [
    "ModelCache",
    "quantize_nf4",
    "quantize_gguf",
    "QuantizationConfig",
    "BenchmarkSuite",
    "TelemetryLogger",
    "TelemetryEntry",
    "DistillationPipeline",
    "TropicalModel",
    "TropicalLinear",
    "TropicalAttention",
    "TropicalFFN",
    "TropicalTransformerBlock",
    "tropical_matmul",
    "tropical_dot_product",
    "crystallization_penalty",
    "sheffer_nand",
    "tropical_to_sheffer",
    "tropical_distillation_loss",
    "convert_to_tropical",
    "TRITON_AVAILABLE",
    "triton_tropical_matmul",
    "triton_tropical_l1_distance",
    "_tropical_matmul_kernel",
    "_tropical_l1_distance_kernel",
    "prune_ffn_intermediate",
    "unstructured_magnitude_prune",
    "prune_attention_heads",
    "compute_sparsity",
    "prune_model",
]
