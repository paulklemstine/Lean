"""
Quantum Tropical Gates
======================

Tropicalizations of standard quantum gates, obtained in the semiclassical
limit ℏ → 0. Each gate has both a "hard" tropical form (β = ∞) and a
"soft" Maslov-deformed form (finite β).

Gate Dictionary:
    Quantum Gate        →  Tropical Gate           →  Neural Operation
    ─────────────────────────────────────────────────────────────────────
    Hadamard H          →  (max(a,b), max(a,b))    →  Winner-take-all
    CNOT                →  (a, a+b)                 →  Synaptic integration
    Phase P(φ)          →  a + φ                    →  Synaptic weight
    Toffoli             →  (a, b, max(b, a₁+a₂))   →  Gated integration
    SWAP                →  (b, a)                   →  Channel swap
    Controlled-Phase    →  (a, b + φ·sgn(a))        →  Conditional modulation
"""

import numpy as np
from abc import ABC, abstractmethod
from qtlib.semiring import maslov_add, trop_add, trop_mul, TROP_NEG_INF


class TropicalGate(ABC):
    """Abstract base class for tropical quantum gates."""

    def __init__(self, name: str, n_qubits: int):
        self.name = name
        self.n_qubits = n_qubits

    @abstractmethod
    def apply(self, state: np.ndarray) -> np.ndarray:
        """Apply the gate to a tropical state vector."""
        pass

    def apply_maslov(self, state: np.ndarray, beta: float) -> np.ndarray:
        """Apply the Maslov-deformed (soft) version of the gate."""
        # Default: fall back to hard tropical gate
        return self.apply(state)

    def __repr__(self):
        return f"{self.name}(qubits={self.n_qubits})"

    def compose(self, other: 'TropicalGate') -> 'ComposedGate':
        """Compose two gates: self ∘ other (apply other first, then self)."""
        return ComposedGate(self, other)


class ComposedGate(TropicalGate):
    """Composition of two tropical gates."""

    def __init__(self, outer: TropicalGate, inner: TropicalGate):
        assert outer.n_qubits == inner.n_qubits
        super().__init__(f"{outer.name}∘{inner.name}", outer.n_qubits)
        self.outer = outer
        self.inner = inner

    def apply(self, state: np.ndarray) -> np.ndarray:
        return self.outer.apply(self.inner.apply(state))

    def apply_maslov(self, state: np.ndarray, beta: float) -> np.ndarray:
        return self.outer.apply_maslov(self.inner.apply_maslov(state, beta), beta)


class TropicalHadamard(TropicalGate):
    """Tropical Hadamard Gate: H_T(a, b) = (max(a,b), max(a,b))

    Tropicalization of H = (1/√2)[[1,1],[1,-1]].
    Neural interpretation: Winner-take-all broadcast.

    Key property: H_T² = H_T (idempotent, not involutive like quantum H).
    """

    def __init__(self, target: int = 0):
        super().__init__("H_T", 1)
        self.target = target

    def apply(self, state: np.ndarray) -> np.ndarray:
        """Apply WTA broadcast: replace all components with the max.
        For single-qubit target, broadcast max over the entire state."""
        result = state.copy()
        m = np.max(state)
        result[:] = m
        return result

    def apply_maslov(self, state: np.ndarray, beta: float) -> np.ndarray:
        result = state.copy()
        m = state[0]
        for i in range(1, len(state)):
            m = maslov_add(m, state[i], beta)
        result[:] = m
        return result


class TropicalCNOT(TropicalGate):
    """Tropical CNOT Gate: CNOT_T(a, b) = (a, a + b)

    Tropicalization of quantum CNOT = [[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]].
    Neural interpretation: Synaptic integration (control signal adds to target).

    Key property: CNOT_T² ≠ I (non-involutive, unlike quantum CNOT).
    CNOT_T²(a,b) = (a, 2a+b).
    """

    def __init__(self, control: int = 0, target: int = 1):
        super().__init__("CNOT_T", 2)
        self.control = control
        self.target = target

    def apply(self, state: np.ndarray) -> np.ndarray:
        result = state.copy()
        result[self.target] = state[self.control] + state[self.target]
        return result

    def apply_maslov(self, state: np.ndarray, beta: float) -> np.ndarray:
        # Maslov-deformed CNOT: target gets logsumexp(control, target)
        # Actually CNOT tropicalization is addition, which doesn't deform
        return self.apply(state)


class TropicalPhase(TropicalGate):
    """Tropical Phase Gate: P_T(φ)(a) = a + φ

    Tropicalization of quantum phase gate [[1,0],[0,e^{iφ}]].
    Neural interpretation: Synaptic weight (additive bias).

    Key property: P_T(φ) ∘ P_T(ψ) = P_T(φ + ψ) — forms an additive group.
    """

    def __init__(self, phi: float, target: int = 0):
        super().__init__(f"P_T({phi:.2f})", 1)
        self.phi = phi
        self.target = target

    def apply(self, state: np.ndarray) -> np.ndarray:
        result = state.copy()
        result[self.target] = state[self.target] + self.phi
        return result

    def apply_maslov(self, state: np.ndarray, beta: float) -> np.ndarray:
        return self.apply(state)  # Phase gate is exact in all regimes


class TropicalToffoli(TropicalGate):
    """Tropical Toffoli Gate: T_T(a, b, c) = (a, b, max(c, a+b))

    Tropicalization of the quantum Toffoli (CCNOT) gate.
    Neural interpretation: Gated synaptic integration — the target receives
    the sum of two control signals only if that sum exceeds the current target.
    """

    def __init__(self, control1: int = 0, control2: int = 1, target: int = 2):
        super().__init__("Toffoli_T", 3)
        self.control1 = control1
        self.control2 = control2
        self.target = target

    def apply(self, state: np.ndarray) -> np.ndarray:
        result = state.copy()
        gated = state[self.control1] + state[self.control2]
        result[self.target] = max(state[self.target], gated)
        return result

    def apply_maslov(self, state: np.ndarray, beta: float) -> np.ndarray:
        result = state.copy()
        gated = state[self.control1] + state[self.control2]
        result[self.target] = maslov_add(state[self.target], gated, beta)
        return result


class TropicalSWAP(TropicalGate):
    """Tropical SWAP Gate: SWAP_T(a, b) = (b, a)

    Tropicalization of quantum SWAP gate.
    Neural interpretation: Channel crossing / routing.

    Key property: SWAP_T² = I (involutive, same as quantum).
    """

    def __init__(self, qubit1: int = 0, qubit2: int = 1):
        super().__init__("SWAP_T", 2)
        self.qubit1 = qubit1
        self.qubit2 = qubit2

    def apply(self, state: np.ndarray) -> np.ndarray:
        result = state.copy()
        result[self.qubit1] = state[self.qubit2]
        result[self.qubit2] = state[self.qubit1]
        return result

    def apply_maslov(self, state: np.ndarray, beta: float) -> np.ndarray:
        return self.apply(state)  # SWAP is exact in all regimes


class MaslovGate(TropicalGate):
    """A generic Maslov-deformed gate parameterized by β.

    Wraps any tropical gate with a continuous deformation parameter β:
        β → ∞:  exact tropical gate
        β = 1:  LogSumExp regime
        β → 0:  arithmetic mean regime
    """

    def __init__(self, base_gate: TropicalGate, beta: float = 1.0):
        super().__init__(f"Maslov({base_gate.name}, β={beta:.1f})", base_gate.n_qubits)
        self.base_gate = base_gate
        self.beta = beta

    def apply(self, state: np.ndarray) -> np.ndarray:
        return self.base_gate.apply_maslov(state, self.beta)

    def set_beta(self, beta: float):
        """Update the deformation parameter."""
        self.beta = beta
        self.name = f"Maslov({self.base_gate.name}, β={beta:.1f})"


class TropicalControlledPhase(TropicalGate):
    """Tropical Controlled-Phase Gate: CP_T(φ)(a, b) = (a, b + φ) if a > threshold, else (a, b)

    In the hard tropical limit, the control activates when the control
    qubit value exceeds a threshold (default 0).
    """

    def __init__(self, phi: float, control: int = 0, target: int = 1, threshold: float = 0.0):
        super().__init__(f"CP_T({phi:.2f})", 2)
        self.phi = phi
        self.control = control
        self.target = target
        self.threshold = threshold

    def apply(self, state: np.ndarray) -> np.ndarray:
        result = state.copy()
        if state[self.control] > self.threshold:
            result[self.target] = state[self.target] + self.phi
        return result

    def apply_maslov(self, state: np.ndarray, beta: float) -> np.ndarray:
        result = state.copy()
        # Soft activation: sigmoid-like gating
        gate_strength = 1.0 / (1.0 + np.exp(-beta * (state[self.control] - self.threshold)))
        result[self.target] = state[self.target] + self.phi * gate_strength
        return result
