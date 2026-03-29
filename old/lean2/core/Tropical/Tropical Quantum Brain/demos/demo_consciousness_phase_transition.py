#!/usr/bin/env python3
"""
Consciousness as a Tropical-Quantum Phase Transition
=====================================================

Simulates the phase transition between quantum-like (superposition)
and tropical (winner-take-all) regimes in neural networks.

Hypothesis: Consciousness arises at the critical point β = β_c where
the system transitions between diffuse multi-stable dynamics and
sharp winner-take-all selection.

Experiments:
1. Order parameter (winner dominance) vs β
2. Susceptibility (response to perturbation) peaks at β_c
3. Binocular rivalry simulation
4. Anesthesia simulation (β pushed away from critical)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

def softmax(x, beta=1.0):
    """Softmax with inverse temperature β"""
    x_shifted = beta * (x - np.max(x))
    e = np.exp(x_shifted)
    return e / e.sum()

def order_parameter(x, beta):
    """σ(β) = max probability - 1/N (measures winner dominance)
    
    σ = 0: uniform (no winner) — quantum-like
    σ = 1 - 1/N: perfect WTA — tropical
    """
    probs = softmax(x, beta)
    return np.max(probs) - 1.0 / len(x)

def susceptibility(x, beta, epsilon=0.01):
    """χ(β) = d(order_parameter)/dβ
    
    Peaks at the critical point β_c — maximum sensitivity to perturbation.
    """
    sigma_plus = order_parameter(x, beta + epsilon)
    sigma_minus = order_parameter(x, beta - epsilon)
    return (sigma_plus - sigma_minus) / (2 * epsilon)

def entropy(x, beta):
    """Shannon entropy of softmax distribution"""
    probs = softmax(x, beta)
    return -np.sum(probs * np.log(probs + 1e-15))

def simulate_binocular_rivalry(n_steps=1000, beta_mean=2.0, beta_std=0.5):
    """Simulate binocular rivalry as oscillation near tropical-quantum critical point.
    
    Two competing representations (left eye, right eye) with fluctuating β.
    When β > β_c: one percept dominates (conscious perception)
    When β < β_c: neither dominates (transition/mixed state)
    """
    # Two competing inputs with slight asymmetry
    input_left = 1.0
    input_right = 0.95
    
    dominance = np.zeros(n_steps)  # +1 = left, -1 = right
    beta_trace = np.zeros(n_steps)
    
    # Adaptation variable (winner gets fatigued)
    adaptation = np.array([0.0, 0.0])
    adapt_rate = 0.01
    adapt_recovery = 0.005
    
    for t in range(n_steps):
        # Fluctuating β (neuromodulatory noise)
        beta = beta_mean + beta_std * np.sin(2 * np.pi * t / 200) + np.random.randn() * 0.3
        beta = max(0.1, beta)
        beta_trace[t] = beta
        
        # Effective inputs (with adaptation)
        effective = np.array([input_left, input_right]) - adaptation
        
        # Softmax competition
        probs = softmax(effective, beta)
        
        # Dominance
        dominance[t] = probs[0] - probs[1]
        
        # Adaptation: winner gets fatigued
        winner = np.argmax(probs)
        adaptation[winner] += adapt_rate * probs[winner]
        adaptation *= (1 - adapt_recovery)  # recovery
    
    return dominance, beta_trace

def plot_phase_transition():
    """Main phase transition visualization"""
    fig = plt.figure(figsize=(20, 16))
    gs = GridSpec(3, 3, figure=fig, hspace=0.4, wspace=0.35)
    fig.suptitle('Consciousness at the Tropical-Quantum Phase Transition',
                fontsize=18, fontweight='bold')
    
    # ================================================================
    # Panel 1: Order parameter σ(β) — the phase transition
    # ================================================================
    ax = fig.add_subplot(gs[0, 0])
    np.random.seed(42)
    
    n_neurons = 10
    inputs = np.random.randn(n_neurons) + np.array([0, 0.5, 0, 0, 1.0, 0, 0, 0.3, 0, 0])
    
    betas = np.linspace(0.01, 15, 300)
    sigmas = [order_parameter(inputs, b) for b in betas]
    
    ax.plot(betas, sigmas, 'b-', linewidth=2)
    ax.fill_between(betas, 0, sigmas, alpha=0.1, color='blue')
    ax.set_xlabel('β (neural gain)', fontsize=12)
    ax.set_ylabel('Order parameter σ', fontsize=12)
    ax.set_title('Phase Transition: σ(β)')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    ax.grid(alpha=0.3)
    
    # Mark critical region
    chi_vals = [susceptibility(inputs, b) for b in betas]
    beta_c = betas[np.argmax(chi_vals)]
    ax.axvline(x=beta_c, color='red', linestyle='--', linewidth=2, label=f'β_c ≈ {beta_c:.1f}')
    ax.axvspan(beta_c - 1, beta_c + 1, alpha=0.1, color='red', label='Critical region')
    ax.legend()
    
    # ================================================================
    # Panel 2: Susceptibility χ(β) — peaks at critical point
    # ================================================================
    ax = fig.add_subplot(gs[0, 1])
    ax.plot(betas, chi_vals, 'r-', linewidth=2)
    ax.fill_between(betas, 0, chi_vals, alpha=0.1, color='red')
    ax.axvline(x=beta_c, color='red', linestyle='--', linewidth=2)
    ax.set_xlabel('β (neural gain)', fontsize=12)
    ax.set_ylabel('Susceptibility χ = dσ/dβ', fontsize=12)
    ax.set_title('Maximum Sensitivity at β_c')
    ax.annotate(f'β_c ≈ {beta_c:.1f}\n(conscious\nsweet spot)', 
               xy=(beta_c, max(chi_vals)), fontsize=10,
               xytext=(beta_c + 3, max(chi_vals) * 0.8),
               arrowprops=dict(arrowstyle='->', color='red'),
               color='red', fontweight='bold')
    ax.grid(alpha=0.3)
    
    # ================================================================
    # Panel 3: Entropy S(β) — information capacity
    # ================================================================
    ax = fig.add_subplot(gs[0, 2])
    entropies = [entropy(inputs, b) for b in betas]
    
    ax.plot(betas, entropies, 'g-', linewidth=2)
    ax.fill_between(betas, 0, entropies, alpha=0.1, color='green')
    ax.axvline(x=beta_c, color='red', linestyle='--', linewidth=2, label=f'β_c ≈ {beta_c:.1f}')
    ax.set_xlabel('β (neural gain)', fontsize=12)
    ax.set_ylabel('Shannon Entropy H', fontsize=12)
    ax.set_title('Information Capacity')
    ax.legend()
    ax.grid(alpha=0.3)
    
    # Annotate
    ax.annotate('High entropy\n(diffuse, many active)', xy=(0.5, max(entropies)*0.9),
               fontsize=9, ha='center', color='green')
    ax.annotate('Low entropy\n(focused, one winner)', xy=(12, 0.3),
               fontsize=9, ha='center', color='green')
    
    # ================================================================
    # Panel 4: Binocular Rivalry Simulation
    # ================================================================
    ax = fig.add_subplot(gs[1, :2])
    
    dominance, beta_trace = simulate_binocular_rivalry(n_steps=800, beta_mean=2.5, beta_std=0.8)
    
    t = np.arange(len(dominance))
    ax.fill_between(t, 0, dominance, where=dominance > 0.1, color='#3498db', alpha=0.5, label='Left eye dominant')
    ax.fill_between(t, 0, dominance, where=dominance < -0.1, color='#e74c3c', alpha=0.5, label='Right eye dominant')
    ax.fill_between(t, -0.1, 0.1, color='#f1c40f', alpha=0.3, label='Mixed/transition')
    ax.plot(t, dominance, 'k-', linewidth=0.5, alpha=0.5)
    
    ax.set_xlabel('Time (ms)', fontsize=12)
    ax.set_ylabel('Dominance (L − R)', fontsize=12)
    ax.set_title('Binocular Rivalry: Oscillation Near β_c', fontsize=13)
    ax.legend(loc='upper right', fontsize=9)
    ax.set_ylim(-1.2, 1.2)
    ax.grid(alpha=0.3)
    
    # ================================================================
    # Panel 5: β trace during rivalry
    # ================================================================
    ax = fig.add_subplot(gs[1, 2])
    ax.plot(t, beta_trace, 'purple', linewidth=1, alpha=0.7)
    ax.axhline(y=beta_c, color='red', linestyle='--', linewidth=2, label=f'β_c ≈ {beta_c:.1f}')
    ax.set_xlabel('Time (ms)', fontsize=12)
    ax.set_ylabel('β (neural gain)', fontsize=12)
    ax.set_title('Fluctuating β During Rivalry')
    ax.legend()
    ax.grid(alpha=0.3)
    
    # ================================================================
    # Panel 6: Anesthesia simulation
    # ================================================================
    ax = fig.add_subplot(gs[2, 0])
    
    anesthetic_doses = np.linspace(0, 5, 100)
    
    # Anesthesia pushes β away from critical
    # Model: β_effective = β_c · exp(-dose/2) (suppresses gain)
    beta_eff = beta_c * np.exp(-anesthetic_doses / 2)
    sigmas_anesthesia = [order_parameter(inputs, b) for b in beta_eff]
    chi_anesthesia = [susceptibility(inputs, b) for b in beta_eff]
    
    ax.plot(anesthetic_doses, chi_anesthesia, 'r-', linewidth=2, label='Susceptibility χ')
    ax.plot(anesthetic_doses, sigmas_anesthesia, 'b-', linewidth=2, label='Order param σ')
    ax.axvline(x=0, color='green', linestyle=':', label='Awake')
    
    ax.set_xlabel('Anesthetic Dose', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Anesthesia: β Pushed Below β_c')
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)
    
    # Mark LOC
    loc_dose = anesthetic_doses[np.argmax(np.array(chi_anesthesia) < max(chi_anesthesia) * 0.5)]
    ax.axvline(x=loc_dose, color='black', linestyle='--', alpha=0.5)
    ax.annotate('Loss of\nConsciousness', xy=(loc_dose, max(chi_anesthesia)*0.6),
               fontsize=9, ha='center', fontweight='bold')
    
    # ================================================================
    # Panel 7: Neuromodulator effects on β
    # ================================================================
    ax = fig.add_subplot(gs[2, 1])
    
    modulators = ['Baseline', 'Dopamine\n(↑ β)', 'Serotonin\n(↓ β)', 'Norepineph.\n(↓ β)', 'Acetylcholine\n(↑ precision)']
    beta_effects = [beta_c, beta_c * 1.5, beta_c * 0.6, beta_c * 0.7, beta_c * 1.2]
    colors_mod = ['gray', '#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    
    bars = ax.bar(range(len(modulators)), beta_effects, color=colors_mod, edgecolor='black')
    ax.axhline(y=beta_c, color='red', linestyle='--', linewidth=2, label=f'β_c = {beta_c:.1f}')
    ax.set_xticks(range(len(modulators)))
    ax.set_xticklabels(modulators, fontsize=9)
    ax.set_ylabel('Effective β', fontsize=12)
    ax.set_title('Neuromodulators Tune β', fontsize=13)
    ax.legend()
    ax.grid(axis='y', alpha=0.3)
    
    # ================================================================
    # Panel 8: Psychedelic simulation (low β)
    # ================================================================
    ax = fig.add_subplot(gs[2, 2])
    
    # Normal vs psychedelic β distributions
    beta_normal = np.random.normal(beta_c, 0.5, 1000)
    beta_psychedelic = np.random.normal(beta_c * 0.5, 0.8, 1000)
    
    ax.hist(beta_normal, bins=40, alpha=0.5, color='gray', label='Normal waking', density=True)
    ax.hist(beta_psychedelic, bins=40, alpha=0.5, color='purple', label='Psychedelic state', density=True)
    ax.axvline(x=beta_c, color='red', linestyle='--', linewidth=2, label=f'β_c = {beta_c:.1f}')
    ax.set_xlabel('β (neural gain)', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title('Psychedelics Lower β', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)
    
    plt.savefig(os.path.join(os.path.dirname(__file__), 'consciousness_phase_transition.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: consciousness_phase_transition.png")

def plot_tropical_decoherence():
    """Simulate quantum → tropical transition via decoherence"""
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    fig.suptitle('Decoherence IS Tropicalization', fontsize=16, fontweight='bold')
    
    # Simulate a 3-state quantum system undergoing decoherence
    n_states = 3
    
    # Initial quantum state (superposition)
    psi = np.array([1, np.exp(1j * np.pi/3), np.exp(1j * 2*np.pi/3)]) / np.sqrt(3)
    rho = np.outer(psi, psi.conj())  # density matrix
    
    # Hamiltonian
    H = np.array([[1.0, 0.3, 0.1],
                  [0.3, 2.0, 0.2],
                  [0.1, 0.2, 0.5]])
    
    # Decoherence rates
    gamma_vals = [0.0, 0.1, 0.5, 1.0, 5.0, 50.0]
    
    for idx, gamma in enumerate(gamma_vals):
        ax = axes[idx // 3, idx % 3]
        
        # Simulate Lindblad evolution
        dt = 0.01
        n_steps = 500
        rho_t = rho.copy()
        
        populations = np.zeros((n_steps, n_states))
        coherences = np.zeros(n_steps)
        
        for t in range(n_steps):
            populations[t] = np.real(np.diag(rho_t))
            coherences[t] = np.sum(np.abs(rho_t) - np.abs(np.diag(np.diag(rho_t))))
            
            # Unitary part
            drho = -1j * (H @ rho_t - rho_t @ H) * dt
            
            # Decoherence (dephasing)
            for i in range(n_states):
                for j in range(n_states):
                    if i != j:
                        drho[i, j] -= gamma * rho_t[i, j] * dt
            
            rho_t = rho_t + drho
            # Ensure Hermiticity
            rho_t = (rho_t + rho_t.conj().T) / 2
        
        time = np.arange(n_steps) * dt
        
        for i in range(n_states):
            ax.plot(time, populations[:, i], linewidth=2, label=f'P_{i}')
        ax.plot(time, coherences / coherences[0] if coherences[0] > 0 else coherences, 
                'k--', linewidth=1.5, alpha=0.5, label='Coherence')
        
        if gamma < 0.01:
            regime = "QUANTUM"
            color = 'blue'
        elif gamma > 10:
            regime = "TROPICAL"
            color = 'red'
        else:
            regime = "CRITICAL"
            color = 'green'
        
        ax.set_title(f'γ = {gamma} ({regime})', fontsize=12, color=color, fontweight='bold')
        ax.set_xlabel('Time')
        ax.set_ylabel('Population / Coherence')
        ax.legend(fontsize=8)
        ax.grid(alpha=0.3)
        ax.set_ylim(-0.05, 1.0)
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_decoherence.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: tropical_decoherence.png")

if __name__ == '__main__':
    print("=" * 60)
    print("CONSCIOUSNESS AT THE TROPICAL-QUANTUM PHASE TRANSITION")
    print("=" * 60)
    print()
    
    plot_phase_transition()
    plot_tropical_decoherence()
    
    print()
    print("HYPOTHESES demonstrated:")
    print("  H1: Consciousness ↔ critical point β ≈ β_c")
    print("  H2: Susceptibility (responsiveness) peaks at β_c")
    print("  H3: Anesthesia pushes β away from critical")
    print("  H4: Psychedelics lower β (expand quantum-like regime)")
    print("  H5: Neuromodulators tune β in real-time")
    print("  H6: Decoherence IS tropicalization of quantum dynamics")
    print()
    print("PREDICTIONS:")
    print("  P1: EEG criticality markers track β proximity to β_c")
    print("  P2: Binocular rivalry rate correlates with β_c distance")
    print("  P3: Anesthetic LOC shows sharp phase transition, not gradual")
