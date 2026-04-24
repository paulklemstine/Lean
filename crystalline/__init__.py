"""
Crystalline: A new AI framework for minimal-VRAM, high-speed inference.

Inspired by formal theorems in the Lean 4 theorem catalog:
- Tropical semiring (min-plus algebra) replaces standard linear algebra
- Crystallization pushes weights to discrete {-1, 0, 1} states
- Sheffer NAND completeness for hardware simplicity
- DeltaNet-compatible tropical recurrence
"""

__version__ = "0.1.0"

from .core import (
    tropical_add,
    tropical_mul,
    tropical_matmul,
    tropical_state_update,
    tropical_dot_product,
)
from .crystallize import (
    crystallization_penalty,
    sheffer_nand,
    tropical_to_sheffer,
    crystallize_module,
)
from .deltanet import CrystallineDeltaLayer
from .moe import CrystallineMoELayer, CrystallineRouter
from .model import CrystallineModel, CrystallineConfig

try:
    from .triton_kernels import (
        TRITON_AVAILABLE,
        triton_tropical_matmul,
        triton_tropical_state_update,
    )
except ImportError:
    TRITON_AVAILABLE = False
    triton_tropical_matmul = None
    triton_tropical_state_update = None

__all__ = [
    "tropical_add",
    "tropical_mul",
    "tropical_matmul",
    "tropical_state_update",
    "tropical_dot_product",
    "crystallization_penalty",
    "sheffer_nand",
    "tropical_to_sheffer",
    "crystallize_module",
    "CrystallineDeltaLayer",
    "CrystallineMoELayer",
    "CrystallineRouter",
    "CrystallineModel",
    "CrystallineConfig",
    "TRITON_AVAILABLE",
    "triton_tropical_matmul",
    "triton_tropical_state_update",
]
