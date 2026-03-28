"""
Quantum Tropical Circuit Simulator
====================================

Simulates circuits built from tropical quantum gates with optional
Maslov deformation. Supports:
    - Sequential gate application
    - Circuit composition and repetition
    - Measurement (tropical projection / WTA)
    - Maslov annealing (varying β during circuit execution)
    - Circuit visualization
"""

import numpy as np
from typing import List, Optional, Tuple, Callable
from qtlib.gates import TropicalGate, TropicalHadamard, TropicalCNOT, TropicalPhase
from qtlib.semiring import TROP_NEG_INF, maslov_add


class TropicalCircuit:
    """A circuit of tropical quantum gates applied sequentially.

    Example
    -------
    >>> circ = TropicalCircuit(n_qubits=2)
    >>> circ.add(TropicalHadamard(target=0))
    >>> circ.add(TropicalCNOT(control=0, target=1))
    >>> circ.add(TropicalPhase(phi=1.5, target=1))
    >>> result = circ.run(np.array([3.0, -1.0]))
    """

    def __init__(self, n_qubits: int, name: str = "TropicalCircuit"):
        self.n_qubits = n_qubits
        self.name = name
        self.gates: List[TropicalGate] = []
        self.history: List[np.ndarray] = []

    def add(self, gate: TropicalGate) -> 'TropicalCircuit':
        """Add a gate to the circuit."""
        self.gates.append(gate)
        return self

    def run(self, initial_state: np.ndarray, beta: Optional[float] = None,
            record_history: bool = False) -> np.ndarray:
        """Execute the circuit on an initial state.

        Parameters
        ----------
        initial_state : array of shape (n_qubits,)
            Tropical state vector (log-probabilities / activations)
        beta : float, optional
            If given, use Maslov-deformed gates with this β.
            If None, use hard tropical gates (β = ∞).
        record_history : bool
            If True, store intermediate states in self.history.

        Returns
        -------
        final_state : array of shape (n_qubits,)
        """
        state = initial_state.copy().astype(float)
        self.history = [state.copy()] if record_history else []

        for gate in self.gates:
            if beta is not None:
                state = gate.apply_maslov(state, beta)
            else:
                state = gate.apply(state)
            if record_history:
                self.history.append(state.copy())

        return state

    def run_annealing(self, initial_state: np.ndarray,
                      beta_schedule: List[float]) -> np.ndarray:
        """Run circuit with a varying β schedule (one β per gate).

        This implements Maslov annealing: starting in the quantum regime
        (low β) and cooling to the tropical regime (high β).
        """
        assert len(beta_schedule) == len(self.gates), \
            f"Schedule length {len(beta_schedule)} ≠ gate count {len(self.gates)}"

        state = initial_state.copy().astype(float)
        for gate, beta in zip(self.gates, beta_schedule):
            state = gate.apply_maslov(state, beta)
        return state

    def measure(self, state: np.ndarray) -> int:
        """Tropical measurement: Winner-Take-All projection.

        Returns the index of the maximum component (the "winner").
        """
        return int(np.argmax(state))

    def tropical_probabilities(self, state: np.ndarray, beta: float = 1.0) -> np.ndarray:
        """Convert tropical state to pseudo-probabilities via softmax.

        p_i = exp(β · s_i) / Σ_j exp(β · s_j)

        At β → ∞, this concentrates on the maximum (WTA).
        At β → 0, this becomes uniform.
        """
        s = beta * state
        s = s - np.max(s)  # numerical stability
        exp_s = np.exp(s)
        return exp_s / np.sum(exp_s)

    def depth(self) -> int:
        """Circuit depth (number of gates)."""
        return len(self.gates)

    def __repr__(self):
        lines = [f"{self.name} (qubits={self.n_qubits}, depth={self.depth()})"]
        for i, gate in enumerate(self.gates):
            lines.append(f"  [{i}] {gate}")
        return "\n".join(lines)


class QuantumTropicalSimulator:
    """Full simulator for quantum tropical circuits.

    Supports:
        - Batch execution over multiple initial states
        - Maslov annealing with configurable schedules
        - Entanglement tracking via tropical rank
        - Measurement statistics
        - Comparison between quantum and tropical regimes
    """

    def __init__(self, n_qubits: int):
        self.n_qubits = n_qubits
        self.circuit = TropicalCircuit(n_qubits)
        self.measurements: List[int] = []

    def build_circuit(self, gates: List[TropicalGate]) -> None:
        """Set the circuit from a list of gates."""
        self.circuit = TropicalCircuit(self.n_qubits)
        for gate in gates:
            self.circuit.add(gate)

    def simulate(self, initial_state: np.ndarray,
                 beta: float = None, n_shots: int = 1) -> dict:
        """Simulate the circuit and collect measurement statistics.

        Parameters
        ----------
        initial_state : array
        beta : float, optional
            Maslov parameter. None = hard tropical.
        n_shots : int
            Number of measurement shots (for stochastic measurement).

        Returns
        -------
        dict with keys:
            'final_state': the output tropical state
            'measurement': WTA measurement result
            'probabilities': softmax probabilities
            'histogram': measurement counts over n_shots
        """
        final = self.circuit.run(initial_state, beta=beta)
        meas = self.circuit.measure(final)

        # For stochastic measurement, sample from softmax
        effective_beta = beta if beta is not None else 100.0
        probs = self.circuit.tropical_probabilities(final, effective_beta)
        histogram = np.zeros(self.n_qubits, dtype=int)
        if n_shots > 1:
            samples = np.random.choice(self.n_qubits, size=n_shots, p=probs)
            for s in samples:
                histogram[s] += 1
        else:
            histogram[meas] = 1

        return {
            'final_state': final,
            'measurement': meas,
            'probabilities': probs,
            'histogram': histogram,
        }

    def sweep_beta(self, initial_state: np.ndarray,
                   betas: np.ndarray) -> dict:
        """Sweep over β values to observe the quantum-tropical transition.

        Returns
        -------
        dict with keys:
            'betas': the β values
            'states': array of shape (len(betas), n_qubits)
            'measurements': array of WTA results
            'entropies': Shannon entropy at each β
        """
        states = []
        measurements = []
        entropies = []

        for beta in betas:
            final = self.circuit.run(initial_state, beta=beta)
            meas = self.circuit.measure(final)
            probs = self.circuit.tropical_probabilities(final, beta)
            entropy = -np.sum(probs * np.log(probs + 1e-30))

            states.append(final)
            measurements.append(meas)
            entropies.append(entropy)

        return {
            'betas': betas,
            'states': np.array(states),
            'measurements': np.array(measurements),
            'entropies': np.array(entropies),
        }

    def compare_regimes(self, initial_state: np.ndarray) -> dict:
        """Compare quantum (β→0), ML (β=1), and tropical (β→∞) regimes."""
        results = {}
        for name, beta in [('quantum', 0.1), ('ml', 1.0), ('tropical', 100.0)]:
            results[name] = self.simulate(initial_state, beta=beta)
        return results
