#!/usr/bin/env python3
"""
Quantum Phase Lattice Visualization Demo — ECSTASIS Framework

Generates visualizations of:
1. Quantum interference patterns as a function of relative phase
2. The Bloch sphere (projective Hilbert space for qubits)
3. Born rule probabilities
4. Channel contraction convergence
"""

import numpy as np
import json


def interference_pattern_data():
    """
    Compute ||psi + e^{i*theta}*phi||^2 for theta in [0, 2*pi].
    Shows constructive and destructive interference.
    """
    dim = 2
    psi = np.array([1.0, 0.0], dtype=complex)  # |0>
    phi = np.array([0.0, 1.0], dtype=complex)  # |1>
    
    thetas = np.linspace(0, 2 * np.pi, 200)
    intensities = []
    
    for theta in thetas:
        superposition = psi + np.exp(1j * theta) * phi
        intensities.append(np.linalg.norm(superposition) ** 2)
    
    return thetas.tolist(), intensities


def bloch_sphere_trajectory():
    """
    Compute a trajectory on the Bloch sphere under phase rotation.
    A qubit state |psi> = cos(theta/2)|0> + e^{i*phi}*sin(theta/2)|1>
    maps to (sin(theta)cos(phi), sin(theta)sin(phi), cos(theta)).
    """
    # Fix theta = pi/3, vary phi
    theta_bloch = np.pi / 3
    phis = np.linspace(0, 2 * np.pi, 100)
    
    xs = np.sin(theta_bloch) * np.cos(phis)
    ys = np.sin(theta_bloch) * np.sin(phis)
    zs = np.full_like(phis, np.cos(theta_bloch))
    
    return xs.tolist(), ys.tolist(), zs.tolist()


def born_probabilities():
    """
    Compute Born rule probability |<psi|phi>|^2 for various state pairs.
    """
    angles = np.linspace(0, np.pi, 100)
    probs = []
    
    for angle in angles:
        psi = np.array([1.0, 0.0], dtype=complex)
        phi = np.array([np.cos(angle), np.sin(angle)], dtype=complex)
        prob = abs(np.vdot(psi, phi)) ** 2
        probs.append(prob)
    
    return angles.tolist(), probs


def contraction_convergence():
    """
    Show geometric convergence of a contractive quantum channel.
    """
    dim = 2
    # Contractive channel: amplitude damping with gamma = 0.3
    gamma = 0.3
    M = np.array([[1, 0], [0, np.sqrt(1 - gamma)]], dtype=complex)
    op_norm = np.linalg.norm(M, ord=2)
    
    psi = np.array([0.0, 1.0], dtype=complex)  # Start in |1>
    
    iterations = list(range(20))
    norms = []
    bounds = []
    
    initial_norm = np.linalg.norm(psi)
    for n in iterations:
        norms.append(np.linalg.norm(psi))
        bounds.append(op_norm ** n * initial_norm)
        psi = M @ psi
    
    return iterations, norms, bounds


if __name__ == "__main__":
    print("Generating quantum phase lattice visualization data...")
    
    thetas, intensities = interference_pattern_data()
    bx, by, bz = bloch_sphere_trajectory()
    angles, probs = born_probabilities()
    iters, norms, bounds = contraction_convergence()
    
    data = {
        "interference": {"thetas": thetas, "intensities": intensities},
        "bloch": {"x": bx, "y": by, "z": bz},
        "born": {"angles": angles, "probabilities": probs},
        "contraction": {"iterations": iters, "norms": norms, "bounds": bounds}
    }
    
    with open("quantum_lattice_viz_data.json", "w") as f:
        json.dump(data, f, indent=2)
    
    print("Data saved to quantum_lattice_viz_data.json")
    print()
    
    # Print summary
    print("Interference pattern: min intensity = {:.4f}, max = {:.4f}".format(
        min(intensities), max(intensities)))
    print("Born probabilities: range [{:.4f}, {:.4f}]".format(
        min(probs), max(probs)))
    print("Contraction: final norm = {:.6f} (started at {:.6f})".format(
        norms[-1], norms[0]))
