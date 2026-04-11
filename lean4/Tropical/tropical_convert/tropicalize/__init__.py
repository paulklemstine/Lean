"""
Tropicalize: Convert HuggingFace transformer models to tropical architecture.

Tropical neural networks replace the standard linear algebra operations
(matrix multiply + sum) with tropical semiring operations (addition + max),
grounded in the mathematical identity: every ReLU network computes a
tropical rational function.

This package provides:
  - tropicalize.layers     — Tropical linear, attention, and MLP layers
  - tropicalize.converter  — Model structure conversion (standard → tropical)
  - tropicalize.distiller  — Knowledge distillation to match original model
  - tropicalize.cache      — Persistent caching for downloads & checkpoints
"""

__version__ = "0.1.0"
