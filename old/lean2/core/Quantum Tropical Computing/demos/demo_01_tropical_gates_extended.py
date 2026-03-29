#!/usr/bin/env python3
"""
Demo 1: Extended Tropical Gate Visualizations
==============================================

Generates:
    - tropical_gate_zoo.png: All tropical gates and their properties
    - gate_composition_algebra.png: Composition rules and algebraic identities
    - maslov_gate_spectrum.png: How each gate varies with β
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from qtlib.gates import (
    TropicalHadamard, TropicalCNOT, TropicalPhase,
    TropicalToffoli, TropicalSWAP
)

plt.rcParams['figure.dpi'] = 150
plt.rcParams['font.size'] = 10


def plot_gate_zoo():
    """Visualize all tropical gates and their key properties."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle("The Quantum Tropical Gate Zoo", fontsize=16, fontweight='bold')

    # Test states
    states_2d = [np.array([a, b]) for a in np.linspace(-3, 3, 20) for b in np.linspace(-3, 3, 20)]
    states_3d = [np.array([a, b, c]) for a in [-1, 0, 1] for b in [-1, 0, 1] for c in [-1, 0, 1]]

    # 1. Hadamard: plot input vs output
    ax = axes[0, 0]
    a_vals = np.linspace(-3, 3, 50)
    b_vals = np.linspace(-3, 3, 50)
    A, B = np.meshgrid(a_vals, b_vals)
    H = TropicalHadamard()
    Z = np.array([[H.apply(np.array([a, b]))[0] for a in a_vals] for b in b_vals])
    im = ax.contourf(A, B, Z, levels=20, cmap='viridis')
    ax.set_xlabel('a'); ax.set_ylabel('b')
    ax.set_title('H_T(a,b)₁ = max(a,b)\n(Winner-Take-All)')
    plt.colorbar(im, ax=ax, label='output')
    ax.plot(a_vals, a_vals, 'r--', linewidth=2, label='a = b boundary')
    ax.legend()

    # 2. CNOT: target output
    ax = axes[0, 1]
    cnot = TropicalCNOT()
    Z_cnot = np.array([[cnot.apply(np.array([a, b]))[1] for a in a_vals] for b in b_vals])
    im = ax.contourf(A, B, Z_cnot, levels=20, cmap='plasma')
    ax.set_xlabel('control (a)'); ax.set_ylabel('target (b)')
    ax.set_title('CNOT_T(a,b)₂ = a + b\n(Synaptic Integration)')
    plt.colorbar(im, ax=ax, label='output')

    # 3. Phase gate
    ax = axes[0, 2]
    phis = np.linspace(-2, 2, 5)
    x_vals = np.linspace(-3, 3, 100)
    for phi in phis:
        P = TropicalPhase(phi)
        y_vals = [P.apply(np.array([x]))[0] for x in x_vals]
        ax.plot(x_vals, y_vals, label=f'φ = {phi:.1f}')
    ax.plot(x_vals, x_vals, 'k--', alpha=0.3, label='identity')
    ax.set_xlabel('input a'); ax.set_ylabel('output a + φ')
    ax.set_title('P_T(φ)(a) = a + φ\n(Synaptic Weight)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # 4. Hadamard idempotency vs quantum involution
    ax = axes[1, 0]
    inputs = np.linspace(-3, 3, 100)
    H = TropicalHadamard()
    h1 = [H.apply(np.array([x, 0.0]))[0] for x in inputs]
    h2 = [H.apply(H.apply(np.array([x, 0.0])))[0] for x in inputs]
    ax.plot(inputs, inputs, 'b-', linewidth=2, label='Identity (quantum H²=I)')
    ax.plot(inputs, h1, 'r-', linewidth=2, label='H_T (once)')
    ax.plot(inputs, h2, 'g--', linewidth=3, label='H_T² (twice)')
    ax.set_xlabel('input a (with b=0)')
    ax.set_ylabel('output')
    ax.set_title('H_T² = H_T (Idempotent!)\nvs Quantum H² = I (Involutive)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # 5. CNOT iteration
    ax = axes[1, 1]
    state = np.array([1.0, 0.5])
    cnot = TropicalCNOT()
    trajectory = [state.copy()]
    for _ in range(6):
        state = cnot.apply(state)
        trajectory.append(state.copy())
    traj = np.array(trajectory)
    ax.plot(traj[:, 0], 'bo-', label='control', markersize=8)
    ax.plot(traj[:, 1], 'rs-', label='target', markersize=8)
    ax.set_xlabel('Application #')
    ax.set_ylabel('Value')
    ax.set_title('CNOT_T iterated:\ntarget grows linearly (a, a+b, 2a+b, ...)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # 6. Toffoli gate: gating behavior
    ax = axes[1, 2]
    toff = TropicalToffoli()
    c_vals = np.linspace(-3, 3, 50)
    for b_val in [-2, 0, 2]:
        outputs = [toff.apply(np.array([a, b_val, -1.0]))[2] for a in c_vals]
        ax.plot(c_vals, outputs, label=f'b = {b_val:.0f}')
    ax.axhline(y=-1.0, color='k', linestyle='--', alpha=0.3, label='original c=-1')
    ax.set_xlabel('control a')
    ax.set_ylabel('target output')
    ax.set_title('Toffoli_T: max(c, a+b)\n(Gated Integration)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_gate_zoo.png'),
                bbox_inches='tight')
    print("Saved: tropical_gate_zoo.png")
    plt.close()


def plot_maslov_spectrum():
    """Show how each gate varies with Maslov parameter β."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Maslov Deformation Spectrum: β Controls Gate Sharpness",
                 fontsize=14, fontweight='bold')

    betas = np.logspace(-1, 2, 200)

    # Hadamard output for fixed input
    ax = axes[0]
    H = TropicalHadamard()
    for a, b in [(3, 1), (3, 2.5), (3, 3)]:
        state = np.array([float(a), float(b)])
        outputs = [H.apply_maslov(state, beta)[0] for beta in betas]
        ax.semilogx(betas, outputs, label=f'a={a}, b={b}')
    ax.axhline(y=3, color='k', linestyle='--', alpha=0.3, label='max')
    ax.set_xlabel('β (Maslov parameter)')
    ax.set_ylabel('H_T output (first component)')
    ax.set_title('Tropical Hadamard')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Toffoli output
    ax = axes[1]
    toff = TropicalToffoli()
    state = np.array([2.0, 1.0, -1.0])
    outputs = [toff.apply_maslov(state, beta)[2] for beta in betas]
    ax.semilogx(betas, outputs, 'b-', linewidth=2)
    ax.axhline(y=max(-1.0, 3.0), color='r', linestyle='--', alpha=0.5, label='max(-1, 2+1)=3')
    ax.set_xlabel('β')
    ax.set_ylabel('Toffoli target output')
    ax.set_title('Tropical Toffoli\n(max(c, a+b) as β→∞)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Entropy of softmax measurement vs β
    ax = axes[2]
    state = np.array([3.0, 2.0, 1.0, 0.0])
    from qtlib.circuits import TropicalCircuit
    circ = TropicalCircuit(4)
    entropies = []
    for beta in betas:
        probs = circ.tropical_probabilities(state, beta)
        entropy = -np.sum(probs * np.log(probs + 1e-30))
        entropies.append(entropy)
    ax.semilogx(betas, entropies, 'purple', linewidth=2)
    ax.axhline(y=np.log(4), color='gray', linestyle='--', alpha=0.5, label='max entropy (uniform)')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5, label='min entropy (WTA)')
    ax.set_xlabel('β')
    ax.set_ylabel('Shannon entropy')
    ax.set_title('Measurement Entropy\n(Quantum → Tropical)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'maslov_gate_spectrum.png'),
                bbox_inches='tight')
    print("Saved: maslov_gate_spectrum.png")
    plt.close()


def plot_composition_algebra():
    """Visualize gate composition rules."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("Tropical Gate Algebra: Composition Rules",
                 fontsize=14, fontweight='bold')

    # 1. H_T^n converges in 1 step
    ax = axes[0, 0]
    H = TropicalHadamard()
    state = np.array([3.0, -1.0])
    norms = [np.linalg.norm(state)]
    for n in range(1, 8):
        state = H.apply(state)
        norms.append(np.linalg.norm(state))
    ax.bar(range(len(norms)), norms, color=['blue'] + ['green'] * (len(norms)-1))
    ax.set_xlabel('Number of H_T applications')
    ax.set_ylabel('||state||')
    ax.set_title('H_T^n stabilizes at n=1\n(Idempotency: H_T² = H_T)')

    # 2. Phase gate composition: additive group
    ax = axes[0, 1]
    phis = np.linspace(0, 2*np.pi, 100)
    x0 = 1.0
    single_app = [x0 + phi for phi in phis]
    double_app = [x0 + phi + phi for phi in phis]
    ax.plot(phis, single_app, 'b-', label='P_T(φ)(x₀)')
    ax.plot(phis, double_app, 'r-', label='P_T(φ)²(x₀) = P_T(2φ)(x₀)')
    ax.plot(phis, [x0 + 2*phi for phi in phis], 'g--', linewidth=3, alpha=0.5,
            label='P_T(2φ)(x₀) [direct]')
    ax.set_xlabel('φ')
    ax.set_ylabel('output')
    ax.set_title('Phase Composition: P_T(φ)∘P_T(ψ) = P_T(φ+ψ)\n(Additive Group Structure)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # 3. CNOT_T power growth
    ax = axes[1, 0]
    cnot = TropicalCNOT()
    a_init, b_init = 1.0, 0.5
    control_vals = [a_init]
    target_vals = [b_init]
    state = np.array([a_init, b_init])
    for _ in range(10):
        state = cnot.apply(state)
        control_vals.append(state[0])
        target_vals.append(state[1])
    n_apps = range(len(control_vals))
    ax.plot(n_apps, control_vals, 'bo-', label='control: a')
    ax.plot(n_apps, target_vals, 'rs-', label=f'target: n·a + b')
    # Theoretical: CNOT^n(a,b) = (a, n*a + b)
    theoretical = [n * a_init + b_init for n in n_apps]
    ax.plot(n_apps, theoretical, 'g--', linewidth=2, label='theory: n·a + b')
    ax.set_xlabel('n (applications)')
    ax.set_ylabel('value')
    ax.set_title('CNOT_T^n(a,b) = (a, n·a + b)\n(Linear Accumulation)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # 4. SWAP is involutive
    ax = axes[1, 1]
    swap = TropicalSWAP()
    state = np.array([3.0, -1.0])
    states = [state.copy()]
    for _ in range(6):
        state = swap.apply(state)
        states.append(state.copy())
    traj = np.array(states)
    ax.plot(range(len(states)), traj[:, 0], 'bo-', markersize=10, label='qubit 0')
    ax.plot(range(len(states)), traj[:, 1], 'rs-', markersize=10, label='qubit 1')
    ax.set_xlabel('Application #')
    ax.set_ylabel('value')
    ax.set_title('SWAP_T² = I (Involutive)\n(Same as Quantum!)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'gate_composition_algebra.png'),
                bbox_inches='tight')
    print("Saved: gate_composition_algebra.png")
    plt.close()


if __name__ == "__main__":
    plot_gate_zoo()
    plot_maslov_spectrum()
    plot_composition_algebra()
    print("\nAll Demo 1 visualizations generated!")
