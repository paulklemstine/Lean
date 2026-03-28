"""
qtlib — Quantum Tropical Universal Learning and Inference Library
=================================================================

A Python library for quantum tropical neural computing, providing:

- Tropical semiring arithmetic (max-plus algebra)
- Quantum tropical gates (Hadamard, CNOT, Phase, Toffoli)
- Tropical tensor products and entanglement measures
- Tropical neural network layers with tropical backpropagation
- Maslov deformation controller (quantum ↔ tropical interpolation)
- Quantum tropical circuit simulator
- Universal learning via morphological gradient descent
- Inference engine for tropical probabilistic models

Core Mathematical Foundation:
    The tropical semiring T = (ℝ ∪ {-∞}, max, +) with Maslov deformation
    parameterized by β ∈ (0, ∞] interpolating to standard arithmetic at β → 0.

Author: Aristotle (Harmonic AI) — Quantum Tropical Computing Research Team
"""

from qtlib.semiring import (
    TropicalFloat,
    trop_add,
    trop_mul,
    trop_zero,
    trop_one,
    maslov_add,
    logsumexp,
)

from qtlib.gates import (
    TropicalGate,
    TropicalHadamard,
    TropicalCNOT,
    TropicalPhase,
    TropicalToffoli,
    TropicalSWAP,
    MaslovGate,
)

from qtlib.circuits import (
    TropicalCircuit,
    QuantumTropicalSimulator,
)

from qtlib.tensor import (
    TropicalTensor,
    tropical_tensor_product,
    tropical_rank,
    tropical_entanglement,
)

from qtlib.networks import (
    TropicalLinear,
    TropicalReLU,
    TropicalSoftmax,
    TropicalNetwork,
    TropicalLoss,
)

from qtlib.learning import (
    TropicalSGD,
    TropicalBackprop,
    MorphologicalGradient,
    tropical_train,
)

from qtlib.inference import (
    TropicalBayesNet,
    TropicalViterbi,
    TropicalBeliefPropagation,
    tropical_infer,
)

__version__ = "1.0.0"
__all__ = [
    # Semiring
    "TropicalFloat", "trop_add", "trop_mul", "trop_zero", "trop_one",
    "maslov_add", "logsumexp",
    # Gates
    "TropicalGate", "TropicalHadamard", "TropicalCNOT", "TropicalPhase",
    "TropicalToffoli", "TropicalSWAP", "MaslovGate",
    # Circuits
    "TropicalCircuit", "QuantumTropicalSimulator",
    # Tensor
    "TropicalTensor", "tropical_tensor_product", "tropical_rank", "tropical_entanglement",
    # Networks
    "TropicalLinear", "TropicalReLU", "TropicalSoftmax", "TropicalNetwork", "TropicalLoss",
    # Learning
    "TropicalSGD", "TropicalBackprop", "MorphologicalGradient", "tropical_train",
    # Inference
    "TropicalBayesNet", "TropicalViterbi", "TropicalBeliefPropagation", "tropical_infer",
]
