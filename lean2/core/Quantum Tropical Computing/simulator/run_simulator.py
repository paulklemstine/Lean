#!/usr/bin/env python3
"""
Quantum Tropical Circuit Simulator — Interactive Demo
======================================================

Run: python3 simulator/run_simulator.py

Demonstrates:
    1. Basic gate operations and their tropical semantics
    2. Circuit composition and execution
    3. Maslov annealing (quantum → tropical transition)
    4. Entanglement detection via tropical rank
    5. Comparison of quantum vs. tropical computation
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import numpy as np
from qtlib.gates import (
    TropicalHadamard, TropicalCNOT, TropicalPhase,
    TropicalToffoli, TropicalSWAP, MaslovGate
)
from qtlib.circuits import TropicalCircuit, QuantumTropicalSimulator
from qtlib.tensor import tropical_tensor_product, tropical_rank, tropical_entanglement
from qtlib.semiring import TropicalFloat, maslov_add

np.set_printoptions(precision=4, suppress=True)


def banner(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_basic_gates():
    banner("1. BASIC TROPICAL GATE OPERATIONS")

    state = np.array([3.0, -1.0])
    print(f"Input state: {state}")
    print(f"  (Interpretation: log-probability of |0⟩ is 3.0, |1⟩ is -1.0)\n")

    # Hadamard
    H = TropicalHadamard()
    h_out = H.apply(state)
    print(f"After Tropical Hadamard H_T:")
    print(f"  H_T({state}) = {h_out}")
    print(f"  → Winner-take-all: both outputs get max(3, -1) = 3\n")

    # Idempotency check
    h_out2 = H.apply(h_out)
    print(f"H_T² (idempotency check):")
    print(f"  H_T(H_T({state})) = {h_out2}")
    print(f"  H_T² = H_T? {np.allclose(h_out, h_out2)} ← IDEMPOTENT (not involutive!)\n")

    # CNOT
    cnot = TropicalCNOT()
    cnot_out = cnot.apply(state)
    print(f"After Tropical CNOT:")
    print(f"  CNOT_T({state}) = {cnot_out}")
    print(f"  → Control preserved, target gets sum: -1 + 3 = 2\n")

    # Non-involutivity
    cnot_out2 = cnot.apply(cnot_out)
    print(f"CNOT_T² (non-involutivity check):")
    print(f"  CNOT_T²({state}) = {cnot_out2}")
    print(f"  CNOT_T² = I? {np.allclose(state, cnot_out2)} ← NOT INVOLUTIVE\n")

    # Phase gate
    phi = 1.5
    P = TropicalPhase(phi)
    p_out = P.apply(np.array([3.0]))
    print(f"Tropical Phase P_T(φ={phi}):")
    print(f"  P_T({3.0}) = {p_out[0]}")
    print(f"  → Synaptic weight: 3.0 + 1.5 = 4.5\n")

    # Toffoli
    state3 = np.array([2.0, 1.0, -1.0])
    toff = TropicalToffoli()
    toff_out = toff.apply(state3)
    print(f"Tropical Toffoli:")
    print(f"  Toffoli_T({state3}) = {toff_out}")
    print(f"  → Gated integration: target = max(-1, 2+1) = max(-1, 3) = 3\n")

    # SWAP
    swap = TropicalSWAP()
    swap_out = swap.apply(state)
    print(f"Tropical SWAP:")
    print(f"  SWAP_T({state}) = {swap_out}")
    swap_out2 = swap.apply(swap_out)
    print(f"  SWAP_T² = I? {np.allclose(state, swap_out2)} ← INVOLUTIVE (same as quantum)")


def demo_circuit():
    banner("2. TROPICAL CIRCUIT EXECUTION")

    circ = TropicalCircuit(n_qubits=2, name="Bell-like Circuit")
    circ.add(TropicalHadamard(target=0))
    circ.add(TropicalCNOT(control=0, target=1))
    circ.add(TropicalPhase(phi=0.5, target=1))

    print(circ)
    print()

    state = np.array([3.0, -1.0])
    print(f"Input: {state}")

    # Hard tropical execution
    result = circ.run(state, record_history=True)
    print(f"\nHard tropical (β = ∞):")
    for i, s in enumerate(circ.history):
        print(f"  Step {i}: {s}")
    print(f"  Measurement: qubit {circ.measure(result)}")

    # Maslov-deformed execution at different β
    for beta in [0.5, 1.0, 5.0, 50.0]:
        result_beta = circ.run(state, beta=beta)
        meas = circ.measure(result_beta)
        probs = circ.tropical_probabilities(result_beta, beta)
        print(f"\n  β = {beta:5.1f}: state = {result_beta}, "
              f"measurement = q{meas}, probs = {probs}")


def demo_maslov_annealing():
    banner("3. MASLOV ANNEALING (Quantum → Tropical Transition)")

    circ = TropicalCircuit(n_qubits=2)
    n_gates = 10
    for i in range(n_gates):
        if i % 3 == 0:
            circ.add(TropicalHadamard(target=0))
        elif i % 3 == 1:
            circ.add(TropicalCNOT(control=0, target=1))
        else:
            circ.add(TropicalPhase(phi=0.3 * (i+1), target=i % 2))

    state = np.array([1.0, -0.5])

    # Annealing schedule: start quantum (low β), end tropical (high β)
    betas = np.linspace(0.1, 20.0, n_gates)
    result = circ.run_annealing(state, betas.tolist())
    print(f"Input: {state}")
    print(f"Annealing schedule: β = {betas[0]:.1f} → {betas[-1]:.1f}")
    print(f"Output: {result}")

    # Compare with fixed β
    for beta in [0.1, 1.0, 20.0]:
        fixed_result = circ.run(state, beta=beta)
        print(f"Fixed β = {beta:5.1f}: {fixed_result}")


def demo_entanglement():
    banner("4. TROPICAL ENTANGLEMENT DETECTION")

    # Separable state: a_i + b_j
    a = np.array([1.0, 2.0, 3.0])
    b = np.array([0.5, -0.5])
    separable = tropical_tensor_product(a, b)
    print(f"Separable state (outer sum):")
    print(f"  a = {a}, b = {b}")
    print(f"  M = a ⊗_T b =\n{separable}")
    ent = tropical_entanglement(separable)
    print(f"  Tropical rank: {ent['rank']}")
    print(f"  Entangled? {ent['is_entangled']}")
    print(f"  Entanglement measure: {ent['entanglement_measure']:.4f}\n")

    # Entangled state: cannot be written as single outer sum
    entangled = np.array([
        [5.0, 1.0],
        [1.0, 5.0],
        [3.0, 3.0],
    ])
    print(f"Entangled state:")
    print(f"  M =\n{entangled}")
    ent2 = tropical_entanglement(entangled)
    print(f"  Tropical rank: {ent2['rank']}")
    print(f"  Entangled? {ent2['is_entangled']}")
    print(f"  Entanglement measure: {ent2['entanglement_measure']:.4f}")


def demo_simulator():
    banner("5. FULL QUANTUM TROPICAL SIMULATOR")

    sim = QuantumTropicalSimulator(n_qubits=3)
    sim.build_circuit([
        TropicalHadamard(target=0),
        TropicalCNOT(control=0, target=1),
        TropicalPhase(phi=1.0, target=2),
        TropicalToffoli(control1=0, control2=1, target=2),
    ])

    state = np.array([2.0, -1.0, 0.5])
    print(f"Circuit: H(0) → CNOT(0,1) → P(1.0)(2) → Toffoli(0,1,2)")
    print(f"Input: {state}")

    # Compare regimes
    results = sim.compare_regimes(state)
    for regime, res in results.items():
        print(f"\n  {regime:10s}: state = {res['final_state']}, "
              f"measurement = q{res['measurement']}")

    # Beta sweep
    print(f"\nβ sweep (quantum → tropical transition):")
    betas = np.array([0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0])
    sweep = sim.sweep_beta(state, betas)
    for i, beta in enumerate(betas):
        print(f"  β = {beta:6.1f}: entropy = {sweep['entropies'][i]:.4f}, "
              f"winner = q{sweep['measurements'][i]}")


def demo_tropical_arithmetic():
    banner("6. TROPICAL SEMIRING ARITHMETIC")

    a = TropicalFloat(3.0)
    b = TropicalFloat(5.0)
    c = TropicalFloat(-2.0)
    z = TropicalFloat.zero()
    o = TropicalFloat.one()

    print(f"a = {a}, b = {b}, c = {c}")
    print(f"Tropical zero (𝟘) = {z}")
    print(f"Tropical one  (𝟙) = {o}")
    print()
    print(f"a ⊕ b = max(3, 5) = {a + b}")
    print(f"a ⊗ b = 3 + 5 = {a * b}")
    print(f"a ⊕ 𝟘 = max(3, -∞) = {a + z}")
    print(f"a ⊗ 𝟙 = 3 + 0 = {a * o}")
    print(f"a ⊕ a = max(3, 3) = {a + a}  (idempotent!)")
    print(f"b ⊗ (a ⊕ c) = 5 + max(3, -2) = {b * (a + c)}")
    print(f"(b ⊗ a) ⊕ (b ⊗ c) = max(8, 3) = {(b * a) + (b * c)}")
    print(f"Distributive? {b * (a + c) == (b * a) + (b * c)}")
    print()

    # Maslov deformation
    print("Maslov deformation a ⊕_β b for a=3, b=5:")
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0]:
        result = maslov_add(3.0, 5.0, beta)
        print(f"  β = {beta:6.1f}: {result:.4f}  (max = 5.0)")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   QUANTUM TROPICAL CIRCUIT SIMULATOR                    ║")
    print("║   Exploring the quantum-tropical-neural triangle        ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_tropical_arithmetic()
    demo_basic_gates()
    demo_circuit()
    demo_maslov_annealing()
    demo_entanglement()
    demo_simulator()

    print(f"\n{'='*60}")
    print(f"  Simulation complete!")
    print(f"{'='*60}")
