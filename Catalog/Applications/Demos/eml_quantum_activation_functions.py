#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Interactive Demo

Demonstrates the key results from the Quantum EML Spectral Pair theory:
1. EML Spectral Gap: exp(x) - log(x) > 2 for all x > 0
2. Quantum Phase Map: exp(iθ) traces the unit circle
3. EML Spectral Pair composition and bridge identity
4. Quantum-classical decomposition of neural activations
"""

import numpy as np

def eml(x: float, y: float) -> float:
    """The EML function: exp(x) - log(y)"""
    return np.exp(x) - np.log(y)

def eml_diag(x: float) -> float:
    """EML diagonal: exp(x) - log(x)"""
    return np.exp(x) - np.log(x)

def quantum_phase_map(theta: float) -> complex:
    """Quantum phase map: θ ↦ exp(iθ)"""
    return np.exp(1j * theta)

class EMLSpectralPair:
    """An EML Spectral Pair (phase, logScale) decomposing quantum-classical computation."""
    def __init__(self, phase: float, logScale: float):
        self.phase = phase
        self.logScale = logScale
    
    def quantum_gate(self) -> complex:
        """The unitary component exp(i·phase)"""
        return np.exp(1j * self.phase)
    
    def classical_info(self) -> float:
        """Classical information content"""
        return -self.logScale
    
    def quantum_amplitude(self) -> float:
        """Quantum amplitude exp(phase)"""
        return np.exp(self.phase)
    
    def eml_value(self) -> float:
        """Full EML value: exp(phase) - logScale"""
        return np.exp(self.phase) - self.logScale
    
    def spectral_norm(self) -> float:
        """Spectral norm: √(phase² + logScale²)"""
        return np.sqrt(self.phase**2 + self.logScale**2)
    
    def __add__(self, other):
        return EMLSpectralPair(self.phase + other.phase, self.logScale + other.logScale)
    
    def __repr__(self):
        return f"EMLSpectralPair(phase={self.phase:.4f}, logScale={self.logScale:.4f})"

class QuantumEMLNeuron:
    """A quantum EML neuron with weights and biases for both channels."""
    def __init__(self, w1: float, b1: float, w2: float, b2: float):
        self.w1 = w1
        self.b1 = b1
        self.w2 = w2
        self.b2 = b2
    
    def eval(self, x: float) -> EMLSpectralPair:
        return EMLSpectralPair(self.w1 * x + self.b1, self.w2 * x + self.b2)
    
    def quantum_output(self, x: float) -> complex:
        return self.eval(x).quantum_gate()
    
    def classical_output(self, x: float) -> float:
        return self.eval(x).eml_value()


def demo_spectral_gap():
    """Demonstrate: exp(x) - log(x) > 2 for all x > 0"""
    print("=" * 60)
    print("THEOREM 1: EML Spectral Gap")
    print("exp(x) - log(x) > 2 for all x > 0")
    print("=" * 60)
    
    test_points = [0.001, 0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0]
    print(f"{'x':>10} {'exp(x)':>12} {'log(x)':>12} {'eml_diag(x)':>14} {'> 2?':>6}")
    print("-" * 60)
    for x in test_points:
        val = eml_diag(x)
        print(f"{x:10.3f} {np.exp(x):12.4f} {np.log(x):12.4f} {val:14.4f} {'✓' if val > 2 else '✗':>6}")
    
    # Find approximate minimum
    xs = np.linspace(0.01, 5.0, 10000)
    vals = [eml_diag(x) for x in xs]
    min_idx = np.argmin(vals)
    print(f"\nApproximate minimum: eml_diag({xs[min_idx]:.4f}) = {vals[min_idx]:.6f}")
    print(f"(True minimum is at x = W(1) ≈ 0.5671 where W is Lambert W)")
    print(f"Minimum value ≈ {eml_diag(0.5671):.6f} > 2 ✓")


def demo_quantum_phase():
    """Demonstrate: exp(iθ) traces the unit circle with |exp(iθ)| = 1"""
    print("\n" + "=" * 60)
    print("THEOREM 2: Quantum Phase Map Properties")
    print("exp(iθ) has unit norm and is multiplicative")
    print("=" * 60)
    
    thetas = np.linspace(0, 2*np.pi, 9)
    print(f"{'θ':>8} {'exp(iθ)':>24} {'|exp(iθ)|':>12}")
    print("-" * 50)
    for t in thetas:
        z = quantum_phase_map(t)
        print(f"{t:8.4f} {z.real:+10.4f}{z.imag:+10.4f}i {abs(z):12.6f}")
    
    # Multiplicativity
    print("\nMultiplicativity: exp(i(θ₁+θ₂)) = exp(iθ₁)·exp(iθ₂)")
    t1, t2 = 1.2, 0.8
    lhs = quantum_phase_map(t1 + t2)
    rhs = quantum_phase_map(t1) * quantum_phase_map(t2)
    print(f"  θ₁={t1}, θ₂={t2}")
    print(f"  LHS = {lhs:.6f}")
    print(f"  RHS = {rhs:.6f}")
    print(f"  |LHS - RHS| = {abs(lhs - rhs):.2e} ✓")


def demo_bridge_identity():
    """Demonstrate: emlValue = quantumAmplitude + classicalInfo"""
    print("\n" + "=" * 60)
    print("THEOREM 3: EML Bridge Identity")
    print("emlValue = quantumAmplitude + classicalInfo")
    print("=" * 60)
    
    pairs = [
        EMLSpectralPair(0, 0),
        EMLSpectralPair(1, 0.5),
        EMLSpectralPair(-0.5, 2),
        EMLSpectralPair(2, -1),
        EMLSpectralPair(0.5, 0.5),
    ]
    
    print(f"{'phase':>8} {'logScale':>10} {'emlValue':>12} {'amp+info':>12} {'match?':>8}")
    print("-" * 55)
    for p in pairs:
        ev = p.eml_value()
        ai = p.quantum_amplitude() + p.classical_info()
        print(f"{p.phase:8.2f} {p.logScale:10.2f} {ev:12.4f} {ai:12.4f} {'✓' if abs(ev-ai) < 1e-10 else '✗':>8}")


def demo_composition():
    """Demonstrate: Composition decomposes into products and sums"""
    print("\n" + "=" * 60)
    print("THEOREM 4: EML Spectral Pair Composition")
    print("(p+q).emlValue = p.amp * q.amp + p.info + q.info")
    print("=" * 60)
    
    p = EMLSpectralPair(1.0, 0.5)
    q = EMLSpectralPair(0.5, -0.3)
    pq = p + q
    
    print(f"p = {p}")
    print(f"q = {q}")
    print(f"p+q = {pq}")
    print(f"\n(p+q).emlValue = {pq.eml_value():.6f}")
    rhs = p.quantum_amplitude() * q.quantum_amplitude() + p.classical_info() + q.classical_info()
    print(f"p.amp * q.amp + p.info + q.info = {rhs:.6f}")
    print(f"Match: {'✓' if abs(pq.eml_value() - rhs) < 1e-10 else '✗'}")
    
    # Quantum gate multiplicativity
    print(f"\n|p.gate| = {abs(p.quantum_gate()):.6f}")
    print(f"|q.gate| = {abs(q.quantum_gate()):.6f}")
    print(f"|(p+q).gate| = {abs(pq.quantum_gate()):.6f}")
    print(f"|p.gate * q.gate| = {abs(p.quantum_gate() * q.quantum_gate()):.6f}")
    print(f"(p+q).gate = p.gate * q.gate: {'✓' if abs(pq.quantum_gate() - p.quantum_gate() * q.quantum_gate()) < 1e-10 else '✗'}")


def demo_neuron():
    """Demonstrate: Quantum EML Neuron evaluation"""
    print("\n" + "=" * 60)
    print("QUANTUM EML NEURON DEMO")
    print("=" * 60)
    
    neuron = QuantumEMLNeuron(w1=2.0, b1=0.5, w2=1.0, b2=-0.3)
    
    xs = np.linspace(-1, 1, 9)
    print(f"Neuron: w₁={neuron.w1}, b₁={neuron.b1}, w₂={neuron.w2}, b₂={neuron.b2}")
    print(f"{'x':>6} {'quantum |z|':>14} {'classical f(x)':>16} {'phase':>10}")
    print("-" * 50)
    for x in xs:
        sp = neuron.eval(x)
        qo = neuron.quantum_output(x)
        co = neuron.classical_output(x)
        print(f"{x:6.2f} {abs(qo):14.6f} {co:16.4f} {sp.phase:10.4f}")


if __name__ == "__main__":
    demo_spectral_gap()
    demo_quantum_phase()
    demo_bridge_identity()
    demo_composition()
    demo_neuron()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Spectral Gap and Quantum Phase Properties

Generates plots showing:
1. The EML diagonal exp(x) - log(x) with the gap bound of 2
2. The quantum phase map exp(iθ) on the unit circle
3. EML spectral pair decomposition
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle

def plot_spectral_gap():
    """Plot the EML spectral gap: exp(x) - log(x) > 2."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Panel 1: EML diagonal
    ax = axes[0]
    x = np.linspace(0.01, 4, 500)
    y_diag = np.exp(x) - np.log(x)
    y_exp = np.exp(x)
    y_neg_log = -np.log(x)
    
    ax.plot(x, y_diag, 'b-', linewidth=2, label=r'$e^x - \ln x$ (EML diagonal)')
    ax.plot(x, y_exp, 'r--', alpha=0.5, label=r'$e^x$ (quantum)')
    ax.plot(x, y_neg_log, 'g--', alpha=0.5, label=r'$-\ln x$ (classical)')
    ax.axhline(y=2, color='orange', linestyle=':', linewidth=2, label='Gap bound = 2')
    
    # Mark minimum
    x_min = 0.5671  # W(1)
    y_min = np.exp(x_min) - np.log(x_min)
    ax.plot(x_min, y_min, 'ko', markersize=8, zorder=5)
    ax.annotate(f'min ≈ {y_min:.3f}', (x_min, y_min), 
                textcoords="offset points", xytext=(15, -15), fontsize=10)
    
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 12)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('EML Spectral Gap Theorem', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Quantum phase map
    ax = axes[1]
    theta = np.linspace(0, 2*np.pi, 100)
    z = np.exp(1j * theta)
    
    ax.plot(z.real, z.imag, 'b-', linewidth=2)
    
    # Mark key angles
    angles = [0, np.pi/4, np.pi/2, np.pi, 3*np.pi/2]
    labels = ['0', 'π/4', 'π/2', 'π', '3π/2']
    for a, lbl in zip(angles, labels):
        pt = np.exp(1j * a)
        ax.plot(pt.real, pt.imag, 'ro', markersize=8)
        ax.annotate(f'θ={lbl}', (pt.real, pt.imag), 
                    textcoords="offset points", xytext=(10, 5), fontsize=9)
    
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axhline(0, color='gray', linewidth=0.5)
    ax.axvline(0, color='gray', linewidth=0.5)
    ax.set_xlabel('Re', fontsize=12)
    ax.set_ylabel('Im', fontsize=12)
    ax.set_title('Quantum Phase Map: exp(iθ) ∈ U(1)', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    # Panel 3: EML value decomposition
    ax = axes[2]
    phases = np.linspace(-2, 3, 200)
    logScales = [0, 0.5, 1.0, -0.5]
    colors = ['blue', 'red', 'green', 'purple']
    
    for ls, c in zip(logScales, colors):
        eml_vals = np.exp(phases) - ls
        ax.plot(phases, eml_vals, color=c, linewidth=1.5, 
                label=f'logScale = {ls}')
    
    # Mark the quantum amplitude
    ax.plot(phases, np.exp(phases), 'k--', alpha=0.5, linewidth=1, 
            label='Quantum amplitude')
    
    ax.set_xlim(-2, 3)
    ax.set_ylim(-2, 10)
    ax.set_xlabel('Phase', fontsize=12)
    ax.set_ylabel('EML Value', fontsize=12)
    ax.set_title('EML Value = Amplitude + Info', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('quantum_eml_spectral_gap.png', dpi=150, bbox_inches='tight')
    print("Saved: quantum_eml_spectral_gap.png")
    plt.close()

def plot_neuron_outputs():
    """Plot quantum EML neuron dual-channel outputs."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Neuron parameters
    w1, b1, w2, b2 = 2.0, 0.5, 1.0, -0.3
    x = np.linspace(-1, 1, 200)
    
    # Phase and quantum gate
    phase = w1 * x + b1
    quantum_re = np.cos(phase)
    quantum_im = np.sin(phase)
    
    ax = axes[0]
    ax.plot(x, quantum_re, 'b-', linewidth=2, label='Re[gate]')
    ax.plot(x, quantum_im, 'r-', linewidth=2, label='Im[gate]')
    ax.plot(x, np.ones_like(x), 'k--', alpha=0.3, label='|gate| = 1')
    ax.set_xlabel('Input x', fontsize=12)
    ax.set_ylabel('Gate component', fontsize=12)
    ax.set_title('Quantum Channel: exp(i·(w₁x+b₁))', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Classical output
    ax = axes[1]
    classical = np.exp(phase) - (w2 * x + b2)
    amplitude = np.exp(phase)
    info = -(w2 * x + b2)
    
    ax.plot(x, classical, 'b-', linewidth=2, label='EML value')
    ax.plot(x, amplitude, 'r--', alpha=0.6, label='Quantum amplitude')
    ax.plot(x, info, 'g--', alpha=0.6, label='Classical info')
    ax.set_xlabel('Input x', fontsize=12)
    ax.set_ylabel('Output', fontsize=12)
    ax.set_title('Classical Channel: exp(w₁x+b₁) - (w₂x+b₂)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('quantum_eml_neuron.png', dpi=150, bbox_inches='tight')
    print("Saved: quantum_eml_neuron.png")
    plt.close()

if __name__ == "__main__":
    plot_spectral_gap()
    plot_neuron_outputs()
