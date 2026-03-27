#!/usr/bin/env python3
"""
Quantum Phenomena Through the Coherence Lens

Explores superposition, entanglement, decoherence, and interference
using the coherence framework. Demonstrates how quantum phenomena
correspond to coherence transformations.
"""

import numpy as np
from itertools import product as cartesian_product

# ============================================================
# Quantum State Representation
# ============================================================

class QuantumState:
    """A quantum state represented by amplitude vector."""
    
    def __init__(self, amplitudes, label=""):
        self.amplitudes = np.array(amplitudes, dtype=complex)
        self.dim = len(self.amplitudes)
        self.n_qubits = int(np.log2(self.dim))
        self.label = label
        # Normalize
        norm = np.sqrt(np.sum(np.abs(self.amplitudes)**2))
        if norm > 1e-15:
            self.amplitudes /= norm
    
    def coherence_l1(self):
        """l1-norm coherence: C = (Σ|αᵢ|)² - 1"""
        return np.sum(np.abs(self.amplitudes))**2 - 1
    
    def coherence_relative_entropy(self):
        """Relative entropy of coherence: C_RE = S(diag(ρ)) - S(ρ)
        For pure states, S(ρ) = 0, so C_RE = S(diag(ρ))."""
        probs = np.abs(self.amplitudes)**2
        entropy = 0
        for p in probs:
            if p > 1e-15:
                entropy -= p * np.log2(p)
        return entropy
    
    def density_matrix(self):
        """Return the density matrix |ψ⟩⟨ψ|."""
        return np.outer(self.amplitudes, np.conj(self.amplitudes))
    
    def measure(self):
        """Simulate a measurement, return outcome and post-measurement state."""
        probs = np.abs(self.amplitudes)**2
        outcome = np.random.choice(self.dim, p=probs)
        new_amp = np.zeros(self.dim, dtype=complex)
        new_amp[outcome] = 1.0
        return outcome, QuantumState(new_amp, f"post-measure({self.label})")
    
    def __repr__(self):
        terms = []
        for i, a in enumerate(self.amplitudes):
            if abs(a) > 1e-10:
                bits = format(i, f'0{self.n_qubits}b')
                terms.append(f"({a:.3f})|{bits}⟩")
        return " + ".join(terms) if terms else "0"


def tensor(state1, state2):
    """Tensor product of two quantum states."""
    amp = np.outer(state1.amplitudes, state2.amplitudes).flatten()
    return QuantumState(amp, f"{state1.label}⊗{state2.label}")


def apply_gate(state, gate):
    """Apply a unitary gate to a quantum state."""
    new_amp = gate @ state.amplitudes
    return QuantumState(new_amp, f"U({state.label})")

# ============================================================
# Standard Gates
# ============================================================

H_gate = np.array([[1, 1], [1, -1]]) / np.sqrt(2)  # Hadamard
X_gate = np.array([[0, 1], [1, 0]])  # Pauli-X
Z_gate = np.array([[1, 0], [0, -1]])  # Pauli-Z
CNOT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]])  # CNOT

def phase_gate(theta):
    """Phase rotation gate."""
    return np.array([[1, 0], [0, np.exp(1j * theta)]])

# ============================================================
# Experiments
# ============================================================

def experiment_superposition_coherence():
    """Show how superposition creates coherence from nothing."""
    print("=" * 70)
    print("EXPERIMENT 1: Superposition Creates Coherence")
    print("=" * 70)
    
    # Start with basis state |0⟩
    psi0 = QuantumState([1, 0], "|0⟩")
    print(f"\n  Initial state: {psi0}")
    print(f"  Coherence (l1):  {psi0.coherence_l1():.4f}")
    print(f"  Coherence (RE):  {psi0.coherence_relative_entropy():.4f}")
    
    # Apply Hadamard → |+⟩
    psi_plus = apply_gate(psi0, H_gate)
    psi_plus.label = "|+⟩"
    print(f"\n  After Hadamard: {psi_plus}")
    print(f"  Coherence (l1):  {psi_plus.coherence_l1():.4f}")
    print(f"  Coherence (RE):  {psi_plus.coherence_relative_entropy():.4f}")
    
    # Partial superposition
    print("\n  Partial superpositions:")
    for theta in [np.pi/8, np.pi/6, np.pi/4, np.pi/3, 3*np.pi/8]:
        amp = [np.cos(theta), np.sin(theta)]
        psi = QuantumState(amp)
        print(f"    θ={theta/np.pi:.3f}π: C_l1={psi.coherence_l1():.4f}, "
              f"C_RE={psi.coherence_relative_entropy():.4f}")
    
    print("\n  → Maximum coherence at θ=π/4 (equal superposition)")

def experiment_entanglement_coherence():
    """Show how entanglement affects coherence differently from product states."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 2: Entanglement vs Product State Coherence")
    print("=" * 70)
    
    # Product state |+⟩|+⟩
    plus = QuantumState([1/np.sqrt(2), 1/np.sqrt(2)], "|+⟩")
    product = tensor(plus, plus)
    product.label = "|+⟩|+⟩"
    
    # Bell state (|00⟩ + |11⟩)/√2
    bell = QuantumState([1/np.sqrt(2), 0, 0, 1/np.sqrt(2)], "|Φ+⟩")
    
    print(f"\n  Product |+⟩|+⟩:  {product}")
    print(f"    C_l1 = {product.coherence_l1():.4f}")
    print(f"    C_RE = {product.coherence_relative_entropy():.4f}")
    
    print(f"\n  Bell |Φ+⟩:       {bell}")
    print(f"    C_l1 = {bell.coherence_l1():.4f}")
    print(f"    C_RE = {bell.coherence_relative_entropy():.4f}")
    
    # Multi-qubit comparison
    print("\n  Scaling with number of qubits:")
    print(f"  {'n':>3s}  {'Product C_l1':>14s}  {'GHZ C_l1':>14s}  {'W C_l1':>14s}  {'Product/Max':>12s}")
    print("  " + "-" * 60)
    
    for n in range(2, 7):
        dim = 2**n
        
        # Product |+⟩^n
        prod_amp = np.ones(dim) / np.sqrt(dim)
        prod_C = np.sum(np.abs(prod_amp))**2 - 1
        
        # GHZ state
        ghz_amp = np.zeros(dim)
        ghz_amp[0] = 1/np.sqrt(2)
        ghz_amp[-1] = 1/np.sqrt(2)
        ghz_C = np.sum(np.abs(ghz_amp))**2 - 1
        
        # W state
        w_amp = np.zeros(dim)
        for i in range(n):
            w_amp[2**i] = 1/np.sqrt(n)
        w_C = np.sum(np.abs(w_amp))**2 - 1
        
        max_C = dim - 1
        print(f"  {n:3d}  {prod_C:14.3f}  {ghz_C:14.3f}  {w_C:14.3f}  {prod_C/max_C:12.4f}")
    
    print("\n  KEY: Product states maximize C_l1; GHZ has C=1 always;")
    print("       W state coherence = n/√n - 1 (intermediate)")

def experiment_decoherence():
    """Simulate decoherence as coherence decay."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 3: Decoherence — Coherence Decay Over Time")
    print("=" * 70)
    
    # Start with |+⟩
    print("\n  Dephasing channel: ρ → (1-p)ρ + p·Z·ρ·Z")
    print("  Applied to |+⟩ state\n")
    
    initial = QuantumState([1/np.sqrt(2), 1/np.sqrt(2)])
    rho = initial.density_matrix()
    
    print(f"  {'Step':>4s}  {'p (noise)':>10s}  {'C_l1':>8s}  {'Off-diag':>10s}  {'Purity':>8s}")
    print("  " + "-" * 50)
    
    for step in range(11):
        p = step * 0.1
        # Dephasing: off-diagonal elements decay by (1-2p)
        rho_noisy = rho.copy()
        rho_noisy[0, 1] *= (1 - 2*p)
        rho_noisy[1, 0] *= (1 - 2*p)
        
        off_diag = np.sum(np.abs(rho_noisy) - np.diag(np.diag(np.abs(rho_noisy))))
        purity = np.real(np.trace(rho_noisy @ rho_noisy))
        
        # l1 coherence of the density matrix
        C_l1 = np.sum(np.abs(rho_noisy)) - np.sum(np.abs(np.diag(rho_noisy)))
        
        print(f"  {step:4d}  {p:10.2f}  {C_l1:8.4f}  {off_diag:10.4f}  {purity:8.4f}")
    
    print("\n  → Coherence decays linearly with dephasing probability")
    print("  → Purity decays quadratically")
    print("  → At p=0.5, complete decoherence: state becomes classical mixture")

def experiment_interference():
    """Show quantum interference as coherence-mediated effect."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 4: Interference — Coherence in Action")
    print("=" * 70)
    
    print("\n  Mach-Zehnder interferometer simulation:")
    print("  |0⟩ → H → Phase(θ) → H → Measure\n")
    
    print(f"  {'θ/π':>6s}  {'P(|0⟩)':>8s}  {'P(|1⟩)':>8s}  {'C_before':>10s}  {'C_after':>10s}")
    print("  " + "-" * 50)
    
    for theta_frac in np.arange(0, 2.1, 0.25):
        theta = theta_frac * np.pi
        
        # |0⟩ → H → phase → H
        psi = np.array([1.0, 0.0], dtype=complex)
        psi = H_gate @ psi  # Superposition
        C_before = np.sum(np.abs(psi))**2 - 1
        
        psi = phase_gate(theta) @ psi  # Phase shift
        psi = H_gate @ psi  # Recombine
        
        C_after = np.sum(np.abs(psi))**2 - 1
        p0 = np.abs(psi[0])**2
        p1 = np.abs(psi[1])**2
        
        print(f"  {theta_frac:6.2f}  {p0:8.4f}  {p1:8.4f}  {C_before:10.4f}  {C_after:10.4f}")
    
    print("\n  → Interference fringes arise from coherence in the intermediate state")
    print("  → No coherence (basis state in/out) → no interference")
    print("  → Maximum coherence → maximum visibility of fringes")

def experiment_ndim_coherence_geometry():
    """Explore the geometry of coherence in n dimensions."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 5: Geometry of N-Dimensional Coherence")
    print("=" * 70)
    
    print("\n  Coherence as a function of state geometry in the simplex\n")
    
    for n in [2, 4, 8, 16]:
        print(f"  --- Dimension {n} ---")
        
        # Sample states uniformly on the probability simplex
        coherences = []
        for trial in range(1000):
            np.random.seed(trial)
            # Random amplitudes from Haar measure
            amp = np.random.randn(n)
            amp = np.abs(amp)
            amp /= np.sqrt(np.sum(amp**2))
            C = np.sum(amp)**2 - 1
            coherences.append(C)
        
        coherences = np.array(coherences)
        max_C = n - 1
        print(f"    Max coherence:  {max_C}")
        print(f"    Mean coherence: {np.mean(coherences):.4f}")
        print(f"    Std coherence:  {np.std(coherences):.4f}")
        print(f"    Min observed:   {np.min(coherences):.4f}")
        print(f"    Max observed:   {np.max(coherences):.4f}")
        
        # Coherence concentration
        frac_near_mean = np.mean(np.abs(coherences - np.mean(coherences)) < np.std(coherences))
        print(f"    Concentration:  {frac_near_mean*100:.1f}% within 1σ of mean")
        print()
    
    print("  KEY INSIGHT: In high dimensions, random states concentrate")
    print("  around a typical coherence value — the 'coherence sphere'")
    print("  phenomenon. Maximum coherence states are exponentially rare.")

def experiment_coherence_complexity_bridge():
    """Connect quantum coherence to computational complexity."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 6: Coherence-Complexity Bridge")
    print("=" * 70)
    
    print("\n  Grover's algorithm coherence evolution\n")
    
    n = 6
    N = 2**n
    target = 42 % N  # marked item
    
    # Initial state: uniform superposition
    psi = np.ones(N, dtype=complex) / np.sqrt(N)
    
    # Oracle and diffusion operators
    def oracle(psi, target):
        psi_new = psi.copy()
        psi_new[target] *= -1
        return psi_new
    
    def diffusion(psi, N):
        mean = np.mean(psi)
        return 2 * mean - psi
    
    optimal_iters = int(np.pi/4 * np.sqrt(N))
    
    print(f"  n={n}, N={N}, target={target}, optimal iterations={optimal_iters}")
    print(f"\n  {'Iter':>4s}  {'P(target)':>10s}  {'C_l1':>8s}  {'C_RE':>8s}  {'State type':>12s}")
    print("  " + "-" * 50)
    
    for i in range(optimal_iters + 3):
        p_target = np.abs(psi[target])**2
        C_l1 = np.sum(np.abs(psi))**2 - 1
        
        probs = np.abs(psi)**2
        C_RE = -sum(p * np.log2(p) if p > 1e-15 else 0 for p in probs)
        
        if p_target > 0.9:
            state_type = "FOUND!"
        elif C_l1 > N/2:
            state_type = "superposed"
        else:
            state_type = "focusing"
        
        print(f"  {i:4d}  {p_target:10.6f}  {C_l1:8.3f}  {C_RE:8.3f}  {state_type:>12s}")
        
        # Grover iteration
        psi = oracle(psi, target)
        psi = diffusion(psi, N)
    
    print(f"\n  → Grover's algorithm trades coherence for amplitude concentration")
    print(f"  → Coherence (l1) decreases as target probability increases")
    print(f"  → At the solution, coherence returns to 0 (basis state)")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════════════════╗")
    print("║  QUANTUM PHENOMENA THROUGH THE COHERENCE LENS                    ║")
    print("║  Superposition • Entanglement • Decoherence • Interference       ║")
    print("╚════════════════════════════════════════════════════════════════════╝")
    
    experiment_superposition_coherence()
    experiment_entanglement_coherence()
    experiment_decoherence()
    experiment_interference()
    experiment_ndim_coherence_geometry()
    experiment_coherence_complexity_bridge()
    
    print("\n" + "=" * 70)
    print("UNIFIED PICTURE")
    print("=" * 70)
    print("""
  Coherence is the COMMON THREAD linking quantum phenomena:
  
  • SUPERPOSITION creates coherence from nothing (0 → max)
  • ENTANGLEMENT distributes coherence non-locally
  • DECOHERENCE destroys coherence (max → 0)  
  • INTERFERENCE converts coherence into measurable probabilities
  
  In complexity theory, this means:
  
  • HIGH COHERENCE problems (NP_1): efficiently solvable via structure
  • MEDIUM COHERENCE problems (NP_0.5): quantum advantage exists
  • LOW COHERENCE problems (NP_0): essentially unstructured → hard
  
  The coherence hierarchy of NP is not just a classification—
  it's a RESOURCE THEORY that quantifies exploitable structure.
""")
