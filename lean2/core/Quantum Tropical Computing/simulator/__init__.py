"""
Quantum Tropical Circuit Simulator
====================================

A standalone simulator for quantum tropical circuits that provides:
    - Interactive circuit construction
    - Step-by-step execution with state visualization
    - Maslov annealing simulation
    - Comparison between quantum, ML, and tropical regimes
    - Entanglement tracking
    - Measurement statistics
"""

from qtlib.circuits import TropicalCircuit, QuantumTropicalSimulator
from qtlib.gates import (
    TropicalHadamard, TropicalCNOT, TropicalPhase,
    TropicalToffoli, TropicalSWAP, MaslovGate
)

__all__ = [
    'TropicalCircuit', 'QuantumTropicalSimulator',
    'TropicalHadamard', 'TropicalCNOT', 'TropicalPhase',
    'TropicalToffoli', 'TropicalSWAP', 'MaslovGate',
]
