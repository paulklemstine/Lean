#!/usr/bin/env python3
"""
Quantum Hardware Integration Demo
==================================
Demonstrates mapping tropical annealing schedules to D-Wave and IBM quantum processors.

This demo simulates:
1. QUBO formulation from tropical optimization problems
2. Annealing schedule mapping for D-Wave (logarithmic, geometric, linear)
3. Trotterized gate decomposition for IBM processors
4. Hybrid quantum-classical optimization loop

Requirements: numpy, matplotlib (for visualization)
Optional: dwave-ocean-sdk, qiskit (for real hardware execution)
"""

import numpy as np
import json
from typing import List, Tuple, Dict, Optional

# ============================================================================
# Section 1: QUBO Formulation from Tropical Optimization
# ============================================================================

def tropical_to_qubo(weights: np.ndarray, biases: np.ndarray) -> np.ndarray:
    """
    Convert a tropical optimization problem max_x (Wx + b) to QUBO form.
    
    The tropical problem: find x ∈ {0,1}^n maximizing max_i(Σ_j w_ij x_j + b_i)
    QUBO form: minimize Q(x) = x^T Q x where Q_ij = -w_ij
    
    Args:
        weights: n×n weight matrix W
        biases: n-vector of biases b
        
    Returns:
        Q: n×n QUBO matrix (upper triangular)
    """
    n = weights.shape[0]
    Q = np.zeros((n, n))
    
    # Off-diagonal: Q_ij = -(w_ij + w_ji) for i < j
    for i in range(n):
        for j in range(i + 1, n):
            Q[i, j] = -(weights[i, j] + weights[j, i])
    
    # Diagonal: Q_ii = -b_i - Σ_j w_ji
    for i in range(n):
        Q[i, i] = -biases[i] - np.sum(weights[:, i])
    
    return Q


def qubo_energy(Q: np.ndarray, x: np.ndarray) -> float:
    """Compute QUBO energy E(x) = x^T Q x."""
    return float(x @ Q @ x)


def brute_force_qubo(Q: np.ndarray) -> Tuple[np.ndarray, float]:
    """Solve QUBO by brute force (for small instances)."""
    n = Q.shape[0]
    best_x = None
    best_energy = float('inf')
    
    for i in range(2**n):
        x = np.array([(i >> j) & 1 for j in range(n)], dtype=float)
        energy = qubo_energy(Q, x)
        if energy < best_energy:
            best_energy = energy
            best_x = x.copy()
    
    return best_x, best_energy


# ============================================================================
# Section 2: D-Wave Annealing Schedule Mapping
# ============================================================================

class AnnealingSchedule:
    """Annealing schedule mapping for D-Wave processors."""
    
    def __init__(self, schedule_type: str = "logarithmic", **params):
        self.schedule_type = schedule_type
        self.params = params
    
    def beta(self, t: float) -> float:
        """Compute inverse temperature β(t)."""
        if self.schedule_type == "logarithmic":
            c = self.params.get("c", 1.0)
            return c * np.log(1 + t)
        elif self.schedule_type == "geometric":
            beta_0 = self.params.get("beta_0", 0.1)
            alpha = self.params.get("alpha", 1.1)
            return beta_0 * alpha ** t
        elif self.schedule_type == "linear":
            rate = self.params.get("rate", 0.01)
            return rate * t
        else:
            raise ValueError(f"Unknown schedule: {self.schedule_type}")
    
    def to_dwave_schedule(self, T_total: float, n_points: int = 100) -> List[Tuple[float, float]]:
        """
        Convert to D-Wave schedule format: list of (time_μs, s_value) pairs.
        s ∈ [0, 1] where s=0 is transverse field dominant, s=1 is problem Hamiltonian.
        
        Maps β(t) to s(t) = β(t) / β_max.
        """
        times = np.linspace(0, T_total, n_points)
        betas = np.array([self.beta(t) for t in times])
        beta_max = betas[-1] if betas[-1] > 0 else 1.0
        s_values = np.clip(betas / beta_max, 0, 1)
        
        # D-Wave expects time in microseconds
        schedule = [(float(t), float(s)) for t, s in zip(times, s_values)]
        return schedule
    
    def gap_bound(self, t: float, n: int) -> float:
        """
        Compute the gap bound log(n)/β(t).
        This bounds the difference between LSE and max.
        """
        b = self.beta(t)
        if b <= 0:
            return float('inf')
        return np.log(n) / b
    
    def convergence_time(self, epsilon: float, n: int) -> float:
        """
        Compute time needed to achieve gap ≤ ε for n elements.
        For logarithmic: t = exp(log(n)/(c·ε)) - 1
        """
        if self.schedule_type == "logarithmic":
            c = self.params.get("c", 1.0)
            return np.exp(np.log(n) / (c * epsilon)) - 1
        else:
            # Binary search for other schedules
            lo, hi = 0.0, 1e6
            for _ in range(100):
                mid = (lo + hi) / 2
                if self.gap_bound(mid, n) <= epsilon:
                    hi = mid
                else:
                    lo = mid
            return hi


class DWaveSimulator:
    """Simulated D-Wave annealer using tropical annealing."""
    
    def __init__(self, Q: np.ndarray, schedule: AnnealingSchedule):
        self.Q = Q
        self.n = Q.shape[0]
        self.schedule = schedule
    
    def anneal(self, n_reads: int = 100, anneal_time: float = 20.0) -> Dict:
        """
        Simulate quantum annealing with the given schedule.
        
        Returns dict with 'samples', 'energies', 'timing'.
        """
        samples = []
        energies = []
        
        for _ in range(n_reads):
            # Start from random state (simulating quantum superposition)
            x = np.random.randint(0, 2, self.n).astype(float)
            
            # Anneal: gradually increase β
            n_steps = 1000
            for step in range(n_steps):
                t = anneal_time * step / n_steps
                beta = self.schedule.beta(t)
                
                # Single spin flip with Metropolis acceptance
                i = np.random.randint(self.n)
                x_new = x.copy()
                x_new[i] = 1 - x_new[i]
                
                dE = qubo_energy(self.Q, x_new) - qubo_energy(self.Q, x)
                
                # Accept with probability min(1, exp(-β·ΔE))
                if dE < 0 or (beta > 0 and np.random.random() < np.exp(-beta * dE)):
                    x = x_new
            
            samples.append(x.copy())
            energies.append(qubo_energy(self.Q, x))
        
        best_idx = np.argmin(energies)
        return {
            'samples': samples,
            'energies': energies,
            'best_sample': samples[best_idx],
            'best_energy': energies[best_idx],
            'timing': {
                'anneal_time_us': anneal_time,
                'n_reads': n_reads,
                'total_time_us': anneal_time * n_reads
            }
        }


# ============================================================================
# Section 3: IBM Gate Decomposition (Trotterization)
# ============================================================================

class TrotterCircuit:
    """Trotterized quantum circuit for IBM processors."""
    
    def __init__(self, Q: np.ndarray, n_trotter_steps: int = 10):
        self.Q = Q
        self.n = Q.shape[0]
        self.n_steps = n_trotter_steps
        self.gates = []
    
    def build_circuit(self, total_time: float = 1.0):
        """
        Build Trotterized circuit for H = Σ_{ij} Q_{ij} Z_i Z_j + Σ_i h_i X_i.
        
        Each Trotter step:
          1. Apply ZZ interactions: exp(-i dt Q_{ij} Z_i Z_j)
          2. Apply transverse field: exp(-i dt h_i X_i)
        """
        dt = total_time / self.n_steps
        self.gates = []
        
        for step in range(self.n_steps):
            # Annealing parameter s(t) increases from 0 to 1
            s = (step + 1) / self.n_steps
            
            # ZZ interactions (problem Hamiltonian, strength s)
            for i in range(self.n):
                for j in range(i + 1, self.n):
                    if abs(self.Q[i, j]) > 1e-10:
                        angle = 2 * s * dt * self.Q[i, j]
                        self.gates.append({
                            'type': 'ZZ',
                            'qubits': (i, j),
                            'angle': angle,
                            'step': step,
                            'decomposition': [
                                {'gate': 'CNOT', 'control': i, 'target': j},
                                {'gate': 'RZ', 'qubit': j, 'angle': angle},
                                {'gate': 'CNOT', 'control': i, 'target': j}
                            ]
                        })
            
            # Single-qubit X rotations (transverse field, strength 1-s)
            for i in range(self.n):
                angle = 2 * (1 - s) * dt
                self.gates.append({
                    'type': 'RX',
                    'qubit': i,
                    'angle': angle,
                    'step': step
                })
        
        return self.gates
    
    def gate_count(self) -> Dict[str, int]:
        """Count gates by type."""
        counts = {'CNOT': 0, 'RZ': 0, 'RX': 0, 'total': 0}
        for gate in self.gates:
            if gate['type'] == 'ZZ':
                counts['CNOT'] += 2  # Each ZZ needs 2 CNOTs
                counts['RZ'] += 1
            elif gate['type'] == 'RX':
                counts['RX'] += 1
        counts['total'] = counts['CNOT'] + counts['RZ'] + counts['RX']
        return counts
    
    def trotter_error_bound(self, total_time: float = 1.0) -> float:
        """
        Estimate Trotter error: ||exact - trotter|| ≤ ||[H_1, H_2]|| · t² / (2n).
        """
        # Estimate commutator norm from Q matrix
        comm_norm = np.linalg.norm(self.Q) ** 2  # Rough upper bound
        return comm_norm * total_time**2 / (2 * self.n_steps)
    
    def to_qiskit_str(self) -> str:
        """Generate Qiskit-compatible circuit description."""
        lines = [
            "from qiskit import QuantumCircuit",
            f"qc = QuantumCircuit({self.n})",
            ""
        ]
        for gate in self.gates:
            if gate['type'] == 'ZZ':
                i, j = gate['qubits']
                angle = gate['angle']
                lines.append(f"# ZZ({i},{j}) angle={angle:.4f}")
                lines.append(f"qc.cx({i}, {j})")
                lines.append(f"qc.rz({angle:.6f}, {j})")
                lines.append(f"qc.cx({i}, {j})")
            elif gate['type'] == 'RX':
                lines.append(f"qc.rx({gate['angle']:.6f}, {gate['qubit']})")
        
        return "\n".join(lines)


# ============================================================================
# Section 4: Hybrid Quantum-Classical Loop
# ============================================================================

class HybridOptimizer:
    """
    Hybrid quantum-classical optimizer combining D-Wave annealing
    with classical post-processing.
    """
    
    def __init__(self, Q: np.ndarray):
        self.Q = Q
        self.n = Q.shape[0]
        self.history = []
    
    def optimize(self, n_iterations: int = 10, n_reads: int = 50) -> Dict:
        """
        Hybrid loop:
        1. Run quantum annealer (simulated)
        2. Classical local search on best solutions
        3. Update problem based on learned structure
        """
        # Start with logarithmic cooling
        schedule = AnnealingSchedule("logarithmic", c=2.0)
        simulator = DWaveSimulator(self.Q, schedule)
        
        best_solution = None
        best_energy = float('inf')
        
        for iteration in range(n_iterations):
            # Quantum phase: anneal
            result = simulator.anneal(n_reads=n_reads, anneal_time=20.0)
            
            # Classical phase: local search on top-k solutions
            indices = np.argsort(result['energies'])[:5]
            top_k = [(result['energies'][i], result['samples'][i]) for i in indices]
            
            for energy, sample in top_k:
                # 1-opt local search
                improved = self._local_search(sample)
                imp_energy = qubo_energy(self.Q, improved)
                
                if imp_energy < best_energy:
                    best_energy = imp_energy
                    best_solution = improved.copy()
            
            self.history.append({
                'iteration': iteration,
                'best_energy': best_energy,
                'quantum_best': min(result['energies']),
                'n_unique': len(set(map(tuple, result['samples'])))
            })
        
        return {
            'best_solution': best_solution,
            'best_energy': best_energy,
            'history': self.history
        }
    
    def _local_search(self, x: np.ndarray, max_iter: int = 100) -> np.ndarray:
        """1-opt local search: flip single bits to improve energy."""
        x = x.copy()
        improved = True
        iteration = 0
        
        while improved and iteration < max_iter:
            improved = False
            iteration += 1
            current_energy = qubo_energy(self.Q, x)
            
            for i in range(self.n):
                x[i] = 1 - x[i]
                new_energy = qubo_energy(self.Q, x)
                
                if new_energy < current_energy:
                    current_energy = new_energy
                    improved = True
                else:
                    x[i] = 1 - x[i]  # Revert
        
        return x


# ============================================================================
# Section 5: Demonstrations
# ============================================================================

def demo_qubo_formulation():
    """Demo: Convert tropical optimization to QUBO."""
    print("=" * 60)
    print("Demo 1: Tropical → QUBO Formulation")
    print("=" * 60)
    
    n = 5
    np.random.seed(42)
    W = np.random.randn(n, n)
    b = np.random.randn(n)
    
    Q = tropical_to_qubo(W, b)
    print(f"\nWeight matrix W ({n}×{n}):")
    print(np.round(W, 3))
    print(f"\nBias vector b: {np.round(b, 3)}")
    print(f"\nQUBO matrix Q ({n}×{n}):")
    print(np.round(Q, 3))
    print(f"\nQUBO coefficients: {n*(n+1)//2}")
    
    # Brute force solve
    best_x, best_E = brute_force_qubo(Q)
    print(f"\nBrute-force solution: x = {best_x.astype(int)}")
    print(f"Optimal QUBO energy: {best_E:.4f}")


def demo_annealing_schedules():
    """Demo: Compare annealing schedules."""
    print("\n" + "=" * 60)
    print("Demo 2: Annealing Schedule Comparison")
    print("=" * 60)
    
    schedules = {
        'logarithmic': AnnealingSchedule("logarithmic", c=2.0),
        'geometric': AnnealingSchedule("geometric", beta_0=0.1, alpha=1.05),
        'linear': AnnealingSchedule("linear", rate=0.5)
    }
    
    print(f"\n{'Time':>8} | {'Log β':>10} | {'Geo β':>10} | {'Lin β':>10}")
    print("-" * 50)
    
    for t in [0, 1, 5, 10, 20, 50, 100]:
        vals = {name: sched.beta(t) for name, sched in schedules.items()}
        print(f"{t:>8.0f} | {vals['logarithmic']:>10.3f} | {vals['geometric']:>10.3f} | {vals['linear']:>10.3f}")
    
    # Gap bounds
    print(f"\nGap bounds for n=100 elements:")
    print(f"{'Time':>8} | {'Log gap':>10} | {'Geo gap':>10} | {'Lin gap':>10}")
    print("-" * 50)
    
    for t in [10, 50, 100, 500]:
        gaps = {name: sched.gap_bound(t, 100) for name, sched in schedules.items()}
        print(f"{t:>8.0f} | {gaps['logarithmic']:>10.4f} | {gaps['geometric']:>10.4f} | {gaps['linear']:>10.4f}")
    
    # D-Wave schedule
    print("\nD-Wave schedule (logarithmic, first 5 points):")
    dw_sched = schedules['logarithmic'].to_dwave_schedule(20.0, n_points=10)
    for t, s in dw_sched[:5]:
        print(f"  t = {t:6.2f} μs, s = {s:.4f}")


def demo_simulated_annealing():
    """Demo: Simulated D-Wave annealing."""
    print("\n" + "=" * 60)
    print("Demo 3: Simulated D-Wave Annealing")
    print("=" * 60)
    
    n = 6
    np.random.seed(123)
    Q = np.random.randn(n, n)
    Q = np.triu(Q + Q.T)  # Symmetric upper triangular
    
    # Brute force reference
    best_x_bf, best_E_bf = brute_force_qubo(Q)
    print(f"\nBrute-force optimal energy: {best_E_bf:.4f}")
    
    # Test different schedules
    for name, sched in [
        ("logarithmic", AnnealingSchedule("logarithmic", c=3.0)),
        ("geometric", AnnealingSchedule("geometric", beta_0=0.1, alpha=1.02)),
        ("linear", AnnealingSchedule("linear", rate=0.5))
    ]:
        sim = DWaveSimulator(Q, sched)
        result = sim.anneal(n_reads=200, anneal_time=50.0)
        print(f"\n{name:>15} schedule:")
        print(f"  Best energy found: {result['best_energy']:.4f}")
        print(f"  Gap to optimal:    {result['best_energy'] - best_E_bf:.4f}")
        print(f"  Best solution:     {result['best_sample'].astype(int)}")


def demo_trotter_circuit():
    """Demo: Trotterized circuit for IBM."""
    print("\n" + "=" * 60)
    print("Demo 4: Trotterized Circuit for IBM")
    print("=" * 60)
    
    n = 4
    np.random.seed(42)
    Q = np.random.randn(n, n)
    Q = np.triu(Q)
    
    for n_steps in [5, 10, 20, 50]:
        circuit = TrotterCircuit(Q, n_trotter_steps=n_steps)
        circuit.build_circuit(total_time=1.0)
        counts = circuit.gate_count()
        error = circuit.trotter_error_bound()
        
        print(f"\nTrotter steps: {n_steps}")
        print(f"  CNOT gates:  {counts['CNOT']}")
        print(f"  RZ gates:    {counts['RZ']}")
        print(f"  RX gates:    {counts['RX']}")
        print(f"  Total gates: {counts['total']}")
        print(f"  Error bound: {error:.6f}")
    
    # Generate Qiskit code for smallest circuit
    circuit = TrotterCircuit(Q, n_trotter_steps=2)
    circuit.build_circuit()
    print("\n--- Qiskit Code (2 Trotter steps) ---")
    print(circuit.to_qiskit_str()[:500] + "\n...")


def demo_hybrid_optimization():
    """Demo: Hybrid quantum-classical optimization."""
    print("\n" + "=" * 60)
    print("Demo 5: Hybrid Quantum-Classical Optimization")
    print("=" * 60)
    
    n = 8
    np.random.seed(42)
    Q = np.random.randn(n, n)
    Q = np.triu(Q + Q.T)
    
    optimizer = HybridOptimizer(Q)
    result = optimizer.optimize(n_iterations=10, n_reads=50)
    
    print(f"\nFinal best energy: {result['best_energy']:.4f}")
    print(f"Best solution:     {result['best_solution'].astype(int)}")
    print(f"\nConvergence history:")
    print(f"{'Iter':>6} | {'Best E':>10} | {'Q-Best':>10} | {'Unique':>8}")
    print("-" * 45)
    for h in result['history']:
        print(f"{h['iteration']:>6} | {h['best_energy']:>10.4f} | {h['quantum_best']:>10.4f} | {h['n_unique']:>8}")


if __name__ == "__main__":
    demo_qubo_formulation()
    demo_annealing_schedules()
    demo_simulated_annealing()
    demo_trotter_circuit()
    demo_hybrid_optimization()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
